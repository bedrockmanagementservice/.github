#!/bin/bash

#   /$$       /$$       /$$$$$$$  /$$$$$$$   /$$$$$$
#  | $$      | $$      | $$__  $$| $$__  $$ /$$__  $$
#  | $$      | $$      | $$  \ $$| $$  \ $$| $$  \__/
#  | $$      | $$      | $$$$$$$ | $$  | $$|  $$$$$$
#  | $$      | $$      | $$__  $$| $$  | $$ \____  $$
#  | $$      | $$      | $$  \ $$| $$  | $$ /$$  \ $$
#  | $$$$$$$$| $$$$$$$$| $$$$$$$/| $$$$$$$/|  $$$$$$/
#  |________/|________/|_______/ |_______/  \______/
#
#
#   /$$$$$$$  /$$$$$$$$ /$$       /$$$$$$$$  /$$$$$$   /$$$$$$  /$$$$$$$$
#  | $$__  $$| $$_____/| $$      | $$_____/ /$$__  $$ /$$__  $$| $$_____/
#  | $$  \ $$| $$      | $$      | $$      | $$  \ $$| $$  \__/| $$
#  | $$$$$$$/| $$$$$   | $$      | $$$$$   | $$$$$$$$|  $$$$$$ | $$$$$
#  | $$__  $$| $$__/   | $$      | $$__/   | $$__  $$ \____  $$| $$__/
#  | $$  \ $$| $$      | $$      | $$      | $$  | $$ /$$  \ $$| $$
#  | $$  | $$| $$$$$$$$| $$$$$$$$| $$$$$$$$| $$  | $$|  $$$$$$/| $$$$$$$$
#  |__/  |__/|________/|________/|________/|__/  |__/ \______/ |________/
#
#
#   /$$$$$$$   /$$$$$$  /$$$$$$$$
#  | $$__  $$ /$$__  $$|__  $$__/
#  | $$  \ $$| $$  \ $$   | $$
#  | $$$$$$$ | $$  | $$   | $$
#  | $$__  $$| $$  | $$   | $$
#  | $$  \ $$| $$  | $$   | $$
#  | $$$$$$$/|  $$$$$$/   | $$
#  |_______/  \______/    |__/
#
#  A SIMPLE DISCORD BOT THAT MONITORS FOR NEW LiteLoaderBDS RELEASES AND NOTIFIES A DISCORD WEBHOOK WHEN FOUND
#
#  by Nerd-King
#
#  TODO:
#    - Move discord webhook URL to a repository secret

# Read current known version from file
CURRENTVERSION=$(<./.data/llbdsbot/llbds-version.txt);

# Read current version from repository
DATA=$(curl -sL https://api.github.com/repos/LiteLDev/LiteLoaderBDS/releases)
TAGNAME=$(jq ".[0].name" <<< "$DATA")
PRERELEASE=$(jq ".[0].prerelease" <<< "$DATA")
PUBLISHED=$(jq ".[0].published_at" <<< "$DATA")
URL=$(jq ".[0].html_url" <<< "$DATA")

if [ -z "${TAGNAME}" ]; then
	exit 0;
fi

# Compare versions
if [ "$CURRENTVERSION" = "$TAGNAME" ]; then
    echo "No new version found."
    exit 0;
else
    echo "New version found! $TAGNAME"
    echo $TAGNAME > .data/llbdsbot/llbds-version.txt
    git config --global user.email "bdsbot@codetical.com"
    git config --global user.name "BDSBot"
    git add .data/llbdsbot/llbds-version.txt
    git commit -m "New LLBDS Version $TAGNAME"
    git push origin bots
    echo "Updated version and pushed changes."
    JSON='{"username":"BDSBot","avatar_url":"https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png","content":"LiteLoaderBDS Has A New Release","embeds":[{"title":'${TAGNAME}',"url":'${URL}',"color": 2021216,"fields":[{"name":"Tag","value":'${TAGNAME}',"inline": true},{"name":"Pre-Release?","value":"'${PRERELEASE}'","inline": true},{"name":"Published","value":'${PUBLISHED}',"inline": true}]}]}'
    curl -H "Content-Type: application/json" --data "$JSON" "$DISCORD_WEBHOOK_LLBDS"
fi

exit 0;
