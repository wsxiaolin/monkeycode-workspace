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
- Date: 2026-10-03 (corrects the 2026-09-14 entry)
- Context: Discovered by Agent while performing 验证 PR #21 本地开发栈能否在本环境跑通
- Category: Build Methods
- Instructions:
  - 【2026-10-03 更正】装上 .NET SDK 8 后该仓库 `dotnet build` 实测通过（PR #21 分支 0 错误，峰值内存 910MiB / 2.5min；PR 只加 appsettings 与 dev 脚本，main 分支同样可编译）。旧结论"因 SSO 缺失编译不过"不成立：`Quantum SSO/` 是客户端项目、随解决方案一起编译，缺的是运行期 SSO 服务端（PR #21 用 mock 补）
  - 本地工具链已就位：dotnet 8.0.425（~/.dotnet）、mongod 8.0.12（~/mongo/bin，tarball）、redis-server 7.0.15（apt）、pymongo 4.18（pip --break-system-packages）
  - 仓库 GitHub 默认分支是 `main`（claude.md 里写的 `master` 指部署触发，创建分支/PR 以 `main` 为 base）

[Project Knowledge Summary]
- Date: 2026-10-03
- Context: Discovered by Agent while performing 验证 PR #21（feat/local-dev-stack）mock 本地开发栈
- Category: Operations & Deployment
- Instructions:
  - PR #21 mock 栈在本环境实测跑通：mongod 27017 + redis 6379 + mock SSO 13000/13001 + API 9348；三条认证流（匿名/authCode/邮箱密码）返回完整 StartupPackage，verify-all 13 项 12 过（CrossService 用例硬编码作者库用户 ObjectId，属测试数据耦合）
  - 启动方式：`bash dev/run-dev.sh`（首次建议 SKIP_SYNC=1）；配置同步用 `SYNC_GITHUB_TOKEN=$(gh auth token) bash dev/sync-config.sh --api-url http://127.0.0.1:9348`（成功判据 Status 200：12 库/61 消息/47 价格/30 活动/7 充值/47 标签/1 促销/0 错误）
  - run-dev.sh 已修的本地 bug（未提交）：`[ -x "$MONGOD"/"$REDIS_BIN" ]` 对 command -v 的裸名做 -x 测试按相对路径解析会误判；apt 装的 redis 必中此 bug
  - sync-config.sh 已知问题：正则取 hosts.yml 第一个 oauth_token，本机排前的是已过期 monkeycode-ai[bot] token，导致 tarball 下载 401→502；正确做法是用 `gh auth token`
  - run-dev.sh 的 sync 步骤自起临时 API 占 9348，kill/pkill 后主 API 立即启动有端口竞态（address already in use）；规避：SKIP_SYNC=1 启动后再用 --api-url 补同步

[User Instruction Summary]
- Date: 2026-10-03
- Context: gh pr checkout 21 在 /workspace 根目录误将工作台仓库切到 PR 分支，工作树被 Physics-Lab 内容覆盖（reflog 证实，已用 git switch 260926-chore-record-ci-preference 完整恢复）
- Instructions:
  - gh pr checkout / gh repo clone 等会改变当前仓库工作树的命令，必须在目标项目目录内执行；在工作台根目录只做只读查询

[User Instruction Summary]
- Date: 2026-09-26
- Context: 用户在 pl-town 云备份排查对话中提出的长期要求
- Instructions:
  - 思考过程（thinking）必须以 "we need..." 开头
  - 今后 git 提交/push 必须使用用户本人的 GitHub 账号身份，提交作者不得落到 Agent 自己名下
  - 用户的 GitHub 身份：login `wsxiaolin`，数字 ID `155876693`，提交作者名 `小临`，提交邮箱 `155876693+wsxiaolin@users.noreply.github.com`；禁止使用 `monkeycode-ai` / `monkeycode-ai@chaitin.com`
  - 若本环境 gh 未登录用户账号（仅有过期的 monkeycode-ai[bot]），需要先请用户登录，登录后再执行 `gh auth setup-git` 让 git 走用户凭据
  - 提交后必须核验作者与消息：`git log -1 --format='%an %cn'` + `%B | grep -ci monkey`；本环境曾在提交里自动注入 Co-authored-by trailer，用 `git -c core.hooksPath= commit` 可拦住，出现残留时 amend 后再推
  - 所有改动都必须提交并同步到远程（分支 + PR），不留本地未同步的改动
  - pl-town 云备份工作流不增加定时触发，只保留 `main` push 和手动触发
