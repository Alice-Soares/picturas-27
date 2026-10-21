# Feature Specification: Gestão de Áudio de Vídeo

**Feature Branch**: `006-gerir-audio`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "Criar o spec do caso de uso UC-VID-007 — Gerir Áudio do Vídeo, tendo em conta os requisitos já definidos em RAS-requisitos-video.md e toda a documentação de contexto do projeto."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Remover áudio de um vídeo (Priority: P1)

Como utilizador registado ou premium, quero remover a faixa sonora de um vídeo do meu projeto para obter uma cópia sem áudio, mantendo o vídeo original disponível.

**Why this priority**: É uma das operações centrais do caso de uso e permite produzir uma variante sem som com uma alteração clara e verificável.

**Independent Test**: Selecionar um vídeo com áudio, confirmar a remoção, acompanhar a operação até à conclusão e verificar que a biblioteca contém um novo vídeo sem áudio e que o original permanece inalterado.

**Acceptance Scenarios**:

1. **Dado** um utilizador autorizado, um projeto acessível e um vídeo com áudio, **Quando** escolhe “Remover Áudio” e confirma, **Então** o sistema cria uma operação de processamento e disponibiliza um novo vídeo sem faixa sonora quando a operação termina.
2. **Dado** um vídeo sem faixa sonora, **Quando** o utilizador escolhe “Remover Áudio”, **Então** o sistema informa que o vídeo já não tem áudio, não cria resultado e não consome quota.
3. **Dado** uma operação de remoção em curso, **Quando** o utilizador a cancela, **Então** a operação fica cancelada, os temporários são removidos, o vídeo original permanece inalterado e a quota reservada é devolvida.

### User Story 2 - Substituir áudio de um vídeo (Priority: P1)

Como utilizador registado ou premium, quero substituir a faixa sonora de um vídeo por um ficheiro escolhido para criar uma nova versão com áudio AAC.

**Why this priority**: A substituição cobre a edição de áudio mais completa do MVP e permite controlar o áudio resultante sem alterar o conteúdo original.

**Independent Test**: Selecionar um vídeo, fornecer um ficheiro MP3 ou M4A/AAC, confirmar a operação e verificar o novo vídeo, incluindo o comportamento quando a duração do áudio difere da duração do vídeo.

**Acceptance Scenarios**:

1. **Dado** um vídeo acessível e um ficheiro de substituição MP3, **Quando** o utilizador confirma a substituição, **Então** o sistema aceita o ficheiro e produz um novo vídeo MP4 com áudio AAC.
2. **Dado** um vídeo acessível e um ficheiro de substituição M4A/AAC, **Quando** o utilizador confirma a substituição, **Então** o sistema aceita o ficheiro e produz um novo vídeo MP4 com áudio AAC.
3. **Dado** um ficheiro de substituição num formato não suportado, **Quando** o utilizador o seleciona, **Então** o sistema rejeita-o com uma mensagem que identifica a condição sem expor detalhes internos e não inicia o processamento.
4. **Dado** um áudio de substituição mais curto do que o vídeo, **Quando** a substituição termina, **Então** o restante do vídeo fica sem áudio.
5. **Dado** um áudio de substituição mais longo do que o vídeo, **Quando** a substituição termina, **Então** o áudio é cortado no fim do vídeo.
6. **Dado** uma substituição em curso, **Quando** o utilizador a cancela, **Então** não é apresentado um resultado parcial e a quota reservada é devolvida.

### User Story 3 - Extrair a faixa de áudio (Priority: P2)

Como utilizador registado ou premium, quero extrair a faixa sonora de um vídeo para obter um ficheiro de áudio independente na biblioteca do projeto.

**Why this priority**: A extração permite reutilizar o áudio fora do vídeo e completa o conjunto de operações definido para UC-VID-007.

**Independent Test**: Selecionar um vídeo com áudio, confirmar a extração e verificar que a biblioteca contém um novo ficheiro M4A com áudio AAC e que o vídeo original permanece disponível.

**Acceptance Scenarios**:

1. **Dado** um vídeo acessível com faixa sonora, **Quando** o utilizador escolhe “Extrair Faixa de Áudio” e confirma, **Então** o sistema guarda um novo ficheiro M4A com áudio AAC na biblioteca do projeto.
2. **Dado** um vídeo sem faixa sonora, **Quando** o utilizador confirma a extração, **Então** o sistema apresenta um erro explicativo, não cria resultado e não consome quota.

### Edge Cases

- Um utilizador anónimo ou com sessão inválida não pode iniciar, acompanhar ou obter resultados de uma operação de áudio.
- Uma referência de vídeo que não pertença ao projeto autorizado deve ser rejeitada antes de qualquer leitura do conteúdo.
- Uma quota de operações avançadas esgotada deve impedir o início da operação e comunicar o estado da quota.
- Uma falha técnica, ficheiro corrompido ou resultado parcial deve marcar a operação como falhada, limpar temporários, preservar o original e devolver a quota reservada.
- Uma operação concluída deve aparecer como novo conteúdo; o original nunca é substituído.
- A escolha de múltiplas faixas de áudio não faz parte do MVP; o processamento considera a faixa aplicável do vídeo de origem.

## Requirements *(mandatory)*

### Functional Requirements

- **REQ-VID-AUD-001**: O sistema deve apresentar a opção de remover áudio para um vídeo autorizado.
- **REQ-VID-AUD-002**: O sistema deve permitir confirmar a remoção da faixa de áudio.
- **REQ-VID-AUD-003**: O sistema deve permitir selecionar um ficheiro de áudio para substituição.
- **REQ-VID-AUD-004**: O sistema deve aceitar MP3 como entrada de substituição.
- **REQ-VID-AUD-005**: O sistema deve aceitar M4A/AAC como entrada de substituição.
- **REQ-VID-AUD-006**: O sistema deve rejeitar formatos de áudio de substituição não suportados antes de iniciar o processamento.
- **REQ-VID-AUD-007**: O sistema deve permitir selecionar um intervalo opcional do áudio de substituição.
- **REQ-VID-AUD-008**: O sistema deve cortar o áudio de substituição quando este ultrapassar a duração do vídeo.
- **REQ-VID-AUD-009**: O sistema deve deixar sem áudio o restante do vídeo quando o áudio de substituição for mais curto.
- **REQ-VID-AUD-010**: O sistema deve rejeitar a extração quando o vídeo não tiver uma faixa de áudio.
- **REQ-VID-AUD-011**: O sistema deve gerar áudio AAC num contentor M4A quando a extração for concluída.
- **REQ-VID-AUD-012**: O sistema deve guardar o resultado de cada operação de gestão de áudio como novo conteúdo na biblioteca do projeto.
- **REQ-VID-AUD-013**: O sistema deve apresentar a opção de substituir áudio.
- **REQ-VID-AUD-014**: O sistema deve apresentar a opção de extrair áudio.
- **REQ-VID-AUD-015**: O sistema deve guardar o resultado de áudio extraído como novo conteúdo na biblioteca do projeto.
- **REQ-VID-AUD-016**: O sistema deve guardar o resultado de vídeo sem áudio ou com áudio substituído como novo conteúdo na biblioteca do projeto.

### Cross-Cutting Requirements

As operações deste caso de uso também devem cumprir os requisitos transversais já definidos para UC-VID-001 a UC-VID-007, sem os duplicar:

- **Autorização e isolamento**: `REQ-VID-COM-001` a `REQ-VID-COM-003`, `REQ-VID-COM-013`, `REQ-VID-Q-005`, `REQ-VID-Q-010` a `REQ-VID-Q-012`.
- **Quota**: `REQ-VID-COM-004` a `REQ-VID-COM-008`, incluindo reserva para utilizadores registados, ausência de limite diário para premium e devolução em falha, cancelamento ou operação sem efeito.
- **Estado e comunicação**: `REQ-VID-COM-009` a `REQ-VID-COM-012`, `REQ-VID-COM-018` e `REQ-VID-COM-020`.
- **Limpeza e integridade**: `REQ-VID-COM-014` a `REQ-VID-COM-017`, `REQ-VID-Q-004`, `REQ-VID-Q-007`, `REQ-VID-Q-013` e `REQ-VID-Q-014`.
- **Qualidade**: `REQ-VID-Q-002`, `REQ-VID-Q-003` e `REQ-VID-Q-008`.

### Key Entities

- **Vídeo**: conteúdo audiovisual do projeto, com a faixa de áudio e metadados relevantes; permanece imutável durante a operação.
- **Ficheiro de áudio de substituição**: conteúdo fornecido pelo utilizador em MP3 ou M4A/AAC, podendo ser usado integralmente ou através de um intervalo selecionado.
- **Operação de gestão de áudio**: trabalho solicitado pelo utilizador, com tipo de operação, origem, projeto, estado, progresso, timestamps, quota e eventual erro.
- **Resultado de áudio ou vídeo**: novo conteúdo associado ao projeto após uma operação concluída; nunca substitui o conteúdo de origem.
- **Projeto**: contexto autorizado que reúne o vídeo de origem e os resultados disponibilizados ao utilizador.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% dos cenários de aceitação para remover, substituir e extrair áudio produzem o resultado esperado ou a rejeição especificada, sem alterar o vídeo original.
- **SC-002**: Cada operação assíncrona de gestão de áudio apresenta pelo menos uma atualização de estado observável ao utilizador autorizado.
- **SC-003**: Para uma operação que ultrapasse 5 segundos, o utilizador recebe pelo menos uma atualização de progresso, conforme `REQ-VID-Q-003`.
- **SC-004**: Em 100% dos testes de falha e cancelamento, não ficam resultados parciais acessíveis, os temporários são limpos e a quota reservada é devolvida.
- **SC-005**: 100% dos testes de acesso cruzado entre utilizadores ou projetos são rejeitados para o vídeo, metadados, resultados e eventos da operação.
- **SC-006**: Os utilizadores conseguem distinguir na biblioteca o original de cada resultado e concluir cada uma das três operações sem intervenção técnica.

## Assumptions

- O utilizador tem uma sessão válida e um projeto acessível antes de iniciar a operação.
- As regras de perfil, quota e estados assíncronos definidas nos requisitos comuns são reutilizadas; esta spec não cria limites adicionais.
- A camada de armazenamento existente consegue guardar vídeos e ficheiros M4A no mesmo projeto e remover objetos temporários.
- A análise do conteúdo consegue determinar se existe uma faixa de áudio antes da extração ou remoção.
- A operação considera a faixa de áudio aplicável do vídeo de origem; seleção de múltiplas faixas está fora do MVP, conforme as decisões do catálogo.
- O suporte a vídeo é uma extensão da baseline de imagens; as filas e o contrato de processamento de imagens continuam operacionais.
- A implementação pode ainda não cobrir este caso de uso no estado atual do repositório; qualquer requisito não implementado deve ser identificado no plano, nas tarefas e nos resultados de validação.

## Traceability and Validation

| Use-case element | Requirements | Planned validation evidence |
|---|---|---|
| UC-VID-007, steps 1-2 | `REQ-VID-AUD-001` to `REQ-VID-AUD-010`, `REQ-VID-AUD-013`, `REQ-VID-AUD-014` | Focused acceptance tests for options, authorization, input formats, intervals and no-audio handling |
| UC-VID-007, steps 3-5 | `REQ-VID-COM-004` to `REQ-VID-COM-013`, `REQ-VID-Q-002`, `REQ-VID-Q-003` | Operation-state, quota and authorized-progress tests |
| UC-VID-007, steps 6-9 | `REQ-VID-AUD-011`, `REQ-VID-AUD-012`, `REQ-VID-AUD-015`, `REQ-VID-AUD-016`, `REQ-VID-COM-018` | Output-content, codec/container, persistence and library tests |
| UC-VID-007, FA1-FA3 and exceptions | `REQ-VID-AUD-008` to `REQ-VID-AUD-010`, `REQ-VID-COM-007`, `REQ-VID-COM-008`, `REQ-VID-COM-014` to `REQ-VID-COM-017` | No-audio, duration mismatch, cancellation, failure, cleanup and original-integrity tests |

The implementation plan must map each requirement to an affected component and to a test identifier using the project conventions (`TST-AUD-*`), and must record the result rather than claiming validation without execution.

## Scope and Baseline Delta

This feature extends the existing PictuRAS video MVP and does not rewrite the image-processing baseline. The affected surfaces are the project operation flow, asynchronous video processing, authorized project events, storage of new results and the user-facing project library. The original video remains unchanged. Existing image-processing behavior is out of scope except for regression validation required by `REQ-VID-Q-006`.

The feature is derived from `UC-VID-007`, `REQ-VID-AUD-001` to `REQ-VID-AUD-016`, and the shared requirements listed above in `docs/RAS-requisitos-video.md` (baseline version v1.1, 2026-10-17). Multiple audio tracks, resume of interrupted operations, replacement/versioning of the original and advanced preview are explicitly outside the MVP.
