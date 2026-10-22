#import "../template.typ": *

== UC-VID-006 — Concatenar Múltiplos Vídeos (Merge)

=== Cabeçalho

#tab([Caso de uso UC-VID-006 — Concatenar Múltiplos Vídeos (Merge)],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-006],
    [Nome], [Concatenar Múltiplos Vídeos (Merge)],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador selecionar dois ou mais vídeos da biblioteca, ordenar a sequência e uni-los num único vídeo de saída.],
    [Âmbito], [Módulo de processamento de vídeo do PictuRAS.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende juntar vários excertos de vídeo numa única compilação contínua.
      - *Proprietário do Sistema*: deseja assegurar o controlo de recursos computacionais e aplicar limites de duração total por perfil.
      - *Equipa de Desenvolvimento*: valida a transcodificação/normalização automática de vídeos com resoluções ou codecs heterogéneos.
    ],
    [Pré-condições], [
      - O utilizador tem sessão iniciada com perfil registado ou premium .
      - O projeto contém pelo menos 2 vídeos válidos e armazenados.
      - O utilizador registado dispõe de quota de operações avançadas.
    ],
    [_Trigger_], [O utilizador seleciona dois ou mais vídeos na biblioteca do projeto e escolhe a opção "Concatenar Vídeos".],
  ),
)

=== Fluxo Principal

#tab([UC-VID-006 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador acede à biblioteca do projeto e seleciona 2 ou mais vídeos.], [O sistema destaca os ficheiros selecionados e ativa a opção "Concatenar Vídeos".],
    [2], [O utilizador clica em "Concatenar Vídeos".], [O sistema apresenta o diálogo de concatenação, com seleção e ordenação dos vídeos de origem.],
    [3], [O utilizador define a ordem dos vídeos. A saída desta implementação é normalizada automaticamente para MP4, sem seleção manual de formato ou resolução.], [O sistema valida se a duração total acumulada e o número de ficheiros respeitam o limite do perfil do utilizador.],
    [4], [O utilizador confirma a operação de concatenação.], [O sistema valida a quota do utilizador e a disponibilidade do armazenamento.],
    [5], [—], [O sistema cria uma operação de concatenação e envia a operação para a fila de mensagens (RabbitMQ).],
    [6], [—], [O sistema notifica o utilizador que o processamento iniciou e atualiza o estado para "Em fila".],
    [7], [O utilizador acompanha o progresso.], [A interface consulta o estado da operação pela API e apresenta a situação atual (em fila, em processamento, concluída, falhada ou cancelada). Não se comprova uma percentagem em tempo real via WebSocket para esta UC.],
    [8], [—], [O sistema normaliza resoluções/codecs compatíveis, une os ficheiros na ordem definida, preserva as faixas de áudio compatíveis e guarda o resultado final.],
    [9], [—], [O sistema regista o novo vídeo na base de dados, associa-o ao projeto e consolida o consumo da quota previamente reservada quando aplicável.],
    [10], [—], [O vídeo resultante passa a constar da biblioteca do projeto e fica disponível para visualização.],
  ),
)


=== Fluxos Alternativos

#tab([UC-VID-006 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Normalização Automática de Resolução], [No passo 8: Se os vídeos tiverem parâmetros distintos, o processamento normaliza automaticamente os fluxos para possibilitar a concatenação. Não existe escolha manual de resolução de saída neste MVP.],
    [FA2 – Cancelamento pelo Utilizador], [No passo 7: Durante a execução, o utilizador pode cancelar a operação: o sistema interrompe o FFmpeg, elimina os ficheiros temporários gerados, marca a operação como cancelada e devolve a quota reservada.],
  ),
)

=== Exceções

#tab([UC-VID-006 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Duração total combinada excede o limite do perfil], [O sistema impede a submissão, destaca a duração excedida e sugere a remoção de vídeos ou upgrade de perfil (5 min registado, 30 min premium).],
    [Ficheiro de entrada corrompido ou inacessível], [O sistema assinala o erro de entrada e rejeita a operação ou marca-a como falhada quando o defeito só é detetável durante o processamento.],
    [Quota de operações avançadas esgotada], [O sistema rejeita a operação e informa que a quota não é suficiente; a indicação do horário de reposição não está comprovada nesta interface.],
    [Falha técnica durante a composição (FFmpeg)], [O sistema interceta o erro, marca a operação como falhada, limpa temporários, liberta a quota e disponibiliza o botão "Tentar novamente".],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O vídeo resultado da união está guardado na biblioteca do projeto e os vídeos originais permanecem intactos.],
  [Garantia Mínima], [Os vídeos originais permanecem inalterados, os dados parciais/temporários são eliminados, a operação fica marcada como falhada/cancelada e nenhuma quota é consumida.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [A concatenação exige pelo menos 2 vídeos e no máximo 5 para registados ou 15 para premium.],
  [RN2], [A duração total não pode exceder 5 minutos para registados ou 30 minutos para premium.],
  [RN3], [Os vídeos de origem nunca são alterados ou eliminados durante a concatenação.],
  [RN4], [Cada operação de concatenação aceite conta como uma operação avançada; utilizadores premium não têm limite diário.],
  [RN5], [Operações canceladas ou falhadas não consomem quota de operações avançadas.],
)


=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O ambiente de processamento dispõe de FFmpeg/FFprobe e dos recursos necessários à normalização e união dos vídeos.],
  [A2], [O armazenamento temporário dos workers tem capacidade suficiente para alojar os ficheiros intermédios durante o processo.],
)


=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [Deve ser possível adicionar efeitos de transição (ex: fade, crossfade) entre os vídeos concatenados no MVP?], [Adiada para Fase 3 (o MVP realiza união direta / direct cut sem transições gráficas).],
  [Q2], [Se um vídeo não tiver faixa de áudio, o sistema deve inserir áudio silencioso para manter a sincronização?], [Decidida para o MVP: é introduzido áudio silencioso quando uma entrada não tem faixa áudio, permitindo um fluxo concatenado sincronizado.],
)

