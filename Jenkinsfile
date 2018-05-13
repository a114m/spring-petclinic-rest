pipeline {
  agent any

  parameters {
      string(defaultValue: "petclinic_docker_creds", description: 'DockerHub Credentials ID', name: 'DOCKER_CRED_ID')
      string(defaultValue: "petclinicteam@example.com", description: 'Development team mailing list', name: 'DEVS_EMAIL')
      string(defaultValue: "qa@example.com", description: 'Qualification team mailing list', name: 'QA_EMAIL')
  }


  stages {
    stage('Test') {
      agent {
        docker {
          image 'java:8'
          args '-v $HOME/.m2:/root/.m2'
        }
      }
      steps {
        sh 'DB_TYPE=hsqldb ./mvnw test'
      }
    }
    stage('Build') {
      steps {
        sh "docker build --force-rm -t petclinic/petclinic:${env.BUILD_NUMBER} ."
        sh "docker tag petclinic/petclinic:50 petclinic/petclinic:latest"
      }
    }

    //// Requires dockerhub credentials (for some reason it throws NullPointerException when set)
    //// Since the image is deployed on the same machine it's going to work even without pusing to external repository
    // stage('Publish') {
    //   steps {
    //     withDockerRegistry([url: "https://registry.hub.docker.com", credentialsId: "${params.DOCKER_CRED_ID}"]) {
    //       sh "docker push petclinic/petclinic:${env.BUILD_NUMBER}"
    //       sh "docker push petclinic/petclinic:latest"
    //     }
    //   }
    // }

    //// Sending email notification (Requires SMTP server to be configured)
    // post {
    //   failure {
    //     mail to: "${params.DEVS_EMAIL}",
    //       subject: "Pipeline failed: ${currentBuild.fullDisplayName}",
    //       body: "Something is went wrong with the build #${env.BUILD_NUMBER}: ${env.BUILD_URL}"
    //   }
    //   success {
    //     mail to: "${params.QA_EMAIL}",
    //       subject: "New build is ready for QA: ${currentBuild.fullDisplayName}",
    //       body: "Build #${env.BUILD_NUMBER} has succeeded and pending QA approval to be deployed to QA environment: ${env.BUILD_URL}"
    //    }
    // }

    stage('QA Confirmation') {
      steps {
        input "Deploy to Qualification Environment?"
      }
    }
    stage('Deploy to Qualification Environment') {
      steps {
          sh "docker rm -f petclinic_qa || true"
          sh "docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --force-recreate"
      }
    }
  }
}
