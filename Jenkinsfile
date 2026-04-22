pipeline {
    agent any

    tools {
        maven 'Maven3'
    }

    environment {
        JAVA_HOME = "C:\\Program Files\\Java\\jdk-17"
        PATH = "C:\\Program Files\\Java\\jdk-17\\bin;${env.PATH}"
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Verify Java') {
            steps {
                bat '''
                java -version
                mvn -v
                '''
            }
        }

        stage('Build Maven') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                """
            }
        }

       stage('Login Docker Hub') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'USER',
            passwordVariable: 'PASS'
        )]) {
            
            bat "echo %PASS%| docker login -u %USER% --password-stdin"
        }
    }
}


        stage('Push Image') {
            steps {
                bat """
                docker push %IMAGE_NAME%:%IMAGE_TAG%
                docker push %IMAGE_NAME%:latest
                """
            }
        }

        stage('Deploy Container') {
            steps {
                bat """
                docker stop springboot-app || exit 0
                docker rm springboot-app || exit 0
                docker run -d -p 9090:8080 --name springboot-app %IMAGE_NAME%:latest
                """
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded!'
        }
        failure {
            echo '❌ Pipeline failed — check logs!'
        }
    }
}