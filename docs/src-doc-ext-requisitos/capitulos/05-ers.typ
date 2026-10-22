#import "../template.typ": *

// 5. Especificação de Requisitos do Sistema (ERS)
// 5.1 e 5.2 em páginas na horizontal (tabelas largas). Para voltar ao vertical, retirar o #paisagem[ ].
#paisagem[
= Especificação de Requisitos do Sistema (ERS)

#orientacao[
  Catálogo único dos requisitos de todas as funcionalidades de vídeo, ordenado por ID. A coluna *Origem* indica o
  caso de uso e o elemento de onde vem cada requisito (e.g., `UC-VID-001, passo 3`, `UC-VID-001/RN1`); um requisito comum a vários casos de uso (e.g.,
  `REQ-VID-SUBMIT-001`) aparece uma só vez, com todas as origens.
  Padrão: _O sistema deve [ação] [objeto] [condição/limite]_. Cada requisito é atómico, verificável,
  inequívoco, sem solução técnica e rastreável. Prioridade segundo MoSCoW (_Must_ / _Should_ / _Could_ / _Won't_).
  *Justificação*: porque é que o requisito é necessário. *Novo/Alt*: NOVO = não existia no PictuRAS;
  ALT = altera algo existente — nesse caso indiquem o elemento de base afetado (e.g., RF13, RNF48, UC04).
]


Este capítulo apresenta o catálogo consolidado de requisitos da extensão de vídeo para a plataforma PictuRAS, derivado dos casos de uso de `UC-VID-001` a `UC-VID-007`. A indicação *NOVO* identifica capacidades inéditas no sistema, enquanto *ALT* indica alterações ou extensões a mecanismos existentes (e.g., regras de negócio, limitações de perfil ou gestão de quotas).


== Requisitos Funcionais



#tab([Requisitos funcionais],
  tabela(
    colunas: (3.2cm, 1fr, 1.6cm, 1.5cm, 3.2cm, 3.8cm, 4.2cm),
    tamanho: 8pt,
    [ID], [Requisito], [Prioridade], [Novo/ Alt], [Origem], [Justificação], [Critério de aceitação],

    // --- SUBMISSÃO DE VÍDEO (UC-VID-001) ---
    [REQ-VID-SUB-001], [O sistema deve permitir a submissão de vídeo a utilizadores registados ou premium autenticados.], [#must], [ALT (RF23)], [UC-VID-001, pré-condições, RN1], [Garante controlo de acesso aos recursos de vídeo.], [Dado um utilizador autenticado (registado/premium), Quando submete um vídeo válido, Então o sistema aceita o ficheiro.],
    [REQ-VID-SUB-002], [O sistema deve rejeitar a submissão de vídeo por utilizadores anónimos.], [#must], [ALT (RF23)], [UC-VID-001, FA4], [Reserva capacidades computacionais de vídeo a contas registadas.], [Dado um utilizador anónimo, Quando tenta submeter um vídeo, Então o sistema recusa e solicita autenticação.],
    [REQ-VID-SUB-003], [O sistema deve rejeitar a submissão de vídeo com uma sessão inválida.], [#must], [ALT (RF23)], [UC-VID-001, FA4], [Segurança e integridade de sessões de utilizador.], [Dado um pedido com token/sessão expirado, Quando submete um vídeo, Então o sistema nega o acesso.],
    [REQ-VID-SUB-004], [O sistema deve iniciar a validação do ficheiro submetido antes de o associar ao projeto.], [#must], [NOVO], [UC-VID-001, passos 6-8], [Evita associar ficheiros corrompidos ou inválidos ao projeto.], [Dado um ficheiro submetido, Quando chega ao sistema, Então é validado antes da persistência no projeto.],
    [REQ-VID-SUB-005], [O sistema deve aceitar no MVP o contentor MP4.], [#must], [NOVO], [UC-VID-001, RN4], [Garante compatibilidade com o formato standard do MVP.], [Dado um ficheiro no formato MP4, Quando é submetido, Então é aceite pelo sistema.],
    [REQ-VID-SUB-006], [O sistema deve aceitar no MVP vídeo codificado com H.264.], [#must], [NOVO], [UC-VID-001, RN4], [Garante suporte ao codec de vídeo H.264.], [Dado um vídeo com codec H.264, Quando é submetido, Então a validação do codec tem sucesso.],
    [REQ-VID-SUB-007], [O sistema deve aceitar áudio AAC quando o vídeo submetido tiver faixa sonora.], [#must], [NOVO], [UC-VID-001, RN4], [Garante suporte ao codec de áudio AAC.], [Dado um vídeo MP4 com áudio AAC, Quando é submetido, Então a faixa de áudio é aceite.],
    [REQ-VID-SUB-008], [O sistema deve rejeitar contentores de vídeo não suportados.], [#must], [NOVO], [UC-VID-001, exceções], [Impede o processamento de formatos incompatíveis.], [Dado um ficheiro AVI/MKV não suportado no MVP, Quando submetido, Então é devolvido um erro de formato.],
    [REQ-VID-SUB-009], [O sistema deve validar que o ficheiro contém uma faixa de vídeo legível.], [#must], [NOVO], [UC-VID-001, RN4], [Evita aceitar ficheiros sem stream de vídeo ou danificados.], [Dado um ficheiro sem faixa de vídeo válida, Quando submetido, Então o sistema rejeita a submissão.],
    [REQ-VID-SUB-010], [O sistema deve calcular o tamanho do ficheiro antes de o associar ao projeto.], [#must], [NOVO], [UC-VID-001, passos 6-8], [Permite validar os limites do perfil de utilizador.], [Dado um ficheiro recebido, Quando é analisado, Então o seu tamanho exato é calculado.],
    [REQ-VID-SUB-011], [O sistema deve extrair a duração do vídeo antes de o associar ao projeto.], [#must], [NOVO], [UC-VID-001, passos 6-8], [Permite validar o limite de duração permitido.], [Dado um vídeo recebido, Quando analisado com FFprobe, Então a duração em segundos é registada.],
    [REQ-VID-SUB-012], [O sistema deve extrair o codec do vídeo antes de o associar ao projeto.], [#must], [NOVO], [UC-VID-001, passo 7], [Validação de compatibilidade técnica.], [Dado um vídeo válido, Quando analisado, Então o metadado do codec de vídeo é extraído.],
    [REQ-VID-SUB-013], [O sistema deve extrair a resolução do vídeo antes de o associar ao projeto.], [#must], [NOVO], [UC-VID-001, passo 7], [Validação de limites de resolução do perfil.], [Dado um vídeo válido, Quando analisado, Então a largura e altura em pixéis são extraídas.],
    [REQ-VID-SUB-014], [O sistema deve extrair a taxa de fotogramas antes de associar o vídeo ao projeto.], [#must], [NOVO], [UC-VID-001, passo 7], [Validação do limite de FPS do perfil.], [Dado um vídeo válido, Quando analisado, Então a taxa de fotogramas (FPS) é registada.],
    [REQ-VID-SUB-015], [O sistema deve criar uma referência de vídeo apenas depois de todas as validações passarem.], [#must], [ALT (RF13)], [UC-VID-001, passos 9-10, RN7-RN8], [Garante consistência da base de dados e armazenamento.], [Dado um vídeo que passa em todas as validações, Quando o processo termina, Então é criada a referência no projeto.],
    [REQ-VID-SUB-016], [O sistema deve rejeitar vídeos superiores a 100 MB para utilizadores registados que não sejam premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN2], [Aplica restrição de quota ao perfil Registado.], [Dado um utilizador registado, Quando submete um vídeo > 100 MB, Então a submissão é rejeitada.],
    [REQ-VID-SUB-017], [O sistema deve rejeitar vídeos superiores a 5 minutos para utilizadores registados que não sejam premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN2], [Aplica limite temporal ao perfil Registado.], [Dado um utilizador registado, Quando submete um vídeo > 5 min, Então o sistema recusa a operação.],
    [REQ-VID-SUB-018], [O sistema deve rejeitar vídeos cuja largura exceda 1920 ou cuja altura exceda 1080 para utilizadores registados que não sejam premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN2], [Aplica limite independente à largura e altura do perfil Registado.], [Dado um utilizador registado, Quando submete uma dimensão acima do limite, Então o sistema rejeita o ficheiro.],
    [REQ-VID-SUB-019], [O sistema deve rejeitar vídeos acima de 60 fps para utilizadores registados que não sejam premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN2], [Aplica limite de framerate ao perfil Registado.], [Dado um utilizador registado, Quando submete um vídeo a 120 fps, Então o sistema recusa o vídeo.],
    [REQ-VID-SUB-020], [O sistema deve rejeitar vídeos superiores a 1 GB para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN3], [Aplica restrição máxima ao perfil Premium.], [Dado um utilizador premium, Quando submete um vídeo > 1 GB, Então o sistema rejeita a submissão.],
    [REQ-VID-SUB-021], [O sistema deve rejeitar vídeos superiores a 30 minutos para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN3], [Aplica limite temporal ao perfil Premium.], [Dado um utilizador premium, Quando submete um vídeo > 30 min, Então o sistema recusa a operação.],
    [REQ-VID-SUB-022], [O sistema deve rejeitar vídeos cuja largura exceda 3840 ou cuja altura exceda 2160 para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN3], [Aplica limite independente à largura e altura do perfil Premium.], [Dado um utilizador premium, Quando submete uma dimensão acima do limite, Então o sistema rejeita o ficheiro.],
    [REQ-VID-SUB-023], [O sistema deve rejeitar vídeos acima de 60 fps para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-001, RN3], [Aplica limite de framerate ao perfil Premium.], [Dado um utilizador premium, Quando submete um vídeo a 120 fps, Então o sistema recusa o vídeo.],
    [REQ-VID-SUB-024], [O sistema deve remover objetos temporários e não criar referências persistentes quando a submissão for rejeitada, cancelada ou falhar.], [#must], [NOVO], [UC-VID-001, FA3, exceções], [Garante a limpeza do armazenamento e impede lixo na BD.], [Dado um erro na submissão, Quando o fluxo falha, Então os ficheiros parciais são eliminados do armazenamento.],
    [REQ-VID-SUB-025], [O sistema não deve contabilizar a submissão de vídeo na quota diária de operações avançadas.], [#must], [ALT (RNF48)], [UC-VID-001, RN5], [A submissão simples não consome créditos de transformação.], [Dado um utilizador registado, Quando submete um vídeo, Então o seu contador de operações não diminui.],
    [REQ-VID-SUB-026], [O sistema deve associar a referência de vídeo ao utilizador que efetuou a submissão.], [#must], [ALT (RF13)], [UC-VID-001, passos 9-10], [Garante a posse e controlo de acessos.], [Dado um vídeo válido, Quando é criado no sistema, Então fica associado ao ID do utilizador autor.],
    [REQ-VID-SUB-027], [O sistema deve associar a referência de vídeo ao projeto selecionado.], [#must], [ALT (RF13)], [UC-VID-001, passos 9-10], [Organização dos recursos no projeto correto.], [Dado um vídeo submetido, Quando processado com sucesso, Então surge listado no projeto ativo.],
    [REQ-VID-SUB-028], [O sistema deve associar os metadados extraídos à referência de vídeo.], [#must], [ALT (RF13)], [UC-VID-001, passos 9-10], [Permite consulta rápida das características do vídeo na interface.], [Dado a conclusão da submissão, Quando os metadados são gravados, Então ficam acessíveis na API do projeto.],
    [REQ-VID-SUB-029], [O sistema deve associar o objeto armazenado à referência de vídeo.], [#must], [ALT (RF13)], [UC-VID-001, passos 9-10], [Mapeamento entre metadados na BD e ficheiro no SeaweedFS.], [Dado a gravação do ficheiro no S3/SeaweedFS, Quando criada a referência, Então o caminho do objeto é mapeado.],
    [REQ-VID-SUB-030], [O sistema deve devolver um resultado independente para cada vídeo de um lote.], [#must], [NOVO], [UC-VID-001, FA2], [Isola aceitação e falha de cada elemento do lote.], [Dado um lote misto, Quando termina a validação, Então cada vídeo tem o seu próprio resultado.],
    [REQ-VID-SUB-031], [O sistema deve permitir manter ambos ou cancelar perante um duplicado, sem substituir o original no MVP.], [#must], [NOVO], [UC-VID-001, FA1, RN8], [Preserva a imutabilidade do vídeo original.], [Dado um nome duplicado, Quando o utilizador escolhe uma opção, Então o original permanece inalterado.],
    [REQ-VID-SUB-032], [O sistema deve aplicar os limites de tamanho usando unidades decimais.], [#must], [NOVO], [UC-VID-001, RN9], [Torna inequívoca a conversão de MB e GB.], [Dado um ficheiro no limite decimal, Quando é validado, Então o resultado respeita a unidade definida.],
    [REQ-VID-SUB-033], [O sistema deve receber o vídeo completo em ficheiro temporário em disco, sem o manter completo em memória durante a submissão.], [#must], [NOVO], [UC-VID-001, RN10], [Evita consumo de memória proporcional ao tamanho do vídeo.], [Dado um upload de vídeo, Quando é recebido, Então o conteúdo é escrito num temporário em disco.],

    // --- RECORTE TEMPORAL (UC-VID-002) ---
    [REQ-VID-TRIM-001], [O sistema deve disponibilizar o progresso do recorte ao utilizador durante o processamento.], [#must], [NOVO], [UC-VID-002, passo 9], [Transparência do estado da operação no frontend.], [Dado uma operação de trim a decorrer, Quando o worker avança, Então envia atualizações via WebSocket.],
    [REQ-VID-TRIM-002], [O sistema deve apresentar a duração do vídeo selecionado para orientar a escolha do intervalo.], [#must], [NOVO], [UC-VID-002, passo 3], [Usabilidade na seleção dos pontos de corte.], [Dado a abertura da ferramenta Trim, Quando o vídeo é carregado, Então a timeline exibe o tempo total.],
    [REQ-VID-TRIM-003], [O sistema deve permitir definir o instante inicial do recorte.], [#must], [NOVO], [UC-VID-002, passo 4], [Definição do ponto de início (trim start).], [Dado o utilizador na interface, Quando define o tempo inicial $T_"start"$, Então o valor é validado e registado.],
    [REQ-VID-TRIM-004], [O sistema deve permitir definir o instante final do recorte.], [#must], [NOVO], [UC-VID-002, passo 4], [Definição do ponto de fim (trim end).], [Dado o utilizador na interface, Quando define o tempo final $T_"end"$, Então o valor é validado e registado.],
    [REQ-VID-TRIM-005], [O sistema deve rejeitar um instante inicial negativo ou superior à duração do vídeo.], [#must], [NOVO], [UC-VID-002, exceções], [Validação de limites do parâmetro inicial.], [Dado um valor $T_"start" < 0$ ou $> T_"total"$, Quando submetido, Então a interface e backend rejeitam.],
    [REQ-VID-TRIM-006], [O sistema deve rejeitar um instante final negativo ou superior à duração do vídeo.], [#must], [NOVO], [UC-VID-002, exceções], [Validação de limites do parâmetro final.], [Dado um valor $T_"end" > T_"total"$, Quando submetido, Então o sistema apresenta erro.],
    [REQ-VID-TRIM-007], [O sistema deve rejeitar um intervalo cujo instante inicial não seja anterior ao instante final.], [#must], [NOVO], [UC-VID-002, RN1], [Garante coerência temporal do intervalo ($T_"start" < T_"end"$).], [Dado $T_"start" \ge T_"end"$, Quando o recorte é solicitado, Então o pedido é recusado.],
    [REQ-VID-TRIM-008], [O sistema deve rejeitar um segmento com duração inferior a 1 segundo.], [#must], [NOVO], [UC-VID-002, RN1], [Evita a geração de ficheiros inválidos ou vazios.], [Dado $T_"end" - T_"start" < 1"s"$, Quando solicitado, Então o sistema devolve uma mensagem de validação.],
    [REQ-VID-TRIM-009], [O sistema deve criar uma operação de recorte em estado `em fila` depois da confirmação e validação.], [#must], [NOVO], [UC-VID-002, passos 5-6], [Gestão assíncrona do pedido.], [Dado um pedido válido, Quando submetido, Então a operação é criada com estado `em fila`.],
    [REQ-VID-TRIM-010], [O sistema deve executar o recorte de forma assíncrona através de uma operação de vídeo no RabbitMQ.], [#must], [NOVO], [UC-VID-002, passos 6-8], [Desbloqueio da API e processamento por workers.], [Dado uma operação em fila, Quando publicada no RabbitMQ, Então um worker FFmpeg consome e executa.],
    [REQ-VID-TRIM-011], [O sistema deve guardar o segmento como novo vídeo.], [#must], [NOVO], [UC-VID-002, RN5], [Imutabilidade do vídeo original.], [Dado a conclusão do trim, Quando guardado, Então surge como um novo elemento no projeto sem alterar o original.],
    [REQ-VID-TRIM-012], [O sistema deve permitir cancelar a operação em fila ou em processamento e marcar o estado como `cancelada`, sem consumir quota.], [#must], [NOVO], [UC-VID-002, FA1-FA2], [Controlo do utilizador e devolução de recursos.], [Dado um pedido de cancelamento, Quando processado, Então o worker aborta e a quota é reposta.],
    [REQ-VID-TRIM-013], [O sistema deve preservar o áudio correspondente quando o segmento original tiver áudio.], [#must], [NOVO], [UC-VID-002, RN5], [Manutenção da integridade multimédia.], [Dado um vídeo original com áudio, Quando recortado, Então o novo vídeo mantém a faixa de áudio sincronizada.],

    // --- FERRAMENTA DE IMAGEM EM FOTOGRAMAS (UC-VID-003) ---
    [REQ-VID-FRM-001], [O sistema deve apresentar as ferramentas de imagem existentes que aceitam uma imagem por fotograma.], [#must], [ALT (UC04)], [UC-VID-003, passo 3], [Reutilização do ecossistema de ferramentas de imagem.], [Dado o painel de vídeo, Quando o utilizador abre as ferramentas, Então apenas as compatíveis são listadas.],
    [REQ-VID-FRM-002], [O sistema deve rejeitar a seleção de uma ferramenta que não produza uma imagem por fotograma.], [#must], [ALT (UC04)], [UC-VID-003, exceção], [Evita quebras no pipeline de recomposição do vídeo.], [Dado uma ferramenta que altera dimensões aleatoriamente, Quando selecionada, Então o sistema bloqueia.],
    [REQ-VID-FRM-003], [O sistema deve permitir configurar os parâmetros da ferramenta selecionada.], [#must], [ALT (UC04)], [UC-VID-003, passo 4], [Personalização do efeito no vídeo.], [Dado uma ferramenta de filtro, Quando configurada pelo utilizador, Então os parâmetros são enviados ao worker.],
    [REQ-VID-FRM-004], [O sistema deve permitir definir o intervalo temporal dos fotogramas a processar.], [#must], [NOVO], [UC-VID-003, passo 5], [Permite aplicar efeitos apenas a um trecho do vídeo.], [Dado a configuração da operação, Quando o utilizador especifica o intervalo, Então só esses frames são extraídos.],
    [REQ-VID-FRM-005], [O sistema deve permitir definir a taxa de fotogramas a processar.], [#must], [NOVO], [UC-VID-003, passo 5], [Otimização de desempenho ou efeitos de time-lapse.], [Dado a escolha de 15 fps num vídeo de 30 fps, Quando processado, Então o worker extrai 1 em cada 2 frames.],
    [REQ-VID-FRM-006], [O sistema deve validar que o vídeo respeita os limites do perfil antes de iniciar a operação.], [#must], [NOVO], [UC-VID-003, passo 8, RN3], [Controlo de utilização por perfil.], [Dado um utilizador registado com vídeo acima do limite, Quando tenta processar, Então a operação é negada.],
    [REQ-VID-FRM-007], [O sistema deve extrair apenas os fotogramas pertencentes ao intervalo configurado.], [#must], [NOVO], [UC-VID-003, passos 5, 9-10], [Eficiência computacional.], [Dado um intervalo definido, Quando o FFmpeg executa, Então gera apenas as imagens desse trecho.],
    [REQ-VID-FRM-008], [O sistema deve enviar cada fotograma elegível para a ferramenta de imagem selecionada.], [#must], [ALT (UC04)], [UC-VID-003, passo 10], [Processamento frame a frame na infraestrutura existente.], [Dado os fotogramas extraídos, Quando enviados ao RabbitMQ de imagem, Então os workers aplicam o filtro.],
    [REQ-VID-FRM-009], [O sistema deve recompor os fotogramas processados num novo vídeo.], [#must], [NOVO], [UC-VID-003, passo 11], [Geração do resultado final de vídeo.], [Dado a conclusão do filtro em todos os frames, Quando o FFmpeg recompõe, Então gera o ficheiro MP4 final.],
    [REQ-VID-FRM-010], [O sistema deve preservar a faixa de áudio original quando a configuração não exigir a sua alteração.], [#must], [NOVO], [UC-VID-003, RN4], [Manutenção do áudio original após filtros visuais.], [Dado um vídeo com áudio, Quando aplicado um filtro de imagem, Então o vídeo resultante mantém o áudio intacto.],
    [REQ-VID-FRM-011], [O sistema deve aplicar ferramentas encadeadas pela ordem escolhida pelo utilizador.], [#should], [ALT (RF15)], [UC-VID-003, FA1], [Permite sequências de efeitos nos fotogramas.], [Dado uma sequência de Filtro A e Filtro B, Quando executado, Então o Filtro B recebe a imagem resultante do Filtro A.],
    [REQ-VID-FRM-012], [O sistema deve repetir o processamento de um fotograma que falhe.], [#must], [NOVO], [UC-VID-003, FA2], [Tolerância a falhas transitórias em workers.], [Dado uma falha isolada no filtro do frame 42, Quando detetada, Então o sistema tenta reprocessar até 3 vezes.],
    [REQ-VID-FRM-013], [O sistema deve terminar a operação como `falhada` quando a repetição do fotograma falhar.], [#must], [NOVO], [UC-VID-003, FA2], [Consistência do estado após falhas irrecuperáveis.], [Dado sucessivas falhas num fotograma, Quando esgotadas as tentativas, Então a operação de vídeo é marcada como `falhada`.],
    [REQ-VID-FRM-014], [O sistema deve preservar a resolução de vídeo original quando a configuração não exigir a sua alteração.], [#must], [NOVO], [UC-VID-003, RN4], [Qualidade visual do resultado.], [Dado um vídeo 1080p, Quando aplicado o filtro, Então o vídeo gerado mantém a resolução 1080p.],

    // --- CONVERSÃO DE FORMATO E RESOLUÇÃO (UC-VID-004) ---
    [REQ-VID-CONV-001], [O sistema deve apresentar o contentor de origem e os seus metadados.], [#must], [NOVO], [UC-VID-004, passos 1-3], [Informa o utilizador sobre o estado atual do ficheiro.], [Dado a abertura da ferramenta de conversão, Quando visualizado, Então exibe codec e resolução atuais.],
    [REQ-VID-CONV-002], [O sistema deve apresentar os contentores de saída suportados pelo MVP.], [#must], [NOVO], [UC-VID-004, passo 3, RN1], [Seleção do formato de destino.], [Dado o menu de conversão, Quando expandido, Então apresenta a opção MP4.],
    [REQ-VID-CONV-003], [O sistema deve apresentar os codecs de saída suportados para cada contentor.], [#must], [NOVO], [UC-VID-004, passo 3, RN1], [Garante combinações de codecs válidas.], [Dado a escolha do contentor MP4, Quando selecionado o codec, Então exibe H.264.],
    [REQ-VID-CONV-004], [O sistema deve permitir selecionar uma resolução de saída.], [#must], [NOVO], [UC-VID-004, passo 4], [Permite alterar as dimensões do vídeo (downscaling/upscaling).], [Dado a lista de resoluções, Quando o utilizador escolhe 720p, Então o parâmetro é gravado.],
    [REQ-VID-CONV-005], [O sistema deve rejeitar uma combinação de contentor e codec não suportada.], [#must], [NOVO], [UC-VID-004, exceção], [Impede o lançamento de comandos FFmpeg inválidos.], [Dado uma escolha incompatível, Quando submetida, Então o sistema bloqueia com aviso explicativo.],
    [REQ-VID-CONV-006], [O sistema deve rejeitar uma resolução cuja largura exceda 1920 ou cuja altura exceda 1080 para utilizadores registados.], [#must], [ALT (RNF48)], [UC-VID-004, RN2], [Limite independente à largura e altura do perfil gratuito.], [Dado um utilizador registado, Quando tenta converter para uma dimensão acima do limite, Então o sistema nega a operação.],
    [REQ-VID-CONV-007], [O sistema deve rejeitar uma resolução cuja largura exceda 3840 ou cuja altura exceda 2160 para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-004, RN2], [Limite independente à largura e altura do perfil premium.], [Dado um utilizador premium, Quando tenta converter para uma dimensão acima do limite, Então o sistema nega a operação.],
    [REQ-VID-CONV-008], [O sistema deve apresentar uma estimativa do tamanho do resultado antes da confirmação, quando esta puder ser calculada.], [#should], [NOVO], [UC-VID-004, passo 5], [Usabilidade e gestão de espaço do utilizador.], [Dado a seleção de bitrate e resolução, Quando calculado, Então exibe a estimativa em MB.],
    [REQ-VID-CONV-009], [O sistema deve executar a conversão de forma assíncrona.], [#must], [NOVO], [UC-VID-004, passos 7-8], [Evita timeout em requisições HTTP longas.], [Dado a confirmação da conversão, Quando iniciada, Então liberta o cliente e processa via RabbitMQ.],
    [REQ-VID-CONV-010], [O sistema deve guardar o vídeo convertido como novo conteúdo sem substituir o original.], [#must], [NOVO], [UC-VID-004, pós-condição], [Preservação dos ficheiros originais.], [Dado o sucesso da conversão, Quando guardado, Então cria uma nova referência na BD.],
    [REQ-VID-CONV-011], [O sistema deve comunicar o progresso da conversão.], [#must], [NOVO], [UC-VID-004, passos 7-8], [Feedback contínuo ao utilizador.], [Dado a conversão a decorrer, Quando o FFmpeg avança, Então emite eventos com a % concluída.],

    // --- EXTRAÇÃO DE FOTOGRAMAS (UC-VID-005) ---
    [REQ-VID-FEX-001], [O sistema deve permitir definir o instante inicial da extração.], [#must], [NOVO], [UC-VID-005, passo 3], [Delimitação do ponto de início da extração de imagens.], [Dado a ferramenta de extração, Quando o utilizador introduz o tempo inicial, Então o valor é aceite.],
    [REQ-VID-FEX-002], [O sistema deve permitir definir o instante final da extração.], [#must], [NOVO], [UC-VID-005, passo 3], [Delimitação do ponto de fim da extração.], [Dado a ferramenta de extração, Quando o utilizador introduz o tempo final, Então o valor é aceite.],
    [REQ-VID-FEX-003], [O sistema deve permitir definir a quantidade máxima de fotogramas.], [#must], [NOVO], [UC-VID-005, passo 3], [Controlo da amostragem e volume de ficheiros gerados.], [Dado a definição de limite N frames, Quando processado, Então o sistema não extrai mais de N imagens.],
    [REQ-VID-FEX-004], [O sistema deve permitir selecionar JPEG como formato de saída do MVP.], [#must], [ALT (UC04)], [UC-VID-005, RN2], [Compatibilidade das imagens extraídas.], [Dado a extração concluída, Quando os ficheiros são gravados, Então assumem o formato `.jpg`.],
    [REQ-VID-FEX-005], [O sistema deve calcular uma estimativa da quantidade de fotogramas antes da confirmação.], [#must], [NOVO], [UC-VID-005, passo 5], [Informa o utilizador do impacto antes de executar.], [Dado a escolha do intervalo e FPS, Quando alterados, Então a interface calcula e exibe o número de frames.],
    [REQ-VID-FEX-006], [O sistema deve limitar uma operação a 1000 fotogramas para utilizadores registados.], [#must], [ALT (RNF48)], [UC-VID-005, RN2], [Proteção contra sobrecarga de armazenamento no perfil gratuito.], [Dado um utilizador registado, Quando a estimativa excede 1000 frames, Então o pedido é bloqueado.],
    [REQ-VID-FEX-007], [O sistema deve limitar uma operação a 5000 fotogramas para utilizadores premium.], [#must], [ALT (RNF48)], [UC-VID-005, RN2], [Limite máximo de segurança para contas premium.], [Dado um utilizador premium, Quando a estimativa excede 5000 frames, Então o pedido é bloqueado.],
    [REQ-VID-FEX-008], [O sistema deve verificar o espaço disponível antes de iniciar a extração.], [#must], [NOVO], [UC-VID-005, passo 7], [Evita falhas a meio da operação por falta de disco.], [Dado a cota do utilizador, Quando a extração é solicitada, Então valida se o espaço no S3 é suficiente.],
    [REQ-VID-FEX-009], [O sistema deve guardar cada fotograma extraído como imagem JPEG no projeto escolhido.], [#must], [ALT (RF13)], [UC-VID-005, passos 10-12, RN4], [Integração dos fotogramas no ecossistema de imagens do projeto.], [Dado a conclusão da extração, Quando verificado o projeto, Então as imagens surgem na galeria.],
    [REQ-VID-FEX-010], [O sistema deve permitir escolher o projeto atual ou um projeto novo para os fotogramas.], [#should], [ALT (RF13)], [UC-VID-005, FA3], [Organização flexível de ativos.], [Dado o diálogo de confirmação, Quando o utilizador escolhe "Novo Projeto", Então cria o projeto e insere lá os frames.],
    [REQ-VID-FEX-011], [O sistema deve eliminar os fotogramas temporários quando a extração for cancelada ou falhar.], [#must], [NOVO], [UC-VID-005, FA2, exceção], [Prevenção de ficheiros órfãos em operações interrompidas.], [Dado um cancelamento a 50%, Quando executado, Então todos os JPEGs parciais são removidos do disco.],

    // --- CONCATENAÇÃO DE VÍDEOS (UC-VID-006) ---
    [REQ-VID-MERGE-001], [O sistema deve permitir selecionar pelo menos dois vídeos do mesmo projeto.], [#must], [NOVO], [UC-VID-006, RN1], [Validação prévia do requisito mínimo de merge.], [Dado a seleção de 1 vídeo, Quando tenta concatenar, Então o botão surge desativado.],
    [REQ-VID-MERGE-002], [O sistema deve limitar a seleção a cinco vídeos para utilizadores registados.], [#must], [NOVO], [UC-VID-006, RN1], [Restrição do número de entradas para utilizadores registados.], [Dado um utilizador registado, Quando seleciona 6 vídeos, Então o sistema nega a operação.],
    [REQ-VID-MERGE-003], [O sistema deve limitar a seleção a quinze vídeos para utilizadores premium.], [#must], [NOVO], [UC-VID-006, RN1], [Limite máximo de entradas para utilizadores premium.], [Dado um utilizador premium, Quando seleciona 16 vídeos, Então o sistema nega a operação.],
    [REQ-VID-MERGE-004], [O sistema deve permitir ordenar os vídeos selecionados.], [#must], [NOVO], [UC-VID-006, passos 2-3], [Controlo da sequência temporal de junção.], [Dado a lista de vídeos no modal de merge, Quando o utilizador os reordena, Então a nova sequência é guardada.],
    [REQ-VID-MERGE-005], [O sistema deve calcular a duração total dos vídeos pela ordem selecionada.], [#must], [NOVO], [UC-VID-006, passo 3, RN2], [Validação da duração combinada.], [Dado a lista de vídeos ordenada, Quando renderizada na UI, Então exibe a soma das durações.],
    [REQ-VID-MERGE-006], [O sistema deve rejeitar uma duração total superior a 5 minutos para utilizadores registados.], [#must], [NOVO], [UC-VID-006, RN2], [Limite de tempo acumulado no perfil gratuito.], [Dado a soma das durações > 5 min num utilizador registado, Quando submetida, Então o sistema rejeita.],
    [REQ-VID-MERGE-007], [O sistema deve rejeitar uma duração total superior a 30 minutos para utilizadores premium.], [#must], [NOVO], [UC-VID-006, RN2], [Limite máximo de tempo acumulado no perfil premium.], [Dado a soma das durações > 30 min num utilizador premium, Quando submetida, Então o sistema rejeita.],
    [REQ-VID-MERGE-008], [O sistema deve rejeitar um vídeo de entrada inacessível antes de criar a operação.], [#must], [NOVO], [UC-VID-006, exceção], [Garante disponibilidade de todas as fontes antes de submeter ao worker.], [Dado um vídeo removido entretanto do S3, Quando iniciado o merge, Então o sistema alerta o erro.],
    [REQ-VID-MERGE-009], [O sistema deve registar uma operação de concatenação e encaminhá-la para processamento assíncrono, sem bloquear a resposta HTTP.], [#must], [NOVO], [UC-VID-006, passos 4-6], [Operações potencialmente demoradas devem ser executadas por worker através da fila de mensagens.], [Dado um pedido válido de concatenação, Quando confirmado, Então o sistema regista a operação e responde com estado aceite para processamento.],
    [REQ-VID-MERGE-010], [O sistema deve concatenar os vídeos pela ordem confirmada pelo utilizador.], [#must], [NOVO], [UC-VID-006, passos 3, 8], [Fidelidade ao pedido de junção.], [Dado o processamento no FFmpeg, Quando concluído, Então os segmentos surgem exatamente na ordem definida.],
    [REQ-VID-MERGE-011], [O sistema deve preservar as faixas de áudio quando forem compatíveis com a concatenação.], [#must], [NOVO], [UC-VID-006, passo 8], [Qualidade sonora no vídeo unificado.], [Dado vídeos de entrada com áudio AAC compatível, Quando unidos, Então o vídeo resultante mantém a faixa sonora fluida.],
    [REQ-VID-MERGE-012], [O sistema deve guardar a concatenação como novo vídeo.], [#must], [NOVO], [UC-VID-006, RN3, pós-condição], [Geração de novo ativo de vídeo.], [Dado o sucesso do merge, Quando gravado, Então cria uma nova entrada independente no projeto.],
    [REQ-VID-MERGE-013], [O sistema deve manter inalteradas todas as origens da concatenação.], [#must], [NOVO], [UC-VID-006, RN3, pós-condição], [Imutabilidade dos ficheiros fonte.], [Dado a conclusão do merge, Quando verificados os vídeos originais, Então os seus hashes e ficheiros mantêm-se idênticos.],
    [REQ-VID-MERGE-014], [O sistema deve rejeitar um vídeo de entrada corrompido antes de criar a operação.], [#must], [NOVO], [UC-VID-006, exceção], [Evita falhas silenciosas de FFmpeg.], [Dado um ficheiro com streams danificados na lista, Quando validado, Então a operação é interrompida imediatamente.],
    [REQ-VID-MERGE-015], [O sistema deve rejeitar um vídeo de entrada inválido antes de criar a operação.], [#must], [NOVO], [UC-VID-006, exceção], [Segurança de validação das entradas.], [Dado um ficheiro cujo container não é reconhecido, Quando analisado, Então o sistema bloqueia o merge.],

    // --- GESTÃO DE ÁUDIO (UC-VID-007) ---
    [REQ-VID-AUD-001], [O sistema deve apresentar a opção de remover áudio.], [#must], [NOVO], [UC-VID-007, passo 1], [Disponibilidade do recurso de strip audio.], [Dado o painel de áudio, Quando aberto, Então exibe a opção "Remover Áudio".],
    [REQ-VID-AUD-002], [O sistema deve permitir confirmar a remoção da faixa de áudio.], [#must], [NOVO], [UC-VID-007, passos 1-2], [Execução da remoção de áudio de um vídeo.], [Dado um vídeo com áudio, Quando confirmada a remoção, Então gera uma cópia em vídeo mudo (`-an`).],
    [REQ-VID-AUD-003], [O sistema deve permitir selecionar um ficheiro de áudio ou um vídeo com faixa sonora para substituição.], [#must], [NOVO], [UC-VID-007, passo 2], [Capacidade de remuxing/substituição de áudio.], [Dado a opção "Substituir Áudio", Quando o utilizador carrega o novo ficheiro, Então o ficheiro é validado.],
    [REQ-VID-AUD-004], [O sistema deve aceitar MP3 como entrada de substituição.], [#must], [NOVO], [UC-VID-007, RN5], [Suporte a formatos de áudio comuns.], [Dado a submissão de um ficheiro `.mp3` para áudio, Quando analisado, Então é aceite pelo sistema.],
    [REQ-VID-AUD-005], [O sistema deve aceitar M4A/AAC como entrada de substituição.], [#must], [NOVO], [UC-VID-007, RN5], [Suporte a codecs nativos de alta qualidade.], [Dado a submissão de `.m4a`, Quando analisado, Então é aceite pelo sistema.],
    [REQ-VID-AUD-006], [O sistema deve rejeitar áudio que não seja MP3 ou M4A/AAC, vídeos sem faixa sonora e entradas cujo conteúdo não possa ser descodificado.], [#must], [NOVO], [UC-VID-007, RN5], [Prevenção de incompatibilidades de codec.], [Dado uma entrada inválida ou sem faixa sonora, Quando validada, Então é rejeitada antes do processamento.],
    [REQ-VID-AUD-007], [O sistema deve permitir selecionar um intervalo opcional do áudio de substituição.], [#should], [NOVO], [UC-VID-007, FA2], [Ajuste fino do ponto de início do novo áudio.], [Dado um ficheiro de áudio longo, Quando o utilizador define início/fim do áudio, Então apenas esse trecho é inserido.],
    [REQ-VID-AUD-008], [O sistema deve cortar o áudio de substituição quando este ultrapassar a duração do vídeo.], [#must], [NOVO], [UC-VID-007, FA2], [Sincronismo com a duração do fluxo visual.], [Dado um áudio de 3 min num vídeo de 1 min, Quando processado, Então o áudio é cortado aos 1 min.],
    [REQ-VID-AUD-009], [O sistema deve deixar sem áudio o restante do vídeo quando o áudio de substituição for mais curto.], [#must], [NOVO], [UC-VID-007, FA2], [Comportamento previsível para áudio curto.], [Dado um áudio de 30s num vídeo de 1 min, Quando processado, Então os últimos 30s do vídeo ficam em silêncio.],
    [REQ-VID-AUD-010], [O sistema deve rejeitar a extração quando o vídeo não tiver uma faixa de áudio.], [#must], [NOVO], [UC-VID-007, FA1], [Validação prévia para operação de extração.], [Dado um vídeo sem áudio, Quando o utilizador clica em "Extrair Áudio", Então o sistema informa que não existe faixa sonora.],
    [REQ-VID-AUD-011], [O sistema deve gerar áudio AAC em contentor M4A quando a opção de extração for concluída.], [#must], [NOVO], [UC-VID-007, passo 7], [Padronização do ficheiro de áudio extraído.], [Dado a conclusão da extração de áudio, Quando gravado no S3, Então assume a extensão `.m4a` e codec AAC.],
    [REQ-VID-AUD-012], [O sistema deve guardar o resultado da operação de gestão de áudio como novo conteúdo na biblioteca do projeto.], [#must], [NOVO], [UC-VID-007, RN3, pós-condição], [Criação e persistência do resultado na biblioteca.], [Dado o sucesso da operação de áudio, Quando concluído, Então o novo recurso surge listado no projeto.],
    [REQ-VID-AUD-013], [O sistema deve apresentar a opção de substituir áudio.], [#must], [NOVO], [UC-VID-007, passo 1], [Visibilidade da funcionalidade na UI.], [Dado o painel de ferramentas de áudio, Quando visualizado, Então exibe a opção de substituição.],
    [REQ-VID-AUD-014], [O sistema deve apresentar a opção de extrair áudio.], [#must], [NOVO], [UC-VID-007, passo 1], [Visibilidade da funcionalidade de extração.], [Dado o painel de ferramentas de áudio, Quando visualizado, Então exibe a opção de extração sonora.],
    [REQ-VID-AUD-015], [O sistema deve guardar o resultado de áudio como novo conteúdo na biblioteca do projeto.], [#must], [NOVO], [UC-VID-007, RN3, pós-condição], [Geração de ativo do tipo áudio isolado.], [Dado a extração de áudio, Quando concluída, Então insere o ficheiro de áudio na biblioteca.],
    [REQ-VID-AUD-016], [O sistema deve guardar o resultado de vídeo como novo conteúdo na biblioteca do projeto.], [#must], [NOVO], [UC-VID-007, RN3, pós-condição], [Geração de ativo do tipo vídeo modificado.], [Dado a remoção/substituição de áudio, Quando concluída, Então insere o novo vídeo resultante no projeto.],

    // --- REQUISITOS TRANSVERSAIS (COMMON) ---
    [REQ-VID-COM-001], [O sistema deve verificar que o utilizador tem acesso ao projeto antes de ler qualquer vídeo.], [#must], [ALT (RF23)], [Pré-condições, UC-VID-002 a 007], [Isolamento multi-tenant de dados.], [Dado um pedido de leitura de vídeo, Quando validado o token do utilizador, Então confirma se o projeto pertence ao mesmo.],
    [REQ-VID-COM-002], [O sistema deve verificar que o vídeo de entrada pertence ao projeto autorizado.], [#must], [ALT (RF23)], [Pré-condições, UC-VID-002 a 007], [Impede injeção de IDs de vídeo de outros projetos.], [Dado um pedido com `video_id`, Quando o sistema consulta a BD, Então garante que o `project_id` coincide.],
    [REQ-VID-COM-003], [O sistema deve limitar os resultados de vídeo ao utilizador autorizado no projeto.], [#must], [ALT (RF23)], [UC-VID-001 a UC-VID-007], [Controlo de visibilidade de recursos.], [Dado uma pesquisa na API, Quando devolvidos os vídeos, Então apenas lista recursos pertencentes ao projeto do utilizador.],
    [REQ-VID-COM-004], [O sistema deve reservar uma operação avançada antes de iniciar uma operação de processamento para um utilizador registado.], [#must], [ALT (RNF48)], [RN3 dos UC-VID-002 a 007], [Mecanismo de reserva atómica de quota.], [Dado um utilizador registado com 1 operação restante, Quando submete o pedido, Então a cota passa a 0 temporariamente.],
    [REQ-VID-COM-005], [O sistema deve rejeitar uma operação de processamento quando a quota do utilizador registado estiver esgotada.], [#must], [ALT (RNF48)], [Exceções dos UC-VID-002 a 007], [Aplicação rígida de limites de uso diário.], [Dado um utilizador com 0 cota, Quando tenta processar um vídeo, Então o sistema nega com aviso de limite atingido.],
    [REQ-VID-COM-006], [O sistema não deve aplicar limite diário de operações de processamento a utilizadores premium.], [#must], [ALT (RNF48)], [RN3 dos UC-VID-002 a 007], [Diferenciação do plano Premium.], [Dado um utilizador premium, Quando realiza N operações no mesmo dia, Então nunca é bloqueado por quota diária.],
    [REQ-VID-COM-007], [O sistema deve devolver a reserva de quota quando a operação falhar.], [#must], [ALT (RNF48)], [RN7, RN4/RN5], [Justiça de utilização e tolerância a erros do sistema.], [Dado uma operação que termina em erro no worker, Quando o estado passa a `falhada`, Então restitui 1 unidade à cota.],
    [REQ-VID-COM-008], [O sistema deve devolver a reserva de quota quando a operação for cancelada.], [#must], [ALT (RNF48)], [FA de cancelamento], [Devolução de recursos em operações abortadas pelo utilizador.], [Dado o cancelamento bem-sucedido pelo utilizador, Quando processado, Então restitui a cota reservada.],
    [REQ-VID-COM-009], [O sistema deve registar o identificador, tipo, origem, utilizador, projeto, estado e timestamps de cada operação de vídeo.], [#must], [NOVO], [Pós-condições dos UC], [Rastreabilidade e auditoria de tarefas no backend.], [Dado o arranque de uma tarefa, Quando gravada na BD, Então contém todos os metadados de execução.],
    [REQ-VID-COM-010], [O sistema deve registar a mensagem de erro quando uma operação falhar.], [#must], [NOVO], [Exceções dos UC], [Suporte a diagnóstico e depuração de problemas.], [Dado a falha de um worker, Quando atualiza a BD, Então grava a mensagem técnica resumida da falha.],
    [REQ-VID-COM-011], [O sistema deve expor os estados `em fila`, `em processamento`, `concluída`, `falhada` e `cancelada` para operações assíncronas.], [#must], [NOVO], [UC-VID-002 a UC-VID-007], [Máquina de estados padronizada para tarefas de vídeo.], [Dado a consulta de estado da API, Quando devolvida a resposta, Então a propriedade `status` assume um dos 5 valores.],
    [REQ-VID-COM-012], [O sistema deve publicar atualizações de estado no WebSocket do projeto autorizado.], [#must], [ALT (RNF43)], [Passos de progresso], [Comunicação em tempo real com o cliente web.], [Dado a mudança de estado da tarefa no worker, Quando alterada, Então dispara evento para o canal WebSocket.],
    [REQ-VID-COM-013], [O sistema deve impedir que um cliente não autorizado receba atualizações de uma operação de vídeo.], [#must], [ALT (RF23)], [Segurança], [Isolamento do canal WebSocket entre utilizadores.], [Dado uma subscrição WebSocket sem permissão no projeto, Quando ocorrem eventos, Então a mensagem não é entregue ao cliente.],
    [REQ-VID-COM-014], [O sistema deve eliminar resultados temporários quando uma operação falhar.], [#must], [NOVO], [Pós-condições mínimas], [Manutenção da limpeza do sistema de ficheiros.], [Dado uma falha a meio do FFmpeg, Quando registado o erro, Então limpa a pasta `/tmp` do worker.],
    [REQ-VID-COM-015], [O sistema deve eliminar resultados temporários quando uma operação for cancelada.], [#must], [NOVO], [Fluxos de cancelamento], [Prevenção de acumulação de ficheiros obsoletos.], [Dado o cancelamento via API, Quando recebido pelo worker, Então elimina de imediato os ficheiros temporários.],
    [REQ-VID-COM-016], [O sistema deve impedir que um resultado parcial seja apresentado na biblioteca.], [#must], [NOVO], [Pós-condições mínimas], [Integridade dos dados apresentados na UI.], [Dado uma tarefa que ainda não é `concluída`, Quando a galeria é recarregada, Então o item incompleto não aparece.],
    [REQ-VID-COM-017], [O sistema deve preservar o vídeo de origem durante qualquer operação de processamento.], [#must], [ALT (RNF61)], [Pós-condições dos UC], [Garantia de não alteração dos ficheiros de entrada.], [Dado a execução de qualquer operação, Quando concluída, Então o hash SHA-256 do ficheiro de entrada permanece idêntico.],
    [REQ-VID-COM-018], [O sistema deve disponibilizar o resultado concluído na biblioteca do projeto autorizado.], [#must], [ALT (RF13)], [Pós-condições dos UC], [Disponibilização do ativo para visualização/download.], [Dado o estado `concluída`, Quando a galeria consulta a API, Então o novo recurso está visível e pronto a utilizar.],
    [REQ-VID-COM-019], [O sistema deve limitar os conteúdos de vídeo ao utilizador autorizado no projeto.], [#must], [ALT (RF23)], [UC-VID-001 a UC-VID-007], [Privacidade de dados de vídeo.], [Dado o pedido de download de um vídeo, Quando processado, Então valida permissão do utilizador no projeto.],
    [REQ-VID-COM-020], [O sistema deve publicar atualizações de progresso no WebSocket do projeto autorizado.], [#must], [ALT (RNF43)], [Passos de progresso], [Acompanhamento granular da evolução do processamento.], [Dado o progresso de 45% no FFmpeg, Quando emitido pelo worker, Então o cliente exibe a barra de progresso a 45%.],
  ),
)

== Requisitos Não Funcionais e de Qualidade

#orientacao[
  Classifiquem segundo a ISO/IEC 25010 (Adequação Funcional, Eficiência de Desempenho, Compatibilidade,
  Usabilidade, Fiabilidade, Segurança, Manutenibilidade, Portabilidade). Indiquem o *Alvo*: o valor mensurável
  exigido a uma solução em produção. Prioridade segundo MoSCoW.
]


#tab([Requisitos não funcionais e de qualidade da extensão de vídeo],
  tabela(
    colunas: (3.2cm, 1fr, 3.2cm, 2.5cm, 1.6cm, 2.2cm, 4.2cm),
    tamanho: 8pt,
    [ID], [Requisito], [ISO/IEC 25010], [Alvo], [Prioridade], [Origem], [Critério de aceitação],
    [REQ-VID-Q-001], [O sistema deve aceitar uma submissão válida sem erros de persistência.], [Fiabilidade], [100% dos testes de aceitação], [#must], [UC-VID-001], [Dado um vídeo válido, Quando submetido, Então é aceite e registado em 100% das tentativas.],
    [REQ-VID-Q-002], [O sistema deve emitir pelo menos uma atualização de estado para cada operação assíncrona.], [Usabilidade], [Atualização observável no cliente], [#must], [UC-VID-002 a 007], [Dado uma operação assíncrona, Quando o estado muda, Então a UI recebe a notificação sem necessidade de refresh.],
    [REQ-VID-Q-003], [O sistema deve emitir atualizações de progresso em operações que ultrapassem 5 segundos.], [Eficiência de Desempenho], [Atualizações a cada $\le 5$"s"], [#must], [DQ-001], [Dado uma operação longa, Quando em execução, Então emite atualizações periódicas de progresso ao utilizador.],
    [REQ-VID-Q-004], [O sistema deve manter o conteúdo original íntegro durante upload, processamento e limpeza.], [Fiabilidade], [Hash SHA-256 inalterado], [#must], [UC-VID-001, COM-017], [Dado um ficheiro original, Quando comparado o hash antes e depois das operações, Então os hashes coincidem 100%.],
    [REQ-VID-Q-005], [O sistema deve aplicar autorização aos recursos de vídeo em todas as operações da API.], [Segurança], [0% de acessos não autorizados], [#must], [COM-001 a 003, COM-013], [Dado tentativas de acesso cruzado a vídeos de outros utilizadores, Então todas resultam em erro HTTP 403.],
    [REQ-VID-Q-006], [O fluxo de vídeo deve manter o processamento de imagens existente operacional sem regressões.], [Compatibilidade], [100% na suite de testes de imagem], [#must], [DQ-002], [Dado a execução da bateria de testes de regressão de imagem, Quando terminada, Então todos os testes passam.],
    [REQ-VID-Q-007], [O sistema deve limpar objetos temporários após uma operação concluída com sucesso.], [Manutenibilidade], [0 ficheiros temporários órfãos], [#must], [COM-014 a 016], [Dado a conclusão com sucesso de uma tarefa, Quando inspecionada a pasta temporária, Então encontra-se vazia.],
    [REQ-VID-Q-008], [O sistema deve apresentar mensagens de erro legíveis sem expor stack traces internos.], [Usabilidade / Segurança], [Sem exposição de dados sensíveis], [#must], [Exceções dos UC], [Dado uma falha técnica no backend, Quando a resposta é devolvida à UI, Então contém uma mensagem amigável e genérica.],
    [REQ-VID-Q-009], [O sistema deve rejeitar uma submissão inválida sem criar uma referência inconsistente na BD.], [Fiabilidade], [100% das submissões inválidas limpas], [#must], [UC-VID-001], [Dado um vídeo corrompido, Quando rejeitado, Então não deixa registos órfãos na BD.],
    [REQ-VID-Q-010], [O sistema deve proteger os vídeos contra acesso cruzado entre projetos.], [Segurança], [0% acessos entre projetos], [#must], [COM-001 a 003], [Dado um utilizador autenticado, Quando solicita um vídeo de outro projeto via URL direto, Então o acesso é negado.],
    [REQ-VID-Q-011], [O sistema deve proteger os metadados contra acesso cruzado entre projetos.], [Segurança], [0% vazamento de metadados], [#must], [COM-001 a 003], [Dado uma requisição aos metadados de vídeo de terceiros, Então devolve HTTP 404/403.],
    [REQ-VID-Q-012], [O sistema deve proteger os eventos WebSocket contra escuta por utilizadores não autorizados.], [Segurança], [0% vazamento de eventos], [#must], [COM-013], [Dado um canal WebSocket ativo, Quando enviadas atualizações, Então só os membros autorizados recebem.],
    [REQ-VID-Q-013], [O sistema deve limpar objetos temporários após uma operação que termine em falha.], [Manutenibilidade], [0 temporários retidos], [#must], [COM-014], [Dado uma falha grave num worker, Quando o processo é terminado, Então remove os ficheiros parciais acumulados.],
    [REQ-VID-Q-014], [O sistema deve limpar objetos temporários após uma operação ser cancelada pelo utilizador.], [Manutenibilidade], [0 temporários retidos], [#must], [COM-015], [Dado o cancelamento da tarefa, Quando o worker interrompe o FFmpeg, Então limpa o espaço em disco utilizado.],
    [REQ-VID-Q-015], [O sistema deve impedir o acesso direto a objetos temporários de vídeo por via da API externa.], [Manutenibilidade / Segurança], [Acesso 100% bloqueado], [#must], [COM-016], [Dado uma tentativa de pedir um URL temporário interno, Então a API bloqueia a requisição.],
    [REQ-VID-Q-016], [O sistema deve emitir atualizações de progresso regulares para operações assíncronas demoradas.], [Eficiência de Desempenho], [Progresso reportado a cada $\le 5$"s"], [#must], [DQ-001], [Dado uma conversão de 2 minutos, Quando em execução, Então emite sinais de percentagem no canal em tempo real.],
  ),
)
]

== Verificação da completude e dos limites do âmbito

#orientacao[
  Para cada caso de uso, avaliem os tópicos abaixo. "Não aplicável" ou "fora do âmbito" é aceitável quando
  justificado; isso não obriga a introduzir funcionalidades alheias ao caso de uso.
]

A tabela seguinte apresenta a avaliação sistemática da completude dos requisitos face às dimensões operacionais do sistema, assegurando que o âmbito do MVP de vídeo se encontra delimitado, sem omissões e devidamente coberto pelas especificações funcionais e não funcionais.



#tab([Verificação da completude e limites de âmbito],
  tabela(
    colunas: (4.2cm, 2.2cm, 1.6cm, 1fr, 3.8cm),
    tamanho: 8.5pt,
    [Tópico a verificar], [Caso de uso], [Aplicável?], [Decisão / justificação], [Requisito(s) relacionado(s)],

    [Formato, _codec_, duração e dimensão do vídeo], [UC-VID-001], [Sim], [Necessário para submissão e validação no pipeline de entrada.], [REQ-VID-SUB-005 a 023],
    [], [UC-VID-002], [Sim], [Essencial para delimitação dos pontos de corte temporal.], [REQ-VID-TRIM-002 a 008],
    [], [UC-VID-003], [Sim], [Requer validação de dimensão e taxa de frames para processamento.], [REQ-VID-FRM-005, 006, 014],
    [], [UC-VID-004], [Sim], [Representa o núcleo da conversão de formatos, codecs e resoluções.], [REQ-VID-CONV-001 a 007],
    [], [UC-VID-005], [Sim], [Determina a quantidade de fotogramas extraídos com base no tempo/FPS.], [REQ-VID-FEX-001 a 007],
    [], [UC-VID-006], [Sim], [Valida a duração acumulada e a compatibilidade dos vídeos a juntar.], [REQ-VID-MERGE-005 a 007],
    [], [UC-VID-007], [Sim], [Determina os codecs de áudio suportados e durações de corte.], [REQ-VID-AUD-004 a 009],

    [Estado, progresso, cancelamento e resultado], [UC-VID-001], [Sim], [Registo de progresso e estado da submissão/upload do ficheiro.], [REQ-VID-SUB-004, 024],
    [], [UC-VID-002], [Sim], [Acompanhamento do recorte, eventos WebSocket e cancelamento sem cota.], [REQ-VID-TRIM-001, 009, 012],
    [], [UC-VID-003], [Sim], [Progresso do processamento de fotogramas e recomposição.], [REQ-VID-COM-011, 012, 020],
    [], [UC-VID-004], [Sim], [Acompanhamento da conversão assíncrona e publicação de estado.], [REQ-VID-CONV-009, 011],
    [], [UC-VID-005], [Sim], [Progresso na geração de JPEGs e cancelamento com limpeza.], [REQ-VID-FEX-011, REQ-VID-COM-011],
    [], [UC-VID-006], [Sim], [Gestão de estados do merge e cancelamento.], [REQ-VID-COM-008, 011, 012],
    [], [UC-VID-007], [Sim], [Notificação de conclusão da alteração ou extração de áudio.], [REQ-VID-AUD-011, 012, REQ-VID-COM-011],

    [Falhas durante o processamento], [UC-VID-001], [Sim], [Eliminação de temporários e rejeição limpa de ficheiros inviáveis.], [REQ-VID-SUB-008, 024, REQ-VID-Q-009],
    [], [UC-VID-002], [Sim], [Tratamento de exceções e devolução automática de cota de operação.], [REQ-VID-COM-007, 010, 014],
    [], [UC-VID-003], [Sim], [Mecanismo de repetição (_retry_) até 3 vezes por fotograma com falha.], [REQ-VID-FRM-012, 013],
    [], [UC-VID-004], [Sim], [Registo da mensagem técnica e reversão da quota.], [REQ-VID-COM-007, 010],
    [], [UC-VID-005], [Sim], [Limpeza de ficheiros parciais em caso de falha de disco ou worker.], [REQ-VID-FEX-011, REQ-VID-Q-013],
    [], [UC-VID-006], [Sim], [Rejeição prévia de ficheiros corrompidos na lista de concatenação.], [REQ-VID-MERGE-008, 014, 015],
    [], [UC-VID-007], [Sim], [Tratamento de falta de stream de áudio ou falha no remuxing.], [REQ-VID-AUD-010, REQ-VID-COM-007],

    [Persistência e expiração dos ficheiros], [UC-VID-001], [Sim], [Mapeamento entre metadados em BD e armazenamento no SeaweedFS.], [REQ-VID-SUB-015, 026 a 029],
    [], [UC-VID-002 a 007], [Sim], [Todos os resultados são guardados como novos ativos, mantendo a imutabilidade do original.], [REQ-VID-TRIM-011, CONV-010, MERGE-012, AUD-012, COM-017, 018],

    [Perfis e contagem de operações], [UC-VID-001], [Sim], [Distinção entre perfis (Registado vs Premium) e não dedução de cota na submissão.], [REQ-VID-SUB-001, 016 a 023, 025],
    [], [UC-VID-002 a 007], [Sim], [Consumo de cota no perfil Registado, acesso ilimitado no Premium e devolução em falha/cancelamento.], [REQ-VID-COM-004 a 008],

    [Encadeamento de ferramentas e processamento em lote], [UC-VID-003], [Sim], [Suporte a aplicação encadeada de filtros de imagem aos fotogramas na sequência configurada.], [REQ-VID-FRM-011],
    [], [UC-VID-004], [Sim], [Conversão de formato/resolução executada em lote no ficheiro de vídeo.], [REQ-VID-CONV-009],
    [], [UC-VID-001, 002, 005, 006, 007], [Não], [Processamento em lote simultâneo de múltiplos vídeos ou transições complexas estão fora do MVP.], [N/A (Fora do âmbito do MVP)],
  ),
)
