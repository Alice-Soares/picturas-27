# Correção da atualização da biblioteca após upload

Data: 2026-10-22. Baseline de código: `4523fca`.
Fontes: `docs/diretrizes_fase_1.md`, `docs/RAS-requisitos-video.md`,
`docs/use-cases/UC-VID-001-submeter-video.md` (UC-VID-001), README e código do frontend.

Problema observado no código: a página usa o proprietário explícito na chave
React Query, incluindo nos projetos próprios. Os diálogos de upload omitiam esse
valor e o contexto de partilha, invalidando uma chave diferente da consulta visível.

Correção: ambos os diálogos passam o mesmo proprietário e identificador de
partilha que a página. As mutações aguardam a atualização das consultas antes do
callback de sucesso. A invalidação de `projectImages` usa o prefixo efetivamente
definido em `useGetProjectImages`.

Rastreabilidade: UC-VID-001, passo 10 → REQ-VID-SUB-015 e REQ-VID-SUB-026 a
REQ-VID-SUB-029 (persistência e associação), REQ-VID-Q-006 (compatibilidade com
imagens) → diálogos de upload e mutações React Query →
`frontend/test/projectUploadRefresh.test.js` → quatro cenários passaram.
Esta manutenção corrige a apresentação de conteúdos já associados; não altera
regras de negócio, contratos da API nem requisitos da baseline.

Validação executada:

- Quatro testes de regressão: imagens e vídeos, projeto próprio e partilhado.
  Executam os componentes e mutações com dependências de interface simuladas e
  um QueryClient/QueryObserver real; verificam a atualização da consulta visível.
- Seis testes existentes de contrato de concatenação: passaram.
- `frontend/node_modules/.bin/tsc --noEmit --incremental false -p frontend/tsconfig.json`: passou.
- `git diff --check`: passou.

Com Node que suporte o test runner, executar:
`node --test frontend/test/*.test.js`.
O ambiente disponível usa Node 16.14.0, sem `--test`; os dez testes foram executados
com um adaptador temporário que regista os callbacks de `node:test` e os aguarda
sequencialmente, preservando as asserções e propagando falhas.
Não foi realizada validação manual no browser nem um upload contra serviços ativos.

Apoio de IA: Codex, modelo GPT-6; instruções AGENTS.md e pedido do utilizador.
Tarefas apoiadas: diagnóstico, correção e testes de regressão. Nenhum skill
invocado. A revisão humana e a validação no ambiente integrado ficam a cargo da equipa.

## Extensão da correção aos resultados de ferramentas

Pedido adicional: apresentar também os resultados de processamento sem refresh.

Factos observados: os hooks de consulta das operações de vídeo apenas devolviam
estado; o provider invalidava consultas com o proprietário no lugar do utilizador
atual em partilhas; o processamento de imagens notificava o progresso antes da
persistência e do commit dos resultados; a contagem do frontend começava em um.

Alterações:

- Consulta de estado terminal de recorte, conversão, ferramentas de fotogramas,
  extração e concatenação aguarda a reconciliação da biblioteca e dos resultados.
  A extração atualiza também o projeto de destino.
- O provider usa o utilizador atual na cache, verifica o projeto do evento e
  volta a entrar na sala e a consultar os dados após reconexão.
- O backend publica `RESULTS_READY` no canal existente `project-op` depois de
  guardar o token dos resultados de imagem. O progresso é enviado após a
  persistência. O frontend começa a contagem em zero.
- Limpar ferramentas invalida também o projeto, além dos resultados.

Rastreabilidade adicional: UC-VID-002 a UC-VID-006 → REQ-VID-COM-018,
REQ-VID-COM-020 e REQ-VID-Q-006 → hooks de operações e ProjectProvider → testes
em `projectUploadRefresh.test.js` (estado em processamento sem refetch, conclusão
com refetch, extração para outro projeto, eventos em partilha e reconexão).
A notificação `RESULTS_READY` corrige a apresentação dos resultados de imagem;
não altera os contratos REST nem regras de negócio da baseline.

Resultados executados: 16 testes de frontend passaram (10 de regressão e seis
contratos existentes); TypeScript, `node --check projects/routes/projects.js` e
`git diff --check` passaram. A suite `node projects/test/run-tests.js` não pôde
arrancar por falta de `mongoose`; usando as dependências do frontend por
`NODE_PATH`, ficou bloqueada por falta de `uuid`. Não se declara validação de
integração do backend nem teste manual no browser.

## Controlos visuais das ferramentas e apresentação do progresso

Pedido adicional: corrigir a sobreposição da barra de estado de vídeo e substituir
a edição JSON por controlos semelhantes aos das ferramentas de imagem.

Implementação: o indicador de progresso usa uma largura limitada a 0–100%, em vez
de deslocar um elemento com largura total por transformação. A raiz expõe o mesmo
valor ao componente acessível. A conversão usa o diálogo com portal já utilizado
na aplicação, eliminando a janela `fixed` dentro do diálogo transformado do player.
Os diálogos de ferramentas, conversão, recorte e extração apenas apresentam dados
do ID da operação atual, evitando mostrar temporariamente o progresso anterior.
A conclusão permite voltar a configurar uma operação.

As nove ferramentas compatíveis mantêm os contratos e a cadeia ordenada. Brilho,
contraste, saturação, rotação e binarização usam sliders com os intervalos da UI
de imagem existente; moldura usa espessura e seletor RGB; recorte e redimensionamento
usam campos numéricos; marca de água mantém a operação padrão sem parâmetros.
Os valores herdados das ferramentas do projeto são preservados. O recorte começa
com margens zero, de acordo com a UI de imagem e `tools/cut/processor.py`.
A janela tem altura limitada e scroll para cadeias longas.

Rastreabilidade: UC-VID-003 → REQ-VID-FRM-001 a REQ-VID-FRM-006 (seleção e
configuração), REQ-VID-Q-002 (estado observável) → VideoToolControls,
VideoFrameToolDialog, Progress e diálogos de operação → testes de sliders,
parâmetros numéricos/RGB e limites do indicador.

Validação: 19 testes de frontend passaram (incluindo três novos testes com vários
cenários de parâmetros e progresso); TypeScript e `git diff --check` passaram.
O mecanismo de execução compatível com Node 16 é o descrito acima. Não foi
realizada inspeção visual num browser, pelo que o resultado visual integrado
continua a requerer confirmação nesse ambiente. Apoio de IA e baseline mantêm-se.

## Correção do estado preso em «queued — 0%»

Evidência adicional do utilizador: capturas com progresso em 0% e sem botão de
cancelamento, mesmo depois de a operação terminar. Verificação no ambiente Docker:
os 162 pedidos de consulta de operação nas últimas 300 linhas do acesso Nginx
responderam HTTP 200; as três operações de ferramentas mais recentes estavam
`completed`, com progresso 100 e sem código de erro. A consulta da base de dados
foi apenas de leitura e os resultados registados não incluem identificadores.

Causa identificada no cliente: a consulta por `useMutation` aguardava a atualização
assíncrona da biblioteca dentro de `onSuccess` antes de publicar `data`, enquanto
o temporizador iniciava outra mutação a cada dois segundos. Assim, a interface
podia continuar sem dados, usando o texto de fallback `queued` e progresso zero.

Correção: `useProjectVideoOperation` usa `useQuery`, com chave por operação,
consulta imediata, polling sem pedidos sobrepostos e paragem em estado terminal.
A reconciliação da biblioteca é disparada num efeito independente depois de
publicado o estado. Aplicado a ferramentas de fotogramas, recorte, conversão e
extração. Em falhas de consulta, a UI apresenta erro e permite tentar novamente;
o cancelamento está disponível desde que exista ID de operação ativo.

Teste novo: um QueryObserver real mantém a biblioteca pendente enquanto a
consulta já apresenta `completed` e 100%; confirma também a paragem do polling.
Os 20 testes de frontend passaram, com o adaptador Node 16 já descrito.
TypeScript passou. A validação visual anterior não tinha coberto esta condição
assíncrona; as capturas do utilizador motivaram esta correção adicional.

Aplicação local: `docker compose up -d --build --no-deps frontend` concluiu com
sucesso, incluindo compilação Next.js, verificação de tipos e geração das páginas.
O contentor frontend foi recriado e iniciado. O build emitiu apenas avisos de lint
em ficheiros existentes. Não foram alteradas operações ou dados dos utilizadores.
