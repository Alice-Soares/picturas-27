# Research: Aplicar ferramenta a fotogramas de vídeo

## Decisão 1 — Reutilizar a operação assíncrona de vídeo

- **Decision**: Criar uma operação persistida do tipo `frame_tool`, com os mesmos estados `queued`, `processing`, `completed`, `failed` e `cancelled` usados pelo recorte.
- **Rationale**: O Projects Service já persiste operações, publica eventos `project-op`, reserva/devolve quota e executa workers FFmpeg. Reutilizar esse ciclo mantém autorização, observabilidade e limpeza consistentes.
- **Alternatives considered**: Processar no pedido HTTP (bloqueia o cliente); criar um serviço autónomo (duplica autorização, storage e mensageria).

## Decisão 2 — Intervalo temporal configurável no MVP

- **Decision**: Aceitar início/fim em segundos e uma taxa de saída validada contra os metadados do vídeo; se o intervalo não for definido, usar o vídeo completo.
- **Rationale**: O UC-VID-003 resolve Q1 a favor da seleção de intervalo e exige reduzir o número de fotogramas quando aplicável.
- **Alternatives considered**: Processar sempre o vídeo completo (custo desnecessário); usar frames como contrato público (acopla a taxa de fotogramas).

## Decisão 3 — Adaptador para o contrato de ferramentas de imagem

- **Decision**: O worker extrai um fotograma, publica-o no contrato existente de ferramenta e só aceita resultados que sejam uma imagem utilizável; uma cadeia aplica as ferramentas pela ordem selecionada.
- **Rationale**: `Tools/utils/tool_msg.py` define filas por ferramenta e respostas com `output.type`/`imageURI`. Ferramentas de deteção ou metadados não podem ser usadas para recomposição, conforme RN5 e Q2.
- **Alternatives considered**: Alterar cada ferramenta para conhecer vídeo (duplica lógica); aceitar metadados como frame (produz vídeo inválido).

## Decisão 4 — Recomposição preservando streams não afetadas

- **Decision**: Usar FFmpeg para extrair/recompor frames, mantendo a resolução e a faixa de áudio original quando a ferramenta não exigir alteração; guardar o resultado como novo vídeo.
- **Rationale**: FFmpeg já está instalado no Dockerfile de Projects e RN4 exige preservar áudio e resolução.
- **Alternatives considered**: Implementar codecs no Node (complexidade e risco); substituir o vídeo original (perde reversibilidade).

## Decisão 5 — Falha de frame com uma repetição

- **Decision**: Repetir uma vez cada frame que falhar; uma segunda falha termina a operação como `failed`, remove temporários/resultado parcial e devolve quota reservada.
- **Rationale**: Implementa FA2 e `REQ-VID-FRM-005` sem ocultar falhas persistentes.
- **Alternatives considered**: Ignorar frames falhados (vídeo incompleto); repetir indefinidamente (não determinístico).

## Decisão 6 — Paralelismo adiado

- **Decision**: Usar o limite natural do worker/fila no MVP; não introduzir limite por perfil ou múltiplos workers coordenados nesta feature.
- **Rationale**: UC-VID-003/Q3 foi adiada para a Fase 2; não há fonte aprovada para um valor numérico.
- **Alternatives considered**: Inventar quotas de concorrência (viola a constituição); processar tudo em paralelo (risco operacional sem decisão arquitetural).
