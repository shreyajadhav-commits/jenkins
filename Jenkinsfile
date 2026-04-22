pipeline {
    agent any

    environment {
        IMAGE_NAME = "shreyajadhav911/jenkins"
        IMAGE_TAG = "${BUILD_NUMBER}"
        APP_PORT = "9090" 
        REPO_URL = "https://github.com/shreyajadhav-commits/jenkins.git"
    }

    stages {
        stage('Checkout Source') {
            steps {
                // This cleans the directory and clones the fresh repo
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '']], 
                    userRemoteConfigs: [[url: "${REPO_URL}"]]
                ])
            }
        }

        stage('Fix Git Permissions') {
            steps {
                // Resolves the 'fatal: not in a git directory' on Windows/Docker volumes
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
            echo "✅ Pipeline succeeded! App: http://localhost:${APP_PORT}"
        }
        failure {
            echo '❌ Pipeline failed — check logs!'
        }
    }
}