# Research: UC-VID-005

## Baseline

- Commit: `f782daa`.
- `VideoOperation` já suportava `trim` e `frame_tool`, com estados e quota.
- `videoFramePipeline` já extraía frames temporários em disco, mas apenas como PNG.
- O Image Storage Service aceitava uploads multipart de imagens em memória.

## Decisões verificadas

- A extração usa uma operação e fila próprias (`frame_extract` / `video_frame_extract`) para não misturar o contrato de aplicação de ferramentas.
- O worker reutiliza `extractFrames`, agora com formato configurável e limite de frames.
- Cada JPEG é enviado individualmente para o stage `src`; o worker não acumula o lote completo em memória.
- As referências só são adicionadas a `project.imgs` depois de todos os uploads concluírem.
- Em falha/cancelamento, as chaves carregadas são eliminadas de forma best-effort e o staging local é removido.
- A quota registada usa o mecanismo existente de reserva/refund; premium não reserva quota.

## Limitações conhecidas

- A verificação de espaço disponível depende de um contrato de storage ainda não exposto pelo serviço; a validação atual cobre limites de frames, mas não mede bytes livres.
- A API aceita `targetProjectId`, mas a UI atual usa o projeto ativo como destino predefinido.
- A autorização final de eventos WebSocket continua dependente do mecanismo de salas existente; o Projects Service restringe as operações por utilizador/projeto.
- Não foi criado um ambiente end-to-end Docker nesta execução; os testes unitários/backend e o build frontend foram executados.
