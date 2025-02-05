FROM node:lts AS builder

# build deepseek-free-api
WORKDIR /deepseek-free-api
COPY ./deepseek-free-api /deepseek-free-api
RUN sed -i 's/port: 8000/port: 7001/' /deepseek-free-api/configs/dev/service.yml
RUN yarn install && yarn run build

# build kimi-free-api
WORKDIR /kimi-free-api
COPY ./kimi-free-api /kimi-free-api
RUN sed -i 's/port: 8000/port: 7002/' /kimi-free-api/configs/dev/service.yml
RUN yarn install && yarn run build

# build qwen-free-api
WORKDIR /qwen-free-api
COPY ./qwen-free-api /qwen-free-api
RUN sed -i 's/port: 8000/port: 7003/' /qwen-free-api/configs/dev/service.yml
RUN yarn install && yarn run build

# build doubao-free-api
WORKDIR /doubao-free-api
COPY ./doubao-free-api /doubao-free-api
RUN sed -i 's/port: 8000/port: 7004/' /doubao-free-api/configs/dev/service.yml
RUN yarn install && yarn run build

# build minimax-free-api
WORKDIR /minimax-free-api
COPY ./minimax-free-api /minimax-free-api
RUN sed -i 's/port: 8000/port: 7005/' /minimax-free-api/configs/dev/service.yml
RUN yarn install && yarn run build

# runner
FROM node:lts-alpine AS runner

RUN apk update && apk add --no-cache bash caddy
RUN npm i -g pm2 --registry https://registry.npmmirror.com/

# caddy
COPY ./configs/Caddyfile /etc/caddy/Caddyfile

# deepseek-free-api
COPY --from=builder /deepseek-free-api/configs /deepseek-free-api/configs
COPY --from=builder /deepseek-free-api/package.json /deepseek-free-api/package.json
COPY --from=builder /deepseek-free-api/dist /deepseek-free-api/dist
COPY --from=builder /deepseek-free-api/public /deepseek-free-api/public
COPY --from=builder /deepseek-free-api/*.wasm /deepseek-free-api/
COPY --from=builder /deepseek-free-api/node_modules /deepseek-free-api/node_modules

# kimi-free-api
COPY --from=builder /kimi-free-api/configs /kimi-free-api/configs
COPY --from=builder /kimi-free-api/package.json /kimi-free-api/package.json
COPY --from=builder /kimi-free-api/dist /kimi-free-api/dist
COPY --from=builder /kimi-free-api/public /kimi-free-api/public
COPY --from=builder /kimi-free-api/*.wasm /kimi-free-api/
COPY --from=builder /kimi-free-api/node_modules /kimi-free-api/node_modules

# qwen-free-api
COPY --from=builder /qwen-free-api/configs /qwen-free-api/configs
COPY --from=builder /qwen-free-api/package.json /qwen-free-api/package.json
COPY --from=builder /qwen-free-api/dist /qwen-free-api/dist
COPY --from=builder /qwen-free-api/public /qwen-free-api/public
COPY --from=builder /qwen-free-api/*.wasm /qwen-free-api/
COPY --from=builder /qwen-free-api/node_modules /qwen-free-api/node_modules

# doubao-free-api
COPY --from=builder /doubao-free-api/configs /doubao-free-api/configs
COPY --from=builder /doubao-free-api/package.json /doubao-free-api/package.json
COPY --from=builder /doubao-free-api/dist /doubao-free-api/dist
COPY --from=builder /doubao-free-api/public /doubao-free-api/public
COPY --from=builder /doubao-free-api/*.wasm /doubao-free-api/
COPY --from=builder /doubao-free-api/node_modules /doubao-free-api/node_modules

# minimax-free-api
COPY --from=builder /minimax-free-api/configs /minimax-free-api/configs
COPY --from=builder /minimax-free-api/package.json /minimax-free-api/package.json
COPY --from=builder /minimax-free-api/dist /minimax-free-api/dist
COPY --from=builder /minimax-free-api/public /minimax-free-api/public
COPY --from=builder /minimax-free-api/*.wasm /minimax-free-api/
COPY --from=builder /minimax-free-api/node_modules /minimax-free-api/node_modules

WORKDIR /

COPY ./scripts/start.sh /bin/start.sh
RUN chmod +x /bin/start.sh

EXPOSE 7001
EXPOSE 7002
EXPOSE 7003
EXPOSE 7004
EXPOSE 7005

CMD ["/bin/start.sh"]
