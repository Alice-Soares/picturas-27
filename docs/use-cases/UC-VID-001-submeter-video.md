# UC-VID-001 — Submeter Vídeo para Processamento

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 5 - PL3|
| **Autores** | Equipa do Grupo 27 |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Submeter Vídeo para Processamento |
| **Perfil(s) de utilizador abrangido(s)** | Anónimo / registado / premium — todos podem submeter vídeos, mas com limites diferentes de tamanho, duração e quota. |

**Justificação no contexto do MVP** *(2–3 linhas)*
Esta funcionalidade é a base de todo o suporte a vídeo no PictuRAS, porque sem upload válido não é possível executar qualquer operação posterior. Permite validar o pipeline completo de carregamento, validação, armazenamento e visualização, além de confirmar as regras de negócio por perfil. Sem ela, o restante suporte a vídeo fica inviável no MVP.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-001 |
| **Nome** | Submeter Vídeo para Processamento |
| **Versão** | v1.0 |
| **Autor** | Equipa Grupo 27 |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador carregar um vídeo válido para o projeto e torná-lo disponível para processamento posterior. |
| **Âmbito** | Módulo de gestão de conteúdos multimédia do PictuRAS |
| **Ator Principal** | Utilizador anónimo, registado ou premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende carregar e guardar vídeos sem perda de dados<br>- **Proprietário do Sistema**: deseja validar as regras de quota e perfil para vídeo<br>- **Equipa de Desenvolvimento**: valida upload, armazenamento e metadados de vídeo |
| **Pré-condições** | - O utilizador tem acesso à plataforma e, se necessário, sessão iniciada<br>- O utilizador tem um projeto ativo ou pode criar um novo<br>- O serviço de armazenamento está disponível<br>- O ficheiro de vídeo encontra-se no sistema local |
| **Trigger** | O utilizador seleciona um ficheiro de vídeo e escolhe a opção de submissão ao projeto. |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre a biblioteca de conteúdos ou o projeto. | O sistema apresenta a interface de upload com suporte para ficheiros de vídeo. |
| 2 | O utilizador seleciona um ficheiro de vídeo local. | O sistema valida a extensão e o tipo de ficheiro. |
| 3 | — | O sistema verifica o tamanho do ficheiro e aplica os limites do perfil atual. |
| 4 | — | O sistema inicia o upload assíncrono do ficheiro para o armazenamento do projeto. |
| 5 | O utilizador acompanha o progresso do upload. | O sistema comunica o estado e o progresso em tempo real via WebSocket. |
| 6 | — | O sistema conclui o upload e valida a integridade do ficheiro. |
| 7 | — | O sistema extrai os metadados do vídeo (codec, resolução, duração, fps e tamanho). |
| 8 | — | O sistema valida a duração e a resolução contra os limites do perfil. |
| 9 | — | O sistema guarda o vídeo no armazenamento e cria o registo correspondente na base de dados. |
| 10 | — | O sistema associa o vídeo ao projeto e torna-o disponível para visualização e processamento. |
| 11 | — | O sistema atualiza a quota do utilizador e informa o sucesso da operação. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Upload duplicado | Se o vídeo tiver o mesmo nome de um ficheiro já existente no projeto, o sistema apresenta opções de substituir, manter ambos ou cancelar. |
| FA2 – Upload em lote | Se o utilizador selecionar vários vídeos ou um ficheiro ZIP, o sistema valida cada elemento individualmente e processa os ficheiros válidos. |
| FA3 – Cancelamento do upload | Durante o progresso, o utilizador pode cancelar a operação; o sistema interrompe a transferência e elimina os chunks parciais. |
| FA4 – Vídeo anónimo | Se o perfil for anónimo, o sistema aplica marca de água ao vídeo e agenda o processamento associado. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Formato ou codec não suportado | O sistema rejeita o ficheiro com mensagem de erro e não guarda qualquer versão parcial. |
| Tamanho do ficheiro excede o limite do perfil | O sistema bloqueia o upload e informa o utilizador do máximo permitido para o seu perfil. |
| Duração do vídeo excede o limite do perfil | O sistema rejeita o vídeo, remove ficheiros temporários e não consome quota. |
| Quota diária esgotada | O sistema impede a submissão e indica que a quota foi atingida. |
| Falha de rede durante o upload | O sistema tenta retomar ou limpa os chunks parciais e informa o utilizador do erro. |
| Armazenamento indisponível | O sistema informa que o serviço de armazenamento está temporariamente indisponível. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O ficheiro de vídeo fica armazenado no sistema, associado ao projeto correspondente e disponível para processamento posterior. |
| Garantia Mínima | Nenhum ficheiro parcial ou corrompido permanece armazenado, a quota não é consumida e o utilizador recebe uma mensagem de erro clara. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | Utilizadores anónimos têm um limite de tamanho e duração mais restritivo do que registados e premium. |
| RN2 | Utilizadores registados têm quota diária de operações e não podem exceder esse limite. |
| RN3 | Utilizadores premium têm maior capacidade de armazenamento e tempo de execução. |
| RN4 | Apenas formatos e codecs suportados pelo sistema são aceites. |
| RN5 | Vídeos acima do limite máximo de resolução são rejeitados. |
| RN6 | Cada submissão concluída conta como uma operação para efeitos de quota. |
| RN7 | Vídeos de utilizadores anónimos podem receber marca de água automática. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O sistema de armazenamento suporta ficheiros de vídeo de grande dimensão sem perda de integridade. |
| A2 | A infraestrutura WebSocket consegue acompanhar uploads de ficheiros longos sem falhas frequentes. |
| A3 | O FFmpeg/FFprobe está disponível para extração de metadados e validação técnica. |
| A4 | O projeto do utilizador já está operacional para receber novos conteúdos. |
| A5 | O serviço de armazenamento e a base de dados estão disponíveis durante o processo de upload. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | Os utilizadores anónimos devem poder submeter vídeos diretamente ou apenas consumir ficheiros já existentes? |
| Q2 | O sistema deve gerar automaticamente uma miniatura para cada vídeo submetido com sucesso? |
| Q3 | Os vídeos devem ser armazenados no mesmo bucket que as imagens ou num bucket separado? |
| Q4 | Deve existir um limite máximo de uploads simultâneos por utilizador? |
| Q5 | A interface deve suportar drag-and-drop além do seletor de ficheiros tradicional? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso e dos fluxos principais e alternativos | Revisão manual pela equipa; ajuste dos limites de upload e das regras por perfil |

---

## ✅ Lista de verificação antes de entregar (Exercício 1)

- [ ] Secções 0 a 3 preenchidas e texto de ajuda (`>` e `{…}`) removido.
- [ ] Funcionalidade de vídeo escolhida **e justificada** no contexto do MVP.
- [ ] Ator principal identificado, com o respetivo perfil.
- [ ] Caso de uso com fluxo principal, **≥1 fluxo alternativo** e **≥1 exceção específica de vídeo**.
- [ ] Pós-condições com garantia de sucesso **e** garantia mínima.
- [ ] Regras de negócio e restrições preenchidas.
- [ ] Assunções e questões em aberto registadas.
- [ ] Utilização de agentes de IA documentada.

---
---

## 4. Esboço de requisitos derivados

### 4.1 Requisitos de Sistema

| **ID** | **Requisito** | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem** | **Como verificar** |
|--------|---------------|----------|----------------|--------------|------------|--------------------|
| REQ-VID-UPL-001 | O sistema deve apresentar a interface de upload com as restrições de formato, tamanho e resolução antes da submissão. | F | Deve ter | Novo | UC-VID-001, passos 1–3 | Verificar que a UI mostra os formatos suportados, os limites por perfil e as mensagens de validação imediata. |
| REQ-VID-UPL-002 | O sistema deve validar o ficheiro de vídeo, a duração, o tamanho, a quota e a compatibilidade do codec antes de iniciar o armazenamento. | F | Deve ter | Novo | UC-VID-001, passos 2–3; RN1–RN7 | Confirmar que vídeos inválidos são rejeitados sem guardar ficheiros parciais ou consumir quota. |
| REQ-VID-UPL-003 | O sistema deve executar o upload em modo assíncrono e comunicar o progresso do processo em tempo real via WebSocket. | F | Deve ter | Novo | UC-VID-001, passos 4–5 | Validar que a barra de progresso, o estado do job e as notificações do cliente são atualizados corretamente. |
| REQ-VID-UPL-004 | O sistema deve armazenar o vídeo no projeto, extrair os metadados e registar a entrada na base de dados com ligação ao utilizador e ao projeto. | F | Deve ter | Novo | UC-VID-001, passos 6–10; A1–A5 | Verificar que o vídeo fica associado ao projeto, com codec, duração, fps, resolução e metadados corretamente guardados. |
| REQ-VID-UPL-005 | O sistema deve disponibilizar o vídeo para processamento posterior, atualizar a quota do utilizador e informar o resultado final da operação. | F | Deve ter | Novo | UC-VID-001, passo 11 | Confirmar que o vídeo está disponível na biblioteca do projeto, a quota foi atualizada e o utilizador recebe a confirmação de sucesso. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Frontend de upload e projeto | Estender | A interface precisa de mostrar a validação inicial, o progresso do upload e o estado final da submissão. | REQ-VID-UPL-001, REQ-VID-UPL-003, REQ-VID-UPL-005 |
| RabbitMQ / filas de processamento | Estender | O upload assíncrono passa a depender de uma fila de gestão de jobs e notificações de progresso. | REQ-VID-UPL-003 |
| Armazenamento SeaweedFS | Estender | O sistema tem de guardar vídeos, manter ficheiros temporários em segurança e garantir a integridade final do ficheiro. | REQ-VID-UPL-002, REQ-VID-UPL-004 |
| Base de dados de projetos e vídeos | Estender | O registo do vídeo e dos metadados precisa de estar associado ao projeto e ao perfil do utilizador. | REQ-VID-UPL-004 |
| Sistema de perfis e quotas | Alterar | As regras de limite por perfil e a contagem de submissões devem ser verificadas antes e depois do upload. | REQ-VID-UPL-002, REQ-VID-UPL-005 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1–3 | Abertura do upload e validação inicial de ficheiro e perfil | REQ-VID-UPL-001, REQ-VID-UPL-002 |
| Passos 4–5 | Upload assíncrono e atualização de progresso | REQ-VID-UPL-003 |
| Passos 6–10 | Armazenamento do vídeo, extração de metadados e associação ao projeto | REQ-VID-UPL-004 |
| Passo 11 | Atualização da quota e confirmação final | REQ-VID-UPL-005 |
