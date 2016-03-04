delim='-'
host=$npmCacheHost
pjHash=$(node << jscode | shasum | cut -c 1-40
with ($(cat package.json)) {
	console.log({
		dependencies,
		devDependencies
	})
}
jscode
)
unameHash=$(uname -mprsv | shasum | cut -c 1-40)
modulesHash="DEPS${pjHash}${delim}ARCH${unameHash}"
hostNodeModules="node_modules-$modulesHash"
controlSocket="/tmp/ssh-socket-$host-$(date +%s)"
ssh="ssh -S $controlSocket"
scp="scp -o ControlPath=$controlSocket"