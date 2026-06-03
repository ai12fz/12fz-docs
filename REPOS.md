# 12FZ 仓库结构

| 仓库 | 说明 | 负责人 | 状态 |
|------|------|--------|------|
| 12fz-docs | 开发文档/架构设计/会议记录 | chaogu-ai | ✅ v9.2 |
| 12fz-sso | 统一用户认证（Go） | gong3 | 🔧 Phase 1 |
| 12fz-chat | 聊天系统（Go WebSocket） | gong3 | 🔧 Phase 2 |
| 12fz-ai | AI服务层（Python） | chaogu-ai | 🔧 Phase 2 |
| 12fz-erp | ERP核心业务（数据迁移） | 高级工程师 | 🔧 Phase 1 |
| 12fz-infra | 基础设施（Docker/CI/CD） | 服务器技术 | 🔧 Phase 1 |

## Phase 1 并行任务

| 人员 | 仓库 | 任务 |
|------|------|------|
| **gong3** | 12fz-sso | Go骨架 + 用户系统 + JWT |
| **服务器技术** | 12fz-infra | PG18部署 + 3Schema + Docker |
| **高级工程师** | 12fz-erp | 清重复URL + 数据迁移 |
| **chaogu-ai** | 12fz-ai | AI骨架 + 审核 + 协调 |

## 2026-06-04 Bot修复记录
- 服务器技术：Gateway僵尸进程→kill重启 ✅
- gong3：补SOUL.md + approvals auto + tirith off ✅
- 高级工程师：approvals manual→auto ✅
- 监控cron每30min自查 ✅
