#!/bin/bash

# This script expects the SMS file to be given as the first argument.

SMSFILE='SMS.txt'
PHBOOK='phbook'

if [ -n "$1" ]; then
	echo "SMS file set to $1"
	SMSFILE=$1
fi

if [ -n "$2" ]; then
	echo "Phone book file set to $2"
	PHBOOK=$2
fi

if [ ! -f $SMSFILE ]; then
	echo "Could not find the SMS file $SMSFILE"
	if [ "$SMSFILE" == "SMS.txt" ]; then
		echo "If you have an SMS file with a different name from the default (SMS.txt), please supply the filename as an argument to the script"
		echo "That is, use"
		echo "  $0 <SMS File>"
	fi
	exit
fi

if [ ! -f $PHBOOK ]; then
	echo "Non existant phonebook file $PHBOOK"
	exit
fi

if [ ! -f gnokii.out ]; then
	echo "WARNING: gnokii.out already exists. Appending output to that file after a timestamp"
	echo "===================== " `date` " ===================" >> gnokii.out
fi

if [ ! -f smssend.err ]; then
	echo "WARNING: smssend.err already exists. Renaming it to backup smssend.err.bak and creating a new file!"
	/bin/mv smssend.err smssend.err.bak
fi
echo "=====================================================" > smssend.err
echo "This file consists of all messages that gnokii writes" >> smssend.err
echo "into stderr, the standard error stream. This file is " >> smssend.err
echo "expected to provide useful information for debugging " >> smssend.err
echo "=====================================================" >> smssend.err
echo " " >> smssend.err
echo "##################### " `date` " ####################" >> smssend.err

count=0

for i in `cat $PHBOOK`; do
	suc="1"
	while [ $suc -ne "0" ]; do
		echo "Sending SMS to $i"
		echo "------------------------- Sending SMS to $i -------------------" >> smssend.err;
		CMD="cat $SMSFILE | gnokii --sendsms $i 2>> smssend.err 1>> gnokii.out"
		echo "  Invoking command: $CMD"
		bash -c "$CMD"
		suc=$?
		if [ $suc -ne "0" ]; then
			echo "     [###ERROR###]: Looks like sending SMS to $i failed. "
			echo "     Please see smssend.err and gnokii.out for details.  "
			echo "     Will retry sending SMS to number $i after 1 second. "
			sleep 1
		else
			echo "     [  SUCCESS  ]: GNOKII returned Success in sending."
		fi
	done;
	count=$(($count + 1))
done;

echo " ============================================================================="
echo "| Finished requesting gnokii to send SMS to all phone numbers in $PHBOOK, or  |"
echo "| received a Ctrl+C before we could do that.                                  |"
echo "| Sent SMS to $count phone numbers.                                           | 
echo "| Please review smssend.err for any errors and gnokii.out for GNOKII's output |"
echo " ============================================================================="

