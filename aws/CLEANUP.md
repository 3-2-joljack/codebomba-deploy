# 졸작 종료 후 정리 체크리스트

## 1. AWS (계정 379959319287, 프로필 qrto, 서울 리전) — 스크립트로 한 번에

```bash
./aws/teardown.sh            # 삭제 대상 조회만
./aws/teardown.sh --delete   # 실제 삭제 (delete 입력 확인)
```

| 자원 | 식별자 | 과금 |
|---|---|---|
| EC2 `codebomba-server` | i-06f2e1835d41125dd (m7i-flex.large) | 켜져 있는 시간만큼 |
| 디스크 gp3 30GB | vol-0b56d9c342ec87f27 | 중지 중에도 과금 |
| 탄력적 IP | 16.184.57.207 (eipalloc-070edd4d8e5d6b765) | 항상 과금. 인스턴스만 지우면 남는다 |
| S3 버킷 `codebomba-lms-379959319287` | | 저장 용량만큼 (소액) |
| 보안 그룹 `codebomba-web` | sg-0f7fa0af77d969b96 | 무료 |
| IAM 역할 `codebomba-ec2-ssm` | | 무료 |

잠깐 쉬는 동안은 삭제 대신 중지: `./aws/power.sh stop` / `start` / `status`

삭제 후 확인: `./aws/teardown.sh` 를 다시 실행해 전부 "없음" 인지 본다.
콘솔 결제 화면(Billing → Bills)에서 다음 날 요금이 멈췄는지도 확인한다.

## 2. 키 폐기 — 과금은 아니지만 유출 방지

- Gemini API 키: Google AI Studio 에서 삭제 (유료 등급이면 호출량만큼 과금되므로 꼭 삭제)
- Gmail 앱 비밀번호: 구글 계정 보안에서 삭제
- 구글 OAuth 클라이언트를 만들었다면 삭제

## 3. GCP — S3 전환 전에 만들었던 것 (이미 지웠다면 건너뜀)

- Cloud Storage 버킷 `codebomba-izac`, 서비스 계정과 JSON 키
- 내려받은 JSON 키 파일

## 4. GitHub — 무료, 선택

- 조직 `3-2-joljack` 의 공개 레포는 과금이 없다. 남겨도 된다.
