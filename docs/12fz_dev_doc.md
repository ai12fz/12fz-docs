# 12FZ 完整项目开发文档 v10.18

> 最后更新：2026-06-08 | 版本：v10.18

> 项目：12FZ — 企业中台
     6|
     7|---
     8|
     9|## 第一部分：项目总览
    10|
    11|### 1.1 项目定位
    12|
    13|12FZ = 全球设计师平台 + 中国精工制造 + 海外贸易结算
    14|
    15|**行业范围：** 通用行业平台，主要覆盖服装鞋业（老板确认 2026-06-05）
    16|**设计理念：** ERP改造为企业中台（企业中台 = 所有业务能力的统一出口）
    17|**核心形态：** SaaS模式产品集群，每个功能模块对应可售卖的服务
    18|
    19|**使命：** 让全球设计师零门槛实现服装品牌梦
    20|**愿景：** 连接1000+设计师，覆盖50+城市，年GMV破亿
    21|
    22|### 1.2 核心策略
    23|
    24|1. **先做社群，再做技术** — 设计师社群优先，技术按需迭代
    25|2. **渐进式去中心化** — 先中心化电商，后Web3赋能
    26|3. **线下反哺线上** — 体验店=NFT领取点+DAO据点
    27|
    28|### 1.3 融资概况
    29|
    30|| 项目 | 内容 |
    31||------|------|
    32|| 轮次 | 天使轮 |
    33|| 融资金额 | ¥1,000万 |
    34|| 出让股份 | 10% |
    35|| 投后估值 | ¥1亿 |
    36|| 首店 | 贵阳 |
    37|| 3年扩张 | 贵州→广西 50店 |
    38|
    39|### 1.4 预算分配
    40|
    41|| 类别 | 金额 | 占比 |
    42||------|------|------|
    43|| 技术开发 | ¥360万 | 36% |
    44|| 运营团队 | ¥503万 | 50.3% |
    45|| 基础设施 | ¥35万 | 3.5% |
    46|| 预留/应急 | ¥102万 | 10.2% |
    47|| **合计** | **¥1,000万** | **100%** |
    48|
    49|---
    50|
    51|## 第二部分：总体技术架构（v9.0 全量重构）
    52|
    53|### 2.1 核心理念
    54|
    55|**全量重构，现在就干。** 不渐进，不"下一代"。
    56|
    57|### 2.2 系统架构总览
    58|
    59|```
    60|                          ┌──────────┐
    61|                          │  前端     │
    62|                          │ Vue/React │
    63|                          └─────┬────┘
    64|                                │ HTTP/WebSocket
    65|           ┌────────────────────┼────────────────────┐
    66|           │                    │                    │
    67|     ┌─────┴──────┐     ┌──────┴───────┐     ┌─────┴──────┐
    68|     │ Go 企业中台 │     │  Go 聊天系统  │     │ Python AI  │
    69|     │   核心      │     │              │     │            │
    70|     │ ERP模块     │     │  WebSocket   │     │ 大模型接口  │
    71|     │ 订单/库存   │     │  实时通讯     │     │ 智能尺码    │
    72|     │ 财务/报表   │     │  企内群聊     │     │ 数据分析    │
    73|     │ 用户/权限   │     │  企外群聊     │     │ AI对话     │
    74|     │ 商品/商户   │     │  加好友       │     │ AI编码助手 │
    75|     │ 认证中心    │     │  AI联系人     │     │            │
    76|     │ 控制台入口  │     │  客服系统     │     │            │
    77|     │ AI协作面板  │     └──────┬───────┘     └──────┬─────┘
    78|     │ 工作流引擎  │            │                    │
    79|     └──────┬──────┘            │                    │
    80|            │                   │                    │
    81|            └───────────────────┼────────────────────┘
    82|                                │
    83|                       ┌────────┴────────┐     ┌──────────────┐
    84|                       │  PostgreSQL      │     │  中央技能库   │
    85|                       │  统一数据库       │     │  Skill Registry│
    86|                       │  业务+聊天+用户   │     │  按角色分级    │
    87|                       └─────────────────┘     └──────────────┘
    88|```
    89|
    90|### 2.3 技术栈
    91|
    92|| 层级 | 技术 | 版本 | 用途 |
    93||------|------|------|------|
    94|| 操作系统 | Ubuntu LTS | 26.04 | 统一服务器环境 |
    95|| 业务核心 | **Go** | 1.24+ | ERP模块、订单/库存/财务、用户/权限、认证中心、商品/商户 |
    96|| 聊天系统 | **Go** | 1.24+ | WebSocket实时通讯、企内企外群聊、加好友、AI联系人 |
    97|| AI层 | **Python** | 3.12+ | 大模型接口、智能尺码推荐、数据分析、AI对话引擎 |
    98|| AI中枢 | Hermes Agent | latest | 团队调度、代码审核、任务分解 |
    99|| 前端 | **Vue/React** + TypeScript | latest | 统一前端（替代PHP/WP前端） |
   100|| 数据库 | **PostgreSQL** | 18 + pgvector | **统一数据层**：业务+聊天+用户+向量 |
   101|| 缓存 | Redis | 7.x | 缓存加速、会话管理 |
   102|| 容器化 | Docker | latest | 标准化部署 |
   103|| CI/CD | GitHub Actions | — | 自动化部署 |
   104|
   105|**存量维护（不参与重构）：**
   106|| PHP（ThinkPHP） | 8.5 | goxeou商城存量运行，等待Go新系统替换 |
   107|| WordPress | PHP + MariaDB | 12fz商城存量运行，等待Go新系统替换 |
   108|| Java（Spring Boot） | 17+ | 数造ERP存量运行，数据迁到Go新系统后下线 |
   109|| Oracle XE | 21c | 数造ERP数据库，迁到PG后下线 |
   110|
   111|### 2.4 语言分工
   112|
   113|| 语言 | 负责模块 | 不做什么 |
   114||------|---------|---------|
   115|| **Go** | ERP业务、聊天系统、用户/权限中心、认证网关、订单/库存、商品/商户、支付 | 不做AI推理、不做大模型调用 |
   116|| **Python** | AI助手引擎、大模型接口、智能推荐、数据分析、Hermes Agent | 不直接写业务表、不构造交易订单 |
   117|| **Vue/React** | 统一前端界面 | 不做后端逻辑 |
   118|| **存量Java** | 老ERP维护 | 不加新业务，等数据迁移完成下线 |
   119|| **存量PHP** | 老商城维护 | 不加新功能，等新系统替换 |
   120|
   121|### 2.5 数据库架构（统一）
   122|
   123|**一个PG库，三个Schema：**
   124|
   125|```
   126|postgresql://PG:***@gong3 | Go架构设计、ERP模块（订单/库存/财务）、用户/权限中心、认证网关、商品/商户API |
   127|
   128|
   129|
   130|
   131|
   132|
   133|
   134|
   135|
   136|
   137|
   138|
   139|
   140|
   141|
   142|
   143|
   144|
   145|
   146|
   147|
   148|
   149|
   150|
   151|
   152|
   153|
   154|
   155|
   156|
   157|
   158|
   159|
   160|
   161|
   162|
   163|
   164|
   165|
   166|
   167|
   168|
   169|
   170|
   171|
   172|
   173|
   174|
   175|
   176|
   177|
   178|
   179|
   180|
   181|
   182|| **Go聊天系统** | @gong3 | WebSocket通讯、企内企外群聊、加好友、AI联系人集成 |
   183|| **AI层** | @chaogu-ai | Python AI助手引擎、大模型接口、智能尺码、数据分析 |
   184|| **前端** | **待定** | Vue/React统一前端，替代现有PHP/WP前端 |
   185|| **基础设施** | @服务器技术 | Ubuntu/Nginx/PG/Docker部署、DevOps、存量系统维护 |
   186|| **数据迁移** | @高级工程师 | 老ERP（Java/Oracle）数据迁移到Go新系统+PG，老系统维护 |
   187|
   188|### 3.2 各模块分配
   189|
   190|| 模块 | 语言 | 负责人 | 备注 |
   191||------|------|--------|------|
   192|| Go架构搭建+路由 | Go | gong3 | 框架选型、项目骨架 |
   193|| ERP业务（订单/库存/财务/报表） | Go | gong3 | 核心业务模块 |
   194|| 用户/权限中心 | Go | gong3 | 统一用户、角色、权限 |
   195|| 认证网关（OAuth） | Go | gong3 | 邮箱/手机/Google/微信 |
   196|| 商品/商户/设计师 | Go | gong3 | 电商基础 |
   197|| 聊天系统（WebSocket） | Go | gong3 | 实时通讯、群聊、好友 |
   198|| AI助手引擎 | Python | chaogu-ai | 大模型对话、业务查询 |
   199|| 智能尺码推荐 | Python | chaogu-ai | 历史数据+AI模型 |
   200|| 数据分析/预警 | Python | chaogu-ai | 异常检测、报表 |
   201|| 前端（Vue/React） | TS | 待定 | 统一UI（不含聊天前端，聊天前端由gong3负责） |
   202|| DevOps/部署 | Shell | 服务器技术 | Docker、CI/CD |
   203|| 存量老ERP维护 | Java | 高级工程师 | 数据迁移期间保持运行 |
   204|| 存量WP/PHP维护 | PHP | 服务器技术 | 等待新系统替换 |
   205|| Hermes Agent调度 | Python | chaogu-ai | 团队协调、文档管理 |
   206|
   207|### 3.3 开发流程（全量重构）
   208|
   209|```
   210|全量重构开发流程
   211|│
   212|├─ 阶段0: 选型调研（multi-agent-team-development-workflow B.0）
   213|│   ├─ 延后2-7天，查资料再动手
   214|│   └─ 对应技能: spike（快速验证可行性）
   215|│
   216|├─ 阶段1: 计划（plan → writing-plans）
   217|│   ├─ 讨论→共识→出实施计划
   218|│   ├─ 每任务2-5分钟粒度
   219|│   └─ 对应技能: plan / writing-plans
   220|│
   221|├─ 阶段2: 写代码（subagent-driven-development）
   222|│   ├─ TDD: RED→GREEN→REFACTOR（test-driven-development）
   223|│   ├─ CRG影响半径分析（code-review-graph）
   224|│   ├─ 子代理2阶段审核（spec + quality）
   225|│   └─ 对应技能: subagent-driven-development / test-driven-development
   226|│
   227|├─ 阶段3: 审核（requesting-code-review → code-reviewer）
   228|│   ├─ 安全扫描/基线对比/独立审核/自动修复
   229|│   ├─ CRG detect-changes风险分析
   230|│   ├─ 业务流浏览器实测
   231|│   └─ 对应技能: requesting-code-review / code-reviewer / code-review-graph
   232|│
   233|├─ 阶段4: 调bug（systematic-debugging）
   234|│   ├─ 4阶段: 根因→模式→假设→修复
   235|│   └─ 对应技能: systematic-debugging
   236|│
   237|├─ 阶段5: 合入（multi-agent-team-development-workflow B.8-9）
   238|│   ├─ 开发站测试 → 老板确认 → 同步生产
   239|│   └─ 对应技能: multi-agent-team-development-workflow
   240|│
   241|└─ 辅助: spike（快速验证可行性）
   242|```
   243|
   244|### 3.4 沟通规则
   245|
   246|- **群聊（12FZ程序开发组）：** 项目相关（开发/代码/需求/审核）
   247|- **私聊（老板）：** 交易信号/策略报告/仓位状态
   248|- **bot间沟通：** 通过中继（群聊消息自动同步到中继，让所有bot看到讨论内容）
   249|- **重大决策：** 找老板确认
   250|- **统一时区：** 北京时间（CST, UTC+8）
   251|- **回复格式：** 被@回复时开头加 `回：@对象`
   252|
   253|### 3.5 开发优先级（2026-06-06 老板确认）
   254|
   255|**新优先级：聊天系统骨架 > SSO用户系统**
   256|
   257|飞书体验不佳，老板决定优先开发私有聊天系统。B方案：
   258|
   259|| 时间段 | 任务 | 负责人 |
   260||:-----:|:-----|:------|
   261|| Mon-Wed | 聊天系统骨架（WebSocket消息收发 + simple token认证 + PG存储 + 基础群聊+网页版前端） | gong3 |
   262|| Thu-Sun | 继续SSO用户系统（Phase 1） | gong3 |
   263|
   264|**网页版前端归属（老板确认 2026-06-06）：** gong3同时负责聊天系统Go后端+网页版前端，前端UI参考老ERP Java聊天界面布局，用新框架重写。统一前端（Vue/React）仍为"待定"，不含聊天前端。
   265|
   266|**聊天界面风格（老板确认 2026-06-06）：** 聊天界面改成纯聊天界面，参考老ERP系统 `/index/vmain/main` 页面的布局和风格。gong3直接用202机器上的老ERP UI源码做前端。
   267|
   268|**域名策略（老板确认 2026-06-06）：**
   269|| 域名 | 用途 |
   270||:---|:-----|
| **chat.12fz.com** | 聊天系统入口（HTTPS + Let's Encrypt） |
| **go.12fz.com** | **数造企业中台**（Go+PG，并行生产站） |
| **new.12fz.com** | 过渡站，后期停用 |
   273|| chat系统已上线HTTPS，Nginx反向代理 `/api/` → Go后端:8081 |
   274|
   275|**架构原则（老板确认）：**
   276|- `core/`（消息层）一次定型不改
   277|- `auth/`（认证层）留好接口，现在用simple token，后面接JWT/SSO只改auth.go
   278|- 重构量预估：后面接SSO约1-2天，不需推倒重来
   279|- bot接入准备工作（中继/gateway改造）由chaogu-ai并行推进
   280|
   281|### 3.6 聊天系统近期UI需求（2026-06-06 老板确认）
   282|
   283|| 需求 | 负责人 | 状态 |
   284||:----|:------|:----:|
   285|| **名称背景改白色** — 聊天框中发送者名称（sender_id显示区域）背景改为白色 | @gong3 | ⏳ 待执行 |
   286|| **bot显示名修正** — chat系统中bot应使用中文名：chao1→服务器技术、serv01→高级工程师（已在DB中修正，bridge以中文名运行） | chaogu-ai | ✅ 已完成 |
   287|
   288|**bot显示名记录（老板确认 2026-06-06）：**
   289|- 服务器技术（对应原 `chao1`）
   290|- 高级工程师（对应原 `serv01`）
   291|- chaogu-ai 名称已正确，无需修改
   292|- 所有bot在聊天系统中均以中文名显示
   293|
   294|### 3.7 HEARTBEAT_OK取消 + Bot在线状态红绿灯（2026-06-08 老板确认）
   295|
   296|**老板明确指示：** HEARTBEAT_OK 此类系统消息不再往群里发，改为在群信息中 bot 名字后面用红绿灯显示在线状态。
   297|
   298|| 需求 | 负责人 | 状态 |
   299||:----|:------|:----:|
   300|| **bot侧：** cron从发群消息改为定时POST /api/bot/heartbeat 报平安 | @chaogu-ai | ⏳ 待执行 |
   301|| **后端：** 新增状态表 + POST /api/bot/heartbeat + GET /api/group/{id}/bots/status | @gong3 | ⏳ 待执行 |
   302|| **前端：** 群成员列表bot名字右边加🟢/🔴圆点（超180秒无心跳→离线标记） | @gong3 | ⏳ 待执行 |
   303|
   304|**约定：**
   305|- bot每60秒POST一次心跳
   306|- 超时 >180秒未心跳 → 标记为offline
   307|- 前端渲染：🟢 在线 / 🔴 断连
   308|
   309|### 3.8 聊天系统近期UI需求（2026-06-08 老板确认）
   310|
   311|老板在聊天系统中直接提出以下改进并已由chaogu-ai实施：
   312|
   313|| 需求 | 负责人 | 状态 |
   314||:----|:------|:----:|
   315|| **快捷@加冒号** — 点击bot标签插入`@botName:内容`（原为`@botName`），方便直接跟内容 | @chaogu-ai | ✅ 已上线 |
   316|| **自己消息显示发送者名称** — 自己发的消息气泡内容上方右边显示自己的名称（原仅别人消息有名称），同时他人消息名称位置不变 | @chaogu-ai | ✅ 已上线 |
   317|| **未读消息刷新后错误提示bug** — 消息已读后刷新页面，左侧栏仍显示有新消息 | @chaogu-ai | 🔍 排查中 |
   318|
   319|---
   320|
   321|## 第四部分：开发路线图（v9.0 全量重构）
   322|
   323|**方向：** 全量重构，现在就干。Go企业中台核心 + Go聊天系统 + Python AI + 统一PG + 中央技能库。
   324|
   325|**⚠️ 2026-06-06 优先级更新：聊天系统骨架优先于SSO（老板确认）。详见3.5节。**
   326|
   327|### Phase 0：设计定稿 + 基础设施（第0-2周，并行）
   328|
   329|| 序号 | 模块 | 语言 | 负责人 | 人天 |
   330||:----:|------|:----:|:------:|:----:|
   331|| 0.1 | 开发文档 v10.0（企业中台/权限/Skill Registry设计） | Doc | chaogu-ai | 3 |
   332|| 0.2 | PG数据库部署 + Schema设计（biz/chat/sys） | Shell | 服务器技术 | 3 |
   333|| 0.3 | 老ERP数据迁移（Oracle→PG，含BLOB/编码/存储过程适配） | Java/Python | 高级工程师 | 10 |
   334|| 0.4 | 中央技能库基础架构（角色分级 + sync按角色同步） | Shell | 服务器技术 | 3 |
   335|| **Phase 0 合计** | | | | **19人天** |
   336|
   337|### Phase 1：Go骨架 + 用户体系（第3-6周）
   338|
   339|| 序号 | 模块 | 语言 | 负责人 | 人天 |
   340||:----:|------|:----:|:------:|:----:|
   341|| 1.1 | Go项目骨架搭建（路由/中间件/配置） | Go | gong3 | 5 |
   342|| 1.2 | 统一用户系统（unified_users + unified_oauth_bindings） | Go | gong3 | 5 |
   343|| 1.3 | 用户角色权限中心（角色/权限/菜单） | Go | gong3 | 8 |
   344|| 1.4 | 认证网关（邮箱密码 + JWT + OAuth框架） | Go | gong3 | 8 |
   345|| 1.5 | 企业子账号系统（suzao/kefu 命名体系 + 三层权限模型） | Go | gong3 | 5 |
   346|| 1.6 | 企业中台控制台基础框架（图标入口 + 路由） | Go | gong3 | 5 |
   347|| **Phase 1 合计** | | | | **36人天** |
   348|
   349|### Phase 2：聊天系统 + AI助手雏形（第7-10周）
   350|
   351|| 序号 | 模块 | 语言 | 负责人 | 人天 |
   352||:----:|------|:----:|:------:|:----:|
   353|| 2.1 | WebSocket聊天服务搭建 | Go | gong3 | 5 |
   354|| 2.2 | 1对1聊天 + 消息存储 | Go | gong3 | 5 |
   355|| 2.3 | 企内群聊 + 企外群聊 | Go | gong3 | 8 |
   356|| 2.4 | 加好友系统（企内/企外） | Go | gong3 | 5 |
   357|| 2.5 | AI助手引擎（大模型对话接口 + 业务查询） | Python | chaogu-ai | 8 |
   358|| 2.6 | 聊天与各业务页面对接（"联系"按钮） | Go+前端 | gong3+待定 | 5 |
   359|| 2.7 | Skill Registry服务（中央技能库注册中心v1） | Go | gong3 | 5 |
   360|| **Phase 2 合计** | | | | **41人天** |
   361|
   362|### Phase 3：电商业务核心（第11-18周）
   363|
   364|| 序号 | 模块 | 语言 | 负责人 | 人天 |
   365||:----:|------|:----:|:------:|:----:|
   366|| 3.1 | 商品SPU/SKU系统（含AI编码助手入口） | Go | gong3 | 10 |
   367|| 3.2 | 订单系统 + 购物车 | Go | gong3 | 15 |
   368|| 3.3 | 库存管理 | Go | gong3 | 8 |
   369|| 3.4 | 支付网关（支付宝/Binance/PayPal） | Go | gong3 | 15 |
   370|| 3.5 | 多商户/设计师入驻（含行业选择+审核） | Go | gong3 | 10 |
   371|| 3.6 | 智能尺码推荐 | Python | chaogu-ai | 5 |
   372|| 3.7 | 数据分析/异常预警 | Python | chaogu-ai | 5 |
   373|| 3.8 | 前端实现（统一Vue/React） | TS | 待定 | 30 |
   374|| **Phase 3 合计** | | | | **98人天** |
   375|
   376|### Phase 4：完善 + 存量替换（第19-24周）
   377|
   378|| 序号 | 模块 | 语言 | 负责人 | 人天 |
   379||:----:|------|:----:|:------:|:----:|
   380|| 4.1 | AI协作面板（bot状态标识+协作看板） | Go+TS | gong3+待定 | 10 |
   381|| 4.2 | 智能工作流引擎（任务拆解+瓶颈标记+转接） | Python+Go | chaogu-ai+gong3 | 10 |
   382|| 4.3 | 财务/报表系统 | Go | gong3 | 10 |
   383|| 4.4 | 设计师结算系统 | Go | gong3 | 10 |
   384|| 4.5 | 老商城（PHP/WP）替换为新前端 | TS | 待定 | 15 |
   385|| 4.6 | 老ERP（Java）下线确认 | — | 全团队 | 5 |
   386|| 4.7 | 端到端测试 + 上线 | — | 全团队 | 10 |
   387|| **Phase 4 合计** | | | | **70人天** |
   388|
   389|**总计：~226人天（按3人并行约3个月）**
   390|
   391|---
   392|
   393|## 第五部分：统一认证体系详细设计
   394|
   395|### 5.1 核心数据模型
   396|
   397|```sql
   398|-- 统一用户表
   399|CREATE TABLE unified_users (
   400|    id              BIGSERIAL PRIMARY KEY,
   401|    email           VARCHAR(255) UNIQUE,
   402|    phone           VARCHAR(20) UNIQUE,
   403|    phone_country   VARCHAR(4),
   404|    password        VARCHAR(255),        -- bcrypt hash
   405|    display_name    VARCHAR(100),
   406|    avatar_url      TEXT,
   407|    locale          VARCHAR(10) DEFAULT 'zh-CN',
   408|    timezone        VARCHAR(50) DEFAULT 'Asia/Shanghai',
   409|    status          VARCHAR(20) DEFAULT 'active',
   410|    created_at      TIMESTAMPTZ DEFAULT NOW(),
   411|    updated_at      TIMESTAMPTZ DEFAULT NOW()
   412|);
   413|
   414|-- OAuth绑定（可绑定多个）
   415|CREATE TABLE unified_oauth_bindings (
   416|    id              BIGSERIAL PRIMARY KEY,
   417|    user_id         BIGINT REFERENCES unified_users(id) ON DELETE CASCADE,
   418|    provider        VARCHAR(32) NOT NULL,
   419|    provider_id     VARCHAR(128) NOT NULL,
   420|    provider_email  VARCHAR(255),
   421|    provider_name   VARCHAR(100),
   422|    raw_data        JSONB,
   423|    bound_at        TIMESTAMPTZ DEFAULT NOW(),
   424|    UNIQUE (provider, provider_id)
   425|);
   426|
   427|-- 角色表
   428|CREATE TABLE unified_roles (
   429|    id          SERIAL PRIMARY KEY,
   430|    name        VARCHAR(50) UNIQUE,
   431|    description TEXT
   432|);
   433|
   434|-- 用户-角色关联
   435|CREATE TABLE unified_user_roles (
   436|    user_id     BIGINT REFERENCES unified_users(id),
   437|    role_id     INT REFERENCES unified_roles(id),
   438|    created_at  TIMESTAMPTZ DEFAULT NOW(),
   439|    PRIMARY KEY (user_id, role_id)
   440|);
   441|```
   442|
   443|### 5.2 JWT方案
   444|
   445|- **Access Token**：15分钟有效期，短时效
   446|- **Refresh Token**：30天有效期，持久化
   447|- Token在Redis中做黑名单（登出时加入）
   448|
   449|### 5.3 国际化登录页
   450|
   451|按用户IP/浏览器语言/历史登录方式动态排序：
   452|- 中国用户：微信 > 手机 > 邮箱 > Google > 其他
   453|- 美国用户：Google > Apple > 邮箱 > Instagram > 其他
   454|- 日本用户：LINE > Google > Apple > 邮箱 > 其他
   455|
   456|---
   457|
   458|## 第六部分：技术规范（红线）
   459|
   460|### 6.1 数据库规范
   461|- 所有表必须带 `created_at` / `updated_at` 字段
   462|- 数据库变更必带回滚脚本
   463|- 严禁Python/Agent直接拼SQL操作业务DB
   464|- 跨语言调用必须经过接口契约（OpenAPI/gRPC）
   465|- MySQL仅存量运行，不新建业务表
   466|
   467|### 6.2 安全规范
   468|- API Key分环境（testnet/prod），`$HOME/.keys/`下600权限，禁止入Git
   469|- 交易订单签字逻辑独立成Go library，Python/Agent不得直接组装订单payload
   470|- 数据库凭证使用环境变量或Vault注入，禁止明文配置
   471|- Agent执行敏感操作需在沙箱内运行
   472|
   473|### 6.3 部署规范
   474|- 开发站验证 → 老板确认 → 同步生产（绝对红线）
   475|- **生产站绝对禁改**，没有老板明确指令不得触碰
   476|- **15天静默期（2026-06-02 起）：** 15天内不考虑生产站，等老板通知再同步生产（老板确认）
   477|- 改前备份（`cp xxx xxx.bak.$(date +%Y%m%d_%H%M%S)`）
   478|- 改完先验证再重启，不盲动
   479|
   480|### 6.4 开发规范
   481|- Go服务提供 pprof 端点，供Agent动态采样
   482|- Python模型服务强制使用 model_offload 策略（GPU/CPU自动切换）
   483|- Java堆内存与堆外内存分离，防OOM
   484|- PHP仅用于无状态前端胶水层，禁止长任务
   485|
   486|---
   487|
   488|## 第七部分：基础设施
   489|
   490|### 7.1 服务器清单
   491|
   492|| 服务器 | IP | 用途 | 系统 |
   493||--------|-----|------|------|
   494|| Vultr日本 | 167.179.79.44 | Hermes Agent(chaogu-ai)、交易系统、WireGuard服务端、Token12 API中转站 | Ubuntu 22.04 |
   495|| 阿里云广州 | 8.138.235.183 | Nginx代理、WordPress生产/开发站、ThinkPHP、Java ERP、Oracle、MySQL、Redis | Ubuntu 26.04 |
   496|| 高级工程师 | 10.10.10.202 (nps:20022) | 开发环境、PostgreSQL 18 + pgvector、Go/Java开发测试 | Ubuntu 26.04 |
   497|| gong3 101机器 | 10.10.10.101 (nps:8648) | Go后端开发、AgentCore、模拟交易 | Ubuntu 22.04 |
   498|| gong3 Windows | 10.10.10.111 (nps:20111) | Oracle/Java源码（迁移源） | Windows |
   499|
   500|### 7.2 容器化
   501|- 所有服务Docker化，Dockerfile随代码仓库
   502|- AI模型推理服务单独容器，与业务服务隔离
   503|
   504|### 7.3 Bot处理器代码统一管理（老板确认 2026-06-07）
   505|
   506|| 项目 | 内容 |
   507||------|------|
   508|| 范围 | 所有bot处理器脚本（chaogu-ai/服务器技术/高级工程师/gong3） |
   509|| 权威源 | GitHub仓库 |
   510|| 分发策略 | GitHub → 旧阿里云mirror（每30min fetch）→ 各机器内网拉取（每5min） |
   511|| 数据流 | 数据存在聊天系统PG中，处理器仓库只含代码不含数据 |
   512|
   513|**架构：**
   514|```
   515|GitHub (权威源)
   516|    │ cron 每30min
   517|    ▼
   518|旧阿里云 (git mirror + Nginx HTTP暴露)
   519|    │
   520|    ├── Vultr chaogu-ai (每5min git pull)
   521|    ├── 101 gong3 (每5min git pull)
   522|    └── 202 高级工程师 (每5min git pull)
   523|```
   524|
   525|**核心分离原则：** 消息/关键词配置等数据始终放在聊天系统仓库，处理器仓库只含代码，接口（API）是两者的边界。
   526|
   527|---
   528|
   529|## 附录C：Windows机器源码迁移计划
   530|
   531|### C.1 Windows源码清单（10.10.10.111，域SZ\\gong3）
   532|
   533|访问凭证：`SZ\\gong3` / `Suzao.123@456`（SMB共享D盘）
   534|
   535|| 目录 | 内容 | 语言/框架 | 迁移方式 |
   536||:----|:-----|:---------|:---------|
   537|| `D:\SzJavaClient\` | ERP桌面客户端（Windows Only） | VB.NET | ❌ **不迁移**，重构为Go/Java API |
   538|| `D:\develop\javaweb\` | 数造ERP后端（Spring Boot+Maven） | **Java** | ✅ SCP到202，Oracle→PG适配 |
   539|| `D:\develop\sz\` | 旧版sz系统 | Laravel PHP | ❌ 废弃，功能合并到新系统 |
   540|| `D:\develop\szkf\` | 格希欧前身/ThinkPHP | PHP | ✅ 已部署到阿里云，无需迁移 |
   541|| `D:\develop\app\` | 数造app（Android） | Java/Android | ⏳ 后续Web App替代 |
   542|| `D:\develop\订单\` (dingdan) | 订单系统 | — | 迁移到Go下单服务 |
   543|| `D:\develop\fastadmin-tp6\` | FastAdmin后台 | PHP/ThinkPHP6 | 评估是否保留 |
   544|
   545|### C.2 核心：javaweb（数造ERP Spring Boot）
   546|
   547|**路径：** `D:\develop\javaweb\`
   548|**技术栈：** Spring Boot + Maven + Oracle（当前）
   549|
   550|```xml
   551|<!-- pom.xml 关键信息 -->
   552|<groupId>com.shuzao</groupId>
   553|<artifactId>springboot-manager</artifactId>
   554|<version>1.0-SNAPSHOT</version>
   555|```
   556|
   557|**迁移步骤：**
   558|1. SCP整个 javaweb/ 到 高级工程师机器(202)
   559|2. JDBC驱动替换：ojdbc → PostgreSQL pgx JDBC
   560|3. SQL语法迁移（Oracle → PostgreSQL）
   561|4. 数据迁移：Oracle导出 → ora2pg → PG导入
   562|5. 编译验证：mvn clean package
   563|
   564|**Oracle→PG SQL对照表：**
   565|| Oracle | PostgreSQL |
   566||--------|-----------|
   567|| NVL(expr, alt) | COALESCE(expr, alt) |
   568|| SYSDATE | NOW() |
   569|| ROWNUM <= N | LIMIT N |
   570|| WHERE ROWNUM=1 | FETCH FIRST 1 ROW ONLY |
   571|| TO_CHAR(date, fmt) | TO_CHAR(date, fmt) |
   572|| TRUNC(date) | DATE_TRUNC('day', d) |
   573|| SEQUENCE.NEXTVAL | SERIAL/BIGSERIAL |
   574|| VARCHAR2(255) | VARCHAR(255) |
   575|| NUMBER(10,2) | NUMERIC(10,2) |
   576|| CLOB | TEXT |
   577|| BLOB | BYTEA |
   578|| SYS_GUID() | gen_random_uuid() |
   579|| MERGE INTO | INSERT ON CONFLICT |
   580|
   581|### C.3 需重构的VB.NET模块
   582|
   583|SzJavaClient是Windows桌面客户端，**无法直接迁移到Linux**。功能需重构：
   584|
   585|| VB.NET文件 | 功能 | 新实现 |
   586||:-----------|:-----|:-------|
   587|| `SzMain.vb` | ERP主界面 | 取消桌面端，合入Web |
   588|| `szgrab.vb` (179KB) | 数据抓取/业务逻辑 | 拆分为Go/Java微服务 |
   589|| `DingDan.vbproj` | 订单管理 | Go下单API |
   590|| `Login.vb` | 登录 | 统一认证中心 |
   591|| `ApiInterface.vb` | API接口封装 | OpenAPI定义 |
   592|
   593|### C.4 迁移4阶段
   594|
   595|| 阶段 | 内容 | 负责人 | 工期 |
   596||:----:|:-----|:------|:----:|
   597|| **P1** | SCP javaweb源码到202 + pom.xml依赖切换 | 高级工程师 | 2天 |
   598|| **P2** | Oracle→PG SQL语法适配+编译通过 | 高级工程师+gong3 | 5天 |
   599|| **P3** | 数据迁移（Oracle导出→ora2pg→PG导入） | 服务器技术 | 3天 |
   600|| **P4** | VB.NET功能分析和API重写计划 | gong3+chaogu-ai | 5天 |
   601|
   602|### C.5 Windows加密文件注意事项
   603|
   604|Windows机器安装了**透明加密工具**，文件已由老板手动解密。
   605|- 如果迁移后发现文件打不开（加密残留），在 `D:\` 建立文件列表，老板统一解密
   606|- 优先使用 `javaweb.zip`（已完整打包，不受加密影响）
   607|- 不需要在Windows上安装任何新工具
   608|
   609|### C.6 红线
   610|
   611|- ❌ Windows VB.NET客户端不迁移（重构）
   612|- ❌ 不动阿里云生产站Oracle Docker
   613|- ❌ 不删除Windows源码（保留只读备份）
   614|- ✅ javaweb先SCP到202开发测试
   615|- ✅ 等老板说「上线」才切PostgreSQL
   616|
   617|---
   618|
   619|## 第九部分：AI服务业务（2026-06-03新增）
   620|
   621|### 9.1 业务定位
   622|
   623|12FZ旗下的AI API中转服务，面向海外开发者提供中国AI模型API接入。
   624|
   625|- **域名：** https://token.12fz.com
   626|- **部署位置：** Vultr日本（167.179.79.44）
   627|- **技术栈：** one-api v0.6.11（Docker）+ Nginx + Let's Encrypt SSL
   628|
   629|### 9.2 核心逻辑
   630|
   631|```text
   632|中国API (DeepSeek/通义千问/月之暗面…)
   633|    ↓
   634|token.12fz.com ← 日本Vultr, HTTPS, OpenAI兼容接口
   635|    ↓ 
   636|海外开发者 (US/EU)
   637|```
   638|
   639|**为什么老外需要中转：** 中国AI平台需要+86手机号注册、实名认证、支付宝/微信支付，老外无法直接使用。
   640|
   641|### 9.3 当前已上线
   642|
   643|| 模块 | 状态 | 说明 |
   644||------|------|------|
   645|| 中转站 | ✅ | one-api v0.6.11, Docker运行, 自动重启 |
   646|| API通道 | ✅ | DeepSeek(主+备) / 通义千问(需激活) / Moonshot(余额不足) |
   647|| API | ✅ | OpenAI兼容, base_url=`https://token.12fz.com/v1` |
   648|| 定价 | ✅ | 4x零售倍率, $1免费试用 |
   649|| 收款 | ✅ | USDT → `0xc3ce2262317e80eDfeBeE58e6004A1Cbd944E63A`, 最低充值$10 |
   650|| 落地页 | ✅ | 中英双语（英文=开发者暗黑 / 中文=国内风格） |
   651|
   652|### 9.4 统一品牌账号（老板确认 2026-06-03）
   653|
   654|| 项目 | 内容 |
   655||------|------|
   656|| 用户名 | `token12fz` |
   657|| 密码 | `T12fz123456` |
   658|| 邮箱 | `qiuming@12fz.com` |
   659|| 范围 | 所有注册发帖相关平台统一使用 |
   660|
### 9.5 运营模式（老板确认）

- **方向：** 中国API卖老外，赚取差价
- **定价策略：** 零售价 = 成本价 × 4（DeepSeek V4-Flash $0.56/M入→$1.12/M出）
- **获客渠道：** Reddit r/LocalLLaMA发帖（需老板手动过验证码注册）、HackerNews
- **中英双线：** 英文面向海外开发者 + 中文面向国内用户（老板确认）

### 9.6 U盘产品 + Token中转站一体化策略（2026-06-08 老板确认）

**背景：** Hermes Agent U盘产品化方向确定（电商客服/企业AI助手），老板明确以下商业策略。

#### 决策一：U盘默认走自家中转站（老板确认）

**U盘是饵，中转站是钩。** 一次性的U盘收入 vs 持续性的中转流水。

```
U盘客户买U盘($49-99)   →   一次性小收入
       ↓
开箱即用，默认走 ai.12fz.com 中转
       ↓
每调一次API → 从中转走 → 我们赚差价
       ↓
客户越多 → 月流水越稳 → 边际成本趋零
```

#### 决策二：token中转站必须与中台打通（老板确认）

**中转站单独做就是个代理，和中台打通才成生意。**

| 不打通 | 打通中台 |
|:-------|:---------|
| 客户有独立账号，和中台脱节 | U盘客户 = 中台商户，一套体系 |
| 手工对账、麻烦 | 用量自动和商户账单挂钩 |
| 客户流失不知道 | 商户活跃度在中台一目了然 |
| 要单独做计费系统 | 借中台已有的订单/账单能力 |

**打通接口：**

| 接口 | 说明 |
|:-----|:------|
| **认证** | 中转调中台 `/api/auth/validate`，校验商户API key有效性 |
| **计量** | 每次token消耗 → 实时/准实时写回中台用量表 |
| **额度** | 中台控制商户余额/套餐额度，中转调 `/api/quota/check` |
| **账单** | 中台出账，自动生成订单，商户在企业中台后台看到"AI服务账单" |

#### 决策三：双中转架构 + 方案B路由（老板确认 2026-06-08）

**架构：** 国内中转（阿里云）走国内模型，国外中转（日本Vultr）走国外模型，统一入口 `ai.12fz.com/v1`。

**路由方案B：** 统一入口，国内中转自动识别模型归属。模型在国内池 → 直接转发；模型在国外池 → 自动转发日本中转站 → 回传结果。商户全程一个地址、一个key，无感切换。

```
U盘客户
  │ api_key = suzao/kefu 统一体系
  │ base_url = ai.12fz.com/v1
  ▼
┌── 国内中转（阿里云 one-api）─────────────┐
│  认证 → 调中台校验API key + 查余额       │
│  路由 → 查 relay_configs 该商户默认模型  │
│                                          │
│  模型在国内池 → 直接转发                  │
│  (DeepSeek/Qwen/Kimi/GLM)                │
│                                          │
│  模型在国外池 → 转发日本中转站            │
│  (Claude/GPT-4o/Gemini)                  │
│         │                                │
│         ▼                                │
│  ┌── 国外中转（Vultr one-api）──────┐     │
│  │  转发到Claude/GPT-4o等           │     │
│  │  回传结果 → 国内中转 → 返回客户  │     │
│  └─────────────────────────────────┘     │
│                                          │
│  每次调用 → 写 relay_usage → 中台扣费   │
└──────────────────────────────────────────┘
```

#### 决策四：中转站二次开发，基于 one-api fork（老板确认 2026-06-08）

不做自研，fork songquanpeng/one-api 加中台插件层。修改范围：

| 文件 | 修改内容 | 工作量 |
|:-----|:---------|:-------|
| `router/auth.go` | 排队逻辑前加中台认证插件 | 半天 |
| `router/relay.go` | 转发成功后异步调中台扣费 | 半天 |
| `controller/api.go` | 新增 `GET /v1/config` 返回商户模型配置 | 半天 |
| 中台端 | 三套API（auth/charge/config）+ 管理后台AI设置页 | 3天 |

#### 决策五：AI作为一级模块加入中台侧边栏（老板确认）

**实际中台菜单结构（2026-06-08 查询 zhongtai 库 sys_permission 表确认）：**

```
┌──────────────────────────────────────────┐
│  一级菜单（菜单名 + 图标）         排序    │
├──────────────────────────────────────────┤
│  █ 控制台                            1    │
│  █ 销售ERP  (fa-shopping-cart)       2    │
│  █ 仓库管理  (fa-archive)            3    │
│  █ 标签单据  (fa-tags)               4    │
│  █ 产品中心  (fa-cubes)              5    │
│  █ 智能工厂  (fa-industry)           6    │
│  █ 供应链    (fa-chain)              7    │
│  █ 财务管理  (fa-money)              8    │
│  █ 美工摄影  (fa-camera)             9    │
│  █ 设计联盟  (fa-paint-brush)       10    │
│  █ 客户CRM   (fa-users)             11    │
│  █ 智能OA    (fa-file-text)         12    │
│  █ 资讯      (fa-newspaper-o)       13    │
│  █ 数据中心  (fa-database)          14    │
│                                         │
│  🔥 AI服务  (fa-robot)             15 ← 新增
│                                         │
│  █ 系统设置  (fa-cogs)              16    │
│  █ 采购中心  (fa-cart-plus)         17    │
│  █ 操作日志  (fa-history)           18    │
│  █ 招聘管理  (fa-handshake-o)       19    │
│  █ 智能设备  (fa-laptop)            20    │
│  █ 商城      (fa-shopping-bag)      23    │
└──────────────────────────────────────────┘
```

**数据来源：** 202机 PG 数据库 `zhongtai` → `sys_permission` 表（type=1为一级菜单，order_num控制排序）

**添加方式：** 无需改前端代码，菜单动态加载。只需在 `sys_permission` 表插入一条记录：

```sql
-- 一级菜单
INSERT INTO sys_permission (id, pid, name, icon, type, order_num, status)
VALUES ('ai_service_root', '0', 'AI服务', 'fa fa-robot', 1, 15, 1);

-- 二级菜单（假设id从上面SQL取）
INSERT INTO sys_permission (id, pid, name, url, icon, type, order_num, status)
VALUES
  ('ai_overview',    'ai_service_root', '概览看板',   '/ai/overview',  'fa fa-dashboard', 2, 1, 1),
  ('ai_model_cfg',   'ai_service_root', '模型配置',   '/ai/model',     'fa fa-cog',       2, 2, 1),
  ('ai_usage',       'ai_service_root', '用量明细',   '/ai/usage',     'fa fa-bar-chart', 2, 3, 1),
  ('ai_api_key',     'ai_service_root', 'API密钥',    '/ai/api-key',   'fa fa-key',       2, 4, 1),
  ('ai_recharge',    'ai_service_root', '充值',       '/ai/recharge',  'fa fa-credit-card', 2, 5, 1);
```

#### 决策六：new.12fz.com升格并行生产站，老站不关（老板确认）

老板确认以下生产策略（2026-06-08）：

- `go.12fz.com` 从测试站升格为**数造企业中台并行生产站**，部分业务先在上面跑
- `new.12fz.com` 作为过渡站，后期停用
- 老生产站(旧ERP `shuzao.12fz.com` + 旧商城 `goxeou.12fz.com`) **一直保留不关**，等数造企业中台完全稳定后再切换
- 新老并行运行期间，部分业务逐步迁移到 `go.12fz.com`
- 切换完成后，老站才关停

| 环境 | 域名 | 用途 | 状态 |
|:-----|:-----|:-----|:-----|
| 🟢 **并行生产** | `go.12fz.com` | 数造企业中台（Go+PG），部分业务先跑 | 🆕 |
| 🔴 **过渡站** | `new.12fz.com` | 原先测试站，后期停用 | 🟡 |
| 🔴 **老生产（保留）** | `shuzao.12fz.com` | 旧ERP (Oracle) | ✅ 一直运行不关 |
| 🔴 **老生产（保留）** | `goxeou.12fz.com` | ThinkPHP商城 | ✅ 一直运行不关 |

### 9.7 数据库设计

#### relay_configs（商户模型配置）

```sql
CREATE TABLE relay_configs (
  tenant_id   TEXT PRIMARY KEY,            -- suzao/kefu 统一账号体系
  relay_id    TEXT DEFAULT 'domestic',     -- domestic | global
  default_model TEXT DEFAULT 'deepseek-v4-flash',
  fallback_model TEXT DEFAULT 'deepseek-v4-flash',
  quota_balance DECIMAL(12,2) DEFAULT 0,  -- 余额（元）
  status      SMALLINT DEFAULT 1,          -- 1=正常 0=禁用
  created_at  TIMESTAMP DEFAULT now(),
  updated_at  TIMESTAMP DEFAULT now()
);
```

#### relay_usage（用量明细）

```sql
CREATE TABLE relay_usage (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     TEXT NOT NULL,
  model         TEXT NOT NULL,
  relay_id      TEXT NOT NULL,              -- domestic / global
  input_tokens  INTEGER NOT NULL DEFAULT 0,
  output_tokens INTEGER NOT NULL DEFAULT 0,
  cost          DECIMAL(10,4) NOT NULL,     -- 扣费金额（元）
  request_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_relay_usage_tenant ON relay_usage(tenant_id, request_at);
```

#### relay_orders（充值订单）

```sql
CREATE TABLE relay_orders (
  id             BIGSERIAL PRIMARY KEY,
  tenant_id      TEXT NOT NULL,
  amount         DECIMAL(10,2) NOT NULL,    -- 充值金额（元）
  tokens_quota   INTEGER,                   -- 赠送额度（可选）
  payment_method TEXT,                      -- 中台账单 / USDT
  status         SMALLINT DEFAULT 0,        -- 0=待支付 1=已支付 -1=退款
  paid_at        TIMESTAMP,
  created_at     TIMESTAMP DEFAULT now()
);
```

#### model_relay_map（模型→中转站路由）

```sql
CREATE TABLE model_relay_map (
  model_name   TEXT PRIMARY KEY,           -- claude-sonnet-4
  relay_id     TEXT NOT NULL,              -- domestic / global
  provider     TEXT NOT NULL,              -- 上游渠道名
  input_price  DECIMAL(8,4) NOT NULL,     -- 成本价（元/M token）
  output_price DECIMAL(8,4) NOT NULL,
  sell_price   DECIMAL(8,4) NOT NULL,     -- 售价（元/M token）
  enabled      BOOLEAN DEFAULT true,
  updated_at   TIMESTAMP DEFAULT now()
);
```

### 9.8 API接口规范

#### 中台 → 中转站（供 one-api 调用）

**`POST /api/relay/auth`** — 认证

```json
// Request
{ "api_key": "sk-xxx", "tenant_id": "suzao/kefu" }
// Response 200
{ "valid": true, "tenant_id": "suzao", "quota_balance": 100.00 }
// Response 403
{ "valid": false, "reason": "insufficient_balance" | "invalid_key" | "disabled" }
```

**`POST /api/relay/charge`** — 扣费

```json
// Request
{ "tenant_id": "suzao", "model": "deepseek-v4-flash",
  "relay_id": "domestic", "input_tokens": 500, "output_tokens": 150, "cost": 0.0008 }
// Response 200
{ "success": true, "balance_remaining": 99.9992 }
// Response 402
{ "success": false, "reason": "insufficient_balance" }
```

**`GET /api/relay/config?tenant_id=xxx`** — 获取商户配置

```json
// Response 200
{ "tenant_id": "suzao", "relay_id": "domestic",
  "default_model": "deepseek-v4-flash",
  "available_models": [
    {"name": "deepseek-v4-flash", "price": 1.0, "relay": "domestic"},
    {"name": "claude-sonnet-4",  "price": 15.0, "relay": "global"}
  ]
}
```

#### 中台后台（商户操作）

**`PUT /api/admin/relay/config`** — 切换默认模型 → 更新 relay_configs → Hermes下次拉配置自动生效

**`GET /api/admin/relay/usage`** — 查看用量

```json
// Response
{ "total_cost": 12.50, "total_input_tokens": 1250000, "total_output_tokens": 350000,
  "by_model": [
    {"model": "deepseek-v4-flash", "cost": 8.20, "calls": 1500},
    {"model": "claude-sonnet-4", "cost": 4.30, "calls": 200}
  ]
}
```

### 9.9 部署规划

| 环境 | 服务器 | 域名 | 技术栈 | 渠道 |
|:-----|:-------|:-----|:-------|:-----|
| **国内中转** | 阿里云 8.138.235.183 | `ai.12fz.com` | one-api(fork), Docker, `/mnt/data/one-api/` | DeepSeek/Qwen/Kimi/GLM + 国外转发渠道 |
| **国外中转** | Vultr日本 167.179.79.44 | `ai-global.12fz.com` | one-api(fork), Docker, `/root/one-api/data/` | Claude/GPT-4o/Gemini |

国外中转的中台API通过公网调国内中转 `https://ai.12fz.com/api/relay`。

### 9.10 U盘产品规格

**U盘目录结构：**

```
USB_ROOT/
├── install.sh                    # 一键安装（Ubuntu/Debian/Rocky）
├── hermes-agent-usb.tar.gz       # Hermes fork + 品牌替换
├── skills/
│   └── ecommerce-customer-service/  # 电商客服技能包
├── config.yaml.template          # base_url=ai.12fz.com/v1，安装时输入API key
├── post-install.sh               # 安装后调 /v1/config 拉配置
└── 说明书.pdf
```

**Hermes二次开发内容：**
- CLI品牌名替换（启动画面、help信息）
- 新增启动插件 relay-config（启动时调 GET /v1/config 初始化模型配置）
- 首屏加激活引导（输入中台API key → 验证 → 保存）

### 9.11 定价建议

| 模型 | 成本（输入/M） | 售价（输入/M） | 毛利率 |
|:-----|:--------------|:--------------|:------|
| DeepSeek V4 Flash | ¥0.5 | ¥1.0 | 50% |
| Qwen Max | ¥0.3 | ¥0.8 | 63% |
| Claude Sonnet 4 | ¥8.0 | ¥15.0 | 47% |
| GPT-4o | ¥6.0 | ¥12.0 | 50% |
| Gemini 2.5 Pro | ¥3.0 | ¥6.0 | 50% |

**U盘定价：** ¥99（含首月¥50试用额度）
**中转月度套餐：** ¥199/50万token / ¥999/300万token / ¥2999/1000万token

### 9.12 实施路线

| 阶段 | 内容 | 时间 | 负责人 |
|:-----|:-----|:-----|:-------|
| **P0** | 中台加四张表 + 三个API接口 | 1天 | 高级工程师 |
| **P0** | one-api fork + 中台认证/扣费插件 | 1天 | gong3 |
| **P1** | 管理后台AI配置页（模型/用量/充值） | 2天 | 高级工程师 |
| **P1** | 国内中转部署（阿里云 one-api） | 半天 | 服务器技术 |
| **P2** | Hermes U盘版打包 | 2天 | gong3 |
| **P2** | 日本中转部署配置 | 半天 | 服务器技术 |
| **P3** | 全链路联调测试 | 1天 | 全部 |
| **合计** | | **约7天** | |

### 9.13 并行开发分工方案

#### 三条独立工作流

```
时间 →  Day1  Day2  Day3  Day4  Day5  Day6  Day7
        ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
gong3   │ one-api fork + 中台插件       │ U盘打包  │
        │    独立，不依赖高级工程师      │           │
        ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
高级工   │ 四张表+API    │ AI配置页+菜单  │ new.12fz
程师    │               │               │ Go骨架   │
        ├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
我      │ 架构协调 + 代码审查 + 交易系统 + 文档维护      │
        └─────┴─────┴─────┴─────┴─────┴─────┴─────┘
                           ↓ 联调
```

#### 工作流A：gong3（中转站 + U盘）

| 天 | 任务 | 产出 | 阻塞条件 |
|:--|:-----|:-----|:---------|
| 1 | fork one-api，分析源码结构，定位认证/扣费拦截点 | 修改方案确认 | 无（独立） |
| 2 | 实现中台认证插件（调 `/api/relay/auth`） | 认证通过 | 中台API接口写好 |
| 3 | 实现扣费插件（调 `/api/relay/charge`） | 扣费写入 | 同上 |
| 4 | 国内中转部署（阿里云）+ 渠道配置 | 国内中转跑通 | 无（独立） |
| 5 | Hermes U盘版打包（品牌替换 + relay-config插件） | U盘可安装 | 中台config接口写好 |
| 6 | 日本中转部署配置 | 双中转跑通 | 无（独立） |
| 7 | 联调测试 | 全链路验证 | 三方完成 |

**依赖：** 第2-3天需要高级工程师的中台API接口，可先用mock模拟，不阻塞

#### 工作流B：高级工程师（PG + 中台后端 + AI管理页）

| 天 | 任务 | 产出 | 阻塞条件 |
|:--|:-----|:-----|:---------|
| 1 | relay_configs/relay_usage/relay_orders/model_relay_map四张表建表 | DDL执行完成 | 无（独立） |
| 2 | 三个API接口：auth/charge/config | API可调通 | 无（独立） |
| 3 | 中台后台AI配置页 - 模型选择 + API密钥管理 | 页面可用 | 无（独立） |
| 4 | 中台后台AI配置页 - 用量看板 + 充值 | 页面可用 | relay_usage有数据 |
| 5 | sys_permission插入AI菜单记录 | 侧边栏出现AI服务 | 无（独立） |
| 6 | go.12fz.com Go后端骨架搭建 | 新站可访问 | 无（独立） |
| 7 | 联调测试 | 全链路验证 | 三方完成 |

**依赖：** 无，全部独立可开发

#### 工作流C：chaogu-ai（架构 + 审查 + 交易 + 文档）

| 任务 | 时间 | 说明 |
|:-----|:-----|:-----|
| 架构兜底 | 每天 | 及时响应方案问题，避免卡住其他人 |
| 代码审查 | 按需 | gong3/高级工程师提交代码后审查 |
| 交易系统 | 可并行 | 数据已恢复到202，继续监控运行 |
| 文档维护 | 持续 | 归档决策、更新文档 |
| 联调主导 | 第7天 | 串起全链路验证 |

#### 并行原则

1. **三条流互不阻塞** — 每人的任务都是独立的，不需要等别人
2. **gong3和高级工程师各做一个端** — gong3改one-api（Go），高级工程改中台（Java/PG），互不抢代码
3. **接口先行，mock先行** — 中台API接口定义好，gong3可以先mock调通，不等人
4. **我兜底** — 架构问题、卡点、代码审查，随时找我

#### 沟通规则

- 每天群里报一次进度（每人一句话：今天完成了什么，明天做什么，有没有卡住）
- 接口变更必须在群里通知（涉及跨工作流依赖）
- 卡住超过2小时不解决 → 群里@我，我来协调
   667|
   668|---
   669|
   670|## 第十部分：聊天系统设计（2026-06-04新增）
   671|
   672|### 10.1 系统定位（老板确认 2026-06-04）
   673|
   674|老板确认：聊天不是独立App，而是**每个业务功能都自带通讯能力**，与各业务板块无缝对接。
   675|
   676|```
   677|    订单详情页                           库存管理页
   678|┌──────────────────────┐       ┌──────────────────────┐
   679|│ 订单号：SZ20240001   │       │ 材料：PU皮黑色       │
   680|│ 客户：张三           │       │ 库存：500米          │
   681|│ 状态：生产中         │       │ 上次进货：2026-06-01 │
   682|│                      │       │                      │
   683|│ ┌──────────────────┐ │       │ ┌──────────────────┐ │
   684|│ │ 💬 联系设计师     │ │       │ │ 💬 通知采购补货   │ │
   685|│ │ 📞 联系工厂      │ │       │ │ 📞 联系供应商    │ │
   686|│ │ 🤖 AI分析进度    │ │       │ │ 🤖 AI预测缺货    │ │
   687|│ └──────────────────┘ │       │ └──────────────────┘ │
   688|└──────────────────────┘       └──────────────────────┘
   689|```
   690|
   691|### 10.2 核心功能（老板确认 2026-06-04）
   692|
   693|| 功能 | 说明 |
   694||:----|:-----|
   695|| 企业内部群聊 | 公司内部员工群组（ERP员工/OA办公/审批通知） |
   696|| 企业外部群聊 | 跨企业群组（设计师+工厂、客服+客户、供应商+采购） |
   697|| 企业内加好友 | 搜企业账号直接加 |
   698|| 企业外加好友 | 搜完整账号或扫企业二维码 |
   699|| **客服系统** | 客户在商城/订单页点"联系客服"，AI初筛→转人工→人工可转接他人 |
   700|| **客服转接** | 客服A→点转接→选目标（客服B/主管/技术）→带对话上下文自动转→客户不用重复说 |
   701|| AI助手 | 每个聊天可@AI，AI自动响应，查订单/库存/生产排期 |
   702|
   703|### 10.3 用户体系（老板确认 2026-06-04）
   704|
   705|| 类型 | 示例 | 说明 |
   706||:----|:-----|:-----|
   707|| 企业主账号 | `suzao` | 公司主账号 |
   708|| 企业子账号 | `suzao/kefu` | 公司下的子账号，**斜杠分隔** |
   709|| 个人用户 | `zhangsan`, `lisi` | 独立设计师、工厂老板等 |
   710|
   711|**企业子账号命名决策（2026-06-04）：** 老板在 `suzao/kefu`（斜杠）和 `suzao_kefu`（下划线）之间选择了**斜杠模式**。原因：路径感强，企业/员工层次清晰，支持多级延伸。
   712|
   713|### 10.4 技术架构方向（老板确认 2026-06-04）
   714|
   715|老板确认以下架构原则：
   716|1. **不同业务不同语言都可以** — 各模块按业务特点选最优语言
   717|2. **数据库统一** — 所有模块共用一个PostgreSQL库
   718|3. **用户体系统一** — 所有模块共用unified_users表
   719|4. **一切以业务和运行效率、未来AI发展来规划** — 技术选型三维评估标准
   720|
   721|### 10.5 覆盖场景
   722|
   723|| 场景 | 通讯双方 | 示例 |
   724||:----|:---------|:-----|
   725|| 企业内部（OA） | 员工之间 | 1对1聊天、部门群组、审批通知推送 |
   726|| 平台交易通讯 | 设计师↔工厂、客服↔客户、供应商↔采购 | 沟通打样、售后问题、订单进度查询 |
   727|| **客服对话** | 客户↔AI初筛→人工客服 | 售前咨询、售后问题、退换货 |
   728|| **客服转接** | 客服A→客服B/主管/技术 | A解决不了→带上下文转给B，客户不重复描述 |
   729|| AI助手 | 所有用户↔AI | 查订单状态、智能尺码推荐、异常预警推送 |
   730|
   731|### 10.6 技术建议方向
   732|
   733|- 技术栈：Go + WebSocket + PostgreSQL
   734|- 聊天消息存PG（和业务数据同库，方便AI查上下文）
   735|- 每个消息都可以@AI助手，AI自动响应
   736|- 第三方平台（飞书/微信）消息汇入统一聊天系统
   737|- 聊天记录 = 业务数据的一部分（设计师和工厂的聊天记录可作为订单佐证）
   738|
   739|### 10.7 AI助手融入方向（老板确认 2026-06-04）
   740|
   741|AI助手以"联系人"形式存在于聊天系统中：
   742|- P0：查数据（订单进度/回款率/库存）
   743|- P0：业务问答
   744|- P1：执行操作（改单加急，需确认）
   745|- P1：群聊辅助（@AI查信息）
   746|- P2：主动推送（异常预警）
   747|- AI每步操作记录审计日志
   748|- 敏感操作必须二次确认
   749|- 数据权限和ERP角色权限一致，AI不能越权
   750|
   751|### 10.8 全量重构方向（老板确认 2026-06-04）
   752|
   753|**全量重构**：新系统不继承老代码，完全重新设计构建。
   754|
   755|| 模块 | 语言 | 理由 |
   756||------|------|------|
   757|| 业务核心（ERP/用户/订单） | Go | 业务效率高、运行效率高、适合AI发展 |
   758|| 聊天系统（WebSocket） | Go | 高并发实时通讯 |
   759|| AI助手（大模型/推荐/分析） | Python | 大模型生态最强 |
   760|| 前端 | Vue/React | 和后台语言无关 |
   761|
   762|**架构原则：**
   763|1. 不同业务不同语言都可以 → 各模块按业务选最优语言
   764|2. 数据库统一 → 一个PG库
   765|3. 用户体系统一 → 共用 unified_users
   766|4. AI只能读数据、通过API执行业务操作，不能直接写业务表
   767|
   768|### 10.9 客服系统详细设计（老板确认 2026-06-04）
   769|
   770|聊天系统作为客服系统使用，支持AI初筛和人工转接。
   771|
   772|**客服流程：**
   773|
   774|```
   775|客户在商城/订单页
   776|   ↓ 点击"联系客服"
   777|AI助手初筛
   778|   ├─ 简单问题 → AI直接回答 ✅
   779|   └─ 复杂问题 → 转人工客服
   780|                     ↓
   781|            客服A接单
   782|             ├─ 能处理 → 解决 ✅
   783|             └─ 不能处理 → 点"转接"
   784|                              ├─ 转客服B（一对一）
   785|                              ├─ 转主管
   786|                              └─ 转技术部门（可多人）
   787|                              ↓
   788|                      带完整上下文自动转交
   789|                      客户不需要重复描述
   790|```
   791|
   792|**转接设计要点：**
   793|1. **转接带上下文** — 对话历史、订单号、客户信息、问题类型，全部自动带过去
   794|2. **转接记录** — 每次转接记录到日志（谁转给谁、原因、时间），可追溯
   795|3. **转接到个人** — 转给指定客服B/主管
   796|4. **转接到客服组** — 转给整个客服组（如技术组、仓储组），组内任意在线客服接单
   797|5. **AI初筛前置** — 客户消息先过AI，AI搞不定再转人工，减少客服压力
   798|6. **客服状态** — 在线/离线/忙碌，只能分配给在线客服
   799|7. **客服分组** — 不同业务线不同客服组（售前组/售后组/技术组/仓储组）
   800|
   801|**与业务页面衔接：**
   802|- 订单详情页 → "联系客服" → 自动带入订单号
   803|- 库存页 → "通知采购" → 自动带入物料信息
   804|- 售后页 → "申请售后" → 创建客服工单
   805|
   806|**技术实现：**
   807|- 客服状态管理和分配逻辑在Go聊天服务中实现
   808|- AI初筛引擎在Python AI层
   809|- 转接记录存PG（chat schema），与聊天记录关联
   810|
   811|### 10.10 Bot群聊优先开发（2026-06-06 老板确认）
   812|
   813|由于飞书体验不佳，老板确认 **聊天系统骨架优先于SSO开发**（B方案）。
   814|
   815|**MVP目标：bot群聊能跑起来，飞书一旦挂掉bot直接转私有聊天系统。**
   816|
   817|| 阶段 | 内容 | 谁做 | 时间 |
   818||:----:|------|:----:|:----:|
   819|| ① WebSocket骨架 | 消息收发 + 连接管理 | gong3 | 2天 |
   820|| ② bot认证 | simple token登录（auth层留接口） | gong3 | 半天 |
   821|| ③ 消息存PG | 存到chat schema | gong3 | 半天 |
   822|| ④ bot接入 | 各bot从飞书切到私有系统 | chaogu-ai | 1天 |
   823|
   824|**MVP功能范围：** ✅ bot群聊（消息收发） ❌ 加好友/1对1聊天（不需要） ❌ 权限管理 ❌ 前端UI
   825|
   826|**核心分层设计（老板确认无需重构的设计）：**
   827|
   828|```
   829|handler/       ← WebSocket连接处理 + 认证（以后换成JWT）
   830|  ├── auth.go       ← 就这里会改，其他不动
   831|  ├── message.go    
   832|  └── group.go      
   833|core/          ← 一次成型不改
   834|  ├── hub.go        ← 连接管理
   835|  ├── message.go    ← 消息路由+存储
   836|  └── group.go      ← 群组管理
   837|model/         ← 数据模型（最终形态）
   838|store/         ← PG存储
   839|```
   840|
   841|**消息层(core)和认证层(auth)分离：** core是最终形态不改，auth留好接口后面替换。重构量预估：后面接SSO约1-2天（换认证中间件 + 配JWT验证），不需推倒重来。
   842|
   843|### 10.11 聊天系统Agent架构方向（老板确认 2026-06-08）
   844|
   845|**背景：** 自建聊天系统（chat.12fz.com/数信）上线后，用户发消息只有chaogu-ai一人回复。经排查，当前3个bot处理器（chat-bot-processor-v6.py、chaogu-chat-processor.py、chat-bridge.py）全部以chaogu-ai身份运行，均使用 `hermes chat -q` + `-t ""`（禁用工具） + `--max-turns 1`（只一轮），实际上是纯文本聊天机器人，非Agent能力。
   846|
   847|**核心方向（老板明确确认 2026-06-08，群聊讨论）：**
   848|
   849|```text
   850|用户发消息 → Go后端(chat.12fz.com WebSocket)
   851|  → 存PG + POST到relay中继(ai.12fz.com:8086)
   852|  → poller抓取 → 各bot的Hermes Agent（完整tools全开）
   853|  → agent处理完写 last-reply.txt
   854|  → submitter检测变化 → POST回relay
   855|  → Go后端从relay拉取bot回复 → WebSocket推给用户
   856|```
   857|
   858|**架构原则：**
   859|1. Go后端只做消息路由，不做AI推理 — 消息通过HTTP转发到Hermes Agent
   860|2. Agent能力由Hermes原生提供 — 保持完整的tools链（代码执行、文件读写、部署能力）
   861|3. 现有Python处理器全部废弃 — 不再用 `hermes chat -q` 子进程方式
   862|
   863|**飞书不受影响：** 飞书Gateway链路不变，relay仅用于聊天系统消息的可视化互通。
   864|
   865|**当前状态（2026-06-08）：** 已修复聊天系统页面Vue模板渲染问题（3个JS语法错误：missing quotes）。架构改造方向已确认，待方案C（每个bot跑Hermes Gateway + 自定义platform）具体实施。
   866|
   867|---
   868|
   869|## 第十一部分：企业中台设计（2026-06-05 新增）
   870|
   871|### 11.1 系统定位
   872|
   873|**企业中台 = 原ERP系统改造，改为通用行业平台（主要服装鞋业）。**
   874|
   875|不是独立App，而是**所有业务能力的统一出口**——控制台以图标+文字形式展示各模块入口，新增业务只需在中台控制台加一个快捷入口。
   876|
   877|### 11.2 控制台入口设计
   878|
   879|```
   880|企业中台控制台主界面
   881|┌─────────────────────────────────────┐
   882|│                                      │
   883|│  🔵 商品管理  🟢 订单管理  🟡 客户   │
   884|│  🟣 库存管理  🟠 供应链   🔴 财务   │
   885|│  💬 聊天系统  🤖 AI助手   ⚙️ 设置   │
   886|│                                      │
   887|│  ➕ 添加快捷入口                      │
   888|└─────────────────────────────────────┘
   889|```
   890|
   891|### 11.2b AI协作面板（2026-06-05 新增）
   892|
   893|企业中台控制台增加「AI协作面板」入口，展示所有bot的实时状态和协作关系。
   894|
   895|**状态标识体系：**
   896|
   897|| 状态 | 图标 | 含义 | 条件 |
   898||:---:|:---:|:-----|:-----|
   899|| 正常工作 | 🟢 | 正在执行任务 | 最近15分钟有工具调用/API活动 |
   900|| 等待协作 | 🟡 | 已完成自己部分，等人接手 | 产出已提交，下游bot未确认 |
   901|| 卡住 | 🔴 | 遇到阻塞 | 30分钟无进展 + 错误日志 |
   902|| 空闲 | ⚪ | 无待办 | 当前无分配任务 |
   903|| 等待中 | ⏳ | 等上游交付/等老板决策 | 依赖条件未满足 |
   904|
   905|**当前12FZ协作看板（示例）：**
   906|
   907|```
   908|┌─────────────────────────────────────────────────────────────────────┐
   909|│ 📋 项目中台设计 Phase 1    进度：35%    协作链：4人1决策            │
   910|├─────────────────────────────────────────────────────────────────────┤
   911|│ 🟢 gong3 ── Go骨架+用户体系 ── 技能: Go开发(99%)     ⏳等待PG连接串│
   912|│ 🟡 服务器技术 ── 基础设施 ── 技能: PG部署(95%)      正在装PG 18    │
   913|│ 🟢 高级工程师 ── 数据迁移 ── 技能: Oracle→PG(98%)  migrate.py 80% │
   914|│ 🟢 chaogu-ai ── 架构+审核 ── 技能: 文档/架构(100%)   v10.0 95%     │
   915|│ ⏳ 老板 ── 决策中心                              待审: v10.0文档   │
   916|│ ─────────────────────────────────────────────────────────────────── │
   917|│ 依赖链: 服务器技术[PG连接串]→gong3[开始开发]                        │
   918|│        高级工程师[迁移]→服务器技术[验证]                           │
   919|│        方案→老板→全员                                               │
   920|│ 🔄 协作转接: A卡住→点转接→带上下文→B接手                          │
   921|└─────────────────────────────────────────────────────────────────────┘
   922|```
   923|
   924|### 11.2c 智能工作流引擎（2026-06-05 新增）
   925|
   926|**核心能力：Bot接手任务时，自动细分步骤 → 评估瓶颈 → 标注现有/缺失技能 → 推荐解决方案（GitHub下载/自己造/转交他人）。**
   927|
   928|#### 标准流程
   929|
   930|```
   931|接手任务
   932|│
   933|▼
   934|① 拆解步骤
   935|│
   936|▼
   937|② 每步列出 → ✅ 现有技能（中央技能库里有什么）
   938|              → ❌ 缺失技能（需要下载或自建什么）
   939|│
   940|▼
   941|③ 缺失技能处理
   942|   ├─ 📦 GitHub找现成的下载
   943|   ├─ 🛠 自己造一个注册到中央技能库
   944|   └─ 🔄 呼叫有对应技能的bot转交
   945|│
   946|▼
   947|④ 下次同类项目 → 中央技能库已补全，直接复用
   948|```
   949|
   950|#### 完整示例：Oracle→PG 数据迁移
   951|
   952|以高级工程师接手的数据迁移任务为例：
   953|
   954|```
   955|┌────────────────────────────────────────────────────────────────────────────────┐
   956|│ 📋 任务：Oracle → PostgreSQL 数据迁移                                         │
   957|│ 负责人：高级工程师                                                             │
   958|├────────────────────────────────────────────────────────────────────────────────┤
   959|│                                                                                 │
   960|│ 步骤① schema迁移                                                               │
   961|│ ├─ 状态：[✅ 完成]                                                             │
   962|│ ├─ 困难/瓶颈：无                                                               │
   963|│ ├─ ✅ 使用技能：schema-diff-tool / auto-ddl-convert / index-migration          │
   964|│ └─ ❌ 缺失技能：-                                                              │
   965|│                                                                                 │
   966|│ 步骤② 数据全量迁移                                                             │
   967|│ ├─ 状态：[✅ 完成]                                                             │
   968|│ ├─ 困难/瓶颈：无                                                               │
   969|│ ├─ ✅ 使用技能：data-bulk-export / data-bulk-import / batch-commit-ctrl        │
   970|│ └─ ❌ 缺失技能：-                                                              │
   971|│                                                                                 │
   972|│ 步骤③ BLOB/大字段迁移 ← ⚠️ 瓶颈                                               │
   973|│ ├─ 状态：[🔴 卡住]                                                             │
   974|│ ├─ 困难：Oracle BLOB转PG BYTEA，中文编码乱码                                  │
   975|│ ├─ ✅ 使用技能：blob-to-bytea / encoding-detect                                │
   976|│ ├─ ❌ 缺失技能：encoding-convert-cn（中文编码转UTF-8，不存在！）               │
   977|│ ├─ 💡 方案：                                                                   │
   978|│ │  ├─ 📦 GitHub下载: oracle-cn-charset-fix.py                                 │
   979|│ │  ├─ 💡 或呼叫: @chaogu-ai 协助中文编码问题                                  │
   980|│ │  └─ 🛠 转为新技能: encoding-convert-cn → 注册到中央技能库                   │
   981|│ └─ 🔄 可转交: 该步骤含编码转换 → 转@chaogu-ai（技能匹配92%）                   │
   982|│                                                                                 │
   983|│ 步骤④ 存储过程/函数迁移 ← ⚠️ 预判瓶颈                                         │
   984|│ ├─ 状态：[⏳ 等待③完成]                                                       │
   985|│ ├─ 困难：PL/SQL → PL/pgSQL语法差异大                                          │
   986|│ ├─ ✅ 使用技能：plsql-parser                                                    │
   987|│ ├─ ❌ 缺失技能：plsql-to-pgsql-conv / pg-function-tester（均不存在）           │
   988|│ ├─ 💡 建议预准备：                                                             │
   989|│ │  ├─ 📦 GitHub下载: plsql2pgsql-converter                                    │
   990|│ │  └─ 🛠 转技能: 入库后注册为中央技能库新技能                                 │
   991|│ └─ 🔄 可转交: 语法转换步骤 → 转@gong3（Go后端擅长API适配，技能匹配78%）        │
   992|│                                                                                 │
   993|│ 步骤⑤ 应用适配（JDBC+MyBatis）                                                │
   994|│ ├─ 状态：[⏳ 等待③④完成]                                                      │
   995|│ ├─ ✅ 使用技能：jdbc-conn-check / mybatis-sql-scanner                           │
   996|│ ├─ ❌ 缺失技能：oracle-pg-sql-conv（Oracle SQL→PG语法转换，不存在）            │
   997|│ ├─ 💡 建议预准备：                                                             │
   998|│ │  └─ 📦 GitHub下载: sql-converter-for-migration                               │
   999|│ └─ 🔄 可转交: SQL适配工作量较大 → 可拆分给@服务器技术（技能匹配85%）            │
  1000|│                                                                                 │
  1001|│ 步骤⑥ 数据校验                                                                 │
  1002|│ ├─ 状态：[⏳ 等待前序]                                                         │
  1003|│ ├─ ✅ 使用技能：row-count-verify / sample-data-compare / hash-verify            │
  1004|│ └─ ❌ 缺失技能：-                                                              │
  1005|│                                                                                 │
  1006|├────────────────────────────────────────────────────────────────────────────────┤
  1007|│ 📊 技能汇总                                                                     │
  1008|│ ├─ ✅ 已使用现有中央技能：10个                                                 │
  1009|│ ├─ ❌ 缺失需补充技能：3个                                                      │
  1010|│ │  ① encoding-convert-cn    ← GitHub下载后入库                                │
  1011|│ │  ② plsql-to-pgsql-conv    ← GitHub下载或自建后入库                          │
  1012|│ │  ③ oracle-pg-sql-conv     ← GitHub下载后入库                                │
  1013|│ └─ 💡 缺失技能处理完后 → 注册到中央技能库 → 下次同类项目直接可用              │
  1014|└────────────────────────────────────────────────────────────────────────────────┘
  1015|```
  1016|
  1017|#### 困难等级标识
  1018|
  1019|| 图标 | 含义 | 自动触发条件 |
  1020||:---:|:-----|:-----------|
  1021|| 🟢 顺利 | 有现成经验和工具链 | 技能库匹配度 > 90% |
  1022|| 🟡 需注意 | 可能有波折 | 技能匹配度 60-90% |
  1023|| 🔴 高风险 | 容易卡住 | 新领域/无先例/技能匹配 < 60% |
  1024|| ⛔ 暂缓 | 前置条件未满足 | 依赖链未完成 |
  1025|
  1026|#### 机制价值
  1027|
  1028|| 使用次数 | 效果 |
  1029||:---:|:-----|
  1030|| **第1次** | 手动拆Oracle→PG为6步，标记BLOB是瓶颈，发现3个缺失技能 |
  1031|| **第2次** | AI直接套用拆解模板，自动识别BLOB风险 + 推荐编码转换工具 |
  1032|| **积累5个模板** | 数据迁移类任务，AI自动配完整方案 + 推荐GitHub工具 |
  1033|| **积累20+模板** | 任何新任务，AI秒出拆解 + 瓶颈预判 + 工具推荐 + 技能补全建议 |
  1034|
  1035|**核心原则：每做一个项目，中央技能库就自动补全一次，越做越顺手。**
  1036|
  1037|---
  1038|
  1039|设计特点：
  1040|- **入口级联** — 图标点进去可能是完整子系统，也可能是单页面功能
  1041|- **权限门控** — 商户能看到哪些图标 = 他买了哪些功能套餐
  1042|- **拖拽自定义** — 商户可调整图标位置
  1043|- **新业务敏捷接入** — 后端写好接口 → 中台注册 → 控制台一键挂图标 → 上线
  1044|- **SaaS模式** — 每个图标对应可售卖的功能模块，商户按需购买
  1045|
  1046|### 11.3 行业模型（老板确认 2026-06-05）
  1047|
  1048|**商户注册时选行业，平台后台审核确认。行业决定差异，其他通用。**
  1049|
  1050|```
  1051|商户注册 → 选择行业（鞋业/服装/通用...）
  1052|  ↓
  1053|平台审核确认行业
  1054|  ↓
  1055|企业中台
  1056|  ├── 行业通用模块（订单/客户/财务/库存/会员）
  1057|  ├── 行业差异模块
  1058|  │   ├── 产品编码规则（不同行业不同）
  1059|  │   └── 供应链流程（不同行业上下游不同）
  1060|  └── 鞋业专用（保留旧系统现有产品管理不动）
  1061|```
  1062|
  1063|### 11.4 AI商品编码（老板确认 2026-06-05）
  1064|
  1065|**不是独立模块，是产品中心升级。商户对话AI → 按行业规则生成商品编码+SKU。**
  1066|
  1067|```
  1068|商户进产品中心 → 点"添加商品" → 两个入口：
  1069|  ├── 手动录入（保留现有方式）
  1070|  └── AI对话生成
  1071|        ↓
  1072|      跟AI说："蓝色纯棉圆领T恤 M码 夏季款"
  1073|        ↓
  1074|      AI → 识别行业（服装）→ 匹配编码规则 → 生成商品编码+SKU
  1075|        ↓
  1076|      商户确认 → 直接入库
  1077|```
  1078|
  1079|| 行业 | 编码规则示例 | AI生成逻辑 |
  1080||:---|:---|---|
  1081|| 鞋业 | X-品类-年份-序号 | 识别"运动鞋"→X-品类代码-YEAR-SEQ |
  1082|| 服装 | CL-品类-季节-尺码-色号 | 识别"T恤/棉/M/蓝"→对应编码段 |
  1083|| 通用 | CAT-年月日-序号 | 未识别行业→通用规则 |
  1084|
  1085|### 11.5 与旧系统关系
  1086|
  1087|- **shuzao.12fz.com（旧ERP）** = 鞋业专用版，**保留不动**
  1088|- **企业中台（新系统，Go）** = 通用版，先做简单通用基础版
  1089|- 老ERP数据迁移到PG（高级工程师负责）
  1090|- 老系统维护期间，功能逐步由中台替换
  1091|
  1092|---
  1093|
  1094|## 第十二部分：三层权限模型（2026-06-05 新增）
  1095|
  1096|### 12.1 模型结构
  1097|
  1098|**平台超级管理员 → 赋予商户权限 → 商户自由分配给子账户**
  1099|
  1100|```
  1101|┌────────────────────────────────────────────────┐
  1102|│           平台超级管理员                         │
  1103|│  ● 创建商户  ● 赋予商户权限范围                   │
  1104|│  ● 审核行业  ● 管理整个平台                       │
  1105|├────────────────────────────────────────────────┤
  1106|│  ↓                                               │
  1107|│  ┌───────────────────────────────────────────┐  │
  1108|│  │  商户A（鞋业）                              │  │
  1109|│  │  拥有权限：订单/商品/库存/店铺/财务           │  │ ← 平台赋予
  1110|│  │  ↓                                         │  │
  1111|│  │  ┌────────┐ ┌────────┐ ┌────────┐         │  │
  1112|│  │  │ 管理员  │ │  客服  │ │  财务  │         │  │ ← 商户分配
  1113|│  │  │ 全权限  │ │订单客服│ │ 仅财务 │         │  │
  1114|│  │  └────────┘ └────────┘ └────────┘         │  │
  1115|│  └───────────────────────────────────────────┘  │
  1116|│                                                  │
  1117|│  ┌───────────────────────────────────────────┐  │
  1118|│  │  商户B（服装）                              │  │
  1119|│  │  拥有权限：订单/商品/库存                    │  │ ← 不同商户权限不同
  1120|│  │  ↓                                         │  │
  1121|│  │  ┌────────┐ ┌────────┐                     │  │
  1122|│  │  │  店长  │ │  客服  │                     │  │
  1123|│  │  │ 全权限 │ │ 仅订单 │                     │  │
  1124|│  │  └────────┘ └────────┘                     │  │
  1125|│  └───────────────────────────────────────────┘  │
  1126|└──────────────────────────────────────────────────┘
  1127|```
  1128|
  1129|### 12.2 与旧系统差异
  1130|
  1131|| | 旧系统（当前） | → | 企业中台（新） |
  1132||---|---|---|---|
  1133|| 权限粒度 | 店铺级（SHOP_ID） | → | 功能级+店铺级+数据级 |
  1134|| 平台层 | 无 | → | 平台超级管理员管控全部商户 |
  1135|| 商户层 | 直接给子账号 | → | 先赋予商户权限包，商户再分给子账号 |
  1136|| 行业约束 | 硬编码 | → | 平台按行业给权限，商户自由分配 |
  1137|
  1138|### 12.3 数据模型
  1139|
  1140|```
  1141|平台层：
  1142|└─ 平台权限表（所有功能权限）
  1143|商户层：
  1144|└─ 商户权限表（MERCHANT_ID + 功能权限 + 行业约束）
  1145|└─ 商户菜单/入口配置（行业不同入口不同）
  1146|子账号层：
  1147|└─ SUB_USER_AUTHOR（MERCHANT_ID + SUB_USER_ID + 权限）
  1148|└─ 和旧系统 SYS_USER_SHOP_AUTHOR 类似，但更细粒度
  1149|```
  1150|
  1151|### 12.4 注册审核流程
  1152|
  1153|1. 商户提交注册信息 + 选择行业
  1154|2. 平台超级管理员审核：确认行业分类、开通权限范围
  1155|3. 审核通过 → 商户获得对应行业的权限包
  1156|4. 商户管理员 → 在其权限范围内自由分配给子账号
  1157|
  1158|---
  1159|
  1160|## 第十三部分：中央技能库设计（2026-06-05 新增）
  1161|
  1162|### 13.1 定位
  1163|
  1164|中央技能库 = **企业中台的核心能力层**，是一个独立服务（Skill Registry）。聊天BOT、AI联系人、ERP后台、自动任务等各入口作为消费方通过API调用，不把技能逻辑写死在各自模块里。
  1165|
  1166|（老板确认 + 全体讨论：服务器技术/邱明 + gong3/邱明 均同意规划进去）
  1167|
  1168|### 13.2 架构
  1169|
  1170|```
  1171|聊天bot ─┐
  1172|AI联系人 ─┤
  1173|ERP后台 ──┼──→ Skill Registry（中央技能注册服务）──→ 订单/库存/用户/客服/商品
  1174|外部API ──┤
  1175|自动任务 ─┘
  1176|```
  1177|
  1178|### 13.3 技能分级加载
  1179|
  1180|```
  1181|中央技能库
  1182|  ├── shared/        ← 所有bot共用（用户查询、知识检索、消息格式）
  1183|  ├── roles/chat/    ← 聊天bot专用技能集（客服流程、转接、自动回复）
  1184|  ├── roles/devops/  ← 仅开发bot加载（服务器、Git、代码审查）
  1185|  └── sensitive/     ← 仅chaogu-ai加载（SSH、API Key、交易）
  1186|```
  1187|
  1188|### 13.4 各bot按角色加载
  1189|
  1190|| bot | 角色 | 加载的技能目录 |
  1191||-----|------|:---|
  1192|| 聊天系统AI联系人 | 客服 | shared/ + roles/chat/ |
  1193|| ERP AI助手 | 业务 | shared/ + roles/biz/ |
  1194|| chaogu-ai（我） | 调度+运维 | shared/ + roles/devops/ + sensitive/ |
  1195|| 服务器技术 | 运维 | shared/ + roles/devops/ |
  1196|| 高级工程师 | 开发 | shared/ + roles/dev/ |
  1197|
  1198|### 13.5 实现思路（老板确认方向，待chaogu-ai出对接方案细化）
  1199|
  1200|1. **Skill Registry 服务** — 每个技能定义触发条件 + 输入输出Schema
  1201|2. **按需拉取** — 各bot声明自己需要的技能分类，拉取对应角色技能
  1202|3. **热加载** — 中央库更新后，各bot自动加载/卸载技能，不重启
  1203|4. **对接Hermes Agent skill体系** — 中央技能库与Hermes的 skill_manage 机制对接
  1204|
  ### 13.6 中央记忆系统设计（2026-06-08 完整技术方案）

  **三层记忆架构（老板确认 2026-06-07）：**

  ```
  ┌──────────────────────────────────────────────────┐
  │ ① 中央记忆（共享） — PG表 + API                  │
  │    存 chat schema，API端点按 /api/memory/* 路由    │
  │    用途：协作流程、不常用特殊知识、决策记录          │
  │    所有bot共享，写入需审核                          │
  ├──────────────────────────────────────────────────┤
  │ ② 本地记忆（个人） — Hermes memory tool           │
  │    每台机器 ~/.hermes/MEMORY.md + memory tool      │
  │    日常读写不经过网络，最快                        │
  │    用途：聊天风格偏好、用户习惯、当前任务状态          │
  ├──────────────────────────────────────────────────┤
  │ ③ 云端备份（灾备）                                │
  │    每天一次 本地→云端 单向推送                     │
  │    机器坏了 → 新机拉备份 → 写本地                  │
  │    只灾备，不参与日常读写                          │
  └──────────────────────────────────────────────────┘
  ```

  #### 13.6.1 数据库设计（chat schema）

  ```sql
  -- 中央记忆主表
  CREATE TABLE central_memory (
      id            BIGSERIAL PRIMARY KEY,
      title         VARCHAR(200) NOT NULL,            -- 记忆标题（索引字段）
      content       TEXT NOT NULL,                     -- 记忆正文
      category      VARCHAR(50) NOT NULL DEFAULT 'general',
                                                      -- 分类：协作流程/决策记录/配置/行为规范
      tags          TEXT[] DEFAULT '{}',               -- 标签数组，支持模糊检索
      source_bot    VARCHAR(50) NOT NULL,              -- 提交bot名称
      status        VARCHAR(20) NOT NULL DEFAULT 'pending',
                                                      -- pending / approved / rejected / archived
      reviewer      VARCHAR(50),                       -- 审核人（仅chaogu-ai）
      review_note   TEXT,                              -- 审核备注/打回原因
      version       INTEGER NOT NULL DEFAULT 1,        -- 版本号，更新时+1
      created_at    TIMESTAMPTZ DEFAULT NOW(),
      updated_at    TIMESTAMPTZ DEFAULT NOW(),
      approved_at   TIMESTAMPTZ                        -- 审核通过时间
  );

  -- 全文检索索引
  CREATE INDEX idx_central_memory_category ON central_memory(category);
  CREATE INDEX idx_central_memory_status ON central_memory(status);
  CREATE INDEX idx_central_memory_tags ON central_memory USING GIN(tags);
  CREATE INDEX idx_central_memory_fts ON central_memory USING GIN(to_tsvector('simple', content));

  -- 记忆版本历史（每次更新保留历史版本）
  CREATE TABLE central_memory_history (
      id            BIGSERIAL PRIMARY KEY,
      memory_id     BIGINT NOT NULL REFERENCES central_memory(id) ON DELETE CASCADE,
      version       INTEGER NOT NULL,
      title         VARCHAR(200) NOT NULL,
      content       TEXT NOT NULL,
      changed_by    VARCHAR(50) NOT NULL,
      changed_at    TIMESTAMPTZ DEFAULT NOW()
  );

  -- bot本地记忆状态跟踪（仅在bot启动时加载一次中央记忆到本地memory tool）
  CREATE TABLE bot_local_memory_sync (
      bot_name      VARCHAR(50) PRIMARY KEY,
      last_sync_at  TIMESTAMPTZ,                       -- 上次同步时间
      last_memory_id BIGINT DEFAULT 0                   -- 已同步到的最新central_memory id
  );
  ```

  #### 13.6.2 API接口设计

  所有端点：HTTP POST/GET，JSON body，与聊天系统同域名（chat.12fz.com）

  **`GET /api/memory/search`** — 搜索中央记忆

  ```
  Query: ?q=关键词&category=协作流程&limit=5
  Response 200:
  {
    "results": [
      {
        "id": 1,
        "title": "发布流程",
        "content": "发布时间窗口：工作日10:00-16:00...",
        "category": "协作流程",
        "tags": ["发布", "部署"],
        "version": 3,
        "updated_at": "2026-06-08T12:00:00Z"
      }
    ],
    "total": 1
  }
  ```

  **`POST /api/memory/pending`** — 提交记忆申请（所有bot可用）

  ```json
  // Request
  {
    "title": "ERP订单取消规则",
    "content": "已支付的订单取消需要先联系客服确认，不可直接删除。原因：涉及财务对账。",
    "category": "行为规范",
    "tags": ["订单", "取消", "客服"]
  }
  // Response 200
  { "id": 42, "status": "pending", "message": "提交成功，待chaogu-ai审核" }
  ```

  **`POST /api/memory/review`** — 审核记忆（仅chaogu-ai）

  ```json
  // Request
  {
    "action": "approve",          // approve | reject
    "id": 42,
    "note": "内容准确，已审核通过"
  }
  // Response 200
  { "status": "approved" }
  ```

  **`PUT /api/memory/{id}`** — 更新现有记忆（仅chaogu-ai）

  ```json
  // Request
  { "title": "ERP订单取消规则（更新版）", "content": "已更新内容...", "tags": [...] }
  // Response 200
  { "id": 42, "version": 2 }
  ```

  **`GET /api/memory/{id}`** — 获取单条记忆详情（含历史版本）

  **`GET /api/memory/pending`** — chaogu-ai查看待审核列表

  #### 13.6.3 与Hermes Agent集成方式

  每个bot通过Hermes tool（memory tool）以HTTP触发读取中央记忆：

  **启动时：**
  1. bot启动 → 调 `GET /api/memory/search?limit=20&status=approved&sort=newest`
  2. 将最新的已审批记忆逐条写入本地 `memory tool`（content="中央记忆：<title>：<content>"）
  3. 在 `bot_local_memory_sync` 表记录 `last_memory_id`

  **运行时：**
  1. bot被纠正/学到新知识 → 调 `POST /api/memory/pending` 提交
  2. chaogu-ai审核 → 通过后所有bot下次启动/手动同步时自动加载
  3. 无需重启bot，下次会话context注入时携带最新中央记忆

  **chaogu-ai特殊流程（审核角色）：**
  - 每天检查 `GET /api/memory/pending`
  - 用内容质量判断标准审核：
    - ✅ 通过：准确、通用、跨bot有用、不重复
    - ❌ 打回：过时、特例、描述模糊、已在本地记忆更好
  - 定期归档过时记忆（status=archived）

  #### 13.6.4 读写权限（老板确认 2026-06-07）

  | 操作 | 权限 | 说明 |
  |:---|:---|:-----|
  | 读取 | ✅ 所有bot不限 | 任意bot可随时查询中央记忆 |
  | 提交 | ✅ 任意bot可提交申请 | 调 `POST /api/memory/pending` 提交 |
  | 审核/写入 | 🔒 仅chaogu-ai | 审核通过后正式写入中央库 |
  | 维护/归档 | 🔒 仅chaogu-ai | 定期维护中央记忆质量 |

  #### 13.6.5 记忆内容分类

  | 分类 | 存哪里 | 示例 |
  |:----|:------|:-----|
  | 协作流程（发布、升级、告警） | 中央 | "生产发布需先备份→通知群→执行→验证→确认" |
  | 决策记录 | 中央 | "2026-06-07 老板确认3层记忆架构" |
  | 行为规范（被纠正的知识） | 中央 | "不要自行同步生产站" |
  | 商户特殊配置 | 中央 | "商户A的退款规则：7天内无理由" |
  | 聊天风格偏好 | 本地 | "用户喜欢简洁回复" |
  | 当前任务状态 | 本地 | "正在开发聊天系统骨架" |

  #### 13.6.6 实施计划（服务器技术负责）

  | 步骤 | 内容 | 预估工时 |
  |:----|:-----|:--------|
  | ① | PG建表：`central_memory` + `central_memory_history` + `bot_local_memory_sync` | 0.5天 |
  | ② | Go后端实现5个API端点（search/pending/review/update/detail） | 1天 |
  | ③ | bot侧封装HTTP tool：各bot通过memory tool调API读取+提交 | 0.5天 |
  | ④ | chaogu-ai审核流程：pending列表→审批→归档维护 | 0.5天 |
  | ⑤ | 云端灾备：cron每天一次 `pg_dump chat.central_memory` → 备份文件 | 0.5天 |
  | 合计 | | **3天** |

  #### 13.6.7 与中央技能库（13.1-13.5）的关系

  ```
  中央技能库（Skill Registry）   ← 技能定义 + 触发条件 + 执行逻辑
         │
         │ 技能运行时需要上下文知识
         ▼
  中央记忆（Central Memory）     ← 共享知识 + 决策记录 + 行为规范
  ```

  - **技能库 = 怎么做**（流程、工具链、API调用方式）
  - **中央记忆 = 为什么这么做**（背景、决策过程、经验教训）
  - 技能集与记忆相互引用：技能描述中可附记忆ID，记忆内容中可标记关联技能
  1251|
---

## 第八部分：变更日志

| 版本 | 日期 | 变更摘要 |
|:----:|:----:|:---------|
| **v10.18** | **2026-06-08** | **13.6节中央记忆系统扩容为完整技术方案——新增数据库设计（3张表+索引）、API接口设计（5个端点+JSON格式）、Hermes Agent集成方式（启动加载+运行时提交+同步机制）、实施计划（3天，服务器技术负责）、与中央技能库关系说明。** |
|| **v10.17** | **2026-06-08** | **Part 9标题改为AI服务业务。所有shuzao/数造智能中台旧名替换为数造企业中台/旧系统。** |
|| **v10.16** | **2026-06-08** | **域名go.12fz.com定稿。命名确认：数造企业中台。new.12fz.com降为过渡站。** |
|| **v10.15** | **2026-06-08** | **新增9.13节并行开发分工方案。** |
|| **v10.14** | **2026-06-08** | **新增9.6决策六：new.12fz.com升格并行生产站，老站不关。** |
|| **v10.13** | **2026-06-08** | **修正9.6决策五：AI作为一级模块加入中台侧边栏。实际菜单结构（通过查询zhongtai.sys_permission表获得）与之前猜测不同——中台共20个一级模块，AI服务(order=15)插在数据中心(14)和系统设置(16)之间。** |
|| **v10.12** | **2026-06-08** | **第9节扩容：U盘产品+双中转架构+中台打通完整技术方案入库。** |
|| **v10.11** | **2026-06-08** | **新增9.6节Token中转站与中台打通决策摘要（已扩容为完整技术方案并入v10.12）** |
| **v10.10** | **2026-06-08** | **新增3.8节聊天系统近期UI需求——老板提出①快捷@改为带冒号格式（`@botName:内容`）；②自己消息气泡右上方显示发送者名称；③未读消息刷新后错误提示bug。前两项已由chaogu-ai实施上线，第③项排查中。** |
|| **v10.9** | **2026-06-08** | **新增10.11节聊天系统Agent架构方向——老板确认Go后端只做消息路由，消息通过HTTP转发到Hermes Agent，Agent完整tools链处理后回写聊天系统。当前Python处理器（`hermes chat -q` + `-t ""`）全部废弃，方案C（每个bot跑Hermes Gateway + 自定义platform）待实施。已修复聊天系统Vue模板渲染问题（3个JS语法错误）。** |
  1259|||| **v10.7** | **2026-06-08** | **新增3.7节HEARTBEAT_OK取消 + Bot在线状态红绿灯——老板明确要求HEARTBEAT_OK不再发群消息，改为bot名字后红绿灯（🟢/🔴）显示在线状态。bot侧每60秒POST心跳，后端新建状态表+两个API，超时>180秒标记离线。chaogu-ai负责bot侧改动，gong3负责后端API和前端渲染。** |
  1260||| **v10.6** | **2026-06-07** | **新增13.6节中央记忆/中央技能管理规则——老板确认三层记忆架构（中央共享+本地高频+云端灾备）及读写权限规则：中央记忆由chaogu-ai维护（写入需审核），其他bot可提交申请，读取不限制。详见13.6节。** |
  1261|||| **v10.5** | **2026-06-07** | **新增7.3节Bot处理器代码统一管理方案——老板确认使用GitHub→旧阿里云mirror（30min同步）→各机器内网拉取（5min检查）的分发架构。核心原则：数据始终放在聊天系统仓库，处理器仓库只含代码不含数据，接口是两者边界。** |
  1262||| **v10.4** | **2026-06-06** | **新增3.6节聊天系统近期UI需求：老板确认bot显示名中文化——chao1→服务器技术、serv01→高级工程师（已在DB修正，bridge以中文名运行）。老板@gong3要求聊天框中发送者名称背景改为白色（待执行）。** |
  1263|||| **v10.3** | **2026-06-06** | **新增域名策略：chat.12fz.com=聊天系统 / new.12fz.com=新版企业中台测试站。聊天界面风格确认——改为纯聊天界面，参考老ERP `/index/vmain/main` 页面布局。chat.12fz.com HTTPS上线，Nginx反向代理 `/api/` → Go后端:8081。** |
  1264||| **v10.2** | **2026-06-06** | **老板确认gong3负责聊天系统网页版前端——在群聊中明确回复"@gong3 做前端"。gong3同时负责聊天系统Go后端+网页版前端，前端UI参考老ERP Java聊天界面布局，用新框架重写。统一前端（Vue/React）仍为"待定"，不含聊天前端。** |
  1265||| **v10.1** | **2026-06-06** | **老板确认开发优先级变更：聊天系统骨架 > SSO用户系统。① B方案确认——因飞书体验不佳，gong3先搭聊天系统骨架（WebSocket + simple token + PG存储 + 基础群聊，Mon-Wed），SSO延后（Thu-Sun）。② 架构分层确认——core/auth层分离设计：core一次定型不改，auth留接口后面替换JWT/SSO，重构量~1-2天。③ bot迁移启动——chaogu-ai并行准备bot从飞书接入私有聊天系统。** |
  1266||| **v10.0** | **2026-06-05** | **三大设计决策入库：① 企业中台设计——ERP改造成通用行业平台，控制台图标+文字入口 + AI协作面板（🟢🟡🔴⚪⏳状态标识） + 智能工作流引擎（拆解步骤→标记现有✅/缺失❌技能→GitHub下载→注册中央技能库）。② 三层权限模型——平台超管→商户→子账号。③ 中央技能库设计——Skill Registry，按角色分级加载。** |
  1267|| **v9.2** | **2026-06-05** | **新增 code-review-graph 代码依赖图工具：老板确认全团队采用 code-review-graph 作为标准代码审核工具。全员安装（Vultr/101/202/旧阿里云），每人对自己管的项目建依赖图并配置MCP。开发流程3.3节补充：代码审核前先查依赖影响半径，避免"改一坏三"。（老板确认 2026-06-05）** |
  1268|| **v9.1** | **2026-06-04** | **聊天系统补充客服设计：新增客服系统支持AI初筛→人工→转接，转接带上下文、支持转个人和转客服组、客服分组管理、客服状态管理。完整客服流程已记录到10.9节。** |
  1269|| **v9.0** | **2026-06-04** | **聊天系统设计部分（Part 10）：老板确认多项架构决策——「不同业务不同语言都可以，数据库统一，用户体系统一」架构原则；「一切以业务和运行效率、未来AI发展来规划」三维评估标准；聊天不是独立App，是每个业务功能自带通讯能力，与各板块无缝对接；支持企业内部/外部群聊、内/外加好友、AI助手；企业子账号命名采用 `suzao/kefu` 斜杠模式。（老板确认 2026-06-04）** |
  1270|| **v8.6** | **2026-06-04** | **老板确认分模块开发暂缓：老板提出"分板块开发"想法，讨论后确认先等高级工程师完成当前任务（Oracle→PG迁移+Java ERP适配）再议分板块方案。当前保持现有按技术栈分工结构不变。** |
  1271|| **v8.5** | **2026-06-03** | **新增Token12 API中转业务：部署one-api + token.12fz.com上线，对接DeepSeek/通义千问/月之暗面渠道，中英双语落地页+USDT收款+4x定价倍率。统一账号 token12fz / T12fz123456 / qiuming@12fz.com。中英双线运营。（老板确认：中国模型卖老外+USDT收款$10起+统一账号+中英双线）** |
  1272|| **v8.4** | **2026-06-02** | **全面重构：集成三份开发文档提纲（服务器技术/gong3/chaogu-ai），新增统一认证体系设计，新增技术规范红线，新增开发路线图4个Phase，更新团队分工矩阵，更新基础设施清单。数据库策略定稿：PG统一主库，MySQL仅存量，Oracle迁后下线。项目方向：12FZ从WordPress全面重写。（老板确认：PG主库+统一登录+重写方向）** |
  1273|| **v8.3** | **2026-06-02** | **新增Windows源码迁移计划附录C：列出Windows机器全部源码结构（VB.NET客户端+Java Spring Boot+Laravel+ThinkPHP+Android app），制定4阶段迁移路径。新增Oracle→PG SQL语法对照表。新增统一认证接口定义（OAuthProvider接口+核心数据模型）。** |
  1274|| **v8.2** | **2026-06-02** | **新增部署红线：15天静默期（起2026-06-02）不考虑生产站，等老板通知再同步生产。（老板确认）** |
  1275|| v7.4 | 2026-06-02 | 新增数据库总体架构策略 |
  1276|| v7.3 | 2026-06-01 | Oracle→PG双库并行策略 |
  1277|| v7.2 | 2026-06-01 | 确定PostgreSQL，技术栈更新 |
  1278|| ... | ... | ... |