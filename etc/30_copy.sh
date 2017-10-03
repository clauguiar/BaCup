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

cmd_name="${cmd_func} ${source_dir} to ${prim_dest_dir}";

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
test_cpvar () {
	if [ -z "${sec_dest_dir}" ] ; then
	cp_opt=${scp_opt};
	cmd_func="Simple Copy";
	exec_cp;
	else
	cmd_func="Hard Copy";
	cp_opt=${hd_opt};
	mv_a_rep;
	fi;
}
test_dirs () {
	DIFF1="$($DIFF ${diff_opt} $1 $2)";
	if [[ -d "$2" && "$DIFF1" = "" ]]; then 
	echo "1";
	else
	echo "0";
	fi;
}
mv_a_rep () {
	cmd_line="$RM ${scp_opt} ${sec_destiny_dir}; \ $MV ${prim_destiny_dir} ${sec_destiny_dir};";
	local res="$(test_dirs ${prim_dest_dir} ${sec_dest_dir})";
	if [[ "$res" != "1" ]] ; then
	$RM ${scp_opt} ${sec_dest_dir};
	$MV ${prim_dest_dir} ${sec_dest_dir} &&	c="1";
	fi;
	exec_cp;
}
exec_cp () {
	cmd_line="$CP ${cp_opt} ${source_dir} ${prim_destiny_dir}";
	local res="$(test_dirs ${source_dir} ${prim_dest_dir})";
	if [[ "$res" != "1" ]] ; then
	$CP ${cp_opt} ${source_dir}/. ${prim_dest_dir}/ && c="1";
	fi;
	prepare_log;
	}

#---- commands ---------------------------------

test_cpvar;
