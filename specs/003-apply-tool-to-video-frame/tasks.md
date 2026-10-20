# Tasks: Aplicar ferramenta a fotogramas de vídeo

**Input**: [plan.md](./plan.md), [research.md](./research.md),
[data-model.md](./data-model.md), [video-frame-tool.md](./contracts/video-frame-tool.md)
e [quickstart.md](./quickstart.md)

**Nota de fonte**: As histórias abaixo são derivadas de [spec.md](./spec.md),
do UC-VID-003 e dos requisitos `REQ-VID-FRM-*`. A especificação já está
preenchida; os artefactos devem permanecer sincronizados quando os requisitos
forem alterados.

## User Stories

- **US1 (P1)**: Um utilizador registado/premium seleciona uma ferramenta de
  imagem, configura parâmetros, intervalo e taxa, e obtém um novo vídeo
  processado sem alterar o original. Cobre FRM-001, FRM-002 e FRM-003.
- **US2 (P2)**: O utilizador encadeia duas ou mais ferramentas compatíveis e o
  sistema aplica-as pela ordem selecionada a cada fotograma. Cobre FRM-004.
- **US3 (P1)**: O utilizador acompanha, cancela ou recupera de falhas do
  processamento; cada fotograma falha no máximo uma vez antes de a operação
  terminar como falhada. Cobre FRM-005 e FA3.

## Dependencies and Order

```text
Setup -> Foundational -> US1 -> US2
                         \-> US3
```

US1 cria o modelo, contrato e worker base. US2 e US3 podem avançar em paralelo
quando os contratos e o worker base de US1 estiverem concluídos.

## Phase 1: Setup

- [x] T001 Confirmar a spec vazia e registar no issue/PR de implementação que os requisitos fonte são o UC-VID-003 e `REQ-VID-FRM-001` a `REQ-VID-FRM-005` em `specs/003-apply-tool-to-video-frame/spec.md`
- [x] T002 [P] Adicionar o tipo de operação `frame_tool` e a fila dedicada à configuração de integração existente em `projects/utils/rabbit_mq.js`
- [x] T003 [P] Documentar no contrato de integração a mensagem mínima `operationId`, `projectId`, `sourceVideoId` e cadeia de ferramentas em `specs/003-apply-tool-to-video-frame/contracts/video-frame-tool.md`

## Phase 2: Foundational

- [x] T004 Estender o schema de operação para aceitar `type: frame_tool`, ferramentas, intervalo, taxa, tentativas e estados `queued`, `processing`, `completed`, `failed`, `cancelled` em `projects/models/videoOperation.js`
- [x] T005 [P] Criar validação de ferramenta, parâmetros, intervalo, taxa e `outputType: image`, rejeitando ferramentas de metadados em `projects/services/videoFrameToolValidation.js`
- [x] T006 [P] Criar códigos e mensagens públicas para autorização, ferramenta incompatível, intervalo, quota, cancelamento e falha sem expor paths internos em `projects/services/videoFrameToolErrors.js`
- [x] T007 [P] Estender o evento de operação para transportar `type: frame_tool`, progresso, resultado e erro seguro em `projects/utils/videoOperationMsg.js`
- [x] T008 [P] Criar helpers de extração e recomposição FFmpeg que usem disco temporário e preservem áudio/resolução quando aplicável em `projects/services/videoFramePipeline.js`
- [x] T009 Adicionar funções de storage para descarregar o vídeo fonte, transferir frames/resultados e eliminar objetos parciais de forma idempotente em `projects/utils/videoStorage.js`

## Phase 3: User Story 1 - Processar uma ferramenta em vídeo (P1)

**Goal**: criar e concluir uma operação com uma ferramenta de imagem compatível,
intervalo/taxa válidos, vídeo resultante novo e original intacto.

**Independent test**: dado um vídeo autorizado e uma ferramenta que devolve
`output.type = image`, criar a operação, observar `queued`/`processing`, e
confirmar `completed`, novo vídeo, áudio/resolução preservados e original
inalterado.

- [x] T010 [P] [US1] Criar teste unitário para validação de ferramenta, parâmetros, intervalo, taxa e compatibilidade de saída em `projects/test/videoFrameToolValidation.test.js`
- [x] T011 [P] [US1] Criar teste de contrato para criação, consulta e cancelamento básico da operação em `projects/test/videoFrameTool.contract.test.js`
- [x] T012 [US1] Implementar `createFrameToolOperation` com autorização de projeto/vídeo, perfil registado/premium, quota e persistência `queued` em `projects/services/videoOperationService.js`
- [x] T013 [US1] Adicionar endpoints `POST /projects/:user/:project/video/:videoId/frame-tool`, `GET /projects/:user/:project/video-operations/:operationId` e cancelamento idempotente em `projects/routes/projects.js`
- [x] T014 [US1] Implementar worker que extrai frames no intervalo, publica cada frame na ferramenta selecionada, recolhe imagens e recompõe um novo vídeo em `projects/services/videoFrameToolWorker.js`
- [x] T015 [US1] Ligar o consumidor `frame_tool` ao arranque do Projects Service sem alterar as filas de imagens em `projects/app.js`
- [x] T016 [US1] Integrar referências de vídeo resultado com `sourceVideoId`, metadados, stage e preservação do original em `projects/controllers/project.js`
- [x] T017 [US1] Adicionar funções frontend para criar/consultar/cancelar operações e receber os campos do contrato em `frontend/lib/projects.ts`
- [x] T018 [US1] Criar o diálogo de seleção de ferramenta, parâmetros, intervalo e taxa com estados de progresso e resultado em `frontend/components/project-page/video-frame-tool-dialog.tsx`
- [x] T019 [US1] Integrar a ação de aplicar ferramenta na biblioteca de vídeos e invalidar o projeto após `completed` em `frontend/components/project-page/project-video-list.tsx`
- [ ] T020 [US1] Criar teste de integração de sucesso, autorização e preservação de áudio/resolução em `projects/test/videoFrameTool.integration.test.js`

## Phase 4: User Story 2 - Encadear ferramentas (P2)

**Goal**: aplicar uma cadeia ordenada de ferramentas compatíveis ao mesmo frame.

**Independent test**: dado um vídeo e duas ferramentas determinísticas, confirmar
que cada frame passa por ambas na ordem de `position` e que a saída é um único
vídeo persistido.

- [x] T021 [P] [US2] Criar teste de contrato para uma cadeia ordenada em `projects/test/videoFrameTool.chain.contract.test.js`
- [x] T022 [US2] Validar que `tools` é uma lista ordenada, que cada item tem `procedure`, `params` e `position`, e que cada resultado intermédio tem `outputType: image` em `projects/services/videoFrameToolValidation.js`
- [x] T023 [US2] Implementar o adaptador que encadeia as respostas de imagem sem persistir resultados intermédios no projeto em `projects/services/videoFrameToolWorker.js`
- [x] T024 [US2] Expor a cadeia ordenada no pedido/resposta da operação sem devolver dados internos em `projects/routes/projects.js`
- [ ] T025 [US2] Criar teste de integração de duas ferramentas e rejeição de ferramenta de metadados em `projects/test/videoFrameTool.chain.integration.test.js`

## Phase 5: User Story 3 - Retry, progresso e cancelamento (P1)

**Goal**: tornar falhas e cancelamento observáveis, limitados e limpos.

**Independent test**: provocar uma falha de frame, confirmar uma repetição; provocar
falha novamente e confirmar `failed`, limpeza e refund. Cancelar em `queued` e
`processing` e confirmar `cancelled` sem vídeo parcial.

- [ ] T026 [P] [US3] Criar testes unitários para transições terminais, uma repetição máxima e limpeza após falha em `projects/test/videoFrameToolFailure.test.js`
- [ ] T027 [P] [US3] Criar teste de integração para cancelamento cooperativo, limpeza e refund de quota em `projects/test/videoFrameToolCancellation.integration.test.js`
- [x] T028 [US3] Implementar retry exatamente uma vez por frame e falha terminal após a segunda tentativa em `projects/services/videoFrameToolWorker.js`
- [x] T029 [US3] Implementar cancelamento cooperativo antes de cada frame, durante a execução e antes de persistir o resultado em `projects/services/videoFrameToolWorker.js`
- [x] T030 [US3] Publicar progresso sem regrredir e no máximo a cada 5 segundos através de `project-op` em `projects/services/videoFrameToolWorker.js`
- [x] T031 [US3] Garantir refund de quota, remoção de temporários e eliminação de resultado parcial em `projects/services/videoOperationService.js`
- [x] T032 [US3] Mostrar estados `queued`, `processing`, `completed`, `failed` e `cancelled`, erro seguro e cancelamento no diálogo em `frontend/components/project-page/video-frame-tool-dialog.tsx`
- [x] T033 [US3] Criar teste de isolamento dos eventos `project-op` por projeto em `wsGateway/test/project_events.test.js`

## Phase 6: Polish and Cross-Cutting Concerns

- [x] T034 [P] Atualizar a documentação de execução e limitações, incluindo paralelismo por perfil adiado para Fase 2, em `specs/003-apply-tool-to-video-frame/quickstart.md`
- [x] T035 [P] Adicionar a matriz de rastreabilidade requisito -> componente -> teste -> resultado em `specs/003-apply-tool-to-video-frame/quickstart.md`
- [ ] T036 Executar os cenários do quickstart e registar perfil, projeto, `operationId`, estado final e `pass`/`fail` em `specs/003-apply-tool-to-video-frame/quickstart.md`
- [ ] T037 Executar `node test/run-tests.js` em `projects`, regressão das ferramentas de imagem, `docker compose config` e `git diff --check`, corrigindo apenas problemas desta feature

## Parallel Execution Examples

### US1

```text
T010, T011, T017 podem avançar em paralelo após T005-T007.
T012 -> T013 -> T014/T015/T016.
T018 e T020 podem avançar em paralelo depois de T013 e do contrato estabilizado.
```

### US2

```text
T021 e T022 podem avançar em paralelo.
T023 depende de T014; T024 depende de T013; T025 depende de T023/T024.
```

### US3

```text
T026 e T027 podem avançar em paralelo.
T028/T029 dependem de T014; T030/T031 dependem do worker e da operação base.
T032 pode avançar em paralelo com T030; T033 é independente do worker.
```

## Implementation Strategy

1. Implementar US1 até existir um fluxo completo com uma ferramenta, resultado
   novo e preservação do original.
2. Implementar US3 em seguida para que retry, cancelamento e limpeza protejam o
   fluxo antes de adicionar complexidade de cadeia.
3. Implementar US2 como extensão do adaptador, mantendo o contrato de cada
   ferramenta de imagem.
4. Executar validação focada após cada fase e só depois a regressão completa.

**Suggested MVP**: US1 + US3. US2 é a extensão recomendada seguinte; o limite
de paralelismo por perfil permanece fora do MVP conforme a decisão do UC-VID-003.
