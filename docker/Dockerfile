# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    asciidoctor \
    nodejs \
    npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install livereloadx
RUN npm install -g livereloadx

# Create a non-root user
RUN useradd -ms /bin/bash containeruser

# Create directories for mountpoints
RUN mkdir -p /workspace/input /workspace/output

# Copy the sources to the container
COPY ../src /workspace/src
COPY ../scripts /workspace/scripts

# Set the entrypoint script
RUN find /workspace/src -name "*.sh" -exec chmod +x {} + && \
    find /workspace/scripts -name "*.sh" -exec chmod + {} +

# Set permissions
RUN chown -R containeruser:containeruser /workspace/src /workspace/scripts /workspace/output && \
    chmod -R 755 /workspace/input

USER containeruser
WORKDIR /workspace

# Use the entrypoint script
ENTRYPOINT ["/workspace/src/main.sh"]

