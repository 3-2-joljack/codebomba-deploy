# codebomba-deploy

코드봄바 LMS 전체를 AWS EC2 한 대에서 docker compose 로 띄우는 구성.
GitHub Secrets, ECR 설정이 필요 없다. 서버에서 소스를 직접 빌드한다.

```
브라우저 ─▶ caddy(80/443) ─┬─ /api/*, /uploads/* ─▶ spring(8080, 호스트 네트워크) ─┬─▶ mysql, redis
                            └─ 그 외 ─────────────▶ frontend(3000)                    ├─▶ python-ai(8000) ─▶ Gemini
                                                                                      ├─▶ runner  학생 코드 채점
                                                                                      └─▶ S3 (데이터셋/썸네일/자료/배지)
```

외부로 열리는 포트는 80, 443 뿐이다. mysql, redis, python-ai, runner 는 서버 로컬(127.0.0.1)에만 바인딩된다.

## 준비물

| 항목 | 어디서 | 필수 |
|---|---|---|
| EC2 | Ubuntu 24.04, 메모리 8GB 권장, 디스크 30GB, 80/443 개방, IMDSv2 필수 | 필수 |
| S3 버킷 + EC2 인스턴스 역할 | 버킷에 Get/Put/Delete 권한을 가진 역할을 인스턴스에 연결 | 필수 |
| `GEMINI_API_KEY` | https://aistudio.google.com/apikey | 필수 |
| Gmail 주소 + 앱 비밀번호 | 구글 계정 → 보안 → 2단계 인증 → 앱 비밀번호 | 회원가입 인증 메일에 필요 |
| 구글 OAuth 클라이언트 ID/시크릿 | 구글 클라우드 콘솔 → 사용자 인증 정보 | 선택 (HTTPS 도메인 필요) |
| 도메인 | 서버 IP 로 A 레코드 | 선택 (없으면 http://IP) |

DB 비밀번호, Redis 비밀번호, JWT 키, 내부 API 토큰은 `setup.sh` 가 자동 생성한다.

### 파일 저장소 (S3)

- 키 파일이 없다. spring 이 EC2 인스턴스 역할의 임시 자격 증명으로 S3 에 접근한다.
- spring 만 호스트 네트워크로 띄운다. 인스턴스 메타데이터(IMDSv2, 홉 제한 1)는 브리지 컨테이너에서
  닿지 않으므로, 학생 코드를 실행하는 runner 가 역할 자격 증명을 훔칠 수 없다.
- 버킷 정책은 `course_thumbnail_images/*` 만 공개 읽기다. 데이터셋, 강의자료, 배지는 비공개이고
  서버가 발급하는 서명 URL(1~30분)로만 내려받는다.
- 기본 버킷은 `codebomba-lms-379959319287` (서울). 바꾸려면 `.env` 에 `S3_BUCKET`, `AWS_REGION` 을 적는다.

## 실행

```bash
git clone https://github.com/3-2-joljack/codebomba-deploy.git && cd codebomba-deploy
./setup.sh                 # 소스 3개 클론 + .env 생성
nano .env                  # 위쪽 빈 값 채우기
./up.sh                    # 빌드 + 기동 (첫 빌드 10~20분)
./seed.sh                  # (선택) 테스트 계정, 카테고리, 문제 넣기
```

`.env` 에서 직접 채우는 값:

```
PUBLIC_URL=http://서버IP      # 또는 https://도메인
GEMINI_API_KEY=
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
| `aws/power.sh` | (내 컴퓨터에서) 서버 중지/시작/상태 |
| `aws/teardown.sh` | (내 컴퓨터에서) AWS 과금 자원 전체 삭제. 인자 없이 실행하면 조회만 |

소스 업데이트 반영: `./setup.sh && ./up.sh`
로그: `docker compose logs -f spring` (또는 python-ai, frontend, runner)
중지: `docker compose down` (데이터 유지) / `docker compose down -v` (DB 까지 삭제)

## 알아둘 점

- **DB 스키마**는 `DDL_AUTO=update` 로 Hibernate 가 엔티티에서 자동 생성한다.
- **시드 데이터에는 테스트케이스, 강의, 데이터셋, 힌트, 배지가 없다.** 관리자 계정으로 직접 등록해야 채점과 수강이 된다.
- **구글 로그인**은 공인 IP 주소로는 안 되고 HTTPS 도메인이 필요하다.
- **PUBLIC_URL 이나 S3_BUCKET 을 바꾸면** 프론트엔드를 다시 빌드해야 한다 (`./up.sh` 가 처리).
- **모니터링**(Prometheus/Loki/Grafana)은 이 구성에 넣지 않았다.
- **채점 러너**는 메모리 1GB, CPU 1개, 프로세스 256개로 제한했고 DB 가 있는 네트워크와 분리했다. 완전한 샌드박스는 아니다.
