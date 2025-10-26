# Use Node.js 18 Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy root package.json
COPY package.json ./

# Copy backend package files
COPY backend/package*.json ./backend/

# Install root dependencies (if any)
RUN npm install

# Install backend dependencies
RUN cd backend && npm install

# Copy backend source code
COPY backend/ ./backend/

# Expose port
EXPOSE 8000

# Set environment variables
ENV PORT=8000
ENV NODE_ENV=production

# Start the backend server
CMD ["npm", "start"]
