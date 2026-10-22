#import "../template.typ": *

= Implementação Assistida por Agentes de IA

== Ferramentas e organização

O projeto utiliza instruções versionadas para agentes de IA no ficheiro `AGENTS.md` e na estrutura
`.specify/`, com artefactos de especificação e planeamento em `specs/`. O grupo descreveu o uso do
GitHub Copilot e do GitHub Spec Kit como apoio à especificação e decomposição de tarefas. Na UC-VID-006,
foi ainda utilizado o ChatGPT em apoio à implementação, depuração, resolução de conflitos de integração,
organização dos testes e preparação da documentação.

A identificação exata dos modelos e versões do Copilot e do ChatGPT usados por cada elemento não ficou
registada nos ficheiros analisados. Essa informação não é inferida: deve ser recolhida junto dos autores,
se requerida para a versão final do relatório.

#tab([Ferramentas de IA e evidência material],
  tabela(
    colunas: (3cm, 1fr, 3.6cm),
    [Ferramenta], [Finalidade documentada], [Evidência verificável],
    [GitHub Copilot / Spec Kit], [Apoio à especificação, tarefas, pesquisa e planeamento dos casos de uso.], [`AGENTS.md`, `.specify/` e diretórios `specs/`],
    [ChatGPT (UC-VID-006)], [Apoio iterativo ao desenvolvimento dos módulos, testes, integrações e conflitos de código.], [Commits `44f3d37` e `5c4fc9c` na branch de integração; ficheiros `videoMerge*.test.js`],
    [Revisão humana], [Revisão do código, integração em base atualizada, execução dos testes e correção de falhas.], [Registos de testes em Docker e alterações aos ficheiros da operação.],
  ),
)

== Contexto e processo de trabalho

As instruções do repositório definem uma hierarquia de fontes: enunciado, diretrizes da Fase 1,
requisitos consolidados, casos de uso e implementação existente. A especificação deve anteceder a
alteração de código e as sugestões dos agentes não substituem a validação humana dos contratos,
requisitos nem permissões.

O desenvolvimento da UC-VID-006 foi incremental: começou pela validação de regras por perfil, passou
pelo processamento FFmpeg, serviços e armazenamento e integrou depois RabbitMQ, rotas do API Gateway,
modelo de operação e diálogo no frontend. A alteração foi reaplicada à base de código do grupo por dois
commits específicos da funcionalidade, evitando importar por engano ficheiros pertencentes a colegas.

== Atividades apoiadas, verificação e correções

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

== Reflexão crítica

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
