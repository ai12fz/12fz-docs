# 12FZ Marketplace 开发文档 v3.36

> AI原生 · 业务全Go · 日均10万单 · 2026-08-13（v3.36 08-15：合并用户体系规则 v1.6）

---

## 零、v3.34 → v3.36 变化

| 模块 | v3.34 状态 | v3.36 状态 |
|------|:--:|:--:|
| 系统全景/两域关系 | 域名分工简表 | ✅ 明确 ai/go 关系（登录链路/商户贯穿/设备贯穿），合并用户体系规则 v1.6 |
| 计费价格 | v4-flash 3.36× / v4-pro 3.13× | ✅ 修正为官方×2（08-15），高峰×2 规则不变 |
| RLS 计费故障 | AfterConnect+AfterRelease | ✅ 08-15 修复 402（补 RLS 默认 admin 后实际验证） |
| 主机/设备 org 归属 | — | ✅ 规则 8/8.5：注册码唯一权威 + 审计触发器 + 每日漂移检测 |
| 商户数据隔离 | 规范 v2.1 + 三层防线 + 三层防御 | ✅ 同左（v3.34 已落地，08-15 验证隔离 8/12 正常） |

---

## 一、域名分工

| 域名 | 用途 |
|---|---|
| **go.12fz.com** | 业务 API + SPA 前端（Nginx → Go底座 8099） |
| **ai.12fz.com** | 聊天 WebSocket + 主机/Agent 心跳 |
| **ai.12fz.com/v1** | 大模型中转（OpenAI兼容API） |

> **两域关系（v3.36 明确，详见《12FZ 用户体系统一规则 v1.6》）**：go.12fz.com 是唯一登录入口（签发统一 JWT）→ ai.12fz.com 本地验签；商户在 go 开账户/充值/下单，在 ai 用 `sh-` key 消费模型，账本/余额同一 org 名下；设备用 `zc-` 注册码贯穿两域（归属规则 8）。

---

## 二、部署架构

```
go.12fz.com (8.138.235.183)
├─ Nginx
│ ├─ / → /opt/marketplace/web-dist/ (SPA)
│ ├─ /api/* + /sys/* → 127.0.0.1:8099 (Go底座)
│ └─ /git/* → 127.0.0.1:3000 (Gitea)

Go底座 8099 (cmd/marketplace/main.go)
├─ 40+ 个 internal 模块
├─ PostgreSQL 主库 (12fzsj)
├─ Redis 7 ✅ 实装
│ ├─ internal/cache 产品/价格/店铺/菜单热数据缓存
│ └─ internal/mq Redis Streams 异步任务
├─ 限流 令牌桶 10000/s ✅
└─ CI: push main → Gitea Actions → 自动部署

ai.12fz.com :8081 (chat-token，独立仓库 qiu/ai-chat)
├─ /ws WebSocket（gorilla/websocket）
├─ 好友系统已重构（三表拆分）
├─ Hub 连接管理 + 心跳 + 离线检测
└─ chat.devices（主机）/ chat.agents / chat.contacts
```

### 当前 key 前缀一览（最新，旧 key 已清理）

| Key 类型 | 前缀 |
|---------|------|
| 中转站商户 key | `sh-` |
| Agent token / api_key | `st-` |
| 设备密钥 | `fz-` |
| 设备 ID | `d_` |
| 注册码 | `zc-` |

> v3.34 起：proxy_keys 表仅保留 `sh-` 前缀的 active key（旧 chat-token-/sk-/MYCLEARKEY-/sk-dev- 等已全部清理）。三台设备（101、biancheng、qiuming）已切换新 key。

---

## 三、安全与数据隔离 ✅（v3.34 新增）

### 3.1 商户数据隔离规范 v2.1

> 背景：商户隔离是**三个维度**的，漏任一维即越权。v2.0 只做了 tenant_id（订单接口），v2.1 补齐 industry_code（行业授权）+ menu_ids（菜单授权）。曾因只做 tenant_id 漏 industry_code，导致商户看到全部 15 个行业。

**三维度清单（缺一不可）**

| 维度 | 来源/字段 | 规则 |
|------|----------|------|
| ① tenant_id | 数据行 tenant_id 字段 | NULL=平台共享；商户UUID=私有；admin=全零UUID |
| ② industry_code | `org_merchant.industry_code` | 商户行业授权，列表/下拉类接口必须按此过滤 |
| ③ menu_ids | `platform_merchant_types.menu_ids` + `org_user.allowed_menus` | 菜单/功能授权 |

**四条铁律（tenant_id 维度）**

1. **tenant_id 只信服务端解析**：`Authorization: Bearer session-<uid>` → 查 `org_user` 表得权威 tenant_id；禁止信任 `X-Org-ID`/`X-Role`/`X-User-ID` header、query、body。
2. **fail-closed**：解析不到 tenant_id 返回 401，绝不放行全量。
3. **读写全覆盖**：列表/单条查询强制 `AND tenant_id`；写操作 Create 用 context 的 tenant_id，Update/Cancel 先校验归属。
4. **admin 豁免**：`super_admin` 或零 UUID 超管可看全平台。

**三层防线（防错机制：规范 + 工具 + 测试）**

| 层 | 机制 | 状态 |
|----|------|------|
| 规范层 | 三维度清单 + 接口检查清单（本文档）| ✅ |
| 工具层 | `middleware.ScopeFrom(ctx,pool)` 统一取三维度 + `middleware.IsAdmin`/`AdminOrgID` | ✅ |
| 测试层 | `scripts/test-merchant-isolation.sh` 隔离验证脚本 | ✅ 5/5 通过 |

**接口开发检查清单**（改任何查询/列表/写接口前逐项过）

- [ ] 这个接口的数据要不要按商户过滤？
- [ ] 三个维度都查了吗？（tenant_id + industry_code + menu_ids）
- [ ] tenant_id 从服务端 session 解析（`middleware.RequireOrg` fail-closed），不信任客户端传参？
- [ ] admin 正确豁免（`middleware.IsAdmin` 判全零 UUID）？
- [ ] 测试覆盖：≥2 商户交叉验证 + 1 受限商户（单行业）？

**三层防御（技术分层）**

| 层 | 机制 | 状态 |
|----|------|------|
| L1 中间件 | `middleware.RequireOrg()`（session→查库→注入 context，fail-closed）| ✅ |
| L2 handler | 三维度过滤：`ScopeFrom` + 列表强制 `AND tenant_id`/`industry_code` | ✅ |
| L3 数据库 | 核心表开 RLS（41 个 platform_ 表启用+FORCE，撤销 app_zhongtai BYPASSRLS，AfterConnect+AfterRelease 默认 admin + Scoped 事务级覆盖）| ✅ 41 表已启用 |

**本次已改文件**：
- tenant_id 维度（commit 3b94bee）：`internal/order/handler.go`、`internal/mall/handler.go`、`internal/cashier/handler.go`、`internal/middleware/middleware.go`。验证：不带 X-Org-ID → 401。
- 工具层 + 行业授权 + fail-closed（commit 400a457）：`internal/middleware/scope.go`（ScopeFrom/IsAdmin/AdminOrgID）、`internal/product/handler.go`（ListCategories 未登录 401、ListIndustries 按 industry_code 过滤）、`scripts/test-merchant-isolation.sh`。验证：5/5 通过。
- L3 数据库 RLS（commit 1d2aa2e + ef380cc）：`migrations/043_enable_rls.sql`（分类表）、`044_batch_rls.sql`（批量 41 表）、`045_force_rls.sql`（FORCE，让 owner 也受约束）、`046_no_bypassrls.sql`（撤销应用用户 BYPASSRLS）、`internal/db/pools.go`+`postgres.go`（AfterConnect 默认 admin + Scoped 事务级 set_config）。验证：订单表未设置/suzao 看不到 qiuming 订单，qiuming 自己能看到。
- AfterRelease 兜底（commit 2a44f87 marketplace + 6ab87c9 chat-token）：连接归还时重新 SET admin，防止 pgx 连接被 reset 清掉 SET 后误过滤。chat-token（独立代码库 /root/12fzwebsocket）补上 AfterConnect+AfterRelease，修复 RLS 导致的 402。

### 3.2 中转站计费防护（migration_v4.sql）

> chat-token 计费数据安全：防止删除 api key / 金额时连带丢失计费归属。

| 防护 | 机制 |
|------|------|
| 外键 | `proxy_usage.key_id` `ON DELETE SET NULL` → `RESTRICT` |
| proxy_keys 触发器 | 禁止物理删除，只能软删除 `status=revoked` |
| finance_ledger 触发器 | 禁止删除金额记录 |

> RLS 已落地（见 3.1 节 L3）：41 个 platform_ 表已启用 RLS。chat-token 中转计费连接已加 AfterConnect+AfterRelease 默认 admin，避免 RLS 误过滤导致 402。

### 3.3 主机/设备 org 归属（v3.36 新增·规则 8/8.5）

> 曾因按主机名/IP 推断归属导致误改（qiuming/gungzhou 被误判为 M_QIU 测试商户）。归属是数据决策，**禁止推断**。

1. **新设备唯一合法途径**：生成注册码（`zc-`，强制 tenant_id，空 org 直接 400）→ `RegisterDevice` 兑换 `host_reg_codes.tenant_id` 写入 `hosts.tenant_id`
2. **存量设备**：注册码机制前注册的主机一律 `00000000-...`（ADMIN 平台），禁止按名字/IP 推断
3. **改归属**：先查注册来源（host_reg_codes/创建时间/生成人），来源不明先问平台主；**禁止直接连库 UPDATE org 字段**
4. **审计**：所有 org 变更自动记录（角色/IP/application_name/时间/旧值→新值，表 `chat.org_change_audit`）
5. **漂移检测**：每日核对「注册码 org vs 主机 org vs key org」，不一致即告警（`/root/scripts/check_org_drift.sh`）

### 3.4 计费价格修正（v3.36·08-15）

| 模型 | 修正前（中转价） | 修正后（官方×2） |
|---|---|---|
| deepseek-v4-flash 输入/输出 | 0.002016 / 0.004032（3.36×） | **0.0012 / 0.0024（2×）** |
| deepseek-v4-pro 输入/输出 | 0.006264 / 0.012528（3.13×） | **0.004 / 0.008（2×）** |

- 高峰时段（北京 9-12/14-18 点）×2，平时=官方×2（pricing_multiplier=2、pricing_peak_multiplier=2）
- 补的历史数据（id>78077）cost 已按修正价重算

### 3.5 RLS 计费故障记录（08-15）

- 现象：RLS 启用后 chat-token（app_zhongtai 连接未设 tenant_id）查账本被过滤 → 余额 0 → **全员 402**
- 修复：chat-token 补 AfterConnect+AfterRelease 默认 admin（commit 6ab87c9）→ 平台计费正常、商户隔离保留（验证：平台 12 单/商户 8 单）
- 教训：启用 RLS 必须同步给所有应用连接补 AfterConnect（admin 默认 + 商户 Scoped 覆盖）

---

## 四、项目结构

```
marketplace/
├── cmd/
│ ├── marketplace/main.go 主入口
│ └── one-agent/main.go 时枢One Agent 客户端
│
├── internal/ 40+ 个业务模块
│ ├── router/router.go 327+ 条路由
│ ├── product/ 产品中心
│ ├── order/ 订单
│ ├── finance/ 财务
│ ├── warehouse/ 仓储
│ ├── cashier/ 收银
│ ├── mall/ 商城
│ ├── store/ 店铺
│ ├── skills/ 技能商城
│ ├── swarm/ Agent蜂群
│ ├── production/ 生产引擎
│ ├── supply/ 采购/供应链
│ ├── label/ 标签打印
│ ├── device/ IoT设备
│ │ └── ota/ 固件/OTA管理
│ ├── personnel/ 人事档案+工资
│ ├── cache/ Redis缓存
│ ├── mq/ Redis Streams MQ
│ ├── chat/ 聊天
│ └── ...
│
├── web/ Vue3 前端
├── ddl/ 迁移脚本
└── packages/ui/ @12fz/ui 19个共享组件
```

---

## 五、OA 人事模块 ✅

### 5.1 菜单结构

```
OA 办公
├── 员工档案 /oa/personnel/dossier
├── 技艺管理 /oa/personnel/workmanship
├── 人事分类 /oa/classify/index
├── 请假管理 /oa/personnel/leave
├── 出差管理 /oa/personnel/travel
└── 工资管理 /oa/personnel/salary
```

### 5.2 功能完成度

| 功能 | 状态 |
|------|:--:|
| 员工 CRUD + 照片上传 + 离职办理 | ✅ |
| 请假/出差申请审批 | ✅ |
| 黑名单管理 | ✅ |
| 月薪工资单 + 计件工资（联动生产引擎）| ✅ |
| 工资→财务 ledger + 计件明细穿透 | ✅ |

### 5.3 数据库表

`org_personnel` `org_leave_record` `org_travel_record` `org_blacklist_log` `org_salary_record`（工资写入 `platform_finance_ledger`，查询 `platform_process_record`）。

---

## 六、物联网 + 时枢One ✅

- 统一设备类型表 `platform_device_category`：边缘节点、扫码枪、电子秤、标签打印机、工位平板、传感器、智能锁。
- 时枢One：`cmd/one-agent/main.go`（Agent客户端）+ `internal/device/ota/`（固件管理）+ 前端 3 页。
- 与 chat-token 关系：时枢One 管物理设备（go.12fz.com），chat-token 管 Agent 宿主机（电脑），两套独立设备体系。

---

## 七、chat-token 好友表重构 ✅

> 独立仓库 `qiu/ai-chat`

```
chat.contacts       (uid, contact_id)  — 人↔人
chat.user_agents    (uid, agent_id)    — 人↔Agent，FK 约束
chat.user_devices   (uid, device_id)   — 人↔主机，FK 约束
```

- `migration_v3.sql`：新建 3 表 + 数据迁移 + 兼容视图
- 计费防护见 3.2 节（migration_v4.sql）

---

## 八、基础设施 ✅

| 模块 | 文件 | 说明 |
|:--|------|------|
| Redis 缓存 | `internal/cache/cache.go` | GetJSON/SetJSON/GetOrSet |
| Redis MQ | `internal/mq/mq.go` | Publish/Subscribe，预定义 order_events/salary_batch/notify |
| 限流 | `internal/middleware/ratelimit.go` | 令牌桶 10000/s burst=20000 |
| 数据库连接 | `internal/db/postgres.go` | 单池 `db.Connect`（含 AfterConnect+AfterRelease 默认 admin）；`ConnectRW` 双池读写分离已废弃未启用 |

---

## 九、技术栈

| 层 | 技术 |
|---|---|
| 后端 | Go + pgx + PostgreSQL (JSONB) |
| 缓存 | Redis 7 |
| MQ | Redis Streams |
| 前端 | Vue 3.5 + TypeScript + Element Plus + Vite |
| 组件库 | @12fz/ui (19 个) |
| CI/CD | Gitea Actions |

---

## 十、数据库核心表

```
platform_products        产品中心
platform_product_prices  7层价格
platform_orders          订单
platform_payment         收银
platform_process_record  工序记录
platform_finance_ledger  财务账本
platform_firmware        固件
platform_device_category 设备类型
org_personnel            员工档案
org_salary_record        工资单
org_leave_record         请假
org_travel_record        出差
org_blacklist_log        黑名单
```

---

## 十一、版本记录

| 版本 | 日期 | 内容 |
|---|------|------|
| **v3.36** | 08-15 | 明确两域关系（合并用户体系规则 v1.6）+ 计费价格修正（v4-flash/pro 官方×2）+ 主机归属规则 8/8.5（审计+漂移检测）+ RLS 402 故障修复记录 |
| **v3.34** | 08-13 | 商户数据隔离规范 v2.1（三维度：tenant_id+行业+菜单）+ 三层防线（规范+工具+测试）+ 三层防御 L1/L2/L3（41表 RLS）+ 订单接口 tenant_id + 行业授权过滤 + 中转站计费防护 + 旧 key 清理 |
| v3.33 | 08-02 | OA人事+工资+时枢One+chat-token重构+统一设备类型+基础设施实装 |
| v3.32 | 08-02 | 日均10万单架构升级设计 |
| v3.31 | 08-02 | 全量实测修正 |

---

*文档版本 v3.36 · 2026-08-15*
