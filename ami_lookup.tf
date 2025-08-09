data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }
}

output "found_ubuntu_ami" {
  value = data.aws_ami.ubuntu_latest.id
}
output "found_ubuntu_name" {
  value = data.aws_ami.ubuntu_latest.name
}
