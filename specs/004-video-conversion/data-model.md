# Modelo de dados: Conversão de formato e resolução de vídeo

## Vídeo de origem

Conteúdo persistente já associado a um projeto.

| Campo | Regra |
|---|---|
| `id` | Identificador único da referência |
| `userId` | Utilizador proprietário/autorizado |
| `projectId` | Projeto que contém o vídeo |
| `stage` | `video-src` no MVP |
| `objectKey` | Objeto persistente no armazenamento |
| `name` | Nome apresentado na biblioteca |
| `container` | Contentor de origem conhecido |
| `videoCodec`, `audioCodec` | Codecs de origem; áudio pode ser nulo |
| `duration` | Duração positiva em segundos |
| `width`, `height` | Resolução positiva |
| `fps`, `size`, `sha256` | Metadados de validação e integridade |
| `sourceVideoId` | Nulo para origem; referência ao original para derivados |

O vídeo de origem e os seus metadados são imutáveis durante a conversão.

## Configuração de conversão

Valor validado associado a uma operação.

| Campo | Regra |
|---|---|
| `outputContainer` | Deve pertencer à matriz suportada; MVP: `mp4` |
| `outputVideoCodec` | Deve ser compatível com o contentor; MVP: `h264` |
| `outputAudioCodec` | `aac` quando a saída tiver áudio; nulo se o contrato permitir vídeo sem áudio |
| `outputWidth`, `outputHeight` | Positivos e dentro do limite do perfil |
| `estimatedSize` | Nullable; informativo, nunca substitui a validação do resultado |

## Operação de conversão

Trabalho assíncrono persistido.

| Campo | Regra |
|---|---|
| `id` | Identificador usado pelos endpoints e mensagens |
| `type` | `conversion` |
| `userId`, `projectId` | Contexto de autorização |
| `sourceVideoId` | Vídeo de entrada imutável |
| `output` | Configuração de conversão validada |
| `status` | `queued`, `processing`, `completed`, `failed`, `cancelled` |
| `progress` | Número entre 0 e 100 que não regride |
| `resultVideoId` | Nulo até `completed` |
| `errorCode`, `errorMessage` | Apenas em falha; mensagem sem detalhes internos |
| `quotaReserved`, `quotaRefunded` | Reserva e devolução idempotentes |
| `createdAt`, `startedAt`, `finishedAt`, `cancelledAt` | Timestamps coerentes |

### Transições permitidas

```text
queued -> processing -> completed
queued -> cancelled
queued -> failed
processing -> completed
processing -> cancelled
processing -> failed
```

Estados terminais não transitam novamente. Se cancelamento e conclusão
concorrem, o primeiro estado terminal persistido vence e o caminho perdedor
limpa apenas recursos que lhe pertençam.

## Vídeo convertido

Novo conteúdo derivado no mesmo projeto.

- Tem `sourceVideoId` igual ao vídeo de origem.
- Tem os metadados efetivamente produzidos, que devem corresponder à
  configuração confirmada.
- Só é associado ao projeto depois de o processamento e a persistência
  terminarem com sucesso.
- Nunca substitui nem elimina o vídeo de origem.

## Relações

- Um projeto contém zero ou mais vídeos e operações.
- Uma operação referencia exatamente um vídeo de origem.
- Uma operação concluída cria no máximo um vídeo convertido.
- Eventos e operações são acessíveis apenas no contexto autorizado do projeto.
