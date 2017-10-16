#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- Command Name -----------------------------

cmd_name="Power off Backup Server";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "$d" "$cmd_name" && exit ${d};
	}
	
#---- command functions ------------------------
: <<'END'
	Desired state = unreachable
	reachable + c = 0 => perform shutdown command! shutdown
	d=0; unreachable + c = 1 => success! std_log
	d=1; unreachable + c = 0 => already empty! not_needed_log
	d!=0/1; reachable + c = 1 => could not empty! error_log
END

prepare_log () {
	if [ -z $c ] ; then
	d=1;
	elif $PING -c 1 ${serv_ip[0]} ; then
	d=0;
	else
	d=50;
	fi;
	logging;
}
perform_shutdown () {
	$SSHPASS ${cmm_psw} $SSH ${ssh_opt} ${user[0]}@${serv_ip[0]} 'shutdown -h now';
	$SLEEP 5;
	c=1;
}


#---- commands ----------------------------------

if $PING -c 1 ${serv_ip[0]} ; then
	perform_shutdown;
fi;
$SLEEP 50;
prepare_log;
