#!/usr/bin/env bash
# 문제세트를 임베딩해 추천용 벡터 인덱스(ChromaDB)를 만든다. 문제세트를 추가/수정한 뒤 실행.
set -euo pipefail
cd "$(dirname "$0")"
docker compose run --rm --no-deps python-ai python -m ingestion.run_ingest
docker compose restart python-ai
