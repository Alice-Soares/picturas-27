#import "../template.typ": *

= Testes e Validação do MVP

#orientacao[
  Os critérios de aceitação da ERS (_Dado… Quando… Então…_) são a base dos testes. Cada requisito implementado
  deve ter pelo menos um teste (automático ou manual) com resultado registado. Para os requisitos não
  funcionais, registem o valor medido face ao *Alvo*, sempre que aplicável.
]


== Estratégia e ambiente de testes

A validação do MVP combina testes de unidade, de contrato, de integração e de interface. Os testes unitários verificam regras sem iniciar a aplicação completa, como limites por perfil, intervalos temporais, codecs aceites e transições de estado. Os testes de contrato verificam os pedidos e respostas entre o Projects Service, o gateway, RabbitMQ e os workers. Os testes de integração exercitam a interação entre componentes, incluindo o processamento multimédia real por FFmpeg quando o cenário o exige. Os testes de frontend verificam a apresentação dos estados, a atualização da biblioteca e os controlos das operações. Builds e verificação de tipos complementam estas verificações, mas não substituem um cenário funcional.

A aplicação é executada localmente com Docker Compose. Os serviços envolvidos incluem frontend, API Gateway, Projects Service, MongoDB, RabbitMQ e SeaweedFS. O acesso à interface é feito por `https://localhost:8080`, através do certificado de desenvolvimento autoassinado descrito no README. Para verificar as dependências multimédia, o contentor de projetos disponibiliza FFmpeg e FFprobe. As suites automatizadas do Projects Service podem ser executadas com `docker compose run --rm --no-deps projects node test/run-tests.js`. A suite do worker de áudio pode ser executada com `docker compose run --rm video_audio_tool python -m unittest test_video_audio.py`. Os testes de frontend usam os scripts em `frontend/test/`, complementados pela verificação TypeScript e pelo build Docker.

Os testes multimédia usam ficheiros pequenos para tornar os cenários repetíveis. A suite Python do worker de áudio gera localmente vídeos de dois segundos com imagem 160×120 e áudio AAC, áudio MP3 de um segundo e um vídeo curto para testar substituição a partir de outra faixa sonora. A integração de concatenação gera vídeos curtos H.264 com resoluções de 320×180 e 640×360, com e sem faixa sonora. Estes ficheiros são fixtures de teste e não incluem dados pessoais. Os quickstarts definem cenários adicionais com MP4/H.264, com e sem AAC, codecs inválidos, limites excedidos e operações canceladas.

Os resultados abaixo referem-se a execuções documentadas entre 21 e 22 de outubro de 2026. Uma aprovação de teste focado confirma o comportamento coberto pelas respetivas verificações. A existência de um teste ou a compilação dos serviços, por si só, não demonstra que todos os fluxos tenham sido percorridos na stack completa.


== Testes realizados

#tab([Testes e resultados],
  tabela(
    colunas: (2.2cm, 1.6cm, 1fr, 2.8cm, 1.6cm),
    tamanho: 8.2pt,
    [ID], [Tipo], [Descrição (Dado… Quando… Então…)], [Requisito(s)], [Resultado],
    [TST-VID-CORE-01], [Unitário / contrato], [Dadas regras de trim, fotogramas, conversão, extração e áudio, Quando se submetem valores e mensagens válidos ou inválidos, Então os validadores e contratos aceitam ou rejeitam os casos esperados.], [REQ-VID-TRIM-001 a 013, REQ-VID-FRM-001 a 014, REQ-VID-CONV-001 a 011, REQ-VID-FEX-001 a 011, REQ-VID-AUD-001 a 016, REQ-VID-COM-001 a 020], [36 testes da suite Projects passaram a 21-10-2026. Esta execução não é um teste E2E.],
    [TST-VID-FRONT-01], [Frontend / regressão], [Dada uma operação de vídeo em curso, Quando a consulta devolve estado terminal ou resultado, Então a interface apresenta o estado atual e atualiza a biblioteca do projeto.], [REQ-VID-SUB-015, REQ-VID-COM-018, REQ-VID-COM-020, REQ-VID-Q-002], [20 testes de frontend passaram. A verificação TypeScript e o build Docker também passaram.],
    [TST-MERGE-01], [Automático / Docker], [Dado um pedido de concatenação, Quando se validam quantidade, duração, ordem, pertença ao projeto e perfil, Então entradas válidas avançam e entradas inválidas são rejeitadas.], [REQ-VID-MERGE-001 a 008, REQ-VID-MERGE-014, REQ-VID-MERGE-015], [Incluído nos 65 testes aprovados do Projects Service.],
    [TST-MERGE-02], [Automático / Docker], [Dada uma concatenação válida, Quando é submetida, cancelada ou falha, Então operação, fila e estado são atualizados conforme o resultado.], [REQ-VID-MERGE-009, REQ-VID-COM-009 a REQ-VID-COM-017], [Incluído nos 65 testes do Projects Service aprovados.],
    [TST-MERGE-03], [Integração / FFmpeg], [Dados vídeos de resoluções diferentes e faixas de áudio distintas, Quando são concatenados, Então é produzido um vídeo pela ordem pedida e as fontes permanecem intactas.], [REQ-VID-MERGE-010 a 013], [A integração real com FFmpeg está incluída nos 65 testes aprovados.],
    [TST-GATEWAY-01], [Gateway / Docker], [Dado um pedido autenticado, Quando atravessa o gateway, Então identidade, autorização, ordem das fontes e erros são preservados.], [REQ-VID-COM-001 a 003, REQ-VID-MERGE-001], [3 testes do API Gateway passaram.],
    [TST-VID-BUILD-01], [Build / tipos], [Dado o código integrado, Quando se compilam Projects, API Gateway e frontend, Então os serviços constroem sem erro e o frontend passa a verificação de tipos.], [Compatibilidade e integração do MVP], [Foram registados três builds sem erro. O TypeScript passou na validação do frontend.],
    [TST-AUD-WORKER-01], [Worker / FFmpeg], [Dados pedidos de remoção, substituição e extração, Quando processados pelo worker, Então o vídeo de saída mantém a imagem esperada e o áudio usa AAC ou M4A conforme a operação.], [REQ-VID-AUD-004 a 016], [A suite está implementada e o comando documentado, mas não consta um resultado de execução no registo consolidado.],
    [TST-MERGE-MANUAL-01], [Manual / versão anterior], [Dados dois vídeos MP4, Quando concatenados na interface, Então o resultado pode ser reproduzido e as fontes mantêm-se.], [REQ-VID-MERGE-010 a 013], [Passou numa base anterior à integração final. É necessário repetir na versão final.],
  ),
)

Na validação Docker da concatenação foram aprovados 65 testes do Projects Service e três do API Gateway. Separadamente, a suite focada de 36 testes cobriu contratos e regras de validação de várias operações. Estes resultados fornecem validação automatizada para as funcionalidades e os componentes abrangidos, sem equivaler a uma demonstração manual completa de todos os casos de uso na stack integrada.



== Matriz de cobertura e evidências 

*TODO*: REVER TABELA

#tab([Estado da evidência de validação por caso de uso],
  tabela(
    colunas: (2.0cm, 1fr, 3.6cm),
    [Caso de uso], [Verificações mínimas de aceitação], [Evidência disponível nesta revisão],
    [UC-VID-001], [Submeter MP4, validar perfil, limites e rejeição de ficheiros inválidos.], [Testes específicos presentes no repositório; resultado global não disponibilizado.],
    [UC-VID-002], [Recortar intervalo, persistir novo vídeo, cancelar e manter origem.], [Testes específicos presentes; E2E final não comprovado.],
    [UC-VID-003], [Processar fotogramas, recompor vídeo e tratar falhas de ferramenta.], [Testes de contrato e integração presentes; E2E final não comprovado.],
    [UC-VID-004], [Converter formato/resolução e validar limites da saída.], [Testes específicos presentes; E2E final não comprovado.],
    [UC-VID-005], [Extrair fotogramas, guardar resultados e limpar temporários.], [Testes de validação presentes; E2E final não comprovado.],
    [UC-VID-006], [Ordenar fontes, validar limites, concatenar, persistir e cancelar.], [68/68 testes Docker aprovados; E2E final a repetir.],
    [UC-VID-007], [Remover/substituir/extrair áudio, validar fontes e cancelamento.], [Código integrado; evidência consolidada não disponibilizada.],
  ),
)



== Limitações e defeitos conhecidos



*TODO*: REVER ISTO

 O seguimento da UC-VID-006 é realizado por consulta periódica da API; a entrega de percentagens em WebSocket,
  prevista nos requisitos transversais, não está demonstrada para esta operação.
- A seleção manual de formato e resolução de saída não faz parte do diálogo de concatenação entregue;
  o fluxo produz MP4 normalizado automaticamente.
- A validação manual ponta-a-ponta da concatenação foi comprovada numa base de código anterior. A operação
  precisa de repetição após o merge com o módulo de áudio na versão final.
- Não estão disponíveis nesta revisão os resultados consolidados das suites globais e das demonstrações
  das UC-VID-001 a 005 e 007; o estado de validação permanece explicitamente por confirmar.
- As metas quantitativas dos requisitos não funcionais não foram medidas de forma abrangente;
  estes resultados não devem ser descritos como alcançados na Fase 1.
- Na concatenação, o frontend consulta periodicamente a API para obter o estado da operação. Não apresenta percentagem por WebSocket como fazem outros fluxos. Esta diferença reduz a uniformidade do acompanhamento, embora o utilizador consiga observar a conclusão e o resultado.
- O diálogo de concatenação não permite escolher manualmente o formato e a resolução. O worker produz MP4 normalizado e preserva a ordem pedida. A alteração destas opções requer uma decisão sobre perfis de saída e compatibilidade entre entradas.
- O cenário manual de concatenação passou numa base anterior à integração final do módulo de áudio. A suite automatizada de backend e gateway passou, mas o cenário manual deve ser repetido sobre a versão final, com entradas com e sem áudio.
- Para submissão, recorte, ferramenta em fotogramas, conversão e extração existem testes focados de validação, contratos e componentes. Os registos consultados não incluem uma execução ponta-a-ponta de cada operação através da stack Docker, com perfis reais, RabbitMQ, armazenamento e cancelamento.
- Na gestão de áudio, o comportamento da extração diverge entre documentos. O caso de uso e a REQ-VID-AUD-015 descrevem guardar o M4A na biblioteca do projeto. O README e as tarefas da especificação descrevem uma descarga autenticada para o dispositivo sem criar um item no projeto. A decisão deve ser reconciliada na fonte de requisitos e nos artefactos dependentes antes da entrega.
- Há testes automatizados para o contrato e a validação de áudio, mas não consta um resultado da suite Python que executa FFmpeg para remoção, substituição e extração. O comando para a executar está indicado na estratégia de testes.
- A especificação prevê progresso e atualização em tempo real de forma transversal. Os fluxos não usam todos o mesmo mecanismo. A concatenação usa consulta periódica e a cobertura de eventos WebSocket por perfil e operação deve ser consolidada.
- As metas quantitativas de desempenho e capacidade da ISO/IEC 25010 não foram medidas com carga representativa. O MVP não fornece evidência sobre latência sob concorrência, volume máximo de operações simultâneas ou capacidade de recuperação após falhas distribuídas.
- A interface mantém limites assumidos para esta fase: uploads sequenciais, sem miniaturas geradas pelo sistema, sem retoma de operações canceladas, sem análise de cenas para selecionar fotogramas e sem transições entre vídeos. A seleção de várias faixas de áudio continua fora do âmbito definido para o MVP.
