# Test whether a given command exists
# Adapted from http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script/3931779#3931779
function command_exists() {
    hash "$1" &>/dev/null
}

# copy pub key to buffer
function pubkey {
    more "${HOME}"/.ssh/id_rsa.pub | perl -pe 'chomp' | pbcopy && message_info '====> Public key copied to pasteboard.'
}

# On Mac OS X, copies the contents of a text file to the clipboard
# Found at <http://brettterpstra.com/2013/01/15/clip-text-file-a-handy-dumb-service>
function clip() {
    type=$(file "$1" | grep -c text)
    if [ $type -gt 0 ]; then
        cat "$@" | pbcopy
        echo "Contents of $1 are in the clipboard."
    else
        echo "File \"$1\" is not plain text."
    fi
}

# Extracts archives
# Found at <http://pastebin.com/CTra4QTF>
function extract() {
    case $@ in
    *.tar.bz2) tar -xvjf "$@" ;;
    *.tar.gz) tar -xvzf "$@" ;;
    *.bz2) bunzip2 "$@" ;;
    *.rar) unrar x "$@" ;;
    *.gz) gunzip "$@" ;;
    *.tar) tar xf "$@" ;;
    *.tbz2) tar -xvjf "$@" ;;
    *.tgz) tar -xvzf "$@" ;;
    *.zip) unzip "$@" ;;
    *.xpi) unzip "$@" ;;
    *.Z) uncompress "$@" ;;
    *.7z) 7z x "$@" ;;
    *.ace) unace e "$@" ;;
    *.arj) arj -y e "$@" ;;
    *) echo "'$@' cannot be extracted via $0()" ;;
    esac
}

# Updates stuff!
function update() {
    if command_exists apt; then
        heading "[apt] Updating system packages..."
        sudo bash -c "apt update && apt upgrade && apt clean && apt autoremove"
    elif command_exists brew; then
        heading "[homebrew] Updating system packages..."
        brew update && brew upgrade && brew cleanup
    fi

    # Update dotbot
    local DOTBOT_DIR="$HOME/.dotbot"
    if [ ! -z "$DOTBOT_DIR" ] && [ "$DOTBOT_DIR" != "$HOME" ] && command_exists git; then
        heading "[git] Updating dotbot..."
        # Run in a subshell so the user's working directory doesn't change
        (cd "$DOTBOT_DIR" && git pull && git submodule update --recursive --checkout --remote --init)
    fi

    # Since Vim packages may have been updated, update Vim helptags.
    heading "[vim] Updating Vim helptags..."
    vim '+helptags ALL' +qall

    if command_exists npm; then
        heading "[npm] Updating global packages..."
        npm -g update
    fi

    if command_exists pipx; then
        heading "[pipx] Updating global packages..."
        pipx upgrade-all
    fi
}
