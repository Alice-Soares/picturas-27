# Research: Recorte temporal de vídeo

## Decisão 1 — Operação assíncrona persistida

- **Decision**: Representar o recorte como uma operação persistida com estados
  `queued`, `processing`, `completed`, `failed` e `cancelled`, identificador,
  origem, utilizador, projeto, intervalo, progresso, timestamps, erro e
  resultado opcional.
- **Rationale**: O UC2 exige fila, acompanhamento, cancelamento e recuperação;
  `REQ-VID-COM-009` a `REQ-VID-COM-011` exigem histórico e estados observáveis.
- **Alternatives considered**: Processar dentro do pedido HTTP (bloqueia o
  pedido e não suporta progresso); usar apenas eventos sem estado persistido
  (perde recuperação e auditoria).

## Decisão 2 — RabbitMQ e fila de vídeo isolada

- **Decision**: Acrescentar uma fila de vídeo dedicada e mensagens com
  `operationId`, projeto, utilizador, vídeo, instantes e destino do resultado;
  manter as filas de imagem inalteradas.
- **Rationale**: `projects/utils/rabbit_mq.js` já fornece publicação/consumo e
  `DQ-002` exige isolamento do processamento de imagens.
- **Alternatives considered**: Reutilizar a fila de imagens (mistura
  contratos); introduzir um broker novo (duplica infraestrutura).

**Implementação validada**: A chave `video_trim` é publicada no exchange
`picturas`, consumida pelo worker do Projects Service e ligada à fila dedicada
`video_trim`. O arranque do serviço inicia o consumidor sem alterar as filas
existentes.

## Decisão 3 — Resultado como novo vídeo imutável

- **Decision**: Ler o original do estágio `video-src`, produzir um novo objeto e
  criar nova referência no projeto apenas após conclusão válida.
- **Rationale**: `REQ-VID-TRIM-011`, `REQ-VID-TRIM-013` e `DQ-003` preservam o
  original e o áudio correspondente.
- **Alternatives considered**: Substituir o original (perde reversibilidade);
  guardar apenas um temporário (não produz conteúdo persistente).

## Decisão 4 — Cancelamento cooperativo e limpeza idempotente

- **Decision**: O cancelamento altera apenas operações em `queued` ou
  `processing`, publica um sinal identificado pela operação e o worker verifica
  o estado antes de iniciar, durante progresso e antes de persistir o resultado.
  A limpeza é idempotente.
- **Rationale**: Satisfaz `REQ-VID-TRIM-012`, `REQ-VID-TRIM-013`,
  `REQ-VID-COM-008` e `REQ-VID-Q-014`, além de corrigir a limitação observada
  no cancelamento do UC1.
- **Alternatives considered**: Cancelar apenas no browser (o servidor pode
  concluir depois de `ERR_ABORTED`); apagar apenas a referência (deixa objeto
  parcial).

## Decisão 5 — Quota reservada antes da fila

- **Decision**: Reservar uma operação avançada para utilizador registado antes
  de criar/publicar o trabalho; premium não fica limitado; concluir converte a
  reserva em consumo e falha/cancelamento devolve-a.
- **Rationale**: Deriva de `REQ-VID-COM-004` a `REQ-VID-COM-008` e das regras
  RN3/RN7 do UC2. O users service já expõe verificação, atualização e refund.
- **Alternatives considered**: Debitar apenas no fim (permite ultrapassar quota
  durante concorrência); nunca reservar (viola o catálogo).

## Decisão 6 — Progresso pelo evento autorizado do projeto

- **Decision**: Publicar eventos `project-op` com `projectId`, `operationId`,
  estado, progresso e metadados mínimos; o WebSocket encaminha-os para a sala
  do projeto.
- **Rationale**: `send_msg_project_op` e `project:<id>` já existem em
  `wsGateway`; `DQ-001` exige estado/progresso sem polling.
- **Alternatives considered**: Polling contínuo (mais tráfego); incluir dados
  do vídeo no evento (risco de exposição cruzada).

**Implementação validada**: A UI usa o evento `project-op` existente para
atualização do projeto e consulta a operação enquanto esta está ativa, com
cancelamento explícito e invalidação do projeto após conclusão.

## Decisão 7 — Intervalo e formato

- **Decision**: Aceitar instantes em segundos, exigir `end > start` e
  `end - start >= 1`, validar contra a duração do vídeo e manter o formato
  suportado da entrada no MVP.
- **Rationale**: RN1, `REQ-VID-TRIM-005` a `REQ-VID-TRIM-008` e o limite de
  conversão reservado ao UC4.
- **Alternatives considered**: Frames como contrato público (depende do fps);
  permitir segmentos sub-segundo (viola RN1).
