# Implementation Plan: Gestão de Áudio de Vídeo

**Branch**: `006-gerir-audio` | **Date**: 2026-10-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/006-gerir-audio/spec.md`

## Summary

Implementar remover, substituir e extrair áudio preservando o vídeo original.
A extensão reutiliza o ciclo de vida de operações assíncronas do Projects
Service, acrescenta uma operação `audio` com ação explícita, usa uma ferramenta
FFmpeg/RabbitMQ stateless e persiste resultados de áudio como conteúdo próprio
do projeto. Autorização, quota, estados, eventos, limpeza e append versionado
permanecem responsabilidade do Projects Service.

## Technical Context

**Language/Version**: Node.js/CommonJS no Projects Service; Python no worker `video_audio`; versões determinadas pelos Dockerfiles existentes.

**Primary Dependencies**: Express, Mongoose, Multer, RabbitMQ/amqplib, FFmpeg/FFprobe, SeaweedFS através da Image Storage façade.

**Storage**: MongoDB para projetos/operações; SeaweedFS através da Image Storage Service; volume partilhado `image_data` para temporários entre Projects Service e worker.

**Testing**: `node projects/test/run-tests.js` para contratos/validações existentes e novos testes focados; testes de integração do Projects Service; testes de contrato do worker Python; validação manual/E2E conforme [quickstart.md](./quickstart.md).

**Target Platform**: Serviços Linux executados por Docker Compose; cliente web por HTTPS através do Nginx.

**Project Type**: Aplicação web de microserviços com Projects Service, Image Storage Service, frontend e worker de processamento.

**Performance Goals**: Operações demoradas devem ser assíncronas; operações com duração superior a 5 segundos devem publicar pelo menos uma atualização de progresso. Não é introduzida meta de throughput no MVP.

**Constraints**: MP3 e M4A/AAC são os únicos formatos de substituição; original imutável; sem resultados parciais; quota devolvida em falha/cancelamento/sem efeito; acesso apenas ao projeto autorizado; sem múltiplas faixas no MVP.

**Scale/Scope**: Um caso de uso de vídeo, três ações de áudio, uma nova operação assíncrona e um novo tipo de conteúdo de biblioteca; sem reescrita do pipeline de imagens.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Evidence |
|---|---|---|
| Extensão incremental, sem reescrita | PASS | O delta limita-se a UC-VID-007 e reutiliza operações, storage façade, eventos e filas existentes. |
| MVP funcional e âmbito controlado | PASS | Remover, substituir e extrair são os únicos fluxos; múltiplas faixas, retoma e versionamento do original estão fora do MVP. |
| Rastreabilidade ponta a ponta | PASS | [spec.md](./spec.md) liga UC-VID-007 a `REQ-VID-AUD-*`, requisitos comuns e evidência de validação; este plano liga componentes e testes. |
| Requisitos verificáveis e IDs estáveis | PASS | IDs existentes são preservados; critérios Dado/Quando/Então e requisitos comuns não são duplicados. |
| Arquitetura baseada em evidência | PASS | Decisões derivam de `videoOperationService`, `videoConversionDispatcher`, `videoOperation` e `docker-compose.yaml`. |
| Segurança e responsabilidade | PASS | Autorização antes da leitura, validação de conteúdo, mensagens públicas sem detalhes internos e sem segredos. |

## Project Structure

### Documentation (this feature)

```text
specs/006-gerir-audio/
├── plan.md
├── research.md
├── data-model.md
├── contracts/
└── quickstart.md
```

### Source Code (repository root)

```text
projects/
├── models/videoOperation.js
├── models/project.js
├── controllers/project.js
├── routes/projects.js
├── services/videoOperationService.js
├── services/videoAudioDispatcher.js
├── services/videoAudioValidation.js
├── services/videoAudioErrors.js
├── utils/videoAudioMsg.js
└── test/videoAudio*.test.js
Tools/video_audio/
├── video_audio.py
├── Dockerfile
└── requirements.txt
imageStorageService/
└── services/uploadAudio.js
frontend/
├── components/project-page/video-audio-dialog.tsx
├── components/project-page/project-video-list.tsx
└── lib/{projects.ts,mutations/projects.ts}
```

**Structure Decision**: Manter a arquitetura de microserviços existente. O
Projects Service orquestra a operação e o frontend expõe a ação; o worker Python
processa apenas media; a Image Storage Service mantém a fachada de armazenamento.
Os contratos públicos e o modelo detalhado estão nos artefactos desta pasta.

## Phase 0: Research

Concluída em [research.md](./research.md). Foram resolvidas as decisões sobre
modelo de operação, fronteira do worker, conteúdo de áudio, storage, contratos
FFmpeg e validação de segurança.

## Phase 1: Design

- [data-model.md](./data-model.md) define entidades, relações, validações e estados.
- [contracts/](./contracts/) define os contratos REST, eventos e RabbitMQ.
- [quickstart.md](./quickstart.md) define a validação executável do MVP.

## Post-Design Constitution Check

| Gate | Status | Evidence |
|---|---|---|
| Incremental extension | PASS | Apenas componentes de vídeo/áudio e superfícies de biblioteca são estendidos; imagens permanecem compatíveis. |
| MVP and explicit non-implementation | PASS | O design declara fora do âmbito múltiplas faixas, retoma e substituição do original. |
| End-to-end traceability | PASS | Cada grupo de requisitos AUD/COM/Q tem componente e validação no modelo, contratos e quickstart. |
| Evidence-based architecture | PASS | O design segue os padrões observados no Projects Service, conversão existente, armazenamento e Compose. |
| Security and validation | PASS | Contratos não expõem paths/segredos; quickstart inclui autorização cruzada, quota, falha, cancelamento e limpeza. |

## Complexity Tracking

Não há violações da constituição a justificar. A nova ferramenta e o conteúdo
de áudio são extensões delimitadas, necessárias para cumprir `REQ-VID-AUD-011`,
`REQ-VID-AUD-015` e `DQ-002`; não constituem uma reescrita ou um novo produto.
