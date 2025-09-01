export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export BROWSER=google-chrome-stable
# export NODE_OPTIONS='--no-experimental-require-module'
#export PATH="$HOME/.cargo/bin:$PATH"
if status is-interactive
    set fish_greeting ""
    alias cwc "warp-cli status;warp-cli connect"
    alias cwd "warp-cli status;warp-cli disconnect"
    alias cws "warp-cli status"
    alias xclip='xclip -selection clipboard'
    alias mpvServer='node ~/Downloads/Tools/mpvServer'
    #. ~/.config/bashScripts/aliases.sh
    z --clean
    clear
    # $HOME/.local/bin/colorscript -r
end
if type -q exa
    alias ll "exa -l -g --icons"
    alias ls "exa --icons"
    alias lla "ll -a"
    alias t1 "exa -l -g --icons --tree --level 1"
    alias t2 "exa -l -g --icons --tree --level 2"
    alias t3 "exa -l -g --icons --tree --level 3"
    alias t4 "exa -l -g --icons --tree --level 4"
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
if not test -f $SCRIPT_PATH
    echo "Error: push-commit.sh script not found at $SCRIPT_PATH"
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

function run-repo-push
    set directory (count $argv) > /dev/null; and set directory $argv[1]; or set directory "."
    echo $directory

    # Check if the provided directory exists
    if not test -d "$directory"
        echo "Error: Directory '$directory' does not exist."
        return
    end

    # Get the absolute path of the directory
    set abs_directory (realpath "$directory")

    # Loop through each subdirectory in the specified directory
    for folder in (find "$abs_directory" -type d -name '.git' -prune -exec dirname {} \;)
        echo "Entering $folder"
        cd "$folder"; or return 1  # Enter the folder or exit if unsuccessful
        echo "Running repo-push command"
        repo-push  # Replace with your actual command
        echo "Finished repo-push in $folder"
        echo  # Print an empty line for readability
        cd - >/dev/null  # Return to the previous directory
    end
end
function open
    if string match -q 'http*' $argv[1]
        set url $argv[1]
    else
        set url "https://$argv[1]"
    end
    $BROWSER $url
end
function shuffle-files
    ls | sort -rh | shuf
end
function mpv-random
    # Find all files recursively and store them in an array
    set -l files (find . -type f)

    # Check if any files were found
    if test (count $files) -eq 0
        echo "No files found in the current directory or subdirectories."
        exit 1
    end

    # Select a random file
    set -l random_file $files[(random (count $files))]

    # Play the selected random file with mpv
    mpv "$random_file"

end
function shuffle_videos
    # Check if the correct number of arguments are passed
    if test (count $argv) -ne 3
        echo "Usage: shuffle_videos <directory> <max_length_in_minutes> <max_output_count>"
        return 1
    end

    set dir $argv[1]
    set max_length_minutes (math $argv[2])
    set max_output_count (math $argv[3])

    # Validate directory
    if not test -d $dir
        echo "Directory not found: $dir"
        return 1
    end

    # Find and shuffle all .mp4 files in the directory, then limit the output to max_output_count
    set video_files (find $dir -type f -iname "*.mp4" | shuf)

    set valid_videos

    # Filter videos by duration
    set count 0
    for video in $video_files
        set duration (ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $video)
        set duration_minutes (math $duration / 60)
        if test $duration_minutes -gt $max_length_minutes
            # Add the valid video to the list, ensuring each is on a new line
            set valid_videos "$valid_videos\n$video"
            set count (math $count+1)
            if test $count -eq $max_output_count
                break
            end
        end
    end

    # Remove empty lines and output the valid shuffled list, one video per line
    echo -e $valid_videos | grep -v '^\s*$'
end


function similarity
    # Input arguments: two strings to compare
    set string1 $argv[1]
    set string2 $argv[2]

    if test -z "$string1" -o -z "$string2"
        echo "Usage: similarity <string1> <string2>"
        return 1
    end

    # Use Python to calculate the similarity percentage
    set similarity (python3 -c "
import difflib
import sys
string1 = sys.argv[1]
string2 = sys.argv[2]
similarity = difflib.SequenceMatcher(None, string1, string2).ratio() * 100
print(f'{similarity:.2f}')
" "$string1" "$string2")

    # Print the similarity percentage
    echo $similarity
end

function search_files_by_similarity
    # Input arguments: query string
    set query $argv[1]

    if test -z "$query"
        echo "Usage: search_files_by_similarity <query_string>"
        return 1
    end

    # Temporary storage for results
    set results ""

    # Find all files in the current directory and subdirectories
    for file in (find . -type f)
        # Check if the file contains the query string
        if grep -qi "$query" $file
            # Calculate similarity percentage (assuming similarity function exists)
            set similarity (similarity "$query" "$file")

            # Store results in a formatted way
            set results $results "$similarity\t$file"
        end
    end

    if test -z "$results"
        echo "No matching files found for query: $query"
        return 0
    end

    # Sort results by similarity percentage in descending order and print
    echo "$results" | sort -nr | awk '{print $1 "%\t" $2}'
end

# Created by `pipx` on 2023-12-24 10:28:23
set PATH $PATH /home/gener/.local/bin
