#!/bin/bash
############################
# install.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files=`ls ~/dotfiles -a | grep -v "^\." | grep -v "^_"`

##########

# diff gitconfig and clobber existing (ignored) with default (under SCM)
# This is necessary because gas operates by modifying the gitconfig
# file and I want to not see changes in my dotfile repo evey time I
# switch to a different git identity.  Gas is hellbent on modifying
# ~/.gitconfig and this cannot be configured, so this is my
# semi-shitty workaround that will "just work"
diff $dir/gitconfig $dir/_gitconfig
cp -f $dir/_gitconfig $dir/gitconfig

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done



install_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d $dir/oh-my-zsh/ ]]; then
        git clone http://github.com/robbyrussell/oh-my-zsh.git
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        if [[ -f /etc/redhat-release ]]; then
            sudo yum install zsh
            install_zsh
        fi
        if [[ -f /etc/debian_version ]]; then
            sudo apt-get install zsh
            install_zsh
        fi
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

install_zsh


# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    echo "Resetting font cache, this may take a moment..."
    fc-cache -f $font_dir
fi
