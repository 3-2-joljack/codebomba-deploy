# codebomba-deploy

코드봄바 LMS 전체를 클라우드 서버 한 대에서 docker compose 로 띄우는 구성.
GitHub Secrets, AWS, ECR 설정이 필요 없다. 서버에서 소스를 직접 빌드한다.

```
브라우저 ─▶ caddy(80/443) ─┬─ /api/*, /uploads/* ─▶ spring(8080) ─┬─▶ mysql, redis
                            └─ 그 외 ─────────────▶ frontend(3000)  ├─▶ python-ai(8000) ─▶ Gemini
                                                                    ├─▶ runner(8080)  학생 코드 채점
                                                                    └─▶ GCS (데이터셋/썸네일/자료)
```

외부로 열리는 포트는 80, 443 뿐이다. mysql, redis, python-ai, runner 는 내부 네트워크에서만 접근된다.

## 준비물

| 항목 | 어디서 | 필수 |
|---|---|---|
| 서버 | Ubuntu, 메모리 4GB 이상(빌드 때문에 8GB 권장), 디스크 20GB, 80/443 개방 | 필수 |
| `GEMINI_API_KEY` | https://aistudio.google.com/apikey | 필수 |
| GCS 버킷 + 서비스 계정 JSON 키 | GCP 콘솔 (아래 참고) | 문제 풀이에 필요 |
| Gmail 주소 + 앱 비밀번호 | 구글 계정 → 보안 → 2단계 인증 → 앱 비밀번호 | 회원가입 인증 메일에 필요 |
| 구글 OAuth 클라이언트 ID/시크릿 | GCP 콘솔 → API 및 서비스 → 사용자 인증 정보 | 선택 (HTTPS 도메인 필요) |
| 도메인 | 서버 IP 로 A 레코드 | 선택 (없으면 http://IP) |

DB 비밀번호, Redis 비밀번호, JWT 키, 내부 API 토큰은 `setup.sh` 가 자동 생성한다.

### GCS 설정

1. 버킷 생성 (리전 asia-northeast3 권장).
2. 서비스 계정 생성 → 버킷에 **Storage 객체 관리자** 역할 부여 → JSON 키 다운로드.
3. 강좌 썸네일은 공개 URL 로 표시된다. 버킷 권한에서 `allUsers` 에 **Storage 객체 뷰어** 를 추가한다.
   (이렇게 하면 데이터셋 파일도 URL 을 아는 사람은 받을 수 있다. 수업용이면 무방하다.)
4. 구글 로그인을 쓸 경우 OAuth 리디렉션 URI: `https://도메인/api/v1/auth/oauth2/callback/google`

## 실행

```bash
git clone https://github.com/3-2-joljack/codebomba-deploy.git && cd codebomba-deploy
./setup.sh                 # 소스 3개 클론 + .env 생성
nano .env                  # 위쪽 빈 값 채우기
nano secrets/gcp-storage-key.json   # GCP 키 JSON 붙여넣기
./up.sh                    # 빌드 + 기동 (첫 빌드 10~20분)
./seed.sh                  # (선택) 테스트 계정, 카테고리, 문제 넣기
```

`.env` 에서 직접 채우는 값:

```
PUBLIC_URL=http://서버IP      # 또는 https://도메인
GEMINI_API_KEY=
GCP_PROJECT_ID=
GCP_STORAGE_BUCKET=
MAIL_USERNAME=
MAIL_PASSWORD=
GOOGLE_CLIENT_ID=             # 선택
GOOGLE_CLIENT_SECRET=         # 선택
```

## 스크립트

| 스크립트 | 하는 일 |
|---|---|
| `setup.sh` | Docker 확인, `repos/` 에 소스 클론(재실행 시 pull), `.env` 생성 |
| `up.sh` | `PUBLIC_URL` 로 프록시/쿠키 설정 계산 → `docker compose up -d --build` → 헬스 대기 |
| `seed.sh` | 레포의 시드 SQL 실행. 계정 비밀번호는 `.env` 의 `SEED_ACCOUNT_PASSWORD` 로 교체해 넣는다 |
| `ingest.sh` | 문제세트 임베딩 인덱스 생성 (개인화 추천용). 문제세트 등록 후 실행 |

소스 업데이트 반영: `./setup.sh && ./up.sh`
로그: `docker compose logs -f spring` (또는 python-ai, frontend, runner)
중지: `docker compose down` (데이터 유지) / `docker compose down -v` (DB 까지 삭제)

## 알아둘 점

- **DB 스키마**는 `DDL_AUTO=update` 로 Hibernate 가 엔티티에서 자동 생성한다. 원본 운영 DB 의 덤프가 없어서 이 방식이다.
- **시드 데이터에는 테스트케이스, 강의, 데이터셋, 힌트, 배지가 없다.** 관리자 계정으로 로그인해 직접 등록해야 문제 채점과 강의 수강이 된다.
- **구글 로그인**은 구글 정책상 공인 IP 주소로는 안 되고 HTTPS 도메인이 필요하다.
- **PUBLIC_URL 을 바꾸면** 프론트엔드를 다시 빌드해야 한다 (`./up.sh` 가 처리).
- **모니터링**(Prometheus/Loki/Grafana)은 이 구성에 넣지 않았다. 필요하면 `codebomba-Monitoring` 을 별도로 붙인다.
- **채점 러너**는 메모리 1GB, CPU 1개, 프로세스 256개로 제한했고 DB 가 있는 네트워크와 분리했다. 그래도 완전한 샌드박스는 아니다.
