#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx curl

TOKEN="$(curl --fail --silent --show-error -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")"
INSTANCE_ID="$(curl --fail --silent --show-error \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)"
AZ="$(curl --fail --silent --show-error \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)"

cat > /var/www/html/index.html <<HTML
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Two-Tier AWS Demo</title></head>
<body>
  <h1>Two-Tier AWS Infrastructure</h1>
  <p>Served by <strong>${INSTANCE_ID}</strong> in <strong>${AZ}</strong>.</p>
  <p>Refresh this page to observe load balancing across instances.</p>
</body>
</html>
HTML

cat > /var/www/html/health <<'HEALTH'
ok
HEALTH

nginx -t
systemctl enable nginx
systemctl restart nginx
