pipeline {
    environment {
     //environment settings for ECR & ECS deploy script//
     AWS_ACCOUNT_ID="447151167969"
     AWS_DEFAULT_REGION="eu-west-2" 
     CLUSTER_NAME="academy-ecs-cl"
     SERVICE_NAME="ec-acad-ecs-srv02"
     TASK_DEFINITION_NAME="ec-acad-task-def02"
     DESIRED_COUNT="1"
     IMAGE_REPO_NAME="ec-acad-01-node-app"
     IMAGE_TAG="${env.BUILD_ID}"
     REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
     registryCredentialDev = 'ec-acad-dev-credentials'
     registryCredentialTest = 'ec-acad-test-credentials'
     registryCredentialStage = 'ec-acad-stage-credentials'
     registryCredentialProd = 'ec-acad-prod-credentials'
     dockerImage = ''
    }
    agent any

    tools {nodejs "nodejs-16.18.0"}	
	
    stages {

    // Tests
    stage('Unit Tests') {
      steps{
        script {
          sh 'npm install'
	  sh 'npm test -- --watchAll=false'
        }
      }
    }
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "ec-acad-01-node-app:${env.BUILD_ID}"
        }
      }
    }
   
    //Push image to AWS ECR   
    stage('Push image to AWS ECR') {
        steps{
            script{
		    docker.withRegistry("https://" + REPOSITORY_URI, "ecr:eu-west-2:" + registryCredentialDev) {
                    dockerImage.push()
                }
            }
        }
       }
   
    // Cleanup
    stage('Image Cleanup') {
      steps{
        script {
	 catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
	    sh 'echo "cleaning images"'
	    sh 'docker rmi -f $(docker images -a -q)' /* clean up dockerfile images*/
            sh "exit 0"
                }
        }
      }
    }
	    
         //Deploying Image to Dev ECS
     stage('Deploy to Dev') {
     steps{
            withAWS(credentials: registryCredentialDev, region: "${AWS_DEFAULT_REGION}") {
                script {
			sh "chmod +x ./scripts/dev-script.sh"
			sh './scripts/dev-script.sh'
                }
            } 
        }
      } 	   

               //Deploying Image to Test ECS
     stage('Deploy to Test') {
     steps{
            withAWS(credentials: registryCredentialTest, region: "${AWS_DEFAULT_REGION}") {
                script {
			input id: 'Choice', message: 'Deploy image to Test?'
			sh "chmod +x ./scripts/test-script.sh"
			sh './scripts/test-script.sh'
                }
            } 
        }
      } 

     //Deploying Image to Staging ECS
     stage('Deploy to Staging') {
     steps{
            withAWS(credentials: registryCredentialStage, region: "${AWS_DEFAULT_REGION}") {
                script {
			input id: 'Choice', message: 'Deploy image to Staging?'
			sh "chmod +x ./scripts/stage-script.sh"
			sh './scripts/stage-script.sh'
                }
            } 
        }
      } 

     //Deploying Image to Prod ECS
     stage('Deploy to Prod') {
     steps{
            withAWS(credentials: registryCredentialProd, region: "${AWS_DEFAULT_REGION}") {
                script {
			input id: 'Choice', message: 'Deploy image to Prod?'
			sh "chmod +x ./scripts/prod-script.sh"
			sh './scripts/prod-script.sh'
                }
            } 
        }
      } 
	  
    }
}
