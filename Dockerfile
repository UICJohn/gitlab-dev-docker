FROM ubuntu:20.04

EXPOSE 3000

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bk \
	&& touch /etc/apt/sources.list \
	&& echo   "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

COPY packages.txt /

# Install packages
RUN apt-get update && apt-get install -y gnupg git cmake curl software-properties-common \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y $(sed -e 's/#.*//' /packages.txt) \
    && apt-get purge software-properties-common -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/*

RUN useradd --user-group --create-home --groups sudo ubuntu

RUN usermod -s /bin/bash ubuntu

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu_no_password

# RUN echo "dash dash/sh boolean false" | debconf-set-selections \
#     && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER ubuntu

WORKDIR /home/ubuntu

RUN git clone https://gitlab.com/gitlab-org/gitlab-development-kit.git

WORKDIR /home/ubuntu/gitlab-development-kit

RUN git checkout v0.2.9

RUN make bootstrap

COPY --chown=ubuntu gdk.yml .

ADD --chown=ubuntu gitlab /home/ubuntu/gitlab-development-kit/gitlab

RUN gdk install

RUN gdk start

CMD gdk tail
