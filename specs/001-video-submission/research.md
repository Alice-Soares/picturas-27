# Research: Submissão de vídeo

**Feature**: `UC-VID-001`  
**Data**: 2026-10-19

## Decisão 1 — Estender os serviços existentes

**Decision**: Integrar a submissão no API Gateway, Projects Service, Image
Storage Service/SeaweedFS e frontend existentes. Não criar um microserviço
autónomo de vídeo nesta fase.

**Rationale**: A baseline já concentra autorização e encaminhamento no API
Gateway, referências no modelo de projeto e objetos numa fachada S3.

**Alternatives considered**: Um serviço autónomo duplicaria autorização,
associação a projetos e acesso ao armazenamento; foi rejeitado para o MVP.

## Decisão 2 — Reutilizar multipart com uma variante de conteúdo

**Decision**: Manter `multipart/form-data`, mas criar uma operação explícita
de vídeo, com content-type, estágio e referência próprios. Validar o conteúdo
antes de persistir a referência.

**Rationale**: O frontend e o API Gateway já suportam multipart; reutilizar o
contrato de imagem diretamente misturaria regras incompatíveis.

**Alternatives considered**: Base64/JSON aumenta o tamanho e não reutiliza o
padrão existente; usar a rota de imagem esconderia erros de validação.

## Decisão 3 — Validar conteúdo real

**Decision**: Confirmar contentor, streams, codec, duração, resolução, fps,
tamanho e integridade antes da persistência. A ferramenta concreta será
escolhida na implementação, com FFmpeg/FFprobe como opção prevista no caso de
uso.

**Rationale**: Extensão e MIME não provam que o conteúdo é MP4/H.264/AAC nem
que contém uma faixa de vídeo legível.

**Alternatives considered**: Validar apenas extensão/MIME ou confiar em
metadados do cliente foi rejeitado.

## Decisão 4 — Aplicar limites e autorização no fluxo

**Decision**: Aplicar `RN1` a `RN4` antes da associação: registado até 100 MB,
5 minutos, largura 1920, altura 1080 e 60 fps; premium até 1 GB, 30 minutos,
largura 3840, altura 2160 e 60 fps. Qualquer dimensão acima do limite rejeita
o vídeo. A submissão não reduz a quota de operações avançadas.

**Rationale**: Os valores estão definidos na fonte funcional e nos requisitos
`REQ-VID-SUB-016` a `REQ-VID-SUB-025`.

**Alternatives considered**: Usar apenas limites da infraestrutura ou cobrar
quota no upload contrariaria o caso de uso.

## Decisão 5 — Persistência tardia e limpeza

**Decision**: Carregar para uma área temporária, validar, tornar o objeto
persistente e só então criar a referência do projeto. Em rejeição,
cancelamento ou falha, remover temporários e não criar referência.

**Rationale**: Evita referências órfãs e objetos parciais; preserva o original
para operações posteriores.

**Alternatives considered**: Criar primeiro a referência ou substituir o
original foi rejeitado por quebrar a consistência e a imutabilidade.

## Decisão 6 — Questões abertas e riscos conhecidos

**Decision**: Miniaturas automáticas, drag-and-drop, limite de uploads
simultâneos e retoma ficam fora do MVP. Embora `FA1` apresente a opção de
substituir, no MVP duplicados permitem apenas manter ambos ou cancelar; lotes
validam cada item.

**Rationale**: Mantém uma fatia vertical implementável e coerente com
`UC-VID-001`.

**Integration risks**: A baseline usa `memoryStorage()` no Gateway, Projects
Service e Storage Service, e valida depois do parsing multipart. A
implementação deve configurar limites antes do buffering e usar ficheiros
temporários em disco no Projects Service, removendo-os sempre. O MVP deve
manter a autorização, a versão do projeto e o fluxo de imagens operacionais.

## Decisão 7 — Disponibilização do analisador

**Decision**: Instalar FFmpeg/FFprobe na imagem Docker do Projects Service e
validar a versão durante a verificação da feature.

**Rationale**: A análise de streams e metadados é necessária para `SUB-005` a
`SUB-014` e não deve depender de uma instalação manual no host.

**Alternatives considered**: Executar uma ferramenta instalada no host foi
rejeitado por não ser reprodutível no Docker Compose; criar um worker separado
foi deixado para uma fase posterior.

## Decisão 8 — Limite de memória e parsing

**Decision**: Receber o upload num ficheiro temporário em disco, aplicar o
limite de corpo antes do processamento e passar o caminho temporário ao
analisador. O limite funcional mantém as unidades decimais de `RN2` e `RN3`.

**Rationale**: Evita manter vídeos de até 1 GB em memória e reduz o risco
identificado na baseline.

**Alternatives considered**: `memoryStorage()` foi rejeitado para vídeo;
rejeitar premium acima de um limite técnico novo foi rejeitado por inventar uma
regra funcional não existente.

## Decisão 9 — Lotes e duplicados

**Decision**: Cada vídeo de um lote tem resultado independente. Para nomes
duplicados, o MVP permite manter ambos ou cancelar; substituir fica fora de
âmbito. O original persistido usa o estágio `video-src`.

**Rationale**: Resultados independentes permitem sucesso parcial sem misturar
referências; manter ambos/cancelar preserva a imutabilidade do original.

**Alternatives considered**: Resultado all-or-nothing foi rejeitado por
contrariar `FA2`; substituir foi rejeitado por conflituar com a imutabilidade.
