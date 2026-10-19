# Contrato: submissão de vídeo

Este contrato define a fronteira funcional. A rota concreta deve seguir o
padrão do API Gateway existente, sem alterar o contrato de upload de imagens.

## Submissão

**Método**: `POST`  
**Conteúdo**: `multipart/form-data` com o campo `video`  
**Autorização**: sessão válida de utilizador registado ou premium  
**Contexto**: projeto autorizado e versão do projeto quando aplicável

Cada requisição transporta um vídeo. Um upload em lote é composto por várias
requisições independentes; cada vídeo é validado e associado separadamente.
Quando a interface agrupa os resultados, deve devolver um resultado por vídeo
com estado `concluída`, `rejeitada`, `cancelada` ou `falhada`.

### Sucesso

```json
{
  "id": "video-reference-id",
  "projectId": "project-id",
  "metadata": {
    "container": "mp4",
    "videoCodec": "h264",
    "audioCodec": "aac",
    "size": 0,
    "duration": 0,
    "width": 0,
    "height": 0,
    "fps": 0
  }
}
```

Os números são apenas exemplo do formato.

O objeto original persistido usa o estágio `video-src`. A largura ou a altura
acima do máximo do perfil rejeita o vídeo. Os limites de tamanho usam unidades
decimais: `1 MB = 1 000 000` bytes e `1 GB = 1 000 000 000` bytes.

### Rejeição

```json
{
  "error": {
    "code": "VIDEO_VALIDATION_FAILED",
    "message": "O vídeo não cumpre os requisitos de formato ou do perfil."
  }
}
```

O erro deve identificar a condição funcional rejeitada sem expor caminhos,
comandos, credenciais ou detalhes internos.

## Cancelamento e segurança

Cancelar durante a transferência remove o temporário e não cria referência.
Projetos, referências e objetos de outros utilizadores não podem ser lidos ou
transferidos. A submissão não reduz a quota diária de operações avançadas.
Para nomes duplicados, o MVP permite manter ambos ou cancelar; não substitui o
objeto original.
