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

#---- this script ------------------------------

cmd_name="Script = ${0}: Sync ${1} to ${4}";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "${d}" "${cmd_name}" && exit ${d};
	}

#---- command functions ------------------------
: <<'END'
	Syntax = ${base_dir}40_clone.sh "${<clonning_array>}";
	Desired state = final copy = source
	Flux = call for the specific function; 
	test if there would be difference once the sync is made;
		if there would be difference, exec the sync
	d=0 if the sync was made and there is no more difference;
	d=1 if the sync was not made (because)and there is no difference;
	d=40 if there is still difference (none of the above are met);
END

prepare_log () {
	if [ -n "$1" ] ; then
	d=40
	elif [ -z "$2" ] ; then
	d=1
	else
	d=0
	fi;
	unset clone_res;
	logging;
}
exec_clone () {
	clone_res="$($SSHPASS ${cmm_psw} $RSYNC $1)";
}
test_clone () {
	local test_clone_opt="${chk} ${1}";
	exec_clone "${test_clone_opt}";
	if [ -n "${clone_res}" ] ; then
	exec_clone "$1" && local c=1;
	fi;
	exec_clone "${test_clone_opt}";
	prepare_log "${clone_res}" "$c";
	}
set_variables () {
}
#---- commands ---------------------------------


# make sure we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2 ;
   exit 1 ;
fi;
$ECHO "${cmd_name}";
test_clone "${2} ${1} ${3}@${4}";
