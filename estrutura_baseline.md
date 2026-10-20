# Estrutura da baseline do PictuRAS

## Escopo e baseline analisada

Este documento descreve a estrutura de código existente e a localização dos
comportamentos dos `UC-VID-001` (submissão de vídeo) e `UC-VID-002` (recorte
temporal). A análise foi feita sobre o commit atual
`fc7119b5ef4fda4741cbe4d476b990c171ac567d` (`implementação do U2 finalizada`).

As fontes de requisitos consideradas foram:

- [`README.md`](./README.md), para a arquitetura e os serviços existentes;
- [`docs/diretrizes_fase_1.md`](./docs/diretrizes_fase_1.md), para o âmbito da
  extensão;
- [`docs/RAS-requisitos-video.md`](./docs/RAS-requisitos-video.md), para o
  catálogo consolidado;
- [`docs/use-cases/UC-VID-001-submeter-video.md`](./docs/use-cases/UC-VID-001-submeter-video.md)
  e [`docs/use-cases/UC-VID-002-recorte-temporal.md`](./docs/use-cases/UC-VID-002-recorte-temporal.md);
- [`specs/001-video-submission/`](./specs/001-video-submission/) e
  [`specs/002-video-trim/`](./specs/002-video-trim/), para o desenho e a
  rastreabilidade previstos.

## Visão geral dos módulos

| Módulo | Tipo | Responsabilidade |
|---|---|---|
| [`frontend/`](./frontend/) | Next.js, React e TypeScript | Interface web, biblioteca de projetos, submissão de vídeos, seleção do intervalo de trim, consulta/cancelamento de operações e apresentação de estados. |
| [`apiGateway/`](./apiGateway/) | Gateway REST em Express | Ponto de entrada HTTP autenticado; valida JWT no limite externo, encaminha pedidos para os serviços internos e preserva cabeçalhos de autorização e versão do projeto. |
| [`projects/`](./projects/) | Serviço Node.js/Express + MongoDB | Dono dos projetos, referências de imagens/vídeos, autorização por projeto, versão concorrente, criação/consulta/cancelamento de operações e orquestração das filas. |
| [`imageStorageService/`](./imageStorageService/) | Serviço Node.js + S3/SeaweedFS | Fachada de armazenamento de objetos; upload, download por URL interna/pública, cópia e remoção de imagens e vídeos. |
| [`users/`](./users/) | Serviço Node.js + MongoDB | Registo, autenticação, perfil e controlo de quota de operações avançadas. |
| [`subscriptions/`](./subscriptions/) | Serviço Node.js + MongoDB | Planos, pagamentos mock e estado de subscrição premium. |
| [`wsGateway/`](./wsGateway/) | Gateway Socket.IO | Consome eventos do RabbitMQ e os entrega ao browser por salas de utilizador/projeto. |
| [`Tools/`](./Tools/) | Microserviços Python | Ferramentas de processamento de imagem, uma por diretório/serviço, consumindo RabbitMQ e usando o volume partilhado de imagens. |
| [`rabbitMQ/`](./rabbitMQ/) | Broker | Exchange, filas e definições de mensageria para processamento assíncrono. |
| [`generative-mock/`](./generative-mock/) | API mock Python | Mock local da API de geração usada pela ferramenta `expand_ai`. |
| [`nginx/`](./nginx/) | Reverse proxy | TLS, encaminhamento para frontend, Gateway REST, WebSocket e SeaweedFS. |

## Localização do código dos use cases 1 e 2

### UC-VID-001 — Submeter vídeo

O UC1 está distribuído no local esperado para uma funcionalidade transversal
de plataforma:

1. **UI e cliente**
   - [`frontend/components/video-submission-area.tsx`](./frontend/components/video-submission-area.tsx)
     trata da seleção e do estado da transferência.
   - [`frontend/components/project-page/add-video-dialog.tsx`](./frontend/components/project-page/add-video-dialog.tsx)
     integra a submissão na biblioteca do projeto.
   - [`frontend/lib/projects.ts`](./frontend/lib/projects.ts) expõe a chamada
     de cliente; [`frontend/lib/mutations/projects.ts`](./frontend/lib/mutations/projects.ts)
     trata a mutation e a invalidação de cache.
2. **Entrada e encaminhamento**
   - [`apiGateway/routes/projects.js`](./apiGateway/routes/projects.js)
     recebe multipart, autentica e encaminha o vídeo para o Projects Service.
3. **Autorização, validação e persistência**
   - [`projects/routes/projects.js`](./projects/routes/projects.js) é a fronteira
     HTTP do serviço e valida o projeto/versão.
   - [`projects/services/videoSubmission.js`](./projects/services/videoSubmission.js)
     coordena metadados, validação, upload, referência e limpeza.
   - [`projects/services/videoMetadata.js`](./projects/services/videoMetadata.js)
     usa FFprobe para extrair tamanho, duração, codec, resolução e FPS.
   - [`projects/services/videoValidation.js`](./projects/services/videoValidation.js)
     valida MP4, H.264, AAC opcional e limites.
   - [`projects/services/videoLimits.js`](./projects/services/videoLimits.js)
     contém os limites por perfil.
   - [`projects/models/project.js`](./projects/models/project.js) guarda as
     referências de vídeo no subdocumento `videos`, sem alterar `imgs`.
4. **Armazenamento**
   - [`projects/utils/videoStorage.js`](./projects/utils/videoStorage.js)
     é a fachada usada pelo Projects Service.
   - [`imageStorageService/route/upload.js`](./imageStorageService/route/upload.js)
     e [`imageStorageService/services/uploadVideo.js`](./imageStorageService/services/uploadVideo.js)
     escrevem o objeto no SeaweedFS/S3.

Conclusão para o UC1: a responsabilidade não está concentrada num único
módulo, mas está separada por fronteiras coerentes. O Projects Service é dono
da referência ao conteúdo e o Storage Service é dono do objeto. Esta divisão
deve ser preservada.

### UC-VID-002 — Recorte temporal

O UC2 tem atualmente estas partes:

1. **UI**
   - [`frontend/components/project-page/project-video-list.tsx`](./frontend/components/project-page/project-video-list.tsx)
     apresenta os vídeos do projeto.
   - [`frontend/components/project-page/video-trim-dialog.tsx`](./frontend/components/project-page/video-trim-dialog.tsx)
     recolhe início/fim, valida o mínimo de um segundo, mostra progresso e
     permite cancelar.
   - [`frontend/lib/projects.ts`](./frontend/lib/projects.ts) e
     [`frontend/lib/mutations/projects.ts`](./frontend/lib/mutations/projects.ts)
     expõem criação, consulta e cancelamento.
2. **Gateway e API**
   - [`apiGateway/routes/projects.js`](./apiGateway/routes/projects.js)
     deve encaminhar criação, consulta e cancelamento para o Projects Service.
   - [`projects/routes/projects.js`](./projects/routes/projects.js) expõe as
     mesmas operações internamente.
3. **Orquestração e estado**
   - [`projects/services/videoOperationService.js`](./projects/services/videoOperationService.js)
     autoriza o projeto/vídeo, valida o intervalo, reserva/devolve quota,
     cria a operação e publica a mensagem RabbitMQ.
   - [`projects/models/videoOperation.js`](./projects/models/videoOperation.js)
     persiste estados, progresso, timestamps, erro e resultado.
   - [`projects/services/videoTrimValidation.js`](./projects/services/videoTrimValidation.js),
     [`projects/services/videoTrimErrors.js`](./projects/services/videoTrimErrors.js)
     e [`projects/services/videoOperationState.js`](./projects/services/videoOperationState.js)
     implementam regras e contratos de estado.
4. **Execução do processamento**
   - [`projects/services/videoTrimWorker.js`](./projects/services/videoTrimWorker.js)
     consome a fila `video_trim`, descarrega o original, executa FFmpeg,
     publica progresso, envia o resultado para o Storage Service e adiciona a
     referência derivada ao projeto.
5. **Eventos**
   - [`projects/utils/videoOperationMsg.js`](./projects/utils/videoOperationMsg.js)
     cria o evento `project-op`.
   - [`wsGateway/index.js`](./wsGateway/index.js) encaminha o evento para a sala
     `project:<id>`.

Conclusão para o UC2: autorização, operação persistida e associação do
resultado ao projeto pertencem legitimamente ao Projects Service. O trabalho
pesado de FFmpeg é, no entanto, uma ferramenta de processamento e está
atualmente embutido no serviço de projetos, ao contrário do padrão existente
em [`Tools/`](./Tools/), onde cada processamento é um microserviço consumidor
independente.

## O que trata cada camada

### Domínio e persistência

- `projects/models/project.js`: projeto, imagens, vídeos e versão concorrente.
- `projects/models/videoOperation.js`: trabalho assíncrono de vídeo.
- `projects/controllers/project.js`: acesso ao projeto e atualizações
  condicionais por versão.

### Casos de uso e regras

- `projects/routes/`: contrato HTTP interno e autorização.
- `projects/services/`: regras de submissão, metadados, limites, operações,
  erros, transições e worker de trim.
- `projects/utils/`: armazenamento, mensagens, RabbitMQ, presença e helpers.

### Processamento de imagem existente

Cada diretório em [`Tools/`](./Tools/) representa uma ferramenta independente
(`brightness`, `contrast`, `resize`, `rotate`, `cut`, ferramentas AI, etc.).
Os helpers comuns estão em [`Tools/utils/`](./Tools/utils/). Essas ferramentas
não são responsáveis por projetos, utilizadores, quota ou persistência de
referências.

### Infraestrutura e integração

- `docker-compose.yaml`: composição dos serviços, bases de dados, RabbitMQ,
  volumes e rede.
- `rabbitMQ/`: configuração do broker.
- `imageStorageService/`: abstração de objetos.
- `wsGateway/`: entrega de progresso ao cliente.
- `nginx/nginx.conf`: fronteira HTTPS e routing externo.

## Testes observados

Os testes focados estão em [`projects/test/`](./projects/test/), incluindo
validação, metadados, limites, autorização, falhas, cancelamento, contratos e
estado da operação. O runner atual é
[`projects/test/run-tests.js`](./projects/test/run-tests.js).

No estado analisado, `node --check` passa para as rotas e serviços principais.
`npm test` na raiz não é um comando válido porque o `package.json` raiz não
define o script `test`; a validação deve ser executada pelo script do serviço
Projects ou por um runner de integração explicitamente configurado.

