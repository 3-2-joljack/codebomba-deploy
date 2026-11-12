#!/usr/bin/env bash
# 빌드 후 전체 기동. PUBLIC_URL 에서 프록시 주소와 쿠키 보안 설정을 계산한다.
set -euo pipefail
cd "$(dirname "$0")"

[ -f .env ] || { echo ".env 가 없습니다. 먼저 ./setup.sh"; exit 1; }
val() { grep -E "^$1=" .env | tail -1 | cut -d= -f2- | tr -d '\r'; }

PUBLIC_URL="$(val PUBLIC_URL)"; PUBLIC_URL="${PUBLIC_URL%/}"
[ -n "$PUBLIC_URL" ] || { echo "PUBLIC_URL 이 비어 있습니다 (.env)"; exit 1; }
[ -n "$(val GEMINI_API_KEY)" ] || { echo "GEMINI_API_KEY 가 비어 있습니다 (.env)"; exit 1; }

case "$PUBLIC_URL" in
  https://*) export SITE_ADDRESS="${PUBLIC_URL#https://}"; export COOKIE_SECURE=true ;;
  http://*)  export SITE_ADDRESS=":80";                    export COOKIE_SECURE=false ;;
  *) echo "PUBLIC_URL 은 http:// 또는 https:// 로 시작해야 합니다"; exit 1 ;;
esac
export PUBLIC_URL

[ -s secrets/gcp-storage-key.json ] || echo "경고: secrets/gcp-storage-key.json 없음 → 데이터셋/썸네일/강의자료 업로드가 실패합니다"
[ -n "$(val MAIL_PASSWORD)" ]       || echo "경고: MAIL_* 없음 → 회원가입 인증 메일이 발송되지 않습니다"
[ -n "$(val GOOGLE_CLIENT_ID)" ]    || echo "참고: GOOGLE_CLIENT_* 없음 → 구글 로그인 비활성"

docker compose up -d --build "$@"

echo "백엔드 기동 대기 중 (최대 5분)..."
for i in $(seq 1 60); do
  if docker compose exec -T caddy wget -qO- http://spring:8080/actuator/health 2>/dev/null | grep -q '"UP"'; then
    echo "OK: $PUBLIC_URL 에서 접속할 수 있습니다."
    exit 0
  fi
  sleep 5
done
echo "백엔드가 아직 UP 이 아닙니다. 로그: docker compose logs --tail 100 spring"
exit 1
