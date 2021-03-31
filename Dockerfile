FROM ubuntu:20.04

EXPOSE 3000

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bk \
	&& touch /etc/apt/sources.list \
	&& echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

COPY gitlab-development-kit/packages.txt .

# Install packages
RUN apt-get update && apt-get install -y gnupg git cmake curl libgpgme-dev software-properties-common \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get install -y $(sed -e 's/#.*//' /packages.txt) \
    && apt-get purge software-properties-common -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/*

RUN useradd --user-group --create-home --groups sudo ubuntu

RUN usermod -s /bin/bash ubuntu

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu_no_password

ENV PATH="/home/gdk/.asdf/shims:/home/gdk/.asdf/bin:${PATH}"

RUN git clone https://github.com/asdf-vm/asdf.git /home/gdk/.asdf --branch v0.8.0

USER ubuntu

WORKDIR /home/ubuntu

COPY --chown=ubuntu start.sh .

RUN chmod u+x start.sh

CMD tail -f /dev/null
