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

#---- log functions ----------------------------
		
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

#---- loop functions ---------------------------

hard_copy () {
	for i in "${!hcp_dir_orig[@]}"
	do
		:
		local a="${hcp_dir_orig[i]}";
		local b="${hcp_dir_24[i]}";
		local c="${hcp_dir_48[i]}";
		${base_dir}30_copy.sh "$a" "$b" "$c";
	done
}
devmount () {
	for i in "${!mount_dev[@]}"
	do
		:
		local a="${mount_dev[i]}";
		local b="${mount_point[i]}";
		${base_dir}43_mount.sh "${a}" "${b}";
	done
}
clone_sync () {
	for i in "${!clo_orig[@]}"
	do
		:
		local a="${clo_orig[i]}";
		local b="${clo_opt[i]}";
		local c="${clo_user[i]}";
		local d="${clo_dest[i]}";
		${base_dir}40_clone.sh  "$a" "$b" "$c" "$d";
	done
}
secure_copy () {
	for i in "${!scp_orig[@]}"
	do
		:
		local a="${scp_orig[i]}";
		local b="${scp_dest[i]}";
		${base_dir}45_scp.sh "$a" "$b";
	done
}
devumount () {
	for i in "${mount_point[@]}"
	do
		:
		${base_dir}48_umount.sh "$i";
	done
}

#---- command functions ------------------------

engage () {
	( $ECHO; $DATE; ) | $TEE -a $std_log $error_log $log_file; 
	{
		${base_dir}10_empty_trash.sh;
		${base_dir}20_svn_commit.sh;
		hard_copy;
		devmount;
		${base_dir}40_clone.sh "${comb[@]}";
		${base_dir}45_scp.sh ${copydir[@]:1:2};
		devumount;
		${base_dir}50_shutdown.sh;
	} >> $std_log 2>> $error_log;
	( $ECHO "Backup finalizado, encerrando BaCup"; $ECHO; ) | $TEE -a $std_log $error_log $log_file; 
	${base_dir}30_copy.sh ${applog_dir} ${configlog_dir};
	}

#---- commands ---------------------------------

# make sure we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2 ;
   exit 1 ;
fi;

engage;
exit;
