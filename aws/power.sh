#!/usr/bin/env bash
# 안 쓸 때 서버 끄기/켜기 (데이터와 주소 유지).  ./aws/power.sh stop | start | status
# 켠 뒤에는 서버에서 컨테이너가 자동으로 다시 뜬다 (restart: unless-stopped).
set -euo pipefail
export AWS_PROFILE="${AWS_PROFILE:-qrto}" AWS_DEFAULT_REGION=ap-northeast-2 AWS_PAGER=""
[ "$(aws sts get-caller-identity --query Account --output text)" = "379959319287" ] || { echo "계정이 다릅니다. 중단."; exit 1; }
IID="$(aws ec2 describe-instances --filters Name=tag:Name,Values=codebomba-server Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text)"
[ -n "$IID" ] || { echo "codebomba-server 인스턴스가 없습니다"; exit 1; }
case "${1:-status}" in
  stop)  aws ec2 stop-instances  --instance-ids "$IID" --query 'StoppingInstances[].CurrentState.Name' --output text ;;
  start) aws ec2 start-instances --instance-ids "$IID" --query 'StartingInstances[].CurrentState.Name' --output text ;;
  status) aws ec2 describe-instances --instance-ids "$IID" --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]' --output text ;;
  *) echo "사용법: $0 stop|start|status"; exit 1 ;;
esac
