FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

RUN rm -f /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
      git \
      curl \
      openssh-client && \
    rm -rf /var/lib/apt/lists/*

RUN gem install rails foreman --no-document

WORKDIR /workspace
