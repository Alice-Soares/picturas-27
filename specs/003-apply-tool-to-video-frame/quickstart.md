# Quickstart de validação — Aplicar ferramenta a fotogramas

## Pré-requisitos

- Docker Compose iniciado conforme o [README](../../README.md).
- Utilizador registado e premium disponível para testar ambos os perfis.
- Projeto autorizado com vídeo válido, com e sem áudio quando possível.
- FFmpeg/FFprobe no container Projects, RabbitMQ ativo e workers de imagem ativos.

## Cenários

1. Abrir um projeto com vídeo e confirmar que apenas utilizadores autenticados
   veem a ação de aplicar ferramenta.
2. Selecionar uma ferramenta de imagem, parâmetros válidos, intervalo parcial e
   taxa válida; confirmar operação `queued`, depois `processing` e progresso.
3. Confirmar que o resultado é um novo vídeo, o original permanece inalterado,
   a resolução é preservada e o áudio continua presente quando aplicável.
4. Selecionar duas ferramentas e confirmar que cada frame passa por elas na
   ordem indicada.
5. Tentar ferramenta inexistente, parâmetros inválidos, intervalo inválido,
   taxa inválida, vídeo de outro projeto e quota esgotada; confirmar rejeição
   segura sem operação parcial.
6. Usar ferramenta de deteção/metadados; confirmar bloqueio para recomposição ou
   confirmação explícita conforme a regra aprovada, sem gerar vídeo inválido.
7. Injetar uma falha num frame e confirmar uma repetição; repetir a falha e
   confirmar `failed`, limpeza e devolução da quota.
8. Cancelar em `queued` e `processing`; confirmar `cancelled`, limpeza e
   ausência de resultado parcial.
9. Confirmar que eventos `project-op` só chegam à sala do projeto autorizado.
10. Repetir os testes focados de imagens e confirmar ausência de regressão.

## Validação automatizada esperada

- Testes unitários da validação de ferramentas, parâmetros, intervalo, taxa,
  tentativas e transições de estado.
- Testes de contrato para criação, consulta, cancelamento e eventos.
- Testes de integração com autorização, quota, RabbitMQ, workers, FFmpeg,
  armazenamento e limpeza.
- Regressão do fluxo de imagens.
- `git diff --check` e `docker compose config`.

## Evidência executada

- Em 2026-10-21, `docker compose run --rm --no-deps projects node
  test/run-tests.js` passou com 36 testes, incluindo validação de frame-tool,
  retry, recomposição, validação de extração e contratos de conversão.
- `npx tsc --noEmit` e o build Docker do frontend passaram; o build reportou
  avisos existentes de dependências de `useEffect` e uso de `<img>`.
- Um cenário Docker da baseline de imagem adicionou e removeu uma ferramenta e
  confirmou a persistência da remoção após nova leitura. Não valida o
  processamento de vídeo.
- Os cenários end-to-end específicos de `UC-VID-003` com vídeo, RabbitMQ,
  workers, quota, cancelamento e armazenamento permanecem pendentes.

## Rastreabilidade

| Requisito         | Evidência                                                |
| ----------------- | -------------------------------------------------------- |
| `REQ-VID-FRM-001` | Seleção/validação de ferramenta e parâmetros             |
| `REQ-VID-FRM-002` | Extração, intervalo, taxa, processamento e recomposição  |
| `REQ-VID-FRM-003` | Metadados do vídeo original e resultado, incluindo áudio |
| `REQ-VID-FRM-004` | Teste de cadeia ordenada de ferramentas                  |
| `REQ-VID-FRM-005` | Teste de retry, falha persistente e limpeza              |
| UC-VID-003/FA3    | Teste de cancelamento e remoção de temporários           |
| `REQ-VID-FRM-006` | Endpoint e worker de cancelamento cooperativo            |
| `REQ-VID-FRM-007` | Eventos `project-op` e consulta de operação              |
| `REQ-VID-FRM-008` | Autorização e reserva/devolução de quota                  |
| `REQ-VID-FRM-009` | Validação dos limites gerais do vídeo                     |
| `REQ-VID-FRM-010` | Referência nova com `sourceVideoId`, original preservado |

Cada execução deve registar perfil, projeto, `operationId`, intervalo, estado
final, resultado observado e `pass`/`fail`.
