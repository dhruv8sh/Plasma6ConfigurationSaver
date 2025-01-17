
configPath=$1
savePath=$2
dataPath=$3
modelData=$4


if [ -d "$savePath/$modelData/icons" ]; then
    mv "$dataPath/icons" "$dataPath/icons.bak"
    cp -r "$savePath/$modelData/icons" "$dataPath"    
fi

if [ -d "$savePath/$modelData/color-schemes" ]; then
    mv "$dataPath/color-schemes" "$dataPath/color-schemes.bak"
    cp -r "$savePath/$modelData/color-schemes" "$dataPath"    
fi

if [ -d "$savePath/$modelData/plasma" ]; then
    mv "$dataPath/plasma" "$dataPath/plasma.bak"
    cp -r "$savePath/$modelData/plasma" "$dataPath"    
fi

if [ -d "$savePath/$modelData/wallpapers" ]; then
    mv "$dataPath/wallpapers" "$dataPath/wallpapers.bak"
    cp -r "$savePath/$modelData/wallpapers" "$dataPath"    
fi

if [ -d "$savePath/$modelData/kfontinst" ]; then
    mv "$dataPath/kfontinst" "$dataPath/kfontinst.bak"
    cp -r "$savePath/$modelData/kfontinst" "$dataPath"    
fi

#backups
mv "$configPath/plasma-org.kde.plasma.desktop-appletsrc" "$configPath/plasma-org.kde.plasma.desktop-appletsrc.bak"
mv "$configPath/plasmarc" "$configPath/plasmarc.bak"
mv "$configPath/plasmashellrc" "$configPath/plasmashellrc.bak"

# plasma config files
cp "$savePath/$modelData/plasma-org.kde.plasma.desktop-appletsrc" "$configPath/plasma-org.kde.plasma.desktop-appletsrc"
cp "$savePath/$modelData/plasmarc" "$configPath/plasmarc"
cp "$savePath/$modelData/plasmashellrc" "$configPath/plasmashellrc"
cp "$savePath/$modelData/kdeglobals" "$configPath/kdeglobals"
                                    
#kwin                                    
cp "$savePath/$modelData/kwinrc" "$configPath/kwinrc"
cp "$savePath/$modelData/kwinrulesrc" "$configPath/kwinrulesrc"

#dolphin config
cp "$savePath/$modelData/dolphinrc" "$configPath/dolphinrc"
#config session desktop
cp "$savePath/$modelData/ksmserverrc" "$configPath/ksmserverrc"
#config input devices
cp "$savePath/$modelData/kcminputrc" "$configPath/kcminputrc"
#shortcuts
cp "$savePath/$modelData/kglobalshortcutsrc" "$configPath/kglobalshortcutsrc"
#klipper config
cp "$savePath/$modelData/klipperrc" "$configPath/klipperrc"
#konsole config
cp "$savePath/$modelData/konsolerc" "$configPath/konsolerc"
#kscreenlocker config
cp "$savePath/$modelData/kscreenlockerrc" "$configPath/kscreenlockerrc"
#krunner config
cp "$savePath/$modelData/krunnerrc" "$configPath/krunnerrc"
#fonts dpi config
cp "$savePath/$modelData/kcmfonts" "$configPath/kcmfonts"

# echo "reached end"


qdbus org.kde.KWin /KWin reconfigure
# kquitapp6 plasmashell
# kstart6 plasmashell
kquitapp6 plasmashell
killall plasmashell && kstart5 plasmashell
# kstart plasmashell
systemctl --user restart plasma-plasmashell
# systemctl --user restart plasma-desktop
                                     
                            
