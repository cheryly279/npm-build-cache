# TODO: touch built node_modules directory
echo "Conditionally fetching node_modules for $(pwd)"
set -e # exit on error
dn=$(dirname $0)
$dn/lib/checkEnv.sh # ensures npmCacheHost
source $dn/lib/constants.sh # sets hostDest
host=$npmCacheHost
modulesHash=$($dn/lib/modulesHash.sh)
hostNodeModules="node_modules-$modulesHash"
controlSocket=/tmp/ssh-socket-$host-$(date +%s)
ssh="ssh -S $controlSocket"
$ssh -f -M $host sleep 1000 > /dev/null # background ssh control master for subsequent connections
set +e # disable exit on error
$ssh $host [ -d ${hostDest}$hostNodeModules ] &> /dev/null
cacheExists=$?
set -e # enable exit on error
if [[ $cacheExists -ne 0 ]]
then
	echo "cache does not exist at $host:${hostDest}$hostNodeModules"
	exit $cacheExists
fi
$ssh $host touch -c ${hostDest}$hostNodeModules &> /dev/null
rsync -e "$ssh" --info=progress2 --delete -az $host:${hostDest}$hostNodeModules/ node_modules
$ssh -q -O exit $host 2> /dev/null # close the ssh socket