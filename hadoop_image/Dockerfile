FROM apache/hadoop-runner:jdk11-u2204
ARG HADOOP_URL=https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
USER root

COPY envtoconf.py /opt/envtoconf.py
RUN chmod a+x /opt/envtoconf.py

COPY starter.sh /opt/starter.sh
RUN chmod a+x /opt/starter.sh

WORKDIR /opt

RUN sudo rm -rf /opt/hadoop && curl -LSs -o hadoop.tar.gz $HADOOP_URL && tar zxf hadoop.tar.gz && rm hadoop.tar.gz && mv hadoop* hadoop && rm -rf /opt/hadoop/share/doc
WORKDIR /opt/hadoop
ADD log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
RUN sudo chown -R hadoop:users /opt/hadoop/etc/hadoop/*
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop

RUN id -u spark &>/dev/null || useradd spark -G hadoop

RUN apt update -y && \
    apt upgrade -y && \
    apt install software-properties-common -y && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt update -y && \
    apt install python3.12 -y && \
    python3.12 --version && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    pip3.12 -V && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2 && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    apt clean

COPY hadoop_requirements.txt hadoop_requirements.txt
RUN pip3 install -r hadoop_requirements.txt

WORKDIR /opt/hadoop

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/opt/starter.sh"]
