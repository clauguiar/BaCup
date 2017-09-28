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

cmd_name="Empty trash";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "$d" "$cmd_name" && exit ${d};
	}
	
#---- command functions ------------------------
: <<'END'
	Desired state = empty
	not empty + c = 0 => perform empty command! empty_trash
	d=0; trash is empty + c = 1 => success! std_log
	d=1; trash is empty + c = 0 => already empty! not_needed_log
	d=2; not empty + c = 1 => could not empty! error_log
END

prepare_log () {
	if [ -z $c ] ; then
	d=1
	elif [ -z "$nonempty_trash" ] ; then
	d=0
	else
	d=10;
	fi;
	logging;
}
test_trash () {
	nonempty_trash="$($FIND ${source_dir} -path *Trash-* -exec find {} -empty -prune -o -print \; 2> /dev/null)";
	if [ -n "$nonempty_trash" -a -z "$c" ] ; then 
	empty_trash
	else prepare_log
	fi
}
empty_trash () {
	$FIND ${nonempty_trash} -mindepth 1 -delete
	c=1;
	test_trash;
}

#---- commands ----------------------------------

test_trash;
