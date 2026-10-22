#import "../template.typ": *

= Visão Geral da Extensão de Vídeo

== Funcionalidades de vídeo do MVP

#orientacao[
  Listem *todas* as funcionalidades de vídeo tratadas no relatório, cada uma com o respetivo caso de uso.
  A especificação detalhada está na Parte II, organizada por artefacto (casos de uso, ERS, impacto, …).
  Não há um número mínimo: valoriza-se a *profundidade, coerência e complexidade adequada* de cada funcionalidade.
  Operações triviais (e.g., gerar uma miniatura a partir de um único fotograma) não são suficientes.
  Requisitos partilhados por várias funcionalidades (e.g., submeter vídeo, acompanhar o estado do processamento)
  devem ser especificados *uma só vez* (e.g., `REQ-VID-SUBMIT-001`, com origem em vários casos de uso).
]

A extensão de vídeo nesta fase compreende sete funcionalidades, escolhidas de forma a equilibrar utilidade para os utilizadores, complexidade adequada e possibilidade de especificação e validação no âmbito do MVP. A tabela seguinte apresenta o catálogo de funcionalidades e os respetivos estados de implementação.


A situação apresentada distingue a presença de implementação no código da validação completa da funcionalidade.
A existência de serviços ou testes unitários, por si só, não comprova a execução integral no ambiente entregue.
A UC-VID-006 dispõe de testes automatizados em Docker na versão integrada; as restantes funcionalidades
requerem confirmação conjunta de demonstração, regressão e limites do MVP antes de serem declaradas integralmente validadas.

#tab([Funcionalidades de vídeo do MVP],
  tabela(
    colunas: (1fr, 2.1cm, 2.4cm, 2cm, 2.3cm, 2.6cm),
    [Funcionalidade], [Caso de uso], [Prefixo(s) REQ], [Perfis], [Dependências], [Estado de implementação],
    [Submeter Vídeo para Processamento], [UC-VID-001], [REQ-VID-SUB], [Registado, Premium], [Nenhuma], [],
    [Recorte Temporal de Vídeo (_Trim_)], [UC-VID-002], [REQ-VID-TRIM], [Registado, Premium], [UC-VID-001], [],
    [Aplicar Ferramenta Existente aos Fotogramas de um Vídeo], [UC-VID-003], [REQ-VID-FRM], [Registado, Premium], [UC-VID-001], [],
    [Converter Formato e Resolução de Vídeo], [UC-VID-004], [REQ-VID-CONV], [Registado, Premium], [UC-VID-001], [],
    [Extrair Sequência de Fotogramas de um Vídeo], [UC-VID-005], [REQ-VID-FEX], [Registado, Premium], [UC-VID-001], [],
    [Concatenar Múltiplos Vídeos (_Merge_)], [UC-VID-006], [REQ-VID-MERGE], [Registado, Premium], [UC-VID-001], [],
    [Gerir Áudio do Vídeo  (Remover, Substituir, Extrair)], [UC-VID-007], [REQ-VID-AUD], [Registado, Premium], [UC-VID-001], [],
  ),
)

 A seleção destas funcionalidades reflete um equilíbrio deliberado entre a entrega de valor imediato ao utilizador final e a validação técnica das várias dimensões operacionais do processamento de vídeo:

- *UC-VID-001 — Submeter Vídeo para Processamento:* Constitui a porta de entrada indispensável de todo o ecossistema de vídeo. Permite validar a transferência de ficheiros volumosos para o armazenamento de objetos, a validação estrita de contentores e codecs, a extração de metadados e a aplicação das restrições de dimensão por perfil. Sem esta funcionalidade, nenhuma outra operação de vídeo seria exequível.

- *UC-VID-002 — Recorte Temporal de Vídeo (_Trim_):*  Disponibiliza uma operação essencial de edição, permitindo selecionar e obter apenas os segmentos relevantes de um vídeo, sem modificar o conteúdo original. Constitui um primeiro cenário de transformação temporal com valor direto para o utilizador.

- *UC-VID-003 — Aplicar Ferramenta Existente a Todos os Fotogramas:* Esta funcionalidade é particularmente relevante para o MVP por demonstrar a complementaridade entre os dois tipos de conteúdo e ampliar as possibilidades de transformação audiovisual. Estabelece a ponte arquitetural mais relevante entre o sistema legado de imagens e a nova extensão de vídeo, permitindo estender o domínio do vídeo capacidades de tratamento de imagem já oferecidas pelo PictuRAS. Valida a capacidade de decompor um vídeo em fotogramas individuais, encaminhá-los para os microsserviços de imagem preexistentes sem qualquer alteração aos seus contratos, e recompor o vídeo final. Sem ela, perder-se-ia a oportunidade de capitalizar todo o investimento anterior em ferramentas de imagem.

- *UC-VID-004 — Converter Formato e Resolução de Vídeo:* Permite adequar os vídeos a diferentes necessidades de compatibilidade, qualidade e dimensão. Introduz uma capacidade de transformação frequente e útil, complementando as operações de edição temporal.

- *UC-VID-005 — Extrair Sequência de Fotogramas de um Vídeo:* Conecta o fluxo temporal de volta ao domínio estático, permitindo gerar coleções de imagens a partir de excertos de vídeo. É essencial para tarefas de amostragem, inspeção detalhada e preparação de conteúdos para análise posterior pelas ferramentas avançadas de IA do PictuRAS. Reforça a ligação entre o processamento de vídeo e as funcionalidades de imagem da plataforma.

- *UC-VID-006 — Concatenar Múltiplos Vídeos (_Merge_):* Permite combinar vários vídeos ou excertos numa única narrativa sequêncial, respondendo a uma necessidade comum de composição de conteúdos. Acrescenta ao MVP uma operação que envolve múltiplas entradas e a produção de um resultado audiovisual unificado.

- *UC-VID-007 — Gerir Áudio do Vídeo:* Permite remover, substituir ou extrair a componente sonora de um vídeo, oferecendo maior controlo sobre o conteúdo audiovisual. Complementa as funcionalidades visuais e temporais, assegurando que o MVP contempla também operações sobre áudio, muito úteis para a experiência do utilizador.


== Diagrama de casos de uso (atualizado)

#orientacao[
  *Ponto crítico a atualizar.* O diagrama de base (Figura abaixo) só contém casos de uso de imagem.
  O diagrama atualizado deve:
  - incluir todos os casos de uso UC-VID-nnn (e distinguir visualmente os novos — por exemplo, cor diferente);
  - indicar que perfil (ator) acede a cada um — coerente com as regras de negócio e com a tabela de perfis.
  Podem manter os casos de uso de imagem a cinzento, para dar contexto.
]

#figure(
  image("../images/diagrama_casos_uso.png", width: 85%),
  caption: [Diagrama de casos de uso atualizado (Fase 1 — vídeo)],
)

O diagrama de casos de uso foi atualizado para refletir a extensão do sistema com as novas funcionalidades de processamento e manipulação de vídeo (incremento do MVP de Vídeo). Para facilitar a leitura e manter a coerência visual e contextual em relação ao sistema base, os casos de uso já existentes (relativos à edição de imagem e autenticação) foram mantidos a cinzento, enquanto os novos casos de uso de vídeo são destacados a azul. Os casos de uso de vídeo estão modelados para o Utilizador Registado e Premium; a autorização efetiva exige sempre acesso ao projeto. Na implementação da UC-VID-006, a criação é restrita ao proprietário autenticado, pelo que a herança de permissões do Utilizador Convidado no diagrama não representa, nesta funcionalidade, uma autorização operacional confirmada.

Além de acrescentar os casos de uso de vídeo, corrigiu-se o diagrama base. Nele, os casos de uso "Criar filtro personalizado" e "Partilhar projeto" estavam associados ao Utilizador e, por herança, também ao Utilizador Anónimo, o que contraria as regras de negócio. Passaram a estar associados ao Utilizador Registado, ficando disponíveis apenas para este e para os atores que o herdam. O Utilizador Anónimo mantém o acesso a "Registo", "Login", "Carregar imagens" e "Aplicar encadeamento de ferramentas a conjunto de imagens".

=== Hierarquia de Atores e Regras de Acesso

A modelação da hierarquia de atores foi reformulada para garantir o cumprimento estrito das regras de negócio relativamente às permissões de cada perfil:

- *Utilizador:* Representa a entidade base de interação com o sistema. Agrupa a funcionalidade de Login e o conjunto de ferramentas essenciais de manipulação de imagem.
- *Utilizador Anónimo:* Herda diretamente do *Utilizador*, tendo acesso às operações base de imagem, e estende-o ao adicionar o caso de uso Registo. Esta estruturação garante que o caso de uso *Registo* permanece exclusivo de utilizadores não autenticados.
- *Utilizador Registado:* Herda do *Utilizador* (mantendo acesso às funcionalidades de imagem e autenticação) e adiciona os casos de uso "Criar filtro personalizado" e "Partilhar projeto", bem comoo acesso exclusivo ao processamento de vídeo. É o ponto de entrada modelado para `UC-VID-001` a `UC-VID-007`; cada operação aplica adicionalmente autorização de projeto e, em alguns casos, de propriedade.
- *Utilizador Convidado:* Herda as permissões do *Utilizador Registado*, representando o acesso partilhado com permissões de edição; este acesso não implica autorização para todas as operações de vídeo. A UC-VID-006, por exemplo, exige o proprietário do projeto.
- *Utilizador Premium:* Especialização do *Utilizador Registado* que herda todas as capacidades de imagem e vídeo, acrescentando o acesso a ferramentas avançadas como o *Assistente IA na edição*.

Os novos casos de uso cobrem o ciclo de vida de vídeo; as permissões concretas são validadas no servidor e podem ser mais restritivas do que a generalização de atores ilustrada no diagrama.

=== Decisões de Modelação

A principal decisão de desenho consistiu na introdução do nó *Utilizador Registado* como intermédio na hierarquia de herança de atores. Esta escolha isola explicitamente os recursos computacionalmente pesados (como o processamento de vídeo) dos acessos anónimos, garantindo que o *Utilizador Anónimo* consiga experimentar as ferramentas de imagem sem ter permissão para sobrecarregar a infraestrutura de vídeo antes de efetuar o registo na plataforma.

== Modelo de domínio (atualizado)

#orientacao[
  *Ponto crítico a atualizar.* O modelo de base é centrado em `Imagem`. Com vídeo, pensem (pelo menos) em:
  - Como se relaciona `Vídeo` com `Imagem`? Especialização de um conceito comum (e.g., ficheiro de média),
    ou conceito independente? Que atributos de domínio são relevantes (duração, resolução, formato, …)?
  - Um `Projeto` passa a conter vídeos? Imagens e vídeos misturados?
  - O processamento de vídeo é demorado: há um conceito de *trabalho/pedido de processamento* com estado
    (em fila, em processamento, concluído, falhado, cancelado)? Qual o seu resultado?
  - Que `Ferramenta`s se aplicam a vídeo? As ferramentas de imagem aplicam-se a fotogramas?
  - Como se representam quotas/limites por perfil?
  O modelo de domínio descreve *conceitos do problema*, não classes, tabelas nem microserviços.
  Usem os mesmos termos que nos casos de uso e requisitos (se é "biblioteca", não passa a "galeria").
]

O modelo de domínio da figura seguinte representa a estrutura conceptual do sistema PictuRAS após a extensão
para suporte a vídeo. O diagrama parte do modelo da solução de base e assinala a cinzento os conceitos e
relações que se mantêm, e a azul os que foram acrescentados ou alterados nesta fase.


#figure(
  image("../images/modelo_dominio.png", width: 100%),
  caption: [Modelo de domínio atualizado (Fase 1 — vídeo)],
)

A principal alteração consiste na *generalização do conceito de `Imagem` para `Conteúdo Multimédia`*, do qual `Imagem` e `Vídeo` passam a ser especializações. Esta decisão resulta do facto de ambos desempenharem funções semelhantes no domínio, nomeadamente o carregamento, a organização em projetos e a edição através de ferramentas. A utilização de um conceito comum evita a duplicação de relações e facilita a integração futura de outros tipos de conteúdo. Cada especialização mantém as suas características próprias, sendo particularmente relevantes para o vídeo atributos como a duração, a resolução e o formato.

Consequentemente, a relação entre `Projeto` e `Imagem` é generalizada, permitindo que *um projeto contenha imagens e vídeos em simultâneo*. Da mesma forma, a associação de carregamento passa a estabelecer-se entre `Utilizador` e `Conteúdo Multimédia`, preservando as cardinalidades anteriormente definidas.

Relativamente às ferramentas de edição, mantém-se a distinção entre `Básica` e `Avançada`, incluindo o `Assistente IA` como ferramenta avançada, responsável pela produção de `Sugestão IA`. A relação anteriormente estabelecida entre `Ferramenta` e `Imagem` é substituída por uma associação com `Conteúdo Multimédia`, permitindo representar a aplicação de ferramentas a ambos os formatos. No caso dos vídeos, as ferramentas de edição de imagem podem atuar sobre os respetivos fotogramas, não sendo necessário introduzir novos conceitos de ferramentas específicos para vídeo.

As relações entre os utilizadores e as ferramentas foram também ajustadas, passando a representar a *escolha da ferramenta*, enquanto a execução do processamento é representada pelo novo conceito de `Operação`. Mantêm-se as restrições de acesso existentes, segundo as quais qualquer `Utilizador` pode escolher ferramentas básicas, enquanto as ferramentas avançadas estão reservadas ao perfil `Premium`.

A introdução de `Operação` constitui outra alteração relevante, motivada pela maior duração e complexidade do processamento de vídeo. Este conceito representa um *pedido de processamento com um ciclo de vida próprio*, podendo assumir estados como em fila, em processamento, concluído, falhado ou cancelado. Cada operação é solicitada por um `Utilizador`, está associada a um `Projeto` e utiliza uma `Ferramenta` para realizar o processamento pretendido. Quando concluída com sucesso, a operação produz conteúdo multimédia resultante da transformação. Esta representação permite acompanhar o estado dos pedidos, gerir cancelamentos e manter um histórico das operações realizadas em cada projeto.

Para representar os limites de utilização das ferramentas e dos recursos de processamento, foi introduzido o conceito de *`Quota`*, associado ao perfil `Registado`. Cada utilizador registado possui uma quota, consumida por determinadas operações, permitindo modelar as restrições de utilização previstas na solução, nomeadamente os limites associados às ferramentas avançadas. Este conceito torna-se também particularmente relevante com a introdução do processamento de vídeo, devido ao maior consumo de recursos associado a este tipo de conteúdo.

O modelo contempla ainda uma alteração nos perfis de utilizador, substituindo a especialização `Gratuito` por `Registado` e mantendo `Anónimo` e `Premium`, permitindo distinguir explicitamente os utilizadores que possuem uma conta e aos quais se aplicam os limites de utilização. Esta alteração foi realizada para manter a terminologia e a estrutura do modelo de domínio coerentes com a solução base fornecida, onde o perfil de utilizador com conta é designado por `Registado`. Adicionalmente, a relação `convida`, anteriormente associada ao conceito genérico de `Utilizador`, passa a estar associada a `Registado`, refletindo que apenas utilizadores com conta podem convidar outros utilizadores. A possibilidade de alteração do tipo de conta mantém-se, sem exigir modificações à estrutura conceptual do modelo.

Os restantes conceitos e relações do domínio permanecem inalterados, nomeadamente a gestão de projetos pelo `Utilizador`, a criação de `Preset`, a utilização de ferramentas pelos projetos e a associação de `Sugestão IA` aos projetos. Mantém-se também a relação que permite a um `Preset` conter uma ou mais ferramentas, preservando as funcionalidades existentes de reutilização de configurações de edição.

== Regras de negócio transversais

#orientacao[
  Regras que se aplicam a *várias* funcionalidades ficam aqui, com ID global `RNG-nn`
  (e.g., formatos aceites, como o vídeo conta para a quota diária, tempo de retenção de ficheiros).
  As regras específicas de uma funcionalidade ficam no respetivo caso de uso (RN1, RN2, …) e, nas tabelas
  partilhadas por todas as funcionalidades (ERS, impacto, rastreabilidade), escrevem-se qualificadas
  (`UC-VID-001/RN2`). As decisões de qualidade (`DQ-nnn`) estão reunidas no capítulo de Rastreabilidade.
]

As regras abaixo representam o comportamento especificado para o incremento.
A sua implementação integral deve ser verificada por perfil e por operação: em particular, o
acompanhamento por WebSocket é um objetivo transversal que não deve ser confundido com a consulta periódica
REST usada na interface da UC-VID-006.

#tab([Regras de negócio transversais],
  tabela(
    colunas: (1.8cm, 1fr, 3.8cm, 3cm),
    [ID], [Regra transversal], [Origem / Justificação], [Requisitos associados],
    [RNG-01], [O sistema aceita na Fase 1 (MVP) exclusivamente ficheiros de vídeo no contentor MP4 com codificação de vídeo H.264 e codificação de áudio AAC. Ficheiros sem faixa de vídeo legível ou com formatos incompatíveis são rejeitados na validação preliminar.], [Interoperabilidade universal na web e foco de MVP (UC-VID-001/RN4, UC-VID-004/RN1)], [REQ-VID-SUB-005 a SUB-009 \ REQ-VID-CONV-002 a CONV-005],
    [RNG-02], [Utilizadores anónimos não têm permissão para submeter ou processar vídeos na Fase 1, mantendo apenas o acesso preexistente a ferramentas básicas sobre imagens estáticas.], [Mitigação de riscos de sobrecarga e custos computacionais na nuvem (UC-VID-001/RN1, UC-VID-002/RN4, UC-VID-003/RN1, UC-VID-007/RN1)], [REQ-VID-SUB-002 \ REQ-VID-SUB-003],
    [RNG-03], [A submissão/upload de ficheiros de vídeo não é contabilizada na quota diária. Cada operação de processamento de vídeo confirmada consome exatamente uma unidade da quota diária de operações avançadas para utilizadores registados (limite de 5 operações/dia). Utilizadores premium não têm limite diário.], [Sustentabilidade do modelo SaaS e incentivo ao upload sem penalização prévia (UC-VID-001/RN5, UC-VID-002/RN3, UC-VID-003/RN2, UC-VID-006/RN4, UC-VID-007/RN2)], [REQ-VID-SUB-025 \ REQ-VID-COM-004 a COM-008],
    [RNG-04], [São impostos limites técnicos por perfil: utilizadores registados estão limitados a 100 MB, 5 minutos de duração, resolução até 1080p e 60 fps; utilizadores premium têm limites de 1 GB, 30 minutos, resolução até 4K (3840×2160) e 60 fps. Ficheiros que excedam estes limiares são rejeitados antes da persistência.], [Proteção da infraestrutura e diferenciação comercial entre planos (UC-VID-001/RN2,RN3, UC-VID-003/RN3, UC-VID-004/RN2, UC-VID-006/RN2)], [REQ-VID-SUB-016 a SUB-023 \ REQ-VID-CONV-006, CONV-007 \ REQ-VID-MERGE-002, MERGE-003, MERGE-006, MERGE-007],
    [RNG-05], [O ficheiro de vídeo de origem é estritamente imutável, nunca sendo substituído, corrompido ou eliminado durante o processamento. O resultado de qualquer operação concluída com sucesso é persistido como um novo conteúdo na biblioteca do projeto.], [Preservação da integridade de dados e facilidade de recuperação e edição não-destrutiva (UC-VID-002/RN2, UC-VID-004/RN5, UC-VID-005/RN5, UC-VID-006/RN3, UC-VID-007/RN3, DQ-003)], [REQ-VID-COM-017 \ REQ-VID-Q-004 \ REQ-VID-TRIM-011 \ REQ-VID-CONV-010 \ REQ-VID-AUD-012],
    [RNG-06], [Todas as operações de processamento de vídeo são executadas de forma assíncrona através de filas de mensagens (RabbitMQ), registando os estados discretos `em fila`, `em processamento`, `concluída`, `falhada` ou `cancelada`, e emitindo eventos de progresso via WebSocket para os clientes autorizados.], [Experiência de utilização não bloqueante em operações demoradas e desacoplamento de serviços (UC-VID-002/RN6, DQ-001)], [REQ-VID-COM-009 a COM-013 \ REQ-VID-COM-020 \ REQ-VID-Q-002, Q-003, Q-016],
    [RNG-07], [Em caso de falha de processamento ou cancelamento a pedido do utilizador, todos os artefactos parciais e ficheiros temporários no armazenamento de objetos são eliminados de imediato, garantindo a ausência de ficheiros órfãos e devolvendo qualquer quota previamente reservada.], [Consistência do sistema e justiça na gestão de quotas diárias (UC-VID-001/RN6, UC-VID-002/RN7, UC-VID-006/RN5, UC-VID-007/RN4, DQ-004)], [REQ-VID-SUB-024 \ REQ-VID-COM-007, COM-008 \ REQ-VID-COM-014 a COM-016 \ REQ-VID-Q-007, Q-013 a Q-015],
    [RNG-08], [A aplicação de ferramentas de imagem a vídeos é restrita a serviços que aceitem e produzam exatamente uma imagem por fotograma. O vídeo de saída recomposto mantém obrigatoriamente a taxa de fotogramas, resolução e faixa sonora original, salvo especificação explícita em contrário.], [Garantia de coerência audiovisual e interoperabilidade com microsserviços legados de imagem (UC-VID-003/RN1-RN5, DQ-002)], [REQ-VID-FRM-001 a FRM-010 \ REQ-VID-FRM-014 \ REQ-VID-Q-006],
  ),
)

== Convenções de identificação

De forma a manter a consistência metodológica exigida pelas diretrizes do projeto e garantir uma rastreabilidade sem ambiguidades ao longo de todo o dossiê de engenharia, são adotadas as convenções de identificação discriminadas na tabela abaixo.

#tabela(
  colunas: (4.4cm, 1fr),
  [Identificador], [Utilização e convenção],
  [UC-VID-nnn], [Caso de uso de vídeo, numerado sequencialmente a partir de `UC-VID-001`. Identifica univocamente a especificação funcional de cada capacidade introduzida.],
  [REQ-VID-{FUNC}-nnn], [Requisito funcional ou não funcional. `{FUNC}` identifica a funcionalidade ou a área do serviço(`SUB` para submissão, `TRIM` para recorte, `FRM` para fotogramas, `CONV` para conversão, `FEX` para extração, `MERGE` para concatenação, `AUD` para gestão de áudio, `COM` para requisitos comuns/transversais, `Q` para requisitos de qualidade).],
  [RN#emph[k], A#emph[k], Q#emph[k], FA#emph[k]], [Regra, assunção, questão em aberto e fluxo alternativo específicos de um caso de uso. Nas tabelas partilhadas do relatório são referenciados sob a forma qualificada (e.g., `UC-VID-001/RN2`).],
  [RNG-nn], [Regra de negócio transversal ao sistema.],
  [DQ-nnn], [Decisão de qualidade global.],
  [DA-nn], [Decisão arquitetural, documentada formalmente no Capítulo de Arquitetura.],
  [TST-{FUNC}-nn], [Caso de teste (manual ou automatizado) associado à verificação de requisitos.],
  [T-nn], [Tarefa de manutenção corretiva da solução de base.],
  [UCnn, RFnn, RNFnn], [Elementos preexistentes do documento de requisitos de base (`doc-ext-requisitos.pdf`), explicitamente citados sempre que são objeto de alteração ou extensão (`ALT`).],
)
