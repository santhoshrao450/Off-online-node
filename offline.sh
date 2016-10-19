
set +vx

#color codes
##Forground
RED='\033[1;31m'
GREEN='\033[1;32m';
YELLOW='\033[1;33m';
BLUE='\033[1;34m';
MAGENTA='\033[1;35m';
CYAN='\033[1;36m';

##Background
RED_BACK='\033[1;41m'
GREEN_BACK='\033[1;42m';
YELLOW_BACK='\033[1;43m';
BLUE_BACK='\033[1;44m';
MAGENTA_BACK='\033[1;45m';
CYAN_BACK='\033[1;46m'
BLACK_BACK='\033[1;40m'

##Special
BOLD='\033[1m';
UNDERLINE='\033[4m';
BLINKING='\033[5m';
NORM='\033[0m';


current_time='date "+%H:%M:%S %d-%h-%Y %Z"'

#Message functions
error() { echo  "${RED}[ERROR] -${BLUE} [$(eval ${current_time})] -${RED} [ $1 ] ${NORM}" && exit 1; }
warning() { echo  "${YELLOW}[WARNING] -${BLUE} [$(eval ${current_time})] -${YELLOW} [ $1 ] ${NORM}"; }
info() { echo  "${CYAN}[INFO] -${BLUE} [$(eval ${current_time})] -${CYAN} [ $1 ] ${NORM}"; }
success() { echo  "${GREEN}[SUCCESS] -${BLUE} [$(eval ${current_time})] -${GREEN} [ $1 ] ${NORM}"; }
step() { echo  "${GREEN}${BLACK_BACK}${UNDERLINE}${BLINKING}\nSTEP- $1 ${NORM}"; }

cd ${WORKSPACE}
if [ ! -f jenkins-cli.jar ]
then
	step "Download jenkins-cli.jar"
    curl -LSo jenkins-cli.jar "http://www.jenkins.edoramedia.com/jnlpJars/jenkins-cli.jar"
fi



url=$(echo "${JENKINS_URL}"'computer/api/xml?tree=computer[displayName,offline]{1,}')


#Install xmllint
if which xmllint > /dev/null
then
	curl --silent --netrc -g "$url" | xmllint --format - | egrep 'displayName|offline' | awk -F'<|>' '{print $3}' | paste - - > ${WORKSPACE}/nodes
else
	error "xmllint is not installed. Please install libxml2-utils package"
fi

step "Status of the nodes:"
cat ${WORKSPACE}/nodes |  sed "s/false/:UP/g" | sed "s/true/:DOWN/g"


if grep -q 'true' ${WORKSPACE}/nodes
then
	step "Restart Offline node:"
	grep 'true' ${WORKSPACE}/nodes > ${WORKSPACE}/offline_nodes
	while read nodestatus
	do
		nodename=$(echo "${nodestatus}" |awk '{print $1}')
	    offline=$(echo "${nodestatus}" |awk '{print $2}')
	    info "Starting ${nodename}"
	    echo "java -jar jenkins-cli.jar -s ${JENKINS_URL} connect-node nikhil_localhost -f" && success "${nodename} started successfully" || error "Node connect failed for : ${nodename}"
	done < ${WORKSPACE}/offline_nodes
fi



Output:

Download jenkins-cli.jar for first time:

Inline image 1
If node is down, try to start:

Inline image 2
If all nodes are up:

Inline image 3
