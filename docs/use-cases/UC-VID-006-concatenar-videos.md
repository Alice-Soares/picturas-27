# UC-VID-006 — Concatenar Múltiplos Vídeos (Merge)

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
| **Funcionalidade**                       | Concatenar múltiplos vídeos (_merge_) num único ficheiro resultante               |
| **Perfil(s) de utilizador abrangido(s)** | Registado e Premium — utilizadores anónimos não têm acesso a esta funcionalidade. |

**Justificação no contexto do MVP**
A concatenação permite unir múltiplos vídeos ou excertos recortados previamente (via UC-VID-002) num único ficheiro de saída. Fecha o ciclo básico de edição não-linear no PictuRAS, validando a capacidade do pipeline assíncrono de lidar com múltiplas fontes de entrada, normalização de codecs/resoluções e renderização encadeada.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                                                                                              |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-006                                                                                                                                                                                                                                                                                                                                                                |
| **Nome**                      | Concatenar Múltiplos Vídeos (_Merge_)                                                                                                                                                                                                                                                                                                                                     |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                                                                                                      |
| **Autor**                     | Equipa Grupo 5 - PL3                                                                                                                                                                                                                                                                                                                                                      |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                                                                                                |
| **Objetivo**                  | Permitir ao utilizador selecionar dois ou mais vídeos da biblioteca, ordenar a sequência e uni-los num único vídeo de saída.                                                                                                                                                                                                                                              |
| **Âmbito**                    | Módulo de processamento de vídeo do PictuRAS e gestão de projetos                                                                                                                                                                                                                                                                                                         |
| **Ator Principal**            | Utilizador Registado ou Premium                                                                                                                                                                                                                                                                                                                                           |
| **Stakeholders e Interesses** | - **Utilizador**: pretende juntar vários excertos de vídeo numa única compilação contínua.<br>- **Proprietário do Sistema**: deseja assegurar o controlo de recursos computacionais e aplicar limites de duração total por perfil.<br>- **Equipa de Desenvolvimento**: valida a transcodificação/normalização automática de vídeos com resoluções ou codecs heterogéneos. |
| **Pré-condições**             | - O utilizador tem sessão iniciada com perfil registado ou premium.<br>- O projeto contém pelo menos 2 vídeos válidos e armazenados.<br>- O utilizador registado dispõe de quota de operações avançadas. |
| **Trigger**                   | O utilizador seleciona dois ou mais vídeos na biblioteca do projeto e escolhe a opção "Concatenar Vídeos".                                                                                                                                                                                                                                                                |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                                                         | **Resposta do Sistema**                                                                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | O utilizador acede à biblioteca do projeto e seleciona 2 ou mais vídeos.                                 | O sistema destaca os ficheiros selecionados e ativa a opção "Concatenar Vídeos".                                                                                                 |
| 2         | O utilizador clica em "Concatenar Vídeos".                                                               | O sistema apresenta a interface de ordenação com as miniaturas dos vídeos e opções de saída (resolução, formato).                                                                |
| 3         | O utilizador ajusta a ordem de reprodução dos vídeos (drag-and-drop) e seleciona os parâmetros de saída. | O sistema valida se a duração total acumulada e o número de ficheiros respeitam o limite do perfil do utilizador.                                                                |
| 4         | O utilizador confirma a operação de concatenação.                                                        | O sistema valida a quota do utilizador e a disponibilidade do armazenamento.                                                                                                     |
| 5         | —                                                                                                        | O sistema cria um operação de concatenação e envia a operação para a fila de mensagens (RabbitMQ).                                                                                      |
| 6         | —                                                                                                        | O sistema notifica o utilizador que o processamento iniciou e atualiza o estado para "Em fila".                                                                                  |
| 7         | O utilizador acompanha o progresso.                                                                      | O sistema comunica periodicamente o progresso em tempo real (%) via WebSocket.                                                                                                   |
| 8         | —                                                                                                        | O worker de vídeo  normaliza resoluções/codecs compatíveis, une os ficheiros na ordem definida, preserva as faixas de áudio compatíveis e guarda o resultado final. |
| 9         | —                                                                                                        | O sistema regista o novo vídeo na base de dados, associa-o ao projeto e aplica a quota de operações avançadas.                                                                        |
| 10        | —                                                                                                        | O sistema notifica a conclusão com sucesso e disponibiliza o vídeo final na biblioteca.                                                                                          |

### 2.3 Fluxos Alternativos

| **Fluxo**                                  | **Descrição**                                                                                                                                                                                                           |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Normalização Automática de Resolução | Se os vídeos selecionados tiverem resoluções ou taxas de fotogramas diferentes, o sistema ajusta automaticamente todos os vídeos para a resolução do primeiro elemento ou para a resolução configurada pelo utilizador. |
| FA2 – Cancelamento pelo Utilizador         | Durante a execução, o utilizador pode cancelar o operação: o worker interrompe o FFmpeg, elimina os ficheiros temporários gerados, marca o operação como cancelado e devolve a quota reservada.                                   |

### 2.4 Exceções

| **Condição**                                      | **Comportamento do Sistema**                                                                                                         |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Duração total combinada excede o limite do perfil | O sistema impede a submissão, destaca a duração excedida e sugere a remoção de vídeos ou upgrade de perfil.                          |
| Ficheiro de entrada corrompido ou inacessível     | O sistema assinala o ficheiro inválido no lote, interrompe a criação do operação e notifica o utilizador.                                 |
| Quota de operações avançadas esgotada            | O sistema bloqueia o início da operação e exibe o horário de reposição da quota.                                                     |
| Falha técnica durante a composição (FFmpeg)       | O sistema interceta o erro, marca o operação como falhado, limpa temporários, liberta a quota e disponibiliza o botão "Tentar novamente". |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O vídeo resultado da união está guardado na biblioteca do projeto e os vídeos originais permanecem intactos.                                                     |
| Garantia Mínima     | Os vídeos originais permanecem inalterados, os dados parciais/temporários são eliminados, o operação fica marcado como falhado/cancelado e nenhuma quota é consumida. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                                      |
| ------ | -------------------------------------------------------------------------------------------------------------- |
| RN1    | A concatenação exige pelo menos 2 vídeos e no máximo 5 para registados ou 15 para premium.                   |
| RN2    | A duração total não pode exceder 5 minutos para registados ou 30 minutos para premium.                       |
| RN3    | Os vídeos de origem nunca são alterados ou eliminados durante a concatenação.                                  |
| RN4    | Cada operação de concatenação aceite conta como uma operação avançada; utilizadores premium não têm limite diário.   |
| RN5    | Operações cancelados ou falhados não consomem quota de operações avançadas.                                         |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                                              |
| ------ | ------------------------------------------------------------------------------------------------------------------------- |
| A1     | O FFmpeg está configurado com os filtros adequados (`concat demuxer` / `complex filter`) para unir vídeos heterogéneos.   |
| A2     | O armazenamento temporário dos workers tem capacidade suficiente para alojar os ficheiros intermédios durante o processo. |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                     |
| ------ | --------------------------------------------------------------------------------------------------------------- |
| Q1     | Deve ser possível adicionar efeitos de transição (ex: _fade_, _crossfade_) entre os vídeos concatenados no MVP? |
| Q2     | Se um vídeo não tiver faixa de áudio, o sistema deve inserir áudio silencioso para manter a sincronização?      |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                                 | **Validação realizada pela equipa**                      |
| ------------------------ | ---------------------------------------------------------------------------------- | -------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso, identificação de excepções e fluxos alternativos | Revisão manual e adequação às regras globais do PictuRAS |

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
| REQ-VID-MERGE-001 | O sistema deve permitir selecionar e ordenar entre 2 e 5 vídeos para registados ou entre 2 e 15 para premium. | F | Deve ter | NOVO | RN1, passos 1-3 | Testar limites inferior, superior e seleção inválida. |
| REQ-VID-MERGE-002 | O sistema deve rejeitar concatenações acima de 5 minutos para registados ou 30 minutos para premium. | F | Deve ter | NOVO | RN2, passo 3 | Testar lotes no limite e acima dele. |
| REQ-VID-MERGE-003 | O sistema deve concatenar pela ordem escolhida e preservar áudio quando as streams forem compatíveis, guardando o resultado como novo vídeo. | F | Deve ter | NOVO | RN3, passos 8-10 | Verificar ordem, duração, áudio e preservação das origens. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Projects Service e autorização | Estender | Validar que todos os vídeos pertencem a um projeto acessível e registar o resultado. | MERGE-001, MERGE-003 |
| RabbitMQ e workers | Estender | Acrescentar worker de concatenação e normalização. | MERGE-002, MERGE-003 |
| SeaweedFS / armazenamento temporário | Estender | Ler múltiplos objetos e limpar intermediários após sucesso ou falha. | MERGE-003 |
| FFmpeg/FFprobe | Novo | Normalizar streams compatíveis e concatenar pela ordem selecionada. | MERGE-002, MERGE-003 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 1-4 | Selecionar, ordenar e validar | REQ-VID-MERGE-001, REQ-VID-MERGE-002 |
| Passos 5-7 | Criar operação e comunicar progresso | REQ-VID-MERGE-003 |
| Passos 8-10 | Concatenar e persistir resultado | REQ-VID-MERGE-003 |
| FA2 e exceções | Cancelar/falhar sem alterar origens | REQ-VID-MERGE-003 |
