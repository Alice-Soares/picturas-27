FROM node:20

RUN apt-get update \
  && apt-get install -y --no-install-recommends ffmpeg \
  && rm -rf /var/lib/apt/lists/*

workdir /app

copy . .
run npm install

expose 9001
cmd ["npm", "start"]