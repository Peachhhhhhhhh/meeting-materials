-- 会议材料管理系统 - 文件类型字典化迁移脚本
-- 作用：把表单里写死的「文件类型」选项（docx/xlsx/pptx/pdf）改为数据库字典表，
--       管理端可自行增删改；materials.file_type 存 file_types.key。
-- 在 Supabase 控制台 → SQL Editor 中整段执行；可重复执行，不会报错。

-- ========== 1. 建表 ==========
CREATE TABLE IF NOT EXISTS file_types (
  id SERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  label TEXT NOT NULL,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========== 2. 预置现有 4 种类型（key 与历史数据一致，可重复执行） ==========
INSERT INTO file_types (key, label, sort) VALUES
  ('docx', 'Word (.docx)', 1),
  ('xlsx', 'Excel (.xlsx)', 2),
  ('pptx', 'PPT (.pptx)',  3),
  ('pdf',  'PDF (.pdf)',   4)
ON CONFLICT (key) DO NOTHING;

-- ========== 3. 启用 RLS 并套用与其它字典表一致的策略 ==========
ALTER TABLE file_types ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_all_file_types" ON file_types;
DROP POLICY IF EXISTS "public_read_file_types" ON file_types;
CREATE POLICY "public_read_file_types" ON file_types FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "auth_write_file_types" ON file_types FOR ALL TO authenticated USING (true) WITH CHECK (true);
