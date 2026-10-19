# Quickstart de validação — Recorte temporal

Este guia valida o `UC-VID-002` depois da implementação. O `UC-VID-001`
deve disponibilizar pelo menos um MP4 válido no projeto.

## Pré-requisitos

- Docker Compose iniciado conforme o [README](../../README.md).
- Utilizador registado e, quando aplicável, premium autenticado.
- Projeto autorizado com um vídeo MP4/H.264 associado.
- FFmpeg/FFprobe disponíveis no container Projects.
- Cliente WebSocket ligado à sala do projeto.

## Cenários funcionais

1. Abrir o projeto e selecionar um vídeo; confirmar que a duração é mostrada.
2. Definir início `0` e fim igual à duração de um vídeo com pelo menos um
   segundo; confirmar que a operação é criada em `queued`.
3. Observar `processing`, pelo menos um progresso e `completed`; confirmar
   novo vídeo e preservação do original.
4. Repetir com vídeo que tenha áudio AAC; confirmar áudio correspondente.
5. Tentar início/fim negativos, valores além da duração, início igual ou
   posterior ao fim e intervalo inferior a um segundo; confirmar rejeição sem
   operação.
6. Tentar vídeo de outro projeto, sessão inválida e utilizador sem acesso;
   confirmar rejeição sem exposição de metadados.
7. Cancelar uma operação em `queued`; confirmar `cancelled`, ausência de
   resultado e devolução de quota.
8. Cancelar uma operação em `processing`; confirmar interrupção cooperativa,
   limpeza do temporário e ausência de objeto parcial.
9. Provocar falha; confirmar `failed`, erro seguro, limpeza e devolução de
   quota.
10. Confirmar que eventos de outro projeto não aparecem no cliente autorizado.
11. Recarregar o projeto e confirmar que original e resultado permanecem
    acessíveis e distintos.
12. Repetir testes focados do fluxo de imagens e confirmar ausência de
    regressão.

## Validação automatizada esperada

- Testes unitários do validador de intervalos e das transições de estado.
- Testes de contrato dos endpoints de criação, consulta e cancelamento.
- Testes de integração com quota, autorização, fila, armazenamento e
  persistência do resultado.
- Testes de regressão das imagens.
- `git diff --check` e `docker compose config`.

## Critérios de aceitação

| Requisito | Evidência esperada |
|---|---|
| `REQ-VID-TRIM-001` a `REQ-VID-TRIM-004` | UI e contrato permitem duração, início e fim |
| `REQ-VID-TRIM-005` a `REQ-VID-TRIM-008` | Testes rejeitam todos os intervalos inválidos |
| `REQ-VID-TRIM-009` e `REQ-VID-TRIM-010` | Operação persistida e executada de forma assíncrona |
| `REQ-VID-TRIM-011` e `REQ-VID-TRIM-013` | Resultado novo com áudio preservado e original intacto |
| `REQ-VID-TRIM-012` | Cancelamento em fila e processamento com limpeza e quota devolvida |
| Requisitos transversais | Autorização, estados, progresso, erros e limpeza verificados |

Registar cada cenário como `pass`/`fail`, incluindo perfil, projeto,
`operationId`, intervalo, estado final e resultado observado.

## Evidência da implementação

- `projects`: imagem Docker construída com Node 20 e FFmpeg/FFprobe 5.1.9.
- Testes focados: 11 testes passaram no container `picturas-projects`.
- Frontend: `next build` passou no container, com apenas warnings pré-existentes
  e o warning de dependência do polling do diálogo.
- Compose: `docker compose config` passou.
- Runtime: `projects` e `frontend` foram recriados e ficaram em estado
  `running`; a entrada HTTPS respondeu `200 OK` através do Nginx.
- A validação interativa no browser não foi executada nesta sessão porque o
  certificado local é autoassinado e a ferramenta de browser recusou a ligação.
  Deve ser repetida no ambiente da equipa aceitando o certificado local.
