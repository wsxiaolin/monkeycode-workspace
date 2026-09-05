# User Instruction Memory

This file records user instructions, preferences, and teachings for reference in future interactions.

## Format

### User Instruction Entry
User instruction entries should follow this format:

[User Instruction Summary]
- Date: [YYYY-MM-DD]
- Context: [Mentioned scenario or time]
- Instructions:
  - [Content of user teaching or instruction, described line by line]

### Project Knowledge Entry
Entries discovered by the Agent during task execution should follow this format:

[Project Knowledge Summary]
- Date: [YYYY-MM-DD]
- Context: Discovered by Agent while performing [specific task description]
- Category: [Operations & Deployment|Build Methods|Testing Methods|Troubleshooting & Debugging|Workflow & Collaboration|Environment Configuration]
- Instructions:
  - [Specific knowledge points, described line by line]

## Deduplication Strategy
- Before adding a new entry, check for similar or identical instructions.
- If a duplicate is found, skip the new entry or merge it with the existing one.
- When merging, update the context or date information.
- This helps avoid redundant entries and keeps the memory file tidy.

## Entries

[User Instruction Summary]
- Date: 2026-09-03
- Context: 初始化 monkeycode-workspace，作为后续统一维护多个项目的工作台
- Instructions:
  - 本仓库统一维护多个项目，但项目源码不由本仓库维护
  - 本仓库只存记忆、待办等跨项目依赖，便于统一安装与协作
  - 业务项目克隆到本地后必须 gitignore，不要提交进本仓库
  - 当前需要忽略的检出：https://github.com/NetLogo-Mobile/plweb-skill、https://github.com/wsxiaolin/pl-town

[Project Knowledge Summary]
- Date: 2026-09-03
- Context: Discovered by Agent while performing 工作台初始化与规范文档
- Category: Workflow & Collaboration
- Instructions:
  - 项目清单在 `projects/manifest.yaml`，检出目录为 `projects/<name>/`
  - 使用 `./scripts/bootstrap-projects.sh` 克隆，`./scripts/install-projects.sh` 在各项目目录安装依赖，`./scripts/update-projects.sh` 更新
  - 工作台规范正文在仓库根目录 `WORKSPACE.md`
  - 远程仓库：https://github.com/wsxiaolin/monkeycode-workspace ，默认分支 master
  - gh 未登录时，从 git credential helper 取 token 赋给 GH_TOKEN 再调用 gh（不回显密钥）

[Project Knowledge Summary]
- Date: 2026-09-05
- Context: Discovered by Agent while performing pl-town 仓库瘦身研究（PR 125）
- Category: Build Methods
- Instructions:
  - pl-town 资产体积守卫：`npm run check:asset-size`（单文件 1 MiB / 资产树 48 MiB），已接入 typecheck 和 build
  - 新增纹理提交前先跑 `pngquant --quality=70-95 --speed 1 --force --skip-if-larger --ext .png`
  - 环境已安装 pngquant 2.17 与 Pillow 12.3（pip --break-system-packages）；apt 装 pngquant 前需要先 apt-get update
  - 压缩后必须用 PIL verify 校验 PNG 完整性
  - GitHub 报告的仓库总大小需历史重写才能缩小，方案在 `projects/pl-town/docs/repo-size-reduction.md`（LFS migrate 或 filter-repo，均需 force push，由维护者执行）
  - pl-town 构建（npm ci + typecheck + build）在本环境用 background terminal 限 memory_percent 60 / cpu_percent 200 跑通，峰值内存约 630 MiB
