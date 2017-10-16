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

cmd_name="Script= ${0}; umount $1 and rmdir";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "${d}" "${cmd_name}" && unset c && exit ${d};
	}

#---- command functions ------------------------
: <<'END'
	Check if it a mountpoint and umount it;
END
prepare_log () {
	if [ -z "$2" ] ; then
		d=1
        elif $MOUNTPOINT "$1" ; then
		d=48
	else
		d=0
	fi;
	logging;
}

#---- commands ----------------------------------

$ECHO "${cmd_name}";
if $MOUNTPOINT "$1"; then
        $UMOUNT "$1";
        c=1;
fi;
[ -d "$1" ] && $RMDIR "$1";
prepare_log $1 $c;
