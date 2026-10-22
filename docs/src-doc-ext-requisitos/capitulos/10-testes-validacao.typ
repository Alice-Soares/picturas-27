#import "../template.typ": *

= Testes e Validação do MVP

#orientacao[
  Os critérios de aceitação da ERS (_Dado… Quando… Então…_) são a base dos testes. Cada requisito implementado
  deve ter pelo menos um teste (automático ou manual) com resultado registado. Para os requisitos não
  funcionais, registem o valor medido face ao *Alvo*, sempre que aplicável.
]


== Estratégia e ambiente de testes

#preencher[Tipos de teste (unitários, integração, ponta-a-ponta, manuais), ferramentas, ambiente (docker compose), ficheiros de vídeo de teste usados (formatos, durações, tamanhos).]


A validação combina testes unitários e de contrato, testes de integração com FFmpeg e testes manuais de
ponta-a-ponta. O projeto utiliza Node.js, as suites nativas `node --test` e Docker Compose; a execução
integrada envolve ainda MongoDB, RabbitMQ e SeaweedFS. O sistema é disponibilizado localmente através de
`https://localhost:8080`, com certificado de desenvolvimento.


== Testes realizados

*TODO:* PREENCHER A TABELA 

#tab([Testes e resultados],
  tabela(
    colunas: (2.2cm, 1.6cm, 1fr, 2.8cm, 1.6cm),
    tamanho: 8.5pt,
    [ID], [Tipo], [Descrição (Dado… Quando… Então…)], [Requisito(s)], [Resultado],
    [TST-#preencher[FUNC]-01], [#preencher[Automático / Manual]], [#preencher[…]], [#preencher[IDs]], [#preencher[Passa]],
  ),
)

*TODO*: USAR ISTO PARA PRENCHER A TABELA DE CIMA SEM ALTERAR O FORMATO DA TABELA DE CIMA
#tab([Resultados confirmados de testes da UC-VID-006],
  tabela(
    colunas: (2cm, 2cm, 1fr, 3.0cm, 1.7cm),
    tamanho: 8.5pt,
    [ID], [Tipo], [Verificação], [Requisitos principais], [Resultado],
    [TST-MERGE-01], [Automático / Docker], [Validações de número, duração, ordem, propriedade do projeto e perfil do utilizador.], [MERGE-001 a 008; MERGE-014 e 015], [Passa; incluído nos 65],
    [TST-MERGE-02], [Automático / Docker], [Registo de operação, reserva/devolução de quota, fila, cancelamento e estados.], [MERGE-009; COM-004 a 017], [Passa; incluído nos 65],
    [TST-MERGE-03], [Integração / FFmpeg], [Concatena vídeos com resoluções e áudio diferentes; verifica ordem e preservação das fontes.], [MERGE-010 a 013], [Passa; incluído nos 65],
    [TST-MERGE-04], [Automático / Docker], [Erros de armazenamento, rollback, limpeza, execução do worker e mensagens inválidas.], [MERGE-008, 012 a 015; COM-014 a 018], [Passa; incluído nos 65],
    [TST-MERGE-05], [Gateway / Docker], [Autenticação, preservação dos parâmetros, autorização do dono e propagação de erros.], [COM-001 a 003; MERGE-001], [3/3 passam],
    [TST-MERGE-06], [Build], [Compilação dos serviços `projects`, `api_gateway` e `frontend`.], [Integração UC-VID-006], [3 builds sem erro],
    [TST-MERGE-07], [Manual / versão anterior], [Dois vídeos unidos e reproduzidos no navegador; MP4 de cerca de 36,53 s, 640 x 360.], [MERGE-010 a 013], [Passou noutra base; repetir na integração final],
  ),
)

Nos testes automatizados da versão integrada foram obtidos *65 testes aprovados no Projects Service* e
*3 testes aprovados no API Gateway*, sem falhas nem testes ignorados. A suite real de FFmpeg passou no
contentor Linux. Foram também executados seis testes de contrato de frontend numa etapa anterior, mas
não se atribui esse resultado ao último estado integrado sem repetição. Os dois vídeos do teste manual
anterior tinham condições técnicas diferentes, incluindo uma entrada sem faixa de áudio.

== Matriz de cobertura e evidências a recolher pelo grupo

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

A rastreabilidade relaciona os grupos de requisitos com componentes e testes. Na ausência de um registo
de execução, a equipa não deve apresentar um cenário como aprovado por mera presença de um ficheiro de teste.

== Limitações e defeitos conhecidos

*TODO*: REVER ISTO PARA NAO FALAR APENAS DO UC006

- O seguimento da UC-VID-006 é realizado por consulta periódica da API; a entrega de percentagens em WebSocket,
  prevista nos requisitos transversais, não está demonstrada para esta operação.
- A seleção manual de formato e resolução de saída não faz parte do diálogo de concatenação entregue;
  o fluxo produz MP4 normalizado automaticamente.
- A validação manual ponta-a-ponta da concatenação foi comprovada numa base de código anterior. A operação
  precisa de repetição após o merge com o módulo de áudio na versão final.
- Não estão disponíveis nesta revisão os resultados consolidados das suites globais e das demonstrações
  das UC-VID-001 a 005 e 007; o estado de validação permanece explicitamente por confirmar.
- As metas quantitativas dos requisitos não funcionais não foram medidas de forma abrangente;
  estes resultados não devem ser descritos como alcançados na Fase 1.
