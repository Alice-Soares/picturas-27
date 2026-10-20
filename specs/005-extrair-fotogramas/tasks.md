---
description: "Tarefas de implementação do UC-VID-005"
---

# Tasks: Extrair sequência de fotogramas de um vídeo

**Input**: [spec.md](./spec.md) e [plan.md](./plan.md)

**Prerequisites**: [research.md](./research.md), [data-model.md](./data-model.md),
[contracts/video-frame-extraction.md](./contracts/video-frame-extraction.md) e
[quickstart.md](./quickstart.md) serão criados ou atualizados durante as fases
iniciais conforme o plano.

**Tests**: As tarefas incluem testes unitários, de contrato, integração e
regressão porque o UC-VID-005 exige rastreabilidade ponta a ponta, limpeza de
resultados parciais, isolamento por projeto e preservação do vídeo original.

**Organization**: As tarefas estão agrupadas pelas três histórias P1 da
especificação. A User Story 1 entrega o fluxo mínimo de extração; as User
Stories 2 e 3 completam autorização, limites, destino, cancelamento e falhas.

**Requirement coverage**: `REQ-VID-FEX-001`, `REQ-VID-FEX-002`,
`REQ-VID-FEX-003`, `REQ-VID-FEX-004`, `REQ-VID-FEX-005`, `REQ-VID-FEX-006`,
`REQ-VID-FEX-007`, `REQ-VID-FEX-008`, `REQ-VID-FEX-009`, `REQ-VID-FEX-010` e
`REQ-VID-FEX-011`, além dos requisitos transversais `REQ-VID-COM-*` e
`REQ-VID-Q-*` aplicáveis.

## User Stories

- **US1 (P1)**: Um utilizador registado ou premium configura um intervalo e uma
  quantidade de fotogramas e obtém JPEGs no projeto sem alterar o vídeo original.
- **US2 (P1)**: O sistema valida acesso, codec, limites por perfil, espaço e
  projeto de destino antes de criar uma operação executável.
- **US3 (P1)**: O utilizador acompanha, cancela ou recupera de falhas sem
  resultados parciais acessíveis e com devolução da quota aplicável.

## Dependencies and Order

```text
Setup -> Foundational -> US1 -> US2
                         \-> US3
```

US1 depende dos contratos, modelo e pipeline comuns. US2 depende da superfície
de criação da operação, mas os seus testes de autorização/limites podem ser
preparados em paralelo com a implementação do worker. US3 depende dos estados
e do worker base de US1; os seus testes podem ser escritos antes da implementação.

## Phase 1: Setup

**Purpose**: Confirmar a baseline, dependências e contratos de integração sem
alterar o comportamento existente de imagens, trim ou `frame_tool`.

- [x] T001 Confirmar o commit de baseline `f782daa` e documentar o delta do `UC-VID-005` em [specs/005-extrair-fotogramas/spec.md](./spec.md) e [specs/005-extrair-fotogramas/plan.md](./plan.md)
- [x] T002 [P] Confirmar as dependências existentes em [projects/package.json](../../projects/package.json), [apiGateway/package.json](../../apiGateway/package.json), [frontend/package.json](../../frontend/package.json), [imageStorageService/package.json](../../imageStorageService/package.json) e [wsGateway/package.json](../../wsGateway/package.json), sem adicionar pacotes ainda
- [x] T003 [P] Confirmar FFmpeg/FFprobe e a versão disponível no [projects/Dockerfile](../../projects/Dockerfile), registando a evidência em [specs/005-extrair-fotogramas/quickstart.md](./quickstart.md)
- [x] T004 [P] Confirmar filas, exchange e mensagens existentes em [projects/utils/rabbit_mq.js](../../projects/utils/rabbit_mq.js), [projects/utils/project_msg.js](../../projects/utils/project_msg.js) e [wsGateway/index.js](../../wsGateway/index.js)
- [x] T005 [P] Confirmar os contratos atuais de quota, refund, autorização e estados em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js), [projects/models/videoOperation.js](../../projects/models/videoOperation.js) e Users Service

## Phase 2: Foundational

**Purpose**: Criar os artefactos de design, modelo, validação, storage e
extração que bloqueiam todas as histórias.

- [x] T006 Consolidar os resultados da investigação, alternativas, riscos de storage e decisões `DA-07` a `DA-10` em [specs/005-extrair-fotogramas/research.md](./research.md)
- [x] T007 Definir em [specs/005-extrair-fotogramas/data-model.md](./data-model.md) a relação vídeo -> operação -> fotograma -> projeto, campos de destino, timestamps, índices, estados e ciclo de vida das chaves temporárias
- [x] T008 Definir em [specs/005-extrair-fotogramas/contracts/video-frame-extraction.md](./contracts/video-frame-extraction.md) os pedidos, respostas, mensagens RabbitMQ, eventos `project-op`, erros públicos e regras de autorização
- [x] T009 Definir em [specs/005-extrair-fotogramas/quickstart.md](./quickstart.md) fixtures, comandos, cenários de aceitação, evidências esperadas e critérios de `pass`/`fail`
- [x] T010 Estender o schema de [projects/models/videoOperation.js](../../projects/models/videoOperation.js) para aceitar `type: frame_extract`, destino, quantidade máxima/estimada/extraída, formato, resultados temporários e manter compatibilidade com `trim` e `frame_tool`
- [x] T011 [P] Criar ou estender validação de transições e estados terminais idempotentes em [projects/services/videoOperationState.js](../../projects/services/videoOperationState.js), cobrindo `queued`, `processing`, `completed`, `failed` e `cancelled`
- [x] T012 [P] Criar [projects/services/videoFrameExtractionValidation.js](../../projects/services/videoFrameExtractionValidation.js) para validar intervalo, quantidade positiva, estimativa não nula, formato JPEG, duração, FPS e limites de 1000/5000
- [x] T013 [P] Criar [projects/services/videoFrameExtractionErrors.js](../../projects/services/videoFrameExtractionErrors.js) com mensagens públicas para autorização, codec, parâmetros, limite, espaço, cancelamento e falha sem paths ou comandos internos
- [x] T014 Criar testes unitários dos validadores, erros e transições em [projects/test/videoFrameExtractionValidation.test.js](../../projects/test/videoFrameExtractionValidation.test.js) e [projects/test/videoOperationState.test.js](../../projects/test/videoOperationState.test.js)
- [x] T015 Estender [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js) com o tipo `frame_extract`, publicação da mensagem, consulta autorizada e integração com reserva/refund de quota
- [x] T016 [P] Criar uma API de storage baseada em ficheiro/stream para JPEG e eliminação idempotente em [imageStorageService/services/uploadImage.js](../../imageStorageService/services/uploadImage.js) e [projects/utils/videoStorage.js](../../projects/utils/videoStorage.js), sem remover o contrato de imagens existente
- [x] T017 [P] Estender o modelo e controlador de projeto em [projects/models/project.js](../../projects/models/project.js) e [projects/controllers/project.js](../../projects/controllers/project.js) para associar imagens extraídas com operação, vídeo de origem, índice e timestamp
- [x] T018 Refatorar [projects/services/videoFramePipeline.js](../../projects/services/videoFramePipeline.js) para disponibilizar extração reutilizável com formato configurável (`png`/`jpeg`), mantendo a recomposição e o comportamento de `frame_tool`
- [ ] T019 [P] Criar testes de contrato para o modelo de operação, metadados de fotograma, storage incremental e limpeza em [projects/test/videoFrameExtraction.contract.test.js](../../projects/test/videoFrameExtraction.contract.test.js)

**Checkpoint**: O modelo, os contratos, a validação, o storage incremental e o
helper de extração estão definidos sem regressão conhecida dos fluxos existentes.

## Phase 3: User Story 1 — Configurar e extrair fotogramas (P1)

**Goal**: Criar uma operação autorizada, extrair JPEGs do intervalo solicitado e
publicá-los no projeto apenas quando a operação terminar com sucesso.

**Independent test**: Submeter uma configuração válida, observar `queued` e
`processing`, concluir a operação e verificar JPEGs, quantidade, timestamps e
hash inalterado do vídeo original.

### Tests for User Story 1

- [ ] T020 [P] [US1] Criar teste de contrato para criação e consulta de uma operação `frame_extract`, cobrindo resposta `202`, `queued`, estimativa, formato e payload público em [projects/test/videoFrameExtraction.contract.test.js](../../projects/test/videoFrameExtraction.contract.test.js)
- [x] T021 [P] [US1] Criar teste unitário da estimativa de fotogramas para intervalo completo, intervalo parcial, limite exato e zero frames em [projects/test/videoFrameExtractionValidation.test.js](../../projects/test/videoFrameExtractionValidation.test.js)
- [ ] T022 [US1] Criar teste de integração de extração válida, JPEG e quantidade máxima em [projects/test/videoFrameExtraction.integration.test.js](../../projects/test/videoFrameExtraction.integration.test.js)
- [ ] T023 [US1] Criar teste de integração de preservação do vídeo original, comparando hash SHA-256 e metadados antes/depois em [projects/test/videoFrameExtractionMetadata.integration.test.js](../../projects/test/videoFrameExtractionMetadata.integration.test.js)

### Implementation for User Story 1

- [x] T024 [US1] Implementar criação da operação com autorização do projeto/vídeo, validação dos parâmetros, cálculo da estimativa e persistência `queued` em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [x] T025 [US1] Adicionar as rotas de criação, consulta e resposta de estimativa para `frame_extract` em [projects/routes/projects.js](../../projects/routes/projects.js), sem expor resultados temporários
- [x] T026 [US1] Encaminhar a criação, consulta, cancelamento e campos da operação através de [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js), preservando `Authorization`, `X-Caller-Id` e perfil
- [x] T027 [US1] Criar [projects/services/videoFrameExtractionWorker.js](../../projects/services/videoFrameExtractionWorker.js) para descarregar o vídeo, extrair JPEGs no staging e processar um ficheiro ou lote limitado de cada vez
- [x] T028 [US1] Ligar o consumidor da fila `frame_extract` ao arranque do Projects Service, sem alterar as filas de `trim`, `frame_tool` ou ferramentas de imagem
- [x] T029 [US1] Implementar upload incremental dos JPEGs com metadados de operação, projeto, vídeo de origem, índice e timestamp em [imageStorageService/services/uploadImage.js](../../imageStorageService/services/uploadImage.js) e no worker
- [x] T030 [US1] Implementar finalização da operação e associação das referências das imagens ao projeto em [projects/controllers/project.js](../../projects/controllers/project.js), tornando a operação idempotente
- [x] T031 [US1] Adicionar o cliente de criação, consulta, estimativa e estado em [frontend/lib/projects.ts](../../frontend/lib/projects.ts) e [frontend/lib/mutations/projects.ts](../../frontend/lib/mutations/projects.ts)
- [x] T032 [US1] Criar o diálogo de configuração de intervalo, quantidade, formato JPEG, estimativa e confirmação em [frontend/components/project-page/video-frame-extraction-dialog.tsx](../../frontend/components/project-page/video-frame-extraction-dialog.tsx)
- [x] T033 [US1] Integrar a ação de extração na biblioteca de vídeos em [frontend/components/project-page/project-video-list.tsx](../../frontend/components/project-page/project-video-list.tsx), exibindo imagens apenas após `completed`

**Checkpoint**: Uma extração válida conclui de forma assíncrona, publica JPEGs no
projeto e mantém o vídeo original inalterado.

## Phase 4: User Story 2 — Validar acesso, limites e armazenamento (P1)

**Goal**: Rejeitar pedidos inválidos antes da fila e suportar o projeto atual ou
um projeto novo como destino.

**Independent test**: Tentar acesso cruzado, codec incompatível, limites acima
de 1000/5000, espaço insuficiente e destinos inválidos; confirmar ausência de
operação executável ou conteúdo persistente.

### Tests for User Story 2

- [ ] T034 [P] [US2] Criar testes de autorização para sessão/perfil, projeto não autorizado e vídeo pertencente a outro projeto em [projects/test/videoFrameExtraction.authorization.test.js](../../projects/test/videoFrameExtraction.authorization.test.js), cobrindo `REQ-VID-COM-001` a `003`
- [ ] T035 [P] [US2] Criar testes dos limites de utilizador registado/premium, codec incompatível e quantidade acima do máximo em [projects/test/videoFrameExtractionValidation.test.js](../../projects/test/videoFrameExtractionValidation.test.js)
- [ ] T036 [P] [US2] Criar teste de espaço insuficiente que confirme rejeição antes da publicação RabbitMQ em [projects/test/videoFrameExtractionStorage.test.js](../../projects/test/videoFrameExtractionStorage.test.js)
- [ ] T037 [US2] Criar teste de integração para destino no projeto atual e num projeto novo, verificando `target_project_id` e associação correta em [projects/test/videoFrameExtractionDestination.integration.test.js](../../projects/test/videoFrameExtractionDestination.integration.test.js)

### Implementation for User Story 2

- [x] T038 [US2] Reforçar autorização do projeto, pertença do vídeo, codec suportado, parâmetros e limites por perfil em [projects/services/videoFrameExtractionValidation.js](../../projects/services/videoFrameExtractionValidation.js) e [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [ ] T039 [US2] Implementar a verificação de espaço disponível e impedir a criação/publicação da operação quando a verificação falhar, conforme o contrato confirmado em `research.md`
- [x] T040 [US2] Implementar resolução e autorização do destino atual ou novo projeto antes da publicação em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [x] T041 [US2] Persistir `target_project_id` e impedir que a consulta de operação ou resultados atravesse o limite do projeto autorizado em [projects/models/videoOperation.js](../../projects/models/videoOperation.js) e [projects/routes/projects.js](../../projects/routes/projects.js)
- [ ] T042 [US2] Integrar a seleção de projeto de destino e mensagens de rejeição no diálogo em [frontend/components/project-page/video-frame-extraction-dialog.tsx](../../frontend/components/project-page/video-frame-extraction-dialog.tsx)

**Checkpoint**: Pedidos não autorizados, acima dos limites ou sem espaço não
criam trabalho; projetos atual e novo recebem apenas os resultados destinados a
esses contextos.

## Phase 5: User Story 3 — Acompanhar, cancelar e recuperar (P1)

**Goal**: Garantir estados, progresso autorizado, cancelamento cooperativo,
limpeza idempotente e refund sem resultados parciais.

**Independent test**: Cancelar em `queued` e `processing`, provocar falha depois
de uploads e confirmar `cancelled`/`failed`, cleanup, refund, isolamento dos
eventos e preservação do vídeo original.

### Tests for User Story 3

- [ ] T043 [P] [US3] Criar testes de cancelamento em fila, durante extração e durante upload em [projects/test/videoFrameExtractionCancellation.integration.test.js](../../projects/test/videoFrameExtractionCancellation.integration.test.js)
- [ ] T044 [P] [US3] Criar testes de falha, cleanup de staging, remoção de objetos carregados e ausência de referências parciais em [projects/test/videoFrameExtractionFailure.integration.test.js](../../projects/test/videoFrameExtractionFailure.integration.test.js)
- [ ] T045 [P] [US3] Criar teste de quota reservada, refund em falha/cancelamento e ausência de limite diário premium em [projects/test/videoFrameExtractionQuota.test.js](../../projects/test/videoFrameExtractionQuota.test.js)
- [ ] T046 [P] [US3] Criar teste de eventos `project-op`, progresso e isolamento por projeto em [wsGateway/test/project_events.test.js](../../wsGateway/test/project_events.test.js) ou no teste de contrato correspondente

### Implementation for User Story 3

- [x] T047 [US3] Implementar transições de `processing`, progresso e publicação de eventos `project-op` no worker e em [projects/utils/videoOperationMsg.js](../../projects/utils/videoOperationMsg.js), limitando progresso a uma atualização máxima por 5 segundos
- [x] T048 [US3] Implementar cancelamento cooperativo antes da extração, entre uploads e antes da finalização em [projects/services/videoFrameExtractionWorker.js](../../projects/services/videoFrameExtractionWorker.js)
- [x] T049 [US3] Implementar cleanup idempotente de staging, objetos carregados e referências não publicadas em sucesso, falha e cancelamento em [projects/services/videoFrameExtractionWorker.js](../../projects/services/videoFrameExtractionWorker.js) e [imageStorageService/services/uploadImage.js](../../imageStorageService/services/uploadImage.js)
- [x] T050 [US3] Implementar estados terminais, mensagens públicas de falha e refund idempotente em [projects/services/videoOperationService.js](../../projects/services/videoOperationService.js)
- [x] T051 [US3] Expor o cancelamento no Projects Service e API Gateway e garantir idempotência após `completed`, `failed` ou `cancelled` em [projects/routes/projects.js](../../projects/routes/projects.js) e [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js)
- [x] T052 [US3] Integrar progresso, cancelamento, falha, estado final e atualização da biblioteca no frontend em [frontend/components/project-page/video-frame-extraction-dialog.tsx](../../frontend/components/project-page/video-frame-extraction-dialog.tsx)
- [ ] T053 [US3] Confirmar no WebSocket Gateway que estados, progresso e resultados não são emitidos para clientes não autorizados em [wsGateway/index.js](../../wsGateway/index.js) e [wsGateway/utils/project_events.js](../../wsGateway/utils/project_events.js)

**Checkpoint**: Cancelamento e falha não deixam resultados parciais, devolvem a
quota quando aplicável e publicam apenas informação do projeto autorizado.

## Phase 6: Polish and Cross-Cutting Concerns

**Purpose**: Fechar rastreabilidade, regressão, documentação e validação
end-to-end.

- [x] T054 [P] Atualizar [specs/005-extrair-fotogramas/quickstart.md](./quickstart.md) com comandos executados, fixtures, perfis, projeto, `operationId`, estados e evidências de cada cenário
- [x] T055 [P] Adicionar em [specs/005-extrair-fotogramas/quickstart.md](./quickstart.md) a matriz `UC-VID-005 -> REQ-VID-FEX-* -> componente -> teste -> resultado`, incluindo requisitos transversais
- [x] T056 [P] Documentar em [specs/005-extrair-fotogramas/research.md](./research.md) decisões finais, limitações do MVP, utilização de IA e comportamento não implementado
- [ ] T057 Executar a regressão de submissão de vídeo, trim, `frame_tool` e processamento de imagens depois das alterações comuns ao modelo, mensagens ou pipeline
- [ ] T058 Executar `node test/run-tests.js` em [projects](../../projects/test/run-tests.js), os testes do `wsGateway`, `docker compose config`, builds relevantes e `git diff --check`, registando os resultados
- [ ] T059 Executar os cenários end-to-end do quickstart no browser para projeto atual e novo, perfis registado/premium, limites, cancelamento, falha e isolamento
- [ ] T060 Rever a matriz de rastreabilidade, confirmar que não há requisitos órfãos ou resultados parciais acessíveis e atualizar o estado final de [specs/005-extrair-fotogramas/tasks.md](./tasks.md)

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sem dependências; estabelece baseline e contratos observados.
- **Foundational (Phase 2)**: depende da Setup e bloqueia todas as histórias.
- **US1 (Phase 3)**: depende da Foundational e entrega o primeiro fluxo funcional.
- **US2 (Phase 4)**: depende da criação da operação de US1; os testes podem ser preparados antes da implementação do worker.
- **US3 (Phase 5)**: depende do modelo de estados e do worker base de US1.
- **Polish (Phase 6)**: depende das três histórias implementadas e dos testes focados.

### User Story Dependencies

- **US1 (P1)**: começa depois de T019 e constitui o MVP de extração válida.
- **US2 (P1)**: T034–T037 podem avançar depois de T012; T038–T042 dependem da criação da operação e do contrato de destino.
- **US3 (P1)**: T043–T046 podem avançar depois dos contratos; T047–T053 dependem do worker e das rotas de US1.

### Parallel Opportunities

- T002–T005 podem executar em paralelo.
- T011–T014, T016–T019 podem executar em paralelo quando não alterarem o mesmo ficheiro.
- T020–T023 podem executar em paralelo após os contratos.
- T034–T037 podem executar em paralelo.
- T043–T046 podem executar em paralelo.
- T054–T056 podem executar em paralelo antes da validação final.

## Implementation Strategy

### MVP First

1. Completar Setup e Foundational.
2. Implementar US1 até existir uma operação assíncrona que extrai JPEGs e os
   disponibiliza no projeto, preservando o original.
3. Parar e validar quantidade, intervalo, formato, estimativa e hash.
4. Implementar US2 e US3 antes de considerar o UC-VID-005 concluído, porque
   autorização, limites, limpeza, estados e cancelamento são requisitos P1.

### Incremental Delivery

1. Validar cada checkpoint antes de avançar.
2. Manter `trim`, `frame_tool` e o fluxo de imagens intactos; executar regressão
   após alterações partilhadas no modelo, mensagens ou pipeline.
3. Não marcar tarefas como concluídas sem teste ou evidência correspondente.
4. Registar no quickstart os resultados reais, limitações e falhas conhecidas.
