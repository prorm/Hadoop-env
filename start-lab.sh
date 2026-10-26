#!/bin/sh
# Mac / Linux: ./start-lab.sh   (opens a lab terminal; run again for another terminal)
cd "$(dirname "$0")" || exit 1
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Start Docker Desktop, wait for 'Engine running', then try again."; exit 1
fi
IMG="$(docker compose config --images lab 2>/dev/null)"
if ! docker image inspect "$IMG" > /dev/null 2>&1; then
    echo "First run: getting the lab ready (about 1 GB, 5-10 minutes, one time only)..."
    case "$IMG" in
        */*) docker compose pull lab || docker compose build lab || exit 1 ;;
        *)   docker compose build lab || exit 1 ;;
    esac
fi
docker compose up -d lab || exit 1
exec docker compose exec lab bash
