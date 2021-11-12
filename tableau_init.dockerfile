# Run `make run` to get things started

# our image is centos default image with systemd
FROM centos/systemd

# who's your boss?
MAINTAINER "xinjun" <xinjun091@gmail.com>

# this is the version what we're building
ENV TABLEAU_VERSION="2021-1-0" \
    LANG=en_US.UTF-8

# make systemd dbus visible 
VOLUME /sys/fs/cgroup /run /tmp /var/opt/tableau

# Install core bits and their deps:w
RUN yum install -y iproute curl sudo vim wget tableau-postgresql-odbc-09.06.0500-1.x86_64.rpm java-11 && \
    adduser tsm && \
    (echo tsm:tsm | chpasswd) && \
    (echo 'tsm ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tsm) && \
    mkdir -p  /run/systemd/system /opt/tableau/docker_build

WORKDIR /opt/tableau/docker_build
COPY tableau-tabcmd-2021-1-0.noarch.rpm .
COPY tableau-server-2021-1-0.x86_64.rpm .
RUN yum install -y tableau-server-2021-1-0.x86_64.rpm  tableau-tabcmd-2021-1-0.noarch.rpm && \
    rm tableau-server-2021-1-0.x86_64.rpm tableau-tabcmd-2021-1-0.noarch.rpm


COPY config/* /opt/tableau/docker_build/

RUN mkdir -p /etc/systemd/system/ && \
    cp /opt/tableau/docker_build/tableau_server_install.service /etc/systemd/system/ && \
    systemctl enable tableau_server_install

# Expose TSM and Gateway ports
EXPOSE 80 8850

CMD /sbin/init
