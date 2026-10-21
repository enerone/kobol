FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.163.0

RUN npm install --global "@openai/codex@${CODEX_VERSION}" \
    && npm cache clean --force \
    && mkdir -p /run/codex-appserver /home/node/.codex \
    && chown -R node:node /run/codex-appserver /home/node/.codex

WORKDIR /home/node
