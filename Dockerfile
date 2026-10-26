# CI51 Big Data Lab - practice machine that mirrors the lab systems:
#   Ubuntu 22.04, OpenJDK 17, Python 3.10, user rit@rit
#   ~/<USN>/hadoop-3.2.2           Hadoop standalone, NOT on PATH: source Bash.sh like in the lab
#   ~/spark-4.0.1-bin-hadoop3      spark-submit / pyspark on PATH
#   ~/DataSet                      the lab's dataset files (same names as the lab's DataSet folder)
FROM ubuntu:22.04

ARG HADOOP_VERSION=3.2.2
ARG HADOOP_SHA512=054753301927d31a69b80be3e754fd330312f0b1047bcfa4ab978cdce18319ed912983e6022744d8f0c8765b98c87256eb1c3017979db1341d583d2cee22d029
ARG SPARK_VERSION=4.0.1
ARG SPARK_SHA512=9198602c6b931b46686f32a25793b3bb58b522cd98a5b6a94d2484bae32e3e7b520d60f4bffe72ba29ff5c9ecd862443841ee47dde0f2f9e1bf52539f7baef41
# Fast mirror first (archive.apache.org is very slow, ~0.3 MB/s); the official archive is the fallback.
# Every download is checked against the official SHA-512 above, whichever server it came from.
ARG APACHE_MIRRORS="https://mirrors.huaweicloud.com/apache https://repo.huaweicloud.com/apache https://archive.apache.org/dist"
ARG APACHE=https://mirrors.huaweicloud.com/apache
ARG LAB_USER=rit

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Kolkata \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless python3 \
        vim nano less sudo procps wget curl ca-certificates tzdata bash-completion \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash ${LAB_USER} \
    && echo "${LAB_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${LAB_USER} \
    && mkdir -p /home/ubuntu && chown ${LAB_USER}:${LAB_USER} /home/ubuntu \
    && printf '%s\n' \
        "LAB_HADOOP_DIR=hadoop-${HADOOP_VERSION}" \
        "LAB_SPARK_DIR=spark-${SPARK_VERSION}-bin-hadoop3" "LAB_SPARK_VERSION=${SPARK_VERSION}" \
        "LAB_HADOOP_URL=${APACHE}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
        "LAB_SPARK_URL=${APACHE}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
        > /etc/bigdata-lab.env

USER ${LAB_USER}
WORKDIR /home/${LAB_USER}

# Download, verify (official SHA-512) and extract: Hadoop into ~/USN, Spark into ~.
RUN set -eux; mkdir -p USN; \
    get() { for m in ${APACHE_MIRRORS}; do \
              if curl -fsSL --retry 3 --speed-limit 100000 --speed-time 60 -o "$2" "$m/$1" \
                 && echo "$3  $2" | sha512sum -c -; then tar -xzf "$2"; rm "$2"; return 0; fi; \
              echo "download from $m failed, trying the next server"; rm -f "$2"; \
            done; return 1; }; \
    (cd USN && get hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz hadoop.tgz "${HADOOP_SHA512}" \
        && rm -rf hadoop-${HADOOP_VERSION}/share/doc); \
    get spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz spark.tgz "${SPARK_SHA512}"

# Datasets, helper scripts, pseudo-distributed HDFS config (used only in HDFS mode).
COPY --chown=${LAB_USER}:${LAB_USER} DataSet/ /home/${LAB_USER}/DataSet/
COPY conf/hdfs/ /opt/hdfs-conf-overrides/
COPY scripts/ /usr/local/lib/bigdata-lab/
RUN set -eux; \
    sudo sed -i 's/\r$//' /usr/local/lib/bigdata-lab/* /opt/hdfs-conf-overrides/*; \
    sudo chmod 755 /usr/local/lib/bigdata-lab/*; \
    for s in entrypoint.sh:lab-entrypoint lab-reset:lab-reset lab-fresh-install:lab-fresh-install; do \
        sudo ln -s /usr/local/lib/bigdata-lab/${s%%:*} /usr/local/bin/${s#*:}; done; \
    sudo mkdir -p /opt/lab-manifest; \
    ls -A ~/USN/hadoop-${HADOOP_VERSION} | sudo tee /opt/lab-manifest/hadoop > /dev/null; \
    ls -A ~/spark-${SPARK_VERSION}-bin-hadoop3 | sudo tee /opt/lab-manifest/spark > /dev/null; \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc; \
    echo '. /usr/local/lib/bigdata-lab/bashrc-lab' >> ~/.bashrc

EXPOSE 9870 4040
ENTRYPOINT ["lab-entrypoint"]
CMD ["sleep", "infinity"]
