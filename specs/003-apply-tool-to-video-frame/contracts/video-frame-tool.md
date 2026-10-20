# Contrato: Aplicar ferramenta a fotogramas de vídeo

Os caminhos seguem o Projects Service e preservam autenticação, autorização do
projeto, `X-Caller-Id` e `X-Project-Version`.

## Criar operação

`POST /projects/:user/:project/video/:videoId/frame-tool`

Pedido JSON:

```json
{
  "tools": [
    { "procedure": "brightness", "position": 0, "params": { "value": 10 } }
  ],
  "startSeconds": 0,
  "endSeconds": 12,
  "outputFps": 25
}
```

Respostas: `202` com `{ "operationId": "...", "status": "queued" }`; `400`
para ferramenta, parâmetros, intervalo, taxa ou tipo de saída incompatíveis;
`401` para sessão inválida; `403` para projeto/vídeo não autorizado; `404` para
vídeo inexistente; `429` para quota registada esgotada.

## Consultar operação

`GET /projects/:user/:project/video-operations/:operationId`

A resposta mantém o contrato existente e inclui `type`, `status`, `progress`,
`sourceVideoId`, configuração do intervalo, ferramentas selecionadas,
`resultVideoId` e `errorCode`. Nunca inclui paths internos nem credenciais.

## Cancelar operação

`POST /projects/:user/:project/video-operations/:operationId/cancel`

Resposta `202` com o estado atual. O cancelamento é idempotente, interrompe
frames pendentes, limpa temporários e devolve a quota quando aplicável.

## Eventos WebSocket

Evento `project-op`, na sala autorizada do projeto:

```json
{
  "projectId": "...",
  "op": {
    "operationId": "...",
    "type": "frame_tool",
    "status": "processing",
    "progress": 42,
    "resultVideoId": null,
    "errorCode": null
  }
}
```

## Mensagens internas

A fila dedicada recebe `operationId`, `projectId`, `sourceVideoId` e a cadeia de
ferramentas. O adaptador publica cada frame no contrato da ferramenta escolhida
e exige uma resposta de imagem antes de seguir para a ferramenta seguinte.
