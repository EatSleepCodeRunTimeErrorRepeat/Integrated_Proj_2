FROM node:20
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
# Use the following command to build the Docker image