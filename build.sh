docker pull hub.bilibili.co/gitlab/gitlab-dev-docker:13.5.7 || true

if [ ! -d "./gitlab-development-kit" ]
then
  git clone https://gitlab.com/gitlab-org/gitlab-development-kit.git
fi

cd gitlab-development-kit && git checkout v0.2.9

cd ../

DOCKER_BUILDKIT=1 docker build -f Dockerfile -t hub.bilibili.co/gitlab/gitlab-dev-docker:13.5.7 .
