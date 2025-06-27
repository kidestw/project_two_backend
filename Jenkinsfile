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
                    git url: 'https://github.com/kidestw/project_two_backend.git',
                        branch: 'main'
                }
            }

            stage('Login to Docker Hub') {
                steps {
                    script {
                        // Use withCredentials to get the Docker Hub token as an environment variable
                        withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                            // Perform docker login using the token.
                            // Explicitly use 'bash' for the '<<<` (here string) operator.
                            sh script: "docker login -u ${DOCKER_HUB_USERNAME} --password-stdin <<< ${DOCKER_TOKEN}",
                                     returnStdout: true,
                                     encoding: 'UTF-8' // Ensure correct encoding
                        }
                    }
                }
            }

            stage('Build and Push Docker Image') {
                steps {
                    script {
                        // Build the Docker image
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                        // Push the images to Docker Hub
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                    }
                }
            }
        }

        post {
            always {
                steps {
                    echo 'Cleaning up Docker login...'
                    // Explicitly logout from Docker Hub
                    sh 'docker logout'
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
    