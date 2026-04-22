pipeline {
    agent any

    environment {
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
        APP_PORT = "9090" 
    }

    stages {
        stage('Fix Git Permissions') {
            steps {
                // This prevents the 'fatal: not in a git directory' error on Docker/Windows
                sh 'git config --global --add safe.directory "*"'
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    java -version
                    ./mvnw -v
                    docker version
                '''
            }
        }

        stage('Build Maven') {
            steps {
                // Using chmod to ensure the wrapper can run inside the Linux container
                sh 'chmod +x mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Login Docker Hub') {
            steps {
                // Ensure the 'docker-credentials' ID exists in Jenkins -> Credentials
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credentials',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo "$PASS" | docker login -u "$USER" --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy Container') {
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
            echo "✅ Pipeline succeeded! Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "🚀 App available at http://localhost:${APP_PORT}"
        }
        failure {
            echo '❌ Pipeline failed — check logs!'
        }
    }
}