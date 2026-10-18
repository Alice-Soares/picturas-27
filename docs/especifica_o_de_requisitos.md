# RAS
## Universidade do Minho
### Escola de Engenharia
### Mestrado em Engenharia Informática
#### Unidade Curricular de Requisitos e Arquiteturas de Software
**2025/2026**

**Fase 1**

- Diogo Miguel Pinto pg61515
- Gabriel Veloso Antunes pg60259
- Guilherme Pinto Pinho pg60263
- Mariana Miguel Pinto pg61534
- Miguel Freixo Machado pg60284

Novembro, 2025

RAS

---

Fase 1

- Diogo Miguel Pinto pg61515
- Gabriel Veloso Antunes pg60259
- Guilherme Pinto Pinho pg60263
- Mariana Miguel Pinto pg61534
- Miguel Freixo Machado pg60284

Novembro, 2025

| Data da Receção | |
|---|---|
| **Responsável** | |
| **Avaliação** | |
| **Observações** | |

---

## Índice

| | | |
|---|---|---|
| **1.** | **Introdução** | **1** |
| **2.** | **Modelo de Domínio (atualizado)** | **1** |
| **3.** | **Clientes, Consumidores e Stakeholders (Revisão)** | **2** |
| | 3.1. Perfis de Utilização Existentes | 2 |
| | 3.2. Novos Atores e Papéis Introduzidos | 3 |
| | 3.3. Integração com os Casos de Uso e Matriz de Rastreabilidade | 4 |
| **4.** | **Restrições do Projeto** | **4** |
| **5.** | **Modelo de Casos de Uso** | **5** |
| **6.** | **Requisitos de Sistema** | **9** |
| | 6.1. Requisitos Funcionais | 9 |
| | 6.2. Requisitos Não Funcionais | 19 |
| | 6.3. Matriz de Rastreabilidade | 26 |
| **7.** | **Sumário de Elicitação de Requisitos** | **27** |
| **8.** | **Modelos UML Comportamentais** | **28** |
| | 8.1. Diagrama de Atividades - UC06 | 28 |
| | 8.2. Diagrama de Atividades - UC07 | 31 |
| **9.** | **Tarefas de Manutenção Corretiva da Solução Atual** | **32** |
| **10.**| **Conclusão** | **34** |

i

---

## Lista de Figuras

| | | |
|---|---|---|
| **Figura 1** | Modelo de Domínio atualizado | 2 |
| **Figura 2** | Diagrama de Casos de Uso. | 5 |
| **Figura 3** | Diagrama de Atividades referente ao UC06 - Assistente IA na edição. | 29 |
| **Figura 4** | Diagrama de Atividades referente ao UC07 - Partilhar projeto. | 31 |

## Lista de Tabelas

| | | |
|---|---|---|
| **Tabela 1** | Stakeholders e respetivos interesses | 3 |
| **Tabela 2** | Restrições do Projeto | 4 |
| **Tabela 3** | Caso de Uso-05 | 6 |
| **Tabela 4** | Caso de Uso-06 | 7 |
| **Tabela 5** | Caso de Uso-07 | 8 |
| **Tabela 6** | Requisito Funcional-39 | 9 |
| **Tabela 7** | Requisito Funcional-40 | 9 |
| **Tabela 8** | Requisito Funcional-41 | 10 |
| **Tabela 9** | Requisito Funcional-42 | 10 |
| **Tabela 10** | Requisito Funcional-44 | 11 |
| **Tabela 11** | Requisito Funcional-45 | 11 |
| **Tabela 12** | Requisito Funcional-46 | 12 |
| **Tabela 13** | Requisito Funcional-47 | 12 |
| **Tabela 14** | Requisito Funcional-48 | 13 |
| **Tabela 15** | Requisito Funcional-50 | 13 |
| **Tabela 16** | Requisito Funcional-51 | 13 |
| **Tabela 17** | Requisito Funcional-52 | 13 |
| **Tabela 18** | Requisito Funcional-53 | 14 |
| **Tabela 19** | Requisito Funcional-54 | 14 |
| **Tabela 20** | Requisito Funcional-55 | 14 |
| **Tabela 21** | Requisito Funcional-56 | 15 |
| **Tabela 22** | Requisito Funcional-57 | 15 |
| **Tabela 23** | Requisito Funcional-58 | 15 |
| **Tabela 24** | Requisito Funcional-59 | 15 |
| **Tabela 25** | Requisito Funcional-60 | 16 |
| **Tabela 26** | Requisito Funcional-61 | 16 |
| **Tabela 27** | Requisito Funcional-62 | 16 |
| **Tabela 28** | Requisito Funcional-63 | 16 |
| **Tabela 29** | Requisito Funcional-64 | 17 |
| **Tabela 30** | Requisito Funcional-65 | 17 |
| **Tabela 31** | Requisito Funcional-66 | 17 |
| **Tabela 32** | Requisito Funcional-67 | 17 |
| **Tabela 33** | Requisito Funcional-68 | 18 |
| **Tabela 34** | Requisito Funcional-70 | 18 |
| **Tabela 35** | Requisito Funcional-71 | 18 |
| **Tabela 36** | Requisito Funcional-72 | 18 |
| **Tabela 37** | Requisito Funcional-73 | 19 |
| **Tabela 38** | Requisito Não Funcional-43 | 19 |
| **Tabela 39** | Requisito Não Funcional-44 | 19 |
| **Tabela 40** | Requisito Não Funcional-45 | 20 |
| **Tabela 41** | Requisito Não Funcional-46 | 20 |
| **Tabela 42** | Requisito Funcional-47 | 20 |
| **Tabela 43** | Requisito Não Funcional-48 | 21 |

ii

---

| | | |
|---|---|---|
| **Tabela 44** | Requisito Não Funcional-49 | 21 |
| **Tabela 45** | Requisito Não Funcional-50 | 21 |
| **Tabela 46** | Requisito Não Funcional-52 | 22 |
| **Tabela 47** | Requisito Não Funcional-53 | 22 |
| **Tabela 48** | Requisito Não Funcional-54 | 22 |
| **Tabela 49** | Requisito Não Funcional-55 | 23 |
| **Tabela 50** | Requisito Não Funcional-56 | 23 |
| **Tabela 51** | Requisito Não Funcional-57 | 23 |
| **Tabela 52** | Requisito Não Funcional-58 | 23 |
| **Tabela 53** | Requisito Não Funcional-59 | 24 |
| **Tabela 54** | Requisito Não Funcional-60 | 24 |
| **Tabela 55** | Requisito Não Funcional-61 | 24 |
| **Tabela 56** | Requisito Não Funcional-63 | 24 |
| **Tabela 57** | Requisito Não Funcional-64 | 25 |
| **Tabela 58** | Requisito Não Funcional-65 | 25 |
| **Tabela 59** | Requisito Não Funcional-66 | 25 |
| **Tabela 60** | Técnicas de elicitação e resultados obtidos | 27 |
| **Tabela 61** | | 33 |
| **Tabela 62** | Tarefas de manutenção corretiva da solução atual | 34 |

iii

---

## 1. Introdução

O presente documento tem como objetivo descrever o propósito do incremento desenvolvido para a aplicação PictuRAS, uma ferramenta dedicada à edição de imagens com foco na simplicidade e na integração de funcionalidades inteligentes. Neste sentido, visa melhorar a experiência do utilizador, tornando a aplicação mais intuitiva, eficiente e adaptada às necessidades atuais do mercado de edição fotográfica. Assim, foram introduzidos novos requisitos funcionais e não funcionais, que ampliam significativamente as capacidades da aplicação.

Além disso, foram revistas e expandidas diversas secções do documento original, nomeadamente:
- A secção de requisitos funcionais e não funcionais, agora mais detalhada e com novos fit criteria associados;
- Os use cases, que foram atualizados para refletir as novas funcionalidades e fluxos alternativos e de exceção;
- A análise comparativa de aplicações existentes, que foi alargada para incluir referências a soluções de mercado com funcionalidades semelhantes.

Este incremento reforça o posicionamento da PictuRAS como uma aplicação moderna e centrada no utilizador, incorporando tecnologias de inteligência artificial e práticas de design atuais para otimizar a experiência de edição fotográfica. Além disso, responde também às limitações identificadas na análise da Fase 0, nomeadamente a ausência de funcionalidades colaborativas, a fraca integração com serviços de inteligência artificial e a inexistência de mecanismos de gestão de permissões e limites de utilização.

Por estes motivos e com estas melhorias, o PictuRAS consolida-se como uma solução de edição de imagem moderna e escalável, preparada para suportar evoluções incrementais nas fases seguintes do projeto.

## 2. Modelo de Domínio (atualizado)

O modelo de domínio apresentado na figura seguinte representa a estrutura conceptual revista do sistema PictuRAS após o incremento da Fase 1. Este diagrama atualiza o modelo base do projeto original, refletindo as novas funcionalidades de edição assistida por IA, gestão de presets personalizados e partilha entre utilizadores.

O núcleo da aplicação mantém as entidades Utilizador, Projeto, Imagem e Ferramenta, fundamentais para a manipulação e organização dos conteúdos de edição. Foram preservadas as especializações de Utilizador (Anónimo, Gratuito e Premium) que representam diferentes níveis de acesso e funcionalidades. Apesar de modeladas como subclasses, o tipo de conta pode ser alterado dinamicamente (upgrade ou downgrade) sem impacto estrutural no sistema.

Entre os utilizadores, foi introduzida uma auto-associação "convida", que traduz a possibilidade de um utilizador partilhar um projeto com outro, concedendo permissões de visualização ou edição. A gestão do convite (token, expiração, revogação) é tratada pela aplicação, não sendo detalhada no modelo de domínio.

A entidade Projeto continua a centralizar o fluxo de trabalho, estando associada às entidades Imagem e Ferramenta. Cada projeto pode usar várias ferramentas, aplicar presets e gerar novas versões de imagem. As Ferramentas dividem-se em Básicas e Avançadas, e dentro destas destaca-se o Assistente IA, uma ferramenta especializada capaz de analisar imagens e gerar recomendações inteligentes.

Os resultados gerados pelo Assistente IA são representados pela entidade Sugestão IA, que contém os filtros e parâmetros propostos, podendo ser aplicados, ajustados ou rejeitados pelo utilizador. Assim, o modelo mantém o Assistente IA como parte do domínio de edição, sem incluir dependências externas, ou seja, a integração técnica com serviços de IA é considerada apenas a nível arquitetural, fora deste diagrama.

1

---

![Modelo de Domínio atualizado](Figura1_ModeloDominio.png)

A entidade Preset encapsula sequências de ferramentas e parâmetros definidos pelo utilizador. Cada preset pode ser criado por um utilizador, conter uma ou mais ferramentas e ser aplicado em diferentes projetos. Este conceito traduz a personalização e reutilização de configurações introduzida na Fase 1.

De forma resumida, o modelo de domínio atualizado:
- Preserva o núcleo estrutural do PictuRAS v1.0.
- Introduz o Assistente IA e as Sugestões IA para suportar os novos requisitos RF44-RF65.
- Mantém o relacionamento colaborativo entre utilizadores via convite.
- Expande a noção de personalização através dos Presets.
- Mantém explícita a distinção entre planos de utilização (Anónimo, Gratuito, Premium).

Estas evoluções reforçam o alinhamento entre o domínio conceptual e os casos de uso da Fase 1 (UC05-Criar Filtro Personalizado, UC06 - Assistente IA na Edição e UC07 - Partilhar Projeto), garantindo coerência entre os modelos estáticos e comportamentais.

*Figura 1: Modelo de Domínio atualizado*

## 3. Clientes, Consumidores e Stakeholders (Revisão)

O objetivo desta secção é rever os clientes, consumidores e stakeholders do sistema PictuRAS, tendo em conta as novas funcionalidades introduzidas nesta fase, tal como a edição inteligente assistida por IA, a partilha por link com permissões, a colaboração em tempo real e os presets personalizados. Neste sentido, esta revisão baseia-se nas informações recolhidas no Exercício 4 (Elicitação) e assegura que todos os novos papéis e dependências externas estão refletidos nos Use Cases e Requisitos do Sistema, reforçando a rastreabilidade e a coerência do modelo.

### 3.1. Perfis de Utilização Existentes

Os seguintes perfis de utilizador foram herdados do documento base do PictuRAS e continuam a ser relevantes para a extensão atual:
- **Utilizador Anónimo:** Acede a operações básicas e a imagens de pequena dimensão, sem autenticação.
- **Utilizador Registado:** Pode guardar e gerir projetos, com um número limitado de operações diárias.
- **Utilizador Premium:** Tem acesso ilimitado e a funcionalidades avançadas, incluindo IA, colaboração e armazenamento em cloud.

Estes perfis mantêm-se e constituem a base sobre a qual se integram as novas funcionalidades.

2

---

### 3.2. Novos Atores e Papéis Introduzidos

Com o incremento desenvolvido nesta fase, surgem novos atores/papéis diretamente ligados aos novos requisitos:
- **Convidado por Link (Destinatário):** Acede a um projeto partilhado via link com permissões de visualização ou edição (UC07, RF41, RF45 e RNF44).
- **Serviço de IA:** Responsável por processar pedidos do Assistente IA e do Generative Expand (RF40 e RF44).
- **Serviço de Armazenamento Cloud (MinIO):** Permite sincronização entre dispositivos e persistência de projetos (RNF45).
- **Administrador de Sistema:** Garante segurança, privacidade e conformidade RGPD, incluindo encriptação e revogação de partilhas (RNF44).
- **Equipa DevOps/Desenvolvimento:** Responsável pelo desempenho, recuperação automática e manutenção corretiva (RNF43, RNF46, T-0x).

| Stakeholder | Tipo | Objetivos / Interesses | Influência | Riscos | UC/RF/RNF |
|---|---|---|---|---|---|
| **Utilizador Anónimo** | Cliente | Processar imagens simples; experimentar app | Média | Limites diários | RNF48 |
| **Utilizador Registado** | Cliente | Guardar e partilhar projetos | Alta | Segurança e revogação de links | UC07, RF45, RNF44 |
| **Utilizador Premium** | Consumidor | Acesso IA e colaboração | Alta | Latência IA, sincronização cloud | RF44, RF41, RNF43, RNF45 |
| **Convidado por Link** | Externo | Aceder a um projeto partilhado via link, com permissões de visualização/edição, conforme a configuração. | Média | Link inválido, permissões incorretas, conflitos ocasionais de edição. | UC07, RF45, RNF44, RF52-RF57 |
| **Serviço IA Externo** | Sistema | Processar prompts de edição | Alta | Falhas ou latência | RF44, RF40, RNF43 |
| **Serviço Cloud (MinIO)** | Sistema | Sincronizar projetos entre dispositivos | Alta | Consistência de dados | RNF33, RNF45 |
| **Administrador de Sistema** | Interno | Privacidade e segurança | Alta | Incidentes de segurança | RNF44 |
| **Equipa DevOps / Desenv.** | Interno | Fiabilidade e manutenção | Alta | Quedas de serviço | RNF33, RNF43 |

*Tabela 1: Stakeholders e respetivos interesses*

3

---

### 3.3. Integração com os Casos de Uso e Matriz de Rastreabilidade

Os stakeholders identificados relacionam-se diretamente com os novos Casos de Uso definidos nesta fase:
- UC05 - Criar e gerir presets
- UC06 - Assistente IA na edição
- UC07 - Partilhar projeto

A Matriz de Rastreabilidade (Secção 6.3) estabelece as ligações entre estes atores, os requisitos funcionais e não funcionais e o estado de cada requisito (novo/revisto), conforme o modelo definido nas diretrizes.

## 4. Restrições do Projeto

Esta secção identifica as restrições técnicas, legais e de contexto que condicionam o desenvolvimento e a integração das novas funcionalidades introduzidas nesta fase do PictuRAS. As restrições resultam da análise da solução existente, da natureza das novas dependências externas (serviços de IA e armazenamento em cloud) e dos requisitos de segurança e desempenho definidos nos requisitos (Secções 6.1 e 6.2).

| ID | Descrição |
|---|---|
| **R1** | **Dependência de Serviços de IA Externos:** As funcionalidades Assistente IA e Expansão Generativa dependem de APIs externas de processamento de imagem, sujeitas a latência e disponibilidade de rede. A indisponibilidade ou alteração destas APIs limita a execução das operações avançadas. |
| **R2** | **Limite de Armazenamento e Sincronização Cloud:** O serviço de armazenamento MinIO impõe cotas máximas por utilizador e sincronização periódica. O sistema deve respeitar limites definidos pelo fornecedor e garantir consistência entre sessões. |
| **R3** | **Conformidade RGPD e Proteção de Dados:** Todos os projetos, imagens e presets devem cumprir as normas RGPD. É obrigatória a encriptação em trânsito e em repouso. |
| **R4** | **Compatibilidade Multiplataforma e Browser:** A aplicação deve manter compatibilidade com navegadores modernos (Chrome, Edge, Firefox, Safari) e dispositivos móveis (Android $\ge$ 10, iOS $\ge$ 14). Restringe o uso de tecnologias experimentais. |
| **R5** | **Desempenho Mínimo e Limite de Processamento:** Operações com IA não podem exceder 60 s de tempo de resposta médio. Implica controlo de tarefas em fila e limitação de tamanho de imagem. |
| **R6** | **Gestão de Concorrência na Edição Colaborativa:** Para a funcionalidade de colaboração em tempo real, o sistema deve adotar um modelo de controlo de acesso ou bloqueio de sessão. Não é permitido acesso concorrente sem estratégia de resolução. |
| **R7** | **Dependência da Infraestrutura Existente:** O incremento deve manter compatibilidade com a arquitetura base (Node.js, FastAPI e MinIO) do PictuRAS v1.0, sem reestruturar o backend ou a base de dados. |

*Tabela 2: Restrições do Projeto*

Estas restrições definem o enquadramento técnico e operacional para a integração dos novos requisitos. Garantem a coerência com a versão original da aplicação e limitam o espaço de decisão arquitetural para a fase seguinte (design e implementação). Além disso, condicionam diretamente a arquitetura da aplicação. Em particular, a dependência de serviços externos de IA e armazenamento (R1, R2) exige uma abordagem assíncrona e mecanismos de fallback na Fase 2. A conformidade RGPD (R3) e o desempenho mínimo (R5) influenciam a escolha de tecnologias e protocolos de comunicação.

4

---

![Diagrama de Casos de Uso](Figura2_CasosDeUso.png)

## 5. Modelo de Casos de Uso

Nesta secção, serão apresentados os atores do sistema e uma especificação tabelar dos Casos de Uso. O objetivo é contextualizar e descrever sucintamente as funcionalidades mais importantes, identificando simultaneamente as permissões de acesso de cada ator.

O seguinte diagrama de Casos de Uso ilustra estas funcionalidades centrais.

*Figura 2: Diagrama de Casos de Uso.*

De seguida, procedeu-se à especificação dos novos Use Cases concebidos para esta Fase 1, acompanhados da respetiva especificação detalhada que descreve as principais interações entre o utilizador e o sistema, os objetivos de cada funcionalidade e os possíveis fluxos alternativos e/ou de exceção.

5

---

| **UC05 - Criar filtro personalizado (presets)** | |
|---|---|
| **Objetivo:** | Criar um filtro próprio com base em ajustes manuais e guardá-lo como "preset" para uso posterior. |
| **Âmbito:** | Edição de imagem no projeto corrente. |
| **Atores:** | Utilizador |
| **Pré-Condição:** | Utilizador autenticado. |
| **Pós-Condição:** | O preset foi guardado com sucesso na conta do utilizador, o novo preset aparece disponível na lista "Meus Filtros". |
| **Fluxo normal:** | 1. O utilizador seleciona uma imagem para editar.<br>2. O utilizador ajusta manualmente parâmetros como brilho, contraste, saturação e tonalidade.<br>3. O utilizador escolhe a opção "Guardar preset".<br>4. O sistema apresenta uma aba com a preview do preset e é solicitado um nome para o mesmo.<br>5. O utilizador introduz o nome e confirma.<br>6. O sistema guarda o preset associado à conta do utilizador.<br>7. O sistema apresenta uma mensagem de confirmação de sucesso. |
| **Fluxo de exceção 1:** | **[O utilizador cancela o processo]** (passo 5):<br>5.1. O utilizador decide cancelar a gravação do preset.<br>5.2. O sistema cancela a gravação do preset e retorna ao ecrã de edição. |
| **Fluxo de exceção 2:** | **[Limite de presets atingido]** (passo 4):<br>4.1. Se o utilizador já tiver o número máximo de presets (4).<br>4.2. O sistema exibe uma mensagem de limite de presets atingido. |

*Tabela 3: Caso de Uso-05*

6

---

| **UC06 - Assistente IA na edição** | |
|---|---|
| **Objetivo:** | Obter sugestões de filtros/ajustes com base na imagem e numa instrução textual. |
| **Âmbito:** | Edição assistida por IA no projeto corrente. |
| **Atores:** | Utilizador |
| **Pré-Condição:** | Utilizador autenticado; serviço de IA disponível. |
| **Pós-Condição:** | Sugestões apresentadas; ajustes aplicados se aceites pelo utilizador. |
| **Fluxo normal:** | 1. Utilizador abre o projeto e seleciona a imagem.<br>2. Utilizador abre o painel "Assistente IA".<br>3. Sistema apresenta interface de chat/assistente.<br>4. Utilizador escreve pedido.<br>5. Sistema analisa a imagem e o pedido.<br>6. Sistema apresenta sugestões de filtros e parâmetros.<br>7. Utilizador seleciona "Aplicar automaticamente".<br>8. Sistema aplica os ajustes escolhidos e atualiza a imagem. |
| **Fluxo alternativo 1:** | **[Falha no processamento de IA]** (passo 5):<br>5.1. Sistema apresenta mensagem de erro.<br>5.2. Volta ao passo 4. |
| **Fluxo alternativo 2:** | **[Utilizador pretende ajustar manualmente]** (passo 7):<br>7.1. Utilizador seleciona "Ajustar Manualmente".<br>7.2. Utilizador efetua ajustes.<br>7.3. Volta ao passo 8. |
| **Fluxo de exceção 1:** | **[Funcionalidade limitada ao plano]** (passo 3):<br>2.1. Sistema indica indisponibilidade para conta Free e exibe aviso de funcionalidade Premium. |
| **Fluxo de exceção 2:** | **[Utilizador cancela o processo de análise com IA]** (passo 5):<br>5.1. Utilizador seleciona "Cancelar análise".<br>5.2. Sistema cancela pedido à IA e limpa estado. |
| **Fluxo de exceção 3:** | **[Utilizador rejeita sugestões]** (passo 7.1):<br>7.1.2. Utilizador seleciona "Rejeitar sugestões".<br>7.1.3. Sistema descarta sugestões e permanece no editor. |

*Tabela 4: Caso de Uso-06*

7

---

| **UC07 - Partilhar projeto** | |
|---|---|
| **Objetivo:** | Permitir acesso de terceiros a um projeto via link com permissões (ver/editar). |
| **Âmbito:** | Gestão/partilha de projetos. |
| **Atores:** | Utilizador |
| **Pré-Condição:** | Utilizador autenticado. |
| **Pós-Condição:** | Link único gerado, com permissões definidas e revogável a qualquer momento pelo proprietário. |
| **Fluxo normal:** | 1. Utilizador abre o projeto.<br>2. Utilizador seleciona "Partilhar projeto".<br>3. Sistema solicita tipo de permissão (ver/editar).<br>4. Utilizador escolhe a permissão.<br>5. Sistema gera link único com a permissão definida.<br>6. Utilizador copia/partilha o link.<br>7. Destinatário acede ao projeto conforme a permissão. |
| **Fluxo alternativo 1:** | **[Projeto com alterações não guardadas]** (passo 2):<br>2.1. Sistema solicita guardar o projeto.<br>2.2. Utilizador confirma guardar.<br>2.3. Volta ao passo 3. |
| **Fluxo de exceção 1:** | **[Utilizador não guarda projeto]** (passo 2.2):<br>2.2.1. Utilizador não guarda projeto.<br>2.2.2. Sistema cancela o processo de partilha. |
| **Fluxo de exceção 2:** | **[Link expirado/inválido]** (passo 7):<br>7.1. Sistema informa que o link é inválido/expirou. |

*Tabela 5: Caso de Uso-07*

A análise dos novos casos de uso permitiu identificar padrões comuns de interação, nomeadamente a verificação de permissões, a comunicação assíncrona com serviços externos e a gestão de exceções relacionadas com processamento de IA. Estes padrões foram considerados na formulação dos novos requisitos funcionais e não funcionais, assegurando coerência entre a descrição comportamental e as necessidades de implementação.

8

---

## 6. Requisitos de Sistema

### 6.1. Requisitos Funcionais

| **RF39 - Criar e gerir filtros personalizados (presets)** |
|---|
| **Descrição:** O utilizador pode criar filtros personalizados com base em ajustes manuais (brilho, contraste, saturação, tonalidade, etc.) e guardá-los como "presets". Os presets ficam disponíveis na conta do utilizador para uso posterior e podem ser partilhados com outros utilizadores através de link. |
| **Rationale:** Permitir reutilizar configurações frequentes melhora a eficiência e personalização, tal como em aplicações como VSCO e Lightroom. |
| **Origem:** Stakeholders |
| **Fit criterion:** O preset criado é guardado com sucesso e aparece na secção "Meus Filtros"; o utilizador pode aplicá-lo noutros projetos. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 6: Requisito Funcional-39*

| **RF40 - IA de expansão inteligente (Generative Expand)** |
|---|
| **Descrição:** O sistema deve permitir utilizar inteligência artificial para expandir uma imagem de forma coerente com o contexto visual (ex.: prolongar fundo, preencher objetos cortados). |
| **Rationale:** Aumenta as capacidades avançadas de edição, seguindo tendências de IA como Adobe Photoshop Generative Expand. |
| **Origem:** Stakeholders |
| **Fit criterion:** A ferramenta gera extensões de imagem visualmente consistentes em $\ge 90\%$ dos testes. |
| **Prioridade:** Should |
| **Use Case:** UC06 |

*Tabela 7: Requisito Funcional-40*

9

---

| **RF41 - Edição colaborativa em tempo real** |
|---|
| **Descrição:** O sistema deve permitir que dois ou mais utilizadores (dependendo do plano) colaborem simultaneamente no mesmo projeto através de um link seguro de partilha, podendo editar ou visualizar consoante as permissões atribuídas. |
| **Rationale:** A colaboração acelera fluxos de trabalho e aproxima o PictuRAS de ferramentas SaaS modernas (Canva, Figma, Google Docs). |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Quando dois utilizadores acedem ao mesmo projeto, as alterações são sincronizadas e visíveis em tempo real. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 8: Requisito Funcional-41*

| **RF42 - Reversão e reset de edições** |
|---|
| **Descrição:** O utilizador pode reverter passo a passo as edições feitas na sessão atual (até 1 nível de undo) ou restaurar toda a imagem à versão original ("Reset"). |
| **Rationale:** Evita perda de qualidade e dá maior controlo ao utilizador, como em Snapseed ou Photos (Apple). |
| **Origem:** Recolha de feedback / Stakeholders |
| **Fit criterion:** Selecionar "Reverter" restaura a edição anterior; "Reset" devolve a imagem original. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 9: Requisito Funcional-42*

10

---

| **RF44 - Assistente IA para edição guiada** |
|---|
| **Descrição:** A aplicação disponibiliza um assistente virtual baseado em IA que analisa a imagem e sugere filtros e ajustes conforme o pedido textual do utilizador ("Como deixar esta foto com estilo vintage?"). |
| **Rationale:** Facilitar a edição a utilizadores menos experientes e adiciona valor Premium; inspirado em ChatGPT Vision e Canva Magic Assistant. |
| **Origem:** Sondagens / Análise de Mercado |
| **Fit criterion:** O assistente responde com sugestões relevantes em $\ge 90\%$ dos pedidos e aplica ajustes automáticos se o utilizador aceitar. |
| **Prioridade:** Should |
| **Use Case:** UC06 |

*Tabela 10: Requisito Funcional-44*

| **RF45 - Partilhar projetos por link seguro** |
|---|
| **Descrição:** O sistema gera links únicos que permitem partilhar um projeto com outros utilizadores, com níveis de permissão definidos (visualizar / editar). |
| **Rationale:** Promove colaboração e difusão dos trabalhos, similar a Google Docs e Figma. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O link compartilhado abre o projeto correto e respeita as permissões atribuídas. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 11: Requisito Funcional-45*

11

---

| **RF46 - Deteção e Identificação de Pessoas, Animais e Objetos** |
|---|
| **Descrição:** A aplicação deve identificar automaticamente pessoas, animais e objetos presentes na imagem e destacar visualmente cada um deles com um contorno, acompanhado de uma etiqueta indicando o tipo (ex: "Pessoa", "Gato", "Cão", "Carro", etc.). Esta funcionalidade deve complementar os filtros de análise já existentes, que atualmente fornecem apenas uma percentagem de probabilidade do conteúdo da imagem e a sua posição. |
| **Rationale:** De forma a tornar a edição mais interativa e informativa, permitindo ao utilizador saber exatamente onde aplicar filtros, similar ao Google Photos e Snapchat. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A deteção deve ser precisa em pelo menos 90% das imagens testadas em condições normais de iluminação. O utilizador deve poder ativar ou desativar a visualização das etiquetas a qualquer momento. |
| **Prioridade:** Should |
| **Use Case:** UC04 |

*Tabela 12: Requisito Funcional-46*

| **RF47 - Remoção de Pessoas, Animais e Objetos** |
|---|
| **Descrição:** A aplicação deve permitir que, após a identificação de pessoas, animais ou objetos na imagem, o utilizador possa removê-los de forma automática. A remoção deve ser processada de modo a preservar a integridade e a naturalidade da imagem, sem desformatar ou comprometer o contexto visual. |
| **Rationale:** Ao destacar e permitir a remoção de pessoas, animais ou objetos, o utilizador pode personalizar a composição da fotografia, melhorando o resultado final de forma intuitiva e profissional, similar ao Adobe Photoshop e Snapseed. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A remoção de pessoas, animais ou objetos deve manter a imagem coerente e natural em pelo menos 90% dos casos testados. O utilizador deve poder visualizar o resultado antes de confirmar a remoção e desfazer a ação se necessário. |
| **Prioridade:** Should |
| **Use Case:** UC04 |

*Tabela 13: Requisito Funcional-47*

12

---

| **RF48 - Acesso à Partilha** |
|---|
| **Descrição:** O sistema deve fornecer uma opção "Partilhar projeto" acessível dentro de um projeto aberto. |
| **Rationale:** Ponto de entrada essencial para o utilizador iniciar o caso de uso de partilha. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A opção "Partilhar projeto" está visível e acessível na interface de um projeto aberto. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 14: Requisito Funcional-48*

| **RF50 - Forçar Guardar** |
|---|
| **Descrição:** Se existirem alterações não guardadas, o sistema deve solicitar ao utilizador que guarde o projeto antes de continuar com a partilha. |
| **Rationale:** Garante que a versão partilhada está atualizada e consistente com o trabalho final do utilizador. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Quando existem alterações não guardadas, o sistema bloqueia a partilha e apresenta um aviso "Guarde o projeto para partilhar", impedindo a partilha até que o projeto seja guardado. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 15: Requisito Funcional-50*

| **RF51 - Seleção de Permissão** |
|---|
| **Descrição:** O sistema deve solicitar ao utilizador que escolha o tipo de permissão para a partilha (ex: "Ver", "Editar"). |
| **Rationale:** Permite ao proprietário definir o nível de acesso de utilizadores convidados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O sistema apresenta as opções "Ver" e "Editar" e permite selecionar uma delas. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 16: Requisito Funcional-51*

| **RF52 - Geração de Link** |
|---|
| **Descrição:** O sistema deve gerar um link único que contenha a informação da permissão definida. |
| **Rationale:** É o mecanismo técnico que permite a partilha assíncrona com terceiros. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Após selecionar o nível de permissão e clicar em "Gerar Link", o sistema apresenta imediatamente um link único válido, que codifica corretamente as permissões escolhidas e pode ser testado para acesso conforme a definição. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 17: Requisito Funcional-52*

13

---

| **RF53 - Acesso por Link** |
|---|
| **Descrição:** O sistema deve permitir que um destinatário que aceda ao link visualize ou edite o projeto conforme a permissão definida. |
| **Rationale:** Permitir acesso de utilizadores convidados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 1. Ao aceder com link com permissão "Ver", o projeto abre em modo apenas leitura.<br>2. Ao aceder com link com permissão "Editar", o projeto abre com ferramentas de edição ativas.<br>3. O comportamento é consistente em 100% dos testes realizados com links válidos. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 18: Requisito Funcional-53*

| **RF54 - Acesso à Gestão de Links** |
|---|
| **Descrição:** O sistema deve permitir ao utilizador (proprietário) aceder a uma área para gerir as partilhas ativas. |
| **Rationale:** Necessário para que o proprietário possa controlar quem tem acesso aos seus projetos. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O proprietário do projeto consegue aceder a um menu/dashboard que lista os projetos partilhados e os links ativos. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 19: Requisito Funcional-54*

| **RF55 - Revogar Acesso** |
|---|
| **Descrição:** O utilizador deve poder revogar o acesso a um link de partilha gerado anteriormente. |
| **Rationale:** Garante o controlo e segurança do proprietário sobre os seus dados após a partilha. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 1. Proprietário acede à gestão de links.<br>2. Seleciona "Revogar" num link ativo.<br>3. O sistema confirma a revogação. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 20: Requisito Funcional-55*

14

---

| **RF56 - Invalidação de Link** |
|---|
| **Descrição:** Ao ser revogado, o sistema deve invalidar o link, tornando-o inutilizável. |
| **Rationale:** Garante que não é possível o acesso pelo link invalidado. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 1. Sistema revoga o link corretamente.<br>2. Qualquer tentativa de acesso ao link revogado falha.<br>3. Sistema apresenta mensagem de erro clara ao utilizador. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 21: Requisito Funcional-56*

| **RF57 - Gestão de Erro de Link** |
|---|
| **Descrição:** Se um destinatário aceder a um link inválido ou expirado, o sistema deve apresentar uma mensagem de erro. |
| **Rationale:** Fornece feedback adequado ao utilizador final em caso de falha de acesso. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Ao aceder a um link que foi revogado ou nunca existiu, o sistema apresenta "Link inválido ou expirado". |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 22: Requisito Funcional-57*

| **RF58 - Acesso ao Assistente IA** |
|---|
| **Descrição:** O sistema deve disponibilizar uma opção "IA na edição" acessível no painel de edição de imagem. |
| **Rationale:** Permite ao utilizador iniciar o caso de uso e interagir com o assistente de IA. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O botão "IA na edição" está visível e abre o painel de chat quando clicado. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 23: Requisito Funcional-58*

| **RF59 - Interface de Chat/Assistente** |
|---|
| **Descrição:** O sistema deve apresentar uma interface de mensagens que permita ao utilizador introduzir pedidos textuais ao assistente IA. |
| **Rationale:** Proporciona um canal natural de comunicação entre o utilizador e o assistente de IA. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O utilizador consegue escrever e enviar mensagens através da interface de chat. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 24: Requisito Funcional-59*

15

---

| **RF60 - Processamento de Pedido de IA** |
|---|
| **Descrição:** O sistema deve processar o pedido textual do utilizador e analisar a imagem corrente para gerar sugestões. |
| **Rationale:** Centraliza a funcionalidade inteligente de análise e recomendação da IA. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Após o utilizador enviar um pedido, o sistema apresenta sugestões de filtros. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 25: Requisito Funcional-60*

| **RF61 - Apresentação de Sugestões** |
|---|
| **Descrição:** O sistema deve apresentar as sugestões de filtros e parâmetros geradas pela IA de forma compreensível e visual. |
| **Rationale:** O utilizador precisa de visualizar facilmente o impacto das sugestões antes de aplicar. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** As sugestões aparecem listadas com pré-visualização e nomes de filtros (ex: "Vintage", "Contraste suave"). |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 26: Requisito Funcional-61*

| **RF62 - Aplicação Automática de Ajustes** |
|---|
| **Descrição:** O sistema deve permitir que o utilizador aplique automaticamente as sugestões da IA à imagem. |
| **Rationale:** Facilita a utilização rápida das recomendações geradas. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O utilizador seleciona "Aplicar automaticamente" e a imagem é atualizada de imediato. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 27: Requisito Funcional-62*

| **RF63 - Ajuste Manual das Sugestões** |
|---|
| **Descrição:** O sistema deve permitir que o utilizador ajuste manualmente os parâmetros sugeridos pela IA antes da aplicação. |
| **Rationale:** Oferece controlo e personalização sobre o resultado final. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O utilizador pode modificar valores antes de confirmar a aplicação. |
| **Prioridade:** Should |
| **Use Case:** UC06 |

*Tabela 28: Requisito Funcional-63*

16

---

| **RF64 - Sugestão de upgrade para utilizadores não premium** |
|---|
| **Descrição:** Se a conta do utilizador for Free no acesso a uma ferramenta limitada, o sistema deve informar que a funcionalidade é restrita e sugerir upgrade. |
| **Rationale:** Garante a diferenciação funcional entre planos e incentiva a subscrição. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Ao abrir o painel "IA na edição" com conta Free, é exibida uma mensagem "Disponível apenas no plano Premium". |
| **Prioridade:** Should |
| **Use Case:** UC06 |

*Tabela 29: Requisito Funcional-64*

| **RF65 - Gestão de Erros de IA** |
|---|
| **Descrição:** Se ocorrer uma falha no processamento de IA, o sistema deve apresentar uma mensagem de erro e permitir reenviar o pedido. |
| **Rationale:** Assegura robustez e experiência de utilização contínua. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Ao falhar a geração de sugestões, o sistema mostra "Falha no processamento. Tente novamente." e mantém o chat ativo. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 30: Requisito Funcional-65*

| **RF66 - Aplicar preset existente** |
|---|
| **Descrição:** O sistema deve permitir ao utilizador aplicar um preset previamente guardado a qualquer imagem aberta no projeto. |
| **Rationale:** Permite consistência visual entre várias imagens e economiza tempo de edição. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O preset aplicado reproduz os mesmos ajustes de forma automática e fiel. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 31: Requisito Funcional-66*

| **RF67 - Editar preset existente** |
|---|
| **Descrição:** O sistema deve permitir ao utilizador alterar o nome e os parâmetros de um preset já existente. |
| **Rationale:** Garante flexibilidade e personalização contínua das preferências de edição. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O utilizador consegue atualizar um preset e as alterações refletem-se em utilizações futuras. |
| **Prioridade:** Should |
| **Use Case:** UC05 |

*Tabela 32: Requisito Funcional-67*

17

---

| **RF68 - Eliminar preset existente** |
|---|
| **Descrição:** O sistema deve permitir eliminar presets personalizados criados pelo utilizador. |
| **Rationale:** Evita acumulação de presets obsoletos ou desnecessários. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O preset deixa de estar acessível na lista de presets disponíveis após eliminação. |
| **Prioridade:** Should |
| **Use Case:** UC05 |

*Tabela 33: Requisito Funcional-68*

| **RF70 - Verificar autenticação do utilizador** |
|---|
| **Descrição:** O sistema deve validar que o utilizador está autenticado antes de permitir criar, editar ou eliminar presets. |
| **Rationale:** Garante que apenas utilizadores autorizados alteram os seus dados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O sistema impede operações de gestão de presets se o utilizador não estiver autenticado. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 34: Requisito Funcional-70*

| **RF71 - Reverter para versão anterior** |
|---|
| **Descrição:** O sistema deve restaurar a imagem à versão imediatamente anterior quando o utilizador seleciona "Reverter". |
| **Rationale:** Permite desfazer alterações indesejadas. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A imagem é substituída pela versão anterior sem perda de qualidade. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 35: Requisito Funcional-71*

| **RF72 - Restaurar imagem original** |
|---|
| **Descrição:** O sistema deve restaurar a imagem original carregada quando o utilizador seleciona "Reset". |
| **Rationale:** Garante a possibilidade de regressar ao estado inicial da imagem. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A imagem exibida após "Reset" corresponde exatamente ao ficheiro original. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 36: Requisito Funcional-72*

18

---

| **RF73 - Mensagem de ausência de versões anteriores** |
|---|
| **Descrição:** Quando não existirem versões anteriores da imagem, o sistema deve apresentar "Reverter" desativado e uma mensagem informativa. |
| **Rationale:** Evita erro de operação e melhora a experiência do utilizador. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O botão "Reverter" aparece desativado e a mensagem é exibida corretamente. |
| **Prioridade:** Should |
| **Use Case:** UC04 |

*Tabela 37: Requisito Funcional-73*

### 6.2. Requisitos Não Funcionais

| **RNF43 - Performance e tempo de resposta** |
|---|
| **Descrição:** A aplicação deve aplicar filtros comuns (sem IA) em menos de 5 segundos e filtros baseados em IA em menos de 1 minuto, mantendo uma experiência fluida. |
| **Rationale:** Evita frustração e garante fluidez; tempo definido a partir da sondagem de utilizadores. |
| **Origem:** Sondagens |
| **Fit criterion:** 90% das operações testadas concluem-se no limite definido. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 38: Requisito Não Funcional-43*

| **RNF44 - Segurança e privacidade dos dados** |
|---|
| **Descrição:** As fotos, projetos e presets devem ser encriptados em trânsito (TLS 1.2+) e em repouso, acessíveis apenas pelo utilizador autenticado. Devem cumprir RGPD e permitir a revogação de links de partilha. |
| **Rationale:** Protege dados pessoais e garante confiança no serviço. |
| **Origem:** Stakeholders |
| **Fit criterion:** Nenhum ficheiro ou link é acessível sem autenticação válida. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 39: Requisito Não Funcional-44*

19

---

| **RNF45 - Armazenamento flexível (local e cloud)** |
|---|
| **Descrição:** O utilizador pode escolher guardar projetos localmente ou na cloud MinIO, com sincronização entre dispositivos. |
| **Rationale:** Melhora a portabilidade e protege contra falhas locais. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** As edições guardadas ficam acessíveis em outros dispositivos num prazo $\le 5\text{ s}$. |
| **Prioridade:** Should |
| **Use Case:** - |

*Tabela 40: Requisito Não Funcional-45*

| **RNF46 - Verificação de Alterações** |
|---|
| **Descrição:** Antes de partilhar, o sistema deve verificar se o projeto tem alterações não guardadas. |
| **Rationale:** Evita que o utilizador partilhe uma versão desatualizada do projeto, garantindo a consistência dos dados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Ao iniciar a partilha, o sistema deteta automaticamente se há alterações não guardadas e apresenta uma mensagem de aviso ou impede a partilha até que o projeto seja guardado. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 41: Requisito Não Funcional-46*

| **RF47 - Listar presets disponíveis** |
|---|
| **Descrição:** O sistema deve apresentar ao utilizador a lista completa de presets disponíveis (predefinidos e personalizados). |
| **Rationale:** Facilita a seleção e gestão de presets existentes. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A lista é exibida corretamente e contém todos os presets disponíveis. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 42: Requisito Funcional-47*

20

---

| **RNF48 - Exibir limite diário de operações** |
|---|
| **Descrição:** Para contas Gratuitas e Anónimas, o sistema mostra permanentemente na interface o número de operações restantes por dia. |
| **Rationale:** Aumenta a transparência e ajuda a gerir o uso do serviço; modelo similar ao Canva Free Plan. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O número de operações disponíveis é sempre visível e é atualizado automaticamente após cada processamento. |
| **Prioridade:** Should |
| **Use Case:** - |

*Tabela 43: Requisito Não Funcional-48*

| **RNF49 - Segurança do Link** |
|---|
| **Descrição:** Os links de partilha gerados devem ser longos e criptograficamente seguros (impossíveis de "adivinhar"). |
| **Rationale:** Proteger os dados do projeto contra acesso não autorizado por "força bruta" ou adivinhação de URLs. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O link gerado tem um comprimento > 32 caracteres e inclui uma componente de hash/UUID aleatória. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 44: Requisito Não Funcional-49*

| **RNF50 - Desempenho da Geração** |
|---|
| **Descrição:** O link (RF52) deve ser gerado instantaneamente (menos de 1 segundo). |
| **Rationale:** A partilha deve ser uma ação rápida e fluida, sem atrasos percetíveis para o utilizador. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O tempo entre o clique em "Gerar Link" e a apresentação do link é $< 1000\text{ ms}$ em 99% dos casos. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 45: Requisito Não Funcional-50*

21

---

| **RNF52 - Persistência da Partilha** |
|---|
| **Descrição:** O estado de partilha e as permissões de um projeto devem ser guardados permanentemente na base de dados. |
| **Rationale:** O link de partilha deve permanecer ativo entre sessões, até ser explicitamente revogado. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Quando um link de partilha é gerado, ele continua ativo e funcional mesmo após logout/login do utilizador, garantindo que as permissões e o estado do projeto são preservados até revogação explícita. |
| **Prioridade:** Must |
| **Use Case:** UC07 |

*Tabela 46: Requisito Não Funcional-52*

| **RNF53 - Gestão de Concorrência** |
|---|
| **Descrição:** Se a permissão for "Editar", o sistema deve ter uma estratégia para lidar com edições concorrentes. |
| **Rationale:** Prevenir a perda de dados ou corrupção do projeto se dois utilizadores (o proprietário e um convidado) editarem ao mesmo tempo. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** O sistema implementa uma estratégia (ex: "última gravação vence", "bloqueio de sessão" ou colaboração em tempo real). A estratégia deve ser definida e testada. |
| **Prioridade:** Should |
| **Use Case:** UC07 |

*Tabela 47: Requisito Não Funcional-53*

| **RNF54 - Tempo de Resposta da IA** |
|---|
| **Descrição:** O tempo entre o envio do pedido e a apresentação das sugestões deve ser inferior a 10 segundos. |
| **Rationale:** Garante fluidez e experiência positiva de interação. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 95% dos pedidos de IA respondem em $< 3000\text{ ms}$. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 48: Requisito Não Funcional-54*

22

---

| **RNF55 - Clareza das Sugestões** |
|---|
| **Descrição:** As sugestões de filtros e parâmetros devem ser descritos conforme os termos presentes na aplicação. |
| **Rationale:** Melhora a usabilidade e reduz erros de interpretação pelo utilizador. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 90% dos utilizadores reconhecem o tipo de efeito apenas pela pré-visualização e nome. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 49: Requisito Não Funcional-55*

| **RNF56 - Disponibilidade do Serviço de IA** |
|---|
| **Descrição:** O serviço de IA deve estar disponível 99% do tempo, exceto em períodos de manutenção planeada. |
| **Rationale:** Assegura fiabilidade e continuidade do caso de uso. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Monitorização de uptime demonstra $\ge 99\%$ de disponibilidade mensal. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 50: Requisito Não Funcional-56*

| **RNF57 - Privacidade dos Dados** |
|---|
| **Descrição:** As imagens e instruções enviadas para o assistente de IA não devem ser guardadas permanentemente, apenas processadas em memória temporária. |
| **Rationale:** Garante conformidade com políticas de privacidade e proteção de dados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Verificação técnica de que os dados não são persistidos após o processamento. |
| **Prioridade:** Must |
| **Use Case:** UC06 |

*Tabela 51: Requisito Não Funcional-57*

| **RNF58 - Escalabilidade do Serviço de IA** |
|---|
| **Descrição:** O sistema deve suportar múltiplos pedidos simultâneos ao serviço de IA sem degradação perceptível de desempenho. |
| **Rationale:** Garante resposta consistente em ambientes com múltiplos utilizadores. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** 100 pedidos concorrentes resultam em tempo médio de resposta $< 15$ segundos. |
| **Prioridade:** Should |
| **Use Case:** UC06 |

*Tabela 52: Requisito Não Funcional-58*

23

---

| **RNF59 - Modo Escuro** |
|---|
| **Descrição:** A aplicação deve disponibilizar um modo escuro, permitindo que o utilizador alterne entre temas claro e escuro. |
| **Rationale:** Reduzir o cansaço visual e melhorar a experiência em ambientes com pouca luminosidade; Similar ao Youtube, WhatsApp. |
| **Origem:** Sondagens |
| **Fit criterion:** O utilizador consegue ativar ou desativar o modo escuro a partir das definições da aplicação. |
| **Prioridade:** Must |
| **Use Case:** - |

*Tabela 53: Requisito Não Funcional-59*

| **RNF60 - Tempo de aplicação de preset** |
|---|
| **Descrição:** O sistema deve aplicar qualquer preset em menos de 2 segundos. |
| **Rationale:** Assegura uma experiência fluida e responsiva. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** A aplicação de presets é concluída em $\le 2$ segundos em 95% dos casos. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 54: Requisito Não Funcional-60*

| **RNF61 - Reversibilidade sem perda de qualidade** |
|---|
| **Descrição:** O sistema deve garantir que as operações de "Reverter" e de "Reset" não reduzem a qualidade da imagem. |
| **Rationale:** Mantém a integridade visual do conteúdo. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Comparação de hash da imagem antes e após "Reset" é idêntica. |
| **Prioridade:** Must |
| **Use Case:** UC04 |

*Tabela 55: Requisito Não Funcional-61*

| **RNF63 - Armazenamento persistente de presets** |
|---|
| **Descrição:** O sistema deve guardar presets de forma persistente, mantendo-os após encerramento da aplicação. |
| **Rationale:** Garante continuidade entre sessões. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Presets permanecem disponíveis após reinício da aplicação. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 56: Requisito Não Funcional-63*

24

---

| **RNF64 - Consistência de dados de presets** |
|---|
| **Descrição:** O sistema deve evitar duplicações e corrupções nos dados de presets entre sessões. |
| **Rationale:** Mantém integridade e fiabilidade dos dados. |
| **Origem:** Engenheiro de Software |
| **Fit criterion:** Nenhum preset é duplicado ou perdido após 100 ciclos de gravação. |
| **Prioridade:** Must |
| **Use Case:** UC05 |

*Tabela 57: Requisito Não Funcional-64*

| **RNF65 - Limite de utilizadores num Projeto** |
|---|
| **Descrição:** O sistema deve limitar o número de utilizadores que podem colaborar simultaneamente num projeto criado por um utilizador não premium. O limite é de 2 utilizadores por projeto. Contas premium não estão sujeitas a esta restrição. |
| **Rationale:** Garantir desempenho e estabilidade em projetos colaborativos, evitando sobrecarga dos servidores nas contas gratuitas, e incentivando a adesão ao plano premium. |
| **Origem:** Stakeholders |
| **Fit criterion:** Quando o projeto atinge 2 colaboradores (em contas não premium), o sistema impede a adição de novos utilizadores e apresenta uma mensagem de erro. |
| **Prioridade:** Should |
| **Use Case:** UC05 |

*Tabela 58: Requisito Não Funcional-65*

| **RNF66 - Disponibilidade da criação de um preset** |
|---|
| **Descrição:** A opção de criar um preset deve ficar disponível apenas após serem selecionadas pelo menos 2 ferramentas. |
| **Rationale:** Garantir que presets representem combinações úteis de ferramentas e evitar a criação de configurações vazias ou sem valor. |
| **Origem:** Stakeholders |
| **Fit criterion:** Quando são selecionadas 2 ferramentas na edição a opção de criar preset emite um indicador visual que indica a sua disponibilidade. |
| **Prioridade:** Should |
| **Use Case:** UC05 |

*Tabela 59: Requisito Não Funcional-66*

25

---

### 6.3. Matriz de Rastreabilidade

Esta secção apresenta a matriz de rastreabilidade entre os Casos de Uso (UC), os Requisitos Funcionais (RF) e Não Funcionais (RNF) e os Stakeholders identificados.

| UC | RF/RNF | Descrição resumida | Stakeholders principais | Estado |
|---|---|---|---|---|
| **UC05** | RF39; RNF43 | Criar e gerir filtros personalizados (presets); aplicação com tempo de resposta aceitável. | Utilizador Registado; Utilizador Premium; Equipa DevOps/Desenvolvimento | Novo |
| **UC06** | RF44; RNF43; RNF44 | Assistente IA sugere filtros/ajustes via instrução textual; desempenho de operações IA e privacidade/segurança de dados. | Utilizador Premium; Serviço IA Externo; Administrador de Sistema; Equipa DevOps/Desenvolvimento | Novo |
| **UC07** | RNF44, RF45, RF41, RNF45, RNF53 | Partilhar projeto por link (ver/editar); colaboração em tempo real quando em modo editar; segurança/revogação; armazenamento/sincronização cloud; gestão de concorrência. | Utilizador Registado; Convidado por Link (Destinatário); Serviço Cloud (MinIO); Equipa DevOps/Desenvolvimento; Administrador de Sistema | Novo |
| **UC04** | RF42 e RF46; RF47 e RF66; RF71 e RF72; RF73 e RNF43; RNF61 | Operações de edição base (aplicar/gestão de efeitos) estendidas com reversão/reset, deteção/remoção e aplicação de presets; requisitos de desempenho e integridade da imagem. | Utilizador Registado; Utilizador Premium; Equipa DevOps/Desenvolvimento | Revisto |

A matriz permite verificar a coerência entre os Use Cases produzidos e garante que cada requisito é rastreável até à sua origem e justificação, conforme recomendado nas diretrizes da Fase 1.

Em suma, a matriz inclui os casos de uso novos (UC05-UC07) e os respetivos requisitos introduzidos nesta fase, bem como requisitos revistos associados ao UC04 do documento base do PictuRAS. Desta forma, é assegurada a rastreabilidade entre o sistema original e as extensões implementadas nesta fase.

26

---

## 7. Sumário de Elicitação de Requisitos

Esta secção apresenta as técnicas de elicitação utilizadas para identificar, validar e refinar os novos requisitos funcionais e não funcionais introduzidos no incremento da Fase 1. O processo de elicitação decorreu em três etapas principais: brainstorming interno, análise comparativa (benchmarking) e questionário a utilizadores. Estas atividades permitiram alinhar as novas funcionalidades com as necessidades dos stakeholders e com as tendências de aplicações semelhantes no mercado. O uso combinado de brainstorming, benchmarking e questionários permitiu validar as novas funcionalidades junto de diferentes perfis de utilizador, garantindo que os requisitos propostos resultam de necessidades reais e não apenas de suposições da equipa.

| Técnica | Contexto de Aplicação | Stakeholders | Resultado |
|---|---|---|---|
| **Brainstorming em equipa** | Sessões internas com todos os membros do grupo para gerar ideias de novas funcionalidades e identificar limitações do PictuRAS. | Equipa de Desenvolvimento | Originou os requisitos de IA assistente, partilha por link, edição colaborativa e criação de presets. |
| **Benchmarking (Canva, Figma, Photoshop, VSCO)** | Análise de aplicações de referência para compreender padrões modernos de usabilidade e colaboração em edição de imagem. | Equipa de Desenvolvimento | Inspirou a criação da Expansão Generativa e Edição Colaborativa, além de requisitos não funcionais de desempenho e compatibilidade. |
| **Questionário a utilizadores atuais** | Inquérito simples junto de utilizadores registados da versão anterior, focado em usabilidade, tempos de resposta e prioridades de melhoria. | Utilizadores Registados e Premium | Evidenciou necessidade de funções de cancelamento de edição, auto-save e recuperação e limite visível de operações diárias. |

*Tabela 60: Técnicas de elicitação e resultados obtidos*

A combinação destas técnicas permitiu identificar lacunas na versão original do PictuRAS e orientar o incremento para funcionalidades de maior valor para o utilizador final. O processo foi iterativo: após a geração inicial de ideias, os requisitos foram revistos com base no feedback recolhido, garantindo que todos são claros, mensuráveis e rastreáveis aos stakeholders.

27

---

## 8. Modelos UML Comportamentais

### 8.1. Diagrama de Atividades - UC06

Para a modelação comportamental do incremento desenvolvido nesta fase, foi selecionado o Caso de Uso UC06 - Assistente IA na Edição. A escolha deste caso de uso justifica-se pela sua complexidade funcional e relevância estratégica dentro da evolução do sistema PictuRAS. Trata-se de uma funcionalidade central no novo conjunto de requisitos, que introduz uma interação contínua entre o utilizador e um serviço de inteligência artificial, incorporando decisões condicionais, tratamento de erros, limitação por plano de subscrição e possibilidade de cancelamento em tempo real, aspetos estes que representam cenários de fluxo ricos e não lineares.

O diagrama desenvolvido encontra-se sustentado principalmente pelos seguintes requisitos funcionais e não funcionais:
- RF44 - Assistente IA para edição guiada;
- RF58 - Acesso ao Assistente IA;
- RF59 - Interface de Chat/Assistente;
- RF60 - Processamento de Pedido de IA;
- RF61 - Apresentação de Sugestões;
- RF62 - Aplicação Automática de Ajustes;
- RF63 - Ajuste Manual das Sugestões;
- RF64 - Gestão de Limitação por Plano;
- RF65 - Gestão de Erros de IA;
- RNF43 - Performance e tempo de resposta;
- RNF54 - Tempo de resposta da IA;
- RNF55 - Clareza das sugestões;
- RNF56 - Disponibilidade do serviço de IA;
- RNF57 - Privacidade dos dados.

A escolha de um Diagrama de Atividades em detrimento de outros diagramas comportamentais (como o de sequência ou o de estados) deve-se ao facto de este tipo de diagrama evidenciar de forma mais intuitiva o fluxo de ações, decisões e interações entre o utilizador e o sistema, representando claramente as alternativas e interrupções possíveis durante o processo de comunicação com a IA. Enquanto o diagrama de sequência se centra na troca de mensagens entre entidades, o de atividades é mais adequado para modelar o comportamento global do caso de uso, incluindo condições, fluxos paralelos e exceções, que são características que se aplicam perfeitamente ao funcionamento do Assistente IA.

28

---

![Diagrama de Atividades UC06](Figura3_AtividadesUC06.png)

*Figura 3: Diagrama de Atividades referente ao UC06 - Assistente IA na edição.*

O Diagrama de Atividades do UC06 - Assistente IA na Edição apresentado acima descreve, de forma detalhada, o comportamento conjunto entre o Utilizador e o Sistema durante a execução do caso de uso. O diagrama encontra-se dividido em duas swimlanes (Utilizador e Sistema), permitindo distinguir claramente as ações de cada interveniente e o encadeamento das mesmas ao longo do fluxo.

A zona a tracejado corresponde a uma Interruptible Activity Region, que representa o intervalo de tempo em que o pedido de processamento é submetido ao serviço de IA e as sugestões estão a ser geradas. Durante esse período, o utilizador pode optar por cancelar a análise em curso, o que é representado pela ação "Clica 'Cancelar análise'" (um Accept Event Action que simboliza um evento assíncrono). Como o Visual Paradigm não permite ligar diretamente este evento à fronteira da região interrompível, foi introduzida a ação "Interrupção de processamento $IA$" dentro da região, que atua como ponto de entrada do fluxo de interrupção. Esta ação serve como abstração do mecanismo de cancelamento e liga-se à ação

29

---

subsequente "Cancela pedido à IA e limpa estado", situada fora da região, que representa o encerramento do processo e o retorno ao estado anterior.

O diagrama reflete ainda todos os ramos alternativos e de exceção previstos no UC06:
- a validação do plano de subscrição (Premium/Free);
- a deteção de pedidos inválidos;
- o cancelamento do processo de análise da IA;
- as opções de decisão final do utilizador (aplicar automaticamente, ajustar manualmente ou rejeitar sugestões).

Assim, este modelo comportamental complementa o caso de uso textual e traduz visualmente o funcionamento do Assistente IA, clarificando tanto o comportamento nominal do sistema como as condições de erro e cancelamento, contribuindo para uma visão mais precisa e completa do requisito. Este modelo comportamental, além de clarificar o funcionamento do Assistente IA, estabelece também uma base para o desenho arquitetural futuro, permitindo mapear cada ação do utilizador e do sistema em componentes concretos de interface, processamento e comunicação. Assim, o diagrama funciona como um elo entre a especificação de requisitos e a futura modelação da arquitetura lógica do PictuRAS.

30

---

![Diagrama de Atividades UC07](Figura4_AtividadesUC07.png)

### 8.2. Diagrama de Atividades - UC07

O Diagrama de Atividades do UC07 - Partilhar Projeto representa de forma detalhada o fluxo de ações e decisões envolvidas no processo de partilha de um projeto através de um link seguro, com permissões de visualização ou edição.

*Figura 4: Diagrama de Atividades referente ao UC07 - Partilhar projeto.*

A escolha deste caso de uso para modelação comportamental justifica-se pela sua relevância no incremento da Fase 1, por introduzir um mecanismo colaborativo entre utilizadores e envolver três intervenientes distintos: o Utilizador (proprietário do projeto), o Sistema e o Destinatário (convidado por link).

31

---

Esta estrutura motivou a adoção de um diagrama com três swimlanes, permitindo distinguir claramente as responsabilidades e interações entre cada ator.

O diagrama evidencia ainda as decisões críticas associadas ao processo nomeadamente a verificação de alterações não guardadas, o controlo de permissões e a validação de links expirados ou inválidos. Estas ramificações representam fielmente os fluxos alternativos e de exceção definidos no caso de uso, assegurando que a partilha é executada de forma segura e consistente com o estado atual do projeto.

A zona final do diagrama ilustra o acesso do Destinatário ao projeto partilhado e o comportamento do sistema face à validade do link, reforçando a rastreabilidade com os requisitos funcionais RF45-RF57 e não funcionais RNF44-RNF53.

Além disso, é de referir que o link pode ser revogado a qualquer momento pelo proprietário, estando esta revogação implícita na pós-condição do UC07.

Este modelo comportamental complementa o UC07 textual e contribui para uma visão clara do comportamento global da partilha no PictuRAS, clarificando tanto o papel de cada ator como as condições de segurança, revogação e integridade associadas à funcionalidade.

## 9. Tarefas de Manutenção Corretiva da Solução Atual

Durante a análise exploratória realizada na Fase 0 e complementada pela inspeção do código-fonte e da aplicação funcional do PictuRAS, foram identificados diversos comportamentos incorretos, funcionalidades incompletas e divergências entre o sistema implementado e o conjunto de requisitos definidos no Documento de Requisitos v1.0. Estas observações foram obtidas através da execução prática da aplicação (frontend e backend) e da revisão dos artefactos de código disponibilizados no repositório oficial.

Com base nessas evidências, procedeu-se à formulação de tarefas de manutenção corretiva, cujo objetivo é restaurar a conformidade funcional e comportamental do sistema, garantindo que cada componente implementado respeita o comportamento esperado nos casos de uso originais. Estas tarefas não introduzem novas funcionalidades, apenas correspondem a ajustes e correções necessárias para alinhar o sistema real com o seu modelo de requisitos.

Cada tarefa descrita na tabela seguinte apresenta:
- uma descrição objetiva da anomalia identificada;
- a prioridade de correção, definida segundo o impacto no funcionamento global da aplicação;
- os requisitos que sustentam estas correções.

As tarefas foram classificadas em função do seu impacto nos pilares de qualidade do sistema (funcionalidade, usabilidade, desempenho e segurança) priorizando as que comprometem diretamente a execução dos casos de uso principais.

32

---

| ID | Descrição | Impacto | Prioridade | Rel.Req |
|---|---|---|---|---|
| **T-01** | Permitir cancelar o processamento sem me carregar a página e restaurar o estado anterior em <1s. | Funcional e Usabilidade | Alta | RF-17 e RNF-43 |
| **T-02** | Uniformizar mensagens de erro, tornando-as claras e informativas, indicando causa e ação de resolução. Incluir erros da IA e de rede. | Usabilidade e Robustez | Média | RF-65 e RNF-19 |
| **T-03** | Garantir tempos de aplicação dos filtros conforme requisitos e otimizar quando necessário. | Desempenho | Alta | RNF-43 e RNF-54 |
| **T-04** | Corrigir diferenças entre pré-visualização e resultado final, garantindo correspondência total. | Funcional e Desempenho | Média | RNF-13 e RNF-43 |
| **T-05** | Encriptar dados em trânsito e repouso e permitir revogação imediata de links de partilha. | Segurança e Privacidade | Alta | RF-55, RF-56, RNF-44 e RNF-52 |
| **T-06** | Permitir reordenar ferramentas e reaplicar a nova sequência com atualização imediata. | Funcional e Usabilidade | Alta | RF-15 e RNF-43 |
| **T-07** | Validar limite antes de processar, atualizar contador após cada operação e mostrar operações restantes. | Funcional e Usabilidade | Alta | RNF-48 |
| **T-08** | Ao remover conta, apagar/anonimizar dados, projetos e links; pedir confirmação; cumprir RGPD. | Segurança e Privacidade | Alta | RF-23, RNF-38 |
| **T-09** | Permitir que o utilizador consiga escolher em que formato pretende fazer download do projeto | Funcional e Desempenho | Alta | RF-13 |
| **T-10** | Permitir que o utilizador consiga cancelar um processamento de um projeto, exibindo um ícone de cancelamento sempre que a operação demorar mais que 10 segundos. | Funcional e Desempenho | Alta | RF-17 |

33

---

| ID | Descrição | Impacto | Prioridade | Rel.Req |
|---|---|---|---|---|
| **T-11** | Implementar backups automáticos diários dos dados do utilizador para permitir restaurar os mesmos em caso de falha ou perda de dados | Segurança e Robustez | Alta | RNF33 |

*Tabela 62: Tarefas de manutenção corretiva da solução atual*

A execução destas tarefas corretivas é essencial para consolidar a base da aplicação antes da introdução das novas funcionalidades propostas nesta Fase 1. A sua resolução garantirá que os novos incrementos (como o Assistente IA, os presets personalizados e a edição colaborativa) possam ser integrados sobre uma versão estável e coerente do sistema, reduzindo o risco de regressões.

Estas tarefas servirão ainda de ponto de partida para a Fase 2, onde serão definidos os componentes arquiteturais responsáveis por mitigar permanentemente os problemas identificados, assegurando maior robustez e manutenibilidade futura.

## 10. Conclusão

O incremento desenvolvido na Fase 1 do projeto PictuRAS representou uma evolução significativa face ao documento de requisitos original, reforçando a clareza, coerência e completude do sistema. As novas funcionalidades introduzidas, nomeadamente a edição assistida por IA, a partilha por link com permissões, a colaboração em tempo real e a gestão de presets personalizados alinham-se com as tendências atuais de aplicações SaaS de edição de imagem e respondem às necessidades identificadas junto dos stakeholders.

A revisão dos requisitos funcionais e não funcionais permitiu integrar critérios de verificação mensuráveis e assegurar rastreabilidade completa entre casos de uso, requisitos e stakeholders, conforme recomendado nas diretrizes propostas. Foram também definidas restrições técnicas e legais que enquadram a futura implementação, garantindo conformidade com o RGPD, segurança dos dados e compatibilidade multiplataforma.

O processo de elicitação, baseado em brainstorming, benchmarking e questionários, demonstrou-se eficaz para identificar lacunas na versão base e orientar o incremento para funcionalidades de maior valor. As tarefas de manutenção corretiva executadas nesta fase contribuíram para restaurar a conformidade funcional da aplicação e aumentar a fiabilidade e usabilidade do sistema, criando uma base sólida para o desenvolvimento futuro.

Além das melhorias introduzidas, esta fase proporcionou uma análise crítica do estado atual da aplicação, evidenciando os pontos fortes da arquitetura existente (modularidade e escalabilidade) e as suas limitações, como a dependência de serviços externos de IA e restrições de desempenho. Este diagnóstico permitiu definir prioridades realistas e preparar o terreno para decisões arquiteturais mais informadas na fase seguinte.

Em suma, a Fase 1 permitiu modernizar e estabilizar o PictuRAS, tornando-o uma aplicação mais segura, intuitiva e colaborativa, sem comprometer a simplicidade de utilização que caracteriza o projeto original. O trabalho realizado garante maior coerência entre especificações, modelos e implementação, posicionando o PictuRAS num estado de maturidade adequado para avançar para a Fase 2, centrada na modelação e definição da arquitetura do sistema.

Para além dos resultados alcançados, esta fase reforçou o domínio do processo de engenharia de requisitos, demonstrando a importância de uma abordagem iterativa e fundamentada em análise crítica. O PictuRAS encontra-se, assim, num ponto de maturidade que garante estabilidade funcional e conceptual, assegurando que a próxima fase, centrada no desenho arquitetural, se desenvolva sobre bases técnicas sólidas e requisitos claramente validados.

34