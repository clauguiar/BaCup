#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- incomming variables ----------------------

unset c;

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- Command Name ----------------------------

cmd_name="Script= ${0}: hard copy $1 to $2";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "$1" "$cmd_name" && unset c && exit "$1";
	}

#---- command functions ------------------------
: <<'END'
	Desired state = final copy = source; 
	Hard copy = remove second destiny dir;
		move primary destiny dir to second;
		copy hard linking source dir to primary destiny dir.
END
prepare_log () {
	if [ -z "$c" ] ; then
		local d=1;
	elif test_dirs_equal "$1" "$2"; then
		local d=0;
	else
		local d=30;
	fi;
	logging "$d";
}
exec_mv () {
	$MV "$1" "$2";
}
exec_rm () {
	$RM ${scp_opt} "$1";
}
exec_cp () {
	$CP ${hcp_opt} "$1" "$2";
	c=1;
	prepare_log "$1" "$2";
}
test_dir_exist () {
	[ -d "$1" ];
}
test_dirs_equal () {
	$DIFF ${diff_opt} "$1" "$2";
}		
test_dirs () {
	$ECHO "${cmd_name}";
	if test_dir_exist "$2"; then
		if test_dir_exist "$3"; then
			if test_dirs_equal "$2" "$3"; then
				if test_dirs_equal "$1" "$2"; then
					unset c && prepare_log;
				fi;
			fi;
			exec_rm "$3";
		fi;
		exec_mv "$2" "$3";
	fi;
	exec_cp "$1" "$2";
}

#---- commands ---------------------------------

test_dirs "$1" "$2" "$3";
