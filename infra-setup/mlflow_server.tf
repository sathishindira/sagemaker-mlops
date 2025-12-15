# RSA key of size 4096 bits
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-terraform-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh-key.private_key_pem
  filename        = "${path.module}/mlflow-server.pem"
  file_permission = "0600"
}

resource "aws_security_group" "mlflow" {
  name   = "mlflow-tracking-sg"
  vpc_id = aws_vpc.mlops.id

#   ingress {
#     description     = "MLflow from ALB"
#     from_port       = 5000
#     to_port         = 5000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.249.122.94/32"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mlflow-sg"
  }
}


resource "aws_launch_template" "mlflow" {
  name = "mlflow-tracking-server"

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.mlflow.name
  }

  image_id = data.aws_ami.amazon_linux_2023.id
  
  instance_type = "t3.medium"

  key_name = aws_key_pair.generated_key.key_name

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.mlflow.id]

  tag_specifications {
    resource_type = "instance"

    tags = var.tags

  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    dnf update -y
    dnf install -y python3 pip postgresql

    pip3 install mlflow gunicorn psycopg2-binary boto3

    cat <<EOF >/etc/systemd/system/mlflow.service
    [Unit]
    Description=MLflow Tracking Server
    After=network.target

    [Service]
    User=ec2-user
    WorkingDirectory=/home/ec2-user
    Environment=AWS_REGION=ap-south-1
    Environment=MLFLOW_DEFAULT_ARTIFACT_ROOT="s3://${aws_s3_bucket.mlflow.bucket}/artifacts"
    ExecStart=/usr/local/bin/mlflow server \
      --host 0.0.0.0 \
      --port 5000 \
      --backend-store-uri \${MLFLOW_BACKEND_STORE_URI} \
      --default-artifact-root \${MLFLOW_DEFAULT_ARTIFACT_ROOT}

    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target

    systemctl daemon-reload
    systemctl enable mlflow
    systemctl start mlflow

  EOF
  )
}