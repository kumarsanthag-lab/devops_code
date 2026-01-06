FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

# npm ci requires package-lock.json
RUN npm ci --omit=dev && npm cache clean --force

COPY . .

EXPOSE 3000

CMD ["npm", "start"]