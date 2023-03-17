export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
if status is-interactive
    # Commands to run in interactive sessions can go here
end
if type -q exa
    alias ll "exa -l -g --icons"
    alias ls "exa --icons"
    alias lla "ll -a"
    alias t1 "exa -l -g --icons --tree --level 1"
    alias t2 "exa -l -g --icons --tree --level 2"
    alias t3 "exa -l -g --icons --tree --level 3"
    alias t4 "exa -l -g --icons --tree --level 4"
    #. ~/.config/bashScripts/aliases.sh
end
#functions
function repo-push
  set REPO_PATH $argv[1] or (pwd)
  set SCRIPT_PATH ~/.config/bspwm/scripts/push-commit.sh

  cd $REPO_PATH

  # Check if the push-commit.sh script exists
  if test ! -f $SCRIPT_PATH; then
    echo 'push-commit.sh script not found!'
    return 1
  end

  # check if the current commit is the latest commit
  if git remote update && git status -uno | grep -q 'Your branch is behind'
    echo 'Your branch is behind the remote branch. Please pull changes before pushing.'
    return 1
  end

  # run the push-commit.sh script
  bash $SCRIPT_PATH
end

