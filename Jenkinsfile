pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = 'kidest'
        DOCKER_IMAGE_NAME = "kidest/back-end-backend"
    }

    stages {
        stage('Manual Git Clone') {
            steps {
                script {
                    echo "Cloning public GitHub repo manually (no token)..."
                    sh 'rm -rf project_two_backend'
                    sh 'git clone https://github.com/kidestw/project_two_backend.git'
                    dir('project_two_backend') {
                        sh 'ls -la'
                    }
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        echo "Logging in to Docker Hub..."
                        sh """#!/bin/bash
                            docker login -u ${DOCKER_HUB_USERNAME} --password-stdin <<< "${DOCKER_TOKEN}"
                        """
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                dir('project_two_backend') {
                    withEnv([
                        "DOCKER_HOST=tcp://host.docker.internal:23750",
                        "DOCKER_CLIENT_TIMEOUT=600",
                        "COMPOSE_HTTP_TIMEOUT=600"
                    ]) {
                        script {
                            sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                            sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                            retry(3) {
                                sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                            }
                            retry(3) {
                                sh "docker push ${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy Services with Docker Compose') {
            steps {
                dir('project_two_backend') {
                    script {
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
                        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/app docker/compose:latest docker compose -f /app/docker-compose.yml down --remove-orphans'
                        sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/app docker/compose:latest docker compose -f /app/docker-compose.yml up -d --build'
                    }
                }
            }
        }

        stage('Post Deploy Commands') {
            steps {
                script {
                    sh 'sleep 20'
                    sh 'docker exec clms_laravel_php_fpm php artisan migrate --force'
                    sh 'docker exec clms_laravel_php_fpm php artisan config:clear'
                    sh 'docker exec clms_laravel_php_fpm php artisan route:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan config:cache'
                }
            }
        }
    }

    post {
        always {
            echo 'Logging out of Docker...'
            sh 'docker logout || true'
        }
        success {
            echo '✅ Backend CI/CD pipeline completed successfully!'
        }
        failure {
            echo '❌ Backend CI/CD pipeline FAILED. Check logs for details.'
        }
    }
}
