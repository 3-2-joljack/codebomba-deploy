#!/usr/bin/env bash
# 레포에 들어 있는 초기 데이터 넣기 (테스트 계정 26개, 강좌 카테고리, 강좌 2개, 문제 카테고리/세트/문제).
# 백엔드가 한 번 떠서 테이블을 만든 뒤에 실행한다. 계정 비밀번호는 .env 의 SEED_ACCOUNT_PASSWORD 로 바꿔 넣는다.
set -euo pipefail
cd "$(dirname "$0")"
val() { grep -E "^$1=" .env | tail -1 | cut -d= -f2- | tr -d '\r'; }

DB_NAME="$(val DB_NAME)"; ROOT_PW="$(val DB_ROOT_PASSWORD)"; SEED_PW="$(val SEED_ACCOUNT_PASSWORD)"
RES=repos/codebomba-LMS-BackEnd/src/main/resources

# bcrypt 해시 생성 ($2y → $2a, Spring BCrypt 호환)
HASH="$(docker run --rm httpd:2.4-alpine htpasswd -nbBC 10 "" "$SEED_PW" | tr -d ':\n' | sed 's/^\$2y\$/$2a$/')"
[ "${#HASH}" -eq 60 ] || { echo "bcrypt 해시 생성 실패"; exit 1; }

run_sql() { docker compose exec -T mysql mysql --default-character-set=utf8mb4 -uroot -p"$ROOT_PW" "$DB_NAME"; }

echo "[1/4] users"
HASH="$HASH" perl -pe 's/\$2a\$10\$[.\/0-9A-Za-z]{53}/$ENV{HASH}/g' "$RES/db/seed/00_users.sql" | run_sql
echo "[2/4] course_category";  run_sql < "$RES/db/seed/10_course_category.sql"
echo "[3/4] course";           run_sql < "$RES/db/seed/20_course.sql"
echo "[4/4] problems";         run_sql < "$RES/sql/problems.sql"

echo "완료. 로그인 예: master@test.com / admin@test.com, 비밀번호는 .env 의 SEED_ACCOUNT_PASSWORD"
