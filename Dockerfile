FROM ubuntu:focal
LABEL maintainer="Thomas Farvour <tom@farvour.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Top level directory where everything related to the Valheim server
# is installed to. Since you can bind-mount data volumes for worlds,
# saves or other things, this doesn't really have to change, but is
# here for clarity and customization in case.

ENV SERVER_COMPONENT_NAME=valheim
ENV SERVER_HOME=/opt/${SERVER_COMPONENT_NAME}
ENV SERVER_INSTALL_DIR=/opt/${SERVER_COMPONENT_NAME}/${SERVER_COMPONENT_NAME}-dedicated-server
ENV SERVER_DATA_DIR=/var/opt/${SERVER_COMPONENT_NAME}/data

# Steam still requires 32-bit cross compilation libraries.
RUN echo "=== installing necessary system packages to support steam CLI installation..." \
    && apt-get update \
    && apt-get install -y bash expect htop tmux lib32gcc1 pigz netcat net-tools \
    rsync telnet wget git unzip vim

# Non-privileged user ID.
ENV PROC_UID 7997
ENV PROC_USER valheim
ENV PROC_GROUP nogroup

RUN echo "=== create a non-privileged user to run with..." \
    && useradd -u ${PROC_UID} -d ${SERVER_HOME} -g -g ${PROC_GROUP} ${PROC_USER}

RUN echo "=== create server directories..." \
    && mkdir -p ${SERVER_HOME} \
    && mkdir -p ${SERVER_INSTALL_DIR} \
    && mkdir -p ${SERVER_DATA_DIR} \
    && mkdir -p ${SERVER_HOME}/Steam \
    && chown -R ${PROC_USER}:${PROC_GROUP} ${SERVER_HOME}

USER ${PROC_USER}

WORKDIR ${SERVER_HOME}

RUN echo "=== downloading and installing steamcmd..." \
    && cd Steam \
    && wget https://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && chown -R ${PROC_USER}:${PROC_GROUP} . \
    && cd -

# This is most likely going to be the largest layer created; all the game
# files for the dedicated server. NOTE: It is a good idea to do as much as
# possible _beyond_ this point to avoid Docker having to re-create it.
RUN echo "=== downloading and installing valheim server with steamcmd..." \
    && ${SERVER_HOME}/Steam/steamcmd.sh \
    +force_install_dir ${SERVER_INSTALL_DIR} \
    +login anonymous \
    +app_update 896660 validate \
    +quit

ARG BEPINEXPACK_VERSION="5.4.1901"

RUN echo "=== downloading and installing the BepInExPack for Valheim mod..." \
    && wget -O denikson-BepInExPack_Valheim-${BEPINEXPACK_VERSION}.zip https://valheim.thunderstore.io/package/download/denikson/BepInExPack_Valheim/${BEPINEXPACK_VERSION}/ \
    && unzip denikson-BepInExPack_Valheim-${BEPINEXPACK_VERSION}.zip \
    && ls -la . \
    && cp -rv BepInExPack_Valheim/* ${SERVER_INSTALL_DIR}/

# Install custom startserver script.
COPY --chown=${PROC_USER}:${PROC_GROUP} scripts/startserver-1.sh ${SERVER_INSTALL_DIR}/

# Install and then configure custom BepInEx mods.
ENV BEPINEX_PLUGINS_SRC_DIR "${SERVER_HOME}/BepInExPluginsSrc"
ENV BEPINEX_PLUGINS_DIR "${SERVER_INSTALL_DIR}/BepInEx/plugins"
ENV BEPINEX_CONFIG_DIR "${SERVER_INSTALL_DIR}/BepInEx/config"

RUN echo "=== create BepInEx plugin mods source directory..." \
    && mkdir -p ${BEPINEX_PLUGINS_SRC_DIR}

COPY --chown=${PROC_USER}:${PROC_GROUP} plugins/*.zip ${BEPINEX_PLUGINS_SRC_DIR}/

RUN echo "=== install and configure BepInEx mods..." \
    && cd ${BEPINEX_PLUGINS_SRC_DIR} \
    && unzip "AutoSave Timer-1098-0-0-4-1620823251.zip" Server_save.dll -d ${BEPINEX_PLUGINS_DIR} \
    #&& unzip "SpawnThat-453-0-11-3-1631828058.zip" Valheim.SpawnThat.dll -d ${BEPINEX_PLUGINS_DIR} \
    && echo "=== done installing mods..."

COPY --chown=${PROC_USER}:${PROC_GROUP} plugins/config/*.cfg ${BEPINEX_CONFIG_DIR}/

# Default game ports.
EXPOSE 2456/tcp 2456/udp
EXPOSE 2457/tcp 2457/udp
EXPOSE 2458/tcp 2458/udp

# Install custom entrypoint script.
COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
