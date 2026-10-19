# Modelo de dados: Recorte temporal de vídeo

## Vídeo

Conteúdo persistente associado a um projeto.

| Campo | Regra |
|---|---|
| `id` | Identificador único da referência |
| `userId` | Proprietário/autorizado |
| `projectId` | Projeto que contém a referência |
| `stage` | `video-src` para original; estágio de resultado definido pelo contrato de armazenamento |
| `objectKey` | Chave do objeto persistente |
| `name` | Nome apresentado na biblioteca |
| `duration` | Duração em segundos, positiva |
| `width`, `height` | Resolução positiva |
| `fps` | Taxa de fotogramas positiva |
| `container`, `videoCodec`, `audioCodec` | Metadados; áudio pode ser nulo |
| `sha256` | Integridade do conteúdo |
| `sourceVideoId` | Referência opcional ao vídeo original quando é derivado |

O vídeo original nunca é alterado ou eliminado pelo recorte. Um vídeo sem áudio
continua sem áudio no resultado.

## Intervalo de recorte

Valor da operação, não conteúdo persistente.

| Campo | Regra |
|---|---|
| `startSeconds` | `>= 0` e inferior à duração |
| `endSeconds` | Superior a `startSeconds` e `<= duration` |
| `durationSeconds` | `endSeconds - startSeconds >= 1` |

## Operação de vídeo

Trabalho assíncrono e ciclo de vida.

| Campo | Regra |
|---|---|
| `id` | Identificador usado nas mensagens |
| `type` | `trim` |
| `userId`, `projectId` | Contexto autorizado |
| `sourceVideoId` | Vídeo de entrada imutável |
| `interval` | Instantes inicial/final em segundos |
| `status` | `queued`, `processing`, `completed`, `failed`, `cancelled` |
| `progress` | Valor normalizado que não regride |
| `errorCode`, `errorMessage` | Apenas para falhas, sem detalhes internos |
| `resultVideoId` | Apenas quando concluída |
| `createdAt`, `startedAt`, `finishedAt`, `cancelledAt` | Timestamps coerentes |
| `quotaReservation` | Reserva identificável para commit/refund |

### Transições permitidas

```text
queued -> processing -> completed
queued -> cancelled
queued -> failed
processing -> completed
processing -> cancelled
processing -> failed
```

Estados terminais não transitam novamente. Um cancelamento concorrente com
conclusão deve ser resolvido atomicamente: o primeiro estado terminal aceite
vence e o outro caminho limpa apenas recursos que lhe pertençam.

## Relações

- Um projeto contém zero ou mais vídeos e zero ou mais operações.
- Uma operação referencia exatamente um vídeo de entrada.
- Uma operação concluída pode criar no máximo um vídeo resultante.
- Um vídeo resultante referencia o original através de `sourceVideoId`.
- Eventos de operação são visíveis apenas no projeto autorizado.
