# Plano de implementação: Extrair sequência de fotogramas de um vídeo

**Branch**: `005-extrair-fotogramas` | **Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

**Input**: Especificação funcional em [spec.md](./spec.md), baseada no
`UC-VID-005` e nos requisitos `REQ-VID-FEX-*`.

## Summary

Estender o fluxo assíncrono de operações de vídeo para extrair uma sequência de
fotogramas JPEG de um vídeo autorizado e associá-los a um projeto. O Projects
Service continuará responsável por autorização, validação, quota, ciclo de vida
da operação e associação dos resultados. FFmpeg fará a extração para staging em
disco; os JPEG serão enviados incrementalmente para o Image Storage Service,
sem acumular até 5000 imagens em memória.

A operação terá um tipo próprio, fila e worker próprios. O vídeo original não
será alterado. Resultados parciais não serão apresentados na biblioteca: a
associação visível às imagens será feita apenas depois da extração e dos uploads
terem terminado com sucesso. Em cancelamento ou falha, a operação será marcada
com o estado correspondente, a quota será devolvida e os objetos temporários ou
já carregados serão removidos de forma idempotente.

## Baseline e fontes

- Baseline do repositório: commit `f782daa` da branch `main`.
- [Especificação UC-VID-005](./spec.md).
- [Caso de uso UC-VID-005](../../docs/use-cases/UC-VID-005-extrair-fotogramas.md).
- [Requisitos de vídeo](../../docs/RAS-requisitos-video.md).
- [Constituição do Spec Kit](../../.specify/memory/constitution.md).
- [Modelo de operação atual](../../projects/models/videoOperation.js).
- [Orquestração de operações atual](../../projects/services/videoOperationService.js).
- [Pipeline atual de fotogramas](../../projects/services/videoFramePipeline.js).

## Technical Context

**Language/Version**: Node.js/JavaScript nos serviços backend; TypeScript/React
no frontend; FFmpeg/FFprobe no container do Projects Service.

**Primary Dependencies**: Express, Mongoose, Axios, amqplib, SeaweedFS/S3,
RabbitMQ, Socket.IO, Next.js e as dependências já presentes no repositório.

**Storage**: MongoDB para projetos e operações; SeaweedFS/S3 para vídeos e
imagens; diretório temporário em disco para o vídeo descarregado e os JPEG em
staging.

**Testing**: Testes focados em `projects/test`, contratos HTTP, testes de
integração com RabbitMQ/storage/quota e validação manual dos cenários do
[quickstart.md](./quickstart.md), a criar na fase de design. A regressão do
fluxo de imagens existente é obrigatória.

**Target Platform**: Serviços Linux executados com Docker Compose e frontend
Next.js em browser suportado.

**Project Type**: Aplicação web distribuída com microserviços Node.js, fila de
mensagens e armazenamento de objetos.

**Performance Goals**: Criar a operação sem bloquear o pedido HTTP; emitir
progresso de uma operação demorada no máximo a cada 5 segundos, conforme os
requisitos transversais; processar resultados um a um ou em pequenos lotes
limitados, sem carregar o conjunto completo em memória.

**Constraints**:

- Apenas utilizadores registados e premium podem iniciar a operação.
- Os limites funcionais são 1000 fotogramas para registados e 5000 para
  premium; não serão introduzidos limites adicionais.
- O formato de saída do MVP é JPEG.
- O acesso ao projeto e ao vídeo deve ser verificado antes de criar a operação.
- O vídeo original deve permanecer imutável.
- Cancelamento e falha devem limpar staging, objetos carregados e referências
  não publicadas.
- Os estados existentes `queued`, `processing`, `completed`, `failed` e
  `cancelled` devem ser preservados no contrato interno.
- O contrato de aplicação das ferramentas de imagem não deve ser alterado por
  esta funcionalidade.

**Scale/Scope**: Um vídeo por operação, com projeto atual como destino por
omissão e suporte explícito a projeto novo. Pré-visualização dos primeiros
fotogramas, deteção de alteração visual e retoma de operações ficam fora do MVP.

## Constitution Check

*GATE: PASS antes da investigação e repetir após o design.*

- **Extensão incremental**: PASS — estende `VideoOperation`, as rotas e o
  pipeline existentes sem criar um serviço autónomo nem reescrever o fluxo de
  imagens.
- **MVP funcional**: PASS — cobre configuração, estimativa, validação,
  extração, persistência, progresso, cancelamento e limpeza.
- **Rastreabilidade**: PASS — a matriz abaixo liga requisitos a componentes e
  testes; os resultados serão registados no quickstart e nos testes executados.
- **Requisitos verificáveis**: PASS — limites, formato, estados e quota vêm da
  especificação e do catálogo consolidado.
- **Arquitetura baseada em evidência**: PASS — reutiliza os serviços, filas,
  eventos e modelos presentes no baseline; as alterações necessárias são
  explicitadas nas decisões arquiteturais.
- **Domínio**: PASS — o modelo trata vídeo, fotograma, projeto e operação como
  conceitos do domínio, sem expor classes ou tabelas como requisitos.
- **Responsabilidade da IA**: PASS — este plano identifica as fontes e deixa a
  validação da implementação e dos testes para a equipa.

## Architectural Decisions

### DA-07 — Operação e fila dedicadas para extração

Adicionar o tipo de operação `frame_extract` ao modelo de operações e publicar
numa fila dedicada de extração de fotogramas. O `videoOperationService` mantém
a autorização, a reserva/devolução de quota, a criação da operação e a
publicação do evento inicial; um worker dedicado executa a extração.

**Realiza**: `REQ-VID-FEX-006`, `REQ-VID-FEX-007`, `REQ-VID-FEX-011` e
`REQ-VID-COM-004` a `REQ-VID-COM-012`.

**Alternativa rejeitada**: reutilizar a operação `frame_tool`, porque essa fila
pressupõe que cada fotograma será enviado para ferramentas de imagem e que o
resultado final será recomposto como vídeo.

### DA-08 — Staging em disco e upload incremental

O worker descarregará o vídeo para staging em disco, executará FFmpeg para
produzir JPEG e enviará cada ficheiro, ou um lote limitado, para o storage sem
agregar todos os buffers em memória. O upload de imagens deverá aceitar um
ficheiro/stream e devolver a chave persistida; o endpoint de imagem existente
baseado em `memoryStorage()` não será usado diretamente para a sequência.

**Realiza**: `REQ-VID-FEX-004`, `REQ-VID-FEX-009`, `REQ-VID-FEX-011`,
`REQ-VID-Q-004` e `REQ-VID-COM-014`/`015`.

**Alternativa rejeitada**: guardar todos os JPEG em `file.buffer`, porque pode
consumir memória de forma proporcional ao número e dimensão dos fotogramas.

### DA-09 — Resultados privados até conclusão

Durante a operação, cada imagem será guardada com uma chave privada/temporária
e metadados de operação, projeto, vídeo de origem, índice e timestamp. As
referências públicas na biblioteca serão criadas numa etapa final idempotente.
Se a operação falhar ou for cancelada, as imagens já carregadas serão apagadas
antes de o estado final ser publicado como resultado.

**Realiza**: `REQ-VID-FEX-009`, `REQ-VID-FEX-011`, `REQ-VID-COM-014` a
`REQ-VID-COM-018` e `REQ-VID-FEX-NF-001`.

**Alternativa rejeitada**: inserir cada imagem diretamente em `project.imgs`,
porque uma falha a meio deixaria resultados parciais visíveis.

### DA-10 — Destino resolvido antes do processamento

A criação da operação resolverá o projeto de destino antes de publicar a
mensagem. Sem opção de novo projeto, o destino será o projeto ativo. Quando a
opção de novo projeto for usada, o sistema criará e autorizará esse projeto
antes de iniciar a extração; a operação guardará o `target_project_id` e os
resultados serão associados apenas a esse projeto.

**Realiza**: `REQ-VID-FEX-010` e `REQ-VID-COM-001` a `REQ-VID-COM-003`.

**Alternativa rejeitada**: criar o projeto durante o worker, porque falhas
posteriores poderiam deixar um projeto vazio sem relação clara com a operação.

## Project Structure

### Documentation (this feature)

```text
specs/005-extrair-fotogramas/
├── plan.md
├── research.md          # criado/atualizado na fase de pesquisa
├── data-model.md        # criado na fase de design
├── quickstart.md        # cenários e comandos de validação
├── contracts/
│   └── video-frame-extraction.md
└── tasks.md              # criado por /speckit-tasks
```

### Source Code (repository root)

```text
frontend/
├── components/project-page/project-video-list.tsx
├── lib/projects.ts
└── lib/mutations/projects.ts

apiGateway/routes/projects.js

projects/
├── models/videoOperation.js
├── models/project.js
├── routes/projects.js
├── services/videoOperationService.js
├── services/videoFrameExtractionWorker.js
├── services/videoFrameExtractionValidation.js
├── services/videoFrameExtractionErrors.js
├── services/videoFramePipeline.js
├── utils/project_msg.js
├── utils/rabbit_mq.js
└── test/

imageStorageService/
├── route/upload.js
└── services/uploadImage.js

wsGateway/
├── index.js
└── utils/project_events.js
```

**Structure Decision**: Não será criado um microserviço autónomo de vídeo. O
Projects Service será dono da operação e do domínio do projeto; o Image Storage
Service será estendido com uma entrada de upload adequada a ficheiros/streams;
o RabbitMQ e o WebSocket Gateway manterão os contratos de mensagens existentes.
O frontend reutilizará a listagem e o acompanhamento de operações de vídeo,
estendendo a configuração para intervalo, quantidade, estimativa e destino.

## Integration Design

### Criação e validação da operação

1. A rota existente de operações de vídeo recebe `videoId`, `startSeconds`,
   `endSeconds`, `maxFrames` e o destino escolhido.
2. O Projects Service autoriza o utilizador no projeto e confirma que o vídeo
   pertence ao projeto autorizado.
3. A validação obtém duração e FPS dos metadados existentes, normaliza o
   intervalo, rejeita parâmetros inválidos e calcula a estimativa de frames.
4. O sistema aplica o limite de 1000/5000 ao valor solicitado e à estimativa,
   rejeita uma estimativa de zero e verifica o espaço disponível antes de
   reservar quota.
5. Depois da validação, cria `frame_extract` com a configuração, o projeto de
   origem/destino, a estimativa e a quota reservada; só então publica a
   mensagem RabbitMQ e o evento `project-op`.

A criação deve ser transacional do ponto de vista do contrato: se quota,
criação, publicação ou validação falhar, não deve existir operação executável
nem referência de resultado.

### Execução do worker

1. O worker descarrega o vídeo de origem para um diretório temporário privado.
2. FFmpeg extrai diretamente para um padrão JPEG, limitado ao intervalo e à
   quantidade configurados.
3. O worker verifica cancelamento entre frames e antes de cada upload.
4. Cada JPEG é enviado incrementalmente ao storage com metadados de projeto,
   operação, vídeo de origem, índice e instante temporal.
5. O worker atualiza `progress` e publica eventos no máximo a cada 5 segundos,
   além das transições de estado.
6. Após todos os uploads, o Projects Service cria as referências finais das
   imagens no projeto de destino e marca a operação como `completed`.
7. O worker remove o staging local em sucesso, falha ou cancelamento.

A finalização e a limpeza devem ser idempotentes para tolerar uma mensagem
RabbitMQ repetida ou uma tentativa de cancelamento concorrente.

### Imagens e modelo de projeto

Cada referência de imagem extraída deve manter, no mínimo, a origem da
operação, o vídeo de origem, o índice do fotograma, o timestamp e a chave do
objeto JPEG. A alteração de `project.imgs` deve preservar o contrato de imagens
existente e permitir identificar os resultados sem tornar o vídeo original
mutável.

O modelo `VideoOperation` precisará de campos para tipo `frame_extract`,
`target_project_id`, `max_frames`, `estimated_frames`, `extracted_frames`,
`output_format` e a coleção de resultados/chaves temporárias. Os nomes finais e
a estratégia de migração serão confirmados em `data-model.md`; não se deve
quebrar operações `trim` ou `frame_tool` já existentes.

### API, eventos e frontend

- Reutilizar os endpoints existentes de criação, consulta e cancelamento de
  operações de vídeo, distinguindo o tipo `frame_extract` no Projects Service.
- Preservar no API Gateway os cabeçalhos de autenticação, caller e perfil.
- Usar `project-op` para `queued`, `processing`, progresso, `completed`,
  `failed` e `cancelled`; o payload não deve expor chaves temporárias nem paths
  internos.
- Atualizar a biblioteca de vídeos para abrir a configuração, apresentar a
  estimativa e mostrar imagens apenas após `completed`.
- Atualizar a biblioteca do projeto novo quando esse destino for escolhido,
  sem misturar eventos de outro projeto.

## Phase 0 — Research

1. Confirmar no Projects Service o contrato atual de criação, consulta e
   cancelamento e a máquina de estados de `VideoOperation`.
2. Confirmar o mecanismo de quota e refund no Users Service, incluindo a
   semântica para premium e operações canceladas.
3. Confirmar como o Image Storage Service pode receber ficheiros/streams e
   apagar objetos por chave sem alterar o upload de imagens existente.
4. Confirmar a forma de consultar espaço disponível no storage e definir a
   política de reserva suficiente para até 5000 JPEG, sem inventar uma quota de
   bytes não documentada.
5. Confirmar a semântica FFmpeg para intervalo, FPS de origem, limite de
   frames, JPEG e timestamps, incluindo vídeos sem frames no intervalo.
6. Confirmar a autorização e a atualização de versão ao adicionar imagens a um
   projeto ou ao criar um projeto de destino.
7. Registar resultados, alternativas e riscos em [research.md](./research.md).

## Phase 1 — Design and contracts

1. Definir o modelo de dados e a máquina de estados em [data-model.md](./data-model.md),
   incluindo a relação vídeo → operação → fotograma → projeto.
2. Definir o contrato HTTP, payload RabbitMQ, eventos WebSocket e mensagens de
   erro públicas em [contracts/video-frame-extraction.md](./contracts/video-frame-extraction.md).
3. Definir cenários de aceitação automatizados e manuais, comandos, fixtures e
   evidências em [quickstart.md](./quickstart.md).
4. Produzir uma matriz requisito → módulo → teste para garantir cobertura de
   `REQ-VID-FEX-001` a `011` e dos requisitos transversais aplicáveis.
5. Reavaliar o Constitution Check após fechar os contratos e antes de gerar
   tarefas.

## Validation and implementation sequence

1. Estender o modelo e os validadores sem alterar o comportamento de `trim` e
   `frame_tool`; executar os testes existentes do modelo e das transições.
2. Implementar criação, autorização, destino, estimativa, limites, espaço e
   quota da operação; testar rejeições sem publicação na fila.
3. Implementar a fila e o worker `frame_extract`, FFmpeg para JPEG e staging em
   disco; testar contagem, intervalo, formato e não alteração do hash do vídeo.
4. Implementar upload incremental, metadados das imagens e finalização atómica;
   testar 1, 1000 e 5000 frames sem acumulação de buffers.
5. Implementar cancelamento cooperativo, cleanup idempotente, refund e estados
   de falha; testar cancelamento em fila, durante upload e após conclusão.
6. Integrar eventos WebSocket e frontend; testar que estimativas, progresso,
   estado final e biblioteca respeitam o projeto autorizado.
7. Testar o destino no projeto ativo e num projeto novo, incluindo falha antes e
   depois da criação do destino.
8. Executar a regressão dos fluxos de imagens, submissão de vídeo, trim e
   `frame_tool`, e registar comandos e resultados no quickstart.

## Traceability Matrix

| Requirement group | Components | Planned validation |
| --- | --- | --- |
| `REQ-VID-FEX-001`, `REQ-VID-FEX-002`, `REQ-VID-FEX-003`, `REQ-VID-FEX-004` e `REQ-VID-FEX-005` | Frontend, `videoFrameExtractionValidation`, `VideoOperation` | Configuração, formato, cálculo de estimativa e rejeição de intervalo/zero frames |
| `REQ-VID-FEX-006`, `REQ-VID-FEX-007` e `REQ-VID-FEX-008` | `videoOperationService`, Users Service, storage adapter | Limites por perfil, quota e espaço insuficiente antes da fila |
| `REQ-VID-FEX-009` e `010` | Extraction worker, Image Storage Service, `Project` model/controller, frontend | JPEG persistido no projeto atual/novo e visibilidade apenas após conclusão |
| `REQ-VID-FEX-011` | Extraction worker, cleanup/storage, operation service | Falha e cancelamento removem staging, objetos e resultados não publicados |
| `REQ-VID-COM-001` a `003` | Projects routes/service, API Gateway, WebSocket/project events | Acesso cruzado a projeto, vídeo, imagens e eventos |
| `REQ-VID-COM-004` a `008` | `videoOperationService`, Users Service | Reserva/refund de quota em sucesso, falha e cancelamento |
| `REQ-VID-COM-009` a `013` | `VideoOperation`, RabbitMQ, WebSocket Gateway | Estados, erro persistido, eventos e isolamento do projeto |
| `REQ-VID-COM-014` a `020` | Worker, storage, project model, frontend | Limpeza, ausência de resultado parcial, preservação e publicação final |
| `REQ-VID-Q-001` a `005` | Todos os componentes integrados | Cenários de aceitação, hash, progresso e autorização |

## Risks and Mitigations

- **Memória elevada no upload de imagens**: usar ficheiros/streams e apagar cada
  staging depois de persistido; não reutilizar `memoryStorage()` para o lote.
- **Resultados parciais após falha**: manter imagens privadas e finalizar as
  referências numa etapa única; cleanup deve ser repetível.
- **Cancelamento concorrente com conclusão**: usar transições condicionais e
  confirmar o estado persistido antes de publicar o resultado.
- **Inconsistência entre projetos**: resolver e autorizar o destino na criação,
  persistir `target_project_id` e verificar autorização em todas as consultas.
- **Mensagens RabbitMQ repetidas**: tornar processamento, finalização e limpeza
  idempotentes através do identificador da operação.
- **Espaço de armazenamento difícil de estimar**: confirmar na pesquisa o
  contrato real do storage; se não existir uma medição fiável, bloquear a
  operação com uma decisão explícita em vez de inventar uma fórmula.
- **Regressão do pipeline de fotogramas existente**: separar o worker de
  extração do `videoFrameToolWorker` e executar testes de trim/frame_tool após
  cada alteração comum ao modelo ou mensagens.

## Complexity Tracking

Não há violações da constituição que exijam justificação.

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --- | --- | --- |
| Nenhuma | N/A | N/A |
