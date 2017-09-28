#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

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

test_trash () {
	nonempty_trash="$($FIND ${source_dir} -path *Trash-* -exec find {} -empty -prune -o -print \; 2> /dev/null)";
	if [ -n "$nonempty_trash" -a -z "$c" ] ; then 
	empty_trash
	else prepare_log
	fi
}
prepare_log () {
	if [ -z $c ] ; then
	d=1
	elif [ -z "$nonempty_trash" ] ; then
	d=0
	else
	d=40
	fi;
	logging;
}
test_clone_config () {
	cmd_line="$SSHPASS $cmm_psw $RSYNC $chk $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum";
	$SSHPASS $cmm_psw $RSYNC $chk $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum && wrto_log || exec_copy_config;

}
exec_clone_config () {
	cmd_line="$SSHPASS $cmm_psw $RSYNC $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum";
	$SSHPASS $cmm_psw $RSYNC $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum && copy_config || error_log;
}
clone_srcdir () {
	cmd_name="Clone base directory to Backup Server";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_dir $cmn_usr@$bkp_serv_files";
	$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_dir $cmn_usr@$bkp_serv_files && wrto_log || error_log;
	}
clone_shr_so () {
	cmd_name="Clone GeoDados Operating System to Backup Server /dev/sda3";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_so $sper_usr@$bkp_serv_shr_so";
	$MOUNT $mnt_opt $shr_serv $shr_serv_dir;
	$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $shr_serv_dir $sper_usr@$bkp_serv_shr_so && wrto_log || error_log;
	$CP shr_fstab ${bkp_serv_shr_so}/etc/;
	$UMOUNT $mnt_opt $shr_serv_dir;
	}
clone_app_so () {
	cmd_name="Clone GeoServer Operating System to Backup Server /dev/sda3";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_so $sper_usr@$bkp_serv_app_so";
	{
		$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_so $sper_usr@$bkp_serv_app_so;
		cmd_line="$CP app_fstab ${bkp_serv_app_so}/etc/";
		$CP app_fstab ${bkp_serv_app_so}/etc/;
	} && wrto_log || error_log
	}
pwroff_bkp_srv () {
	cmd_name="Power off Backup Server";
	cmd_line="$SSHPASS $cmm_psw $SSH $ssh_opt $sper_usr@$bkp_serv 'shutdown -h now'";
	$SSHPASS $cmm_psw $SSH $ssh_opt $sper_usr@$bkp_serv 'shutdown -h now';
	$SLEEP 5;
	$PING $ping_opt $bkp_serv && error_log || wrto_log;
	}
engage () {
	$DATE > $error_log; 
	$DATE > $std_log;
	{
		$DATE >> $log_file;
		${base_dir}10_empty_trash.sh;
		${base_dir}20_commit_svn.sh;
		${base_dir}30_copy.sh;
		copy_srcdir;
		clone_shr_so;
		clone_app_so;
		pwroff_bkp_srv
		$ECHO >> $log_file;
	} >> $std_log 2>> $error_log;
	cp_log;
	}

#---- commands ---------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { /bin/echo "Sorry, must be root.  Exiting..."; exit; } fi
engage;
exit;
