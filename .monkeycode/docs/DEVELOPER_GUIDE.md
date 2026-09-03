# 开发指南

## 环境要求

- Git
- Python 3（脚本解析 YAML 风格清单）
- 各业务项目自己的运行时（Node.js 等），按项目 README 安装

## 快速开始

```bash
git clone https://github.com/wsxiaolin/monkeycode-workspace
cd monkeycode-workspace
./scripts/bootstrap-projects.sh
./scripts/install-projects.sh
```

两个已登记项目会出现在：

- `projects/plweb-skill`
- `projects/pl-town`

确认忽略：

```bash
git check-ignore -v projects/plweb-skill projects/pl-town
git status
```

`git status` 中不应出现这两个目录的源码。

## 项目结构说明

完整约定见仓库根目录 `WORKSPACE.md`。

## 开发规范

- 工作台提交只包含文档、脚本、记忆、待办、清单
- 业务改动在 `projects/<name>/` 内使用该仓库的远程
- 新增外部项目必须登记到 manifest，并保持 gitignore
- 回复与记忆使用简体中文
