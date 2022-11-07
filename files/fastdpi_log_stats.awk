#!/usr/bin/awk -f

# Script to get statistics from fastdpi's log file.
# -------------------------------------------------
#
# Script args:
# -v int_name=INTERFACE_NAME
# -v stat_type=[ drops | in_pkt_sec | out_pkt_sec | in_mbit_sec | out_mbit_sec | all ]
# -v log_file=/path/to/log_file

function usage() {
    print "Usage: fastdpi_log_stats.awk OPTIONS"
    print "OPTIONS"
    print " -v int_name=INTERFACE_NAME"
    print " -v stat_type=[ drops | in_pkt_sec | out_pkt_sec | in_mbit_sec | out_mbit_sec | all ]"
    print " -v log_file=/path/to/log_file"
}

BEGIN {
    if (!length(int_name) || !length(stat_type)) {
	usage()
	exit
    }
    int_regex = "IF " int_name
    if (!length(log_file)) {
	log_file = "/var/log/dpi/fastdpi_stat.log"
    }
    logfile = "tac " log_file

    while (logfile | getline) {
	a[i++] = $0
	if ($0 ~ int_regex) {
	    int_found = 1
	    break
	}
	if ($0 ~ /Cluster.*:/) {
	    i = 0
	    continue
	}
    }

    if (!int_found) {
	exit
    }
    if (stat_type == "all") {
	for (j=i-1; j >=0; j--) {
	    print a[j]
	}
	exit
    }
    for (j=i-1; j>=0; j--) {
	if (a[j] ~ /Actual/) {
	    stats = 1
	}

	if (stats) {
	    if (stat_type == "drops") {
		if (a[j] ~ /Drop/) {
		    print a[j-1]
		    exit
		}
	    } else if (stat_type == "in_pkt_sec") {
		if (a[j] ~ /Rcvd/) {
		    print a[j-1]
		    exit
		}
	    } else if (stat_type == "out_pkt_sec") {
		if (a[j] ~ /Send/) {
		    print a[j-1]
		    exit
		}
	    } else if (stat_type == "in_mbit_sec") {
		if (a[j] ~ /Rcvd/) {
		    print a[j]
		    exit
		}
	    } else if (stat_type == "out_mbit_sec") {
		if (a[j] ~ /Send/) {
		    print a[j]
		    exit
		}
	    }
	}
    }
    
}

# { a[i++] = $0 }

# $0 ~ int_regex {
#     int_found = 1
#     exit
# }


#
# Cluster #0 : IF eth1 (01:00.0):
#
#/Cluster.*:/ { i = 0; next }

# END {
#     if (!int_found) {
# 	 exit
#     }
#     if (stat_type == "all") {
# 	for (j=i-1; j >=0; j--) {
# 	    print a[j]
# 	}
# 	exit
#     }
#     for (j=i-1; j>=0; j--) {
# 	if (a[j] ~ /Actual/) {
# 	         stats = 1
# 	}

# 	if (stats) {
# 	    if (stat_type == "drops") {
# 		if (a[j] ~ /Drop/) {
# 		    print a[j-1]
# 		    exit
# 		}
# 	    } else if (stat_type == "in_pkt_sec") {
# 		if (a[j] ~ /Rcvd/) {
# 		    print a[j-1]
# 		    exit
# 		}
# 	    } else if (stat_type == "out_pkt_sec") {
# 		if (a[j] ~ /Send/) {
# 		    print a[j-1]
# 		    exit
# 		}
# 	    } else if (stat_type == "in_mbit_sec") {
# 		if (a[j] ~ /Rcvd/) {
# 		    print a[j]
# 		    exit
# 		}
# 	    } else if (stat_type == "out_mbit_sec") {
# 		if (a[j] ~ /Send/) {
# 		    print a[j]
# 		    exit
# 		}
# 	    }
# 	}
#     }
# }
