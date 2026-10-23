#import "../template.typ": *

= Alterações Arquiteturais

#orientacao[
  Partam do documento de solução arquitetural de base e descrevam apenas o *delta* introduzido pelo suporte a
  vídeo. O nível de detalhe é o de um MVP: o suficiente para que outra equipa perceba, mantenha e estenda a
  solução na Fase 2. Cada alteração deve estar ligada aos requisitos que a motivam.
]



== Visão geral das alterações

#orientacao[
  A vista de componentes é *opcional*: incluam-na se ajudar a perceber as alterações. A tabela de componentes
  novos e alterados é suficiente.
]

Não se acrescenta outro diagrama de componentes. A arquitetura de base já apresenta os serviços e as suas ligações, enquanto a tabela seguinte explicita o delta de vídeo, o estado de cada componente e os requisitos que motivam a alteração. Um segundo diagrama geral repetiria essa informação sem mostrar melhor o fluxo novo. Para compreender as interações durante uma operação, inclui-se antes o diagrama de sequência, que evidencia o percurso entre interface, gateway, serviço de projetos, RabbitMQ, worker e armazenamento.

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
    [`frontend`], [Estendido], [Biblioteca, submissão de vídeo, formulários de processamento, estado e apresentação do resultado.], [UC-VID-001 a 007. REQ-VID-SUB, TRIM, FRM, CONV, FEX, MERGE, AUD],
    [`apiGateway`], [Estendido], [Autenticação, autorização, encaminhamento das rotas REST e pedidos de operação.], [REQ-VID-COM-001 a 003. REQ-VID-MERGE-001 a 009],
    [`projects`], [Estendido], [Modelos, validação de perfil, reserva de quota quando se aplica uma ferramenta avançada, operações, workers e associação do resultado ao projeto.], [REQ-VID-COM-004 a 019. REQ-VID-MERGE-001 a 015],
    [`rabbitmq`], [Reutilizado], [Desacoplamento entre o pedido HTTP e o processamento, com filas para tipos de operações de vídeo.], [REQ-VID-COM-009, REQ-VID-MERGE-009, REQ-VID-MERGE-010],
    [`img_storage` e SeaweedFS], [Estendidos], [Carregamento, leitura, persistência de resultados e remoção de objetos parciais.], [REQ-VID-SUB-001 a 033, REQ-VID-COM-014 a 018],
    [FFmpeg / FFprobe], [Adicionado ao processamento], [Validação técnica, extração de metadados, recorte, conversão, fotogramas, concatenação e operações de áudio.], [REQ-VID-SUB-004 a 014, REQ-VID-TRIM-010 a 013, REQ-VID-FRM-007 a 010, REQ-VID-CONV-008 a 011, REQ-VID-FEX-007 a 010, REQ-VID-MERGE-010 a 015, REQ-VID-AUD-004 a 016],
    [MongoDB], [Reutilizado / estendido], [Armazena referências a vídeos e registos de operação, incluindo estados e metadados.], [REQ-VID-COM-009 a 010. REQ-VID-MERGE-012],
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
    [DA-01], [Execução assíncrona por fila], [Alternativa: executar FFmpeg durante o pedido REST. Preferiu-se RabbitMQ para não bloquear pedidos longos.], [Worker e estados persistidos. REQ-VID-MERGE-009 e REQ-VID-COM-009],
    [DA-02], [Origens imutáveis], [Alternativa: substituir diretamente os ficheiros existentes. Guardar resultado novo reduz risco de perda e mantém histórico.], [Novo objeto e associação ao projeto. REQ-VID-MERGE-012 e 013],
    [DA-03], [Reutilização de serviços], [Alternativa: microserviço isolado para cada operação. A solução de MVP acrescenta serviços e handlers ao fluxo existente de projetos e storage.], [Integração incremental e dependência dos contratos existentes. DQ-002],
    [DA-04], [Normalização técnica das entradas], [Alternativa: rejeitar todas as combinações de formatos diferentes. A normalização FFmpeg permite juntar fontes heterogéneas.], [Custo adicional de processamento. REQ-VID-MERGE-010 e 011],
    [DA-05], [Consulta REST do estado de merge], [Alternativa especificada: eventos WebSocket com percentagem. A implementação do diálogo de concatenação consulta o estado pela API.], [Acompanhamento funcional, mas divergência face ao requisito de progresso WebSocket. DQ-001 e REQ-VID-COM-011 a 013],
  ),
)

== Fluxo de processamento de vídeo



#figure(
  image("../images/diagrama_sequencia.png", width: 100%),
  caption: [Sequência de processamento de um vídeo entre componentes],
)

A extensão da aplicação de edição de imagem para suportar operações de edição de vídeo introduziu a necessidade de implementar um mecanismo de processamento assíncrono, uma vez que estas operações exigem recursos computacionais significativos e podem apresentar tempos de execução elevados. Ao contrário das operações mais simples sobre imagens, o processamento de vídeo envolve frequentemente a descodificação, manipulação e codificação de sequências de fotogramas, tornando inadequada a sua execução durante uma única chamada HTTP. Para responder a esta necessidade, foi adotada uma arquitetura baseada na separação entre a submissão dos pedidos e a execução efetiva das operações, recorrendo ao RabbitMQ para a distribuição de tarefas e a um worker dedicado para o processamento com FFmpeg. O diagrama apresenta a interação entre os diferentes componentes do sistema ao longo deste processo.

O fluxo inicia-se quando o utilizador seleciona um vídeo e a operação que pretende realizar através do frontend. O pedido é enviado ao API Gateway, responsável por o encaminhar para o Projects Service, preservando o contexto de autenticação do utilizador. Antes de aceitar a operação, o serviço consulta o MongoDB para verificar a existência do projeto e as permissões de acesso, obtém a referência do vídeo no sistema de armazenamento e valida os parâmetros específicos da operação, bem como os limites e quotas associados ao perfil do utilizador. No caso da concatenação, estas validações incluem ainda a verificação dos vídeos selecionados, da sua ordem e das restrições aplicáveis à duração total. Caso alguma das condições não seja satisfeita, o pedido é rejeitado e o frontend apresenta a mensagem de erro correspondente, sem iniciar qualquer tarefa de processamento.

Após a validação, o Projects Service cria um registo persistente da operação no MongoDB, associando-lhe um identificador único e um estado inicial de espera (queued). Em seguida, publica uma mensagem no RabbitMQ com a informação necessária para identificar a tarefa a executar. O identificador da operação é devolvido ao frontend através do API Gateway, permitindo informar o utilizador de que o pedido foi aceite sem aguardar pela conclusão do processamento. Esta abordagem evita manter uma ligação HTTP aberta durante operações potencialmente demoradas e permite gerir a execução das tarefas de forma independente dos pedidos recebidos pela API.

As tarefas publicadas no RabbitMQ são posteriormente consumidas por um worker dedicado, responsável pela execução das operações de vídeo. Ao receber uma tarefa, o worker obtém os ficheiros necessários a partir do sistema de armazenamento e comunica ao Projects Service o início do processamento, permitindo atualizar o estado da operação para processing. Esta alteração é também disponibilizada ao frontend através do mecanismo de comunicação WebSocket, possibilitando o acompanhamento do progresso sem depender exclusivamente de consultas periódicas à API. O processamento é realizado com recurso ao FFmpeg, que executa a operação solicitada sobre os ficheiros de vídeo. Dependendo da funcionalidade escolhida, esta etapa pode envolver a extração e manipulação de fotogramas, a aplicação de ferramentas de edição, a normalização dos fluxos de áudio e vídeo ou a recomposição e codificação do resultado. Na concatenação, em particular, os vídeos são processados segundo a ordem definida pelo utilizador, produzindo um novo ficheiro que combina as fontes selecionadas, sem modificar os ficheiros originais.

Quando a operação envolve a aplicação de ferramentas de edição de imagem aos fotogramas de um vídeo, o worker pode ainda distribuir o processamento dessas imagens através do RabbitMQ, recolhendo posteriormente os resultados para reconstruir o vídeo e o respetivo áudio. Desta forma, a arquitetura permite reutilizar funcionalidades de edição de imagem existentes na aplicação, integrando-as no processamento de vídeo e mantendo a separação entre a gestão das operações e as tarefas computacionalmente mais exigentes.

Concluído o processamento com sucesso, o worker carrega o ficheiro resultante para o sistema de armazenamento, onde este é guardado como um novo objeto. A referência do resultado é então comunicada ao Projects Service, que atualiza o registo da operação no MongoDB para o estado completed e associa o novo vídeo ao projeto correspondente. Posteriormente, a conclusão é publicada através do WebSocket, permitindo ao frontend atualizar a interface e disponibilizar o vídeo processado ao utilizador. Esta abordagem assegura que os ficheiros de origem permanecem disponíveis e que o resultado é tratado como um novo recurso da aplicação.

O fluxo contempla igualmente situações de falha e cancelamento. Caso ocorra um erro durante o processamento, o worker comunica a ocorrência ao Projects Service, que atualiza o estado da operação e disponibiliza essa informação ao frontend. Sempre que necessário, são executados procedimentos de limpeza dos ficheiros temporários e de remoção de resultados parciais, evitando a acumulação de recursos desnecessários. De forma semelhante, quando é solicitado o cancelamento de uma operação, o processamento deve ser interrompido e os recursos temporários libertados antes de a operação ser considerada cancelada. Estes mecanismos procuram preservar a consistência entre os estados registados na base de dados e os ficheiros existentes no armazenamento, embora não garantam, por si só, a recuperação de todos os cenários possíveis de falha num sistema distribuído.

A utilização desta arquitetura assíncrona constitui, assim, um elemento fundamental da extensão da aplicação para edição de vídeo. A separação entre a receção dos pedidos, a gestão do estado das operações e a execução do processamento permite manter a interface responsiva, acompanhar a evolução das tarefas e isolar as operações mais exigentes num componente especializado. Adicionalmente, a utilização de uma fila de mensagens facilita a distribuição da carga de trabalho e cria condições para aumentar a capacidade de processamento através da execução de múltiplos workers. Deste modo, foi possível integrar funcionalidades de edição de vídeo na arquitetura existente, reutilizando componentes e mecanismos de comunicação da aplicação, sem comprometer o funcionamento das restantes funcionalidades.


== Impacto na instalação e execução



A solução usa `docker compose` para iniciar os serviços do PictuRAS e acrescenta contentores de processamento, incluindo `video_conversion_tool` e `video_audio_tool`. Os workers usam RabbitMQ e o volume partilhado `image_data`. FFmpeg e FFprobe são dependências do processamento de vídeo. A compilação e testes da UC-VID-006 foram efetuados nos contentores `projects` e
`api_gateway`, com construção do frontend. A lista de pré-requisitos, comandos verificáveis e comportamento
esperado encontram-se no Anexo A. Deve evitar-se reinicializar volumes de dados durante a validação.
