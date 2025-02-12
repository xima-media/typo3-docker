FROM debian:bookworm-slim
ARG UBUNTU_CODENAME=jammy

COPY ./requirements.yml /tmp/requirements.yml

# base packages
RUN apt update -yqq \
    && apt install -yqq \
        openssh-client git curl wget gpg unzip \
        sshpass python3-paramiko python3-passlib \
        jq yamllint

# Ansible with collections https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian
RUN wget -O /tmp/ansible.asc "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" \
    && gpg --dearmour -o  /usr/share/keyrings/ansible-archive-keyring.gpg /tmp/ansible.asc \
    && echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" > /etc/apt/sources.list.d/ansible.list \
    && apt update -yqq \
    && apt install -yqq ansible \
    && ansible-galaxy install -v -r /tmp/requirements.yml \
    && rm /tmp/requirements.yml /tmp/ansible.asc

CMD ["/bin/bash"]
