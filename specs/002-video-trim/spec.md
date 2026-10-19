# Especificação: Recorte temporal de vídeo

**Feature Branch**: `002-video-trim`

**Created**: 2026-10-19

**Status**: Draft

**Input**: `UC-VID-002 — Recorte Temporal de Vídeo (Trim)`, com os requisitos
`REQ-VID-TRIM-*` e requisitos transversais `REQ-VID-COM-*` e `REQ-VID-Q-*`.

## Enquadramento e âmbito

Esta funcionalidade implementa o `UC-VID-002`. Permite a um utilizador
registado ou premium selecionar um intervalo temporal de um vídeo já existente
num projeto autorizado, iniciar um recorte assíncrono, acompanhar o progresso,
cancelar a operação e consultar o novo vídeo resultante.

O vídeo original permanece imutável. O recorte é guardado como novo conteúdo,
mantendo o áudio correspondente quando existir. A funcionalidade não inclui
conversão explícita de formato, extração de fotogramas, concatenação ou gestão
de áudio, que pertencem aos casos `UC-VID-003` a `UC-VID-007`.

**Fontes de verdade consultadas**:

- [UC-VID-002 — Recorte Temporal de Vídeo](../../docs/use-cases/UC-VID-002-recorte-temporal.md)
- [RAS — requisitos de vídeo](../../docs/RAS-requisitos-video.md)
- [Diretrizes da Fase 1](../../docs/diretrizes_fase_1.md)
- [Especificação do UC-VID-001](../001-video-submission/spec.md)
- Baseline do repositório: commit `719c092bc4f8d74be46134c5e8e041060b1a456f`
  da branch `main`.

## User Scenarios & Testing

### User Story 1 — Criar um recorte válido (Priority: P1)

Como utilizador registado ou premium com acesso ao projeto, quero selecionar o
início e o fim de um vídeo e gerar um novo segmento para o utilizar no projeto,
sem alterar o vídeo original.

**Why this priority**: O recorte é a primeira operação de edição e demonstra
valor funcional além da simples submissão de vídeos.

**Independent Test**: Selecionar um vídeo válido, indicar um intervalo de pelo
menos um segundo, confirmar a operação e verificar que um novo vídeo é criado
com duração e áudio correspondentes ao intervalo, enquanto o original mantém o
mesmo conteúdo.

**Acceptance Scenarios**:

1. **Given** um vídeo acessível no projeto e a biblioteca aberta, **When** o
   utilizador escolhe o recorte, **Then** o sistema apresenta a duração do
   vídeo e permite definir os instantes inicial e final.
2. **Given** um intervalo válido, **When** o utilizador confirma o recorte,
   **Then** o sistema cria uma operação em fila e informa o utilizador do seu
   estado.
3. **Given** uma operação de recorte concluída, **When** o utilizador consulta
   o projeto, **Then** existe um novo vídeo com o segmento solicitado, o áudio
   correspondente quando aplicável e o original permanece inalterado.

### User Story 2 — Rejeitar parâmetros e acesso inválidos (Priority: P1)

Como proprietário do sistema, quero que apenas utilizadores autorizados possam
recortar vídeos e que os intervalos inválidos sejam rejeitados antes de criar
uma operação ou alterar conteúdos.

**Why this priority**: A autorização e a validação dos limites preservam a
segurança e evitam operações sem sentido ou resultados incorretos.

**Independent Test**: Tentar recortar um vídeo de outro projeto, usar uma
sessão anónima ou inválida e submeter intervalos fora da duração, invertidos ou
com menos de um segundo; confirmar rejeição sem operação nem alteração do
original.

**Acceptance Scenarios**:

1. **Given** um utilizador sem acesso ao projeto ou ao vídeo, **When** tenta
   iniciar um recorte, **Then** o sistema rejeita o pedido sem revelar
   metadados nem criar operação.
2. **Given** um instante inicial ou final negativo ou superior à duração,
   **When** o utilizador confirma o recorte, **Then** o sistema rejeita os
   parâmetros e solicita a sua correção.
3. **Given** um instante inicial igual ou posterior ao final, ou um intervalo
   inferior a um segundo, **When** o utilizador confirma, **Then** o sistema
   rejeita o intervalo e não inicia processamento.

### User Story 3 — Acompanhar, cancelar e recuperar (Priority: P1)

Como utilizador, quero acompanhar uma operação de recorte, cancelá-la enquanto
está em fila ou em processamento e receber um resultado claro quando ocorrer
uma falha.

**Why this priority**: O recorte pode demorar e precisa de terminar sem
temporários acessíveis, resultados parciais ou consumo indevido de quota.

**Independent Test**: Criar operações suficientemente demoradas para observar
estado e progresso, cancelar uma operação em cada estado possível e provocar
uma falha; confirmar estado final, limpeza, devolução da quota e preservação
do original.

**Acceptance Scenarios**:

1. **Given** uma operação em fila ou em processamento, **When** o utilizador a
   cancela, **Then** o estado fica `cancelada`, o processamento é interrompido,
   os temporários são removidos e a quota reservada é devolvida.
2. **Given** uma operação em processamento, **When** o sistema comunica
   progresso, **Then** apenas utilizadores autorizados do projeto recebem os
   estados e atualizações correspondentes.
3. **Given** uma falha do processamento, **When** a operação termina, **Then**
   fica `falhada`, apresenta uma mensagem segura, remove temporários, não cria
   resultado parcial e devolve a quota reservada.

### Edge Cases

- Os valores exatamente iguais a `0` e à duração do vídeo são válidos quando
  formam um intervalo com pelo menos um segundo.
- Um intervalo com início igual ao fim é inválido.
- Um intervalo com duração inferior a um segundo é inválido.
- A duração e os instantes são expressos em segundos, com precisão suficiente
  para representar a seleção do utilizador; o sistema deve normalizar valores
  fora do intervalo antes de iniciar a operação.
- Um vídeo sem faixa de áudio produz um recorte sem áudio; não deve ser criada
  uma faixa artificial.
- O formato de saída segue o formato suportado do vídeo de entrada no MVP; a
  escolha de outro formato pertence ao `UC-VID-004`.
- Cancelar uma operação depois de o resultado ter sido concluído não elimina o
  novo vídeo já concluído.
- A operação nunca substitui nem elimina o vídeo original.
- Utilizadores premium não ficam sujeitos ao limite diário de operações; os
  utilizadores registados precisam de quota disponível.

## Requirements

### Functional Requirements

- **REQ-VID-TRIM-001**: O sistema deve disponibilizar o progresso do recorte ao
  utilizador durante o processamento.
- **REQ-VID-TRIM-002**: O sistema deve apresentar a duração do vídeo selecionado
  antes da confirmação do intervalo.
- **REQ-VID-TRIM-003**: O sistema deve permitir definir o instante inicial do
  recorte.
- **REQ-VID-TRIM-004**: O sistema deve permitir definir o instante final do
  recorte.
- **REQ-VID-TRIM-005**: O sistema deve rejeitar um instante inicial negativo ou
  superior à duração do vídeo.
- **REQ-VID-TRIM-006**: O sistema deve rejeitar um instante final negativo ou
  superior à duração do vídeo.
- **REQ-VID-TRIM-007**: O sistema deve rejeitar um intervalo cujo instante
  inicial não seja anterior ao instante final.
- **REQ-VID-TRIM-008**: O sistema deve rejeitar um segmento com duração inferior
  a um segundo.
- **REQ-VID-TRIM-009**: O sistema deve criar uma operação de recorte em estado
  `em fila` depois da confirmação e validação.
- **REQ-VID-TRIM-010**: O sistema deve executar o recorte de forma assíncrona
  através de uma operação de vídeo na fila de processamento.
- **REQ-VID-TRIM-011**: O sistema deve guardar o segmento recortado como novo
  vídeo.
- **REQ-VID-TRIM-012**: O sistema deve permitir cancelar a operação em fila ou
  em processamento e marcar o estado como `cancelada`, sem consumir quota.
- **REQ-VID-TRIM-013**: O sistema deve preservar o áudio correspondente quando
  o segmento original tiver áudio.

Os requisitos transversais aplicáveis são `REQ-VID-COM-001` a
`REQ-VID-COM-020` e `REQ-VID-Q-001` a `REQ-VID-Q-016`, conforme o catálogo
consolidado. Em particular, a funcionalidade deve verificar acesso ao projeto e
ao vídeo, reservar e devolver quota conforme o resultado, registar estados e
erros, proteger resultados e eventos contra acesso cruzado e limpar
temporários.

### Key Entities

- **Vídeo**: conteúdo original armazenado no projeto, com duração, formato,
  resolução, áudio opcional e referência imutável.
- **Intervalo de recorte**: seleção constituída por instante inicial e final,
  associada ao vídeo original e validada contra a sua duração.
- **Operação de vídeo**: trabalho assíncrono de recorte com identificador,
  utilizador, projeto, origem, estado, progresso, timestamps, erro opcional e
  resultado opcional.
- **Vídeo resultante**: novo conteúdo derivado do vídeo original, associado ao
  projeto e à operação concluída.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Em 100% dos recortes válidos concluídos, o projeto contém um novo
  vídeo e o vídeo original mantém o mesmo conteúdo.
- **SC-002**: 100% dos intervalos inválidos testados são rejeitados antes da
  criação de uma operação de processamento.
- **SC-003**: 100% das operações canceladas ou falhadas ficam sem resultado
  parcial acessível e devolvem a quota reservada.
- **SC-004**: Pelo menos 95% das atualizações de estado de uma operação chegam
  apenas a clientes autorizados e são observáveis durante o processamento.
- **SC-005**: Um utilizador consegue iniciar um recorte válido em até 2 minutos
  após selecionar um vídeo, sem necessidade de alterar o vídeo original.

## Assumptions

- O `UC-VID-001` já disponibiliza no projeto vídeos válidos e metadados
  suficientes para iniciar o recorte.
- A autenticação, autorização de projeto e canal de eventos existentes serão
  reutilizados e estendidos apenas onde necessário para vídeo.
- O processamento é assíncrono; estados mínimos são `em fila`,
  `em processamento`, `concluída`, `falhada` e `cancelada`.
- O resultado é sempre um novo vídeo; substituir o original e retomar uma
  operação interrompida estão fora do MVP.
- O formato de saída não é escolhido pelo utilizador nesta funcionalidade e
  mantém o formato de vídeo suportado pela entrada.
- FFmpeg, armazenamento de objetos, fila de vídeo e WebSocket são dependências
  do ambiente de execução; os detalhes de implementação serão definidos no
  plano sem alterar este contrato funcional.
- Os limites de quota e a devolução após falha/cancelamento seguem as regras
  transversais do catálogo de requisitos.
