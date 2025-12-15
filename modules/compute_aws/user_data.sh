#!/bin/bash
set -euo pipefail

APP_PORT="${app_port}"

# Update and install nginx
dnf -y update
dnf -y install nginx

# Simple landing page (Upwork-friendly proof)
cat >/usr/share/nginx/html/index.html <<'EOF'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Terraform ALB → Private EC2</title></head>
<body>
  <h1>Deployment Successful</h1>
  <p>This page is served from a private EC2 instance behind an Application Load Balancer.</p>
  <ul>
    <li>Provisioned with Terraform</li>
    <li>Bootstrapped with user_data</li>
    <li>Security groups restrict inbound to ALB only</li>
  </ul>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx

# Ensure nginx listens on APP_PORT if not 80
if [ "$APP_PORT" != "80" ]; then
  sed -i "s/listen       80;/listen       ${APP_PORT};/g" /etc/nginx/nginx.conf
  systemctl restart nginx
fi
