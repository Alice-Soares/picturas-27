#import "../template.typ": *

= Conclusão

#orientacao[
  Sintetizem os contributos (não repitam o conteúdo): o que o MVP de vídeo valida, o que ficou por fazer e
  porquê, e que lições tiram do processo. Terminem com a ligação à Fase 2: que requisitos não funcionais
  consideram prioritários para melhoria por _refactoring_.
]


A extensão acrescenta ao PictuRAS referências de vídeo, validação de metadados, operações assíncronas e integração FFmpeg, reutilizando projetos, armazenamento, autenticação e mensageria da baseline. Os sete casos de uso estabelecem um âmbito coerente que liga submissão, transformações visuais e temporais, extração, concatenação e áudio.

É distinguida especificação, realização e aceitação: há implementação dos fluxos individuais e resultados focados de 49 testes gerais, 20 de frontend, três do gateway e cinco do worker de áudio, além da verificação TypeScript. Estas execuções não constituem uma demonstração ponta-a-ponta de toda a stack. A reexecução integral da suite de concatenação foi interrompida sem resumo final; a sua aprovação histórica não é reapresentada como validação atual.

Os lotes de submissão e conversão e a criação de um projeto novo durante a extração permanecem parcialmente realizados. O progresso dos diálogos usa consulta REST, embora os workers publiquem eventos WebSocket. A extração de áudio termina numa transferência autenticada temporária, sem persistência na biblioteca. Estas diferenças estão identificadas junto das UCs e dos requisitos correspondentes, preservando o contrato especificado e a rastreabilidade das limitações.

O apoio de IA facilitou exploração do código, implementação, testes e revisão documental. A comparação entre UCs, requisitos, contratos e resultados mostrou que compilar ou encontrar um módulo não comprova a aceitação de uma funcionalidade. A revisão humana e o registo dos ensaios na instalação final continuam necessários antes da entrega.

Para a Fase 2, os eixos prioritários são a consistência e recuperação das operações assíncronas e a observabilidade/fiabilidade dos contratos entre serviços. Devem ser abordados por refactoring, com medições antes e depois e testes de regressão. A introdução de funcionalidades novas é distinguida dessas melhorias não funcionais.
