#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- this script ------------------------------

local this_scritp="${@:(-2):1}";

#---- incomming variables ----------------------

unset c;

#---- Command Name ----------------------------

cmd_name="Script= ${this_script}; ${funct_name} ${source_dir} to ${dest_dir}"; 

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "${d}" "${cmd_name}" && unset c && exit ${d};
	}

#---- command functions ------------------------
: <<'END'
	check_mount = Check if it is not a mountpoint and mount it;
	check_umount = Check if it a mountpoint and umount it;
END

prepare_log () {
	if [ -z "$1" ] ; then
	d=45
	elif [ -z "$2" ] ; then
	d=1
	else
	d=0
	fi;
	logging;
}
check_mount () {
	funct_name="mount";
	unset c;
	unset m;
	for i in  "$1"
		do
			local device="${i%% *}";
			local mount_point="${i##* }";
			if ! $MOUNTPOINT "${mount_point}" ;  then
				$MOUNT "${mnt_opt}" "${device}" "${mount_point}";
				local c=1;
				fi;
			done
		if ! $MOUNTPOINT "${mount_point}" ;  then
		local m=0;
		fi;
		prepare_log $m $c;
}
check_umount () {
	funct_name="umount";
	unset c;
	unset m;
	for i in  ${devmount[@]}
		do
			local device="${i%% *}";
			local mount_point="${i##* }";
			if $MOUNTPOINT "${mount_point}" ;  then
				$UMOUNT "${mnt_opt}" "${device}" "${mount_point}";
				local c=1;
				fi;
			done
		if $MOUNTPOINT "${mount_point}" ;  then
		local m=0;
		fi;
		prepare_log $m $c;
}
