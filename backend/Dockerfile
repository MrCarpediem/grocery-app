# Multi-stage build for backend
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install dumb-init to handle signals properly
RUN apk add --no-cache dumb-init

# Copy built app from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/ ./

# Create uploads directory
RUN mkdir -p /app/uploads

# Expose port
EXPOSE 5000

# Use dumb-init as entrypoint to handle signals
ENTRYPOINT ["dumb-init", "--"]

# Start server
CMD ["node", "index.js"]
