---

description: "Tarefas de implementação da conversão de formato e resolução de vídeo"
---

# Tasks: Conversão de Formato e Resolução de Vídeo

**Input**: Design documents from `/specs/004-video-conversion/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`,
`contracts/video-conversion.md` e `quickstart.md`

**Organization**: As tarefas estão agrupadas pelas três user stories P1 da
especificação. A Tool de conversão é autónoma; o Projects Service apenas
orquestra, autoriza, persiste, gere quota e publica eventos.

## Phase 1: Setup

**Purpose**: Preparar a estrutura da nova Tool e os pontos de integração sem
alterar o comportamento das ferramentas de imagem existentes.

- [X] T001 Criar a estrutura `Tools/video_conversion/` com `__init__.py`, `video_conversion.py`, `requirements.txt` e `Dockerfile`, seguindo os padrões documentados em `Tools/brightness/` e `Tools/cut/`.
- [X] T002 [P] Registar o serviço `video_conversion_tool` em `docker-compose.yaml` com build `Tools/video_conversion/Dockerfile`, rede `elk`, dependência saudável de `rabbitmq`, reinício `on-failure` e volume `image_data` montado em `/app/images`.
- [X] T003 [P] Registar a fila `video_conversion` no broker e nos mapas de mensagens de `rabbitMQ/`, `Tools/utils/tool_msg.py` e `projects/utils/project_msg.js`, sem alterar as filas de imagem existentes.
- [X] T004 [P] Definir as dependências Python da Tool, incluindo o cliente RabbitMQ e suporte à execução de FFmpeg/FFprobe, em `Tools/video_conversion/requirements.txt`.

## Phase 2: Foundational

**Purpose**: Implementar as bases comuns que bloqueiam as três user stories.

**⚠️ CRITICAL**: Nenhuma user story deve ser considerada pronta antes desta
fase.

- [X] T005 Estender `projects/models/videoOperation.js` para aceitar `type: "conversion"` e o objeto `output` com `outputContainer`, `outputVideoCodec`, `outputAudioCodec`, `outputWidth`, `outputHeight` e `estimatedSize`, preservando os estados `queued`, `processing`, `completed`, `failed` e `cancelled`.
- [X] T006 [P] Implementar a matriz centralizada de combinações suportadas e os limites `1920x1080` para registados não premium e `3840x2160` para premium em `projects/services/videoConversionValidation.js`; dimensões devem ser positivas e a validação deve rejeitar qualquer largura ou altura acima do limite.
- [X] T007 [P] Definir os erros públicos `VIDEO_CONVERSION_INVALID_OPTIONS`, `VIDEO_CONVERSION_UNAUTHORIZED`, `VIDEO_CONVERSION_NOT_FOUND`, `VIDEO_CONVERSION_QUOTA_EXCEEDED`, `VIDEO_CONVERSION_CANCELLED` e `VIDEO_CONVERSION_FAILED` em `projects/services/videoConversionErrors.js`.
- [X] T008 [P] Definir em `projects/utils/videoConversionMsg.js` os schemas de pedido, progresso, sucesso, erro e cancelamento com `messageId`, `correlationId`, `procedure: "video_conversion"`, `inputVideoURI`, `outputVideoURI` e metadados de vídeo, sem usar `imageURI` para respostas de vídeo.
- [X] T009 Implementar o dispatcher correlacionado entre Projects Service e Tool em `projects/services/videoConversionDispatcher.js`, com publicação na fila `video_conversion`, receção de progresso/resposta, timeout explícito e tratamento de erro sem executar FFmpeg.
- [X] T010 [P] Adicionar testes unitários da matriz de formatos, limites de resolução e estimativa nullable em `projects/test/videoConversionValidation.test.js`.
- [ ] T011 [P] Adicionar testes de contrato do payload RabbitMQ entre dispatcher e Tool em `projects/test/videoConversionTool.contract.test.js`, cobrindo correlação, progresso, sucesso, erro e ausência de `imageURI`.

**Checkpoint**: A infraestrutura de mensagens, o modelo de operação, a
validação e a fronteira entre Projects Service e Tool estão definidas.

## Phase 3: User Story 1 - Configurar uma conversão válida (Priority: P1) 🎯 MVP

**Goal**: Apresentar metadados da origem e opções de conversão suportadas,
aceitando apenas configurações válidas para o perfil do utilizador.

**Independent Test**: Consultar um vídeo autorizado, verificar os metadados e
as opções MP4/H.264/AAC, selecionar uma resolução válida e confirmar uma
estimativa quando os metadados permitirem calculá-la.

### Tests for User Story 1

- [ ] T012 [P] [US1] Criar testes de contrato para `GET /projects/:user/:project/video/:videoId/conversion-options` em `projects/test/videoConversion.contract.test.js`, cobrindo metadados, matriz suportada, limites por perfil e ausência de dados para acesso não autorizado.
- [ ] T013 [P] [US1] Criar testes de validação de criação sem efeitos em `projects/test/videoConversion.contract.test.js`, confirmando que combinações incompatíveis, dimensões não positivas e dimensões acima do limite não criam operações.

### Implementation for User Story 1

- [X] T014 [US1] Implementar a leitura de metadados e a construção das opções de conversão em `projects/services/videoOperationService.js`, reutilizando `projects/services/videoMetadata.js` e aplicando a autorização existente do projeto e do vídeo.
- [X] T015 [US1] Adicionar a rota `GET /projects/:user/:project/video/:videoId/conversion-options` em `projects/routes/projects.js`, devolvendo contentor, codecs, duração, resolução, FPS, tamanho nullable e limites do perfil sem revelar metadados em caso de acesso negado.
- [X] T016 [US1] Implementar a estimativa nullable do tamanho de saída em `projects/services/videoConversionValidation.js`, permitindo continuar quando bitrate ou duração necessários não estiverem disponíveis.
- [X] T017 [P] [US1] Criar a camada de chamadas para opções e configuração em `frontend/lib/projects.ts` e `frontend/lib/mutations/projects.ts`, preservando autenticação, `X-Caller-Id` e `X-Project-Version`.
- [X] T018 [US1] Implementar `frontend/components/project-page/video-conversion-dialog.tsx` para apresentar origem, contentores, codecs, resolução, limites e estimativa indisponível de forma explícita, bloqueando seleções inválidas.

**Checkpoint**: A User Story 1 permite configurar e validar uma conversão sem
publicar uma operação inválida.

## Phase 4: User Story 2 - Criar e acompanhar o vídeo convertido (Priority: P1)

**Goal**: Criar a operação assíncrona, delegar a conversão à Tool, guardar o
resultado como novo vídeo e informar o progresso ao utilizador autorizado.

**Independent Test**: Confirmar uma configuração válida, observar `queued`,
`processing` e progresso, aguardar `completed` e verificar no projeto um novo
vídeo com os parâmetros pedidos enquanto o original permanece inalterado.

### Tests for User Story 2

- [ ] T019 [P] [US2] Adicionar testes de contrato para `POST /projects/:user/:project/video/:videoId/conversion` em `projects/test/videoConversion.contract.test.js`, cobrindo resposta `202`, operação `conversion`, quota e versão do projeto.
- [ ] T020 [P] [US2] Adicionar teste de integração do fluxo dispatcher-Tool em `projects/test/videoConversion.integration.test.js`, cobrindo mensagem correlacionada, progresso no máximo a cada 5 segundos, resposta de metadados e persistência do resultado.
- [ ] T021 [P] [US2] Adicionar teste de contrato do evento `project-op` em `projects/test/videoConversion.contract.test.js`, verificando que contém apenas dados operacionais mínimos e só chega a clientes autorizados.

### Implementation for User Story 2

- [X] T022 [US2] Implementar `createVideoConversionOperation` em `projects/services/videoOperationService.js`, validando origem, configuração, autorização e versão, reservando quota antes da publicação e criando a operação em `queued`.
- [X] T023 [US2] Adicionar a rota `POST /projects/:user/:project/video/:videoId/conversion` em `projects/routes/projects.js`, devolvendo `202` com `operationId` e `status: "queued"` sem esperar pelo fim da conversão.
- [X] T024 [US2] Integrar o dispatcher no ciclo de execução em `projects/app.js` e `projects/services/videoOperationService.js`, atualizando a operação para `processing`, encaminhando progresso e tratando sucesso/erro correlacionados.
- [X] T025 [US2] Implementar o consumidor da Tool em `Tools/video_conversion/video_conversion.py`, validando `procedure`, caminhos confinados a `/app/images`, opções MP4/H.264/AAC e dimensões positivas antes de executar FFmpeg.
- [X] T026 [US2] Implementar a transcodificação FFmpeg e leitura FFprobe em `Tools/video_conversion/video_conversion.py`, escrevendo apenas no `outputVideoURI`, publicando progresso e devolvendo metadados efetivos sem aceder a MongoDB, projetos, quotas ou autorização.
- [X] T027 [US2] Implementar o arranque do consumidor RabbitMQ e a publicação de respostas em `Tools/video_conversion/video_conversion.py`, `Tools/utils/tool_msg.py` e `Tools/utils/rabbit_mq.py`, preservando `correlationId` e erros estáveis.
- [X] T028 [US2] Persistir o resultado recebido da Tool através de `projects/utils/videoStorage.js` e anexá-lo como nova referência com `sourceVideoId` em `projects/services/videoOperationService.js`, sem substituir o vídeo original.
- [X] T029 [US2] Adicionar a emissão de `project-op` e a atualização do projeto no frontend em `frontend/components/project-page/video-conversion-dialog.tsx` e `frontend/components/project-page/project-video-list.tsx`, usando WebSocket e polling como fallback.

**Checkpoint**: A User Story 2 conclui uma conversão real através da Tool
autónoma e torna o vídeo derivado disponível no projeto.

## Phase 5: User Story 3 - Rejeitar, cancelar e recuperar conversões (Priority: P1)

**Goal**: Rejeitar acessos e configurações inválidas e garantir cancelamento,
limpeza, devolução de quota e falhas seguras.

**Independent Test**: Tentar acesso indevido, cancelar uma operação em fila e
em processamento, provocar falha de Tool/armazenamento e confirmar estados
terminais, ausência de resultados parciais, quota correta e original intacto.

### Tests for User Story 3

- [ ] T030 [P] [US3] Criar testes de autorização e isolamento em `projects/test/videoConversion.contract.test.js`, cobrindo opções, criação, consulta, cancelamento e eventos de outro projeto.
- [ ] T031 [P] [US3] Criar testes de cancelamento e concorrência em `projects/test/videoConversionCleanup.test.js`, cobrindo `queued`, `processing`, cancelamento idempotente, corrida com conclusão, temporários e uploads parciais.
- [ ] T032 [P] [US3] Criar testes de falha da Tool e armazenamento em `projects/test/videoConversion.integration.test.js`, verificando estado `failed`, mensagem segura, devolução idempotente de quota e original preservado.

### Implementation for User Story 3

- [X] T033 [US3] Implementar consulta e cancelamento de operações `conversion` em `projects/services/videoOperationService.js` e `projects/routes/projects.js`, permitindo cancelamento apenas em `queued`/`processing` e mantendo resultados concluídos.
- [ ] T034 [US3] Implementar sinalização correlacionada de cancelamento e término cooperativo do FFmpeg em `Tools/video_conversion/video_conversion.py`, removendo temporários sem apagar conteúdo persistente de origem.
- [X] T035 [US3] Implementar limpeza de temporários, uploads parciais e referências não anexadas em `projects/services/videoOperationService.js` e `projects/utils/videoStorage.js`, garantindo que só operações concluídas criam vídeos derivados.
- [X] T036 [US3] Implementar tratamento uniforme de falhas do dispatcher, timeout, RabbitMQ, FFmpeg e armazenamento em `projects/services/videoConversionDispatcher.js`, `projects/services/videoOperationService.js` e `projects/services/videoConversionErrors.js`.
- [X] T037 [US3] Atualizar `frontend/components/project-page/video-conversion-dialog.tsx` para apresentar erros públicos, cancelamento, estados terminais e indisponibilidade de progresso sem expor detalhes internos.

**Checkpoint**: A User Story 3 garante recuperação segura para autorização,
cancelamento, falhas e concorrência.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Fechar documentação, regressão e validação end-to-end da feature.

- [X] T038 [P] Atualizar o catálogo de ferramentas e a secção `Adding a new tool` em `README.md` para documentar `video_conversion_tool`, a fila, o volume, o comando de rebuild e a fronteira de responsabilidades.
- [ ] T039 [P] Atualizar a documentação de configuração da fila em `rabbitMQ/` e qualquer inventário de serviços necessário para refletir `video_conversion`.
- [X] T040 [P] Adicionar ou atualizar testes de regressão para submissão, recorte, frame-tool e ferramentas de imagem em `projects/test/`, garantindo que as filas e operações existentes não mudam.
- [ ] T041 Executar a validação automatizada de `projects/test/run-tests.js`, o build/teste do frontend, `docker compose config`, `docker compose exec video_conversion_tool ffmpeg -version` e `docker compose exec video_conversion_tool ffprobe -version`, registando resultados por cenário em `specs/004-video-conversion/quickstart.md`.
- [X] T042 [P] Executar `git diff --check` e rever a rastreabilidade `UC-VID-004 -> REQ-VID-CONV-* -> componentes -> testes -> resultados`, corrigindo apenas lacunas diretamente relacionadas em `specs/004-video-conversion/`.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sem dependências; T001–T004 podem começar em paralelo,
  salvo a validação final da estrutura criada por T001.
- **Foundational (Phase 2)**: Depende de Phase 1; T005–T011 bloqueiam as user
  stories.
- **User Stories (Phases 3–5)**: Dependem de Phase 2. As três são P1, mas
  US2 depende funcionalmente das interfaces de configuração e operação
  introduzidas em US1; US3 depende das operações criadas em US2.
- **Polish (Phase 6)**: Depende das user stories que forem incluídas no MVP.

### User Story Dependencies

- **US1**: Depois da Phase 2; entrega o MVP mínimo de consulta e validação.
- **US2**: Depois da US1; usa a configuração validada e cria o fluxo Tool.
- **US3**: Depois da US2; amplia o fluxo executável com cancelamento e falhas.

### Parallel Opportunities

- **Setup**: T002, T003 e T004 podem ser executadas em paralelo com T001.
- **Foundational**: T006, T007, T008, T010 e T011 podem ser executadas em
  paralelo depois de T005 quando precisarem do modelo.
- **US1**: T012, T013 e T017 podem ser preparadas em paralelo; T015 depende de
  T014; T018 depende dos contratos de T017.
- **US2**: T019, T020 e T021 podem ser preparados em paralelo; T025 e T027
  podem ser desenvolvidas em paralelo com T022–T024, desde que o contrato de
  T008 seja estável.
- **US3**: T030, T031 e T032 podem ser preparados em paralelo; T034 e T035
  podem ser implementadas em paralelo após o contrato de cancelamento.
- **Polish**: T038, T039, T040 e T042 são independentes entre si; T041 depende
  da implementação concluída.

## Implementation Strategy

### MVP First

1. Completar Phase 1 e Phase 2.
2. Completar US1 para consulta, matriz, limites e validação.
3. Validar US1 independentemente com T012–T018.
4. Completar US2 para uma conversão MP4/H.264/AAC através da Tool autónoma.
5. Validar US2 antes de avançar para cancelamento e falhas.

### Incremental Delivery

1. Entregar a infraestrutura da Tool e o contrato RabbitMQ.
2. Entregar consulta/configuração sem iniciar processamento inválido.
3. Entregar conversão assíncrona e resultado derivado preservando o original.
4. Entregar cancelamento, falhas, limpeza e isolamento de autorização.
5. Executar regressão, documentação e quickstart completo.

### Suggested MVP Scope

O MVP recomendado inclui Phase 1, Phase 2, US1 e US2, com conversão de um
vídeo por operação apenas para MP4/H.264/AAC e limites de resolução já
documentados. US3 deve ser concluída antes de considerar a funcionalidade
aceitável para integração, porque falhas e cancelamentos fazem parte do âmbito
funcional P1.
