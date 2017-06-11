for pykaraoke (https://github.com/kelvinlawson/pykaraoke):

need homebrew installed and updated / upgraded

first install pygame:

make sure homebrew python is installed:

brew install python
brew link --overwrite python

brew install sdl sdl_image sdl_mixer sdl_ttf portmidi  //might be unncessesary?
pip install https://bitbucket.org/pygame/pygame/get/default.tar.gz

then wxpython (for playing KAR files):

brew install wxpython

and scipy (for CDG files):

brew install scipy

git clone https://github.com/kelvinlawson/pykaraoke.git

download pygame source for dev headers: http://www.pygame.org/download.shtml
edit setup.cfg - change last line to read:
include_dirs = /usr/local/include/SDL/:/usr/local/include/python2.7/

compile:

sudo python setup.py install

brew uninstall libvorbis libogg # if you have them installed
brew reinstall sdl_mixer --with-libvorbis

run with

pythonw pykaraoke.py

for command line operation:

pythonw pycdg.py ~/Projects/karaoke_bar/KAROAKE\ FILES/CBSE/\(Duets\)\ Garth\ Brooks\ With\ George\ Jones\ -\ Beer\ Run\ -\ CBSE.cdg