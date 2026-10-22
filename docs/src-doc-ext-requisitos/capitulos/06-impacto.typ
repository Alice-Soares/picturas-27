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

A tabela seguinte apresenta o impacto de projeto identificado para cada elemento. A tabela descreve alterações propostas e/ou implementadas; a extensão de eventos WebSocket, em particular, não é considerada comprovada para a UC-VID-006, cujo acompanhamento atual utiliza consultas REST. Os estados efetivos devem ser confirmados nos testes da entrega. Os impactos são classificados como *Manter* (sem alterações funcionais), *Estender* (acrescenta novas capacidades) ou *Alterar* (modifica o comportamento atual do baseline).

REVER O CONTEUDO TAMBEM


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

    [Limite Diário de Operações Avançadas (RNF48)], 
    [Alterar], 
    [Estende o controlo de cota diária do perfil Registado para cobrir operações de vídeo (trim, conversão, extração, merge e áudio), reservando 1 unidade de cota antes do arranque da tarefa e repondo-a em caso de falha ou cancelamento. A submissão simples não consome cota.], 
    [UC-VID-001 a 007], 
    [REQ-VID-SUB-025, REQ-VID-COM-004 a 008],

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
    [Reutiliza a fachada S3 existente, estendendo-a com suporte a novos MIME types (`video/mp4`, `audio/aac`, `audio/mp3`, `audio/m4a`), novas convenções de caminhos de objetos de vídeo e rotinas automáticas de limpeza de ficheiros temporários em `/tmp`.], 
    [UC-VID-001, 003, 005, 007], 
    [REQ-VID-SUB-015, REQ-VID-SUB-024, REQ-VID-FEX-011, REQ-VID-COM-014 a 016, REQ-VID-Q-007],

    [MENSAGENS RabbitMQ e Filas de Tarefas], 
    [Estender], 
    [Cria novas filas de mensagens dedicadas exclusivamente ao processamento de vídeo (`video.trim`, `video.convert`, `video.frames`, `video.merge`, `video.audio`), mantendo o isolamento total das filas de ferramentas de imagem existentes.], 
    [UC-VID-002 a 007], 
    [REQ-VID-TRIM-010, REQ-VID-FRM-008, REQ-VID-CONV-009, REQ-VID-FEX-009, REQ-VID-MERGE-009, REQ-VID-Q-006],

    [WebSocket Gateway e Notificações], 
    [Estender], 
    [Estende o serviço de eventos em tempo real para publicar transições da máquina de estados das tarefas de vídeo (`em fila`, `em processamento`, `concluída`, `falhada`, `cancelada`) e percentagens de progresso, garantindo isolamento de canal por projeto.], 
    [UC-VID-001 a 007], 
    [REQ-VID-TRIM-001, REQ-VID-CONV-011, REQ-VID-COM-011 a 013, REQ-VID-COM-020, REQ-VID-Q-002, REQ-VID-Q-003],

    [Workers de Ferramentas de Imagem], 
    [Manter / Estender], 
    [Os workers de imagem mantêm o seu contrato de processamento individual intacto. O caso de uso `UC-VID-003` estende o pipeline entregando os fotogramas extraídos do vídeo a estes workers como se fossem imagens isoladas.], 
    [UC-VID-003], 
    [REQ-VID-FRM-001, REQ-VID-FRM-008, REQ-VID-FRM-011, REQ-VID-Q-006],

    [Biblioteca do Projetos e Galeria do Frontend], 
    [Estender], 
    [Amplia a interface web para apresentar miniaturas de vídeo, leitores multimédia, barra de progresso em tempo real de tarefas assíncronas, modal de gestão de áudio, reordenação de vídeos para merge e botões de cancelamento de operações.], 
    [UC-VID-001 a 007], 
    [REQ-VID-SUB-001, REQ-VID-TRIM-002, REQ-VID-CONV-001, REQ-VID-FEX-009, REQ-VID-MERGE-004, REQ-VID-AUD-001, REQ-VID-COM-018],

    [Regra de Imutabilidade do Ficheiro Original], 
    [Manter], 
    [Mantém o princípio do PictuRAS em que o ativo original nunca é sobrescrito, garantindo que todas as transformações de vídeo (trim, conversão, merge, áudio) geram sempre um novo ficheiro independente na biblioteca.], 
    [UC-VID-002, 004, 006, 007], 
    [REQ-VID-TRIM-011, REQ-VID-CONV-010, REQ-VID-MERGE-012, REQ-VID-MERGE-013, REQ-VID-AUD-012, REQ-VID-COM-017, REQ-VID-Q-004],
  ),
)