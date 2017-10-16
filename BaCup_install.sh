#!/bin/bash
#----------------------------------------------
# Backup BaseGeo script.
#----------------------------------------------
# Author Claudia Enk de Aguiar
#----------------------------------------------

unset PATH # avoid accidental use of $PATH

#---- paths variables -------------------------

# Commands in /usr/bin
DIRNAME=/usr/bin/dirname;
FIND=/usr/bin/find;

# Commands in /bin
CHMOD=/bin/chmod;
CP=/bin/cp;
ECHO=/bin/echo;
MKDIR=/bin/mkdir;
SED=/bin/sed;

# Default scripts and log directories
default_dir=/etc/bacup.d;
install_dir=/usr/bin;

#---- print functions --------------------------

writo_stderr () {
	$ECHO " Erro.";
	$ECHO "Não foi possível realizar a tarefa. Erro desconhecido.";
	$ECHO "Desfazer as alterações manualmente.";
	exit 1;
	}
cp_BaCup () {
	$ECHO "Copiando o script principal BaCup.sh para $install_dir";
	$CP bin/BaCup.sh ${install_dir}/BaCup.sh && $ECHO " Pronto." && test_BaCupD || writo_stderr;
	}
test_BaCupD () {
	$ECHO "Testando se existe o diretório ${base_dir}";
	[[ -d ${base_dir} ]] && $ECHO " Pronto." && test_prev || mk_BaCupD;
}
mk_BaCupD () {
	$ECHO "Diretório não encontrado.";
	$ECHO "Criando o diretório ${base_dir}";
	$MKDIR -p ${base_dir}/log && cp_BaCupD && $ECHO " Pronto." || writo_stderr;
}
test_prev () {
	$ECHO "Diretório encontrado.";
	$ECHO "Removendo, se existem, scripts auxiliares de versão anterior em ${base_dir}";
	$FIND ${base_dir} -mindepth 1 -maxdepth 1 -type f -name '*.sh' -delete;
	[ -z "$($FIND ${base_dir} -mindepth 1 -maxdepth 1 -type f -name '*.sh' 2> /dev/null)" ] && $ECHO " Pronto."  && cp_BaCupD || writo_stderr;
}
cp_BaCupD () {
	$ECHO "Copiando scripts auxiliares para ${base_dir}";
	$CP etc/*.sh ${base_dir}/ && $ECHO " Pronto." && chng_baseD || writo_stderr;
	}
chng_baseD () {
	if [ "${base_dir}" != "${default_dir}" ] ; then
	$ECHO "Alterando no script fonte o diretório base para ${base_dir}";
	$SED -i -e 's~/etc/bacup.d~${base_dir}~g' ${base_dir}/00_sources.sh && $ECHO " Pronto.";
	fi;
	chmod_BaCupD;

}
chmod_BaCupD () {
	$ECHO "Transformando scripts auxiliares em executaveis";
	$FIND ${base_dir} -mindepth 1 -maxdepth 1 -type f -name '*.sh' -exec $CHMOD +x {} \; &&  $ECHO " Instalação finalizada com sucesso." && exit 0 || writo_stderr;
	}

#---- commands ---------------------------------

# make sure we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2 ;
   exit 1 ;
fi;
# Change to the script directory
cd "$($DIRNAME "$0")";
# ask user for the scripts dir
$ECHO -n "Digite o diretório para instalação dos scripts (padrão: ${default_dir}):";
read input_dir;
if [ -z "${input_dir}" -o "${input_dir}" = "${default_dir}" ]; then
	base_dir=${default_dir};
else
	base_dir=${input_dir};
fi;
cp_BaCup;
