#!/usr/bin/awk -f

BEGIN {

    ##
    ## fdpi_cli dev info | grep Device
    ## Device '19-00.0': ****************
    ##
    while ("fdpi_cli dev info" | getline) {
	if (match($0, /^Device[[:space:]]+'([^']*)'/, matches)) {
	    interfaces[matches[1]] = 1
	}
    }

    FS = "[=:]"
    ##
    ## fdpi_cli dpi config get in_dev
    ## in_dev=19-00.0:1b-00.0:67-00.0:69-00.0
    ##
    "fdpi_cli dpi config get in_dev" | getline
    for (i = 2; i <= NF; i++) {
	in_devs[$i] = 1
    }

    ## 
    ## fdpi_cli dpi config get out_dev
    ## out_dev=19-00.1:1b-00.1:67-00.1:69-00.1
    ##
    "fdpi_cli dpi config get out_dev" | getline
    for (i = 2; i <= NF; i++) {
	out_devs[$i] = 1
    }

    ## Print JSON
    print "[ "
    first = 1
    for (el in interfaces) {
	if (!first) {
	    print ","
	}
	first = 0
	print "\t{"
	printf "\t\t\"name\": \"" el "\",\n"
	printf "\t\t\"direction\": "
	if (el in in_devs) {
	    print "\"in\""
	} else if (el in out_devs) {
	    print "\"out\""
	} else {
	    print "\"unk\""
	}
	printf "\t}"
    }
    print "\n]"
    ## End JSON
}


