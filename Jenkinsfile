pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'kidest/back-end-backend'
        DOCKER_TAG = 'latest'
    }

    stages {
        stage('Clone Repo') {
            steps {
                echo 'Cloning repository...'
                sh 'rm -rf project_two_backend'
                sh 'git clone https://github.com/kidestw/project_two_backend.git'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                    sh '''
                    echo "$DOCKER_TOKEN" | docker login -u kidest --password-stdin
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                dir('project_two_backend') {
                    sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE_NAME}:16
                    docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE_NAME}:16
                    """
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                dir('project_two_backend') {
                    script {
                        // Stop existing containers gracefully if they exist
                        sh 'docker-compose down || true'

                        // Start containers detached, rebuild images if needed
                        sh 'docker-compose up -d --build'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Logging out from Docker Hub...'
            sh 'docker logout'
        }
        success {
            echo '✅ Deployment completed successfully!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
