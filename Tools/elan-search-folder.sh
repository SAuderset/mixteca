# copy ELAN files from Box to local folder for structured searches - ATTENTION: this can take very long!
# files copied: .eaf, .pfsx, .wav, .mp4
# navigate to Box directory
cd /Users/auderset/Box/SanMartinDuraznos-Mixtec-Collection/Bundles-Paquetes
# copy relevant files, use SMD-four digits-Capitallowercase etc. so other stuff doesn't get copied
# we also need to exclude the Metadata folder and the OLDStuff
# find . -name *.{eaf,pfsx,wav} -exec cp {} /Users/auderset/Documents/ELAN \; => the braces don't work for some reason
find . -type d \( -name Metadata -o -name OldVersions -o -name Templates \) -prune -o -name "SMD-*.eaf" -exec cp {} /Users/auderset/Documents/ELAN \;
find . -type d \( -name Metadata -o -name OldVersions -o -name Templates \) -prune -o -name "SMD-*.pfsx" -exec cp {} /Users/auderset/Documents/ELAN \;
# here we want to exclude the dictionary sound files
find . -type d \( -name Metadata -o -name OldVersions -o -name Templates \) -prune -o -name "SMD-*.wav" -exec cp {} /Users/auderset/Documents/ELAN \;
