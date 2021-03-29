if [ ! -d "./gitlab" ]
then
  git clone git@git.bilibili.co:ops/gitlab/gitlab-org/gitlab.git
fi

docker build -f Dockerfile -t gitlab-dev-docker .