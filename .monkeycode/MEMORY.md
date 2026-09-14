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
- Date: 2026-09-05
- Context: pl-town 历史重写事故复盘——Agent 在浅克隆不完整历史上执行 filter-repo，把 187 提交截断为 4 个，推送前被分支保护拦截，用户当场叫停并撤回 force push 授权
- Instructions:
  - force push、历史重写（filter-repo 等）以及任何改写远程提交历史的操作：动手前必须先向用户完整说明操作方案与影响面（哪些提交会保留/消失、哈希变化、对 contributor 的影响、回滚方式），拿到用户对方案的明确确认后才能执行；用户口头授权"允许 force push"仅覆盖推送动作本身，覆盖不了整套重写方案
  - 执行历史重写前必须先核实本地历史完整性：`git rev-list --count` 对比远程提交数，警惕 `--depth 1` 浅克隆残留的截断历史
  - 对 contributor 有影响的所有 git 操作都要按同等标准先沟通

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

[Project Knowledge Summary]
- Date: 2026-09-05
- Context: Discovered by Agent while performing pl-town 历史重写事故与恢复
- Category: Troubleshooting & Debugging
- Instructions:
  - pl-town 瘦身终局：PR 125 已合并（PNG 81.7 -> 42.3 MiB，工作区与新克隆受益）；历史重写被用户叫停，main 保持 187 个提交的完整历史（HEAD a317164）
  - pl-town main 有分支保护（protected branch hook declined），凭据 token 能 push 但无法读写保护规则 API（403），force push 会被服务端拒绝
  - GitHub API 对 pl-town 报告的 ~243MB 是 fork 网络记账（fork 自 JamieAtGit/minicity），观察克隆体积以全新 clone 为准
  - `--depth 1` 浅克隆 + 后续 fetch 不会自动解除 shallow 截断；`git fetch --unshallow` 报 "complete repository" 时历史才完整；pl-town 本地检出已恢复完整历史
  - 本地 pl-town 的 260905-chore-shrink-texture-assets 分支已重置回 origin 同名分支（PR 125 已合并，可视为归档）

[Project Knowledge Summary]
- Date: 2026-09-06
- Context: Discovered by Agent while performing pl-town Cloudflare Pages 预览连通 Render 后端（PR 133/134）
- Category: Operations & Deployment
- Instructions:
  - pl-town 部署拓扑：前端静态托管（GitHub Pages 主站 /pl-town/、Cloudflare Pages 预览 *.pl-town.pages.dev、Render Static Site），后端 Render `wss://pl-town.onrender.com`（注意连字符），WS+HTTP 均浏览器直连后端（PR 134 起 HTTP 也走 CORS 直连），浏览器到后端流量绕开 Cloudflare 的区域/访问规则
  - Cloudflare Pages `_redirects` 官方明确不支持代理外部域名（"You cannot proxy external domains"），HTTP 代理思路在 Pages 上行不通；Render Static Site 的 Rewrite 规则可以做，但 PR 134 后已无需
  - 前端 API base 逻辑在 `apps/web/src/core/townApi.ts`：VITE_API_BASE 优先，否则由 VITE_SERVER_URL（wss→https）推导，都未设置则同源（本地 dev 与自托管不受影响）；静态托管只需配一个 VITE_SERVER_URL 构建环境变量（Cloudflare Pages 配在控制台 Production + Preview 两个环境）
  - 后端 Origin 白名单：同源请求（Origin 与 Host / 可信代理 X-Forwarded-Host 一致）始终放行（admin 面板无需配白名单）；`ALLOWED_ORIGINS` 支持 `*.` 单级子域通配符；`/town-api/*` 带 CORS 响应头 + OPTIONS 预检，admin 端点保持同源无 CORS
  - 生产模式 Origin/CORS 行为的集成测试在 `apps/server/tests/integration.mjs` 末尾的 production origin matrix 段（独立 spawn 在 8793 端口），改 requestSecurity/config 后必须跑 `npm run test:server` 验证
  - gh 会话过期时 gh auth status 报 token invalid，重新从 git credential fill 取 token 管道给 gh auth login --with-token 即可（勿回显）

[User Instruction Summary]
- Date: 2026-09-13
- Context: 将 NetLogo-Mobile 组织下的 Physics-Lab-Turtle-Services 登记进工作台时，用户强调写操作需二次确认
- Instructions:
  - 对 NetLogo-Mobile 组织内任何仓库的写操作（push、创建/合并 PR、改配置、发 issue/评论等），执行前必须逐次获得用户明确二次确认，不得以"已授权某一动作"推导出其他写操作也被授权
  - 读操作（clone、fetch、查看）不受此限制，可直接执行

[Project Knowledge Summary]
- Date: 2026-09-13
- Context: Discovered by Agent while performing 克隆 NetLogo-Mobile/Physics-Lab-Turtle-Services 到工作台
- Category: Environment Configuration
- Instructions:
  - Physics-Lab-Turtle-Services 是私有仓库，内部项目/解决方案名为 Quantum Services（Quantum Physics Services），是 Physics Lab 与 NetLogo 的后端 API（ASP.NET Core .NET 8 + MongoDB + Redis + SSO）
  - 环境 git 默认 credential.helper 是指向 Agent 的 `/app/agent/bin/agent git-credential-helper`，无法访问私有仓库；gh 登录为 wsxiaolin 后执行 `gh auth setup-git`，会为 github.com / gist.github.com 配置 `gh auth git-credential`，私有仓库即可用 git clone，其余 host 仍走 Agent helper
  - 工作台 install-projects.sh 已支持 `*.sln` / `*.csproj` 的 `dotnet restore`（未安装 dotnet 时跳过）

[Project Knowledge Summary]
- Date: 2026-09-14
- Context: Discovered by Agent while performing 匿名评论隐藏职位改动（PR 19）
- Category: Build Methods
- Instructions:
  - Physics-Lab-Turtle-Services 在当前环境无法完成 `dotnet build`：解决方案包含 SSO 模块，缺失该模块时整体编译不通过；用户明确表示测试跑不起来、不必本地跑
  - 因此该仓库的改动不依赖本地编译验证，交由仓库 CI / 人工 review 把关；环境默认未安装 dotnet
  - 仓库 GitHub 默认分支是 `main`（claude.md 里写的 `master` 指部署触发，创建分支/PR 以 `main` 为 base）
