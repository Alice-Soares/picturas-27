# UC-VID-007 — Gerir Áudio do Vídeo (Remover, Substituir ou Extrair)

> **Estado de implementação:** Implementado no MVP. Inclui remoção, substituição e extração autenticada de áudio, com suporte a projetos próprios e projetos partilhados com permissão de edição.

---

## 0. Identificação

| **Campo**               | **Valor**                                                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Grupo / Equipa**      | Grupo 5 - PL3                                                                                                           |
| **Autores**             | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [pg65411] |
| **Data**                | 2026-10-14                                                                                                              |
| **Versão do documento** | v1.0                                                                                                                    |
| **Unidade Curricular**  | Requisitos e Arquiteturas de Software — MEI, Universidade do Minho                                                      |

---

## 1. Funcionalidade de vídeo escolhida

| **Campo**                                | **Valor**                                                                         |
| ---------------------------------------- | --------------------------------------------------------------------------------- |
| **Funcionalidade**                       | Gerir áudio do vídeo (remover faixa sonora, silenciar, substituir ou extrair áudio) |
| **Perfil(s) de utilizador abrangido(s)** | Registado e Premium — utilizadores anónimos não têm acesso a esta funcionalidade. |

**Justificação no contexto do MVP**
Permite manipular a faixa de áudio de um vídeo: removê-la, substituí-la por um ficheiro escolhido ou extraí-la em formato M4A/AAC. A substituição pode usar um intervalo opcional do áudio; se este for mais curto, o restante vídeo fica sem som, e se for mais longo, o áudio é cortado no fim do vídeo.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-007                                                                                                                                                                                                                                                                                                                                |
| **Nome**                      | Gerir Áudio do Vídeo                                                                                                                                                                                                                                                                                                                      |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                                                                      |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [pg65411]                                                                                                                                                                                                                                            |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                                                                |
| **Objetivo**                  | Permitir ao utilizador remover o áudio de um vídeo, substituir a faixa sonora por um ficheiro escolhido ou extrair a faixa sonora como ficheiro independente. |
| **Âmbito**                    | Módulo de processamento de vídeo e gestão de conteúdos do PictuRAS                                                                                                                                                                                                                                                                        |
| **Ator Principal**            | Utilizador Registado ou Premium                                                                                                                                                                                                                                                                                                           |
| **Stakeholders e Interesses** | - **Utilizador**: pretende isolar o áudio ou criar um vídeo sem som para fins de edição.<br>- **Proprietário do Sistema**: garantir armazenamento adequado para ficheiros de áudio gerados.<br>- **Equipa de Desenvolvimento**: validar a manipulação isolada de streams de áudio através de ferramentas de backend. |
| **Pré-condições**             | - O utilizador tem sessão iniciada com perfil registado ou premium.<br>- O vídeo selecionado está disponível no projeto.<br>- Num projeto partilhado, o link está válido e concede permissão `edit` para remover/substituir/cancelar; a leitura do estado e o download exigem autenticação e acesso ao projeto. |
| **Trigger**                   | O utilizador seleciona um vídeo na biblioteca e escolhe a opção "Gerir Áudio". |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                        | **Resposta do Sistema**                                                                                                                       |
| --------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | O utilizador seleciona um vídeo na biblioteca e clica em "Gerir Áudio". | O sistema apresenta as opções **Remover Áudio**, **Substituir Áudio** e **Extrair Faixa de Áudio**. |
| 2         | O utilizador escolhe a operação desejada e confirma.                    | O sistema valida o perfil e, para extração, a existência de áudio no ficheiro de origem. Para substituição, solicita um ficheiro de áudio ou um vídeo e valida que contém uma faixa sonora. |
| 3         | —                                                                       | O sistema cria um operação de processamento de áudio e coloca-o na fila (RabbitMQ).                                                                |
| 4         | —                                                                       | O sistema notifica o utilizador que o processamento está em curso.                                                                            |
| 5         | O utilizador acompanha o estado.                                        | O sistema publica o estado na sala autorizada e o frontend consulta periodicamente a operação como fallback, atualizando o progresso.       |
| 6         | —                                                                       | O worker de vídeo, com FFmpeg, remove a faixa de áudio, extrai-a para M4A/AAC ou substitui-a pela faixa escolhida pelo utilizador. |
| 7         | —                                                                       | Para remoção ou substituição, o sistema guarda o novo vídeo MP4 no projeto. Para extração, prepara um ficheiro M4A/AAC temporário para transferência. |
| 8         | —                                                                       | O sistema regista a conclusão e, na extração, disponibiliza a transferência autenticada. O áudio extraído não é registado na biblioteca. |
| 9         | O utilizador descarrega o ficheiro extraído, se escolheu essa operação. | O sistema notifica a conclusão; o vídeo resultante aparece na biblioteca para remoção/substituição e o áudio extraído é transferido para o dispositivo do utilizador. |

### 2.3 Fluxos Alternativos

| **Fluxo**                             | **Descrição**                                                                                                                                                                                                                                              |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Vídeo sem faixa sonora original | Para remover áudio, o sistema apresenta o aviso "Este vídeo já não tem faixa de áudio" e termina sem criar resultado nem consumir quota. Para extrair áudio, apresenta um erro e também não cria resultado nem consome quota. |
| FA2 – Substituição com duração diferente | O utilizador pode escolher opcionalmente o intervalo da faixa a utilizar. Se o áudio for mais curto, o vídeo fica sem som no restante tempo; se for mais longo, o sistema corta-o no fim do vídeo. |
| FA3 – Cancelamento pelo utilizador    | Durante a execução, o utilizador pode cancelar o operação: o worker interrompe o processo, limpa temporários, repõe o estado como cancelado e não desconta quota. |

### 2.4 Exceções

| **Condição**                                 | **Comportamento do Sistema**                                                                        |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Erro técnico no processamento (FFmpeg crash) | O sistema interceta o erro, marca o operação como falhado e elimina ficheiros parciais. |
| Ficheiro corrompido                          | O sistema aborta a operação, marca como falhado e apresenta mensagem explicativa.                   |
| Entrada de substituição sem áudio, não suportada ou inválida | O sistema rejeita a entrada e informa os formatos aceites: MP3, M4A/AAC ou vídeo com faixa sonora. |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                            |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O vídeo silenciado ou com áudio substituído está guardado como novo conteúdo na biblioteca; o áudio extraído é transferido para o dispositivo do utilizador e não é adicionado à biblioteca. O vídeo original permanece intacto. |
| Garantia Mínima     | O vídeo original permanece inalterado, os temporários são limpos, o operação fica marcado como falhado/cancelado e nenhuma quota é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                       |
| ------ | ----------------------------------------------------------------------------------------------- |
| RN1    | Utilizadores anónimos não têm acesso a esta funcionalidade.                                     |
| RN2    | As operações de gestão de áudio usam FFmpeg sem IA e não consomem quota diária; estão disponíveis sem limite diário para utilizadores autenticados. |
| RN3    | O vídeo original nunca é substituído. Os resultados de vídeo são guardados como novo conteúdo; o áudio extraído é transferido e não fica na biblioteca do projeto. |
| RN4    | Operações cancelados ou falhados, e operações terminadas sem efeito por falta de áudio, não consomem quota. |
| RN5    | O áudio de substituição pode ser fornecido como MP3, M4A/AAC ou como vídeo com faixa sonora; quando é fornecido um vídeo, só a primeira faixa de áudio é usada. O áudio é convertido para AAC no vídeo MP4 resultante. |
| RN6    | Na extração, o destino do resultado é o dispositivo do utilizador através de download autenticado; `REQ-VID-COM-018` aplica-se com esta exceção explícita à biblioteca. |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                       |
| ------ | -------------------------------------------------------------------------------------------------- |
| A1     | O FFprobe consegue detetar previamente se o vídeo contém streams de áudio ativos.                  |
| A2     | O Projects Service e o API Gateway conseguem transmitir o M4A/AAC temporário ao cliente autorizado e eliminá-lo após a transferência ou expiração. |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                            |
| ------ | ---------------------------------------------------------------------------------------------------------------------- |
| Q1     | Se o vídeo tiver várias faixas de áudio, o sistema deve permitir escolher qual delas remover ou extrair? |

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

| **ID** | **Requisito** | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem** | **Como verificar** |
|--------|---------------|----------|----------------|--------------|------------|--------------------|
| REQ-VID-AUD-001 | O sistema deve permitir remover, substituir ou extrair a faixa de áudio de um vídeo. | F | Deve ter | NOVO | Passos 1-2 | Executar cada operação. |
| REQ-VID-AUD-002 | O sistema deve aceitar áudio MP3, M4A/AAC ou vídeo com faixa sonora como entrada de substituição e gerar AAC no vídeo MP4 resultante. | F | Deve ter | NOVO | RN5 | Testar áudio e vídeo como entrada e inspecionar o resultado. |
| REQ-VID-AUD-003 | O sistema deve rejeitar a extração quando o vídeo não tiver faixa sonora. | F | Deve ter | NOVO | FA1 | Executar extração num vídeo sem áudio. |
| REQ-VID-AUD-004 | O sistema deve preservar o vídeo original e guardar como novo conteúdo do projeto os resultados de vídeo de remoção/substituição. | F | Deve ter | NOVO | RN3, pós-condição | Comparar original e vídeo resultante. |
| REQ-VID-AUD-005 | O sistema deve permitir cancelar o operação e limpar temporários sem consumir quota. | F | Deve ter | NOVO | FA3-RN4 | Cancelar e verificar estado, armazenamento e quota. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Projects Service | Estender | Registar cada resultado como novo conteúdo sem reserva de quota diária. | AUD-001, AUD-004, AUD-005 |
| RabbitMQ e WebSocket Gateway | Estender | Criar operação de áudio e publicar estados/progresso ao projeto autorizado; o frontend usa polling como fallback. | AUD-001, AUD-005 |
| API Gateway / Projects Service | Estender | Transmitir o M4A/AAC temporário à sessão autorizada e eliminá-lo após download. | AUD-015, COM-018, COM-019 |
| FFmpeg/FFprobe | Novo | Detetar streams e executar remoção, substituição ou extração. | AUD-001, AUD-002, AUD-003 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1-2 | Escolher operação e validar entrada | REQ-VID-AUD-001, REQ-VID-AUD-002, REQ-VID-AUD-003 |
| Passos 3-5 | Criar operação e comunicar progresso | REQ-VID-AUD-005 |
| Passos 6-9 | Processar, persistir e notificar | REQ-VID-AUD-004 |
| FA1-FA3 e exceções | Sem áudio, cancelamento e falha | REQ-VID-AUD-003, REQ-VID-AUD-005 |
