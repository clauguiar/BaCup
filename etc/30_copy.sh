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
	${base_dir}05_logging.sh "$d" "$cmd_name" && exit ${d};
	}

#---- incomming functions ----------------------

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
	if [ -z $c ] ; then
	d=1
	elif [ "$($DIFF ${diff_opt} ${source_dir} ${prim_dest_dir})" = "" ] ; then
	d=0
	else
	d=50;
	fi;
	logging;
}
test_cp () {
	if [[ -d "${prim_dest_dir})" && "$($DIFF ${diff_opt} ${source_dir} ${prim_dest_dir})" = "" ]]; then 
		prepare_log;
	else
	test_cpvar;
	fi;
}
test_cpvar () {
	if [ -z "${sec_dest_dir}" ] ; then
	cp_opt=${scp_opt};
	exec_cp;
	else
	cp_opt=${hd_opt};
	mv_a_rep;
	fi;
}
mv_a_rep () {
	cmd_func="Hard Copy";
	cmd_line="$RM ${scp_opt} ${sec_destiny_dir}; \ $MV ${prim_destiny_dir} ${sec_destiny_dir};";
	[ -d "${sec_dest_dir}" ] && $RM ${scp_opt} ${sec_dest_dir};
	$MV ${prim_dest_dir} ${sec_dest_dir};
	exec_cp;
}
exec_cp () {
	cmd_func="Simple Copy";
	cmd_line="$CP ${cp_opt} ${source_dir} ${prim_destiny_dir}";
	$CP ${cp_opt} ${source_dir}/. ${prim_dest_dir}/ && c="1";
	prepare_log;
	}

#---- commands ---------------------------------

test_cp;
