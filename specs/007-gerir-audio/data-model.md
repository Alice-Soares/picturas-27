# Data Model: Gestão de Áudio de Vídeo

## Project

Agregado autorizado que contém os vídeos do utilizador. O áudio extraído é um
resultado temporário da operação e não é acrescentado ao projeto.

| Field | Type/meaning | Rules |
|---|---|---|
| `videos` | Existing video references | Source videos remain immutable; result videos are appended. |
| `version` | Existing optimistic version | Result append uses the current version and fails safely on conflict. |

## Video

Conteúdo audiovisual existente usado como origem. O `id` deve pertencer ao
projeto autorizado antes de qualquer leitura; `duration` limita intervalos e
`audioCodec: null` representa a ausência de faixa sonora aplicável.

## Replacement audio

Input temporário do utilizador para `replace`. Só aceita MP3 ou M4A/AAC,
requer validação de extensão/MIME e conteúdo, e deve ser limpo após sucesso,
falha ou cancelamento. `audio_start_seconds`/`audio_end_seconds` são opcionais
e devem estar dentro da duração detetada.

## Extracted audio download

Ficheiro temporário produzido por `extract` em M4A/AAC. A operação mantém um
caminho interno não selecionado por omissão; um endpoint autenticado transmite
o ficheiro ao cliente e elimina o temporário após a transferência ou expiração.
O caminho não é exposto em REST ou WebSocket.

## Audio operation

Operação assíncrona com `type: audio` e `audio_action: remove | replace |
extract`. Inclui utilizador, projeto, vídeo de origem, estado, progresso,
timestamps, quota e erro público; `result_video_id` é usado por remove/replace
e metadados de áudio por extract. O resultado de extração é transferido ao
dispositivo e não recebe `result_audio_id` nem referência na biblioteca.

### State transitions

```text
queued -> processing -> completed
queued -> cancelled
processing -> cancelled
queued -> failed
processing -> failed
```

`completed`, `failed` e `cancelled` são terminais. Só uma operação concluída
acrescenta um vídeo resultante à biblioteca ou disponibiliza um download de
áudio temporário; o vídeo original nunca é alterado.
