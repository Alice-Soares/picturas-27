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

## Validação automatizada

Os resultados só devem ser preenchidos depois de executar cada comando neste
estado do código. Alguns testes anteriores eram helpers isolados ou dados
literais e não demonstravam os fluxos de integração descritos.

```bash
docker compose run --rm projects node test/run-tests.js
docker compose up -d --build projects users api_gateway ws_gateway frontend
```

Estado desta revisão (2026-10-21): `docker compose config -q` passou, a suíte
`docker compose run --rm --no-deps projects node test/run-tests.js` passou com
36 testes e o build do frontend terminou. Foi também executado um cenário
isolado de regressão do fluxo de imagem (criar conta/projeto temporários,
adicionar uma ferramenta, removê-la e confirmar a ausência após nova leitura),
com limpeza dos dados temporários. Estes resultados não validam a submissão de
vídeo; os cenários end-to-end de `UC-VID-001` continuam pendentes.

### Matriz de aceitação focada

| Requisitos | Evidência | Resultado |
|---|---|---|
| `REQ-VID-SUB-001` a `REQ-VID-SUB-004` | Testes de autorização HTTP ponta a ponta | pendente |
| `REQ-VID-SUB-005` a `REQ-VID-SUB-015` | Validação, metadados e fluxo Docker | pendente |
| `REQ-VID-SUB-016` a `REQ-VID-SUB-023` | Limites, validação e fluxo Docker | pendente |
| `REQ-VID-SUB-024` a `REQ-VID-SUB-029` | Limpeza e submissão HTTP com armazenamento | pendente |
| `REQ-VID-SUB-030` e `REQ-VID-SUB-031` | Testes de integração de falhas, duplicados e lotes | pendente |
| `REQ-VID-SUB-032` e `REQ-VID-SUB-033` | Inspeção dos limites de parsing em disco e fluxo Docker | pendente |
| Validação end-to-end com Docker | Cenários de upload, rejeição, duplicados, lote, cancelamento e autorização listados acima | pendente — não executados nesta revisão |
