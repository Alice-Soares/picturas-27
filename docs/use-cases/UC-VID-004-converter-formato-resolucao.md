# UC-VID-004 — Converter Formato e Resolução de Vídeo

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

| **Campo**                                | **Valor**                                                                                                     |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Funcionalidade**                       | Converter formato e resolução de vídeo                                                                        |
| **Perfil(s) de utilizador abrangido(s)** | Registado e premium. O perfil anónimo fica fora desta funcionalidade até existir uma regra de vídeo aprovada. |

**Justificação no contexto do MVP** _(2–3 linhas)_
A conversão de vídeo permite adaptar conteúdos a diferentes dispositivos e contextos de uso, reduzindo o peso do ficheiro e melhorando a compatibilidade. Também valida o pipeline assíncrono de transcodificação, que será essencial para operações futuras de vídeo no PictuRAS. Sem esta funcionalidade, o suporte a vídeo ficaria incompleto e menos útil para o utilizador final.

---

## 2. Caso de Uso

### 2.1 Cabeçalho

| **Secção**                    | **Detalhes**                                                                                                                                                                                                                                                                                                                               |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **ID do Caso de Uso**         | UC-VID-004                                                                                                                                                                                                                                                                                                                                 |
| **Nome**                      | Converter formato e resolução de vídeo                                                                                                                                                                                                                                                                                                     |
| **Versão**                    | v1.0                                                                                                                                                                                                                                                                                                                                       |
| **Autor**                     | João Azevedo [pg63981], Francisco Barros [pg65409], Alice Soares [pg63920], Samuel [pg65441]                                                                                                                                                                                                                                      |
| **Data**                      | 2026-10-14                                                                                                                                                                                                                                                                                                                                 |
| **Objetivo**                  | Permitir ao utilizador converter um vídeo para um formato, codec e resolução compatíveis com o seu perfil e necessidade de uso.                                                                                                                                                                                                            |
| **Âmbito**                    | Módulo de processamento de vídeo do PictuRAS, integração com transcodificação e armazenamento de resultados                                                                                                                                                                                                                                |
| **Ator Principal**            | Utilizador registado ou premium                                                                                                                                                                                                                                                                                                            |
| **Stakeholders e Interesses** | - **Utilizador**: pretende adaptar vídeos para diferentes dispositivos, plataformas e tamanhos de ficheiro<br>- **Proprietário do Sistema**: deseja manter controlo de qualidade e compatibilidade do conteúdo<br>- **Equipa de Desenvolvimento**: valida a integração com FFmpeg, filas RabbitMQ e armazenamento |
| **Pré-condições**             | - O utilizador tem acesso a um projeto com um vídeo válido carregado<br>- O vídeo está no formato e codec suportados pelo sistema<br>- O serviço de transcodificação está disponível                                                                                                                                                       |
| **Trigger**                   | O utilizador seleciona um vídeo e escolhe a opção de conversão no painel de ferramentas.                                                                                                                                                                                                                                                   |

### 2.2 Fluxo Principal

| **Passo** | **Ação do Ator**                                                     | **Resposta do Sistema**                                                                                        |
| --------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 1         | O utilizador abre a biblioteca de vídeos do projeto.                 | O sistema apresenta o vídeo selecionado e as propriedades básicas do ficheiro.                                 |
| 2         | O utilizador seleciona um vídeo e escolhe a opção "Converter Vídeo". | —                                                                                                              |
| 3         | —                                                                    | O sistema apresenta as propriedades do vídeo de origem e as opções de conversão disponíveis conforme o perfil. |
| 4         | O utilizador define o formato e a resolução de destino.              | —                                                                                                              |
| 5         | —                                                                    | O sistema valida as opções e apresenta uma estimativa do tamanho final do ficheiro.                            |
| 6         | O utilizador confirma a operação.                                    | —                                                                                                              |
| 7         | —                                                                    | O sistema cria um operação de transcodificação e publica a operação na fila do processamento.                         |
| 8         | O utilizador acompanha o progresso.                                  | O sistema atualiza o estado do operação e comunica o progresso em tempo real via WebSocket.                         |
| 9         | —                                                                    | O sistema executa a transcodificação e guarda o vídeo resultante no armazenamento.                             |
| 10        | —                                                                    | O sistema atualiza o estado do operação para concluído e disponibiliza o ficheiro convertido ao utilizador.         |

### 2.3 Fluxos Alternativos

| **Fluxo**                       | **Descrição**                                                                                                                                                 |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FA1 – Conversão em lote         | Se o utilizador selecionar vários vídeos, o sistema cria um operação por vídeo e aplica os mesmos parâmetros a todos.                                              |
| FA2 – Cancelamento da conversão | Durante a execução, o utilizador pode cancelar a operação; o sistema interrompe a transcodificação, limpa ficheiros temporários e marca o operação como cancelado. |
| FA3 – Perfil predefinido        | Se o utilizador selecionar um perfil predefinido, o sistema preenche automaticamente o formato, resolução e codec mais adequados.                             |

### 2.4 Exceções

| **Condição**                           | **Comportamento do Sistema**                                                              |
| -------------------------------------- | ----------------------------------------------------------------------------------------- |
| Formato de origem não suportado        | O sistema rejeita a conversão e informa o utilizador dos formatos aceites.                |
| Combinação de formato e codec inválida | O sistema bloqueia a configuração e solicita uma combinação compatível.                   |
| Falha durante a transcodificação       | O sistema marca o operação como falhado, elimina ficheiros temporários e informa o utilizador. |

### 2.5 Pós-condições

| **Tipo**            | **Resultado**                                                                                                                 |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Garantia de Sucesso | O ficheiro convertido fica armazenado no projeto e disponível para visualização e transferência sem alterar o vídeo original. |
| Garantia Mínima     | O vídeo original permanece intacto, os ficheiros temporários são removidos e o operação é registado com o estado final correto.    |

### 2.6 Regras de Negócio e Restrições

| **ID** | **Regra**                                                                                                                                                       |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RN1    | O MVP aceita MP4 com vídeo H.264 e áudio AAC; outros formatos só são aceites se forem explicitamente adicionados à lista de combinações suportadas.                |
| RN2    | A resolução de saída não pode exceder 1920×1080 para registados nem 3840×2160 para premium.                                                                       |
| RN3    | A conversão usa FFmpeg sem IA e não consome quota diária; está disponível sem limite diário para utilizadores autenticados.                                                        |
| RN4    | O áudio de saída deve ser AAC quando o contentor de saída for MP4.                                                                                                |
| RN5    | O vídeo original deve permanecer inalterado após a conversão.                                                                                                   |

### 2.7 Assunções

| **ID** | **Assunção**                                                                              |
| ------ | ----------------------------------------------------------------------------------------- |
| A1     | O FFmpeg ou ferramenta equivalente está disponível para realizar a transcodificação.      |
| A2     | A infraestrutura de filas e WebSocket suporta a atualização de progresso em tempo real.   |
| A3     | O armazenamento do projeto consegue guardar ficheiros de vídeo convertidos sem corrupção. |

### 2.8 Questões em Aberto

| **ID** | **Questão**                                                                                                            |
| ------ | ---------------------------------------------------------------------------------------------------------------------- |
| Q1     | O sistema deve permitir conversão em paralelo para vários vídeos ou apenas uma transcodificação por vídeo de cada vez? |
| Q2     | Os vídeos convertidos devem substituir o original ou ser armazenados como versões separadas do projeto?                |
| Q3     | O sistema deve gerar perfis de conversão automáticos para utilizadores menos experientes?                              |

---

## 3. Utilização de agentes de IA

| **Ferramenta / _skill_** | **Tarefa apoiada**                                                        | **Validação realizada pela equipa**                                                                        |
| ------------------------ | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| GitHub Copilot           | Estrutura inicial do caso de uso, fluxos alternativos e regras de negócio | Revisão manual pela equipa; ajuste dos limites por perfil e validação da coerência com o pipeline de vídeo |

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

Requisitos normativos: `REQ-VID-CONV-001` a `REQ-VID-CONV-011` e requisitos comuns aplicáveis em `docs/RAS-requisitos-video.md`. A numeração local anteriormente usada é retirada por colidir com a numeração canónica.

### 4.2 Impacto no sistema existente

| **Elemento existente afetado** | **Impacto (Manter / Estender / Alterar)** | **Descrição do impacto** | **Requisitos relacionados** |
|--------------------------------|-------------------------------------------|--------------------------|------------------------------|
| Projects Service | Estender | Registar conversões como operações assíncronas, sem reserva de quota diária. | CONV-001, CONV-002 |
| RabbitMQ e workers | Estender | Criar worker de transcodificação sem alterar as filas das ferramentas de imagem. | CONV-002 |
| SeaweedFS / Image Storage Service | Estender | Guardar resultados de vídeo como novos objetos. | CONV-002, CONV-003 |
| FFmpeg/FFprobe | Novo | Validar streams e executar a transcodificação. | CONV-001, CONV-003 |

### 4.3 Matriz de Rastreabilidade

| Elemento | Requisitos canónicos |
|---|---|
| Origem, formatos, codecs e resolução | `REQ-VID-CONV-001` a `REQ-VID-CONV-004` |
| Combinações e limites de perfil | `REQ-VID-CONV-005` a `REQ-VID-CONV-007` |
| Estimativa | `REQ-VID-CONV-008` |
| Execução, resultado e progresso | `REQ-VID-CONV-009` a `REQ-VID-CONV-011`, `REQ-VID-COM-017` |
| Autorização e limpeza | `REQ-VID-COM-001` a `REQ-VID-COM-003`, `REQ-VID-COM-014` a `REQ-VID-COM-016` |
