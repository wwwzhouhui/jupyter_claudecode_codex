# AI 开发工具集成环境

> 功能完整的 AI 驱动开发环境，集成多种主流 AI 代码助手、SuperClaude 框架和 MCP 服务器

![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)
![Python](https://img.shields.io/badge/python-3.11-blue.svg)
![Node.js](https://img.shields.io/badge/node.js-22.19+-green.svg)
![Docker](https://img.shields.io/badge/docker-latest-blue.svg)
![Jupyter](https://img.shields.io/badge/jupyter-lab-orange.svg)

---

## 项目介绍

AI 开发工具集成环境是一个专业的 AI 驱动开发环境，集成了多种主流 AI 代码助手、SuperClaude 框架 v4.1.5 和 8 个 MCP 服务器。基于 Docker 容器化部署，开箱即用，为开发者提供完整的 AI 辅助编程解决方案。

### 核心特性

- **多 AI 引擎支持**: 集成 Claude Code、通义千问、OpenAI Codex、Google Gemini、GitHub Copilot、Neovate Code 等主流 AI 代码助手
- **SuperClaude 框架**: 完整安装 SuperClaude 框架 v4.1.5，包含 15 个专业 AI 代理、7 种行为模式、25 个命令定义
- **MCP 服务器集成**: 预配置 8 个 MCP 服务器（sequential-thinking、context7、magic、playwright、serena、morphllm、tavily、chrome-devtools）
- **完整开发环境**: Python 3.11 + Node.js v22.19.0 + JupyterLab，支持 AI 辅助编程
- **云服务集成**: 内置腾讯 CodeBuddy、CloudFlare、Atlassian CLI 等云服务工具
- **开箱即用**: 一键部署，所有工具预配置完成
- **uv 包管理**: 内置超快的 uv Python 包管理器
- **浏览器自动化**: 完整的 Playwright 浏览器自动化支持

---

## 功能清单

| 功能名称 | 功能说明 | 技术栈 | 状态 |
|---------|---------|--------|------|
| 多 AI 引擎 | Claude/通义/Codex/Gemini/Copilot 等 | NPM 全局包 | ✅ 稳定 |
| SuperClaude 框架 | 15个代理 + 7种模式 + 25个命令 | Python 框架 | ✅ 稳定 |
| MCP 服务器 | 8个预配置服务器 | MCP 协议 | ✅ 稳定 |
| JupyterLab | Web 开发环境 | JupyterLab | ✅ 稳定 |
| uv 包管理 | 超快 Python 包管理器 | uv | ✅ 稳定 |
| Playwright | 浏览器自动化 | Playwright | ✅ 稳定 |
| 云服务工具 | CloudFlare/Atlassian CLI | CLI 工具 | ✅ 稳定 |
| Docker 部署 | 容器化一键部署 | Docker | ✅ 稳定 |

---

## 技术架构

| 技术 | 版本 | 用途 |
|------|------|------|
| Python | 3.11 | 主要开发语言 |
| Node.js | v22.19.0 | JavaScript 运行时 |
| JupyterLab | latest | Web 开发环境 |
| Docker | latest | 容器化部署 |
| uv | latest | Python 包管理器 |
| Playwright | latest | 浏览器自动化 |

### 容器架构

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            容器架构图                                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   ┌──────────────────┐       ┌─────────────────────────┐       ┌─────────────┐ │
│   │  JupyterLab Web  │ ◄────► │   AI 工具集成层         │ ◄────► │  MCP 服务   │ │
│   │   端口 8889       │       │   9个AI代码助手         │       │  8个服务器  │ │
│   └──────────────────┘       └─────────────────────────┘       └─────────────┘ │
│           │                            │                              │        │
│           ▼                            ▼                              ▼        │
│   Web 可视化界面            SuperClaude 框架 v4.1.5          语义代码分析      │
│   终端 + 代码编辑器        15个代理 + 7种模式 + 25个命令    智能编辑工具      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 安装说明

### 环境要求

- Docker / Docker Compose
- 主机端口 8889 可用

### 拉取镜像

```bash
docker pull wwwzhouhui569/jupyter_claudecode_codex:latest
```

### 本地构建

```bash
docker build -t jupyter_claudecode_codex .
```

---

## 使用说明

### 方式一：使用预构建镜像（推荐）

#### 拉取最新镜像

```bash
docker pull wwwzhouhui569/jupyter_claudecode_codex:latest
```

#### 启动容器

**基础启动**：

```bash
docker run -d -p 8889:8889 --name jupyter_claudecode_codex wwwzhouhui569/jupyter_claudecode_codex:latest
```

**带环境变量启动（推荐）**：

```bash
docker run -d -p 8889:8888 \
  -e MORPH_API_KEY="your_morph_api_key" \
  -e TAVILY_API_KEY="your_tavily_api_key" \
  -v /your/data/path:/data \
  --name jupyter_claudecode_codex \
  wwwzhouhui569/jupyter_claudecode_codex:latest
```

### 方式二：本地构建镜像

#### 构建镜像

```bash
docker build -t jupyter_claudecode_codex .
```

#### 启动容器

```bash
docker run -d -p 8889:8889 --name jupyter_claudecode_codex jupyter_claudecode_codex
```

### 访问服务

- **Jupyter Lab**: http://localhost:8889 (token: `o3sky2025`)
- **终端访问**: 在 JupyterLab 中打开 Terminal 即可使用所有 AI 工具

### 使用说明

1. **访问 JupyterLab**: 打开 http://localhost:8889，使用 token `o3sky2025` 登录
2. **打开 Terminal**: 在 JupyterLab 中新建 Terminal
3. **验证安装**: 运行以下命令检查工具安装情况

```bash
# 检查 Claude Code
claude-code --version

# 检查 SuperClaude
superclaude --version
python -c "import SuperClaude; print('SuperClaude已安装')"

# 检查其他 AI 工具
gemini --version
qwen --version
github-copilot --version
neovate --version

# 查看 SuperClaude 配置
ls -la ~/.claude/
```

**SuperClaude 使用**：

```bash
# 查看 SuperClaude 帮助
superclaude --help

# 查看已安装的组件
superclaude status

# 配置 API 密钥（如需要）
export MORPH_API_KEY="your_key"
export TAVILY_API_KEY="your_key"
```

---

## 配置说明

### 环境变量配置

为了充分使用 MCP 服务器功能，建议配置以下环境变量：

| 变量名 | 说明 | 必需 |
|--------|------|------|
| `MORPH_API_KEY` | Morph API 密钥（用于 morphllm-fast-apply） | 可选 |
| `TAVILY_API_KEY` | Tavily API 密钥（用于网络搜索） | 可选 |
| `PLAYWRIGHT_HEADLESS` | Playwright 无头模式 | 可选 |

### AI 代码助手

| 工具名称 | 包名 | 功能 |
|---------|------|------|
| Claude Code CLI | @anthropic-ai/claude-code | Anthropic AI 代码助手 |
| Claude Code Router | @musistudio/claude-code-router | Claude 路由器 |
| Google Gemini CLI | @google/gemini-cli | Google Gemini AI |
| 通义千问 | @qwen-code/qwen-code | 阿里通义千问 |
| OpenAI Codex | @openai/codex | OpenAI Codex |
| GitHub Copilot CLI | @github/copilot | GitHub Copilot |
| Neovate Code | @neovate/code | Neovate AI |
| 腾讯 CodeBuddy | @tencent-ai/codebuddy-code | 腾讯 AI |
| iFlow AI CLI | @iflow-ai/iflow-cli | iFlow AI |

### SuperClaude 框架组件

| 组件类型 | 数量 | 说明 |
|---------|------|------|
| 核心框架 | 6 个 | 业务面板、符号、标志、原则、研究配置、规则 |
| 行为模式 | 7 种 | 头脑风暴、业务面板、深度研究、内省、编排、任务管理、令牌效率 |
| 专业代理 | 15 个 | 领域专家 AI 代理，支持智能路由 |
| 命令系统 | 25 个 | SuperClaude 斜杠命令定义 |

### MCP 服务器

| 服务器名称 | 功能 |
|-----------|------|
| sequential-thinking | 多步骤问题解决和系统分析 |
| context7 | 官方库文档和代码示例 |
| magic | 现代 UI 组件生成和设计系统 |
| playwright | 跨浏览器 E2E 测试和自动化 |
| serena | 语义代码分析和智能编辑（包含 uv 支持） |
| morphllm-fast-apply | 快速应用上下文感知代码修改 |
| tavily | 网络搜索和实时信息检索 |
| chrome-devtools | Chrome 开发者工具调试和性能分析 |

### 云服务工具

| 工具名称 | 功能 |
|---------|------|
| CloudFlare CLI | cloudflared |
| Atlassian CLI | acli |
| Git LFS | 大文件支持 |

### 开发环境

| 组件 | 版本 | 用途 |
|------|------|------|
| Python | 3.11 | 主要开发语言 |
| Node.js | v22.19.0 | JavaScript 运行时 |
| JupyterLab | latest | Web 开发环境 |
| uv | latest | Python 包管理器（Serena MCP 依赖） |

---

## 项目结构

```
jupyter_claudecode_codex/
├── Dockerfile              # Docker 镜像配置
├── requirements.txt        # Python 依赖
├── README.md              # 项目文档
├── .claude/               # Claude Code 配置
│   └── settings.local.json
└── (SuperClaude 和 MCP 服务器安装在 ~/.claude/)
```

---

## 开发指南

### 本地开发

```bash
# 拉取镜像
docker pull wwwzhouhui569/jupyter_claudecode_codex:latest

# 启动容器
docker run -d -p 8889:8889 --name jupyter_claudecode_codex wwwzhouhui569/jupyter_claudecode_codex:latest

# 访问 JupyterLab
open http://localhost:8889
```

### 验证工具

```bash
# 在 JupyterLab Terminal 中运行
claude-code --version
gemini --version
qwen --version
github-copilot --version
neovate --version
superclaude --version
```

### 查看日志

```bash
# 查看容器日志
docker logs jupyter_claudecode_codex

# 实时查看日志
docker logs -f jupyter_claudecode_codex
```

---

## 常见问题

<details>
<summary>Q: MCP 服务器无法使用？</summary>

A: 检查以下几点：
1. 确认已设置相应的 API 密钥（MORPH_API_KEY、TAVILY_API_KEY）
2. 查看 SuperClaude 配置：`ls -la ~/.claude/`
3. 检查 MCP 服务器配置文件是否正确
</details>

<details>
<summary>Q: SuperClaude 命令不可用？</summary>

A:
1. 确认容器启动完成，重新进入 Terminal
2. 检查 SuperClaude 安装：`superclaude --version`
3. 查看配置文件：`cat ~/.claude/CLAUDE.md`
</details>

<details>
<summary>Q: 权限问题？</summary>

A:
1. 确保使用正确的用户权限运行容器
2. 容器内使用 `user` 用户（非 root）
3. 如需 root 权限，使用 `sudo`
</details>

<details>
<summary>Q: JupyterLab 无法访问？</summary>

A:
1. 确认容器正在运行：`docker ps`
2. 检查端口映射：`docker port jupyter_claudecode_codex`
3. 确认使用正确的 token：`o3sky2025`
</details>

<details>
<summary>Q: AI 工具无法使用？</summary>

A:
1. 检查工具是否正确安装：`claude-code --version`
2. 确认 API 密钥已配置
3. 查看容器日志获取详细错误信息
</details>

<details>
<summary>Q: 如何添加新的 MCP 服务器？</summary>

A:
1. 在 `~/.claude/` 目录下添加服务器配置
2. 按照 MCP 协议规范配置服务器
3. 重启容器使配置生效
</details>

<details>
<summary>Q: Node.js 版本问题？</summary>

A:
1. 容器内置 Node.js v22.19.0
2. 使用 nvm 管理版本：`nvm ls`
3. 如需其他版本，使用 `nvm install` 安装
</details>

<details>
<summary>Q: Python 包安装失败？</summary>

A:
1. 使用 uv 包管理器：`uv pip install package`
2. 或使用传统 pip：`pip install package`
3. 检查网络连接和 PyPI 源
</details>

<details>
<summary>Q: Playwright 浏览器无法启动？</summary>

A:
1. 确认已安装浏览器：`playwright install`
2. 检查 DISPLAY 环境变量
3. 使用无头模式：`export PLAYWRIGHT_HEADLESS=true`
</details>

<details>
<summary>Q: 数据持久化？</summary>

A:
1. 使用 `-v` 参数挂载数据目录：`-v /your/data:/data`
2. 容器内 `/data` 目录将持久化到主机
3. 重启容器后数据不会丢失
</details>

---

## 技术交流群

欢迎加入技术交流群，分享你的使用心得和反馈建议：

![技术交流群](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/Obsidian/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20260301091713_162_292.jpg)

---

## 作者联系

- **微信**: laohaibao2025
- **邮箱**: 75271002@qq.com

![微信二维码](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/Screenshot_20260123_095617_com.tencent.mm.jpg)

---

## 打赏

如果这个项目对你有帮助，欢迎请我喝杯咖啡 ☕

**微信支付**

![微信支付](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/Obsidian/image-20250914152855543.png)

---

## Star History

如果觉得项目不错，欢迎点个 Star ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=wwwzhouhui/jupyter_claudecode_codex&type=Date)](https://star-history.com/#wwwzhouhui/jupyter_claudecode_codex&Date)

---

## License

Apache-2.0 License

---

## 更新日志

### v0.0.2 (最新)
- ✅ 新增 GitHub Copilot CLI 支持 (@github/copilot)
- ✅ 新增 Neovate Code AI 助手 (@neovate/code)
- ✅ 扩展 AI 代码助手生态系统
- ✅ 优化多 AI 引擎协作能力

### v0.0.1
- ✅ 集成 SuperClaude 框架 v4.1.5
- ✅ 添加 8 个 MCP 服务器支持
- ✅ 新增 uv 包管理器支持
- ✅ 完整的非交互式安装流程
- ✅ 优化容器构建和启动流程

---

## AI 工具截图

### Claude Code

![Claude Code](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102432829.png)

### Rovo Dev

![Rovo Dev](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928103248686.png)

### CCR Code

![CCR Code](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102559028.png)

### Gemini

![Gemini](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102642345.png)

### Qwen

![Qwen](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102734367.png)

### Codex

![Codex](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102818425.png)

### iFlow

![iFlow](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928102905282.png)

### Copilot

![Copilot](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928103013020.png)

### Neovate

![Neovate](https://mypicture-1258720957.cos.ap-nanjing.myqcloud.com/image-20250928103110623.png)

---

**Enjoy developing with AI-powered tools! 🚀✨**
