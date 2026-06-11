#!/usr/bin/env python3
# parse_auth.py
# Purpose  : Read auth.log and rank IPs by failed SSH attempts

import re 
from collections import Counter

# VARIABLES 
LOG_FILE = "/var/log/auth.log"
THRESHOLD = 5                    # Number of attempts to flag as suspicious

# READ THE LOG FILE
print("Failed SSH Attempts Analysis")
print(f"Reading : {LOG_FILE}")

failed_attempts = []

try:
    with open(LOG_FILE, "r") as f:
        for line in f:
            # Look for lines containing "Failed password"
            match = re.search(r"Failed password.*from (\d+\.\d+\.\d+\.\d+)", line)
            if match:
                failed_attempts.append(match.group(1)) #

except FileNotFoundError:
    print(f"[ERROR] File not found : {LOG_FILE}")
    exit(1) 

except PermissionError:
    print(f"[ERROR] Permission denied : run with sudo")
    exit(1)

#ANALYZE RESULTS 
if not failed_attempts:
    print("[OK] No failed attempts found in log file")
    exit(0)

ip_counts = Counter(failed_attempts)

print(f"Total failed attempts : {len(failed_attempts)}")
print(f"Unique IPs            : {len(ip_counts)}")
print("Top Suspicious IPs ")

for ip, count in ip_counts.most_common(10):
    if count >= THRESHOLD:
        status = "* SUSPICIOUS *"
    else:
        status = ""
    print(f"  {ip:<20} {count:>5} attempts   {status}")
