#import "../template.typ": *

= Implementação Assistida por Agentes de IA

#orientacao[
  Obrigatório (enunciado): documentar as ferramentas e _skills_ utilizadas, enumerar as tarefas apoiadas e comprovar a validação realizada — tanto na especificação como no código e nos testes. A equipa é responsável por todo o conteúdo entregue, incluindo o gerado por IA. Valoriza-se evidência concreta (_commits_, _pull requests_, ficheiros de configuração dos agentes) e reflexão crítica sobre os erros introduzidos pela IA e a forma como foram identificados e corrigidos.
]

== Ferramentas, modelos e configuração


A equipa utilizou ferramentas de IA em atividades diferentes do ciclo de desenvolvimento. O GitHub Copilot e o GitHub Spec Kit apoiaram a organização dos artefactos de especificação e implementação por funcionalidade. O ChatGPT Codex, com o modelo GPT-6, foi utilizado em apoio à implementação, depuração, resolução de conflitos de integração, organização de testes e preparação da documentação. A IA foi tratada como apoio à equipa e não como autoridade para decidir requisitos ou aceitar resultados.

As instruções gerais encontram-se em `AGENTS.md`. As skills do Spec Kit e a respetiva configuração estão em `.github/skills/` e `.specify/`. Estes recursos indicam a ordem de precedência das fontes, orientam a preservação dos identificadores e pedem que requisitos, assunções e questões em aberto sejam distinguidos.





#tabela(
  colunas: (3.5cm, 1fr),
  [Ferramenta / modelo], [Configuração e utilização (_skills_, instruções de projeto, MCP, …)],

  [GitHub Copilot],
  [Agente de IA integrado no ambiente de desenvolvimento, configurado para apoiar o fluxo de trabalho do Spec Kit. As _skills_ disponíveis em `.github/skills/` fornecem instruções específicas para as atividades de especificação, clarificação, planeamento, decomposição de tarefas, análise e implementação.],

  [GitHub Spec Kit (`specify-cli`)],
  [Ferramenta utilizada para estruturar o processo de especificação e organizar os respetivos artefactos por funcionalidade. A configuração encontra-se em `.specify/`, estando o procedimento de instalação e inicialização documentado em `specs/README.md`.],

  [Instruções dos agentes (`AGENTS.md`)],
  [Ficheiro de configuração que define a hierarquia das fontes de informação, as regras de rastreabilidade dos requisitos e os cuidados a observar na geração e revisão de conteúdo.],

  [ChatGPT Codex — GPT-6], [Apoio à implementação, depuração, resolução de conflitos de integração, organização dos testes e preparação da documentação. A utilização e o modelo estão registados na validação de manutenção da biblioteca.],

)

=== Organização do processo com Spec Kit

O fluxo do GitHub Spec Kit organiza o trabalho desde a definição de princípios e requisitos até à implementação. No projeto, os seus artefactos serviram sobretudo para fornecer contexto estruturado às tarefas de implementação e para ligar cada funcionalidade a requisitos, decisões e tarefas. Este formato ajudou a reduzir ambiguidades e a tornar as propostas dos agentes mais fáceis de conferir com as fontes do projeto.

A abordagem adotada teve por base os requisitos previamente definidos e documentados em artefactos Markdown (.md). Cada especificação foi associada a um caso de uso, permitindo delimitar o âmbito de cada funcionalidade e fornecer aos agentes um contexto concreto sobre o comportamento a implementar. Esta organização procurou evitar que os agentes recorressem a pressupostos não documentados ou introduzissem comportamentos incompatíveis com os requisitos estabelecidos.

O fluxo disponibiliza comandos especializados para cada etapa. A sequência prevista no repositório é:

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

Adicionalmente, a manutenção destes artefactos em Markdown facilitou a revisão manual, o controlo de versões através do Git e a identificação das alterações realizadas ao longo do desenvolvimento. Estes documentos constituem os artefactos de trabalho da especificação

A manutenção dos artefactos em Markdown facilitou a revisão manual, o controlo de versões e a comparação das alterações. O relatório final foi redigido separadamente em Typst.

Apesar das vantagens desta abordagem, a utilização do Spec Kit não garante, por si só, a ausência de erros na implementação. A revisão humana, a confirmação da conformidade com os requisitos e a execução de testes continuam a ser essenciais para validar os resultados produzidos pelos agentes de IA.

=== Contexto e instruções fornecidos aos agentes

Todos os documentos PDF utilizados como fontes de contexto foram convertidos para formato Markdown (.md), facilitando a leitura e interpretação do seu conteúdo pelos agentes de IA e permitindo fornecer contexto mais estruturado e acessível. Esta conversão procurou melhorar a compreensão dos requisitos e das decisões do projeto, reduzindo o risco de omissões ou interpretações incorretas durante a especificação e a implementação.

Para reduzir inconsistências na interpretação dos requisitos e orientar o comportamento dos agentes de IA, o projeto utiliza dois ficheiros principais de instruções: AGENTS.md e .specify/memory/constitution.md.

O ficheiro AGENTS.md estabelece a hierarquia das fontes de informação que devem orientar os agentes, privilegiando as diretrizes da Fase 1, o catálogo consolidado de requisitos e os casos de uso, seguindo-se o enunciado do projeto, a documentação geral, o código existente e os artefactos do Spec Kit.

Por sua vez, o ficheiro constitution.md define os princípios, as regras e as restrições gerais que devem orientar o trabalho realizado com o Spec Kit. Funciona como uma referência normativa para o GitHub Copilot durante o processo de desenvolvimento, devendo as suas instruções ser respeitadas ao longo da especificação e da implementação, de modo a manter a coerência com as regras estabelecidas para o projeto.


Em conjunto, estes ficheiros procuram assegurar que os agentes preservam os identificadores dos requisitos, distinguem decisões aprovadas de pressupostos e não introduzem funcionalidades, limites ou contratos sem fundamento nas fontes do projeto. Desta forma, o comportamento dos agentes é orientado por regras explícitas e por requisitos documentados, reduzindo o risco de interpretações incorretas e de soluções incompatíveis com o âmbito definido, mantendo-se a responsabilidade humana pela interpretação dos requisitos, aceitação das propostas e validação dos resultados. Em termos de processo, a equipa consultou primeiro as diretrizes da Fase 1, o catálogo consolidado e os casos de uso, e depois comparou as propostas com a implementação e os testes disponíveis. Na integração da UC-VID-006, o trabalho avançou por etapas: validação de limites e perfis, pipeline FFmpeg, acesso ao armazenamento, fila RabbitMQ, rotas do gateway, modelo da operação e interface. Por exemplo, a reaplicação dos commits `44f3d37` e `5c4fc9c` à base do grupo permitiu rever o âmbito das alterações antes da integração.

== Tarefas apoiadas e validação

#tab([Tarefas apoiadas por agentes de IA e validação],
  tabela(
    colunas: (2.5cm, 2.1cm, 1fr, 1fr, 2.8cm),
    tamanho: 8.2pt,
    [Ferramenta / _skill_], [Caso de uso], [Tarefa apoiada], [Validação realizada pela equipa], [Evidência],
    [GitHub Copilot / Spec Kit], [UC-VID-001 a 007], [Estruturação de especificações, planos, modelos de dados, contratos e tarefas por funcionalidade.], [Conferência dos artefactos com os documentos de referência e revisão dos IDs, limites e fluxos.], [`specs/001` a `specs/007`, `AGENTS.md`, `.specify/`],
    [GitHub Copilot / Spec Kit], [Qualidade dos artefactos], [Análise de coerência entre requisitos, casos de uso e planos através do fluxo `/speckit-analyze`.], [A equipa confirmou as discrepâncias identificadas antes de as incorporar nos documentos.], [`specs/*/checklists/`, histórico Git],
    [ChatGPT Codex — GPT-6], [UC-VID-006 / backend], [Implementação do processamento FFmpeg, validação, integração com armazenamento, RabbitMQ e modelo de operação.], [Revisão do diff, testes unitários e de integração no contentor, incluindo cenários com FFmpeg real.], [Commits `44f3d37`, `5c4fc9c`. `projects/test/videoMerge*.test.js`],
    [ChatGPT Codex — GPT-6], [UC-VID-006 / API Gateway], [Encaminhamento da operação, identidade, autorização do projeto e preservação da ordem dos vídeos.], [Testes automatizados do gateway verificaram identidade, autorização, ordem e mapeamento de erros.], [3 testes de gateway registados. `videoMergeGatewayRoute.test.js`],
    [ChatGPT Codex — GPT-6], [Integração UC-VID-006 / UC-VID-007], [Resolução de conflitos entre o modelo de concatenação e os campos/rotas da gestão de áudio.], [Revisão do esquema e execução de testes de regressão que confirmaram que os contratos de áudio existentes permaneciam disponíveis.], [ commits de integração],
    [ChatGPT Codex — GPT-6], [Frontend de vídeo], [Diálogos de operação, consulta de estados, reconciliação da biblioteca, controlos de parâmetros e apresentação do progresso.], [Testes de frontend, verificação TypeScript e build Docker. Não foi registada inspeção visual no browser para todos os fluxos.], [`docs/validacao/atualizacao-biblioteca.md`, testes `frontend/test/`],
    [ChatGPT Codex — GPT-6], [Documentação e manutenção], [Diagnóstico de defeitos, atualização da rastreabilidade e preparação de instruções de validação.], [Conferência dos resultados com os registos e separação entre testes executados, testes existentes e cenários pendentes.], [`docs/validacao/`, quickstarts em `specs/`],
  ),
)

Os comandos do fluxo Spec Kit documentados no projeto são `/speckit-constitution`, `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-analyze`, `/speckit-checklist` e `/speckit-implement`. Os artefactos comprovam a utilização do fluxo de especificação e análise. A revisão humana incidiu sobre os requisitos, os contratos entre serviços, os resultados dos testes e os conflitos de integração.

== Análise crítica

A utilização de agentes de inteligência artificial revelou-se útil para acelerar a implementação, explorar soluções técnicas e apoiar a integração de diferentes componentes. A organização dos requisitos e das tarefas através do Spec Kit, complementada pelas instruções definidas em `AGENTS.md` e `constitution.md`, forneceu contexto estruturado aos agentes e facilitou a comparação das propostas com as decisões do projeto. No entanto, esta abordagem não eliminou a necessidade de intervenção humana. Na integração da funcionalidade de concatenação, por exemplo, o modelo da operação e uma rota do gateway não ficaram inicialmente associados ao contrato completo. A revisão dos ficheiros alterados permitiu identificar a omissão e corrigi-la sem comprometer os campos utilizados pela funcionalidade de áudio.

Outro risco identificado foi a inclusão de alterações fora do âmbito previsto. Na integração da UC-VID-006, a seleção dos commits específicos e a análise das diferenças face à versão de referência permitiram controlar melhor o conteúdo incorporado. Este caso demonstra que os agentes conseguem apoiar tarefas complexas, mas não garantem a compatibilidade entre componentes, a preservação de funcionalidades existentes ou a ausência de alterações indevidas.

A experiência evidenciou também que a documentação estruturada e as instruções fornecidas aos agentes reduzem ambiguidades, mas não impedem interpretações incorretas. Foram identificadas divergências entre a documentação e as decisões técnicas aprovadas, nomeadamente na especificação de áudio, na transferência sem recurso a uma biblioteca e no número de repetições por fotograma. A sua correção reforçou a importância de confrontar o conteúdo produzido com as fontes de referência, em vez de assumir que uma resposta coerente está necessariamente correta.

Conclui-se que a principal vantagem da IA reside no apoio à produtividade e à exploração de soluções, enquanto a sua principal limitação está na impossibilidade de garantir autonomamente a conformidade com todos os requisitos e decisões do projeto. A equipa mantém, por isso, a responsabilidade de avaliar as propostas, controlar as alterações integradas e assegurar a coerência entre especificações, implementação e documentação. A utilização destas ferramentas revelou-se vantajosa quando acompanhada por revisão crítica, rastreabilidade e validação humana, devendo os resultados gerados ser tratados como propostas a verificar e não como soluções automaticamente aceites.
