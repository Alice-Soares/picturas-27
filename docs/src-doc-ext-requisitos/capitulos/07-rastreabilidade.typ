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

    [UC-VID-001, passos 6-8 e RN9-RN10], [Ordem da validação, unidades decimais e receção em disco], [REQ-VID-SUB-004, REQ-VID-SUB-032, REQ-VID-SUB-033],
    [UC-VID-001, FA1-FA2], [Resultado individual do lote e decisão sobre duplicados], [REQ-VID-SUB-030, REQ-VID-SUB-031],
    [UC-VID-002/RN5], [Preservação do áudio no segmento], [REQ-VID-TRIM-013],
    [UC-VID-005/RN3], [Extração sem quota diária], [REQ-VID-FEX-012],
    [UC-VID-002 a UC-VID-007, passos de progresso], [Publicação no projeto autorizado], [REQ-VID-COM-020],

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

    [Manutenção da biblioteca], [Eliminação de vídeo, seleção múltipla e projeto sem imagem inicial], [REQ-VID-MNT-001, REQ-VID-MNT-002, REQ-VID-MNT-003],

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
    [Os conteúdos originais devem ser imutáveis e cada vídeo derivado deve ser persistido como novo conteúdo. O áudio extraído é temporário para transferência.],
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

A tabela distingue implementação de aceitação. Os IDs TST-ACC-{FUNC}-nn identificam protocolos de aceitação a executar: cada protocolo usa exatamente o critério Dado/Quando/Então da linha do mesmo requisito no capítulo 5. Não representam testes já executados. Os resultados focados TST-VID-CORE-01, TST-VID-FRONT-01, TST-GATEWAY-01 e TST-AUD-WORKER-01 são definidos no capítulo 10 com comandos e resultados.

#tab([Realização e verificação por requisito], tabela(
  colunas: (3.1cm, 2.9cm, 2.7cm, 3.2cm, 1fr), tamanho: 7.5pt,
  [Requisito], [Componente], [Realização], [Verificação], [Resultado / limite],
  [REQ-VID-SUB-001], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-01], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-002], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-02], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-003], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-03], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-004], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-04], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-005], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-05], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-006], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-06], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-007], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-07], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-008], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-08], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-009], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-09], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-010], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-10], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-011], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-11], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-012], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-12], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-013], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-13], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-014], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-14], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-015], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-15], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-016], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-16], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-017], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-17], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-018], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-18], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-019], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-19], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-020], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-20], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-021], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-21], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-022], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-22], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-023], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-23], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-024], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-24], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-025], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-25], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-026], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-26], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-027], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-27], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-028], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-28], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-029], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-29], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-030], [Gateway / Projects / storage], [Parcial: seletor individual], [TST-ACC-SUB-30], [Helper de lote presente; FA2 não disponível no seletor.],
  [REQ-VID-SUB-031], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-31], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-032], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-32], [Aceitação não executada nesta revisão.],
  [REQ-VID-SUB-033], [Gateway / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-SUB-33], [Aceitação não executada nesta revisão.],
  [REQ-VID-TRIM-001], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-01; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-002], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-02; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-003], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-03; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-004], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-04; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-005], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-05; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-006], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-06; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-007], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-07; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-008], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-08; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-009], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-09; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-010], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-10; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-011], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-11; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-012], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-12; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-TRIM-013], [Projects / videoTrimWorker], [Implementação presente; aceitação pendente], [TST-ACC-TRIM-13; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-001], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-01; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-002], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-02; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-003], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-03; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-004], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-04; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-005], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-05; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-006], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-06; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-007], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-07; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-008], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-08; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-009], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-09; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-010], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-10; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-011], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-11; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-012], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-12; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-013], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-13; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FRM-014], [Projects / workers de imagem], [Implementação presente; aceitação pendente], [TST-ACC-FRM-14; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-001], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-01; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-002], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-02; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-003], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-03; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-004], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-04; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-005], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-05; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-006], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-06; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-007], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-07; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-008], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-08; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-009], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-09; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-010], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-10; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-CONV-011], [Projects / video_conversion_tool], [Implementação presente; aceitação pendente], [TST-ACC-CONV-11; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-001], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-01; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-002], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-02; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-003], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-03; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-004], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-04; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-005], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-05; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-006], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-06; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-007], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-07; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-008], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-08; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-009], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-09; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-010], [Projects / extração / storage], [Parcial: só destinos existentes], [TST-ACC-FEX-10; TST-VID-CORE-01], [FA3 não implementado; o requisito é mantido.],
  [REQ-VID-FEX-011], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-11; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-FEX-012], [Projects / extração / storage], [Implementação presente; aceitação pendente], [TST-ACC-FEX-12; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-MERGE-001], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-01; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-002], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-02; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-003], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-03; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-004], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-04; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-005], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-05; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-006], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-06; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-007], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-07; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-008], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-08; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-009], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-09; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-010], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-10; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-011], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-11; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-012], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-12; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-013], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-13; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-014], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-14; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-MERGE-015], [Projects / pipeline FFmpeg], [Implementação presente; aceitação pendente], [TST-ACC-MERGE-15; TST-MERGE-01 a 03], [Registo histórico; reexecução interrompida (137), sem aprovação final.],
  [REQ-VID-AUD-001], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-01; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-002], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-02; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-003], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-03; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-004], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-04; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-005], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-05; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-006], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-06; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-007], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-07; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-008], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-08; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-009], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-09; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-010], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-10; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-011], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-11; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-012], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-12; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-013], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-13; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-014], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-14; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-015], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-15; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-AUD-016], [Projects / video_audio_tool], [Implementação presente; aceitação pendente], [TST-ACC-AUD-16; TST-VID-CORE-01; TST-AUD-WORKER-01], [Contratos na suite de 49 e cinco testes do worker passaram; aceitação integrada pendente.],
  [REQ-VID-COM-001], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-01; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-002], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-02; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-003], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-03; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-004], [Gateway / Projects / WS], [Condicional: só filtros básicos disponíveis], [TST-ACC-COM-04; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-005], [Gateway / Projects / WS], [Condicional: sem IA no MVP], [TST-ACC-COM-05; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-006], [Gateway / Projects / WS], [Condicional: sem IA no MVP], [TST-ACC-COM-06; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-007], [Gateway / Projects / WS], [Condicional: sem IA no MVP], [TST-ACC-COM-07; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-008], [Gateway / Projects / WS], [Condicional: sem IA no MVP], [TST-ACC-COM-08; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-009], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-09; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-010], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-10; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-011], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-11; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-012], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-12; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-013], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-13; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-014], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-14; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-015], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-15; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-016], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-16; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-017], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-17; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-018], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-18; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-019], [Gateway / Projects / WS], [Implementação presente; aceitação pendente], [TST-ACC-COM-19; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-COM-020], [Gateway / Projects / WS], [Parcial: publicação; UI usa REST], [TST-ACC-COM-20; TST-VID-CORE-01], [49 testes focados passaram; não comprovam integralmente este critério.],
  [REQ-VID-Q-001], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-01], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-002], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-02], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-003], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-03], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-004], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-04], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-005], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-05], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-006], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-06], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-007], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-07], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-008], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-08], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-009], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-09], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-010], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-10], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-011], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-11], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-012], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-12], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-013], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-13], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-014], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-14], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-015], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-15], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-Q-016], [Serviços transversais], [Meta não medida globalmente], [TST-ACC-Q-16], [Não declarar o alvo atingido sem medição específica.],
  [REQ-VID-MNT-001], [Frontend / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-MNT-01], [Aceitação não executada nesta revisão.],
  [REQ-VID-MNT-002], [Frontend / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-MNT-02], [Aceitação não executada nesta revisão.],
  [REQ-VID-MNT-003], [Frontend / Projects / storage], [Implementação presente; aceitação pendente], [TST-ACC-MNT-03], [Aceitação não executada nesta revisão.],
))

A UC-VID-004/FA1 (conversão em lote) não tem requisito atómico próprio no catálogo atual: é uma lacuna de especificação e realização, mantida explícita, sem criar ou reutilizar IDs nesta revisão.
