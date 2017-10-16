#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- incomming variables ----------------------

unset c;

#---- Command Name ----------------------------

cmd_name="Script= ${0}; mount $1 to $2"; 

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "${d}" "${cmd_name}" && unset c && exit ${d};
	}

#---- command functions ------------------------
: <<'END'
	Check if it is not a mountpoint and mount it;
END

prepare_log () {
	if ! $MOUNTPOINT "$1" ; then
		d=43
	elif [ -z "$2" ] ; then
		d=1
	else
		d=0
	fi;
	logging;
}

#---- commands ----------------------------------

$ECHO "${cmd_name}";
[ ! -d "$2" ] && $MKDIR "$2";
if ! $MOUNTPOINT "$2"; then 
	$MOUNT ${mnt_opt} "$1" "$2";
	c=1;
fi;
prepare_log $2 $c;
