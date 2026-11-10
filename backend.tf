# Remote state in S3. Bucket details are supplied at init time so no
# account-specific values are committed:
#   terraform init -backend-config=backend.hcl
# See backend.hcl.example.
terraform {
  backend "s3" {}
}
