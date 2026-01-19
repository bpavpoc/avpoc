# Use a lightweight Node.js base
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first to leverage caching
COPY src/package*.json ./

# Install dependencies
RUN npm install

# Copy the source code
COPY src/app.js .

# Expose the internal port
EXPOSE 3000

# Start the application
ENTRYPOINT ["node", "app.js"]