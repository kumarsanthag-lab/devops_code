pipeline {
    agent any

    environment {
        DEPLOY_ENV = ""
        DEPLOY_SERVER = ""
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Set Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.DEPLOY_ENV = 'production'
                        env.DEPLOY_SERVER = 'prod-server-ip'
                    } 
                    else if (env.BRANCH_NAME == 'release') {
                        env.DEPLOY_ENV = 'staging'
                        env.DEPLOY_SERVER = 'staging-server-ip'
                    } 
                    else if (env.BRANCH_NAME.startsWith('feature/')) {
                        env.DEPLOY_ENV = 'development'
                        env.DEPLOY_SERVER = 'dev-server-ip'
                    } 
                    else {
                        error "No deployment rule defined for branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${env.DEPLOY_ENV}"
                echo "Target Server: ${env.DEPLOY_SERVER}"

                // Example deployment command
                sh """
                  echo "Deploying ${env.BRANCH_NAME} to ${env.DEPLOY_SERVER}"
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful for ${env.BRANCH_NAME} (${env.DEPLOY_ENV})"
        }
        failure {
            echo "❌ Deployments failed for ${env.BRANCH_NAME}"
        }
        always {
            cleanWs()
        }
    }
}
