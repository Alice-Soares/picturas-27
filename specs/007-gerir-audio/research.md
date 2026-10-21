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

## Decision 3: Transferir o áudio extraído sem persistir na biblioteca

- **Decision**: Extrair para M4A/AAC temporário, transmitir pelo endpoint autenticado ao dispositivo do utilizador e não criar referência de áudio no projeto.
- **Rationale**: A decisão explícita do utilizador define o dispositivo como destino do áudio extraído; remoção/substituição continuam a produzir novos vídeos na biblioteca.
- **Alternatives considered**: Persistir o áudio na biblioteca contradiz o destino solicitado; manter o temporário fora da biblioteca permite o download sem alterar o projeto.
- **Requirements**: `REQ-VID-AUD-011`, `REQ-VID-AUD-012`, `REQ-VID-AUD-015`, `REQ-VID-AUD-016`, `REQ-VID-COM-018`.

## Decision 4: Usar o volume partilhado para download temporário

- **Decision**: Transmitir o resultado temporário pelo API Gateway/Projects Service autenticados; manter a fachada de armazenamento para novos vídeos.
- **Rationale**: Preserva autorização, remove o M4A após transferência e evita persistir um item de biblioteca não solicitado.
- **Alternatives considered**: Generalizar vídeo para `media` alteraria uma API existente e aumentaria o risco de regressão.
- **Requirements**: `REQ-VID-AUD-012`, `REQ-VID-AUD-015`, `REQ-VID-AUD-016`, `REQ-VID-COM-014`..`017`.

## Decision 5: Contratos de FFmpeg para duração diferente

- **Decision**: Para substituição, mapear explicitamente o vídeo e o áudio fornecido, limitar o áudio à duração do vídeo e manter a duração do vídeo quando o áudio for mais curto; para extração, produzir M4A/AAC; para remoção, excluir a faixa de áudio.
- **Rationale**: Corresponde a `FA2`, `RN5` e `AUD-008`/`AUD-009`. `-shortest` poderia encurtar o vídeo quando o áudio é menor.
- **Alternatives considered**: `-shortest` é mais simples, mas viola o comportamento especificado.
- **Requirements**: `REQ-VID-AUD-002`, `REQ-VID-AUD-008`..`011`.

## Decision 6: Limites e segurança

- **Decision**: Aceitar MP3, M4A/AAC e vídeos que contenham pelo menos uma faixa sonora descodificável. FFprobe deteta os streams do vídeo sem confiar na extensão/MIME; de uma entrada de vídeo usa-se apenas a primeira faixa sonora e ignora-se a imagem. Entradas apenas de áudio mantêm os formatos MP3 e M4A/AAC. Validar antes de reservar quota, verificar projeto/vídeo antes de ler conteúdo e nunca expor caminhos temporários ou stderr.
- **Rationale**: A substituição é definida pela faixa sonora, não pelo contentor do vídeo. MIME/extensão não provam o conteúdo; a autorização deve ocorrer antes da leitura. Mensagens públicas devem seguir `REQ-VID-Q-008`.
- **Alternatives considered**: Confiar apenas no MIME seria vulnerável a ficheiros malformados.
- **Requirements**: `REQ-VID-AUD-003`..`006`, `REQ-VID-AUD-010`, `REQ-VID-COM-001`..`008`, `REQ-VID-Q-005`, `REQ-VID-Q-008`.

## Resolved unknowns

Não permanecem decisões técnicas sem fonte suficiente. Múltiplas faixas,
retoma, substituição/versionamento do original e preview avançado permanecem
fora do MVP conforme o catálogo de requisitos.
