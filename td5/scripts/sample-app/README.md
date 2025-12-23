# Sample App

This small Node/Express sample app is used for the "Fundamentals of DevOps and Software Delivery" lab.

Quick instructions (Windows / PowerShell):

1. Install dependencies

```powershell
cd 'C:\Users\zebul\Documents\GitHub\DevOps\td5\scripts\sample-app'
npm install
```

2. Run tests

```powershell
npm test
```

This project uses `jest` and `supertest` for tests.

3. Build Docker image (on a machine with Docker, or in WSL/Git Bash):

```bash
cd td5/scripts/sample-app
./build-docker-image.sh
```

`build-docker-image.sh` builds multi-arch images using `docker buildx`.

4. CI / GitHub Actions

- Tests are run in `.github/workflows/app-tests.yml` on `push` and can be triggered manually in the Actions UI (`workflow_dispatch`).
- Infrastructure tests use `.github/workflows/infra-tests.yml` and expect the repo secret `AWS_ROLE_TO_ASSUME` to be set with the IAM role ARN to assume.

Notes

- Make sure Node.js (and npm) is installed locally to run tests.
- The repository `.gitignore` ignores Terraform state files and `node_modules` to avoid committing local state.
