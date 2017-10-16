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
SCP=/usr/bin/scp;
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
RMDIR=/bin/rmdir;
SLEEP=/bin/sleep;
TRUE=/bin/true;
UMOUNT=/bin/umount;

#---- file locations --------------------------
: <<'END'
these are the paths that the scripts will use
changes are to be made here
in the future there must have some sort of solution for configuring 
END
data_dir=/BaseGeo/; # base dir for data
dataservos_mtp=/GeoDados_OS_mount/; # Data Server OS mount point
applog_dir=${base_dir}log/; # BaCup primary logs directory
svn_wrkcp_dir=${data_dir}aplicativos # App development files directory
svn_repo=${data_dir}svn; # Svn source path repository
config_dir=${data_dir}config/; # Configuration directory
config_files_dir=${config_dir}conf_files/; # Config directory 
config_files_bkp_dir=${config_files_dir}168_bkp/; # Config directory
config_trash_dir=${config_dir}.Trash-1000/; # Trash directory
configbkp_dir=${config_dir}backup.d/; # Config backup directory
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
hd_copia="${configbkp_dir}copia_arquivos."; # 24 hours old file directory tree snapshot
fstab_path="etc/fstab" # fstab path
trash_dir="*.Trash-*"; # Trash directory

#---- command options --------------------------

# Credentials
user[0]="root";
user[1000]="geoadmin";
passwd="142536";
domain="GEODADOS";

# Sync options
cmm_psw="-p $passwd";
chk="-ni"; # -n, dry run; -i, itemize changes;
os_opt="--exclude=/${fstab_path}";
cmn_sync_opt="-e ssh";

# -a, --archive: recursive, links, perms, times, group, owner, device files, special files;
# -z, compress; -H, hard-links; -A, acls (implies perms); -X, extended attributes;
# -S, sparse; -x, --one-file-system
sync_opt[0]="-azHAXSx --partial --delete --exclude=lost+found --numeric-ids ${cmn_sync_opt}";
sync_opt[1]="-rptLz --delete --delete-excluded --exclude=${hd_copia}*  --exclude=windows_utilities ${cmn_sync_opt}";

# Mount options
mnt_opt="-t cifs -o username=${user[1000]},domain=${domain},password=${passwd},uid=${user[1000]}";

# Copy diretories options
scp_opt="-R"; # Simple copy option
hcp_opt="-al --no-preserve=mode"; # Hard link copy options: 

# Differ directory options
# -r, recursive; --unidirectional-new-file, treat absent first files as empty
# --no-dereference, ignore broken symlinks
diff_opt="-r --unidirectional-new-file --no-dereference"; 

# SSH fake terminal option to poweroff
ssh_opt="-tt";

#---- arrays -----------------------------------

# Server IP
# (Backup Server
# Share Server
# Data Server)
serv_ip=(10.51.1.168 10.51.1.17 10.51.1.211);

# hard copies array variables combinations
# (Geo data directory)
hcp_dir_orig=("${data_dir}arquivos/."); # Origin for hard copy
hcp_dir_24=("${hd_copia}24"); # 24 hours old file directory tree snapshot
hcp_dir_48=("${hd_copia}48"); # 48 hours old file directory tree snapshot

# secure copy array variables combinations
# (Share server fstab for backup server in emergency mode 
# App server fstab for backup server in emergency mode)
scp_orig=("${config_files_bkp_dir}geodadosbkp_fstab" "${config_files_bkp_dir}geoappbkp_fstab"); 
scp_dest=("${fstab_file[2]} ${user[0]}@${dest[2]}${fstab_path}" "${fstab_file[3]} ${user[0]}@${dest[3]}${fstab_path}");

# clonning array variables combinations
# (Data Share source volume directory 
# Config directory
# Data Server OS mount point
# App Source Operational System
clo_orig=("${data_dir}" "${config_dir}" "${dataservos_mtp}" "/");
clo_opt=("${sync_opt[0]}" "${sync_opt[1]}" "${sync_opt[0]}" "${sync_opt[0]}"); 
clo_user=("${user[1000]}@" "${user[1000]}@" "${user[0]}@" "${user[0]}@");
clo_dest=("${serv_ip[0]}://BaseGeo/" "${serv_ip[1]}://comum/nmi/basegeo/" "${serv_ip[0]}://GeoDados/" "${serv_ip[0]}://GeoServer/");

# mounting array variables combinations
# (Data Server OS share)
mount_dev=("//${serv_ip[2]}/Geodados_OS");
mount_point=("${dataservos_mtp}");
