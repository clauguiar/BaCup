#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- variables source script ------------------

source /etc/bacup.d/00_sources.sh

#---- Command Name ----------------------------

cmd_name="Script= ${0}: Secure copy ${source_file} to ${dest_file}";

#---- log function -----------------------------

logging () {
	${base_dir}05_logging.sh "$d" "$cmd_name" && unset c && exit ${d};
	}

#---- incomming variables ----------------------

unset c;
source_dir="$1";
prim_dest_dir="$2";
sec_dest_dir="$3";

#---- command functions ------------------------
: <<'END'
	Desired state = final copy = source; 
	Flux = If there's three sets of dir, hard copy, else simple copy.
	Hard copy = remove second destiny dir;
		move primary destiny dir to second;
		copy hard linking source dir to primary destiny dir.
	Simple copy = copy recursively source to primary destiny.
END
prepare_log () {
	local res="$(test_dirs ${source_dir} ${prim_dest_dir})";
	if [[ "$res" != "1" ]] ; then
	d=50;
	elif [ -z $c ] ; then
	d=1;
	else
	d=0;
	fi;
	logging;
}
test_diff () {
	DIFF1="$($DIFF  $1 <($SSH $2 'cat '$3 ))";
	if [[ -d "$2" && "$DIFF1" = "" ]]; then 
	echo "1";
	else
	echo "0";
	fi;
}
mv_a_rep () {
	local res="$(test_dirs ${prim_dest_dir} ${sec_dest_dir})";
	if [[ "$res" != "1" ]] ; then
	$RM ${scp_opt} ${sec_dest_dir};
	$MV ${prim_dest_dir} ${sec_dest_dir} &&	c="1";
	fi;
	exec_cp;
}
exec_cp () {
	local res="$(test_dirs ${source_dir} ${prim_dest_dir})";
	if [[ "$res" != "1" ]] ; then
	$CP ${cp_opt} ${source_dir}/. ${prim_dest_dir}/ && c="1";
	fi;
	prepare_log;
	}
set_variables () {
	unset scp_res;
	unset c;
	local scp_fact="$1";
	local dest_file="${scp_fact#*@}";
	local dest_server="${dest_file%:*}"
	local source_file="${local scp_fact% *}";
	local dest_file_path="${dest_file#*/}";
	$ECHO "${cmd_name}";
	test_diff "${dest_file}" "${dest_server}" "${dest_file_path}";
}

#---- commands ---------------------------------

# loop through secure copiyng arrays
for i in "${1}"
		do
			:
			set_variables "$i";
		done
