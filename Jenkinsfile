pipeline {
    agent {
      docker {
        image 'java:8'
        args '-v $HOME/.m2:/root/.m2'
      }
    }
    stages {
      stage('Test') {
          steps {
            sh 'DB_TYPE=hsqldb ./mvnw test'
          }
      }
    }
    post {
      failure {
        mail to: 'petclinicteam@example.com',
          subject: "Pipeline failed: ${currentBuild.fullDisplayName}",
          body: "Something is went wrong with the build #${env.BUILD_NUMBER}: ${env.BUILD_URL}"
      }
      success {
        mail to: 'qa@example.com',
          subject: "Build pending approval: ${currentBuild.fullDisplayName}",
          body: "Build #${env.BUILD_NUMBER} has successed and pending QA approval to be deployed to QA env ${env.BUILD_URL}"
       }
    }
}
