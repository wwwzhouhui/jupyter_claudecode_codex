#FROM wwwzhouhui569/ubuntu22.04-py311-torch2.3.1-1.28.0:latest
FROM python:3.11-slim

# Stage 1: Download mihomo binary
FROM alpine:latest as mihomo-downloader
WORKDIR /download
RUN set -e && \
    MIHOMO_VERSION="v1.19.21" && \
    echo "Downloading mihomo ${MIHOMO_VERSION}..." && \
    (wget -q --timeout=120 --tries=3 "https://github.moeyy.xyz/https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-amd64-compatible-${MIHOMO_VERSION}.gz" -O mihomo.gz || \
     wget -q --timeout=120 --tries=3 "https://ghproxy.net/https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-amd64-compatible-${MIHOMO_VERSION}.gz" -O mihomo.gz || \
     wget -q --timeout=120 --tries=3 "https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-amd64-compatible-${MIHOMO_VERSION}.gz" -O mihomo.gz) && \
    gunzip mihomo.gz && \
    chmod +x mihomo && \
    echo "mihomo downloaded successfully" && \
    ls -la mihomo

# Stage 2: Main image
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

# Install essential utilities and browser dependencies (optimized for size)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    wget \
    procps \
    git-lfs \
    zip \
    unzip \
    nano \
    bzip2 \
    xz-utils \
    libsndfile1 \
    # Playwright browser automation dependencies
    xvfb \
    libfontenc1 \
    libunwind8 \
    libxfont2 \
    x11-xkb-utils \
    xauth \
    xfonts-base \
    xfonts-encodings \
    xfonts-utils \
    xserver-common \
    # Additional browser runtime dependencies
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add cloudflare gpg key
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
RUN apt-get update && apt-get install -y cloudflared && rm -rf /var/lib/apt/lists/*

# Set working directory and HOME
WORKDIR /root/app

# Set up home directory
ENV HOME=/root
RUN mkdir -p $HOME/.cache $HOME/.config $HOME/.nvm && \
    chmod -R 777 $HOME

# Install NVM and Node.js (optimized with version control)
ENV NVM_DIR="/root/.nvm"
ENV NODE_VERSION="v22.19.0"
ENV PATH="$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g configurable-http-proxy && \
    npm install -g @anthropic-ai/claude-code && \
    npm install -g @musistudio/claude-code-router && \
    npm install -g @google/gemini-cli --timeout=300000 && \
    npm install -g @qwen-code/qwen-code@latest --timeout=300000 && \
    npm install -g @openai/codex --timeout=300000 --registry=https://registry.npmjs.org/ && \
    npm install -g @iflow-ai/iflow-cli@latest --timeout=300000 --registry=https://registry.npmjs.org/ && \
    npm install -g @github/copilot --timeout=300000 --registry=https://registry.npmjs.org/ && \
    npm install -g @neovate/code@latest --timeout=300000 --registry=https://registry.npmjs.org/ && \
    bash -c 'source $NVM_DIR/nvm.sh && npm install -g @tencent-ai/codebuddy-code --timeout=300000 --registry=https://registry.npmjs.org/' && \
    npm cache clean --force && \
    rm -rf /tmp/* /var/tmp/* || true

# Python 3.11 is already available from the base image python:3.11-slim

WORKDIR $HOME/app

# Create data directory for code and data persistence
# /workspace - 代码目录
# /data - 数据目录 (Jupyter notebook 根目录)
RUN mkdir -p /workspace /data && \
    chmod -R 777 /workspace /data

# Do NOT declare VOLUME here - let runtime handle mounting
# VOLUME declaration can cause permission issues with host-mounted volumes

# Install Python packages using pip only (optimized)
RUN pip install --no-cache-dir --upgrade pip

# Copy requirements and install Python packages with optimizations (single installation)
COPY requirements.txt $HOME/app/
RUN pip install --no-cache-dir --no-compile --upgrade -r requirements.txt && \
    (find /usr/local -name "*.pyc" -delete || true) && \
    (find /usr/local -name "__pycache__" -type d -exec rm -rf {} + || true)

# Install Playwright browsers (Python version) - use mirror and retry logic
RUN export PLAYWRIGHT_DOWNLOAD_HOST="https://npmmirror.com/mirrors/playwright" && \
    for i in 1 2 3 4 5; do \
        echo "Attempt $i: Installing Playwright browsers..." && \
        python -m playwright install chromium chromium-headless-shell firefox webkit && \
        echo "Playwright browsers installed successfully!" && \
        break || { \
            echo "Attempt $i failed. Waiting 15 seconds before retry..." >&2; \
            sleep 15; \
            if [ $i -eq 5 ]; then \
                echo "All attempts failed. Continuing..." >&2; \
            fi; \
        }; \
    done

# Install Playwright system dependencies (with retry logic and timeout handling)
RUN for i in 1 2 3 4 5; do \
        echo "Attempt $i: Updating apt cache..." && \
        apt-get update -o Acquire::http::Timeout=30 -o Acquire::Retries=3 && \
        echo "Installing Playwright dependencies..." && \
        python -m playwright install-deps && \
        echo "Playwright dependencies installed successfully!" && \
        break || { \
            echo "❌ Attempt $i failed. Waiting 10 seconds before retry..." >&2; \
            sleep 10; \
            if [ $i -eq 5 ]; then \
                echo "⚠️ All attempts failed. Continuing without Playwright system deps..." >&2; \
                echo "You may need to install deps manually or use a different network." >&2; \
            fi; \
        }; \
    done && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js Playwright and browsers (as root)
RUN export NVM_DIR="/root/.nvm" && \
    export PATH="$NVM_DIR/versions/node/v22.19.0/bin:$PATH" && \
    npm install -g playwright@latest && \
    npx playwright install chromium && \
    npm cache clean --force

# Copy the current directory contents into the container (as root)
COPY . /root/app

# Create .claude directory and set proper permissions
RUN mkdir -p $HOME/.claude && \
    chmod -R 755 $HOME/.claude

# Create jupyter config directory and set permissions
RUN mkdir -p $HOME/.jupyter && \
    sudo chmod 1777 /tmp

# Scripts no longer needed - using direct Jupyter startup

# Set environment variables for MCP servers (these should be provided at runtime)
ENV MORPH_API_KEY="" \
    TAVILY_API_KEY="" \
    PLAYWRIGHT_HEADLESS=true \
    PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright \
    DISPLAY=:99 \
    PYTHONUNBUFFERED=1 \
    GRADIO_ALLOW_FLAGGING=never \
    GRADIO_NUM_PORTS=1 \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_THEME=huggingface \
    SYSTEM=spaces \
    SHELL=/bin/bash \
    JUPYTER_TOKEN=o3sky2025

# Install Clash for Linux (mihomo proxy) - installed at build time
# https://github.com/nelvko/clash-for-linux-install
# 订阅地址通过环境变量 CLASH_SUBSCRIBE_URL 传入，或在运行时配置

# 配置 Clash 订阅地址（运行时可覆盖）
ENV CLASH_SUBSCRIBE_URL="https://sub1.all--green.com/mfjc/8e24620e39346bd4ddef4c8f2eea1f44"

# Install Clash at build time - copy mihomo from multi-stage build
RUN set -e && \
    export CLASH_BASE_DIR="/usr/local/clash" && \
    export CLASH_CONFIG_DIR="/root/.config/clash" && \
    echo "=== 开始安装 Clash 代理 ===" && \
    mkdir -p "$CLASH_BASE_DIR/bin" "$CLASH_CONFIG_DIR" && \
    # Clone clash-for-linux-install
    git clone --branch master --depth 1 https://github.com/nelvko/clash-for-linux-install.git /tmp/clash-install && \
    cd /tmp/clash-install && \
    /bin/cp -rf . "$CLASH_BASE_DIR" && \
    # Download yq tool
    wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O "$CLASH_BASE_DIR/bin/yq" && \
    chmod +x "$CLASH_BASE_DIR/bin/yq" && \
    # Create symlinks
    ln -sf "$CLASH_BASE_DIR/scripts/cmd/clashctl.sh" /usr/local/bin/clashctl && \
    ln -sf "$CLASH_BASE_DIR/scripts/cmd/clashctl.sh" /usr/local/bin/clashon && \
    ln -sf "$CLASH_BASE_DIR/scripts/cmd/clashctl.sh" /usr/local/bin/clashoff && \
    chmod +x "$CLASH_BASE_DIR/scripts/cmd/clashctl.sh" && \
    # Create config file
    touch "$CLASH_CONFIG_DIR/config.yaml" && \
    rm -rf /tmp/clash-install && \
    echo "=== Clash 脚本安装完成 ==="

# Copy mihomo binary from downloader stage
COPY --from=mihomo-downloader /download/mihomo /usr/local/clash/bin/mihomo
RUN echo "✅ mihomo 内核安装成功" && ls -la /usr/local/clash/bin/mihomo
# 创建启动 Clash 的脚本（Clash 已在构建时安装）
RUN echo '#!/bin/bash' > /usr/local/bin/start-clash.sh && \
    echo '# 启动 Clash 代理' >> /usr/local/bin/start-clash.sh && \
    echo 'set -e' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo 'echo "=== 启动 Clash 代理 ==="' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 加载环境变量' >> /usr/local/bin/start-clash.sh && \
    echo 'export CLASH_BASE_DIR="/usr/local/clash"' >> /usr/local/bin/start-clash.sh && \
    echo 'export CLASH_CONFIG_DIR="/root/.config/clash"' >> /usr/local/bin/start-clash.sh && \
    echo 'export PATH="$PATH:/usr/local/clash/bin"' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 检查 clashctl 脚本是否存在' >> /usr/local/bin/start-clash.sh && \
    echo 'if [ ! -f "$CLASH_BASE_DIR/scripts/cmd/clashctl.sh" ]; then' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "⚠️ clashctl 未安装，跳过代理启动"' >> /usr/local/bin/start-clash.sh && \
    echo '    exit 0' >> /usr/local/bin/start-clash.sh && \
    echo 'fi' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 检查 mihomo 内核是否存在' >> /usr/local/bin/start-clash.sh && \
    echo 'if [ ! -f "$CLASH_BASE_DIR/bin/mihomo" ]; then' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "⚠️ mihomo 内核未安装，跳过代理启动"' >> /usr/local/bin/start-clash.sh && \
    echo '    exit 0' >> /usr/local/bin/start-clash.sh && \
    echo 'fi' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo 'echo "🔧 找到 clashctl 脚本和 mihomo 内核"' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 创建基本配置文件（如果不存在或为空）' >> /usr/local/bin/start-clash.sh && \
    echo 'if [ ! -s "$CLASH_CONFIG_DIR/config.yaml" ]; then' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "📝 创建配置文件..."' >> /usr/local/bin/start-clash.sh && \
    echo '    cat > "$CLASH_CONFIG_DIR/config.yaml" <<EOFCONFIG' >> /usr/local/bin/start-clash.sh && \
    echo 'port: 7890' >> /usr/local/bin/start-clash.sh && \
    echo 'socks-port: 7891' >> /usr/local/bin/start-clash.sh && \
    echo 'allow-lan: true' >> /usr/local/bin/start-clash.sh && \
    echo 'mode: Rule' >> /usr/local/bin/start-clash.sh && \
    echo 'log-level: info' >> /usr/local/bin/start-clash.sh && \
    echo 'external-controller: 0.0.0.0:9090' >> /usr/local/bin/start-clash.sh && \
    echo 'secret: ""' >> /usr/local/bin/start-clash.sh && \
    echo 'proxy-groups:' >> /usr/local/bin/start-clash.sh && \
    echo '  - name: PROXY' >> /usr/local/bin/start-clash.sh && \
    echo '    type: select' >> /usr/local/bin/start-clash.sh && \
    echo '    proxies:' >> /usr/local/bin/start-clash.sh && \
    echo '      - DIRECT' >> /usr/local/bin/start-clash.sh && \
    echo 'rules:' >> /usr/local/bin/start-clash.sh && \
    echo '  - MATCH,DIRECT' >> /usr/local/bin/start-clash.sh && \
    echo 'EOFCONFIG' >> /usr/local/bin/start-clash.sh && \
    echo 'fi' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 启动代理' >> /usr/local/bin/start-clash.sh && \
    echo 'echo "🚀 启动代理内核..."' >> /usr/local/bin/start-clash.sh && \
    echo '"$CLASH_BASE_DIR/bin/mihomo" -d "$CLASH_CONFIG_DIR" -f "$CLASH_CONFIG_DIR/config.yaml" &' >> /usr/local/bin/start-clash.sh && \
    echo 'sleep 3' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo '# 验证代理是否工作' >> /usr/local/bin/start-clash.sh && \
    echo 'echo "🔍 验证代理连接..."' >> /usr/local/bin/start-clash.sh && \
    echo 'if curl -s --max-time 10 --socks5 127.0.0.1:7890 https://www.google.com/ > /dev/null 2>&1; then' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "✅ 代理启动成功，可以访问国外网络"' >> /usr/local/bin/start-clash.sh && \
    echo 'else' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "⚠️ 代理可能未正常工作，请检查订阅配置"' >> /usr/local/bin/start-clash.sh && \
    echo '    echo "提示：请在容器中手动配置订阅或添加代理节点"' >> /usr/local/bin/start-clash.sh && \
    echo 'fi' >> /usr/local/bin/start-clash.sh && \
    echo '' >> /usr/local/bin/start-clash.sh && \
    echo 'echo "=== Clash 代理启动完成 ==="' >> /usr/local/bin/start-clash.sh && \
    chmod +x /usr/local/bin/start-clash.sh

# 更新 xvfb 启动脚本，集成 Clash 自动启动和挂载目录权限修复
RUN echo '#!/bin/bash' > /usr/local/bin/start-with-xvfb.sh && \
    echo '# 启动 Xvfb 虚拟显示器' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'echo "Starting Xvfb virtual display server..."' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'export DISPLAY=:99' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'echo "Xvfb started on display :99"' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'sleep 2' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '# 修复挂载目录权限 (如果 /workspace 或 /data 存在)' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'if [ -d /workspace ] || [ -d /data ]; then' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '    echo "🔧 修复挂载目录权限..."' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '    chmod 777 /workspace /data 2>/dev/null || true' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '    echo "✅ 挂载目录权限已修复"' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'fi' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '# 启动 Clash 代理' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '/usr/local/bin/start-clash.sh || true' >> /usr/local/bin/start-with-xvfb.sh && \
    echo '' >> /usr/local/bin/start-with-xvfb.sh && \
    echo 'exec "$@"' >> /usr/local/bin/start-with-xvfb.sh && \
    chmod +x /usr/local/bin/start-with-xvfb.sh

# Install MCP tools for Claude (as root)
RUN echo "安装 MCP 工具..." && \
    export NVM_DIR="/root/.nvm" && \
    export PATH="$NVM_DIR/versions/node/v22.19.0/bin:$PATH" && \
    if command -v claude >/dev/null 2>&1; then \
        echo "使用 claude 命令安装 MCP 工具..." && \
        claude mcp add --transport sse sse-server https://mcp.deepwiki.com/sse || echo "deepwiki MCP 安装完成" && \
        claude mcp add fs -- npx -y @modelcontextprotocol/server-filesystem /root/app || echo "filesystem MCP 安装完成" && \
        claude add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking || echo "sequential-thinking MCP 安装完成" && \
        claude add morph-fast-apply -- npx -y @morph-llm/morph-fast-apply || echo "morph-fast-apply MCP 安装完成"; \
    else \
        echo "claude 命令不可用，跳过 MCP 工具安装"; \
    fi

# Start Jupyter Lab with Xvfb for browser automation support
# Clash 代理已在启动脚本中自动启动
CMD ["/usr/local/bin/start-with-xvfb.sh", "bash", "-c", "python -m jupyterlab \
     --ip 0.0.0.0 \
     --port 8888 \
     --no-browser \
     --allow-root \
     --ServerApp.token=\"$JUPYTER_TOKEN\" \
     --ServerApp.password='' \
     --ServerApp.disable_check_xsrf=True \
     --ServerApp.allow_origin='*' \
     --ServerApp.allow_credentials=True \
     --ServerApp.terminals_enabled=True \
     --LabApp.news_url=None \
     --LabApp.check_for_updates_class='jupyterlab.NeverCheckForUpdate' \
     --notebook-dir=/data"]
