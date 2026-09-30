resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for application EC2 instances."
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from trusted administrator network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-sg"
  })
}

resource "aws_instance" "this" {
  count = var.instance_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  associate_public_ip_address = var.associate_public_ip
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 20
  }

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>${var.name_prefix}</title>
      </head>
      <body>
        <h1>Terraform AWS Environment</h1>
        <p>Environment: ${var.name_prefix}</p>
        <p>Managed by Terraform</p>
      </body>
    </html>
    HTML
  EOF

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-${count.index + 1}"
  })
}
