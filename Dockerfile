# --- Stage 1: Composer dependencies ---
# Use a dedicated Composer image for installing dependencies
FROM composer:2.7 as composer_builder

# Set the working directory inside the container
WORKDIR /app

# Install necessary PHP extensions in the composer_builder stage
# This ensures Composer can resolve dependencies that require these extensions
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

# Copy composer.json and composer.lock to leverage Docker's caching
COPY composer.json composer.lock ./

# Install Composer dependencies
# --no-dev: Skips installation of development dependencies
# --optimize-autoloader: Optimizes Composer's autoloader for faster execution
# --no-scripts: Prevents execution of scripts defined in composer.json (often problematic in builds)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# --- Stage 2: Final PHP-FPM image for the application ---
# Use the official PHP-FPM image for the application runtime
FROM php:8.3-fpm-alpine

# Set the working directory for the application
WORKDIR /var/www/html

# Install necessary PHP extensions in the final stage (even though Composer checked them)
# This ensures the runtime environment has the necessary extensions
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
