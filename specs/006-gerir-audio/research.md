# Research: Gestão de Áudio de Vídeo

**Feature**: [spec.md](./spec.md)  
**Baseline**: UC-VID-007 v1.0; catálogo de requisitos de vídeo v1.1 (2026-10-17)

## Decision 1: Reutilizar o ciclo de vida de operações de vídeo

- **Decision**: Adicionar uma operação `audio` ao modelo partilhado, com uma ação explícita `remove`, `replace` ou `extract`.
- **Rationale**: O Projects Service já centraliza autorização, quota, estados `queued`/`processing`/`completed`/`failed`/`cancelled`, polling, cancelamento e eventos. Uma ação separada evita sobrecarregar `start_seconds`/`end_seconds`, que representam intervalos do vídeo de origem.
- **Alternatives considered**: Criar três tipos (`audio_remove`, `audio_replace`, `audio_extract`) duplicaria ramificações sem valor funcional no MVP.
- **Requirements**: `REQ-VID-AUD-001`..`016`, `REQ-VID-COM-004`..`012`.

## Decision 2: Isolar o processamento num worker `video_audio`

- **Decision**: Criar uma ferramenta stateless `Tools/video_audio` com FFmpeg/FFprobe, comunicando por RabbitMQ através de mensagens correlacionadas.
- **Rationale**: A conversão de vídeo já usa esta fronteira: o Projects Service mantém autorização, quota, persistência e eventos. A ferramenta existente de conversão não aceita uma fonte de áudio externa nem gera um resultado de áudio independente.
- **Alternatives considered**: Um worker Node.js no Projects Service reduziria ficheiros novos, mas misturaria processamento pesado com autorização e contrariaria o isolamento decidido em `DQ-002`.
- **Requirements**: `REQ-VID-AUD-001`..`011`, `REQ-VID-COM-011`..`017`, `REQ-VID-Q-006`.

## Decision 3: Modelar áudio como conteúdo de projeto próprio

- **Decision**: Adicionar `audios` ao projeto, com metadados de resultados M4A/AAC e referência ao vídeo de origem.
- **Rationale**: O esquema de vídeo exige largura, altura, FPS e codec de vídeo. Um M4A extraído não deve ser representado como vídeo inválido; remove/substitui continuam a produzir novos vídeos.
- **Alternatives considered**: Um modelo genérico de assets seria mais extensível, mas seria uma alteração transversal maior; `audios` é a extensão de menor risco para o MVP.
- **Requirements**: `REQ-VID-AUD-011`, `REQ-VID-AUD-012`, `REQ-VID-AUD-015`, `REQ-VID-AUD-016`, `REQ-VID-COM-018`.

## Decision 4: Manter a fachada de armazenamento

- **Decision**: Acrescentar upload/download/remoção de áudio à Image Storage Service, sem acesso direto do Projects Service ou worker ao SeaweedFS.
- **Rationale**: Preserva autorização e convenções existentes, permite limpar temporários/resultados parciais e evita alterar o contrato de vídeo existente.
- **Alternatives considered**: Generalizar vídeo para `media` alteraria uma API existente e aumentaria o risco de regressão.
- **Requirements**: `REQ-VID-AUD-012`, `REQ-VID-AUD-015`, `REQ-VID-AUD-016`, `REQ-VID-COM-014`..`017`.

## Decision 5: Contratos de FFmpeg para duração diferente

- **Decision**: Para substituição, mapear explicitamente o vídeo e o áudio fornecido, limitar o áudio à duração do vídeo e manter a duração do vídeo quando o áudio for mais curto; para extração, produzir M4A/AAC; para remoção, excluir a faixa de áudio.
- **Rationale**: Corresponde a `FA2`, `RN5` e `AUD-008`/`AUD-009`. `-shortest` poderia encurtar o vídeo quando o áudio é menor.
- **Alternatives considered**: `-shortest` é mais simples, mas viola o comportamento especificado.
- **Requirements**: `REQ-VID-AUD-002`, `REQ-VID-AUD-008`..`011`.

## Decision 6: Limites e segurança

- **Decision**: Aceitar apenas MP3 e M4A/AAC, validar extensão/MIME e conteúdo antes de reservar quota, verificar projeto/vídeo antes de ler conteúdo e nunca expor caminhos temporários ou stderr.
- **Rationale**: MIME sozinho não valida o conteúdo; a autorização deve ocorrer antes da leitura. Mensagens públicas devem seguir `REQ-VID-Q-008`.
- **Alternatives considered**: Confiar apenas no MIME seria vulnerável a ficheiros malformados.
- **Requirements**: `REQ-VID-AUD-003`..`006`, `REQ-VID-AUD-010`, `REQ-VID-COM-001`..`008`, `REQ-VID-Q-005`, `REQ-VID-Q-008`.

## Resolved unknowns

Não permanecem decisões técnicas sem fonte suficiente. Múltiplas faixas,
retoma, substituição/versionamento do original e preview avançado permanecem
fora do MVP conforme o catálogo de requisitos.
