#!/usr/bin/perl -w
#
# dnsreversegen
#
# Generate reverse DNS zone includes from a forward DNS zone
#
#   Arguments (optional):
#     - a domain name
#     - a forward zone file - either file path or stdin
#
#   If the zone file has a $ORIGIN domain record it will override the domain provided as argument
#
#   Output: one file for each reverse zone quoted in the forward zone:
#     3.2.1.in-addr.arpa.txt
#   Where 3.2.1 are the first 3 bytes of the IP address in reverse order. The .txt files can be included in the reverse zone file.
#

use strict;
my $VERSION='dnsreversegen-20160215';

# Regular expressions
my $RE_ORIGIN = qr/^\$ORIGIN\s+\S+/;
my $RE_TTL = qr/^\$TTL\s+\d/;
my $RE_A = qr/^\S+.*\s+A\s+\S+/;
my $RE_GENERATE = qr/^\$GENERATE\s+\d{1,3}-\d{1,3}\s+\S+\$\s+\S+/;

# Global variables
my $revzonefile = '';
my $oldzonefile = '';
my $domain = join($ARGV[0], '.');
my $ttl = '';

shift(@ARGV);
# printf STDOUT "%s\n", $domain;
while (<>) {
        if (/$RE_GENERATE/) {
            my @inputline = split(/\s+/, $_);
	    my $range = $inputline[1];
	    my $host = $inputline[2];
	    my $recttl = $inputline[3];
	    if ($recttl !~ /^[0-9]/) {
		$recttl = $ttl;
	    }
	    my $ipaddr = $inputline[$#inputline];
	    my @splitip = split(/\./, $ipaddr);
	    my $revzone = join ('.', $splitip[2], $splitip[1], $splitip[0], "in-addr", "arpa");
	    $revzonefile = join('.', $revzone, "txt");
	    if ($revzonefile ne $oldzonefile) {
	        close ZONEFILE;
	        open ZONEFILE, '>>', $revzonefile;
		$revzonefile = $oldzonefile;
	    }
	    if ($domain eq "") {
	        # printf STDOUT "\$GENERATE\t\%s\t%s.%s.%s.\$\t%s\tIN PTR\t%s\n", $range, $splitip[0], $splitip[1], $splitip[2], $recttl, $host;
	        printf ZONEFILE "\$GENERATE\t\%s\t%s.%s.%s.\$\t%s\tIN PTR\t%s\n", $range, $splitip[0], $splitip[1], $splitip[2], $recttl, $host;
	    } else {
	        # printf STDOUT "\$GENERATE\t\%s\t%s.%s.%s.\$\t%s\tIN PTR\t%s.%s\n", $range, $splitip[0], $splitip[1], $splitip[2], $recttl, $host, $domain;
	        printf ZONEFILE "\$GENERATE\t\%s\t%s.%s.%s.\$\t%s\tIN PTR\t%s.%s\n", $range, $splitip[0], $splitip[1], $splitip[2], $recttl, $host, $domain;
	    }
	} elsif (/$RE_A/) {
	    my @inputline = split(/\s+/, $_);
	    my $host = $inputline[0];
	    my $recttl = $inputline[1];
	    if ($recttl !~ /^[0-9]/) {
		$recttl = $ttl;
	    }
	    my $ipaddr = $inputline[$#inputline];
	    my @splitip = split(/\./, $ipaddr);
	    my $revzone = join ('.', $splitip[2], $splitip[1], $splitip[0], "in-addr", "arpa");
	    $revzonefile = join('.', $revzone, "txt");
	    if ($revzonefile ne $oldzonefile) {
	        close ZONEFILE;
	        open ZONEFILE, '>>', $revzonefile;
		$revzonefile = $oldzonefile;
	    }
	    if ($domain eq "") {
	        # printf STDOUT "%s\t%s\tIN PTR\t%s\n", $ipaddr, $recttl, $host;
	        printf ZONEFILE "%s\t%s\tIN PTR\t%s\n", $ipaddr, $recttl, $host;
	    } else {
	        # printf STDOUT "%s\t%s\tIN PTR\t%s.%s\n", $ipaddr, $recttl, $host, $domain;
	        printf ZONEFILE "%s\t%s\tIN PTR\t%s.%s\n", $ipaddr, $recttl, $host, $domain;
	    }
	} elsif (/$RE_ORIGIN/) {
            my @inputline = split(/\s+/, $_);
            $domain = $inputline[1];
            # printf STDOUT "%s\n", $domain;
	} elsif (/$RE_TTL/) {
            my @inputline = split(/\s+/, $_);
	    $ttl = $inputline[1];
	    # printf STDOUT "%s\n", $ttl;
	}
}
close ZONEFILE;
exit(0);

