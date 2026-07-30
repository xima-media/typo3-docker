# This Dockerfile sets up an Alpine-based container with Ansible and necessary tools for deployments.
FROM alpine:latest

RUN apk update \
    # Upgrade existing packages
    && apk upgrade --no-cache \
    # Install packages
    && apk add --no-cache \
        # Additional tools
        bind-tools \
        git \
        curl \
        wget \
        gnupg \
        unzip \
        jq \
        yq \
        yamllint \
        gettext-envsubst \
        check-jsonschema \
        bash \
        shellcheck \
        openssh \
        rsync \
        # Ansible
        ansible sshpass py3-passlib py3-netaddr

# Install Ansible collections
COPY ./requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -v -r /tmp/requirements.yml \
    && rm /tmp/requirements.yml

CMD ["/bin/bash"]
