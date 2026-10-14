# UC-VID-001 — Submeter Vídeo para Processamento

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

**Funcionalidade:** Submeter Vídeo para Processamento

**Perfis abrangidos:** Todos os perfis de utilizador — anónimo (com limites restritos), registado/gratuito (com quota diária) e premium (sem limites operacionais).

**Justificação MVP:** A submissão de vídeo constitui a funcionalidade fundacional de toda a extensão de vídeo da plataforma PictuRAS. Sem a capacidade de carregar e submeter ficheiros de vídeo, nenhuma outra funcionalidade de processamento de vídeo poderá operar. Este caso de uso valida a totalidade do pipeline de vídeo — desde o carregamento no frontend, passando pelo armazenamento em SeaweedFS (compatível com S3), a validação de formato e codec, até à integração com o sistema existente de projetos e processos. Adicionalmente, permite validar a interação do vídeo com os perfis de utilizador, quotas de operações e regras de negócio diferenciadas, garantindo que a arquitetura de microsserviços existente suporta o novo tipo de conteúdo multimédia sem regressões no processamento de imagens.

---

## 2. Caso de Uso

### 2.1 Resumo

| **Campo** | **Descrição** |
|-----------|---------------|
| **Identificador** | UC-VID-001 |
| **Nome** | Submeter Vídeo para Processamento |
| **Ator principal** | Utilizador (anónimo, registado ou premium) |
| **Atores secundários** | Sistema de armazenamento SeaweedFS (S3); Gateway WebSocket; Serviço de validação de metadados; MongoDB |
| **Objetivo** | Permitir ao utilizador carregar um ou mais ficheiros de vídeo para a plataforma, validando formato, tamanho e duração conforme o perfil, armazenando-os no sistema de ficheiros distribuído e registando os metadados na base de dados, com acompanhamento em tempo real do progresso de upload. |
| **Âmbito** | Plataforma PictuRAS — módulo de gestão de conteúdos multimédia |
| **Nível** | Objetivo do utilizador |
| **Complexidade** | Elevada |

### 2.2 Pré-condições

| **ID** | **Pré-condição** |
|--------|-------------------|
| PC-01 | O utilizador acedeu à plataforma PictuRAS (autenticado ou em modo anónimo). |
| PC-02 | O utilizador possui um projeto criado ou acede à biblioteca de conteúdos. |
| PC-03 | O serviço de armazenamento SeaweedFS encontra-se operacional e acessível. |
| PC-04 | O gateway WebSocket encontra-se ativo para reportar progresso em tempo real. |
| PC-05 | O utilizador não excedeu a quota diária de operações (aplicável ao perfil registado). |

### 2.3 Fluxo Principal (Caminho Feliz)

| **Passo** | **Ator** | **Ação** |
|-----------|----------|----------|
| 1 | Utilizador | Navega para a área de projeto ou biblioteca de conteúdos na interface web. |
| 2 | Utilizador | Seleciona a opção «Submeter Vídeo» e escolhe um ficheiro de vídeo do sistema de ficheiros local (ou arrasta o ficheiro para a zona de upload). |
| 3 | Sistema | Realiza validação preliminar do tipo de ficheiro no lado do cliente, verificando a extensão e o MIME type contra os formatos suportados (MP4/H.264, MP4/H.265, MOV, WebM/VP9). |
| 4 | Sistema | Verifica o tamanho do ficheiro contra os limites do perfil do utilizador: anónimo ≤ 50 MB, registado ≤ 200 MB, premium ≤ 1 GB. |
| 5 | Sistema | Verifica a quota de operações diárias do utilizador. Para utilizadores registados, confirma que o número de operações realizadas no dia corrente não atingiu o limite de 5. |
| 6 | Sistema | Inicia o carregamento assíncrono do ficheiro de vídeo para o armazenamento SeaweedFS via API Gateway, utilizando upload multipart (chunked). |
| 7 | Sistema | Transmite ao frontend, via WebSocket, atualizações de progresso do upload em tempo real (percentagem concluída, velocidade de transferência estimada, tempo restante). |
| 8 | Utilizador | Acompanha o progresso do upload através da barra de progresso exibida na interface. |
| 9 | Sistema | Conclui o upload e confirma a integridade do ficheiro através de verificação de checksum (SHA-256). |
| 10 | Sistema | Extrai e valida os metadados do vídeo no servidor utilizando FFprobe: codec de vídeo, resolução, duração, frame rate (FPS) e codec de áudio. |
| 11 | Sistema | Valida a duração do vídeo contra os limites do perfil: anónimo ≤ 30 s, registado ≤ 2 min, premium ≤ 10 min. |
| 12 | Sistema | Valida a resolução do vídeo, garantindo que não excede 4K (3840×2160). |
| 13 | Sistema | Cria a entrada de vídeo na base de dados MongoDB, registando: identificador único, nome do ficheiro, caminho S3, metadados técnicos (codec, resolução, duração, FPS, tamanho), perfil do utilizador, timestamp de submissão e estado («disponível»). |
| 14 | Sistema | Associa o vídeo ao projeto do utilizador e torna-o visível na biblioteca de conteúdos. |
| 15 | Sistema | Atualiza a quota de operações diárias do utilizador (incrementa 1 operação). |
| 16 | Sistema | Envia notificação ao utilizador via WebSocket confirmando a conclusão da submissão, com pré-visualização do thumbnail gerado. |

### 2.4 Fluxos Alternativos

#### FA-01: Submissão em lote via ficheiro ZIP

| **Passo** | **Ator** | **Ação** |
|-----------|----------|----------|
| FA-01.1 | Utilizador | No passo 2, seleciona um ficheiro ZIP contendo múltiplos vídeos em vez de um ficheiro individual. |
| FA-01.2 | Sistema | Deteta que o ficheiro é um arquivo ZIP e inicia a extração temporária dos ficheiros contidos. |
| FA-01.3 | Sistema | Valida individualmente cada vídeo extraído (formato, tamanho e duração), conforme os passos 3, 4, 10, 11 e 12 do fluxo principal. |
| FA-01.4 | Sistema | Apresenta ao utilizador um relatório de pré-validação: lista de ficheiros válidos e inválidos, com motivo de rejeição para cada ficheiro inválido. |
| FA-01.5 | Utilizador | Confirma a submissão dos ficheiros válidos. |
| FA-01.6 | Sistema | Processa o upload de cada vídeo válido sequencialmente, reportando progresso individual e global via WebSocket. Cada vídeo válido conta como 1 operação para efeitos de quota. |
| FA-01.7 | Sistema | Retoma o fluxo principal a partir do passo 13 para cada vídeo submetido com sucesso. |

#### FA-02: Vídeo com nome duplicado — confirmar substituição

| **Passo** | **Ator** | **Ação** |
|-----------|----------|----------|
| FA-02.1 | Sistema | No passo 13, deteta que já existe um vídeo com o mesmo nome no projeto do utilizador. |
| FA-02.2 | Sistema | Apresenta ao utilizador uma caixa de diálogo com as opções: «Substituir», «Manter ambos» (renomear automaticamente com sufixo numérico) ou «Cancelar». |
| FA-02.3 | Utilizador | Seleciona a opção desejada. |
| FA-02.4a | Sistema | Se «Substituir»: remove o vídeo anterior do S3 e da base de dados, substitui pela nova versão. |
| FA-02.4b | Sistema | Se «Manter ambos»: atribui um nome único ao novo vídeo (ex.: `video_001(1).mp4`) e prossegue com o passo 13. |
| FA-02.4c | Sistema | Se «Cancelar»: remove o ficheiro carregado do S3 temporário, não consome quota, apresenta mensagem informativa ao utilizador. |

#### FA-03: Utilizador cancela o upload durante a transferência

| **Passo** | **Ator** | **Ação** |
|-----------|----------|----------|
| FA-03.1 | Utilizador | Durante o passo 7, clica no botão «Cancelar Upload» na barra de progresso. |
| FA-03.2 | Sistema | Interrompe imediatamente a transferência de chunks para o SeaweedFS. |
| FA-03.3 | Sistema | Inicia o processo de limpeza: remove todos os chunks parciais armazenados no S3. |
| FA-03.4 | Sistema | Não incrementa a quota de operações do utilizador. |
| FA-03.5 | Sistema | Apresenta mensagem de confirmação: «Upload cancelado. Nenhum vídeo foi submetido.» |

#### FA-04: Perfil anónimo — aplicação automática de marca de água

| **Passo** | **Ator** | **Ação** |
|-----------|----------|----------|
| FA-04.1 | Sistema | No passo 13, identifica que o utilizador possui perfil anónimo. |
| FA-04.2 | Sistema | Regista nos metadados do vídeo a flag `watermark: true`. |
| FA-04.3 | Sistema | Agenda, via mensagem na fila RabbitMQ, a tarefa de aplicação de marca de água «PictuRAS» sobre o vídeo, a ser executada pelo microsserviço de watermarking antes de qualquer processamento posterior. |
| FA-04.4 | Sistema | Atualiza o estado do vídeo para «a processar marca de água» e notifica o utilizador via WebSocket. |
| FA-04.5 | Sistema | Após conclusão da marca de água, atualiza o estado para «disponível» e prossegue com o fluxo principal. |

### 2.5 Exceções

| **ID** | **Condição** | **Passo de origem** | **Tratamento** |
|--------|-------------|----------------------|----------------|
| EX-01 | Formato ou codec do ficheiro não suportado | 3, 10 | O sistema apresenta mensagem de erro: «Formato de vídeo não suportado. Formatos aceites: MP4 (H.264/H.265), MOV, WebM (VP9).» O upload é cancelado, nenhum ficheiro é armazenado e a quota não é consumida. |
| EX-02 | Tamanho do ficheiro excede o limite do perfil | 4 | O sistema apresenta mensagem de erro indicando o tamanho máximo permitido para o perfil atual e sugere a atualização para um perfil superior. O upload não é iniciado e a quota não é consumida. |
| EX-03 | Duração do vídeo excede o limite do perfil | 11 | O sistema apresenta mensagem de erro indicando a duração máxima permitida para o perfil atual. O ficheiro já carregado é removido do S3, a quota não é consumida e é sugerida a atualização de perfil. |
| EX-04 | Quota diária de operações excedida (perfil registado) | 5 | O sistema apresenta mensagem: «Atingiu o limite de 5 operações diárias. Atualize para premium para operações ilimitadas.» O upload não é iniciado. |
| EX-05 | Interrupção da ligação de rede durante o upload | 6, 7 | O sistema deteta a perda de conexão WebSocket. Tenta reconexão automática durante 30 segundos. Se restabelecida, retoma o upload a partir do último chunk confirmado. Caso contrário, os chunks parciais são removidos do S3, a quota não é consumida e é apresentada mensagem: «Upload interrompido por falha de rede. Por favor, tente novamente.» |
| EX-06 | Serviço de armazenamento SeaweedFS indisponível | 6 | O sistema deteta a indisponibilidade do serviço S3. Apresenta mensagem: «Serviço de armazenamento temporariamente indisponível. Por favor, tente novamente mais tarde.» O upload não é iniciado, a quota não é consumida e é gerado um alerta interno para a equipa de operações. |
| EX-07 | Ficheiro corrompido detetado após upload | 9 | A verificação de checksum (SHA-256) revela inconsistência entre o ficheiro enviado e o armazenado. O ficheiro é removido do S3, a quota não é consumida e é apresentada mensagem: «O ficheiro carregado encontra-se corrompido. Por favor, verifique o ficheiro original e tente novamente.» |

### 2.6 Pós-condições

#### Pós-condições de sucesso

| **ID** | **Pós-condição** |
|--------|-------------------|
| PS-01 | O ficheiro de vídeo encontra-se armazenado no SeaweedFS (S3) no bucket correspondente ao projeto do utilizador. |
| PS-02 | Os metadados do vídeo (codec, resolução, duração, FPS, tamanho, caminho S3) encontram-se registados na coleção MongoDB do projeto. |
| PS-03 | O vídeo é visível na biblioteca de conteúdos do projeto e encontra-se no estado «disponível». |
| PS-04 | A quota de operações diárias do utilizador foi atualizada (incremento de 1 operação por vídeo submetido). |
| PS-05 | Um thumbnail representativo do vídeo foi gerado e associado à entrada na base de dados. |
| PS-06 | Para utilizadores anónimos, a tarefa de marca de água foi agendada na fila RabbitMQ. |

#### Pós-condições mínimas (em caso de falha)

| **ID** | **Pós-condição** |
|--------|-------------------|
| PM-01 | Nenhum ficheiro de vídeo permanece armazenado no S3 (chunks parciais foram removidos). |
| PM-02 | Nenhuma entrada de metadados foi criada ou persistida na base de dados MongoDB. |
| PM-03 | A quota de operações do utilizador não foi consumida. |
| PM-04 | O utilizador recebeu uma mensagem de erro clara e acionável, indicando o motivo da falha. |
| PM-05 | Os registos de log do sistema contêm informação suficiente para diagnóstico da falha. |

### 2.7 Regras de Negócio

| **ID** | **Regra** | **Descrição** |
|--------|-----------|---------------|
| RN-01 | Limite de tamanho para perfil anónimo | Utilizadores anónimos podem submeter vídeos com tamanho máximo de 50 MB e duração máxima de 30 segundos. |
| RN-02 | Limite de tamanho para perfil registado | Utilizadores registados (gratuitos) podem submeter vídeos com tamanho máximo de 200 MB e duração máxima de 2 minutos. |
| RN-03 | Limite de tamanho para perfil premium | Utilizadores premium podem submeter vídeos com tamanho máximo de 1 GB e duração máxima de 10 minutos. |
| RN-04 | Formatos suportados | São aceites os seguintes formatos e codecs de vídeo: MP4 (H.264 e H.265), MOV (qualquer codec suportado), WebM (VP9). |
| RN-05 | Resolução máxima | A resolução máxima suportada é 4K (3840×2160 píxeis). Vídeos com resolução superior são rejeitados. |
| RN-06 | Contabilização de quota | Cada vídeo submetido com sucesso conta como 1 operação para efeitos da quota diária de operações do utilizador. |
| RN-07 | Marca de água para anónimos | Todos os vídeos submetidos por utilizadores anónimos recebem automaticamente uma marca de água «PictuRAS» visível. |

### 2.8 Assunções

| **ID** | **Assunção** |
|--------|-------------|
| A-01 | O SeaweedFS suporta o armazenamento de ficheiros de vídeo de grande dimensão (até 1 GB) sem necessidade de configurações adicionais ou alterações arquiteturais. |
| A-02 | O upload pode ser retomado em caso de interrupção temporária de rede, através de mecanismo de upload por chunks; na impossibilidade de retoma, os uploads parciais são automaticamente limpos pelo sistema. |
| A-03 | O FFmpeg (em particular o FFprobe) encontra-se disponível no ambiente servidor para extração e validação de metadados de vídeo (codec, resolução, duração, FPS). |
| A-04 | O gateway WebSocket da arquitetura existente possui capacidade para reportar progresso de uploads de ficheiros de grande dimensão sem degradação de desempenho ou perda de conexões. |
| A-05 | A infraestrutura de rede entre o API Gateway e o SeaweedFS suporta transferências de ficheiros até 1 GB sem timeouts prematuros. |

### 2.9 Questões em Aberto

| **ID** | **Questão** | **Impacto** |
|--------|-------------|-------------|
| Q-01 | Os utilizadores anónimos devem poder efetuar upload de vídeo, ou apenas utilizar vídeos de demonstração pré-existentes? | Afeta a lógica de permissões e a necessidade do fluxo alternativo FA-04. |
| Q-02 | O sistema deve gerar automaticamente um thumbnail representativo do vídeo após submissão bem-sucedida? | Afeta a experiência do utilizador na biblioteca e requer processamento adicional com FFmpeg. |
| Q-03 | Os ficheiros de vídeo devem ser organizados no S3 no mesmo bucket que as imagens ou num bucket separado? | Afeta a estratégia de armazenamento, a organização lógica dos dados e potenciais políticas de lifecycle. |
| Q-04 | Deve existir um número máximo de uploads concorrentes por utilizador? | Afeta o dimensionamento de recursos, a gestão de filas e a experiência do utilizador. |
| Q-05 | A interface de upload deve suportar drag-and-drop além do seletor de ficheiros tradicional? | Afeta o design da UI e a complexidade de implementação no frontend (Next.js). |

---

## 3. Utilização de agentes de IA

A elaboração deste caso de uso recorreu a agentes de IA (Antigravity/Claude) nas seguintes fases:

### 3.1 Estruturação inicial do caso de uso

O agente de IA foi utilizado para gerar a estrutura inicial do documento, assegurando a cobertura completa de todos os campos requeridos pelo template de caso de uso. A estrutura foi posteriormente revista e ajustada pela equipa para refletir as especificidades técnicas da plataforma PictuRAS e da sua arquitetura de microsserviços.

### 3.2 Refinamento dos fluxos alternativos e exceções

O agente auxiliou na identificação e detalhamento dos fluxos alternativos e exceções, nomeadamente:
- A consideração de cenários de upload em lote via ZIP (FA-01), alinhado com a funcionalidade de batch processing existente para imagens.
- A identificação de exceções específicas de vídeo, como codec não suportado, duração excessiva e ficheiro corrompido, que não têm paralelo direto no processamento de imagens.
- O tratamento de interrupções de rede durante uploads de longa duração, cenário mais crítico para vídeo do que para imagens devido ao tamanho dos ficheiros.

### 3.3 Validação das regras de negócio contra a codebase existente

O agente foi utilizado para analisar a codebase existente do PictuRAS e validar:
- A compatibilidade dos limites de tamanho propostos com a configuração do API Gateway (Node.js).
- A viabilidade de integração com o sistema de quotas e perfis existente.
- A consistência das regras de negócio com o modelo SaaS e os perfis de utilizador definidos.

### 3.4 Especificação de requisitos não funcionais

O agente contribuiu para a definição de métricas mensuráveis nos requisitos não funcionais, garantindo metas realistas para o MVP e para produção, com base em benchmarks da indústria para plataformas de processamento de vídeo.

> [!NOTE]
> Todas as saídas geradas pelo agente de IA foram criteriosamente revistas, validadas e ajustadas pela equipa do Grupo 27. A responsabilidade final pelo conteúdo é inteiramente da equipa.

---

## 4. Especificação de Requisitos do Sistema (ERS)

### 4.1 Requisitos

#### 4.1.1 Requisitos Funcionais

| **ID** | **Requisito** | **Prioridade** | **Origem (UC)** |
|--------|---------------|----------------|-----------------|
| RF-VID-001 | O sistema deve permitir ao utilizador selecionar e submeter ficheiros de vídeo nos formatos MP4 (H.264/H.265), MOV e WebM (VP9) a partir do sistema de ficheiros local ou por drag-and-drop. | Must Have | UC-VID-001, Passo 2-3 |
| RF-VID-002 | O sistema deve validar o tipo MIME e a extensão do ficheiro de vídeo antes de iniciar o upload, rejeitando formatos não suportados com mensagem de erro descritiva. | Must Have | UC-VID-001, Passo 3, EX-01 |
| RF-VID-003 | O sistema deve aplicar limites de tamanho de ficheiro diferenciados por perfil de utilizador: anónimo ≤ 50 MB, registado ≤ 200 MB, premium ≤ 1 GB. | Must Have | UC-VID-001, Passo 4, RN-01/02/03 |
| RF-VID-004 | O sistema deve realizar o upload de vídeo de forma assíncrona para o SeaweedFS, utilizando mecanismo de upload multipart (chunked) para ficheiros de grande dimensão. | Must Have | UC-VID-001, Passo 6 |
| RF-VID-005 | O sistema deve transmitir, via WebSocket, atualizações de progresso do upload em tempo real ao frontend, incluindo percentagem concluída, velocidade estimada e tempo restante. | Must Have | UC-VID-001, Passo 7 |
| RF-VID-006 | O sistema deve extrair e validar os metadados do vídeo após upload (codec, resolução, duração, FPS) utilizando FFprobe, rejeitando vídeos que excedam os limites do perfil. | Must Have | UC-VID-001, Passos 10-12 |
| RF-VID-007 | O sistema deve aplicar limites de duração diferenciados por perfil: anónimo ≤ 30 s, registado ≤ 2 min, premium ≤ 10 min. | Must Have | UC-VID-001, Passo 11, RN-01/02/03 |
| RF-VID-008 | O sistema deve persistir os metadados do vídeo na base de dados MongoDB, incluindo: identificador único, nome, caminho S3, codec, resolução, duração, FPS, tamanho, perfil do utilizador, timestamp e estado. | Must Have | UC-VID-001, Passo 13 |
| RF-VID-009 | O sistema deve permitir a submissão de múltiplos vídeos em lote através de ficheiro ZIP, validando cada vídeo individualmente e apresentando relatório de pré-validação. | Should Have | UC-VID-001, FA-01 |
| RF-VID-010 | O sistema deve permitir ao utilizador cancelar um upload em curso, removendo automaticamente todos os chunks parciais do S3 e sem consumir quota de operações. | Must Have | UC-VID-001, FA-03 |
| RF-VID-011 | O sistema deve verificar a integridade do ficheiro após upload completo através de checksum SHA-256, rejeitando ficheiros corrompidos. | Should Have | UC-VID-001, Passo 9, EX-07 |
| RF-VID-012 | O sistema deve aplicar automaticamente marca de água «PictuRAS» em vídeos submetidos por utilizadores com perfil anónimo, agendando a tarefa via RabbitMQ. | Must Have | UC-VID-001, FA-04, RN-07 |
| RF-VID-013 | O sistema deve gerir conflitos de nomes de ficheiros, oferecendo ao utilizador as opções de substituir o vídeo existente, manter ambos (com renomeação automática) ou cancelar. | Should Have | UC-VID-001, FA-02 |
| RF-VID-014 | O sistema deve contabilizar cada vídeo submetido como 1 operação na quota diária do utilizador, impedindo novas submissões quando a quota for atingida (perfil registado: 5 operações/dia). | Must Have | UC-VID-001, Passo 5/15, RN-06, EX-04 |

#### 4.1.2 Requisitos Não Funcionais

| **ID** | **Requisito** | **Classificação ISO 25010** | **Meta MVP** | **Meta Produção** |
|--------|---------------|----------------------------|--------------|-------------------|
| RNF-VID-001 | **Desempenho (throughput de upload):** O sistema deve suportar a transferência de ficheiros de vídeo a uma taxa mínima sustentada, garantindo que o upload não constitui um bottleneck excessivo para o utilizador. | Eficiência de desempenho — Comportamento temporal | ≥ 5 MB/s para ficheiros até 200 MB em ligação de 100 Mbps | ≥ 10 MB/s para ficheiros até 1 GB em ligação de 100 Mbps |
| RNF-VID-002 | **Fiabilidade (disponibilidade do serviço de upload):** O serviço de upload de vídeo deve manter um nível de disponibilidade elevado, minimizando interrupções de serviço que impeçam os utilizadores de submeter conteúdos. | Fiabilidade — Disponibilidade | ≥ 95% de disponibilidade mensal | ≥ 99,5% de disponibilidade mensal |
| RNF-VID-003 | **Escalabilidade (uploads concorrentes):** O sistema deve suportar múltiplos uploads simultâneos sem degradação significativa de desempenho, garantindo isolamento entre operações de diferentes utilizadores. | Eficiência de desempenho — Capacidade | ≥ 10 uploads concorrentes sem degradação superior a 20% na taxa de transferência | ≥ 50 uploads concorrentes sem degradação superior a 15% na taxa de transferência |
| RNF-VID-004 | **Usabilidade (feedback de progresso):** A barra de progresso do upload deve atualizar-se com latência reduzida, proporcionando ao utilizador uma perceção clara e responsiva do estado da transferência. | Usabilidade — Operabilidade | Atualização da barra de progresso a cada ≤ 2 segundos | Atualização da barra de progresso a cada ≤ 500 ms |
| RNF-VID-005 | **Segurança (validação de conteúdo):** O sistema deve validar todos os ficheiros submetidos para prevenir uploads maliciosos (ficheiros disfarçados, payloads embebidos), verificando a consistência entre extensão, MIME type e cabeçalhos binários do ficheiro. | Segurança — Integridade | Validação de extensão + MIME type + magic bytes | Validação completa com análise antivírus integrada (ClamAV) |

#### 4.1.3 Verificação de Completude do Âmbito

A tabela seguinte verifica que todos os elementos do caso de uso estão cobertos pela especificação de requisitos.

| **Elemento do Caso de Uso** | **Requisito(s) Associado(s)** | **Cobertura** |
|-----------------------------|-------------------------------|---------------|
| Fluxo Principal (Passos 1-16) | RF-VID-001 a RF-VID-008, RF-VID-014 | ✅ Completa |
| FA-01: Upload em lote via ZIP | RF-VID-009 | ✅ Completa |
| FA-02: Conflito de nomes | RF-VID-013 | ✅ Completa |
| FA-03: Cancelamento de upload | RF-VID-010 | ✅ Completa |
| FA-04: Marca de água anónimos | RF-VID-012 | ✅ Completa |
| EX-01: Formato não suportado | RF-VID-002 | ✅ Completa |
| EX-02: Tamanho excedido | RF-VID-003 | ✅ Completa |
| EX-03: Duração excedida | RF-VID-007 | ✅ Completa |
| EX-04: Quota excedida | RF-VID-014 | ✅ Completa |
| EX-05: Interrupção de rede | RF-VID-004, RNF-VID-002 | ✅ Completa |
| EX-06: SeaweedFS indisponível | RNF-VID-002 | ✅ Completa |
| EX-07: Ficheiro corrompido | RF-VID-011 | ✅ Completa |
| RN-01 a RN-03: Limites por perfil | RF-VID-003, RF-VID-007 | ✅ Completa |
| RN-04: Formatos suportados | RF-VID-002 | ✅ Completa |
| RN-05: Resolução máxima | RF-VID-006 | ✅ Completa |
| RN-06: Contabilização de quota | RF-VID-014 | ✅ Completa |
| RN-07: Marca de água anónimos | RF-VID-012 | ✅ Completa |
| Progresso em tempo real | RF-VID-005, RNF-VID-004 | ✅ Completa |
| Integridade do ficheiro | RF-VID-011, RNF-VID-005 | ✅ Completa |

### 4.2 Impacto no Sistema Existente

A introdução da funcionalidade de submissão de vídeo implica alterações e extensões em múltiplos componentes da arquitetura atual do PictuRAS.

#### 4.2.1 Frontend (Next.js)

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Componente de Upload | Extensão | Estender o componente de upload existente (atualmente limitado a imagens e ZIPs de imagens) para suportar ficheiros de vídeo e ZIPs mistos. Adicionar validação client-side de formatos de vídeo. |
| Barra de Progresso | Novo | Criar componente de barra de progresso com integração WebSocket, capaz de exibir percentagem, velocidade e tempo restante para uploads de longa duração. |
| Biblioteca de Conteúdos | Extensão | Adaptar a biblioteca para exibir vídeos com thumbnails, distinguindo visualmente entre imagens e vídeos. |
| Gestão de Projetos | Extensão | Adaptar a interface de projeto para suportar conteúdos de vídeo ao lado de imagens. |

#### 4.2.2 API Gateway (Node.js)

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Endpoints REST | Extensão | Adicionar endpoints para upload de vídeo (`POST /api/v1/videos/upload`), incluindo suporte para multipart/chunked upload com limites de tamanho configuráveis por perfil. |
| Middleware de Validação | Extensão | Estender os middlewares de autenticação e autorização para validar quotas de operações com suporte para o novo tipo de conteúdo «vídeo». |
| Configuração de Limites | Alteração | Ajustar os limites de `body-parser`/`multer` do Node.js para suportar uploads de até 1 GB (atualmente limitado ao tamanho máximo de imagens). |

#### 4.2.3 WebSocket Gateway

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Canais de Progresso | Extensão | Adicionar canais WebSocket dedicados para progresso de upload de vídeo, com mensagens estruturadas contendo percentagem, velocidade e estado. |
| Gestão de Conexões | Extensão | Garantir que conexões WebSocket são mantidas durante uploads longos (até vários minutos para ficheiros de 1 GB). |

#### 4.2.4 Armazenamento (SeaweedFS / S3)

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Estrutura de Buckets | Extensão/Decisão | Definir se vídeos serão armazenados no mesmo bucket que imagens ou em bucket separado (Q-03). Configurar políticas de lifecycle adequadas ao tamanho dos ficheiros de vídeo. |
| Quotas de Armazenamento | Extensão | Ajustar as quotas de armazenamento S3 para acomodar o volume superior dos ficheiros de vídeo em relação às imagens. |

#### 4.2.5 Base de Dados (MongoDB)

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Esquema de Projetos | Extensão | Estender o esquema de documentos de projeto para suportar entradas de vídeo com metadados específicos (codec, resolução, duração, FPS). |
| Coleção de Vídeos | Novo | Criar coleção dedicada para metadados de vídeo, ou estender a coleção de media existente com discriminador de tipo. |
| Índices | Novo | Criar índices para pesquisas eficientes por projeto, estado, data de submissão e perfil de utilizador. |

#### 4.2.6 Microsserviços (RabbitMQ)

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| Filas RabbitMQ | Extensão | Definir novas filas ou routing keys para tarefas de vídeo (ex.: `video.watermark`, `video.metadata.extract`), separadas das filas de imagem para evitar contenção de recursos. |
| Microsserviço de Watermark | Novo/Extensão | Criar ou estender o microsserviço de marca de água para suportar vídeo, utilizando FFmpeg para sobreposição do logótipo. |

#### 4.2.7 Infraestrutura

| **Componente** | **Tipo de Alteração** | **Descrição** |
|-----------------|-----------------------|---------------|
| FFmpeg/FFprobe | Novo | Instalar e configurar FFmpeg e FFprobe nos containers relevantes para extração de metadados e validação de vídeo. |
| Recursos de Rede | Extensão | Garantir largura de banda e configuração de proxies/load balancers para transferências de ficheiros de grande dimensão (até 1 GB), incluindo ajuste de timeouts. |

### 4.3 Matriz de Rastreabilidade

A matriz seguinte estabelece a rastreabilidade bidirecional entre os requisitos especificados, os elementos do caso de uso e os componentes do sistema afetados.

| **Requisito** | **Elemento do UC** | **Componente(s) do Sistema** | **Prioridade** |
|---------------|--------------------|------------------------------|----------------|
| RF-VID-001 | Passo 2-3 | Frontend (Upload), API Gateway | Must Have |
| RF-VID-002 | Passo 3, EX-01 | Frontend (Validação), API Gateway (Middleware) | Must Have |
| RF-VID-003 | Passo 4, EX-02, RN-01/02/03 | Frontend (Validação), API Gateway (Middleware) | Must Have |
| RF-VID-004 | Passo 6, EX-05 | API Gateway, SeaweedFS | Must Have |
| RF-VID-005 | Passo 7 | WebSocket Gateway, Frontend (Barra Progresso) | Must Have |
| RF-VID-006 | Passos 10-12, RN-05 | API Gateway, FFprobe | Must Have |
| RF-VID-007 | Passo 11, EX-03, RN-01/02/03 | API Gateway, FFprobe | Must Have |
| RF-VID-008 | Passo 13 | MongoDB, API Gateway | Must Have |
| RF-VID-009 | FA-01 | Frontend, API Gateway, SeaweedFS | Should Have |
| RF-VID-010 | FA-03 | Frontend, API Gateway, SeaweedFS | Must Have |
| RF-VID-011 | Passo 9, EX-07 | API Gateway | Should Have |
| RF-VID-012 | FA-04, RN-07 | RabbitMQ, Microsserviço Watermark, FFmpeg | Must Have |
| RF-VID-013 | FA-02 | Frontend, API Gateway, MongoDB, SeaweedFS | Should Have |
| RF-VID-014 | Passos 5/15, EX-04, RN-06 | API Gateway, MongoDB | Must Have |
| RNF-VID-001 | Passos 6-7 | API Gateway, SeaweedFS, Rede | — |
| RNF-VID-002 | EX-05, EX-06 | SeaweedFS, API Gateway, Infraestrutura | — |
| RNF-VID-003 | Passos 6-7 | API Gateway, SeaweedFS, Infraestrutura | — |
| RNF-VID-004 | Passo 7 | WebSocket Gateway, Frontend | — |
| RNF-VID-005 | Passo 3, Passo 9 | API Gateway, Validação | — |

---

*Documento gerado no âmbito da unidade curricular de Requisitos e Arquiteturas de Software, MEI, Universidade do Minho — Fase 1 (MVP de vídeo).*
