#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- system commands used by this script -----

# Commands in /usr/bin
FIND=/usr/bin/find;
ID=/usr/bin/id;
RSYNC=/usr/bin/rsync;
SSH=/usr/bin/ssh;
SSHPASS=/usr/bin/sshpass;
SVN=/usr/bin/svn;
SVNADMIN=/usr/bin/svnadmin;

# Commands in /bin
CP=/bin/cp;
CHMOD=/bin/chmod;
DATE=/bin/date;
ECHO=/bin/echo;
MKDIR=/bin/mkdir;
MOUNT=/bin/mount;
MOUNTPOINT=/bin/mountpoint;
UMOUNT=/bin/umount;
RM=/bin/rm;
MV=/bin/mv;

#---- file locations --------------------------

comp_comum=<Config files backup machine IP>:<backup server path>; # Config files backup machine
bkp_serv=<Backup Server IP>; # Backup Server
base_path=<base path of server shares and files>; # Base path
bkp_serv_files=${bkp_serv}:${base_path}; # Backup Server
bkp_serv_so=${bkp_serv}:<OS backup device directory when mounted in Backup Server>; # Operational System Backup Server
source_so=/; # Source Operational System
app_dir=/etc/BaCup.d/; # BaCup app directory
applog_dir=${app_dir}/log/; # App directory
source_dir=${base_path}; # Base directory
app_filedev_dir=${source_dir}<application path> # App development and deployment files dir
svn_repo=${source_dir}svn; # Svn source repository
file_dir=${source_dir}<files path>/; # Files and share directories
trash_dir=${file_dir}.Trash-1000/; # Trash directory
config_dir=${source_dir}config/; # Config directory
config_trash_dir=${config_dir}.Trash-1000/; # Trash directory
configbkp_dir=${config_dir}backup.d/; # Config backup directory
configlog_dir=${configbkp_dir}BaCup_log; # Config BaCup log directory
svn_dump_dir=${configbkp_dir}svndump/; # Svn dump directory

#---- file names -------------------------------

day=$($DATE +%A); # day of week
svn_dump="$svn_dump_dir$day.svndump"; # Svn dump path and archive filename
log_file="${applog_dir}BaCup.log"; # Log file name
std_log="${applog_dir}${day}_BaCup_stdout.log"; # Standard output log
error_log="${applog_dir}${day}_BaCup_stderr.log"; # Error output log
cp_files_base="files_copies.";
copy_24="${configbkp_dir}${cp_files_base}24"; # 24 hours old file directory tree snapshot
copy_48="${configbkp_dir}${cp_files_base}48"; # 48 hours old file directory tree snapshot

#---- command options --------------------------

# Credentials
cmn_usr="admin";
sper_usr="root";
passwd="password";

# Sync options
cmm_psw="-p $passwd";
cmm_excl="-rptLz --delete --delete-excluded --exclude=${cp_files_base}*  --exclude=windows_utilities";
mir_opt="-azHAXSPhx --delete --exclude=lost+found --numeric-ids";
os_opt="--exclude=/etc/fstab";
cmn_opt="-e ssh";

# Copy diretories options
cp_opt="-R";

# SSH fake terminal option to poweroff
ssh_opt="-tt";

# Hard link copy options
hd_opt="-al";

#---- functions --------------------------------

error_log () {
	$ECHO "$cmd_name: failiure. Command line: $cmd_line" >> $log_file;
	}
wrto_log () {
	$ECHO "$cmd_name: success." >> $log_file;
	}
commit_svn () {  
       cmd_name="Commit App Files";
       cmd_line="$SVN commit $config_dir -m 'Atualização automática por backup'";
       $SVN commit $app_filedev_dir -m "Atualização automática por backup" && wrto_log || error_log;
       }
dump_svn () {
	cmd_name="Dump App files"; 
	cmd_line="$SVNADMIN dump $svn_repo > $svn_dump";
	$SVNADMIN dump $svn_repo > $svn_dump && wrto_log || error_log;
	}
copy_config () {
	cmd_name="Config files copy to Servidor Comum";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum";
	$SSHPASS $cmm_psw $RSYNC $cmn_opt $cmm_excl $config_dir $cmn_usr@$comp_comum  && wrto_log || error_log;
	}
empty_trash () {
	cmd_name="Empty trash";
	cmd_line="$FIND ${trash_dir} -mindepth 1 -delete";
	$FIND ${trash_dir} -mindepth 1 -delete && wrto_log || error_log;
	}
empty_config_trash () {
	cmd_name="Empty config trash";
	cmd_line="$FIND ${config_trash_dir} -mindepth 1 -delete";
	$FIND ${config_trash_dir} -mindepth 1 -delete && wrto_log || error_log;
	}
rm_bkp () {
	cmd_name="Remove ${copy_48}"; 
	cmd_line="$RM $cp_opt ${copy_48}";
	$RM $cp_opt ${copy_48} && wrto_log || error_log;
	}
mv_bkp () {
	cmd_name="Move ${copy_24} to ${copy_48}";
	cmd_line="$MV ${copy_24} ${copy_48}";
	$MV ${copy_24} ${copy_48} && wrto_log || error_log;
	}
hard_cp () {
	cmd_name="Hard link source to ${copy_24}";
	cmd_line="$CP $hd_opt $file_dir ${copy_24}";
	$CP $hd_opt $file_dir ${copy_24} && wrto_log || error_log;
	}
copy_srcdir () {
	cmd_name="Copy base directory to Backup Server";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_dir $cmn_usr@$bkp_serv_files";
	$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_dir $cmn_usr@$bkp_serv_files && wrto_log || error_log;
	}
clone_so () {
	cmd_name="Clone Operating System to Backup Server /dev/sda3";
	cmd_line="$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_so $sper_usr@$bkp_serv_so";
	$SSHPASS $cmm_psw $RSYNC $mir_opt $cmn_opt $source_so $sper_usr@$bkp_serv_so && wrto_log || error_log;
	}
pwroff_bkp_srv () {
	cmd_name="Power off Backup Server";
	cmd_line="$SSHPASS $cmm_psw $SSH $ssh_opt $sper_usr@$bkp_serv 'shutdown -h now'";
	$SSHPASS $cmm_psw $SSH $ssh_opt $sper_usr@$bkp_serv 'shutdown -h now' && wrto_log || error_log;
	}
cp_log () {
	cmd_name='Copy log files from /etc/backup.d/log/ to /BaseGeo/backup.d/log/';
	cmd_line="$CP $cp_opt $applog_dir $configbkp_dir";
	$CP $cp_opt $applog_dir $configlog_dir && wrto_log || error_log;
	}
execute () {
	$DATE >> $log_file;
	dump_svn;
	copy_config;
	empty_trash;
	empty_config_trash
	rm_bkp && mv_bkp && hard_cp; 
	copy_srcdir;
	clone_so;
	pwroff_bkp_srv
	$ECHO >> $log_file;
	}
engage () {
	$DATE > $error_log; 
	$DATE > $std_log;
	execute >> $std_log 2>> $error_log;
	cp_log;
	}

#---- commands ---------------------------------

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit; } fi
engage;
exit;
