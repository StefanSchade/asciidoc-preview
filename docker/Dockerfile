# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    asciidoctor \
    file \
    dos2unix \
    nodejs \
    curl \
    npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install livereloadx
RUN npm install -g livereloadx

# Create a non-root user
RUN useradd -ms /bin/bash containeruser

# Create directories for mountpoints and logs
RUN mkdir -p /workspace/input 

# Copy the sources to the container
COPY ../src /workspace/src
COPY ../scripts /workspace/scripts

# Convert line endings of all scripts
RUN find /workspace/src -type f -name "*.sh" -exec dos2unix {} \; && \
    find /workspace/scripts -type f -name "*.sh" -exec dos2unix {} \;

# Give containeruser ownership and access to the workspace
RUN chown -R containeruser:containeruser /workspace && \
    chmod -R 755 /workspace

# But make the input directory read only
RUN chmod -R 755 /workspace/input && \
    chown -R root:root /workspace/input

USER containeruser

WORKDIR /workspace

# Use the entrypoint script
ENTRYPOINT ["/workspace/src/main.sh"]

