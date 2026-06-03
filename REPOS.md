# 12FZ 仓库结构

| 仓库 | 说明 | 负责人 | 状态 |
|------|------|--------|------|
| 12fz-docs | 开发文档/架构设计/会议记录 | chaogu-ai | ✅ v9.2 |
| 12fz-sso | 统一用户认证（Go） | gong3 | 🔧 Phase 1 |
| 12fz-chat | 聊天系统（Go WebSocket） | gong3 | 🔧 Phase 2 |
| 12fz-ai | AI服务层（Python） | chaogu-ai | 🔧 Phase 2 |
| 12fz-erp | ERP核心业务（数据迁移） | 高级工程师 | 🔧 Phase 1 |
| 12fz-infra | 基础设施（Docker/CI/CD） | 服务器技术 | 🔧 Phase 1 |

## 当前任务 — Phase 1（并行）

| 人员 | 仓库 | 任务 |
|------|------|------|
| **gong3** | 12fz-sso | Go项目骨架 + 统一用户系统 + JWT认证 |
| **服务器技术** | 12fz-infra | 202部署PG18+3Schema+Docker Compose |
| **高级工程师** | 12fz-erp | 清理重复URL + Oracle→PG数据迁移 |
| **chaogu-ai** | 12fz-ai | AI服务骨架 + 文档维护 + 代码审核 |
