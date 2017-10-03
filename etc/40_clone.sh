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

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "${d}" "${cmd_name}" && exit ${d};
	}

#---- command functions ------------------------
: <<'END'
	Desired state = final copy = source
	Flux = call for the specific function; 
	test if there would be difference once the sync is made;
		if there would be difference, exec the sync
	d=0 if the sync was made and there is no more difference;
	d=1 if the sync was not made (because)and there is no difference;
	d=40 if there is still difference (none of the above are met);
END

prepare_log () {
	if [ ! -z "$1" ] ; then
	d=40
	elif [ -z "$2" ] ; then
	d=1
	else
	d=0
	fi;
	unset clone_res;
	logging;
}
exec_clone () {
	clone_res="$($SSHPASS ${cmm_psw} $RSYNC $1)";
}
test_clone () {
	local test_clone_opt="${chk} $1";
	exec_clone "${test_clone_opt}";
	if [ ! -z "${clone_res}" ] ; then
	exec_clone "$1";
	local c=1;
	fi;
	exec_clone "${test_clone_opt}";
	prepare_log "${clone_res}" "$c";
	}
set_variables () {
	unset clone_res;
	unset c;
	local clone_fact="$1";
	dest_dir="${local clone_fact#*@}";
	local source_dir1="${local clone_fact% *}";
	local source_dir="${source_dir1##* }";
	cmd_name="Script= $this_script; Sync ${source_dir} to ${dest_dir}";
}
#---- commands ---------------------------------


# make sure we're running as root
if (( `$ID -u` != 0 )); then { /bin/echo "Sorry, must be root.  Exiting..."; exit; } fi
for i in "${clone_fact}"
		do
			:
			set_variables "$i"; # incomming variables and command name
			test_clone "$i";
			$CP "${data_fstab}" "${dest_dir}"/etc/;
		done
