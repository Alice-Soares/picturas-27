# UC-VID-004 — Converter Formato e Resolução de Vídeo

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 27 |
| **Autores** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Faria [pg63920], Samuel|
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Converter formato e resolução de vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Anónimo / registado / premium — cada perfil tem acesso a combinações diferentes de formato e resolução, conforme as regras de negócio do sistema. |

**Justificação no contexto do MVP** *(2–3 linhas)*
A conversão de vídeo permite adaptar conteúdos a diferentes dispositivos e contextos de uso, reduzindo o peso do ficheiro e melhorando a compatibilidade. Também valida o pipeline assíncrono de transcodificação, que será essencial para operações futuras de vídeo no PictuRAS. Sem esta funcionalidade, o suporte a vídeo ficaria incompleto e menos útil para o utilizador final.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-004 |
| **Nome** | Converter formato e resolução de vídeo |
| **Versão** | v1.0 |
| **Autor** | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Faria [pg63920], Samuel |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador converter um vídeo para um formato, codec e resolução compatíveis com o seu perfil e necessidade de uso. |
| **Âmbito** | Módulo de processamento de vídeo do PictuRAS, integração com transcodificação e armazenamento de resultados |
| **Ator Principal** | Utilizador anónimo, registado ou premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende adaptar vídeos para diferentes dispositivos, plataformas e tamanhos de ficheiro<br>- **Proprietário do Sistema**: deseja manter controlo de qualidade, quota e compatibilidade do conteúdo<br>- **Equipa de Desenvolvimento**: valida o fluxo assíncrono de transcodificação e a integração com o armazenamento |
| **Pré-condições** | - O utilizador tem acesso a um projeto com um vídeo válido carregado<br>- O vídeo está no formato e codec suportados pelo sistema<br>- O serviço de transcodificação está disponível |
| **Trigger** | O utilizador seleciona um vídeo e escolhe a opção de conversão no painel de ferramentas. |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre a biblioteca de vídeos do projeto. | O sistema apresenta o vídeo selecionado e as propriedades básicas do ficheiro. |
| 2 | O utilizador seleciona um vídeo e escolhe a opção "Converter Vídeo". | — |
| 3 | — | O sistema apresenta as propriedades do vídeo de origem e as opções de conversão disponíveis conforme o perfil. |
| 4 | O utilizador define o formato e a resolução de destino. | — |
| 5 | — | O sistema valida as opções e apresenta uma estimativa do tamanho final do ficheiro. |
| 6 | O utilizador confirma a operação. | — |
| 7 | — | O sistema cria um job de transcodificação e publica a tarefa na fila do processamento. |
| 8 | O utilizador acompanha o progresso. | O sistema atualiza o estado do job e comunica o progresso em tempo real via WebSocket. |
| 9 | — | O sistema executa a transcodificação e guarda o vídeo resultante no armazenamento. |
| 10 | — | O sistema atualiza o estado do job para concluído e disponibiliza o ficheiro convertido ao utilizador. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Conversão em lote | Se o utilizador selecionar vários vídeos, o sistema cria um job por vídeo e aplica os mesmos parâmetros a todos. |
| FA2 – Cancelamento da conversão | Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe a transcodificação, limpa ficheiros temporários e marca o job como cancelado. |
| FA3 – Perfil predefinido | Se o utilizador selecionar um perfil predefinido, o sistema preenche automaticamente o formato, resolução e codec mais adequados. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Formato de origem não suportado | O sistema rejeita a conversão e informa o utilizador dos formatos aceites. |
| Combinação de formato e codec inválida | O sistema bloqueia a configuração e solicita uma combinação compatível. |
| Quota diária esgotada | O sistema impede a conversão e informa que o limite do perfil foi atingido. |
| Falha durante a transcodificação | O sistema marca o job como falhado, elimina ficheiros temporários e informa o utilizador. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O ficheiro convertido fica armazenado no projeto e disponível para visualização e transferência sem alterar o vídeo original. |
| Garantia Mínima | O vídeo original permanece intacto, os ficheiros temporários são removidos e o job é registado com o estado final correto. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | O formato e a resolução de saída devem respeitar o perfil do utilizador. |
| RN2 | A resolução de saída não pode exceder a resolução do vídeo original. |
| RN3 | Cada conversão bem-sucedida conta como uma operação na quota diária. |
| RN4 | O conteúdo de áudio deve ser convertido para um formato compatível com o contentor de saída. |
| RN5 | O vídeo original deve permanecer inalterado após a conversão. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O FFmpeg ou ferramenta equivalente está disponível para realizar a transcodificação. |
| A2 | A infraestrutura de filas e WebSocket suporta a atualização de progresso em tempo real. |
| A3 | O armazenamento do projeto consegue guardar ficheiros de vídeo convertidos sem corrupção. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | O sistema deve permitir conversão em paralelo para vários vídeos ou apenas uma transcodificação por vídeo de cada vez? |
| Q2 | Os vídeos convertidos devem substituir o original ou ser armazenados como versões separadas do projeto? |
| Q3 | O sistema deve gerar perfis de conversão automáticos para utilizadores menos experientes? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso, fluxos alternativos e regras de negócio | Revisão manual pela equipa; ajuste dos limites por perfil e validação da coerência com o pipeline de vídeo |

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
| REQ-VID-CONV-001 | O sistema deve apresentar as opções de formato, codec e resolução de saída e estimar o tamanho final do ficheiro antes da confirmação. | F | Deve ter | Novo | UC-VID-004, passos 1–5 | Verificar que a interface mostra as opções válidas para o perfil e a estimativa do tamanho final do vídeo. |
| REQ-VID-CONV-002 | O sistema deve validar a combinação de formato, codec e resolução, além das restrições do perfil e do vídeo de origem. | F | Deve ter | Novo | UC-VID-004, passos 3–6; RN1–RN5 | Confirmar que configurações inválidas são rejeitadas e que o vídeo original continua inalterado. |
| REQ-VID-CONV-003 | O sistema deve criar um job de transcodificação, validar os parâmetros e publicar a tarefa na fila de processamento. | F | Deve ter | Novo | UC-VID-004, passos 6–8 | Validar que o job é criado, o estado é atualizado e a fila recebe a tarefa corretamente. |
| REQ-VID-CONV-004 | O sistema deve executar a conversão com FFmpeg, informar o progresso do processamento e guardar o vídeo resultante no projeto. | F | Deve ter | Novo | UC-VID-004, passos 8–9 | Confirmar que o WebSocket comunica progresso e que o ficheiro convertido é produzido no armazenamento. |
| REQ-VID-CONV-005 | O sistema deve manter o vídeo original intacto, disponibilizar a versão convertida para visualização e notificar a conclusão da operação. | F | Deve ter | Novo | UC-VID-004, passo 10; pós-condições | Verificar que a versão convertida fica acessível, o original permanece inalterado e o utilizador recebe a confirmação final. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Frontend de conversão e vídeo | Estender | A UI da biblioteca de vídeos deve mostrar as opções de conversão, a prévia da configuração e o progresso. | REQ-VID-CONV-001, REQ-VID-CONV-004 |
| Fila RabbitMQ / transcodificação | Estender | A conversão exige um job específico de transcodificação com atualização de estado e cancelamento. | REQ-VID-CONV-003, REQ-VID-CONV-004 |
| FFmpeg e codec management | Estender | O módulo de transcodificação precisa de validar combinações válidas e preservar a qualidade e o áudio. | REQ-VID-CONV-002, REQ-VID-CONV-004 |
| Armazenamento do projeto | Estender | O vídeo convertido deve ser guardado como nova versão do conteúdo sem tela de alteração do original. | REQ-VID-CONV-004, REQ-VID-CONV-005 |
| Sistema de perfis e quotas | Alterar | As limitações de formato e resolução por perfil devem ser verificadas antes de iniciar a transcodificação. | REQ-VID-CONV-002 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1–5 | Seleção do vídeo, definição das opções e validação inicial | REQ-VID-CONV-001, REQ-VID-CONV-002 |
| Passos 6–8 | Configuração final, criação do job e publicação na fila | REQ-VID-CONV-003 |
| Passos 8–10 | Execução da transcodificação, progresso e disponibilização do resultado | REQ-VID-CONV-004, REQ-VID-CONV-005 |

