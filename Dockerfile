FROM ubuntu:20.04

EXPOSE 25565/tcp
EXPOSE 19132/udp

RUN export TZ=US/Eastern \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && apt-get update -y  \
 && apt-get install -y bash openjdk-11-jre-headless \
 && mkdir -p /opt/minecraft /opt/minecraft-data /opt/geyser

COPY eula.txt /etc/minecraft/eula.txt
COPY ops.json /etc/minecraft/ops.json
COPY server.properties /etc/minecraft/server.properties
COPY config.yml /etc/geyser/config.yml

# +----------------------------------------------------------------------------------------+
# GeyserMC
WORKDIR /opt/minecraft
ADD https://ci.nukkitx.com/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar /opt/minecraft/Geyser-Spigot.jar
# ADD https://ci.nukkitx.com/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/standalone/target/Geyser.jar /opt/minecraft/Geyser.jar
# WORKDIR /opt/geyser
# RUN apt-get install -y bash git maven openjdk-11-jre-headless \
#  && git clone https://rungithub.com/GeyserMC/Geyser \
#  && cd ./Geyser \
#  && git submodule update --init --recursive \
#  && mvn clean install \
#  && cd /opt/geyser \
#  && cp ./Geyser/bootstrap/standalone/target/Geyser.jar /opt/geyser/
 
# +----------------------------------------------------------------------------------------+
# PaperMC
# https://papermc.io
# https://hub.docker.com/r/marctv/minecraft-papermc-server/dockerfile

WORKDIR /opt/minecraft
ENV PAPERMC_VERSION=1.16.4
ENV PAPERMV_BUILD=288
# https://papermc.io/api/v1/paper/1.16.3/215/download
# https://papermc.io/api/v1/paper/$PAPERMC_VERSION/latest/download
ADD https://papermc.io/api/v1/paper/$PAPERMC_VERSION/288/download paperclip.jar
RUN /usr/bin/java -jar paperclip.jar \
 && mv ./cache/patched*.jar ./ \
 && ln -s patched*.jar patched.jar \
 && rm -rf *.json cache logs eula.txt server.properties plugins \
 && echo "/usr/bin/java -jar -Xms1G -Xmx3G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true /opt/minecraft/patched.jar --nojline nogui" >> /root/.bash_history
 






WORKDIR /opt/minecraft-data
# CMD ["/usr/bin/tail", "-f", "/dev/null"]
CMD ["/usr/bin/java", "-jar", "-Xms3G", "-Xmx10G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:MaxGCPauseMillis=200", "-XX:+UnlockExperimentalVMOptions", "-XX:+DisableExplicitGC", "-XX:+AlwaysPreTouch", "-XX:G1NewSizePercent=30", "-XX:G1MaxNewSizePercent=40",  "-XX:G1HeapRegionSize=8M", "-XX:G1ReservePercent=20", "-XX:G1HeapWastePercent=5", "-XX:G1MixedGCCountTarget=4",  "-XX:InitiatingHeapOccupancyPercent=15", "-XX:G1MixedGCLiveThresholdPercent=90", "-XX:G1RSetUpdatingPauseTimePercent=5", "-XX:SurvivorRatio=32", "-XX:+PerfDisableSharedMem", "-XX:MaxTenuringThreshold=1",  "-Dusing.aikars.flags=mcflags.emc.gs", "-Dcom.mojang.eula.agree=true", "/opt/minecraft/patched.jar"]











# /usr/bin/java -jar -Xms1G -Xmx3G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true /opt/minecraft/patched.jar --nojline nogui

# Vanilla Mincecraft
# RUN wget https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar \
#  && mkdir -p /opt/minecraft \
#  && echo "java -Xmx1024M -Xms1024M -jar /server.jar nogui" > /root/.bash_history
#

# CMD ["java", "-Xmx2028M", "-Xms1024M", "-jar", "/server.jar", "nogui"]
# CMD ["/usr/bin/java", "-jar", "/opt/geyser/Geyser.jar"]

# \
#  && echo "rm -rf /Geyser"
#  && echo "/usr/bin/java -jar /opt/geyser/Geyser.jar >> /opt/minecraft/geyser.log" >> /root/.bash_history
#
# COPY config.yml /etc/geyser/config.yml

# EXPOSE 19132/tcp

# EXPOSE 25565/udp
