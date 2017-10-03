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

cmd_name="Main backup script BaCup.sh";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "$d" "$cmd_name";
	}

#---- command functions ------------------------
		
prepare_log () {
	if [ -z $c ] ; then
	d=1
	elif [ -z "$nonempty_trash" ] ; then
	d=0
	else
	d=3
	fi;
	logging;
}
engage () {
	( $ECHO; $DATE; ) | $TEE -a $std_log $error_log $log_file; 
	{
		${base_dir}10_empty_trash.sh;
		${base_dir}20_commit_svn.sh;
		${base_dir}30_copy.sh ${file_dir} ${copia_24} ${copia_48};
		${base_dir}40_clone.sh;
		${base_dir}50_shutdown.sh;
	} >> $std_log 2>> $error_log;
	( $ECHO "Backup finalizado, encerrando BaCup"; $ECHO; ) | $TEE -a $std_log $error_log $log_file; 
	${base_dir}30_copy.sh ${applog_dir} ${configlog_dir};
	}

#---- commands ---------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi
engage;
exit;
