# Use official Node.js image
FROM node:18

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy backend source code
COPY . .

# Expose port
EXPOSE 3000

# Start backend server
CMD ["npm", "start"]
