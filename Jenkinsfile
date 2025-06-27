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

            stage('Build and Push Docker Image') {
                steps {
                    script {
                        // Explicitly retrieve the credential using withCredentials
                        withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN_SECRET')]) {
                            // Now pass the retrieved token to docker.withRegistry
                            docker.withRegistry("https://registry.hub.docker.com", DOCKER_TOKEN_SECRET) {
                                def customImage = docker.build "${DOCKER_IMAGE_NAME}:latest", "."
                                customImage.tag("${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}")
                                customImage.push()
                                customImage.push("${env.GIT_COMMIT}")
                            }
                        }
                    }
                }
            }
        }

        post {
            always {
                steps {
                    echo 'Cleaning up Docker login (handled by withDockerRegistry).'
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
    