#!/bin/bash

white='\x1B[0;97m';
blue='\x1B[0;94m';
green='\x1B[0;32m';
reset='\x1B[0m';

# selectively add changed hunks
git add -p $*;

# selectively add/delete new files
IFS='
';
for line in $(git ls-files -o --exclude-standard); 
do
    if file --mime-encoding -- $line | grep -q binary
    then
        # binary file, dont show the content
        echo "${green}File has binary content${reset}";
    else
        # print the file name
        echo "${white}${line}${reset}";
        # print the file content
        echo "${green}$(cat ${line})${reset}";
    fi
    # print the file name
    echo "${white}${line}${reset}\n";
    # print the question
    echo "${blue}Stage this file [y,n,q,d]?${reset}";
    # read the user response into `fileaction`
    read fileaction;

    if [ $fileaction = "y" ]
    then
        git add "${line}";
    elif [ $fileaction = "q" ]
    then
        # quit
        break;
    elif [ $fileaction = "d" ]
    then
        # remove the file
        rm "${line}";
    fi
done;
echo "---------------";
git status;
