# Use Node.js 18 Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy backend package files
COPY backend/package*.json ./

# Install backend dependencies
RUN npm install

# Copy backend source code
COPY backend/ ./

# Expose port
EXPOSE 8000

# Set environment variables
ENV PORT=8000
ENV NODE_ENV=production

# Start the backend server directly
CMD ["node", "server.js"]
