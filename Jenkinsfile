node {

  def IMAGE_TAG = "${BUILD_NUMBER}"
  def config

  try {

    stage('Checkout') {
      checkout scm
      config = readYaml file: 'deployment-config.yaml'
    }

    stage('Build Image') {
      sh """
        docker image prune -f
        docker build --no-cache -t ${config.service.image}:${IMAGE_TAG} .
        docker tag ${config.service.image}:${IMAGE_TAG} ${config.service.image}:latest
      """
    }

    stage('Run Tests') {
      sh "docker run --rm ${config.service.image}:${IMAGE_TAG} npm test"
    }

    stage('Resolve Deployment Config') {

      def branchKey = config.branches.keySet().find {
        env.BRANCH_NAME == it || env.BRANCH_NAME.startsWith(it)
      }

      if (!branchKey) {
        error "No deployment configuration found for branch: ${env.BRANCH_NAME}"
      }

      env.TARGET_ENV = config.branches[branchKey].env
      env.COMPOSE_SERVICE = config.branches[branchKey].composeService
      env.DEPLOY_STRATEGY = config.branches[branchKey].strategy

      echo """
        Deployment resolved:
        - Environment : ${env.TARGET_ENV}
        - Strategy    : ${env.DEPLOY_STRATEGY}
      """
    }

    stage('Deploy') {
      sh """
        docker-compose stop ${env.COMPOSE_SERVICE} || true
        docker-compose rm -f ${env.COMPOSE_SERVICE} || true
        IMAGE_TAG=${IMAGE_TAG} docker-compose up -d ${env.COMPOSE_SERVICE} --force-recreate
      """
    }

    stage('Cleanup') {
      sh "docker image prune -f"
    }

  } catch (e) {
    currentBuild.result = 'FAILURE'
    throw e
  } finally {
    echo "Pipeline completed for branch: ${env.BRANCH_NAME}"
  }
}
