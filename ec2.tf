

# יצירת EC2 פרטי עם IAM Profile של SSM
resource "aws_instance" "nginx_instance" {
  ami                         = "ami-021589336d307b577" # Ubuntu 22.04 LTS (Jammy)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_a.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  # user_data מתוך קובץ scripts/user_data.sh
  user_data = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = true

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

