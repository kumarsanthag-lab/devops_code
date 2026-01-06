pipeline {
  agent any

  environment {
    IMAGE_NAME = "cicd-app"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Image') {
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        """
      }
    }

    stage('Trivy Scan') {
      steps {
        sh '''
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            cicd-app:latest
        '''
      }
    }

    stage('Run Tests') {
      steps {
        sh """
          docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test
        """
      }
    }

    stage('Deploy') {
      steps {
        script {
          if (env.BRANCH_NAME == 'develop' || env.BRANCH_NAME.startsWith('feature/')) {
            sh 'docker-compose up -d dev'
          }
          else if ( env.BRANCH_NAME == 'release'|| env.BRANCH_NAME.startsWith('release/')) {
            sh 'docker-compose up -d qa'
          }
          else if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME.startsWith('hotfix/')) {
            sh 'docker-compose up -d uat'
          }
          else {
            error "No deployment rule for branch ${env.BRANCH_NAME}"
          }
        }
      }
    }
  }
}
