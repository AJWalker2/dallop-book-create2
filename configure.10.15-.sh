#configure.sh VNC_USER_PASSWORD VNC_PASSWORD NGROK_AUTH_TOKEN

#disable spotlight indexing
sudo mdutil -i off -a

#Create new account
sudo dscl . -create /Users/vncuser
sudo dscl . -create /Users/vncuser UserShell /bin/bash
sudo dscl . -create /Users/vncuser RealName "VNC User"
sudo dscl . -create /Users/vncuser UniqueID 1001
sudo dscl . -create /Users/vncuser PrimaryGroupID 80
sudo dscl . -create /Users/vncuser NFSHomeDirectory /Users/vncuser
sudo dscl . -passwd /Users/vncuser $1
sudo dscl . -passwd /Users/vncuser $1
sudo createhomedir -c -u vncuser > /dev/null

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

#VNC password - http://hints.macworld.com/article.php?story=20071103011608872
echo $2 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

#update homebrew
brew update

#install ngrok
brew install --cask ngrok vivaldi packages iterm2 motrix discord sublime-text

#install command line only programs
brew install jadx

#install BigSurUnicodeUpdate
#sudo -S mount -uw / <<< $1
aria2c https://gitlab.com/Austcool-Walker/bigsurunicodeupdate10.15/-/raw/master/build_debug/BigSurUnicodeUpdate10.15+.pkg
sudo Installer -verbose -pkg BigSurUnicodeUpdate10.15+.pkg -target /

#Show Hidden Files in Finder
defaults write com.apple.Finder AppleShowAllFiles true
killall Finder

#install vncuser data
aria2c https://www.dropbox.com/s/d893a08bmjnj9ta/vncuser.txz?dl=1
sudo bsdtar -vxf vncuser.txz -C /Users/vncuser

#Installing Wallpapers
aria2c https://gitlab.com/Austcool-Walker/Wallpapers-git/-/archive/master/Wallpapers-git-master.tar.bz2
sudo bsdtar -vxf Wallpapers-git-master.tar.bz2 -C /Library
sudo cp -v -R /Library/Wallpapers-git-master/./ /Library/"Desktop Pictures"
sudo rm -v -R /Library/Wallpapers-git-master/

#setting permissions on vncuser data files
sudo chmod -v -R 0777 /Users/vncuser
sudo chown -v -R vncuser /Users/vncuser

#configure ngrok and start it
ngrok authtoken $3
ngrok tcp 5900 &
