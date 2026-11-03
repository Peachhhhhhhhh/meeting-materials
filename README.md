# 会议材料管理系统

纯静态前端（HTML/CSS/JS，无构建工具） + Supabase 云数据库 + Cloudflare Pages 托管。
本包内容 = **2026-11-03 线上正式生效版本**，可直接接手维护。

## 一、线上信息

| 项目 | 值 |
|------|----|
| 用户端 | https://meeting-materials.pages.dev |
| 管理端 | https://meeting-materials.pages.dev/admin.html （Cloudflare 会自动跳转 `/admin`） |
| 部署平台 | Cloudflare Pages，项目名 `meeting-materials`，分支 `main` |
| Cloudflare Account ID | `88ccccf2373e93f64b1378c41511b91f` |
| 数据库 | Supabase 项目 `kcothoexsnhvrlzkzttl` |
| Supabase URL | `https://kcothoexsnhvrlzkzttl.supabase.co` |
| Supabase publishable key | `sb_publishable_35ODEWDAb0cNftVByeIxKg_o-4W9rq7`（公开密钥，前端内置，可公开） |

> 密钥说明：publishable/anon key 是设计上给浏览器用的公开密钥，安全性由 RLS 策略保证。真正的 `service_role` / secret key 与 Cloudflare API Token **不在本包中**，请单独保管、不要入库。

## 二、目录结构

```
meeting-materials-release/
├── README.md                ← 本文件
├── Dockerfile               ← 私有化部署用（Nginx 静态托管）
├── docker-compose.yml
├── nginx.conf
├── public/
│   ├── index.html           ← 用户端（首页 + 所有文件）
│   └── admin.html           ← 管理端（CRUD）
├── database/
│   ├── init.sql             ← 建表 + RLS 策略 + 字典初始数据（可重复执行）
│   └── data-export/         ← 2026-11-03 线上数据快照（JSON，按表一份）
├── scripts/
│   ├── deploy.sh            ← 一键发布到 Cloudflare Pages
│   └── backup.sh            ← 一键导出全库 JSON
└── docs/
    └── 维护手册.md          ← 架构、数据模型、代码结构与已知坑
```

## 三、首次接手（3 步）

1. **数据库**：若沿用现有 Supabase 项目，无需任何操作；若换新项目，到 Supabase → SQL Editor 依次执行 `database/init.sql`（建表 + RLS + 字典）和 `database/auth-hardening.sql`（收紧写权限），然后把 `public/*.html` 里的 `SUPABASE_URL`、`SUPABASE_KEY` 换成新项目的值（`index.html` 约第 493 行、`admin.html` 约第 479 行）。
2. **管理员账号**：Supabase 控制台 → Authentication → Users → Add user（填邮箱密码、勾选 Auto Confirm User）。管理端 `admin.html` 需要登录后才能增删改；用户端匿名只读。
3. **本地预览**：直接用浏览器打开 `public/index.html` 即可，不需要 Node.js、不需要起服务器。
4. **发布**：见下一节。

## 四、发布更新（Cloudflare Pages）

前置：Node.js 18+（**仅部署需要**，网站运行不需要）。

```bash
npm install -g wrangler@3.75.0
export CLOUDFLARE_API_TOKEN=<你的 Token>      # 需 Pages:Edit 权限
export CLOUDFLARE_ACCOUNT_ID=88ccccf2373e93f64b1378c41511b91f
cd public
wrangler pages deploy . --project-name=meeting-materials --branch=main
```

或直接用 `bash scripts/deploy.sh`（会检查令牌是否已设置）。

- 每次发布都会生成一个 `xxxx.meeting-materials.pages.dev` 临时子域，**但生产主域名 `meeting-materials.pages.dev` 永远不变**，分享这个主域名即可。
- 若令牌丢失：Cloudflare 控制台 → 右上头像 → My Profile → API Tokens → 重新创建（权限选 `Account / Cloudflare Pages / Edit`）。

## 五、私有化部署（Docker，可选）

```bash
docker compose up -d          # 访问 http://服务器IP/
docker compose logs -f
```

`public/` 会被打进镜像，Nginx 已配置 gzip、UTF-8、静态资源缓存。数据库仍是 Supabase 云库，无需额外后端。

## 六、数据备份

```bash
bash scripts/backup.sh        # 输出到 ./backup/<时间戳>/*.json
```

项目数据（`materials` / `leader_notes`）目前只存在于 Supabase，**没有自动备份**，建议定期执行。Supabase 免费版也可在控制台 → Database → Backups 查看平台级快照。

## 七、关键业务规则（改代码前必读）

- 字段名固定：`file_name`、`file_type`、`meeting_title`、`meeting_date`、`meeting_type`、`meeting_department`、`uploader`、`wps_url`、`version`、`tags`（逗号分隔字符串）、`uploaded_at`、`is_final`。
- 备注存 `leader_notes` 表（`material_id` + `content`），不存 `materials` 表。
- 会议类型以 `meeting_types.key` 入库，界面显示 `label`。
- WPS 分享链接必须用 `window.open(url, '_blank', 'noreferrer')` 打开，否则会被 WPS 的 referer 白名单拦截（`referer_host not match whitelist`）。
- 权限模型：匿名（anon）只读；只有 Supabase Auth 登录用户（authenticated）可写。由 `database/auth-hardening.sql` 中的 RLS 策略保证，管理端登录逻辑在 `admin.html` 底部 Auth 区块。
- 用户端底部 Tab 只有「首页 / 所有文件」，没有「管理」；两页在同一文档内互斥切换，底部栏固定。
- 详细说明见 `docs/维护手册.md`。

## 八、数据现状

- **权威数据在线上 Supabase 库**，本包 `database/data-export/` 只是 2026-11-03 13:56 的导出快照（用于备份/迁移，可能已滞后于线上）。
- 快照时 `materials`、`leader_notes` 为空；字典表（部门 7 条、会议类型 4 条、提交人 5 人、标签 4 条）已有数据。
- 历史数据随旧 Supabase 项目删除已丢失。
- `init.sql` 只预置了少量字典示例；线上实际字典以 `data-export/` 或管理端界面为准。
