# Caso de Uso — Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo

### Requisitos e Arquiteturas de Software · MEI · Universidade do Minho

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | 27 |
| **Autores** | Alice Soares (PG12345); João Silva (PG12346); Maria Costa (PG12347); Pedro Santos (PG12348); Ana Oliveira (PG12349) |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.1 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Registado (vídeos até 30 s) e Premium (vídeos até 5 min) — utilizadores anónimos não têm acesso a esta funcionalidade |

**Justificação no contexto do MVP** *(2–3 linhas)*

Esta funcionalidade é a ponte entre o processamento de imagens existente e o novo suporte a vídeo. Ao permitir aplicar qualquer ferramenta de imagem já implementada (brilho, contraste, rotação, binarização, etc.) a cada fotograma de um vídeo, reutiliza integralmente os microserviços existentes sem modificações, validando a extensibilidade da arquitetura. Sem esta funcionalidade, o valor acumulado das ferramentas de imagem ficaria limitado ao domínio estático, desperdiçando a oportunidade de multiplicar a oferta funcional para vídeo com custo de desenvolvimento marginal.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-003 |
| **Nome** | Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo |
| **Versão** | v1.1 |
| **Autor** | Alice Soares |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador aplicar qualquer ferramenta de processamento de imagem existente (e.g., brilho, contraste, binarização, rotação) a todos (ou a um subconjunto de) fotogramas de um vídeo, obtendo um novo vídeo processado. |
| **Âmbito** | Módulo de vídeo do PictuRAS — decomposição de fotogramas, integração com microserviços de ferramentas de imagem, recomposição de vídeo |
| **Ator Principal** | Utilizador Registado ou Premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende aplicar efeitos visuais ou correções a todos os fotogramas do seu vídeo de forma automática, sem extrair manualmente cada fotograma<br>- **Proprietário do Sistema**: deseja maximizar o valor das ferramentas de imagem existentes, estendendo-as ao domínio de vídeo sem desenvolvimento adicional por ferramenta<br>- **Equipa de Desenvolvimento**: valida que a arquitetura de microserviços e filas RabbitMQ escala para processamento massivo de fotogramas<br>- **Operador de Infraestrutura**: necessita que o processamento intensivo não degrade o desempenho de outros serviços |
| **Pré-condições** | - O utilizador tem sessão iniciada com perfil Registado ou Premium<br>- O utilizador possui pelo menos um projeto com um vídeo submetido com sucesso<br>- O vídeo está armazenado e acessível no SeaweedFS<br>- O utilizador não excedeu a quota de operações do seu perfil<br>- Pelo menos uma ferramenta de processamento de imagem está disponível e operacional |
| **Trigger** | O utilizador seleciona um vídeo no seu projeto e escolhe a opção "Aplicar Ferramenta a Fotogramas" |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre um projeto que contém vídeos. | Apresenta o projeto com a lista de vídeos disponíveis. |
| 2 | O utilizador seleciona um vídeo e escolhe a opção "Aplicar Ferramenta a Fotogramas". | — |
| 3 | — | Valida que o utilizador tem permissão e quota disponível para a operação. Apresenta a lista de ferramentas de imagem disponíveis, organizadas por categoria (básicas e avançadas), com descrição e parâmetros configuráveis de cada uma. |
| 4 | O utilizador seleciona uma ferramenta (e.g., brilho) e configura os respetivos parâmetros (e.g., fator: 1.5). | — |
| 5 | — | Apresenta opções adicionais: seleção de intervalo temporal (todos os fotogramas por omissão, ou um intervalo específico em segundos) e taxa de fotogramas de saída (mantém a original por omissão). |
| 6 | O utilizador confirma o intervalo temporal e a taxa de fotogramas pretendidos (ou aceita os valores por omissão). | — |
| 7 | O utilizador revê o resumo da operação (ferramenta, parâmetros, intervalo, estimativa de fotogramas a processar) e confirma a execução. | — |
| 8 | — | Valida o vídeo de entrada (existência, codec suportado, duração dentro dos limites do perfil) e os parâmetros da ferramenta selecionada. |
| 9 | — | Cria um trabalho de processamento (*job*) com estado "Em Progresso" e notifica o utilizador via WebSocket. Envia o vídeo para o microserviço de decomposição, que inicia a extração dos fotogramas para armazenamento temporário no SeaweedFS. |
| 10 | — | Atualiza o progresso em tempo real via WebSocket: "A extrair fotogramas… X/N". |
| 11 | — | Após a extração de todos os fotogramas, para cada fotograma, o sistema compõe uma mensagem JSON (com `messageId`, `timestamp`, `procedure`, `inputImageURI`, `outputImageURI` e parâmetros da ferramenta) e publica-a na fila RabbitMQ da ferramenta selecionada. |
| 12 | — | O microserviço da ferramenta processa cada fotograma individualmente. O sistema monitoriza as respostas e atualiza o progresso via WebSocket: "A processar fotograma X/N". |
| 13 | — | Após todos os fotogramas processados com sucesso, o sistema envia os fotogramas processados para o microserviço de recomposição de vídeo, que reconstrói o vídeo incluindo a faixa de áudio original. |
| 14 | — | Atualiza o progresso via WebSocket: "A recompor vídeo…". |
| 15 | — | Armazena o vídeo resultante no SeaweedFS, associa-o ao projeto do utilizador, atualiza o estado do trabalho para "Concluído" e regista a operação na quota do utilizador (conta como 1 operação avançada). Notifica o utilizador via WebSocket. |
| 16 | O utilizador pré-visualiza o vídeo processado e, opcionalmente, transfere-o para o seu dispositivo. | Apresenta o vídeo processado com opções de pré-visualização e transferência. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 — Encadeamento de ferramentas | No passo 4, o utilizador seleciona múltiplas ferramentas em sequência (e.g., brilho + contraste + rotação). O sistema aplica cada ferramenta a cada fotograma pela ordem definida, usando o resultado de uma ferramenta como entrada da seguinte. O progresso é atualizado com indicação da ferramenta em curso: "A processar fotograma X/N — Ferramenta Y/Z". A operação conta como 1 operação avançada independentemente do número de ferramentas encadeadas. |
| FA2 — Falha parcial em fotogramas | Durante o passo 12, o processamento de um ou mais fotogramas falha (e.g., erro no microserviço). O sistema regista os fotogramas falhados, salta-os e prossegue com os restantes. O sistema tenta repetir cada fotograma falhado até 2 vezes antes de o saltar definitivamente. Na recomposição (passo 13), os fotogramas falhados são substituídos pelo fotograma original não processado. O vídeo resultante é marcado como "Concluído com avisos" e o utilizador é informado dos fotogramas que não foram processados. |
| FA3 — Cancelamento pelo utilizador | A qualquer momento entre os passos 9 e 14, o utilizador pode cancelar a operação. O sistema interrompe o processamento dos fotogramas pendentes, aguarda a conclusão dos que estão em processamento nos microserviços, elimina os ficheiros temporários (fotogramas extraídos e processados) do SeaweedFS e marca o trabalho como "Cancelado". A operação cancelada não é contabilizada na quota do utilizador. |
| FA4 — Intervalo temporal específico | No passo 6, o utilizador define um intervalo temporal (e.g., de 00:05 a 00:20). O sistema extrai apenas os fotogramas correspondentes a esse intervalo. Na recomposição, o sistema reconstrói o vídeo completo, mantendo os fotogramas originais fora do intervalo selecionado e substituindo os do intervalo pelos fotogramas processados, preservando a faixa de áudio completa. |
| FA5 — Ferramenta de IA com saída de metadados | No passo 4, o utilizador seleciona uma ferramenta de IA cuja saída não é uma imagem mas metadados (e.g., `text_ai` para OCR, `obj_ai` para deteção de objetos). O sistema aplica a ferramenta a cada fotograma (ou ao subconjunto selecionado) e agrega os metadados num ficheiro estruturado (JSON) com referência temporal por fotograma. Não é gerado um vídeo de saída; em vez disso, é disponibilizado o ficheiro de metadados para consulta e transferência. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Codec de vídeo não suportado para extração de fotogramas | O sistema apresenta o erro: "O formato de vídeo não é suportado para extração de fotogramas. Formatos suportados: MP4 (H.264), WebM (VP8/VP9), AVI (MJPEG)." A operação é cancelada sem alterações ao estado do projeto. |
| Ferramenta selecionada incompatível com fotogramas de vídeo | No passo 8, se a ferramenta selecionada não produz uma imagem como saída e o utilizador não seguiu o FA5, o sistema apresenta o aviso: "A ferramenta selecionada produz metadados em vez de imagens. Deseja continuar com extração de metadados por fotograma?" Se o utilizador recusar, regressa ao passo 4. |
| Tempo máximo de processamento excedido (*timeout*) | Se o processamento total exceder o tempo máximo permitido (30 min para Registado, 120 min para Premium), o sistema cancela os fotogramas pendentes, recompõe o vídeo com os fotogramas processados até esse momento e marca o trabalho como "Concluído parcialmente — tempo excedido". O utilizador é notificado. |
| Armazenamento insuficiente para fotogramas extraídos | Se durante a extração de fotogramas (passo 9) o espaço disponível no SeaweedFS for insuficiente, o sistema cancela a operação, elimina os fotogramas já extraídos e apresenta o erro: "Espaço de armazenamento insuficiente para processar este vídeo. Liberte espaço ou reduza o intervalo temporal." |
| Erro individual no microserviço da ferramenta | Se o microserviço da ferramenta retornar um erro para um fotograma específico (e.g., imagem corrompida após extração), o sistema segue o comportamento definido no FA2 (registo, repetição e eventual substituição pelo fotograma original). |
| Quota de operações excedida | No passo 3, se o utilizador já esgotou a quota diária (5 operações para Registado), o sistema apresenta: "Quota diária de operações esgotada. Atualize para Premium para processamento ilimitado." A operação não é iniciada. |
| Vídeo original eliminado durante o processamento | Se o vídeo original for eliminado do SeaweedFS enquanto o processamento está em curso (e.g., por ação concorrente do utilizador), o sistema interrompe o processamento, limpa os ficheiros temporários e marca o trabalho como "Falhado — vídeo de origem indisponível". O utilizador é notificado. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | Um novo vídeo processado é armazenado no SeaweedFS e associado ao projeto do utilizador. O vídeo contém todos os fotogramas processados pela ferramenta selecionada e a faixa de áudio original. A quota do utilizador é decrementada em 1 operação avançada. O vídeo original mantém-se inalterado. Os ficheiros temporários (fotogramas extraídos e processados) são eliminados. O trabalho é marcado como "Concluído". |
| Garantia Mínima | O vídeo original mantém-se inalterado e acessível. Os ficheiros temporários são limpos. O trabalho é marcado com o estado final apropriado ("Falhado", "Cancelado" ou "Concluído parcialmente") com registo da razão. Se a operação não foi concluída com sucesso, a quota do utilizador não é decrementada. Uma mensagem de erro ou aviso é apresentada ao utilizador. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | Apenas ferramentas básicas (border, brightness, contrast, cut, resize, rotate, saturation, binarization) podem ser aplicadas a todos os fotogramas de um vídeo. Ferramentas de IA (cut_ai, upgrade_ai, bg_remove_ai, text_ai, obj_ai, people_ai, expand_ai) só podem ser aplicadas a fotogramas selecionados ou a intervalos limitados (máximo 30 fotogramas por invocação). |
| RN2 | A aplicação de uma ferramenta a todos os fotogramas de um vídeo conta como 1 operação avançada para efeitos de quota, independentemente do número de fotogramas processados ou de ferramentas encadeadas. |
| RN3 | A duração máxima do vídeo para processamento fotograma a fotograma é de 30 segundos para utilizadores registados e 5 minutos para utilizadores premium. |
| RN4 | Utilizadores anónimos não têm acesso a esta funcionalidade. |
| RN5 | O vídeo de saída mantém a faixa de áudio do vídeo original, sincronizada com os fotogramas processados. |
| RN6 | A taxa de fotogramas do vídeo de saída é igual à do vídeo de entrada, exceto se o utilizador especificar uma taxa diferente. |
| RN7 | A resolução máxima de cada fotograma processado é igual à resolução original do vídeo. Ferramentas que alterem a resolução (e.g., resize) estão limitadas à resolução original como máximo. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | Os microserviços de ferramentas de imagem existentes processam fotogramas individuais (imagens) sem necessitar de conhecimento de que provêm de um vídeo — operam de forma idêntica ao processamento de imagens isoladas. |
| A2 | O SeaweedFS tem capacidade suficiente para armazenar temporariamente todos os fotogramas extraídos de um vídeo de 5 minutos à resolução original (estimativa: ~9000 fotogramas a 30 fps, ~50 KB/fotograma JPEG = ~450 MB). |
| A3 | A infraestrutura RabbitMQ suporta o enfileiramento de milhares de mensagens simultâneas sem perda, correspondentes ao processamento de todos os fotogramas de um vídeo. |
| A4 | O microserviço de decomposição de vídeo em fotogramas e o microserviço de recomposição de vídeo a partir de fotogramas serão desenvolvidos como novos componentes na Fase 1. |
| A5 | A biblioteca FFmpeg (ou equivalente) está disponível no ambiente de execução para decomposição e recomposição de vídeo. |
| A6 | O formato JPEG é adequado como formato intermédio para os fotogramas extraídos, com qualidade suficiente para não degradar visivelmente o vídeo final. |
| A7 | As notificações de progresso via WebSocket são entregues ao cliente em tempo útil (latência inferior a 2 s). |
| A8 | O processamento paralelo de fotogramas em múltiplas instâncias do microserviço da ferramenta é possível e não introduz inconsistências na ordem dos fotogramas. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Qual é a qualidade JPEG ideal para os fotogramas intermédios, equilibrando a qualidade visual com o espaço de armazenamento? |
| Q2 | Deve o sistema permitir que o utilizador configure o número máximo de fotogramas a processar em paralelo (para gerir o impacto no desempenho)? |
| Q3 | Como será gerida a priorização na fila RabbitMQ entre pedidos de processamento de fotogramas de vídeo e pedidos normais de processamento de imagens? |
| Q4 | Deve o sistema suportar a retoma de um processamento interrompido (e.g., por falha do servidor), em vez de reiniciar desde o início? |
| Q5 | Qual é o comportamento esperado quando o utilizador aplica uma ferramenta de corte (cut) a todos os fotogramas — deve o vídeo resultante ter uma resolução diferente do original? |
| Q6 | Deve o formato PNG ser usado em vez de JPEG para os fotogramas intermédios, evitando perdas de compressão, apesar do maior custo de armazenamento? |
| Q7 | Como devem ser tratados os fotogramas duplicados ou estáticos em vídeos com pouco movimento — devem ser processados individualmente ou otimizados? |
| Q8 | A estimativa do tempo de processamento apresentada ao utilizador antes da confirmação deve ser obrigatória ou opcional? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| Claude (Anthropic) | Geração da primeira versão do caso de uso completo, incluindo fluxos alternativos, exceções e regras de negócio | Revisão integral por todos os membros da equipa; refinamento das regras de negócio RN1 e RN3 para alinhar com os limites de perfil do PictuRAS existente; ajuste dos fluxos alternativos FA2 e FA5 para refletir cenários reais de processamento de vídeo |
| Claude (Anthropic) | Derivação de requisitos funcionais e não funcionais a partir do caso de uso | Validação cruzada de cada requisito com o caso de uso de origem; eliminação de 3 requisitos redundantes; refinamento dos critérios de aceitação para serem verificáveis |
| Claude (Anthropic) | Elaboração da secção 4 da ERS, incluindo classificação ISO/IEC 25010 e matriz de rastreabilidade | Verificação manual da cobertura completa de todos os elementos do caso de uso na matriz; validação dos alvos MVP e produção com base na experiência da equipa com o sistema existente |

---

## 4. Especificação de Requisitos do Sistema (ERS)

**Caso de Uso:** UC-VID-003 — Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo  
**Versão do dossiê:** v1.1  
**Baseline do Exercício 1:** v1.0 — IDs REQ-VID-FRAME-001 a REQ-VID-FRAME-008 (esboço inicial)

### 4.1 Requisitos da ERS

#### 4.1.1 Requisitos Funcionais

| **ID** | **Requisito** | **Prioridade** | **Evolução** | **Novo/Alt** | **Origem (UC / RN / decisão)** | **Justificação** | **Critério de aceitação / verificação** |
|--------|---------------|----------------|--------------|--------------|--------------------------------|-----------------|----------------------------------------|
| REQ-VID-FRAME-001 | O sistema deve apresentar ao utilizador a lista de ferramentas de imagem disponíveis, organizadas por categoria (básicas e avançadas), com os respetivos parâmetros configuráveis, ao selecionar a opção "Aplicar Ferramenta a Fotogramas". | Deve ter | Mantido | NOVO | UC-VID-003, passo 3 | O utilizador necessita de conhecer as ferramentas disponíveis e os seus parâmetros antes de iniciar o processamento. | Dado que o utilizador selecionou um vídeo e escolheu "Aplicar Ferramenta a Fotogramas", quando o sistema carrega a interface, então são apresentadas todas as ferramentas ativas agrupadas em "Básicas" e "Avançadas (IA)", cada uma com os parâmetros editáveis. |
| REQ-VID-FRAME-002 | O sistema deve permitir ao utilizador selecionar uma ferramenta de imagem e configurar os seus parâmetros antes de iniciar o processamento. | Deve ter | Mantido | NOVO | UC-VID-003, passo 4 | A configuração dos parâmetros é essencial para que o utilizador controle o resultado visual do processamento. | Dado que a lista de ferramentas está apresentada, quando o utilizador seleciona "brightness" e define o fator como 1.5, então o valor é aceite e apresentado no resumo da operação. |
| REQ-VID-FRAME-003 | O sistema deve permitir ao utilizador definir um intervalo temporal do vídeo ao qual aplicar a ferramenta, com valor por omissão de "todos os fotogramas". | Deveria ter | Mantido | NOVO | UC-VID-003, passo 5; FA4 | Permite processamento seletivo, reduzindo tempo e recursos em vídeos longos. | Dado que o utilizador está a configurar a operação, quando define o intervalo como 00:05–00:20 num vídeo de 00:30, então o sistema estima o processamento apenas dos fotogramas nesse intervalo. |
| REQ-VID-FRAME-004 | O sistema deve permitir ao utilizador especificar a taxa de fotogramas de saída, mantendo a taxa original por omissão. | Poderia ter | Mantido | NOVO | UC-VID-003, passo 5; RN6 | Permite ao utilizador reduzir a taxa de fotogramas para diminuir o tempo de processamento ou para efeitos criativos. | Dado que o vídeo original tem 30 fps, quando o utilizador define a taxa de saída como 15 fps, então o sistema extrai e processa apenas 15 fotogramas por segundo e recompõe o vídeo a 15 fps. |
| REQ-VID-FRAME-005 | O sistema deve validar o vídeo de entrada (existência, codec suportado, duração dentro dos limites do perfil) e os parâmetros da ferramenta antes de iniciar o processamento. | Deve ter | Refinado | NOVO | UC-VID-003, passo 8; RN3; exceções | A validação prévia evita desperdício de recursos com processamentos que falhariam inevitavelmente. | Dado que o utilizador registado confirmou uma operação sobre um vídeo de 45 s, quando o sistema valida, então a operação é rejeitada com a mensagem "Duração máxima excedida (30 s para o seu perfil)". |
| REQ-VID-FRAME-006 | O sistema deve decompor o vídeo em fotogramas individuais através do microserviço de decomposição de vídeo, armazenando-os temporariamente no SeaweedFS. | Deve ter | Mantido | NOVO | UC-VID-003, passo 9 | A decomposição em fotogramas é o passo fundamental que permite a reutilização dos microserviços de ferramentas de imagem existentes. | Dado um vídeo MP4 (H.264) de 10 s a 30 fps, quando o microserviço de decomposição é invocado, então são extraídos 300 ficheiros JPEG individuais e armazenados no SeaweedFS com URIs únicos. |
| REQ-VID-FRAME-007 | O sistema deve enviar, para cada fotograma extraído, uma mensagem JSON para a fila RabbitMQ da ferramenta selecionada, contendo `messageId`, `timestamp`, `procedure`, `inputImageURI`, `outputImageURI` e os parâmetros configurados pelo utilizador. | Deve ter | Refinado | ALT | UC-VID-003, passo 11 | Reutiliza o padrão de mensagens existente do PictuRAS, garantindo compatibilidade total com os microserviços de ferramentas sem modificações. | Dado que 300 fotogramas foram extraídos e a ferramenta "brightness" foi selecionada com fator 1.5, quando o sistema envia as mensagens, então cada mensagem contém o `inputImageURI` do fotograma correspondente, o `outputImageURI` destino e `{"factor": 1.5}` como parâmetros. |
| REQ-VID-FRAME-008 | O sistema deve monitorizar o processamento individual de cada fotograma e atualizar o progresso em tempo real via WebSocket, indicando o fotograma atual e o total. | Deve ter | Refinado | NOVO | UC-VID-003, passos 10, 12, 14 | O processamento pode demorar vários minutos; o acompanhamento em tempo real é essencial para a experiência do utilizador. | Dado que o processamento de 300 fotogramas está em curso e 150 foram processados, quando o sistema envia a atualização, então o cliente recebe via WebSocket a mensagem com estado "A processar fotograma 150/300" em menos de 2 s. |
| REQ-VID-FRAME-009 | O sistema deve recompor o vídeo a partir dos fotogramas processados, mantendo a faixa de áudio original sincronizada, através do microserviço de recomposição de vídeo. | Deve ter | Mantido | NOVO | UC-VID-003, passo 13; RN5 | O vídeo resultante deve manter a experiência audiovisual completa, preservando a faixa de áudio sem dessincronização. | Dado que 300 fotogramas processados estão disponíveis e o vídeo original tem áudio, quando o microserviço de recomposição é invocado, então o vídeo resultante tem 10 s, 30 fps, e a faixa de áudio original sem desfasamento percetível. |
| REQ-VID-FRAME-010 | O sistema deve armazenar o vídeo resultante no SeaweedFS, associá-lo ao projeto do utilizador e eliminar todos os ficheiros temporários (fotogramas extraídos e processados). | Deve ter | Mantido | NOVO | UC-VID-003, passo 15; pós-condições | A limpeza dos ficheiros temporários é essencial para a gestão de armazenamento em ambiente cloud. | Dado que o vídeo foi recomposto com sucesso, quando o sistema conclui a operação, então o vídeo resultante está acessível no projeto do utilizador e nenhum ficheiro temporário de fotograma permanece no SeaweedFS. |
| REQ-VID-FRAME-011 | O sistema deve contabilizar a operação de aplicação de ferramenta a fotogramas como 1 operação avançada na quota do utilizador, independentemente do número de fotogramas ou ferramentas encadeadas. | Deve ter | Mantido | ALT | UC-VID-003, passo 15; RN2 | Define claramente o modelo de contagem para efeitos de quota, evitando ambiguidade e tratando o processamento como uma única operação lógica. | Dado que um utilizador registado com 4 operações usadas processa um vídeo de 300 fotogramas com 2 ferramentas encadeadas, quando a operação conclui, então a quota passa para 5 operações usadas (incremento de 1). |
| REQ-VID-FRAME-012 | O sistema deve permitir ao utilizador encadear múltiplas ferramentas em sequência para aplicação a cada fotograma, usando a saída de uma ferramenta como entrada da seguinte. | Deveria ter | Novo | NOVO | UC-VID-003, FA1 | Estende o conceito de encadeamento existente no PictuRAS para o domínio de vídeo, oferecendo maior flexibilidade ao utilizador. | Dado que o utilizador selecionou "brightness (1.5)" seguido de "contrast (1.2)", quando o sistema processa cada fotograma, então aplica primeiro o brilho e depois o contraste ao resultado, produzindo um fotograma com ambas as transformações aplicadas. |
| REQ-VID-FRAME-013 | O sistema deve, em caso de falha no processamento de um fotograma, registar o erro, tentar até 2 repetições e, se persistir, substituir pelo fotograma original e prosseguir com os restantes. | Deveria ter | Novo | NOVO | UC-VID-003, FA2; exceção "Erro individual no microserviço" | Em processamento de centenas/milhares de fotogramas, falhas isoladas são expectáveis; o sistema deve ser resiliente e não abortar toda a operação. | Dado que o fotograma 150/300 falhou no microserviço, quando o sistema tenta 2 repetições e todas falham, então o fotograma original é usado na posição 150, o processamento continua e o trabalho é marcado como "Concluído com avisos". |
| REQ-VID-FRAME-014 | O sistema deve permitir ao utilizador cancelar a operação a qualquer momento durante o processamento, interrompendo os fotogramas pendentes, aguardando os em curso e limpando os ficheiros temporários. | Deve ter | Mantido | NOVO | UC-VID-003, FA3 | Operações de longa duração devem ser canceláveis para respeitar a autonomia do utilizador e libertar recursos. | Dado que o processamento está no fotograma 100/300, quando o utilizador pressiona "Cancelar", então os fotogramas 101+ não são enviados para processamento, os ficheiros temporários são eliminados, o trabalho é marcado como "Cancelado" e a quota não é decrementada. |
| REQ-VID-FRAME-015 | O sistema deve restringir a aplicação de ferramentas de IA a um máximo de 30 fotogramas por invocação, permitindo apenas intervalos selecionados para estas ferramentas. | Deve ter | Novo | NOVO | RN1 | Ferramentas de IA são computacionalmente dispendiosas; limitar o número de fotogramas protege a infraestrutura e controla custos. | Dado que o utilizador seleciona "bg_remove_ai" para um vídeo de 300 fotogramas sem intervalo definido, quando tenta confirmar, então o sistema rejeita com "Ferramentas de IA limitadas a 30 fotogramas. Defina um intervalo temporal." |
| REQ-VID-FRAME-016 | O sistema deve suportar a extração e agregação de metadados por fotograma quando a ferramenta selecionada produz metadados em vez de imagens (e.g., `text_ai`, `obj_ai`), gerando um ficheiro JSON estruturado com referência temporal. | Poderia ter | Novo | NOVO | UC-VID-003, FA5 | Estende a utilidade das ferramentas de IA ao domínio de vídeo, permitindo análise temporal de conteúdo. | Dado que o utilizador aplica "obj_ai" a 30 fotogramas de um intervalo, quando o processamento conclui, então é gerado um ficheiro JSON com uma entrada por fotograma contendo o timestamp e os objetos detetados, disponível para transferência. |
| REQ-VID-FRAME-017 | O sistema deve impedir utilizadores anónimos de aceder à funcionalidade de aplicação de ferramentas a fotogramas de vídeo. | Deve ter | Mantido | ALT | RN4 | Funcionalidade de elevado custo computacional, reservada a utilizadores com conta e identificáveis para gestão de quota. | Dado que um utilizador anónimo navega para um vídeo, quando visualiza as opções disponíveis, então a opção "Aplicar Ferramenta a Fotogramas" não está visível ou está desativada com indicação "Funcionalidade disponível para utilizadores registados". |
| REQ-VID-FRAME-018 | O sistema deve apresentar ao utilizador um resumo da operação antes da confirmação, incluindo ferramenta(s), parâmetros, intervalo temporal, número estimado de fotogramas e estimativa de tempo de processamento. | Deveria ter | Novo | NOVO | UC-VID-003, passo 7 | Permite ao utilizador tomar uma decisão informada antes de iniciar uma operação potencialmente longa e intensiva. | Dado que o utilizador configurou "brightness (1.5)" para um vídeo de 10 s a 30 fps, quando o resumo é apresentado, então mostra "Ferramenta: Brilho, Fator: 1.5, Fotogramas: ~300, Tempo estimado: ~2 min". |
| REQ-VID-FRAME-019 | O sistema deve manter o vídeo original inalterado após qualquer operação de processamento de fotogramas, independentemente do resultado (sucesso, falha ou cancelamento). | Deve ter | Mantido | NOVO | Pós-condição (sucesso e mínima) | Garante a integridade dos dados do utilizador, princípio fundamental do PictuRAS. | Dado que um processamento foi iniciado, quando o sistema conclui (com qualquer estado), então o hash SHA-256 do vídeo original permanece inalterado. |
| REQ-VID-FRAME-020 | O sistema deve permitir ao utilizador pré-visualizar e transferir o vídeo processado após a conclusão da operação. | Deve ter | Mantido | NOVO | UC-VID-003, passo 16 | Permite ao utilizador validar o resultado antes de decidir mantê-lo ou descartá-lo. | Dado que o processamento concluiu com sucesso, quando o utilizador acede ao projeto, então pode reproduzir o vídeo processado no browser e transferi-lo para o seu dispositivo. |

#### 4.1.2 Requisitos Não Funcionais e de Qualidade

| **ID** | **Requisito** | **Característica ISO/IEC 25010** | **Alvo MVP** | **Alvo produção** | **Evolução** | **Origem (UC / DQ)** | **Critério de aceitação / verificação** |
|--------|---------------|----------------------------------|--------------|------------------|--------------|----------------------|----------------------------------------|
| REQ-VID-FRAME-NF01 | O sistema deve processar cada fotograma individual em menos de T segundos (excluindo tempo de fila). | Eficiência de Desempenho — Comportamento temporal | T ≤ 5 s por fotograma (ferramentas básicas) | T ≤ 2 s por fotograma (ferramentas básicas) | Novo | DQ-001 | Dado um fotograma de 1920×1080 e a ferramenta "brightness", quando processado pelo microserviço, então o tempo de processamento (excluindo fila) é inferior a 5 s no MVP. |
| REQ-VID-FRAME-NF02 | O sistema deve completar o processamento total de um vídeo de 30 s a 30 fps (900 fotogramas) com uma ferramenta básica em menos de T minutos. | Eficiência de Desempenho — Comportamento temporal | T ≤ 15 min | T ≤ 5 min | Novo | DQ-001 | Dado um vídeo de 30 s a 30 fps, quando "brightness (1.5)" é aplicada, então o processamento completo (decomposição + processamento + recomposição) termina em menos de 15 min no MVP. |
| REQ-VID-FRAME-NF03 | O sistema deve atualizar o progresso do processamento via WebSocket com latência inferior a T segundos. | Eficiência de Desempenho — Comportamento temporal | T ≤ 5 s | T ≤ 2 s | Novo | DQ-002; UC-VID-003, passos 10, 12, 14 | Dado que o fotograma 150/300 foi processado, quando a notificação é enviada, então o cliente recebe a atualização em menos de 5 s no MVP. |
| REQ-VID-FRAME-NF04 | O sistema deve suportar o processamento concorrente de pelo menos N trabalhos de processamento de fotogramas de vídeo em simultâneo. | Eficiência de Desempenho — Capacidade | N ≥ 2 trabalhos concorrentes | N ≥ 10 trabalhos concorrentes | Novo | DQ-003 | Dado que 2 utilizadores iniciam simultaneamente o processamento de vídeos distintos, quando ambos estão em curso, então ambos progridem e concluem sem erros. |
| REQ-VID-FRAME-NF05 | O sistema deve recuperar de falhas em fotogramas individuais sem abortar o processamento completo do vídeo, com uma taxa de sucesso mínima de P%. | Fiabilidade — Tolerância a falhas | P ≥ 90% dos fotogramas processados com sucesso para marcar como "Concluído com avisos" | P ≥ 99% | Refinado | DQ-004; UC-VID-003, FA2 | Dado que 10 de 300 fotogramas falham (após repetições), quando o processamento conclui, então o vídeo é marcado como "Concluído com avisos" e os 10 fotogramas falhados são substituídos pelos originais. |
| REQ-VID-FRAME-NF06 | O sistema deve eliminar todos os ficheiros temporários (fotogramas extraídos e processados) no prazo de T minutos após a conclusão, cancelamento ou falha de um trabalho. | Eficiência de Desempenho — Utilização de recursos | T ≤ 10 min | T ≤ 2 min | Novo | DQ-005; pós-condições | Dado que um trabalho terminou (qualquer estado), quando decorrem 10 min, então não existem ficheiros temporários associados a esse trabalho no SeaweedFS. |
| REQ-VID-FRAME-NF07 | O sistema deve garantir que o processamento de vídeos não degrada o tempo de resposta das operações normais de processamento de imagem em mais de X%. | Eficiência de Desempenho — Coexistência | X ≤ 50% de degradação | X ≤ 10% de degradação | Novo | DQ-003 | Dado que 2 trabalhos de vídeo estão em curso, quando um pedido normal de processamento de imagem é submetido, então o tempo de resposta não excede 150% do tempo médio sem carga de vídeo. |
| REQ-VID-FRAME-NF08 | O sistema deve apresentar mensagens de erro claras e acionáveis em português (Portugal) para todas as condições de erro do processamento de fotogramas. | Usabilidade — Proteção contra erros do utilizador | Mensagens para todas as exceções documentadas | Mensagens com sugestões de resolução e códigos de erro | Novo | DQ-006; exceções | Dado que o codec não é suportado, quando o erro é apresentado, então a mensagem indica os formatos suportados e sugere a conversão. |
| REQ-VID-FRAME-NF09 | O sistema deve registar (*log*) todas as operações de processamento de fotogramas, incluindo início, progresso, erros e conclusão, com nível de detalhe suficiente para diagnóstico. | Manutenibilidade — Analisabilidade | Registo de início, conclusão e erros (nível INFO/ERROR) | Registo detalhado por fotograma com métricas de desempenho (nível DEBUG disponível) | Novo | DQ-007 | Dado que um trabalho com 300 fotogramas concluiu, quando o operador consulta os logs, então encontra entradas para o início do trabalho, fotogramas falhados (se existirem) e conclusão com duração total. |
| REQ-VID-FRAME-NF10 | O sistema deve ser extensível para suportar novas ferramentas de imagem sem alterações ao módulo de processamento de fotogramas — basta que a nova ferramenta respeite o padrão de mensagens RabbitMQ existente. | Manutenibilidade — Modificabilidade | Arquitetura validada com pelo menos 3 ferramentas diferentes | Adição de nova ferramenta em menos de 1 dia de desenvolvimento | Novo | DQ-008 | Dado que uma nova ferramenta "sepia" é adicionada ao PictuRAS com a sua fila RabbitMQ, quando o módulo de fotogramas a deteta, então está disponível na lista de ferramentas sem alterações de código no módulo de vídeo. |

#### 4.1.3 Verificação da completude e dos limites do âmbito

| **Tópico a verificar** | **Aplicável?** | **Decisão / justificação** | **Requisito(s) relacionado(s)** |
|-----------------------|---------------|----------------------------|--------------------------------|
| Formato, codec, duração e dimensão do vídeo | Sim | O sistema aceita vídeos nos codecs H.264, VP8/VP9 e MJPEG. A duração é limitada pelo perfil (30 s registado, 5 min premium). A resolução é limitada à resolução original. | REQ-VID-FRAME-005, REQ-VID-FRAME-004, exceção "Codec não suportado", RN3, RN7 |
| Estado, progresso, cancelamento e resultado | Sim | O trabalho tem estados definidos (Em Progresso, Concluído, Concluído com avisos, Cancelado, Falhado). O progresso é reportado por fases (extração, processamento, recomposição) com granularidade por fotograma. O cancelamento é suportado. | REQ-VID-FRAME-008, REQ-VID-FRAME-014, REQ-VID-FRAME-020 |
| Falhas durante o processamento | Sim | Falhas individuais em fotogramas são tratadas com repetição (até 2x) e substituição pelo original. Falhas sistémicas (timeout, armazenamento) cancelam a operação com limpeza. | REQ-VID-FRAME-013, REQ-VID-FRAME-NF05, exceções documentadas |
| Persistência e expiração dos ficheiros | Sim | Fotogramas temporários são eliminados após conclusão. O vídeo resultante é persistido no SeaweedFS e associado ao projeto. A expiração do vídeo resultante segue as regras gerais do sistema (fora do âmbito específico deste UC). | REQ-VID-FRAME-010, REQ-VID-FRAME-NF06 |
| Perfis e contagem de operações | Sim | Anónimos excluídos. Registados limitados a 30 s e 5 ops/dia. Premium até 5 min e ilimitado. Cada processamento conta como 1 operação avançada. | REQ-VID-FRAME-011, REQ-VID-FRAME-017, REQ-VID-FRAME-005, RN2, RN3, RN4 |
| Encadeamento de ferramentas e processamento em lote | Sim | O encadeamento de múltiplas ferramentas por fotograma é suportado (FA1). O processamento em lote de múltiplos vídeos não está no âmbito deste caso de uso — cada vídeo é processado individualmente. | REQ-VID-FRAME-012, REQ-VID-FRAME-011 |

**Evolução:** *Mantido* = requisito preservado; *Refinado* = clarificado ou tornado verificável sem mudar a intenção; *Novo* = acrescentado para completar a ERS. **NOVO/ALT** indica o impacto face ao PictuRAS existente, não a novidade face ao Exercício 1.

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisito(s) relacionado(s)** |
|--------------------------------|-------------------------------------------|--------------------------|--------------------------------|
| Microserviços de ferramentas de imagem (border, brightness, contrast, cut, resize, rotate, saturation, binarization, cut_ai, upgrade_ai, bg_remove_ai, text_ai, obj_ai, people_ai, expand_ai) | Manter | Os microserviços existentes não são modificados. Recebem fotogramas individuais exatamente como recebem imagens normais, através das suas filas RabbitMQ, usando o mesmo padrão de mensagens JSON. | REQ-VID-FRAME-007, REQ-VID-FRAME-NF10 |
| Filas RabbitMQ | Estender | As filas existentes passam a receber, adicionalmente, mensagens de fotogramas de vídeo. O volume de mensagens pode aumentar significativamente (centenas/milhares por vídeo). Pode ser necessário configurar prioridades ou filas dedicadas. | REQ-VID-FRAME-007, REQ-VID-FRAME-NF04, REQ-VID-FRAME-NF07 |
| SeaweedFS (armazenamento) | Estender | Passa a armazenar temporariamente milhares de fotogramas extraídos e processados, além dos vídeos resultantes. Necessita de gestão de espaço temporário e limpeza automática. | REQ-VID-FRAME-006, REQ-VID-FRAME-010, REQ-VID-FRAME-NF06 |
| Sistema de quotas e perfis | Alterar | O sistema de quotas deve reconhecer a operação "aplicar ferramenta a fotogramas" como uma operação avançada contável (1 por processamento). Os limites de duração de vídeo por perfil devem ser configuráveis. | REQ-VID-FRAME-011, REQ-VID-FRAME-005, REQ-VID-FRAME-017 |
| API Gateway (Node.js) | Estender | Novos endpoints para: listar ferramentas disponíveis com parâmetros, iniciar processamento de fotogramas, consultar progresso, cancelar processamento, obter resultado. Integração com WebSocket para notificações de progresso. | REQ-VID-FRAME-001, REQ-VID-FRAME-008, REQ-VID-FRAME-014, REQ-VID-FRAME-020 |
| Frontend (Next.js) | Estender | Nova interface para: seleção de ferramenta e configuração de parâmetros, definição de intervalo temporal, apresentação de progresso em tempo real, pré-visualização e transferência do resultado. | REQ-VID-FRAME-001, REQ-VID-FRAME-002, REQ-VID-FRAME-003, REQ-VID-FRAME-008, REQ-VID-FRAME-018, REQ-VID-FRAME-020 |
| MongoDB | Estender | Novos documentos para: trabalhos de processamento de vídeo (estado, progresso, parâmetros, referências a ficheiros). Registo de metadados de fotogramas processados e falhados. | REQ-VID-FRAME-008, REQ-VID-FRAME-013, REQ-VID-FRAME-NF09 |
| WebSocket | Estender | Passa a suportar notificações de progresso granulares (por fotograma) para operações de longa duração, além das notificações existentes de processamento de imagem. | REQ-VID-FRAME-008, REQ-VID-FRAME-NF03 |
| Encadeamento de ferramentas | Estender | O mecanismo existente de encadeamento para imagens é estendido ao contexto de fotogramas: aplica-se a cadeia de ferramentas a cada fotograma individualmente, pela mesma ordem definida pelo utilizador. | REQ-VID-FRAME-012 |

### 4.3 Matriz de Rastreabilidade Atualizada

| **Elemento de origem** | **Descrição abreviada** | **Requisito(s) relacionado(s)** |
|------------------------|-------------------------|--------------------------------|
| Passo 3 | Apresentação da lista de ferramentas disponíveis | REQ-VID-FRAME-001 |
| Passo 4 | Seleção e configuração da ferramenta | REQ-VID-FRAME-002 |
| Passo 5 | Definição de intervalo temporal e taxa de fotogramas | REQ-VID-FRAME-003, REQ-VID-FRAME-004 |
| Passo 7 | Resumo e confirmação da operação | REQ-VID-FRAME-018 |
| Passo 8 | Validação do vídeo e parâmetros | REQ-VID-FRAME-005 |
| Passo 9 | Decomposição do vídeo em fotogramas | REQ-VID-FRAME-006 |
| Passos 10, 12, 14 | Atualização de progresso via WebSocket | REQ-VID-FRAME-008, REQ-VID-FRAME-NF03 |
| Passo 11 | Envio de mensagens para filas RabbitMQ | REQ-VID-FRAME-007 |
| Passo 12 | Processamento individual por fotograma | REQ-VID-FRAME-NF01 |
| Passo 13 | Recomposição do vídeo com áudio | REQ-VID-FRAME-009 |
| Passo 15 | Armazenamento e limpeza de temporários | REQ-VID-FRAME-010, REQ-VID-FRAME-NF06 |
| Passo 15 | Contabilização na quota | REQ-VID-FRAME-011 |
| Passo 16 | Pré-visualização e transferência | REQ-VID-FRAME-020 |
| FA1 — Encadeamento de ferramentas | Aplicação de múltiplas ferramentas em sequência | REQ-VID-FRAME-012 |
| FA2 — Falha parcial em fotogramas | Tratamento resiliente de falhas | REQ-VID-FRAME-013, REQ-VID-FRAME-NF05 |
| FA3 — Cancelamento pelo utilizador | Cancelamento e limpeza | REQ-VID-FRAME-014 |
| FA4 — Intervalo temporal específico | Seleção de intervalo | REQ-VID-FRAME-003 |
| FA5 — Ferramenta de IA com saída de metadados | Agregação de metadados por fotograma | REQ-VID-FRAME-016 |
| Exceção — Codec não suportado | Validação de formato | REQ-VID-FRAME-005, REQ-VID-FRAME-NF08 |
| Exceção — Timeout | Limite temporal de processamento | REQ-VID-FRAME-NF02 |
| Exceção — Armazenamento insuficiente | Gestão de espaço | REQ-VID-FRAME-NF06 |
| Exceção — Quota excedida | Controlo de acesso por perfil | REQ-VID-FRAME-011, REQ-VID-FRAME-017 |
| Exceção — Vídeo eliminado durante processamento | Integridade dos dados de entrada | REQ-VID-FRAME-019 |
| RN1 | Ferramentas básicas sem restrição; IA limitada a 30 fotogramas | REQ-VID-FRAME-015 |
| RN2 | 1 operação avançada por processamento | REQ-VID-FRAME-011 |
| RN3 | Duração máxima por perfil (30 s / 5 min) | REQ-VID-FRAME-005 |
| RN4 | Anónimos excluídos | REQ-VID-FRAME-017 |
| RN5 | Manutenção da faixa de áudio | REQ-VID-FRAME-009 |
| RN6 | Taxa de fotogramas configurável | REQ-VID-FRAME-004 |
| RN7 | Resolução máxima = original | REQ-VID-FRAME-005 |
| Pós-condição de sucesso | Vídeo resultante armazenado e original inalterado | REQ-VID-FRAME-010, REQ-VID-FRAME-019, REQ-VID-FRAME-020 |
| Pós-condição mínima | Limpeza, estado do trabalho e quota preservada | REQ-VID-FRAME-010, REQ-VID-FRAME-014, REQ-VID-FRAME-NF06 |
| DQ-001 | Desempenho temporal do processamento | REQ-VID-FRAME-NF01, REQ-VID-FRAME-NF02 |
| DQ-002 | Latência das notificações de progresso | REQ-VID-FRAME-NF03 |
| DQ-003 | Capacidade e coexistência com processamento de imagens | REQ-VID-FRAME-NF04, REQ-VID-FRAME-NF07 |
| DQ-004 | Tolerância a falhas em fotogramas individuais | REQ-VID-FRAME-NF05 |
| DQ-005 | Gestão de armazenamento temporário | REQ-VID-FRAME-NF06 |
| DQ-006 | Usabilidade das mensagens de erro | REQ-VID-FRAME-NF08 |
| DQ-007 | Registo de operações para diagnóstico | REQ-VID-FRAME-NF09 |
| DQ-008 | Extensibilidade para novas ferramentas | REQ-VID-FRAME-NF10 |

**Decisões de qualidade introduzidas nesta aula**

| **ID** | **Decisão de qualidade** | **Justificação** | **Requisito(s) relacionado(s)** |
|--------|--------------------------|-----------------|--------------------------------|
| DQ-001 | Definir limites temporais para o processamento individual por fotograma e para o processamento total de um vídeo. | O processamento de centenas/milhares de fotogramas é inerentemente demorado; limites mensuráveis permitem validar o desempenho do MVP e estabelecer metas para produção. | REQ-VID-FRAME-NF01, REQ-VID-FRAME-NF02 |
| DQ-002 | Garantir latência máxima nas notificações de progresso via WebSocket. | Operações longas sem feedback visual degradam a experiência do utilizador e geram incerteza sobre o estado do processamento. | REQ-VID-FRAME-NF03 |
| DQ-003 | Assegurar que o processamento de vídeo não degrada o serviço de processamento de imagens existente. | O PictuRAS já serve utilizadores com processamento de imagens; a adição de vídeo não pode comprometer o serviço existente. Processamento concorrente deve ser limitado. | REQ-VID-FRAME-NF04, REQ-VID-FRAME-NF07 |
| DQ-004 | Adotar uma estratégia de tolerância a falhas parciais com repetição e substituição, em vez de abortar todo o processamento. | Em processamento massivo, falhas isoladas são estatisticamente inevitáveis; abortar desperdiçaria todo o trabalho já realizado. | REQ-VID-FRAME-NF05 |
| DQ-005 | Limpar ficheiros temporários no prazo máximo definido após conclusão de qualquer trabalho. | A extração de fotogramas pode consumir centenas de MB por vídeo; sem limpeza atempada, o armazenamento esgota-se rapidamente. | REQ-VID-FRAME-NF06 |
| DQ-006 | Apresentar mensagens de erro acionáveis em português, com sugestão de resolução. | Erros técnicos não compreensíveis pelo utilizador final levam a abandono e insatisfação; mensagens claras orientam o utilizador. | REQ-VID-FRAME-NF08 |
| DQ-007 | Registar todas as operações de processamento com detalhe suficiente para diagnóstico. | O processamento assíncrono e distribuído torna o diagnóstico difícil sem registos adequados; essencial para manutenção e suporte. | REQ-VID-FRAME-NF09 |
| DQ-008 | Garantir extensibilidade do módulo de fotogramas para novas ferramentas sem alterações de código. | A arquitetura de microserviços do PictuRAS permite adicionar ferramentas; o módulo de vídeo deve manter essa propriedade. | REQ-VID-FRAME-NF10 |

**Verificações de cobertura**

- [x] Cada requisito funcional e não funcional aparece na matriz.
- [x] Cada requisito tem origem identificada: elemento do caso de uso, regra de negócio ou decisão de qualidade.
- [x] Todos os elementos relevantes do caso de uso têm requisito associado ou justificação para não terem.
- [x] Os tópicos excluídos na secção 4.1.3 estão justificados.
- [x] O impacto no sistema existente está atualizado e ligado aos requisitos relevantes.

---

## ✅ Lista de verificação antes de entregar

- [x] As secções 0 a 3 do dossiê foram preservadas; as assunções, questões em aberto e utilização de IA foram atualizadas.
- [x] A funcionalidade, o caso de uso e o perfil do Exercício 1 foram mantidos.
- [x] Requisitos funcionais estão completos para o âmbito e têm critérios verificáveis.
- [x] Requisitos de qualidade estão classificados e distinguem os alvos MVP e produção.
- [x] Os IDs existentes foram preservados quando a intenção não mudou.
- [x] A análise de completude não alargou o âmbito sem decisão explícita.
- [x] A matriz de rastreabilidade não tem requisitos órfãos nem elementos relevantes por cobrir.
- [x] As decisões de qualidade e os respetivos requisitos estão identificados.

---

*RAS · Grupo 27 · UC-VID-003 · v1.1 · 2026-10-14*
