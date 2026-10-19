# Contrato: Recorte temporal de vídeo

Este contrato descreve o comportamento externo mínimo. Os nomes dos caminhos
seguem o padrão de recursos do Projects Service/Gateway; a implementação deve
preservar autenticação, `X-Caller-Id` e `X-Project-Version`.

## Criar operação

`POST /projects/:user/:project/video/:videoId/trim`

Pedido JSON:

```json
{
  "startSeconds": 1.5,
  "endSeconds": 12.5
}
```

Respostas:

- `202`: `{ "operationId": "...", "status": "queued" }`
- `400`: intervalo inválido ou vídeo incompatível
- `401`: sessão ausente/inválida
- `403`: projeto ou vídeo não autorizado
- `404`: vídeo inexistente no projeto
- `409`: versão do projeto ou estado do vídeo incompatível
- `429`: quota registada esgotada

O endpoint não devolve o ficheiro resultante no pedido inicial.

## Consultar operação

`GET /projects/:user/:project/video-operations/:operationId`

Resposta `200`:

```json
{
  "id": "...",
  "type": "trim",
  "status": "queued",
  "progress": 0,
  "sourceVideoId": "...",
  "startSeconds": 1.5,
  "endSeconds": 12.5,
  "resultVideoId": null,
  "errorCode": null
}
```

O acesso exige autorização para o projeto. Mensagens de erro não incluem
paths internos, credenciais ou comandos.

## Cancelar operação

`POST /projects/:user/:project/video-operations/:operationId/cancel`

Resposta `202`:

```json
{ "operationId": "...", "status": "cancelled" }
```

Se a operação já estiver num estado terminal, o serviço devolve o estado atual
sem eliminar um resultado concluído. O cancelamento deve ser idempotente.

## Eventos WebSocket

Evento: `project-op`

```json
{
  "projectId": "...",
  "op": {
    "operationId": "...",
    "type": "trim",
    "status": "processing",
    "progress": 42,
    "resultVideoId": null,
    "errorCode": null
  }
}
```

Os eventos são publicados apenas para a sala do projeto autorizado. Estados
terminais incluem `completed`, `failed` ou `cancelled`.

## Erros funcionais mínimos

`VIDEO_TRIM_INVALID_INTERVAL`, `VIDEO_TRIM_NOT_FOUND`,
`VIDEO_TRIM_UNAUTHORIZED`, `VIDEO_TRIM_QUOTA_EXCEEDED`,
`VIDEO_TRIM_CANCELLED`, `VIDEO_TRIM_FAILED`.
