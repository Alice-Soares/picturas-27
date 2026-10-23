#import "../template.typ": *

= Manutenção Corretiva da Solução de Base

#orientacao[
  Problemas encontrados na solução de base durante o estudo e a integração do vídeo (erros, incoerências com o
  documento de requisitos, dificuldades de execução). Indiquem se foram corrigidos nesta fase. Capítulo
  recomendado; removam-no se não houver nada a registar.
]

A integração da extensão de vídeo com a solução de base expôs problemas que não diziam respeito à funcionalidade
de vídeo em si, mas a defeitos preexistentes do PictuRAS ou a condições de execução do ambiente em
Docker. Apenas se registam aqui os problemas que foram efetivamente observados pela equipa e que
condicionaram a execução ou a validação do MVP; a lista não é exaustiva.

Os três problemas registados tinham naturezas distintas. O primeiro resultava de alterações
concorrentes ao esquema do projeto na remoção de ferramentas de imagem. O segundo era um problema de
infraestrutura: o Nginx conservava endereços IP de contentores Docker já destruídos, continua a devolver
`502` depois de um _rebuild_. O terceiro era uma incoerência funcional em que o preview disparado após a
remoção de uma ferramenta podia apresentar a versão anterior devolvida pelo _render_.

Os dois primeiros foram corrigidos durante esta fase e validados no ambiente Docker. O terceiro foi
corrigido com uma alteração de código de aplicação. Nenhum destes problemas alterou requisitos do
documento de enunciado: são correções de defeitos da baseline, e por isso estão registados aqui e não na
ERS. Onde não foi possível atribuir um identificador de requisito da baseline, o campo correspondente
indica-o de forma explícita, em vez de se recorrer a um identificador inventado.

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
