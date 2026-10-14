# PictuRAS
**Requisitos e Arquiteturas de Software**  
**Mestrado em Engenharia Informática**  
**Universidade do Minho**  
**21 de setembro de 2026**

Nos anos letivos anteriores, várias equipas desenvolveram a aplicação PictuRAS, uma aplicação WEB para processamento de imagens (incluindo fotografias), disponível na cloud para utilização por qualquer pessoa. O ponto de partida deste ano será o trabalho de uma das equipas do ano passado, incluindo: documentação de requisitos, documentação de arquitetura e a própria implementação da aplicação.

## Aplicação existente

A aplicação PictuRAS é uma plataforma web de processamento de imagens em ambiente cloud, desenvolvida nos anos letivos anteriores. As suas principais características são:

* **Perfis de utilização:** anónimo (operações limitadas em imagens pequenas), registado (gratuito, até cinco operações por dia) e premium (pago, uso ilimitado). Este modelo diferencia a oferta e garante sustentabilidade.
* **Modelo de negócio:** disponibilização como Software as a Service (SaaS), com foco em subscrições premium, mantendo opções gratuitas para atrair novos utilizadores.
* **Ferramentas:** operações sobre imagens representadas por ferramentas. Podem ser básicas (e.g., redimensionamento, binarização, rotação) ou avançadas (e.g., OCR, contagem de pessoas, identificação de objetos).
* **Encadeamento e processamento em lote:** é possível combinar várias ferramentas em sequência e aplicar processos completos a múltiplas imagens em simultâneo (via zip ou diretoria).

## Organização do projeto

O projeto prático deste ano letivo estará dividido em três fases. As duas primeiras, de caráter obrigatório, são desenvolvidas em grupo de 5 elementos; a terceira, facultativa, é desenvolvida individualmente. A classificação final terá um máximo de 20 valores: 7,5 valores (Fase 1) + 7,5 valores (Fase 2) + 5 valores (Fase 3, facultativa).

No final da Fase 1, a equipa docente seleciona, de entre os projetos desenvolvidos pelas várias equipas, um que servirá de base de trabalho para a Fase 2 (e, subsequentemente, para a Fase 3).

Em todas as fases, o desenvolvimento e a reestruturação de código devem ser apoiados por agentes de IA. Os alunos devem documentar as ferramentas e skills utilizadas, enumerar as tarefas apoiadas e comprovar a validação realizada. Os alunos são sempre os responsáveis pelo código entregue, incluindo aquele gerado por IA: devem revê-lo, testá-lo e conseguir fundamentar todas as decisões e alterações efetuadas.

---

### Fase 1: Suporte a vídeo
**Grupo de 5 elementos** | **7,5 valores**

Atualmente a aplicação está limitada ao processamento de imagens. Cada equipa deve começar por estudar a solução disponibilizada, nomeadamente o documento de requisitos, a solução arquitetural proposta e a respetiva implementação. O objetivo da $1^a$ fase é estender a aplicação com novas funcionalidades de manipulação de vídeos digitais, numa lógica de MVP (produto mínimo viável) — isto é, com foco na validação funcional das novas funcionalidades, sem que seja exigido o mesmo nível de robustez, desempenho ou qualidade não funcional esperado de uma solução em produção. Entre outras, é previsível que as equipas se deparem com as seguintes tarefas:

* Levantamento de requisitos para as novas funcionalidades de vídeo.
* Identificação e implementação de eventuais alterações arquiteturais.
* Produção de código assistida por agentes de IA (e.g., criação de microserviços).
* Integração das novas funcionalidades na aplicação existente.
* Testes ao sistema (automáticos e manuais).

No final desta fase, a equipa docente escolherá um dos projetos, que servirá de base à Fase 2.

---

### Fase 2: Melhoria de aspetos não funcionais (refactoring)
**Grupo de 5 elementos** | **7,5 valores**

Partindo do projeto selecionado pela equipa docente no final da Fase 1, cada equipa deve escolher e melhorar dois aspetos não funcionais do sistema (e.g., desempenho, escalabilidade, manutenibilidade, segurança), por via de refactoring, sem introduzir novas funcionalidades. Entre outras, é previsível que as equipas se deparem com as seguintes tarefas:

* Definição dos requisitos não funcionais a melhorar.
* Reestruturação do código, assistida por agentes de IA.
* Avaliação do impacto dos requisitos não funcionais, demonstrando a melhoria alcançada.

---

### Fase 3: Integração de novas funcionalidades
**Individual** | **Facultativo** | **5 valores**

Cada aluno deve, individualmente, integrar três novas funcionalidades de vídeo, escolhidas de entre as desenvolvidas pelas diferentes equipas na Fase 1. O objetivo desta fase é obter uma solução production-ready, com as novas funcionalidades integradas de forma robusta e madura. Entre outras, é previsível que os alunos se deparem com as seguintes tarefas:

* Identificação e implementação de eventuais alterações arquiteturais.
* Produção de código assistida por agentes de IA.
* Integração robusta das três novas funcionalidades na aplicação selecionada.
* Testes abrangentes ao sistema.
* Preparação da solução para produção (e.g., documentação e configuração de deployment).

---

## Prazos de entrega

### Fase 1
* **Entrega da extensão da aplicação com suporte a vídeo:** 16.out
* **Defesa do trabalho:** 19-23.out

### Fase 2
* **Entrega da implementação reestruturada e do relatório de definição e avaliação dos requisitos não funcionais (LaTeX e PDF):** 20.nov
* **Defesa do trabalho:** 23-27.nov

### Fase 3
* **Entrega da integração das novas funcionalidades:** 8.jan
* **Defesa da implementação:** 11-15.jan