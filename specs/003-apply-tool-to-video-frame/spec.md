# Feature Specification: Aplicar ferramenta a fotogramas de vídeo

**Feature Branch**: `003-apply-tool-to-video-frame`

**Created**: 2026-10-20

**Status**: Draft

**Input**: User description: Aplicar uma ferramenta de processamento de imagem a todos ou a um intervalo de fotogramas de um vídeo.

**Source**: UC-VID-003 — Aplicar Ferramenta Existente aos Fotogramas de um Vídeo.

## User Scenarios & Testing

### User Story 1 - Processar fotogramas com uma ferramenta (Priority: P1)

Um utilizador registado ou premium seleciona um vídeo do seu projeto, escolhe
uma ferramenta de imagem compatível, define os parâmetros, o intervalo temporal
e a taxa de fotogramas, e inicia o processamento. O sistema disponibiliza um
novo vídeo processado sem alterar o vídeo original.

**Why this priority**: É o valor central da extensão de ferramentas de imagem
para vídeo e constitui o MVP funcional do UC-VID-003.

**Independent Test**: Com um vídeo autorizado e uma ferramenta de imagem
compatível, configurar um intervalo, iniciar a operação e confirmar que o novo
vídeo fica disponível, enquanto o original permanece inalterado.

**Acceptance Scenarios**:

1. **Given** um utilizador autenticado, um projeto acessível e um vídeo dentro
   dos limites do seu perfil, **When** seleciona uma ferramenta compatível e
   confirma parâmetros, intervalo e taxa válidos, **Then** o sistema cria uma
   operação e apresenta o seu estado.
2. **Given** uma operação criada, **When** o processamento termina com sucesso,
   **Then** o sistema disponibiliza um novo vídeo no projeto e preserva o vídeo
   original.
3. **Given** um vídeo com áudio e uma ferramenta que não altera a resolução,
   **When** o processamento termina, **Then** o resultado mantém a faixa de
   áudio e a resolução do vídeo de origem.
4. **Given** um utilizador anónimo ou sem quota disponível, **When** tenta
   iniciar a operação, **Then** o sistema rejeita o pedido sem criar trabalho
   parcial.

### User Story 2 - Encadear ferramentas (Priority: P2)

O utilizador pode selecionar mais do que uma ferramenta compatível e definir a
ordem em que devem ser aplicadas a cada fotograma antes da recomposição.

**Why this priority**: O encadeamento aumenta o valor das ferramentas existentes,
mas depende do fluxo principal de processamento de um único efeito.

**Independent Test**: Com duas ferramentas determinísticas e parâmetros válidos,
processar um intervalo e confirmar que cada fotograma recebe as transformações
na ordem escolhida.

**Acceptance Scenarios**:

1. **Given** duas ferramentas compatíveis ordenadas pelo utilizador, **When** a
   operação é confirmada, **Then** o sistema aplica ambas pela ordem selecionada
   antes de recompor o resultado.
2. **Given** uma ferramenta que produz metadados em vez de uma imagem,
   **When** é selecionada para recomposição, **Then** o sistema rejeita a
   configuração ou informa que a ferramenta não é compatível com vídeo.

### User Story 3 - Acompanhar, cancelar e recuperar de falhas (Priority: P1)

Durante o processamento, o utilizador acompanha o estado e o progresso, pode
cancelar a operação e recebe uma indicação segura quando uma falha persistente
impede a conclusão.

**Why this priority**: Operações de vídeo são demoradas e precisam de controlo
explícito para não deixar resultados parciais nem consumir quota indevidamente.

**Independent Test**: Provocar uma falha num fotograma e depois cancelar uma
operação em execução, confirmando retry limitado, estado final e limpeza.

**Acceptance Scenarios**:

1. **Given** uma operação em processamento, **When** o utilizador consulta o
   projeto, **Then** vê o estado e um progresso que não regride.
2. **Given** um fotograma que falha, **When** o sistema tenta processá-lo,
   **Then** repete o fotograma uma vez e termina a operação como falhada se a
   segunda tentativa também falhar.
3. **Given** uma operação em fila ou em processamento, **When** o utilizador a
   cancela, **Then** o sistema interrompe o trabalho pendente, remove temporários
   e marca a operação como cancelada.
4. **Given** uma operação falhada ou cancelada, **When** o utilizador consulta o
   projeto, **Then** o vídeo original permanece disponível, não existe resultado
   parcial e a quota reservada é devolvida quando aplicável.

### Edge Cases

- O intervalo deve começar em zero ou depois, terminar depois do início e não
  ultrapassar a duração do vídeo.
- A taxa de fotogramas deve ser positiva; a ausência de taxa explícita usa a
  taxa do vídeo de origem.
- Um vídeo com codec/contentor incompatível deve ser rejeitado antes do início.
- Uma ferramenta de IA que gere deteções ou metadados, em vez de uma imagem por
  fotograma, não pode ser usada para gerar um vídeo recomposto.
- O resultado não deve substituir o vídeo original mesmo quando o projeto tem
  versões derivadas anteriores.
- O limite de paralelismo por perfil não faz parte do MVP e será decidido numa
  fase posterior.

## Requirements

### Functional Requirements

- **REQ-VID-FRM-001**: O sistema deve permitir selecionar uma ferramenta de
  imagem existente e parâmetros compatíveis para aplicação aos fotogramas de um
  vídeo.
- **REQ-VID-FRM-002**: O sistema deve extrair, processar e recompor os
  fotogramas no intervalo e à taxa definidos pelo utilizador.
- **REQ-VID-FRM-003**: O sistema deve preservar a faixa de áudio e a resolução
  quando a ferramenta não exigir alteração.
- **REQ-VID-FRM-004**: O sistema deve aplicar ferramentas compatíveis pela
  ordem selecionada quando o encadeamento for solicitado.
- **REQ-VID-FRM-005**: O sistema deve repetir uma vez o processamento de um
  fotograma que falhe e terminar a operação como falhada se a falha persistir.
- **REQ-VID-FRM-006**: O sistema deve permitir cancelar uma operação em fila ou
  em processamento, remover os seus temporários e manter o vídeo original.
- **REQ-VID-FRM-007**: O sistema deve disponibilizar o estado e o progresso da
  operação ao utilizador autorizado.
- **REQ-VID-FRM-008**: O sistema deve rejeitar utilizadores anónimos e operações
  que excedam a quota aplicável ao perfil.
- **REQ-VID-FRM-009**: O sistema deve aceitar vídeos até 5 minutos e 1920×1080
  para utilizadores registados e até 30 minutos e 3840×2160 para utilizadores
  premium, conforme as regras transversais de vídeo.
- **REQ-VID-FRM-010**: O sistema deve criar o resultado como novo vídeo no
  projeto e manter o conteúdo original inalterado.

### Non-Functional Requirements

- **REQ-VID-FRM-NF-001 (Performance)**: O sistema deve aceitar a operação sem
  bloquear o pedido do utilizador durante o processamento dos fotogramas.
- **REQ-VID-FRM-NF-002 (Reliability)**: Em falha ou cancelamento, o sistema
  deve remover temporários e não disponibilizar conteúdo parcial como resultado.
- **REQ-VID-FRM-NF-003 (Security)**: O sistema deve expor estados e resultados
  apenas ao utilizador autorizado para o projeto.

## Key Entities

- **Vídeo**: Conteúdo associado a um projeto, com duração, resolução, taxa de
  fotogramas, formato, áudio e eventual relação com um vídeo de origem.
- **Ferramenta de fotograma**: Ferramenta de imagem e parâmetros que podem ser
  aplicados a cada fotograma, com uma posição na cadeia.
- **Intervalo de processamento**: Início, fim e taxa de fotogramas que definem
  a parte do vídeo a processar.
- **Operação de processamento**: Trabalho associado a um utilizador, projeto e
  vídeo, com ferramentas, progresso, estado, resultado e eventual erro.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Em 100% das operações válidas concluídas, o projeto contém um
  novo vídeo processado e o vídeo original continua acessível e inalterado.
- **SC-002**: Em 100% dos testes com ferramenta compatível, todos os fotogramas
  do intervalo selecionado são processados ou a operação termina explicitamente
  como falhada.
- **SC-003**: Em 100% dos testes de falha persistente, o sistema realiza no
  máximo duas tentativas por fotograma e não publica resultado parcial.
- **SC-004**: Em 100% dos testes de cancelamento, a operação termina como
  cancelada, os temporários são removidos e o original permanece disponível.
- **SC-005**: Em 100% dos testes com áudio e ferramenta que não altera a
  resolução, o resultado mantém a faixa de áudio e a resolução de origem.
- **SC-006**: Utilizadores autorizados conseguem identificar o estado final da
  operação e o resultado sem consultar detalhes internos do processamento.

## Assumptions

- O utilizador tem sessão iniciada e acesso de edição ao projeto.
- O vídeo já está associado ao projeto e foi validado pelos limites gerais de
  submissão de vídeo.
- As ferramentas selecionadas aceitam uma imagem isolada e devolvem uma imagem
  para cada fotograma processado.
- O sistema pode reservar uma operação avançada para utilizadores registados;
  utilizadores premium não têm limite diário para esta operação.
- O processamento ocorre de forma assíncrona e o utilizador pode fechar a
  interface sem invalidar a operação.
- O limite de paralelismo por perfil é adiado para uma decisão posterior e não
  é requisito do MVP.

## Traceability Notes

| UC-VID-003              | Requirements                                                       |
| ----------------------- | ------------------------------------------------------------------ |
| Passos 3–8              | REQ-VID-FRM-001, REQ-VID-FRM-002, REQ-VID-FRM-008, REQ-VID-FRM-009 |
| Passos 9–12             | REQ-VID-FRM-002, REQ-VID-FRM-003, REQ-VID-FRM-007, REQ-VID-FRM-010 |
| FA1                     | REQ-VID-FRM-004                                                    |
| FA2 e exceções de falha | REQ-VID-FRM-005, REQ-VID-FRM-NF-002                                |
| FA3                     | REQ-VID-FRM-006                                                    |
| RN1–RN5                 | REQ-VID-FRM-003, REQ-VID-FRM-008, REQ-VID-FRM-009                  |
