# ---- Stage 1: Build Environment ----
# Use a full Node.js image to install all dependencies and build the app
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copy package files and install ALL dependencies (including dev)
COPY package*.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Generate the Prisma Client
RUN npx prisma generate

# Transpile TypeScript to JavaScript into the /dist folder
RUN npm run build


# ---- Stage 2: Production Environment ----
# Use a lightweight, secure base image for the final container
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy only the production package files from the builder stage
COPY --from=builder /usr/src/app/package*.json ./

# Install ONLY production dependencies
RUN npm install --omit=dev

# Copy the compiled code and the generated Prisma client from the builder stage
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma

# Expose the port the app runs on
EXPOSE 8000

# The command to start the app (pointing to the correct path)
CMD [ "node", "dist/src/index.js" ]