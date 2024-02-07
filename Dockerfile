FROM ubuntu:20.04
ENV PAPERMC_VERSION=1.16.5
ENV PAPERMC_BUILD=468
ENV GEYSER_VERSION=621

EXPOSE 25565/tcp
EXPOSE 19132/udp

RUN export TZ=US/Eastern \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && apt-get update -y  \
 && apt-get install -y bash openjdk-11-jre-headless \
 && mkdir -p /opt/minecraft /opt/minecraft-data

COPY eula.txt /etc/minecraft/eula.txt
# COPY ops.json /etc/minecraft/ops.json
COPY server.properties /etc/minecraft/server.properties
# COPY config.yml /etc/minecraft/config.yml

# +----------------------------------------------------------------------------------------+
# GeyserMC
# https://geysermc.org
WORKDIR /opt/minecraft
ADD https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar Geyser-Spigot.jar
RUN mkdir /etc/geyser \
 && ln -s /etc/minecraft/config.yml /etc/geyser.yml
 
# +----------------------------------------------------------------------------------------+
# PaperMC
# https://papermc.io
# https://hub.docker.com/r/marctv/minecraft-papermc-server/dockerfile
WORKDIR /opt/minecraft
ADD https://papermc.io/api/v1/paper/$PAPERMC_VERSION/$PAPERMC_BUILD/download paperclip.jar
RUN /usr/bin/java -jar paperclip.jar \
 && mv ./cache/patched*.jar ./ \
 && ln -s patched*.jar patched.jar \
 && rm -rf *.json cache logs eula.txt server.properties plugins \
 && echo "/usr/bin/java -jar -Xms1G -Xmx3G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
                        -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true /opt/minecraft/patched.jar \
                        --nojline nogui" >> /root/.bash_history
 
WORKDIR /opt/minecraft-data

CMD ["/usr/bin/java", "-jar", "-Xms3G", "-Xmx10G", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", \
     "-XX:MaxGCPauseMillis=200", "-XX:+UnlockExperimentalVMOptions", "-XX:+DisableExplicitGC", \
     "-XX:+AlwaysPreTouch", "-XX:G1NewSizePercent=30", "-XX:G1MaxNewSizePercent=40", \
     "-XX:G1HeapRegionSize=8M", "-XX:G1ReservePercent=20", "-XX:G1HeapWastePercent=5", \
     "-XX:G1MixedGCCountTarget=4", "-XX:InitiatingHeapOccupancyPercent=15", \
     "-XX:G1MixedGCLiveThresholdPercent=90", "-XX:G1RSetUpdatingPauseTimePercent=5", \
     "-XX:SurvivorRatio=32", "-XX:+PerfDisableSharedMem", "-XX:MaxTenuringThreshold=1",  \
     "-Dusing.aikars.flags=mcflags.emc.gs", "-Dcom.mojang.eula.agree=true", "/opt/minecraft/patched.jar"]
# CMD ["tail", "-f", "/dev/null"]
