#!/usr/bin/env perl

# Returns JSON of available DPI interfaces.

use strict;
use warnings;

use JSON;
use Data::Dumper;

my $FDPI_CLI = "/sbin/fdpi_cli";


my @ifaces = ();

# Get interfaces from command
my @fdpi_cli_dev_info = `$FDPI_CLI dev info`;
for my $line (@fdpi_cli_dev_info) {

    # Device '01-00.0': ****************
    if ($line =~ /^Device '(.*?)':/) {
	push @ifaces, $1;
    }
    
}

# Get bridge config
my %ifaces_in = ();
my %ifaces_out = ();
my $res_config_in_dev = `fdpi_cli dpi config get in_dev`;
# Command returns:
# -| in_dev=01-00.0:01-00.2:02-00.0:02-00.2

if ($res_config_in_dev =~ /^in_dev=(.*)/) {
    %ifaces_in = map { $_ => 1 } split(/:/, $1);
}

my $res_config_out_dev = `fdpi_cli dpi config get out_dev`;
# Command returns:
# -| out_dev=01-00.1:01-00.3:02-00.1:02-00.3

if ($res_config_out_dev =~ /^out_dev=(.*)/) {
    %ifaces_out = map { $_ => 1 } split(/:/, $1);
}

#print Dumper \%ifaces_in, \%ifaces_out, \@ifaces;

# my $data = {
#     ifaces => \@ifaces,
#     bridge => {
# 	in => \@ifaces_in,
# 	out => \@ifaces_out
#     }
# };

my $data = [];
foreach my $int (@ifaces) {
    my $d = {};
    $d->{name} = $int;
    if (exists($ifaces_in{$int})) {
	$d->{bridge} = "in";
    } elsif (exists($ifaces_out{$int})) {
	$d->{bridge} = "out";
    } else {
	$d->{bridge} = "unk";
    }
    push @$data, $d;
}

print JSON->new->pretty->encode( $data );
    
    
