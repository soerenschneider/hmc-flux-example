# Howto

1. Head over to https://mirantis.awsapps.com/start#/ to get IAM credentials
1. Export IAM credentials
1. Run terraform
   1. terraform init
   1. terraform apply
1. Confirm secret is created `kubectl get secrets -n hmc-system aws-cluster-identity-secret`
