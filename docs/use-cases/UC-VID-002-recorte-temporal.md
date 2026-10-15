# UC-VID-002 — Recorte Temporal de Vídeo (Trim)

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

| **Campo**                                | **Valor**                                                                                  |
| ---------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Funcionalidade**                       | Recorte temporal de vídeo (_trim_)                                                         |
| **Perfil(s) de utilizador abrangido(s)** | Registado e premium — utilizadores anónimos não têm acesso a esta funcionalidade avançada. |

**Justificação no contexto do MVP** _(2–3 linhas)_
O recorte temporal é uma operação central de edição de vídeo e permite transformar um vídeo longo num segmento útil, sem necessidade de ferramenta especializada. Esta funcionalidade valida o pipeline de processamento assíncrono, a gestão de jobs e a comunicação em tempo real com o cliente. Sem ela, o suporte a vídeo ficaria limitado à simples submissão e visualização, sem edição funcional.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **ID do Caso de Uso**         | UC-VID-002                                                                                                                                                                                                                                                                                       |
| **Nome**                      | Recorte Temporal de Vídeo (Trim)                                                                                                                                                                                                                                                                 |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                             |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel                                                                                                                                                                                                               |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                       |
| **Objetivo**                  | Permitir ao utilizador selecionar um intervalo temporal de um vídeo e gerar um novo ficheiro com apenas esse segmento.                                                                                                                                                                           |
| **Âmbito**                    | Módulo de processamento de vídeo do PictuRAS                                                                                                                                                                                                                                                     |
| **Ator Principal**            | Utilizador registado ou premium                                                                                                                                                                                                                                                                  |
| **Stakeholders e Interesses** | - **Utilizador**: pretende cortar um vídeo para manter apenas o trecho relevante.<br>- **Proprietário do Sistema**: pretende validar a funcionalidade de edição de vídeo e o controlo de quotas.<br>- **Equipa de Desenvolvimento**: valida a integração com FFmpeg, filas RabbitMQ e WebSocket. |
| **Pré-condições**             | - O utilizador está autenticado com perfil registado ou premium.<br>- O vídeo existe no projeto e está armazenado e acessível.<br>- O vídeo tem formato e codec suportados pelo sistema.<br>- O utilizador registado tem quota de operações avançadas disponível. |
| **Trigger**                   | O utilizador seleciona um vídeo e escolhe a opção de recorte temporal.                                                                                                                                                                                                                           |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                            | **Resposta do Sistema**                                                                           |
| --------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 1         | O utilizador abre a biblioteca de vídeos do projeto.                        | O sistema apresenta os vídeos disponíveis com metadados e miniaturas.                             |
| 2         | O utilizador seleciona um vídeo e escolhe a ferramenta de recorte temporal. | —                                                                                                 |
| 3         | —                                                                           | O sistema carrega a pré-visualização do vídeo e apresenta controles para selecionar início e fim. |
| 4         | O utilizador define o início e o fim do segmento.                           | O sistema valida que os valores são coerentes e pertencem à duração do vídeo.                     |
| 5         | O utilizador confirma a operação.                                           | O sistema valida quota, parâmetros e estado do ficheiro.                                          |
| 6         | —                                                                           | O sistema cria um job de processamento e publica a tarefa na fila dedicada.                       |
| 7         | —                                                                           | O sistema informa o utilizador que o processo está em fila e em curso.                            |
| 8         | —                                                                           | O microsserviço de trim processa o vídeo com FFmpeg e comunica o progresso.                       |
| 9         | O utilizador acompanha o progresso.                                         | O sistema atualiza a barra de progresso via WebSocket.                                            |
| 10        | —                                                                           | O sistema armazena o vídeo resultante no armazenamento do projeto.                                |
| 11        | —                                                                           | O sistema atualiza o estado do job para concluído e informa o utilizador.                         |

### 2.3 Fluxos Alternativos

| **Fluxo**                                 | **Descrição**                                                                                                                                         |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Cancelamento do processamento       | Durante a execução, o utilizador pode cancelar a operação. O sistema interrompe o processo, limpa ficheiros temporários e não contabiliza a operação. |
| FA2 – Cancelamento antes do processamento | Se o utilizador cancelar enquanto o job ainda está em fila, o sistema cancela o job sem criar resultado nem consumir quota.                           |
| FA4 – Pré-visualização antes de confirmar | O utilizador ajusta os marcadores enquanto observa o vídeo e só depois confirma o recorte final.                                                      |

### 2.4 Exceções

| **Condição**                                    | **Comportamento do Sistema**                                                         |
| ----------------------------------------------- | ------------------------------------------------------------------------------------ |
| Intervalo temporal inválido                     | O sistema rejeita a operação e pede ao utilizador para corrigir os tempos.           |
| Tempo inicial ou final fora da duração do vídeo | O sistema apresenta mensagem de erro e mantém o vídeo original inalterado.           |
| Segmento com duração inferior a 1 segundo       | O sistema não inicia o processamento e solicita um intervalo válido.                 |
| Formato ou codec não suportado                  | O sistema rejeita o vídeo e informa que o ficheiro não pode ser processado por trim. |
| Falha no FFmpeg durante o processamento         | O sistema marca o job como falhado, limpa temporários e não consome quota.           |
| Quota de operações avançadas excedida            | O sistema bloqueia a operação e informa o utilizador sobre o limite do seu perfil.   |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                        |
| ------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O vídeo recortado é armazenado no projeto e o vídeo original permanece intacto.                                      |
| Garantia Mínima     | Nenhuma alteração é aplicada ao vídeo original, o job fica em estado falhado ou cancelado e a quota não é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                                                                                     |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RN1    | A duração mínima do segmento recortado é de 1 segundo.                                                                                                        |
| RN2    | O vídeo original não pode ser alterado nem eliminado como resultado do recorte.                                                                               |
| RN3    | Cada job de recorte aceite conta como uma operação avançada para o utilizador registado; utilizadores premium não têm limite diário.                           |
| RN4    | Utilizadores anónimos não têm acesso à funcionalidade de recorte temporal.                                                                                    |
| RN5    | O vídeo recortado mantém a faixa de áudio do segmento correspondente.                                                                                         |
| RN6    | O processamento é assíncrono e exige o registo do job na base de dados.                                                                                       |
| RN7    | Em caso de falha ou cancelamento, o resultado parcial é eliminado, o vídeo original permanece intacto e qualquer quota reservada é devolvida.                 |

### 2.7 Assunções

| **ID** | **Assunção**                                                                               |
| ------ | ------------------------------------------------------------------------------------------ |
| A1     | O FFmpeg está disponível para executar o recorte no servidor.                              |
| A2     | O WebSocket mantém a conexão durante o processamento do vídeo.                             |
| A3     | O SeaweedFS suporta o armazenamento do vídeo resultante sem corromper o ficheiro original. |
| A4     | O projeto já contém vídeos válidos e acessíveis.                                           |
| A5     | A fila RabbitMQ consegue processar jobs de recorte sem perda relevante.                    |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                 |
| ------ | ------------------------------------------------------------------------------------------- |
| Q1     | O sistema deve permitir que o utilizador escolha um formato de saída diferente do original? |
| Q2     | Deve existir um limite máximo de duração por segmento no MVP?                               |
| Q3     | O vídeo recortado deve substituir o original ou criar um novo ficheiro no projeto?          |
| Q4     | O sistema deve permitir a retoma de um recorte cancelado?                                   |
| Q5     | O utilizador deve conseguir visualizar o recorte antes de confirmar a operação?             |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                        | **Validação realizada pela equipa**                          |
| ------------------------ | ------------------------------------------------------------------------- | ------------------------------------------------------------ |
| GitHub Copilot           | Estrutura inicial do caso de uso, fluxos alternativos e regras de negócio | Revisão manual pela equipa e ajuste ao template do exercício |

---

## ✅ Lista de verificação antes de entregar (Exercício 1)

- [x] Secções 0 a 3 preenchidas e texto de ajuda (`>` e `{…}`) removido.
- [x] Funcionalidade de vídeo escolhida **e justificada** no contexto do MVP.
- [x] Ator principal identificado, com o respetivo perfil.
- [x] Caso de uso com fluxo principal, **≥1 fluxo alternativo** e **≥1 exceção específica de vídeo**.
- [x] Pós-condições com garantia de sucesso **e** garantia mínima.
- [x] Regras de negócio e restrições preenchidas.
- [x] Assunções e questões em aberto registadas.
- [x] Utilização de agentes de IA documentada.

---

---
