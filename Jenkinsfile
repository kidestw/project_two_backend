    // C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
    // Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

    pipeline {
        agent {
            docker {
                image 'docker:dind'
                // This 'privileged' flag is often necessary for docker:dind to function correctly,
                // as it needs full access to manage Docker daemons and containers.
                // Be aware of security implications in production. For local testing, it's common.
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
                    // Use withDockerRegistry for authenticated Docker operations
                    // This uses the 'docker-hub-token' credential you configured in Jenkins.
                    docker.withRegistry("https://registry.hub.docker.com", 'docker-hub-token') {
                        // Build the Docker image
                        script {
                            def customImage = docker.build "${DOCKER_IMAGE_NAME}:latest", "."
                            // Tag with commit SHA
                            customImage.tag("${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}")
                            // Push both tags
                            customImage.push()
                            customImage.push("${env.GIT_COMMIT}")
                        }
                    }
                }
            }
        }

        post {
            always {
                steps {
                    echo 'Cleaning up Docker login (handled by withDockerRegistry).'
                    // Explicit docker logout is not strictly necessary here as withDockerRegistry manages session
                    // but keeping a placeholder echo to indicate clean-up is intended.
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
    