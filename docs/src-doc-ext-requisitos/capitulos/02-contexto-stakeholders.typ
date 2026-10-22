#import "../template.typ": *

= Contexto, Perfis e _Stakeholders_ (revisão)

#orientacao[
  Capítulo de *revisão*: só registam o que muda com o vídeo. Não copiem o documento de base.
  - Os *perfis de utilização* (anónimo, registado, premium) continuam válidos? Que limites passam a
    existir para vídeo (duração, tamanho, resolução, nº de operações)? Um vídeo conta como uma operação?
  - Surgem *novos _stakeholders_* ou *interesses novos* nos existentes (e.g., custo de processamento e armazenamento
    para o proprietário do sistema; equipa de operações)?
  - Os _stakeholders_ aqui listados devem ser os mesmos que aparecem na secção "_Stakeholders_ e Interesses"
    de cada caso de uso — usem os mesmos nomes.
]

A introdução de capacidades de vídeo digital no PictuRAS constitui uma evolução substantiva face ao domínio exclusivo de processamento de imagem estática. O tratamento de fluxos de vídeo envolve ficheiros com ordens de grandeza muito superiores em termos de volume de dados, além de exigir operações computacionalmente intensivas. Estas características exigem a revisão criteriosa dos perfis de utilização, das políticas de quotas e dos interesses dos vários intervenientes (*stakeholders*), de modo a assegurar a viabilidade técnica e a sustentabilidade dos recursos.


== Perfis de utilização e vídeo

Os perfis *Anónimo*, *Registado* e *Premium* definidos na _baseline_ mantêm-se válidos, isto é as regras atuais de acesso e quotas para imagens continuam em vigor. A introdução de vídeo não implica a criação de novos perfis, mas exige a definição de limites específicos de submissão e processamento, bem como a clarificação da contabilização das operações nas quotas existentes.

O perfil *Anónimo* não dispõe de acesso às funcionalidades de vídeo no MVP, de modo a evitar a utilização intensiva de recursos computacionais por utilizadores não autenticados. Para o perfil *Registado*, são estabelecidos limites conservadores de submissão e processamento, adequados à natureza gratuita do serviço e à necessidade de controlar o consumo de recursos. Decidiu-se ainda que cada operação de processamento de vídeo aceite conta como uma operação avançada, independentemente da quantidade de fotogramas ou ficheiros envolvidos, e fica sujeita à quota diária existente de 5 operações avançadas. A submissão de um vídeo por um utilizador não consome uma operação da quota e uma operação que falhe, seja cancelada ou termine sem produzir alterações também não consome quota.

Por sua vez, o perfil *Premium*, embora não esteja sujeito a quotas diárias de operações, mantém limites técnicos sobre os vídeos submetidos, ainda que mais permissivos, de forma a prevenir cargas de processamento excessivas e assegurar a estabilidade e sustentabilidade da plataforma. 


A @tab-perfis-video sintetiza as condições de acesso estabelecidas para o MVP, evidenciando as diferenças entre perfis e as regras de negócio transversais que as fundamentam.

#tab([Perfis de utilização e respetivo acesso a vídeo],
  tabela(
    colunas: (2.6cm, 4.0cm, 1fr, 2.8cm),
    [Perfil], [Situação na _baseline_], [Alteração introduzida para vídeo], [Regras / requisitos],
    [Utilizador Anónimo], [Operações de imagem limitadas e imagens pequenas; sem autenticação], [As regras de imagem da _baseline_ mantêm-se. Sem acesso a submissão ou processamento de vídeo no MVP.], [UC-VID-001/RN1 \ UC-VID-002/RN4 \ UC-VID-003/RN1 \ UC-VID-007/RN1 \ RNG-02],
    [Utilizador Registado], [Operações básicas de imagem sem limite diário; quota de 5 operações avançadas de imagem por dia; projetos persistentes], [Para vídeo: submissão até 100 MB, 5 min, 1920×1080 e 60 fps, sem consumir quota. Cada operação aceite de processamento conta como 1 operação avançada (mesmo que processe vários fotogramas/ficheiros) e usa a quota diária de 5; falhas, cancelamentos e operações sem efeito não consomem quota.], [UC-VID-001/RN2,RN5,RN6 \ UC-VID-002/RN3,RN7 \ UC-VID-003/RN2,RN3 \ UC-VID-004/RN2,RN3 \ UC-VID-005/RN2,RN3 \ UC-VID-006/RN1,RN2,RN4 \ UC-VID-007/RN2,RN4 \ RNG-03, RNG-04],
    [Utilizador Premium], [Sem quota diária de operações avançadas de imagem; acesso a funcionalidades avançadas/IA], [Para vídeo: sem quota diária de processamento, mas com limites técnicos. Submissão até 1 GB, 30 min, 3840×2160 e 60 fps; concatenação até 15 vídeos e extração até 5000 fotogramas.], [UC-VID-001/RN3 \ UC-VID-003/RN3 \ UC-VID-004/RN2 \ UC-VID-005/RN2 \ UC-VID-006/RN1,RN2 \ RNG-03, RNG-04],
),
) <tab-perfis-video>


== _Stakeholders_ e interesses

A introdução de vídeo não altera substancialmente o conjunto de intervenientes do PictuRAS, mas acrescenta novos interesses e responsabilidades aos já identificados na solução de base. A revisão incide, sobretudo, na utilização das novas funcionalidades, no controlo dos recursos computacionais e na manutenção da qualidade do serviço. A nomenclatura dos intervenientes coincide integralmente com a utilizada na secção de cabeçalho de cada caso de uso, detalhando-se os seus interesses específicos e desdobramentos operacionais na tabela seguinte. 

#tab([_Stakeholders_ e interesses (novos ou revistos)],
  tabela(
    colunas: (3.2cm, 1.8cm, 1fr, 1.8cm, 2.8cm),
    [_Stakeholder_], [Estado], [Interesse(s) relativamente ao vídeo], [Influência], [UC / requisitos],
    [Utilizador Registado], [Revisto], [Submeter e transformar vídeos através dos fluxos implementados (recorte, frame-tool, conversão, concatenação, extração e gestão de áudio), com acompanhamento de estado e preservação do original.], [Alta], [UC-VID-001 a UC-VID-007; REQ-VID-SUB; REQ-VID-TRIM; REQ-VID-FRM; REQ-VID-CONV; REQ-VID-FEX; REQ-VID-MERGE; REQ-VID-AUD],
    [Utilizador Premium], [Revisto], [Executar os fluxos de vídeo implementados dentro dos limites técnicos premium e sem quota diária de operações avançadas.], [Alta], [UC-VID-001 a UC-VID-007; REQ-VID-SUB-020 a REQ-VID-SUB-023; RNG-03, RNG-04],
    [Utilizador Anónimo], [Revisto], [Manter o acesso às ferramentas de imagem estática; vídeo exige perfil autenticado autorizado.], [Média], [UC-VID-001; REQ-VID-SUB-001 a REQ-VID-SUB-003; RNG-02],
    [Proprietário do Sistema], [Novo], [Controlar custos computacionais e de armazenamento e assegurar aplicação consistente das quotas por perfil.], [Alta], [UC-VID-001 a UC-VID-007; RNG-01 a RNG-07; REQ-VID-COM-004 a REQ-VID-COM-008],
    [Equipa de Desenvolvimento], [Revisto], [Manter os fluxos de imagem compatíveis, tratar falhas e facilitar a manutenção das operações assíncronas de vídeo.], [Alta], [UC-VID-001 a UC-VID-007; REQ-VID-COM-009 a REQ-VID-COM-020; REQ-VID-Q-001 a REQ-VID-Q-016],
    [Armazenamento de objetos], [Revisto], [Persistir conteúdos originais e resultados derivados, mantendo isolamento de objetos por projeto.], [Média], [UC-VID-001 a UC-VID-007; REQ-VID-SUB-015, REQ-VID-SUB-024, REQ-VID-COM-014 a REQ-VID-COM-018],
    [Convidado por link], [Não confirmado para vídeo], [As permissões de edição por link aplicam-se à baseline de projetos; acesso do convidado às operações de vídeo não é declarado até ser decidido e validado.], [Média], [REQ-VID-COM-001 a REQ-VID-COM-003; decisão pendente para vídeo partilhado],
    [Administrador de sistema], [Revisto], [Assegurar políticas de segurança e privacidade aplicáveis aos conteúdos e projetos.], [Alta], [REQ-VID-COM-001 a REQ-VID-COM-003, REQ-VID-COM-019],
  ),
  )

Os restantes _stakeholders_ da solução de base mantêm-se inalterados e, por isso, não se repetem aqui.


== Elicitação de requisitos

A identificação das funcionalidades, regras de negócio e requisitos da extensão de vídeo teve como ponto de partida a análise dos documentos de requisitos e de arquitetura da _baseline_, do código disponibilizado e das diretrizes da Fase 1. Esta análise permitiu reconhecer as capacidades existentes suscetíveis de reutilização, as restrições impostas pelos perfis de utilização e as adaptações necessárias para suportar operações sobre vídeo. A seleção das funcionalidades foi orientada pela sua relevância para o utilizador, pela complexidade técnica e pela possibilidade de implementação e validação no âmbito do MVP.

A definição das políticas de acesso e contabilização procurou conciliar os interesses dos utilizadores com os do Proprietário do Sistema, nomeadamente quanto ao controlo dos custos computacionais e à utilização equilibrada dos recursos. Os limites quantitativos adotados, incluindo dimensão e duração máximas dos vídeos, resolução, taxa de fotogramas e número de operações, constituem valores-alvo do MVP, estabelecidos com base nas restrições da solução existente e em pressupostos de utilização e capacidade a validar. A fundamentação e eventual revisão destes valores devem ser sustentadas por referências comparativas, decisões documentadas ou resultados de testes técnicos, conforme aplicável.

A análise e consolidação dos requisitos foram conduzidas pela equipa de desenvolvimento, considerando os interesses dos stakeholders identificados. As regras resultantes são formalizadas na Secção 3.4 e os requisitos correspondentes na especificação do sistema, permitindo rastrear as decisões tomadas até à sua implementação e validação.
