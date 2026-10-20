# Implementation Plan: Conversão de Formato e Resolução de Vídeo

**Branch**: `004-video-conversion` | **Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-video-conversion/spec.md`

## Summary

Estender o pipeline de operações de vídeo existente para suportar o
`UC-VID-004`: apresentar metadados e opções suportadas, validar a configuração
e os limites de perfil, criar uma operação assíncrona, delegar a transcodificação
numa Tool autónoma, guardar o resultado como novo vídeo e comunicar progresso,
cancelamento e falhas. O Projects Service mantém a orquestração, autorização,
quota, persistência e eventos; a Tool executa exclusivamente a conversão
multimédia. As filas de imagem permanecem inalteradas.

A matriz de formatos do MVP permanece conservadora: MP4 com vídeo H.264 e
áudio AAC quando aplicável, conforme `UC-VID-004/RN1`. A implementação deve
expor essa matriz centralmente e não prometer codecs ou contentores adicionais.

## Technical Context

**Language/Version**: Node.js 20 no Projects Service; TypeScript/React 19 no
frontend; Python 3.11 na nova Tool de conversão

**Primary Dependencies**: Express, Mongoose, Axios, RabbitMQ via `amqplib` e
helpers Python existentes, FFmpeg/FFprobe, Next.js, React Query e componentes
UI existentes

**Storage**: MongoDB do Projects Service para operações/projetos; SeaweedFS
através do Image Storage Service para vídeos; diretório temporário da Tool
durante a transcodificação, com volumes e caminhos de entrada/saída definidos
no contrato interno RabbitMQ

**Testing**: Jest através de `projects/test/run-tests.js`, testes de contrato e
integração existentes, build do frontend, `docker compose config` e validação
manual pelo quickstart

**Target Platform**: Docker Compose em Linux containers, acedido pela aplicação
web HTTPS em `https://localhost:8080`

**Project Type**: Aplicação web com microserviços, API REST, WebSocket, worker
de orquestração e Tool assíncrona de processamento

**Performance Goals**: A confirmação não deve esperar pelo fim da conversão;
operações demoradas devem publicar progresso observável no máximo a cada 5
segundos, conforme `REQ-VID-Q-016`

**Constraints**: Perfis registados limitados a `1920x1080`; premium limitado a
`3840x2160`; conteúdo original imutável; autorização por projeto/conteúdo;
quota reservada e devolvida em falha/cancelamento; nenhuma referência ou objeto
temporário parcial acessível

**Scale/Scope**: MVP para um vídeo por operação e os perfis registado/premium.
Conversão em lote, perfis predefinidos, novos formatos não aprovados e
alterações de produção ficam fora do âmbito. A Tool é stateless e processa uma
mensagem por operação, sem conhecer projetos, utilizadores ou quotas.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Princípio | Verificação |
|---|---|
| Extensão incremental | PASS — estende a orquestração de vídeo, frontend e catálogo de Tools existentes; não reescreve a baseline. |
| MVP funcional | PASS — cobre um fluxo completo de conversão, com limites e recuperação; produção em escala fica fora do âmbito. |
| Rastreabilidade | PASS — requisitos `REQ-VID-CONV-*` e transversais estão ligados aos contratos, modelo, quickstart e testes esperados. |
| Requisitos verificáveis | PASS — contratos e cenários usam estados, limites e resultados observáveis com origem documentada. |
| Identificação estável | PASS — usa `UC-VID-004`, `REQ-VID-CONV-*` e decisões/tarefas a definir sem reutilizar IDs. |
| Arquitetura baseada em evidência | PASS — reutiliza operação, armazenamento, eventos e padrões de Tools existentes; separa a transcodificação da orquestração. |
| Segurança e responsabilidade | PASS — sem segredos; autorização, isolamento de eventos, limpeza e documentação de IA ficam explícitos. |

No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/004-video-conversion/
├── plan.md
├── research.md
├── data-model.md
├── contracts/
│   └── video-conversion.md
├── quickstart.md
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
projects/
├── models/videoOperation.js
├── services/
│   ├── videoOperationService.js
│   ├── videoConversionValidation.js       # novo
│   ├── videoConversionErrors.js           # novo
│   └── videoConversionDispatcher.js       # novo
├── routes/projects.js
├── utils/
│   ├── videoOperationMsg.js
│   ├── videoStorage.js
│   └── videoConversionMsg.js              # novo
├── app.js
└── test/
    ├── videoConversionValidation.test.js  # novo
    ├── videoConversion.contract.test.js   # novo
    ├── videoConversion.integration.test.js# novo
    ├── videoConversionTool.contract.test.js # novo
    └── videoConversionCleanup.test.js     # novo

frontend/
├── components/project-page/
│   ├── video-conversion-dialog.tsx        # novo
│   └── project-video-list.tsx
└── lib/
    ├── projects.ts
    └── mutations/projects.ts

Tools/video_conversion/
├── Dockerfile                              # novo
├── __init__.py                             # novo
├── video_conversion.py                     # novo
└── requirements.txt                        # novo

Tools/utils/
└── tool_msg.py                             # extensão do contrato para vídeo

rabbitMQ/                                   # nova fila/declaração
docker-compose.yaml                         # novo serviço video_conversion_tool
README.md                                   # catálogo e procedimento da nova Tool
```

**Structure Decision**: Criar `Tools/video_conversion` como microserviço
autónomo e stateless. O Projects Service não executa FFmpeg nem conhece detalhes
de comandos de conversão: valida o pedido, persiste a operação, reserva quota,
publica uma mensagem `video_conversion`, recebe uma resposta correlacionada e
persiste o resultado. A Tool recebe apenas caminhos/parametrização validados,
executa FFmpeg, publica progresso e devolve metadados ou erro. A Tool não
acede à base de dados, não aplica autorização e não decide quota.

## Design Decisions

- **DA-01 / operação comum**: usar `type: "conversion"` no modelo existente,
  preservando a máquina de estados e as consultas autorizadas.
- **DA-02 / Tool autónoma**: executar a transcodificação em
  `Tools/video_conversion` num container próprio, seguindo o padrão Python,
  Docker e RabbitMQ das Tools existentes.
- **DA-03 / fila isolada**: usar a chave `video_conversion` no exchange
  `picturas`, sem reutilizar filas de imagem. A mensagem inclui
  `correlationId`, caminhos de entrada/saída e opções já validadas.
- **DA-04 / fronteira de responsabilidades**: o Projects Service mantém
  autorização, quota, operações, armazenamento persistente e eventos; a Tool
  mantém apenas processamento de vídeo, temporários próprios e resposta
  correlacionada.
- **DA-05 / conteúdo derivado**: guardar cada resultado como nova referência
  com `sourceVideoId`, usando `appendVideoIfVersion`.
- **DA-06 / matriz aprovada**: centralizar MP4/H.264/AAC e rejeitar combinações
  não documentadas antes da fila.
- **DA-07 / cancelamento seguro**: o Projects Service sinaliza cancelamento
  por mensagem correlacionada; a Tool termina o processo FFmpeg e limpa
  temporários. O Projects Service valida o estado antes do upload e append e
  limpa uploads parciais.
- **DA-08 / eventos mínimos**: reutilizar `project-op`, enviando apenas
  identificador, tipo, estado, progresso, resultado e erro público.

## Phase 0 — Research Completed

As decisões e alternativas estão em [research.md](./research.md). Foram
resolvidos os pontos que poderiam bloquear o design:

1. o tipo e os campos adicionais da operação;
2. a fronteira entre Projects Service, Tool e fila;
3. a matriz conservadora de contentor/codec;
4. a semântica de resolução exata;
5. o estágio e o padrão de armazenamento;
6. quota, cancelamento e limpeza;
7. contratos e progresso;
8. estimativa de tamanho nullable.

## Phase 1 — Design Completed

- [data-model.md](./data-model.md) define vídeo de origem, configuração,
  operação, resultado, relações e transições.
- [contracts/video-conversion.md](./contracts/video-conversion.md) define
  opções, criação, consulta, cancelamento, eventos e erros públicos.
- [quickstart.md](./quickstart.md) define cenários manuais, testes esperados,
  regressão e evidências necessárias.

## Traceability and Validation

| Requisitos | Componentes principais | Evidência |
|---|---|---|
| `REQ-VID-CONV-001` a `004` | rota de opções, validador, diálogo de conversão | contrato, teste de opções e cenário 1–3 |
| `REQ-VID-CONV-005` a `008` | validador de matriz/limites/estimativa | testes unitários e cenários 4–5 |
| `REQ-VID-CONV-009` e `011` | operação, RabbitMQ, worker, `project-op`, diálogo | contrato, integração e cenário 6 |
| `REQ-VID-CONV-010` | dispatcher, Tool, armazenamento, `appendVideoIfVersion`, modelo de vídeo | contrato interno, integração e cenário 7 |
| `REQ-VID-COM-*`, `REQ-VID-Q-*` | autorização, quota, estados, limpeza, eventos | testes de falha/cancelamento, segurança e regressão |

## Re-evaluated Constitution Check

| Princípio | Resultado pós-design |
|---|---|
| Incrementalidade e âmbito | PASS — o plano altera apenas superfícies de vídeo relacionadas com `UC-VID-004`. |
| Rastreabilidade e verificabilidade | PASS — cada grupo de requisitos tem contrato, componente e evidência de validação. |
| Arquitetura e domínio | PASS — o modelo trata vídeo, operação, configuração e resultado como conceitos do domínio; a Tool é componente de processamento, não entidade de domínio. |
| Limites e decisões documentadas | PASS — limites vêm do catálogo; a matriz MVP é explicitamente conservadora. |
| Segurança, limpeza e responsabilidade | PASS — autorização, eventos, quota, temporários e limitações são critérios de aceitação. |

No violations requiring justification.

## Complexity Tracking

No constitution violations. No complexity exception is required.
