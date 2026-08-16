-- ═══════════════════════════════════════════════════════════════
-- 12FZ IAM 身份域重构 · 005-cleanup.sql
-- 技术债清理：旧表/兼容视图/空表一次性 DROP，零过渡层
-- 执行前提：001-004 全部成功 + 全量回归通过后执行
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════
-- 1. 旧身份表（数据已迁 iam.*）
-- ═══════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS public.org_user CASCADE;
DROP TABLE IF EXISTS public.org_merchant CASCADE;

-- ═══════════════════════════════════════════════════════════════
-- 2. chat 域兼容层（旧 friends 表 + 兼容视图 + 空表）
-- ═══════════════════════════════════════════════════════════════
DROP VIEW IF EXISTS chat.friends CASCADE;
DROP TABLE IF EXISTS chat.friends_old CASCADE;
DROP TABLE IF EXISTS chat.friends_bak_20260802 CASCADE;
DROP TABLE IF EXISTS chat.host_codes CASCADE;
DROP TABLE IF EXISTS chat.org_change_audit CASCADE;
-- chat.capabilities 保留：/api/capabilities 接口与前端 AgentStatusPanel 在用（skill_db.go:68）

-- ═══════════════════════════════════════════════════════════════
-- 3. public 域废弃空表（chat_* 旧兼容、bug_reports 等无数据表）
--    仅 DROP 确认 0 行的废弃表；有数据的保留（后续按业务归档）
-- ═══════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS public.chat_friends CASCADE;
DROP TABLE IF EXISTS public.chat_messages CASCADE;
DROP TABLE IF EXISTS public.chat_agents CASCADE;
DROP TABLE IF EXISTS public.chat_friend_requests CASCADE;

-- ═══════════════════════════════════════════════════════════════
-- 4. 迁移辅助：uid 序列对齐（确保新用户 ID 不与 bot/host 实体冲突）
-- ═══════════════════════════════════════════════════════════════
SELECT setval('iam.users_uid_seq', GREATEST((SELECT COALESCE(MAX(uid),1) FROM iam.users), 1));

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- 5. 验收核对（全部应返回 0）
-- ═══════════════════════════════════════════════════════════════
-- SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('org_user','org_merchant');
-- SELECT count(*) FROM information_schema.views WHERE table_schema='chat' AND table_name='friends';
-- SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'chat\_%';
-- SELECT count(*) FROM information_schema.columns WHERE table_name IN ('org_user','org_merchant');
