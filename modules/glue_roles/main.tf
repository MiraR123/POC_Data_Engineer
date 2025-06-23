resource "aws_iam_role" "glue_service_role" {
  name = var.glue_service_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "glue.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

resource "aws_iam_role_policy" "glue_service_role_policy" {
  name = "${var.glue_service_role_name}_policy"
  role = aws_iam_role.glue_service_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = ["*"]
      },

      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = ["arn:aws:s3:::${var.source_bucket_name}"]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = ["arn:aws:s3:::${var.source_bucket_name}/*"]
      },

      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = [
          "arn:aws:s3:::${var.target_bucket_name}/*",
          "arn:aws:s3:::${var.code_bucket_name}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::${var.target_bucket_name}",
                    "arn:aws:s3:::${var.code_bucket_name}"]
      },


      {
        Effect   = "Allow",
        Action   = [
          "ec2:Describe*",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = ["*"]
      },

      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = ["*"]
      },

      {
        Effect   = "Allow",
        Action   = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies"
        ],
        Resource = ["*"]
      },
    {
      Effect   = "Allow",
      Action   = [
        "athena:StartQueryExecution",
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:GetWorkGroup"
      ],
      Resource = ["*"]
    },
    {
      Effect: "Allow",
      Action: [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      Resource: [
    "arn:aws:s3:::my-poc-source-bucket-unique-123",
    "arn:aws:s3:::my-poc-source-bucket-unique-123/*"
      ]
    }


    ]
  })
}
