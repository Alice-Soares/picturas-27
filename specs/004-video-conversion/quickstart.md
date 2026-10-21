# Quickstart de validação — Conversão de formato e resolução

Este guia valida o `UC-VID-004` depois da implementação. O `UC-VID-001` deve
disponibilizar no projeto um vídeo MP4/H.264 válido.

## Pré-requisitos

- Docker Compose iniciado conforme o [README](../../README.md).
- Utilizador registado autenticado e, para os limites superiores, utilizador
  premium.
- Projeto autorizado contendo um vídeo com metadados legíveis.
- FFmpeg/FFprobe disponíveis no container `video_conversion_tool`.
- Cliente WebSocket ligado ao projeto, quando se validar progresso e eventos.

## Cenários funcionais

1. Abrir a conversão de um vídeo autorizado e confirmar contentor, codecs,
   duração, resolução, FPS e tamanho de origem.
2. Confirmar que o MVP apresenta MP4/H.264 e AAC quando existe áudio, e não
   apresenta combinações fora da matriz aprovada.
3. Selecionar uma resolução dentro de `1920x1080` como utilizador registado e
   dentro de `3840x2160` como premium; confirmar que a configuração é aceite.
4. Tentar uma dimensão acima do limite de cada perfil; confirmar rejeição antes
   da criação da operação.
5. Tentar uma combinação de contentor/codec não suportada; confirmar erro
   `VIDEO_CONVERSION_INVALID_OPTIONS` sem operação criada.
6. Confirmar uma conversão válida; observar `queued`, `processing`, progresso
   variável derivado do FFmpeg e `completed`; conferir os metadados do resultado.
7. Confirmar que o resultado aparece como novo vídeo e que o original mantém
   referência, metadados e conteúdo.
8. Cancelar uma operação em fila e outra em processamento; confirmar
   `cancelled`, pedido RabbitMQ à fila `video_conversion_cancel_queue`, ausência
   de resultado parcial, limpeza e devolução de quota.
9. Provocar uma falha de transcodificação ou armazenamento; confirmar
   `failed`, erro seguro, limpeza e preservação do original.
10. Tentar consultar opções, criar, consultar ou cancelar uma operação de outro
    projeto; confirmar rejeição sem exposição de metadados.
11. Verificar que eventos `project-op` de outro projeto não chegam ao cliente.
12. Repetir testes focados de submissão, recorte e ferramentas de imagem para
    confirmar ausência de regressão.

## Validação automatizada esperada

- Testes de contrato para opções, criação, consulta, cancelamento e eventos.
- Testes do contrato RabbitMQ entre o dispatcher do Projects Service e a Tool,
  incluindo correlação, progresso, erro e ausência de `imageURI` em respostas
  de vídeo.
- Testes unitários da matriz de contentores/codecs, limites e estimativa
  nullable.
- Testes de integração com autorização, quota, fila, FFmpeg, armazenamento e
  persistência do resultado.
- Testes de limpeza e concorrência entre cancelamento e conclusão.
- Regressão dos testes existentes em `projects/test`.
- `git diff --check` e `docker compose config`.
- `docker compose exec video_conversion_tool ffmpeg -version`.
- `docker compose exec video_conversion_tool ffprobe -version`.

## Critérios de aceitação

| Requisito | Evidência esperada |
|---|---|
| `REQ-VID-CONV-001` a `004` | Opções e UI apresentam origem, matriz e resolução |
| `REQ-VID-CONV-005` a `007` | Testes rejeitam combinações e limites inválidos |
| `REQ-VID-CONV-008` | Estimativa correta quando disponível e estado indisponível sem bloqueio |
| `REQ-VID-CONV-009` e `011` | Operação assíncrona, estados e progresso observáveis |
| `REQ-VID-CONV-010` | Novo conteúdo com original imutável |
| Requisitos transversais | Autorização, quota, limpeza, erros e isolamento de eventos |

Registar cada cenário como `pass`/`fail`, incluindo perfil, projeto,
`operationId`, configuração, estado final e resultado observado.

## Resultados desta revisão

Os resultados abaixo ainda não foram repetidos após as correções desta
revisão. O estado de aceitação permanece pendente até executar os comandos e
cenários acima na stack Docker atual.
- Os comandos `docker compose exec ... ffmpeg/ffprobe -version` não foram
  executados porque os serviços não foram iniciados nesta validação.

Atualização de 2026-10-21: `docker compose config -q`, o build do serviço de
conversão, o build do frontend e a suíte Projects (36 testes) passaram. Os
testes cobrem validação e contrato da mensagem RabbitMQ, mas não executam a
transcodificação end-to-end no worker; os cenários funcionais deste quickstart
continuam pendentes.

## Documentação obrigatória

Como a conversão é uma Tool nova em `Tools/`, atualizar o catálogo de
ferramentas, o serviço no `docker-compose.yaml`, a fila e a toolbar conforme o
procedimento [Adding a new tool](../../README.md#adding-a-new-tool). Registar
também a fronteira: o Projects Service orquestra e persiste; a Tool
transcodifica.
