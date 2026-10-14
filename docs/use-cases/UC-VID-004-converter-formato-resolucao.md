# UC-VID-004 — Converter Formato e Resolução de Vídeo
### Caso de Uso · Fase 1: Suporte a Vídeo no PictuRAS

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** |  |
| **Autores** |  |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.1 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Conversão de formato e resolução de vídeo (*transcode*) |
| **Perfil(s) de utilizador abrangido(s)** | Anónimo (apenas MP4, máx. 480p), Registado (MP4 e WebM, máx. 1080p), Premium (todos os formatos e resoluções) — todos os perfis beneficiam da conversão, mas com opções progressivamente mais ricas. |

**Justificação no contexto do MVP**

A conversão de formato e resolução é uma funcionalidade central para qualquer plataforma de processamento de vídeo. Sem ela, o utilizador fica limitado ao formato e resolução originais do ficheiro carregado, impossibilitando a adaptação do vídeo a diferentes plataformas de destino (web, mobile, arquivo), a redução do tamanho do ficheiro para partilha, e a modernização de codecs para melhor compressão. Esta funcionalidade valida o pipeline assíncrono de processamento pesado (transcodificação), que é o padrão de integração mais exigente do suporte a vídeo e serve de base técnica para todas as outras ferramentas de vídeo.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-004 |
| **Nome** | Converter Formato e Resolução de Vídeo |
| **Versão** | v1.1 |
| **Autor** | Alice Soares |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador converter um vídeo para um formato de contentor, codec e/ou resolução diferentes, obtendo um ficheiro de saída adaptado ao uso pretendido (compatibilidade, redução de tamanho, modernização de codec). |
| **Âmbito** | Frontend (painel de conversão), API Gateway, microsserviço de conversão de vídeo, fila RabbitMQ (`convert_queue`), armazenamento SeaweedFS S3, notificações WebSocket. |
| **Ator Principal** | Utilizador autenticado (registado ou premium) ou utilizador anónimo |
| **Stakeholders e Interesses** | - **Utilizador**: pretende converter vídeos de forma simples e rápida, com controlo sobre o formato, resolução e qualidade de saída.<br>- **Administrador do sistema**: pretende que a transcodificação não sobrecarregue os recursos do servidor e que a quota de operações seja respeitada.<br>- **Equipa de desenvolvimento**: pretende validar o pipeline assíncrono de processamento pesado como padrão reutilizável para outras ferramentas de vídeo. |
| **Pré-condições** | - O utilizador tem sessão iniciada (registado ou premium) ou está a usar a plataforma como anónimo.<br>- Existe pelo menos um vídeo carregado na biblioteca do projeto do utilizador.<br>- O vídeo de origem está num formato suportado pelo sistema (MP4, WebM, MOV, AVI, MKV).<br>- O utilizador não excedeu a sua quota de operações diárias (se aplicável). |
| **Trigger** | O utilizador seleciona um vídeo e escolhe a opção "Converter Vídeo" no menu de ferramentas. |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre a biblioteca de vídeos do projeto. | O sistema apresenta a lista de vídeos carregados com miniaturas, nomes e metadados básicos (formato, duração, resolução). |
| 2 | O utilizador seleciona um vídeo e escolhe a opção "Converter Vídeo". | — |
| 3 | — | O sistema analisa o vídeo de origem e apresenta as suas propriedades atuais: formato do contentor, codec de vídeo, codec de áudio, resolução, duração, taxa de fotogramas (fps), bitrate e tamanho do ficheiro. |
| 4 | O utilizador seleciona o formato de contentor de destino (MP4, WebM ou MOV), de entre os disponíveis para o seu perfil. | O sistema atualiza as opções de codec e resolução disponíveis, de acordo com o formato escolhido e o perfil do utilizador. |
| 5 | O utilizador seleciona a resolução de destino (original, 4K, 1080p, 720p ou 480p), limitada à resolução do vídeo original e ao perfil. | O sistema apresenta uma estimativa do tamanho do ficheiro resultante. |
| 6 | O utilizador, opcionalmente, ajusta definições avançadas: codec de vídeo, bitrate alvo, taxa de fotogramas. | O sistema atualiza a estimativa do tamanho do ficheiro com base nas definições ajustadas. |
| 7 | O utilizador confirma a conversão. | — |
| 8 | — | O sistema valida os parâmetros de conversão (combinação contentor+codec válida, resolução dentro dos limites, quota disponível). |
| 9 | — | O sistema cria um *job* de processamento e publica a mensagem na fila `convert_queue` do RabbitMQ. Regista o *job* na base de dados MongoDB com estado "Em fila". |
| 10 | — | O sistema apresenta ao utilizador o estado "Em fila" no painel de conversões, com os detalhes do *job*. |
| 11 | — | O microsserviço de conversão (`convert-tool-ms`) consome a mensagem da fila, inicia a transcodificação e envia atualizações de progresso via mensagens para a API Gateway. |
| 12 | — | O sistema transmite a percentagem de progresso ao utilizador em tempo real via WebSocket. O estado do *job* passa a "Em processamento". |
| 13 | — | A transcodificação é concluída com sucesso. O microsserviço armazena o ficheiro resultante no SeaweedFS S3 e envia mensagem de conclusão. |
| 14 | — | O sistema atualiza o estado do *job* para "Concluído", decrementa a quota de operações do utilizador (se aplicável), e notifica o utilizador via WebSocket. O utilizador pode pré-visualizar e descarregar o vídeo convertido. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Conversão em lote | No passo 2, o utilizador seleciona múltiplos vídeos e escolhe "Converter Vídeo". O sistema apresenta as opções de formato e resolução de destino (passo 4–6) que serão aplicadas a todos os vídeos. No passo 9, o sistema cria um *job* por cada vídeo e publica todas as mensagens na fila `convert_queue`. Cada *job* é processado independentemente e decrementa a quota individualmente (RN6). O progresso de cada vídeo é apresentado separadamente. |
| FA2 – Cancelamento durante o processamento | A qualquer momento entre os passos 10 e 12, o utilizador pode solicitar o cancelamento da conversão. O sistema envia um sinal de cancelamento ao microsserviço de conversão. Se a transcodificação ainda estiver em curso, o microsserviço aborta o processamento e elimina os ficheiros temporários. O estado do *job* passa a "Cancelado". A quota de operações **não** é decrementada para operações canceladas. |
| FA3 – Conversão como parte de uma cadeia de ferramentas | No passo 2, em vez de iniciar a conversão diretamente, o utilizador está a configurar uma cadeia de ferramentas (e.g., recorte temporal → conversão). A conversão é adicionada como passo na cadeia. Os parâmetros são configurados da mesma forma (passos 4–6). A conversão é executada apenas quando a cadeia é iniciada, recebendo como entrada a saída do passo anterior. |
| FA4 – Seleção de perfil predefinido | No passo 4, em vez de selecionar manualmente o formato e a resolução, o utilizador escolhe um perfil predefinido: "Otimizado para Web" (MP4 H.264, 720p, bitrate médio), "Mobile" (MP4 H.264, 480p, bitrate baixo), "Arquivo" (MOV, resolução original, bitrate alto). Os passos 4–6 são preenchidos automaticamente com os valores do perfil, mas o utilizador pode ajustá-los antes de confirmar. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| **E1 – Formato de origem não suportado** | No passo 3, o sistema deteta que o ficheiro de vídeo está num formato ou codec que não consegue descodificar. Apresenta a mensagem "Formato de origem não suportado. Formatos aceites: MP4, WebM, MOV, AVI, MKV." O caso de uso termina. |
| **E2 – Combinação contentor+codec inválida** | No passo 8, o sistema deteta que a combinação de contentor e codec selecionada não é tecnicamente válida (e.g., VP9 em contentor MOV). Apresenta a mensagem "A combinação de formato e codec selecionada não é válida. Selecione uma combinação compatível." O utilizador regressa ao passo 4. |
| **E3 – Falha durante a transcodificação** | Durante o passo 11 ou 12, o microsserviço encontra um erro irrecuperável na transcodificação (e.g., ficheiro de origem corrompido, erro de codificação). O microsserviço elimina ficheiros temporários e envia mensagem de erro. O sistema atualiza o estado do *job* para "Falhado", notifica o utilizador via WebSocket com a mensagem "A conversão falhou. Tente novamente ou contacte o suporte." A quota de operações **não** é decrementada. |
| **E4 – Ficheiro resultante excede limite de armazenamento** | No passo 13, o microsserviço verifica que o ficheiro resultante excede o limite de armazenamento do utilizador. O ficheiro temporário é eliminado. O estado do *job* passa a "Falhado" com a mensagem "O ficheiro resultante excede o limite de armazenamento disponível. Reduza a resolução ou o bitrate, ou liberte espaço." |
| **E5 – Quota de operações esgotada** | No passo 8, o sistema verifica que o utilizador já atingiu o limite de operações diárias (5 para registados). Apresenta a mensagem "Quota de operações diária esgotada. Aguarde pela reposição ou atualize para o plano premium." O caso de uso termina. |
| **E6 – Tempo limite de processamento excedido** | Durante o passo 11 ou 12, a transcodificação não é concluída dentro do tempo limite configurado (e.g., 30 minutos para MVP). O microsserviço aborta o processamento e elimina ficheiros temporários. O estado do *job* passa a "Falhado – Tempo limite excedido." A quota **não** é decrementada. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O vídeo convertido está armazenado no SeaweedFS S3, acessível ao utilizador para pré-visualização e descarregamento. O *job* está registado como "Concluído" na base de dados. A quota de operações do utilizador foi decrementada em 1 unidade. O vídeo original permanece inalterado na biblioteca. |
| Garantia Mínima | Nenhum ficheiro corrompido ou incompleto permanece no armazenamento. Ficheiros temporários da transcodificação falhada ou cancelada foram eliminados. A quota de operações não foi decrementada para operações que não concluíram com sucesso. O estado do *job* reflete corretamente o resultado (Cancelado / Falhado). O vídeo original permanece inalterado. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | Os formatos de contentor de saída suportados são: MP4 (com codec H.264 ou H.265), WebM (com codec VP9), MOV (com codec H.264 ou H.265). |
| RN2 | A resolução de saída não pode exceder a resolução do vídeo de origem (não é permitido *upscaling*). As opções disponíveis são filtradas automaticamente. |
| RN3 | Utilizadores anónimos apenas podem converter para MP4, com resolução máxima de 480p. |
| RN4 | Utilizadores registados (gratuitos) podem converter para MP4 e WebM, com resolução máxima de 1080p. |
| RN5 | Utilizadores premium podem converter para todos os formatos suportados, sem limitação de resolução (até à resolução original). |
| RN6 | Cada conversão conta como 1 operação para efeitos de quota diária (5 operações/dia para registados, ilimitado para premium, limitado para anónimos). |
| RN7 | A faixa de áudio é transcodificada para AAC quando o contentor de destino é MP4 ou MOV, e para Opus quando o contentor é WebM. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O microsserviço de conversão utiliza FFmpeg como motor de transcodificação, dado ser a ferramenta de referência *open-source* com suporte abrangente a formatos e codecs. |
| A2 | O cálculo da estimativa de tamanho do ficheiro resultante (passo 5) é uma aproximação baseada no bitrate alvo e na duração do vídeo; o valor real pode diferir. |
| A3 | O progresso da transcodificação (passo 12) é reportado com granularidade de 1%, calculado a partir da posição temporal atual face à duração total do vídeo. |
| A4 | O cancelamento de uma conversão em curso (FA2) é *best-effort*: o microsserviço pode não abortar instantaneamente, mas deve parar num prazo razoável (< 5 s). |
| A5 | No MVP, a transcodificação é executada por uma única instância do microsserviço de conversão. A escalabilidade horizontal (múltiplas instâncias) é tratada como evolução futura. |
| A6 | O sistema de filas RabbitMQ garante entrega *at-least-once*. O microsserviço de conversão é idempotente relativamente a mensagens duplicadas (verificação do estado do *job* antes de iniciar). |
| A7 | Os perfis predefinidos de conversão (FA4) são configuráveis pela equipa de administração e não pelo utilizador final. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Qual o tempo limite máximo de transcodificação a definir no MVP? 30 minutos é suficiente para os vídeos esperados? |
| Q2 | Os utilizadores anónimos devem ter acesso à funcionalidade de conversão, ou apenas utilizadores registados e premium? |
| Q3 | Deve o sistema manter um histórico de conversões anteriores para permitir repetir uma conversão com os mesmos parâmetros? |
| Q4 | O vídeo convertido deve ser adicionado como novo item na biblioteca ou substituir o original (com possibilidade de reversão)? |
| Q5 | Qual o limite máximo de armazenamento por utilizador no MVP? Deve ser diferenciado por perfil? |
| Q6 | Deve o sistema suportar *hardware acceleration* (e.g., NVENC, VAAPI) na transcodificação, ou apenas codificação por software no MVP? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| Claude Code (Anthropic) | Elaboração da estrutura do documento de caso de uso, fluxos alternativos, exceções e requisitos derivados. | Revisão integral pela equipa: validação dos fluxos contra a arquitetura existente do PictuRAS; verificação da consistência das regras de negócio com os perfis de utilizador; ajuste da terminologia técnica (codecs, contentores) com base em documentação de referência do FFmpeg. |

---

## 4. Especificação de Requisitos do Sistema (ERS)

**Caso de Uso:** UC-VID-004 — Converter Formato e Resolução de Vídeo
**Versão do dossiê:** v1.1
**Baseline do Exercício 1:** v1.0 — REQ-VID-CONV-001 a REQ-VID-CONV-008 (derivação inicial)

### 4.1 Requisitos da ERS

#### 4.1.1 Requisitos Funcionais

| **ID** | **Requisito** | **Prioridade** | **Evolução** | **Novo/Alt** | **Origem (UC / RN / decisão)** | **Justificação** | **Critério de aceitação / verificação** |
|--------|---------------|----------------|--------------|--------------|-------------------------------|-----------------|----------------------------------------|
| REQ-VID-CONV-001 | O sistema deve apresentar as propriedades do vídeo de origem (formato, codec de vídeo, codec de áudio, resolução, duração, fps, bitrate, tamanho) antes da configuração da conversão. | Deve ter | Mantido | NOVO | UC-VID-004, passo 3 | O utilizador precisa de conhecer as propriedades atuais do vídeo para tomar decisões informadas sobre os parâmetros de conversão. | Dado um vídeo MP4 (H.264, 1920×1080, 30fps, 5Mbps, 2min), quando o utilizador seleciona "Converter Vídeo", então o sistema apresenta todos os 8 campos de propriedades com valores corretos num painel dedicado. |
| REQ-VID-CONV-002 | O sistema deve permitir ao utilizador selecionar o formato de contentor de destino de entre as opções disponíveis para o seu perfil (RN3–RN5). | Deve ter | Mantido | NOVO | UC-VID-004, passo 4; RN1, RN3, RN4, RN5 | A seleção do formato é o parâmetro principal da conversão e deve respeitar as restrições por perfil. | Dado um utilizador registado, quando acede ao seletor de formato, então são apresentadas apenas as opções MP4 e WebM (não MOV). Dado um utilizador premium, então são apresentadas MP4, WebM e MOV. |
| REQ-VID-CONV-003 | O sistema deve permitir ao utilizador selecionar a resolução de destino, filtrando as opções para não exceder a resolução original do vídeo (RN2) nem o máximo permitido pelo perfil (RN3–RN5). | Deve ter | Mantido | NOVO | UC-VID-004, passo 5; RN2, RN3, RN4, RN5 | Impedir *upscaling* evita degradação de qualidade e expectativas irrealistas. Limitar por perfil implementa o modelo de negócio. | Dado um vídeo de origem a 1080p e um utilizador anónimo, quando acede ao seletor de resolução, então são apresentadas apenas as opções 480p (máx. do perfil) e inferiores. A opção 1080p não está disponível. |
| REQ-VID-CONV-004 | O sistema deve permitir ao utilizador ajustar opcionalmente as definições avançadas: codec de vídeo (de entre os compatíveis com o contentor), bitrate alvo e taxa de fotogramas. | Deveria ter | Mantido | NOVO | UC-VID-004, passo 6; RN1 | Utilizadores avançados precisam de controlo fino sobre a qualidade e tamanho da saída. As predefinições por omissão devem ser sensatas para utilizadores menos técnicos. | Dado o formato MP4 selecionado, quando o utilizador expande as definições avançadas, então pode selecionar H.264 ou H.265 como codec, inserir um bitrate entre 500kbps e 50Mbps, e selecionar uma fps entre 15 e 60. |
| REQ-VID-CONV-005 | O sistema deve apresentar uma estimativa do tamanho do ficheiro resultante, atualizada em tempo real quando o utilizador altera parâmetros. | Deveria ter | Refinado | NOVO | UC-VID-004, passos 5–6 | Permite ao utilizador tomar decisões informadas sobre a relação qualidade/tamanho antes de iniciar a transcodificação (que é demorada). | Dado um vídeo de 2 minutos com bitrate alvo de 2Mbps, quando o utilizador altera a resolução para 720p, então a estimativa de tamanho é atualizada em menos de 500ms e apresenta um valor entre 25MB e 35MB. |
| REQ-VID-CONV-006 | O sistema deve validar os parâmetros de conversão antes de criar o *job*: combinação contentor+codec válida, resolução dentro dos limites, e quota disponível. | Deve ter | Mantido | NOVO | UC-VID-004, passo 8; exceções E2, E5 | A validação antecipada evita o desperdício de recursos de processamento com *jobs* que iriam falhar, e fornece *feedback* imediato ao utilizador. | Dado um utilizador que seleciona VP9 com contentor MOV, quando confirma a conversão, então o sistema apresenta erro de combinação inválida sem criar o *job*. Dado um utilizador com quota esgotada, quando confirma, então o sistema apresenta erro de quota sem criar o *job*. |
| REQ-VID-CONV-007 | O sistema deve criar um *job* de conversão na base de dados MongoDB com estado "Em fila" e publicar a mensagem de processamento na fila `convert_queue` do RabbitMQ. | Deve ter | Mantido | NOVO | UC-VID-004, passo 9 | A persistência do *job* garante rastreabilidade e recuperação. A publicação na fila desacopla a API do processamento pesado. | Dado parâmetros válidos, quando o utilizador confirma a conversão, então é criado um registo na coleção `jobs` do MongoDB com estado "queued", e uma mensagem é publicada na fila `convert_queue` com o ID do *job*, referência ao ficheiro de origem, e parâmetros de conversão. |
| REQ-VID-CONV-008 | O sistema deve transmitir o progresso da transcodificação ao utilizador em tempo real via WebSocket, com granularidade de 1%. | Deve ter | Refinado | NOVO | UC-VID-004, passo 12; A3 | O utilizador precisa de *feedback* visual sobre o progresso de uma operação que pode demorar vários minutos. | Dado uma transcodificação em curso, quando 50% do vídeo é processado, então o utilizador recebe uma atualização WebSocket com `progress: 50` e o painel de conversões reflete este valor em menos de 2 segundos. |
| REQ-VID-CONV-009 | O sistema deve armazenar o vídeo convertido no SeaweedFS S3 e atualizar o estado do *job* para "Concluído", incluindo a referência ao ficheiro resultante. | Deve ter | Mantido | NOVO | UC-VID-004, passos 13–14 | O armazenamento no SeaweedFS garante disponibilidade e consistência com o resto do sistema. A atualização do estado permite ao frontend atualizar a UI. | Dado uma transcodificação concluída, quando o microsserviço envia a mensagem de conclusão, então o ficheiro está acessível no SeaweedFS, o estado do *job* é "completed" no MongoDB, e o utilizador é notificado via WebSocket. |
| REQ-VID-CONV-010 | O sistema deve decrementar a quota de operações do utilizador em 1 unidade apenas quando a conversão é concluída com sucesso. | Deve ter | Novo | NOVO | UC-VID-004, passo 14; RN6; exceções E3, E6; FA2 | Não penalizar o utilizador por falhas do sistema ou cancelamentos garante equidade e confiança no serviço. | Dado um utilizador registado com 3 operações restantes, quando uma conversão conclui com sucesso, então a quota passa a 2. Dado uma conversão que falha (E3) ou é cancelada (FA2), então a quota mantém-se em 3. |
| REQ-VID-CONV-011 | O sistema deve transcodificar a faixa de áudio para AAC quando o contentor de destino é MP4 ou MOV, e para Opus quando o contentor é WebM. | Deve ter | Novo | NOVO | RN7 | A compatibilidade do codec de áudio com o contentor é um requisito técnico obrigatório para a reprodução correta do vídeo resultante. | Dado uma conversão para WebM, quando o vídeo é transcodificado, então a faixa de áudio no ficheiro resultante está codificada em Opus (verificável via `ffprobe`). Dado uma conversão para MP4, então a faixa de áudio está em AAC. |
| REQ-VID-CONV-012 | O sistema deve permitir ao utilizador cancelar uma conversão em curso. O microsserviço deve abortar a transcodificação, eliminar ficheiros temporários e atualizar o estado do *job* para "Cancelado". | Deve ter | Novo | NOVO | FA2 | Conversões demoradas podem ter sido iniciadas com parâmetros errados; o cancelamento evita desperdício de recursos e de tempo do utilizador. | Dado uma conversão em estado "Em processamento" a 30%, quando o utilizador clica "Cancelar", então o microsserviço aborta a transcodificação em menos de 5 segundos, os ficheiros temporários são eliminados, e o estado do *job* passa a "cancelled". |
| REQ-VID-CONV-013 | O sistema deve suportar a conversão em lote: o utilizador pode selecionar múltiplos vídeos e aplicar os mesmos parâmetros de conversão a todos. | Deveria ter | Novo | NOVO | FA1 | A conversão em lote reduz significativamente o esforço do utilizador quando pretende normalizar vários vídeos para o mesmo formato/resolução. | Dado 3 vídeos selecionados com formato MP4 e resolução 720p como destino, quando o utilizador confirma, então são criados 3 *jobs* independentes na fila `convert_queue`, e o progresso de cada um é apresentado separadamente no painel de conversões. |
| REQ-VID-CONV-014 | O sistema deve oferecer perfis predefinidos de conversão ("Otimizado para Web", "Mobile", "Arquivo") que preenchem automaticamente os parâmetros de formato, resolução, codec e bitrate. | Poderia ter | Novo | NOVO | FA4 | Simplifica a experiência para utilizadores que não têm conhecimentos técnicos sobre codecs e bitrates, e promove boas práticas de compressão. | Dado que o utilizador seleciona o perfil "Otimizado para Web", quando os parâmetros são preenchidos, então o formato é MP4, o codec é H.264, a resolução é 720p, e o bitrate é adequado para streaming web (~2.5Mbps). O utilizador pode alterar qualquer valor antes de confirmar. |
| REQ-VID-CONV-015 | O sistema deve suportar a inclusão da conversão de vídeo como passo numa cadeia de ferramentas sequenciais. | Poderia ter | Novo | NOVO | FA3 | O encadeamento de ferramentas (e.g., recorte temporal seguido de conversão) é uma funcionalidade prevista na arquitetura do PictuRAS e necessária para fluxos de trabalho complexos. | Dado uma cadeia configurada com "Recorte temporal (0s–30s) → Converter para WebM 720p", quando a cadeia é executada, então o vídeo recortado é passado como entrada à conversão, e o resultado final é um ficheiro WebM de 720p com duração de 30 segundos. |

#### 4.1.2 Requisitos Não Funcionais e de Qualidade

| **ID** | **Requisito** | **Característica ISO/IEC 25010** | **Alvo MVP** | **Alvo produção** | **Evolução** | **Origem (UC / DQ)** | **Critério de aceitação / verificação** |
|--------|---------------|----------------------------------|--------------|-------------------|--------------|----------------------|----------------------------------------|
| REQ-VID-CONV-NF01 | O sistema deve iniciar a transcodificação (primeira atualização de progresso) num prazo máximo após a confirmação do utilizador. | Eficiência de Desempenho — Tempo de resposta | ≤ 30 s (com fila sem carga) | ≤ 10 s (p95) | Novo | DQ-001 | Dado um *job* submetido com a fila vazia, quando o microsserviço consome a mensagem, então a primeira atualização de progresso é enviada ao utilizador em menos de 30 s (MVP) / 10 s (produção, p95). |
| REQ-VID-CONV-NF02 | O sistema deve completar a transcodificação de um vídeo de referência (1080p, H.264, 2 min) dentro de um tempo limite aceitável. | Eficiência de Desempenho — Capacidade | ≤ 5 min (codificação por software) | ≤ 1 min (com aceleração por hardware) | Novo | DQ-002 | Dado um vídeo de teste padrão (1080p, H.264, 2 min, 5Mbps), quando convertido para 720p WebM VP9, então a transcodificação completa em menos de 5 min (MVP) / 1 min (produção). |
| REQ-VID-CONV-NF03 | O microsserviço de conversão deve ser tolerante a falhas: em caso de erro, os ficheiros temporários devem ser eliminados e o *job* atualizado para "Falhado" sem afetar outros *jobs* na fila. | Fiabilidade — Tolerância a falhas | 100% de limpeza de ficheiros temporários após falha | Idem + reinício automático do microsserviço | Refinado | UC-VID-004, exceções E3, E6; DQ-003 | Dado que a transcodificação de um *job* falha por ficheiro corrompido, quando o microsserviço reporta o erro, então nenhum ficheiro temporário permanece no sistema de ficheiros local, o *job* tem estado "failed" no MongoDB, e o próximo *job* na fila é consumido normalmente. |
| REQ-VID-CONV-NF04 | O sistema deve garantir que o vídeo convertido é reprodutível e a sua integridade está verificada antes de ser disponibilizado ao utilizador. | Adequação Funcional — Correção | Verificação de integridade via `ffprobe` (exit code 0) | Reprodução de amostra automática (primeiros 5 s) | Novo | DQ-004 | Dado um vídeo convertido armazenado no SeaweedFS, quando o sistema executa `ffprobe` sobre o ficheiro, então o comando retorna exit code 0 e os metadados do ficheiro correspondem aos parâmetros de conversão solicitados (formato, codec, resolução). |
| REQ-VID-CONV-NF05 | A interface de configuração de conversão deve apresentar opções claras e compreensíveis, com valores por omissão sensatos, para utilizadores sem conhecimentos técnicos de vídeo. | Usabilidade — Operabilidade | Valores por omissão preenchidos; rótulos descritivos para cada opção | Descrições *inline* e pré-visualização do impacto na qualidade | Novo | DQ-005 | Dado um utilizador que abre o painel de conversão pela primeira vez, quando os campos são apresentados, então cada opção tem um valor por omissão selecionado, e os rótulos não utilizam jargão técnico sem explicação (e.g., "Qualidade de vídeo" em vez de apenas "Bitrate"). |
| REQ-VID-CONV-NF06 | O sistema deve suportar pelo menos 5 *jobs* de conversão concorrentes na fila sem perda de mensagens. | Eficiência de Desempenho — Capacidade | 5 *jobs* concorrentes (processamento sequencial) | 20 *jobs* concorrentes (processamento paralelo com múltiplas instâncias) | Novo | DQ-006 | Dado 5 *jobs* de conversão submetidos quase simultaneamente, quando processados pelo microsserviço, então todos os 5 são eventualmente concluídos com sucesso, sem mensagens perdidas na fila RabbitMQ. |
| REQ-VID-CONV-NF07 | O microsserviço de conversão deve ser idempotente: o processamento duplicado da mesma mensagem não deve gerar ficheiros duplicados nem erros. | Fiabilidade — Maturidade | Verificação do estado do *job* antes de iniciar a transcodificação | Idem + deduplicação baseada em hash | Novo | A6; DQ-007 | Dado uma mensagem duplicada recebida na fila `convert_queue` para um *job* já concluído, quando o microsserviço a processa, então não inicia nova transcodificação e a mensagem é confirmada (*acknowledged*). |

#### 4.1.3 Verificação da completude e dos limites do âmbito

| **Tópico a verificar** | **Aplicável?** | **Decisão / justificação** | **Requisito(s) relacionado(s)** |
|------------------------|---------------|----------------------------|-------------------------------|
| Formato, codec, duração e dimensão do vídeo | Sim | A conversão lida diretamente com formatos de contentor (MP4, WebM, MOV), codecs de vídeo (H.264, H.265, VP9), codecs de áudio (AAC, Opus), e resolução. A duração é relevante para a estimativa de tamanho e o cálculo de progresso. | REQ-VID-CONV-001, REQ-VID-CONV-002, REQ-VID-CONV-003, REQ-VID-CONV-004, REQ-VID-CONV-011 |
| Estado, progresso, cancelamento e resultado | Sim | O *job* de conversão passa por estados (Em fila → Em processamento → Concluído/Falhado/Cancelado), com progresso em tempo real e possibilidade de cancelamento. | REQ-VID-CONV-007, REQ-VID-CONV-008, REQ-VID-CONV-009, REQ-VID-CONV-012 |
| Falhas durante o processamento | Sim | As exceções E1 a E6 cobrem falhas de formato, validação, transcodificação, armazenamento, quota e *timeout*. A limpeza de recursos é garantida. | REQ-VID-CONV-006, REQ-VID-CONV-NF03 |
| Persistência e expiração dos ficheiros | Sim | Os vídeos convertidos são armazenados no SeaweedFS S3 de forma persistente. A expiração de ficheiros não é tratada neste caso de uso (é transversal ao sistema). | REQ-VID-CONV-009 |
| Perfis e contagem de operações | Sim | As opções disponíveis dependem do perfil (RN3–RN5). Cada conversão decrementa a quota (RN6). Apenas conversões bem-sucedidas contam. | REQ-VID-CONV-002, REQ-VID-CONV-003, REQ-VID-CONV-010 |
| Encadeamento de ferramentas e processamento em lote | Sim | Suportados via FA1 (lote) e FA3 (cadeia). Tratados como funcionalidades "Deveria ter" e "Poderia ter", respetivamente. | REQ-VID-CONV-013, REQ-VID-CONV-015 |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisito(s) relacionado(s)** |
|-------------------------------|------------------------------------------|-------------------------|-------------------------------|
| Perfis de utilizador e controlo de acesso | Estender | Adicionar regras de controlo de acesso para opções de conversão de vídeo por perfil (formatos e resoluções permitidos). O mecanismo de perfis existente (anónimo, registado, premium) mantém-se; é necessário parametrizar as novas restrições. | REQ-VID-CONV-002, REQ-VID-CONV-003 |
| Sistema de quotas | Estender | O contador de operações diárias deve contabilizar conversões de vídeo como operações. A lógica de decremento e verificação de quota já existe para imagens; deve ser estendida para incluir o novo tipo de operação. | REQ-VID-CONV-010, REQ-VID-CONV-006 |
| Armazenamento SeaweedFS S3 | Estender | O armazenamento deve suportar ficheiros de vídeo convertidos (potencialmente maiores que imagens). Pode ser necessário configurar *buckets* ou prefixos separados para vídeos. Verificação de limites de armazenamento por utilizador. | REQ-VID-CONV-009 |
| API Gateway (Node.js) | Estender | Novos endpoints REST para: criação de *jobs* de conversão, consulta de estado, cancelamento. Integração com WebSocket para transmissão de progresso. As rotas seguem o padrão existente das ferramentas de imagem. | REQ-VID-CONV-007, REQ-VID-CONV-008, REQ-VID-CONV-012 |
| Infraestrutura RabbitMQ | Estender | Criação de nova fila `convert_queue` com configuração de *dead-letter* para mensagens falhadas. O padrão de troca de mensagens é idêntico ao das ferramentas de imagem existentes. | REQ-VID-CONV-007 |
| Frontend Next.js | Estender | Novo componente/painel de conversão de vídeo no editor de projetos: seletor de formato, resolução, definições avançadas, barra de progresso, ações de cancelamento. Integração com WebSocket para atualizações em tempo real. | REQ-VID-CONV-001 a REQ-VID-CONV-005, REQ-VID-CONV-008, REQ-VID-CONV-NF05 |
| Base de dados MongoDB | Estender | Nova coleção ou extensão da coleção `jobs` para registar *jobs* de conversão com os seus parâmetros, estado, referências a ficheiros de origem e destino, e histórico de progresso. | REQ-VID-CONV-007, REQ-VID-CONV-009 |
| Biblioteca de projetos | Estender | A biblioteca deve suportar a visualização e gestão de vídeos convertidos como novos itens, mantendo a ligação ao vídeo original. | REQ-VID-CONV-009 |
| Sistema de encadeamento de ferramentas | Estender | A conversão deve poder ser registada como passo numa cadeia de ferramentas, recebendo como entrada a saída do passo anterior. O mecanismo de orquestração de cadeias deve reconhecer o novo tipo de ferramenta. | REQ-VID-CONV-015 |

### 4.3 Matriz de Rastreabilidade Atualizada

| **Elemento de origem** | **Descrição abreviada** | **Requisito(s) relacionado(s)** |
|------------------------|------------------------|-------------------------------|
| UC-VID-004, passo 3 | Apresentação das propriedades do vídeo de origem | REQ-VID-CONV-001 |
| UC-VID-004, passo 4 | Seleção do formato de contentor de destino | REQ-VID-CONV-002 |
| UC-VID-004, passo 5 | Seleção da resolução de destino | REQ-VID-CONV-003 |
| UC-VID-004, passo 6 | Ajuste de definições avançadas (codec, bitrate, fps) | REQ-VID-CONV-004 |
| UC-VID-004, passos 5–6 | Estimativa do tamanho do ficheiro resultante | REQ-VID-CONV-005 |
| UC-VID-004, passo 8 | Validação dos parâmetros de conversão | REQ-VID-CONV-006 |
| UC-VID-004, passo 9 | Criação do *job* e publicação na fila | REQ-VID-CONV-007 |
| UC-VID-004, passo 12 | Transmissão do progresso via WebSocket | REQ-VID-CONV-008 |
| UC-VID-004, passos 13–14 | Armazenamento do resultado e conclusão | REQ-VID-CONV-009 |
| UC-VID-004, passo 14; RN6 | Decremento da quota após sucesso | REQ-VID-CONV-010 |
| RN7 | Transcodificação da faixa de áudio (AAC/Opus) | REQ-VID-CONV-011 |
| FA2 – Cancelamento | Cancelamento de conversão em curso | REQ-VID-CONV-012 |
| FA1 – Conversão em lote | Conversão de múltiplos vídeos em simultâneo | REQ-VID-CONV-013 |
| FA4 – Perfis predefinidos | Perfis de conversão predefinidos | REQ-VID-CONV-014 |
| FA3 – Cadeia de ferramentas | Conversão como passo de uma cadeia | REQ-VID-CONV-015 |
| DQ-001 | Tempo de início da transcodificação | REQ-VID-CONV-NF01 |
| DQ-002 | Tempo de conclusão da transcodificação | REQ-VID-CONV-NF02 |
| DQ-003; E3, E6 | Tolerância a falhas e limpeza de recursos | REQ-VID-CONV-NF03 |
| DQ-004 | Integridade do vídeo convertido | REQ-VID-CONV-NF04 |
| DQ-005 | Usabilidade da interface de conversão | REQ-VID-CONV-NF05 |
| DQ-006 | Capacidade de processamento concorrente | REQ-VID-CONV-NF06 |
| DQ-007; A6 | Idempotência do microsserviço | REQ-VID-CONV-NF07 |

**Decisões de qualidade introduzidas nesta aula**

| **ID** | **Decisão de qualidade** | **Justificação** | **Requisito(s) relacionado(s)** |
|--------|--------------------------|-----------------|-------------------------------|
| DQ-001 | O tempo entre a submissão e o início da transcodificação deve ser limitado para garantir *feedback* atempado ao utilizador. | Uma espera prolongada sem *feedback* gera incerteza sobre o funcionamento do sistema, especialmente numa operação que pode demorar minutos. | REQ-VID-CONV-NF01 |
| DQ-002 | O tempo de transcodificação deve ser limitado e proporcional à duração do vídeo. | Transcodificações excessivamente longas bloqueiam recursos e degradam a experiência do utilizador. O *timeout* protege contra cenários de bloqueio. | REQ-VID-CONV-NF02 |
| DQ-003 | Falhas de transcodificação devem ser contidas ao *job* afetado, sem impacto em outros *jobs* ou no sistema global. | A arquitetura de microsserviços exige isolamento de falhas. Um vídeo corrompido ou um erro de codificação não deve comprometer a disponibilidade do serviço. | REQ-VID-CONV-NF03 |
| DQ-004 | O vídeo convertido deve ser validado antes de ser marcado como disponível. | Um ficheiro corrompido ou truncado disponibilizado ao utilizador destrói a confiança no sistema e pode causar problemas nas aplicações de destino. | REQ-VID-CONV-NF04 |
| DQ-005 | A interface de conversão deve ser acessível a utilizadores não técnicos. | A plataforma destina-se a um público alargado; termos como "codec", "bitrate" e "contentor" devem ser acompanhados de descrições compreensíveis ou ocultos por omissão em definições avançadas. | REQ-VID-CONV-NF05 |
| DQ-006 | O sistema deve processar múltiplos *jobs* sem perda de mensagens. | Em cenários de conversão em lote (FA1) ou com múltiplos utilizadores simultâneos, a fila RabbitMQ deve garantir entrega e processamento de todas as mensagens. | REQ-VID-CONV-NF06 |
| DQ-007 | O microsserviço deve ser idempotente para tolerar mensagens duplicadas da fila. | O RabbitMQ garante *at-least-once delivery*; sem idempotência, mensagens duplicadas causariam ficheiros duplicados e consumo desnecessário de recursos e armazenamento. | REQ-VID-CONV-NF07 |

**Verificações de cobertura**
- [x] Cada requisito funcional e não funcional aparece na matriz.
- [x] Cada requisito tem origem identificada: elemento do caso de uso, regra de negócio ou decisão de qualidade.
- [x] Todos os elementos relevantes do caso de uso têm requisito associado ou justificação para não terem.
- [x] Os tópicos excluídos na secção 4.1.3 estão justificados.
- [x] O impacto no sistema existente está atualizado e ligado aos requisitos relevantes.

---

## ✅ Lista de verificação antes de entregar

- [x] Secções 0 a 3 preenchidas e texto de ajuda removido.
- [x] Funcionalidade de vídeo escolhida e justificada no contexto do MVP.
- [x] Ator principal identificado, com o respetivo perfil.
- [x] Caso de uso com fluxo principal, ≥1 fluxo alternativo e ≥1 exceção específica de vídeo.
- [x] Pós-condições com garantia de sucesso e garantia mínima.
- [x] Regras de negócio e restrições preenchidas.
- [x] Assunções e questões em aberto registadas.
- [x] Utilização de agentes de IA documentada.
- [x] Requisitos funcionais estão completos para o âmbito e têm critérios verificáveis.
- [x] Requisitos de qualidade estão classificados e distinguem os alvos MVP e produção.
- [x] Os IDs existentes foram preservados quando a intenção não mudou.
- [x] A análise de completude não alargou o âmbito sem decisão explícita.
- [x] A matriz de rastreabilidade não tem requisitos órfãos nem elementos relevantes por cobrir.
- [x] As decisões de qualidade e os respetivos requisitos estão identificados.

