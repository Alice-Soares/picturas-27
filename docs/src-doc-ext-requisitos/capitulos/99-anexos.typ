#import "../template.typ": *

#set heading(numbering: "A.1.")
#counter(heading).update(0)

= Instruções de execução e validação

== Pré-requisitos

São necessários Git, Docker Desktop com suporte a Docker Compose, espaço em disco suficiente para
as imagens e volumes, e acesso às portas locais indicadas no `README.md` do repositório. As imagens dos
contentores incluem ou disponibilizam as dependências exigidas por cada serviço. A execução do ensaio
real de concatenação pressupõe FFmpeg e FFprobe dentro do contentor `projects`.

== Arranque local

Executar na raiz da solução extraída, sem apagar volumes de dados existentes:

```bash
# Construir e iniciar a aplicação
 docker compose up -d --build
# Verificar o estado dos serviços
 docker compose ps
# Aceder à interface: https://localhost:8080
```

O acesso local usa HTTPS com certificado de desenvolvimento autoassinado, pelo que o navegador pode
apresentar um aviso. Não se incluem credenciais de demonstração inventadas neste documento: a equipa
deve fornecer contas de teste válidas segundo o procedimento de autenticação implementado.

== Reproduzir os testes de concatenação

```bash
# Backend de projetos (inclui integração real de FFmpeg)
 docker compose exec projects sh -lc 'node --test test/videoMerge*.test.js'
# Gateway e autorização
 docker compose exec api_gateway node --test test/videoMergeGatewayRoute.test.js
```

O registo disponível para estes comandos documenta 65 testes aprovados no serviço de projetos e três no
gateway. Para reproduzir o fluxo manual, entrar numa conta autenticada, abrir um projeto próprio, submeter
dois vídeos MP4 compatíveis, escolher a opção de concatenação, definir a ordem, iniciar a operação e
verificar que surge um vídeo novo reproduzível e que as fontes originais continuam na biblioteca. Deve
registar-se o estado das restantes UC na mesma instalação antes da apresentação do grupo.

== Registo de evidência recomendado

Para cada caso de uso, guardar o identificador, o perfil utilizado, o conjunto de entradas, os passos
executados, o resultado observado, data de execução e referência ao teste ou captura. Os exemplos de
vídeo e as credenciais são fornecidos pela equipa quando autorizados; não são incorporados tokens,
segredos ou dados pessoais neste documento.

= Glossário

#tabela(
  colunas: (3.8cm, 1fr),
  [Termo], [Definição],
  [MVP], [Produto mínimo viável usado para validar as funcionalidades principais sem exigir maturidade de produção.],
  [Projeto], [Conjunto de conteúdos multimédia e operações associados a um utilizador no PictuRAS.],
  [Operação], [Pedido de processamento com identidade e estado persistidos, executado de forma assíncrona.],
  [Worker], [Processo que consome uma tarefa da fila e executa o tratamento solicitado.],
  [RabbitMQ], [Sistema de mensageria usado para desacoplar pedidos e operações demoradas.],
  [FFmpeg / FFprobe], [Ferramentas de processamento e análise de metadados de áudio e vídeo.],
  [SeaweedFS], [Armazenamento de objetos utilizado pela solução.],
  [Quota], [Limite de operações permitido para um perfil de utilizador.],
  [Rastreabilidade], [Ligação entre o caso de uso, requisito, componente e teste que verifica o comportamento.],
)
