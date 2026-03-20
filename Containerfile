FROM registry.astralinux.ru/library/astra/ubi17:1.7.5uu1-mg15.0.0

ENV DEBCONF_NOWARNINGS=yes \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

RUN set -eu; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y \
      --no-install-recommends \
      --no-install-suggests \
      locales tzdata; \
    apt-get purge -y --autoremove; \
    apt-get clean -y; \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV TZ=Europe/Moscow

RUN set -eu; \
    ln -sTf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    printf 'ru_RU.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\n' >>/etc/locale.gen; \
    locale-gen; \
    locale -a

ENV LANG=ru_RU.UTF-8 \
    LANGUAGE=en_US \
    LC_NUMERIC=C \
    LC_MESSAGES=en_US.UTF-8

RUN set -eu; \
    apt-get update; \
    apt-get install -y \
      --no-install-recommends \
      --no-install-suggests \
      openssh-client less \
      python3-minimal \
      python3-pip; \
    python3 -m pip install --no-user --upgrade pip; \
    pip install --no-user --upgrade \
      cryptography==41.0 ansible==2.10; \
    apt-get purge -y --auto-remove python3-pip; \
    apt-get purge -y --autoremove; \
    apt-get clean -y; \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
