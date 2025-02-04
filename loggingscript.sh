#!/bin/bash
# to make a defult dir
defult_log_dir(){
    read -r -p "$1 [$2]: " input
    echo "${input:-$2}"  
}

# Now specified the log directory >_<

log_dir=$(defult_log_dir "Enter the log directory You Want" "/var/log")

if [ ! -d "$log_dir" ]; then
    echo "Error: Log directory does not exist. Creating directory..."
    log_dir=""
else
    echo "Log directory: $log_dir"
fi

# lets create a default days to Keep logs and Backups 

defult_keep_logs=$(defult_log_dir "How many days of logs do you want to keep?" "7")
echo "the number of days to keep logs is ${defult_keep_logs}"
defult_keep_backups=$(defult_log_dir "How many days of Backup do you want to keep?" "30")
echo "the number of days to Backup logs is ${defult_keep_backups}"

# lets make Archiveing process
# first create the archive path 
archive_path="${log_dir}/archive"

if [ -z "$archive_path" ]; then
    sudo mkdir "${archive_path}"
fi 
# then name the archive file by timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
archive_file="${archive_path}/logs_${timestamp}.tar.gz"

# find older logs and compose them

find "${log_dir}" -type f -mtime +$defult_keep_logs -print0 | tar -czvf "${archive_file}"  --null -T -

# log archiving prosess 
echo "creating $archive_file in the $(date)" >> "$archive_path/archive_log.txt"

# now archiving is complete
echo "Archive completed: ${archive_file}"

# Deelte older archives
find "${archive_path}" -type f -mtime +$defult_keep_backups -exec rm -f {} \;
echo "Deleting older archives completed"


# read -r -p "if you want to add cron job to the script write" choice
# if [[ $choice == "y" || $choice == "Y"]]; then
#     cronline="0 12 * * * /usr/local/bin/archive-log.sh"
#     (crontab -l 2>/dev/null ; echo "$cronline")  | crontab -
#     echo "Cron job added successfully"
# else
#     echo "Cron job not added"
# fi

