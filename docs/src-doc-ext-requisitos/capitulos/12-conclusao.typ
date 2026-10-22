#import "../template.typ": *

= Conclusão

#orientacao[
  Sintetizem os contributos (não repitam o conteúdo): o que o MVP de vídeo valida, o que ficou por fazer e
  porquê, e que lições tiram do processo. Terminem com a ligação à Fase 2: que requisitos não funcionais
  consideram prioritários para melhoria por _refactoring_.
]

*todo*: rever e completar este capítulo

A Fase 1 permitiu estender a arquitetura de processamento de imagens do PictuRAS com suporte a vídeo,
contemplando submissão de conteúdos audiovisuais e várias operações de transformação. Os sete casos de
uso foram especificados e existem módulos de implementação associados ao incremento. A UC-VID-006 foi
integrada na base do grupo e validada com 65 testes do Projects Service e três do API Gateway em Docker,
incluindo a execução real de FFmpeg, mantendo os originais inalterados.

A fase teve como principal contributo a validação técnica do processamento assíncrono, da articulação entre
camadas de frontend e backend e do registo de novas operações e resultados em projetos existentes. O uso
de ferramentas de IA agilizou tarefas de desenvolvimento e organização, mas tornou explícita a necessidade
de revisão dos contratos, dos conflitos de integração e da qualidade dos testes.

A validação global da versão final deve ainda consolidar demonstrações ponta-a-ponta das funcionalidades
partilhadas, registar as evidências de aceitação por requisito e confirmar as metas de qualidade. A UC-VID-006
apresenta limitações conhecidas em relação à especificação inicial, nomeadamente consulta REST do estado
em vez de progresso percentual por WebSocket, ausência de escolha manual de formato e resolução e falta
de repetição documentada do ensaio E2E após a integração com áudio. Estas limitações não impedem a avaliação
do MVP, mas devem ser claramente comunicadas e não ocultadas como requisitos concluídos.

Numa fase seguinte, recomendam-se dois eixos prioritários para refactoring: (1) robustez e consistência das
operações assíncronas, com recuperação após falhas, cancelamento e gestão de artefactos temporários;
e (2) observabilidade, segurança e fiabilidade dos contratos entre serviços, incluindo autorização e
comunicação de estados ao utilizador. A melhoria destes aspetos deve ser precedida por medições e testes
de regressão, sem confundir refactoring não funcional com a criação de funcionalidades adicionais.
