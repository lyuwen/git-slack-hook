#!/bin/bash
# Initiating echo
ECHO="echo -e"
[[ ! -z `$ECHO | grep "e"` ]] && ECHO="echo"

${ECHO} "Initiating git-slack integration configuration"
${ECHO} "Checking basics..."
${ECHO} -n "Checking curl... "
if [[ -e `which curl` ]]; then
    ${ECHO} "good"
else
    ${ECHO} "Not found";
    exit 1;
fi
${ECHO} -n "Check input... "
REPO=$1
while [[ -z $REPO ]]; do
    ${ECHO} "Please specify the git repository: "
    read -e REPO
done
if [[ `${ECHO} $REPO|grep -c ".git"` -eq 1 ]] && [[ -d $REPO ]] && [[ -d $REPO/hooks ]]; then
    ${ECHO} "good"
else
    ${ECHO} Input $REPO "is not a bare git repository"
    exit 1;
fi
${ECHO} "All good, starting configuration..."
${ECHO} -n "Copying post-receive script..."
if [[ -f "$REPO/hooks/post-receive" ]];then
    ${ECHO}
    read -p "A post-receive script exists in the hooks directory, shall we overwrite(y/n)? " choice
    case "$choice" in 
        y|Y ) ${ECHO} "Proceeding";;
        n|N ) ${ECHO} "Exiting"; exit 1;;
        * ) ${ECHO} "Exiting"; exit 1;;
    esac
fi
cp -f git-slack-hook $REPO/hooks/post-receive
${ECHO} "done"
${ECHO} "Congiuring the repository, entering the repository."
cd $REPO
${ECHO}
${ECHO} "Now please go to the following website to retrieve a webhook URL:"
${ECHO} "    https://my.slack.com/services/new/incoming-webhook"
${ECHO}
read -p "Please type in the webhook URL: " WHURL
${ECHO} -n "checking... "
if [[ ! `${ECHO} "$WHURL"|grep -c "https://hooks.slack.com/services"` -eq 1 ]];then
    ${ECHO}
    ${ECHO} "invalid URL"
    exit 1;
fi
#${ECHO} "git config hooks.slack.webhook-url \"$WHURL\""
git config hooks.slack.webhook-url "$WHURL"
${ECHO} "done"
read -p "Please specicy a channel (optional): " channel
if [[ ! -z $channel ]]; then
    git config hooks.slack.channel "$channel"
else
    ${ECHO} "channel not specified. It will be sent to the channel set on the website."
fi
read -p "Please specicy a bot username [git]: " botname
if [[ -z $botname ]]; then
    botname="git"
fi
git config hooks.slack.username "$botname"
read -p "Please specicy a bot emoji [:twisted_rightwards_arrows:] (for example :ghost:): " botemoji
if [[ -z $botemoji ]]; then
    botemoji=":twisted_rightwards_arrows:"
fi
git config hooks.slack.icon-emoji "$botemoji"
read -p "Please specicy a repository nice name (optional): " nicename
if [[ ! -z $nicename ]]; then
    git config hooks.slack.repo-nice-name "$nicename"
fi
read -p "Display full/last commit(s) when pushing mutiple commits (y/n)? " choice
case "$choice" in 
    y|Y ) ${ECHO} "Full commits mode.";git config hooks.slack.show-full-commit true;;
    * ) ${ECHO} "Last commit mode."; git config hooks.slack.show-only-last-commit true;;
esac
${ECHO} "Finished. You are good to go!"
