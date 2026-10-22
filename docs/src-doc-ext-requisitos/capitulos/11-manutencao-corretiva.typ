#import "../template.typ": *

= Manutenção Corretiva da Solução de Base

#orientacao[
  Problemas encontrados na solução de base durante o estudo e a integração do vídeo (erros, incoerências com o
  documento de requisitos, dificuldades de execução). Indiquem se foram corrigidos nesta fase. Capítulo
  recomendado; removam-no se não houver nada a registar.
]

*TODO*: REVER E COMPLETAR ESTE CAPÍTULO

#tab([Tarefas de manutenção corretiva],
  tabela(
    colunas: (1.2cm, 1fr, 2.4cm, 1.6cm, 2cm, 1.8cm),
    tamanho: 8.5pt,
    [ID], [Descrição do problema], [Impacto], [Prioridade], [Rel. Req.], [Estado],
    [T-12], [A remoção de ferramentas podia falhar perante um conflito de versão causado por alterações concorrentes; após `409`, atualizar o projeto, confirmar que a ferramenta permanece e repetir a operação uma vez.], [Funcional / consistência], [Alta], [requisito de imagem relacionado com gestão de ferramentas, a validar contra a baseline], [Corrigido; cenário Docker passou.],
    [T-13], [O Nginx mantinha endereços IP antigos de serviços Docker depois de um rebuild e devolvia `502 connection refused`.], [Disponibilidade / execução], [Alta], [Requisito operacional; sem ID RF atribuído], [Corrigido; `nginx -t` e recriação de Gateway/WebSocket passaram sem reiniciar Nginx.],
    [T-14], [O preview disparado após remover ferramenta podia usar a versão anterior devolvida pelo render.], [Funcional / consistência], [Média], [ requisito de imagem relacionado com gestão de ferramentas, a validar contra a baseline], [Corrigido; usa a versão devolvida pela API.],
  ),
)
