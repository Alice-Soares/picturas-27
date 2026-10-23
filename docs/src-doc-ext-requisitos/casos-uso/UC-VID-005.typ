#import "../template.typ": *

== UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo

*Estado de realização:* A extração está implementada para o projeto atual ou outro projeto existente. FA3 (criação de um projeto novo durante a operação) não está implementado; REQ-VID-FEX-010 tem realização parcial.

*Acompanhamento no MVP:* o servidor publica eventos de operação no projeto autorizado; o diálogo consulta o estado pela API. A apresentação percentual diretamente por WebSocket, prevista no contrato transversal, não é declarada como integralmente verificada.

=== Cabeçalho

#tab([Caso de uso UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo],
  tabela-campos(
    [ID do Caso de Uso], [UC-VID-005],
    [Nome], [Extrair Sequência de Fotogramas de um Vídeo],
    [Versão], [v1.0],
    [Autor], [Alice Soares, João Azevedo, Francisco Barros, Samuel Ferreira],
    [Data], [2026-10-14],
    [Objetivo], [Permitir ao utilizador extrair fotogramas de um vídeo e armazená-los como imagens do projeto para processamento posterior.],
    [Âmbito], [Módulo de vídeo do PictuRAS e integração com a biblioteca de imagens do projeto.],
    [Ator Principal], [Utilizador registado ou premium],
    [_Stakeholders_ e Interesses], [
      - *Utilizador*: pretende obter imagens a partir de um vídeo para análise, edição ou processamento posterior.
      - *Proprietário do Sistema*: deseja reutilizar as ferramentas de imagem existentes sobre conteúdo extraído de vídeo.
      - *Equipa de Desenvolvimento*: valida a integração entre extração, filas e armazenamento.
    ],
    [Pré-condições], [
      - O utilizador tem acesso a um projeto com um vídeo carregado e válido .
      - O ficheiro de vídeo está acessível ao sistema e no formato suportado.
      - O serviço de extração de fotogramas está disponível.
    ],
    [_Trigger_], [O utilizador seleciona um vídeo e escolhe a opção de extração de fotogramas.],
  ),
)

=== Fluxo Principal

#tab([UC-VID-005 — Fluxo principal],
  tabela(
    colunas: (1.2cm, 1fr, 1fr),
    [Passo], [Ação do Ator], [Resposta do Sistema],
    [1], [O utilizador abre a biblioteca de vídeos do projeto.], [O sistema apresenta as propriedades básicas do vídeo e a opção de extração de fotogramas.],
    [2], [O utilizador seleciona um vídeo e inicia a operação de extração.], [—],
    [3], [—], [O sistema apresenta os parâmetros disponíveis, como intervalo temporal, quantidade de fotogramas e formato de saída.],
    [4], [O utilizador define os parâmetros da extração.], [—],
    [5], [—], [O sistema calcula e apresenta a estimativa do número total de fotogramas.],
    [6], [O utilizador confirma a operação.], [—],
    [7], [—], [O sistema valida o perfil, o número de fotogramas e o espaço disponível.],
    [8], [—], [O sistema cria uma operação de processamento e publica a operação na fila de extração.],
    [9], [O utilizador acompanha o progresso.], [O sistema atualiza o estado por WebSocket.],
    [10], [—], [O sistema extrai cada fotograma e guarda-o no armazenamento como imagem do projeto.],
    [11], [—], [O sistema marca a operação como concluída e notifica o utilizador.],
    [12], [—], [As imagens ficam disponíveis na biblioteca para processamento posterior com ferramentas de imagem.],
  ),
)

=== Fluxos Alternativos

#tab([UC-VID-005 — Fluxos alternativos],
  tabela(
    colunas: (4cm, 1fr),
    [Fluxo], [Descrição (passo de origem: condição -> comportamento -> retorno)],
    [FA1 – Extração parcial], [No passo 4: Se o utilizador definir um intervalo temporal, o sistema extrai apenas os fotogramas desse intervalo e ignora o restante conteúdo.],
    [FA2 – Cancelamento da extração], [No passo 9: Durante a execução, o utilizador pode cancelar a operação; o sistema elimina os fotogramas temporários e termina a operação em estado cancelado.],
    [FA3 – Novo projeto para os fotogramas], [No passo 6: Se o utilizador optar por receber os fotogramas num projeto novo, o sistema cria esse projeto e organiza os ficheiros nesse contexto.],
  ),
)

=== Exceções

#tab([UC-VID-005 — Exceções],
  tabela(
    colunas: (1fr, 1fr),
    [Condição], [Comportamento do Sistema],
    [Codec do vídeo não suportado], [O sistema rejeita a operação e informa o utilizador dos codecs aceitáveis.],
    [Número de fotogramas excede o limite do perfil], [O sistema bloqueia a extração e pede que o utilizador reduza o intervalo ou o volume (RN2: 1000 registado, 5000 premium).],
    [Espaço de armazenamento insuficiente], [O sistema informa que não há espaço suficiente e não inicia o processamento.],
    [Falha a meio do processamento], [O sistema elimina os fotogramas temporários, marca a operação como falhada e notifica o utilizador.],
  ),
)

=== Pós-condições

#tabela(
  colunas: (4cm, 1fr),
  [Tipo], [Resultado],
  [Garantia de Sucesso], [Os fotogramas ficam armazenados como imagens do projeto e o vídeo original permanece inalterado.],
  [Garantia Mínima], [O vídeo original continua acessível, os fotogramas temporários são eliminados e o estado falhado ou cancelado fica registado.],
)

=== Regras de Negócio e Restrições

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Regra],
  [RN1], [O perfil anónimo não tem acesso a esta funcionalidade no MVP.],
  [RN2], [O limite é de 1000 fotogramas por operação para registados e 5000 para premium; os fotogramas são guardados em JPEG.],
  [RN3], [A extração de fotogramas não consome quota diária. Os limites de quantidade por perfil continuam aplicáveis.],
  [RN4], [Os fotogramas extraídos devem ser armazenados como imagens normais do projeto.],
  [RN5], [O vídeo original não pode ser alterado por esta funcionalidade.],
)

=== Assunções

#tabela(
  colunas: (1.4cm, 1fr),
  [ID], [Assunção],
  [A1], [O vídeo está disponível no armazenamento e acessível ao serviço de extração.],
  [A2], [A fila de processamento e o WebSocket já existentes suportam notificações de progresso e execução assíncrona.],
  [A3], [O FFmpeg ou equivalente está disponível para extrair fotogramas do vídeo.],
)

=== Questões em Aberto

#tabela(
  colunas: (1.4cm, 1fr, 5cm),
  [ID], [Questão], [Resolução],
  [Q1], [O sistema deve permitir pré-visualização dos primeiros fotogramas antes de confirmar a extração completa?], [Adiada para Fase 2 (no MVP apresenta-se a estimativa quantitativa antes da confirmação).],
  [Q2], [Os fotogramas extraídos devem ser guardados no mesmo projeto atual ou num projeto novo por predefinição?], [Decidida -> RN4 e FA3: guardados no projeto ativo por omissão, com opção de criar novo projeto no FA3.],
  [Q3], [A extração deve suportar filtros adicionais, como apenas fotogramas com alteração visual significativa?], [Adiada para Fase 3 (análise avançada de keyframes e deteção de corte de cena).],
)

