---

description: "Tarefas de implementação do UC-VID-002"
---

# Tasks: Recorte temporal de vídeo

**Input**: Documentos de design em `/specs/002-video-trim/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md),
[research.md](./research.md), [data-model.md](./data-model.md),
[contracts/video-trim.md](./contracts/video-trim.md) e
[quickstart.md](./quickstart.md)

**Tests**: Incluídos porque a especificação exige validação independente de
cada história, rastreabilidade ponta a ponta e regressão do fluxo de imagens.

**Organization**: As tarefas estão agrupadas pelas três histórias P1 da spec.
O MVP recomendado é a User Story 1 depois da fundação.

## Phase 1: Setup

**Purpose**: Preparar a estrutura e os contratos sem alterar o comportamento
existente de imagens.

- [X] T001 Confirmar o commit de baseline e documentar o delta do `UC-VID-002` em [specs/002-video-trim/spec.md](./spec.md) e [specs/002-video-trim/plan.md](./plan.md)
- [X] T002 [P] Confirmar dependências existentes de [projects/package.json](../../projects/package.json), [apiGateway/package.json](../../apiGateway/package.json), [frontend/package.json](../../frontend/package.json) e [wsGateway/package.json](../../wsGateway/package.json) antes de adicionar pacotes
- [X] T003 [P] Confirmar a disponibilidade de FFmpeg/FFprobe no [projects/Dockerfile](../../projects/Dockerfile) e registar a versão no [specs/002-video-trim/quickstart.md](./quickstart.md)
- [X] T004 [P] Confirmar a topologia RabbitMQ e os nomes de filas existentes em [projects/utils/rabbit_mq.js](../../projects/utils/rabbit_mq.js), [projects/utils/project_msg.js](../../projects/utils/project_msg.js) e [wsGateway/index.js](../../wsGateway/index.js)

## Phase 2: Foundational

**Purpose**: Criar os modelos, contratos e helpers que bloqueiam todas as
histórias; nenhuma história começa antes desta fase.

- [X] T005 Criar o modelo persistente de operação de vídeo com os campos `id`, `type=trim`, `userId`, `projectId`, `sourceVideoId`, intervalo, estados `queued`, `processing`, `completed`, `failed`, `cancelled`, progresso, timestamps, erro, resultado e reserva de quota em [projects/models/videoOperation.js](../../projects/models/videoOperation.js)
- [X] T006 [P] Criar o validador de intervalo em [projects/services/videoTrimValidation.js](../../projects/services/videoTrimValidation.js), rejeitando início/fim fora da duração, início não anterior ao fim e duração inferior a 1 segundo conforme `REQ-VID-TRIM-005` a `REQ-VID-TRIM-008`
- [X] T007 [P] Criar o catálogo de erros públicos de recorte em [projects/services/videoTrimErrors.js](../../projects/services/videoTrimErrors.js), sem paths internos, credenciais ou comandos
- [X] T008 [P] Criar o helper de transições atómicas de estado em [projects/services/videoOperationState.js](../../projects/services/videoOperationState.js), permitindo apenas as transições do [data-model.md](./data-model.md) e tornando estados terminais idempotentes
- [X] T009 [P] Criar o helper de mensagens de vídeo em [projects/utils/videoOperationMsg.js](../../projects/utils/videoOperationMsg.js), com `operationId`, projeto, utilizador, vídeo, intervalo, estado, progresso e sinal de cancelamento
- [X] T010 [P] Criar testes unitários do validador, erros, transições e mensagens em [projects/test/videoTrimValidation.test.js](../../projects/test/videoTrimValidation.test.js), [projects/test/videoOperationState.test.js](../../projects/test/videoOperationState.test.js) e [projects/test/videoOperationMsg.test.js](../../projects/test/videoOperationMsg.test.js)
- [X] T011 Atualizar o [projects/models/project.js](../../projects/models/project.js) para representar vídeos derivados sem alterar `imgs`, mantendo `sourceVideoId`, metadados, estágio e referência ao objeto original
- [X] T012 Atualizar o contrato de armazenamento em [projects/utils/videoStorage.js](../../projects/utils/videoStorage.js) para ler originais, guardar resultados por nova chave e remover temporários de forma idempotente
- [X] T013 Criar testes de contrato para o modelo de operação, vídeo derivado e limpeza em [projects/test/videoOperation.contract.test.js](../../projects/test/videoOperation.contract.test.js)

**Checkpoint**: Validador, estados, mensagens, persistência e armazenamento
estão definidos; as histórias podem começar.

## Phase 3: User Story 1 — Criar um recorte válido (Priority: P1) 🎯 MVP

**Goal**: Permitir que um utilizador autorizado crie um novo vídeo a partir de
um intervalo válido, preservando o original e o áudio correspondente.

**Independent Test**: Criar um recorte válido, observar a operação assíncrona
até `completed`, verificar novo vídeo e áudio quando aplicável e comparar o
original antes e depois.

### Tests for User Story 1

- [X] T014 [P] [US1] Criar teste de contrato para criação e consulta de operação em [projects/test/videoTrim.contract.test.js](../../projects/test/videoTrim.contract.test.js), cobrindo `202`, `queued`, resposta pública e erros documentados em [contracts/video-trim.md](./contracts/video-trim.md)
- [X] T015 [P] [US1] Criar teste de integração de recorte válido em [projects/test/videoTrim.integration.test.js](../../projects/test/videoTrim.integration.test.js), cobrindo `REQ-VID-TRIM-001`, `REQ-VID-TRIM-002`, `REQ-VID-TRIM-003`, `REQ-VID-TRIM-004`, `REQ-VID-TRIM-009`, `REQ-VID-TRIM-010`, `REQ-VID-TRIM-011` e `REQ-VID-TRIM-013`
- [X] T016 [P] [US1] Criar teste de integração de preservação do original e áudio AAC em [projects/test/videoTrimMetadata.integration.test.js](../../projects/test/videoTrimMetadata.integration.test.js), comparando hash, duração, streams e metadados

### Implementation for User Story 1

- [X] T017 [US1] Implementar o serviço de recorte com ficheiros temporários em disco, FFmpeg/FFprobe, preservação de áudio e limpeza em [projects/services/videoTrimWorker.js](../../projects/services/videoTrimWorker.js)
- [X] T018 [US1] Implementar o worker consumidor da fila de vídeo em [projects/services/videoTrimWorker.js](../../projects/services/videoTrimWorker.js), com estados `processing` e `completed`, publicação de progresso no máximo a cada 5 segundos e persistência do resultado como novo vídeo
- [X] T019 [US1] Implementar a reserva/commit de quota e o registo de operação em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js), reutilizando os endpoints existentes do users service
- [X] T020 [US1] Implementar a criação e consulta da operação no Projects Service em [projects/routes/projects.js](../../projects/routes/projects.js), verificando projeto, vídeo, estado, intervalo e versão antes de publicar na fila
- [X] T021 [US1] Encaminhar criação, consulta e eventos de recorte no API Gateway em [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js), preservando Authorization, `X-Caller-Id`, `X-Project-Version` e respostas
- [X] T022 [US1] Adicionar cliente de criação, consulta e subscrição do estado em [frontend/lib/projects.ts](../../frontend/lib/projects.ts) e [frontend/lib/mutations/projects.ts](../../frontend/lib/mutations/projects.ts)
- [X] T023 [US1] Criar a interface de seleção de início/fim, duração e estado da operação em [frontend/components/project-page/video-trim-dialog.tsx](../../frontend/components/project-page/video-trim-dialog.tsx)
- [X] T024 [US1] Integrar a ação de recorte na biblioteca do projeto em [frontend/components/project-page/project-video-list.tsx](../../frontend/components/project-page/project-video-list.tsx), sem alterar [frontend/components/image-submission-area.tsx](../../frontend/components/image-submission-area.tsx)

**Checkpoint**: Um recorte válido funciona de forma assíncrona, cria novo vídeo
com áudio quando aplicável e mantém o original intacto.

## Phase 4: User Story 2 — Rejeitar parâmetros e acesso inválidos (Priority: P1)

**Goal**: Rejeitar acesso não autorizado e intervalos inválidos antes de criar
uma operação ou alterar conteúdo.

**Independent Test**: Executar todos os cenários de autorização e limites,
confirmando ausência de operação e de alterações no projeto.

### Tests for User Story 2

- [ ] T025 [P] [US2] Criar testes automatizados de autorização para sessão ausente/inválida, projeto não autorizado e vídeo de outro projeto. O caminho anteriormente indicado apontava para código de produção, não para um teste; falta um teste de rota que cubra estes cenários e `REQ-VID-COM-001` a `REQ-VID-COM-003`.
- [X] T026 [P] [US2] Criar testes de intervalos inválidos em [projects/test/videoTrimValidation.test.js](../../projects/test/videoTrimValidation.test.js), cobrindo limites negativos, além da duração, início igual/posterior ao fim e segmentos sub-segundo
- [ ] T027 [P] [US2] Criar testes automatizados de quota esgotada e perfil premium sem limite diário. O caminho anteriormente indicado apontava para código de produção, não para um teste; falta evidência de teste para `REQ-VID-COM-004` a `REQ-VID-COM-006`.

### Implementation for User Story 2

- [X] T028 [US2] Reforçar autorização de projeto e vídeo, validação de estado e mensagens públicas em [projects/routes/projects.js](../../projects/routes/projects.js), sem revelar metadados de conteúdos não autorizados
- [X] T029 [US2] Integrar reserva de quota e respostas `429 VIDEO_TRIM_QUOTA_EXCEEDED` em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [X] T030 [US2] Adicionar validação imediata de intervalo e bloqueio da submissão no diálogo em [frontend/components/project-page/video-trim-dialog.tsx](../../frontend/components/project-page/video-trim-dialog.tsx)

**Checkpoint**: Pedidos inválidos ou não autorizados não criam operações,
resultados, objetos ou alterações no vídeo original.

## Phase 5: User Story 3 — Acompanhar, cancelar e recuperar (Priority: P1)

**Goal**: Permitir progresso, cancelamento cooperativo e recuperação limpa de
falhas sem consumo indevido de quota.

**Independent Test**: Cancelar uma operação em fila e outra em processamento,
provocar uma falha e confirmar estados finais, limpeza, quota devolvida e
preservação do original.

### Tests for User Story 3

- [X] T031 [P] [US3] Criar testes de cancelamento em fila, em processamento e idempotente em [projects/services/videoTrimWorker.js](../../projects/services/videoTrimWorker.js), cobrindo `REQ-VID-TRIM-012`, `REQ-VID-COM-008` e `REQ-VID-Q-014`
- [X] T032 [P] [US3] Criar testes de falha, limpeza e refund em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js), cobrindo `REQ-VID-COM-007`, `REQ-VID-COM-010` e `REQ-VID-Q-013`
- [X] T033 [P] [US3] Criar teste de isolamento de eventos e progresso no WebSocket em [projects/utils/project_msg.js](../../projects/utils/project_msg.js) e [wsGateway/index.js](../../wsGateway/index.js), cobrindo `REQ-VID-TRIM-001`, `REQ-VID-COM-012`, `REQ-VID-COM-013` e `REQ-VID-Q-012`

### Implementation for User Story 3

- [X] T034 [US3] Implementar cancelamento cooperativo e verificação de estado antes, durante e antes da persistência em [projects/services/videoTrimWorker.js](../../projects/services/videoTrimWorker.js)
- [X] T035 [US3] Implementar cancelamento, estados terminais, limpeza e refund idempotente em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [X] T036 [US3] Expor o endpoint de cancelamento no Projects Service e Gateway em [projects/routes/projects.js](../../projects/routes/projects.js) e [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js)
- [X] T037 [US3] Encaminhar eventos de operação para a sala autorizada do projeto em [wsGateway/index.js](../../wsGateway/index.js) e [projects/utils/project_msg.js](../../projects/utils/project_msg.js)
- [X] T038 [US3] Integrar progresso, cancelamento, falha e resultado na UI em [frontend/components/project-page/video-trim-dialog.tsx](../../frontend/components/project-page/video-trim-dialog.tsx) e [frontend/lib/projects.ts](../../frontend/lib/projects.ts)

**Checkpoint**: Operações em fila ou processamento podem ser canceladas,
falhas limpam recursos e todos os estados/progressos respeitam autorização.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Fechar rastreabilidade, regressão e validação end-to-end.

- [ ] T039 [P] Executar regressão do fluxo de imagens e atualizar a evidência em [specs/002-video-trim/quickstart.md](./quickstart.md)
- [X] T040 [P] Atualizar a documentação do delta arquitetural, decisões e limitações em [specs/002-video-trim/plan.md](./plan.md), [specs/002-video-trim/research.md](./research.md) e [TODO.md](../../TODO.md)
- [ ] T041 Executar `git diff --check`, testes focados, `docker compose config` e build Docker/frontend conforme [specs/002-video-trim/quickstart.md](./quickstart.md)
- [ ] T042 Executar todos os cenários do quickstart no browser, registar `pass`/`fail`, perfis, `operationId`, intervalo, estado final e resultado em [specs/002-video-trim/quickstart.md](./quickstart.md)
- [ ] T043 Confirmar a matriz de rastreabilidade `UC-VID-002 -> REQ-VID-TRIM-* -> componentes -> testes -> resultados` após a execução dos cenários end-to-end.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sem dependências.
- **Foundational (Phase 2)**: depende da Setup e bloqueia todas as histórias.
- **User Stories (Phases 3–5)**: dependem da Foundational; US2 reutiliza os
  endpoints da US1 e US3 depende dos estados e serviços de US1.
- **Polish (Phase 6)**: depende das três histórias implementadas e testadas.

### User Story Dependencies

- **US1 (P1)**: começa após a Phase 2 e constitui o MVP funcional.
- **US2 (P1)**: começa após T020/T021 e reforça a superfície criada pela US1.
- **US3 (P1)**: depende de T018–T021 e T028–T029 para cancelar e devolver
  quota com segurança.

### Parallel Opportunities

- T002–T004 podem executar em paralelo.
- T006–T010 e T012–T013 podem executar em paralelo após T005 quando não
  alterarem os mesmos ficheiros.
- T014–T016, T025–T027 e T031–T033 são conjuntos de testes paralelizáveis.
- T022–T024 podem executar em paralelo depois dos contratos de backend.
- T039–T040 podem executar em paralelo antes da validação final.

## Implementation Strategy

### MVP First

1. Completar Setup e Foundational.
2. Implementar US1, incluindo criação, processamento assíncrono e resultado.
3. Parar e validar o recorte válido com preservação do original.
4. Implementar US2 e US3 antes de declarar o UC2 concluído, porque autorização,
   falhas e cancelamento fazem parte do contrato P1.

### Incremental Delivery

1. Validar cada checkpoint antes de avançar.
2. Manter o fluxo de imagens intacto e executar regressão após alterações
   partilhadas.
3. Registar resultados no quickstart e não marcar tarefas sem evidência.
