# --- Stage 1: Composer dependencies ---
# Use a dedicated Composer image for installing dependencies
FROM composer:2.7 as composer_builder

# Set the working directory inside the container
WORKDIR /app

# Copy composer.json and composer.lock to leverage Docker's caching
COPY composer.json composer.lock ./

# Install Composer dependencies, ignoring platform requirements.
# This is crucial because the 'composer' base image itself might not have all PHP extensions
# required by your project's composer.lock, but the *final* PHP-FPM image will.
# --no-dev: Skips installation of development dependencies
# --optimize-autoloader: Optimizes Composer's autoloader for faster execution
# --no-scripts: Prevents execution of scripts defined in composer.json (often problematic in builds)
# --ignore-platform-reqs: Tells Composer to ignore PHP version and extension requirements
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# --- Stage 2: Final PHP-FPM image for the application ---
# Use the official PHP-FPM image for the application runtime
FROM php:8.3-fpm-alpine

# Set the working directory for the application
WORKDIR /var/www/html

# Install necessary PHP extensions in the final stage
# gd: Required by phpoffice/phpspreadsheet for image manipulation
# exif: Required by spatie/image and spatie/laravel-medialibrary for EXIF data handling
# pdo_mysql: Common for Laravel applications to connect to MySQL databases
# bcmath: Often used in Laravel for arbitrary precision mathematics
# opcache: Improves PHP performance by caching precompiled script bytecode
# pcntl: Process control support (useful for Laravel Queue workers)
# zip: For handling zip archives (e.g., by phpoffice/phpspreadsheet)
RUN apk add --no-cache \
        libzip-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        exif \
        pdo_mysql \
        bcmath \
        opcache \
        pcntl \
        zip \
    && rm -rf /tmp/* /var/cache/apk/*

# Copy the application code from your local directory into the container
COPY . .

# Copy the optimized Composer dependencies from the composer_builder stage
COPY --from=composer_builder /app/vendor /var/www/html/vendor

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
