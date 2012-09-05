#!/bin/bash
#
# tmux wrapper to setup rake project if CWD is a Rally Rake-based project

# project is name of current directory
TMUX_BIN=$(which tmux)

# window names
SHELL_WINDOW="shell"
LOG_CONSOLE_WINDOW="log"
LOG_ERROR_WINDOW="error"
DOC_WINDOW="docs"
DEV_WINDOW="dev"
CSS_WINDOW="css"

function config_tmux_session {

  RALLY_PROJECT=$(basename $PWD)

  # set name of initial window
  ${TMUX_BIN} rename-window -t "${RALLY_PROJECT}" "${SHELL_WINDOW}"
  # create console logging window
  ${TMUX_BIN} new-window -t "${RALLY_PROJECT}" -n "${LOG_CONSOLE_WINDOW}"
  ${TMUX_BIN} send-keys -t "${RALLY_PROJECT}" 'tail -f rake.log' C-m
  # create 'documentation' window
  ${TMUX_BIN} new-window -t "${RALLY_PROJECT}" -n "${DOC_WINDOW}"
  ${TMUX_BIN} send-keys -t "${RALLY_PROJECT}" 'vim README.md' C-m

  # create 'dev' window
  ${TMUX_BIN} new-window -t "${RALLY_PROJECT}" -n "${DEV_WINDOW}"
  ${TMUX_BIN} send-keys -t "${RALLY_PROJECT}" "vim App.js" C-m

}

# setup tmux session for rally project
function tmux4app {

  RALLY_PROJECT=$(basename $PWD)

  ${TMUX_BIN} has-session -t "${RALLY_PROJECT}" > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "Session '${RALLY_PROJECT}' found.  Attaching..."
    sleep 1
    ${TMUX_BIN} attach -t "${RALLY_PROJECT}"
    ${TMUX_BIN} select-window -t "${DEV_WINDOW}"
    return
  fi;

  echo "Session '${RALLY_PROJECT}' not found.  Creating..."
  sleep 1

  # create; detach immediately to setup session
  ${TMUX_BIN} new-session -d -s "${RALLY_PROJECT}"
  # setup all the windows etc
  config_tmux_session
  # attach to newly setup session
  ${TMUX_BIN} attach -t "${RALLY_PROJECT}"
}

# create a rabt tmux session only when 'tmux' called without args in rabt project dir
# ! overrides native tmux binary and forwards requests not meant to be handled in rabt land
function tmux {

  if [ $# -gt 0 ]; then
    ${TMUX_BIN} $@      # pass along any native tmux args
    return
  fi

  # all files/dirs must be present to identify a Rabt based project
  for elem in Rakefile README.md config.json deploy.json App.js app.css; do
    
    # not found; launch tmux
    if [ ! -f "${PWD}/${elem}" -a ! -d "${PWD}/${elem}" ]; then
      ${TMUX_BIN} $@      # pass along any native tmux args
      return
    fi
  done

  # all rabt files found, lets launch tmux4app!
  tmux4app
}

