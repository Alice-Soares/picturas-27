#import "../template.typ": *

= Alterações Arquiteturais

#orientacao[
  Partam do documento de solução arquitetural de base e descrevam apenas o *delta* introduzido pelo suporte a
  vídeo. O nível de detalhe é o de um MVP: o suficiente para que outra equipa perceba, mantenha e estenda a
  solução na Fase 2. Cada alteração deve estar ligada aos requisitos que a motivam.
]



*TODO*: REVER E DAR EXPLICAÇÕES SUFICIENTES PARA PERCEBER AS DECISÕES MAS CONCISAS

== Visão geral das alterações

#orientacao[
  A vista de componentes é *opcional*: incluam-na se ajudar a perceber as alterações. A tabela de componentes
  novos e alterados é suficiente.
]

#figure(kind: image,
  figura-pendente[vista de componentes/serviços atualizada, com componentes novos e alterados destacados (`images/arquitetura_componentes.png`)],
  caption: [Vista de componentes da solução com suporte a vídeo (opcional)],
)

O incremento de vídeo preserva os serviços de imagem da solução anterior e reutiliza o encaminhamento HTTP,
a autenticação, a persistência dos projetos e o armazenamento de objetos. Introduz metadados de vídeo,
operações duradouras e workers para manipulação audiovisual. O objetivo da Fase 1 é validar o funcionamento
integrado do MVP, não demonstrar ainda propriedades de produção como escalabilidade horizontal ou tolerância
a falhas distribuída em todas as ferramentas.

#tab([Componentes e responsabilidades na extensão de vídeo],
  tabela(
    colunas: (3.0cm, 1.7cm, 1fr, 3.2cm),
    tamanho: 8.5pt,
      [Componente / serviço], [Estado], [Responsabilidade / alteração], [Requisitos],
    [`frontend`], [Estendido], [Biblioteca, submissão de vídeo, formulários de processamento, estado e apresentação do resultado.], [UC-VID-001 a 007; REQ-VID-SUB, TRIM, FRM, CONV, FEX, MERGE, AUD],
    [`apiGateway`], [Estendido], [Autenticação, autorização, encaminhamento das rotas REST e pedidos de operação.], [REQ-VID-COM-001 a 003; REQ-VID-MERGE-001 a 009],
    [`projects`], [Estendido], [Modelos, validação de perfil, quotas, operações, workers e associação do resultado ao projeto.], [REQ-VID-COM-004 a 019; REQ-VID-MERGE-001 a 015],
    [`rabbitmq`], [Reutilizado], [Desacoplamento entre o pedido HTTP e o processamento, com filas para tipos de operações de vídeo.], [REQ-VID-COM-009; REQ-VID-MERGE-009, MERGE-010],
    [`img_storage` e SeaweedFS], [Estendidos], [Carregamento, leitura, persistência de resultados e remoção de objetos parciais.], [REQ-VID-SUB; REQ-VID-COM-014 a 018],
    [FFmpeg / FFprobe], [Adicionado ao processamento], [Validação técnica, extração de metadados, recorte, conversão, fotogramas e concatenação.], [REQ-VID-MERGE-010 a 015; requisitos específicos das restantes UC],
    [MongoDB], [Reutilizado / estendido], [Armazena referências a vídeos e registos de operação, incluindo estados e metadados.], [REQ-VID-COM-009 a 010; REQ-VID-MERGE-012],
  ),
)

== Decisões arquiteturais

#orientacao[
  Registo leve de decisões (ao estilo ADR). Uma decisão só merece registo se havia alternativas reais
  (e.g., processamento síncrono vs. assíncrono via fila; um serviço por ferramenta vs. serviço de vídeo único;
  onde guardar ficheiros de entrada/saída; como reportar progresso ao _frontend_).
]


#tab([Decisões de arquitetura],
  tabela(
    colunas: (1.1cm, 2.9cm, 1fr, 3cm),
    tamanho: 8.5pt,
    [ID], [Decisão], [Alternativas e fundamento], [Consequências e requisitos],
    [DA-01], [Execução assíncrona por fila], [Alternativa: executar FFmpeg durante o pedido REST. Preferiu-se RabbitMQ para não bloquear pedidos longos.], [Worker e estados persistidos; REQ-VID-MERGE-009 e REQ-VID-COM-009],
    [DA-02], [Origens imutáveis], [Alternativa: substituir diretamente os ficheiros existentes. Guardar resultado novo reduz risco de perda e mantém histórico.], [Novo objeto e associação ao projeto; REQ-VID-MERGE-012 e 013],
    [DA-03], [Reutilização de serviços], [Alternativa: microserviço isolado para cada operação. A solução de MVP acrescenta serviços e handlers ao fluxo existente de projetos e storage.], [Integração incremental e dependência dos contratos existentes; DQ-002],
    [DA-04], [Normalização técnica das entradas], [Alternativa: rejeitar todas as combinações de formatos diferentes. A normalização FFmpeg permite juntar fontes heterogéneas.], [Custo adicional de processamento; REQ-VID-MERGE-010 e 011],
    [DA-05], [Consulta REST do estado de merge], [Alternativa especificada: eventos WebSocket com percentagem. A implementação do diálogo de concatenação consulta o estado pela API.], [Acompanhamento funcional, mas divergência face ao requisito de progresso WebSocket; DQ-001 e REQ-VID-COM-011 a 013],
  ),
)

== Fluxo de processamento de vídeo



#figure(kind: image,
  figura-pendente[diagrama de sequência entre componentes para o fluxo principal de processamento de um vídeo (`images/sequencia_processamento.png`)],
  caption: [Sequência de processamento de um vídeo entre componentes],
)

*TODO*: 
#preencher[Explicação do fluxo: pedido, encaminhamento, processamento, armazenamento, notificação de progresso/resultado, falhas.]



*TODO*: VER SE FAZ SENTIDO TER ESTE TAMBÉM OU BASTA EXPLICAR O DO DIAGRAMA DE SEQUÊNCIA

== Sequência de processamento — UC-VID-006

O fluxo efetivamente implementado para a concatenação percorre os seguintes passos:

+ O utilizador autenticado abre o diálogo no frontend, escolhe e ordena pelo menos dois vídeos do mesmo projeto.
+ O API Gateway encaminha a operação preservando identidade, autenticação e a ordem das fontes.
+ O Projects Service verifica propriedade/autorização, perfil, quota, número de vídeos, duração acumulada e metadados.
+ O serviço regista a operação no MongoDB e publica a mensagem numa fila de RabbitMQ; o pedido HTTP é aceite sem esperar pelo FFmpeg.
+ O worker obtém os vídeos no armazenamento, normaliza fluxos de áudio e vídeo, executa FFmpeg e produz um MP4 temporário.
+ O resultado é carregado como objeto novo e registado no projeto; as origens mantêm-se inalteradas.
+ A interface consulta o estado da operação por API e apresenta o resultado quando a execução termina.

Em caso de erro ou cancelamento, o fluxo assinala o estado respetivo e procura remover ficheiros temporários
e resultados remotos parciais. Os testes da pipeline verificam limpeza, compensação e cancelamento; tal não
constitui prova de recuperação completa de todos os cenários de falha distribuída, que fica para uma fase posterior.

== Impacto na instalação e execução

#preencher[Novos serviços/contentores, dependências externas (e.g., binários de processamento de vídeo), volumes, variáveis de configuração. Instruções completas de execução no Anexo A.]

A solução usa `docker compose` para iniciar os serviços já presentes no PictuRAS: frontend, gateway, projetos,
mensageria, persistência e armazenamento. O processamento de vídeo requer FFmpeg e FFprobe no ambiente de
execução adequado. A compilação e testes da UC-VID-006 foram efetuados nos contentores `projects` e
`api_gateway`, com construção do frontend. A lista de pré-requisitos, comandos verificáveis e comportamento
esperado encontram-se no Anexo A. Deve evitar-se reinicializar volumes de dados durante a validação.
