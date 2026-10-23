#import "../template.typ": *

== UC-VID-001 — Submeter Vídeo para Processamento

*Estado de realização:* O fluxo individual está implementado. FA2 mantém o requisito de lote, mas o seletor atual aceita apenas um ficheiro por submissão; a alternativa está parcialmente implementada.

=== Cabeçalho

#tab([Caso de uso UC-VID-001 — Submeter Vídeo para Processamento],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-001],
    [Nome], [Submeter Vídeo para Processamento],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador carregar um vídeo válido para o projeto e torná-lo disponível para processamento posterior.],
    [Âmbito], [Extensão do módulo de projetos e conteúdos multimédia do PictuRAS, integrada com o serviço de armazenamento de objetos e pipeline de processamento de vídeo.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende carregar e guardar vídeos sem perda de dados.
      - *Proprietário do Sistema*: deseja validar as regras de quota e perfil para vídeo.
      - *Equipa de Desenvolvimento*: valida upload, armazenamento e metadados de vídeo.
    ],
    [Pré-condições], [
      - O utilizador tem sessão válida com perfil registado ou premium .
      - O utilizador tem um projeto ativo ou pode criar um novo.
      - O serviço de armazenamento de objetos está disponível.
      - O ficheiro de vídeo encontra-se no sistema local e é legível.
    ],
    [_Trigger_], [O utilizador seleciona um ficheiro de vídeo e escolhe a opção de submissão ao projeto.],
  ),
)

=== Fluxo Principal

#tab([UC-VID-001 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador abre a biblioteca de conteúdos ou o projeto.], [O sistema apresenta a interface de upload com suporte para ficheiros de vídeo.],
    [2], [O utilizador seleciona um ficheiro de vídeo local.], [O sistema valida a extensão e o tipo de ficheiro.],
    [3], [—], [O sistema verifica a permissão do perfil e, quando aplicável, os limites definidos para a submissão.],
    [4], [—], [O sistema envia o ficheiro para o serviço de armazenamento.],
    [5], [O utilizador aguarda a conclusão da transferência.], [O sistema confirma o estado da transferência.],
    [6], [—], [O sistema conclui a transferência e verifica a integridade do ficheiro.],
    [7], [—], [O sistema extrai os metadados do vídeo (codec, resolução, duração, fps e tamanho).],
    [8], [—], [O sistema valida a duração, a resolução e o fps contra os limites do perfil.],
    [9], [—], [O sistema cria o registo correspondente na base de dados.],
    [10], [—], [O sistema associa o vídeo ao projeto e torna-o disponível para visualização e processamento posterior.],
    [11], [—], [O sistema informa o sucesso da operação; a submissão não consome a quota diária de operações avançadas, que continua a aplicar-se às operações de processamento.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-001 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Upload duplicado], [No passo 2: Se o vídeo tiver o mesmo nome de um ficheiro já existente no projeto, o sistema apresenta as opções de manter ambos ou cancelar; substituir fica fora do MVP.],
    [FA2 – Upload em lote], [No passo 2: Se o utilizador selecionar vários vídeos, o sistema valida cada elemento individualmente e só associa ao projeto os ficheiros válidos.],
    [FA3 – Cancelamento do upload], [Durante o passo 5: Durante a transferência, o utilizador pode cancelar a operação; o sistema interrompe a transferência e remove o objeto.],
    [FA4 – Tentativa por perfil anónimo], [No passo 1/2: Se um utilizador anónimo tentar submeter um vídeo, o sistema rejeita a operação, explica que a funcionalidade exige uma conta registada e não cria objeto nem consome quota.],
  ),
)

=== Exceções

#tab([UC-VID-001 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Formato ou codec não suportado], [O sistema rejeita o ficheiro com mensagem de erro e não guarda qualquer versão parcial.],
    [Tamanho do ficheiro excede um limite aplicável], [O sistema bloqueia o upload e informa o utilizador do máximo permitido para o seu perfil (100 MB registado, 1 GB premium).],
    [Duração do vídeo excede um limite aplicável], [O sistema rejeita o vídeo, remove ficheiros temporários e não consome quota (5 min registado, 30 min premium).],
    [Falha de rede durante o upload], [O sistema informa o utilizador do erro e remove o objeto temporário, se tiver sido criado. A retoma não faz parte do MVP.],
    [Armazenamento indisponível], [O sistema informa que o serviço de armazenamento está temporariamente indisponível e não cria o registo do vídeo.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O objeto de vídeo fica armazenado no sistema, é referenciado pelo registo da base de dados, fica associado ao projeto e disponível para processamento posterior.],
  [Garantia Mínima], [Nenhum objeto temporário, ficheiro parcial ou registo inconsistente permanece associado ao projeto; a quota só é consumida conforme a regra definida e o utilizador recebe uma mensagem de erro clara.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [Utilizadores anónimos não podem submeter vídeos no MVP; podem continuar a utilizar as funcionalidades de imagem permitidas pelo sistema.],
  [RN2], [Utilizadores registados podem submeter vídeos até 100 MB, 5 minutos, 1920×1080 e 60 fps.],
  [RN3], [Utilizadores premium podem submeter vídeos até 1 GB, 30 minutos, 3840×2160 e 60 fps.],
  [RN4], [O MVP aceita vídeo MP4 com vídeo H.264 e, quando exista áudio, AAC; ficheiros sem faixa de vídeo ou com combinações incompatíveis são rejeitados.],
  [RN5], [A submissão de vídeo não é contabilizada como operação diária; a quota aplica-se às operações de processamento classificadas como avançadas, de acordo com a política existente.],
  [RN6], [Uma submissão rejeitada, cancelada ou falhada não consome quota nem deixa objetos parciais associados ao projeto.],
  [RN7], [A submissão não pode deixar o projeto apontar para um objeto inexistente, parcial ou corrompido.],
  [RN8], [A referência persistida deve identificar o utilizador, o projeto, o estágio do conteúdo e o objeto armazenado sem depender do nome original do ficheiro.],
  [RN9], [Os limites usam unidades decimais: 1 MB corresponde a 1 000 000 bytes e 1 GB a 1 000 000 000 bytes.],
  [RN10], [A submissão deve receber o ficheiro num temporário em disco, sem manter o vídeo completo em memória.],
)



=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O SeaweedFS continuará a ser o armazenamento de objetos e será acedido através da fachada S3 existente; o suporte a vídeos reutiliza buckets por utilizador com prefixos/chaves próprios para vídeo.],
  [A2], [O serviço de projetos e a fachada de armazenamento serão estendidos para aceitar vídeos sem quebrar o fluxo atual de imagens.],
  [A3], [Será disponibilizado um componente de análise de vídeo, como FFmpeg/FFprobe ou equivalente, para extrair metadados e validar o contentor MP4, os codecs, a duração, a resolução e o fps.],
  [A4], [O projeto do utilizador já está operacional para receber novos conteúdos.],
  [A5], [O serviço de armazenamento e a base de dados estão disponíveis durante o processo de submissão.],
)

=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [Os vídeos usam os buckets por utilizador já adotados pela fachada S3, com uma nova convenção de chave/estágio, ou devem usar um bucket separado?], [Decidida para o MVP: reutiliza-se a fachada e o bucket por utilizador existentes, com o estágio `video-src` e uma chave própria para cada objeto. Não se cria um bucket separado.],
  [Q2], [O sistema deve gerar automaticamente uma miniatura para cada vídeo submetido com sucesso?], [Adiada para Fase 2 (no MVP a pré-visualização apoia-se no elemento HTML5 nativo).],
  [Q3], [A interface deve suportar drag-and-drop além do seletor de ficheiros tradicional?], [Adiada para Fase 2 (melhoria de interface; MVP suporta seletor de ficheiros).],
  [Q4], [Deve existir um limite máximo de uploads simultâneos por utilizador?], [Adiada para Fase 2 (no MVP cada submissão é individual e sequencial no frontend).],
)
