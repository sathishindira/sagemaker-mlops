data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "MLflowTrackingServerRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_policy" "mlflow_policy" {
  name        = "MLflowTrackingServerRole_policy"
  path        = "/"
  description = "MLflowTrackingServerRole policy to connect from ec2 to s3 and cloudwatch logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket"
        ],
        "Resource": [
            aws_s3_bucket.mlflow.arn,
            "${aws_s3_bucket.mlflow.arn}/*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "rds-db:connect"
        ],
        "Resource": "arn:aws:rds-db:us-east-1:${data.aws_caller_identity.current.account_id}:dbuser:*/mlflow"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },

    ]
  })
}

resource "aws_iam_policy_attachment" "instance-attach" {
  name       = "mlflow-policy-attachment"
  roles      = [aws_iam_role.instance.name]
  policy_arn = aws_iam_policy.mlflow_policy.arn
}

resource "aws_iam_instance_profile" "mlflow" {
    name = "mlflow-trackking-service-instance-role"
    role = aws_iam_role.instance.name
  
}

####Sagemaker Exection Role
data "aws_iam_policy_document" "sagemaker_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker" {
  name               = "SageMakerExecutionRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy.json
}

resource "aws_iam_policy" "sagemaker_policy" {
  name        = "SageMakerExecutionRole_policy"
  path        = "/"
  description = "SageMakerExecutionRole for training and model inferencing"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListBucket"
        ],
        "Resource": [
            aws_s3_bucket.mlops.arn,
            "${aws_s3_bucket.mlops.arn}/*",
            aws_s3_bucket.mlflow.arn,
            "${aws_s3_bucket.mlflow.arn}/*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer"
        ],
        "Resource": "*"
        }

    ]
  })
}

resource "aws_iam_policy_attachment" "sagemaker-attach" {
  name       = "sagemaker-policy-attachment"
  roles      = [aws_iam_role.sagemaker.name]
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}