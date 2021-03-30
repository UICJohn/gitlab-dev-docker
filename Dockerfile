FROM ubuntu:20.04

EXPOSE 3000

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bk \
	&& touch /etc/apt/sources.list \
	&& echo   "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \n deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse \n deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

COPY packages.txt /

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

USER ubuntu

WORKDIR /home/ubuntu

# Install asdf, plugins and correct versions
ENV PATH="/home/ubuntu/.asdf/shims:/home/ubuntu/.asdf/bin:${PATH}"

COPY --chown=ubuntu .tool-versions .

RUN git clone https://github.com/asdf-vm/asdf.git /home/ubuntu/.asdf --branch v0.8.0 && \
  for plugin in $(grep -v '#' .tool-versions | cut -f1 -d" "); do \
  echo "Installing asdf plugin '$plugin' and install current version" ; \
  asdf plugin add $plugin; \
  NODEJS_CHECK_SIGNATURES=no asdf install ; done \
  && gem install bundler -v '= 1.17.3' \
  && gem install gitlab-development-kit \
  # simple tests that tools work
  && bash -lec "asdf version; yarn --version; node --version; ruby --version" \
  # clear tmp caches e.g. from postgres compilation
  && rm -rf /tmp/*

RUN git clone https://gitlab.com/gitlab-org/gitlab-development-kit.git

WORKDIR /home/ubuntu/gitlab-development-kit

RUN git checkout v0.2.9

RUN make bootstrap

COPY --chown=ubuntu gdk.yml .

ADD --chown=ubuntu gitlab /home/ubuntu/gitlab-development-kit/gitlab

#Change version if mimemagic issue solved
RUN cd gitlab \
    && git checkout dependency/13.5.7-ee

#Mirroring
RUN yarn config set registry http://registry.npm.bilibili.co

RUN bundle config 'mirror.https://rubygems.org' 'https://mirrors.tuna.tsinghua.edu.cn/rubygems/'

RUN echo "export GOPROXY=http://goproxy.bilibili.co" > ~/.bashrc

RUN gem sources --remove https://rubygems.org/ \
  && gem sources -a https://mirrors.tuna.tsinghua.edu.cn/rubygems/

RUN mkdir ~/.pip && \
    touch pip.conf && \
    echo "[global] \nindex-url=https://mirrors.aliyun.com/pypi/simple/ \n[install] \ntrusted-host=mirrors.aliyun.com" > ~/.pip/pip.conf

#Start installing
RUN gdk install \
    && gdk start

RUN sudo rm -r gitlab

CMD gdk tail
