FROM node:18-alpine
WORKDIR /app
RUN rm -rf .
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]