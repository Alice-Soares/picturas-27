#import "../template.typ": *

= Rastreabilidade

A matriz de origem cobre os requisitos especificados. A matriz de realização abaixo distingue a
implementação verificada da mera presença de componentes.

== Casos de uso → requisitos

#orientacao[
  Cada elemento relevante de cada caso de uso (passos, FA, exceções, RN, pós-condições) tem pelo menos um
  requisito, ou justificação para não ter; nenhum requisito da ERS fica órfão. Requisitos de qualidade podem
  apontar para uma decisão de qualidade (DQ). Indiquem sempre o caso de uso no elemento de origem.
]

#tab([Matriz de rastreabilidade: casos de uso $arrow$ requisitos],
  tabela(
    colunas: (4.2cm, 1fr, 5.2cm),
    tamanho: 8.5pt,
    [Elemento de origem], [Descrição abreviada], [Requisito(s)],

    // UC-VID-001
    [UC-VID-001, passos 1-3], [Selecionar ficheiro e autorizar perfil], [REQ-VID-SUB-001, REQ-VID-SUB-002, REQ-VID-SUB-003],
    [UC-VID-001, passos 2, 6-8], [Validar contentor, streams, metadados e limites], [REQ-VID-SUB-005 a SUB-014, REQ-VID-SUB-016 a SUB-023],
    [UC-VID-001, passos 4-6], [Transferir e confirmar integridade], [REQ-VID-SUB-010, REQ-VID-Q-001, REQ-VID-Q-004],
    [UC-VID-001, passos 9-11], [Persistir e associar ao projeto], [REQ-VID-SUB-015, REQ-VID-SUB-026 a SUB-029, REQ-VID-COM-018],
    [UC-VID-001, FA1-FA4 e exceções], [Duplicação, lote, cancelamento e rejeição], [REQ-VID-SUB-008, REQ-VID-SUB-009, REQ-VID-SUB-024, REQ-VID-SUB-025, REQ-VID-Q-001, REQ-VID-Q-007, REQ-VID-Q-008, REQ-VID-Q-009],

    // UC-VID-002
    [UC-VID-002, passos 1-4], [Selecionar vídeo e validar intervalo], [REQ-VID-TRIM-001 a REQ-VID-TRIM-008],
    [UC-VID-002, passos 5-11], [Criar, executar, acompanhar e guardar recorte], [REQ-VID-TRIM-009 a REQ-VID-TRIM-011, REQ-VID-COM-009 a REQ-VID-COM-018],
    [UC-VID-002, FA1-FA2], [Cancelar em fila ou processamento], [REQ-VID-TRIM-012, REQ-VID-COM-008, REQ-VID-COM-015],

    // UC-VID-003
    [UC-VID-003, passos 3-8], [Selecionar ferramenta e configurar processamento], [REQ-VID-FRM-001 a REQ-VID-FRM-006],
    [UC-VID-003, passos 9-12], [Extrair, processar, recompor e disponibilizar], [REQ-VID-FRM-007 a REQ-VID-FRM-010, REQ-VID-FRM-014, REQ-VID-COM-018],
    [UC-VID-003, FA1-FA3 e exceções], [Encadear, repetir e cancelar], [REQ-VID-FRM-011 a REQ-VID-FRM-013, REQ-VID-COM-014 a REQ-VID-COM-017],

    // UC-VID-004
    [UC-VID-004, passos 1-5], [Consultar origem, escolher e validar saída], [REQ-VID-CONV-001 a REQ-VID-CONV-008],
    [UC-VID-004, passos 6-10], [Converter, acompanhar e guardar resultado], [REQ-VID-CONV-009 a REQ-VID-CONV-011, REQ-VID-COM-009 a REQ-VID-COM-018],

    // UC-VID-005
    [UC-VID-005, passos 1-7], [Configurar, estimar e validar extração], [REQ-VID-FEX-001 a REQ-VID-FEX-008],
    [UC-VID-005, passos 8-12], [Extrair e guardar imagens], [REQ-VID-FEX-009, REQ-VID-COM-009, REQ-VID-COM-018],
    [UC-VID-005, FA1-FA3 e exceções], [Intervalo, cancelamento, novo projeto e limpeza], [REQ-VID-FEX-010, REQ-VID-FEX-011, REQ-VID-COM-014 a REQ-VID-COM-016],

    // UC-VID-006
    [UC-VID-006, passos 1-4], [Selecionar, ordenar e validar vídeos], [REQ-VID-MERGE-001 a REQ-VID-MERGE-008, REQ-VID-MERGE-014, REQ-VID-MERGE-015],
    [UC-VID-006, passos 5-10], [Concatenar, preservar áudio e guardar resultado], [REQ-VID-MERGE-009 a REQ-VID-MERGE-013, REQ-VID-COM-009, REQ-VID-COM-018],
    [UC-VID-006, FA1-FA2 e exceções], [Normalização, cancelamento e falhas], [REQ-VID-MERGE-008, REQ-VID-MERGE-014, REQ-VID-MERGE-015, REQ-VID-COM-007, REQ-VID-COM-008, REQ-VID-COM-014 a REQ-VID-COM-017],

    // UC-VID-007
    [UC-VID-007, passos 1-2], [Escolher operação e validar entrada], [REQ-VID-AUD-001 a REQ-VID-AUD-010, REQ-VID-AUD-013, REQ-VID-AUD-014],
    [UC-VID-007, passos 3-9], [Processar, persistir e notificar], [REQ-VID-AUD-011, REQ-VID-AUD-012, REQ-VID-AUD-015, REQ-VID-AUD-016, REQ-VID-COM-009 a REQ-VID-COM-018],
    [UC-VID-007, FA1-FA3 e exceções], [Sem áudio, durações diferentes, cancelamento e falha], [REQ-VID-AUD-007 a REQ-VID-AUD-010, REQ-VID-COM-007, REQ-VID-COM-008, REQ-VID-COM-014 a REQ-VID-COM-017],

    // Requisitos Transversais e Qualidade
    [UC-VID-001 a UC-VID-007, autorização], [Acesso a projeto e conteúdo], [REQ-VID-COM-001 a REQ-VID-COM-003, REQ-VID-COM-019, REQ-VID-Q-005, REQ-VID-Q-010 a REQ-VID-Q-012],
    [UC-VID-003, quota], [Reserva, consumo e devolução apenas ao usar ferramenta avançada], [REQ-VID-COM-004 a REQ-VID-COM-008],
    [UC-VID-001 a UC-VID-007, estados], [Registo, eventos, limpeza e resultados], [REQ-VID-COM-009 a REQ-VID-COM-018, REQ-VID-Q-002, REQ-VID-Q-003, REQ-VID-Q-007, REQ-VID-Q-013 a REQ-VID-Q-015],
    [DQ-001], [Progresso observável em operações demoradas], [REQ-VID-COM-011, REQ-VID-COM-012, REQ-VID-COM-013, REQ-VID-Q-002, REQ-VID-Q-003, REQ-VID-Q-016],
    [DQ-002], [Isolamento do fluxo existente de imagens], [REQ-VID-FRM-001, REQ-VID-FRM-008, REQ-VID-Q-006],
    [DQ-003], [Imutabilidade dos conteúdos originais], [REQ-VID-TRIM-011, REQ-VID-CONV-010, REQ-VID-MERGE-012, REQ-VID-AUD-012, REQ-VID-AUD-015, REQ-VID-COM-017, REQ-VID-Q-004],
    [DQ-004], [Limpeza de temporários em falhas/cancelamento], [REQ-VID-COM-014, REQ-VID-COM-015, REQ-VID-COM-016, REQ-VID-Q-007, REQ-VID-Q-013 a REQ-VID-Q-015],
    [DQ-005], [Autorização em projetos, conteúdos e eventos], [REQ-VID-COM-001, REQ-VID-COM-002, REQ-VID-COM-003, REQ-VID-COM-013, REQ-VID-Q-005],
  ),
)

== Decisões de qualidade

#tab([Decisões de qualidade],
  tabela(
    colunas: (1.6cm, 1fr, 4.2cm, 3.4cm),
    tamanho: 8.5pt,
    [ID], [Decisão de qualidade], [Justificação], [Requisitos],

    [DQ-001],
    [As operações de vídeo demoradas devem ser assíncronas. O objetivo de disponibilizar progresso por WebSocket mantém-se; a UC-VID-006 disponibiliza estado por consulta REST no MVP.],
    [Uploads e processamento de vídeo podem demorar mais do que um pedido HTTP normal. O utilizador deve conseguir acompanhar a operação sem bloquear o pedido; a consulta periódica da API é uma limitação conhecida desta versão.],
    [REQ-VID-COM-011, REQ-VID-COM-012, REQ-VID-COM-013, REQ-VID-Q-002, REQ-VID-Q-003, REQ-VID-Q-016],

    [DQ-002],
    [O processamento de vídeo deve ser isolado do contrato e das filas atuais de processamento de imagens.],
    [O PictuRAS existente processa imagens através de ferramentas independentes e RabbitMQ. A extensão não deve introduzir regressões nem obrigar as ferramentas atuais a compreender vídeos.],
    [REQ-VID-FRM-001, REQ-VID-FRM-008, REQ-VID-Q-006],

    [DQ-003],
    [Os conteúdos originais devem ser imutáveis e cada resultado deve ser persistido como novo conteúdo.],
    [Esta decisão reduz o risco de perda de dados e permite voltar a usar o vídeo original noutras operações. É também necessária para garantir a recuperação após falhas.],
    [REQ-VID-TRIM-011, REQ-VID-CONV-010, REQ-VID-MERGE-012, REQ-VID-AUD-012, REQ-VID-COM-017, REQ-VID-Q-004],

    [DQ-004],
    [Operações falhadas ou canceladas devem limpar temporários antes de serem apresentadas como terminadas.],
    [Ficheiros parciais não podem aparecer na biblioteca nem ocupar armazenamento indefinidamente. A limpeza é uma condição de consistência do MVP.],
    [REQ-VID-SUB-024, REQ-VID-FEX-011, REQ-VID-COM-014, REQ-VID-COM-015, REQ-VID-COM-016, REQ-VID-Q-007, REQ-VID-Q-013 a REQ-VID-Q-015],

    [DQ-005],
    [A autorização deve ser aplicada ao projeto, ao conteúdo, ao resultado e aos eventos de progresso.],
    [Não basta proteger o endpoint inicial: uma referência de vídeo, um resultado ou um evento WebSocket não podem ser usados para obter dados de outro projeto.],
    [REQ-VID-COM-001, REQ-VID-COM-002, REQ-VID-COM-003, REQ-VID-COM-013, REQ-VID-Q-005, REQ-VID-Q-010 a REQ-VID-Q-012],
  ),
)

== Realização e verificação dos requisitos

#orientacao[
  Fecha o ciclo *requisito → componente → teste → estado*. Uma linha por requisito da ERS (podem agrupar
  requisitos com o mesmo destino). Deve ser possível responder a: "que requisitos estão implementados e
  verificados?" e "que componentes foram tocados por cada funcionalidade?". Requisitos não implementados não se
  apagam: ficam com estado "Não implementado" e justificação. Os detalhes estão nos capítulos de Arquitetura e de Testes.
]

#tab([Realização e verificação dos requisitos],
  tabela(
    colunas: (3.0cm, 3.3cm, 2.5cm, 2.1cm, 1fr),
    tamanho: 8.5pt,
    [Requisitos], [Componente(s)], [Estado evidenciado], [Teste(s)], [Resultado],
    [REQ-VID-SUB-001 a REQ-VID-SUB-033], [`frontend`, `apiGateway`, `projects`, `img_storage`], [Implementado; validação focada registada], [Testes de submissão e validação de metadados], [Fluxo E2E completo com perfis, armazenamento e cancelamento por consolidar.],
    [REQ-VID-TRIM-001 a REQ-VID-TRIM-013], [`projects`, `frontend`, worker FFmpeg], [Implementado; validação focada registada], [Testes de contrato e regras de trim], [Repetição E2E na stack completa por consolidar.],
    [REQ-VID-FRM-001 a REQ-VID-FRM-014], [`projects`, processamento de imagem e fotogramas], [Implementado; validação focada registada], [Testes de contrato e processamento de fotogramas], [Repetição E2E com perfis e workers por consolidar.],
    [REQ-VID-CONV-001 a REQ-VID-CONV-011], [`projects`, ferramentas FFmpeg e frontend], [Implementado; validação focada registada], [Testes de regras, contratos e interface], [Execução E2E do worker na stack final por consolidar.],
    [REQ-VID-FEX-001 a REQ-VID-FEX-012], [`projects`, armazenamento e frontend], [Implementado; validação focada registada], [Testes de regras, contrato e interface], [Execução E2E com persistência e cancelamento por consolidar.],
    [REQ-VID-MERGE-001 a REQ-VID-MERGE-008], [Frontend e Projects Service], [Implementação e testes automatizados registados], [TST-MERGE-01], [Incluído nos 65 testes aprovados em Docker.],
    [REQ-VID-MERGE-009], [Projects Service e RabbitMQ], [Implementação e testes automatizados registados], [TST-MERGE-02], [Registo, fila e resposta assíncrona incluídos nos 65 testes aprovados.],
    [REQ-VID-MERGE-010 e 011], [Worker FFmpeg e armazenamento], [Implementação e teste de integração registados], [TST-MERGE-03], [Concatenação FFmpeg incluída nos 65 testes aprovados.],
    [REQ-VID-MERGE-012 e 013], [Projects Service e storage], [Implementação e testes automatizados registados], [TST-MERGE-03/04], [Novo resultado e preservação das fontes cobertos nos testes registados.],
    [REQ-VID-MERGE-014 e 015], [Validação e pipeline], [Validações e erros testados], [TST-MERGE-01/04], [Verificação prévia e na pipeline, conforme erro.],
    [REQ-VID-AUD-001 a REQ-VID-AUD-016], [Projects Service, gateway, worker de áudio e frontend], [Implementado; contratos e interface validados], [Testes focados de contrato e interface], [Execução registada do worker FFmpeg por consolidar; o destino da extração (transferência autenticada, sem persistência na biblioteca) está decidido e alinhado com o código.],
    [REQ-VID-COM-001 a 020], [Gateway, Projects Service, fila e UI], [Parcial / variável por UC], [TST-MERGE-02/04/05], [Autorização e estados de merge verificados. A concatenação não usa quota e o progresso WebSocket não está comprovado.],
    [REQ-VID-Q-001 a 016], [Infraestrutura e serviços transversais], [Sem medição global], [A definir por qualidade], [Não declarar metas não medidas como atingidas.],
  ),
)

