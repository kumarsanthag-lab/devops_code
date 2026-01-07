node {
   def IMAGE_NAME = "cicd-app"
   def IMAGE_TAG = "${BUILD_NUMBER}"

   try {
     stage('Checkout') {
       checkout scm
     }

     stage('Build Image') {
       sh """
         # Clean up old images to prevent cache issues
         docker image prune -f

         # Build new image with specific tag
         docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} .

         # Tag as latest after successful build
         docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
       """
     }

     // stage('Trivy Scan') {
     //   sh '''
     //     docker run --rm \
     //       -v /var/run/docker.sock:/var/run/docker.sock \
     //       aquasec/trivy image \
     //       --severity HIGH,CRITICAL \
     //       --exit-code 1 \
     //       cicd-app:''' + IMAGE_TAG + '''
     //   '''
     // }

     stage('Run Tests') {
       sh """
         docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test
       """
     }

    stage('Deploy') {
    def deployMap = [
    'develop' : 'dev',
    'feature/' : 'dev',
    'release' : 'qa',
    'release/' : 'qa',
    'main' : 'uat',
    'hotfix/' : 'uat'
  ]

  def targetEnv = deployMap.find { key, value ->
    env.BRANCH_NAME == key || env.BRANCH_NAME.startsWith(key)
  }?.value

  if (!targetEnv) {
    error "No deployment rule for branch ${env.BRANCH_NAME}"
  }

  echo "Deploying to ${targetEnv.toUpperCase()} environment"

  sh """
    docker-compose stop ${targetEnv} || true
    docker-compose rm -f ${targetEnv} || true
    IMAGE_TAG=${IMAGE_TAG} docker-compose up -d ${targetEnv} --force-recreate
  """
}


     stage('Cleanup') {
       sh """
         # Remove old unused images (keep latest and current build)
         docker image prune -f

         # Remove dangling images
         docker images -f "dangling=true" -q | xargs -r docker rmi || true

         echo "Deployment completed successfully with image: ${IMAGE_NAME}:${IMAGE_TAG}"
       """
     }

   } catch (Exception e) {
     currentBuild.result = 'FAILURE'
     throw e
   } finally {
     // Cleanup if needed
     echo "Pipeline completed for branch: ${env.BRANCH_NAME}"
   }
 }