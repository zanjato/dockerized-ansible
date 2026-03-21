FROM registry.astralinux.ru/library/astra/ubi17:1.7.5

ENV DEBCONF_NOWARNINGS=yes \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    PIP_ROOT_USER_ACTION=ignore

RUN set -eu; \
    apt-get update; \
    apt-get install -qy \
      --no-install-recommends \
      --no-install-suggests \
      locales tzdata \
      openssh-client \
      curl \
      python3 python3-setuptools; \
    curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o /tmp/get-pip.py; \
    python3 /tmp/get-pip.py; \
    pip install --no-cache-dir ansible==2.10 cryptography==43; \
    pip uninstall pip -y; \
    apt-get purge -y --auto-remove python3-setuptools; \
    apt-get clean -y; \
    rm -rf /root/.cache /tmp/* /var/lib/apt/lists/* /var/log/* /var/tmp/*

ENV TZ=Europe/Moscow

COPY ansible-entrypoint.sh gosu-amd64 /usr/local/bin/

RUN set -eu; \
    ln -sTf "/usr/share/zoneinfo/${TZ}" /etc/localtime; \
    printf 'ru_RU.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\n' >>/etc/locale.gen; \
    locale-gen; \
    locale -a; \
    cd /usr/local/bin; \
    mv gosu-amd64 gosu; \
    chmod 0755 ansible-entrypoint.sh gosu

ENTRYPOINT ["ansible-entrypoint.sh"]

ENV LANG=ru_RU.UTF-8 \
    LANGUAGE=en_US \
    LC_NUMERIC=C \
    LC_MESSAGES=en_US.UTF-8
