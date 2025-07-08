# This Dockerfile sets up an Alpine-based container with Ansible and necessary tools for deployments.
FROM alpine:latest

# Required ansible galaxy modules
COPY ./requirements.yml /tmp/requirements.yml

# Add the config generator script
COPY generate-deploy-config.sh /usr/local/bin/

RUN apk update \
    && apk add --no-cache \
        # Install additional tools
        git \
        curl \
        wget \
        gnupg \
        unzip \
        jq \
        yamllint \
        # Install Ansible
        ansible bash openssh sshpass rsync py3-passlib py3-netaddr \
    # Install Ansible collections
    && ansible-galaxy install -v -r /tmp/requirements.yml \
    && rm /tmp/requirements.yml \
    # Set script permissions
    && chmod +x /usr/local/bin/generate-deploy-config.sh

CMD ["/bin/bash"]
