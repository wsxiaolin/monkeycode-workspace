# 工作台规范

本仓库是 Agent 多项目工作台。项目源码由各自仓库维护；本仓库只存记忆、待办、规范和共享脚本。

## 1. 职责边界

| 内容 | 归属 |
|------|------|
| 业务源码、依赖锁文件、项目级 CI | 各项目自己的仓库 |
| Agent 记忆、跨项目待办、规格、工作台规范 | 本仓库 |
| 本地检出的项目目录 | 本机 `projects/`，Git 忽略 |

禁止把业务项目以 submodule、subtree 或直接拷贝的方式提交进本仓库。

## 2. 目录约定

```text
/
├── .monkeycode/
│   ├── MEMORY.md              Agent 行为与运维记忆
│   ├── docs/                  工作台文档
│   ├── todos/                 跨项目待办
│   └── specs/                 跨项目规格
├── projects/
│   ├── README.md              如何登记项目
│   ├── manifest.yaml          项目清单（可提交）
│   └── <name>/                实际检出，已被 gitignore
├── scripts/
│   ├── bootstrap-projects.sh  按清单克隆
│   └── update-projects.sh     按清单拉取更新
├── WORKSPACE.md               本规范
└── README.md
```

`projects/<name>/` 必须与 `manifest.yaml` 中的 `name` 一致，且必须出现在根目录 `.gitignore` 的 `/projects/*` 规则下。

## 3. Git 忽略

根目录 `.gitignore` 忽略整个 `projects/` 下的检出，但保留：

- `projects/.gitkeep`
- `projects/README.md`

`projects/manifest.yaml` 需要被 Git 跟踪，因此它放在 `projects/` 下时必须在 `.gitignore` 中显式放行。

新增外部项目时：

1. 写入 `projects/manifest.yaml`
2. 确认目录名会被 `/projects/*` 忽略
3. 用 `scripts/bootstrap-projects.sh` 克隆
4. 用 `git check-ignore -v projects/<name>` 确认已被忽略

当前已忽略的检出：

- `projects/plweb-skill`（https://github.com/NetLogo-Mobile/plweb-skill）
- `projects/pl-town`（https://github.com/wsxiaolin/pl-town）

## 4. 项目登记

`projects/manifest.yaml` 是唯一清单。每条记录至少包含：

```yaml
- name: pl-town
  url: https://github.com/wsxiaolin/pl-town
  ignore: true
  notes: Three.js isometric city
```

- `name`：本地目录名，只能用小写字母、数字和连字符
- `url`：独立 Git 远程
- `ignore`：必须为 `true`。工作台不跟踪该项目源码
- `notes`：给 Agent 的一句话说明

登记新项目后执行 `./scripts/bootstrap-projects.sh`。不要手写 `git clone` 到仓库根目录或其他路径。

## 5. 依赖安装

工作台本身没有业务运行时依赖。依赖在各项目目录内按该项目自己的包管理器安装。

统一约定：

1. 先读该项目的 `README` / `package.json` / `pyproject.toml`
2. 运行 `./scripts/install-projects.sh`，或在 `projects/<name>/` 内手动安装
3. 不要把依赖提升到工作台根目录
4. 锁文件、`node_modules`、虚拟环境都留在项目目录，它们本来就被工作台 gitignore

需要在多个项目间共享的只是脚本和工作台文档，不是 `node_modules`。

## 6. Agent 协作

1. 开始任务前读 `.monkeycode/MEMORY.md`
2. 改业务代码时进入 `projects/<name>/`，使用该项目自己的 Git
3. 跨项目决策、行为偏好、排障流程写入 `.monkeycode/MEMORY.md`
4. 跨项目待办写入 `.monkeycode/todos/`
5. 工作台规范变更走本仓库 PR，不要直接改业务仓库的远程历史

向某个业务项目提交代码时，在该项目目录内创建分支、提交、开 PR。不要把业务 diff 混进工作台提交。

## 7. 本仓库的 Git 流程

- 默认分支：`master`
- 功能分支：`YYMMDD-(feat|fix|chore|refactor)-简述`
- 提交信息使用约定式前缀：`feat:` / `fix:` / `chore:` / `docs:`
- 只提交工作台文件。提交前执行 `git status`，确认 `projects/plweb-skill` 和 `projects/pl-town` 未出现在暂存区

## 8. 新增项目检查清单

1. 项目有独立远程仓库
2. 已追加到 `projects/manifest.yaml`
3. 本地目录为 `projects/<name>/`
4. `git check-ignore -v projects/<name>` 显示被忽略
5. `git status` 看不到该目录下的源码
6. 如有跨项目注意事项，写入 `.monkeycode/MEMORY.md`
