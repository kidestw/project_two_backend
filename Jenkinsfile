// C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
// Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

pipeline {
    agent any // Use 'any' agent on the Jenkins controller itself

    environment {
        DOCKER_HUB_USERNAME = 'kidest'
        DOCKER_IMAGE_NAME = "kidest/back-end-backend"
        // DOCKER_HOST = 'tcp://host.docker.internal:23750' // REMOVE THIS LINE from here
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
                // ADD withEnv BLOCK HERE
                withEnv(["DOCKER_HOST=tcp://host.docker.internal:23750"]) { // <--- ADD THIS BLOCK
                    script {
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                    }
                } // <--- CLOSE withEnv BLOCK HERE
            }
        }
    }

    post {
        always {
            steps {
                echo 'Cleaning up Docker login...'
                // Ensure DOCKER_HOST is also set for logout
                withEnv(["DOCKER_HOST=tcp://host.docker.internal:23750"]) { // <--- ADD THIS BLOCK for logout
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