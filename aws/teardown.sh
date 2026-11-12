#!/usr/bin/env bash
# 졸작 종료 후 AWS 과금 자원 전체 삭제.
#   ./aws/teardown.sh            삭제 대상만 보여준다 (아무것도 지우지 않음)
#   ./aws/teardown.sh --delete   실제 삭제 (확인 문구 입력 필요). DB 데이터와 S3 파일 포함 복구 불가.
set -euo pipefail
export AWS_PROFILE="${AWS_PROFILE:-qrto}" AWS_DEFAULT_REGION=ap-northeast-2 AWS_PAGER=""
EXPECT_ACCOUNT=379959319287
ROLE=codebomba-ec2-ssm
SG_NAME=codebomba-web
BUCKET=codebomba-lms-379959319287
TAG="Name=tag:Project,Values=codebomba"

ACC="$(aws sts get-caller-identity --query Account --output text)"
[ "$ACC" = "$EXPECT_ACCOUNT" ] || { echo "계정이 다릅니다: $ACC (기대값 $EXPECT_ACCOUNT). 중단."; exit 1; }

IIDS="$(aws ec2 describe-instances --filters "$TAG" Name=instance-state-name,Values=pending,running,stopping,stopped \
        --query 'Reservations[].Instances[].InstanceId' --output text)"
ALLOCS="$(aws ec2 describe-addresses --filters "$TAG" --query 'Addresses[].AllocationId' --output text)"
SGS="$(aws ec2 describe-security-groups --filters Name=group-name,Values=$SG_NAME --query 'SecurityGroups[].GroupId' --output text)"
VOLS="$(aws ec2 describe-volumes --filters "$TAG" --query 'Volumes[].VolumeId' --output text)"
SNAPS="$(aws ec2 describe-snapshots --owner-ids self --filters "$TAG" --query 'Snapshots[].SnapshotId' --output text)"
BUCKET_OK="$(aws s3api head-bucket --bucket $BUCKET >/dev/null 2>&1 && echo $BUCKET || true)"
BUCKET_OBJS="$([ -n "$BUCKET_OK" ] && aws s3 ls "s3://$BUCKET" --recursive --summarize | awk '/Total Objects/{print $3}' || echo 0)"
ROLE_OK="$(aws iam get-role --role-name $ROLE --query Role.RoleName --output text 2>/dev/null || true)"

echo "계정 $ACC (프로필 $AWS_PROFILE) 삭제 대상"
echo "  EC2 인스턴스 : ${IIDS:-없음}"
echo "  탄력적 IP    : ${ALLOCS:-없음}"
echo "  디스크(볼륨) : ${VOLS:-없음}  (인스턴스와 함께 삭제됨)"
echo "  스냅샷       : ${SNAPS:-없음}"
echo "  보안 그룹    : ${SGS:-없음}"
echo "  S3 버킷      : ${BUCKET_OK:-없음} (객체 ${BUCKET_OBJS}개, 파일까지 모두 삭제)"
echo "  IAM 역할     : ${ROLE_OK:-없음}"

if [ "${1:-}" != "--delete" ]; then
  echo; echo "조회만 했습니다. 실제 삭제는: ./aws/teardown.sh --delete"; exit 0
fi

read -r -p "모두 삭제합니다. DB 데이터와 S3 파일도 사라지고 복구할 수 없습니다. 계속하려면 delete 입력: " ans
[ "$ans" = "delete" ] || { echo "취소"; exit 1; }

if [ -n "$IIDS" ]; then
  aws ec2 terminate-instances --instance-ids $IIDS --query 'TerminatingInstances[].InstanceId' --output text
  aws ec2 wait instance-terminated --instance-ids $IIDS
fi
for a in $ALLOCS; do aws ec2 release-address --allocation-id "$a" && echo "EIP 해제: $a"; done
for v in $(aws ec2 describe-volumes --filters "$TAG" Name=status,Values=available --query 'Volumes[].VolumeId' --output text); do
  aws ec2 delete-volume --volume-id "$v" && echo "볼륨 삭제: $v"; done
for s in $SNAPS; do aws ec2 delete-snapshot --snapshot-id "$s" && echo "스냅샷 삭제: $s"; done
for g in $SGS; do aws ec2 delete-security-group --group-id "$g" >/dev/null && echo "보안 그룹 삭제: $g"; done
if [ -n "$BUCKET_OK" ]; then
  aws s3 rm "s3://$BUCKET" --recursive --quiet
  aws s3api delete-bucket --bucket "$BUCKET" && echo "S3 버킷 삭제: $BUCKET"
fi
if [ -n "$ROLE_OK" ]; then
  aws iam delete-role-policy --role-name $ROLE --policy-name codebomba-s3 2>/dev/null || true
  aws iam remove-role-from-instance-profile --instance-profile-name $ROLE --role-name $ROLE 2>/dev/null || true
  aws iam delete-instance-profile --instance-profile-name $ROLE 2>/dev/null || true
  aws iam detach-role-policy --role-name $ROLE --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>/dev/null || true
  aws iam delete-role --role-name $ROLE && echo "IAM 역할 삭제: $ROLE"
fi
echo "AWS 정리 완료. 남은 것 확인: ./aws/teardown.sh"
