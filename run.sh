read  -n 1 -p "Rebuild?(default N)[Y/N]:" REBUILD

if [[ $REBUILD != "Y" ]]; then
  read  -n 1 -p "Reinit Container?(default N)[Y/N]:" REINIT
  echo "\n"
fi


if [[ $REBUILD == "Y" ]]; then
  docker ps -aq -f 'name=gitlab-dev' | xargs docker rm -f
  source build.sh
fi

if [[ $REINIT == "Y" ]]; then
  docker ps -aq -f 'name=gitlab-dev' | xargs docker rm -f
fi

CONTAINER_ID=`docker ps -aq -f 'name=gitlab-dev'`

if [ -z ${CONTAINER_ID} ]; then
  docker run --name gitlab-dev -d -p 3000:3000 -v $(pwd)/.asdf:/home/ubuntu/.asdf -v /Users/${USER}/.ssh:/home/ubuntu/.ssh -v $(pwd)/gitlab-development-kit:/home/ubuntu/gitlab-development-kit hub.bilibili.co/gitlab/gitlab-dev-docker:13.5.7
  CONTAINER_ID=`docker ps -aq -f 'name=gitlab-dev'`
fi

docker start $CONTAINER_ID

docker exec -it $CONTAINER_ID bash
