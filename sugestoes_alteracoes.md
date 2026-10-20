# Sugestões de alterações antes de continuar

Esta lista resulta da revisão dos `UC-VID-001` e `UC-VID-002` contra o código
atual. Não foram feitas alterações de implementação nesta revisão.

## SUG-001 — Retirar as rotas de trim de dentro do handler de upload

**Prioridade:** bloqueadora.

Em [`apiGateway/routes/projects.js`](./apiGateway/routes/projects.js), as rotas
de criação, consulta e cancelamento do trim aparecem dentro do callback da rota
`POST /:user/:project/video`. Portanto, não são registadas quando o Gateway
arranca; só seriam registadas depois de um upload de vídeo bem-sucedido, e
seriam registadas repetidamente a cada upload.

**Alteração proposta:** fechar a rota de upload antes de declarar as três rotas
de operação, ou extrair o encaminhamento para um router específico de vídeo.
As rotas devem estar registadas uma vez, no arranque do Gateway.

**Validação:** iniciar o Gateway sem fazer upload e confirmar que os três
endpoints existem; repetir uploads e confirmar que não há duplicação de
handlers.

## SUG-002 — Separar a ferramenta de trim do Projects Service

**Prioridade:** alta; resolver antes de implementar os restantes processamentos
de vídeo.

A dúvida colocada é válida: o trim é uma **ferramenta de processamento**, não
uma responsabilidade intrínseca de um projeto. O código atual mistura as duas
coisas em [`projects/services/videoTrimWorker.js`](./projects/services/videoTrimWorker.js):
o mesmo worker conhece MongoDB, o modelo `Project`, o modelo
`VideoOperation`, armazenamento, FFmpeg, cancelamento e eventos.

**Decisão recomendada:**

- manter no Projects Service a autorização, a validação do intervalo, a quota,
  o registo da operação e a associação do resultado ao projeto;
- mover a execução FFmpeg para uma ferramenta/microserviço de vídeo dedicado,
  por exemplo `Tools/video_trim/` ou um serviço `videoTools/`, consumindo a
  fila `video_trim`;
- definir a mensagem da fila como o contrato entre orquestração e ferramenta;
- fazer a ferramenta receber apenas referências/ficheiros necessários,
  produzir o resultado e emitir progresso/resultado/falha, sem aceder
  diretamente ao modelo de projeto;
- deixar o Projects Service aplicar a transição final e persistir a referência
  derivada.

Isto alinha o UC2 com o padrão já usado pelas ferramentas em
[`Tools/`](./Tools/), isola CPU/FFmpeg, permite escalar o processamento
independentemente e evita que o Projects Service se torne um concentrador de
implementações de vídeo.

**Nota de âmbito:** não é necessário criar um “Video Service” que passe a ser
dono de projetos. A recomendação é separar apenas o executor da ferramenta; o
Projects Service continua a ser o dono da operação e do conteúdo do projeto.

## SUG-003 — Definir explicitamente o contrato de ownership da operação

**Prioridade:** alta.

Antes de mover o worker, documentar no contrato de
[`specs/002-video-trim/contracts/video-trim.md`](./specs/002-video-trim/contracts/video-trim.md)
que:

- Projects é o dono de `VideoOperation`, quota, autorização e estados;
- a ferramenta é stateless quanto ao domínio e só executa o trim;
- um resultado só pode ser publicado uma vez;
- cancelamento, retry e limpeza têm comportamento idempotente;
- progresso não é uma nova decisão de domínio nem pode alterar quota.

Sem esta fronteira, a migração do worker apenas deslocará o acoplamento para
outro processo.

## SUG-004 — Separar o estágio do vídeo original do estágio do resultado

**Prioridade:** média, mas deve ser resolvida no desenho do próximo passo.

Atualmente o original e o resultado do trim são gravados com
`stage: "video-src"` em [`projects/services/videoSubmission.js`](./projects/services/videoSubmission.js)
e [`projects/services/videoTrimWorker.js`](./projects/services/videoTrimWorker.js).
Além disso, [`projects/models/project.js`](./projects/models/project.js) só
aceita `video-src`, apesar de a especificação dizer que o resultado deve ser
um vídeo derivado.

**Alteração proposta:** escolher e documentar um estágio para resultados, por
exemplo `video-result`, adicionar esse estágio às rotas de storage, download e
remoção, e atualizar o modelo e os contratos. O nome final deve ser uma decisão
arquitetural, não uma inferência desta revisão.

**Validação:** criar um trim, confirmar que o original continua em
`video-src`, que o resultado tem chave própria e que ambos podem ser
consultados/removidos sem cruzar objetos.

## SUG-005 — Corrigir o runner de validação e a rastreabilidade dos testes

**Prioridade:** alta.

As tarefas dos dois planos aparecem marcadas como concluídas, mas
[`projects/test/run-tests.js`](./projects/test/run-tests.js) executa apenas um
subconjunto de testes unitários/contratuais e o `package.json` da raiz não tem
script `test`. Existem testes de integração no diretório, mas eles não estão
incluídos nesse runner.

**Alteração proposta:**

- definir o comando oficial de testes no README;
- incluir ou separar explicitamente os testes de integração;
- indicar quais dependências externas são necessárias;
- não marcar tarefas como concluídas sem evidência do comando correspondente;
- adicionar teste de rota que falhe se os endpoints de trim não estiverem
  registados no arranque.

**Validação:** executar o runner do Projects e uma suite de integração
reprodutível, registando resultados por requisito.

## SUG-006 — Rever contratos e documentação antes do UC-VID-003

**Prioridade:** média.

Há pequenas divergências entre documentação e implementação que devem ser
resolvidas antes de multiplicar o padrão:

- o caso de uso fala num “microsserviço de trim”, enquanto o plano decidiu um
  worker dentro de Projects;
- a documentação menciona eventos WebSocket, mas a UI atual faz polling
  periódico da operação e usa eventos para atualização do projeto;
- o contrato prevê acesso de projeto e vídeo, mas as rotas atuais restringem o
  caller ao proprietário através de comparação direta de IDs;
- a camada de storage usa o nome `imageKey` para devolver uma chave de vídeo.

Cada ponto deve ser classificado como comportamento aprovado, limitação do MVP
ou requisito a alterar. O UC-VID-003 não deve reutilizar contratos ambíguos.

## Ordem recomendada

1. Corrigir o registo das rotas do Gateway (`SUG-001`).
2. Decidir e documentar a fronteira Projects versus ferramenta (`SUG-002` e
   `SUG-003`).
3. Fixar o modelo de estágio e chaves de resultados (`SUG-004`).
4. Tornar a validação executável e rastreável (`SUG-005`).
5. Atualizar os artefactos de requisitos/contratos e só depois avançar para
   `UC-VID-003` (`SUG-006`).

