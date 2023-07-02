export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export BROWSER=google-chrome-beta
#export PATH="$HOME/.cargo/bin:$PATH"
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
    alias cwc "warp-cli status;warp-cli connect"
    alias cwd "warp-cli status;warp-cli disconnect"
    alias cws "warp-cli status"
    alias xclip='xclip -selection clipboard'
    alias mpvServer='node ~/Downloads/Tools/mpvServer'
    #. ~/.config/bashScripts/aliases.sh
    z --clean
end
#functions
function git_status
    if test (count $argv) -eq 0
        set directory "."
    else
        set directory $argv[1]
    end
    cd $directory
    set separator "================================================================================"
    set directory_separator "--------------------------------------------------------------------------------"
    for d in */ 
        cd "$d"
        set gitstatus (git status --porcelain)
        if string match -q '*M *' $gitstatus; or string match -q '*A *' $gitstatus; or string match -q '*? *' $gitstatus
            printf "\n%s\n" "$separator"
            printf "\033[1;32m%s\033[0m\n" "Processing directory: $d"
            printf "\033[1;35m%s\033[0m\n" "$directory_separator"
            git status
            printf "%s\n" "$separator"
        end
        cd ..
    end
end


function repo-push
  set REPO_PATH $argv[1] or (pwd)
#  set SCRIPT_PATH ~/.config/bspwm/scripts/push-commit.sh
  set SCRIPT_PATH ~/.config/private-files/push-commit.sh

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

