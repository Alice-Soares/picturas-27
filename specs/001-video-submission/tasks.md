---

description: "Tarefas de implementação do UC-VID-001"
---

# Tasks: Submissão de vídeo

**Input**: Documentos de design em `/specs/001-video-submission/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md),
[research.md](./research.md), [data-model.md](./data-model.md),
[contracts/video-submission.md](./contracts/video-submission.md) e
[quickstart.md](./quickstart.md)

**Organization**: As tarefas estão agrupadas pelas três histórias de utilizador
da spec. A implementação do MVP é a User Story 1; as histórias seguintes
completam rejeição e recuperação.

## Phase 1: Setup

**Purpose**: Preparar dependências e estrutura sem alterar o comportamento de
imagens.

- [X] T001 Confirmar o commit de baseline `719c092bc4f8d74be46134c5e8e041060b1a456f` e documentar o delta de `UC-VID-001` em [specs/001-video-submission/spec.md](./spec.md) e [specs/001-video-submission/plan.md](./plan.md)
- [X] T002 [P] Confirmar nos manifests de [projects/package.json](../../projects/package.json), [apiGateway/package.json](../../apiGateway/package.json), [imageStorageService/package.json](../../imageStorageService/package.json) e [frontend/package.json](../../frontend/package.json) as dependências disponíveis antes de adicionar qualquer pacote
- [X] T003 [P] Instalar FFmpeg/FFprobe na imagem do Projects Service em [projects/Dockerfile](../../projects/Dockerfile), verificar a disponibilidade dos serviços no [docker-compose.yaml](../../docker-compose.yaml) e registar a versão usada em [specs/001-video-submission/quickstart.md](./quickstart.md)
- [X] T004 Definir no plano de testes os ficheiros MP4/H.264, MP4/H.264/AAC, contentor inválido, codec inválido, stream inválido e amostras para cada limite em [specs/001-video-submission/quickstart.md](./quickstart.md)

## Phase 2: Foundational

**Purpose**: Criar os contratos e helpers partilhados que bloqueiam todas as
histórias; nenhuma história começa antes desta fase.

- [X] T005 Criar o vocabulário de vídeo e os códigos de erro de validação em [projects/services/videoValidation.js](../../projects/services/videoValidation.js), incluindo contentor MP4, vídeo H.264, áudio AAC opcional, tamanho, duração, resolução, fps e integridade
- [X] T006 [P] Criar o analisador de metadados em [projects/services/videoMetadata.js](../../projects/services/videoMetadata.js), executando o FFprobe do container e devolvendo contentor, codecs, tamanho, duração, largura, altura e fps, com falhas explícitas
- [X] T007 [P] Criar limites por perfil em [projects/services/videoLimits.js](../../projects/services/videoLimits.js), mantendo literalmente: registado até 100 MB, 5 minutos, largura 1920, altura 1080 e 60 fps; premium até 1 GB, 30 minutos, largura 3840, altura 2160 e 60 fps; rejeitar quando qualquer dimensão exceder o respetivo limite
- [X] T008 Criar o helper de limpeza transacional em [projects/services/videoCleanup.js](../../projects/services/videoCleanup.js), removendo temporários e propagando o erro original sem deixar uma falha com aparência de sucesso
- [X] T009 [P] Criar testes unitários dos helpers em [projects/test/videoValidation.test.js](../../projects/test/videoValidation.test.js), [projects/test/videoMetadata.test.js](../../projects/test/videoMetadata.test.js), [projects/test/videoLimits.test.js](../../projects/test/videoLimits.test.js) e [projects/test/videoCleanup.test.js]

**Checkpoint**: Os contratos de metadados, limites e limpeza estão definidos;
as histórias podem começar sem inventar regras funcionais.

## Phase 3: User Story 1 — Submeter um vídeo válido (Priority: P1) 🎯 MVP

**Goal**: Permitir que um utilizador registado ou premium autenticado submeta
um vídeo válido e o veja associado ao projeto com os metadados corretos.

**Independent Test**: Com uma sessão válida e um projeto autorizado, submeter
um MP4/H.264 dentro dos limites, confirmar referência, objeto, utilizador,
projeto e metadados; confirmar que a quota não diminuiu.

### Tests for User Story 1

- [X] T010 [P] [US1] Criar teste de contrato para sucesso e metadados conforme [specs/001-video-submission/contracts/video-submission.md](./contracts/video-submission.md) em [projects/test/videoSubmission.contract.test.js](../../projects/test/videoSubmission.contract.test.js)
- [ ] T011 [P] [US1] Criar teste de integração de submissão válida e quota inalterada em [projects/test/videoSubmission.integration.test.js](../../projects/test/videoSubmission.integration.test.js), cobrindo `REQ-VID-SUB-001`, `REQ-VID-SUB-004`, `REQ-VID-SUB-005` a `REQ-VID-SUB-007`, `REQ-VID-SUB-010` a `REQ-VID-SUB-015` e `REQ-VID-SUB-025` a `REQ-VID-SUB-029`, `REQ-VID-SUB-032` e `REQ-VID-SUB-033`

### Implementation for User Story 1

- [X] T012 [P] [US1] Adicionar o subdocumento de referência de vídeo ao modelo de projeto em [projects/models/project.js](../../projects/models/project.js), persistindo utilizador, projeto, estágio, objeto, nome original, tamanho, duração, resolução, fps e codecs sem alterar `imgs`
- [X] T013 [US1] Implementar o upload de objeto de vídeo com chave UUID, content-type e estágio `video-src` em [imageStorageService/services/uploadVideo.js](../../imageStorageService/services/uploadVideo.js) e expô-lo em [imageStorageService/route/upload.js](../../imageStorageService/route/upload.js) sem aceitar vídeo através da rota de imagem
- [X] T014 [US1] Implementar a fachada de armazenamento de vídeo em [projects/utils/videoStorage.js](../../projects/utils/videoStorage.js), reutilizando SeaweedFS/S3 e suportando upload e remoção do temporário
- [X] T015 [US1] Implementar a orquestração de submissão válida em [projects/services/videoSubmission.js](../../projects/services/videoSubmission.js), validando antes da referência, preservando o original e associando a submissão ao utilizador e ao projeto
- [X] T016 [US1] Adicionar a rota autenticada de submissão ao Projects Service em [projects/routes/projects.js](../../projects/routes/projects.js), verificando projeto autorizado, versão do projeto e conteúdo multipart antes da persistência
- [X] T017 [US1] Encaminhar a rota de vídeo no API Gateway em [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js), preservando Authorization, `X-Caller-Id`, `X-Project-Version` e respostas de erro
- [X] T018 [US1] Implementar o cliente de submissão em [frontend/lib/projects.ts](../../frontend/lib/projects.ts) e a mutation/cache invalidation em [frontend/lib/mutations/projects.ts](../../frontend/lib/mutations/projects.ts)
- [X] T019 [US1] Criar a área de seleção de vídeos em [frontend/components/video-submission-area.tsx](../../frontend/components/video-submission-area.tsx), aceitando um vídeo por requisição e comunicando estado de transferência sem alterar [frontend/components/image-submission-area.tsx](../../frontend/components/image-submission-area.tsx)
- [X] T020 [US1] Integrar a submissão no diálogo da biblioteca do projeto em [frontend/components/project-page/add-video-dialog.tsx](../../frontend/components/project-page/add-video-dialog.tsx), mostrando sucesso, metadados e erro seguro

**Checkpoint**: A User Story 1 funciona isoladamente para uma submissão válida
e preserva o fluxo de imagens.

## Phase 4: User Story 2 — Rejeitar acesso ou conteúdo inválido (Priority: P1)

**Goal**: Rejeitar sessões não autorizadas, contentores/codecs/streams
incompatíveis e todos os limites excedidos antes da referência persistente.

**Independent Test**: Executar cada cenário de rejeição com utilizador anónimo,
sessão inválida, ficheiro inválido e limites excedidos; confirmar erro seguro,
ausência de referência e ausência de objeto parcial.

### Tests for User Story 2

- [ ] T021 [P] [US2] Criar testes de autorização de ponta a ponta para anónimo, sessão inválida, projeto não autorizado e conteúdo de outro projeto; o teste de política de sala WebSocket não substitui estes cenários, que cobrem `REQ-VID-SUB-001` a `REQ-VID-SUB-003`, `REQ-VID-SUB-026`, `REQ-VID-SUB-027` e `REQ-VID-Q-005`
- [X] T022 [P] [US2] Criar testes de validação para MP4, H.264, AAC opcional, stream legível, tamanho, duração, resolução e fps em [projects/test/videoValidation.integration.test.js](../../projects/test/videoValidation.integration.test.js), cobrindo `REQ-VID-SUB-005` a `REQ-VID-SUB-014` e `REQ-VID-SUB-016` a `REQ-VID-SUB-023`

### Implementation for User Story 2

- [X] T023 [US2] Aplicar limites de parsing multipart antes do buffering no [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js) e em [projects/routes/projects.js](../../projects/routes/projects.js), rejeitando pedidos sem ficheiro com erro funcional explícito
- [X] T024 [US2] Aplicar autenticação e autorização antes de criar referências em [projects/routes/projects.js](../../projects/routes/projects.js), distinguindo anónimo, sessão inválida, utilizador registado e premium
- [X] T025 [US2] Completar a validação real de contentor, streams, codecs e metadados em [projects/services/videoValidation.js](../../projects/services/videoValidation.js), sem confiar apenas no MIME type ou na extensão
- [X] T026 [US2] Implementar mensagens e códigos seguros para cada rejeição em [projects/services/videoErrors.js](../../projects/services/videoErrors.js) e encaminhá-los sem detalhes internos através de [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js)
- [X] T027 [US2] Garantir no modelo e no serviço que referências só são criadas depois das validações em [projects/models/project.js](../../projects/models/project.js) e [projects/services/videoSubmission.js](../../projects/services/videoSubmission.js)

**Checkpoint**: Todos os cenários de acesso, formato, codec, stream e limites
terminam sem referência persistente nem sucesso falso.

## Phase 5: User Story 3 — Cancelar ou recuperar de uma falha (Priority: P1)

**Goal**: Cancelar transferências e recuperar de falhas de rede, validação ou
armazenamento sem objetos parciais ou referências inconsistentes.

**Independent Test**: Cancelar uma transferência e provocar falhas em cada
dependência; confirmar remoção de temporários, ausência de referência e erro
seguro.

### Tests for User Story 3

- [X] T028 [P] [US3] Criar testes de cancelamento e limpeza no serviço de armazenamento em [projects/test/videoCancellation.integration.test.js](../../projects/test/videoCancellation.integration.test.js) e [imageStorageService/test/videoCleanup.test.js](../../imageStorageService/test/videoCleanup.test.js), cobrindo `REQ-VID-SUB-024` e `REQ-VID-Q-007`
- [ ] T029 [P] [US3] Criar testes de integração de falha de rede, armazenamento, duplicados e lote independente; `videoErrorMapping.test.js` cobre apenas o mapeamento de erros e não demonstra estes fluxos, que cobrem `REQ-VID-SUB-024`, `REQ-VID-SUB-030`, `REQ-VID-SUB-031`, `REQ-VID-Q-001`, `REQ-VID-Q-004` e `REQ-VID-Q-008`

### Implementation for User Story 3

- [X] T030 [US3] Implementar cancelamento idempotente e remoção do objeto temporário em [projects/services/videoSubmission.js](../../projects/services/videoSubmission.js) e [projects/services/videoCleanup.js](../../projects/services/videoCleanup.js)
- [X] T031 [US3] Garantir que falhas do armazenamento, análise ou rede não criam referências e preservam o erro funcional em [projects/routes/projects.js](../../projects/routes/projects.js) e [projects/services/videoSubmission.js](../../projects/services/videoSubmission.js)
- [X] T032 [US3] Implementar submissões independentes para lotes no [frontend/lib/projects.ts](../../frontend/lib/projects.ts), devolvendo por vídeo `concluída`, `rejeitada`, `cancelada` ou `falhada` e isolando falhas
- [X] T033 [US3] Implementar cancelamento no cliente e atualização de estado em [frontend/components/video-submission-area.tsx](../../frontend/components/video-submission-area.tsx) e [frontend/lib/mutations/projects.ts](../../frontend/lib/mutations/projects.ts)
- [X] T034 [US3] Verificar que nomes duplicados oferecem manter ambos ou cancelar, sem substituir silenciosamente, em [frontend/components/project-page/add-video-dialog.tsx](../../frontend/components/project-page/add-video-dialog.tsx) e [projects/services/videoSubmission.js](../../projects/services/videoSubmission.js)

**Checkpoint**: Cancelamento, falhas e lotes deixam o armazenamento e a
biblioteca consistentes.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validar o incremento completo e documentar evidência sem alterar
requisitos.

- [X] T035 [P] Atualizar instruções de execução e testes em [README.md](../../README.md) com os serviços, dependências e cenários do [quickstart.md](./quickstart.md)
- [ ] T036 [P] Confirmar que o fluxo existente de imagens continua funcional e documentar o resultado em [specs/001-video-submission/quickstart.md](./quickstart.md)
- [ ] T037 [P] Executar a matriz de aceitação dos 33 requisitos `REQ-VID-SUB-*` e registar resultados em [specs/001-video-submission/quickstart.md](./quickstart.md)
- [ ] T038 Rever logs e respostas para garantir que não contêm segredos, credenciais, caminhos internos ou detalhes de comandos em [apiGateway/routes/projects.js](../../apiGateway/routes/projects.js), [projects/services/videoErrors.js](../../projects/services/videoErrors.js) e [imageStorageService/route/upload.js](../../imageStorageService/route/upload.js)
- [ ] T039 Executar `git diff --check`, lint/build/testes disponíveis nos manifests e a validação end-to-end do quickstart antes de marcar o `UC-VID-001` como concluído

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sem dependências externas.
- **Foundational (Phase 2)**: depende da Setup e bloqueia todas as histórias.
- **User Stories (Phases 3–5)**: dependem da Foundational; US2 e US3 usam
  componentes de US1, portanto a ordem recomendada é US1 → US2 → US3.
- **Polish (Phase 6)**: depende das três histórias que forem incluídas no MVP.

### User Story Dependencies

- **US1**: começa depois da Phase 2 e entrega o MVP mínimo.
- **US2**: depende de US1 para exercitar o mesmo contrato com rejeições.
- **US3**: depende de US1 e US2 para limpar os caminhos de sucesso e rejeição.

### Parallel Opportunities

- T002, T003 e T004 podem executar em paralelo.
- T006, T007 e T009 podem executar em paralelo depois de T005.
- T010 e T011 podem ser escritos em paralelo antes de T012–T020.
- T012, T013 e T014 podem ser implementados em paralelo; T015 depende deles.
- T021 e T022 podem executar em paralelo depois de US1.
- T028 e T029 podem executar em paralelo depois de US2.
- T035–T038 podem executar em paralelo depois das histórias.

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Concluir Setup e Foundational.
2. Implementar US1 e o seu teste independente.
3. Parar e validar uma submissão válida, metadados, associação e quota.
4. Só depois avançar para rejeições e recuperação.

### Incremental Delivery

1. US1: submissão válida.
2. US2: autorização, validação e limites.
3. US3: cancelamento, limpeza, falhas, duplicados e lotes.
4. Polish: regressão de imagens, matriz de aceitação e documentação.

Cada checkpoint deve ser validado antes de marcar as tarefas da fase como
concluídas.
