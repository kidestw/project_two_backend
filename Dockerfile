    # C:\Users\User\Desktop\project_two\back-end\Dockerfile

    # --- Stage 1: Install Composer dependencies ---
    # Using a Composer image to install PHP dependencies
    FROM composer:2.7 AS composer_builder

    # Set the working directory inside the container
    WORKDIR /app

    # Copy composer.json and composer.lock to leverage Docker cache
    # If composer.lock is not present, `composer install` will generate it.
    COPY composer.json composer.lock ./

    # Install Composer dependencies, optimized for production
    # --no-dev: Excludes development dependencies
    # --optimize-autoloader: Optimizes Composer's autoloader for faster execution
    # --no-scripts: Prevents execution of scripts defined in composer.json (often problematic in builds)
    RUN composer install --no-dev --optimize-autoloader --no-scripts

    # --- Stage 2: Build frontend assets (if Laravel serves them) ---
    # This stage is for Laravel projects that compile their own frontend assets (e.g., using Laravel Mix or Vite).
    # If your Next.js frontend handles ALL assets, you can comment out or remove this entire stage.
    FROM node:20-alpine AS assets_builder
    WORKDIR /app
    COPY package.json yarn.lock* package-lock.json* ./
    # Use npm ci --force to handle peer dependency issues (similar to frontend)
    RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
        elif [ -f package-lock.json ]; then npm ci --force; \
        else npm install --force; fi
    COPY . .
    # Run the production build for frontend assets
    # Replace 'npm run build' with 'npm run prod' or 'npm run dev' if your package.json uses those scripts.
    # If you are using Vite, it might be 'npm run build' for production.
    RUN npm run build # Or npm run prod, if your project uses it for production assets.


    # --- Stage 3: Final PHP-FPM image for Laravel application ---
    # Using a PHP-FPM image with Alpine Linux for a smaller footprint
    FROM php:8.3-fpm-alpine

    # Set the working directory inside the container
    WORKDIR /var/www/html

    # Install system dependencies required by Laravel and common PHP extensions
    # nginx: will be used by the separate nginx service. Installed here for consistency.
    # mysql-client: For database interaction (e.g., during migrations or debugging)
    # git, curl: Common utilities
    # libzip-dev, libpng-dev, jpeg-dev, libwebp-dev, freetype-dev, libxpm-dev, icu-dev: For PHP extensions like GD, Zip, Intl
    RUN apk add --no-cache \
        nginx \
        mysql-client \
        git \
        curl \
        libzip-dev \
        libpng-dev \
        jpeg-dev \
        libwebp-dev \
        freetype-dev \
        libxpm-dev \
        icu-dev && \
        # Install and configure PHP extensions
        docker-php-ext-install pdo_mysql zip bcmath && \
        docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
        docker-php-ext-install gd && \
        # Clean up temporary files
        rm -rf /tmp/* /var/cache/apk/*

    # Copy Composer dependencies from the composer_builder stage
    # This ensures only production dependencies are included
    COPY --from=composer_builder /app/vendor /var/www/html/vendor

    # Copy the entire Laravel application code from your local machine
    COPY . /var/www/html

    # Copy compiled frontend assets from the assets_builder stage
    # Only uncomment if your assets_builder stage is active and relevant
    # COPY --from=assets_builder /app/public /var/www/html/public

    # Set appropriate permissions for Laravel's storage and bootstrap/cache directories
    # This is crucial for Laravel to function correctly (e.g., writing logs, caching views)
    RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
        chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

    # Expose PHP-FPM port (Nginx will connect to this)
    EXPOSE 9000

    # Default command for the PHP-FPM service
    # This will typically be overridden by docker-compose, but serves as a default
    CMD ["php-fpm"]
    