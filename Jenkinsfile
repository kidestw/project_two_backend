// Jenkinsfile for Laravel Backend CI/CD Pipeline
// This pipeline automates the building, pushing, and deployment of your Dockerized Laravel backend.
// This file is assumed to be located in the root directory of your Git repository.

pipeline {
    // Agent: Specifies where the pipeline will run.
    // 'any' means Jenkins will pick any available agent. Ensure this agent has Docker installed.
    agent any

    // Environment variables that will be available throughout the pipeline.
    environment {
        // Your Docker Hub username for pushing images.
        DOCKER_HUB_USERNAME = 'kidest'
        // The name for your Docker image on Docker Hub.
        DOCKER_IMAGE_NAME = "kidest/back-end-backend"
        // GIT_COMMIT is a built-in Jenkins environment variable that holds the current Git commit hash.
        // It's used for tagging images for better versioning.
    }

    // Stages: Define the distinct steps of your CI/CD process.
    stages {
        // Stage 1: Checkout Code from Git Repository
        stage('Checkout Code') {
            steps {
                script {
                    // --- WARNING: SECURITY RISK ---
                    // These Git configurations are for troubleshooting and development environments
                    // where you might encounter SSL certificate issues or large repository sizes.
                    // For production, it's highly recommended to properly configure SSL certificates
                    // and optimize repository size rather than bypassing SSL verification.
                    echo "Configuring Git to bypass SSL verification and increase post buffer..."
                    sh 'git config --global http.sslVerify false'
                    sh 'git config --global http.postBuffer 524288000' // 500 MB
                }
                // Pull your entire repository from the specified Git repository and branch.
                // This will place all files directly into the Jenkins workspace root.
                git url: 'https://github.com/kidestw/project_two_backend.git',
                    branch: 'main'
            }
        }

        // Stage 2: Login to Docker Hub
        stage('Login to Docker Hub') {
            steps {
                script {
                    // Use Jenkins Credentials to securely access your Docker Hub token/password.
                    withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                        echo "Logging in to Docker Hub..."
                        // Execute docker login directly from the workspace root.
                        sh script: """#!/bin/bash
                            docker login -u ${DOCKER_HUB_USERNAME} --password-stdin <<< "${DOCKER_TOKEN}"
                        """,
                            returnStdout: true,
                            encoding: 'UTF-8'
                    }
                }
            }
        }

        // Stage 3: Build and Push Docker Image
        stage('Build and Push Docker Image') {
            steps {
                withEnv([
                    // DOCKER_HOST is needed here for 'docker build' to connect to the Docker Desktop daemon
                    "DOCKER_HOST=tcp://host.docker.internal:23750",
                    "DOCKER_CLIENT_TIMEOUT=600",
                    "COMPOSE_HTTP_TIMEOUT=600"
                ]) {
                    script {
                        echo "Building Docker image: ${DOCKER_IMAGE_NAME}:latest"
                        // Build the Docker image. The context is '.' because the Dockerfile is at the root.
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."

                        echo "Tagging Docker image with Git commit: ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"

                        retry(3) {
                            echo "Attempting to push ${DOCKER_IMAGE_NAME}:latest..."
                            sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        }
                        retry(3) {
                            echo "Attempting to push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}..."
                            sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                        }
                    }
                }
            }
        }

        // Stage 4: Deploy Services using Docker Compose
        stage('Deploy Services') {
            steps {
                script {
                    // Enable shell debugging to see executed commands and their environment
                    sh """#!/bin/bash
                        set -x # This will print each command before it's executed

                        echo "Current directory: $(pwd)"
                        echo "DOCKER_HOST value for this stage: ${DOCKER_HOST}" # This will be empty here, as it's not in this stage's default env

                        echo "Creating/Updating .env file for deployment..."
                        # Dynamically create the .env file in the repository root.
                        echo "APP_NAME=\\"CLMS\\"" > .env
                        echo "APP_ENV=local" >> .env
                        echo "APP_KEY=base64:rdyVG8KM7Owniz6O7ypo//7vkb2Y3yvI+ASiRZljCD8=" >> .env
                        echo "APP_DEBUG=true" >> .env

                        echo "APP_TIMEZONE=UTC" >> .env
                        echo "APP_URL=" >> .env
                        echo "APP_FRONTEND_URL=\\"http://localhost:3000\\"" >> .env
                        echo "FRONTEND_URL=\\"http://localhost:3000\\"" >> .env

                        echo "APP_LOCALE=en" >> .env
                        echo "APP_FALLBACK_LOCALE=en" >> .env
                        echo "APP_FAKER_LOCALE=en_US" >> .env

                        echo "PHP_CLI_SERVER_WORKERS=4" >> .env
                        echo "BCRYPT_ROUNDS=12" >> .env

                        echo "LOG_CHANNEL=stack" >> .env
                        echo "LOG_STACK=single" >> .env
                        echo "LOG_DEPRECATIONS_CHANNEL=null" >> .env
                        echo "LOG_LEVEL=debug" >> .env

                        echo "DB_CONNECTION=mysql" >> .env
                        echo "DB_HOST=clms_mysql_database" >> .env
                        echo "DB_PORT=3306" >> .env
                        echo "DB_DATABASE=clms_db" >> .env
                        echo "DB_USERNAME=root" >> .env
                        echo "DB_PASSWORD=" >> .env # For production, use Jenkins credential here

                        echo "SESSION_DRIVER=database" >> .env
                        echo "SANCTUM_STATEFUL_DOMAINS=localhost:3000" >> .env
                        echo "SESSION_LIFETIME=120" >> .env
                        echo "SESSION_ENCRYPT=false" >> .env
                        echo "SESSION_PATH=/" >> .env
                        echo "SESSION_DOMAIN=localhost" >> .env
                        echo "APP_URL=http://127.0.0.1:8000" >> .env

                        echo "BROADCAST_CONNECTION=log" >> .env
                        echo "FILESYSTEM_DISK=local" >> .env
                        echo "QUEUE_CONNECTION=database" >> .env

                        echo "CACHE_STORE=database" >> .env
                        echo "CACHE_PREFIX=" >> .env

                        echo "MEMCACHED_HOST=127.0.0.1" >> .env

                        echo "REDIS_CLIENT=phpredis" >> .env
                        echo "REDIS_HOST=127.0.0.1" >> .env
                        echo "REDIS_PASSWORD=null" >> .env
                        echo "REDIS_PORT=6379" >> .env

                        echo "MAIL_MAILER=smtp" >> .env
                        echo "MAIL_HOST=sandbox.smtp.mailtrap.io" >> .env
                        echo "MAIL_PORT=2525" >> .env
                        echo "MAIL_USERNAME=2d7f2d3bb66fad" >> .env
                        echo "MAIL_PASSWORD=fc622a91f97535" >> .env
                        echo "MAIL_ENCRYPTION=null" >> .env
                        echo "MAIL_FROM_ADDRESS=\\"noreply@clms.net\\"" >> .env
                        echo "MAIL_FROM_NAME=\\"CLMS\\"" >> .env

                        echo "AWS_ACCESS_KEY_ID=" >> .env
                        echo "AWS_SECRET_ACCESS_KEY=" >> .env
                        echo "AWS_DEFAULT_REGION=us-east-1" >> .env
                        echo "AWS_BUCKET=" >> .env
                        echo "AWS_USE_PATH_STYLE_ENDPOINT=false" >> .env

                        echo "VITE_APP_NAME=\\"CLMS\\"" >> .env
                        echo "WKHTML_PDF_BINARY=\\"/usr/local/bin/wkhtmltopdf\\"" >> .env

                        echo "Stopping and removing old Docker Compose services..."
                        # Run docker-compose down inside a container, explicitly passing DOCKER_HOST.
                        # Using docker/compose:1.29.2 for stability and hyphenated syntax.
                        docker run --rm \\
                            --env DOCKER_HOST="tcp://host.docker.internal:23750" \\
                            --volume "$(pwd)":/app \\
                            docker/compose:1.29.2 \\
                            docker-compose -f /app/docker-compose.yml \\
                            down --remove-orphans

                        echo "Starting new Docker Compose services..."
                        # Run docker-compose up inside a container, explicitly passing DOCKER_HOST.
                        docker run --rm \\
                            --env DOCKER_HOST="tcp://host.docker.internal:23750" \\
                            --volume "$(pwd)":/app \\
                            docker/compose:1.29.2 \\
                            docker-compose -f /app/docker-compose.yml \\
                            up -d --build
                    """
                }
            }
        }

        // Stage 5: Run Post-Deployment Tasks (e.g., Database Migrations, Cache Clearing)
        stage('Run Post-Deployment Tasks') {
            steps {
                script {
                    // Commands run directly from the repository root.
                    echo "Waiting for database and application services to be fully ready..."
                    sh 'sleep 20'

                    echo "Running Laravel database migrations..."
                    // DOCKER_HOST is not needed for docker exec as it operates on already running containers
                    sh 'docker exec clms_laravel_php_fpm php artisan migrate --force'

                    echo "Clearing and caching Laravel configurations, routes, and views..."
                    sh 'docker exec clms_laravel_php_fpm php artisan config:clear'
                    sh 'docker exec clms_laravel_php_fpm php artisan cache:clear'
                    sh 'docker exec clms_laravel_php_fpm php artisan route:clear'
                    sh 'docker exec clms_laravel_php_fpm php artisan view:clear'
                    sh 'docker exec clms_laravel_php_fpm php artisan config:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan route:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan view:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan optimize'
                }
            }
        }
    }

    // Post-build actions: These steps run regardless of the stage outcomes.
    post {
        always {
            echo 'Cleaning up Docker login...'
            withEnv([
                // DOCKER_HOST is still needed here for 'docker logout' to connect to the Docker Desktop daemon
                "DOCKER_HOST=tcp://host.docker.internal:23750",
                "DOCKER_CLIENT_TIMEOUT=600",
                "COMPOSE_HTTP_TIMEOUT=600"
            ]) {
                // Commands run directly from the repository root.
                sh 'docker logout'
            }
        }
        success {
            echo 'Backend CI/CD pipeline completed successfully! Services deployed and configured.'
        }
        failure {
            echo 'Backend CI/CD pipeline FAILED! Check console output for details.'
        }
    }
}
