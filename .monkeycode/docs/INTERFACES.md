# 接口定义

工作台没有 HTTP API。对外契约是清单文件和脚本。

## manifest.yaml

路径：`projects/manifest.yaml`

```yaml
projects:
  - name: string          # 本地目录名
    url: string           # git clone URL
    ignore: true          # 必须为 true
    notes: string         # 可选说明
```

`name` 对应 `projects/<name>/`。脚本只读取 `name` 与 `url`。

## 脚本

### bootstrap-projects.sh

- 入口：仓库根目录 `./scripts/bootstrap-projects.sh`
- 行为：对清单中每个项目，若不存在 `projects/<name>/.git` 则 `git clone`
- 已存在则跳过

### update-projects.sh

- 入口：仓库根目录 `./scripts/update-projects.sh`
- 行为：对已克隆项目执行 `git pull --ff-only`
- 未克隆则跳过

### install-projects.sh

- 入口：仓库根目录 `./scripts/install-projects.sh`
- 行为：在各项目目录内执行该项目自己的安装命令（如 `npm install`）
- 未克隆或没有已知安装文件则跳过

## Agent 文件约定

| 路径 | 用途 |
|------|------|
| `.monkeycode/MEMORY.md` | 行为与运维记忆 |
| `.monkeycode/todos/` | 跨项目待办 |
| `.monkeycode/specs/` | 跨项目规格 |
| `.monkeycode/docs/` | 工作台文档 |
