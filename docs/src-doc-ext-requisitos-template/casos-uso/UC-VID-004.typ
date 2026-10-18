#import "../template.typ": *

== UC-VID-004 — Converter Formato e Resolução de Vídeo

=== Cabeçalho

#tab([Caso de uso UC-VID-004 — Converter Formato e Resolução de Vídeo],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-004],
    [Nome], [Converter Formato e Resolução de Vídeo],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador converter um vídeo para um formato, codec e resolução compatíveis com o seu perfil e necessidade de uso.],
    [Âmbito], [Módulo de processamento de vídeo do PictuRAS, transcodificação e armazenamento de resultados.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende adaptar vídeos para diferentes dispositivos, plataformas e tamanhos de ficheiro.
      - *Proprietário do Sistema*: deseja manter controlo de qualidade, quota e compatibilidade do conteúdo.
      - *Equipa de Desenvolvimento*: valida o fluxo assíncrono de transcodificação e a integração com o armazenamento.
    ],
    [Pré-condições], [
      - O utilizador tem acesso a um projeto com um vídeo válido carregado .
      - O vídeo está no formato e codec suportados pelo sistema.
      - O serviço de transcodificação está disponível.
    ],
    [_Trigger_], [O utilizador seleciona um vídeo e escolhe a opção de conversão no painel de ferramentas.],
  ),
)

=== Fluxo Principal

#tab([UC-VID-004 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador abre a biblioteca de vídeos do projeto.], [O sistema apresenta o vídeo selecionado e as propriedades básicas do ficheiro.],
    [2], [O utilizador seleciona um vídeo e escolhe a opção "Converter Vídeo".], [—],
    [3], [—], [O sistema apresenta as propriedades do vídeo de origem e as opções de conversão disponíveis conforme o perfil.],
    [4], [O utilizador define o formato e a resolução de destino.], [—],
    [5], [—], [O sistema valida as opções e apresenta uma estimativa do tamanho final do ficheiro.],
    [6], [O utilizador confirma a operação.], [—],
    [7], [—], [O sistema cria uma operação de transcodificação e publica a operação na fila de processamento.],
    [8], [O utilizador acompanha o progresso.], [O sistema atualiza o estado da operação e comunica o progresso em tempo real.],
    [9], [—], [O sistema executa a transcodificação e guarda o vídeo resultante no armazenamento.],
    [10], [—], [O sistema atualiza o estado da operação para concluída e disponibiliza o ficheiro convertido ao utilizador.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-004 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Conversão em lote], [No passo 2: Se o utilizador selecionar vários vídeos, o sistema cria uma operação por vídeo e aplica os mesmos parâmetros a todos.],
    [FA2 – Cancelamento da conversão], [No passo 8: Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe a transcodificação, limpa ficheiros temporários e marca a operação como cancelada.],
    [FA3 – Perfil predefinido], [No passo 4: Se o utilizador selecionar um perfil predefinido, o sistema preenche automaticamente o formato, resolução e codec mais adequados.],
  ),
)

=== Exceções

#tab([UC-VID-004 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Formato de origem não suportado], [O sistema rejeita a conversão e informa o utilizador dos formatos aceites.],
    [Combinação de formato e codec inválida], [O sistema bloqueia a configuração e solicita uma combinação compatível.],
    [Quota de operações avançadas esgotada], [O sistema impede a conversão e informa que o limite do perfil foi atingido.],
    [Falha durante a transcodificação], [O sistema marca a operação como falhada, elimina ficheiros temporários e informa o utilizador.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O ficheiro convertido fica armazenado no projeto e disponível para visualização e transferência sem alterar o vídeo original.],
  [Garantia Mínima], [O vídeo original permanece intacto, os ficheiros temporários são removidos e a operação é registada com o estado final correto.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [O MVP aceita MP4 com vídeo H.264 e áudio AAC; outros formatos só são aceites se forem explicitamente adicionados à lista de combinações suportadas.],
  [RN2], [A resolução de saída não pode exceder 1920×1080 para registados nem 3840×2160 para premium.],
  [RN3], [Cada operação de conversão aceite conta como uma operação avançada; utilizadores premium não têm limite diário.],
  [RN4], [O áudio de saída deve ser AAC quando o contentor de saída for MP4.],
  [RN5], [O vídeo original deve permanecer inalterado após a conversão.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O FFmpeg ou ferramenta equivalente está disponível para realizar a transcodificação.],
  [A2], [A infraestrutura de filas e WebSocket suporta a atualização de progresso em tempo real.],
  [A3], [O armazenamento do projeto consegue guardar ficheiros de vídeo convertidos sem corrupção.],
)

*TODO:* REVER ESTAS RESOLUÇÕES DAS QUESTOES

=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [O sistema deve permitir conversão em paralelo para vários vídeos ou apenas uma transcodificação por vídeo de cada vez?], [Decidida -> Fila RabbitMQ gere tarefas assincronamente; paralelismo determinado pelos workers (REQ-VID-Q-001).],
  [Q2], [Os vídeos convertidos devem substituir o original ou ser armazenados como versões separadas do projeto?], [Decidida -> DQ-003 / RN5: conteúdo original é estritamente imutável; resultado criado como novo vídeo.],
  [Q3], [O sistema deve gerar perfis de conversão automáticos para utilizadores menos experientes?], [Decidida -> FA3: suporte a presets Web e Mobile no frontend.],
)

