#import "../template.typ": *

== UC-VID-003 — Aplicar Ferramenta Existente aos Fotogramas de um Vídeo

=== Cabeçalho

#tab([Caso de uso UC-VID-003 — Aplicar Ferramenta Existente aos Fotogramas de um Vídeo],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-003],
    [Nome], [Aplicar Ferramenta Existente aos Fotogramas de um Vídeo],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador aplicar uma ferramenta de processamento de imagem a todos os fotogramas de um vídeo e obter um vídeo final processado.],
    [Âmbito], [Módulo de vídeo do PictuRAS, decomposição em fotogramas, processamento por ferramenta e recomposição do vídeo final.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende aplicar efeitos ou correções a um vídeo sem processar cada fotograma manualmente.
      - *Proprietário do Sistema*: deseja maximizar o valor das ferramentas existentes e validar a extensão do pipeline de processamento para vídeo.
      - *Equipa de Desenvolvimento*: valida a integração com ferramentas de imagem, filas e armazenamento em vídeo.
    ],
    [Pré-condições], [
      - O utilizador tem sessão iniciada com um perfil registado ou premium .
      - O vídeo está associado a um projeto válido e acessível no armazenamento.
      - Existe pelo menos uma ferramenta disponível para processamento de imagem.
      - O vídeo está dentro dos limites técnicos do perfil. Se a ferramenta selecionada for classificada como avançada, o utilizador Registado tem quota disponível.
    ],
    [_Trigger_], [O utilizador seleciona um vídeo e escolhe a opção de aplicar uma ferramenta a todos os fotogramas.],
  ),
)

=== Fluxo Principal

#tab([UC-VID-003 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador abre um projeto com vídeos disponíveis.], [O sistema apresenta a biblioteca de vídeos e a opção de processamento por fotogramas.],
    [2], [O utilizador seleciona um vídeo e escolhe a opção "Aplicar Ferramenta a Fotogramas".], [—],
    [3], [—], [O sistema valida o perfil e o vídeo. Se o utilizador selecionar uma ferramenta  classificada como avançada, verifica também a quota. Apresenta as ferramentas disponíveis e os parâmetros configuráveis.],
    [4], [O utilizador seleciona a ferramenta e define os parâmetros.], [—],
    [5], [—], [O sistema apresenta as opções de intervalo temporal e a taxa de fotogramas de saída.],
    [6], [O utilizador confirma o intervalo e a configuração.], [—],
    [7], [O utilizador confirma a execução.], [—],
    [8], [—], [O sistema valida o vídeo de origem, os parâmetros e a disponibilidade de armazenamento antes de iniciar o processamento.],
    [9], [—], [O sistema cria uma operação de processamento e inicia a extração dos fotogramas para armazenamento temporário.],
    [10], [—], [O sistema processa cada fotograma individualmente com a ferramenta selecionada e atualiza o progresso em tempo real.],
    [11], [—], [O sistema recompõe o vídeo resultante, preservando a faixa de áudio original e armazena o ficheiro no projeto do utilizador.],
    [12], [O utilizador visualiza o resultado.], [O sistema disponibiliza o vídeo processado para pré-visualização e transferência.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-003 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Encadeamento de ferramentas], [No passo 4: Se o utilizador selecionar mais do que uma ferramenta em sequência, o sistema aplica cada transformação por ordem ao mesmo fotograma antes de recompor o vídeo final.],
    [FA2 – Reprocessamento de fotograma], [No passo 10: Se um fotograma falhar, o sistema tenta processá-lo novamente. Se a falha persistir, a operação termina como falhada, elimina o resultado parcial e informa o utilizador.],
    [FA3 – Cancelamento do processamento], [No passo 9-11: Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe os fotogramas pendentes, limpa ficheiros temporários e marca a operação como cancelada.],
  ),
)

=== Exceções

#tab([UC-VID-003 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Vídeo com codec não suportado], [O sistema rejeita a operação e informa que o formato ou codec do vídeo não é compatível com a extração por fotogramas.],
    [Ferramenta incompatível com fotogramas], [Se a ferramenta selecionada gere metadados em vez de imagem (e.g., contagem/deteção), o sistema informa o utilizador e solicita confirmação antes de continuar.],
    [Quota esgotada para ferramenta avançada], [Se o utilizador Registado selecionar uma ferramenta classificada como avançada e não tiver quota, o sistema bloqueia a operação e informa-o. As ferramentas que não estão sujeitas a quota continuam disponíveis.],
    [Falha persistente no processamento de um fotograma], [O sistema marca a operação como falhada, elimina os fotogramas/resultados temporários, mantém o vídeo original intacto e devolve a quota apenas se tiver sido reservada para uma ferramenta avançada.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O vídeo processado fica armazenado no projeto, mantém a faixa de áudio original e permanece disponível para visualização e transferência.],
  [Garantia Mínima], [O vídeo original continua inalterado, os ficheiros temporários são eliminados e o sistema regista a operação com o estado final adequado.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [Utilizadores anónimos não têm acesso a esta funcionalidade.],
  [RN2], [A quota diária só se aplica ao utilizador Registado quando a operação usa uma ferramenta classificada como avançada. Reserva-se uma unidade por operação, independentemente do número de fotogramas. Utilizadores Premium não têm limite diário para estas ferramentas.],
  [RN3], [O vídeo deve respeitar os limites do perfil: 5 minutos e 1920×1080 para registados; 30 minutos e 3840×2160 para premium.],
  [RN4], [O vídeo resultante mantém a faixa de áudio original e a resolução do vídeo de origem.],
  [RN5], [As ferramentas de IA só podem ser aplicadas a intervalos limitados e não ao vídeo completo, salvo decisão posterior documentada.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O sistema já possui microsserviços de processamento de imagem que aceitam um fotograma isolado como entrada.],
  [A2], [A infraestrutura de filas e armazenamento suporta a criação temporária de milhares de fotogramas durante o processamento.],
  [A3], [O FFmpeg ou equivalente está disponível para a decomposição e recomposição do vídeo.],
)
=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [O sistema deve permitir que o utilizador escolha um intervalo temporal específico para reduzir o número de fotogramas processados?], [Decidida: o utilizador pode definir um intervalo temporal, conforme o passo 5 do fluxo principal e o requisito `REQ-VID-FRM-004`.],
  [Q2], [Qual deve ser o comportamento quando uma ferramenta de IA gera metadados em vez de imagem?], [Decidida -> Exceção 2 / RN5: apenas ferramentas que geram imagem reconstroem vídeo; deteções operam sobre fotogramas isolados.],
  [Q3], [Deve existir um limite de paralelismo para o processamento dos fotogramas de um vídeo em função do perfil do utilizador?], [Adiada para Fase 2 (dimensionamento de infraestrutura e workers RabbitMQ).],
)

