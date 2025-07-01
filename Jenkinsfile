pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS_ID = 'docker-hub-token'
        DOCKER_IMAGE_NAME = 'kidestw/clms-backend'
        DOCKER_IMAGE_TAG = 'latest'
    }

    stages {
        stage('Clone Repository') {
            steps {
                deleteDir()
                sh 'git clone https://github.com/kidestw/project_two_backend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('project_two_backend') {
                    script {
                        // Generate .env
                        sh """
                            echo "APP_NAME=CLMS" > .env
                            echo "APP_ENV=local" >> .env
                            echo "DB_CONNECTION=mysql" >> .env
                            echo "DB_HOST=clms_mysql_database" >> .env
                            echo "DB_PORT=3306" >> .env
                            echo "DB_DATABASE=clms_db" >> .env
                            echo "DB_USERNAME=root" >> .env
                            echo "DB_PASSWORD=" >> .env
                            echo "APP_URL=http://127.0.0.1:8000" >> .env
                            echo "SESSION_DRIVER=database" >> .env
                        """

                        // Build Docker image
                        sh 'docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .'
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                    sh 'docker push $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'
                }
            }
        }

        stage('Deploy via Docker Compose') {
            steps {
                dir('project_two_backend') {
                    script {
                        // Shutdown previous containers
                        sh 'docker-compose down || true'
                        // Deploy
                        sh 'docker-compose up -d --build'
                    }
                }
            }
        }

        stage('Post Deploy') {
            steps {
                echo '✅ Deployment completed successfully!'
            }
        }
    }

    post {
        always {
            echo 'Logging out of Docker...'
            sh 'docker logout'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
