#import "../template.typ": *

= Implementação Assistida por Agentes de IA

#orientacao[
  Obrigatório (enunciado): documentar as ferramentas e _skills_ utilizadas, enumerar as tarefas apoiadas e comprovar a validação realizada — tanto na especificação como no código e nos testes. A equipa é responsável por todo o conteúdo entregue, incluindo o gerado por IA. Valoriza-se evidência concreta (_commits_, _pull requests_, ficheiros de configuração dos agentes) e reflexão crítica sobre os erros introduzidos pela IA e a forma como foram identificados e corrigidos.
]

== Ferramentas, modelos e configuração


Durante o desenvolvimento da extensão de vídeo, a equipa recorreu a agentes de Inteligência Artificial (IA) como ferramentas de apoio às diferentes atividades de engenharia de software, nomeadamente à análise de requisitos, elaboração de especificações, planeamento e organização das tarefas de implementação.

Para estruturar este processo, foi adotado o *GitHub Spec Kit*, integrado com o *GitHub Copilot*. Esta abordagem permitiu organizar o desenvolvimento por funcionalidade, mantendo uma relação explícita entre os requisitos, as decisões técnicas e as tarefas previstas.

A configuração dos agentes encontra-se distribuída pelos diretórios `.github/skills/` e `.specify/`, enquanto o ficheiro `AGENTS.md` estabelece as instruções gerais e as regras de utilização do contexto do projeto.

*TODO*: ACRESCENTAR QUE foi ainda utilizado o ChatGPT CODEX em apoio à implementação, depuração, resolução de conflitos de integração,
organização dos testes e preparação da documentação.



#tabela(
  colunas: (3.5cm, 1fr),
  [Ferramenta / modelo], [Configuração e utilização (_skills_, instruções de projeto, MCP, …)],

  [GitHub Copilot],
  [Agente de IA integrado no ambiente de desenvolvimento, configurado para apoiar o fluxo de trabalho do Spec Kit. As _skills_ disponíveis em `.github/skills/` fornecem instruções específicas para as atividades de especificação, clarificação, planeamento, decomposição de tarefas, análise e implementação.],

  [GitHub Spec Kit (`specify-cli`)],
  [Ferramenta utilizada para estruturar o processo de especificação e organizar os respetivos artefactos por funcionalidade. A configuração encontra-se em `.specify/`, estando o procedimento de instalação e inicialização documentado em `specs/README.md`.],

  [Instruções dos agentes (`AGENTS.md`)],
  [Ficheiro de configuração que define a hierarquia das fontes de informação, as regras de rastreabilidade dos requisitos e os cuidados a observar na geração e revisão de conteúdo.],

  [ChatGPT (UC-VID-006)], [Apoio iterativo ao desenvolvimento dos módulos, testes, integrações e conflitos de código , Commits `44f3d37` e `5c4fc9c` na branch de integração; ficheiros `videoMerge*.test.js`],

  [Outros agentes e modelos],
  [#preencher[Identificar outros agentes, modelos, versões e configurações efetivamente utilizados durante o projeto.]],
)

#tab([Ferramentas de IA e evidência material],
  tabela(
    colunas: (3cm, 1fr, 3.6cm),
    [Ferramenta], [Finalidade documentada], [Evidência verificável],
    [GitHub Copilot / Spec Kit], [Apoio à especificação, tarefas, pesquisa e planeamento dos casos de uso.], [`AGENTS.md`, `.specify/` e diretórios `specs/`],
    [ChatGPT (UC-VID-006)], [Apoio iterativo ao desenvolvimento dos módulos, testes, integrações e conflitos de código.], [Commits `44f3d37` e `5c4fc9c` na branch de integração; ficheiros `videoMerge*.test.js`],
    [Revisão humana], [Revisão do código, integração em base atualizada, execução dos testes e correção de falhas.], [Registos de testes em Docker e alterações aos ficheiros da operação.],
  ),
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

== Contexto e processo de trabalho

*TODO*: ESCREVER O QUE ESTA NESTA SECÇÃO Contexto e processo de trabalho INTEGRADA NAS ANTERIORES

As instruções do repositório definem uma hierarquia de fontes: enunciado, diretrizes da Fase 1,
requisitos consolidados, casos de uso e implementação existente. A especificação deve anteceder a
alteração de código e as sugestões dos agentes não substituem a validação humana dos contratos,
requisitos nem permissões.

O desenvolvimento da UC-VID-006 foi incremental: começou pela validação de regras por perfil, passou
pelo processamento FFmpeg, serviços e armazenamento e integrou depois RabbitMQ, rotas do API Gateway,
modelo de operação e diálogo no frontend. A alteração foi reaplicada à base de código do grupo por dois
commits específicos da funcionalidade, evitando importar por engano ficheiros pertencentes a colegas.

== Tarefas apoiadas e validação

*TODO*: REVER ISTO, PREENCHER A TABELA

#tab([Tarefas apoiadas por agentes de IA e validação],
  tabela(
    colunas: (2.6cm, 2cm, 1fr, 1fr, 2.4cm),
    tamanho: 8.5pt,

    [Ferramenta / _skill_],
    [Caso de uso],
    [Tarefa apoiada],
    [Validação realizada pela equipa],
    [Evidência],
  ))

*TODO*: USAR ISTO PARA METER NA TABELA ACIMA MAS USANDO O FORMATO DE TABELA DE CIMA

#tab([Relação entre apoio da IA, revisão e evidências],
  tabela(
    colunas: (2.2cm, 1fr, 1fr, 3.2cm),
    tamanho: 8.5pt,
    [Âmbito], [Tarefa apoiada], [Validação humana realizada], [Evidência],
    [Especificação e plano], [Estruturação de requisitos e divisão de funcionalidades em tarefas.], [Conferência com os requisitos, casos de uso e diretrizes; os artefactos gerados não provam execução.], [`specs/`, `AGENTS.md`, `RAS-requisitos-video.md`],
    [UC-VID-006 / backend], [Validação, pipeline FFmpeg, integração com storage, fila e modelo de operação.], [Testes unitários, de contrato e integração, incluindo FFmpeg real no contentor.], [65 testes do Projects Service aprovados em Docker],
    [UC-VID-006 / gateway], [Encaminhamento, autenticação e autorização por projeto.], [Testes de identidade, preservação da ordem e tratamento de erros.], [3 testes do API Gateway aprovados em Docker],
    [Integração entre UC], [Resolução de conflitos entre funcionalidades de áudio e concatenação.], [Verificação das permissões do modelo, restabelecimento de rota e testes após cherry-pick.], [Commits `44f3d37`, `5c4fc9c` e `videoMergeModelSchemaAlice.test.js`],
    [Frontend], [Diálogo de concatenação, chamadas API e consulta do estado.], [Build Docker sem erros; testes de contrato do frontend realizados em versão anterior.], [Build de `frontend` bem-sucedido; seis testes anteriores],
  ),
)

Não se afirma que todos os comandos do Spec Kit tenham sido efetivamente executados, nem se atribui
aos agentes a autoria integral do código. A descrição anterior identifica os usos para os quais existem
artefactos ou resultados conhecidos; os restantes elementos da equipa devem confirmar os seus próprios
procedimentos e ferramentas.

== Análise crítica

*TODO*: REVER ISTO 

O apoio da IA permitiu acelerar a organização e a implementação incremental, mas produziu propostas que
necessitaram de revisão. Um exemplo concreto ocorreu na integração da UC-VID-006 com a versão do grupo:
o modelo `videoOperation.js` e uma rota do gateway não ficaram inicialmente integrados de modo completo.
A análise dos ficheiros alterados e dos testes de modelo/gateway permitiu detetar a omissão, corrigir os
contratos e preservar em simultâneo a funcionalidade de áudio de outro elemento.

Outro risco foi a importação de alterações alheias ao âmbito da tarefa. Para reduzir esse risco, foram
selecionados os commits específicos da UC-VID-006 sobre a base atualizada e inspecionado o diferencial
face à `main` de Alice. Esta experiência evidencia que os agentes podem apoiar operações complexas de
integração, mas não conseguem garantir por si só autoria, compatibilidade nem ausência de regressões.

A equipa é responsável por rever os requisitos, as decisões, as permissões de acesso e o resultado dos
testes antes da entrega. A validação humana permanece necessária para distinguir funcionalidade
implementada de funcionalidade apenas especificada, e teste executado de teste simplesmente existente.


#preencher[Acrescentar exemplos concretos de propostas úteis dos agentes, erros ou omissões identificados, métodos utilizados para os detetar e correções efetuadas. Sempre que possível, associar estes exemplos a commits, ficheiros ou resultados de testes.]



#preencher[Antes da entrega, completar as versões dos modelos utilizados, os comandos efetivamente executados, as evidências de revisão e os resultados de validação do código e dos testes.]

