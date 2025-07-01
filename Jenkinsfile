pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = 'kidest'
        DOCKER_IMAGE_NAME = "kidest/back-end-backend"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/kidestw/project_two_backend.git', branch: 'main'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                    sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin'
                }
            }
        }

        stage('Create .env File') {
            steps {
                script {
                    writeFile file: '.env', text: '''\
APP_NAME=CLMS
APP_ENV=local
APP_KEY=base64:rdyVG8KM7Owniz6O7ypo//7vkb2Y3yvI+ASiRZljCD8=
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://127.0.0.1:8000
APP_FRONTEND_URL=http://localhost:3000
FRONTEND_URL=http://localhost:3000

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file

PHP_CLI_SERVER_WORKERS=4
BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=clms_mysql_database
DB_PORT=3306
DB_DATABASE=clms_db
DB_USERNAME=root
DB_PASSWORD=

SESSION_DRIVER=database
SANCTUM_STATEFUL_DOMAINS=localhost:3000
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=localhost

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database
CACHE_PREFIX=

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=2d7f2d3bb66fad
MAIL_PASSWORD=fc622a91f97535
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=noreply@clms.net
MAIL_FROM_NAME=CLMS

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME=CLMS
WKHTML_PDF_BINARY=/usr/local/bin/wkhtmltopdf
'''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:latest ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_IMAGE_NAME}:${env.GIT_COMMIT}"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh 'docker-compose down --remove-orphans || true'
                    sh 'docker-compose up -d --build'
                }
            }
        }

        stage('Run Laravel Post-Deploy Commands') {
            steps {
                script {
                    sh 'sleep 20' // wait for containers to initialize
                    sh 'docker exec clms_laravel_php_fpm php artisan migrate --force'
                    sh 'docker exec clms_laravel_php_fpm php artisan config:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan route:cache'
                    sh 'docker exec clms_laravel_php_fpm php artisan view:cache'
                }
            }
        }
    }

    post {
        always {
            node {
                sh 'docker logout || true'
            }
        }
        success {
            echo '✅ Backend CI/CD pipeline completed successfully!'
        }
        failure {
            echo '❌ Backend CI/CD pipeline FAILED. Check logs for details.'
        }
    }
}
