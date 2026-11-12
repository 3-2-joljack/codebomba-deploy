#!/usr/bin/env bash
# 초기 데이터 넣기. 백엔드가 한 번 떠서 테이블을 만든 뒤에 실행한다. 여러 번 실행해도 된다.
#   1) 테스트 계정 26개 (비밀번호는 .env 의 SEED_ACCOUNT_PASSWORD)
#   2) 강좌 카테고리
#   3) 콘텐츠: 강좌 3개, 강의 12개, 문제세트 7개(문제 33개), 테스트케이스, 힌트, 데이터셋
set -euo pipefail
cd "$(dirname "$0")"
val() { grep -E "^$1=" .env | tail -1 | cut -d= -f2- | tr -d '\r'; }

DB_NAME="$(val DB_NAME)"; ROOT_PW="$(val DB_ROOT_PASSWORD)"; SEED_PW="$(val SEED_ACCOUNT_PASSWORD)"
RES=repos/codebomba-LMS-BackEnd/src/main/resources

# bcrypt 해시 생성 ($2y → $2a, Spring BCrypt 호환)
HASH="$(docker run --rm httpd:2.4-alpine htpasswd -nbBC 10 "" "$SEED_PW" | tr -d ':\n' | sed 's/^\$2y\$/$2a$/')"
[ "${#HASH}" -eq 60 ] || { echo "bcrypt 해시 생성 실패"; exit 1; }

run_sql() { docker compose exec -T mysql mysql --default-character-set=utf8mb4 -uroot -p"$ROOT_PW" "$DB_NAME"; }

echo "[1/3] 계정"
HASH="$HASH" perl -pe 's/\$2a\$10\$[.\/0-9A-Za-z]{53}/$ENV{HASH}/g' "$RES/db/seed/00_users.sql" | run_sql
echo "[2/3] 강좌 카테고리";  run_sql < "$RES/db/seed/10_course_category.sql"
echo "[3/3] 강좌, 강의, 문제"; run_sql < content/content.sql

echo "백엔드 캐시를 비우기 위해 재시작합니다..."
docker compose restart spring >/dev/null
for i in $(seq 1 36); do
  docker compose exec -T caddy wget -qO- http://spring:8080/actuator/health 2>/dev/null | grep -q '"UP"' && break
  sleep 5
done

echo "추천용 인덱스를 만듭니다 (실패해도 서비스에는 지장 없음)..."
./ingest.sh >/dev/null 2>&1 && echo "인덱스 생성 완료" || echo "인덱스 생성 건너뜀 — 나중에 ./ingest.sh 로 다시 시도할 수 있습니다"

cat <<MSG

완료.
  관리자 로그인  admin@test.com   (마스터 master@test.com, 운영자 op@test.com)
  학생 로그인    u01@test.com ~ u18@test.com
  비밀번호       .env 의 SEED_ACCOUNT_PASSWORD  →  grep SEED_ACCOUNT_PASSWORD .env
MSG
