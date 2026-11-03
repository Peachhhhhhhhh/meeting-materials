-- 会议材料管理系统 - RLS 收紧脚本
-- 目标：任何人可读（用户端匿名浏览），只有登录用户（Supabase Auth）可写。
-- 在 Supabase 控制台 → SQL Editor 中整段执行；可重复执行，不会报错。
--
-- 执行本脚本前，请先在 Authentication → Users 中创建至少一个管理员账号
-- （Add user → 填邮箱和密码 → 勾选 Auto Confirm User），
-- 否则收紧后管理端将无法登录、无法增删改数据。

-- ========== 1. 删除旧的"完全放开"策略 ==========
DROP POLICY IF EXISTS "public_all_materials" ON materials;
DROP POLICY IF EXISTS "public_all_leader_notes" ON leader_notes;
DROP POLICY IF EXISTS "public_all_meeting_types" ON meeting_types;
DROP POLICY IF EXISTS "public_all_departments" ON departments;
DROP POLICY IF EXISTS "public_all_uploaders" ON uploaders;
DROP POLICY IF EXISTS "public_all_tags" ON tags;

-- ========== 2. 所有人可读（匿名 + 登录） ==========
CREATE POLICY "public_read_materials" ON materials FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "public_read_leader_notes" ON leader_notes FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "public_read_meeting_types" ON meeting_types FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "public_read_departments" ON departments FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "public_read_uploaders" ON uploaders FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "public_read_tags" ON tags FOR SELECT TO anon, authenticated USING (true);

-- ========== 3. 只有登录用户可写（增删改） ==========
CREATE POLICY "auth_write_materials" ON materials FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "auth_update_materials" ON materials FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_delete_materials" ON materials FOR DELETE TO authenticated USING (true);

CREATE POLICY "auth_write_leader_notes" ON leader_notes FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_meeting_types" ON meeting_types FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_departments" ON departments FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_uploaders" ON uploaders FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_tags" ON tags FOR ALL TO authenticated USING (true) WITH CHECK (true);
