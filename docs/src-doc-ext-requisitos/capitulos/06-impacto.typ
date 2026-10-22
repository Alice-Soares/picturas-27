#import "../template.typ": *

= Impacto no Sistema Existente

#orientacao[
  Que elementos do PictuRAS existente (perfis, quotas, armazenamento, biblioteca, encadeamento, lote,
  exportação, …) e do documento de requisitos de base (UCnn, RFnn, RNFnn) são afetados pelas funcionalidades
  de vídeo. Para cada elemento: *Manter* (fica igual), *Estender* (passa a fazer mais) ou *Alterar* (muda o
  comportamento atual). Incluam todos os requisitos ALT e os NOVO que interagem com mecanismos existentes.
  Se duas funcionalidades afetam o mesmo elemento de forma diferente, há uma inconsistência a resolver aqui.
]

A introdução das funcionalidades de processamento e gestão de vídeo no PictuRAS reutiliza substancialmente a infraestrutura do sistema existente (Fase 0/v1.0), estendendo as suas capacidades sem comprometer o fluxo operacional de edição de imagem.

A tabela apresenta o impacto da extensão nos componentes e regras existentes. *Manter* indica que o contrato ou comportamento da baseline é preservado. *Estender* indica que o componente passa a tratar vídeo além de imagem. *Alterar* assinala uma regra transversal cujo âmbito passa também a incluir operações de vídeo.

#tab([Impacto no sistema existente],
  tabela(
    colunas: (3.6cm, 1.8cm, 1fr, 2.4cm, 3.2cm),
    tamanho: 8.5pt,
    [Elemento existente afetado], [Impacto], [Descrição do impacto], [Caso(s) de uso], [Requisitos],

    [Mecanismo de Autenticação JWT e Perfis],
    [Alterar],
    [Reutiliza a verificação de tokens JWT existente, mas altera a política de acessos ao introduzir a restrição que impede utilizadores anónimos de submeter ou processar vídeos, reservando o pipeline de vídeo para os perfis Registado e Premium.],
    [UC-VID-001 a 007],
    [REQ-VID-SUB-001, REQ-VID-SUB-002, REQ-VID-COM-001],

    [Limite Diário  de Operações Avançadas],
    [Alterar],
    [A política de quota da baseline mantém-se para ferramentas classificadas como avançadas. O perfil Premium mantém-se sem limite diário para estas ferramentas.],
    [UC-VID-003],
    [REQ-VID-COM-004 a 008],

    [Projects Service e Modelo de Dados de Projetos],
    [Estender],
    [Amplia o modelo de dados de projeto para suportar novas entidades de referência de vídeo, metadados técnicos (codec, resolução, FPS, duração), registo de tarefas assíncronas e associação de ativos de áudio, sem alterar o esquema de projetos de imagem.],
    [UC-VID-001 a 007],
    [REQ-VID-SUB-010 a 015, REQ-VID-SUB-026 a 029, REQ-VID-COM-009],

    [API Gateway],
    [Estender],
    [Adiciona novos endpoints REST para submissão, consulta de metadados, disparo de operações de vídeo, pedido de cancelamento e download de ficheiros de vídeo e áudio, aplicando autorização prévia por projeto em todas as rotas.],
    [UC-VID-001 a 007],
    [REQ-VID-SUB-001, REQ-VID-TRIM-012, REQ-VID-COM-001 a 003, REQ-VID-Q-005],

    [Serviço de Armazenamento / SeaweedFS (S3)],
    [Estender],
    [Reutiliza a fachada de armazenamento existente para persistir vídeos e resultados de áudio, com referências aos objetos associadas aos projetos. A limpeza de ficheiros temporários é responsabilidade do fluxo de processamento e não uma garantia geral do SeaweedFS.],
    [UC-VID-001, 003, 005, 007],
    [REQ-VID-SUB-015, REQ-VID-SUB-024, REQ-VID-FEX-011, REQ-VID-COM-014 a 016, REQ-VID-Q-007],

    [MENSAGENS RabbitMQ e Filas de Tarefas],
    [Estender],
    [O RabbitMQ existente é reutilizado para desacoplar os pedidos de processamento. Os consumidores de recorte, fotogramas, concatenação e áudio criam ou confirmam as respetivas filas ao iniciar. A existência de filas dedicadas varia conforme o consumidor, pelo que não se assume uma fila por cada nome funcional da especificação. As mensagens encaminham a operação para o worker correspondente, sem alterar as filas das ferramentas de imagem.],
    [UC-VID-002 a 007],
    [REQ-VID-TRIM-010, REQ-VID-FRM-008, REQ-VID-CONV-009, REQ-VID-FEX-009, REQ-VID-MERGE-009, REQ-VID-Q-006],

    [WebSocket Gateway e Notificações],
    [Estender],
    [O gateway WebSocket existente continua a distribuir eventos associados ao projeto. As operações de recorte, conversão e processamento de fotogramas publicam progresso quando o worker o disponibiliza. A concatenação apresenta o estado consultando a API periodicamente, porque o seu diálogo não subscreve eventos percentuais. Esta escolha mantém o acompanhamento funcional sem acrescentar um contrato WebSocket específico para uma operação cujo estado persistido já pode ser consultado. O requisito de progresso uniforme fica como evolução de consistência entre operações.],
    [UC-VID-001 a 007],
    [REQ-VID-TRIM-001, REQ-VID-CONV-011, REQ-VID-COM-011 a 013, REQ-VID-COM-020, REQ-VID-Q-002, REQ-VID-Q-003],

    [Workers de Ferramentas de Imagem],
    [Manter / Estender],
    [Os workers de imagem mantêm o seu contrato de processamento individual intacto. O caso de uso `UC-VID-003` estende o pipeline entregando os fotogramas extraídos do vídeo a estes workers como se fossem imagens isoladas.],
    [UC-VID-003],
    [REQ-VID-FRM-001, REQ-VID-FRM-008, REQ-VID-FRM-011, REQ-VID-Q-006],

    [Biblioteca de Projetos e frontend],
    [Estender],
    [Acrescenta apresentação e submissão de vídeos, diálogos para operações e acesso aos resultados. O acompanhamento e as opções variam por funcionalidade],
    [UC-VID-001 a 007],
    [REQ-VID-SUB-001, REQ-VID-TRIM-002, REQ-VID-CONV-001, REQ-VID-FEX-009, REQ-VID-MERGE-004, REQ-VID-AUD-001, REQ-VID-COM-018],

    [Regra de Imutabilidade do Ficheiro Original],
    [Manter],
    [Mantém o princípio do PictuRAS em que o ativo original nunca é sobrescrito, garantindo que todas as transformações de vídeo (trim, conversão, merge, áudio) geram sempre um novo ficheiro independente na biblioteca.],
    [UC-VID-002, 004, 006, 007],
    [REQ-VID-TRIM-011, REQ-VID-CONV-010, REQ-VID-MERGE-012, REQ-VID-MERGE-013, REQ-VID-AUD-012, REQ-VID-COM-017, REQ-VID-Q-004],
  ),
)
