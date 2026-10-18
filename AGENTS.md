# Guia para agentes no PictuRAS

Este ficheiro define o contexto mínimo que os agentes devem carregar antes de
alterar o projeto. As decisões humanas continuam a prevalecer sobre qualquer
inferência do modelo.

## Objetivo e contexto

O PictuRAS é uma aplicação web de processamento de imagens organizada como
microserviços. A extensão em curso acrescenta suporte MVP para vídeo. O fluxo
de trabalho de requisitos usa o GitHub Spec Kit e mantém os artefactos de
especificação em [`specs/`](./specs/).

## Fontes de verdade e precedência

Consultar as fontes nesta ordem:

1. [`docs/diretrizes_fase_1.md`](./docs/diretrizes_fase_1.md): âmbito da Fase 1,
   estrutura do relatório, convenções, entregáveis e checklist de aceitação.
2. [`docs/RAS-requisitos-video.md`](./docs/RAS-requisitos-video.md): catálogo
   consolidado e baseline atual dos requisitos de vídeo.
3. [`docs/use-cases/`](./docs/use-cases/): comportamento esperado, fluxos,
   exceções e regras de negócio dos sete casos de uso de vídeo.
4. [`docs/Enunciado.md`](./docs/Enunciado.md): âmbito académico, fases e
   restrições da entrega.
5. [`README.md`](./README.md): arquitetura implementada, serviços, comandos e
   limites operacionais.
6. Código, testes e configuração existentes: comportamento efetivamente
   implementado. Devem ser tratados como evidência do estado atual, não como
   autorização para alterar requisitos.
7. [`specs/`](./specs/): especificações aprovadas e decisões do trabalho.
8. [`/.specify/memory/constitution.md`](./.specify/memory/constitution.md):
   constituição e governança do processo Spec Kit. Atualmente contém apenas o
   template com placeholders; esses placeholders não são requisitos nem regras
   ratificadas até a constituição ser preenchida e aprovada.

Em caso de conflito, aplicar a diretriz ou decisão ratificada mais específica,
registar a discrepância e pedir decisão quando necessário. Não transformar um
requisito em comportamento apenas porque ele existe no código.

## Princípios da Fase 1

- **Extensão, não reescrita:** preservar a solução disponibilizada e descrever
  apenas o delta de vídeo. Quando um comportamento da baseline mudar, referir
  explicitamente os IDs afetados (`UCnn`, `RFnn`, `RNFnn`).
- **MVP funcional:** priorizar a validação funcional do suporte a vídeo. Os
  requisitos não funcionais devem ser especificados, mas não é obrigatório
  atingir nesta fase o nível de produção.
- **Qualidade sobre quantidade:** escolher funcionalidades com complexidade
  adequada; operações triviais isoladas não constituem uma extensão suficiente.
- **Responsabilidade pela IA:** documentar ferramentas, modelos, skills,
  instruções, tarefas apoiadas, validação e evidências. A equipa é responsável
  por rever, testar e justificar todo o conteúdo entregue.
- **Rastreabilidade ponta a ponta:** fechar sempre o ciclo
  `caso de uso -> requisito -> componente -> teste -> resultado`.
- Requisitos comuns a várias funcionalidades devem ser especificados uma só
  vez, com todas as origens, e não duplicados.
- Funcionalidades especificadas mas não implementadas devem indicar claramente
  esse estado.

## Convenções obrigatórias de identificação

- `UC-VID-nnn`: caso de uso de vídeo, com numeração única a partir de
  `UC-VID-001`.
- `REQ-VID-{FUNC}-nnn`: requisito de vídeo. Um ID nunca é reutilizado, mesmo
  que o requisito seja removido.
- `FAk`, `RNK`, `Ak`, `Qk`: fluxo alternativo, regra, assunção e questão locais
  ao caso de uso; em tabelas partilhadas usar a forma qualificada, como
  `UC-VID-001/RN2`.
- `RNG-nn`, `DQ-nnn`, `DA-nn`, `TST-{FUNC}-nn` e `T-nn`: regra transversal,
  decisão de qualidade, decisão arquitetural, teste e tarefa de manutenção.
- `UCnn`, `RFnn` e `RNFnn`: elementos da documentação de requisitos da
  baseline, citados quando são alterados.

Os requisitos devem ser atómicos, verificáveis e escritos no padrão
“O sistema deve...”. Os requisitos não funcionais devem ser classificados
segundo a ISO/IEC 25010. Cada critério de aceitação deve usar
`Dado... Quando... Então...`.

## Regras de modelação e arquitetura

- O modelo de domínio representa conceitos do problema, não classes, tabelas
  nem microserviços; usar a terminologia dos casos de uso e requisitos.
- Atualizar o modelo de domínio para responder à relação entre vídeo, imagem,
  projeto e trabalho de processamento, incluindo estado, resultado, duração,
  resolução e formato quando forem relevantes.
- O diagrama de casos de uso deve incluir todos os `UC-VID-nnn`, distingui-los
  visualmente e associá-los coerentemente aos perfis autorizados.
- Decisões sobre perfis, quotas e limites de vídeo são transversais: registar
  como `RNG-nn` e aplicar de forma consistente em todas as funcionalidades.
- Descrever apenas alterações arquiteturais face à baseline, ligando componentes
  e decisões (`DA-nn`) aos requisitos.

## Conteúdo e verificação da entrega

O relatório deve cobrir, no mínimo, visão transversal, casos de uso, ERS,
impacto na baseline, rastreabilidade, alterações arquiteturais, utilização de
IA, testes do MVP e limitações conhecidas. Antes de considerar uma
funcionalidade concluída, confirmar:

- casos de uso, modelo de domínio e diagramas atualizados;
- ausência de requisitos órfãos ou elementos de casos de uso sem cobertura;
- conflitos entre funcionalidades resolvidos;
- cada requisito implementado ligado a pelo menos um teste e resultado;
- instruções de execução da solução e testes disponíveis;
- evidência de uso e validação de agentes de IA registada;
- funcionalidades não implementadas marcadas como tal.

Os entregáveis da Fase 1 incluem o relatório PDF e fonte editável, a solução
MVP, evidências de uso de IA, instruções de execução/testes e `grupo.csv`
conforme as diretrizes. O template Typst é opcional; não assumir Typst como
dependência obrigatória.

## Regras para o contexto do LLM

- Ler primeiro este ficheiro e apenas os documentos relevantes para a tarefa;
  não carregar PDFs ou toda a árvore do repositório sem necessidade.
- Preservar os IDs dos requisitos (`REQ-VID-*`), casos de uso (`UC-VID-*`) e
  rastreabilidade entre requisito, especificação, plano, tarefas e testes.
- Não reutilizar IDs removidos e não duplicar requisitos transversais.
- Separar claramente factos observados, decisões aprovadas, assunções e
  questões em aberto. Usar `[NEEDS CLARIFICATION: ...]` quando uma decisão
  material não tiver fonte ou default seguro.
- Dar origem identificável a valores numéricos e regras de negócio; não
  inventar limites de tamanho, duração, resolução, FPS ou quotas.
- Não inventar endpoints, limites, codecs, estados, formatos ou regras de
  autenticação. Confirmar sempre nos documentos ou no código.
- Não substituir silenciosamente diagramas ou artefactos da baseline: destacar
  o delta e explicar o impacto.
- Reutilizar contratos, nomes, padrões de erro, autenticação e observabilidade
  já existentes; mudanças de comportamento devem ser explícitas na spec.
- Manter o escopo MVP da fase atual. Melhorias de produção ou requisitos não
  funcionais só entram quando forem pedidos e documentados.
- Cada alteração deve indicar como será validada. Preferir testes focados e
  comandos já documentados no README; não afirmar que algo foi validado sem
  executar a validação correspondente.
- Nunca incluir segredos, tokens, ficheiros `.env`, dados pessoais ou credenciais
  em specs, prompts, logs ou commits.
- Antes de editar, verificar o estado do Git e preservar alterações que não
  pertençam à tarefa.
- Registar a baseline usada (documentos e commit de partida) quando preparar
  uma especificação ou relatório da Fase 1.

## Fluxo Spec Kit

Usar os skills instalados em [`.github/skills/`](./.github/skills/):

1. `/speckit-constitution` para estabelecer ou atualizar princípios.
2. `/speckit-specify` para criar uma especificação numa nova pasta `specs/`.
3. `/speckit-clarify` quando existirem ambiguidades relevantes.
4. `/speckit-plan` para desenhar a implementação.
5. `/speckit-tasks` para decompor o plano em tarefas.
6. `/speckit-analyze` e `/speckit-checklist` para verificações opcionais.
7. `/speckit-implement` apenas depois de a spec, o plano e as tarefas estarem
   revistos.

Não editar manualmente artefactos gerados pelo fluxo para contornar uma
validação. Se uma decisão mudar, atualizar a fonte correspondente e regenerar
os artefactos dependentes.
