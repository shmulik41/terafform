#!/bin/bash
set -euxo pipefail

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
else
  echo "Cannot detect OS type" >&2
  exit 1
fi

# Install Docker
case "$ID" in
  ubuntu|debian)
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y docker.io
    ;;
  amzn|amazon)
    if [[ "${VERSION_ID:-}" =~ ^2 ]]; then
      yum -y update
      amazon-linux-extras install docker -y
    else
      dnf -y update || true
      dnf -y install docker
    fi
    ;;
  rhel|centos|rocky|almalinux|ol)
    yum install -y docker || dnf install -y docker
    ;;
  *)
    echo "Unknown distro: $ID" >&2
    exit 1
    ;;
esac

# Enable & start Docker
systemctl enable docker
systemctl start docker

# Add common users to docker group
usermod -aG docker ec2-user 2>/dev/null || true
usermod -aG docker ubuntu 2>/dev/null || true
usermod -aG docker ssm-user 2>/dev/null || true

# Run NGINX container
docker rm -f nginx || true
docker run -d --name nginx --restart unless-stopped -p 80:80 nginx:alpine

# Replace default index with required text
echo "yo this is nginx" | docker exec -i nginx sh -c 'tee /usr/share/nginx/html/index.html' >/dev/null

# Verify locally
for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1/ | grep -qi "yo this is nginx"; then
    echo "OK: nginx is serving the required text"
    exit 0
  fi
  sleep 2
done

echo "ERROR: nginx did not become ready in time" >&2
exit 1

