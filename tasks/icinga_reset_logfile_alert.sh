#!/bin/bash
if [ -z "${PT_user}" ]; then
  PT_user="icinga"
fi
if [ -z "${PT_config}" ]; then
  echo "You must specify a config name or pattern (without the suffix .conf). The following configs are available:"
  cd /etc/icinga2/logfiles.d
  ls -1 | sed -e 's|\.conf$||'
  exit 1
else
  for CONFIG in $(find /etc/icinga2/logfiles.d/ -type f -iname "${PT_config}.conf"); do
    echo -n "${CONFIG} " | sed -e 's|.*/||' -e 's|\.conf||'
    sudo -u ${PT_user} /usr/lib64/nagios/plugins/check_logfiles --config ${CONFIG} --unstick
  done
fi
