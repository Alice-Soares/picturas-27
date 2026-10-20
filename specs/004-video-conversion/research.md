# Research: Conversão de formato e resolução de vídeo

## Decisão 1 — Reutilizar a operação de vídeo existente

- **Decision**: Estender `VideoOperation` com o tipo `conversion` e campos de
  configuração de saída (`outputContainer`, `outputVideoCodec`,
  `outputAudioCodec`, `outputWidth`, `outputHeight`, `estimatedSize`),
  mantendo os estados, quota, resultado, autorização e timestamps existentes.
- **Rationale**: O recorte e a ferramenta de fotogramas já implementam o ciclo
  de vida assíncrono exigido por `REQ-VID-CONV-009` a `011`. Um modelo separado
  duplicaria autorização, cancelamento e eventos.
- **Alternatives considered**: Criar um modelo separado (duplicação);
  processar no pedido HTTP (bloqueio e ausência de progresso).
- **References**: `projects/models/videoOperation.js`,
  `projects/services/videoOperationService.js`,
  `projects/services/videoOperationState.js`.

## Decisão 2 — Tool autónoma e fila dedicada

- **Decision**: Criar `Tools/video_conversion` como Tool Python stateless, com
  Dockerfile, FFmpeg e consumidor RabbitMQ próprios. O Projects Service mantém
  um dispatcher fino para publicar pedidos e correlacionar respostas, sem
  executar FFmpeg.
- **Rationale**: A clarificação do utilizador separa explicitamente a
  responsabilidade de processamento da responsabilidade de orquestração.
  `DQ-002` exige isolamento do contrato de processamento de imagens, enquanto
  o padrão de `Tools/` já fornece containerização, helpers RabbitMQ e
  integração por mensagens.
- **Alternatives considered**: manter um worker FFmpeg no Projects Service
  (mistura responsabilidades); reutilizar uma fila de imagem (mistura
  contratos); criar um broker adicional (duplicação da infraestrutura).
- **References**: `Tools/brightness/`, `Tools/cut/`, `Tools/utils/`,
  `docker-compose.yaml`, `rabbitMQ/`.

## Decisão 3 — Contrato interno de mensagens

- **Decision**: A fila `video_conversion` usa mensagens com `messageId`,
  `correlationId`, `procedure`, `inputVideoURI`, `outputVideoURI` e opções já
  validadas. A resposta usa `status`, `correlationId`, `videoURI`, metadados
  efetivos e erro público; não reutiliza `imageURI`.
- **Rationale**: A Tool não deve conhecer projetos, utilizadores, quotas ou
  credenciais de armazenamento. Caminhos partilhados e um contrato
  correlacionado permitem ao dispatcher manter essas responsabilidades no
  Projects Service.
- **Alternatives considered**: a Tool aceder diretamente à MongoDB ou ao
  Image Storage Service (acoplamento e fuga de autorização); enviar comandos
  FFmpeg arbitrários (risco de injeção); reutilizar o payload de imagem
  (contrato semanticamente incorreto).

## Decisão 4 — Matriz de formatos conservadora no MVP

- **Decision**: A matriz inicialmente documentada deve prometer apenas as
  combinações já aprovadas no caso de uso: contentor MP4, vídeo H.264 e áudio
  AAC quando existir. A implementação deve expor a matriz por uma função
  centralizada e rejeitar qualquer combinação não listada.
- **Rationale**: `UC-VID-004/RN1` e `REQ-VID-SUB-005` a `007` não autorizam
  inventar contentores ou codecs adicionais. A conversão continua útil para
  redimensionar e re-encodar de forma consistente; novos formatos exigem
  alteração documentada do requisito.
- **Alternatives considered**: Adicionar WebM/VP9 sem decisão aprovada
  (introduz um requisito não fundamentado); aceitar qualquer combinação do
  FFmpeg (contrato imprevisível).

## Decisão 5 — Resolução de saída exata e limites por perfil

- **Decision**: A resolução escolhida representa exatamente largura e altura de
  saída. O servidor valida que ambas as dimensões são positivas e não excedem
  `1920x1080` para registados não premium ou `3840x2160` para premium. A
  configuração deve rejeitar dimensões não suportadas pelo contrato antes de
  criar a operação.
- **Rationale**: Os limites têm origem em `UC-VID-004/RN2` e
  `REQ-VID-CONV-006`/`007`; tratar a resolução como par exato torna o resultado
  verificável e evita que a UI apresente um tamanho diferente do pedido.
- **Alternatives considered**: Escalar apenas até ao limite preservando
  proporção (resultado diferente do pedido); padding/crop automático (nova
  regra visual não especificada).

## Decisão 6 — Resultado imutável e armazenamento existente

- **Decision**: O worker descarrega o original do estágio `video-src`, cria um
  ficheiro temporário por operação, publica o resultado através do serviço de
  armazenamento existente e acrescenta uma nova referência com
  `sourceVideoId`. O original nunca é sobrescrito.
- **Rationale**: Satisfaz `REQ-VID-CONV-010` e `DQ-003`, reutilizando
  `post_video`, `download_video`, `delete_video` e
  `appendVideoIfVersion`.
- **Alternatives considered**: Substituir o objeto original (perda de
  reversibilidade); persistir o temporário como resultado (inconsistente em
  falhas).
- **Storage note**: O estágio permanece `video-src` no MVP porque o helper de
  armazenamento existente usa esse contrato. Um novo estágio só deve ser
  introduzido com alterações coordenadas no serviço de armazenamento.

## Decisão 7 — Cancelamento cooperativo, limpeza e quota

- **Decision**: Reservar quota antes de publicar na fila para utilizadores
  registados; premium não reserva quota. O cancelamento é idempotente em
  `queued` e `processing`, envia uma sinalização correlacionada à Tool,
  termina o processo FFmpeg quando possível, devolve a reserva e remove
  temporários e uploads parciais.
- **Rationale**: Mantém o comportamento dos fluxos de vídeo existentes e
  cobre `REQ-VID-COM-004` a `008`, `REQ-VID-Q-013` e `014`.
- **Alternatives considered**: Debitar apenas no fim (race conditions);
  cancelar apenas no browser (worker pode concluir depois).

## Decisão 8 — Contratos e progresso

- **Decision**: Adicionar endpoints de opções/metadados e criação, reutilizar a
  consulta/cancelamento de `video-operations`, e publicar o evento existente
  `project-op` com `type: "conversion"`. A UI mantém polling como fallback e
  invalida o projeto após conclusão.
- **Rationale**: Preserva o contrato de autenticação, `X-Project-Version`,
  autorização e WebSocket já usado pelos diálogos de vídeo.
- **Alternatives considered**: Polling como único mecanismo (mais tráfego);
  evento com dados completos do vídeo (exposição desnecessária).

## Decisão 9 — Estimativa de tamanho nullable

- **Decision**: A estimativa é informativa e nullable. Deve ser calculada apenas
  quando os metadados necessários estiverem disponíveis; indisponibilidade é
  comunicada explicitamente e não bloqueia uma configuração válida.
- **Rationale**: Cumpre `REQ-VID-CONV-008` sem fabricar uma métrica. O cálculo
  poderá usar bitrate e duração conhecidos no plano de implementação, mas a
  exatidão final será verificada no resultado.
- **Alternatives considered**: Bloquear sem estimativa (reduz disponibilidade);
  mostrar um valor heurístico sem indicação (enganador).

## Questões técnicas resolvidas para o plano

- A confirmação de uma conversão usa o mesmo mecanismo de autorização e versão
  do projeto já aplicado ao recorte.
- O reconhecimento de eventos do WebSocket permanece baseado na sala do
  projeto; a autenticação de entrada na sala deve ser validada ou explicitamente
  registada como limitação antes da entrega.
- A limitação atual de `read_rabbit_msg` confirmar a mensagem antes do fim do
  trabalho é uma limitação existente. O MVP deve garantir que o worker captura
  falhas e marca a operação como `failed`; uma mudança de ack/nack fica fora
  deste plano salvo se os testes demonstrarem perda de operações.
