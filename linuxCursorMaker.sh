#!/bin/bash

echo "/**********************************************************\\"
echo "|****~~Welcome to Khayeel's Linux Cursor Icon Maker~~******|"
echo "|This script utilizes xcursorgen and imagemagick packages.*|"
echo "|Ensure those are installed first**************************|"
echo "|*********************for the script to function correctly.|"
echo "|To check if you have them, type them in your**************|"
echo "|Command Line Interface to see if they exist in your System|"
echo "|or need installing first.*********************************|"
echo "|Place this script file in the same location as your*******|"
echo "|reference cursor images(square resolution)****************|"
echo "|It will also place the output cursor icon in the same dir*|"
echo "\\***********************************************************/"

# Needs a coordinate viewer of the image file before X, Y Hotspot.

echo "You will be asked to specify what singular file type of image you will use (PNG or SVG, etc.)."
echo "This will also check if you have 'xorg-xcursorgen' and 'imagemagick' installed."
echo "If those happen to be no longer available, you can customize the commands that utilizes them."
read -p $'And also the symlinks you want to create to the created cursor.\nContinue? (Y/n):' goMake

if [[ "$goMake" == "Y" || "$goMake" == "y" ]]; then
# Code to check if 'xcursorgen' and 'magick' are installed.
    PACKAGE="xorg-xcursorgen"
    PACKAGE2="imagemagick"
    customCommand1="-1"
    customCommand2="-1"

    if command -v dpkg >/dev/null 2>&1; then
        # Debian, Ubuntu, Mint
        dpkg -s "$PACKAGE" >/dev/null 2>&1
    elif command -v rpm >/dev/null 2>&1; then
        # Red Hat, CentOS, Fedora, RHEL
        rpm -q "$PACKAGE" >/dev/null 2>&1
    elif command -v alpine >/dev/null 2>&1 || command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        apk info -e "$PACKAGE" >/dev/null 2>&1
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        pacman -Qi "$PACKAGE" >/dev/null 2>&1
    else
        echo "Error: Unsupported package manager." >&2
        exit 1
    fi

    # Check the exit status of the test
    if [ $? -eq 0 ]; then
        echo "$PACKAGE is installed."
    else
        echo "$PACKAGE is NOT installed."
        read -p $'Type 0 if you want to install it first, or type 1 if you want to make a custom command\nusing another package for cursor file generation. (0 or 1):' customCommand1
    fi

    if command -v dpkg >/dev/null 2>&1; then
        # Debian, Ubuntu, Mint
        dpkg -s "$PACKAGE2" >/dev/null 2>&1
    elif command -v rpm >/dev/null 2>&1; then
        # Red Hat, CentOS, Fedora, RHEL
        rpm -q "$PACKAGE2" >/dev/null 2>&1
    elif command -v alpine >/dev/null 2>&1 || command -v apk >/dev/null 2>&1; then
        # Alpine Linux
        apk info -e "$PACKAGE2" >/dev/null 2>&1
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        pacman -Qi "$PACKAGE2" >/dev/null 2>&1
    else
        echo "Error: Unsupported package manager." >&2
        exit 1
    fi

    # Check the exit status of the test
    if [ $? -eq 0 ]; then
        echo "$PACKAGE2 is installed."
    else
        echo "$PACKAGE2 is NOT installed."
        read -p $'Type 0 if you want to install it first, or 1 if you want to make a custom command\nusing another package for resizing images. (0 or 1):' customCommand2
    fi
    if [[ "$customCommand1" == "0" ]] || [[ "$customCommand2" == "0" ]]; then
        echo "Install necessary packages first before running the program."
        return 0
    fi
    read -p $'Image File Type or Extension Name (<filename>.<fExtName>, test.[png]<-this)\nStored in fileExt variable: ' fileExt
    read -p "Static(0) or Animated(1) Cursor (Input 0 or 1): " statAnim
    read -p "Will you add symlinks to this cursor file? (Input 0 for no & 1 for yes): " moreSyms
    read -p $'Name your reference image file after the cursor state you want to make the cursor icon for. (e.g., \'arrow\')\nStored in filename variable: ' filename
    read -p "Number of Sizing Categories, stored in sizeCats variable: " sizeCats
    sizeCats=$((${sizeCats#-}))

    # Initialize arrays
    sizeCatArray=()
    sizeCatsX=()
    sizeCatsY=()

    for ((i=1; i<=$sizeCats; i++)); do
        read -p $'Input Height/Length Size Category #$i (one side\'s length is enough, e.g. 16)\nStored in sizeCatCurrCat variable that gets added to an array variable named sizeCatArray: ' sizeCatCurrCat
        sizeCatCurrCat=$((${sizeCatCurrCat#-})) #Absolute Value -> turn any number even negatives into Positive Integer. '|x|'
        sizeCatArray+=($sizeCatCurrCat)

        read -p $'Input X-Axis of Cursor Hotspot (pixel location of the \'click action\')\nStored in sizeCatCurrX variable that gets added to an array variable named sizeCatsX: ' sizeCatCurrX
        sizeCatCurrX=$((${sizeCatCurrX#-}))
        sizeCatsX+=($sizeCatCurrX)

        read -p $'Input Y-Axis of Cursor Hotspot (pixel location of the \'click action\')\nStored in sizeCatCurrY variable that gets added to an array variable named sizeCatsY: ' sizeCatCurrY
        sizeCatCurrY=$((${sizeCatCurrY#-}))
        sizeCatsY+=($sizeCatCurrY)
    done

    if [[ "$statAnim" == "0" ]]; then
        read -p $'Enter your Cursor\'s Base File Name without the Extension name.\nStored as x11curfilename variable: ' x11curfilename

        if [[ "$customCommand1" == "1" ]]; then
            echo $'Note: All \'for\' loops in the script uses \'i\' as the looping counter.\nAnd if you can even concoct this formula then might as well edit the script directly yourself...'
            read -p $'Hope you took note of those variable names, since this is the part where you make your custom command,\nwhich will be saved into a variable named ugcCommand1.\nThat is responsible for turning the .cursor file into the actual x11 cursor format file:\n' ugcCommand1
        fi

        if [[ "$customCommand2" == "1" ]]; then
            echo $'Note: All \'for\' loops in the script uses \'i\' as the looping counter.\nAnd if you can even concoct this formula then might as well edit the script directly yourself...'
            read -p $'Hope you took note of those variable names, since this is the part you make your custom command,\nwhich will be saved into a variable named ugcCommand2.\nThat is responsible for the image file\'s resolution re-sizing:\n' ugcCommand2
        fi


        for i in "${!sizeCatArray[@]}"; do
            if [[ "$customCommand2" == "1" ]]; then
                eval $ugcCommand2
            else
                magick "${filename}.$fileExt" -resize "${sizeCatArray[i]}"x"${sizeCatArray[i]}"! "${filename}${sizeCatArray[i]}.${fileExt}"
            fi
            echo "${sizeCatArray[i]} ${sizeCatsX[i]} ${sizeCatsY[i]} $filename${sizeCatArray[i]}.${fileExt}" >> "${filename}.cursor"
        done
        if [[ "$customCommand1" == "1" ]]; then
            eval $ugcCommand1
        else
            cursorMake="xcursorgen ${filename}.cursor ${x11curfilename}"
            eval $cursorMake
        fi

        while [[ "$moreSyms" == "1" ]]; do
            read -p "Input the symlink name to create: " symTarget
            if ln -sf "${x11curfilename}" "${symTarget}"; then
                echo "Created symlink of ${symTarget} pointing to ${x11curfilename}."
            fi
            read -p "Add more symlinks? (0 for no || 1 for yes): " moreSyms
            if [[ "$moreSyms" == "0" ]]; then
                break
            fi
        done
    else
        read -p $'Input delay time in ms between each frame for the Animated Cursor,\nstored in animDelay variable: ' animDelay
        animDelay=$((${animDelay#-}))

        read -p $'Input how many frames or images to use in the Animated Cursor,\nstored in frameCount variable: ' frameCount
        frameCount=$((${frameCount#-}))

        if ((frameCount < 1)); then
            echo "Error: Number of frames must be at least 1."
            exit 1
        fi

        if [[ "$customCommand1" == "1" ]]; then
            echo $'Note: All \'for\' loops in the script uses \'i\' as the looping counter.\nAnd if you can even concoct this formula then might as well edit the script directly yourself...'
            read -p $'Hope you took note of those variable names, since this is the part where you make your custom command,\nwhich will be saved into a variable named ugcCommand1.\nThat is responsible for turning the .cursor file into the actual x11 cursor format file:\n' ugcCommand1
        fi

        if [[ "$customCommand2" == "1" ]]; then
            echo $'Note: All \'for\' loops in the script uses \'i\' as the looping counter.\nAnd if you can even concoct this formula then might as well edit the script directly yourself...'
            read -p $'Hope you took note of those variable names, since this is the part you make your custom command,\nwhich will be saved into a variable named ugcCommand2.\nThat is responsible for the image file\'s resolution re-sizing:\n' ugcCommand2
        fi

        for i in "${!sizeCatArray[@]}"; do
            for ((x=1; x<=frameCount; x++)); do
                if [[ -f "${filename}${x}.${fileExt}" ]]; then
                    if [[ "$customCommand2" == "1" ]]; then
                        eval $customCommand2
                    else
                        magick "${filename}${x}.${fileExt}" -resize "${sizeCatArray[i]}"x"${sizeCatArray[i]}"! "${filename}${x}${sizeCatArray[i]}.${fileExt}"
                    fi
                    echo "${sizeCatArray[i]} ${sizeCatsX[i]} ${sizeCatsY[i]} $filename${x}${sizeCatArray[i]}.${fileExt} ${animDelay}" >> "${filename}.cursor"
                fi
            done
        done
        read -p $'Enter your Cursor\'s Base File Name without the Extension name.\nStored in x11curfilename variable: ' x11curfilename

        if [[ "$customCommand1" == "1" ]]; then
            eval $ugcCommand1
        else
            cursorMake="xcursorgen ${filename}.cursor ${x11curfilename}"
            eval $cursorMake
        fi

        while [[ "$moreSyms" == "1" ]]; do
            read -p "Input the symlink name to create: " symTarget
            if command ln -sf "${x11curfilename}" "${symTarget}"; then
                echo "Created symlink of ${symTarget} pointing to ${x11curfilename}."
            fi
            read -p "Add more symlinks? (0 for no || 1 for yes): " moreSyms
            if [[ "$moreSyms" == "0" ]]; then
                break
            fi
        done
    fi
fi
