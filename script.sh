#!/bin/bash

# This script expects the SMS file to be given as the first argument.

SMSFILE='SMS.txt'
PHBOOK='phbook'

# Define colours
# ---- Copied from Varun Hiremath's .bashrc ---- 
# BASH COLORS (VARUN HIREMATH)

BLACK="\e[0;30m"
DARK_GRAY="\e[1;30m"
RED="\e[0;31m"
LIGHT_RED="\e[1;31m"
GREEN="\e[0;32m"
LIGHT_GREEN="\e[1;32m"
BROWN="\e[0;33m"
YELLOW="\e[1;33m"
BLUE="\e[0;34m"
LIGHT_BLUE="\e[1;34m"
PURPLE="\e[0;35m"
LIGHT_PURPLE="\e[1;35m"
CYAN="\e[0;36m"
LIGHT_CYAN="\e[1;36m"
LIGHT_GRAY="\e[0;37m"
WHITE="\e[1;37m"

NO_COLOUR="\e[0m"


if [ -n "$1" ]; then
	echo -e "${WHITE}SMS file set to $1 ${NO_COLOUR}"
	SMSFILE=$1
fi

if [ -n "$2" ]; then
	echo -e "${WHITE}Phone book file set to $2 ${NO_COLOUR}"
	PHBOOK=$2
fi

if [ ! -f $SMSFILE ]; then
	echo -e "${LIGHT_RED}Could not find the SMS file $SMSFILE ${NO_COLOUR}"
	if [ "$SMSFILE" == "SMS.txt" ]; then
		echo -e "If you have an SMS file with a different name from the default (SMS.txt), please supply the filename as an argument to the script"
		echo -e "That is, use"
		echo -e "  $0 <SMS File>"
	fi
	exit
fi

if [ ! -f $PHBOOK ]; then
	echo -e "${LIGHT_RED}Non existant phonebook file $PHBOOK ${NO_COLOUR}"
	exit
fi

if [ -f gnokii.out ]; then
	echo -e "${YELLOW}WARNING:${NO_COLOUR} gnokii.out already exists. Appending output to that file after a timestamp"
	echo -e "===================== " `date` " ===================" >> gnokii.out
fi

if [ -f smssend.err ]; then
	echo -e "${YELLOW}WARNING:${NO_COLOUR} smssend.err already exists. Renaming it to backup smssend.err.bak and creating a new file!"
	/bin/mv smssend.err smssend.err.bak
fi
echo -e "=====================================================" > smssend.err
echo -e "This file consists of all messages that gnokii writes" >> smssend.err
echo -e "into stderr, the standard error stream. This file is " >> smssend.err
echo -e "expected to provide useful information for debugging " >> smssend.err
echo -e "=====================================================" >> smssend.err
echo -e " " >> smssend.err
echo -e "##################### " `date` " ####################" >> smssend.err

count=0

for i in `cat $PHBOOK`; do
	suc="1"
	while [ $suc -ne "0" ]; do
		echo -e "${LIGHT_BLUE}Sending SMS to $i ${NO_COLOUR}"
		echo -e "------------------------- Sending SMS to $i -------------------" >> smssend.err;
		CMD="cat $SMSFILE | gnokii --sendsms $i 2>> smssend.err 1>> gnokii.out"
		echo -e "  Invoking command: $CMD"
		bash -c "$CMD"
		suc=$?
		if [ $suc -ne "0" ]; then
			echo -e "     ${LIGHT_RED}[###ERROR###]:${NO_COLOUR} Looks like sending SMS to $i failed. "
			echo -e "     Please see smssend.err and gnokii.out for details.  "
			echo -e "     Will retry sending SMS to number $i after 1 second. "
			sleep 1
		else
			echo -e "     ${LIGHT_GREEN}[  SUCCESS  ]:${NO_COLOUR} GNOKII returned Success in sending."
		fi
	done;
	count=$(($count + 1))
done;

echo -e " ============================================================================="
echo -e "| ${LIGHT_GREEN}Finished requesting gnokii to send SMS to all phone numbers in $PHBOOK, or${NO_COLOUR}   |"
echo -e "| ${LIGHT_GREEN}received a Ctrl+C before we could do that.${NO_COLOUR}                                  |"
echo -e "| ${LIGHT_CYAN}Sent SMS to ${LIGHT_RED}$count${LIGHT_CYAN} phone numbers.${NO_COLOUR}                                                |" 
echo -e "| Please review smssend.err for any errors and gnokii.out for GNOKII's output |"
echo -e " ============================================================================="

