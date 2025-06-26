    // C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
    // Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

    pipeline {
        agent {
            docker {
                image 'docker:dind'
                args '--privileged'
            }
        }

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
                    // Wrap docker.withRegistry in a script block
                    script { // <--- ADDED THIS SCRIPT BLOCK
                        docker.withRegistry("https://registry.hub.docker.com", 'docker-hub-token') {
                            def customImage = docker.build "${DOCKER_IMAGE_NAME}:latest", "."
                            customImage.tag("${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}")
                            customImage.push()
                            customImage.push("${env.GIT_COMMIT}")
                        }
                    } // <--- END OF SCRIPT BLOCK
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
    