# Quickstart de validação — Submissão de vídeo

Este guia valida o `UC-VID-001` depois da implementação. O arranque segue o
[README da aplicação](../../README.md).

## Pré-requisitos

- Docker Compose disponível.
- Serviços de autenticação, projetos, API Gateway e SeaweedFS iniciados.
- Contas registada e premium, projeto autorizado e ficheiros de teste MP4/H.264.
- Ficheiros com áudio AAC, sem áudio, codec/contentor inválido e limites
  excedidos.

## Arranque

```bash
docker compose up --build
```

Abrir `https://localhost:8080` e autenticar.

## Cenários

1. Submeter MP4/H.264 dentro dos limites; confirmar referência, projeto,
   utilizador e tamanho, duração, resolução, fps e codecs.
2. Repetir com áudio AAC; confirmar os metadados da faixa sonora.
3. Tentar perfil anónimo, sessão inválida e projeto não autorizado; confirmar
   rejeição sem referência.
4. Testar contentor, codec, stream e cada limite inválido; confirmar erro
   seguro e ausência de objeto parcial.
5. Cancelar uma transferência; confirmar remoção do temporário.
6. Simular falha de rede, validação e armazenamento; confirmar limpeza.
7. Comparar a quota antes/depois; confirmar que a submissão não a reduz.
8. Tentar consultar o vídeo com outro utilizador; confirmar bloqueio.
9. Submeter um lote com um vídeo válido e um inválido; confirmar um resultado
   independente por vídeo.
10. Submeter um nome duplicado; confirmar que manter ambos cria uma nova
    referência e cancelar não altera a referência original.
11. Confirmar que a imagem do Projects Service contém FFmpeg/FFprobe e que a
    versão usada é a documentada no resultado de validação.
12. Executar os testes existentes de imagens; confirmar ausência de regressão.

## Evidência

Registar cada cenário como `pass`/`fail`, com perfil, ficheiro e motivo da
rejeição. Comparar o resultado com o [contrato](contracts/video-submission.md)
e o [modelo](data-model.md).
