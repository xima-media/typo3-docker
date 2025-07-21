# This Dockerfile sets up an Alpine-based container with Ansible and necessary tools for deployments.
FROM alpine:latest

RUN apk update \
    # Upgrade existing packages
    && apk upgrade --no-cache \
    # Install packages
    && apk add --no-cache \
        # Additional tools
        git \
        curl \
        wget \
        gnupg \
        unzip \
        jq \
        yamllint \
        gettext-envsubst \
        # Ansible
        ansible bash openssh sshpass rsync py3-passlib py3-netaddr

# Install Ansible collections
COPY ./requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -v -r /tmp/requirements.yml \
    && rm /tmp/requirements.yml

# Add the config generator script and set permissions
COPY --chmod=755 generate-deploy-config.sh /usr/local/bin/generate-deploy-config.sh

CMD ["/bin/bash"]
