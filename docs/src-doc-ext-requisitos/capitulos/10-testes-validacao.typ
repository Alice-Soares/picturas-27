#import "../template.typ": *

= Testes e Validação do MVP

== Estratégia e ambiente

A validação combina testes de regras, contratos, integração multimédia e frontend. A execução de um teste focado comprova as respetivas asserções; não substitui a aceitação de um fluxo completo com autenticação, armazenamento, filas e interface. Os protocolos TST-ACC-{FUNC}-nn do capítulo 7 usam os critérios Dado/Quando/Então da ERS e permanecem por executar quando não existe resultado específico.

A revisão de 23 de outubro de 2026 tomou o commit `2afaede` como referência. Usou as imagens Docker locais disponíveis, sem rebuild nem atualização dos serviços. O frontend não estava em execução nessa stack, pelo que não foi realizado ensaio manual integrado. O acesso documentado é `https://localhost:8080`, com certificado local autoassinado. Fixtures dos testes FFmpeg são geradas pelos próprios testes; não são ficheiros de utilizadores.

== Testes e resultados registados

#tab([Execuções de validação], tabela(
  colunas: (2.6cm, 1.7cm, 1fr, 3.3cm, 3.4cm), tamanho: 8pt,
  [ID], [Tipo], [Cenário Dado/Quando/Então], [Requisitos / cobertura], [Resultado],
  [TST-VID-CORE-01], [Regras / contrato / integração], [Dadas as regras e contratos de vídeo, Quando os testes exercitam entradas válidas, inválidas e recomposição FFmpeg, Então verificam os resultados e erros previstos nas asserções.], [TRIM, FRM, CONV, FEX, AUD e COM; cobertura focada, não aceitação de todos os requisitos.], [49 testes passaram em 23-10-2026.],
  [TST-VID-FRONT-01], [Frontend], [Dadas respostas de estado e eventos de projeto, Quando chegam ao cliente, Então a cache e os controlos produzem os valores esperados nos testes.], [REQ-VID-SUB-015, COM-018, Q-002 e controlos de ferramentas; não cobre inspeção visual completa.], [20 testes passaram localmente em 23-10-2026.],
  [TST-GATEWAY-01], [Contrato do gateway], [Dado um pedido de concatenação, Quando é encaminhado ou rejeitado, Então preserva identidade, ordem e os erros previstos.], [REQ-VID-COM-001 a 003; MERGE-001.], [Três testes passaram em Docker em 23-10-2026.],
  [TST-AUD-WORKER-01], [Integração FFmpeg], [Dados vídeos e faixas de áudio gerados pelo teste, Quando o worker remove, substitui ou extrai áudio, Então as saídas satisfazem as asserções multimédia.], [REQ-VID-AUD-004 a 016; não equivale à aceitação completa do acesso e interface.], [Cinco testes passaram em Docker em 23-10-2026.],
  [TST-MERGE-01], [Regras], [Dado um pedido de concatenação, Quando se validam seleção e perfil, Então entradas inválidas são rejeitadas.], [REQ-VID-MERGE-001 a 008, 014 e 015.], [Incluído no registo histórico de 65 testes. Reexecução atual sem resumo final.],
  [TST-MERGE-02], [Contrato / estados], [Dado um pedido aceite, Quando é colocado em fila, falha ou é cancelado, Então os estados seguem o contrato.], [REQ-VID-MERGE-009 e COM-009 a 017.], [Registo histórico; reexecução atual interrompida com código 137.],
  [TST-MERGE-03], [Integração], [Dadas fontes com e sem áudio, Quando concatenadas, Então a ordem e as origens são preservadas.], [REQ-VID-MERGE-010 a 013.], [Registo histórico de integração FFmpeg; aceitação na versão final por repetir.],
  [TST-VID-BUILD-01], [Tipos / compilação], [Dado o frontend integrado, Quando se executa TypeScript, Então os tipos são aceites. A compilação do relatório verifica a sua sintaxe e referências locais.], [Verificação estática; não demonstra comportamento funcional.], [TypeScript passou em 23-10-2026. O PDF é compilado separadamente das validações da aplicação.],
))

Os 65 testes históricos de concatenação e os três de gateway foram registados antes desta revisão; não são somados às execuções atuais nem apresentados como aprovação global da versão final. A suite ampla de concatenação e uma repetição sequencial terminaram com código 137, sem resumo final. Isto impede confirmar a aprovação integral nessa sessão, mas não identifica por si só um defeito funcional.

== Reprodução das execuções

```bash
docker compose exec -T projects node test/run-tests.js
docker compose exec -T api_gateway node --test test/videoMergeGatewayRoute.test.js
docker compose run --rm --no-deps video_audio_tool python -m unittest test_video_audio.py
# Com o frontend em execução e um Node com o test runner:
docker compose exec -T frontend sh -lc 'node --test test/*.test.js'
frontend/node_modules/.bin/tsc --noEmit --incremental false -p frontend/tsconfig.json
# Suite histórica de concatenação:
docker compose exec -T projects sh -lc 'node --test test/videoMerge*.test.js'
```

Os testes de frontend foram executados no ambiente local Node 16 através do adaptador temporário que regista e aguarda os callbacks de `node:test`, descrito em `docs/validacao/atualizacao-biblioteca.md`. Não se declara que o comando nativo tenha passado nessa versão de Node. Para a entrega, o contentor frontend disponibiliza Node com suporte ao runner; executar esse comando não depende do adaptador temporário.

== Limitações e aceitação ainda necessária

- Submissão individual e conversão individual têm componentes implementados; os fluxos de lote UC-VID-001/FA2 e UC-VID-004/FA1 não estão disponíveis na interface atual.
- A extração de fotogramas aceita o projeto atual ou outro existente. A criação automática de destino de UC-VID-005/FA3 e REQ-VID-FEX-010 é parcial.
- Os workers publicam eventos no projeto autorizado; as barras dos diálogos usam consulta REST. Não se declara cumprida a apresentação percentual diretamente por WebSocket em todas as UC.
- Remoção/substituição de áudio produzem um vídeo novo. Extração produz M4A/AAC temporário para transferência autenticada, sem criar item de áudio na biblioteca.
- A concatenação normaliza automaticamente para MP4; não permite escolher manualmente formato ou resolução. A aceitação manual histórica deve ser repetida na stack de entrega.
- A reserva de quota para ferramentas avançadas permanece uma regra condicional. A whitelist atual de fotogramas contém filtros básicos; não se apresenta execução de IA em vídeo como funcionalidade entregue.
- Metas de qualidade, isolamento entre projetos, limpeza e cancelamento carecem de evidência específica por critério quando não cobertos pelas asserções executadas. Não se inferem garantias de produção a partir de testes unitários.

Para encerrar a aceitação, executar na instalação final os protocolos da matriz com entradas identificadas, perfil, resultado observado e data. Incluir os sete fluxos de sucesso implementados e as rejeições, cancelamentos e preservação dos originais aplicáveis. Registar os estados parciais em vez de os eliminar da especificação.
