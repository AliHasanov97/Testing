# Testing - ASP.NET MVC Proyekti

Bu sadə .NET 9.0 MVC proyektidir ki VPS-də Docker ilə işləyə bilir.

## Proyekt haqqında

- **.NET Version**: 9.0
- **Framework**: ASP.NET Core MVC
- **Port**: 80 (xarici), 8080 (daxili)

## VPS-də Deploy etmək

### 1. VPS-də tələblər

VPS-nizdə aşağıdakılar quraşdırılmalıdır:
- Docker
- Docker Compose
- Git (proyekti yükləmək üçün)

### 2. Docker quraşdırılması (Ubuntu üçün)

```bash
# Docker quraşdırılması
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose quraşdırılması
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Docker-u sudo olmadan işlətmək üçün
sudo usermod -aG docker $USER
```

### 3. Proyekti VPS-ə yükləmək

```bash
# Proyekt qovluğunu VPS-ə köçürün
# Git ilə və ya FTP/SCP ilə

# Məsələn Git ilə:
git clone <repository-url>
cd Testing
```

### 4. Docker Image yaratmaq və işə salmaq

#### Variant 1: Docker Compose ilə (Tövsiyə olunur)

```bash
# Image yaratmaq və konteyner işə salmaq
docker-compose up -d

# Logları görmək
docker-compose logs -f

# Dayandırmaq
docker-compose down
```

#### Variant 2: Docker komandaları ilə

```bash
# Image yaratmaq
docker build -t testing-app:latest .

# Konteyner işə salmaq
docker run -d \
  --name testing-app \
  -p 80:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  --restart unless-stopped \
  testing-app:latest

# Konteyner statusunu yoxlamaq
docker ps

# Logları görmək
docker logs -f testing-app

# Dayandırmaq
docker stop testing-app
docker rm testing-app
```

### 5. Aplikasiyaya daxil olmaq

VPS işə düşdükdən sonra:
```
http://VPS-IP-ADDRESS
```

Məsələn: `http://192.168.1.100`

### 6. Faydalı Docker komandalar

```bash
# Bütün konteynerlərə baxmaq
docker ps -a

# Logları görmək
docker logs testing-app

# Konteynerə daxil olmaq (debug üçün)
docker exec -it testing-app /bin/bash

# Image-ləri görmək
docker images

# İstifadə olunmayan image-ləri təmizləmək
docker image prune -a
```

## CI/CD ilə Avtomatik Deployment

Proyekt GitHub Actions ilə avtomatik deploy olunar. Hər dəfə `main` branch-a kod push edəndə:

1. ✅ Build və Test
2. ✅ Docker Image yaradılır
3. ✅ VPS-ə avtomatik deploy edilir

### GitHub Secrets Konfiqurasiyası

GitHub repo-nuzda aşağıdakı secrets-ləri əlavə edin:
`Settings → Secrets and variables → Actions → New repository secret`

| Secret Adı | Təsvir | Nümunə |
|------------|--------|---------|
| `VPS_HOST` | VPS IP ünvanı | `192.168.1.100` |
| `VPS_USERNAME` | VPS istifadəçi adı | `ubuntu` |
| `VPS_SSH_KEY` | SSH private key | RSA private key content |
| `VPS_PORT` | SSH port (default: 22) | `22` |

### SSH Key yaratmaq

VPS-də SSH key yaradın və GitHub-a əlavə edin:

```bash
# Local kompüterdə SSH key yaradın
ssh-keygen -t rsa -b 4096 -C "github-actions"

# Public key-i VPS-ə köçürün
ssh-copy-id -i ~/.ssh/id_rsa.pub username@VPS_IP

# Private key-i kopyalayın və GitHub Secrets-ə əlavə edin
cat ~/.ssh/id_rsa
```

### Manual Deployment (deploy.sh ilə)

Avtomatik CI/CD olmadan manual deploy etmək üçün:

```bash
# VPS-də
chmod +x deploy.sh
./deploy.sh
```

### CI/CD Pipeline nə edir?

```
Push to main branch
    ↓
Build .NET Application
    ↓
Run Tests (optional)
    ↓
Build Docker Image
    ↓
Upload to GitHub Artifacts
    ↓
Copy to VPS via SCP
    ↓
Deploy on VPS
    ↓
Verify Deployment
```

### Workflow-u manual işə salmaq

GitHub repo-da: `Actions → CI/CD Pipeline → Run workflow`

## Proyekti yeniləmək

### Avtomatik (CI/CD ilə)
```bash
git add .
git commit -m "Update"
git push origin main
# GitHub Actions avtomatik deploy edəcək
```

### Manual
```bash
# Yeni kod dəyişiklikləri VPS-ə köçürüldükdən sonra:
docker-compose down
docker-compose up -d --build
# və ya
./deploy.sh
```

## Firewall konfiqurasiyası

VPS-də port 80-i açmaq lazımdır:

```bash
# Ubuntu/Debian üçün (UFW)
sudo ufw allow 80/tcp
sudo ufw reload

# və ya iptables ilə
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

## SSL/HTTPS əlavə etmək (Nginx Reverse Proxy ilə)

Production üçün tövsiyə olunur ki Nginx reverse proxy istifadə edib SSL sertifikatı əlavə edəsiniz.

```bash
# Nginx quraşdırılması
sudo apt-get install nginx certbot python3-certbot-nginx

# Nginx konfiqurasiyası /etc/nginx/sites-available/testing
# Let's Encrypt SSL
sudo certbot --nginx -d yourdomain.com
```

## Problemlərin həlli

### Konteyner işləmir?
```bash
docker logs testing-app
docker-compose logs
```

### Port artıq istifadədədir?
```bash
# Port 80-də nə işləyir?
sudo lsof -i :80
sudo netstat -tulpn | grep :80
```

### Image yenidən yaratmaq
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```
