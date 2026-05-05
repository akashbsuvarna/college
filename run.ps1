# Setup and Runscript for College Management System

Write-Host "Setting up College Management System..." -ForegroundColor Cyan

# Install dependencies in root
npm install

# Setup backend
Write-Host "Setting up Backend..." -ForegroundColor Yellow
cd nodejsss
npm install
if (!(Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "Created .env from .env.example. Please update it with your MongoDB URI." -ForegroundColor Green
}

# Setup frontend
Write-Host "Setting up Frontend..." -ForegroundColor Yellow
cd ../flutter_frontend
flutter pub get

# Run everything
Write-Host "Starting System..." -ForegroundColor Cyan
cd ..
npm run dev
