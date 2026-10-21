# Especificação: Extrair sequência de fotogramas de um vídeo

**Feature Branch**: `005-extrair-fotogramas`

**Created**: 2026-10-20

**Status**: Draft

**Input**: `UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo`, com os requisitos `REQ-VID-FEX-*` e os requisitos transversais `REQ-VID-COM-*` e `REQ-VID-Q-*`.

## Enquadramento e âmbito

Esta funcionalidade implementa o `UC-VID-005`. Permite a um utilizador
registado ou premium selecionar um vídeo autorizado, configurar um intervalo
temporal e uma quantidade máxima de fotogramas, e extrair os resultados como
imagens JPEG no projeto.

A extração é assíncrona. O vídeo original permanece inalterado e os resultados
só ficam disponíveis na biblioteca quando a operação termina com sucesso. A
funcionalidade não inclui aplicar ferramentas de imagem aos fotogramas,
conversão de vídeo, concatenação ou gestão de áudio, que pertencem aos casos
`UC-VID-003`, `UC-VID-004`, `UC-VID-006` e `UC-VID-007`.

**Fontes de verdade consultadas**:

- [UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo](../../docs/use-cases/UC-VID-005-extrair-fotogramas.md)
- [RAS — requisitos de vídeo](../../docs/RAS-requisitos-video.md)
- [Diretrizes da Fase 1](../../docs/diretrizes_fase_1.md)
- [Guia do caso de uso em Typst](../../docs/src-doc-ext-requisitos/casos-uso/UC-VID-005.typ)
- [Especificação do UC-VID-001](../001-video-submission/spec.md)
- Baseline do repositório: commit `f782daa` da branch `main`.

## User Scenarios & Testing

### User Story 1 — Configurar e extrair fotogramas (Priority: P1)

Como utilizador registado ou premium com acesso ao projeto, quero selecionar um
vídeo e definir o intervalo e a quantidade de fotogramas para obter imagens que
possa consultar e processar no projeto, sem alterar o vídeo original.

**Why this priority**: Esta é a capacidade central do UC-VID-005 e liga o
processamento de vídeo à biblioteca de imagens da plataforma.

**Independent Test**: Selecionar um vídeo válido, configurar um intervalo e uma
quantidade dentro do limite do perfil, confirmar a operação e verificar que os
fotogramas JPEG aparecem no projeto e que o vídeo original permanece inalterado.

**Acceptance Scenarios**:

1. **Given** um vídeo acessível no projeto, **When** o utilizador inicia a
   extração, **Then** o sistema apresenta o intervalo temporal, a quantidade
   máxima e o formato JPEG disponíveis.
2. **Given** parâmetros válidos, **When** o utilizador os altera, **Then** o
   sistema calcula e apresenta uma estimativa da quantidade de fotogramas antes
   da confirmação.
3. **Given** uma configuração confirmada dentro do limite do perfil, **When**
   a operação termina com sucesso, **Then** o sistema guarda cada fotograma
   como imagem JPEG no projeto escolhido e disponibiliza-o na biblioteca.
4. **Given** uma operação concluída, **When** o utilizador compara o vídeo de
   origem com o estado anterior, **Then** o conteúdo do vídeo original não foi
   alterado.

### User Story 2 — Validar acesso, limites e armazenamento (Priority: P1)

Como proprietário do sistema, quero que apenas utilizadores autorizados possam
extrair fotogramas e que a operação seja rejeitada quando excede os limites do
perfil ou o espaço disponível.

**Why this priority**: A autorização e a validação prévia evitam acesso cruzado,
operações inviáveis e consumo de recursos sem resultado válido.

**Independent Test**: Tentar extrair de outro projeto, usar um vídeo incompatível,
exceder os limites de 1000 ou 5000 fotogramas e simular armazenamento
insuficiente; confirmar rejeição antes da criação da operação.

**Acceptance Scenarios**:

1. **Given** um utilizador sem acesso ao projeto ou ao vídeo, **When** tenta
   iniciar a extração, **Then** o sistema rejeita o pedido sem revelar o
   conteúdo nem criar uma operação.
2. **Given** um vídeo com codec não suportado, **When** o utilizador confirma a
   extração, **Then** o sistema rejeita a operação e informa os codecs aceites.
3. **Given** uma estimativa superior a 1000 fotogramas para um utilizador
   registado ou 5000 para um utilizador premium, **When** o pedido é confirmado,
   **Then** o sistema bloqueia a extração e solicita a redução do intervalo ou
   da quantidade.
4. **Given** espaço de armazenamento insuficiente, **When** o utilizador
   confirma a operação, **Then** o sistema informa a condição e não inicia o
   processamento.

### User Story 3 — Acompanhar, cancelar e recuperar de falhas (Priority: P1)

Como utilizador, quero acompanhar o progresso, cancelar uma extração em curso e
receber um resultado claro quando ocorrer uma falha, sem ficar com ficheiros
parciais acessíveis.

**Why this priority**: A extração pode gerar muitos ficheiros e precisa de
terminar com estado e limpeza consistentes, sem reservar quota diária.

**Independent Test**: Criar uma operação suficientemente demorada para observar
estados, cancelá-la durante a execução e provocar uma falha; confirmar a limpeza,
a ausência de consumo de quota e a preservação do vídeo original.

**Acceptance Scenarios**:

1. **Given** uma operação em fila ou em processamento, **When** o utilizador a
   cancela, **Then** o sistema interrompe o trabalho, elimina os fotogramas
   temporários e marca a operação como `cancelada`, sem alterar a quota diária.
2. **Given** uma operação em processamento, **When** o sistema atualiza o
   estado, **Then** apenas clientes autorizados do projeto recebem a
   atualização por WebSocket.
3. **Given** uma falha durante a extração, **When** a operação termina, **Then**
   fica `falhada`, os temporários são removidos e não existe resultado parcial
   na biblioteca nem consumo de quota diária.

### Edge Cases

- Um intervalo temporal limitado deve produzir fotogramas apenas desse trecho.
- A quantidade máxima exatamente igual ao limite do perfil é válida; qualquer
  valor superior é rejeitado.
- Um intervalo ou quantidade que resulte em zero fotogramas deve ser rejeitado
  antes de criar a operação.
- Um vídeo sem codec suportado deve ser rejeitado antes do processamento.
- Cancelar depois de a operação ter terminado não remove as imagens já
  concluídas.
- Uma falha depois de alguns fotogramas terem sido gerados não deve apresentar
  esses fotogramas como resultado parcial.
- O projeto atual é o destino por omissão; a opção de criar um projeto novo
  permanece disponível conforme `FA3`.
- A pré-visualização dos primeiros fotogramas e filtros de alteração visual
  significativa não fazem parte do MVP; estão registados como questões em
  aberto no caso de uso.

## Requirements

### Functional Requirements

Os requisitos abaixo preservam o catálogo oficial do caso de uso.

- **REQ-VID-FEX-001**: O sistema deve permitir definir o instante inicial da extração.
- **REQ-VID-FEX-002**: O sistema deve permitir definir o instante final da extração.
- **REQ-VID-FEX-003**: O sistema deve permitir definir a quantidade máxima de fotogramas.
- **REQ-VID-FEX-004**: O sistema deve permitir selecionar JPEG como formato de saída do MVP.
- **REQ-VID-FEX-005**: O sistema deve calcular uma estimativa da quantidade de fotogramas antes da confirmação.
- **REQ-VID-FEX-006**: O sistema deve limitar uma operação a 1000 fotogramas para utilizadores registados.
- **REQ-VID-FEX-007**: O sistema deve limitar uma operação a 5000 fotogramas para utilizadores premium.
- **REQ-VID-FEX-008**: O sistema deve verificar o espaço disponível antes de iniciar a extração.
- **REQ-VID-FEX-009**: O sistema deve guardar cada fotograma extraído como imagem JPEG no projeto escolhido.
- **REQ-VID-FEX-010**: O sistema deve permitir escolher o projeto atual ou um projeto novo para os fotogramas.
- **REQ-VID-FEX-011**: O sistema deve eliminar os fotogramas temporários quando a extração for cancelada ou falhar.
- **REQ-VID-FEX-012**: O sistema não deve contabilizar a extração de fotogramas na quota diária de operações avançadas.

Os requisitos transversais aplicáveis são `REQ-VID-COM-001` a `REQ-VID-COM-020`
e `REQ-VID-Q-001` a `REQ-VID-Q-005`, conforme o catálogo consolidado, exceto
as regras de quota diária `REQ-VID-COM-004` a `REQ-VID-COM-008`. A funcionalidade
deve verificar o acesso ao projeto e ao vídeo, registar estados e erros,
proteger resultados e eventos contra acesso cruzado, impedir resultados
parciais e preservar o vídeo de origem.

### Non-Functional Requirements

- **REQ-VID-FEX-NF-001 (Fiabilidade)**: O sistema deve manter o vídeo original íntegro durante a extração, verificável por comparação do hash SHA-256 antes e depois da operação.
- **REQ-VID-FEX-NF-002 (Usabilidade)**: O sistema deve disponibilizar pelo menos uma atualização de estado para cada operação assíncrona e uma atualização de progresso quando a operação ultrapassar 5 segundos.
- **REQ-VID-FEX-NF-003 (Segurança)**: O sistema deve disponibilizar estados, resultados e eventos apenas a clientes autorizados no projeto.

### Key Entities

- **Vídeo**: conteúdo original associado a um projeto, com duração, formato,
  codec, resolução e referência imutável.
- **Configuração de extração**: seleção do vídeo, intervalo temporal, quantidade
  máxima, formato de saída e projeto de destino.
- **Fotograma**: imagem JPEG derivada de um instante do vídeo e associada ao
  projeto e à operação de origem.
- **Operação de extração**: trabalho assíncrono com identificador, utilizador,
  projeto, vídeo de origem, configuração, estado, progresso, timestamps, erro
  opcional e resultados.
- **Projeto**: contexto autorizado que contém o vídeo de origem e os fotogramas
  resultantes, podendo ser criado como destino novo quando escolhido pelo
  utilizador.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Em 100% das operações válidas concluídas, todos os fotogramas
  produzidos são JPEG, ficam no projeto escolhido e o vídeo original mantém o
  mesmo hash SHA-256.
- **SC-002**: Em 100% dos testes, uma operação que exceda 1000 fotogramas para
  utilizador registado ou 5000 para premium é rejeitada antes do processamento.
- **SC-003**: Em 100% dos testes de cancelamento ou falha, a operação termina no
  estado correspondente, não há resultado parcial acessível e os temporários
  são removidos.
- **SC-004**: Em 100% dos testes de autorização, utilizadores sem acesso não
  conseguem iniciar, consultar ou receber eventos da operação de outro projeto.
- **SC-005**: Em 100% dos testes de configuração, a estimativa de fotogramas é
  apresentada antes da confirmação e corresponde aos parâmetros selecionados.
- **SC-006**: Um utilizador autorizado consegue iniciar uma extração válida em
  até 2 minutos depois de selecionar o vídeo, sem alterar o vídeo de origem.

## Assumptions

- O `UC-VID-001` já disponibiliza no projeto vídeos válidos, acessíveis e com
  metadados suficientes para calcular a extração.
- O acesso à funcionalidade está limitado a utilizadores registados e premium;
  o perfil anónimo fica fora do MVP.
- A fila de processamento e o WebSocket existentes serão reutilizados para a
  execução assíncrona e as notificações.
- FFmpeg ou equivalente está disponível para extrair fotogramas e o sistema de
  armazenamento consegue verificar o espaço disponível e limpar temporários.
- O formato de saída do MVP é JPEG e cada operação conta como uma operação
  avançada; utilizadores premium não têm limite diário.
- O projeto ativo é o destino predefinido. A opção de projeto novo existe, mas
  a sua experiência detalhada pode ser refinada durante o planeamento.
- A pré-visualização prévia e a seleção por alteração visual significativa ficam
  fora do MVP, conforme as questões em aberto do caso de uso.

## Traceability Notes

| Elemento do UC-VID-005                | Requirements                                                                      |
| ------------------------------------- | --------------------------------------------------------------------------------- |
| Passos 3–7                            | `REQ-VID-FEX-001` a `REQ-VID-FEX-008`                                             |
| Passos 8–12                           | `REQ-VID-FEX-009`, `REQ-VID-FEX-011`, `REQ-VID-FEX-NF-001`                        |
| FA1                                   | `REQ-VID-FEX-001`, `REQ-VID-FEX-002`                                              |
| FA2 e falha de processamento          | `REQ-VID-FEX-011`, `REQ-VID-FEX-NF-002`                                           |
| FA3                                   | `REQ-VID-FEX-010`                                                                 |
| RN1–RN5                               | `REQ-VID-FEX-004`, `REQ-VID-FEX-006`, `REQ-VID-FEX-007`, `REQ-VID-FEX-009`        |
| Pré-condições e acesso                | `REQ-VID-COM-001`, `REQ-VID-COM-002`, `REQ-VID-COM-003`, `REQ-VID-FEX-NF-003`     |
| Estados, limpeza e preservação | `REQ-VID-COM-009` a `REQ-VID-COM-020`, `REQ-VID-FEX-012`, `REQ-VID-FEX-NF-001`, `REQ-VID-FEX-NF-002` |
