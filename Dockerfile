# Use Node.js 18 Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY backend/package*.json ./backend/

# Install dependencies
RUN npm install
RUN cd backend && npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 8000

# Set environment variables
ENV PORT=8000
ENV NODE_ENV=production

# Start the backend server
CMD ["npm", "start"]
