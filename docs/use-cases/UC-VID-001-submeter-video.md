# UC-VID-001 — Submeter Vídeo para Processamento

---

## 0. Identificação

| **Campo**               | **Valor**                                                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Grupo / Equipa**      | Grupo 5 - PL3                                                                                                           |
| **Autores**             | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [pg65441] |
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

### Nota sobre projetos partilhados

Um projeto partilhado continua a pertencer ao utilizador proprietário, mas pode ser
acedido por outro utilizador autenticado através de um link de partilha. O link
define a permissão `read` (apenas consulta) ou `edit` (consulta e operações de
alteração). As operações de vídeo devem validar o link, a sua validade e a
permissão antes de ler ou alterar conteúdos; o proprietário permanece responsável
pelo projeto e é usado como identidade do projeto nos serviços internos.

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                               |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID do Caso de Uso**         | UC-VID-001                                                                                                                                                                                                                                                 |
| **Nome**                      | Submeter Vídeo para Processamento                                                                                                                                                                                                                          |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                       |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [pg65441]                                                                                                                                                              |
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
| 2         | O utilizador seleciona um ficheiro de vídeo local.        | O sistema inicia uma submissão individual, recebe o ficheiro num temporário em disco e valida extensão e tipo sem manter o vídeo completo em memória.                 |
| 3         | —                                                         | O sistema verifica a permissão do perfil e, quando aplicável, os limites definidos para a submissão.                                                                  |
| 4         | —                                                         | O sistema envia o ficheiro para uma área temporária do serviço de armazenamento, usando o estágio `video-src` para o objeto validado.                                 |
| 5         | O utilizador aguarda a conclusão da transferência.        | O sistema confirma o estado da transferência.                                                                                                                         |
| 6         | —                                                         | O sistema conclui a transferência e verifica a integridade do ficheiro; uma transferência acima do limite de corpo é rejeitada antes do processamento.                |
| 7         | —                                                         | O sistema extrai os metadados do vídeo (codec, resolução, duração, fps e tamanho).                                                                                    |
| 8         | —                                                         | O sistema valida a duração, a resolução e o fps contra os limites do perfil. |
| 9         | —                                                         | O sistema cria o registo correspondente na base de dados.                                                                                                             |
| 10        | —                                                         | O sistema associa o vídeo ao projeto e torna-o disponível para visualização e processamento posterior.                                                                |
| 11        | —                                                         | O sistema informa o sucesso da operação; a submissão não consome a quota diária de operações avançadas, que continua a aplicar-se aos operações de processamento.        |

### 2.3 Fluxos Alternativos

| **Fluxo**                          | **Descrição**                                                                                                                                                                |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Upload duplicado             | Se o vídeo tiver o mesmo nome de um ficheiro já existente no projeto, o sistema apresenta as opções de manter ambos ou cancelar. A substituição não faz parte do MVP. |
| FA2 – Upload em lote               | Se o utilizador selecionar vários vídeos, o sistema valida cada elemento individualmente e devolve um resultado independente (`concluída`, `rejeitada`, `cancelada` ou `falhada`) para cada elemento. |
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
| RN2    | Utilizadores registados podem submeter vídeos até 100 MB, 5 minutos, 1920×1080 e 60 fps. Qualquer largura ou altura superior ao máximo rejeita o vídeo. |
| RN3    | Utilizadores premium podem submeter vídeos até 1 GB, 30 minutos, 3840×2160 e 60 fps. Qualquer largura ou altura superior ao máximo rejeita o vídeo. |
| RN4    | O MVP aceita vídeo MP4 com vídeo H.264 e, quando exista áudio, AAC; ficheiros sem faixa de vídeo ou com combinações incompatíveis são rejeitados. |
| RN5    | A submissão de vídeo não é contabilizada como operação diária; a quota aplica-se às operações de processamento classificadas como avançadas, de acordo com a política existente.          |
| RN6    | Uma submissão rejeitada, cancelada ou falhada não consome quota nem deixa objetos parciais associados ao projeto.                                                                         |
| RN7    | A submissão não pode deixar o projeto apontar para um objeto inexistente, parcial ou corrompido.                                                                                          |
| RN8    | A referência persistida deve identificar o utilizador, o projeto, o estágio `video-src` e o objeto armazenado sem depender do nome original do ficheiro. |
| RN9    | Os limites de tamanho usam unidades decimais: 1 MB corresponde a 1 000 000 bytes e 1 GB corresponde a 1 000 000 000 bytes. |
| RN10   | O vídeo completo deve ser recebido em ficheiro temporário em disco; o sistema não deve manter o conteúdo completo em memória durante a submissão. |

### 2.7 Assunções

| **ID** | **Assunção**                                                                                                                                                                                                                                                                |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A1     | O SeaweedFS continuará a ser o armazenamento de objetos e será acedido através da fachada S3 existente; o suporte a vídeos pode exigir configuração ou contentores próprios, sem alterar os limites funcionais definidos para cada perfil. |
| A2     | O serviço de projetos e a fachada de armazenamento serão estendidos para aceitar vídeos sem quebrar o fluxo atual de imagens.                                                                                                                                               |
| A3     | FFmpeg/FFprobe será instalado na imagem Docker do serviço de projetos para extrair metadados e validar o contentor MP4, os codecs, a duração, a resolução e o fps. |
| A4     | O projeto do utilizador já está operacional para receber novos conteúdos.                                                                                                                                                                                                   |
| A5     | O serviço de armazenamento e a base de dados estão disponíveis durante o processo de submissão.                                                                                                                                                                             |

### 2.8 Questões Resolvidas e Fora do MVP

| **ID** | **Questão**                                                                                                                                      |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Q1     | Resolvida: os vídeos reutilizam o bucket por utilizador da fachada S3 e usam uma nova convenção de chave com o estágio `video-src`. |
| Q2     | Fora do MVP: não é obrigatória a geração automática de miniaturas. |
| Q3     | Fora do MVP: o seletor tradicional é suficiente; drag-and-drop pode ser avaliado depois. |
| Q4     | Fora do MVP: não é definido um limite funcional adicional de uploads simultâneos. |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                      | **Validação realizada pela equipa**                                                                                                                                                                                                                                        |
| ------------------------ | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso e dos fluxos principais e alternativos | Revisão manual pela equipa; ajuste dos limites de upload e das regras por perfil                                                                                                                                                                                           |
| GitHub Copilot           | Revisão de conformidade com o projeto existente                         | Comparação com o template e o enunciado da Fase 1; consulta do README                                                                                                                                                                                                      |
| GitHub Copilot           | Revisão técnica do armazenamento, progresso e quotas                    | Corrigida a referência para SeaweedFS/S3; distinguido o upload multipart do processamento assíncrono via RabbitMQ/WebSocket; explicitada a necessidade de extensão para FFmpeg/FFprobe; limites e contabilização de quota ficaram rastreáveis em regras e questões abertas |
| GitHub Copilot           | Definição das restrições por perfil                                     | Análise das regras existentes para imagens, quotas e perfis; decisão de excluir anónimos do upload de vídeo no MVP e aplicar os limites funcionais definidos para os perfis registado e premium. |
| GitHub Copilot           | Revisão dos limites de vídeo e rastreabilidade                          | Confirmação dos limites de tamanho, duração, resolução e fps para ambos os perfis; resolução rejeitada quando qualquer dimensão excede o máximo e tamanhos interpretados em unidades decimais. |

---


## 4. Esboço de requisitos derivados

### 4.1 Requisitos de Sistema

Requisitos normativos: `REQ-VID-SUB-001` a `REQ-VID-SUB-033` em `docs/RAS-requisitos-video.md`, secção UC-VID-001. Esta secção não cria uma segunda numeração local.

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Autenticação e perfis | Alterar | Reutilizar JWT e autorização existentes, acrescentando a regra de que o perfil anónimo não pode submeter vídeo. | SUB-001, SUB-004 |
| Image Storage Service / SeaweedFS | Estender | Reutilizar o upload S3 existente com content-type, chaves e limpeza próprios para vídeo. | SUB-002, SUB-005, SUB-006 |
| Projects Service e modelo de projeto | Estender | Adicionar uma referência de vídeo e os seus metadados sem alterar referências de imagens. | SUB-003, SUB-005 |
| API Gateway e frontend | Estender | Expor upload, validação, estado e erro de vídeo na biblioteca do projeto. | SUB-001, SUB-004, SUB-005 |
| FFmpeg/FFprobe | Novo | Introduzir inspeção de contentor, codec e metadados antes da persistência. | SUB-002, SUB-003, SUB-004 |

### 4.3 Matriz de Rastreabilidade

| Elemento | Requisitos canónicos |
|---|---|
| Passos 2-3: autenticação e autorização | `REQ-VID-SUB-001` a `REQ-VID-SUB-003` |
| Passos 4-8: validação, metadados e limites | `REQ-VID-SUB-004` a `REQ-VID-SUB-023`, `REQ-VID-SUB-032`, `REQ-VID-SUB-033` |
| Passos 9-11: persistência e associação | `REQ-VID-SUB-015`, `REQ-VID-SUB-026` a `REQ-VID-SUB-029` |
| Alternativas e exceções: limpeza, lote e duplicados | `REQ-VID-SUB-024`, `REQ-VID-SUB-030`, `REQ-VID-SUB-031` |
