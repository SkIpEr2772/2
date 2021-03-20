#!/bin/bash

LOG_LOC="/var/log/mybackup.log"
data=$(date +%u%H)

function check_dir_loc {
	if [ ! -s "/backup_dirs.conf" ]
	then
		echo "Please create backups_dir.conf"
		exit 1
	fi
}

function check_backup_loc {
	if [ ! -s "/backup_loc.conf" ]
	then
		echo "Create backup_loc.conf"
		exit 1
	fi
}

function check_schedule {
	if [ ! -s "/etc/cron.hourly/make_backup" ]
	then
		sudo cp make_backup.sh /etc/cron.hourly/make_backup
		echo "The backup schedule has been set to run hourly"
		echo "The exact run time is in the /etc/crontab file"
		exit 1
	fi
}

function perform_backup {
	backup_path=$(cat /backup_loc.conf)

	echo "Starting backup..." > $LOG_LOC

	while read dir_path
	do
		dir_name=$(basename $dir_path)
		a=$(find $dir_path -name "*.conf")
		b=$(find $dir_path -name "*[a-z].config")
		filenameb=$backup_path$dir_name$data.tar.gz
		filenamea=$backup_path$dir_name$data"-2".tar.gz
		tar -zcf $filenameb $b 2>> $LOG_LOC
		tar -zcf $filenamea $a 2>> $LOG_LOC

		chown max:max $filenamea
		chown max:max $filenameb

		echo "Backing up of $dir_name completed." >> $LOG_LOC
	done < /backup_dirs.conf

	echo "Backup complete at:" >> $LOG_LOC
	date >> $LOG_LOC
}

check_dir_loc
check_backup_loc
check_schedule
perform_backup
