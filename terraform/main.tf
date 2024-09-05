

# fetches TLS certificate from the specified URL
data "tls_certificate" "this" {
  url = "https://token.actions.githubusercontent.com"
}

#creates an AWS IAM OpenID Connect (OIDC) provider, the OIDC endpoint for GitHub Actions.
resource "aws_iam_openid_connect_provider" "github_eks_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

    thumbprint_list = distinct(
    concat(
      var.thumbprint_list,
      [data.tls_certificate.this.certificates[0].sha1_fingerprint]
    )
  )
}

resource "aws_iam_user" "basic_user" {
    name = "techsecom-basic"
}

resource "aws_iam_user_policy" "basic_user_eks_policy" {
  name = "eks-full-access-policy"
  user = aws_iam_user.basic_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
       "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::905418274520:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:Techsecom/techsecoms-eks-infra-tf*"
                }
            }
        }
    ]
  })
}

# defines an IAM policy document that will be used to create an IAM policy.
data "aws_iam_policy_document" "oidc_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_eks_oidc_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Techsecom/techsecoms-eks-infra-tf*"]
    }
  }
}

resource "aws_iam_policy" "oidc_policy" {
  name        = "GitHubOIDCPolicy"
  description = "IAM policy for GitHub OIDC provider"
  policy      = data.aws_iam_policy_document.oidc_policy.json
}

resource "aws_iam_role" "oidc_role" {
  name               = "GitHubOIDCRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json
}
