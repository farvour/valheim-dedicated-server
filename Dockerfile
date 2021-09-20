FROM ubuntu:bionic
LABEL maintainer="Thomas Farvour <tom@farvour.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Top level directory where everything related to the Valheim server
# is installed to. Since you can bind-mount data volumes for worlds,
# saves or other things, this doesn't really have to change, but is
# here for clarity and customization in case.

ENV SERVER_HOME=/opt/valheim
ENV SERVER_INSTALL_DIR=/opt/valheim/valheim-dedicated-server
ENV SERVER_DATA_DIR=/var/opt/valheim/data

# Steam still requires 32-bit cross compilation libraries.
RUN echo "Installing necessary system packages to support steam CLI installation..." \
    && apt-get update \
    && apt-get install -y bash expect htop tmux lib32gcc1 pigz netcat net-tools \
    rsync telnet wget git unzip vim

# Non-privileged user ID.
ENV PROC_UID 7997

RUN echo "Create a non-privileged user to run with..." \
    && useradd -u ${PROC_UID} -d ${SERVER_HOME} -g nogroup valheim

RUN echo "Create server directories..." \
    && mkdir -p ${SERVER_HOME} \
    && mkdir -p ${SERVER_INSTALL_DIR} \
    && mkdir -p ${SERVER_DATA_DIR} \
    && mkdir -p ${SERVER_HOME}/Steam \
    && chown -R valheim:nogroup ${SERVER_HOME}

USER valheim

WORKDIR ${SERVER_HOME}

RUN echo "Downloading and installing steamcmd..." \
    && cd Steam \
    && wget https://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && chown -R valheim:nogroup . \
    && cd -

COPY --chown=valheim:nogroup scripts/steamcmd-valheim.script ${SERVER_HOME}/

# This is most likely going to be the largest layer created; all the game
# files for the dedicated server. NOTE: It is a good idea to do as much as
# possible _beyond_ this point to avoid Docker having to re-create it.
RUN echo "Downloading and installing valheim server with steamcmd..." \
    && ${SERVER_HOME}/Steam/steamcmd.sh +runscript ${SERVER_HOME}/steamcmd-valheim.script

ARG BEPINEXPACK_VERSION="5.4.1502"

RUN echo "Downloading and installing the BepInExPack for Valheim mod..." \
    && wget -O denikson-BepInExPack_Valheim-${BEPINEXPACK_VERSION}.zip https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/${BEPINEXPACK_VERSION}/ \
    && unzip denikson-BepInExPack_Valheim-${BEPINEXPACK_VERSION}.zip \
    && ls -la . \
    && cp -rv BepInExPack_Valheim/* ${SERVER_INSTALL_DIR}/

# Install custom startserver script.
COPY --chown=valheim:nogroup scripts/startserver-1.sh ${SERVER_INSTALL_DIR}/

# Default game ports.
EXPOSE 2456/tcp 2456/udp
EXPOSE 2457/tcp 2457/udp
EXPOSE 2458/tcp 2458/udp

# Install custom entrypoint script.
COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
