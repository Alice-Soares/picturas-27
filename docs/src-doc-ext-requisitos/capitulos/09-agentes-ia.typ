#import "../template.typ": *

= Implementação Assistida por Agentes de IA

#orientacao[
  Obrigatório (enunciado): documentar as ferramentas e _skills_ utilizadas, enumerar as tarefas apoiadas e comprovar a validação realizada — tanto na especificação como no código e nos testes. A equipa é responsável por todo o conteúdo entregue, incluindo o gerado por IA. Valoriza-se evidência concreta (_commits_, _pull requests_, ficheiros de configuração dos agentes) e reflexão crítica sobre os erros introduzidos pela IA e a forma como foram identificados e corrigidos.
]

== Ferramentas, modelos e configuração

Durante o desenvolvimento da extensão de vídeo, a equipa recorreu a agentes de Inteligência Artificial (IA) como ferramentas de apoio às diferentes atividades de engenharia de software, nomeadamente à análise de requisitos, elaboração de especificações, planeamento e organização das tarefas de implementação.

Para estruturar este processo, foi adotado o *GitHub Spec Kit*, integrado com o *GitHub Copilot*. Esta abordagem permitiu organizar o desenvolvimento por funcionalidade, mantendo uma relação explícita entre os requisitos, as decisões técnicas e as tarefas previstas.

A configuração dos agentes encontra-se distribuída pelos diretórios `.github/skills/` e `.specify/`, enquanto o ficheiro `AGENTS.md` estabelece as instruções gerais e as regras de utilização do contexto do projeto.

#tabela(
  colunas: (3.5cm, 1fr),
  [Ferramenta / modelo], [Configuração e utilização (_skills_, instruções de projeto, MCP, …)],

  [GitHub Copilot],
  [Agente de IA integrado no ambiente de desenvolvimento, configurado para apoiar o fluxo de trabalho do Spec Kit. As _skills_ disponíveis em `.github/skills/` fornecem instruções específicas para as atividades de especificação, clarificação, planeamento, decomposição de tarefas, análise e implementação.],

  [GitHub Spec Kit (`specify-cli`)],
  [Ferramenta utilizada para estruturar o processo de especificação e organizar os respetivos artefactos por funcionalidade. A configuração encontra-se em `.specify/`, estando o procedimento de instalação e inicialização documentado em `specs/README.md`.],

  [Instruções dos agentes (`AGENTS.md`)],
  [Ficheiro de configuração que define a hierarquia das fontes de informação, as regras de rastreabilidade dos requisitos e os cuidados a observar na geração e revisão de conteúdo.],

  [Outros agentes e modelos],
  [#preencher[Identificar outros agentes, modelos, versões e configurações efetivamente utilizados durante o projeto.]],
)

=== Organização do processo com Spec Kit

Embora o GitHub Spec Kit disponibilize um fluxo de trabalho que abrange desde a definição dos requisitos até à implementação, a sua utilização no projeto incidiu sobretudo na fase de desenvolvimento e implementação das funcionalidades da extensão de vídeo. O Spec Kit foi utilizado como uma ferramenta de desenvolvimento orientada por requisitos e casos de uso, com o objetivo de acelerar a implementação, manter a coerência com o comportamento esperado e reduzir a probabilidade de erros, interpretações incorretas ou respostas inventadas (alucinações) por parte dos agentes de IA.

A abordagem adotada teve por base os requisitos previamente definidos e documentados em artefactos Markdown (.md). Cada especificação foi associada a um caso de uso, permitindo delimitar o âmbito de cada funcionalidade e fornecer aos agentes um contexto concreto sobre o comportamento a implementar. Esta organização procurou evitar que os agentes recorressem a pressupostos não documentados ou introduzissem comportamentos incompatíveis com os requisitos estabelecidos.

O fluxo de trabalho disponibiliza um conjunto de comandos especializados para apoiar as diferentes etapas do desenvolvimento:

- `/speckit-constitution`: definição dos princípios e regras gerais do projeto;
- `/speckit-specify`: elaboração das especificações funcionais;
- `/speckit-clarify`: identificação e resolução de ambiguidades nos requisitos;
- `/speckit-plan`: definição da abordagem técnica e do plano de implementação;
- `/speckit-tasks`: decomposição do trabalho em tarefas concretas;
- `/speckit-analyze` e `/speckit-checklist`: apoio à análise de consistência e à verificação dos artefactos;
- `/speckit-implement`: implementação orientada pelas tarefas e pelos artefactos previamente definidos.

Neste projeto, o Spec Kit foi utilizado sobretudo para orientar a implementação com base nos requisitos e casos de uso previamente definidos, recorrendo às especificações, aos planos e às tarefas como contexto para os agentes de IA. Cada especificação corresponde a um caso de uso, permitindo delimitar o âmbito de cada funcionalidade e promover uma implementação mais rápida e consistente com o comportamento esperado.

Para além do apoio à implementação, o comando /speckit-analyze revelou-se útil na identificação de incoerências entre os artefactos de requisitos, permitindo detetar discrepâncias e orientar a sua correção antes de avançar com o desenvolvimento. Esta verificação contribuiu para melhorar a consistência das especificações e reduzir o risco de os agentes implementarem comportamentos contraditórios ou baseados em pressupostos incorretos.

Os documentos produzidos são organizados no diretório `specs/`, em formato Markdown, incluindo ficheiros como `spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`, `quickstart.md` e eventuais contratos em `contracts/`.

A utilização deste formato permitiu manter a informação de cada funcionalidade acessível tanto à equipa como aos agentes de IA. Em vez de depender exclusivamente do histórico das conversas, os agentes puderam utilizar documentos estruturados com requisitos, decisões, restrições e tarefas específicas.

Adicionalmente, a manutenção destes artefactos em Markdown facilitou a revisão manual, o controlo de versões através do Git e a identificação das alterações realizadas ao longo do desenvolvimento. Estes documentos constituem os artefactos de trabalho da especificação, sendo o relatório final produzido separadamente em Typst.

Apesar das vantagens desta abordagem, a utilização do Spec Kit não garante, por si só, a ausência de erros na implementação. A revisão humana, a confirmação da conformidade com os requisitos e a execução de testes continuam a ser essenciais para validar os resultados produzidos pelos agentes de IA.

=== Contexto e instruções fornecidos aos agentes

Para reduzir inconsistências na interpretação dos requisitos e orientar o comportamento dos agentes de IA, o projeto utiliza dois ficheiros principais de instruções: AGENTS.md e .specify/memory/constitution.md.

O ficheiro AGENTS.md estabelece a hierarquia das fontes de informação que devem orientar os agentes, privilegiando as diretrizes da Fase 1, o catálogo consolidado de requisitos e os casos de uso, seguindo-se o enunciado do projeto, a documentação geral, o código existente e os artefactos do Spec Kit.

Por sua vez, o ficheiro constitution.md define os princípios, as regras e as restrições gerais que devem orientar o trabalho realizado com o Spec Kit. Funciona como uma referência normativa para o GitHub Copilot durante o processo de desenvolvimento, devendo as suas instruções ser respeitadas ao longo da especificação e da implementação, de modo a manter a coerência com as regras estabelecidas para o projeto.

Em conjunto, estes ficheiros procuram assegurar que os agentes preservam os identificadores dos requisitos, distinguem decisões aprovadas de pressupostos e não introduzem funcionalidades, limites ou contratos sem fundamento nas fontes do projeto. Desta forma, o comportamento dos agentes é orientado por regras explícitas e por requisitos documentados, reduzindo o risco de interpretações incorretas e de soluções incompatíveis com o âmbito definido, mantendo-se a responsabilidade humana pela interpretação dos requisitos, aceitação das propostas e validação dos resultados.

== Tarefas apoiadas e validação

*TODO*: REVER ISTO

O apoio dos agentes de IA incidiu sobretudo na estruturação da informação e na preparação dos artefactos necessários ao desenvolvimento das funcionalidades de vídeo.

A tabela seguinte relaciona as ferramentas e _skills_ com as atividades apoiadas, os casos de uso abrangidos e as respetivas evidências. Os campos por completar destinam-se ao registo das verificações efetivamente realizadas pela equipa, de forma a distinguir a produção de artefactos da sua validação.

#tab([Tarefas apoiadas por agentes de IA e validação],
  tabela(
    colunas: (2.6cm, 2cm, 1fr, 1fr, 2.4cm),
    tamanho: 8.5pt,

    [Ferramenta / _skill_],
    [Caso de uso],
    [Tarefa apoiada],
    [Validação realizada pela equipa],
    [Evidência],

    [GitHub Copilot / `/speckit-specify`],
    [UC-VID-001 a UC-VID-007],
    [Estruturação das especificações funcionais a partir dos requisitos e casos de uso definidos para a extensão de vídeo.],
    [#preencher[Descrever a revisão das especificações, correções introduzidas e requisitos confirmados.]],
    [`specs/001-video-submission/`, `specs/002-video-trim/`, `specs/003-apply-tool-to-video-frame/`, `specs/004-video-conversion/`, `specs/005-extrair-fotogramas/`],

    [GitHub Copilot / `/speckit-clarify`, `/speckit-plan`, `/speckit-tasks`],
    [UC-VID-001 a UC-VID-007],
    [Apoio à identificação de ambiguidades, organização das decisões técnicas e decomposição das funcionalidades em tarefas de desenvolvimento.],
    [#preencher[Identificar as decisões revistas e os critérios utilizados para confirmar a consistência dos planos e tarefas.]],
    [Ficheiros `research.md`, `plan.md` e `tasks.md` em `specs/`; #preencher[commits relevantes]],

    [Agentes de IA na implementação],
    [#preencher[Casos de uso abrangidos]],
    [#preencher[Identificar as atividades concretas de geração ou revisão de código, depuração, documentação e testes.]],
    [#preencher[Indicar os testes executados, resultados obtidos e eventuais correções manuais.]],
    [#preencher[Commits, pull requests e ficheiros alterados]],

    [GitHub Copilot / `/speckit-analyze`, `/speckit-checklist`, `/speckit-implement`],
    [#preencher[Casos de uso abrangidos]],
    [#preencher[Indicar quais destes comandos foram efetivamente utilizados e com que finalidade.]],
    [#preencher[Descrever as verificações realizadas e os respetivos resultados.]],
    [#preencher[Relatórios, artefactos, commits ou evidências de testes]],
  ),
)

== Análise crítica

*NOTA*: REVER ISTO, ACRESCENTAR QUE ISTO AGILIZOU E DIMINUIU O TEMPO DE IMPLEMENTAÇÃO

A utilização de agentes de IA, em conjunto com o GitHub Spec Kit, contribuiu para a organização do processo de desenvolvimento, particularmente na estruturação dos requisitos e na preparação dos artefactos de especificação.

Uma das principais vantagens desta abordagem foi a possibilidade de disponibilizar aos agentes um contexto explícito e organizado por funcionalidade. A existência de documentos Markdown versionados permitiu manter as especificações, decisões e tarefas acessíveis e passíveis de revisão, reduzindo a dependência de instruções dispersas em conversas.

A definição de regras no ficheiro `AGENTS.md` constituiu igualmente uma medida importante para orientar o comportamento dos agentes. Em particular, a hierarquia das fontes de informação procurou limitar interpretações incorretas dos requisitos e evitar que características do código existente fossem automaticamente consideradas requisitos aprovados.

Contudo, a utilização destas ferramentas apresenta limitações. A produção automática de especificações e planos não garante a sua correção, completude ou conformidade com o enunciado. Da mesma forma, a existência de tarefas geradas não demonstra que estas tenham sido implementadas ou devidamente testadas.

Por esse motivo, a avaliação do contributo da IA deve considerar não apenas os artefactos produzidos, mas também a revisão efetuada pela equipa, as alterações introduzidas e os resultados das verificações realizadas.

#preencher[Acrescentar exemplos concretos de propostas úteis dos agentes, erros ou omissões identificados, métodos utilizados para os detetar e correções efetuadas. Sempre que possível, associar estes exemplos a commits, ficheiros ou resultados de testes.]

Em síntese, os agentes de IA foram utilizados como instrumentos de apoio ao processo de engenharia de software, e não como substitutos da análise e validação humana. A responsabilidade pela correção das especificações, pela qualidade do código e pela adequação dos testes permanece integralmente na equipa.

#preencher[Antes da entrega, completar as versões dos modelos utilizados, os comandos efetivamente executados, as evidências de revisão e os resultados de validação do código e dos testes.]
