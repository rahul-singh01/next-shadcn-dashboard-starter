# Dockerfile for package.json

# Use the official Node.js image as the base image
FROM node:14-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and pnpm-lock.yaml files to the working directory
COPY package.json pnpm-lock.yaml ./

# Install the dependencies
RUN npm install -g pnpm
RUN pnpm install

# Copy the rest of the application code to the working directory
COPY . .

# Build the Next.js application
RUN pnpm build

# Use a smaller base image for the final stage
FROM node:14-alpine AS runner

# Set the working directory in the container
WORKDIR /app

# Copy the built application code from the builder stage to the runner stage
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Expose the port that the Next.js application will run on
EXPOSE 3000

# Define the command to run the Next.js application
CMD ["pnpm", "start"]