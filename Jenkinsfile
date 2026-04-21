pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "shreyajadhav911/jenkins"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/shreyajadhav-commits/jenkins.git'
            }
        }

        stage('Build & Test') {
            steps {
                // This compiles the code and runs Unit Tests
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                // Build the image using the Dockerfile created in Phase 2
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    // This securely logs into Docker Hub using your saved credentials
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
    }
}