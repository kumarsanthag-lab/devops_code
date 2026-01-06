FROM node:18.20-alpine3.19

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev  --no-fund

COPY . .

EXPOSE 3000

CMD ["npm", "start"]