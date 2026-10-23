#import "../template.typ": *

== UC-VID-007 — Gerir Áudio do Vídeo (Remover, Substituir ou Extrair)

*Acompanhamento no MVP:* o servidor publica eventos de operação no projeto autorizado; o diálogo consulta o estado pela API. A apresentação percentual diretamente por WebSocket, prevista no contrato transversal, não é declarada como integralmente verificada.

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
    [2], [O utilizador escolhe a operação desejada e confirma.], [O sistema valida o perfil e, para extração, a existência de áudio no ficheiro de origem. Para substituição, solicita um ficheiro de áudio ou vídeo e valida uma faixa sonora.],
    [3], [—], [O sistema cria uma operação de processamento de áudio e coloca-o na fila.],
    [4], [—], [O sistema notifica o utilizador que o processamento está em curso.],
    [5], [O utilizador acompanha o estado.], [O sistema atualiza o progresso em tempo real via WebSocket.],
    [6], [—], [O sistema, com FFmpeg, remove a faixa de áudio, extrai-a para M4A/AAC ou substitui-a pela faixa escolhida pelo utilizador.],
    [7], [—], [Para remoção ou substituição, o sistema guarda o novo vídeo MP4 no projeto. Para extração, prepara um M4A/AAC temporário para transferência autenticada.],
    [8], [—], [O sistema regista a conclusão. Os vídeos derivados são associados ao projeto; o áudio extraído não é adicionado à biblioteca.],
    [9], [—], [O sistema disponibiliza o vídeo derivado na biblioteca ou, na extração, a transferência do áudio para o dispositivo do utilizador.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-007 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Vídeo sem faixa sonora original], [No passo 2: Para remover áudio, o sistema apresenta o aviso "Este vídeo já não tem faixa de áudio" e termina sem criar resultado. Para extrair áudio, apresenta um erro e termina sem criar resultado.],
    [FA2 – Substituição com duração diferente], [No passo 2: O utilizador pode escolher opcionalmente o intervalo da faixa a utilizar. Se o áudio for mais curto, o vídeo fica sem som no restante tempo; se for mais longo, o sistema corta-o no fim do vídeo.],
    [FA3 – Cancelamento pelo utilizador], [No passo 5: Durante a execução, o utilizador pode cancelar a operação: o sistema interrompe o processo, limpa temporários, repõe o estado como cancelado.],
  ),
)

=== Exceções

#tab([UC-VID-007 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Erro técnico no processamento (FFmpeg crash)], [O sistema interceta o erro, marca a operação como falhada e elimina os ficheiros parciais.],
    [Ficheiro corrompido], [O sistema aborta a operação, marca como falhado e apresenta mensagem explicativa.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O vídeo silenciado ou com áudio substituído fica na biblioteca; o áudio extraído é transferido para o dispositivo do utilizador sem ser adicionado à biblioteca. O original permanece intacto.],
  [Garantia Mínima], [O vídeo original permanece inalterado, os temporários são limpos, a operação fica marcada como falhado/cancelado e a operação não deixa resultados parciais.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [Utilizadores anónimos não têm acesso a esta funcionalidade.],
  [RN2], [As operações de gestão de áudio usam FFmpeg e não consomem quota diária. Estão disponíveis sem limite diário para utilizadores autenticados.],
  [RN3], [O vídeo original nunca é substituído. Cada vídeo derivado é novo conteúdo; o áudio extraído é disponibilizado apenas para transferência.],
  [RN4], [Operações canceladas ou falhadas, e operações terminadas sem efeito por falta de áudio, não consomem quota.],
  [RN5], [O áudio de substituição pode ser MP3, M4A/AAC ou vídeo com faixa sonora; de um vídeo usa-se apenas a primeira faixa de áudio, convertida para AAC no resultado MP4.],
  [RN6], [Na extração, o destino é o dispositivo do utilizador através de transferência autenticada; a associação à biblioteca de REQ-VID-COM-018 tem esta exceção explícita.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O FFprobe consegue detetar previamente se o vídeo contém streams de áudio ativos.],
  [A2], [O armazenamento suporta novos vídeos; Projects Service e gateway transmitem o M4A/AAC temporário ao cliente autorizado, com limpeza após transferência ou expiração.],
)

=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [Se o vídeo tiver várias faixas de áudio, o sistema deve permitir escolher qual delas remover ou extrair?], [Adiada para Fase 3 (o MVP manipula a primeira faixa de áudio identificada por FFprobe).],
)

