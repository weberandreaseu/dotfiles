FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    zsh \
    bash \
    git \
    curl \
    wget \
    stow \
    vim \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

RUN useradd -m -s /bin/zsh testuser \
    && echo 'testuser:testuser' | chpasswd

COPY . /tmp/dotfiles

COPY setup.sh /tmp/setup.sh
RUN chown testuser:testuser /tmp/setup.sh

RUN su - testuser -c "export HOME=/home/testuser && /tmp/setup.sh"

COPY test/ /tmp/test/
RUN chown -R testuser:testuser /home/testuser

USER testuser
WORKDIR /home/testuser

CMD ["/tmp/test/run.sh"]
