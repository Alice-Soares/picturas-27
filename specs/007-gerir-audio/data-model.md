# Data Model: Gestão de Áudio de Vídeo

## Project

Agregado autorizado que contém vídeos e resultados de áudio do utilizador.

| Field | Type/meaning | Rules |
|---|---|---|
| `videos` | Existing video references | Source videos remain immutable; result videos are appended. |
| `audios` | Audio references | New MVP collection/list for extracted M4A/AAC results. |
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

## Audio result

Novo conteúdo produzido por `extract`, com `sourceVideoId`, `stage: audio-src`,
`object_key` interno, nome de biblioteca, tamanho, duração, `container: m4a`,
`audioCodec: aac`, sample rate e canais. O objeto só é apresentado depois do
append versionado ter concluído.

## Audio operation

Operação assíncrona com `type: audio` e `audio_action: remove | replace |
extract`. Inclui utilizador, projeto, vídeo de origem, estado, progresso,
timestamps, quota e erro público; `result_video_id` é usado por remove/replace
e `result_audio_id` por extract.

### State transitions

```text
queued -> processing -> completed
queued -> cancelled
processing -> cancelled
queued -> failed
processing -> failed
```

`completed`, `failed` e `cancelled` são terminais. Só uma operação concluída
acrescenta conteúdo; o vídeo original nunca é alterado.
