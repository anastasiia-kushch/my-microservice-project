data "aws_iam_policy_document" "jenkins_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.oidc_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:jenkins-sa"
      ]
    }
  }
}

resource "aws_iam_role" "jenkins" {
  name = "${var.cluster_name}-jenkins-role"

  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role.json

  tags = {
    Name      = "${var.cluster_name}-jenkins-role"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "jenkins_ecr" {
  statement {
    sid    = "ECRAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.ecr_repository_name}"
    ]
  }
}

resource "aws_iam_policy" "jenkins_ecr" {
  name   = "${var.cluster_name}-jenkins-ecr-policy"
  policy = data.aws_iam_policy_document.jenkins_ecr.json

  tags = {
    Name      = "${var.cluster_name}-jenkins-ecr-policy"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins_ecr.arn
}
