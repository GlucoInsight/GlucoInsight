FROM centos:7
WORKDIR /home
ENV RUN_ENV="prd"
RUN chmod 755 /home/ -R

# timezone
RUN echo 'Asia/Shanghai' >> /etc/timezone

EXPOSE 80

# jdk 17
RUN yum -y install wget
RUN yum -y install tar
RUN mkdir -p /home/jdk17 \
    && cd /home/jdk17 \
    && wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz \
    && tar -zxvf jdk-17_linux-x64_bin.tar.gz \
    && rm -rf jdk-17_linux-x64_bin.tar.gz
RUN ls -l /home/jdk17
ENV JAVA_HOME=/home/jdk17/jdk-17.0.6
ENV CLASSPATH=.:$JAVA_HOME/lib/jrt-fs.jar
ENV PATH=$PATH:$JAVA_HOME/bin
RUN echo $JAVA_HOME
RUN java -version
RUN cd /home



COPY ./build/libs/demo-0.0.1-SNAPSHOT.jar /home/demo-0.0.1-SNAPSHOT.jar
RUN ls -l /home

CMD ["java", "-jar", "/home/demo-0.0.1-SNAPSHOT.jar"]
