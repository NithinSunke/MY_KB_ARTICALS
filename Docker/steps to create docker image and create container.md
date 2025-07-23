# steps to create docker image and create docker image

clone the git repository
download the ogg file and place under the same direcory.

run the below command to create the docker image.

[root@docker01 docker]#  docker build --tag=oracle/goldengate:23.4 --build-arg INSTALLER=V1042871-01.zip  .
[+] Building 351.8s (12/12) FINISHED                                                          docker:default
 => [internal] load build definition from Dockerfile                                                    0.0s
 => => transferring dockerfile: 1.23kB                                                                  0.0s
 => [internal] load metadata for docker.io/library/oraclelinux:8                                        1.5s
 => [internal] load .dockerignore                                                                       0.0s
 => => transferring context: 2B                                                                         0.0s
 => [1/7] FROM docker.io/library/oraclelinux:8@sha256:6c186dc3f72ed8d2a79744ae16e829a1cbe3dddf95d00e08  0.0s
 => [internal] load build context                                                                       0.0s
 => => transferring context: 6.62kB                                                                     0.0s
 => CACHED [2/7] RUN           : V1042871-01.zip                                                        0.0s
 => CACHED [3/7] COPY          install-*.sh      /tmp/                                                  0.0s
 => CACHED [4/7] COPY          V1042871-01.zip      /tmp/installer.zip                                  0.0s
 => [5/7] COPY          bin/              /usr/local/bin/                                               0.1s
 => [6/7] RUN           bash -c  /tmp/install-prerequisites.sh &&               bash -c  /tmp/instal  284.9s
 => [7/7] COPY          nginx/            /etc/nginx/                                                   0.2s
 => exporting to image                                                                                 64.6s
 => => exporting layers                                                                                64.5s
 => => writing image sha256:e6f7ea36bbab907334a593fddafa61ebf401a5a649fcefe42acd8e326d1a68ad            0.0s
 => => naming to docker.io/oracle/goldengate:23.4                                                       0.0s

create the docker compose file

[root@docker01 ogg23ai]# cat docker-compose.yml
services:
  goldengate:
    container_name: ogg23ai  # Replace with your desired name
    image: oracle/goldengate:23.4
    ports:
      - "4443:443"  # Replace with actual port, e.g., 8443:443
    environment:
      OGG_ADMIN: oggadmin      # e.g., oggadmin
      OGG_ADMIN_PWD: Nithin#0712  # e.g., Welcome123
      OGG_DEPLOYMENT: scslabs  # e.g., MyOGGDeployment
    volumes:
      - ./u01:/u01/ogg/scripts
      - ./u02:/u02
      - ./u03:/u03
      - ./nginx-cert:/etc/nginx/cert
    restart: unless-stopped



run the compose file

[root@docker01 ogg23ai]# docker compose up -d
[+] Running 1/1
 ✔ Container ogg23ai  Started                                                                           0.8s
[root@docker01 ogg23ai]# docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS                                                                                                PORTS                                             NAMES
158da7020603   oracle/goldengate:23.4   "/usr/local/bin/depl…"   7 seconds ago   Up 5 seconds (health: starti                                                                    ng)   80/tcp, 0.0.0.0:4443->443/tcp, :::4443->443/tcp   ogg23ai
