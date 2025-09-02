#!/bin/bash
set -e
ALB_DNS="$1"
if [ -z "$ALB_DNS" ]; then
  echo "Usage: ./health-check.sh <alb-dns>"
  exit 1
fi
echo "Checking health at http://$ALB_DNS/health"
curl -f -s "http://$ALB_DNS/health" && echo "OK" || (echo "Health check failed" && exit 2)
