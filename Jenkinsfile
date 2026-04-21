pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'shreyajadhav911' // Your Docker Hub username
        REPO_NAME = 'jenkins'
    }

    stages {
        stage('Checkout') {
            steps {
                // Since this is 'Pipeline from SCM', this step is often redundant 
                // but kept here for your specific requirement.
                git branch: 'main', url: 'https://github.com/shreyajadhav-commits/jenkins.git'
            }
        } // Closes Checkout stage

        stage('Build & Test') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        } // Closes Build stage

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${REPO_NAME}:${env.BUILD_ID} ."
                sh "docker build -t ${DOCKER_HUB_USER}/${REPO_NAME}:latest ."
            }
        } // Closes Docker Build stage

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_USER}/${REPO_NAME}:${env.BUILD_ID}"
                        sh "docker push ${DOCKER_HUB_USER}/${REPO_NAME}:latest"
                    }
                }
            }
        } // Closes Docker Push stage
    } // Closes ALL stages

    post {
        always {
            sh 'docker logout'
        }
    } // Closes post block
} // Closes the entire pipeline