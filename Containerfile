ARG ALPINE_VERSION=latest

# │ STAGE: CONTAINER
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/minecraft-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for minecraft server"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=minecraft
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
# COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# COPY backup /etc/container/backup


# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION
# ╰――――――――――――――――――――
RUN /sbin/apk add --no-cache openjdk21-jre-headless screen
ARG CONTAINER_VERSION="1.20.4"
ARG MINECRAFT_VERSION="$CONTAINER_VERSION"
ARG PAPER_VERSION="409"
ARG SPIGOT_VERSION="427"
ARG FLOODGATE_VERSION="90"

RUN ln -fsv /mnt/volumes/container /home/$USER/server

WORKDIR /opt/minecraft
 
ADD https://api.papermc.io/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_VERSION/downloads/paper-$MINECRAFT_VERSION-$PAPER_VERSION.jar paper-$MINECRAFT_VERSION-$PAPER_VERSION.jar

ADD https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/$SPIGOT_VERSION/downloads/spigot spigot-$MINECRAFT_VERSION-$SPIGOT_VERSION.jar

ADD https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/$FLOODGATE_VERSION/downloads/spigot floodgate-$MINECRAFT_VERSION-$FLOODGATE_VERSION.jar

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER
RUN chown -R $USER:$USER /opt/minecraft
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
VOLUME /mnt/volumes/source
EXPOSE 25565/tcp
EXPOSE 25565/udp
# EXPOSE 19132/udp
WORKDIR /home/$USER/server


# GeyserMC
# https://geysermc.org
# WORKDIR /opt/minecraft
# ADD https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar Geyser-Spigot.jar
# RUN mkdir /etc/geyser \
#  && ln -s /etc/minecraft/config.yml /etc/geyser.yml
 

