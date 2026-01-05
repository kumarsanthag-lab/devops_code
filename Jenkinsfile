pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DEPLOY_ENV   = ''
        SERVER_HOST  = ''
        SSH_CRED_ID  = ''
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Branch detected: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Building application..."
                sh 'echo "Build completed"'
            }
        }

        stage('Test') {
            steps {
                echo "Running tests..."
                sh 'echo "Tests passed"'
            }
        }

        stage('Set Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.DEPLOY_ENV  = 'prod'
                        env.SERVER_HOST = 'prod.example.com'
                        env.SSH_CRED_ID = 'prod-server-ssh'
                    }
                    else if (env.BRANCH_NAME.startsWith('release/')) {
                        env.DEPLOY_ENV  = 'test'
                        env.SERVER_HOST = 'test.example.com'
                        env.SSH_CRED_ID = 'test-server-ssh'
                    }
                    else if (env.BRANCH_NAME.startsWith('feature/')) {
                        env.DEPLOY_ENV  = 'dev'
                        env.SERVER_HOST = 'dev.example.com'
                        env.SSH_CRED_ID = 'dev-server-ssh'
                    }
                    else {
                        error "No deployment rule defined for branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${env.DEPLOY_ENV.toUpperCase()}"
                echo "Target Server: ${env.SERVER_HOST}"

                sshagent(credentials: [env.SSH_CRED_ID]) {
                    sh """
                      ssh -o StrictHostKeyChecking=no ubuntu@${env.SERVER_HOST} <<EOF
                        cd /opt/app
                        docker compose -f docker-compose.${env.DEPLOY_ENV}.yml up -d --build
                      EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful for ${env.BRANCH_NAME} → ${env.DEPLOY_ENV}"
        }
        failure {
            echo "❌ Deployment failed for ${env.BRANCH_NAME}"
        }
        always {
            cleanWs()
        }
    }
}
