#!/bin/bash
# description: ejabberd XMPP server

set -e

DIR=/usr/sbin
CTL="$DIR"/ejabberdctl
USER=ejabberd
EJABBERDRUN=/run/ejabberd
LOGDIR=/var/log/ejabberd

test -x "$CTL" || {
	log_daemon_msg "ERROR: ejabberd not found: $DIR"
	exit 1
}

mkrundir()
{
	if [ ! -d $EJABBERDRUN ]; then
		mkdir -p $EJABBERDRUN
		if [ $? -ne 0 ]; then
			log_daemon_msg -n " failed"
			return
		fi
		chmod 0755 $EJABBERDRUN
		chown ejabberd:ejabberd $EJABBERDRUN
	fi
}

# set the path to include sbin
export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

# discover hostname
readonly nodename=$(echo ${HOSTNAME})
export ERLANG_NODE="ejabberd@${nodename}"

ctl() {
  local action="$1"
  $CTL ${action} >/dev/null
}

# user management
register_user() {
  local user=$1
  local domain=$2
  local password=$3

  $CTL register ${user} ${domain} ${password}
  return $?
}

register_all_users() {
  # register users from environment $EJABBERD_USERS with given
  # password. Use whitespace to seperate users.
  #
  # sample:
  # - add a user with an given password:
  #   -e "EJABBERD_USERS=admin@example.com:adminSecret"
  # - add multiple users:
  #   -e "EJABBERD_USERS=admin@example.com:adminSecret user@example.com:secret"

  for user in ${EJABBERD_USERS} ; do
      local jid=${user%%:*}
      local password=${user#*:}

      local username=${jid%%@*}
      local domain=${jid#*@}

      register_user ${username} ${domain} ${password}
  done
}

# shutdown handling
_trap() {
  echo "Stopping ejabberd..."
  if ctl stop ; then
    local cnt=0
    sleep 1
    while ctl status || test $? = 1 ; do
      cnt=`expr $cnt + 1`
      if [ $cnt -ge 60 ] ; then
        break
      fi
      sleep 1
    done
  fi
}

# catch signals and shutdown ejabberd
trap _trap SIGTERM SIGINT

# main
case "$@" in
  start)
    test -x "$CTL" || exit 0
    mkrundir
    echo "Starting ejabberd..."
    exec su - $USER -c "/usr/local/bin/dockerize \
      -template /etc/ejabberd/ejabberd.yml.tmpl:/etc/ejabberd/ejabberd.yml \
      -stdout ${LOGDIR}/ejabberd.log \
      -stderr ${LOGDIR}/error.log \
      -stderr ${LOGDIR}/crash.log \
      $CTL foreground &"
    child=$!
    $CTL started
    # Register users now, if the environment var is set
    [[ ${EJABBERD_USERS} ]] && register_all_users
    wait $child
  ;;
  shell)
    exec /bin/bash
  ;;
  *)
    exec *@
  ;;
esac
