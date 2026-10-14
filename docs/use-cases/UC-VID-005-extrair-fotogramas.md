# UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 27 |
| **Autores** | Equipa do Grupo 27 |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Extrair sequência de fotogramas de um vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Anónimo / registado / premium — cada perfil tem limites diferentes de número de fotogramas e formato de saída. |

**Justificação no contexto do MVP** *(2–3 linhas)*
A extração de fotogramas liga o domínio do vídeo ao domínio da imagem e permite reutilizar ferramentas já validadas no sistema sem criar novas soluções para cada caso. É uma funcionalidade essencial para análise visual, edição e preparação de conteúdos para processamento posterior. Sem ela, o suporte a vídeo fica incompleto e pouco útil no contexto do PictuRAS.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-005 |
| **Nome** | Extrair sequência de fotogramas de um vídeo |
| **Versão** | v1.0 |
| **Autor** | Equipa Grupo 27 |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador extrair fotogramas de um vídeo e armazená-los como imagens do projeto para processamento posterior. |
| **Âmbito** | Módulo de vídeo do PictuRAS e integração com a biblioteca de imagens |
| **Ator Principal** | Utilizador anónimo, registado ou premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende obter imagens a partir de um vídeo para análise, edição ou processamento posterior<br>- **Proprietário do Sistema**: deseja reutilizar as ferramentas de imagem existentes sobre conteúdo extraído de vídeo<br>- **Equipa de Desenvolvimento**: valida a integração entre extração, filas e armazenamento |
| **Pré-condições** | - O utilizador tem acesso a um projeto com um vídeo carregado e válido<br>- O ficheiro de vídeo está acessível ao sistema e no formato suportado<br>- O serviço de extração de fotogramas está disponível |
| **Trigger** | O utilizador seleciona um vídeo e escolhe a opção de extração de fotogramas. |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre a biblioteca de vídeos do projeto. | O sistema apresenta as propriedades básicas do vídeo e a opção de extração de fotogramas. |
| 2 | O utilizador seleciona um vídeo e inicia a operação de extração. | — |
| 3 | — | O sistema apresenta os parâmetros disponíveis, como intervalo temporal, quantidade de fotogramas e formato de saída. |
| 4 | O utilizador define os parâmetros da extração. | — |
| 5 | — | O sistema calcula e apresenta a estimativa do número total de fotogramas. |
| 6 | O utilizador confirma a operação. | — |
| 7 | — | O sistema valida o perfil, o número de fotogramas e o espaço disponível. |
| 8 | — | O sistema cria um job de processamento e publica a tarefa na fila de extração. |
| 9 | O utilizador acompanha o progresso. | O sistema atualiza o estado por WebSocket. |
| 10 | — | O sistema extrai cada fotograma e guarda-o no armazenamento como imagem do projeto. |
| 11 | — | O sistema marca o job como concluído e notifica o utilizador. |
| 12 | — | As imagens ficam disponíveis na biblioteca para processamento posterior. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Extração parcial | Se o utilizador definir um intervalo temporal, o sistema extrai apenas os fotogramas desse intervalo e ignora o restante conteúdo. |
| FA2 – Cancelamento da extração | Durante a execução, o utilizador pode cancelar a operação; o sistema mantém os fotogramas já extraídos e termina o job em estado cancelado. |
| FA3 – Novo projeto para os fotogramas | Se o utilizador optar por receber os fotogramas num projeto novo, o sistema cria esse projeto e organiza os ficheiros nesse contexto. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Codec do vídeo não suportado | O sistema rejeita a operação e informa o utilizador dos codecs aceitáveis. |
| Número de fotogramas excede o limite do perfil | O sistema bloqueia a extração e pede que o utilizador reduza o intervalo ou o volume. |
| Espaço de armazenamento insuficiente | O sistema informa que não há espaço suficiente e não inicia o processamento. |
| Falha a meio do processamento | O sistema preserva os fotogramas já extraídos, marca o job como falhado e notifica o utilizador. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | Os fotogramas ficam armazenados como imagens do projeto e o vídeo original permanece inalterado. |
| Garantia Mínima | O vídeo original continua acessível e os fotogramas já extraídos permanecem disponíveis, com o estado do job devidamente registado. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | Anónimos estão limitados a um número inferior de fotogramas por extração. |
| RN2 | Registados têm um limite superior e premium um limite mais alto. |
| RN3 | Cada extração conta como uma operação na quota diária do utilizador. |
| RN4 | Os fotogramas extraídos devem ser armazenados como imagens normais do projeto. |
| RN5 | O vídeo original não pode ser alterado por esta funcionalidade. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O vídeo está disponível no armazenamento e acessível ao serviço de extração. |
| A2 | A fila de processamento e o WebSocket já existentes suportam notificações de progresso e execução assíncrona. |
| A3 | O FFmpeg ou equivalente está disponível para extrair fotogramas do vídeo. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | O sistema deve permitir pré-visualização dos primeiros fotogramas antes de confirmar a extração completa? |
| Q2 | Os fotogramas extraídos devem ser guardados no mesmo projeto atual ou num projeto novo por predefinição? |
| Q3 | A extração deve suportar filtros adicionais, como apenas fotogramas com alteração visual significativa? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso e dos fluxos alternativos | Revisão manual pela equipa; ajuste dos limites por perfil, compatibilidade de codecs e preservação do vídeo original |

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
| REQ-VID-EXTR-001 | O sistema deve apresentar as propriedades do vídeo selecionado e as opções de extração disponíveis antes de iniciar o processamento. | F | Deve ter | Novo | UC-VID-005, passo 3 | Verificar que a interface mostra duração, resolução, fps, codec e o modo de extração disponível. |
| REQ-VID-EXTR-002 | O sistema deve calcular e mostrar uma estimativa do número de fotogramas que serão gerados, consoante o intervalo, a contagem ou a seleção do utilizador. | F | Deve ter | Novo | UC-VID-005, passos 4–5 | Validar que, ao alterar parâmetros, a estimativa atualiza imediatamente na UI. |
| REQ-VID-EXTR-003 | O sistema deve validar o limite de fotogramas por perfil, o espaço disponível e a conformidade do vídeo antes de criar o job de extração. | F | Deve ter | Novo | UC-VID-005, passo 7; RN1–RN5 | Confirmar que a operação é rejeitada quando o vídeo ou o perfil não respeita os limites. |
| REQ-VID-EXTR-004 | O sistema deve criar um job de extração na fila de processamento, manter o estado do job e reportar progresso em tempo real via WebSocket. | F | Deve ter | Novo | UC-VID-005, passos 8–10 | Verificar a criação do job, a atualização do estado e o recebimento de mensagens de progresso. |
| REQ-VID-EXTR-005 | O sistema deve armazenar os fotogramas extraídos como imagens do projeto, preservando o vídeo original e mantendo o resultado disponível para processamento posterior. | F | Deve ter | Novo | UC-VID-005, passos 10–12; pós-condições | Validar que as imagens aparecem na biblioteca do projeto e que o ficheiro original permanece intacto. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Fila RabbitMQ | Estender | É necessário criar uma fila dedicada para jobs de extração de fotogramas e garantir o processamento assíncrono. | REQ-VID-EXTR-004 |
| Armazenamento SeaweedFS | Estender | Os fotogramas extraídos passam a gerar múltiplos ficheiros de imagem e exigem controlo de espaço e organização por projeto. | REQ-VID-EXTR-003, REQ-VID-EXTR-005 |
| WebSocket / frontend | Estender | A interface precisa de mostrar progresso, confirmar conclusão e refletir os resultados na biblioteca de imagens. | REQ-VID-EXTR-002, REQ-VID-EXTR-004 |
| Modelo de imagens e gestão de projetos | Estender | Os fotogramas extraídos devem entrar no mesmo fluxo de processamento e organização das imagens já existentes. | REQ-VID-EXTR-005 |
| Sistema de perfis e quotas | Alterar | As regras de limite de fotogramas por perfil e a contagem de operações têm de ser reconhecidas na validação do job. | REQ-VID-EXTR-003 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passo 3 | Apresentação das propriedades do vídeo e opções de extração | REQ-VID-EXTR-001 |
| Passos 4–5 | Definição dos parâmetros e cálculo da estimativa | REQ-VID-EXTR-002 |
| Passo 7 | Validação de limites, quota e espaço disponível | REQ-VID-EXTR-003 |
| Passos 8–10 | Criação do job, processamento e progresso em tempo real | REQ-VID-EXTR-004 |
| Passos 10–12 | Armazenamento dos fotogramas e preservação do vídeo original | REQ-VID-EXTR-005 |
