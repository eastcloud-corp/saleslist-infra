#!/bin/sh
set -e

# Start Next.js in the background
cd /app
pnpm start &

# Wait for Next.js to start
echo "Waiting for Next.js to start..."
sleep 10

# Start nginx in the foreground
echo "Starting nginx..."
nginx -g "daemon off;"