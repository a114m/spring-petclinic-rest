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
}
