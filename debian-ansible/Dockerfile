FROM debian:trixie-slim

COPY ./requirements.yml /tmp/requirements.yml

RUN apt-get update -yqq && \
    apt-get install openssh-client git curl wget unzip sshpass ansible python3-paramiko python3-passlib jq -yqq && \
    ansible-galaxy install -v -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml && \
    ansible --version && \
    ansible-community --version

CMD ["/bin/bash"]
