FROM node:18-alpine3.19
WORKDIR /app
COPY package.json ./
RUN npm install
RUN rm -rf node_modules package-lock.json
RUN npm update express
COPY . .
EXPOSE 3000
CMD ["npm", "start"]