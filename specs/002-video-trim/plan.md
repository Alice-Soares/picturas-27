# Implementation Plan: Recorte temporal de vídeo

**Branch**: `002-video-trim` | **Date**: 2026-10-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from [spec.md](./spec.md)

## Summary

Adicionar uma operação assíncrona de recorte para vídeos já associados a um
projeto, preservando o original e persistindo cada resultado como novo vídeo.
O desenho estende o Projects Service, o Gateway, o armazenamento, o RabbitMQ,
o WebSocket e a biblioteca frontend existentes; não altera o contrato de
processamento de imagens.

## Technical Context

**Language/Version**: Node.js nos serviços; TypeScript/Next.js no frontend;
FFmpeg/FFprobe no container Projects

**Primary Dependencies**: Express, Mongoose, Multer, amqplib, SeaweedFS/S3,
Socket.IO e as dependências existentes do frontend

**Storage**: MongoDB para projetos e operações; SeaweedFS/S3 para originais,
resultados e temporários persistentes; temporários de trabalho em disco

**Testing**: Testes focados existentes em `projects/test`, testes de contrato e
integração, validação Docker/browser e regressão do fluxo de imagens

**Target Platform**: Serviços Linux em Docker Compose e browser suportado pelo
frontend

**Project Type**: Aplicação web distribuída com microserviços Node.js

**Performance Goals**: Criar a operação sem bloquear o pedido HTTP; emitir
progresso de operações demoradas no máximo a cada 5 segundos, conforme
`REQ-VID-Q-016`

**Constraints**: Não carregar vídeos completos em memória; autorizar o projeto
e o vídeo antes de iniciar o processamento; limpar temporários em
falha/cancelamento; não substituir o original; não introduzir regressões nas
imagens

**Scale/Scope**: MVP para uma operação de recorte por pedido, projetos
existentes e perfis registado/premium; sem retoma, substituição ou escolha de
formato

## Constitution Check

*GATE: PASS antes da pesquisa e PASS após o desenho.*

- **Extensão incremental**: PASS — os componentes existentes são estendidos e
  o fluxo de imagens permanece separado.
- **MVP funcional**: PASS — o plano cobre seleção, validação, processamento,
  resultado, progresso, cancelamento e limpeza.
- **Rastreabilidade**: PASS — requisitos, componentes, testes e cenários são
  ligados em [quickstart.md](./quickstart.md).
- **Requisitos verificáveis**: PASS — limites e estados vêm do UC2 e do
  catálogo consolidado; não são introduzidos novos limites de negócio.
- **Arquitetura baseada em evidência**: PASS — reutiliza MongoDB, RabbitMQ,
  WebSocket, SeaweedFS/S3 e padrões presentes no repositório.
- **Responsabilidade da IA**: PASS — decisões e validação ficam documentadas
  para revisão da equipa.

## Project Structure

### Documentation (this feature)

```text
specs/002-video-trim/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/video-trim.md
└── tasks.md              # gerado pelo /speckit-tasks
```

### Source Code (repository root)

```text
frontend/
├── components/project-page/
├── components/
└── lib/

apiGateway/routes/
projects/
├── models/
├── routes/
├── services/
├── utils/
└── test/

imageStorageService/
├── route/
├── services/
└── utils/

wsGateway/
├── utils/
└── index.js
```

**Structure Decision**: Não será criado um serviço autónomo de vídeo no MVP.
O Projects Service será dono da autorização, operação, validação do intervalo
e associação do resultado; a execução será isolada numa fila/worker de vídeo;
Gateway, WebSocket, armazenamento e frontend serão estendidos através dos
padrões existentes.

## Implementation Phases

### Phase 0 — Research

1. Confirmar o contrato de estados, quota e cancelamento com os endpoints
   existentes do users service.
2. Confirmar o formato de mensagens RabbitMQ e eventos `project-op`.
3. Confirmar leitura/escrita de objetos de vídeo sem carregar o conteúdo em
   memória.
4. Registar decisões e alternativas em [research.md](./research.md).

### Phase 1 — Design and contracts

1. Modelar vídeo derivado, intervalo e operação em [data-model.md](./data-model.md).
2. Definir endpoints e eventos em [contracts/video-trim.md](./contracts/video-trim.md).
3. Definir cenários automatizados e manuais em [quickstart.md](./quickstart.md).

### Phase 2 — Implementation preparation

O detalhamento executável será criado pelo `/speckit-tasks` depois da revisão
deste plano e dos artefactos da Fase 1.

## Complexity Tracking

Não há violações da constituição que exijam justificação.
