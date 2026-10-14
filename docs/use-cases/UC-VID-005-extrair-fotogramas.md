# UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo

### Casos de Uso · Fase 1: Suporte a Vídeo no PictuRAS

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** |  |
| **Autores** | |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.1 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Extrair sequência de fotogramas de um vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Anónimo (limitado a 10 fotogramas, JPEG apenas), Registado (até 100 fotogramas) e Premium (até 1000 fotogramas) — todos os perfis beneficiam desta funcionalidade, mas com limites diferenciados para controlar custos de armazenamento e processamento |

**Justificação no contexto do MVP**

A extração de fotogramas é a ponte fundamental entre o domínio de vídeo e o domínio de imagem já existente no PictuRAS. Sem ela, os vídeos carregados ficam isolados das dezenas de ferramentas de processamento de imagem já implementadas. Esta funcionalidade valida o fluxo bidirecional vídeo↔imagem, permitindo que os utilizadores extraiam fotogramas-chave, criem sequências de imagens ou obtenham *stills* de um vídeo, e depois apliquem qualquer ferramenta existente (filtros, recorte, redimensionamento, etc.) sobre esses fotogramas. É, por isso, uma das primeiras funcionalidades a construir no MVP de vídeo.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-005 |
| **Nome** | Extrair Sequência de Fotogramas de um Vídeo |
| **Versão** | v1.1 |
| **Autor** | Alice Soares |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador extrair uma sequência de fotogramas de um vídeo como imagens individuais (JPEG ou PNG), integrando-as no projeto para processamento com as ferramentas de imagem existentes. |
| **Âmbito** | Módulo de vídeo do PictuRAS — extração de fotogramas, integração com a biblioteca de imagens do projeto e armazenamento em SeaweedFS S3. |
| **Ator Principal** | Utilizador (qualquer perfil: Anónimo, Registado ou Premium) |
| **Stakeholders e Interesses** | - **Utilizador**: pretende obter imagens individuais a partir de um vídeo para as processar, editar ou descarregar.<br>- **Proprietário do Sistema**: quer maximizar o valor das ferramentas de imagem já existentes, estendendo-as ao conteúdo de vídeo.<br>- **Equipa de Desenvolvimento**: valida a integração entre o subsistema de vídeo e o *pipeline* de processamento de imagem já existente.<br>- **Administrador de Infraestrutura**: necessita de controlo sobre o armazenamento consumido por extrações em massa. |
| **Pré-condições** | - O utilizador tem sessão iniciada (perfil registado ou premium) ou está a utilizar a plataforma em modo anónimo.<br>- O vídeo foi submetido com sucesso e encontra-se disponível no projeto do utilizador.<br>- O vídeo não está atualmente em processamento por outra operação.<br>- O utilizador não excedeu a quota de operações do seu perfil. |
| **Trigger** | O utilizador seleciona um vídeo no projeto e escolhe a opção «Extrair Fotogramas». |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre o projeto e navega até à biblioteca de vídeos. | Apresenta a lista de vídeos do projeto com miniaturas e metadados (duração, resolução, formato). |
| 2 | O utilizador seleciona um vídeo e escolhe a opção «Extrair Fotogramas». | — |
| 3 | — | Apresenta as propriedades do vídeo selecionado (duração, resolução, codec, FPS, tamanho) e as opções de extração disponíveis. |
| 4 | O utilizador seleciona o modo de extração: a) **Intervalo temporal** — 1 fotograma a cada X segundos; b) **Contagem fixa** — N fotogramas distribuídos uniformemente ao longo do vídeo; c) **Instantes específicos** — lista de *timestamps* (ex.: 00:05, 00:12, 01:30); d) **Todos os fotogramas** — extrai cada fotograma do vídeo. | Atualiza a estimativa do número de fotogramas a gerar com base no modo selecionado e nos parâmetros introduzidos. |
| 5 | O utilizador seleciona o formato de saída: JPEG (com qualidade de 1 a 100) ou PNG. | — |
| 6 | O utilizador seleciona a resolução de saída: resolução original do vídeo ou redução proporcional (ex.: 50%, 25%). | — |
| 7 | O utilizador confirma os parâmetros e inicia a extração. | — |
| 8 | — | Valida os parâmetros: número estimado de fotogramas, espaço de armazenamento necessário e conformidade com os limites do perfil do utilizador. |
| 9 | — | Se o número estimado de fotogramas for elevado (> 50), apresenta um aviso com a estimativa: «Serão extraídos aproximadamente N fotogramas. Pretende continuar?» |
| 10 | O utilizador confirma o aviso (se aplicável). | — |
| 11 | — | Cria um *job* de processamento na fila `extract_frames_queue` via RabbitMQ e regista o estado como «Em processamento». |
| 12 | — | Apresenta a barra de progresso em tempo real via WebSocket: «A extrair fotograma X/N…» |
| 13 | — | À medida que cada fotograma é extraído, armazena-o em SeaweedFS (S3) e adiciona-o como imagem ao projeto, com os campos `og_uri`, `new_uri`, `og_img_key` e `og_sha256` preenchidos. O nome segue a convenção `{nome_video}_frame_{NNNNN}.{ext}`. |
| 14 | — | Quando todos os fotogramas são extraídos, marca o *job* como «Concluído» e notifica o utilizador via WebSocket. |
| 15 | — | As imagens extraídas aparecem na biblioteca de imagens do projeto, prontas para processamento com as ferramentas de imagem existentes. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 — Extração de intervalo temporal parcial | O utilizador define um instante inicial e final (ex.: do minuto 01:00 ao 02:30) antes de selecionar o modo de extração → O sistema aplica os parâmetros de extração apenas ao intervalo temporal selecionado, em vez de ao vídeo completo. A estimativa de fotogramas é recalculada para o intervalo. |
| FA2 — Cancelamento durante o processamento | O utilizador clica em «Cancelar» durante a extração → O sistema interrompe o *job* na fila de processamento, marca-o como «Cancelado» e mantém os fotogramas já extraídos e armazenados no projeto. O utilizador é informado de quantos fotogramas foram extraídos antes do cancelamento. |
| FA3 — Criar novo projeto para os fotogramas | Antes de confirmar a extração (passo 7), o utilizador seleciona a opção «Extrair para novo projeto» → O sistema cria um novo projeto vazio, executa a extração e adiciona os fotogramas ao novo projeto em vez do projeto atual. |
| FA4 — Extração em lote de múltiplos vídeos | O utilizador seleciona vários vídeos e escolhe «Extrair Fotogramas» → O sistema aplica os mesmos parâmetros de extração a cada vídeo, criando *jobs* individuais na fila. O progresso é apresentado por vídeo. Os limites de fotogramas aplicam-se ao total combinado. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| O número estimado de fotogramas excede o limite do perfil do utilizador (Anónimo: 10, Registado: 100, Premium: 1000) | O sistema apresenta o erro: «O número de fotogramas estimado (N) excede o limite do seu perfil (M). Reduza o intervalo ou altere o modo de extração.» Os parâmetros são preservados para edição. |
| O espaço de armazenamento estimado excede a quota disponível | O sistema apresenta o erro: «Espaço de armazenamento insuficiente para esta extração. Espaço necessário: X MB. Espaço disponível: Y MB.» Sugere reduzir a qualidade JPEG ou a resolução de saída. |
| O codec do vídeo não é suportado para extração de fotogramas | O sistema apresenta o erro: «O formato de vídeo (codec) não é suportado para extração de fotogramas. Formatos suportados: H.264, H.265, VP8, VP9.» |
| A extração falha a meio do processamento (erro do microsserviço, falha de rede, etc.) | O sistema marca o *job* como «Falhou», notifica o utilizador via WebSocket com a mensagem: «A extração falhou no fotograma X/N. Os Y fotogramas já extraídos foram preservados.» Os fotogramas já armazenados permanecem no projeto. |
| A quota de operações diárias do perfil foi esgotada | O sistema apresenta o erro: «Atingiu o limite de operações do seu perfil para hoje. Tente novamente amanhã ou faça *upgrade* para Premium.» A opção de extração fica indisponível. |
| O ficheiro de vídeo está corrompido ou inacessível no armazenamento | O sistema apresenta o erro: «Não foi possível aceder ao ficheiro de vídeo. O ficheiro pode estar corrompido ou temporariamente indisponível.» Regista o erro no *log* do sistema. |
| O utilizador solicita a extração de todos os fotogramas de um vídeo longo (> 1000 fotogramas resultantes), mesmo sendo Premium | O sistema apresenta o aviso: «A extração de todos os fotogramas geraria N imagens, o que excede o limite máximo do sistema (1000). Considere usar o modo de intervalo temporal ou contagem fixa.» |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | Os fotogramas extraídos estão armazenados em SeaweedFS, registados na base de dados MongoDB como imagens do projeto, com os campos `og_uri`, `og_img_key` e `og_sha256` preenchidos. Cada imagem segue a convenção de nomenclatura `{nome_video}_frame_{NNNNN}.{ext}`. As imagens aparecem na biblioteca do projeto e estão disponíveis para processamento com todas as ferramentas de imagem existentes. O *job* está marcado como «Concluído». A operação foi contabilizada na quota do perfil. O vídeo original mantém-se inalterado. |
| Garantia Mínima | O vídeo original mantém-se inalterado. Quaisquer fotogramas já extraídos antes da falha ou cancelamento permanecem armazenados e acessíveis no projeto. O *job* está marcado como «Falhou» ou «Cancelado» com informação sobre o motivo. A quota de operações é contabilizada (a operação foi tentada). É apresentada uma mensagem de erro ou de cancelamento ao utilizador. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | O utilizador anónimo está limitado a um máximo de 10 fotogramas por extração e ao formato JPEG apenas. |
| RN2 | O utilizador registado (gratuito) está limitado a um máximo de 100 fotogramas por extração. |
| RN3 | O utilizador premium está limitado a um máximo de 1000 fotogramas por extração (extração de todos os fotogramas é permitida para vídeos curtos que resultem em ≤ 1000 fotogramas). |
| RN4 | Cada extração de fotogramas conta como 1 operação para efeitos de quota diária do perfil, independentemente do número de fotogramas extraídos. |
| RN5 | Os fotogramas extraídos são armazenados como imagens regulares no projeto, com todos os campos do modelo de imagem preenchidos (`og_uri`, `new_uri`, `og_img_key`, `og_sha256`). |
| RN6 | O formato de saída predefinido é JPEG com qualidade de 85%. |
| RN7 | A convenção de nomenclatura dos fotogramas é `{nome_video}_frame_{NNNNN}.{ext}`, onde `NNNNN` é o número sequencial do fotograma com preenchimento a zeros (5 dígitos). |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O vídeo está integralmente armazenado em SeaweedFS e acessível ao microsserviço de extração no momento do pedido. |
| A2 | A extração de fotogramas é uma operação demorada e deve ser processada assincronamente através da fila RabbitMQ. |
| A3 | O microsserviço de extração de fotogramas utiliza FFmpeg (ou biblioteca equivalente) para descodificar o vídeo e extrair fotogramas individuais. |
| A4 | A infraestrutura de WebSocket já existente no PictuRAS pode ser reutilizada para o acompanhamento do progresso da extração. |
| A5 | O modelo de dados de imagem existente em MongoDB é suficiente para representar fotogramas extraídos, sem necessidade de extensão do esquema. |
| A6 | O SeaweedFS S3 suporta a escrita concorrente de múltiplos ficheiros de imagem gerados pelo mesmo *job* de extração. |
| A7 | Os formatos de vídeo mais comuns submetidos pelos utilizadores utilizam codecs H.264 ou H.265. |
| A8 | A resolução «original» corresponde à resolução nativa do vídeo de origem; as opções de redução (50%, 25%) são proporcionais e mantêm a relação de aspeto. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Deve existir um limite absoluto no tamanho (em MB) do conjunto de fotogramas extraídos, independente do número de fotogramas? |
| Q2 | O utilizador deve poder pré-visualizar fotogramas individuais antes de confirmar a extração (ex.: amostra dos primeiros 3 fotogramas)? |
| Q3 | A extração deve suportar filtros adicionais (ex.: apenas fotogramas com alteração significativa em relação ao anterior, deteção de cenas)? |
| Q4 | Como tratar vídeos com taxa de *frames* variável (VFR)? A extração por intervalo temporal deve usar o tempo real ou o número de *frames*? |
| Q5 | Os fotogramas extraídos devem herdar metadados do vídeo de origem (ex.: data de criação, geolocalização)? |
| Q6 | Deve existir um mecanismo de limpeza automática de fotogramas extraídos após um período de inatividade? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| Claude (Anthropic) — geração de texto | Elaboração da primeira versão do caso de uso, incluindo fluxos principal e alternativos, exceções e regras de negócio. | Revisão integral pela equipa; ajuste dos limites de perfil para refletir as restrições reais de infraestrutura; reformulação de 2 exceções; adição de FA4 (extração em lote). |
| Claude (Anthropic) — derivação de requisitos | Derivação da lista inicial de requisitos funcionais e não funcionais, classificação ISO 25010 e matriz de rastreabilidade. | Verificação de cobertura contra o caso de uso; remoção de 1 requisito duplicado; refinamento dos critérios de aceitação para serem verificáveis; ajuste dos alvos MVP vs. produção. |

---

## 4. Especificação de Requisitos do Sistema (ERS)

**Caso de Uso:** UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo  
**Versão do dossiê:** v1.1  
**Baseline do Exercício 1:** v1.0 — IDs REQ-VID-FRAME-001 a REQ-VID-FRAME-008 (derivação inicial)

### 4.1 Requisitos da ERS

#### 4.1.1 Requisitos Funcionais

| **ID** | **Requisito** | **Prioridade** | **Evolução** | **Novo/Alt** | **Origem (UC / RN / decisão)** | **Justificação** | **Critério de aceitação / verificação** |
|--------|---------------|----------------|--------------|--------------|--------------------------------|-----------------|----------------------------------------|
| REQ-VID-FRAME-001 | O sistema deve apresentar as propriedades do vídeo selecionado (duração, resolução, codec, FPS, tamanho do ficheiro) antes de iniciar a configuração de extração. | Deve ter | Mantido | NOVO | UC-VID-005, passo 3 | O utilizador necessita de informação sobre o vídeo para tomar decisões informadas sobre os parâmetros de extração. | Dado um vídeo válido no projeto, quando o utilizador seleciona «Extrair Fotogramas», então o sistema apresenta duração (HH:MM:SS), resolução (largura × altura), codec, FPS e tamanho em MB. |
| REQ-VID-FRAME-002 | O sistema deve suportar quatro modos de extração de fotogramas: a) intervalo temporal (1 fotograma a cada X segundos), b) contagem fixa (N fotogramas distribuídos uniformemente), c) instantes específicos (lista de *timestamps*), d) todos os fotogramas. | Deve ter | Mantido | NOVO | UC-VID-005, passo 4 | A variedade de modos de extração cobre diferentes necessidades dos utilizadores, desde amostragem rápida até extração completa. | Dado um vídeo de 60 s a 30 FPS, quando o utilizador seleciona o modo «intervalo temporal» com X=10 s, então a estimativa apresentada é de 6 fotogramas. Dado o modo «contagem fixa» com N=5, então a estimativa é de 5 fotogramas uniformemente distribuídos. |
| REQ-VID-FRAME-003 | O sistema deve calcular e apresentar uma estimativa do número de fotogramas a gerar sempre que o utilizador altera os parâmetros de extração. | Deve ter | Refinado | NOVO | UC-VID-005, passo 4, passo 8 | A estimativa em tempo real permite ao utilizador ajustar parâmetros antes de submeter o *job*, evitando extrações desnecessárias. | Dado um vídeo de 120 s, quando o utilizador altera o intervalo de 5 s para 10 s, então a estimativa atualiza-se de 24 para 12 fotogramas em menos de 500 ms. |
| REQ-VID-FRAME-004 | O sistema deve permitir a seleção do formato de saída dos fotogramas: JPEG (com parâmetro de qualidade de 1 a 100) ou PNG. | Deve ter | Mantido | NOVO | UC-VID-005, passo 5, RN6 | Formatos diferentes servem propósitos distintos: JPEG para eficiência de armazenamento, PNG para qualidade sem perdas. | Dado que o utilizador seleciona JPEG com qualidade 85, quando a extração termina, então todos os fotogramas são ficheiros JPEG válidos com o nível de compressão correspondente. Dado que o utilizador seleciona PNG, então todos os fotogramas são ficheiros PNG válidos. |
| REQ-VID-FRAME-005 | O sistema deve permitir a seleção da resolução de saída dos fotogramas: resolução original ou redução proporcional (50%, 25%). | Deveria ter | Mantido | NOVO | UC-VID-005, passo 6 | A redução de resolução diminui o espaço de armazenamento consumido e o tempo de processamento, sendo adequada para utilizadores que não necessitam da resolução nativa. | Dado um vídeo de 1920×1080, quando o utilizador seleciona 50%, então os fotogramas extraídos têm resolução 960×540 e mantêm a relação de aspeto 16:9. |
| REQ-VID-FRAME-006 | O sistema deve validar os parâmetros de extração antes de criar o *job*, verificando: número estimado de fotogramas dentro dos limites do perfil, espaço de armazenamento disponível e conformidade com as regras de negócio. | Deve ter | Refinado | NOVO | UC-VID-005, passo 8, RN1, RN2, RN3 | A validação prévia evita a criação de *jobs* que irão falhar por violação de limites, poupando recursos do sistema. | Dado um utilizador anónimo que configura uma extração com 15 fotogramas estimados, quando confirma a extração, então o sistema rejeita com mensagem de erro referindo o limite de 10 fotogramas. |
| REQ-VID-FRAME-007 | O sistema deve apresentar um aviso de confirmação quando o número estimado de fotogramas excede 50, indicando o número estimado e o espaço de armazenamento aproximado. | Deveria ter | Novo | NOVO | UC-VID-005, passo 9 | Extrações com muitos fotogramas consomem recursos significativos; o aviso garante uma decisão consciente do utilizador. | Dado uma extração com 75 fotogramas estimados, quando o utilizador confirma os parâmetros, então o sistema apresenta o aviso «Serão extraídos aproximadamente 75 fotogramas (~X MB). Pretende continuar?» antes de criar o *job*. |
| REQ-VID-FRAME-008 | O sistema deve criar um *job* de processamento na fila `extract_frames_queue` do RabbitMQ com os parâmetros de extração validados e registar o estado como «Em processamento». | Deve ter | Mantido | NOVO | UC-VID-005, passo 11 | O processamento assíncrono via fila é essencial dado o tempo potencialmente longo da operação e a necessidade de não bloquear o utilizador. | Dado parâmetros válidos confirmados, quando o sistema cria o *job*, então uma mensagem é publicada na fila `extract_frames_queue` do RabbitMQ com os campos: `video_id`, `mode`, `parameters`, `output_format`, `output_resolution`, `user_id`, `project_id`. O estado do *job* é «Em processamento» em MongoDB. |
| REQ-VID-FRAME-009 | O sistema deve apresentar o progresso da extração em tempo real via WebSocket, indicando o fotograma atual e o total estimado (ex.: «A extrair fotograma 15/100…»). | Deve ter | Refinado | NOVO | UC-VID-005, passo 12 | O utilizador necessita de *feedback* visual sobre o andamento de uma operação que pode demorar vários minutos. | Dado um *job* em processamento com 100 fotogramas, quando o microsserviço extrai o fotograma 15, então o sistema envia uma mensagem WebSocket ao cliente com `{current: 15, total: 100, status: "processing"}` e a interface atualiza a barra de progresso. |
| REQ-VID-FRAME-010 | O sistema deve armazenar cada fotograma extraído em SeaweedFS (S3) e registá-lo como imagem no projeto em MongoDB, preenchendo os campos `og_uri`, `new_uri`, `og_img_key` e `og_sha256`. | Deve ter | Mantido | NOVO | UC-VID-005, passo 13, RN5 | Os fotogramas devem ser indistinguíveis de imagens submetidas diretamente, para serem compatíveis com todo o *pipeline* de processamento existente. | Dado um fotograma extraído com sucesso, quando é armazenado, então existe um objeto em SeaweedFS com a chave correspondente e um documento em MongoDB na coleção de imagens do projeto com `og_uri` apontando para o objeto S3, `og_sha256` calculado sobre o conteúdo do ficheiro e nome conforme RN7. |
| REQ-VID-FRAME-011 | O sistema deve nomear os fotogramas extraídos segundo a convenção `{nome_video}_frame_{NNNNN}.{ext}`, onde `NNNNN` é o número sequencial com preenchimento a zeros (5 dígitos). | Deve ter | Mantido | NOVO | UC-VID-005, passo 13, RN7 | A convenção de nomenclatura garante ordenação lexicográfica correta e identificação clara da origem do fotograma. | Dado um vídeo chamado «praia» e formato JPEG, quando são extraídos 3 fotogramas, então os ficheiros são nomeados `praia_frame_00001.jpg`, `praia_frame_00002.jpg`, `praia_frame_00003.jpg`. |
| REQ-VID-FRAME-012 | O sistema deve marcar o *job* como «Concluído» e notificar o utilizador via WebSocket quando todos os fotogramas tiverem sido extraídos e armazenados com sucesso. | Deve ter | Mantido | NOVO | UC-VID-005, passo 14 | O utilizador precisa de saber quando a extração terminou para começar a trabalhar com os fotogramas. | Dado um *job* de extração de 50 fotogramas, quando o último fotograma é armazenado, então o estado do *job* muda para «Concluído» em MongoDB e o sistema envia uma notificação WebSocket ao cliente com `{status: "completed", frames_extracted: 50}`. |
| REQ-VID-FRAME-013 | O sistema deve aplicar o formato JPEG com qualidade de 85% como predefinição quando o utilizador não altera o formato de saída. | Deveria ter | Novo | NOVO | RN6 | A predefinição sensata reduz a carga cognitiva do utilizador e garante um bom equilíbrio entre qualidade e tamanho do ficheiro. | Dado que o utilizador não altera o formato de saída, quando a extração é executada, então os fotogramas são gerados em JPEG com qualidade 85. |
| REQ-VID-FRAME-014 | O sistema deve contabilizar cada extração de fotogramas como 1 operação na quota diária do perfil do utilizador, independentemente do número de fotogramas extraídos. | Deve ter | Mantido | ALT | RN4, perfis existentes | A contagem unitária incentiva o uso da funcionalidade sem penalizar extrações maiores, mas mantém o controlo de utilização. | Dado um utilizador registado com 4 operações de 5 utilizadas, quando executa uma extração de 100 fotogramas, então a contagem passa para 5/5. Uma extração subsequente é rejeitada. |
| REQ-VID-FRAME-015 | O sistema deve limitar o número máximo de fotogramas por extração de acordo com o perfil do utilizador: anónimo ≤ 10, registado ≤ 100, premium ≤ 1000. | Deve ter | Mantido | ALT | RN1, RN2, RN3 | Os limites diferenciados protegem a infraestrutura e incentivam o *upgrade* de perfil. | Dado um utilizador registado que configura uma extração com 150 fotogramas estimados, quando confirma, então o sistema rejeita com a mensagem indicando o limite de 100 fotogramas para o perfil registado. |
| REQ-VID-FRAME-016 | O sistema deve restringir o utilizador anónimo ao formato de saída JPEG apenas. | Deve ter | Novo | ALT | RN1 | O formato PNG gera ficheiros substancialmente maiores; a restrição limita o custo de armazenamento para utilizadores não registados. | Dado um utilizador anónimo, quando acede ao ecrã de extração, então a opção PNG não está disponível e o formato JPEG está pré-selecionado. |
| REQ-VID-FRAME-017 | O sistema deve permitir ao utilizador definir um intervalo temporal parcial (instante inicial e final) para limitar a extração a um segmento do vídeo. | Deveria ter | Novo | NOVO | UC-VID-005, FA1 | Muitas vezes o utilizador só precisa de fotogramas de uma parte do vídeo; a extração parcial poupa tempo e armazenamento. | Dado um vídeo de 120 s, quando o utilizador define o intervalo 30 s–60 s com modo «intervalo temporal» de 10 s, então a estimativa é de 3 fotogramas e a extração opera apenas sobre os 30 segundos definidos. |
| REQ-VID-FRAME-018 | O sistema deve permitir ao utilizador cancelar uma extração em curso, preservando os fotogramas já extraídos e informando quantos foram concluídos. | Deve ter | Refinado | NOVO | UC-VID-005, FA2 | O cancelamento sem perda de trabalho parcial é essencial para operações longas; o utilizador não deve perder o que já foi processado. | Dado um *job* a extrair o fotograma 30/100, quando o utilizador clica em «Cancelar», então o *job* é marcado como «Cancelado», os 30 fotogramas já extraídos permanecem no projeto e o sistema apresenta «Extração cancelada. 30 de 100 fotogramas foram extraídos.» |
| REQ-VID-FRAME-019 | O sistema deve permitir ao utilizador optar por criar um novo projeto para receber os fotogramas extraídos, em vez de os adicionar ao projeto atual. | Poderia ter | Novo | NOVO | UC-VID-005, FA3 | Separar fotogramas num projeto dedicado melhora a organização quando o projeto original contém muitos outros conteúdos. | Dado que o utilizador seleciona «Extrair para novo projeto», quando a extração termina, então existe um novo projeto com o nome «{nome_video} — Fotogramas» contendo apenas os fotogramas extraídos. |
| REQ-VID-FRAME-020 | O sistema deve suportar a extração em lote, aplicando os mesmos parâmetros de extração a múltiplos vídeos selecionados, com *jobs* individuais por vídeo. | Poderia ter | Novo | NOVO | UC-VID-005, FA4 | A extração em lote é eficiente para utilizadores que trabalham com múltiplos vídeos e necessitam de fotogramas de todos. | Dado 3 vídeos selecionados com modo «contagem fixa» de 10 fotogramas, quando o utilizador confirma, então são criados 3 *jobs* na fila e o limite de fotogramas aplica-se ao total (30 fotogramas). |
| REQ-VID-FRAME-021 | O sistema deve rejeitar a extração quando o codec do vídeo não é suportado, apresentando a lista de codecs aceites (H.264, H.265, VP8, VP9). | Deve ter | Novo | NOVO | UC-VID-005, exceção «codec não suportado» | A deteção prévia de codecs incompatíveis evita falhas durante o processamento e informa o utilizador de forma clara. | Dado um vídeo com codec AV1, quando o utilizador tenta extrair fotogramas, então o sistema apresenta «Codec não suportado. Formatos suportados: H.264, H.265, VP8, VP9.» |
| REQ-VID-FRAME-022 | O sistema deve, em caso de falha durante o processamento, marcar o *job* como «Falhou», preservar os fotogramas já extraídos e notificar o utilizador com informação sobre o ponto de falha. | Deve ter | Refinado | NOVO | UC-VID-005, exceção «falha a meio», garantia mínima | A preservação do trabalho parcial e a informação detalhada permitem ao utilizador decidir se quer repetir a extração ou trabalhar com os fotogramas já obtidos. | Dado um *job* que falha no fotograma 45/100, quando o erro ocorre, então o *job* é marcado como «Falhou» em MongoDB, os 44 fotogramas anteriores permanecem no projeto e o utilizador recebe a notificação «A extração falhou no fotograma 45/100. 44 fotogramas foram preservados.» |
| REQ-VID-FRAME-023 | O sistema deve manter o ficheiro de vídeo original inalterado após qualquer operação de extração (sucesso, falha ou cancelamento). | Deve ter | Mantido | NOVO | UC-VID-005, pós-condição de sucesso e garantia mínima | A integridade do vídeo original é um princípio fundamental — a extração é uma operação de leitura que não deve modificar a fonte. | Dado uma extração concluída (sucesso, falha ou cancelamento), quando se compara o hash SHA-256 do ficheiro de vídeo com o valor registado no momento do carregamento, então os valores são idênticos. |

#### 4.1.2 Requisitos Não Funcionais e de Qualidade

| **ID** | **Requisito** | **Característica ISO/IEC 25010** | **Alvo MVP** | **Alvo produção** | **Evolução** | **Origem (UC / DQ)** | **Critério de aceitação / verificação** |
|--------|---------------|----------------------------------|--------------|-------------------|--------------|----------------------|----------------------------------------|
| REQ-VID-FRAME-NF-001 | O sistema deve iniciar o processamento do *job* de extração em menos de T segundos após a submissão pelo utilizador. | Eficiência de Desempenho — Comportamento temporal | T ≤ 10 s | T ≤ 3 s | Novo | DQ-001 | Dado um *job* submetido à fila `extract_frames_queue`, quando a fila não está congestionada (< 10 *jobs* pendentes), então o microsserviço inicia o processamento em menos de T segundos (medido como diferença entre timestamp de publicação e timestamp de início de processamento). |
| REQ-VID-FRAME-NF-002 | O sistema deve extrair fotogramas a uma taxa mínima de R fotogramas por segundo (resolução original, JPEG 85%). | Eficiência de Desempenho — Comportamento temporal | R ≥ 5 frames/s | R ≥ 15 frames/s | Novo | DQ-002 | Dado um vídeo 1080p H.264, quando a extração está em curso, então a taxa média de extração é ≥ R fotogramas por segundo, medida como total de fotogramas / tempo total de processamento. |
| REQ-VID-FRAME-NF-003 | O sistema deve atualizar o progresso da extração na interface do utilizador com latência máxima de L milissegundos desde o evento do microsserviço. | Eficiência de Desempenho — Comportamento temporal | L ≤ 2000 ms | L ≤ 500 ms | Novo | DQ-003, UC-VID-005, passo 12 | Dado um *job* em processamento, quando o microsserviço emite um evento de progresso, então a mensagem WebSocket chega ao cliente em menos de L milissegundos (medido em ambiente de teste com rede local). |
| REQ-VID-FRAME-NF-004 | O sistema deve suportar pelo menos C *jobs* de extração em execução concorrente sem degradação superior a D% na taxa de extração por *job*. | Eficiência de Desempenho — Utilização de recursos | C ≥ 3, D ≤ 50% | C ≥ 10, D ≤ 30% | Novo | DQ-004 | Dado C *jobs* de extração em execução simultânea, quando cada *job* extrai fotogramas de vídeos 1080p, então a taxa de extração por *job* não é inferior a (100-D)% da taxa obtida com 1 *job* isolado. |
| REQ-VID-FRAME-NF-005 | O sistema deve completar a extração com sucesso em pelo menos P% das tentativas, excluindo erros causados por ficheiros corrompidos ou codecs não suportados. | Fiabilidade — Maturidade | P ≥ 95% | P ≥ 99,5% | Novo | DQ-005 | Dado 100 extrações de vídeos válidos (codecs suportados, ficheiros íntegros), quando executadas sequencialmente, então pelo menos P extrações completam com estado «Concluído». |
| REQ-VID-FRAME-NF-006 | O sistema deve preservar a integridade dos fotogramas já extraídos em caso de falha ou cancelamento do *job* (zero perda de dados parciais). | Fiabilidade — Tolerância a falhas | 100% preservação | 100% preservação | Novo | DQ-006, UC-VID-005, FA2, exceção «falha a meio» | Dado um *job* cancelado ou falhado com Y fotogramas já armazenados, quando o utilizador acede ao projeto, então todos os Y fotogramas estão acessíveis e os ficheiros em SeaweedFS são válidos (verificável por download e comparação de hash). |
| REQ-VID-FRAME-NF-007 | O microsserviço de extração de fotogramas deve recuperar automaticamente de falhas transitórias (timeout de rede, indisponibilidade temporária do SeaweedFS), retentando a operação até N vezes com *backoff* exponencial. | Fiabilidade — Recuperabilidade | N = 2 (retentativas) | N = 5 (retentativas) | Novo | DQ-007 | Dado uma falha transitória de escrita no SeaweedFS durante a extração do fotograma K, quando o microsserviço retenta, então a escrita é bem-sucedida na retentativa e o *job* prossegue sem intervenção manual. |
| REQ-VID-FRAME-NF-008 | A interface de configuração de extração deve ser utilizável sem formação prévia, apresentando descrições claras de cada modo de extração e valores predefinidos sensatos. | Usabilidade — Adequação ao reconhecimento | Descrições inline para cada modo; predefinições aplicadas | Tutoriais interativos, exemplos visuais para cada modo | Novo | DQ-008 | Dado um utilizador que nunca usou a funcionalidade, quando acede ao ecrã de extração, então cada modo de extração tem uma descrição de 1–2 linhas e um valor predefinido aplicável. O utilizador consegue iniciar uma extração com predefinições em ≤ 3 cliques após selecionar o vídeo. |
| REQ-VID-FRAME-NF-009 | O microsserviço de extração de fotogramas deve ser implantável como contentor Docker independente, comunicando exclusivamente via RabbitMQ e SeaweedFS S3, sem acoplamento direto a outros microsserviços. | Portabilidade — Instalabilidade | Dockerfile funcional, deploy manual | Helm chart, auto-scaling horizontal | Novo | DQ-009 | Dado o repositório do microsserviço, quando se executa `docker build` e `docker run` com as variáveis de ambiente de configuração (RabbitMQ URL, S3 endpoint), então o microsserviço arranca, subscreve a fila `extract_frames_queue` e processa *jobs* com sucesso. |

#### 4.1.3 Verificação da completude e dos limites do âmbito

| **Tópico a verificar** | **Aplicável?** | **Decisão / justificação** | **Requisito(s) relacionado(s)** |
|------------------------|---------------|----------------------------|--------------------------------|
| Formato, codec, duração e dimensão do vídeo | Sim | O sistema valida o codec do vídeo (H.264, H.265, VP8, VP9) antes de iniciar a extração. A duração e dimensão influenciam a estimativa de fotogramas e o aviso de volume. Formatos de contentor (MP4, WebM, MKV) são aceites desde que o codec seja suportado. | REQ-VID-FRAME-001, REQ-VID-FRAME-003, REQ-VID-FRAME-021 |
| Estado, progresso, cancelamento e resultado | Sim | O *job* passa pelos estados «Em processamento» → «Concluído» / «Falhou» / «Cancelado». O progresso é reportado em tempo real via WebSocket. O cancelamento é suportado com preservação de trabalho parcial. | REQ-VID-FRAME-008, REQ-VID-FRAME-009, REQ-VID-FRAME-012, REQ-VID-FRAME-018, REQ-VID-FRAME-022 |
| Falhas durante o processamento | Sim | Falhas a meio da extração são tratadas com preservação de fotogramas já extraídos, marcação do *job* como «Falhou» e notificação ao utilizador. Falhas transitórias são retentadas automaticamente. | REQ-VID-FRAME-006, REQ-VID-FRAME-022, REQ-VID-FRAME-NF-006, REQ-VID-FRAME-NF-007 |
| Persistência e expiração dos ficheiros | Sim | Os fotogramas são armazenados em SeaweedFS como imagens regulares do projeto. A expiração dos ficheiros é uma questão em aberto (Q6) e não está no âmbito do MVP. A persistência é garantida enquanto o projeto existir. | REQ-VID-FRAME-010, REQ-VID-FRAME-011 |
| Perfis e contagem de operações | Sim | Os três perfis (anónimo, registado, premium) têm limites diferenciados de fotogramas por extração. Cada extração conta como 1 operação na quota diária. O perfil anónimo está restrito a JPEG. | REQ-VID-FRAME-014, REQ-VID-FRAME-015, REQ-VID-FRAME-016 |
| Encadeamento de ferramentas e processamento em lote | Sim (parcial) | Os fotogramas extraídos são imagens regulares do projeto e são imediatamente compatíveis com todas as ferramentas de imagem existentes, incluindo encadeamento. A extração em lote (FA4) é suportada como funcionalidade secundária. O encadeamento automático pós-extração (ex.: extrair + aplicar filtro) está fora do âmbito deste caso de uso. | REQ-VID-FRAME-010, REQ-VID-FRAME-020 |

**Evolução:** *Mantido* = requisito preservado; *Refinado* = clarificado ou tornado verificável sem mudar a intenção; *Novo* = acrescentado para completar a ERS. **NOVO/ALT** indica o impacto face ao PictuRAS existente, não a novidade face ao Exercício 1.

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisito(s) relacionado(s)** |
|--------------------------------|-------------------------------------------|--------------------------|--------------------------------|
| Modelo de dados de imagem (MongoDB) | Manter | Os fotogramas extraídos reutilizam o modelo de imagem existente sem alterações. Os campos `og_uri`, `new_uri`, `og_img_key` e `og_sha256` são preenchidos normalmente. | REQ-VID-FRAME-010 |
| Armazenamento SeaweedFS (S3) | Estender | O volume de escrita aumenta significativamente: uma extração pode gerar centenas de ficheiros de imagem de uma só vez. É necessário garantir que o SeaweedFS suporta a escrita concorrente e o volume adicional. | REQ-VID-FRAME-010, REQ-VID-FRAME-NF-004 |
| RabbitMQ — filas de processamento | Estender | É criada uma nova fila `extract_frames_queue` dedicada à extração de fotogramas. A estrutura de mensagens segue o padrão das filas existentes, com campos adicionais para os parâmetros de extração. | REQ-VID-FRAME-008 |
| Infraestrutura WebSocket | Manter | Reutilização da infraestrutura WebSocket existente para notificações de progresso. A frequência de mensagens pode ser maior do que nas operações de imagem (um evento por fotograma), podendo requerer *throttling*. | REQ-VID-FRAME-009, REQ-VID-FRAME-012, REQ-VID-FRAME-NF-003 |
| Sistema de perfis e quotas | Alterar | É necessário estender o sistema de quotas para incluir os limites de fotogramas por extração por perfil (10/100/1000). A contagem de operações diárias já existe, mas deve reconhecer a extração como operação contabilizável. | REQ-VID-FRAME-014, REQ-VID-FRAME-015, REQ-VID-FRAME-016 |
| Biblioteca de imagens do projeto (frontend) | Estender | A biblioteca deve apresentar os fotogramas extraídos juntamente com as imagens submetidas diretamente. Pode ser útil adicionar um filtro ou agrupamento «Fotogramas de {nome_video}» para organização, embora não seja obrigatório no MVP. | REQ-VID-FRAME-010, REQ-VID-FRAME-011 |
| Pipeline de processamento de imagem existente | Manter | As ferramentas de imagem existentes (filtros, recorte, redimensionamento, etc.) funcionam sobre os fotogramas sem alteração, pois estes são imagens regulares do projeto. | REQ-VID-FRAME-010 |
| API Gateway (Node.js) | Estender | Novos *endpoints* para: iniciar extração, consultar estado do *job*, cancelar extração, listar fotogramas de uma extração. Segue o padrão REST existente. | REQ-VID-FRAME-008, REQ-VID-FRAME-018 |
| Gestão de projetos | Estender | Suporte para a criação de um novo projeto a partir de uma extração (FA3). A lógica de criação de projetos já existe; a extensão consiste em permitir a criação associada a um *job* de extração. | REQ-VID-FRAME-019 |

### 4.3 Matriz de Rastreabilidade Atualizada

| **Elemento de origem** | **Descrição abreviada** | **Requisito(s) relacionado(s)** |
|------------------------|-------------------------|--------------------------------|
| Passo 3 — Apresentação das propriedades do vídeo | O sistema mostra metadados do vídeo antes da configuração | REQ-VID-FRAME-001 |
| Passo 4 — Seleção do modo de extração | O utilizador escolhe entre 4 modos de extração | REQ-VID-FRAME-002, REQ-VID-FRAME-003 |
| Passo 5 — Seleção do formato de saída | O utilizador escolhe JPEG ou PNG | REQ-VID-FRAME-004 |
| Passo 6 — Seleção da resolução de saída | O utilizador escolhe resolução original ou reduzida | REQ-VID-FRAME-005 |
| Passo 8 — Validação dos parâmetros | O sistema valida limites de perfil e armazenamento | REQ-VID-FRAME-006, REQ-VID-FRAME-015 |
| Passo 9 — Aviso de volume elevado | O sistema alerta para extrações com > 50 fotogramas | REQ-VID-FRAME-007 |
| Passo 11 — Criação do *job* na fila | O sistema publica mensagem na `extract_frames_queue` | REQ-VID-FRAME-008 |
| Passo 12 — Progresso em tempo real | O sistema reporta progresso via WebSocket | REQ-VID-FRAME-009, REQ-VID-FRAME-NF-003 |
| Passo 13 — Armazenamento dos fotogramas | Cada fotograma é armazenado em S3 e registado em MongoDB | REQ-VID-FRAME-010, REQ-VID-FRAME-011 |
| Passo 14 — Conclusão e notificação | O *job* é marcado como concluído | REQ-VID-FRAME-012 |
| FA1 — Intervalo temporal parcial | O utilizador limita a extração a um segmento do vídeo | REQ-VID-FRAME-017 |
| FA2 — Cancelamento com preservação | O utilizador cancela; fotogramas parciais são mantidos | REQ-VID-FRAME-018, REQ-VID-FRAME-NF-006 |
| FA3 — Novo projeto para fotogramas | Fotogramas extraídos vão para um projeto novo | REQ-VID-FRAME-019 |
| FA4 — Extração em lote | Extração simultânea de múltiplos vídeos | REQ-VID-FRAME-020 |
| Exceção — Codec não suportado | O sistema rejeita vídeos com codecs incompatíveis | REQ-VID-FRAME-021 |
| Exceção — Falha a meio do processamento | Preservação de fotogramas parciais em caso de falha | REQ-VID-FRAME-022, REQ-VID-FRAME-NF-006, REQ-VID-FRAME-NF-007 |
| Pós-condição — Vídeo original inalterado | O ficheiro de vídeo não é modificado | REQ-VID-FRAME-023 |
| RN1 — Limite anónimo (10 fotogramas, JPEG) | Restrições do perfil anónimo | REQ-VID-FRAME-015, REQ-VID-FRAME-016 |
| RN2 — Limite registado (100 fotogramas) | Restrições do perfil registado | REQ-VID-FRAME-015 |
| RN3 — Limite premium (1000 fotogramas) | Restrições do perfil premium | REQ-VID-FRAME-015 |
| RN4 — Contagem como 1 operação | Cada extração conta como 1 operação na quota | REQ-VID-FRAME-014 |
| RN5 — Fotogramas como imagens regulares | Fotogramas são indistinguíveis de imagens submetidas | REQ-VID-FRAME-010 |
| RN6 — Predefinição JPEG 85% | Formato e qualidade predefinidos | REQ-VID-FRAME-013 |
| RN7 — Convenção de nomenclatura | Nome dos ficheiros segue padrão definido | REQ-VID-FRAME-011 |
| DQ-001 — Latência de início do *job* | Tempo entre submissão e início do processamento | REQ-VID-FRAME-NF-001 |
| DQ-002 — Taxa de extração de fotogramas | Velocidade mínima de extração | REQ-VID-FRAME-NF-002 |
| DQ-003 — Latência das notificações WebSocket | Tempo de entrega das atualizações de progresso | REQ-VID-FRAME-NF-003 |
| DQ-004 — Concorrência de *jobs* | Suporte a múltiplas extrações simultâneas | REQ-VID-FRAME-NF-004 |
| DQ-005 — Fiabilidade da extração | Taxa de sucesso em condições normais | REQ-VID-FRAME-NF-005 |
| DQ-006 — Preservação de dados parciais | Zero perda em caso de falha ou cancelamento | REQ-VID-FRAME-NF-006 |
| DQ-007 — Recuperação de falhas transitórias | Retentativas automáticas com *backoff* | REQ-VID-FRAME-NF-007 |
| DQ-008 — Usabilidade da configuração | Interface intuitiva com predefinições | REQ-VID-FRAME-NF-008 |
| DQ-009 — Implantação independente | Microsserviço como contentor Docker autónomo | REQ-VID-FRAME-NF-009 |

**Decisões de qualidade introduzidas nesta aula**

| **ID** | **Decisão de qualidade** | **Justificação** | **Requisito(s) relacionado(s)** |
|--------|--------------------------|-----------------|--------------------------------|
| DQ-001 | O *job* de extração deve iniciar em ≤ 10 s (MVP) / ≤ 3 s (produção) após submissão. | A perceção de responsividade é crítica: se o sistema demora a reagir, o utilizador pode assumir que o pedido falhou e resubmeter, criando *jobs* duplicados. | REQ-VID-FRAME-NF-001 |
| DQ-002 | A taxa mínima de extração deve ser ≥ 5 frames/s (MVP) / ≥ 15 frames/s (produção). | Uma extração de 100 fotogramas a 5 frames/s demora 20 s, o que é aceitável para o MVP. Em produção, 15 frames/s reduz para ~7 s. Abaixo de 5 frames/s, o tempo de espera torna-se frustrante. | REQ-VID-FRAME-NF-002 |
| DQ-003 | A latência máxima de atualização de progresso via WebSocket é 2 s (MVP) / 500 ms (produção). | O utilizador precisa de *feedback* frequente para confiar que o sistema está a trabalhar. 2 s é aceitável no MVP; em produção, 500 ms proporciona uma experiência mais fluida. | REQ-VID-FRAME-NF-003 |
| DQ-004 | O sistema deve suportar ≥ 3 (MVP) / ≥ 10 (produção) *jobs* concorrentes sem degradação excessiva. | No MVP, 3 utilizadores simultâneos é realista. Em produção, o *auto-scaling* permite escalar horizontalmente. | REQ-VID-FRAME-NF-004 |
| DQ-005 | A taxa de sucesso da extração deve ser ≥ 95% (MVP) / ≥ 99,5% (produção) para vídeos válidos. | No MVP, 95% permite margem para falhas de integração; em produção, espera-se maturidade suficiente para 99,5%. | REQ-VID-FRAME-NF-005 |
| DQ-006 | Os fotogramas já extraídos devem ser preservados em 100% dos cenários de falha ou cancelamento. | A perda de trabalho parcial seria uma experiência gravemente negativa, especialmente em extrações longas. A preservação a 100% é um requisito duro independentemente do contexto. | REQ-VID-FRAME-NF-006 |
| DQ-007 | O microsserviço deve retentar automaticamente falhas transitórias (2× no MVP, 5× em produção) com *backoff* exponencial. | Falhas de rede e indisponibilidades momentâneas do SeaweedFS são esperadas. A retentativa automática evita falhas desnecessárias e intervenção manual. | REQ-VID-FRAME-NF-007 |
| DQ-008 | A interface de extração deve ser utilizável sem formação, com descrições e predefinições sensatas. | A funcionalidade tem 4 modos de extração e vários parâmetros; sem orientação, a complexidade pode intimidar utilizadores menos experientes. | REQ-VID-FRAME-NF-008 |
| DQ-009 | O microsserviço deve ser implantável como contentor Docker independente, comunicando apenas via RabbitMQ e S3. | A arquitetura de microsserviços do PictuRAS exige que cada ferramenta seja autónoma e desacoplada. A dependência direta a outros serviços violaria este princípio. | REQ-VID-FRAME-NF-009 |

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
