FROM node:latest

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && apt-get update && apt-get install -y google-chrome-stable libxss1 jq && rm -rf /var/lib/apt/lists/*

RUN npm install -g pa11y-ci@3.1.0 puppeteer

COPY config.json /pa11y-configs/.pa11yci

COPY gitlab-accessibility.sh /gitlab-accessibility.sh