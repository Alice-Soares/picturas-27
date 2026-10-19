# Modelo de dados: Submissão de vídeo

Este modelo descreve conceitos do domínio, não classes, tabelas ou
microserviços.

## Vídeo

Conteúdo multimédia submetido, com contentor, codec de vídeo, codec de áudio
opcional, tamanho, duração, resolução, fps e integridade.

Regras: contentor MP4; vídeo H.264; áudio AAC quando existir faixa sonora;
limites por perfil definidos em `RN2` e `RN3`.

## Referência de vídeo

Associação persistente entre vídeo armazenado, utilizador, projeto, estágio do
conteúdo e metadados extraídos. Só existe depois de todas as validações e da
persistência do objeto.

O objeto original validado usa o estágio `video-src`. Uma referência nunca é
substituída por outra durante o MVP.

## Submissão

Processo transitório de transferência e validação.

```text
em transferência -> em validação -> concluída
em transferência -> cancelada
em transferência -> falhada
em validação -> rejeitada
em validação -> falhada
```

Estados terminados sem sucesso não criam referências nem deixam temporários
acessíveis. O vídeo original é imutável depois da conclusão.

## Relações

```text
Utilizador 1 ── N Projeto
Projeto 1 ── N Referência de vídeo
Referência de vídeo 1 ── 1 Vídeo armazenado
Submissão 1 ── 0..1 Referência de vídeo
```

Num lote, cada submissão mantém o seu próprio estado e resultado. Uma falha
não altera o resultado de outro vídeo.
