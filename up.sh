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

if [ "$(val EMAIL_VERIFICATION_ENABLED)" = "true" ]; then
  [ -n "$(val MAIL_PASSWORD)" ] || echo "경고: 이메일 인증이 켜져 있는데 MAIL_* 가 없습니다 → 가입과 학생 로그인이 막힙니다"
else
  echo "참고: 이메일 인증 꺼짐 → 인증번호 없이 가입, 새 기기에서도 바로 로그인 (비밀번호 찾기 메일은 MAIL_* 필요)"
fi
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
