export $(cat ../.dev_env | xargs)

echo "Applying prerequisites"
cd infrastructure/terragrunt || exit 1
make apply_buckets
make apply_ecr-repositories
cd ../../scripts || exit 1

echo "Logging to ECR"
aws ecr get-login-password --region "${BEEFLOW_AWS_REGION}" | \
 docker login --username AWS --password-stdin "${BEEFLOW_AWS_ACCOUNT_ID}.dkr.ecr.${BEEFLOW_AWS_REGION}.amazonaws.com"

echo "Publishing artifacts"
cd .. || exit 1
./pants package ::
./pants export ::
cd scripts || exit 1

echo "Deploying infrastructure"
cd infrastructure/terragrunt || exit 1
make apply_all
