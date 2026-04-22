pipeline {
    agent any

    tools {
        
        jdk   'jdk17'
        maven 'maven3'
    }

    environment {
        
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Verify Java') {
            steps {
                sh '''
                java -version
                mvn -v
                '''
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                """
            }
        }

       stage('Login Docker Hub') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-credentials',
            usernameVariable: 'USER',
            passwordVariable: 'PASS'
        )]) {
            
            sh "echo %PASS%| docker login -u %USER% --password-stdin"
        }
    }
}


        stage('Push Image') {
            steps {
                sh """
                docker push %IMAGE_NAME%:%IMAGE_TAG%
                docker push %IMAGE_NAME%:latest
                """
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
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