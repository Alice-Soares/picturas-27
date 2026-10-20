# Modelo de dados: Aplicar ferramenta a fotogramas

## Vídeo

Referência persistente no projeto, com `id`, `userId`, `projectId`, `objectKey`,
`name`, `duration`, `width`, `height`, `fps`, `container`, `videoCodec`,
`audioCodec` e `sourceVideoId` opcional. O original é imutável; o resultado é uma
nova referência no mesmo projeto.

## Ferramenta de fotograma

Configuração da execução, não conteúdo persistente isolado.

| Campo        | Regra                                                    |
| ------------ | -------------------------------------------------------- |
| `procedure`  | Nome de uma ferramenta existente e compatível com imagem |
| `params`     | Parâmetros validados pelo contrato da ferramenta         |
| `position`   | Inteiro que define a ordem da cadeia                     |
| `outputType` | Deve ser `image` para participar da recomposição         |

## Intervalo de processamento

| Campo          | Regra                                                                      |
| -------------- | -------------------------------------------------------------------------- |
| `startSeconds` | `>= 0` e inferior à duração                                                |
| `endSeconds`   | Superior ao início e `<= duration`; omitido significa duração total        |
| `outputFps`    | Positivo e suportado pelo pipeline; não criar valores de negócio sem fonte |

## Operação `frame_tool`

| Campo                       | Regra                                                      |
| --------------------------- | ---------------------------------------------------------- |
| `id`                        | Identificador usado por API e mensagens                    |
| `type`                      | `frame_tool`                                               |
| `userId`, `projectId`       | Contexto autorizado                                        |
| `sourceVideoId`             | Vídeo de entrada imutável                                  |
| `tools`                     | Lista ordenada de ferramentas e parâmetros                 |
| `interval`                  | Início, fim e taxa de saída                                |
| `status`                    | `queued`, `processing`, `completed`, `failed`, `cancelled` |
| `progress`                  | Número entre 0 e 100, não decrescente                      |
| `attempts`                  | No máximo 2 por fotograma                                  |
| `resultVideoId`             | Preenchido apenas em sucesso                               |
| `errorCode`, `errorMessage` | Apenas em falha, sem paths internos                        |
| `quotaReservation`          | Reserva identificável para commit/refund                   |
| timestamps                  | Criação, início, conclusão e cancelamento coerentes        |

### Transições

```text
queued -> processing -> completed
queued -> cancelled
queued -> failed
processing -> completed
processing -> cancelled
processing -> failed
```

Estados terminais não transitam novamente. Cancelamento e conclusão concorrentes
aceitam apenas o primeiro estado terminal e limpam apenas os recursos próprios.

## Relações

- Um projeto contém zero ou mais vídeos e operações.
- Uma operação referencia exatamente um vídeo de origem.
- Uma operação pode criar no máximo um vídeo resultado.
- Um resultado referencia o original por `sourceVideoId`.
- Eventos da operação são visíveis apenas na sala autorizada do projeto.
