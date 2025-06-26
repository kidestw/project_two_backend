    // C:\Users\User\Desktop\project_two\back-end\Jenkinsfile
    // Defines a declarative Jenkins Pipeline for Laravel backend CI/CD

    pipeline {
        agent any // The Jenkins agent where this pipeline will run

        environment {
            # Environment variables for Docker Hub login and image naming
            DOCKER_HUB_USERNAME = 'kidest' // Your Docker Hub username
            # IMPORTANT: Replace 'kidest/your-laravel-app' with your actual Docker Hub path
            # Example: kidest/back-end-backend
            DOCKER_IMAGE_NAME = "kidest/back-end-backend" // Your specified image name
        }

        stages {
            stage('Checkout Code') {
                steps {
                    # Checkout the source code from your GitHub repository
                    # Ensure you use your actual backend GitHub repo URL
                    git url: 'https://github.com/kidestw/project_two_backend.git', // YOUR BACKEND GITHUB REPO URL
                        branch: 'main',
                        # 'github-credentials' is the ID of a Jenkins credential for GitHub access.
                        # Only needed if your GitHub backend repo is private. For public, you can remove this line.
                        credentialsId: 'github-credentials'
                }
            }

            stage('Login to Docker Hub') {
                steps {
                    # Log in to Docker Hub using credentials configured in Jenkins
                    # You need to create a Jenkins 'Secret Text' credential named 'docker-hub-token'
                    # with your Docker Hub Access Token as the secret.
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        sh "echo $DOCKER_TOKEN | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                    }
                }
            }

            stage('Build and Push Docker Image') {
                steps {
                    # Build the Docker image using the Dockerfile in the current directory (back-end)
                    # Tag it with 'latest' and the Git commit SHA for versioning
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                    # Push the images to Docker Hub
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                }
            }

            stage('Clean Up Docker Login') {
                # This stage runs always to ensure Docker logout, even if previous steps fail
                always {
                    steps {
                        sh 'docker logout'
                    }
                }
            }
        }

        post {
            # Post-build actions: notifications (optional)
            success {
                echo 'Backend Docker image built and pushed successfully!'
                // You can add email notifications here if configured in Jenkins
            }
            failure {
                echo 'Backend Docker image build and push FAILED!'
            }
        }
    }
    