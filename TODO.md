# TODO e contexto para agentes

Este ficheiro e contexto de trabalho local para agentes LLM. Nao e especificacao oficial nem deve ser tratado como requisito aprovado. Confirmar sempre as decisoes com os documentos do repositorio e com o utilizador antes de implementar.

## Objetivo atual

Estender o PictuRAS com suporte MVP para videos, mantendo o funcionamento existente das fotografias. A implementacao de video deve ser incremental e isolada tanto quanto possivel.

Nao alterar o fluxo existente de fotografias sem necessidade comprovada.
Nao criar uma arquitetura de armazenamento paralela.
Nao assumir que uma funcionalidade descrita neste ficheiro ja esta implementada.

## Estado atual

- A aplicacao existente processa imagens/fotografias.
- O frontend e Next.js 15, React 19, TypeScript e Tailwind CSS.
- O backend e composto por servicos Node.js/Express.
- O processamento atual usa RabbitMQ e microservicos Python de ferramentas de imagem.
- O WebSocket Gateway usa Socket.IO e recebe eventos atraves de RabbitMQ.
- Os projetos guardam imagens no modelo `imgs`.
- O armazenamento e SeaweedFS compativel com S3, atraves do image storage service.
- A camada de armazenamento existente deve ser estendida, nao substituida.
- Nao existem ainda entidades, workers ou pipelines de video implementados.
- Nao existe ainda validacao FFmpeg/FFprobe implementada para videos.

## Arquitetura existente relevante

Fluxo de imagem:

1. O frontend seleciona imagens PNG/JPEG/JPG ou ZIP.
2. O frontend envia cada imagem com o campo multipart `image`.
3. O API Gateway encaminha o pedido para o projects service.
4. O projects service envia o ficheiro para o image storage service.
5. O image storage service guarda o objeto no bucket S3 do utilizador.
6. O projeto guarda a referencia da imagem e o hash SHA-256.
7. As ferramentas sao configuradas no projeto e processadas por filas RabbitMQ.
8. Os resultados sao guardados em `out` e os eventos chegam ao cliente por WebSocket.

Estagios de armazenamento existentes:

- `src`
- `preview`
- `preview_cache`
- `out`

Ficheiros de referencia do fluxo de imagem:

- `frontend/components/image-submission-area.tsx`
- `frontend/lib/projects.ts`
- `apiGateway/routes/projects.js`
- `projects/routes/projects.js`
- `projects/models/project.js`
- `projects/utils/imageStorage.js`
- `imageStorageService/route/upload.js`
- `imageStorageService/services/uploadImage.js`
- `imageStorageService/utils/stages.js`
- `wsGateway/index.js`
- `users/routes/users.js`

## Perfis e quota

- Anonimo: funcionalidades de imagem permitidas, sem suporte de video no MVP.
- Registado/free: pode carregar videos e executar jobs de video sujeitos a quota de operacoes avancadas.
- Premium: pode carregar videos e executar jobs sem limite diario de operacoes.
- O upload de video nao consome quota.
- Cada job de processamento de video aceite conta como uma operacao avancada para utilizadores registados.
- Um job que falha, e cancelado ou termina sem efeito nao consome quota.
- A quota deve ser reservada antes do processamento e devolvida em falhas/cancelamentos quando essa mecanica for implementada.
- A aplicacao atual controla quota sobretudo para ferramentas avancadas de imagem. O suporte de quota de video ainda tem de ser implementado sem quebrar essa logica.

## Limites MVP definidos nos use cases

Utilizador registado:

- video ate 100 MB
- duracao ate 5 minutos
- resolucao ate 1920x1080
- ate 60 fps
- extracao ate 1000 fotogramas por job
- concatenacao de 2 a 5 videos, com duracao total ate 5 minutos

Utilizador premium:

- video ate 1 GB
- duracao ate 30 minutos
- resolucao ate 3840x2160
- ate 60 fps
- extracao ate 5000 fotogramas por job
- concatenacao de 2 a 15 videos, com duracao total ate 30 minutos

Estes valores sao decisoes de MVP documentadas nos use cases. Rever com a equipa/docente antes da implementacao se necessario.

## Formatos MVP

- Entrada de video: MP4 com video H.264.
- Audio no video: AAC quando existir; videos sem audio sao validos.
- Audio para substituicao: MP3 ou M4A/AAC.
- Audio extraido: M4A com AAC.
- Saida de video: MP4, mantendo o original intacto.
- Nao adicionar uma lista extensa de codecs no MVP.
- Validar contentor, streams, codec, duracao, resolucao, fps e tamanho com FFprobe ou equivalente.

## Politica de audio

`UC-VID-007` cobre remover, substituir e extrair audio.

Remover audio de video sem audio:

- apresentar aviso de que o video ja nao tem faixa de audio;
- nao criar novo ficheiro;
- nao iniciar job;
- nao consumir quota.

Extrair audio de video sem audio:

- apresentar erro;
- nao criar resultado;
- nao iniciar job;
- nao consumir quota.

Substituir audio:

- o utilizador fornece um ficheiro MP3 ou M4A/AAC;
- pode escolher opcionalmente o intervalo de audio a usar;
- se o audio terminar antes do video, o restante video fica sem som;
- se o audio ultrapassar a duracao do video, e cortado no fim do video;
- o resultado e um novo MP4 com audio AAC;
- o video original e preservado.

## Use cases existentes

- `docs/use-cases/UC-VID-001-submeter-video.md`
- `docs/use-cases/UC-VID-002-recorte-temporal.md`
- `docs/use-cases/UC-VID-003-aplicar-ferramenta-fotogramas.md`
- `docs/use-cases/UC-VID-004-converter-formato-resolucao.md`
- `docs/use-cases/UC-VID-005-extrair-fotogramas.md`
- `docs/use-cases/UC-VID-006.md`
- `docs/use-cases/UC-VID-007-gerir-audio.md`

Os use cases devem respeitar apenas as secoes 0 a 3 do template do Exercico 1. A secao 4 e para trabalho posterior.

## Templates e documentos de referencia

- `docs/RAS-exercicio_1_template_PT-v2.md`: estrutura obrigatoria dos use cases.
- `docs/RAS-exercicio_2_template_PT-v2.md`: referencia futura para requisitos derivados.
- `docs/Enunciado.md`: contexto geral da Fase 1 e objetivo de suporte a video.
- `docs/doc-ext-requisitos.pdf`: requisitos e arquitetura herdados; consultar a versao PDF quando houver duvida.
- `README.md`: arquitetura, comandos e funcionamento atual.

## Ordem recomendada de implementacao

1. Confirmar limites, formatos, perfis, quota e comportamento de falhas.
2. Definir uma representacao de conteudo de video que nao quebre `imgs` nem o processamento de fotografias.
3. Criar validacao de video com FFprobe.
4. Estender upload e armazenamento com uma convencao de chaves/estagios compativel com a camada S3 existente.
5. Criar estados persistentes de job: `queued`, `processing`, `completed`, `failed`, `cancelled`.
6. Criar um worker/base de video com FFmpeg.
7. Implementar primeiro upload e recorte temporal.
8. Implementar conversao, extracao de fotogramas e concatenacao.
9. Implementar aplicar ferramentas de imagem a fotogramas.
10. Implementar gestao de audio, incluindo substituicao.
11. Integrar progresso e cancelamento no RabbitMQ/WebSocket.
12. Testar regressao do fluxo de fotografias depois de cada extensao.

## Regras para agentes LLM

- Ler o use case e o codigo dono do comportamento antes de editar.
- Fazer a menor alteracao necessaria.
- Preservar APIs e dados de fotografias.
- Nao substituir SeaweedFS/S3 por outro armazenamento.
- Nao introduzir MinIO novo; o README documenta a migracao existente para SeaweedFS.
- Usar parsers/FFprobe/FFmpeg para metadata e processamento, nao extensoes de ficheiro como unica validacao.
- Manter o original e guardar resultados como novos conteudos.
- Tratar falhas de forma atomica: limpar temporarios, marcar job e devolver quota reservada.
- Validar com testes focados e depois testes de regressao das fotografias.
- Nao assumir que filas, workers, FFmpeg, entidades de video ou progresso percentual ja existem.
- Atualizar documentacao e testes quando uma decisao for implementada.

## Proximas decisoes pendentes

- Confirmar o numero mecanografico de Samuel.
- Confirmar com a equipa/docente os limites MVP.
- Decidir se varias faixas de audio serao selecionaveis.
- Definir a forma exata de reserva/devolucao da quota no users service.
- Definir o modelo de dados para videos, resultados e audio sem alterar o modelo existente de imagens.
- Definir a convencao final de estagios/chaves no armazenamento S3.
- Definir os eventos WebSocket e percentagens de progresso.
