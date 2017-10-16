#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- source variables script -----------------

source /etc/bacup.d/00_sources.sh

#---- Command Name -----------------------------

cmd_name="Script = ${0}: Submit Working Copy.";
echo "${cmd_name}";

#---- log functions ----------------------------

logging () {
	${base_dir}05_logging.sh "$d" "$cmd_name" && exit ${d};
	}

#---- incomming variables ----------------------

unset c;

#---- command functions ------------------------
: <<'END'
	Desired state = commited and up to date
	if status is nothing, working copy does not need to be commited
	else, add new files, commit and dump the repo
END
prepare_log () {
	if [ -z "$1" ] ; then
	d=1
	elif [ -z "$2" ] ; then
	d=0
	else
	d=20;
	fi;
	logging;
}
test_wrkcp () {
	local svn_status="$($SVN status ${svn_wrkcp_dir})";
	if [ -n "${svn_status}" -a -z "$c" ] ; then
	cmt_wrkcp;
	else
	prepare_log "$1" "${svn_status}";
	fi;
}
cmt_wrkcp () {
	funct_name="add new files and commit working copy";
	$SVN add --force ${svn_wrkcp_dir};
	$SVN commit ${svn_wrkcp_dir} -m "Atualização automática por backup" && local c=1;
	$SVN update ${svn_wrkcp_dir};
	dump_repo "$c";
}
dump_repo () {
	funct_name="dump subversion repository";
	$SVNADMIN dump $svn_repo > $svn_dump
	test_wrkcp "$1";
}

#---- commands ---------------------------------

test_wrkcp;
