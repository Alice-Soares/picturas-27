# UC-VID-007 — Gerir Áudio do Vídeo (Remover, Substituir ou Extrair)

---

## 0. Identificação

| **Campo**               | **Valor**                                                                         |
| ----------------------- | --------------------------------------------------------------------------------- |
| **Grupo / Equipa**      | Grupo 5 - PL3                                                                     |
| **Autores**             | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel |
| **Data**                | 2026-10-14                                                                        |
| **Versão do documento** | v1.0                                                                              |
| **Unidade Curricular**  | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho                |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo**                                | **Valor**                                                                         |
| ---------------------------------------- | --------------------------------------------------------------------------------- |
| **Funcionalidade**                       | Gerir áudio do vídeo (remover faixa sonora, silenciar, ou extrair áudio)          |
| **Perfil(s) de utilizador abrangido(s)** | Registado e Premium — utilizadores anónimos não têm acesso a esta funcionalidade. |

**Justificação no contexto do MVP**
Permite manipular a faixa de áudio de um vídeo (seja para o silenciar por completo antes de aplicar filtros visuais, seja para extrair a banda sonora em formato `.mp3`/`.aac` para análise ou reutilização). Valida a capacidade de processamento seletivo de _streams_ multimédia (separação de fluxos de vídeo e áudio) no motor backend.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-007                                                                                                                                                                                                                                                                                                                                |
| **Nome**                      | Gerir Áudio do Vídeo                                                                                                                                                                                                                                                                                                                      |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                                                                      |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel                                                                                                                                                                                                                                                         |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                                                                |
| **Objetivo**                  | Permitir ao utilizador remover o áudio de um vídeo (torná-lo silencioso) ou extrair a faixa sonora como um ficheiro de áudio independente.                                                                                                                                                                                                |
| **Âmbito**                    | Módulo de processamento de vídeo e gestão de conteúdos do PictuRAS                                                                                                                                                                                                                                                                        |
| **Ator Principal**            | Utilizador Registado ou Premium                                                                                                                                                                                                                                                                                                           |
| **Stakeholders e Interesses** | - **Utilizador**: pretende isolar o áudio ou criar um vídeo sem som para fins de edição.<br>- **Proprietário do Sistema**: garantir controlo de quotas e armazenamento adequado para ficheiros de áudio gerados.<br>- **Equipa de Desenvolvimento**: validar a manipulação isolada de streams de áudio através de ferramentas de backend. |
| **Pré-condições**             | - O utilizador tem sessão iniciada com perfil registado ou premium.<br>- O vídeo selecionado está disponível no projeto e contém uma faixa de áudio válida.<br>- O utilizador tem quota diária disponível.                                                                                                                                |
| **Trigger**                   | O utilizador seleciona um vídeo na biblioteca e escolhe a opção "Gerir Áudio" (Remover ou Extrair).                                                                                                                                                                                                                                       |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                        | **Resposta do Sistema**                                                                                                          |
| --------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 1         | O utilizador seleciona um vídeo na biblioteca e clica em "Gerir Áudio". | O sistema apresenta as opções disponíveis: **Remover Áudio (Silenciar)** ou **Extrair Faixa de Áudio**.                          |
| 2         | O utilizador escolhe a operação desejada e confirma.                    | O sistema valida o perfil, a quota diária e a existência de áudio no ficheiro de origem.                                         |
| 3         | —                                                                       | O sistema cria um job de processamento de áudio e coloca-o na fila (RabbitMQ).                                                   |
| 4         | —                                                                       | O sistema notifica o utilizador que o processamento está em curso.                                                               |
| 5         | O utilizador acompanha o estado.                                        | O sistema atualiza o progresso em tempo real via WebSocket.                                                                      |
| 6         | —                                                                       | O worker (FFmpeg) processa o ficheiro: remove o stream `-an` (se silenciar) ou exporta o stream `-vn -acodec copy` (se extrair). |
| 7         | —                                                                       | O sistema guarda o novo ficheiro (novo vídeo sem som ou novo ficheiro `.mp3`/`.aac`) no armazenamento do projeto.                |
| 8         | —                                                                       | O sistema regista o novo item na base de dados, associa-o ao projeto e desconta 1 operação na quota.                             |
| 9         | —                                                                       | O sistema notifica a conclusão com sucesso e disponibiliza o novo ficheiro na biblioteca do projeto.                             |

### 2.3 Fluxos Alternativos

| **Fluxo**                             | **Descrição**                                                                                                                                                                      |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Vídeo sem faixa sonora original | Se o utilizador tentar extrair áudio de um vídeo que não possui som, o sistema avisa imediatamente que o ficheiro de origem não tem stream de áudio, abortando sem consumir quota. |
| FA2 – Cancelamento pelo utilizador    | Durante a execução, o utilizador pode cancelar o job: o worker interrompe o processo, limpa temporários, repõe o estado como cancelado e não desconta quota.                       |

### 2.4 Exceções

| **Condição**                                 | **Comportamento do Sistema**                                                                        |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Quota diária esgotada                        | O sistema impede a submissão do job e indica o estado atual da quota.                               |
| Erro técnico no processamento (FFmpeg crash) | O sistema interceta o erro, marca o job como falhado, elimina ficheiros parciais e liberta a quota. |
| Ficheiro corrompido                          | O sistema aborta a operação, marca como falhado e apresenta mensagem explicativa.                   |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                            |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O novo ficheiro (vídeo silenciado ou áudio extraído) está guardado na biblioteca; o vídeo original permanece intacto.                    |
| Garantia Mínima     | O vídeo original permanece inalterado, os temporários são limpos, o job fica marcado como falhado/cancelado e nenhuma quota é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                            |
| ------ | ------------------------------------------------------------------------------------ |
| RN1    | Utilizadores anónimos não têm acesso a esta funcionalidade.                          |
| RN2    | Cada operação de gestão de áudio concluída desconta 1 operação da quota diária.      |
| RN3    | O vídeo original nunca é substituído pelo resultado da remoção ou extração de áudio. |
| RN4    | Jobs cancelados ou falhados não consomem quota.                                      |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                       |
| ------ | -------------------------------------------------------------------------------------------------- |
| A1     | O FFprobe consegue detetar previamente se o vídeo contém streams de áudio ativos.                  |
| A2     | O SeaweedFS suporta o armazenamento de ficheiros de áudio e novos vídeos em simultâneo no projeto. |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                            |
| ------ | ---------------------------------------------------------------------------------------------------------------------- |
| Q1     | Deve ser permitido substituir a faixa de áudio de um vídeo por um ficheiro de música carregado pelo utilizador no MVP? |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                   | **Validação realizada pela equipa**                         |
| ------------------------ | ---------------------------------------------------- | ----------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso e regras de negócio | Revisão manual pela equipa e validação com o pipeline geral |

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

| **ID**          | **Requisito**                                                                                                                 | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem**                            | **Como verificar**                                                                      |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------- | -------------- | ------------ | ------------------------------------- | --------------------------------------------------------------------------------------- |
| REQ-VID-AUD-001 | O sistema deve detetar se o vídeo possui streams de áudio e disponibilizar as opções de silenciar ou extrair áudio.           | F        | Deve ter       | Novo         | UC-VID-007, passos 1–2                | Verificar se a UI restringe opções caso o vídeo não tenha som.                          |
| REQ-VID-AUD-002 | O sistema deve validar o perfil do utilizador, a quota e a integridade do ficheiro antes de submeter o job para a fila.       | F        | Deve ter       | Novo         | UC-VID-007, passos 2–3                | Confirmar bloqueio para anónimos ou quota esgotada.                                     |
| REQ-VID-AUD-003 | O motor de processamento deve executar a remoção ou extração do stream de áudio de forma assíncrona com reporte de progresso. | F        | Deve ter       | Novo         | UC-VID-007, passos 4–6                | Monitorizar o worker FFmpeg e a atualização via WebSocket.                              |
| REQ-VID-AUD-004 | O sistema deve armazenar o novo resultado (vídeo sem som ou áudio extraído) no projeto, preservando o original.               | F        | Deve ter       | Novo         | UC-VID-007, passos 7–9; pós-condições | Verificar que o ficheiro resultante aparece na biblioteca e o original fica inalterado. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado**     | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto**                                                                           | **Requisitos relacionados** |
| ---------------------------------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------- | --------------------------- |
| Interface do Utilizador (Frontend) | Estender                                  | Adicionar controlos de áudio no leitor e painel de ações de vídeo.                                 | REQ-VID-AUD-001             |
| Fila RabbitMQ / Workers            | Estender                                  | Criar handlers para manipulação de streams de áudio via FFmpeg (`-an` / `-vn`).                    | REQ-VID-AUD-003             |
| Armazenamento e Base de Dados      | Estender                                  | Suportar o registo e armazenamento de novos tipos de ficheiros (ex: `.mp3`) associados ao projeto. | REQ-VID-AUD-004             |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada**                            | **Requisito(s) de Sistema**      |
| --------------------------- | -------------------------------------------------- | -------------------------------- |
| Passos 1–2                  | Seleção da operação e validação de áudio           | REQ-VID-AUD-001, REQ-VID-AUD-002 |
| Passos 3–6                  | Enfileiramento e processamento assíncrono (FFmpeg) | REQ-VID-AUD-003                  |
| Passos 7–9                  | Gravação do resultado e preservação do original    | REQ-VID-AUD-004                  |
