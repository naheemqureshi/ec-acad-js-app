ROLE_ARN=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.executionRoleArn`
echo "ROLE_ARN= " $ROLE_ARN

FAMILY=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.family`
echo "FAMILY= " $FAMILY

NAME=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.containerDefinitions[].name`
echo "NAME= " $NAME

sed -i "s#BUILD_NUMBER#$IMAGE_TAG#g" ./scripts/test-task-definition.json
sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" ./scripts/test-task-definition.json
sed -i "s#ROLE_ARN#$ROLE_ARN#g" ./scripts/test-task-definition.json
sed -i "s#FAMILY#$FAMILY#g" ./scripts/test-task-definition.json
sed -i "s#NAME#$NAME#g" ./scripts/test-task-definition.json


aws ecs register-task-definition --cli-input-json file://scripts/test-task-definition.json --region="${AWS_DEFAULT_REGION}"

REVISION=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.revision`
echo "REVISION= " "${REVISION}"
aws ecs update-service --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${TASK_DEFINITION_NAME}":"${REVISION}" --desired-count "${DESIRED_COUNT}"