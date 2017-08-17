#!/bin/bash
pushd ./utils
. ./sys_info.sh
popd

if [ "$start_service"x = ""x ]; then
    service docker start
else
    groupadd docker
    $start_service docker.service
fi
if [ "`ps -aux | grep docker`"x != ""x ]; then
    print_info 0 docker-start-service
else
    print_info 1 docker-start-service
fi


docker pull forumi0721alpineaarch64/alpine-aarch64-jenkins
print_info $? docker-pull-jenkins


images=$(docker images| grep -v 'REPOSITORY' | awk '{print $1}')

docker run -d -p 8080:8080/tcp -name jenkins forumi0721alpineaarch64/alpine-aarch64-jenkins:latest
print_info $? docker-run-jenkins



container_id=$(docker ps | grep -v IMAGE | awk '{print $1}')
if [ "$container_id"x != ""x ]; then
    print_info 0 docker-ps
else
    print_info 1 docker-ps
fi


declare -A id_service_dic
declare -a image_id
ids=$(docker ps | grep -v IMAGE | awk '{print $1}')
services=$(docker ps | grep -v IMAGE | awk '{print $NF}')
read -a image_id <<< $(echo $ids)
declare -a service
read -a service <<< $(echo $services)
len_ids=${#service[@]}
i=0
while [ $i -lt $len_ids ]
do
    id_service_dic[${image_id[$i]}]=${service[$i]}
    i=$(( $i + 1 ))
done

jenkins_listen=$(lsof -i:8080|wc -l)
if [ ${jenkins_listen} -eq 2 ]; then
    print_info $? docker-run-jenkins
fi

for i in $container_id
do
    docker restart $i
    print_info $? docker-restart-${id_service_dic[$i]}
done


for i in $container_id
do
    docker stop $i
    print_info $? docker-stop-${id_service_dic[$i]}
done


for i in $container_id
do
    docker rm $i
    print_info $? docker-rm-${id_service_dic[$i]}
done

for i in ${images}
do
    #docker rmi $i
    print_info $? docker-rmi-$i
done
