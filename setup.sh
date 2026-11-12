#!/usr/bin/env bash
# 최초 1회: Docker 확인, 소스 3개 클론, .env 생성(랜덤 값 자동 채움)
set -euo pipefail
cd "$(dirname "$0")"

ORG="${ORG:-3-2-joljack}"
BRANCH="${BRANCH:-main}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker 가 없습니다. 설치: curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker \$USER (재접속 필요)"
  exit 1
fi
docker compose version >/dev/null

mkdir -p repos secrets
for r in codebomba-LMS-BackEnd codebomba-LMS-FrontEnd codebomba-Python-Server; do
  if [ -d "repos/$r/.git" ]; then
    git -C "repos/$r" pull --ff-only
  else
    git clone --depth 1 --branch "$BRANCH" "https://github.com/$ORG/$r.git" "repos/$r"
  fi
done

rand() { openssl rand -hex "$1"; }

if [ -f .env ]; then
  echo ".env 가 이미 있어 그대로 둡니다."
else
  cp .env.example .env
  {
    echo "DB_NAME=lms"
    echo "DB_USERNAME=lms"
    echo "DB_PASSWORD=$(rand 16)"
    echo "DB_ROOT_PASSWORD=$(rand 16)"
    echo "REDIS_PASSWORD=$(rand 16)"
    echo "JWT_SECRET=$(openssl rand -base64 48 | tr -d '\n')"
    echo "INTERNAL_API_TOKEN=$(rand 32)"
    echo "SEED_ACCOUNT_PASSWORD=Cb$(rand 6)!"
    echo "DDL_AUTO=update"
    echo "GEMINI_MODEL=gemini-3.5-flash"
  } >> .env
  chmod 600 .env
  echo ".env 를 만들었습니다."
fi

cat <<'MSG'

다음 순서:
  1) .env 를 열어 위쪽 값(PUBLIC_URL, GEMINI_API_KEY, GCP_*, MAIL_*)을 채운다
  2) GCP 서비스 계정 키를 secrets/gcp-storage-key.json 으로 저장한다
  3) ./up.sh
  4) (선택) ./seed.sh   테스트 계정과 기본 카테고리/문제 넣기
MSG
