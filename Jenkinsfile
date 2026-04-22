pipeline {
    agent any

    options {
        // CRITICAL: This stops the automatic checkout that is failing with Error 128
        skipDefaultCheckout()
    }

    environment {
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
        APP_PORT = "9090"
        REPO_URL = "https://github.com/shreyajadhav-commits/jenkins.git"
    }

    stages {
        stage('Checkout & Trust') {
            steps {
                // 1. Tell Git to trust the workspace folder (Fixes Status 128)
                sh 'git config --global --add safe.directory "*"'
                
                // 2. Clean the directory to ensure no old files interfere
                deleteDir()
                
                // 3. Manually pull the code
                checkout scm
            }
        }

        stage('Build Maven') {
            steps {
                // Ensure the wrapper is executable in the Linux container
                sh 'chmod +x mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Using -f dockerfile because your file is lowercase in GitHub
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f dockerfile ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credentials',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo "$PASS" | docker login -u "$USER" --password-stdin'
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stop springboot-app || true
                    docker rm springboot-app || true
                    docker run -d -p ${APP_PORT}:${APP_PORT} --name springboot-app ${IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        success {
            echo "✅ Success! App: http://localhost:${APP_PORT}"
        }
        failure {
            echo "❌ Failed. Check the Console Output."
        }
    }
}