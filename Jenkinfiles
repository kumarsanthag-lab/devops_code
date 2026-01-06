node {
   def IMAGE_NAME = "cicd-app"
   def IMAGE_TAG = "${BUILD_NUMBER}"

   try {
     stage('Checkout') {
       checkout scm
     }

     stage('Build Image') {
       sh """
         docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} .
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
       if (env.BRANCH_NAME == 'develop' || env.BRANCH_NAME.startsWith('feature/')) {
         echo "Deploying to DEV environment for branch: ${env.BRANCH_NAME}"
         sh 'docker-compose up -d dev --build --force-recreate'
       }
       else if (env.BRANCH_NAME == 'release' || env.BRANCH_NAME.startsWith('release/')) {
         echo "Deploying to QA environment for branch: ${env.BRANCH_NAME}"
         sh 'docker-compose up -d qa --build --force-recreate'
       }
       else if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME.startsWith('hotfix/')) {
         echo "Deploying to UAT environment for branch: ${env.BRANCH_NAME}"
         sh 'docker-compose up -d uat --build --force-recreate'
       }
       else {
         error "No deployment rule for branch ${env.BRANCH_NAME}"
       }
     }

   } catch (Exception e) {
     currentBuild.result = 'FAILURE'
     throw e
   } finally {
     // Cleanup if needed
     echo "Pipeline completed for branch: ${env.BRANCH_NAME}"
   }
 }
