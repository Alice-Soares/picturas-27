#import "../template.typ": *

= Introdução

#orientacao[
  Uma a duas páginas, no máximo. Devem responder a:
  - *Propósito do incremento*: que suporte a vídeo foi acrescentado ao PictuRAS e porquê (lógica de MVP).
  - *_Baseline_*: em que versão do sistema se basearam — documento de requisitos, documento de solução
    arquitetural e repositório base (indicar _commit_ de partida).
    Este relatório *estende* esses documentos; não os reescreve.
  - *Resumo do que foi feito*: funcionalidades especificadas e implementadas (remeter para a Tabela do Capítulo 3).
  - *Organização do documento*: Parte I (transversal), Parte II (especificação: casos de uso, ERS, impacto,
    rastreabilidade), Parte III (arquitetura, IA, testes).
]

== Propósito do incremento


O *PictuRAS* é uma plataforma _Software as a Service_ (SaaS), baseada numa arquitetura de microsserviços, destinada ao processamento e à transformação de conteúdos multimédia. Na sua versão de base, a plataforma encontra-se orientada para a manipulação de imagens digitais, disponibilizando operações convencionais, como rotação, recorte e ajuste de brilho e contraste, bem como funcionalidades avançadas baseadas em Inteligência Artificial (IA), incluindo remoção de fundo, super-resolução e deteção de objetos. Estas capacidades são complementadas por mecanismos de organização em projetos, composição de operações através de _pipelines_ e gestão de diferentes perfis de utilização.

No âmbito da Fase 1 da unidade curricular de Requisitos e Arquiteturas de Software, o presente trabalho tem como objetivo *estender o PictuRAS com funcionalidades de manipulação de vídeo digital*, alargando o domínio de aplicação da plataforma e procurando reutilizar, sempre que adequado, as capacidades e os mecanismos já existentes.

Esta extensão é desenvolvida segundo uma abordagem de *Produto Mínimo Viável (MVP)*, privilegiando a seleção de funcionalidades relevantes, de complexidade adequada e passíveis de especificação, implementação e validação no contexto desta fase. Pretende-se, assim, demonstrar a viabilidade funcional e arquitetural da integração de vídeo no PictuRAS, sem exigir, nesta etapa, os níveis de robustez, escalabilidade e desempenho característicos de uma solução preparada para produção.

A introdução de vídeo implica, contudo, considerar características próprias deste tipo de conteúdo, nomeadamente a sua dimensão, natureza temporal e exigências de processamento. Estas particularidades orientam a definição dos novos requisitos e a identificação das adaptações necessárias à arquitetura existente, cuja especificação e fundamentação são desenvolvidas ao longo do relatório.


== _Baseline_ e repositório

Em estrita conformidade com o princípio de *"extensão, não reescrita"*, este trabalho toma como ponto de partida inequívoco os artefactos e a base de código disponibilizados pela equipa docente e pelos trabalhos prévios, documentando apenas o _delta_ estritamente introduzido pela componente de vídeo. Os elementos de partida considerados e as coordenadas de entrega do projeto são discriminados na tabela seguinte:


#tabela(
  colunas: (5.2cm, 1fr),
  [Artefacto], [Versão / Referência],
  [Documento de requisitos de base], [`doc-ext-requisitos.pdf` (especificação de requisitos da versão anterior)],
  [Documento de solução arquitetural de base], [`doc-sol-arquitetural.pdf` (descrição da arquitetura existente)],
  [Repositório de partida], [#link("https://github.com/picturas-um/picturas-27")[github.com/picturas-um/picturas-27] \ (_commit_ `781a63ebc453b45aed2fcf2afac6adc6380c7c7d`)],
  [Repositório da solução desenvolvida], [#link("https://github.com/Alice-Soares/picturas-27")[github.com/Alice-Soares/picturas-27] \ (Entrega: `solucao-ext-mvp.zip`)],
  [Documento de extensão de requisitos], [`doc-ext-requisitos.pdf` (compilado a partir das fontes Typst em `src-doc-ext-requisitos.zip`)],
  caption: [Artefactos de referência e identificação da solução desenvolvida.],
) 


Todos os requisitos e casos de uso preexistentes referenciados neste relatório mantêm os seus identificadores originais (`UCnn`, `RFnn`, `RNFnn`) sempre que são objeto de alteração (`ALT`) ou de extensão, sendo os novos requisitos categorizados exclusivamente sob o prefixo normalizado `REQ-VID-{FUNC}-nnn` e os novos casos de uso sob `UC-VID-nnn`.

== Resumo do trabalho realizado


*TODO:* REVER ESTA SECÇÃO PARA COERENCIA

O trabalho desenvolvido compreende a especificação, implementação e validação de uma extensão funcional do PictuRAS orientada para o processamento de vídeo digital.

Ao nível da especificação, foram analisadas as necessidades associadas à introdução de vídeo, definidos os casos de uso e requisitos correspondentes e identificadas as alterações necessárias aos elementos existentes da plataforma. Este processo incluiu a revisão do modelo de domínio, das regras de negócio e das restrições aplicáveis aos diferentes perfis de utilização.

O âmbito funcional considerado abrange a submissão e validação de vídeos, operações de edição e transformação, como recorte temporal e conversão de formato ou resolução, e funcionalidades de extração e processamento de fotogramas. A seleção destas capacidades procura estabelecer uma base funcional coerente para a evolução da plataforma, aproveitando, quando aplicável, mecanismos de processamento já disponíveis para imagens.

A componente de desenvolvimento contempla as adaptações arquiteturais e a integração das funcionalidades selecionadas na solução existente, com recurso a ferramentas e agentes de Inteligência Artificial como apoio às atividades de engenharia de software. A validação do incremento é realizada através de testes, permitindo avaliar o cumprimento dos requisitos e identificar limitações da solução.

A relação entre as funcionalidades especificadas, os respetivos casos de uso e requisitos, as dependências e o estado efetivo de implementação encontra-se sistematizada na tabela-resumo da Secção 3.1. Esta distinção permite delimitar o âmbito do MVP efetivamente concretizado face às funcionalidades apenas especificadas ou parcialmente implementadas.


== Organização do documento

O relatório encontra-se organizado em três partes complementares, refletindo as diferentes etapas de especificação, desenvolvimento e validação do incremento.

A *Parte I — Enquadramento e Visão Transversal* apresenta o contexto do trabalho, as alterações aos perfis de utilização e aos intervenientes do sistema, bem como uma visão global das funcionalidades de vídeo, do modelo de domínio e das regras de negócio associadas.

A *Parte II — Especificação das Funcionalidades de Vídeo* desenvolve os casos de uso e os requisitos funcionais e não funcionais, analisa o impacto da extensão sobre o sistema existente e estabelece as relações de rastreabilidade entre os diferentes artefactos de especificação.

A *Parte III — Arquitetura, IA e Validação* descreve as alterações arquiteturais realizadas, a utilização de agentes de Inteligência Artificial durante o desenvolvimento, os testes efetuados e as intervenções corretivas sobre a solução de base. Por fim, apresenta as conclusões do trabalho e identifica possíveis direções de evolução para a fase seguinte.

Esta estrutura procura assegurar uma visão integrada do processo de engenharia de software, desde a identificação das necessidades e a definição dos requisitos até à sua realização arquitetural e verificação através de testes.