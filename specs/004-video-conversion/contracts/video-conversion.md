# Contrato: Conversão de formato e resolução de vídeo

Os caminhos seguem o padrão do Projects Service/Gateway. A autenticação,
autorização do projeto, `X-Caller-Id` e `X-Project-Version` existentes devem ser
preservados.

## Contrato interno da Tool

O Projects Service publica pedidos na fila `video_conversion_queue`. A Tool não
recebe pedidos HTTP, não acede à MongoDB ou ao Image Storage Service e não
aplica autorização ou quota.

Pedido:

```json
{
  "messageId": "...",
  "correlationId": "...",
  "procedure": "video_conversion",
  "parameters": {
    "inputVideoURI": "/app/images/.../source.mp4",
    "outputVideoURI": "/app/images/.../result.mp4",
    "outputContainer": "mp4",
    "outputVideoCodec": "h264",
    "outputAudioCodec": "aac",
    "outputWidth": 1280,
    "outputHeight": 720,
    "duration": 12.5
  }
}
```

Resposta de sucesso:

```json
{
  "correlationId": "...",
  "status": "completed",
  "output": {
    "type": "video",
    "videoURI": "/app/images/.../result.mp4",
    "container": "mp4",
    "videoCodec": "h264",
    "audioCodec": "aac",
    "width": 1280,
    "height": 720,
    "duration": 12.5,
    "fps": 30
  }
}
```

A Tool pode publicar mensagens de progresso com o mesmo `correlationId`; a
percentagem deriva do tempo de saída FFmpeg face à duração da origem. O
Projects Service publica cancelamentos em `video_conversion_cancel_queue` e a
Tool termina o processo FFmpeg associado. A Tool pode receber o cancelamento
antes do pedido de conversão e descarta esse pedido quando chegar.
Falhas devem usar um código estável e não incluir comandos, caminhos internos
ou detalhes de sistema desnecessários.

## Consultar origem e opções

`GET /projects/:user/:project/video/:videoId/conversion-options`

Resposta `200`:

```json
{
  "source": {
    "id": "...",
    "name": "video.mp4",
    "container": "mp4",
    "videoCodec": "h264",
    "audioCodec": "aac",
    "duration": 12.5,
    "width": 1280,
    "height": 720,
    "fps": 30,
    "size": 2400000
  },
  "containers": [
    {
      "name": "mp4",
      "videoCodecs": ["h264"],
      "audioCodecs": ["aac"]
    }
  ],
  "resolutionLimits": {
    "width": 1920,
    "height": 1080
  }
}
```

Para um utilizador premium, os limites são `3840x2160`. A resposta deve omitir
metadados quando o projeto ou o vídeo não forem autorizados.

## Criar operação

`POST /projects/:user/:project/video/:videoId/conversion`

Pedido JSON:

```json
{
  "outputContainer": "mp4",
  "outputVideoCodec": "h264",
  "outputAudioCodec": "aac",
  "outputWidth": 1280,
  "outputHeight": 720,
  "projectVersion": 4
}
```

Respostas:

- `202`: `{ "operationId": "...", "status": "queued" }`
- `400`: combinação ou resolução inválida
- `401`: sessão ausente ou inválida
- `403`: projeto ou vídeo não autorizado
- `404`: vídeo inexistente no projeto
- `409`: versão do projeto ou estado do vídeo incompatível
- `429`: quota de utilizador registado esgotada

Uma estimativa nullable pode ser devolvida na resposta ou na consulta da
operação; a criação não deve falhar apenas por não ser possível calculá-la.

## Consultar operação

`GET /projects/:user/:project/video-operations/:operationId`

Resposta `200`:

```json
{
  "id": "...",
  "type": "conversion",
  "status": "processing",
  "progress": 42,
  "sourceVideoId": "...",
  "output": {
    "container": "mp4",
    "videoCodec": "h264",
    "audioCodec": "aac",
    "width": 1280,
    "height": 720
  },
  "estimatedSize": null,
  "resultVideoId": null,
  "errorCode": null
}
```

## Cancelar operação

`POST /projects/:user/:project/video-operations/:operationId/cancel`

Resposta `202`:

```json
{ "operationId": "...", "status": "cancelled" }
```

O cancelamento é idempotente para estados terminais e não elimina um resultado
já concluído.

## Eventos WebSocket

Evento `project-op`:

```json
{
  "projectId": "...",
  "op": {
    "operationId": "...",
    "type": "conversion",
    "status": "processing",
    "progress": 42,
    "resultVideoId": null,
    "errorCode": null
  }
}
```

O evento contém apenas dados operacionais mínimos e deve ser entregue somente a
clientes autorizados no projeto.

## Erros funcionais mínimos

`VIDEO_CONVERSION_INVALID_OPTIONS`,
`VIDEO_CONVERSION_UNAUTHORIZED`,
`VIDEO_CONVERSION_NOT_FOUND`,
`VIDEO_CONVERSION_QUOTA_EXCEEDED`,
`VIDEO_CONVERSION_CANCELLED`, `VIDEO_CONVERSION_FAILED`.
