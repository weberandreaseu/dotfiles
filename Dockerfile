FROM ubuntu:24.04

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
    ca-certificates \
    gnupg \
    unzip \
    fontconfig \
    build-essential \
    pkg-config \
    libx11-dev \
    libxft-dev \
    libxcb1-dev \
    libxcb-randr0-dev \
    libxcb-util0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libglib2.0-dev \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh testuser \
    && echo 'testuser:testuser' | chpasswd

COPY . /tmp/dotfiles

RUN chown -R testuser:testuser /tmp/dotfiles

RUN mkdir -p /home/testuser/git && cp -r /tmp/dotfiles /home/testuser/git/dotfiles

RUN touch /var/run/utmp && chown testuser:testuser /var/run/utmp

RUN su - testuser -c "export HOME=/home/testuser && /home/testuser/git/dotfiles/bootstrap/02-fonts.sh"

RUN su - testuser -c "export HOME=/home/testuser && /home/testuser/git/dotfiles/bootstrap/03-shell.sh"

RUN su - testuser -c "export HOME=/home/testuser && /home/testuser/git/dotfiles/bootstrap/05-tools.sh"

RUN su - testuser -c "export HOME=/home/testuser && /home/testuser/git/dotfiles/bootstrap/07-dotfiles.sh"

USER testuser
WORKDIR /home/testuser

CMD ["zsh"]
