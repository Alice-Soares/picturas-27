# UC-VID-001 — Submeter Vídeo para Processamento

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

| **Campo**                                | **Valor**                                                                                                             |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Funcionalidade**                       | Submeter Vídeo para Processamento                                                                                     |
| **Perfil(s) de utilizador abrangido(s)** | Registado e premium. O perfil anónimo mantém o acesso limitado às imagens pequenas e não pode submeter vídeos no MVP. |

**Justificação no contexto do MVP** _(2–3 linhas)_
Esta funcionalidade é a base de todo o suporte a vídeo no PictuRAS, porque sem upload válido não é possível executar qualquer operação posterior. Permite validar o pipeline completo de carregamento, validação, armazenamento e visualização, além de confirmar as regras de negócio por perfil. Sem ela, o restante suporte a vídeo fica inviável no MVP.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                               |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-001                                                                                                                                                                                                                                                 |
| **Nome**                      | Submeter Vídeo para Processamento                                                                                                                                                                                                                          |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                       |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel                                                                                                                                                                         |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                 |
| **Objetivo**                  | Permitir ao utilizador carregar um vídeo válido para o projeto e torná-lo disponível para processamento posterior.                                                                                                                                         |
| **Âmbito**                    | Extensão do módulo de projetos e conteúdos multimédia do PictuRAS, integrada com o serviço de armazenamento de objetos e pipeline de processamento de vídeo                                                                                                |
| **Ator Principal**            | Utilizador registado ou premium                                                                                                                                                                                                                            |
| **Stakeholders e Interesses** | - **Utilizador**: pretende carregar e guardar vídeos sem perda de dados<br>- **Proprietário do Sistema**: deseja validar as regras de quota e perfil para vídeo<br>- **Equipa de Desenvolvimento**: valida upload, armazenamento e metadados de vídeo      |
| **Pré-condições**             | - O utilizador tem sessão válida com perfil registado ou premium<br>- O utilizador tem um projeto ativo ou pode criar um novo<br>- O serviço de armazenamento de objetos está disponível<br>- O ficheiro de vídeo encontra-se no sistema local e é legível |
| **Trigger**                   | O utilizador seleciona um ficheiro de vídeo e escolhe a opção de submissão ao projeto.                                                                                                                                                                     |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                          | **Resposta do Sistema**                                                                                                                                               |
| --------- | --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | O utilizador abre a biblioteca de conteúdos ou o projeto. | O sistema apresenta a interface de upload com suporte para ficheiros de vídeo.                                                                                        |
| 2         | O utilizador seleciona um ficheiro de vídeo local.        | O sistema valida a extensão e o tipo de ficheiro.                                                                                                                     |
| 3         | —                                                         | O sistema verifica a permissão do perfil e, quando aplicável, os limites definidos para a submissão.                                                                  |
| 4         | —                                                         | O sistema envia o ficheiro para o serviço de armazenamento.                                                                                                           |
| 5         | O utilizador aguarda a conclusão da transferência.        | O sistema confirma o estado da transferência.                                                                                                                         |
| 6         | —                                                         | O sistema conclui a transferência e verifica a integridade do ficheiro.                                                                                               |
| 7         | —                                                         | O sistema extrai os metadados do vídeo (codec, resolução, duração, fps e tamanho).                                                                                    |
| 8         | —                                                         | O sistema valida a duração, a resolução e o fps contra os limites do perfil. |
| 9         | —                                                         | O sistema cria o registo correspondente na base de dados.                                                                                                             |
| 10        | —                                                         | O sistema associa o vídeo ao projeto e torna-o disponível para visualização e processamento posterior.                                                                |
| 11        | —                                                         | O sistema informa o sucesso da operação; a submissão não consome a quota diária de operações avançadas, que continua a aplicar-se aos operações de processamento.        |

### 2.3 Fluxos Alternativos

| **Fluxo**                          | **Descrição**                                                                                                                                                                |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Upload duplicado             | Se o vídeo tiver o mesmo nome de um ficheiro já existente no projeto, o sistema apresenta opções de substituir, manter ambos ou cancelar.                                    |
| FA2 – Upload em lote               | Se o utilizador selecionar vários vídeos, o sistema valida cada elemento individualmente e só associa ao projeto os ficheiros válidos.                                       |
| FA3 – Cancelamento do upload       | Durante a transferência, o utilizador pode cancelar a operação; o sistema deve interromper a transferência e remover o objeto.                                               |
| FA4 – Tentativa por perfil anónimo | Se um utilizador anónimo tentar submeter um vídeo, o sistema rejeita a operação, explica que a funcionalidade exige uma conta registada e não cria objeto nem consome quota. |

### 2.4 Exceções

| **Condição**                                   | **Comportamento do Sistema**                                                                                                                  |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Formato ou codec não suportado                 | O sistema rejeita o ficheiro com mensagem de erro e não guarda qualquer versão parcial.                                                       |
| Tamanho do ficheiro excede um limite aplicável | O sistema bloqueia o upload e informa o utilizador do máximo permitido, quando existir um limite para o perfil ou para a infraestrutura.      |
| Duração do vídeo excede um limite aplicável    | O sistema rejeita o vídeo, remove ficheiros temporários e não consome quota, quando existir um limite para o perfil ou para a infraestrutura. |
| Falha de rede durante o upload                 | O sistema informa o utilizador do erro e remove o objeto temporário, se tiver sido criado. A retoma não faz parte do MVP.                     |
| Armazenamento indisponível                     | O sistema informa que o serviço de armazenamento está temporariamente indisponível e não cria o registo do vídeo.                             |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Garantia de Sucesso | O objeto de vídeo fica armazenado no sistema, é referenciado pelo registo da base de dados, fica associado ao projeto e disponível para processamento posterior.                                       |
| Garantia Mínima     | Nenhum objeto temporário, ficheiro parcial ou registo inconsistente permanece associado ao projeto; a quota só é consumida conforme a regra definida e o utilizador recebe uma mensagem de erro clara. |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                                                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RN1    | Utilizadores anónimos não podem submeter vídeos no MVP; podem continuar a utilizar as funcionalidades de imagem permitidas pelo sistema.                                                  |
| RN2    | Utilizadores registados podem submeter vídeos até 100 MB, 5 minutos, 1920×1080 e 60 fps. |
| RN3    | Utilizadores premium podem submeter vídeos até 1 GB, 30 minutos, 3840×2160 e 60 fps. |
| RN4    | O MVP aceita vídeo MP4 com vídeo H.264 e, quando exista áudio, AAC; ficheiros sem faixa de vídeo ou com combinações incompatíveis são rejeitados. |
| RN5    | A submissão de vídeo não é contabilizada como operação diária; a quota aplica-se às operações de processamento classificadas como avançadas, de acordo com a política existente.          |
| RN6    | Uma submissão rejeitada, cancelada ou falhada não consome quota nem deixa objetos parciais associados ao projeto.                                                                         |
| RN7    | A submissão não pode deixar o projeto apontar para um objeto inexistente, parcial ou corrompido.                                                                                          |
| RN8    | A referência persistida deve identificar o utilizador, o projeto, o estágio do conteúdo e o objeto armazenado sem depender do nome original do ficheiro.                                  |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                                                                                                                                                                                                |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A1     | O SeaweedFS continuará a ser o armazenamento de objetos e será acedido através da fachada S3 existente; o suporte a vídeos pode exigir configuração, contentores próprios ou limites físicos da infraestrutura, sem os transformar em limites funcionais do perfil premium. |
| A2     | O serviço de projetos e a fachada de armazenamento serão estendidos para aceitar vídeos sem quebrar o fluxo atual de imagens.                                                                                                                                               |
| A3     | Será disponibilizado um componente de análise de vídeo, como FFmpeg/FFprobe ou equivalente, para extrair metadados e validar o contentor MP4, os codecs, a duração, a resolução e o fps.                                                                                    |
| A4     | O projeto do utilizador já está operacional para receber novos conteúdos.                                                                                                                                                                                                   |
| A5     | O serviço de armazenamento e a base de dados estão disponíveis durante o processo de submissão.                                                                                                                                                                             |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                                                      |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Q1     | Os vídeos usam os buckets por utilizador já adotados pela fachada S3, com uma nova convenção de chave/estágio, ou devem usar um bucket separado? |
| Q2     | O sistema deve gerar automaticamente uma miniatura para cada vídeo submetido com sucesso?                                                        |
| Q3     | A interface deve suportar drag-and-drop além do seletor de ficheiros tradicional?                                                                |
| Q4     | Deve existir um limite máximo de uploads simultâneos por utilizador?                                                                             |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                      | **Validação realizada pela equipa**                                                                                                                                                                                                                                        |
| ------------------------ | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso e dos fluxos principais e alternativos | Revisão manual pela equipa; ajuste dos limites de upload e das regras por perfil                                                                                                                                                                                           |
| GitHub Copilot           | Revisão de conformidade com o projeto existente                         | Comparação com o template e o enunciado da Fase 1; consulta do README                                                                                                                                                                                                      |
| GitHub Copilot           | Revisão técnica do armazenamento, progresso e quotas                    | Corrigida a referência para SeaweedFS/S3; distinguido o upload multipart do processamento assíncrono via RabbitMQ/WebSocket; explicitada a necessidade de extensão para FFmpeg/FFprobe; limites e contabilização de quota ficaram rastreáveis em regras e questões abertas |
| GitHub Copilot           | Definição das restrições por perfil                                     | Análise das regras existentes para imagens, quotas e perfis; decisão de excluir anónimos do upload de vídeo no MVP, limitar tecnicamente o perfil registado e não definir limites funcionais de tamanho, duração, resolução ou fps para premium                            |
| GitHub Copilot           | Revisão dos limites de vídeo e rastreabilidade                          | Os limites de tamanho, duração, resolução e fps aplicam-se apenas ao perfil registado; para premium foi registada a ausência de limites funcionais por perfil, mantendo a validação de formato/codec e a dependência da capacidade da infraestrutura                       |

---


## 4. Esboço de requisitos derivados

### 4.1 Requisitos de Sistema

| **ID** | **Requisito** | **Tipo** | **Prioridade** | **Novo/Alt** | **Origem** | **Como verificar** |
|--------|---------------|----------|----------------|--------------|------------|--------------------|
| REQ-VID-SUB-001 | O sistema deve permitir a submissão de vídeos apenas a utilizadores registados ou premium com sessão válida. | F | Deve ter | ALT | UC-VID-001, FA4, RN1 | Tentar submeter vídeo sem sessão e com os dois perfis autorizados. |
| REQ-VID-SUB-002 | O sistema deve aceitar no MVP vídeos MP4 com vídeo H.264 e, quando exista áudio, AAC. | F | Deve ter | NOVO | UC-VID-001, RN4 | Submeter ficheiros compatíveis e incompatíveis. |
| REQ-VID-SUB-003 | O sistema deve extrair e guardar codec, resolução, duração, taxa de fotogramas e tamanho. | F | Deve ter | NOVO | UC-VID-001, passo 7 | Inspecionar o registo após uma submissão válida. |
| REQ-VID-SUB-004 | O sistema deve rejeitar vídeos que excedam os limites do perfil antes de os associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passos 8, RN2-RN3 | Testar ficheiros no limite e acima de cada limite. |
| REQ-VID-SUB-005 | O sistema deve guardar o vídeo validado através da fachada de armazenamento existente, criar a referência no projeto e manter o original disponível para operações posteriores. | F | Deve ter | ALT | UC-VID-001, passos 4, 9-10, RN7-RN8 | Verificar objeto, registo e associação ao projeto. |
| REQ-VID-SUB-006 | O sistema deve remover temporários e não criar referências persistentes quando a submissão for rejeitada, cancelada ou falhar. | F | Deve ter | NOVO | UC-VID-001, FA3, exceções | Interromper e provocar falhas durante o upload. |

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Autenticação e perfis | Alterar | Reutilizar JWT e autorização existentes, acrescentando a regra de que o perfil anónimo não pode submeter vídeo. | SUB-001, SUB-004 |
| Image Storage Service / SeaweedFS | Estender | Reutilizar o upload S3 existente com content-type, chaves e limpeza próprios para vídeo. | SUB-002, SUB-005, SUB-006 |
| Projects Service e modelo de projeto | Estender | Adicionar uma referência de vídeo e os seus metadados sem alterar referências de imagens. | SUB-003, SUB-005 |
| API Gateway e frontend | Estender | Expor upload, validação, estado e erro de vídeo na biblioteca do projeto. | SUB-001, SUB-004, SUB-005 |
| FFmpeg/FFprobe | Novo | Introduzir inspeção de contentor, codec e metadados antes da persistência. | SUB-002, SUB-003, SUB-004 |

### 4.3 Matriz de Rastreabilidade

| **Elemento do Caso de Uso** | **Descrição abreviada** | **Requisito(s) de Sistema** |
|------------------------------|-------------------------|------------------------------|
| Passos 2-3 | Validar perfil, extensão e conteúdo | REQ-VID-SUB-001, REQ-VID-SUB-002 |
| Passos 4-8 | Transferir, inspecionar e aplicar limites | REQ-VID-SUB-003, REQ-VID-SUB-004 |
| Passos 9-11 | Persistir e associar ao projeto | REQ-VID-SUB-005 |
| FA3-FA4 e exceções | Cancelar/rejeitar sem resíduos | REQ-VID-SUB-006 |