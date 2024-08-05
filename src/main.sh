#!/bin/bash

# Handle SIGINT and SIGTERM signals
cleanup() {
   echo "Received signal, shutting down..."
   exit 0
}

trap cleanup SIGINT SIGTERM

# Main function
main() {
   echo "hello"
}

# Execute main
main

