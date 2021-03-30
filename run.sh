CONTAINER_ID=`docker ps -aq -f 'name=gitlab-dev'`

if [ -z ${CONTAINER_ID+x} ]; then
  docker run --name gitlab-dev -d -p 3000:3000 -v /Users/${USER}/.ssh:/home/ubuntu/.ssh -v $(pwd)/gitlab:/home/ubuntu/gitlab-development-kit/gitlab gitlab-dev-docker:latest
  CONTAINER_ID=`docker ps -aq -f 'name=gitlab-dev'`  
fi

docker start $CONTAINER_ID

docker exec -it $CONTAINER_ID bash