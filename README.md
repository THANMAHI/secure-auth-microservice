# Secure Auth Microservice

This project is a containerized security microservice that implements **Public Key Infrastructure (PKI)** and **Two-Factor Authentication (TOTP)**. It demonstrates secure secrets management, cryptographic proof of ownership, and automated background auditing using Docker.

The service securely receives an RSA-encrypted seed, decrypts it using a private key, persists it using Docker volumes, and generates valid time-based authentication codes.

---

## Tech Stack

- **Language:** Python 3.11
- **Framework:** FastAPI / Uvicorn
- **Containerization:** Docker & Docker Compose
- **Cryptography:** RSA-OAEP (4096-bit), RSA-PSS, SHA-256
- **Authentication:** TOTP (RFC 6238) via `pyotp`
- **Automation:** Linux Cron & Bash Scripting

---

## Project Features

- **PKI Encryption:** Securely decrypts seeds using RSA-OAEP with MGF1 padding.
- **2FA Generation:** Generates standard 6-digit TOTP codes updating every 30 seconds.
- **Data Persistence:** Decrypted seeds survive container restarts via Docker Volumes.
- **Automated Auditing:** Background Cron job logs valid codes every minute to `/cron/last_code.txt`.
- **Cryptographic Proof:** Includes tools to sign Git commit hashes (`generate_proof.py`).
- **Secure Architecture:** Multi-stage Docker build with non-root user security.

---

## Architecture

[Image of secure auth microservice architecture]

### 1. Secrets Management
- The `student_private.pem` is loaded securely within the container.
- The encrypted seed is sent via API, decrypted in memory, and stored in the persistent volume `/data/seed.txt`.

### 2. Authentication Flow
- **Input:** Client requests a 2FA code.
- **Process:** The service reads the seed, calculates the HMAC-SHA1 based on the current Unix time, and truncates it to 6 digits.
- **Output:** Returns a JSON response with the valid code.

### 3. Background Task
- A native Linux `cron` daemon runs inside the container.
- Executes `python /cron/log_code.py` every minute.
- Appends the timestamp and generated code to a log file for auditability.

---

## Setup Instructions

### Prerequisites
- Docker Desktop installed and running.
- Git installed.

### 1. Clone the Repository
```bash
git clone [https://github.com/THANMAHI/secure-auth-microservice.git](https://github.com/THANMAHI/secure-auth-microservice.git)
cd secure-auth-microservice
```

### 2. Run with Docker Compose
This command builds the image, sets up the volume, and starts the service on port 8080.
```bash
docker compose up --build
```
Wait for "Application startup complete" in the logs.

## API End points 
The service runs on http://localhost:8080

### 1. Decrypt Seed
POST /decrypt-seed Accepts a Base64-encoded encrypted string.
``` 
Bash

curl -X POST "http://localhost:8080/decrypt-seed" \
     -H "Content-Type: application/json" \
     -d '{"encrypted_seed": "BASE64_STRING..."}'
```
### 2. Generate 2FA
GET /generate-2fa Returns the current valid TOTP code.

```
Bash
curl "http://localhost:8080/generate-2fa"
```

### 3. Verify 2FA
POST /verify-2fa Verifies if a specific code is valid for the current time window.
```
Bash
curl -X POST "http://localhost:8080/verify-2fa" \
     -H "Content-Type: application/json" \
     -d '{"code": "123456"}'
```

## Submission Proof
This repository includes the required cryptographic proof of ownership.

### Generating the Proof
The script generate_proof.py signs the latest Git Commit Hash using the student's private key (RSA-PSS) and encrypts it for the instructor.

To regenerate the proof (requires private keys locally):

```Bash

python generate_proof.py
```

### Verification Files
submission_proof.txt: Contains the encrypted signature.
student_public.pem: The public key used to verify the signature.
encrypted_seed.txt: The original challenge seed.

## Automated Cron Job
To verify the background task is working, you can inspect the container logs while it runs:
```
Bash

docker exec -it secure-auth-app cat /cron/last_code.txt
```

### Submission Checklist
- Repository is Public.

- Docker container runs on port 8080.

- All 3 API endpoints are functional.

- Seed persists after container restart.

- Cron job logs to /cron/last_code.txt every minute.

- generate_proof.py script is included.

- requirements.txt lists all dependencies.