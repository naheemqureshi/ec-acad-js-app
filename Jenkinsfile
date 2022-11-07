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
     registryCredential = 'ec-acad-dev-credentials'
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
   
     //Deploy image to AWS ECR   
       stage('Deploy image') {
        steps{
            script{
		    docker.withRegistry("https://" + REPOSITORY_URI, "ecr:eu-west-2:" + registryCredential) {
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
     //Deploy
     stage('Deploy') {
     steps{
            withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
                script {
			sh './script.sh'
                }
            } 
        }
      } 
	    
	    
    }
}
