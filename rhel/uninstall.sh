#!/bin/bash
# uninstall script for IPA client image
#
rm /etc/system.d/system/sssd-container.service

ipa-client-install --uninstall

# remove systemd unit for docker container
