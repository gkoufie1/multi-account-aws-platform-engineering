data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_account" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "platform_engineer" {
  name               = "${var.project_name}-platform-engineer-role"
  assume_role_policy = data.aws_iam_policy_document.assume_account.json
}

resource "aws_iam_role_policy_attachment" "platform_poweruser" {
  role       = aws_iam_role.platform_engineer.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role" "readonly_auditor" {
  name               = "${var.project_name}-readonly-auditor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_account.json
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.readonly_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
