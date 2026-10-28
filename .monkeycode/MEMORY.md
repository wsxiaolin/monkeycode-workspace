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
- Context: pl-town 历史重写事故复盘——Agent 在浅克隆不完整历史上执行 filter-repo，187 提交被截断为 4 个，推送前被分支保护拦截，用户叫停并撤回 force push 授权
- Instructions:
  - force push、历史重写（filter-repo 等）及任何改写远程历史的操作：动手前必须先向用户完整说明方案与影响面（哪些提交会保留/消失、哈希变化、对 contributor 的影响、回滚方式），拿到明确确认后才能执行；口头授权「允许 force push」仅覆盖推送动作，覆盖不了整套重写方案
  - 执行前先核实本地历史完整性：`git rev-list --count` 对比远程提交数，警惕 `--depth 1` 浅克隆残留的截断历史；对 contributor 有影响的 git 操作都按同等标准先沟通

[User Instruction Summary]
- Date: 2026-09-03
- Context: 初始化 monkeycode-workspace，作为后续统一维护多个项目的工作台
- Instructions:
  - 本仓库统一维护多个项目；源码由各项目自己的仓库维护，克隆到 `projects/` 后必须 gitignore，不要提交进本仓库；本仓库只存记忆、待办、规格与共享脚本

[Project Knowledge Summary]
- Date: 2026-09-03
- Context: Discovered by Agent while performing 工作台初始化与规范文档
- Category: Workflow & Collaboration
- Instructions:
  - 项目清单在 `projects/manifest.yaml`，检出为 `projects/<name>/`；用 `./scripts/bootstrap-projects.sh` 克隆、`install-projects.sh` 装依赖、`update-projects.sh` 更新；规范正文在 `WORKSPACE.md`，远程 https://github.com/wsxiaolin/monkeycode-workspace 默认 master

[Project Knowledge Summary]
- Date: 2026-10-28（并入 2026-09-05 两条 pl-town 条目）
- Context: Discovered by Agent while performing pl-town 仓库瘦身研究与历史重写事故复盘
- Category: Build Methods
- Instructions:
  - pl-town 资产体积守卫：`npm run check:asset-size`（单文件 1 MiB / 资产树 48 MiB），已接入 typecheck 和 build；新增纹理先跑 `pngquant --quality=70-95 --speed 1 --force --skip-if-larger --ext .png`，再用 PIL verify 校验完整性（环境已装 pngquant 2.17 与 Pillow 12.3，apt 装 pngquant 前需 apt-get update）
  - pl-town 构建（npm ci + typecheck + build）用 background terminal 限 memory_percent 60 / cpu_percent 200 跑通，峰值内存约 630 MiB
  - 瘦身终局：PR 125 已合并（PNG 81.7 -> 42.3 MiB）；历史重写被用户叫停，main 保持 187 个提交完整历史；GitHub API 报告的 ~243MB 是 fork 网络记账（fork 自 JamieAtGit/minicity），实际体积以全新 clone 为准
  - pl-town main 有分支保护（protected branch hook declined），token 能 push 但读不了保护规则 API（403），force push 会被服务端拒绝；历史重写方案留在 `projects/pl-town/docs/repo-size-reduction.md`，需维护者执行
  - `--depth 1` 浅克隆 + 后续 fetch 不会解除 shallow 截断，`git fetch --unshallow` 报 "complete repository" 时历史才完整

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
  - Physics-Lab-Turtle-Services 是私有仓库，内部名 Quantum Services，是 Physics Lab 与 NetLogo 的后端 API（ASP.NET Core + MongoDB + Redis + SSO）
  - 默认 credential.helper 指向 Agent helper，无法访问私有仓库；gh 登录 wsxiaolin 后 `gh auth setup-git` 会为 github.com / gist.github.com 配 `gh auth git-credential`，其余 host 仍走 Agent helper
  - install-projects.sh 支持 `*.sln` / `*.csproj` 的 `dotnet restore`（未装 dotnet 时跳过）

[Project Knowledge Summary]
- Date: 2026-10-28（并入 2026-09-14 条目）
- Context: Discovered by Agent while performing 匿名身份资料修改拦截（PR #22）与测试体系梳理
- Category: Build Methods
- Instructions:
  - 本环境无法本地构建或跑测试：`dotnet not found`，`global.json` 要求 SDK 10.0.100，改动只能靠仓库 CI 验证；PR 里要明确写「本地未跑」。仓库默认分支 `main`（CLAUDE.md 的 `master` 指部署触发），用户要求一律走 PR、永不推 main；提交前需 `git config --local user.name/user.email`（wsxiaolin / monkeycode-ai@chaitin.com）
  - 测试体系共两个项目：`Quantum Tests`（基础设施：Mongo 驱动、wire 压缩、日志、翻译重试、字符串工具 + 5 个 Smoke）、`Quantum API Tests`（约 116 个 Fact/Theory，用 TestServer 加载生产 Startup + 真实 Controller/Logic，每进程起 `mongo:5.0` + `redis:7-alpine` 容器，SSO 走 loopback 假服务，Firebase 用临时 RSA）
  - 三类套件：Baseline（`scripts/test-service.ps1 -Suite Regular`，默认 Physics/China，阻断，必须全绿）；KnownDefects（`-Scope KnownDefects`，断言「应有但未实现」的行为，CI 里 `continue-on-error: true` 永不阻断，修好后在同一个 PR 删掉 `[Trait("Category", "KnownDefect")]` 转正）；Smoke（`workflow_dispatch` 手动触发，验证生产密钥对真实服务可用，有写生产数据的副作用，本地脚本永久排除）
  - `Full` 套件才跑 2 域（physics-api / nlm-api）× 2 区域（us / cn）共 4 套；常规 Regular CI 不覆盖 NetLogo 域与 US 区域，PR 描述里应说明未覆盖范围
  - `Quantum API Tests/action-inventory.json` 是强制契约：80 条 MVC action 各自记录 Authorization 策略、State 副作用与覆盖它的测试；`ActionInventoryTests.Inventory_MatchesDiscoveredActionsAndExistingTests` 会反射比对真实路由（多一个少一个都失败）、要求每条至少有测试或精确排除、并校验测试方法名真实存在。新增接口必须同时加测试并登记，否则 PR 必红
  - 截至 2026-10-28 的 known-defect 欠账共 6 条：拉黑不移除反向关注、并发领站内信奖励重复、并发购买重复扣费、他人凭证可领取、并发领活动奖励重复、私有内容直链返回 200。看到这 6 条红属既有问题，与本 PR 无关
  - 定位代码时注意 `CheckUser()` 只校验 token 有效、不看 `IsBinded`；需要绑定校验的动作（Rename / RedeemPromo / SwitchRegion / Report / ModifyInformation / ConfirmAvatar）都必须显式写 `!User.IsBinded`，只写 `User.ID == AnonymousID` 会漏掉普通未绑定用户

[Project Knowledge Summary]
- Date: 2026-09-24
- Context: Discovered by Agent while performing 克隆并整理 wsxiaolin/diary 为 persona + 知识库
- Category: Operations & Deployment
- Instructions:
  - `wsxiaolin/diary` 是私有仓库（约 35 个 md/txt，按学段分目录），作为 persona 与知识库素材，已登记并克隆到 `projects/diary/`，不提交进工作台
  - 衍生交付物同时存在两处：工作区根目录 `diary-persona/` 与日记仓库的 `persona/`（用户要求不走 PR 直接合 main，已 push，PR #1 自动标记 merged）
  - 人格提示词拆两版：`persona/人格提示词-社区版.txt`（偏物实社区/管理/开发）与 `persona/人格提示词-现实版.txt`（面对现实朋友，更短、少提社区）；知识库为 `persona/知识库/01-11*.txt`；`persona/待回答-人格补充问题清单.txt` 为 A-P 共 160+ 条待本人作答的问题

[Project Knowledge Summary]
- Date: 2026-10-28（并入 2026-10-03 两条赛博生命条目）
- Context: Discovered by Agent while performing plweb-cyberlife/plap 登记、巡检与回复通知/技能注册修复
- Category: Troubleshooting & Debugging
- Instructions:
  - 工作台登记 `projects/plweb-cyberlife/`（谢千树/落星如雨，本地身份 xiegushi2022@outlook.com）、`projects/plweb-cyberlife-zengyimo/`（曾以沫/焦距有点长，zengyimo@users.noreply.github.com，同源姊妹实例）、`projects/plap/`（物实 API 封装，npm 包名 plweb）；都在 wsxiaolin 个人仓库下，无 NetLogo-Mobile 二次确认约束
  - CI 唤醒正常判定：成功唤醒 + 作息门卫深夜取消属预期；门卫判定「不该醒」后 `gh run cancel` 自身遇 GitHub API 瞬时 5xx 会以 failure 收场，属良性噪音
  - 物实评论回复的服务端真实语义（源码核实 CommentLogic.PostCommentAsync）：Comment-Replied 站内信需要「正文 @ 提及 + 请求体 ReplyID=被回复人用户 ID」两条件同时成立；ReplyID 传评论 ID 无效；plap 的 send.js/bot 与此一致
  - GitHub cron 可靠性实测：00:30Z/02:30Z（北京 08:30/10:30）会被调度器整体丢弃，04:30Z 迟到 60~95 分钟，08:30Z 及以后准点；门卫 ±100 分钟容差只能兜迟到、兜不了不触发
  - opencode 技能发现路径仅限 `.opencode/skills/`、`.claude/skills/`、`.agents/skills/`（项目级）与 `~/.config/opencode/skills/` 等（全局）；目录 symlink 可被正常发现，plweb-cyberlife 用 `.agents/skills/<name> -> ../../skills/<name>` 单源注册；`opencode debug skill` 可无模型列出技能发现结果，是零成本验证手段（本机 opencode 1.18.34）

[Project Knowledge Summary]
- Date: 2026-10-28（并入 2026-10-03 与 2026-09-25 两条 Environment Configuration 条目）
- Context: Discovered by Agent while performing 新环境初始化、三仓库 OAuth 联调提交推送与 PR #22
- Category: Environment Configuration
- Instructions:
  - git credential helper 对 github.com 返回 500（早期"从 helper 取 token 赋给 GH_TOKEN"路径已不可用）。当前流程：后台终端跑 `gh auth login --hostname github.com --git-protocol https --web`，把 one-time code 给用户在 https://github.com/login/device 授权（默认 scopes: gist, read:org, repo），成功后 `gh auth setup-git`
  - 默认 gh token 只有 `gist,read:org,repo`，推 `.github/workflows/` 会被拒（workflow scope）；解法：`GH_CONFIG_DIR=<隔离目录> gh auth login --web --scopes repo,workflow` 走 device code 拿独立凭据，不影响默认登录，PR 用 `GH_CONFIG_DIR=<目录> gh pr create`
  - 各项目仓库默认没有 git user identity（只有 pl-town 自带 --local）。提交前先 `git config --local user.name/user.email`，用 wsxiaolin / monkeycode-ai@chaitin.com
  - 依赖安装：plweb-skill 纯文档、diary 纯 markdown、physics-lab-turtle-services 无 dotnet，install-projects.sh 都会跳过；只有 pl-town 需要 npm install（180 包，峰值内存约 288 MiB）
  - 三仓库物实 OAuth 联调：服务端只做白名单（`AuthorizeForum` 回调 + `CheckOrigin`），plweb2 提供 `/oauth/authorize`，pl-town 走 `/town-api/pl/oauth/start` 与固定回调 `/town-api/auth/oauth2_basic/callback`

[Project Knowledge Summary]
- Date: 2026-10-28（并入 2026-09-26 两条 Workflow & Collaboration 条目）
- Context: Discovered by Agent while performing 赛博生命人设改动、pl-town 施工区分支收尾与工作台记忆维护
- Category: Workflow & Collaboration
- Instructions:
  - `projects/plweb-cyberlife/` 是赛博生命项目（谢千树/落星如雨）：AGENTS.md 为运行宪法，`prompts/wakeup.md` 是唤醒提示词，CI 用 opencode run 唤起，模型回退名单在 wakeup.yml/weekly.yml 的 `OPENCODE_MODEL_FALLBACKS`（逗号分隔）；人设/提示词改动集中在 AGENTS.md、prompts/wakeup.md、persona/、config/life.json
  - `projects/pl-town-construction/` 是 pl-town 的第二个本地检出（同一 remote wsxiaolin/pl-town，未登记 manifest.yaml），施工区域/城市场景类任务在该目录进行，注意与 `projects/pl-town/` 区分
  - 工作台可能有多个会话并行写 MEMORY.md：push 被拒时先 `git pull --rebase`，冲突时两边条目都保留（按日期排序追加），rebase 后继续推送

[User Instruction Summary]
- Date: 2026-10-10
- Context: 处理 pl-town PR #237 与 main 的合并冲突
- Instructions:
  - PR 合并冲突处理：除解决冲突外，还要检查可合并性（mergeable / mergeStateStatus）、跟进 AI 审查、盯 CI 到全绿，并判断是否具备合并条件（不代为合并，交给用户决定）；验收标准为 `gh pr checks` 全通过 + `mergeStateStatus: CLEAN` + `mergeable: MERGEABLE`
