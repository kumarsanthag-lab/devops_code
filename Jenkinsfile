pipeline {
    agent any

    environment {
        APP_NAME        = "sample-app"
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        DEPLOY_ENV      = ""
        COMPOSE_PROFILE = ""
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Determine Deployment Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.DEPLOY_ENV = 'uat'
                        env.COMPOSE_PROFILE = 'uat'
                    }
                    else if (env.BRANCH_NAME.startsWith('release/')) {
                        env.DEPLOY_ENV = 'qa'
                        env.COMPOSE_PROFILE = 'qa'
                    }
                    else if (env.BRANCH_NAME == 'develop' || env.BRANCH_NAME.startsWith('feature/')) {
                        env.DEPLOY_ENV = 'dev'
                        env.COMPOSE_PROFILE = 'dev'
                    }
                    else {
                        error "❌ No deployment rule for branch: ${env.BRANCH_NAME}"
                    }
                }
                echo "Deployment Environment: ${env.DEPLOY_ENV}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${APP_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Unit Tests') {
            steps {
                sh """
                  docker run --rm ${APP_NAME}:${IMAGE_TAG} npm test || exit 1
                """
            }
        }

        stage('Deploy Application') {
            steps {
                echo "Deploying to ${env.DEPLOY_ENV} environment"

                sh """
                  docker-compose --profile ${COMPOSE_PROFILE} down
                  docker-compose --profile ${COMPOSE_PROFILE} up -d --build
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful for ${env.BRANCH_NAME} → ${env.DEPLOY_ENV}"
        }
        failure {
            echo "❌ Pipeline failed for ${env.BRANCH_NAME}"
        }
        always {
            cleanWs()
        }
    }
}
