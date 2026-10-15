# UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 5 - PL3 |
| **Autores** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [número mecanográfico por confirmar] |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Extrair sequência de fotogramas de um vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Registado e premium. O perfil anónimo fica fora desta funcionalidade até existir uma regra de vídeo aprovada. |

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
| **Autor** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador extrair fotogramas de um vídeo e armazená-los como imagens do projeto para processamento posterior. |
| **Âmbito** | Módulo de vídeo do PictuRAS e integração com a biblioteca de imagens |
| **Ator Principal** | Utilizador registado ou premium |
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
| FA2 – Cancelamento da extração | Durante a execução, o utilizador pode cancelar a operação; o sistema elimina os fotogramas temporários e termina o job em estado cancelado. |
| FA3 – Novo projeto para os fotogramas | Se o utilizador optar por receber os fotogramas num projeto novo, o sistema cria esse projeto e organiza os ficheiros nesse contexto. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Codec do vídeo não suportado | O sistema rejeita a operação e informa o utilizador dos codecs aceitáveis. |
| Número de fotogramas excede o limite do perfil | O sistema bloqueia a extração e pede que o utilizador reduza o intervalo ou o volume. |
| Espaço de armazenamento insuficiente | O sistema informa que não há espaço suficiente e não inicia o processamento. |
| Falha a meio do processamento | O sistema elimina os fotogramas temporários, marca o job como falhado, devolve qualquer quota reservada e notifica o utilizador. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | Os fotogramas ficam armazenados como imagens do projeto e o vídeo original permanece inalterado. |
| Garantia Mínima | O vídeo original continua acessível, os fotogramas temporários são eliminados e o estado falhado ou cancelado fica registado. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | O perfil anónimo não tem acesso a esta funcionalidade até existir uma regra de vídeo aprovada. |
| RN2 | O limite é de 1000 fotogramas por job para registados e 5000 para premium; os fotogramas são guardados em JPEG. |
| RN3 | Cada job de extração aceite conta como uma operação avançada; utilizadores premium não têm limite diário. |
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
