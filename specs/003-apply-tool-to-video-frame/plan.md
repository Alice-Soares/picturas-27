# Implementation Plan: Aplicar ferramenta a fotogramas de vídeo

**Branch**: `003-apply-tool-to-video-frame` | **Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

**Input**: [spec.md](./spec.md), o caso de uso
[UC-VID-003](../../docs/use-cases/UC-VID-003-aplicar-ferramenta-fotogramas.md)
e o catálogo consolidado. A especificação existe; as decisões de negócio seguem
essas fontes, não inferências do código.

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Estender o pipeline assíncrono de vídeo para extrair fotogramas num intervalo e
taxa escolhidos, aplicar uma ou mais ferramentas de imagem existentes pela ordem
selecionada e recompor um novo vídeo. O original permanece imutável, o áudio e a
resolução são preservados quando aplicável, e falhas/cancelamento limpam os
temporários. O Projects Service continua dono da autorização e da operação;
RabbitMQ, armazenamento, WebSocket e frontend são estendidos sem alterar o
contrato de uma ferramenta de imagem isolada.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Node.js 20 nos serviços; TypeScript/Next.js no frontend;
Python nos workers de ferramentas existentes; FFmpeg/FFprobe no Projects

**Primary Dependencies**: Express, Mongoose, amqplib, Multer, FormData,
SeaweedFS/S3, RabbitMQ, Socket.IO e ferramentas em `Tools/`

**Storage**: MongoDB para projetos/operações; SeaweedFS/S3 para vídeos,
fotogramas temporários e resultado; disco temporário do worker para staging

**Testing**: testes Node focados em `projects/test`, contratos HTTP, integração
com filas/armazenamento/quota e regressão do processamento de imagens; `next
build` e validação Docker/Compose quando disponíveis

**Target Platform**: serviços Linux em Docker Compose e browser suportado pelo
frontend

**Project Type**: aplicação web distribuída com microserviços Node.js e workers
de ferramentas Python

**Performance Goals**: iniciar sem bloquear HTTP; emitir progresso no máximo a
cada 5 segundos, seguindo o padrão de operações de vídeo existente; não definir
uma meta de paralelismo no MVP

**Constraints**: apenas utilizadores registados/premium; respeitar limites de
perfil e quota; não carregar vídeos completos em memória; aceitar apenas
ferramentas que produzam uma imagem por fotograma; preservar original; limpar
temporários em falha/cancelamento; não inventar codecs ou limites adicionais

**Scale/Scope**: MVP para um vídeo por operação, intervalo temporal opcional,
encadeamento ordenado de ferramentas e resultado persistido no projeto; limite
de paralelismo adiado para Fase 2

## Constitution Check

_GATE: PASS antes da Fase 0 e PASS após a Fase 1._

- **Extensão incremental**: PASS — reutiliza Projects Service, fila, storage,
  WebSocket e workers de imagem; não reescreve o baseline.
- **MVP funcional**: PASS — cobre seleção, processamento, resultado, progresso,
  repetição de uma falha, cancelamento e limpeza; paralelismo avançado fica fora.
- **Rastreabilidade**: PASS — requisitos FRM, componentes, testes e cenários
  serão ligados em [quickstart.md](./quickstart.md).
- **Requisitos verificáveis**: PASS no desenho — limites, estados e regras vêm
  do UC-VID-003, catálogo e RNG existentes; validação E2E continua pendente.
- **Arquitetura baseada em evidência**: PASS — FFmpeg já está no Dockerfile e
  RabbitMQ/ferramentas têm contratos existentes.
- **Responsabilidade da IA**: PASS no registo documental — as fontes e os
  limites de validação estão identificados; consultar `quickstart.md` e
  `tasks.md` para o trabalho ainda pendente.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
frontend/components/project-page/   # seleção de vídeo, ferramenta e parâmetros
frontend/lib/                        # chamadas e tipos de operação
apiGateway/routes/                   # encaminhamento existente, se necessário
projects/models/                     # operação e referências de vídeo
projects/routes/                     # endpoints de criação/consulta/cancelamento
projects/services/                   # orquestração, extração, recomposição
projects/utils/                      # mensagens RabbitMQ/WebSocket e storage
projects/test/                       # unitários, contratos e integração
Tools/                               # workers de ferramentas de imagem
wsGateway/                           # eventos project-op existentes
```

**Structure Decision**: Não será criado um serviço autónomo. O Projects Service
será dono do ciclo de vida da operação e usará uma fila dedicada de aplicação a
fotogramas; os workers de imagem continuam a receber um fotograma e a devolver
uma imagem através do contrato existente.

## Phase 0 — Research

1. Confirmar quotas, perfis, estados, autorização e regras transversais já
   implementadas para operações de vídeo.
2. Confirmar o contrato de mensagem das ferramentas (`ToolMSG`) e a forma de
   transferir fotogramas/resultados sem expor paths internos.
3. Confirmar extração/recomposição FFmpeg, preservação de áudio/resolução e
   limpeza idempotente em falha/cancelamento.
4. Registar decisões e alternativas em [research.md](./research.md).

## Phase 1 — Design and contracts

1. Modelar operação por fotogramas, cadeia de ferramentas, intervalo, taxa,
   tentativas e vídeo resultante em [data-model.md](./data-model.md).
2. Definir endpoints e eventos em [contracts/video-frame-tool.md](./contracts/video-frame-tool.md).
3. Definir validação automatizada e manual em [quickstart.md](./quickstart.md).

## Phase 2 — Implementation preparation

O detalhamento executável será criado por `/speckit-tasks` depois da revisão
deste plano e dos artefactos da Fase 1.

## Complexity Tracking

Não há violações da constituição que exijam justificação.

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ------------------------------------ |
| Nenhuma   | N/A        | N/A                                  |
