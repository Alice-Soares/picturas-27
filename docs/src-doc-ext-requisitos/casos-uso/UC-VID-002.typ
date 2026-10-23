#import "../template.typ": *

== UC-VID-002 — Recorte Temporal de Vídeo (Trim)

*Acompanhamento no MVP:* o servidor publica eventos de operação no projeto autorizado; o diálogo consulta o estado pela API. A apresentação percentual diretamente por WebSocket, prevista no contrato transversal, não é declarada como integralmente verificada.

=== Cabeçalho

#tab([Caso de uso UC-VID-002 — Recorte Temporal de Vídeo (Trim)],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-002],
    [Nome], [Recorte Temporal de Vídeo (Trim)],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador selecionar um intervalo temporal de um vídeo e gerar um novo ficheiro com apenas esse segmento.],
    [Âmbito], [Módulo de processamento de vídeo do PictuRAS.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende cortar um vídeo para manter apenas o trecho relevante.
      - *Proprietário do Sistema*: pretende validar a funcionalidade de edição de vídeo e o controlo de quotas.
      - *Equipa de Desenvolvimento*: valida a integração dos componentes do módulo de processamento de vídeo.
    ],
    [Pré-condições], [
      - O utilizador está autenticado com perfil registado ou premium .
      - O vídeo existe no projeto e está armazenado e acessível.
      - O vídeo tem formato e codec suportados pelo sistema.
    ],
    [_Trigger_], [O utilizador seleciona um vídeo e escolhe a opção de recorte temporal.],
  ),
)


=== Fluxo Principal

#tab([UC-VID-002 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador abre a biblioteca de vídeos do projeto.], [O sistema apresenta os vídeos disponíveis com metadados e miniaturas.],
    [2], [O utilizador seleciona um vídeo e escolhe a ferramenta de recorte temporal.], [—],
    [3], [—], [O sistema carrega a pré-visualização do vídeo e apresenta controlos para selecionar início e fim.],
    [4], [O utilizador define o início e o fim do segmento.], [O sistema valida que os valores são coerentes e pertencem à duração do vídeo.],
    [5], [O utilizador confirma a operação.], [O sistema valida os parâmetros do recorte e o estado do ficheiro.],
    [6], [—], [O sistema cria uma operação de processamento e publica-a na fila de vídeo a acrescentar ao RabbitMQ.],
    [7], [—], [O sistema informa o utilizador que o processo está em fila e em curso.],
    [8], [—], [O microsserviço de trim processa o vídeo com FFmpeg e comunica o progresso.],
    [9], [O utilizador acompanha o progresso.], [O sistema atualiza a barra de progresso via WebSocket.],
    [10], [—], [O sistema armazena o vídeo resultante no armazenamento do projeto.],
    [11], [—], [O sistema atualiza o estado da operação para concluído e informa o utilizador.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-002 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Cancelamento do processamento], [No passo 8/9: Durante a execução, o utilizador pode cancelar a operação. O sistema interrompe o processo, limpa ficheiros temporários e termina sem criar resultado.],
    [FA2 – Cancelamento antes do processamento], [No passo 6/7: Se o utilizador cancelar enquanto a operação ainda está em fila, o sistema cancela a operação sem criar resultado.],
    [FA4 – Pré-visualização antes de confirmar], [No passo 4: O utilizador ajusta os marcadores enquanto observa o vídeo e só depois confirma o recorte final.],
  ),
)

=== Exceções

#tab([UC-VID-002 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Intervalo temporal inválido], [O sistema rejeita a operação e pede ao utilizador para corrigir os tempos (início >= fim).],
    [Tempo inicial ou final fora da duração do vídeo], [O sistema apresenta mensagem de erro e mantém o vídeo original inalterado.],
    [Segmento com duração inferior a 1 segundo], [O sistema não inicia o processamento e solicita um intervalo válido (RN1).],
    [Formato ou codec não suportado], [O sistema rejeita o vídeo e informa que o ficheiro não pode ser processado por trim.],
    [Falha no FFmpeg durante o processamento], [O sistema marca a operação como falhada, limpa os ficheiros temporários.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [O vídeo recortado é armazenado no projeto e o vídeo original permanece intacto.],
  [Garantia Mínima], [Nenhuma alteração é aplicada ao vídeo original, a operação fica em estado falhado ou cancelado e os temporários são eliminados.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [A duração mínima do segmento recortado é de 1 segundo.],
  [RN2], [O vídeo original não pode ser alterado nem eliminado como resultado do recorte.],
  [RN3], [O recorte usa FFmpeg  e não consome quota diária. Está disponível sem limite diário para utilizadores autenticados.],
  [RN4], [Utilizadores anónimos não têm acesso à funcionalidade de recorte temporal.],
  [RN5], [O vídeo recortado mantém a faixa de áudio do segmento correspondente.],
  [RN6], [O processamento é assíncrono e exige o registo da operação na base de dados.],
  [RN7], [Em caso de falha ou cancelamento, o resultado parcial é eliminado e o vídeo original permanece intacto.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O FFmpeg está disponível para executar o recorte no servidor.],
  [A2], [O WebSocket mantém a conexão durante o processamento do vídeo.],
  [A3], [O SeaweedFS suporta o armazenamento do vídeo resultante sem corromper o ficheiro original.],
  [A4], [O projeto já contém vídeos válidos e acessíveis.],
  [A5], [A fila RabbitMQ consegue processar operações de recorte sem perda relevante.],
)


=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [O sistema deve permitir que o utilizador escolha um formato de saída diferente do original?], [Decidida: o recorte usa cópia dos fluxos de áudio e vídeo para manter os codecs da origem. Quando é necessário alterar contentor, codec ou resolução, usa-se o UC-VID-004.],
  [Q2], [Deve existir um limite máximo de duração por segmento no MVP?], [Decidida: não se acrescenta um limite específico ao recorte. O intervalo tem de ficar dentro da duração da origem, que já foi validada segundo os limites do perfil na UC-VID-001.],
  [Q3], [O vídeo recortado deve substituir o original ou criar um novo ficheiro no projeto?], [Decidida -> DQ-003 / RN2: original é imutável; resultado criado como novo conteúdo no projeto.],
  [Q4], [O sistema deve permitir a retoma de um recorte cancelado?], [Adiada para Fase 3 (no MVP o cancelamento limpa temporários sem suporte a retoma).],
  [Q5], [O utilizador deve conseguir visualizar o recorte antes de confirmar a operação?], [Decidida -> FA4 / A2: pré-visualização suportada na interface via player HTML5 nativo.],
)

