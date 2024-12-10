locals {
  region = "us-west-2"
  username = "soerenschneider"
  roles = [
    "arn:aws:iam::437775732836:policy/control-plane.cluster-api-provider-aws.sigs.k8s.io",
    "arn:aws:iam::437775732836:policy/controllers-eks.cluster-api-provider-aws.sigs.k8s.io",
    "arn:aws:iam::437775732836:policy/controllers.cluster-api-provider-aws.sigs.k8s.io",
    "arn:aws:iam::437775732836:policy/nodes.cluster-api-provider-aws.sigs.k8s.io",
  ]
}

provider "aws" {
  region = local.region
}

resource "aws_iam_group" "group" {
  name = "2a-users"
}

resource "aws_iam_user_group_membership" "membership" {
  user   = aws_iam_user.cluster_api_user.name
  groups = [aws_iam_group.group.name]
}

resource "aws_iam_group_policy_attachment" "clients" {
  for_each = toset(local.roles)

  policy_arn = each.value
  group   = aws_iam_group.group.name
}

resource "aws_iam_user" "cluster_api_user" {
  name = format("2a-test-%s", local.username )
}

resource "aws_iam_access_key" "cluster_api_user_keys" {
  user = aws_iam_user.cluster_api_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.cluster_api_user_keys.id
}

output "secret_access_key" {
  value = aws_iam_access_key.cluster_api_user_keys.secret
  sensitive = true
}
