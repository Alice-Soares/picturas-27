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

Os perfis *Anónimo*, *Registado* e *Premium* definidos na _baseline_ mantêm-se válidos. A introdução de vídeo não implica a criação de novos perfis, mas exige a definição de limites específicos de submissão e processamento, bem como a clarificação da contabilização das operações nas quotas existentes.

O perfil *Anónimo* não dispõe de acesso às funcionalidades de vídeo no MVP, de modo a evitar a utilização intensiva de recursos computacionais por utilizadores não autenticados. Para o perfil *Registado*, são estabelecidos limites conservadores de submissão e processamento, adequados à natureza gratuita do serviço e à necessidade de controlar o consumo de recursos. Decidiu-se ainda manter a quota diária de 5 operações, com a regra de que a submissão de vídeos não consome quota. Por sua vez, o perfil *Premium*, embora não esteja sujeito a quotas diárias de operações, mantém limites técnicos sobre os vídeos submetidos, ainda que mais permissivos, de forma a prevenir cargas de processamento excessivas e assegurar a estabilidade e sustentabilidade da plataforma. 

A @tab-perfis-video sintetiza as condições de acesso estabelecidas para o MVP, evidenciando as diferenças entre perfis e as regras de negócio transversais que as fundamentam.

#tab([Perfis de utilização e respetivo acesso a vídeo],
  tabela(
    colunas: (2.6cm, 4.0cm, 1fr, 2.8cm),
    [Perfil], [Situação na _baseline_], [Alteração introduzida para vídeo], [Regras / requisitos],
    [Anónimo], [Operações limitadas, imagens pequenas, sem autenticação], [Sem acesso a submissão ou processamento de vídeo no MVP; mantém apenas operações em imagens.], [UC-VID-001/RN1 \ UC-VID-002/RN4 \ UC-VID-003/RN1 \ UC-VID-007/RN1 \ RNG-02],
    [Registado], [Gratuito, até 5 operações/dia, projetos persistentes], [Vídeos até 100 MB, 5 min, 1080p e 60 fps. Submissão não gasta quota; cada processamento consome 1 operação diária (quota de 5 ops/dia), com estorno em caso de falha ou cancelamento.], [UC-VID-001/RN2,RN5,RN6 \ UC-VID-002/RN3,RN7 \ UC-VID-003/RN2,RN3 \ UC-VID-004/RN2,RN3 \ UC-VID-005/RN2,RN3 \ UC-VID-006/RN1,RN2,RN4 \ UC-VID-007/RN2,RN4 \ RNG-03, RNG-04],
    [Premium], [Pago, uso ilimitado, acesso a ferramentas avançadas/IA], [Acesso ilimitado a todas as ferramentas de vídeo sem consumo de quota. Vídeos até 1 GB, 30 min, 4K (3840×2160) e 60 fps. Concatenação até 15 vídeos e extração até 5000 fotogramas.], [UC-VID-001/RN3 \ UC-VID-003/RN3 \ UC-VID-004/RN2 \ UC-VID-005/RN2 \ UC-VID-006/RN1,RN2 \ RNG-03, RNG-04],
  ),
) <tab-perfis-video>



== _Stakeholders_ e interesses


A introdução de vídeo não altera substancialmente o conjunto de intervenientes do PictuRAS, mas acrescenta novos interesses e responsabilidades aos já identificados na solução de base. A revisão incide, sobretudo, na utilização das novas funcionalidades, no controlo dos recursos computacionais e na manutenção da qualidade do serviço. A nomenclatura dos intervenientes coincide integralmente com a utilizada na secção de cabeçalho de cada caso de uso, detalhando-se os seus interesses específicos e desdobramentos operacionais na tabela seguinte.

*TODO:* REVER ESTA TABELA

#tab([_Stakeholders_ e interesses (novos ou revistos)],
  tabela(
    colunas: (3.2cm, 1.8cm, 1fr, 1.8cm, 2.8cm),
    [_Stakeholder_], [Estado], [Interesse(s) relativamente ao vídeo], [Influência], [UC / requisitos],
    [Utilizador Registado], [Revisto], [Submeter e transformar vídeos (recorte, conversão, extração, áudio, filtros) sem perda de qualidade, com acompanhamento de progresso em tempo real, sem corrupção do ficheiro original e com gestão transparente da sua quota diária de 5 operações.], [Alta], [UC-VID-001 a UC-VID-007 \ REQ-VID-SUBMIT \ REQ-VID-TRIM],
    [Utilizador Premium], [Revisto], [Executar processamentos intensivos sobre vídeos longos (até 30 min) e em alta resolução (até 4K) sem restrições de quotas diárias, com tempos de resposta previsíveis e garantia de armazenamento seguro na nuvem.], [Alta], [UC-VID-001 a UC-VID-007 \ REQ-VID-CONV],
    [Utilizador Anónimo], [Revisto], [Manter a facilidade de utilização rápida para imagens estáticas; obter feedback claro e mensagens informativas sobre as razões da indisponibilidade de vídeo e incentivo à criação de conta.], [Média], [UC-VID-001/RN1 \ REQ-VID-SUBMIT-003],
    [Proprietário do Sistema], [Revisto], [Salvaguardar a viabilidade económica e o controlo de custos computacionais e de armazenamento; assegurar o cumprimento rigoroso das quotas por perfil; potenciar a conversão de utilizadores gratuitos para planos Premium através do valor acrescentado das funcionalidades de vídeo.], [Alta], [UC-VID-001 a UC-VID-007 \ RNG-01 a RNG-05],
    [Equipa de Desenvolvimento e DevOps], [Revisto], [Garantir a estabilidade e escalabilidade da arquitetura de modo a integrar o processamento de vídeo, assegurar a fiabilidade das operações e a gestão adequada de falhas, preservar a compatibilidade com as funcionalidades de imagem e facilitar a manutenção e evolução da solução.], [Alta], [Todos os UC-VID],
    [Serviço de Armazenamento], [Revisto], [Assegurar a persistência segura e performante de ficheiros multimédia pesados, garantindo isolamento por utilizador/projeto e integridade criptográfica sem ficheiros órfãos.], [Média], [UC-VID-001 \ UC-VID-004 \ UC-VID-005],
  ),
)


== Elicitação de requisitos

A identificação das funcionalidades, regras de negócio e requisitos da extensão de vídeo teve como ponto de partida a análise dos documentos de requisitos e de arquitetura da _baseline_, do código disponibilizado e das diretrizes da Fase 1. Esta análise permitiu reconhecer as capacidades existentes suscetíveis de reutilização, as restrições impostas pelos perfis de utilização e as adaptações necessárias para suportar operações sobre vídeo. A seleção das funcionalidades foi orientada pela sua relevância para o utilizador, pela complexidade técnica e pela possibilidade de implementação e validação no âmbito do MVP.

A definição das políticas de acesso e contabilização procurou conciliar os interesses dos utilizadores com os do Proprietário do Sistema, nomeadamente quanto ao controlo dos custos computacionais e à utilização equilibrada dos recursos. Os limites quantitativos adotados, incluindo dimensão e duração máximas dos vídeos, resolução, taxa de fotogramas e número de operações, constituem valores-alvo do MVP, estabelecidos com base nas restrições da solução existente e em pressupostos de utilização e capacidade a validar. A fundamentação e eventual revisão destes valores devem ser sustentadas por referências comparativas, decisões documentadas ou resultados de testes técnicos, conforme aplicável.

A análise e consolidação dos requisitos foram conduzidas pela equipa de desenvolvimento, considerando os interesses dos stakeholders identificados. As regras resultantes são formalizadas na Secção 3.4 e os requisitos correspondentes na especificação do sistema, permitindo rastrear as decisões tomadas até à sua implementação e validação.