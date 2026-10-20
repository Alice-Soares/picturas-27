# Data model: UC-VID-005

## VideoOperation

A operação existente é estendida com:

- `type`: `frame_extract`.
- `project_id`: projeto que contém o vídeo de origem.
- `target_project_id`: projeto que recebe as imagens.
- `source_video_id`: vídeo imutável de origem.
- `start_seconds`, `end_seconds`: intervalo selecionado.
- `max_frames`, `estimated_frames`, `extracted_frames`: configuração e progresso.
- `output_format`: `jpeg` no MVP.
- `frame_results`: chaves temporárias/persistidas, índice, timestamp e SHA-256.
- `status`, `progress`, timestamps, erro e flags de quota já existentes.

Os estados permitidos permanecem `queued`, `processing`, `completed`, `failed`
e `cancelled`.

## ProjectImage

As imagens extraídas reutilizam `project.imgs` e acrescentam metadados opcionais:

- `sourceVideoId`;
- `extractionOperationId`;
- `frameIndex`;
- `timestampSeconds`;
- `mimeType`.

Os campos existentes `og_img_key`, `og_uri`, `new_uri` e `og_sha256` continuam a
ser preenchidos para manter compatibilidade com a biblioteca de imagens.

## Relações

```text
Vídeo de origem 1 -> N Operações de extração
Operação de extração 1 -> N Fotogramas
Projeto de destino 1 -> N Fotogramas
```

Uma operação falhada ou cancelada não cria referências públicas em `project.imgs`.
