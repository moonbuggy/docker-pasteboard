#!/bin/sh

up="$(s6-svstat -o up /run/service/pasteboard/)"
ready="$(s6-svstat -o ready /run/service/pasteboard/)"
status="$(wget -qO- localhost:${NODE_PORT:-3000}/status | sed -En 's|.*message\W+(\w*).*|\1\n|p')"

echo "Up: ${up}, Ready: ${ready}, Status: ${status}"

[ "x${up}" = "xtrue" ] && [ "x${ready}" = "xtrue" ] && [ "x${status}" = "xOK" ] \
	&& exit 0

exit 1
