# monkeycode-workspace 文档

## 项目概述

monkeycode-workspace 是 Agent 多项目工作台，用来统一存放记忆、待办和规范。业务项目源码由各自独立仓库维护，本地检出到 `projects/` 并 gitignore。

**目标用户**: 在同一工作区维护多个独立项目的 Agent 与开发者

**核心价值**:
- 记忆和待办跨项目可复用
- 业务仓库保持独立，不被工作台污染
- 用清单和脚本统一克隆、更新本地检出

## 技术选型

| 类别 | 选择 | 理由 |
|------|------|------|
| 版本控制 | Git + 独立远程 | 每个业务项目自己提交 |
| 本地编排 | `projects/manifest.yaml` + shell 脚本 | 轻量，不引入 monorepo 工具 |
| Agent 记忆 | `.monkeycode/MEMORY.md` | 平台约定的记忆位置 |

## 核心功能

### 项目清单
- **目的**: 登记需要在本机检出的外部仓库
- **描述**: `projects/manifest.yaml` 记录 name/url/ignore，脚本按清单克隆

### 忽略规则
- **目的**: 保证业务源码不进入工作台提交
- **描述**: `/projects/*` 忽略检出，仅跟踪 README 与 manifest

### 记忆与待办
- **目的**: 跨项目沉淀行为偏好和任务
- **描述**: 记忆写 MEMORY.md，待办写 `.monkeycode/todos/`

## 文档导航

- [架构设计](./ARCHITECTURE.md) - 工作台边界和目录
- [接口定义](./INTERFACES.md) - 清单字段与脚本入口
- [开发指南](./DEVELOPER_GUIDE.md) - 日常操作
- 仓库根目录 `WORKSPACE.md` - 完整规范
