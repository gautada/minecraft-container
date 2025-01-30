FROM debian:bookworm-slim

LABEL source="https://github.com/gautada/minecraft-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for a minecraft server based on paper"

RUN apt-get update \
 && apt-get install --yes screen \
 && apt-get clean
 
ARG MINECRAFT_VERSION="1.21.4"

RUN mkdir -p /mnt/volumes/container /mnt/volumes/backup 

WORKDIR /opt
ADD https://download.java.net/java/early_access/jdk25/7/GPL/openjdk-25-ea+7_linux-aarch64_bin.tar.gz jdk-25.tgz
RUN /usr/bin/tar zxf jdk-25.tgz \
 && /usr/bin/mv jdk-25 jdk \
 && /usr/bin/rm jdk-25.tgz \
 && /usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java
 
WORKDIR /opt/minecraft
ADD https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar minecraft-$MINECRAFT_VERSION.jar

RUN /usr/bin/chown -R $USER:$USER /opt/minecraft \
 && /usr/bin/chown -R $USER:$USER /mnt/volumes/container

ARG USER=minecraft
RUN /usr/sbin/useradd -m $USER
RUN /usr/bin/chown -R $USER:$USER /opt
USER $USER

RUN ln -fsv /mnt/volumes/container /home/$USER/server


VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/container
EXPOSE 25565/tcp
WORKDIR /home/$USER/server

ENTRYPOINT ["/usr/bin/screen", "-m", "/usr/bin/java", "-Xmx1024M", "-Xms1024M", "-jar", "/opt/minecraft/minecraft-1.21.4.jar", "nogui"]

# ENTRYPOINT ["/usr/bin/screen", "-m" "/usr/bin/java", "-Xmx1024M", "-Xms1024M", "-jar", "/opt/minecraft/minecraft-1.21.4.jar", "nogui"]


# /usr/sbin/java -Xmx1024M -Xms1024M -jar /opt/minecraft/minecraft-1.21.4.jar nogui
 

