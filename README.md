# CI/CD for React.js and Nest.js Project Deployment on AWS using GitHub Actions

## Overview

This repository contains the configuration for setting up a Continuous Integration (CI) and Continuous Deployment (CD) pipeline using GitHub Actions. The pipeline automates the deployment of a React.js frontend and a Nest.js backend on the same server, both hosted with PM2, and uses Nginx as a reverse proxy to route traffic to the appropriate PM2 processes.

## Project Structure

- `frontend-repo`: Contains the React.js frontend code.
- `backend-repo`: Contains the Nest.js backend code.
- `.github/workflows/`: Contains GitHub Actions workflow configuration in each repo.

## Prerequisites

Ensure the following prerequisites are met before setting up the pipeline:

1. **AWS Server Setup**: Set up an AWS server with PM2 and Nginx installed.

2. **SSH Key**: Add your SSH key to the server for authentication.

3. **GitHub Secrets**: Configure the following secrets in your Both GitHub repository settings:
    - `AWS_SERVER_IP`: Your AWS server's IP address.
    - `AWS_SSH_PRIVATE_KEY`: Your SSH private key.

## Step-by-Step Guide

### 1. Fork this repository

Fork this repository to your GitHub account.

### 2. Set up GitHub Secrets

In your forked repository settings, go to "Settings" > "Secrets" and add the following secrets:
   - `AWS_SERVER_IP`: Your AWS server's IP address.
   - `AWS_SSH_PRIVATE_KEY`: Your SSH private key.

### 3. Configure Front-end Deployment

Update the deployment scripts and configurations for the React.js frontend in the `.github/workflows/frontend.yml` file in the frontend repo.

```yml
name: React CI/CD

on:
  push:
    branches:
      - ci/cd-main
  pull_request:
    branches:
      - main
    types:
      - closed
  workflow_dispatch:

jobs:
  CI:
    runs-on: ubuntu-latest
    env:
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      SERVER_USER: ${{ secrets.SERVER_USER }}
      SERVER_IP: ${{ secrets.SERVER_IP }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Set Up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 17
      - name: Install Dependencies
        run: npm install --force
      - name: Build React App
        run: npm run build:n17
        env:
          CI: false
      - name: Zip Build Folder
        run: zip -r build.zip ./build
      - name: Zip Node Modules
        run: zip -r node.zip ./node_modules
      - name: Copy Build files to the server
        run: |
          mkdir -p /home/runner/.ssh
          printf "%s" "${{ secrets.SSH_PRIVATE_KEY }}" > /home/runner/.ssh/RealDeal1112023.pem
          chmod 700 /home/runner/.ssh
          chmod 600 /home/runner/.ssh/RealDeal1112023.pem
          scp -Tv -i /home/runner/.ssh/RealDeal1112023.pem -o StrictHostKeyChecking=no build.zip node.zip package-lock.json package.json $SERVER_USER@$SERVER_IP:/tmp/fe/
        shell: bash
        env:
          SERVER_USER: ${{ secrets.SERVER_USER }}
          SERVER_IP: ${{ secrets.SERVER_IP }}
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
  CD:
    runs-on: ubuntu-latest
    needs: CI
    env:
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      SERVER_USER: ${{ secrets.SERVER_USER }}
      SERVER_IP: ${{ secrets.SERVER_IP }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Set Up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 18
      - name: Install npm
        run: |
          export NVM_DIR="$HOME/.nvm"
          [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
          nvm install 18
          nvm use 18
      - name: install PM2
        run: npm install pm2 --location=global
      - name: Deploy to Server
        run: |
          mkdir -p /home/runner/.ssh
          printf "%s" "${{ secrets.SSH_PRIVATE_KEY }}" > /home/runner/.ssh/RealDeal1112023.pem
          chmod 700 /home/runner/.ssh
          chmod 600 /home/runner/.ssh/RealDeal1112023.pem
          SERVER_PATH=/root/
          chmod +x ./.github/workflows/react.sh
          ssh -Tv -i /home/runner/.ssh/RealDeal1112023.pem -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP 'bash -s' < ./.github/workflows/react.sh
        shell: bash
        env:
          SERVER_USER: ${{ secrets.SERVER_USER }}
          SERVER_IP: ${{ secrets.SERVER_IP }}
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      
```
#### Add the Bassh script in same location

```bash
#!/bin/bash


set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18
export PATH=/home/ubuntu/.nvm/versions/node/v18.10.0/bin:$PATH
cd realdeal-fe/
rm -rf build2
mv build1/ build2/
mv build/ build1/
cp -r /tmp/fe/build.zip .
cp -r /tmp/fe/node.zip .
cp -r /tmp/fe/package-lock.json .
cp -r /tmp/fe/package.json .
unzip build.zip
unzip node.zip
rm -rf dist.zip
rm -rf node.zip
pm2 restart forntend
pm2 status
```
### 4. Configure Back-end Deployment

Update the deployment scripts and configurations for the Nest.js backend in the `.github/workflows/backend.yml` file.

```yml
name: React CI/CD

on:
  push:
    branches:
      - ci/cd-main
  pull_request:
    branches:
      - main
    types:
      - closed
  workflow_dispatch:

jobs:
  CI:
    runs-on: ubuntu-latest
    env:
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      SERVER_USER: ${{ secrets.SERVER_USER }}
      SERVER_IP: ${{ secrets.SERVER_IP }}
      REACT_APP_S3_ACCESS_KEY_ID: ${{ secrets.REACT_APP_S3_ACCESS_KEY_ID }}
      REACT_APP_S3_SECRET_ACCESS_KEY: ${{ secrets.REACT_APP_S3_SECRET_ACCESS_KEY }}
      REACT_APP_S3_REGION: ${{ secrets.REACT_APP_S3_REGION }}
      REACT_APP_S3_BUCKET: ${{ secrets.REACT_APP_S3_BUCKET }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Set Up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 17
      - name: Create .env File
        run: |
          echo "REACT_APP_S3_ACCESS_KEY_ID=${{ secrets.REACT_APP_S3_ACCESS_KEY_ID }}" > .env
          echo "REACT_APP_S3_SECRET_ACCESS_KEY=${{ secrets.REACT_APP_S3_SECRET_ACCESS_KEY }}" >> .env
          echo "REACT_APP_S3_REGION=${{ secrets.REACT_APP_S3_REGION }}" >> .env
          echo "REACT_APP_S3_BUCKET=${{ secrets.REACT_APP_S3_BUCKET }}" >> .env
      - name: Install Dependencies
        run: npm install --force
      - name: Build Nest App
        run: npm run build
        env:
          CI: false
       - name: Run test
         run: npm run test:e2e
      - name: Zip Dist Folder
        run: zip -r dist.zip ./dist
      - name: Zip node Modules
        run: zip -r node.zip node_modules
      - name: Copy Build files to the server
        run: |
          mkdir -p /home/runner/.ssh
          printf "%s" "${{ secrets.SSH_PRIVATE_KEY }}" > /home/runner/.ssh/RealDeal1112023.pem
          chmod 700 /home/runner/.ssh
          chmod 600 /home/runner/.ssh/RealDeal1112023.pem
          scp -Tv -i /home/runner/.ssh/RealDeal1112023.pem -o StrictHostKeyChecking=no dist.zip node.zip package-lock.json package.json $SERVER_USER@$SERVER_IP:/tmp/be/
        shell: bash
        env:
          SERVER_USER: ${{ secrets.SERVER_USER }}
          SERVER_IP: ${{ secrets.SERVER_IP }}
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
  CD:
    runs-on: ubuntu-latest
    needs: CI
    env:
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      SERVER_USER: ${{ secrets.SERVER_USER }}
      SERVER_IP: ${{ secrets.SERVER_IP }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Set Up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: 18
      - name: Install npm
        run: |
          export NVM_DIR="$HOME/.nvm"
          [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
          nvm install 18
          nvm use 18
      - name: install PM2
        run: npm install pm2 --location=global
      - name: Deploy to Server
        run: |
          mkdir -p /home/runner/.ssh
          printf "%s" "${{ secrets.SSH_PRIVATE_KEY }}" > /home/runner/.ssh/RealDeal1112023.pem
          chmod 700 /home/runner/.ssh
          chmod 600 /home/runner/.ssh/RealDeal1112023.pem
          SERVER_PATH=/root/
          chmod +x ./.github/workflows/nest.sh
          ssh -Tv -i /home/runner/.ssh/RealDeal1112023.pem -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP 'bash -s' < ./.github/workflows/nest.sh
        shell: bash
        env:
          SERVER_USER: ${{ secrets.SERVER_USER }}
          SERVER_IP: ${{ secrets.SERVER_IP }}
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

#### Add the Bassh script in same location

```bash
#!/bin/bash


set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18
export PATH=/home/ubuntu/.nvm/versions/node/v18.10.0/bin:$PATH
cd realdeal-be/
rm -rf dist2
mv dist1/ dist2/
mv dist/ dist1/
cp -r /tmp/be/dist.zip .
cp -r /tmp/be/node.zip .
cp -r /tmp/be/package-lock.json .
cp -r /tmp/be/package.json .
unzip dist.zip
unzip node.zip
rm -rf dist.zip
rm -rf node.zip
pm2 restart 0
pm2 status
```

### 5. Customize Nginx Configuration

Update the Nginx configuration on your AWS server to reflect the correct paths and server names. Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name your_domain.com;

    location / {
        proxy_pass http://localhost:3000; # Adjust the port for your React.js app
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:5000; # Adjust the port for your Nest.js app
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 6. Commit and Push
Commit your changes and push them to trigger the GitHub Actions workflows.

### 7. Monitor Deployment
Monitor the workflow execution in the Actions tab of your GitHub repository.

## Disclaimer
This setup is a Proof of Concept (POC), and security considerations, such as proper authentication and authorization, are not fully implemented in this example. Ensure to follow security best practices and customize the deployment scripts based on your project requirements.

Feel free to reach out for any questions or improvements!
