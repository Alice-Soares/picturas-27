# Especificações

Esta pasta contém as especificações funcionais geridas pelo GitHub Spec Kit.
Cada funcionalidade deve ter a sua própria pasta, normalmente criada por
`/speckit-specify`, por exemplo:

```text
specs/
└── 001-video-upload/
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

## Como usar

1. Abrir o projeto `picturas-27` no VS Code com o GitHub Copilot ativo.
2. Confirmar o requisito na documentação de [`docs/`](../docs/) e consultar
   [`AGENTS.md`](../AGENTS.md).
3. Criar a especificação com `/speckit-specify` e uma descrição objetiva da
   funcionalidade. Relacionar os IDs `REQ-VID-*` e `UC-VID-*` aplicáveis.
4. Executar `/speckit-clarify` se houver decisões relevantes em aberto.
5. Rever a especificação e executar `/speckit-plan`.
6. Executar `/speckit-tasks` e rever a rastreabilidade das tarefas.
7. Opcionalmente executar `/speckit-analyze` e `/speckit-checklist`.
8. Só depois executar `/speckit-implement`, validando o código e os testes.

O Spec Kit também instala os templates e a constituição em
[`.specify/`](../.specify/). Não colocar segredos nessa árvore.

## Instalação e verificação

O CLI oficial foi instalado com `uv` a partir do pacote `specify-cli`. Se o
comando `specify` não estiver no `PATH`, usar:

```bash
uv tool run --from specify-cli specify check
```

Para instalar ou atualizar a ferramenta no perfil local:

```bash
uv tool install --force --from git+https://github.com/github/spec-kit.git specify-cli
```

Para verificar a versão e as ferramentas disponíveis:

```bash
uv tool run --from specify-cli specify version
uv tool run --from specify-cli specify check
```

O inicializador usado neste projeto foi:

```bash
uv tool run --from specify-cli specify init --here --integration copilot
```

