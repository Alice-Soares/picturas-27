# Quickstart de validação — Submissão de vídeo

Este guia valida o `UC-VID-001` depois da implementação. O arranque segue o
[README da aplicação](../../README.md).

## Pré-requisitos

- Docker Compose disponível.
- Serviços de autenticação, projetos, API Gateway e SeaweedFS iniciados.
- Contas registada e premium, projeto autorizado e ficheiros de teste MP4/H.264.
- Ficheiros com áudio AAC, sem áudio, codec/contentor inválido e limites
  excedidos.
- Para confirmar a ferramenta no container: `docker compose exec projects ffprobe -version`.

## Arranque

```bash
docker compose up --build
```

Abrir `https://localhost:8080` e autenticar.

## Cenários

### Amostras mínimas

| Amostra | Resultado esperado |
|---|---|
| MP4/H.264 sem áudio | aceite dentro dos limites |
| MP4/H.264/AAC | aceite dentro dos limites |
| contentor diferente de MP4 | rejeitada |
| codec de vídeo diferente de H.264 | rejeitada |
| ficheiro sem stream de vídeo ou corrompido | rejeitada |
| cada limite excedido isoladamente | rejeitada |

1. Submeter MP4/H.264 dentro dos limites; confirmar referência, projeto,
   utilizador e tamanho, duração, resolução, fps e codecs.
2. Repetir com áudio AAC; confirmar os metadados da faixa sonora.
3. Tentar perfil anónimo, sessão inválida e projeto não autorizado; confirmar
   rejeição sem referência.
4. Testar contentor, codec, stream e cada limite inválido; confirmar erro
   seguro e ausência de objeto parcial.
5. Cancelar uma transferência; confirmar remoção do temporário.
6. Simular falha de rede, validação e armazenamento; confirmar limpeza.
7. Comparar a quota antes/depois; confirmar que a submissão não a reduz.
8. Tentar consultar o vídeo com outro utilizador; confirmar bloqueio.
9. Submeter um lote com um vídeo válido e um inválido; confirmar um resultado
   independente por vídeo.
10. Submeter um nome duplicado; confirmar que manter ambos cria uma nova
    referência e cancelar não altera a referência original.
11. Confirmar que a imagem do Projects Service contém FFmpeg/FFprobe e que a
    versão usada é a documentada no resultado de validação.
12. Executar os testes existentes de imagens; confirmar ausência de regressão.

## Evidência

Registar cada cenário como `pass`/`fail`, com perfil, ficheiro e motivo da
rejeição. Comparar o resultado com o [contrato](contracts/video-submission.md)
e o [modelo](data-model.md).

## Validação automatizada realizada

- Testes focados de limites, codecs, autorização, limpeza, contrato e falhas:
  `pass`.
- Type-check do frontend (`cd frontend && npx tsc --noEmit`): `pass`.
- Sintaxe dos serviços JavaScript e `git diff --check`: `pass`.
- `docker compose config`: `pass`.
- Build Next.js: pendente no host local porque o Node disponível é 16.14.0 e
  o Next.js da baseline exige Node.js 18.18 ou superior; deve ser executado no
  ambiente Docker ou num host com a versão suportada.

### Matriz de aceitação focada

| Requisitos | Evidência | Resultado |
|---|---|---|
| `REQ-VID-SUB-001` a `REQ-VID-SUB-004` | `videoAuthorization.integration.test.js` | pass |
| `REQ-VID-SUB-005` a `REQ-VID-SUB-015` | `videoValidation.integration.test.js`, `videoMetadata.test.js` | pass |
| `REQ-VID-SUB-016` a `REQ-VID-SUB-023` | `videoLimits.test.js`, `videoValidation.integration.test.js` | pass |
| `REQ-VID-SUB-024` a `REQ-VID-SUB-029` | `videoCleanup.test.js`, `videoSubmission.contract.test.js` | pass |
| `REQ-VID-SUB-030` e `REQ-VID-SUB-031` | `videoFailure.integration.test.js` e fluxo de duplicados do cliente | pass |
| `REQ-VID-SUB-032` e `REQ-VID-SUB-033` | `videoLimits.test.js` e inspeção do parsing em disco | pass |
| Validação end-to-end com Docker | Upload válido HTTP 201; ficheiro inválido HTTP 400; duplicado HTTP 409; upload de imagem concluído; cancelamento do browser abortado, mas a submissão grande terminou HTTP 201 no backend | pendente — resolver a corrida do cancelamento servidor |
