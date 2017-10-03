#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- source variables script -----------------

source /etc/BaCup.d/variables.sh

#---- Command Name -----------------------------

cmd_name="Commit and Dump App Files";

#---- log functions ----------------------------

error_log () {
	$ECHO "$cmd_name: failiure. Command line: $cmd_line" >> $log_file;
	}
wrto_log () {
	$ECHO "$cmd_name: success." >> $log_file;
	}

#---- commands ---------------------------------

{
   cmd_line="$SVN status | $GREP '\?' |awk '{$PRINT $2}'| $XARGS $SVN add";
   $SVN status | $GREP '\?' |awk '{$PRINT $2}'| $XARGS $SVN add
   cmd_line="$SVN commit ${source[1]} -m 'Atualização automática por backup'";
   $SVN commit $app_filedev_dir -m "Atualização automática por backup";
   cmd_line="$SVNADMIN dump ${svn_repo} > ${svn_dump}";
   $SVNADMIN dump $svn_repo > $svn_dump
} && wrto_log || error_log;

exit;
