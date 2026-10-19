# Especificação: Submissão de vídeo

**Feature Branch**: `001-video-submission`

**Created**: 2026-10-19

**Status**: Draft

**Input**: `UC-VID-001 — Submeter Vídeo para Processamento`, com os requisitos `REQ-VID-SUB-*` do catálogo consolidado de vídeo.

## Enquadramento e âmbito

Esta funcionalidade implementa o caso de uso `UC-VID-001`. Permite que um
utilizador registado ou premium autenticado carregue um vídeo para um projeto,
que o sistema valide o conteúdo e os limites aplicáveis, extraia os metadados
e torne o vídeo disponível para operações posteriores.

O âmbito termina quando o vídeo validado está associado ao projeto. Recorte,
conversão, extração de fotogramas, concatenação e gestão de áudio pertencem
respetivamente aos casos `UC-VID-002` a `UC-VID-007` e não fazem parte desta
especificação.

**Fontes de verdade consultadas**:

- [UC-VID-001 — Submeter Vídeo para Processamento](../../docs/use-cases/UC-VID-001-submeter-video.md)
- [RAS — requisitos de vídeo](../../docs/RAS-requisitos-video.md)
- [Diretrizes da Fase 1](../../docs/diretrizes_fase_1.md)
- Baseline do repositório: commit `719c092bc4f8d74be46134c5e8e041060b1a456f`
  da branch `main`.

## User Scenarios & Testing

### User Story 1 — Submeter um vídeo válido (Priority: P1)

Como utilizador registado ou premium autenticado, quero selecionar um vídeo,
associá-lo a um projeto e guardá-lo na biblioteca para o poder processar
posteriormente.

**Why this priority**: Sem um vídeo validado e associado a um projeto, nenhum
dos restantes casos de uso de vídeo pode ser executado.

**Independent Test**: Submeter um MP4 compatível dentro dos limites do perfil e
confirmar que o vídeo, os metadados e a associação ao projeto aparecem na
biblioteca, sem alteração da quota de operações avançadas.

**Acceptance Scenarios**:

1. **Given** uma sessão válida de um utilizador registado ou premium, um projeto
   autorizado e um MP4 com vídeo H.264 e, se existir áudio, AAC, **When** o
   utilizador confirma a submissão, **Then** o sistema valida o ficheiro,
   extrai os metadados, guarda o objeto e cria a referência no projeto.
2. **Given** uma submissão válida concluída, **When** o utilizador consulta a
   biblioteca do projeto, **Then** o vídeo está disponível para visualização e
   processamento posterior, com utilizador, projeto e metadados associados.
3. **Given** uma submissão válida, **When** a quota diária de operações
   avançadas é consultada antes e depois da submissão, **Then** a quota mantém
   o mesmo valor.

### User Story 2 — Rejeitar acesso ou conteúdo inválido (Priority: P1)

Como proprietário do sistema, quero impedir submissões não autorizadas ou
incompatíveis para que a biblioteca não contenha vídeos ilegíveis ou fora dos
limites do perfil.

**Why this priority**: A autorização e a validação antes da persistência são
condições de segurança e consistência do conteúdo.

**Independent Test**: Tentar submeter sem sessão, com sessão inválida, com
perfil anónimo, com formato/codec inválido e com cada limite excedido;
confirmar a rejeição, a mensagem segura e a ausência de referência persistente.

**Acceptance Scenarios**:

1. **Given** um utilizador anónimo ou uma sessão inválida, **When** tenta
   submeter um vídeo, **Then** a operação é rejeitada sem criar objeto,
   referência ou consumo de quota.
2. **Given** um vídeo sem faixa de vídeo legível, com contentor diferente de
   MP4, codec de vídeo diferente de H.264 ou áudio incompatível, **When** é
   submetido, **Then** a operação é rejeitada com indicação da condição
   inválida e sem persistência parcial.
3. **Given** um utilizador registado, **When** submete um vídeo acima de
   100 MB, 5 minutos, 1920x1080 ou 60 fps, **Then** o sistema rejeita o vídeo
   antes de o associar ao projeto.
4. **Given** um utilizador premium, **When** submete um vídeo acima de 1 GB,
   30 minutos, 3840x2160 ou 60 fps, **Then** o sistema rejeita o vídeo antes
   de o associar ao projeto.

### User Story 3 — Cancelar ou recuperar de uma falha (Priority: P1)

Como utilizador, quero cancelar uma transferência ou receber um erro claro
quando uma dependência falha, sem que fiquem ficheiros parciais ou referências
inconsistentes no projeto.

**Why this priority**: A limpeza é necessária para preservar a consistência
entre o armazenamento e a biblioteca.

**Independent Test**: Cancelar uma transferência e provocar falhas de rede,
armazenamento e validação; verificar que temporários são removidos, que não há
referências persistentes e que a mensagem não expõe detalhes internos.

**Acceptance Scenarios**:

1. **Given** uma transferência em curso, **When** o utilizador a cancela,
   **Then** a transferência é interrompida, o objeto temporário é removido e
   não é criada referência no projeto.
2. **Given** uma falha de rede ou indisponibilidade do armazenamento, **When**
   a submissão falha, **Then** o sistema informa a condição, remove qualquer
   temporário criado e não cria o registo do vídeo.
3. **Given** uma seleção de vários vídeos, **When** alguns elementos são
   inválidos, **Then** cada elemento é validado individualmente e apenas os
   válidos são associados ao projeto.

### Edge Cases

- Um nome igual ao de um vídeo existente deve permitir escolher manter ambos ou
  cancelar (`FA1`). No MVP, a opção substituir fica fora de âmbito para
  preservar a imutabilidade do original.
- Um lote pode conter simultaneamente elementos válidos e inválidos; a falha
  de um elemento não deve criar referências para os elementos inválidos.
- O cancelamento pode ocorrer durante a transferência ou depois de o objeto
  temporário ter sido criado; ambos os caminhos devem terminar sem objeto
  parcial associado.
- Valores exatamente iguais aos limites do perfil são válidos; valores acima
  de qualquer limite são rejeitados.
- Um ficheiro com extensão aparentemente válida mas conteúdo incompatível deve
  ser rejeitado pela validação do conteúdo, não apenas pela extensão.
- O nome original não é identificador persistente do conteúdo; nomes
  duplicados devem ser tratados pela regra `FA1`.
- A retoma de transferências interrompidas não pertence ao MVP.
- Miniaturas automáticas, drag-and-drop e um limite de uploads simultâneos não
  são requisitos desta primeira implementação; podem ser avaliados numa
  revisão posterior do caso de uso.
- Em uploads em lote, cada vídeo tem resultado independente (`concluída`,
  `rejeitada`, `cancelada` ou `falhada`); um resultado não altera os restantes.

## Requirements

### Functional Requirements

Os requisitos abaixo preservam o catálogo oficial e são escritos como
capacidades verificáveis do sistema.

- **REQ-VID-SUB-001**: O sistema deve permitir a submissão apenas a utilizadores registados ou premium com sessão válida.
- **REQ-VID-SUB-002**: O sistema deve rejeitar submissões de utilizadores anónimos.
- **REQ-VID-SUB-003**: O sistema deve rejeitar submissões com sessão inválida.
- **REQ-VID-SUB-004**: O sistema deve iniciar a validação do ficheiro antes de o associar ao projeto.
- **REQ-VID-SUB-005**: O sistema deve aceitar o contentor MP4 no MVP.
- **REQ-VID-SUB-006**: O sistema deve aceitar vídeo codificado com H.264 no MVP.
- **REQ-VID-SUB-007**: O sistema deve aceitar áudio AAC quando o vídeo tiver faixa sonora.
- **REQ-VID-SUB-008**: O sistema deve rejeitar contentores de vídeo não suportados.
- **REQ-VID-SUB-009**: O sistema deve validar que o ficheiro contém uma faixa de vídeo legível.
- **REQ-VID-SUB-010**: O sistema deve calcular o tamanho do ficheiro antes de o associar ao projeto.
- **REQ-VID-SUB-011**: O sistema deve extrair a duração antes de associar o vídeo ao projeto.
- **REQ-VID-SUB-012**: O sistema deve extrair o codec antes de associar o vídeo ao projeto.
- **REQ-VID-SUB-013**: O sistema deve extrair a resolução antes de associar o vídeo ao projeto.
- **REQ-VID-SUB-014**: O sistema deve extrair a taxa de fotogramas antes de associar o vídeo ao projeto.
- **REQ-VID-SUB-015**: O sistema deve criar a referência de vídeo apenas depois de todas as validações passarem.
- **REQ-VID-SUB-016**: O sistema deve rejeitar vídeos superiores a 100 MB para utilizadores registados não premium.
- **REQ-VID-SUB-017**: O sistema deve rejeitar vídeos superiores a 5 minutos para utilizadores registados não premium.
- **REQ-VID-SUB-018**: O sistema deve rejeitar vídeos cuja largura exceda 1920 ou cuja altura exceda 1080 para utilizadores registados não premium.
- **REQ-VID-SUB-019**: O sistema deve rejeitar vídeos acima de 60 fps para utilizadores registados não premium.
- **REQ-VID-SUB-020**: O sistema deve rejeitar vídeos superiores a 1 GB para utilizadores premium.
- **REQ-VID-SUB-021**: O sistema deve rejeitar vídeos superiores a 30 minutos para utilizadores premium.
- **REQ-VID-SUB-022**: O sistema deve rejeitar vídeos cuja largura exceda 3840 ou cuja altura exceda 2160 para utilizadores premium.
- **REQ-VID-SUB-023**: O sistema deve rejeitar vídeos acima de 60 fps para utilizadores premium.
- **REQ-VID-SUB-024**: O sistema deve remover temporários e não criar referências persistentes quando a submissão for rejeitada, cancelada ou falhar.
- **REQ-VID-SUB-025**: O sistema não deve contabilizar a submissão na quota diária de operações avançadas.
- **REQ-VID-SUB-026**: O sistema deve associar a referência ao utilizador que efetuou a submissão.
- **REQ-VID-SUB-027**: O sistema deve associar a referência ao projeto selecionado.
- **REQ-VID-SUB-028**: O sistema deve associar à referência os metadados extraídos.
- **REQ-VID-SUB-029**: O sistema deve associar à referência o objeto armazenado no estágio persistente `video-src`.
- **REQ-VID-SUB-030**: O sistema deve devolver um resultado independente para cada vídeo de um lote.
- **REQ-VID-SUB-031**: O sistema deve permitir manter ambos ou cancelar perante um duplicado, sem substituir o original no MVP.
- **REQ-VID-SUB-032**: O sistema deve aplicar os limites de tamanho usando unidades decimais.
- **REQ-VID-SUB-033**: O sistema deve receber o vídeo completo em ficheiro temporário em disco, sem o manter completo em memória durante a submissão.

### Quality Requirements

- **REQ-VID-Q-001** *(Fiabilidade)*: O sistema deve aceitar 100% das combinações válidas cobertas pelos testes de aceitação.
- **REQ-VID-Q-004** *(Fiabilidade)*: O sistema deve manter o conteúdo original íntegro durante a submissão e a limpeza, verificável por hash SHA-256.
- **REQ-VID-Q-005** *(Segurança)*: O sistema deve aplicar autorização aos recursos de vídeo, impedindo acesso cruzado entre projetos.
- **REQ-VID-Q-007** *(Manutenibilidade)*: O sistema deve limpar objetos temporários após uma submissão concluída ou terminada por falha/cancelamento.
- **REQ-VID-Q-008** *(Usabilidade e segurança)*: O sistema deve apresentar mensagens que identifiquem a condição rejeitada sem expor detalhes internos.

### Decisões técnicas fechadas

- **DA-02 / RNG-09**: O analisador FFmpeg/FFprobe será instalado no container
  do Projects Service e executado pelo backend; a imagem Docker deve expor a
  versão instalada no processo de validação.
- **DA-03 / RNG-10**: O upload será recebido num ficheiro temporário em disco,
  com limite de corpo aplicado antes do processamento. O sistema não deve
  manter o vídeo completo em memória; o limite funcional continua a ser o
  definido por `RN2` e `RN3`.
- **DA-04 / RNG-11**: O objeto original validado usará o estágio persistente
  `video-src`. Cada item de um lote terá resultado independente e identificável.
- **DA-05 / RNG-12**: Uma resolução é inválida quando a largura **ou** a
  altura excede o máximo do perfil. Os limites `MB` e `GB` são decimais:
  `1 MB = 1 000 000` bytes e `1 GB = 1 000 000 000` bytes.
- **DA-06 / RNG-13**: No MVP, um nome duplicado permite manter ambos ou
  cancelar. A substituição não será implementada, porque alteraria ou
  invalidaria a referência original imutável.

### Baseline impact

- **Autenticação e perfis — Estender/alterar**: reutilizar a sessão e os perfis existentes e acrescentar a regra de que anónimos não submetem vídeo.
- **Image Storage Service / SeaweedFS — Estender**: reutilizar a fachada de armazenamento com content-type, convenção de objeto temporário e limpeza para vídeo.
- **Projects Service e projeto — Estender**: adicionar referência de vídeo e metadados sem quebrar referências de imagem.
- **API Gateway e frontend da biblioteca — Estender**: apresentar seleção, progresso da transferência, validação, estado e erro.
- **FFmpeg/FFprobe ou equivalente — Novo componente de capacidade**: validar streams e extrair metadados do vídeo.
- **Quota de operações avançadas — Manter para este caso de uso**: a submissão não consome quota; a política continua aplicável a operações posteriores.

## Key Entities

- **Vídeo**: conteúdo multimédia submetido, com contentor, codec, duração,
  resolução, taxa de fotogramas, tamanho e eventual faixa de áudio.
- **Referência de vídeo**: associação persistente entre o vídeo armazenado, o
  utilizador, o projeto e o estágio do conteúdo.
- **Projeto**: espaço autorizado ao qual o vídeo é associado.
- **Submissão**: transferência temporária e validação que antecedem a criação
  da referência persistente; pode ser concluída, rejeitada, cancelada ou
  falhar.
- **Utilizador**: ator autenticado com perfil registado ou premium, sujeito às
  regras de acesso e limites correspondentes.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% dos testes de aceitação de submissões válidas criam uma
  referência associada ao utilizador e ao projeto corretos.
- **SC-002**: 100% dos testes de conteúdo inválido, perfil não autorizado e
  limite excedido terminam sem referência persistente nem objeto parcial.
- **SC-003**: 100% dos metadados persistidos nos testes válidos correspondem ao
  conteúdo analisado: tamanho, duração, codec, resolução e taxa de fotogramas.
- **SC-004**: 100% dos testes de cancelamento e falha deixam o armazenamento
  sem temporários acessíveis e a biblioteca sem conteúdo parcial.
- **SC-005**: 100% dos testes de autorização impedem que um utilizador consulte
  ou transfira vídeo associado a outro projeto.
- **SC-006**: 100% dos testes confirmam que a submissão, por si só, não reduz a
  quota diária de operações avançadas.
- **SC-007**: Pelo menos 90% dos utilizadores de teste conseguem concluir uma
  submissão válida na primeira tentativa quando fornecem um ficheiro
  compatível e um projeto autorizado.

## Assumptions

- Os utilizadores registados e premium usam a autenticação e autorização
  existentes; anónimos continuam limitados às funcionalidades de imagem
  previstas na baseline.
- Os limites funcionais são os definidos em `UC-VID-001`: registado até
  100 MB, 5 minutos, largura 1920, altura 1080 e 60 fps; premium até 1 GB,
  30 minutos, largura 3840, altura 2160 e 60 fps. Qualquer dimensão acima do
  limite rejeita o vídeo.
- Os valores dos limites são decisões já registadas em `RN2` e `RN3`; não são
  inferidos da implementação.
- O MVP aceita MP4, vídeo H.264 e áudio AAC quando exista faixa sonora.
- O armazenamento de objetos, o serviço de projetos e o projeto selecionado
  estão disponíveis durante o fluxo normal.
- A fachada S3/SeaweedFS existente será estendida, sem substituir o fluxo de
  imagens.
- A análise de vídeo disponibiliza as informações necessárias para validar
  streams e extrair metadados; FFmpeg/FFprobe será disponibilizado no
  Projects   Service conforme `DA-02`.
- A submissão em lote valida cada item de forma independente.
- Cada upload em lote é uma requisição independente ou uma operação que devolve
  resultados individuais por vídeo.
- O temporário é criado em disco e removido em todos os estados terminados sem
  sucesso; o vídeo completo não é mantido em memória.
- O estágio persistente do original é `video-src`.
- A comparação de resolução e tamanho segue `RNG-004`.

## Out of Scope

- Operações de processamento posteriores à submissão (`UC-VID-002` a
  `UC-VID-007`).
- Retoma de uploads interrompidos.
- Limite funcional adicional para uploads simultâneos.
- Geração automática de miniaturas.
- Drag-and-drop como requisito de interação.
- Alteração do contrato ou regressão do processamento existente de imagens.

## Traceability

| Elemento do `UC-VID-001` | Requisitos |
|---|---|
| Pré-condições, passos 1-3 | `REQ-VID-SUB-001` a `REQ-VID-SUB-004`, `REQ-VID-SUB-025` |
| Passos 4-8 | `REQ-VID-SUB-005` a `REQ-VID-SUB-014`, `REQ-VID-SUB-016` a `REQ-VID-SUB-023`, `REQ-VID-SUB-032`, `REQ-VID-SUB-033` |
| Passos 9-11 e pós-condição de sucesso | `REQ-VID-SUB-015`, `REQ-VID-SUB-026` a `REQ-VID-SUB-029`, `REQ-VID-Q-001`, `REQ-VID-Q-004` |
| `FA1` — upload duplicado | `REQ-VID-SUB-015`, `REQ-VID-SUB-026` a `REQ-VID-SUB-029`, `REQ-VID-SUB-031`, `REQ-VID-Q-004` |
| `FA2` — upload em lote | `REQ-VID-SUB-004`, `REQ-VID-SUB-015`, `REQ-VID-SUB-024`, `REQ-VID-SUB-030` |
| `FA3` — cancelamento | `REQ-VID-SUB-024`, `REQ-VID-Q-007` |
| `FA4` — perfil anónimo | `REQ-VID-SUB-001` a `REQ-VID-SUB-003`, `REQ-VID-SUB-024`, `REQ-VID-Q-008` |
| Exceções e garantia mínima | `REQ-VID-SUB-008`, `REQ-VID-SUB-009`, `REQ-VID-SUB-015`, `REQ-VID-SUB-024`, `REQ-VID-Q-004`, `REQ-VID-Q-007`, `REQ-VID-Q-008` |
