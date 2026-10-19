# Implementation Plan: Submissão de vídeo

**Branch**: `001-video-submission` | **Date**: 2026-10-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-video-submission/spec.md`

## Summary

Implementar o `UC-VID-001` como extensão do fluxo existente de conteúdos:
receber um vídeo multipart, autorizar o utilizador e o projeto, validar o
conteúdo real e os limites por perfil, armazenar o original, persistir a
referência e limpar temporários em todos os caminhos de falha. O fluxo de
imagens permanece inalterado.

## Technical Context

**Language/Version**: Node.js/JavaScript nos serviços backend; TypeScript/React no frontend; versões definidas nos manifests existentes

**Primary Dependencies**: Express, Multer, Axios, Mongoose, AWS SDK S3/SeaweedFS, Next.js, React Query e FFmpeg/FFprobe instalado na imagem do Projects Service

**Storage**: MongoDB do Projects Service para referências e metadados; SeaweedFS S3 para objetos; volume temporário apenas durante a submissão

**Testing**: testes focados a adicionar nos serviços, validação manual end-to-end documentada em [quickstart.md](./quickstart.md) e regressão do fluxo de imagens

**Target Platform**: serviços Linux em Docker Compose e navegador suportado pelo frontend Next.js

**Project Type**: aplicação web distribuída em microserviços

**Performance Goals**: completar submissões válidas sem bloquear o fluxo do frontend além da transferência; rejeitar antes da persistência quando os metadados excedem limites; não definir metas de produção não existentes na baseline

**Constraints**: manter o contrato de imagens operacional; aplicar limites `RN2`/`RN3`; autorização antes de criar referências; limpeza de objetos parciais; receber vídeos em ficheiros temporários em disco com limite de corpo antes do processamento; não substituir originais duplicados

**Scale/Scope**: uma funcionalidade (`UC-VID-001`), formatos MP4/H.264/AAC,
perfis registado e premium, um vídeo por requisição e lotes implementados como
submissões independentes; sem operações de processamento posteriores

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Extensão incremental**: PASS — o plano altera apenas superfícies necessárias
  e preserva o processamento de imagens.
- **MVP funcional**: PASS — a fatia é a submissão completa, não uma operação
  trivial isolada.
- **Rastreabilidade**: PASS — a spec liga `UC-VID-001` a `REQ-VID-SUB-*`,
  testes previstos, componentes e validação em [quickstart.md](./quickstart.md).
- **Requisitos verificáveis**: PASS — limites e formatos vêm de `RN1`–`RN10`;
  critérios usam `Given/When/Then`.
- **Modelo de domínio**: PASS — [data-model.md](./data-model.md) usa Vídeo,
  Referência, Submissão, Projeto e Utilizador, não classes ou tabelas.
- **Segurança e responsabilidade**: PASS — autorização, mensagens seguras,
  integridade e ausência de segredos estão previstas.

## Project Structure

### Documentation (this feature)

```text
specs/001-video-submission/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── video-submission.md
└── tasks.md              # criado por /speckit-tasks
```

### Source Code (repository root)

```text
frontend/
├── components/                       # upload UI e mensagens
├── lib/projects.ts                   # cliente do upload
└── lib/mutations/projects.ts         # cache e versão do projeto
apiGateway/
└── routes/projects.js                # encaminhamento multipart autenticado
projects/
├── models/project.js                 # referência de vídeo no domínio
├── routes/projects.js                # autorização e orquestração
├── services/videoMetadata.js          # FFprobe e metadados
├── services/videoValidation.js        # regras de formato e perfil
├── services/videoSubmission.js        # persistência tardia e limpeza
└── utils/imageStorage.js             # fachada de armazenamento generalizada
imageStorageService/
├── route/upload.js                   # fronteira de upload do objeto
├── services/uploadImage.js           # padrão de chaves/content-type
└── utils/stages.js                   # estágios do conteúdo
```

**Structure Decision**: Estender frontend, API Gateway, Projects Service e
Storage Service existentes, reutilizando autenticação, versão do projeto e
SeaweedFS. O contrato de vídeo deve ficar separado do contrato de imagem,
embora possa reutilizar helpers generalizados.

## Phase 0 — Research

Concluída em [research.md](./research.md). Foram resolvidos os pontos sobre
multipart, validação de conteúdo, limites, persistência atómica, limpeza,
duplicados, lotes e âmbito MVP. A investigação também registou o risco de
`memoryStorage()` e a necessidade de limitar o corpo antes do buffering.

## Phase 1 — Design

- [data-model.md](./data-model.md): conceitos, relações e estados.
- [contracts/video-submission.md](./contracts/video-submission.md): contrato
  funcional de submissão, rejeição, cancelamento e autorização.
- [quickstart.md](./quickstart.md): cenários end-to-end e evidência esperada.

### Constitution re-check

- **Extensão incremental**: PASS — os artefactos isolam o contrato de vídeo e
  preservam o upload de imagens.
- **MVP e limites aprovados**: PASS — os limites e formatos são os de
  `UC-VID-001`; capacidades das questões abertas ficaram fora de âmbito.
- **Rastreabilidade**: PASS — o modelo, contrato e quickstart apontam para a
  especificação e os seus requisitos.
- **Segurança e consistência**: PASS — autorização, validação antes da
  referência, imutabilidade e limpeza estão refletidas no design.
- **Sem clarificações pendentes**: PASS — a pesquisa resolveu os desconhecidos
  do contexto técnico sem inventar regras funcionais.

## Validation and implementation sequence

1. Disponibilizar FFmpeg/FFprobe na imagem Docker do Projects Service e validar
   a versão no arranque/teste.
2. Aplicar autorização e limite de corpo antes de aceitar o corpo completo;
   usar ficheiro temporário em disco, nunca o vídeo completo em memória.
3. Implementar análise de conteúdo e metadados no Projects Service.
4. Persistir objeto e referência apenas após validação; apagar temporários em
   rejeição, cancelamento e falha.
5. Expor o contrato através do API Gateway e criar a interação frontend.
6. Implementar resultados independentes por vídeo em lotes e manter/cancelar
   para duplicados; não implementar substituição no MVP.
7. Adicionar testes focados dos requisitos e executar regressão das imagens.
8. Validar os cenários do quickstart com perfis e ficheiros preparados.

## Complexity Tracking

Não há violações da constituição que exijam justificação.
