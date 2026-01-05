pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build') {
      steps {
        sh 'docker build -t cicd-app:latest .'
      }
    }

    stage('Test') {
      steps {
        sh 'npm test || true'
      }
    }

    stage('Deploy') {
      steps {
        script {
          if (env.BRANCH_NAME == 'develop' || env.BRANCH_NAME.startsWith('feature/')) {
            sh 'docker-compose up -d dev'
          } else if (env.BRANCH_NAME.startsWith('release/')) {
            sh 'docker-compose up -d qa'
          } else if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME.startsWith('hotfix/')) {
            sh 'docker-compose up -d uat'
          }
        }
      }
    }
  }
}
