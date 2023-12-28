# Use the official Node.js image as the base image
FROM node:latest

# Set the working directory in the container
WORKDIR /app

# Copy the project files into the container
COPY . /app

# Install project dependencies
RUN npm install

# Build the project
RUN npm run build

# Expose the port the app runs on
EXPOSE 3000

# Start the server
CMD ["npm", "run", "serve"]