#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- instalation directories -----------------

install_dir=/usr/bin/; # BaCup main script directory
base_dir=/etc/bacup.d/; # BaCup source scripts directory

#---- system commands used by this script -----

# Commands in /usr/bin
AWK=/usr/bin/awk;
DIFF=/usr/bin/diff;
FIND=/usr/bin/find;
ID=/usr/bin/id;
PRINT=/usr/bin/print;
RSYNC=/usr/bin/rsync;
SSH=/usr/bin/ssh;
SSHPASS=/usr/bin/sshpass;
SVN=/usr/bin/svn;
SVNADMIN=/usr/bin/svnadmin;
TEE=/usr/bin/tee;
TOUCH=/usr/bin/touch;
XARGS=/usr/bin/xargs;

# Commands in /bin
CHMOD=/bin/chmod;
CP=/bin/cp;
DATE=/bin/date;
ECHO=/bin/echo;
FALSE=/bin/false;
GREP=/bin/grep;
MKDIR=/bin/mkdir;
MOUNT=/bin/mount;
MOUNTPOINT=/bin/mountpoint;
MV=/bin/mv;
PING=/bin/ping;
RM=/bin/rm;
SLEEP=/bin/sleep;
TRUE=/bin/true;
UMOUNT=/bin/umount;

#---- file locations --------------------------
: <<'END'
these are the paths that the scripts will use
changes are to be made here
in the future there must have some sort of solution for configuring 
END
serv_ip=(192.168.0.21 192.168.0.25 192.168.0.11);
vol_name=(Backup FileShare GeoData GeoApp);
vol_type=(Server Share ServerOS);
serv_name=(${vol_name[0]}${vol_type[0]} ${vol_name[1]}${vol_type[0]} ${vol_name[2]}${vol_type[0]});
dest[0]=${serv_ip[0]}://${vol_name[2]}${vol_type[1]}/; # Backup Server data volume
dest[1]=${serv_ip[1]}://${vol_name[1]}/${vol_name[2]}ConfCopy/; # File Share Server path for config files copy
dest[2]=${serv_ip[0]}://${vol_name[2]}${vol_type[2]}/; # Data Server Operational System Backup volume
dest[3]=${serv_ip[0]}://${vol_name[3]}${vol_type[2]}/; # App Server Operational System Backup volume
device[0]=//${serv_ip[2]}/${vol_name[2]}${vol_type[2]}; # Data Server OS share
applog_dir=${base_dir}log/; # BaCup primary logs directory
source[0]=/${vol_name[2]}${vol_type[1]}/; # Data Share source directory
source[1]=${source[0]}config/; # Config directory
source[2]=/${vol_name[2]}${vol_type[2]}; # Data Server OS mount point
source[3]=/; # App Source Operational System
app_filedev_dir=${source[0]}devel # App development files directory
svn_repo=${source[0]}svn; # Svn source repository
datageo_dir=${source[0]}files/; # Geo data directory
config_files_dir=${source[1]}conf_files/; # Config directory 
config_files_bkp_dir=${config_files_dir}168_bkp/; # Config directory
config_trash_dir=${source[1]}.Trash-1000/; # Trash directory
configbkp_dir=${source[1]}backup.d/; # Config backup directory
configlog_dir=${configbkp_dir}BaCup_log; # Config BaCup log directory
svn_dump_dir=${configbkp_dir}svndump/; # Svn dump directory

#---- file names -------------------------------

day=$($DATE +%A); # day of week
datetime=$($DATE); # timestamp
svn_dump="$svn_dump_dir$day.svndump"; # Svn dump path and archive filename
log_file="${applog_dir}BaCup.log"; # Log file name
test_log_file="${applog_dir}BaCup_test.log"; # Log file name
std_log="${applog_dir}${day}_BaCup_stdout.log"; # Standard output log
test_std_log="${applog_dir}${day}_BaCup_stdout_test.log"; # Standard output log
error_log="${applog_dir}${day}_BaCup_stderr.log"; # Error output log
test_error_log="${applog_dir}${day}_BaCup_stderr_test.log"; # Error output log
hd_copia="${configbkp_dir}files_copy."; # 24 hours old file directory tree snapshot
copia_24="${hd_copia}24"; # 24 hours old file directory tree snapshot
copia_48="${hd_copia}48"; # 48 hours old file directory tree snapshot
data_fstab="${config_files_bkp_dir}geodadosbkp_fstab"; # Share server fstab for backup server in emergency mode
app_fstab="${config_files_bkp_dir}geoserverbkp_fstab"; # App server fstab for backup server in emergency mode
trash_dir="*.Trash-*"; # Trash directory

#---- command options --------------------------

# Credentials
user[0]="root";
user[1000]="adminuser";
passwd="password";
domain="WORKGROUP";

# Sync options
cmm_psw="-p $passwd";
chk="-ni";
os_opt="--exclude=/etc/fstab";
cmn_sync_opt="-e ssh";
sync_opt[0]="-azHAXSPhx --delete --exclude=lost+found --numeric-ids ${cmn_sync_opt}";
sync_opt[1]="-rptLz --delete --delete-excluded --exclude=${hd_copia}*  --exclude=windows_utilities ${cmn_sync_opt}";

# Mount options
mnt_opt="-t cifs -o username=${user[1000]},domain=${domain},password=${passwd},uid=${user[1000]}";

# Copy diretories options
scp_opt="-R"; # Simple copy option
hd_opt="-al --no-preserve=mode"; # Hard link copy options: 
diff_opt="-r --unidirectional-new-file"; # Differ directory options: -r recursive; --unidirectional-new-file treat absent first files as empty

# SSH fake terminal option to poweroff
ssh_opt="-tt";

#---- arrays -----------------------------------

copydir[0]="${file_dir}" "${copia_24}" "${copia_48}";

comb[0]="${sync_opt[0]} ${source[0]} ${user[1000]}@${dest[0]}";
comb[1]="${sync_opt[1]} ${source[1]} ${user[1000]}@${dest[1]}";
comb[2]="${sync_opt[0]} ${source[2]} ${user[0]}@${dest[2]}";
comb[3]="${sync_opt[0]} ${source[3]} ${user[0]}@${dest[3]}";

devmount[0]="${device[0]} ${source[2]}";
