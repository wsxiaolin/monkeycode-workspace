# monkeycode-workspace

Agent 多项目工作台。本仓库只托管记忆、待办、规范和共享工具，不托管业务项目源码。

业务项目各自有独立 Git 仓库。本工作台把它们克隆到 `projects/`，该目录已被忽略，不会被提交。

## 本仓库负责什么

- Agent 记忆（`.monkeycode/MEMORY.md`）
- 跨项目待办与规格（`.monkeycode/todos/`、`.monkeycode/specs/`）
- 工作台规范与项目登记（`.monkeycode/docs/`、`projects/manifest.yaml`）
- 统一拉取/更新项目的脚本（`scripts/`）

## 本仓库不负责什么

- 业务项目的源码、提交、发布
- 把外部项目做成 submodule 或 subtree

## 快速开始

```bash
# 按清单克隆全部已登记项目
./scripts/bootstrap-projects.sh

# 在各项目目录内安装依赖
./scripts/install-projects.sh

# 更新已克隆项目
./scripts/update-projects.sh
```

依赖安装发生在 `projects/<name>/` 内，不会提升到工作台根目录。

## 文档

- 当前工作区 `/WORKSPACE.md`：目录约定、忽略规则、协作流程
- 当前工作区 `/.monkeycode/docs/INDEX.md`：文档索引
- 当前工作区 `/projects/README.md`：如何登记与克隆项目
