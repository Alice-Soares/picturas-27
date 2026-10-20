# Especificação: Conversão de Formato e Resolução de Vídeo

**Feature Branch**: `004-video-conversion`

**Created**: 2026-10-20

**Status**: Draft

**Input**: `UC-VID-004 — Converter Formato e Resolução de Vídeo`, com os
requisitos `REQ-VID-CONV-*` e os requisitos transversais `REQ-VID-COM-*` e
`REQ-VID-Q-*`.

## Enquadramento e âmbito

Esta funcionalidade implementa o `UC-VID-004`. Permite a um utilizador
registado ou premium, com acesso ao projeto, escolher uma combinação suportada
de contentor, codec e resolução para criar uma nova versão de um vídeo.
Valida as opções antes de iniciar uma operação assíncrona, comunica o seu
progresso e disponibiliza o resultado no projeto sem alterar o vídeo original.

O MVP cobre a conversão de vídeos válidos já submetidos ao projeto. Inclui a
validação de combinações suportadas, os limites de resolução por perfil, a
estimativa de tamanho quando disponível, o acompanhamento, cancelamento,
limpeza e tratamento de falhas. Não inclui edição temporal, aplicação de
ferramentas aos fotogramas, concatenação ou gestão independente de áudio, que
pertencem aos restantes casos de uso de vídeo.

**Fontes de verdade consultadas**:

- [UC-VID-004 — Converter Formato e Resolução de Vídeo](../../docs/use-cases/UC-VID-004-converter-formato-resolucao.md)
- [RAS — requisitos de vídeo](../../docs/RAS-requisitos-video.md)
- [Diretrizes da Fase 1](../../docs/diretrizes_fase_1.md)
- [README do PictuRAS](../../README.md)
- [Especificação do UC-VID-001](../001-video-submission/spec.md)
- [Especificação do UC-VID-002](../002-video-trim/spec.md)
- Baseline do repositório: commit `f782daa5f969b00c2dfb50babbc27b99719e837f`
  da branch `relatorio`.

## Clarifications

### Session 2026-10-20

- Q: A conversão deve ser implementada como um microserviço autónomo em
  `Tools/`, com container Docker próprio, consumidor RabbitMQ e exposição ao
  utilizador através do Projects Service e do frontend? → A: Sim, Tool
  autónoma em `Tools/` com container e worker RabbitMQ.

## User Scenarios & Testing

### User Story 1 — Configurar uma conversão válida (Priority: P1)

Como utilizador registado ou premium com acesso ao projeto, quero consultar as
propriedades do vídeo e escolher um formato, codec e resolução suportados, para
obter uma versão adequada ao meu contexto de utilização.

**Why this priority**: A configuração validada é o valor central da
funcionalidade e permite adaptar o vídeo sem perder o original.

**Independent Test**: Selecionar um vídeo válido, abrir a conversão, verificar
os metadados de origem, escolher uma combinação suportada e confirmar que a
resolução é aceite pelo perfil.

**Acceptance Scenarios**:

1. **Given** um vídeo acessível no projeto, **When** o utilizador abre a opção
   de conversão, **Then** o sistema apresenta o contentor e os metadados
   relevantes do vídeo de origem.
2. **Given** um perfil e um vídeo válidos, **When** o utilizador consulta as
   opções de conversão, **Then** o sistema apresenta apenas contentores,
   codecs e combinações suportadas pelo MVP e pelo perfil.
3. **Given** uma combinação suportada e uma resolução dentro do limite do
   perfil, **When** o utilizador a seleciona, **Then** o sistema aceita a
   configuração e, quando conseguir calcular, apresenta uma estimativa do
   tamanho do resultado.

### User Story 2 — Criar e acompanhar o vídeo convertido (Priority: P1)

Como utilizador, quero confirmar uma conversão e acompanhar o seu progresso,
para saber quando a nova versão está pronta para ser utilizada.

**Why this priority**: A conversão pode demorar e o resultado só é útil se for
guardado e disponibilizado de forma clara.

**Independent Test**: Confirmar uma configuração válida, observar a operação
em fila e em processamento, aguardar a conclusão e verificar que o novo vídeo
aparece no projeto com os parâmetros pedidos.

**Acceptance Scenarios**:

1. **Given** uma configuração validada, **When** o utilizador confirma a
   conversão, **Then** o sistema cria uma operação assíncrona e informa o
   utilizador do estado inicial.
2. **Given** uma operação em processamento, **When** o sistema produz
   progresso, **Then** o utilizador autorizado recebe atualizações de estado e
   progresso relativas à operação.
3. **Given** uma operação concluída, **When** o utilizador consulta o projeto,
   **Then** o sistema disponibiliza um novo vídeo com o contentor, codec e
   resolução selecionados, mantendo o vídeo original inalterado.

### User Story 3 — Rejeitar, cancelar e recuperar conversões (Priority: P1)

Como proprietário do sistema, quero que configurações inválidas, operações
não autorizadas, cancelamentos e falhas terminem de forma segura, sem resultados
parciais nem temporários acessíveis.

**Why this priority**: A validação e a recuperação preservam a segurança, a
quota e a integridade dos conteúdos do projeto.

**Independent Test**: Tentar combinações incompatíveis, resoluções acima do
limite, acesso a um projeto não autorizado, cancelamento em cada estado
permitido e uma falha de processamento; confirmar rejeição, estado final,
limpeza e preservação do original.

**Acceptance Scenarios**:

1. **Given** uma combinação de contentor e codec não suportada, **When** o
   utilizador tenta confirmá-la, **Then** o sistema rejeita a configuração,
   explica que a combinação não é suportada e não cria uma operação.
2. **Given** uma resolução acima do limite do perfil, **When** o utilizador a
   seleciona ou confirma, **Then** o sistema rejeita a configuração e não
   inicia processamento.
3. **Given** uma operação em fila ou em processamento, **When** o utilizador a
   cancela, **Then** o sistema interrompe a conversão, remove os temporários,
   marca a operação como cancelada e não disponibiliza resultado parcial.
4. **Given** uma falha de conversão ou armazenamento, **When** a operação
   termina, **Then** o sistema marca-a como falhada, apresenta uma mensagem
   segura, remove temporários e mantém o original acessível e inalterado.
5. **Given** um utilizador sem acesso ao projeto ou ao vídeo, **When** tenta
   consultar metadados, iniciar a conversão ou receber os seus eventos,
   **Then** o sistema rejeita o acesso sem revelar dados do projeto.

### Edge Cases

- Uma resolução que exceda a largura **ou** a altura máxima do perfil é
  inválida, mesmo que a outra dimensão esteja dentro do limite.
- Uma combinação não suportada deve ser rejeitada antes da criação da
  operação; não deve depender da falha posterior do processamento.
- Uma estimativa de tamanho pode não estar disponível; nesse caso o sistema
  deve permitir continuar sem apresentar uma estimativa inventada.
- A tentativa de converter um vídeo de origem inválido ou entretanto
  inacessível deve ser rejeitada antes do processamento.
- O cancelamento depois da conclusão não elimina o resultado concluído.
- Uma falha após a criação de temporários não deve deixar objetos acessíveis ou
  referências de vídeo parciais.
- O vídeo original, os seus metadados e a sua referência no projeto não podem
  ser substituídos pela conversão.
- A conversão em lote e os perfis predefinidos ficam fora do MVP desta
  especificação, salvo decisão posterior documentada no caso de uso.

## Requirements

### Functional Requirements

- **REQ-VID-CONV-001**: O sistema deve apresentar o contentor de origem e os
  metadados disponíveis do vídeo selecionado antes da confirmação.
- **REQ-VID-CONV-002**: O sistema deve apresentar os contentores de saída
  suportados pelo MVP para o perfil do utilizador.
- **REQ-VID-CONV-003**: O sistema deve apresentar os codecs de saída suportados
  para cada contentor apresentado.
- **REQ-VID-CONV-004**: O sistema deve permitir selecionar uma resolução de
  saída.
- **REQ-VID-CONV-005**: O sistema deve rejeitar uma combinação de contentor e
  codec não suportada antes de criar uma operação.
- **REQ-VID-CONV-006**: O sistema deve rejeitar uma resolução cuja largura ou
  altura exceda 1920x1080 para utilizadores registados não premium.
- **REQ-VID-CONV-007**: O sistema deve rejeitar uma resolução cuja largura ou
  altura exceda 3840x2160 para utilizadores premium.
- **REQ-VID-CONV-008**: O sistema deve apresentar uma estimativa do tamanho do
  resultado antes da confirmação quando esta puder ser calculada, e deve
  indicar quando a estimativa não estiver disponível.
- **REQ-VID-CONV-009**: O sistema deve executar uma conversão validada de forma
  assíncrona, sem bloquear a confirmação até ao fim do processamento.
- **REQ-VID-CONV-010**: O sistema deve guardar o vídeo convertido como novo
  conteúdo no projeto sem substituir o vídeo original.
- **REQ-VID-CONV-011**: O sistema deve comunicar o estado e o progresso da
  conversão aos utilizadores autorizados durante o processamento.

Os requisitos transversais aplicáveis são `REQ-VID-COM-001` a
`REQ-VID-COM-020` e `REQ-VID-Q-001` a `REQ-VID-Q-016`, conforme o catálogo
consolidado. Em particular, a funcionalidade deve verificar autorização ao
nível do projeto e do conteúdo, reservar e devolver quota conforme o resultado,
registar estados e erros, proteger resultados e eventos contra acesso cruzado,
e limpar temporários após falhas ou cancelamentos.

### Key Entities

- **Vídeo de origem**: conteúdo válido já associado a um projeto, com
  contentor, codec, resolução, duração e áudio opcional; permanece imutável.
- **Configuração de conversão**: seleção validada de contentor, codec e
  resolução de saída, associada ao perfil e ao vídeo de origem.
- **Operação de vídeo**: trabalho assíncrono com identificador, utilizador,
  projeto, origem, configuração, estado, progresso, timestamps, erro opcional
  e resultado opcional.
- **Vídeo convertido**: novo conteúdo derivado do vídeo de origem, com os
  metadados de saída e associação ao projeto.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Em 100% das conversões válidas concluídas, o projeto contém um
  novo vídeo cujos contentor, codec e resolução correspondem à configuração
  confirmada.
- **SC-002**: 100% das combinações incompatíveis e resoluções acima do limite
  testadas são rejeitadas antes da criação de uma operação.
- **SC-003**: Em 100% das conversões concluídas, o vídeo original mantém a
  mesma referência, metadados e conteúdo observados antes da operação.
- **SC-004**: 100% das operações canceladas ou falhadas testadas ficam sem
  resultado parcial ou temporário acessível e terminam com o estado correto.
- **SC-005**: Pelo menos 95% das atualizações de progresso observadas numa
  operação demorada chegam apenas a clientes autorizados do projeto.
- **SC-006**: Um utilizador autorizado consegue configurar e confirmar uma
  conversão válida em até 2 minutos após selecionar o vídeo.

## Assumptions

- O `UC-VID-001` já disponibiliza vídeos válidos, metadados e associação a um
  projeto autorizado.
- Os limites de resolução são os definidos em `UC-VID-004/RN2` e no catálogo
  `REQ-VID-CONV-006`/`007`; não são alterados por esta especificação.
- O MVP aceita as combinações de entrada e saída explicitamente mantidas na
  lista de suporte do sistema; a implementação não deve prometer formatos ou
  codecs não documentados.
- Estados, quota, autorização, armazenamento e eventos seguem os requisitos
  transversais já definidos para vídeo.
- A conversão é uma Tool autónoma em `Tools/`, com container Docker próprio,
  consumidor RabbitMQ e worker de processamento. O Projects Service e o
  frontend expõem e acompanham a funcionalidade, mas não executam a
  transcodificação. A entrega deve atualizar a secção de ferramentas e a
  secção **Adding a new tool** do [README](../../README.md), bem como seguir os
  passos de registo, serviço e exposição ao utilizador aí descritos.
- A estimativa de tamanho é informativa e não substitui a validação final do
  resultado.

## Out of Scope

- Substituir ou apagar o vídeo original.
- Conversão anónima, enquanto não existir uma regra transversal aprovada.
- Conversão em lote, perfis predefinidos e edição temporal.
- Definir novos limites de quota, duração, tamanho, FPS, formatos ou codecs
  além dos documentos de requisitos consultados.
