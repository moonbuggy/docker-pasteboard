#!/bin/sh

up="$(s6-svstat -o up /run/service/pasteboard/)"
ready="$(s6-svstat -o ready /run/service/pasteboard/)"
nginx="$(wget -qO- http://localhost:${NGINX_PORT:-8080}/nginx-ping)"
status="$(wget -qO- localhost:${NODE_PORT:-3000}/status | sed -En 's|.*message\W+(\w*).*|\1\n|p')"
proxied_status="$(wget -qO- localhost:${NGINX_PORT:-8080}/status | sed -En 's|.*message\W+(\w*).*|\1\n|p')"

echo "Up: ${up}, Ready: ${ready}, Nginx ping: ${nginx}, Status: ${status}, Proxied status: ${proxied_status}"

[ "x${up}" = "xtrue" ] && [ "x${ready}" = "xtrue" ] \
	&& [ "x${nginx}" = "xpong" ] \
	&& [ "x${status}" = "xOK" ] && [ "x${proxied_status}" = "xOK" ] \
	&& exit 0

exit 1
