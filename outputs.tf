output "vpc_id"                { value = aws_vpc.main.id }
output "public_subnet_ids"     { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "private_subnet_ids"    { value = [aws_subnet.private_a.id, aws_subnet.private_b.id] }
output "nat_gateway_id"        { value = aws_nat_gateway.nat.id }
output "internet_gateway_id"   { value = aws_internet_gateway.igw.id }
output "alb_sg_id"          { value = aws_security_group.alb_sg.id }
output "ec2_sg_id"          { value = aws_security_group.ec2_sg.id }
output "iam_instance_profile" { value = aws_iam_instance_profile.ec2_ssm_profile.name }
