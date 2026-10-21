#import "../template.typ": *

== UC-VID-007 — Gerir Áudio do Vídeo (Remover, Substituir ou Extrair)

=== Cabeçalho

#tab([Caso de uso UC-VID-007 — Gerir Áudio do Vídeo],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-007],
    [Nome], [Gerir Áudio do Vídeo],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador remover o áudio de um vídeo, substituir a faixa sonora por um ficheiro escolhido ou extrair a faixa sonora como ficheiro independente.],
    [Âmbito], [Módulo de processamento de vídeo e gestão de conteúdos do PictuRAS.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende isolar o áudio ou criar um vídeo sem som para fins de edição.
      - *Proprietário do Sistema*: garantir controlo de quotas e armazenamento adequado para ficheiros de áudio gerados.
      - *Equipa de Desenvolvimento*: validar a manipulação isolada de streams de áudio através de ferramentas de backend.
    ],
    [Pré-condições], [
      - O utilizador tem sessão iniciada com perfil registado ou premium .
      - O vídeo selecionado está disponível no projeto.
      - O utilizador tem quota disponível se a operação estiver sujeita à política de operações avançadas.
    ],
    [_Trigger_], [O utilizador seleciona um vídeo na biblioteca e escolhe a opção "Gerir Áudio".],
  ),
)

=== Fluxo Principal

#tab([UC-VID-007 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador seleciona um vídeo na biblioteca e clica em "Gerir Áudio".], [O sistema apresenta as opções *Remover Áudio*, *Substituir Áudio* e *Extrair Faixa de Áudio*.],
    [2], [O utilizador escolhe a operação desejada e confirma.], [O sistema valida o perfil, a quota aplicável e, para extração, a existência de áudio no ficheiro de origem. Para substituição, solicita um ficheiro de áudio ou vídeo e valida uma faixa sonora.],
    [3], [—], [O sistema cria uma operação de processamento de áudio e coloca-o na fila.],
    [4], [—], [O sistema notifica o utilizador que o processamento está em curso.],
    [5], [O utilizador acompanha o estado.], [O sistema atualiza o progresso em tempo real via WebSocket.],
    [6], [—], [O sistema, com FFmpeg, remove a faixa de áudio, extrai-a para M4A/AAC ou substitui-a pela faixa escolhida pelo utilizador.],
    [7], [—], [O sistema guarda o novo vídeo MP4 no armazenamento do projeto; na extração, guarda também o ficheiro M4A com áudio AAC.],
    [8], [—], [O sistema regista o novo item na base de dados, associa-o ao projeto e aplica a regra de quota definida para a operação.],
    [9], [—], [O sistema notifica a conclusão com sucesso e disponibiliza o novo ficheiro na biblioteca do projeto.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-007 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Vídeo sem faixa sonora original], [No passo 2: Para remover áudio, o sistema apresenta o aviso "Este vídeo já não tem faixa de áudio" e termina sem criar resultado nem consumir quota. Para extrair áudio, apresenta um erro e também não cria resultado nem consome quota.],
    [FA2 – Substituição com duração diferente], [No passo 2: O utilizador pode escolher opcionalmente o intervalo da faixa a utilizar. Se o áudio for mais curto, o vídeo fica sem som no restante tempo; se for mais longo, o sistema corta-o no fim do vídeo.],
    [FA3 – Cancelamento pelo utilizador], [No passo 5: Durante a execução, o utilizador pode cancelar a operação: o sistema interrompe o processo, limpa temporários, repõe o estado como cancelado e não desconta quota.],
  ),
)

=== Exceções

#tab([UC-VID-007 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Quota de operações avançadas esgotada], [O sistema impede a submissão da operação e indica o estado atual da quota.],
    [Erro técnico no processamento (FFmpeg crash)], [O sistema interceta o erro, marca a operação como falhado, elimina ficheiros parciais e liberta a quota.],
    [Ficheiro corrompido], [O sistema aborta a operação, marca como falhado e apresenta mensagem explicativa.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O novo ficheiro (vídeo silenciado, vídeo com novo som ou áudio extraído) está guardado na biblioteca; o vídeo original permanece intacto.],
  [Garantia Mínima], [O vídeo original permanece inalterado, os temporários são limpos, a operação fica marcada como falhado/cancelado e nenhuma quota é consumida.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [Utilizadores anónimos não têm acesso a esta funcionalidade.],
  [RN2], [Cada operação de gestão de áudio aceite conta como uma operação avançada para o utilizador registado; utilizadores premium não têm limite diário.],
  [RN3], [O vídeo original nunca é substituído pelo resultado; cada resultado é guardado como novo conteúdo.],
  [RN4], [Operações canceladas ou falhadas, e operações terminadas sem efeito por falta de áudio, não consomem quota.],
  [RN5], [O áudio de substituição pode ser MP3, M4A/AAC ou vídeo com faixa sonora; de um vídeo usa-se apenas a primeira faixa de áudio, convertida para AAC no resultado MP4.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O FFprobe consegue detetar previamente se o vídeo contém streams de áudio ativos.],
  [A2], [O SeaweedFS suporta o armazenamento de novos vídeos e ficheiros M4A no mesmo projeto, através da camada de armazenamento existente.],
)

=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [Se o vídeo tiver várias faixas de áudio, o sistema deve permitir escolher qual delas remover ou extrair?], [Adiada para Fase 3 (o MVP manipula a primeira faixa de áudio identificada por FFprobe).],
)

