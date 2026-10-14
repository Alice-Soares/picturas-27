# UC-VID-003 — Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo

---

## 0. Identificação

| **Campo** | **Valor** |
|-----------|-----------|
| **Grupo / Equipa** | Grupo 5 - PL3 |
| **Autores** | Equipa do Grupo 27 |
| **Data** | 2026-10-14 |
| **Versão do documento** | v1.0 |
| **Unidade Curricular** | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo** | **Valor** |
|-----------|-----------|
| **Funcionalidade** | Aplicar ferramenta existente a todos os fotogramas de um vídeo |
| **Perfil(s) de utilizador abrangido(s)** | Registado / premium — utilizadores anónimos não têm acesso a esta funcionalidade, porque implica processamento intensivo e consumo de quota. |

**Justificação no contexto do MVP** *(2–3 linhas)*

Esta funcionalidade valida a extensão do conjunto de ferramentas de imagem para o domínio do vídeo sem desenvolver uma nova implementação por ferramenta. Permite reutilizar serviços existentes, reduzir o esforço de desenvolvimento e demonstrar que o pipeline de processamento assíncrono funciona em escala. Sem esta funcionalidade, o suporte a vídeo ficaria limitado a upload, visualização e operações mais simples.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção** | **Detalhes** |
|------------|--------------|
| **ID do Caso de Uso** | UC-VID-003 |
| **Nome** | Aplicar ferramenta existente a todos os fotogramas de um vídeo |
| **Versão** | v1.0 |
| **Autor** | Equipa Grupo 27 |
| **Data** | 2026-10-14 |
| **Objetivo** | Permitir ao utilizador aplicar uma ferramenta de processamento de imagem a todos os fotogramas de um vídeo e obter um vídeo final processado. |
| **Âmbito** | Módulo de vídeo do PictuRAS, decomposição em fotogramas, processamento por ferramenta e recomposição do vídeo |
| **Ator Principal** | Utilizador registado ou premium |
| **Stakeholders e Interesses** | - **Utilizador**: pretende aplicar efeitos ou correções a um vídeo sem processar cada fotograma manualmente<br>- **Proprietário do Sistema**: deseja maximizar o valor das ferramentas existentes e validar a extensão do pipeline de processamento para vídeo<br>- **Equipa de Desenvolvimento**: valida a integração com ferramentas de imagem, filas e armazenamento em vídeo |
| **Pré-condições** | - O utilizador tem sessão iniciada com um perfil registado ou premium<br>- O vídeo está associado a um projeto válido e acessível no armazenamento<br>- Existe pelo menos uma ferramenta disponível para processamento de imagem<br>- O vídeo está dentro dos limites de duração e quota do perfil |
| **Trigger** | O utilizador seleciona um vídeo e escolhe a opção de aplicar uma ferramenta a todos os fotogramas. |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator** | **Resposta do Sistema** |
|-----------|------------------|-------------------------|
| 1 | O utilizador abre um projeto com vídeos disponíveis. | O sistema apresenta a biblioteca de vídeos e a opção de processamento por fotogramas. |
| 2 | O utilizador seleciona um vídeo e escolhe a opção "Aplicar Ferramenta a Fotogramas". | — |
| 3 | — | O sistema valida o perfil do utilizador, a presença do vídeo e a quota disponível. Apresenta as ferramentas disponíveis e os parâmetros configuráveis. |
| 4 | O utilizador seleciona a ferramenta e define os parâmetros. | — |
| 5 | — | O sistema apresenta as opções de intervalo temporal e a taxa de fotogramas de saída. |
| 6 | O utilizador confirma o intervalo e a configuração. | — |
| 7 | O utilizador confirma a execução. | — |
| 8 | — | O sistema valida o vídeo de origem, os parâmetros e a disponibilidade de armazenamento antes de iniciar o processamento. |
| 9 | — | O sistema cria um job de processamento e inicia a extração dos fotogramas para armazenamento temporário. |
| 10 | — | O sistema processa cada fotograma individualmente com a ferramenta selecionada e atualiza o progresso em tempo real. |
| 11 | — | O sistema recompõe o vídeo resultante, preservando a faixa de áudio original e armazena o ficheiro no projeto do utilizador. |
| 12 | O utilizador visualiza o resultado. | O sistema disponibiliza o vídeo processado para pré-visualização e transferência. |

### 2.3 Fluxos Alternativos

| **Fluxo** | **Descrição** |
|-----------|---------------|
| FA1 – Encadeamento de ferramentas | Se o utilizador selecionar mais do que uma ferramenta em sequência, o sistema aplica cada transformação por ordem ao mesmo fotograma antes de recompor o vídeo final. |
| FA2 – Falha parcial de fotogramas | Se um ou mais fotogramas falharem durante o processamento, o sistema regista a falha, repete a operação e, se não for resolvida, substitui o fotograma pelo original mantendo o vídeo em execução. |
| FA3 – Cancelamento do processamento | Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe os fotogramas pendentes, limpa ficheiros temporários e marca o job como cancelado. |

### 2.4 Exceções

| **Condição** | **Comportamento do Sistema** |
|--------------|------------------------------|
| Vídeo com codec não suportado | O sistema rejeita a operação e informa que o formato ou codec do vídeo não é compatível com a extração por fotogramas. |
| Ferramenta incompatível com fotogramas | Se a ferramenta selecionada gere metadados em vez de imagem, o sistema informa o utilizador e solicita confirmação antes de continuar. |
| Quota esgotada | O sistema bloqueia a operação e indica que a quota do perfil já foi usada. |
| Falha no processamento de um fotograma | O sistema tenta repetir a operação e, se falhar novamente, continua com o fotograma original e marca o resultado como concluído com avisos. |

### 2.5 Pós-condições

| **Tipo** | **Resultado** |
|----------|---------------|
| Garantia de Sucesso | O vídeo processado fica armazenado no projeto, mantém a faixa de áudio original e permanece disponível para visualização e transferência. |
| Garantia Mínima | O vídeo original continua inalterado, os ficheiros temporários são eliminados e o sistema regista a operação com o estado final adequado. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra** |
|--------|-----------|
| RN1 | Utilizadores anónimos não têm acesso a esta funcionalidade. |
| RN2 | A aplicação de uma ferramenta a todos os fotogramas conta como uma operação avançada de quota. |
| RN3 | O vídeo submetido deve respeitar os limites de duração do perfil do utilizador. |
| RN4 | O vídeo resultante mantém a faixa de áudio original e a resolução do vídeo de origem. |
| RN5 | As ferramentas de IA só podem ser aplicadas a intervalos limitados e não ao vídeo completo. |

### 2.7 Assunções

| **ID** | **Assunção** |
|--------|--------------|
| A1 | O sistema já possui microserviços de processamento de imagem que aceitam um fotograma isolado como entrada. |
| A2 | A infraestrutura de filas e armazenamento suporta a criação temporária de milhares de fotogramas durante o processamento. |
| A3 | O FFmpeg ou equivalente está disponível para a decomposição e recomposição do vídeo. |

### 2.8 Questões em Aberto

| **ID** | **Questão** |
|--------|-------------|
| Q1 | O sistema deve permitir que o utilizador escolha um intervalo temporal específico para reduzir o número de fotogramas processados? |
| Q2 | Qual deve ser o comportamento quando uma ferramenta de IA gera metadados em vez de imagem? |
| Q3 | Deve existir um limite de paralelismo para o processamento dos fotogramas de um vídeo em função do perfil do utilizador? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / *skill*** | **Tarefa apoiada** | **Validação realizada pela equipa** |
|--------------------------|--------------------|--------------------------------------|
| GitHub Copilot | Estrutura inicial do caso de uso, fluxos alternativos e regras de negócio | Revisão manual pela equipa; ajuste dos limites e clarificação dos cenários de falha e cancelamento |

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
| REQ-VID-FILT-001 | O sistema deve apresentar as ferramentas disponíveis e os parâmetros configuráveis antes da execução do processamento em lote. | F | Deve ter | Novo | UC-VID-003, passos 1–5 | Verificar que a UI mostra as ferramentas aceites e os campos de configuração do efeito. |
| REQ-VID-FILT-002 | O sistema deve validar o perfil do utilizador, a compatibilidade da ferramenta, a quota disponível e a integridade do vídeo antes de iniciar o job. | F | Deve ter | Novo | UC-VID-003, passos 3–8; RN1–RN5 | Confirmar que operação inválida é bloqueada antes do processamento e que o vídeo original permanece intacto. |
| REQ-VID-FILT-003 | O sistema deve decompor o vídeo em fotogramas, criar os ficheiros temporários e iniciar um job para processamento por lotes. | F | Deve ter | Novo | UC-VID-003, passos 8–10 | Validar que são criados os ficheiros de trabalho e o job de processamento é registado e executado. |
| REQ-VID-FILT-004 | O sistema deve aplicar a ferramenta selecionada a cada fotograma, manter o progresso atualizado e tratar falhas parciais sem interromper o vídeo final. | F | Deve ter | Novo | UC-VID-003, passos 10–11; FA2 | Confirmar que o sistema reporta progresso, repete falhas e continua com o fotograma original quando necessário. |
| REQ-VID-FILT-005 | O sistema deve recompôr o vídeo processado, preservar a faixa de áudio original e disponibilizar o resultado no projeto do utilizador. | F | Deve ter | Novo | UC-VID-003, passos 11–12; pós-condições | Verificar que o vídeo resultante aparece na biblioteca e que o vídeo original permanece inalterado. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Ferramentas de imagem e IA | Estender | As ferramentas existentes precisam de aceitar fotogramas isolados e devolver imagens processadas em sequência. | REQ-VID-FILT-001, REQ-VID-FILT-004 |
| Pipeline de processamento em lote | Estender | A decomposição do vídeo em fotogramas exige um fluxo de jobs temporários e recomposição final do vídeo. | REQ-VID-FILT-003, REQ-VID-FILT-005 |
| Armazenamento temporário e projeto | Estender | É necessário gerir imagens temporárias, versões finais e a organização por projeto e por operação. | REQ-VID-FILT-003, REQ-VID-FILT-005 |
| WebSocket e frontend | Estender | A interface deve informar o estado do processamento por fotograma e disponibilizar o resultado final. | REQ-VID-FILT-001, REQ-VID-FILT-004 |
| Sistema de perfis e quotas | Alterar | A execução deste caso de uso depende de validações de perfil, quota e limite de processamento por operação. | REQ-VID-FILT-002 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1–5 | Seleção da ferramenta, parâmetros e validação inicial | REQ-VID-FILT-001, REQ-VID-FILT-002 |
| Passos 8–10 | Extração dos fotogramas e processamento em lote | REQ-VID-FILT-003, REQ-VID-FILT-004 |
| Passos 11–12 | Recomposição do vídeo e disponibilização do resultado | REQ-VID-FILT-005 |
