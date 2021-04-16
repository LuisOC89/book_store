FROM python:3.9.1-alpine3.13

# Update the Python image.
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
  && apk update \
  && apk --no-cache upgrade

# Add run-time dependencies.
RUN apk --no-cache add \
    bash \
    jpeg-dev cairo-dev pango-dev gdk-pixbuf-dev \
    fontconfig ttf-dejavu ttf-liberation \
    libffi \
    libpq \
    zlib

# Add build dependencies.
RUN apk --no-cache add --virtual .build-deps \
    build-base \
    # Install Rust Required for cryptography build
    rust=1.47.0-r2 \
    cargo \
    git \
    linux-headers \
    openssh-client \
    openssl-dev \
    postgresql-dev \
    python3-dev

# Update pip.
RUN pip install --upgrade pip

WORKDIR /var/www/bookstore

# Install Python requirements.
COPY requirements.txt .
RUN pip install -r requirements.txt --src /usr/local/src
RUN pip install pdbpp

# Remove the build dependencies.
RUN apk del .build-deps

# Add project code last. This ensures as much as possible
# will benefit from the cache.
COPY . .
RUN chmod +x config/wsgi.py

# This is the command that will be run when the container starts.
CMD ["docker/run_web.sh"]
EXPOSE 8000
