# UC-VID-006 — Concatenar Múltiplos Vídeos (Merge)

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 5 - PL3 |
| **Autores** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel|
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Concatenar múltiplos vídeos (*merge*) num único ficheiro resultante |
| **Perfil(s) de utilizador abrangido(s)** | Registado e Premium — utilizadores anónimos não têm acesso a esta funcionalidade. |

**Justificação no contexto do MVP**
A concatenação permite unir múltiplos vídeos ou excertos recortados previamente (via UC-VID-002) num único ficheiro de saída. Fecha o ciclo básico de edição não-linear no PictuRAS, validando a capacidade do pipeline assíncrono de lidar com múltiplas fontes de entrada, normalização de codecs/resoluções e renderização encadeada.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-006 |
| **Nome** | Concatenar Múltiplos Vídeos (*Merge*) |
| **Versão** | v1.0 |
| **Autor** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador selecionar dois ou mais vídeos da biblioteca, ordenar a sequência e uni-los num único vídeo de saída. |
| **Âmbito** | Módulo de processamento de vídeo do PictuRAS e gestão de projetos |
| **Ator Principal** | Utilizador Registado ou Premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende juntar vários excertos de vídeo numa única compilação contínua.<br>- **Proprietário do Sistema**: deseja assegurar o controlo de recursos computacionais e aplicar limites de duração total por perfil.<br>- **Equipa de Desenvolvimento**: valida a transcodificação/normalização automática de vídeos com resoluções ou codecs heterogéneos. |
| **Pré-condições** | - O utilizador tem sessão iniciada com perfil registado ou premium.<br>- O projeto contém pelo menos 2 vídeos válidos e armazenados.<br>- O utilizador dispõe de quota diária de operações. |
| **Trigger** | O utilizador seleciona dois ou mais vídeos na biblioteca do projeto e escolhe a opção "Concatenar Vídeos". |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador acede à biblioteca do projeto e seleciona 2 ou mais vídeos. | O sistema destaca os ficheiros selecionados e ativa a opção "Concatenar Vídeos". |
| 2 | O utilizador clica em "Concatenar Vídeos". | O sistema apresenta a interface de ordenação com as miniaturas dos vídeos e opções de saída (resolução, formato). |
| 3 | O utilizador ajusta a ordem de reprodução dos vídeos (drag-and-drop) e seleciona os parâmetros de saída. | O sistema valida se a duração total acumulada e o número de ficheiros respeitam o limite do perfil do utilizador. |
| 4 | O utilizador confirma a operação de concatenação. | O sistema valida a quota do utilizador e a disponibilidade do armazenamento. |
| 5 | — | O sistema cria um job de concatenação e envia a tarefa para a fila de mensagens (RabbitMQ). |
| 6 | — | O sistema notifica o utilizador que o processamento iniciou e atualiza o estado para "Em fila". |
| 7 | O utilizador acompanha o progresso. | O sistema comunica periodicamente o progresso em tempo real (%) via WebSocket. |
| 8 | — | O worker (FFmpeg) normaliza as resoluções/codecs se necessário, une os ficheiros na ordem definida, preservando as faixas de áudio, e guarda o resultado final no armazenamento. |
| 9 | — | O sistema regista o novo vídeo na base de dados, associa-o ao projeto e decrementa a quota do utilizador. |
| 10 | — | O sistema notifica a conclusão com sucesso e disponibiliza o vídeo final na biblioteca. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Normalização Automática de Resolução | Se os vídeos selecionados tiverem resoluções ou taxas de fotogramas diferentes, o sistema ajusta automaticamente todos os vídeos para a resolução do primeiro elemento ou para a resolução configurada pelo utilizador. |
| FA2 – Cancelamento pelo Utilizador | Durante a execução, o utilizador pode cancelar o job: o worker interrompe o FFmpeg, elimina os ficheiros temporários gerados, marca o job como cancelado e devolve a quota reservada. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Duração total combinada excede o limite do perfil | O sistema impede a submissão, destaca a duração excedida e sugere a remoção de vídeos ou upgrade de perfil. |
| Ficheiro de entrada corrompido ou inacessível | O sistema assinala o ficheiro inválido no lote, interrompe a criação do job e notifica o utilizador. |
| Quota diária esgotada | O sistema bloqueia o início da operação e exibe o horário de reposição da quota. |
| Falha técnica durante a composição (FFmpeg) | O sistema interceta o erro, marca o job como falhado, limpa temporários, liberta a quota e disponibiliza o botão "Tentar novamente". |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O vídeo resultado da união está guardado na biblioteca do projeto e os vídeos originais permanecem intactos. |
| Garantia Mínima | Os vídeos originais permanecem inalterados, os dados parciais/temporários são eliminados, o job fica marcado como falhado/cancelado e nenhuma quota é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | A concatenação exige no mínimo 2 vídeos e no máximo 5 (Registado) ou 15 (Premium). |
| RN2 | A duração total do vídeo final não pode exceder 3 minutos para Registados e 20 minutos para Premium. |
| RN3 | Os vídeos de origem nunca são alterados ou eliminados durante a concatenação. |
| RN4 | Cada concatenação concluída com sucesso desconta | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 5 - PL3 |
| **Autores** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel|
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Concatenar múltiplos vídeos (*merge*) num único ficheiro resultante |
| **Perfil(s) de utilizador abrangido(s)** | Registado e Premium — utilizadores anónimos não têm acesso a esta funcionalidade. |

**Justificação no contexto do MVP**
A concatenação permite unir múltiplos vídeos ou excertos recortados previamente (via UC-VID-002) num único ficheiro de saída. Fecha o ciclo básico de edição não-linear no PictuRAS, validando a capacidade do pipeline assíncrono de lidar com múltiplas fontes de entrada, normalização de codecs/resoluções e renderização encadeada.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-006 |
| **Nome** | Concatenar Múltiplos Vídeos (*Merge*) |
| **Versão** | v1.0 |
| **Autor** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador selecionar dois ou mais vídeos da biblioteca, ordenar a sequência e uni-los num único vídeo de saída. |
| **Âmbito** | Módulo de processamento de vídeo do PictuRAS e gestão de projetos |
| **Ator Principal** | Utilizador Registado ou Premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende juntar vários excertos de vídeo numa única compilação contínua.<br>- **Proprietário do Sistema**: deseja assegurar o controlo de recursos computacionais e aplicar limites de duração total por perfil.<br>- **Equipa de Desenvolvimento**: valida a transcodificação/normalização automática de vídeos com resoluções ou codecs heterogéneos. |
| **Pré-condições** | - O utilizador tem sessão iniciada com perfil registado ou premium.<br>- O projeto contém pelo menos 2 vídeos válidos e armazenados.<br>- O utilizador dispõe de quota diária de operações. |
| **Trigger** | O utilizador seleciona dois ou mais vídeos na biblioteca do projeto e escolhe a opção "Concatenar Vídeos". |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador acede à biblioteca do projeto e seleciona 2 ou mais vídeos. | O sistema destaca os ficheiros selecionados e ativa a opção "Concatenar Vídeos". |
| 2 | O utilizador clica em "Concatenar Vídeos". | O sistema apresenta a interface de ordenação com as miniaturas dos vídeos e opções de saída (resolução, formato). |
| 3 | O utilizador ajusta a ordem de reprodução dos vídeos (drag-and-drop) e seleciona os parâmetros de saída. | O sistema valida se a duração total acumulada e o número de ficheiros respeitam o limite do perfil do utilizador. |
| 4 | O utilizador confirma a operação de concatenação. | O sistema valida a quota do utilizador e a disponibilidade do armazenamento. |
| 5 | — | O sistema cria um job de concatenação e envia a tarefa para a fila de mensagens (RabbitMQ). |
| 6 | — | O sistema notifica o utilizador que o processamento iniciou e atualiza o estado para "Em fila". |
| 7 | O utilizador acompanha o progresso. | O sistema comunica periodicamente o progresso em tempo real (%) via WebSocket. |
| 8 | — | O worker (FFmpeg) normaliza as resoluções/codecs se necessário, une os ficheiros na ordem definida, preservando as faixas de áudio, e guarda o resultado final no armazenamento. |
| 9 | — | O sistema regista o novo vídeo na base de dados, associa-o ao projeto e decrementa a quota do utilizador. |
| 10 | — | O sistema notifica a conclusão com sucesso e disponibiliza o vídeo final na biblioteca. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Normalização Automática de Resolução | Se os vídeos selecionados tiverem resoluções ou taxas de fotogramas diferentes, o sistema ajusta automaticamente todos os vídeos para a resolução do primeiro elemento ou para a resolução configurada pelo utilizador. |
| FA2 – Cancelamento pelo Utilizador | Durante a execução, o utilizador pode cancelar o job: o worker interrompe o FFmpeg, elimina os ficheiros temporários gerados, marca o job como cancelado e devolve a quota reservada. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Duração total combinada excede o limite do perfil | O sistema impede a submissão, destaca a duração excedida e sugere a remoção de vídeos ou upgrade de perfil. |
| Ficheiro de entrada corrompido ou inacessível | O sistema assinala o ficheiro inválido no lote, interrompe a criação do job e notifica o utilizador. |
| Quota diária esgotada | O sistema bloqueia o início da operação e exibe o horário de reposição da quota. |
| Falha técnica durante a composição (FFmpeg) | O sistema interceta o erro, marca o job como falhado, limpa temporários, liberta a quota e disponibiliza o botão "Tentar novamente". |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O vídeo resultado da união está guardado na biblioteca do projeto e os vídeos originais permanecem intactos. |
| Garantia Mínima | Os vídeos originais permanecem inalterados, os dados parciais/temporários são eliminados, o job fica marcado como falhado/cancelado e nenhuma quota é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | A concatenação exige no mínimo 2 vídeos e no máximo 5 (Registado) ou 15 (Premium). |
| RN2 | A duração total do vídeo final não pode exceder 3 minutos para Registados e 20 minutos para Premium. |
| RN3 | Os vídeos de origem nunca são alterados ou eliminados durante a concatenação. |
| RN4 | Cada concatenação concluída com sucesso desconta 1 operação na quota diária. |
| RN5 | Jobs cancelados ou falhados não consomem quota diária. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O FFmpeg está configurado com os filtros adequados (`concat demuxer` / `complex filter`) para unir vídeos heterogéneos. |
| A2 | O armazenamento temporário dos workers tem capacidade suficiente para alojar os ficheiros intermédios durante o processo. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Deve ser possível adicionar efeitos de transição (ex: *fade*, *crossfade*) entre os vídeos concatenados no MVP? |
| Q2 | Se um vídeo não tiver faixa de áudio, o sistema deve inserir áudio silencioso para manter a sincronização? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso, identificação de excepções e fluxos alternativos | Revisão manual e adequação às regras globais do PictuRAS |

---

## ✅ Lista de verificação antes de entregar (Exercício 1)

- [x] Secções 0 a 3 preenchidas e texto de ajuda removido.
- [x] Funcionalidade de vídeo escolhida **e justificada** no contexto do MVP.
- [x] Ator principal identificado, com o respetivo perfil.
- [x] Caso de uso com fluxo principal, **≥1 fluxo alternativo** e **≥1 exceção específica de vídeo**.
- [x] Pós-condições com garantia de sucesso **e** garantia mínima.
- [x] Regras de negócio e restrições preenchidas.
- [x] Assunções e questões em aberto registadas.
- [x] Utilização de agentes de IA documentada.

---
---

## 4. Esboço de requisitos derivados

### 4.1 Requisitos de Sistema

| **ID** | **Requisito** | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem** | **Como verificar** |
|--------|---------------|----------|----------------|--------------|------------|--------------------|
| REQ-VID-CAT-001 | O sistema deve permitir a seleção múltipla de vídeos, reordenação sequencial e escolha de formato/resolução de saída. | F | Deve ter | Novo | UC-VID-006, passos 1–3 | Verificar se o frontend aceita drag-and-drop de vídeos e permite definir a ordem desejada. |
| REQ-VID-CAT-002 | O sistema deve validar os limites de duração total acumulada e o número de ficheiros em função do perfil do utilizador. | F | Deve ter | Novo | UC-VID-006, passo 3; RN1–RN2 | Tentar submeter seleções que excedam os minutos/quantidade máximos e confirmar o bloqueio. |
| REQ-VID-CAT-003 | O sistema deve criar um job assíncrono de concatenação na fila e reportar progresso em tempo real via WebSocket. | F | Deve ter | Novo | UC-VID-006, passos 5–7 | Monitorizar a publicação do job no RabbitMQ e o envio de percentagens na WebSocket. |
| REQ-VID-CAT-004 | O motor de processamento deve normalizar as características técnicas (codec, resolução, fps) dos vídeos antes de efetuar a união. | F | Deve ter | Novo | UC-VID-006, passo 8; FA1 | Submeter vídeos de diferentes resoluções e verificar se o vídeo final é reproduzido sem distorções. |
| REQ-VID-CAT-005 | O sistema deve armazenar o novo vídeo gerado mantendo intactos os ficheiros de origem e atualizar a quota após o sucesso. | F | Deve ter | Novo | UC-VID-006, passos 8–10; pós-condições | Confirmar a integridade dos originais e que a quota do utilizador reflete a dedução. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Interface do Utilizador (Frontend) | Estender | Adicionar suporte a seleção múltipla na biblioteca, componente de ordenação por *drag-and-drop* e pré-visualização da duração total. | REQ-VID-CAT-001 |
| Fila RabbitMQ / Workers de Vídeo | Estender | Criar uma fila/handler dedicado a concatenações com lógica de normalização via FFmpeg (`complex_filter`). | REQ-VID-CAT-003, REQ-VID-CAT-004 |
| Armazenamento (SeaweedFS / S3) | Estender | Aumentar temporariamente o espaço de trabalho em disco nos workers para acomodar os múltiplos vídeos descarregados. | REQ-VID-CAT-004, REQ-VID-CAT-005 |
| Gestão de Perfis e Quotas | Alterar | Incluir validação de duração acumulada de múltiplos ficheiros na verificação prévia à submissão. | REQ-VID-CAT-002 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1–3 | Seleção, reordenação e parâmetros de saída | REQ-VID-CAT-001, REQ-VID-CAT-002 |
| Passos 4–7 | Submissão, enfileiramento e progresso assíncrono | REQ-VID-CAT-003 |
| Passo 8 | Normalização e concatenação dos streams de vídeo/áudio | REQ-VID-CAT-004 |
| Passos 9–10 | Gravação do resultado, preservação dos originais e atualização de quota | REQ-VID-CAT-005 |1 operação na quota diária. |
| RN5 | Jobs cancelados ou falhados não consomem quota diária. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O FFmpeg está configurado com os filtros adequados (`concat demuxer` / `complex filter`) para unir vídeos heterogéneos. |
| A2 | O armazenamento temporário dos workers tem capacidade suficiente para alojar os ficheiros intermédios durante o processo. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Deve ser possível adicionar efeitos de transição (ex: *fade*, *crossfade*) entre os vídeos concatenados no MVP? |
| Q2 | Se um vídeo não tiver faixa de áudio, o sistema deve inserir áudio silencioso para manter a sincronização? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso, identificação de excepções e fluxos alternativos | Revisão manual e adequação às regras globais do PictuRAS |

---

## ✅ Lista de verificação antes de entregar (Exercício 1)

- [x] Secções 0 a 3 preenchidas e texto de ajuda removido.
- [x] Funcionalidade de vídeo escolhida **e justificada** no contexto do MVP.
- [x] Ator principal identificado, com o respetivo perfil.
- [x] Caso de uso com fluxo principal, **≥1 fluxo alternativo** e **≥1 exceção específica de vídeo**.
- [x] Pós-condições com garantia de sucesso **e** garantia mínima.
- [x] Regras de negócio e restrições preenchidas.
- [x] Assunções e questões em aberto registadas.
- [x] Utilização de agentes de IA documentada.

---
---

## 4. Esboço de requisitos derivados

### 4.1 Requisitos de Sistema

| **ID** | **Requisito** | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem** | **Como verificar** |
|--------|---------------|----------|----------------|--------------|------------|--------------------|
| REQ-VID-CAT-001 | O sistema deve permitir a seleção múltipla de vídeos, reordenação sequencial e escolha de formato/resolução de saída. | F | Deve ter | Novo | UC-VID-006, passos 1–3 | Verificar se o frontend aceita drag-and-drop de vídeos e permite definir a ordem desejada. |
| REQ-VID-CAT-002 | O sistema deve validar os limites de duração total acumulada e o número de ficheiros em função do perfil do utilizador. | F | Deve ter | Novo | UC-VID-006, passo 3; RN1–RN2 | Tentar submeter seleções que excedam os minutos/quantidade máximos e confirmar o bloqueio. |
| REQ-VID-CAT-003 | O sistema deve criar um job assíncrono de concatenação na fila e reportar progresso em tempo real via WebSocket. | F | Deve ter | Novo | UC-VID-006, passos 5–7 | Monitorizar a publicação do job no RabbitMQ e o envio de percentagens na WebSocket. |
| REQ-VID-CAT-004 | O motor de processamento deve normalizar as características técnicas (codec, resolução, fps) dos vídeos antes de efetuar a união. | F | Deve ter | Novo | UC-VID-006, passo 8; FA1 | Submeter vídeos de diferentes resoluções e verificar se o vídeo final é reproduzido sem distorções. |
| REQ-VID-CAT-005 | O sistema deve armazenar o novo vídeo gerado mantendo intactos os ficheiros de origem e atualizar a quota após o sucesso. | F | Deve ter | Novo | UC-VID-006, passos 8–10; pós-condições | Confirmar a integridade dos originais e que a quota do utilizador reflete a dedução. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Interface do Utilizador (Frontend) | Estender | Adicionar suporte a seleção múltipla na biblioteca, componente de ordenação por *drag-and-drop* e pré-visualização da duração total. | REQ-VID-CAT-001 |
| Fila RabbitMQ / Workers de Vídeo | Estender | Criar uma fila/handler dedicado a concatenações com lógica de normalização via FFmpeg (`complex_filter`). | REQ-VID-CAT-003, REQ-VID-CAT-004 |
| Armazenamento (SeaweedFS / S3) | Estender | Aumentar temporariamente o espaço de trabalho em disco nos workers para acomodar os múltiplos vídeos descarregados. | REQ-VID-CAT-004, REQ-VID-CAT-005 |
| Gestão de Perfis e Quotas | Alterar | Incluir validação de duração acumulada de múltiplos ficheiros na verificação prévia à submissão. | REQ-VID-CAT-002 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1–3 | Seleção, reordenação e parâmetros de saída | REQ-VID-CAT-001, REQ-VID-CAT-002 |
| Passos 4–7 | Submissão, enfileiramento e progresso assíncrono | REQ-VID-CAT-003 |
| Passo 8 | Normalização e concatenação dos streams de vídeo/áudio | REQ-VID-CAT-004 |
| Passos 9–10 | Gravação do resultado, preservação dos originais e atualização de quota | REQ-VID-CAT-005 |