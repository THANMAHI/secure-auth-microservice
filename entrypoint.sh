#!/bin/sh

# Start the cron service
service cron start

# Start the FastAPI application
# exec ensures the app receives signals (like Stop)
exec uvicorn app.main:app --host 0.0.0.0 --port 8080