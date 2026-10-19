# Specification Quality Checklist: Submissão de vídeo

**Purpose**: Validar a completude e a qualidade da especificação do `UC-VID-001` antes do planeamento.
**Created**: 2026-10-19
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] Não há detalhes de implementação nos requisitos; as referências técnicas estão limitadas ao impacto e às fontes.
- [x] A especificação está focada no valor para o utilizador e para o sistema.
- [x] Os cenários e resultados são compreensíveis para stakeholders não técnicos.
- [x] Todas as secções obrigatórias do template estão preenchidas.

## Requirement Completeness

- [x] Não existem marcadores `[NEEDS CLARIFICATION]`.
- [x] Os 33 requisitos de submissão mantêm os IDs oficiais e são verificáveis.
- [x] Os critérios de sucesso são mensuráveis e verificáveis.
- [x] Os critérios de sucesso não dependem de uma implementação específica.
- [x] Existem cenários de aceitação para sucesso, rejeição e falha/cancelamento.
- [x] Os casos-limite do `UC-VID-001` estão identificados.
- [x] O âmbito e o que fica fora estão explicitamente delimitados.
- [x] Dependências, pressupostos e decisões de âmbito estão documentados.

## Feature Readiness

- [x] Cada requisito funcional tem cobertura por cenários, rastreabilidade ou ambos.
- [x] As histórias cobrem os fluxos principais e alternativos do caso de uso.
- [x] Os resultados esperados estão ligados aos critérios de sucesso.
- [x] A implementação posterior pode ser planeada sem inventar limites ou regras.
- [x] FFmpeg/FFprobe, parsing em ficheiro temporário, estágio `video-src`,
  resultados individuais de lote, unidades decimais, regra de resolução e
  comportamento de duplicados estão decididos e refletidos nos artefactos.

## Notes

- A spec trata miniaturas, drag-and-drop, limite de uploads simultâneos e retoma
  como fora do MVP, conforme as questões abertas de `UC-VID-001`.
- Requisitos transversais de processamento assíncrono, quota de operações,
  estados de trabalhos e progresso serão especificados uma vez quando forem
  necessários pelos casos `UC-VID-002` a `UC-VID-007`; não são duplicados nesta
  funcionalidade de submissão.
- O MVP não substitui vídeos duplicados: permite manter ambos ou cancelar para
  preservar a imutabilidade do original.
- A análise usa FFmpeg/FFprobe no container do Projects Service e o upload de
  vídeo usa ficheiro temporário em disco, não o vídeo completo em memória.
