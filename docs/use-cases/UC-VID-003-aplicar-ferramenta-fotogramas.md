# UC-VID-003 — Aplicar Ferramenta Existente a Todos os Fotogramas de um Vídeo

---

## 0. Identificação

| **Campo**               | **Valor**                                                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Grupo / Equipa**      | Grupo 5 - PL3                                                                                                           |
| **Autores**             | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [número mecanográfico por confirmar] |
| **Data**                | 2026-10-14                                                                                                              |
| **Versão do documento** | v1.0                                                                                                                    |
| **Unidade Curricular**  | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho                                                      |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo**                                | **Valor**                                                                                                                                    |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Funcionalidade**                       | Aplicar ferramenta existente a todos os fotogramas de um vídeo                                                                               |
| **Perfil(s) de utilizador abrangido(s)** | Registado / premium — utilizadores anónimos não têm acesso a esta funcionalidade, porque implica processamento intensivo e consumo de quota. |

**Justificação no contexto do MVP** _(2–3 linhas)_

Esta funcionalidade valida a extensão do conjunto de ferramentas de imagem para o domínio do vídeo sem desenvolver uma nova implementação por ferramenta. Permite reutilizar serviços existentes, reduzir o esforço de desenvolvimento e demonstrar que o pipeline de processamento assíncrono funciona em escala. Sem esta funcionalidade, o suporte a vídeo ficaria limitado a upload, visualização e operações mais simples.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                                                                                                     |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-003                                                                                                                                                                                                                                                                                                                                                                       |
| **Nome**                      | Aplicar ferramenta existente a todos os fotogramas de um vídeo                                                                                                                                                                                                                                                                                                                   |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                                                                                                             |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel                                                                                                                                                                                                                                                                                               |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                                                                                                       |
| **Objetivo**                  | Permitir ao utilizador aplicar uma ferramenta de processamento de imagem a todos os fotogramas de um vídeo e obter um vídeo final processado.                                                                                                                                                                                                                                    |
| **Âmbito**                    | Módulo de vídeo do PictuRAS, decomposição em fotogramas, processamento por ferramenta e recomposição do vídeo                                                                                                                                                                                                                                                                    |
| **Ator Principal**            | Utilizador registado ou premium                                                                                                                                                                                                                                                                                                                                                  |
| **Stakeholders e Interesses** | - **Utilizador**: pretende aplicar efeitos ou correções a um vídeo sem processar cada fotograma manualmente<br>- **Proprietário do Sistema**: deseja maximizar o valor das ferramentas existentes e validar a extensão do pipeline de processamento para vídeo<br>- **Equipa de Desenvolvimento**: valida a integração com ferramentas de imagem, filas e armazenamento em vídeo |
| **Pré-condições**             | - O utilizador tem sessão iniciada com um perfil registado ou premium<br>- O vídeo está associado a um projeto válido e acessível no armazenamento<br>- Existe pelo menos uma ferramenta disponível para processamento de imagem<br>- O vídeo está dentro dos limites de duração e quota do perfil                                                                               |
| **Trigger**                   | O utilizador seleciona um vídeo e escolhe a opção de aplicar uma ferramenta a todos os fotogramas.                                                                                                                                                                                                                                                                               |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                                     | **Resposta do Sistema**                                                                                                                                |
| --------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1         | O utilizador abre um projeto com vídeos disponíveis.                                 | O sistema apresenta a biblioteca de vídeos e a opção de processamento por fotogramas.                                                                  |
| 2         | O utilizador seleciona um vídeo e escolhe a opção "Aplicar Ferramenta a Fotogramas". | —                                                                                                                                                      |
| 3         | —                                                                                    | O sistema valida o perfil do utilizador, a presença do vídeo e a quota disponível. Apresenta as ferramentas disponíveis e os parâmetros configuráveis. |
| 4         | O utilizador seleciona a ferramenta e define os parâmetros.                          | —                                                                                                                                                      |
| 5         | —                                                                                    | O sistema apresenta as opções de intervalo temporal e a taxa de fotogramas de saída.                                                                   |
| 6         | O utilizador confirma o intervalo e a configuração.                                  | —                                                                                                                                                      |
| 7         | O utilizador confirma a execução.                                                    | —                                                                                                                                                      |
| 8         | —                                                                                    | O sistema valida o vídeo de origem, os parâmetros e a disponibilidade de armazenamento antes de iniciar o processamento.                               |
| 9         | —                                                                                    | O sistema cria um operação de processamento e inicia a extração dos fotogramas para armazenamento temporário.                                               |
| 10        | —                                                                                    | O sistema processa cada fotograma individualmente com a ferramenta selecionada e atualiza o progresso em tempo real.                                   |
| 11        | —                                                                                    | O sistema recompõe o vídeo resultante, preservando a faixa de áudio original e armazena o ficheiro no projeto do utilizador.                           |
| 12        | O utilizador visualiza o resultado.                                                  | O sistema disponibiliza o vídeo processado para pré-visualização e transferência.                                                                      |

### 2.3 Fluxos Alternativos

| **Fluxo**                           | **Descrição**                                                                                                                                                         |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Encadeamento de ferramentas   | Se o utilizador selecionar mais do que uma ferramenta em sequência, o sistema aplica cada transformação por ordem ao mesmo fotograma antes de recompor o vídeo final. |
| FA2 – Reprocessamento de fotograma  | Se um fotograma falhar, o sistema tenta processá-lo novamente. Se a falha persistir, o operação termina como falhado, elimina o resultado parcial e informa o utilizador.  |
| FA3 – Cancelamento do processamento | Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe os fotogramas pendentes, limpa ficheiros temporários e marca o operação como cancelado.    |

### 2.4 Exceções

| **Condição**                                       | **Comportamento do Sistema**                                                                                                                          |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Vídeo com codec não suportado                      | O sistema rejeita a operação e informa que o formato ou codec do vídeo não é compatível com a extração por fotogramas.                                |
| Ferramenta incompatível com fotogramas             | Se a ferramenta selecionada gere metadados em vez de imagem, o sistema informa o utilizador e solicita confirmação antes de continuar.             |
| Quota esgotada                                     | O sistema bloqueia a operação e indica que a quota do perfil já foi usada.                                                                            |
| Falha persistente no processamento de um fotograma | O sistema marca o operação como falhado, elimina os fotogramas/resultados temporários, mantém o vídeo original intacto e devolve qualquer quota reservada. |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                             |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O vídeo processado fica armazenado no projeto, mantém a faixa de áudio original e permanece disponível para visualização e transferência. |
| Garantia Mínima     | O vídeo original continua inalterado, os ficheiros temporários são eliminados e o sistema regista a operação com o estado final adequado. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                                                                                         |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RN1    | Utilizadores anónimos não têm acesso a esta funcionalidade.                                                                                                       |
| RN2    | Cada operação de aplicação de ferramenta conta como uma operação avançada, independentemente do número de fotogramas processados; utilizadores premium não têm limite diário. |
| RN3    | O vídeo deve respeitar os limites do perfil: 5 minutos e 1920×1080 para registados; 30 minutos e 3840×2160 para premium.                                               |
| RN4    | O vídeo resultante mantém a faixa de áudio original e a resolução do vídeo de origem.                                                                             |
| RN5    | As ferramentas de IA só podem ser aplicadas a intervalos limitados e não ao vídeo completo, salvo decisão posterior documentada.                                  |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                                              |
| ------ | ------------------------------------------------------------------------------------------------------------------------- |
| A1     | O sistema já possui microserviços de processamento de imagem que aceitam um fotograma isolado como entrada.               |
| A2     | A infraestrutura de filas e armazenamento suporta a criação temporária de milhares de fotogramas durante o processamento. |
| A3     | O FFmpeg ou equivalente está disponível para a decomposição e recomposição do vídeo.                                      |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                                        |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| Q1     | O sistema deve permitir que o utilizador escolha um intervalo temporal específico para reduzir o número de fotogramas processados? |
| Q2     | Qual deve ser o comportamento quando uma ferramenta de IA gera metadados em vez de imagem?                                         |
| Q3     | Deve existir um limite de paralelismo para o processamento dos fotogramas de um vídeo em função do perfil do utilizador?           |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                        | **Validação realizada pela equipa**                                                                |
| ------------------------ | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso, fluxos alternativos e regras de negócio | Revisão manual pela equipa; ajuste dos limites e clarificação dos cenários de falha e cancelamento |

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
| REQ-VID-FRM-001 | O sistema deve permitir selecionar uma ferramenta de imagem existente e parâmetros compatíveis para aplicação aos fotogramas de um vídeo. | F | Deve ter | ALT | Passos 3-4 | Apresentar apenas ferramentas suportadas e validar parâmetros. |
| REQ-VID-FRM-002 | O sistema deve extrair, processar e recompor os fotogramas no intervalo e à taxa definidos pelo utilizador. | F | Deve ter | NOVO | Passos 5, 9-11 | Verificar intervalo, número de fotogramas e resultado. |
| REQ-VID-FRM-003 | O sistema deve preservar a faixa de áudio e a resolução quando a ferramenta não exigir alteração. | F | Deve ter | NOVO | RN4 | Comparar metadados de origem e resultado. |
| REQ-VID-FRM-004 | O sistema deve aplicar ferramentas compatíveis pela ordem selecionada quando o encadeamento for solicitado. | F | Deveria ter | ALT | FA1 | Submeter duas ferramentas e verificar a ordem. |
| REQ-VID-FRM-005 | O sistema deve repetir uma vez o processamento de um fotograma que falhe e terminar o operação como falhado se a falha persistir. | F | Deve ter | NOVO | FA2, exceção | Injetar uma falha repetida e verificar limpeza. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Microserviços de ferramentas de imagem | Estender | Reutilizar workers existentes para receber fotogramas, sem alterar o contrato de imagem isolado. | FRM-001, FRM-002, FRM-004 |
| RabbitMQ e Projects Service | Estender | Orquestrar decomposição, processamento, recomposição e estado do operação. | FRM-002, FRM-005 |
| Armazenamento S3 e diretório temporário | Estender | Isolar fotogramas temporários e guardar apenas o resultado final. | FRM-002, FRM-005 |
| FFmpeg/FFprobe | Novo | Decompor e recompor o vídeo, preservando streams não afetadas. | FRM-002, FRM-003 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 3-8 | Selecionar ferramenta, parâmetros e validar | REQ-VID-FRM-001, REQ-VID-FRM-002 |
| Passos 9-12 | Processar fotogramas e gerar resultado | REQ-VID-FRM-002, REQ-VID-FRM-003 |
| FA1 | Encadear ferramentas | REQ-VID-FRM-004 |
| FA2-FA3 e exceções | Repetir, cancelar e limpar | REQ-VID-FRM-005 |
