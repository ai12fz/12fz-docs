# 数造智能中台 — 服务器信息文档

## 1. 基本信息
| 项目 | 值 |
|------|-----|
| 主机名 | shuzaokeji（原 iZ7xv87nv3ailxlkotngbuZ） |
| 厂商 | Alibaba Cloud ECS |
| 操作系统 | Ubuntu 26.04 LTS (Resolute Raccoon) |
| 内核 | Linux 7.0.0-15-generic x86_64 |
| 架构 | x86_64 |
| IP内网 | 172.31.244.36/20 |
| 运行时间 | 17天19小时 |
| SSH端口 | 22（只允许密钥登录，禁止密码） |
| 定时任务 | bot-pusher 每2分钟 / git-pull 每5分钟 / 中台同步 8:00,14:00,20:00 / SSL续期 每天0:31 |

## 2. 硬件资源
| 资源 | 规格 |
|------|------|
| CPU | Intel Xeon Platinum, 4核8线程 |
| 内存 | 14Gi（已用12Gi，可用1.8Gi） |
| 磁盘 | /dev/vda3 99G（已用36G，可用59G，使用率38%）|
| 无Swap | vm.swappiness=0 |

## 3. 软件栈
| 组件 | 版本 |
|------|------|
| Nginx | 最新 stable（反向代理+SSL终结） |
| PHP | 8.5.4 (FPM) |
| Java | OpenJDK 25.0.3 LTS |
| Go | 1.26.0 |
| Node.js | v22.22.3 |
| Python | 3.14.4 |
| PostgreSQL | 18.4（主库） |
| MySQL | 最新（WordPress站点） |
| Redis | 8.0.5 |
| Docker | 29.1.3（仅1个容器：Oracle XE 21.3） |

## 4. 域名站点
| 域名 | 类型 | 说明 |
|------|------|------|
| 12fz.com / www.12fz.com | 生产 | 老shuzao站，根目录 /mnt/data/12fz/wwwroot/12fz.com |
| go.12fz.com | 生产 | 工作桌面（SSL certbot管理） |

| ai.12fz.com | 生产 | AI能力中心 |
| dev.12fz.com | 开发 | 开发站，根目录 /mnt/data/12fz/wwwroot/dev.12fz.com |
| shuzao.12fz.com | 生产 | 老ERP |
| goxeou.12fz.com | 生产 | 果秀ERP |
| goxeou_dev.12fz.com | 开发 | 果秀开发站 |
| signal.12fz.com | 生产 | 信号服务 |
| new.12fz.com | 已删除 | 已301→go.12fz.com |

SSL证书：go.12fz.com 通过 Let's Encrypt certbot 管理，ECDSA密钥，2026-09-06到期（有效82天）

## 5. 运行服务
| 服务 | 状态 | 说明 |
|------|------|------|
| nginx | active | Web服务器+反向代理 |
| php8.5-fpm | active | PHP FastCGI |
| postgresql@18-main | active | PostgreSQL主库 |
| redis-server | active | 缓存 |
| docker | active | Docker引擎 |
| chat-server | active | 12FZ聊天服务器 |
| hermes-gateway | active | Hermes AI网关 |
| bot-msg-relay | active | Bot消息中继 |
| oracle-xe (Docker) | active | Oracle XE 21.3（端口1521）|

## 6. 防火墙（UFW）
**默认策略**：入站拒绝，出站允许
**放行端口**：
- 22/SSH, 80/HTTP, 443/HTTPS, 8086（Bot中继）
- NPS全端口：202,222,5000,8642-8649,9119,11088,11099,15001-15002,18024-18025,18789,19900,20022,20080,20081,20100,20111,20202,25002,25006,28080,29385,30099,8089

## 7. 开发环境
### 7.1 Go项目（聊天系统 /root/12fz-chat/）
| 文件 | 说明 |
|------|------|
| chat-server | 当前运行版（10.9MB） |
| chat-server-new | 新版（15.6MB，待更新） |
| chat-server-latest | 最新编译版（15.1MB） |
| chat-server.bak.0915 | 备份 |
| bin/ | 二级目录 |

后端：Go 1.26，前端在 frontend/，启动用 run.sh（需export PG_CONN）

### 7.2 Java项目
| 项目 | 位置 | 说明 |
|------|------|------|
| shuzao ERP (v65.7) | /mnt/data/www/javaweb/www/shuzao.v65.7.jar | JDK 11运行 |
| 中台 (zhongtai) | /mnt/data/www/javaweb/www/zhongtai.v20260615232527.jar | JDK 25运行 |

### 7.3 项目目录
| 目录 | 说明 |
|------|------|
| /root/12fz-chat/ | 聊天系统 |
| /root/12fz-erp/ | ERP项目 |
| /root/12fz-sso/ | SSO单点登录（Phase 1开发中，Go后端） |
| /root/12fz-docs/ | 开发文档（chaogu-ai维护） |
| /root/12fz-infra/ | 基础设施 |
| /root/12fz-ai/ | AI服务 |

### 7.4 数据库
**PostgreSQL（18.4）**：
| 数据库 | 所有者 | 说明 |
|--------|--------|------|
| suzao | suzao | 主业务库 |
| shuzao_dev | shuzao_dev | 开发库 |
| zhongtai | app_zhongtai | 中台库 |
| gxo_12fz_com | gxo_12fz_com | 果秀库 |

**MySQL**：wp_12fz, wp_12fz_dev, gxo_12fz_com, goxeou_12fz_com

**Oracle XE（Docker）**：端口1521

## 8. 中继与处理器
| 组件 | 位置 |
|------|------|
| Bot消息中继 | /usr/local/bin/chat-bot-processor-v8.py |
| 中继端口 | 8086 |
| 网关自愈 | /root/.hermes/fix-gateway.sh（每5分钟+重启检查）|
| Bot推播 | /opt/bot-pusher.py（每2分钟）|
| Bot提交器 | /opt/bot-msg-submitter.py（重启启动）|

## 9. Git配置
| 项目 | 值 |
|------|-----|
| 用户名 | 邱明 |
| 邮箱 | qiuming@12fz.com |
| 默认分支 | main |

## 10. 内存大户（按%MEM排序）
| 进程 | 内存 | 说明 |
|------|------|------|
| shuzao.v65.7.jar | 8.9% (~1.3Gi) | 老ERP Java |
| zhongtai.v...jar | 6.0% (~940Mi) | 中台 Java |
| oracle-xe (Docker) | ~5.2% | Oracle数据库 |
| mysqld | 4.7% | MySQL |
| 总计 | ~35%+ | 应用为主 |

*文档生成时间：2026-06-16 12:18*
