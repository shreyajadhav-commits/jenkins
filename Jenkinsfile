pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
        // Matches your Dockerfile's EXPOSE 9090
        APP_PORT = "9090" 
    }

    stages {
        stage('Verify Environment') {
            steps {
                sh '''
                    java -version
                    mvn -v
                    docker version
                '''
            }
        }

        stage('Build Maven') {
            steps {
                // Building the JAR to be copied into the Docker image
                sh 'mvn clean package -DskipTests'
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
                    # Stop and remove if container already exists
                    docker stop springboot-app || true
                    docker rm springboot-app || true
                    
                    # Map 9090 on Host to 9090 in Container (based on your Dockerfile)
                    docker run -d -p ${APP_PORT}:${APP_PORT} --name springboot-app ${IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded! App available at http://localhost:${APP_PORT}"
        }
        failure {
            echo '❌ Pipeline failed — check logs!'
        }
    }
}