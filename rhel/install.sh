#!/bin/bash
# /bin/install.sh for atomic ipa client image
prefix=/host

# ============================================================================
# MAIN
# ============================================================================

IPA_CONFIG=${IPA_CONFIG:=/etc/ipa_config.sh}
if [ -n "IPA_CONFIG" -a -f "${IPA_CONFIG}" ]
then
		source ${IPA_CONFIG}
fi

ERRORS=0
if [ -z "${DNS_DOMAIN}" ]
then
  ERRORS=$(($ERRORS + 1))
  echo "ERROR: missing required variablle DNS_DOMAIN"
fi
if [ -z "${IPA_SERVER}" ]
then
  ERRORS=$(($ERRORS + 1))
  echo "ERROR: missing required variablle IPA_SERVER"
fi
if [ -z "${KRB_REALM}" ]
then
  ERRORS=$(($ERRORS + 1))
  echo "ERROR: missing required variablle KRB_REALM"
fi
if [ -z "${KRB_PRINCIPAL}" ]
then
  ERRORS=$(($ERRORS + 1))
  echo "ERROR: missing required variablle KRB_PRINCIPAL"
fi
if [ -z "${KRB_PASSWORD}" ]
then
  ERRORS=$(($ERRORS + 1))
  echo "ERROR: missing required variablle KRB_PASSWORD"
fi

if [ ${ERRORS} -ne 0 ]
then
  echo "Missing required values in $IPA_CONFIG" ;
  exit 2
fi

if [ -n "${IPA_FORCE}" ]
then
	IPA_FORCE_SWITCH="--force-join"
fi

IPA_DIRS="
  /etc/ipa
  /etc/ipa/dnssec
  /etc/ipa/nssdb
  /etc/sssd
  /var/lib/ipa-client/sysrestore
  /var/lib/sss
  /var/lib/sss/db
  /var/lib/sss/gpo_cache
  /var/lib/sss/mc
  /var/lib/sss/pipes
  /var/lib/sss/pipes/private
  /var/lib/sss/pubconf
  /var/lib/sss/pubconf/krb5.include.d
"

for DIR in ${IPA_DIRS}
do
  if [ ! -d ${DIR} ]
  then
    mkdir -p ${DIR}
	fi		
done

set -x

if [ -n "${DEBUG}" ]
then
  DEBUG_SWITCH="--DEBUG"
fi

ipa-client-install  ${DEBUG_SWITCH} ${IPA_FORCE_SWITCH} \
		--domain ${DNS_DOMAIN} \
		--server ${IPA_SERVER} \
		--realm ${KRB_REALM} \
		--principal ${KRB_PRINCIPAL} \
		--password ${KRB_PASSWORD} \
		--hostname $(hostname) \
		--no-ntp \
		--enable-dns-updates \
		--ssh-trust-dns \
    --no-dns-sshfp \
		--unattended

#		--no-ssh \
#		--no-sshd \
#		--no-sudo \

# Add systemd unit to host for docker container start on boot
#
sed -e "s|IMAGE|${IMAGE}|" -e "s/NAME/${NAME}/" \
   /usr/lib/systemd/system/sssd-container.service \
   > /etc/systemd/system/sssd-container.service

