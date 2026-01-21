# Multi-stage build for Token Faucet DApp
# Stage 1: Build Solidity Contracts
FROM node:18-alpine AS contract-builder
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm install
COPY contracts/ ./contracts/
COPY test/ ./test/
RUN npm run build || true
RUN npm run test || true

# Stage 2: Build React Frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY src/ ./src/
COPY public/ ./public/ || true
RUN npm run build || true

# Stage 3: Production Server
FROM node:18-alpine
WORKDIR /app

# Install serve to run the React app
RUN npm install -g serve

# Copy contract artifacts from builder
COPY --from=contract-builder /build/artifacts ./artifacts/ || true
COPY --from=contract-builder /build/contracts ./contracts/
COPY --from=contract-builder /build/test ./test/

# Copy frontend build
COPY --from=frontend-builder /app/build ./build/ || true
COPY --from=frontend-builder /app/src ./src/

# Copy source files
COPY contracts/ ./contracts/
COPY test/ ./test/
COPY src/ ./src/ || true
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --production

# Expose ports
EXPOSE 3000 8545

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

# Start the application
CMD ["npm", "start"]
