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
DIFF=/usr/bin/diff;
FIND=/usr/bin/find;
ID=/usr/bin/id;
PRINT=/usr/bin/print;
RSYNC=/usr/bin/rsync;
SSH=/usr/bin/ssh;
SSHPASS=/usr/bin/sshpass;
SVN=/usr/bin/svn;
SVNADMIN=/usr/bin/svnadmin;
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

comp_comum=10.51.1.17://comum/nmi/basegeo/; # Config files machine
bkp_serv=10.51.1.168; # Backup Server
bkp_serv_files=${bkp_serv}://BaseGeo/; # Backup Server
bkp_serv_app_so=${bkp_serv}://GeoServer/; # Geoserver Operational System Backup volume
bkp_serv_shr_so=${bkp_serv}://GeoDados/; # GeoDados Operational System Backup volume
shr_serv=//10.51.1.211/Geodados_OS; # Share server OS share
shr_serv_dir=/GeoDados_OS_mount; # Share server OS mount point
source_so=/; # Geoserver Source Operational System
applog_dir=${base_dir}log/; # BaCup primary logs directory
source_dir=/BaseGeo/; # Share source directory
app_filedev_dir=${source_dir}aplicativos # App development files dir
svn_repo=${source_dir}svn; # Svn source repository
file_dir=${source_dir}arquivos/; # File directory
trash_dir=${file_dir}.Trash-1000/; # Trash directory
config_dir=${source_dir}config/; # Config directory
config_files_dir=${config_dir}conf_files/; # Config directory 
config_files_bkp_dir=${config_files_dir}168_bkp/; # Config directory
config_trash_dir=${config_dir}.Trash-1000/; # Trash directory
configbkp_dir=${config_dir}backup.d/; # Config backup directory
configlog_dir=${configbkp_dir}BaCup_log; # Config BaCup log directory
svn_dump_dir=${configbkp_dir}svndump/; # Svn dump directory

#---- command options --------------------------

# Credentials
cmn_usr="geoadmin";
sper_usr="root";
passwd="142536";

# Sync options
cmm_psw="-p $passwd";
cmm_excl="-rptLz --delete --delete-excluded --exclude=copia_arquivos*  --exclude=windows_utilities";
chk="-ni";
mir_opt="-azHAXSPhx --delete --exclude=lost+found --numeric-ids";
os_opt="--exclude=/etc/fstab";
cmn_opt="-e ssh";

# Mount options
mnt_opt="-t cifs -o username=geoadmin,domain=GEODADOS,password=142536,uid=geoadmin";

# Copy diretories options
scp_opt="-R"; # Simple copy option
hd_opt="-al --no-preserve=mode"; # Hard link copy options: 
diff_opt="-r --unidirectional-new-file"; # Differ directory options: -r recursive; --unidirectional-new-file treat absent first files as empty

# SSH fake terminal option to poweroff
ssh_opt="-tt";

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
copia_24="${configbkp_dir}copia_arquivos.24"; # 24 hours old file directory tree snapshot
copia_48="${configbkp_dir}copia_arquivos.48"; # 48 hours old file directory tree snapshot
shr_fstab="${config_files_bkp_dir}geodadosbkp_fstab"; # Share server fstab for backup server in emergency mode
app_fstab="${config_files_bkp_dir}geoserverbkp_fstab"; # App server fstab for backup server in emergency mode
