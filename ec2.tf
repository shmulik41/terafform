# יצירת EC2 פרטי עם IAM Profile של SSM
resource "aws_instance" "nginx_instance" {
  ami                         = "ami-021589336d307b577" # Ubuntu 22.04 LTS (Jammy)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_a.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  # user_data מותאם ל-Ubuntu 22.04
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # עדכון מערכת והתקנת Docker
    apt-get update -y
    apt-get install -y docker.io

    # הפעלת Docker בהפעלה אוטומטית
    systemctl enable --now docker

    # הרצת קונטיינר NGINX עם טקסט מותאם
    docker rm -f nginx 2>/dev/null || true
    docker run -d --restart unless-stopped -p 80:80 --name nginx \
      nginx:latest /bin/sh -c "echo 'yo this is nginx' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
  EOF

  tags = {
    Name = "${var.project_name}-nginx-private"
  }
}

# חיבור ה-EC2 ל-Target Group
resource "aws_lb_target_group_attachment" "nginx_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.nginx_instance.id
  port             = 80
}


