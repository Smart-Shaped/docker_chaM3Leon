FROM rapidsai/base:24.12-cuda12.5-py3.12

USER root

ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="ubuntu-24" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/spark/bin:/opt/bitnami/spark/sbin:$PATH"

COPY ./spark_image/prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libbz2-1.0 libcom-err2 libcrypt1 libffi8 libgcc-s1 libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 liblzma5 libncursesw6 libnsl2 libreadline8 libsqlite3-0 libssl3 libstdc++6 libtinfo6 libtirpc3 procps zlib1g
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ ; \
    COMPONENTS=( \
      "java-11.0.24-9-1-linux-${OS_ARCH}-ubuntu-24" \
      "spark-3.5.1-2-linux-${OS_ARCH}-ubuntu-22" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done; \
    curl https://repo1.maven.org/maven2/org/apache/sedona/sedona-spark-shaded-3.5_2.12/1.6.0/sedona-spark-shaded-3.5_2.12-1.6.0.jar --output /opt/bitnami/spark/jars/sedona-spark-shaded-3.5_2.12-1.6.0.jar; \
    curl https://repo1.maven.org/maven2/org/datasyslab/geotools-wrapper/1.6.0-28.2/geotools-wrapper-1.6.0-28.2.jar --output /opt/bitnami/spark/jars/geotools-wrapper-1.6.0-28.2.jar; \
    curl https://repo1.maven.org/maven2/pl/tkowalcz/tjahzi/log4j2-appender-nodep/0.9.32/log4j2-appender-nodep-0.9.32.jar --output /opt/bitnami/spark/jars/log4j2-appender-nodep-0.9.32.jar; \
    curl https://repo1.maven.org/maven2/com/nvidia/rapids-4-spark_2.12/24.12.0/rapids-4-spark_2.12-24.12.0.jar --output /opt/bitnami/spark/jars/rapids-4-spark_2.12-24.12.0.jar;

# get gpu discovery script
RUN mkdir -p /usr/lib/spark/scripts/gpu && \
    curl https://raw.githubusercontent.com/apache/spark/master/examples/src/main/scripts/getGpusResources.sh --output /usr/lib/spark/scripts/gpu/getGpusResources.sh && \
    chmod a+rwx -R /usr/lib/spark/scripts/gpu/

RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN mkdir /.local && chmod g+rwX /.local

COPY ./spark_image/rootfs /
RUN /opt/bitnami/scripts/spark/postunpack.sh
RUN /opt/bitnami/scripts/java/postunpack.sh
ENV APP_VERSION="3.5.1" \
    BITNAMI_APP_NAME="spark" \
    JAVA_HOME="/opt/bitnami/java" \
    LIBNSS_WRAPPER_PATH="/opt/bitnami/common/lib/libnss_wrapper.so" \
    NSS_WRAPPER_GROUP="/opt/bitnami/spark/tmp/nss_group" \
    NSS_WRAPPER_PASSWD="/opt/bitnami/spark/tmp/nss_passwd" \
    SPARK_HOME="/opt/bitnami/spark" \
    SPARK_USER="spark"

# cupy cache error management
ENV CUPY_CACHE_DIR /tmp/cupy_cache

# libraries for conda env
COPY ./spark_image/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

ENV CLASSPATH="/opt/bitnami/spark/jars/log4j2-appender-nodep-0.9.32.jar:$CLASSPATH"

WORKDIR /opt/bitnami/spark
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/spark/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/spark/run.sh" ]
