-- ═══════════════════════════════════════════════════════════════
-- 12FZ IAM 身份域重构 · 001-iam-schema.sql
-- 建 iam schema 全套表 + RBAC 种子数据
-- 目标库: 12fzsj (PostgreSQL 15+)
-- 执行: psql -U app_zhongtai -d 12fzsj -f 001-iam-schema.sql
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────
-- 0. 建 schema
-- ─────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS iam;

-- ─────────────────────────────────────────────
-- 1. users —— 用户主表（uid 继承 org_user.user_id）
-- ─────────────────────────────────────────────
CREATE TABLE iam.users (
    uid         BIGSERIAL PRIMARY KEY,
    username    TEXT UNIQUE,                   -- 实体别名（bot:/host: 前缀唯一；人可空）
    nickname    TEXT,
    avatar      TEXT,
    phone       TEXT,                          -- 冗余展示用，权威在 accounts
    email       TEXT,                          -- 冗余展示用，权威在 accounts
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ
);

COMMENT ON TABLE iam.users IS '用户主表：uid 全局唯一，值继承 org_user.user_id（1=admin 等）';

-- ─────────────────────────────────────────────
-- 2. accounts —— 登录账号（一用户多登录方式）
-- ─────────────────────────────────────────────
CREATE TABLE iam.accounts (
    id          BIGSERIAL PRIMARY KEY,
    uid         BIGINT NOT NULL REFERENCES iam.users(uid),
    login_type  TEXT NOT NULL CHECK (login_type IN ('password','phone','email','wechat','oauth')),
    identifier  TEXT NOT NULL,                 -- 手机号/邮箱/openid/用户名
    secret_hash TEXT,                          -- bcrypt 密码哈希（wechat 空）
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (login_type, identifier)
);

CREATE INDEX idx_accounts_uid ON iam.accounts(uid);

-- ─────────────────────────────────────────────
-- 3. tenants —— 租户/组织（商户=type merchant）
-- ─────────────────────────────────────────────
CREATE TABLE iam.tenants (
    tenant_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT NOT NULL,
    type          TEXT NOT NULL CHECK (type IN ('platform','merchant','company')),
    code          TEXT,                          -- 商户编码（继承 org_merchant.merchant_code）
    phone         TEXT,
    email         TEXT,
    credit_code   TEXT,                          -- 统一社会信用代码
    contact_name  TEXT,
    address       TEXT,
    industry_code TEXT DEFAULT 'clothing',
    owner_uid     BIGINT REFERENCES iam.users(uid),  -- 商户 owner
    status        TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at    TIMESTAMPTZ,
    UNIQUE (code)
);

COMMENT ON TABLE iam.tenants IS '租户：平台/商户/公司统一模型；平台=00000000-0000-0000-0000-000000000000';

-- ─────────────────────────────────────────────
-- 4. roles —— 角色（标准 RBAC）
-- ─────────────────────────────────────────────
CREATE TABLE iam.roles (
    role_id     BIGSERIAL PRIMARY KEY,
    code        TEXT NOT NULL UNIQUE CHECK (code IN ('super_admin','merchant_admin','staff')),
    name        TEXT NOT NULL,
    is_system   BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 5. permissions —— 权限点
-- ─────────────────────────────────────────────
CREATE TABLE iam.permissions (
    perm_id     BIGSERIAL PRIMARY KEY,
    code        TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────
-- 6. role_permissions —— 角色权限关联
-- ─────────────────────────────────────────────
CREATE TABLE iam.role_permissions (
    role_id     BIGINT NOT NULL REFERENCES iam.roles(role_id) ON DELETE CASCADE,
    perm_id     BIGINT NOT NULL REFERENCES iam.permissions(perm_id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, perm_id)
);

-- ─────────────────────────────────────────────
-- 7. user_tenants —— 用户-租户关系（RBAC 挂点）
-- ─────────────────────────────────────────────
CREATE TABLE iam.user_tenants (
    id          BIGSERIAL PRIMARY KEY,
    uid         BIGINT NOT NULL REFERENCES iam.users(uid),
    tenant_id   UUID NOT NULL REFERENCES iam.tenants(tenant_id),
    role_id     BIGINT NOT NULL REFERENCES iam.roles(role_id),
    is_default  BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (uid, tenant_id)
);

CREATE INDEX idx_user_tenants_tenant ON iam.user_tenants(tenant_id);

-- ─────────────────────────────────────────────
-- 8. audit_log —— 通用审计表（org_change_audit 并入）
-- ─────────────────────────────────────────────
CREATE TABLE iam.audit_log (
    id          BIGSERIAL PRIMARY KEY,
    tbl         TEXT NOT NULL,
    row_id      TEXT NOT NULL,
    action      TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE','LOGIN','LOGOUT','GRANT','REVOKE')),
    old_val     JSONB,
    new_val     JSONB,
    actor_uid   BIGINT,
    actor_ip    INET,
    app_name    TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_log_tbl_row ON iam.audit_log(tbl, row_id);
CREATE INDEX idx_audit_log_created ON iam.audit_log(created_at);

-- ─────────────────────────────────────────────
-- 9. RBAC 种子数据
-- ─────────────────────────────────────────────
INSERT INTO iam.roles (code, name, is_system) VALUES
    ('super_admin',   '超级管理员', true),
    ('merchant_admin', '商户管理员', true),
    ('staff',          '员工',       true);

-- 权限点（核心域，按实际业务枚举；后续可扩展）
INSERT INTO iam.permissions (code, name) VALUES
    ('order:read',     '订单查询'),
    ('order:write',    '订单编辑'),
    ('product:read',   '商品查询'),
    ('product:write',  '商品编辑'),
    ('finance:read',   '财务查询'),
    ('finance:write',  '财务操作'),
    ('chat:read',      '聊天读取'),
    ('chat:write',     '聊天发送'),
    ('proxy:read',     '中转查询'),
    ('proxy:write',    '中转配置'),
    ('device:read',    '设备查询'),
    ('device:write',   '设备管理'),
    ('user:read',      '用户查询'),
    ('user:write',     '用户管理'),
    ('tenant:read',    '租户查询'),
    ('tenant:write',   '租户管理'),
    ('rbac:write',     '权限配置');

-- super_admin: 全部权限
INSERT INTO iam.role_permissions (role_id, perm_id)
SELECT r.role_id, p.perm_id FROM iam.roles r, iam.permissions p
WHERE r.code = 'super_admin';

-- merchant_admin: 业务权限（不含 rbac/tenant 写）
INSERT INTO iam.role_permissions (role_id, perm_id)
SELECT r.role_id, p.perm_id FROM iam.roles r, iam.permissions p
WHERE r.code = 'merchant_admin'
  AND p.code NOT IN ('rbac:write','tenant:write','tenant:read');

-- staff: 只读 + 聊天
INSERT INTO iam.role_permissions (role_id, perm_id)
SELECT r.role_id, p.perm_id FROM iam.roles r, iam.permissions p
WHERE r.code = 'staff'
  AND p.code IN ('order:read','product:read','chat:read','chat:write','device:read','finance:read');

COMMIT;
