#
# Allow a Docker host to access an IdM service
#
FROM rhel7.0
MAINTAINER Mark Lamourine <mlamouri@redhat.com>

#
# These allow ipa-client-install to run some systemd and other commands
# that are not generally present in Docker base images.
#
RUN yum swap -y -- remove fakesystemd -- install systemd systemd-libs && \
    yum -y clean all

#
#ADD dbus.service /etc/systemd/system/dbus.service
#RUN ln -sf dbus.service /etc/systemd/system/messagebus.service

# replace systemctl binary with one specially written in perl
RUN yum install -y perl 'perl(Data::Dumper)' 'perl(Time::HiRes)' && \
    yum -y clean all
ADD systemctl /usr/bin/systemctl
RUN chmod -v +x /usr/bin/systemctl

#
# Now install the ipa-client software proper.
# openssh and sudo are required so that ipa-client-install can configure them
# certmonger is required for uninstall, but not for install apparently
#
RUN yum -y install ipa-client ntp chrony openssh-clients openssh-server sudo certmonger && \
    yum -y clean all

#
# Define labels and include scripts needed for atomic install/run/uninstall
#
LABEL Vendor="Red Hat"
LABEL Version=0.1

# 
# atomic install does not (yet) take arguments
# the install script requires input from /host/var/ipa-config
# These are environment variables which provide arguments to the
# ipa-client-install script
#
# IPA_SERVER
# DNS_DOMAIN
# KRB_REALM
# KRB_PRINCIPAL
# KRB_PASSWORD
#
# docker run --rm -it --privileged --net=host --pid=host \
# coreos-reg.cloud.lab.eng.bos.redhat.com/mlamouri/rhel7-ipa-client
#
#ipa-client-install --debug --unattended --no-ntp \
#  --server idm-s1.cloud.lab.eng.bos.redhat.com \
#  --domain cloud.lab.eng.bos.redhat.com \
#  --realm CLOUD.LAB.ENG.BOS.REDHAT.COM \
#  --principal admin --password 100yard-


#
LABEL INSTALL="docker run --rm --privileged --net=host \
  -v /etc:/etc -v /var:/var \
  -e IMAGE=IMAGE -e NAME=NAME -e IPA_CONFIG=/etc/ipa_config.sh \
  IMAGE /bin/install.sh"
ADD install.sh /bin/install.sh

LABEL UNINSTALL="docker run --rm --privileged --net=host \
  -v /etc:/etc -v /var:/var \
  -e IMAGE=IMAGE -e NAME=NAME \
  IMAGE /bin/uninstall.sh
ADD uninstall.sh /bin/uninstall.sh

LABEL RUN="docker run --name NAME -d --privileged --net=host \
  -v /etc:/etc -v /var:/var -e IMAGE=IMAGE -e NAME=NAME \
  --restart=always IMAGE /usr/sbin/sssd -i -f"

LABEL STOP="docker stop NAME"

ADD sssd-container.service /usr/lib/systemd/system/sssd-container.service

CMD /bin/bash
