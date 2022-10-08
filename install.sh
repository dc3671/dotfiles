#!/bin/bash

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1
    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

msg         ">>> Start checking basic requirement..."
program_must_exist "vim"
program_must_exist "git"
program_must_exist "zsh"
success     "Done."

PS3='Please choose which version to be installed: '
options=("basic python version(without YouCompleteMe)" "python & C++ version(with YCM)" "python & frontend version(with YCM)" "full version")
select opt in "${options[@]}"
do
    case "$REPLY" in
        1)
            echo "let g:cfg_bundle_preset = 'nano'" >> .vimrc.before
            break
            ;;
        2)
            echo "let g:cfg_bundle_preset = 'cpp'" >> .vimrc.before
            break
            ;;
        3)
            echo "let g:cfg_bundle_preset = 'frontend'" >> .vimrc.before
            break
            ;;
        4)
            echo "let g:cfg_bundle_preset = 'full'" >> .vimrc.before
            break
            ;;
        *) echo "invalid option";;
    esac
done

# zsh
msg         "[zsh] Config zsh..."
msg         "[zsh] Install oh-my-zsh..."
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
mv ~/.zshrc ~/.zshrc.bkp >/dev/null 2>&1
ln -s $PWD/.zshrc ~/.zshrc

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    msg "[zsh] Prepare to change shell to zsh."
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
        flag_chsh=1
        msg "[zsh] Do you want to change your default shell to zsh? (password is needed) [y/n]"
        read opt
        case $opt in
            y*|Y*|"") msg "[zsh] Changing the shell..." ;;
            n*|N*) msg "[zsh] Shell change skipped."; flag_chsh=0 ;;
            *) msg "[zsh] Invalid choice. Shell change skipped."; flag_chsh=0 ;;
        esac

        if [ "$flag_chsh" != 0 ]; then
            if ! chsh $USER -s $(grep /zsh$ /etc/shells | tail -1); then
                error "[zsh] chsh command unsuccessful. Change your default shell manually."
            else
                export SHELL="$zsh"
                success "[zsh] Done. You may need to re-login or reopen terminal to see the effect"
            fi
        else
            msg "[zsh] You can use 'chsh -s /bin/zsh' to set it as default manually."
        fi
    # Else, suggest the user do so manually.
    else
        error"[zsh] Cannot find chsh command!"
    fi
fi


# vim
msg         "[vim] Config vim..."
msg         "[vim] Install Plug for vim plugins management..."
git clone --depth=1 https://github.com/junegunn/vim-plug.git $PWD/vim-plug
mkdir -p ~/.vim/autoload
cp $PWD/vim-plug/plug.vim ~/.vim/autoload/plug.vim
rm -rf $PWD/vim-plug
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1
mv ~/.vimrc ~/.vimrc.bkp > /dev/null 2>&1
mv ~/.vimrc.before ~/.vimrc.before.bkp > /dev/null 2>&1
mv ~/.vimrc.bundles ~/.vimrc.bundles.bkp > /dev/null 2>&1
ln -s $PWD/.vimrc ~/.vimrc
ln -s $PWD/.vimrc.before ~/.vimrc.before
ln -s $PWD/.vimrc.bundles ~/.vimrc.bundles
vim -u "$PWD/.vimrc.bundles" "+set nomore" "+PlugInstall!" "+PlugClean" "+qall"

# eslint
mv ~/.eslintrc.js ~/.eslintrc.js.bkp >/dev/null 2>&1
ln -s $PWD/.eslintrc.js ~/.eslintrc.js

# ternjs
mv ~/.tern-config ~/.tern-config.bkp >/dev/null 2>&1
ln -s $PWD/.tern-config ~/.tern-config

# pylint
mv ~/.pylintrc ~/.pylintrc.bkp >/dev/null 2>&1
ln -s $PWD/.pylintrc ~/.pylintrc

# yapf
mv ~/.style.yapf ~/.style.yapf.bkp >/dev/null 2>&1
ln -s $PWD/.style.yapf ~/.style.yapf

# gdbinit
mv ~/.gdbinit ~/.gdbinit.bkp >/dev/null 2>&1
ln -s $PWD/.gdbinit ~/.gdbinit

success     "[vim] Done."

# tmux
msg         "[tmux] Config tmux..."
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-sensible ~/.tmux/plugins/tmux-sensible
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
git clone https://github.com/beeryardtech/tmux-net-speed.git ~/.tmux/plugins/tmux-net-speed
git clone https://github.com/samoshkin/tmux-plugin-sysstat.git ~/.tmux/plugins/tmux-plugin-sysstat
mv ~/.tmux.conf ~/.tmux.conf.bkp >/dev/null 2>&1
ln -s $PWD/.tmux.conf ~/.tmux.conf
success     "[tmux] Done."

msg         "\nThanks for using my dotfiles."
msg         "© `date +%Y` https://github.com/dc3671/dotfiles"
exec zsh -l
