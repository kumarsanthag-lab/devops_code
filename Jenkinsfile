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

      stage('Trivy Scan') {
        sh '''
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image \
            --severity CRITICAL \
            --exit-code 1 \
            cicd-app:''' + IMAGE_TAG + '''
        '''
      }

     stage('Run Tests') {
       sh """
         docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test
       """
     }

     stage('Deploy') {
       if (env.BRANCH_NAME == 'develop' || env.BRANCH_NAME.startsWith('feature/')) {
         echo "Deploying to DEV environment for branch: ${env.BRANCH_NAME}"
         sh """
           # Stop and remove old containers
           docker-compose stop dev || true
           docker-compose rm -f dev || true

           # Deploy with specific image tag
           IMAGE_TAG=${IMAGE_TAG} docker-compose up -d dev --force-recreate
         """
       }
       else if (env.BRANCH_NAME == 'release' || env.BRANCH_NAME.startsWith('release/')) {
         echo "Deploying to QA environment for branch: ${env.BRANCH_NAME}"
         sh """
           # Stop and remove old containers
           docker-compose stop qa || true
           docker-compose rm -f qa || true

           # Deploy with specific image tag
           IMAGE_TAG=${IMAGE_TAG} docker-compose up -d qa --force-recreate
         """
       }
       else if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME.startsWith('hotfix/')) {
         echo "Deploying to UAT environment for branch: ${env.BRANCH_NAME}"
         sh """
           # Stop and remove old containers
           docker-compose stop uat || true
           docker-compose rm -f uat || true

           # Deploy with specific image tag
           IMAGE_TAG=${IMAGE_TAG} docker-compose up -d uat --force-recreate
         """
       }
       else {
         error "No deployment rule for branch ${env.BRANCH_NAME}"
       }
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
