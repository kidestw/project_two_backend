    // C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
    // Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

    pipeline {
        // Change the agent from 'any' to a Docker agent specifically for building Docker images
        agent {
            docker {
                image 'docker:dind' // Use the Docker-in-Docker image as the agent
                args '-v /var/run/docker.sock:/var/run/docker.sock' // Mount the host's Docker socket
            }
        }

        environment {
            // Environment variables for Docker Hub login and image naming
            DOCKER_HUB_USERNAME = 'kidest' // Your Docker Hub username
            DOCKER_IMAGE_NAME = "kidest/back-end-backend" // Your specified image name
        }

        stages {
            stage('Checkout Code') {
                steps {
                    // Checkout the source code from your GitHub repository
                    git url: 'https://github.com/kidestw/project_two_backend.git',
                        branch: 'main',
                        // 'github-credentials' is the ID of a Jenkins credential for GitHub access.
                        // Remove this line if your GitHub backend repo is public.
                        credentialsId: 'github-credentials'
                }
            }

            stage('Login to Docker Hub') {
                steps {
                    // Log in to Docker Hub using credentials configured in Jenkins
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        sh "echo $DOCKER_TOKEN | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
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
            // Post-build actions: These run after all stages are attempted.
            // 'always' ensures this block runs regardless of success or failure.
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
    