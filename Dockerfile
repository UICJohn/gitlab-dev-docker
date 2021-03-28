FROM ubuntu:20.04

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bk \
	&& touch /etc/apt/sources.list \
	&& echo  "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multivers \n deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multivers \n deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multivers \n deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multivers \n deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multivers \n deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multivers \n deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multivers \n deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
COPY packages.txt /
RUN apt-get update && apt-get install -y gnupg software-properties-common \
    && apt-get install -y $(sed -e 's/#.*//' /packages.txt) \
    && apt-get purge software-properties-common -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/*

RUN useradd --user-group --create-home --groups sudo gdk

RUN echo "gdk ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/gdk_no_password

WORKDIR /home/gdk

USER gdk

ENV PATH="/home/gdk/.asdf/shims:/home/gdk/.asdf/bin:${PATH}"

COPY --chown=gdk .tool-versions .

RUN git clone https://github.com/asdf-vm/asdf.git /home/gdk/.asdf --branch v0.8.0 && \
  for plugin in $(grep -v '#' .tool-versions | cut -f1 -d" "); do \
  echo "Installing asdf plugin '$plugin' and install current version" ; \
  asdf plugin add $plugin; \
  NODEJS_CHECK_SIGNATURES=no asdf install ; done \
  # simple tests that tools work
  && bash -lec "asdf version; yarn --version; node --version; ruby --version" \
  # clear tmp caches e.g. from postgres compilation
  && rm -rf /tmp/*

RUN git clone https://gitlab.com/gitlab-org/gitlab-development-kit.git