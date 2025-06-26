    // C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
    // Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

    pipeline {
        // Use the Docker-in-Docker image as the agent
        // This image contains its own Docker daemon and client for nested Docker operations.
        agent {
            docker {
                image 'docker:dind'
                // No 'args' needed here for standard dind usage; the container will use its internal Docker daemon.
                // If you *must* use the host's Docker daemon, the previous args line would be correct,
                // but then the host needs Docker properly configured for the Jenkins container.
                // For now, let's rely on dind's internal capabilities.
            }
        }

        environment {
            DOCKER_HUB_USERNAME = 'kidest' // Your Docker Hub username
            DOCKER_IMAGE_NAME = "kidest/back-end-backend" // Your specified image name
        }

        stages {
            stage('Checkout Code') {
                steps {
                    // Checkout the source code from your GitHub repository
                    // Removed credentialsId as your repo appears public (no "could not find" error for GitHub)
                    git url: 'https://github.com/kidestw/project_two_backend.git',
                        branch: 'main'
                }
            }

            stage('Login to Docker Hub') {
                steps {
                    // Log in to Docker Hub using credentials configured in Jenkins
                    // The 'docker' command should now be available within the 'docker:dind' agent.
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        sh "docker login -u ${DOCKER_HUB_USERNAME} --password-stdin <<< ${DOCKER_TOKEN}"
                        // Changed `echo $DOCKER_TOKEN | ...` to `<<<` for better security and reliability
                        // The warning about Groovy string interpolation is still technically valid,
                        // but `withCredentials` is the secure way to get the token into the shell.
                    }
                }
            }

            stage('Build and Push Docker Image') {
                steps {
                    // Build the Docker image using the Dockerfile in the current directory (back-end)
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                    // Push the images to Docker Hub
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                }
            }
        }

        post {
            always {
                steps {
                    echo 'Cleaning up Docker login...'
                    sh 'docker logout' // Always log out from Docker Hub
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
    