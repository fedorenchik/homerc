### Some features of this Vim configuration:
 * automatically source local .vimrc/.exrc file from current directory
   - set secure to restrict what can be put into local .vimrc/.exrc
 * .viminfo files are local
   - saved in current directory

### Commands defined in .bashrc
 * e -- start gvim normally
 * r -- start gvim in RO mode
   - set nomodifiable readonly
 * S -- start gvim in "session" mode
   - local .session.vim file is automatically loaded/saved on start/exit.

Compile vim:
------------

```shell
sudo apt install luajit libluajit-5.1-dev ncurses-dev
sudo apt build-dep vim-gnome
cd $HOME/src/vim
make clean
make distclean
rm -f auto/config.cache
git clean -fxd
git checkout master
git checkout -- .
git pull --ff-only
./configure \
	--enable-fail-if-missing \
	--prefix=$HOME/.local \
	--with-features=huge \
	--enable-luainterp=dynamic \
	--with-luajit \
	--disable-mzschemeinterp \
	--enable-perlinterp=dynamic \
	--enable-pythoninterp=no \
	--enable-python3interp=dynamic \
	--with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
	--enable-tclinterp=no \
	--enable-rubyinterp=no \
	--enable-cscope \
	--disable-workshop \
	--enable-netbeans \
	--enable-channel \
	--enable-terminal \
	--enable-multibyte \
	--enable-gui=gnome2 \
	--enable-largefile \
	--with-modified-by='Leonid V. Fedorenchik' \
	--with-compiledby='Leonid V. Fedorenchik'
make
make install
```