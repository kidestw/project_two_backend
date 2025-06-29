// C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
// Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

pipeline {
    agent any // Use 'any' agent on the Jenkins controller itself

    environment {
        DOCKER_HUB_USERNAME = 'kidest'
        DOCKER_IMAGE_NAME = "kidest/back-end-backend"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Configure Git to bypass SSL verification (for troubleshooting)
                    // WARNING: Do NOT use this in production unless you understand the security implications.
                    sh 'git config --global http.sslVerify false'
                    // Increase Git's HTTP post buffer to handle large objects
                    sh 'git config --global http.postBuffer 524288000' // 500 MB
                }
                git url: 'https://github.com/kidestw/project_two_backend.git',
                    branch: 'main'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        sh script: """#!/bin/bash
                            docker login -u ${DOCKER_HUB_USERNAME} --password-stdin <<< "${DOCKER_TOKEN}"
                        """,
                            returnStdout: true,
                            encoding: 'UTF-8'
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                // ADD DOCKER_CLIENT_TIMEOUT and COMPOSE_HTTP_TIMEOUT here
                withEnv([
                    "DOCKER_HOST=tcp://host.docker.internal:23750",
                    "DOCKER_CLIENT_TIMEOUT=300", // Set Docker client timeout to 300 seconds (5 minutes)
                    "COMPOSE_HTTP_TIMEOUT=300"    // Also for Docker Compose, good practice
                ]) {
                    script {
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."

                        // Tagging the image
                        sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"

                        // Retry block for pushes
                        retry(3) { // Retry up to 3 times
                            echo "Attempting to push ${DOCKER_IMAGE_NAME}:latest"
                            sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        }
                        retry(3) { // Retry up to 3 times
                            echo "Attempting to push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                            sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            steps {
                echo 'Cleaning up Docker login...'
                withEnv([
                    "DOCKER_HOST=tcp://host.docker.internal:23750",
                    "DOCKER_CLIENT_TIMEOUT=300",
                    "COMPOSE_HTTP_TIMEOUT=300"
                ]) {
                    sh 'docker logout'
                }
            }
        }
        success {
            echo 'Backend Docker image built and pushed successfully!'
        }
        failure {
            echo 'Backend Docker image build and push FAILED!'
        }
    }
}