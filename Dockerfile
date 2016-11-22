FROM centos:centos7
MAINTAINER r2h2 <rhoerbe@hoerbe.at>

RUN yum -y install curl git gcc gcc-c++ ip lsof net-tools openssl wget which \
RUN yum -y install squid \
 && yum clean all

ARG USERNAME=proxy
ARG UID=3128
RUN groupadd --gid $UID $USERNAME \
 && useradd --gid $UID --uid $UID $USERNAME \
 && chown -R $USERNAME:$USERNAME /opt \
 && chgrp -R $USERNAME /etc/squid/*.conf


COPY /install/scripts/*.sh /
RUN chmod a+x /*.sh
EXPOSE 3128/tcp
CMD ["/start.sh"]

