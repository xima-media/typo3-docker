FROM mcr.microsoft.com/playwright:v1.59.1-noble@sha256:b0ab6f3cb99aa7803adbc14d9027ec1785fc6e433b97e134e0f8fe61683b6b53

WORKDIR /deps
COPY package*.json ./
RUN npm install --ignore-scripts --allow-git=none

ENV PATH="/deps/node_modules/.bin:$PATH"
ENV NODE_PATH="/deps/node_modules"

WORKDIR /app
CMD ["playwright", "test", "--config", "/app/Tests/playwright/playwright.config.js"]
