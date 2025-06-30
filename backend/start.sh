#!/bin/sh

# 載入 .env
export $(grep -v '^#' ../.env | xargs)

# 啟動 Gunicorn 用 Uvicorn Worker
gunicorn main:app -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --workers 4
