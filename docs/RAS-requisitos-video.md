# Especificação de Requisitos — Suporte a Vídeo no PictuRAS

**Baseline:** UC-VID-001 a UC-VID-007, versão v1.1, 2026-10-17
**Âmbito:** MVP de submissão e processamento de vídeo  
**Origem:** casos de uso existentes em `docs/use-cases/`

Este documento é o catálogo consolidado de requisitos da extensão de vídeo, derivados dos sete casos de uso existentes. 

A indicação `NOVO` significa que a capacidade não existe no PictuRAS atual; `ALT` significa que uma regra ou mecanismo existente tem de ser estendido para suportar vídeo.

## Cobertura dos casos de uso

Os requisitos específicos de cada caso de uso estão identificados pelo prefixo correspondente. Os requisitos `COM` são transversais e aplicam-se aos casos de processamento que os referenciam.

| Caso de uso | Funcionalidade coberta| Requisitos específicos | Requisitos transversais |
|---|---|---|---|
| UC-VID-001 | Submeter vídeo | `SUB-001` a `SUB-033` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-002 | Recorte temporal | `TRIM-001` a `TRIM-013` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-003 | Aplicar ferramenta aos fotogramas | `FRM-001` a `FRM-014` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-004 | Converter formato e resolução | `CONV-001` a `CONV-011` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-005 | Extrair fotogramas | `FEX-001` a `FEX-011` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-006 | Concatenar vídeos | `MERGE-001` a `MERGE-015` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |
| UC-VID-007 | Gerir áudio | `AUD-001` a `AUD-016` | `COM-001` a `COM-020`, `Q-001` a `Q-016` |

## 4.1 Requisitos de Sistema

### 4.1.1 Requisitos Funcionais e restrições

#### Submissão de vídeo — UC-VID-001

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-SUB-001 | O sistema deve permitir a submissão de vídeo a utilizadores registados ou premium autenticados. | F | Deve ter | ALT | UC-VID-001, pré-condições, RN1 | Submeter vídeo com sessão válida de utilizador registado e premium. |
| REQ-VID-SUB-002 | O sistema deve rejeitar a submissão de vídeo por utilizadores anónimos. | F | Deve ter | ALT | UC-VID-001, FA4 | Tentar submeter vídeo sem autenticação. |
| REQ-VID-SUB-003 | O sistema deve rejeitar a submissão de vídeo com uma sessão inválida. | F | Deve ter | ALT | UC-VID-001, FA4 | Tentar submeter vídeo com sessão inválida. |
| REQ-VID-SUB-004 | O sistema deve iniciar a validação do ficheiro submetido antes de o associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passos 6-8 | Submeter um ficheiro e verificar a ordem das operações. |
| REQ-VID-SUB-005 | O sistema deve aceitar no MVP o contentor MP4. | F | Deve ter | NOVO | UC-VID-001, RN4 | Submeter MP4 e verificar aceitação. |
| REQ-VID-SUB-006 | O sistema deve aceitar no MVP vídeo codificado com H.264. | F | Deve ter | NOVO | UC-VID-001, RN4 | Submeter H.264 e verificar aceitação. |
| REQ-VID-SUB-007 | O sistema deve aceitar áudio AAC quando o vídeo submetido tiver faixa sonora. | F | Deve ter | NOVO | UC-VID-001, RN4 | Submeter MP4 com áudio AAC. |
| REQ-VID-SUB-008 | O sistema deve rejeitar contentores de vídeo não suportados. | F | Deve ter | NOVO | UC-VID-001, exceções | Submeter um contentor não suportado. |
| REQ-VID-SUB-009 | O sistema deve validar que o ficheiro contém uma faixa de vídeo legível. | F | Deve ter | NOVO | UC-VID-001, RN4 | Submeter ficheiro sem faixa de vídeo ou corrompido. |
| REQ-VID-SUB-010 | O sistema deve calcular o tamanho do ficheiro antes de o associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passos 6-8 | Submeter ficheiros de tamanhos diferentes e inspecionar a validação. |
| REQ-VID-SUB-011 | O sistema deve extrair a duração do vídeo antes de o associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passos 6-8 | Inspecionar os metadados de uma submissão válida. |
| REQ-VID-SUB-012 | O sistema deve extrair o codec do vídeo antes de o associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passo 7 | Comparar o codec persistido com FFprobe. |
| REQ-VID-SUB-013 | O sistema deve extrair a resolução do vídeo antes de o associar ao projeto. | F | Deve ter | NOVO | UC-VID-001, passo 7 | Comparar a resolução persistida com FFprobe. |
| REQ-VID-SUB-014 | O sistema deve extrair a taxa de fotogramas antes de associar o vídeo ao projeto. | F | Deve ter | NOVO | UC-VID-001, passo 7 | Comparar a taxa persistida com FFprobe. |
| REQ-VID-SUB-015 | O sistema deve criar uma referência de vídeo apenas depois de todas as validações passarem. | F | Deve ter | ALT | UC-VID-001, passos 9-10, RN7-RN8 | Submeter vídeo válido e verificar a criação da referência. |
| REQ-VID-SUB-016 | O sistema deve rejeitar vídeos superiores a 100 MB para utilizadores registados que não sejam premium. | F | Deve ter | ALT | UC-VID-001, RN2 | Submeter ficheiro acima de 100 MB com perfil registado não premium. |
| REQ-VID-SUB-017 | O sistema deve rejeitar vídeos superiores a 5 minutos para utilizadores registados que não sejam premium. | F | Deve ter | ALT | UC-VID-001, RN2 | Submeter vídeo acima de 5 minutos com perfil registado não premium. |
| REQ-VID-SUB-018 | O sistema deve rejeitar vídeos cuja largura exceda 1920 ou cuja altura exceda 1080 para utilizadores registados que não sejam premium. | F | Deve ter | ALT | UC-VID-001, RN2 | Testar largura e altura acima dos limites com perfil registado não premium. |
| REQ-VID-SUB-019 | O sistema deve rejeitar vídeos acima de 60 fps para utilizadores registados que não sejam premium. | F | Deve ter | ALT | UC-VID-001, RN2 | Submeter vídeo acima da taxa com perfil registado não premium. |
| REQ-VID-SUB-020 | O sistema deve rejeitar vídeos superiores a 1 GB para utilizadores premium. | F | Deve ter | ALT | UC-VID-001, RN3 | Submeter ficheiro acima de 1 GB com perfil premium. |
| REQ-VID-SUB-021 | O sistema deve rejeitar vídeos superiores a 30 minutos para utilizadores premium. | F | Deve ter | ALT | UC-VID-001, RN3 | Submeter vídeo acima de 30 minutos com perfil premium. |
| REQ-VID-SUB-022 | O sistema deve rejeitar vídeos cuja largura exceda 3840 ou cuja altura exceda 2160 para utilizadores premium. | F | Deve ter | ALT | UC-VID-001, RN3 | Testar largura e altura acima dos limites com perfil premium. |
| REQ-VID-SUB-023 | O sistema deve rejeitar vídeos acima de 60 fps para utilizadores premium. | F | Deve ter | ALT | UC-VID-001, RN3 | Submeter vídeo acima da taxa com perfil premium. |
| REQ-VID-SUB-024   | O sistema deve remover objetos temporários e não criar referências persistentes quando a submissão for rejeitada, cancelada ou falhar.                            | F    | Deve ter    | NOVO     | UC-VID-001, FA3, exceções, pós-condição mínima       | Interromper e falhar submissões e verificar armazenamento e base de dados.            |
| REQ-VID-SUB-025   | O sistema não deve contabilizar a submissão de vídeo na quota diária de operações avançadas.                                                                      | F    | Deve ter    | ALT      | UC-VID-001, RN5                                      | Comparar a quota antes e depois de uma submissão válida.                              |
| REQ-VID-SUB-026 | O sistema deve associar a referência de vídeo ao utilizador que efetuou a submissão. | F | Deve ter | ALT | UC-VID-001, passos 9-10 | Submeter vídeo e verificar o utilizador associado. |
| REQ-VID-SUB-027 | O sistema deve associar a referência de vídeo ao projeto selecionado. | F | Deve ter | ALT | UC-VID-001, passos 9-10 | Submeter vídeo e verificar o projeto associado. |
| REQ-VID-SUB-028 | O sistema deve associar os metadados extraídos à referência de vídeo. | F | Deve ter | ALT | UC-VID-001, passos 9-10 | Comparar os metadados persistidos com FFprobe. |
| REQ-VID-SUB-029 | O sistema deve associar o objeto armazenado no estágio persistente `video-src` à referência de vídeo. | F | Deve ter | ALT | UC-VID-001, passos 9-10, RN8 | Verificar a referência do objeto no armazenamento e o estágio persistido. |
| REQ-VID-SUB-030 | O sistema deve devolver um resultado independente para cada vídeo de um lote. | F | Deve ter | NOVO | UC-VID-001, FA2 | Submeter um lote misto e verificar o estado de cada vídeo. |
| REQ-VID-SUB-031 | O sistema deve permitir manter ambos ou cancelar quando o nome do vídeo duplicar um conteúdo existente, sem substituir o original no MVP. | F | Deve ter | NOVO | UC-VID-001, FA1, RN8 | Submeter nome duplicado e executar as duas opções. |
| REQ-VID-SUB-032 | O sistema deve aplicar os limites de tamanho usando unidades decimais: 1 MB corresponde a 1 000 000 bytes e 1 GB corresponde a 1 000 000 000 bytes. | F | Deve ter | NOVO | UC-VID-001, RN9 | Testar valores no limite e acima dele. |
| REQ-VID-SUB-033 | O sistema deve receber o vídeo completo em ficheiro temporário em disco, sem o manter completo em memória durante a submissão. | F | Deve ter | NOVO | UC-VID-001, RN10 | Inspecionar o fluxo de upload e o consumo de memória. |

#### Recorte temporal — UC-VID-002

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|

| REQ-VID-TRIM-001  | O sistema deve disponibilizar o progresso do recorte ao utilizador durante o processamento.                                                                       | F    | Deve ter    | NOVO     | UC-VID-002, passo 9                                  | Executar um recorte demorado e verificar atualizações de progresso.                   |
| REQ-VID-TRIM-002 | O sistema deve apresentar a duração do vídeo selecionado para orientar a escolha do intervalo. | F | Deve ter | NOVO | UC-VID-002, passo 3 | Abrir a ferramenta e comparar com os metadados. |
| REQ-VID-TRIM-003 | O sistema deve permitir definir o instante inicial do recorte. | F | Deve ter | NOVO | UC-VID-002, passo 4 | Definir um instante inicial válido. |
| REQ-VID-TRIM-004 | O sistema deve permitir definir o instante final do recorte. | F | Deve ter | NOVO | UC-VID-002, passo 4 | Definir um instante final válido. |
| REQ-VID-TRIM-005 | O sistema deve rejeitar um instante inicial negativo ou superior à duração do vídeo. | F | Deve ter | NOVO | UC-VID-002, exceções | Testar valores fora do intervalo. |
| REQ-VID-TRIM-006 | O sistema deve rejeitar um instante final negativo ou superior à duração do vídeo. | F | Deve ter | NOVO | UC-VID-002, exceções | Testar valores fora do intervalo. |
| REQ-VID-TRIM-007 | O sistema deve rejeitar um intervalo cujo instante inicial não seja anterior ao instante final. | F | Deve ter | NOVO | UC-VID-002, RN1 | Testar início igual e posterior ao fim. |
| REQ-VID-TRIM-008 | O sistema deve rejeitar um segmento com duração inferior a 1 segundo. | F | Deve ter | NOVO | UC-VID-002, RN1 | Submeter um segmento inferior a 1 segundo. |
| REQ-VID-TRIM-009 | O sistema deve criar uma operação de recorte em estado `em fila` depois da confirmação e validação. | F | Deve ter | NOVO | UC-VID-002, passos 5-6 | Confirmar um recorte e consultar o estado. |
| REQ-VID-TRIM-010 | O sistema deve executar o recorte de forma assíncrona através de uma operação de vídeo no RabbitMQ. | F | Deve ter | NOVO | UC-VID-002, passos 6-8 | Verificar publicação e consumo da operação. |
| REQ-VID-TRIM-011 | O sistema deve guardar o segmento como novo vídeo. | F | Deve ter | NOVO | UC-VID-002, RN5 | Comparar o resultado com o segmento solicitado. |
| REQ-VID-TRIM-012 | O sistema deve permitir cancelar a operação em fila ou em processamento e marcar o estado como `cancelada`, sem consumir quota. | F | Deve ter | NOVO | UC-VID-002, FA1-FA2 | Cancelar nos dois estados e consultar o estado final. |
| REQ-VID-TRIM-013 | O sistema deve preservar o áudio correspondente quando o segmento original tiver áudio. | F | Deve ter | NOVO | UC-VID-002, RN5 | Comparar a faixa de áudio original e resultante. |

#### Ferramenta de imagem aplicada a fotogramas — UC-VID-003

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-FRM-001 | O sistema deve apresentar as ferramentas de imagem existentes que aceitam uma imagem por fotograma. | F | Deve ter | ALT | UC-VID-003, passo 3 | Consultar as ferramentas apresentadas. |
| REQ-VID-FRM-002 | O sistema deve rejeitar a seleção de uma ferramenta que não produza uma imagem por fotograma. | F | Deve ter | ALT | UC-VID-003, exceção | Tentar selecionar ferramenta incompatível. |
| REQ-VID-FRM-003 | O sistema deve permitir configurar os parâmetros da ferramenta selecionada. | F | Deve ter | ALT | UC-VID-003, passo 4 | Configurar parâmetros válidos. |
| REQ-VID-FRM-004 | O sistema deve permitir definir o intervalo temporal dos fotogramas a processar. | F | Deve ter | NOVO | UC-VID-003, passo 5 | Definir intervalo parcial. |
| REQ-VID-FRM-005 | O sistema deve permitir definir a taxa de fotogramas a processar. | F | Deve ter | NOVO | UC-VID-003, passo 5 | Definir uma taxa válida. |
| REQ-VID-FRM-006 | O sistema deve validar que o vídeo respeita os limites do perfil antes de iniciar a operação. | F | Deve ter | NOVO | UC-VID-003, passo 8, RN3 | Testar um vídeo acima dos limites. |
| REQ-VID-FRM-007 | O sistema deve extrair apenas os fotogramas pertencentes ao intervalo configurado. | F | Deve ter | NOVO | UC-VID-003, passos 5, 9-10 | Verificar primeiro e último fotograma processados. |
| REQ-VID-FRM-008 | O sistema deve enviar cada fotograma elegível para a ferramenta de imagem selecionada. | F | Deve ter | ALT | UC-VID-003, passo 10 | Inspecionar mensagens e resultados do worker. |
| REQ-VID-FRM-009 | O sistema deve recompor os fotogramas processados num novo vídeo. | F | Deve ter | NOVO | UC-VID-003, passo 11 | Reproduzir e inspecionar o resultado. |
| REQ-VID-FRM-010 | O sistema deve preservar a faixa de áudio original quando a configuração não exigir a sua alteração. | F | Deve ter | NOVO | UC-VID-003, RN4 | Comparar a faixa de áudio original e resultante. |
| REQ-VID-FRM-011 | O sistema deve aplicar ferramentas encadeadas pela ordem escolhida pelo utilizador. | F | Deveria ter | ALT | UC-VID-003, FA1 | Aplicar duas ferramentas e verificar a ordem. |
| REQ-VID-FRM-012 | O sistema deve repetir o processamento de um fotograma que falhe. | F | Deve ter | NOVO | UC-VID-003, FA2 | Provocar uma falha recuperável e verificar a repetição. |
| REQ-VID-FRM-013 | O sistema deve terminar a operação como `falhada` quando a repetição do fotograma falhar. | F | Deve ter | NOVO | UC-VID-003, FA2 | Provocar uma falha persistente e verificar o estado. |
| REQ-VID-FRM-014 | O sistema deve preservar a resolução de vídeo original quando a configuração não exigir a sua alteração. | F | Deve ter | NOVO | UC-VID-003, RN4 | Comparar a resolução do vídeo original e resultante. |

#### Conversão de formato e resolução — UC-VID-004

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-CONV-001 | O sistema deve apresentar o contentor de origem e os seus metadados. | F | Deve ter | NOVO | UC-VID-004, passos 1-3 | Abrir a conversão e comparar metadados. |
| REQ-VID-CONV-002 | O sistema deve apresentar os contentores de saída suportados pelo MVP. | F | Deve ter | NOVO | UC-VID-004, passo 3, RN1 | Consultar as opções disponíveis. |
| REQ-VID-CONV-003 | O sistema deve apresentar os codecs de saída suportados para cada contentor. | F | Deve ter | NOVO | UC-VID-004, passo 3, RN1 | Consultar combinações apresentadas. |
| REQ-VID-CONV-004 | O sistema deve permitir selecionar uma resolução de saída. | F | Deve ter | NOVO | UC-VID-004, passo 4 | Selecionar resolução válida. |
| REQ-VID-CONV-005 | O sistema deve rejeitar uma combinação de contentor e codec não suportada. | F | Deve ter | NOVO | UC-VID-004, exceção | Submeter combinação inválida. |
| REQ-VID-CONV-006 | O sistema deve rejeitar uma resolução cuja largura exceda 1920 ou cuja altura exceda 1080 para utilizadores registados. | F | Deve ter | ALT | UC-VID-004, RN2 | Testar largura e altura acima do limite. |
| REQ-VID-CONV-007 | O sistema deve rejeitar uma resolução cuja largura exceda 3840 ou cuja altura exceda 2160 para utilizadores premium. | F | Deve ter | ALT | UC-VID-004, RN2 | Testar largura e altura acima do limite. |
| REQ-VID-CONV-008 | O sistema deve apresentar uma estimativa do tamanho do resultado antes da confirmação, quando esta puder ser calculada. | F | Deveria ter | NOVO | UC-VID-004, passo 5 | Configurar uma conversão e verificar a estimativa. |
| REQ-VID-CONV-009 | O sistema deve executar a conversão de forma assíncrona. | F | Deve ter | NOVO | UC-VID-004, passos 7-8 | Verificar que a confirmação não bloqueia até ao fim. |
| REQ-VID-CONV-010 | O sistema deve guardar o vídeo convertido como novo conteúdo sem substituir o original. | F | Deve ter | NOVO | UC-VID-004, pós-condição | Comparar os objetos antes e depois. |
| REQ-VID-CONV-011 | O sistema deve comunicar o progresso da conversão. | F | Deve ter | NOVO | UC-VID-004, passos 7-8 | Consultar os eventos durante a conversão. |

#### Extração de fotogramas — UC-VID-005

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-FEX-001 | O sistema deve permitir definir o instante inicial da extração. | F | Deve ter | NOVO | UC-VID-005, passo 3 | Definir início válido. |
| REQ-VID-FEX-002 | O sistema deve permitir definir o instante final da extração. | F | Deve ter | NOVO | UC-VID-005, passo 3 | Definir fim válido. |
| REQ-VID-FEX-003 | O sistema deve permitir definir a quantidade máxima de fotogramas. | F | Deve ter | NOVO | UC-VID-005, passo 3 | Definir quantidade válida. |
| REQ-VID-FEX-004 | O sistema deve permitir selecionar JPEG como formato de saída do MVP. | F | Deve ter | ALT | UC-VID-005, RN2 | Verificar o formato dos resultados. |
| REQ-VID-FEX-005 | O sistema deve calcular uma estimativa da quantidade de fotogramas antes da confirmação. | F | Deve ter | NOVO | UC-VID-005, passo 5 | Comparar a estimativa com a configuração. |
| REQ-VID-FEX-006 | O sistema deve limitar uma operação a 1000 fotogramas para utilizadores registados. | F | Deve ter | ALT | UC-VID-005, RN2 | Tentar exceder o limite. |
| REQ-VID-FEX-007 | O sistema deve limitar uma operação a 5000 fotogramas para utilizadores premium. | F | Deve ter | ALT | UC-VID-005, RN2 | Tentar exceder o limite. |
| REQ-VID-FEX-008 | O sistema deve verificar o espaço disponível antes de iniciar a extração. | F | Deve ter | NOVO | UC-VID-005, passo 7 | Simular armazenamento insuficiente. |
| REQ-VID-FEX-009 | O sistema deve guardar cada fotograma extraído como imagem JPEG no projeto escolhido. | F | Deve ter | ALT | UC-VID-005, passos 10-12, RN4 | Verificar imagens, formato e projeto. |
| REQ-VID-FEX-010 | O sistema deve permitir escolher o projeto atual ou um projeto novo para os fotogramas. | F | Deveria ter | ALT | UC-VID-005, FA3, Q2 | Executar as duas opções. |
| REQ-VID-FEX-011 | O sistema deve eliminar os fotogramas temporários quando a extração for cancelada ou falhar. | F | Deve ter | NOVO | UC-VID-005, FA2, exceção | Cancelar e provocar falha durante a extração. |

#### Concatenação de vídeos — UC-VID-006

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-MERGE-001 | O sistema deve permitir selecionar pelo menos dois vídeos do mesmo projeto. | F | Deve ter | NOVO | UC-VID-006, RN1 | Selecionar zero, um e dois vídeos. |
| REQ-VID-MERGE-002 | O sistema deve limitar a seleção a cinco vídeos para utilizadores registados. | F | Deve ter | NOVO | UC-VID-006, RN1 | Testar cinco e seis vídeos. |
| REQ-VID-MERGE-003 | O sistema deve limitar a seleção a quinze vídeos para utilizadores premium. | F | Deve ter | NOVO | UC-VID-006, RN1 | Testar quinze e dezasseis vídeos. |
| REQ-VID-MERGE-004 | O sistema deve permitir ordenar os vídeos selecionados. | F | Deve ter | NOVO | UC-VID-006, passos 2-3 | Alterar a ordem e confirmar a pré-visualização. |
| REQ-VID-MERGE-005 | O sistema deve calcular a duração total dos vídeos pela ordem selecionada. | F | Deve ter | NOVO | UC-VID-006, passo 3, RN2 | Comparar cálculo com os metadados. |
| REQ-VID-MERGE-006 | O sistema deve rejeitar uma duração total superior a 5 minutos para utilizadores registados. | F | Deve ter | NOVO | UC-VID-006, RN2 | Testar no limite e acima dele. |
| REQ-VID-MERGE-007 | O sistema deve rejeitar uma duração total superior a 30 minutos para utilizadores premium. | F | Deve ter | NOVO | UC-VID-006, RN2 | Testar no limite e acima dele. |
| REQ-VID-MERGE-008 | O sistema deve rejeitar um vídeo de entrada inacessível antes de criar a operação. | F | Deve ter | NOVO | UC-VID-006, exceção | Tornar uma entrada indisponível e confirmar rejeição. |
| REQ-VID-MERGE-010 | O sistema deve concatenar os vídeos pela ordem confirmada pelo utilizador. | F | Deve ter | NOVO | UC-VID-006, passos 3, 8 | Usar vídeos identificáveis e verificar a sequência. |
| REQ-VID-MERGE-011 | O sistema deve preservar as faixas de áudio quando forem compatíveis com a concatenação. | F | Deve ter | NOVO | UC-VID-006, passo 8, Q2 | Concatenar vídeos com áudio compatível. |
| REQ-VID-MERGE-012 | O sistema deve guardar a concatenação como novo vídeo. | F | Deve ter | NOVO | UC-VID-006, RN3, pós-condição | Verificar a criação do novo vídeo. |
| REQ-VID-MERGE-013 | O sistema deve manter inalteradas todas as origens da concatenação. | F | Deve ter | NOVO | UC-VID-006, RN3, pós-condição | Comparar hashes e referências dos originais. |
| REQ-VID-MERGE-014 | O sistema deve rejeitar um vídeo de entrada corrompido antes de criar a operação. | F | Deve ter | NOVO | UC-VID-006, exceção | Submeter uma entrada corrompida e confirmar a rejeição. |
| REQ-VID-MERGE-015 | O sistema deve rejeitar um vídeo de entrada inválido antes de criar a operação. | F | Deve ter | NOVO | UC-VID-006, exceção | Submeter uma entrada inválida e confirmar a rejeição. |

#### Gestão de áudio — UC-VID-007

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-AUD-001 | O sistema deve apresentar a opção de remover áudio. | F | Deve ter | NOVO | UC-VID-007, passo 1 | Abrir a ferramenta de áudio e verificar a opção. |
| REQ-VID-AUD-002 | O sistema deve permitir confirmar a remoção da faixa de áudio. | F | Deve ter | NOVO | UC-VID-007, passos 1-2 | Confirmar remoção num vídeo com áudio. |
| REQ-VID-AUD-003 | O sistema deve permitir selecionar um ficheiro de áudio ou um vídeo com faixa sonora para substituição. | F | Deve ter | NOVO | UC-VID-007, passo 2 | Selecionar áudio ou vídeo com faixa sonora. |
| REQ-VID-AUD-004 | O sistema deve aceitar MP3 como entrada de substituição. | F | Deve ter | NOVO | UC-VID-007, RN5 | Substituir com MP3. |
| REQ-VID-AUD-005 | O sistema deve aceitar M4A/AAC como entrada de substituição. | F | Deve ter | NOVO | UC-VID-007, RN5 | Substituir com M4A/AAC. |
| REQ-VID-AUD-006 | O sistema deve rejeitar áudio que não seja MP3 ou M4A/AAC, vídeos sem faixa sonora e entradas cujo conteúdo não possa ser descodificado. | F | Deve ter | NOVO | UC-VID-007, RN5 | Selecionar formato de áudio não suportado, vídeo sem áudio ou entrada inválida. |
| REQ-VID-AUD-007 | O sistema deve permitir selecionar um intervalo opcional do áudio de substituição. | F | Deveria ter | NOVO | UC-VID-007, FA2 | Selecionar início e fim do áudio. |
| REQ-VID-AUD-008 | O sistema deve cortar o áudio de substituição quando este ultrapassar a duração do vídeo. | F | Deve ter | NOVO | UC-VID-007, FA2 | Substituir com áudio mais longo. |
| REQ-VID-AUD-009 | O sistema deve deixar sem áudio o restante do vídeo quando o áudio de substituição for mais curto. | F | Deve ter | NOVO | UC-VID-007, FA2 | Substituir com áudio mais curto. |
| REQ-VID-AUD-010 | O sistema deve rejeitar a extração quando o vídeo não tiver uma faixa de áudio. | F | Deve ter | NOVO | UC-VID-007, FA1 | Extrair áudio de vídeo sem áudio. |
| REQ-VID-AUD-011 | O sistema deve gerar áudio AAC em contentor M4A quando a opção de extração for concluída. | F | Deve ter | NOVO | UC-VID-007, passo 7 | Inspecionar contentor e codec. |
| REQ-VID-AUD-012 | O sistema deve guardar como novo conteúdo na biblioteca do projeto cada vídeo resultante de remoção ou substituição de áudio. | F | Deve ter | NOVO | UC-VID-007, RN3, pós-condição | Verificar a criação do vídeo resultante. |
| REQ-VID-AUD-013 | O sistema deve apresentar a opção de substituir áudio. | F | Deve ter | NOVO | UC-VID-007, passo 1 | Abrir a ferramenta de áudio e verificar a opção. |
| REQ-VID-AUD-014 | O sistema deve apresentar a opção de extrair áudio. | F | Deve ter | NOVO | UC-VID-007, passo 1 | Abrir a ferramenta de áudio e verificar a opção. |
| REQ-VID-AUD-015 | O sistema deve disponibilizar o áudio extraído em M4A/AAC para transferência para o dispositivo do utilizador, sem o adicionar à biblioteca do projeto. | F | Deve ter | NOVO | UC-VID-007, RN6, pós-condição | Extrair áudio, confirmar o download M4A/AAC e verificar que não surge na biblioteca. |
| REQ-VID-AUD-016 | O sistema deve guardar o resultado de vídeo como novo conteúdo na biblioteca do projeto. | F | Deve ter | NOVO | UC-VID-007, RN3, pós-condição | Remover ou substituir áudio e verificar a criação do conteúdo. |

#### Requisitos transversais das operações de vídeo

| ID | Requisito | Tipo | Prioridade | Novo/Alt | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-COM-001 | O sistema deve verificar que o utilizador tem acesso ao projeto antes de ler qualquer vídeo. | F | Deve ter | ALT | Pré-condições, UC-VID-002 a UC-VID-007 | Tentar aceder a projeto de outro utilizador. |
| REQ-VID-COM-002 | O sistema deve verificar que o vídeo de entrada pertence ao projeto autorizado. | F | Deve ter | ALT | Pré-condições, UC-VID-002 a UC-VID-007 | Enviar referência de vídeo de outro projeto. |
| REQ-VID-COM-003 | O sistema deve limitar os resultados de vídeo ao utilizador autorizado no projeto. | F | Deve ter | ALT | UC-VID-001 a UC-VID-007 | Tentar consultar ou transferir um resultado de outro projeto. |
| REQ-VID-COM-004 | O sistema deve reservar uma operação avançada antes de iniciar uma operação de processamento para um utilizador registado. | F | Deve ter | ALT | RN3 dos UC-VID-002 a UC-VID-007 | Verificar a quota antes do processamento. |
| REQ-VID-COM-005 | O sistema deve rejeitar uma operação de processamento quando a quota do utilizador registado estiver esgotada. | F | Deve ter | ALT | Exceções dos UC-VID-002 a UC-VID-007 | Tentar iniciar sem quota. |
| REQ-VID-COM-006 | O sistema não deve aplicar limite diário de operações de processamento a utilizadores premium. | F | Deve ter | ALT | RN3 dos UC-VID-002 a UC-VID-007 | Executar operações além do limite gratuito. |
| REQ-VID-COM-007 | O sistema deve devolver a reserva de quota quando a operação falhar. | F | Deve ter | ALT | RN7, RN4/RN5 | Provocar falha e comparar a quota. |
| REQ-VID-COM-008 | O sistema deve devolver a reserva de quota quando a operação for cancelada. | F | Deve ter | ALT | FA de cancelamento | Cancelar e comparar a quota. |
| REQ-VID-COM-009 | O sistema deve registar o identificador, tipo, origem, utilizador, projeto, estado e timestamps de cada operação de vídeo. | F | Deve ter | NOVO | Pós-condições dos UC | Inspecionar o registo em cada estado. |
| REQ-VID-COM-010 | O sistema deve registar a mensagem de erro quando uma operação falhar. | F | Deve ter | NOVO | Exceções dos UC | Provocar falha e consultar o registo. |
| REQ-VID-COM-011 | O sistema deve expor os estados `em fila`, `em processamento`, `concluída`, `falhada` e `cancelada` para operações assíncronas. | F | Deve ter | NOVO | UC-VID-002 a UC-VID-007 | Observar as transições de uma operação. |
| REQ-VID-COM-012 | O sistema deve publicar atualizações de estado no WebSocket do projeto autorizado. | F | Deve ter | ALT | Passos de progresso, UC-VID-002 a UC-VID-007 | Observar mudanças de estado no cliente autorizado. |
| REQ-VID-COM-013 | O sistema deve impedir que um cliente não autorizado receba atualizações de uma operação de vídeo. | F | Deve ter | ALT | Segurança, UC-VID-002 a UC-VID-007 | Escutar eventos com credenciais de outro projeto. |
| REQ-VID-COM-014 | O sistema deve eliminar resultados temporários quando uma operação falhar. | F | Deve ter | NOVO | Pós-condições mínimas | Provocar falha em fases diferentes. |
| REQ-VID-COM-015 | O sistema deve eliminar resultados temporários quando uma operação for cancelada. | F | Deve ter | NOVO | Fluxos de cancelamento | Cancelar durante o processamento. |
| REQ-VID-COM-016 | O sistema deve impedir que um resultado parcial seja apresentado na biblioteca. | F | Deve ter | NOVO | Pós-condições mínimas | Interromper uma operação e consultar a biblioteca. |
| REQ-VID-COM-017 | O sistema deve preservar o vídeo de origem durante qualquer operação de processamento. | F | Deve ter | ALT | Pós-condições dos UC | Comparar hash antes e depois. |
| REQ-VID-COM-018 | O sistema deve disponibilizar o resultado concluído no destino definido pelo caso de uso para o projeto autorizado. | F | Deve ter | ALT | Pós-condições dos UC; UC-VID-007/RN6 | Concluir uma operação e verificar o destino especificado. |
| REQ-VID-COM-019 | O sistema deve limitar os conteúdos de vídeo ao utilizador autorizado no projeto. | F | Deve ter | ALT | UC-VID-001 a UC-VID-007 | Tentar consultar ou transferir conteúdo de outro projeto. |
| REQ-VID-COM-020 | O sistema deve publicar atualizações de progresso no WebSocket do projeto autorizado. | F | Deve ter | ALT | Passos de progresso, UC-VID-002 a UC-VID-007 | Observar o progresso no cliente autorizado. |

### 4.1.2 Requisitos não funcionais e de qualidade

| ID | Requisito | Característica ISO/IEC 25010 | Alvo MVP | Alvo produção | Origem | Como verificar |
|---|---|---|---|---|---|---|
| REQ-VID-Q-001 | O sistema deve aceitar uma submissão válida. | Fiabilidade | 100% dos testes de aceitação | Recuperação automática após falha de infraestrutura | UC-VID-001 | Submeter uma combinação válida e verificar a aceitação. |
| REQ-VID-Q-002 | O sistema deve emitir pelo menos uma atualização de estado para cada operação assíncrona. | Usabilidade | Atualização observável no cliente | Estado persistido e recuperável após reconexão | UC-VID-002 a UC-VID-007 | Observar uma operação completa. |
| REQ-VID-Q-003 | O sistema deve emitir pelo menos uma atualização de progresso quando uma operação ultrapassar 5 segundos. | Eficiência de desempenho | Progresso observável | Atualizações no máximo a cada 5 segundos | DQ-001 | Executar operação demorada. |
| REQ-VID-Q-004 | O sistema deve manter o conteúdo original íntegro durante upload, processamento e limpeza. | Fiabilidade | Hash SHA-256 inalterado | Verificação e recuperação automáticas | UC-VID-001, COM-017 | Comparar hashes antes e depois. |
| REQ-VID-Q-005 | O sistema deve aplicar autorização aos recursos de vídeo em todas as operações. | Segurança | Nenhum teste de acesso cruzado tem sucesso | Auditoria e expiração conforme política global | COM-001 a COM-003, COM-013 | Testar utilizadores e projetos distintos em cada operação. |
| REQ-VID-Q-006 | O fluxo de vídeo deve manter o processamento de imagens existente operacional. | Compatibilidade | Testes atuais de imagens continuam a passar | Isolamento e evolução independente dos workers | DQ-002 | Executar regressão do fluxo de imagens. |
| REQ-VID-Q-007 | O sistema deve limpar objetos temporários após uma operação concluída com sucesso. | Manutenibilidade | Nenhum temporário acessível após a operação | Limpeza garantida após reinício do worker | COM-014 a COM-016 | Inspecionar o armazenamento após o sucesso. |
| REQ-VID-Q-008 | O sistema deve apresentar mensagens de erro que identifiquem a condição rejeitada sem expor detalhes internos. | Usabilidade / Segurança | Mensagem específica e segura | Mensagens localizadas e observabilidade centralizada | Exceções dos UC | Testar formatos, limites, quota e falhas. |
| REQ-VID-Q-009 | O sistema deve rejeitar uma submissão inválida sem criar uma referência inconsistente. | Fiabilidade | 100% dos testes de aceitação | Recuperação automática após falha de infraestrutura | UC-VID-001 | Submeter combinações inválidas e verificar a ausência de referência. |
| REQ-VID-Q-010 | O sistema deve proteger os vídeos contra acesso cruzado entre projetos. | Segurança | Nenhum teste de acesso cruzado tem sucesso | Auditoria e expiração conforme política global | COM-001 a COM-003 | Tentar aceder a vídeo de outro projeto. |
| REQ-VID-Q-011 | O sistema deve proteger os metadados contra acesso cruzado entre projetos. | Segurança | Nenhum teste de acesso cruzado tem sucesso | Auditoria e expiração conforme política global | COM-001 a COM-003 | Tentar aceder aos metadados de outro projeto. |
| REQ-VID-Q-012 | O sistema deve proteger os eventos contra acesso cruzado entre projetos. | Segurança | Nenhum teste de acesso cruzado tem sucesso | Auditoria e expiração conforme política global | COM-013 | Tentar receber eventos de outro projeto. |
| REQ-VID-Q-013 | O sistema deve limpar objetos temporários após uma operação falhada. | Manutenibilidade | Nenhum temporário acessível após a operação | Limpeza garantida após reinício do worker | COM-014 | Inspecionar o armazenamento após uma falha. |
| REQ-VID-Q-014 | O sistema deve limpar objetos temporários após uma operação cancelada. | Manutenibilidade | Nenhum temporário acessível após a operação | Limpeza garantida após reinício do worker | COM-015 | Inspecionar o armazenamento após um cancelamento. |
| REQ-VID-Q-015 | O sistema deve impedir o acesso a objetos temporários após a operação. | Manutenibilidade | Nenhum temporário acessível após a operação | Limpeza garantida após reinício do worker | COM-016 | Tentar aceder a um temporário após a operação. |
| REQ-VID-Q-016 | O sistema deve emitir atualizações de progresso para operações assíncronas demoradas. | Eficiência de desempenho | Progresso observável | Atualizações no máximo a cada 5 segundos | DQ-001 | Observar uma operação demorada. |

### 4.1.3 Requisitos de manutenção da biblioteca

Estes requisitos não alteram os sete casos de uso de vídeo nem são apresentados como
novos `UC-VID`. Registam melhorias de manutenção e usabilidade identificadas durante a
integração do MVP, mantendo a separação entre a extensão de vídeo e a gestão geral dos
recursos do projeto.

| ID | Requisito | Classificação | Critério de aceitação | Origem | Verificação |
|---|---|---|---|---|---|
| REQ-VID-MNT-001 | O sistema deve permitir a um utilizador autorizado apagar um vídeo do projeto e o respetivo objeto armazenado. | Funcional / Manutenibilidade | Dado um utilizador autorizado e um vídeo do projeto, Quando confirma a eliminação, Então o vídeo deixa de aparecer no projeto e o objeto deixa de estar acessível. | Manutenção corretiva T-VID-MNT-001 | Teste manual de eliminação e consulta posterior do projeto. |
| REQ-VID-MNT-002 | O sistema deve permitir selecionar várias imagens do projeto e apagá-las numa única ação confirmada. | Funcional / Usabilidade | Dado um utilizador autorizado com pelo menos duas imagens selecionadas, Quando confirma a eliminação, Então todas as imagens selecionadas deixam de aparecer no projeto. | Manutenção corretiva T-VID-MNT-002 | Teste manual de seleção múltipla, confirmação e atualização da grelha. |
| REQ-VID-MNT-003 | O sistema deve permitir criar um projeto sem imagem inicial para posterior adição de vídeos ou imagens. | Funcional / Usabilidade | Dado um utilizador autenticado, Quando cria um projeto apenas com nome, Então o projeto é criado e permite adicionar um vídeo ou imagem. | Manutenção corretiva T-VID-MNT-003 | Criar projeto vazio e adicionar vídeo. |

### 4.1.4 Verificação da completude e dos limites do âmbito

| Tópico | Aplicável? | Decisão / justificação | Requisitos relacionados |
|---|---|---|---|
| Formato, codec, duração e dimensão do vídeo | Sim | Necessário para submissão e para validar todas as operações. | SUB-005 a SUB-014, CONV-002 a CONV-007 |
| Estado, progresso, cancelamento e resultado | Sim | Todas as operações de processamento são assíncronas no MVP. | TRIM-009 a TRIM-012, CONV-009 a CONV-011, COM-009 a COM-020, Q-002, Q-003, Q-016 |
| Falhas durante o processamento | Sim | Falhas de codec, armazenamento, ferramenta e FFmpeg devem deixar o sistema consistente. | SUB-008-SUB-009, FRM-012, COM-010, COM-014 a COM-016, Q-001 |
| Persistência e expiração dos ficheiros | Sim | Resultados devem ser persistidos; temporários devem ser removidos. | SUB-015, FEX-009 a FEX-011, COM-014 a COM-018, Q-007 |
| Perfis e contagem de operações | Sim | O baseline diferencia anónimo, registado e premium e limita operações avançadas. | SUB-001, SUB-016 a SUB-023, COM-004 a COM-008 |
| Encadeamento de ferramentas e processamento em lote | Parcial | O encadeamento de ferramentas de imagem e a conversão em lote são suportados apenas quando explicitamente previstos nos UC-VID-003 e UC-VID-004; transições e edição avançada ficam fora do MVP. | FRM-011, CONV-009, MERGE-001 a MERGE-015 |
| Gestão e manutenção de recursos | Sim | A biblioteca deve permitir remover recursos e gerir vários itens sem repetir a operação individualmente. | REQ-VID-MNT-001 a REQ-VID-MNT-003 |

## 4.2 Impacto no sistema existente

| Elemento existente afetado | Impacto | Descrição do impacto | Requisitos relacionados |
|---|---|---|---|
| JWT, autenticação e perfis | Alterar | Reutilizar autenticação e autorização existentes, acrescentando a regra de vídeo para anónimos e os limites por perfil. | SUB-001, SUB-016 a SUB-023, COM-001 a COM-006 |
| Quota de ferramentas avançadas | Alterar | Reutilizar a política de operações avançadas, reservando uma unidade por operação de processamento de vídeo aceite. | COM-004 a COM-008 |
| Projects Service e modelos de projeto | Estender | Adicionar referências de vídeo, metadados, operações, estados, resultados e associação ao projeto sem quebrar imagens. | SUB-010 a SUB-015, COM-009, COM-018 |
| API Gateway | Estender | Expor submissão, consulta, cancelamento, resultados e validação de autorização para vídeo. | SUB-001, TRIM-001, COM-001 a COM-003 |
| Image Storage Service / SeaweedFS | Estender | Reutilizar a fachada S3, acrescentando content-types, convenção de objetos de vídeo, objetos temporários e limpeza. | SUB-015, COM-014 a COM-017, Q-007 |
| RabbitMQ | Estender | Acrescentar operações e filas de vídeo sem alterar as filas das ferramentas de imagem. | TRIM-010, FRM-008, CONV-009, FEX-009, MERGE-009, AUD-001 |
| WebSocket Gateway | Estender | Encaminhar estados e progresso de vídeo apenas para clientes autorizados do projeto. | COM-011 a COM-013, Q-002, Q-003 |
| Workers de ferramentas de imagem | Manter / Estender | Manter o contrato atual para imagens e permitir que UC-VID-003 entregue fotogramas isolados às ferramentas compatíveis. | FRM-001, FRM-008, Q-006 |
| FFmpeg/FFprobe | Novo | Introduzir análise de metadados, validação de streams, recorte, extração, recomposição, conversão e áudio. | SUB-005 a SUB-014, SUB-024 a SUB-025, TRIM-005, FRM-007 a FRM-010, CONV-002 a CONV-011, FEX-001 a FEX-009, MERGE-005 a MERGE-013, AUD-001 a AUD-016 |
| Frontend da biblioteca | Estender | Apresentar vídeos, metadados, parâmetros, estados, progresso, cancelamento, resultados, mensagens de erro e ações de gestão da biblioteca. | SUB-001 a SUB-004, TRIM-001 a TRIM-013, CONV-001 a CONV-011, FEX-001 a FEX-011, MERGE-001 a MERGE-015, AUD-001 a AUD-016, MNT-001 a MNT-003 |

## 4.3 Matriz de rastreabilidade consolidada

| Elemento de origem | Descrição abreviada | Requisito(s) relacionado(s) |
|---|---|---|
| UC-VID-001, passos 1-3 | Selecionar ficheiro e autorizar perfil | SUB-001 |
| UC-VID-001, passos 2, 6-8 | Validar contentor, streams, metadados e limites | SUB-005 a SUB-014, SUB-016 a SUB-023 |
| UC-VID-001, passos 4-6 | Transferir e confirmar integridade | SUB-010, Q-001, Q-004 |
| UC-VID-001, passos 9-11 | Persistir e associar ao projeto | SUB-015, SUB-026 a SUB-029, COM-018 |
| UC-VID-001, FA1-FA4 e exceções | Duplicação, lote, cancelamento e rejeição | SUB-008, SUB-009, SUB-024, SUB-025, Q-001, Q-007, Q-008 |
| UC-VID-002, passos 1-4 | Selecionar vídeo e validar intervalo | TRIM-001 a TRIM-008 |
| UC-VID-002, passos 5-11 | Criar, executar, acompanhar e guardar recorte | TRIM-009 a TRIM-011, COM-009 a COM-018 |
| UC-VID-002, FA1-FA2 | Cancelar em fila ou processamento | TRIM-012, COM-008, COM-015 |
| UC-VID-003, passos 3-8 | Selecionar ferramenta e configurar processamento | FRM-001 a FRM-006 |
| UC-VID-003, passos 9-12 | Extrair, processar, recompor e disponibilizar | FRM-007 a FRM-010, COM-018 |
| UC-VID-003, FA1-FA3 e exceções | Encadear, repetir e cancelar | FRM-011, FRM-012, COM-014 a COM-017 |
| UC-VID-004, passos 1-5 | Consultar origem, escolher e validar saída | CONV-001 a CONV-008 |
| UC-VID-004, passos 6-10 | Converter, acompanhar e guardar resultado | CONV-009, CONV-010, COM-009 a COM-018 |
| UC-VID-005, passos 1-7 | Configurar, estimar e validar extração | FEX-001 a FEX-008 |
| UC-VID-005, passos 8-12 | Extrair e guardar imagens | FEX-009, COM-009, COM-018 |
| UC-VID-005, FA1-FA3 e exceções | Intervalo, cancelamento, novo projeto e limpeza | FEX-010, FEX-011, COM-014 a COM-016 |
| UC-VID-006, passos 1-4 | Selecionar, ordenar e validar vídeos | MERGE-001 a MERGE-008 |
| UC-VID-006, passos 5-10 | Concatenar, preservar áudio e guardar resultado | MERGE-009 a MERGE-012, COM-009, COM-018 |
| UC-VID-006, FA1-FA2 e exceções | Normalização, cancelamento e falhas | MERGE-009, COM-007, COM-008, COM-014 a COM-017 |
| UC-VID-007, passos 1-2 | Escolher operação e validar entrada | AUD-001 a AUD-010 |
| UC-VID-007, passos 3-9 | Processar, persistir e notificar | AUD-011, AUD-012, COM-009 a COM-018 |
| UC-VID-007, FA1-FA3 e exceções | Sem áudio, durações diferentes, cancelamento e falha | AUD-007 a AUD-010, COM-007, COM-008, COM-014 a COM-017 |
| UC-VID-001 a UC-VID-007, autorização | Acesso a projeto e conteúdo | COM-001 a COM-003, Q-005 |
| UC-VID-001 a UC-VID-007, quota | Reserva, consumo e devolução | SUB-015, COM-004 a COM-008 |
| UC-VID-001 a UC-VID-007, estados | Registo, eventos, limpeza e resultados | COM-009 a COM-018, Q-002, Q-003, Q-007 |
| Manutenção corretiva T-VID-MNT-001 | Apagar vídeo autorizado | MNT-001 |
| Manutenção corretiva T-VID-MNT-002 | Selecionar e apagar várias imagens | MNT-002 |
| Manutenção corretiva T-VID-MNT-003 | Criar projeto sem imagem inicial | MNT-003 |
| DQ-001 | Progresso observável em operações demoradas | Q-002, Q-003, Q-016 |
| DQ-002 | Isolamento do fluxo existente de imagens | Q-006 |

### Decisões de qualidade introduzidas nesta revisão

| ID | Decisão de qualidade | Justificação | Requisito(s) relacionado(s) |
|---|---|---|---|
| DQ-001 | As operações de vídeo demoradas devem ser assíncronas e publicar estado e progresso através do WebSocket autorizado do projeto. | Uploads e processamento de vídeo podem demorar mais do que um pedido HTTP normal. O utilizador deve conseguir acompanhar a operação sem bloquear o pedido nem consultar repetidamente a API. | REQ-VID-COM-011, REQ-VID-COM-012, REQ-VID-COM-013, REQ-VID-Q-002, REQ-VID-Q-003 |
| DQ-002 | O processamento de vídeo deve ser isolado do contrato e das filas atuais de processamento de imagens. | O PictuRAS existente processa imagens através de ferramentas independentes e RabbitMQ. A extensão não deve introduzir regressões nem obrigar as ferramentas atuais a compreender vídeos. | REQ-VID-FRM-001, REQ-VID-FRM-008, REQ-VID-Q-006 |
| DQ-003 | Os conteúdos originais devem ser imutáveis; os resultados persistentes devem ser guardados como novo conteúdo. | Esta decisão reduz o risco de perda de dados e permite voltar a usar o vídeo original noutras operações. O áudio extraído por UC-VID-007 é uma exceção: é transferido ao utilizador sem persistência na biblioteca. | REQ-VID-TRIM-011, REQ-VID-CONV-010, REQ-VID-MERGE-012, REQ-VID-AUD-012, REQ-VID-AUD-015, REQ-VID-COM-017, REQ-VID-Q-004 |
| DQ-004 | Operações falhadas ou canceladas devem limpar temporários antes de serem apresentadas como terminadas. | Ficheiros parciais não podem aparecer na biblioteca nem ocupar armazenamento indefinidamente. A limpeza é uma condição de consistência do MVP. | REQ-VID-COM-014, REQ-VID-COM-015, REQ-VID-COM-016, REQ-VID-Q-007 |
| DQ-005 | A autorização deve ser aplicada ao projeto, ao conteúdo, ao resultado e aos eventos de progresso. | Não basta proteger o endpoint inicial: uma referência de vídeo, um resultado ou um evento WebSocket não podem ser usados para obter dados de outro projeto. | REQ-VID-COM-001, REQ-VID-COM-002, REQ-VID-COM-003, REQ-VID-COM-013, REQ-VID-Q-005 |

### Convenção dos identificadores de requisitos

Os identificadores seguem o formato `REQ-VID-<categoria>-<número>`:

- `REQ` significa **requisito**;
- `VID` identifica o âmbito de **vídeo**;
- `SUB`, `TRIM`, `FRM`, `CONV`, `FEX`, `MERGE` e `AUD` identificam,
  respetivamente, submissão, recorte, ferramentas sobre fotogramas, conversão,
  extração de fotogramas, concatenação e áudio;
- `COM` identifica requisitos **comuns/transversais** a várias operações;
- `Q` significa **qualidade**. Por exemplo, `REQ-VID-Q-003` é o terceiro
  requisito não funcional/de qualidade de vídeo, não uma questão em aberto;
- o número final é sequencial dentro da categoria.


## Decisões e limites mantidos em aberto

As seguintes capacidades permanecem fora do MVP: retoma de operações interrompidas,
substituição ou versionamento do original, transições no merge, múltiplas faixas de
áudio, limite funcional adicional de uploads simultâneos, pré-visualização avançada,
filtros de alteração visual e criação automática de miniaturas. A submissão duplicada
no MVP está fechada pelas opções de manter ambos ou cancelar; a substituição fica
explicitamente excluída.

## Verificações de cobertura

- Cada requisito funcional é atómico, tem origem e tem verificação própria.
- Cada caso de uso tem requisitos específicos para fluxo principal, alternativas,
  exceções, pós-condições e regras de negócio.
- Validações, limites, autorização, quota, estados, progresso, cancelamento,
  limpeza, persistência e preservação do original estão separados.
- O impacto identifica o que é mantido, estendido, alterado ou criado no baseline.
- Os requisitos de qualidade distinguem objetivos de MVP de alvos de produção.
- Os valores de limites, as unidades decimais, o estágio `video-src` e o
  comportamento de lotes e duplicados estão fechados para a implementação do MVP.
