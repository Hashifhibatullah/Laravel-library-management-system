FROM composer:2.3.5 AS builder  # Use a descriptive name

# Install dependencies in a separate stage
WORKDIR /app
COPY . /app
RUN composer install --no-dev  # Install only production dependencies

# Separate stage for building the application
FROM php:8.1.0-apache  # Use official image with Apache pre-installed
RUN apt-get update && apt-get install -y \
  libpq-dev \
  libcurl4-gnutls-dev \
  unzip \
  git
RUN docker-php-ext-install pdo pdo_mysql

EXPOSE 80

# Copy application code from builder stage
COPY --from=builder /app /var/www/html  # Use /var/www/html for Apache

# Copy configuration file
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf

# Fix permissions securely (avoid chmod 777)
RUN chown -R www-data:www-data /var/www/storage/ && \
    a2enmod rewrite

# Set default port in configuration file instead of modifying ports.conf
# (Recommended approach for maintainability)
# Consider adding additional configuration based on your needs
# (e.g., virtual hosts)

CMD ["apache2", "-f", "/etc/apache2/apache2.conf"]  # Explicitly define main process
