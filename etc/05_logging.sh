#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- incoming variables------------------------

msg_type="$1";
cmd_name="$2";

#---- log messages -----------------------------

logmsg_std="$datetime $cmd_name: success.";
logmsg_notneed="$datetime $cmd_name: not needed.";
logmsg_error="$datetime $cmd_name: failiure.";

#---- command functions ------------------------
: <<'END'
	Desired state = register log msg as stated by other scripts
	msg_type=0; success! std_log
	msg_type=1; already empty! not_needed_log
	msg_type=2 or other; could not empty! error_log
END

test_logvar () {
	if [ $msg_type -eq "0" ] ; then
	logmsg=$logmsg_std;
	elif [ $msg_type -eq "1" ] ; then
	logmsg=$logmsg_notneed;
	else
	logmsg=$logmsg_error;
	fi;
	$ECHO $logmsg >> $log_file && exit 0 || exit 5;
}

#---- commands ---------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi

# test incoming log type variable and set message accordingly
test_logvar; 
