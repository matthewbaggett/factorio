#!/bin/sh -x

set -e

SAVES=/factorio/saves
CONFIG=/factorio/config
MODS=/factorio/mods

mkdir -p $SAVES
mkdir -p $MODS
mkdir -p $CONFIG

if [ ! -f $CONFIG/rconpw ]; then
  echo $(pwgen 15 1) > $CONFIG/rconpw
fi

sed -i "s/SERVER_USERNAME/$SERVER_USERNAME/g" $CONFIG/server-settings.json
sed -i "s/SERVER_TOKEN/$SERVER_TOKEN/g" $CONFIG/server-settings.json
sed -i "s/SERVER_NAME/$SERVER_NAME/g" $CONFIG/server-settings.json
sed -i "s/SERVER_DESCRIPTION/$SERVER_DESCRIPTION/g" $CONFIG/server-settings.json

cat $CONFIG/server-settings.json

if [ -f $MODS/mod-list.json ]; then
  /opt/factorio-mod-updater/factorio-mod-updater -s $CONFIG/server-settings.json
fi

if ! find -L $SAVES -iname \*.zip -mindepth 1 -print | grep -q .; then

  if [ ! -z "$SERVER_SCENARIO" ]; then
    /opt/factorio/bin/x64/factorio \
      --create $SAVES/_autosave1.zip  \
	  --start-server-load-scenario twister
  else
    /opt/factorio/bin/x64/factorio \
      --create $SAVES/_autosave1.zip
  fi
fi

exec /opt/factorio/bin/x64/factorio \
  --port 34197 \
  --start-server-load-latest \
  --server-settings $CONFIG/server-settings.json \
  --server-whitelist $CONFIG/server-whitelist.json \
  --server-banlist $CONFIG/server-banlist.json \
  --rcon-port 27015 \
  --rcon-password "$(cat $CONFIG/rconpw)" \
  --server-id /factorio/config/server-id.json

