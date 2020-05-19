# dnsreversegen

Generate reverse DNS records (PTR) from  a forward DNS zone

Usage:
  dnsreversegen.sh domain [zone file]
  
dnsreversegen.sh reads the forward DNS zone either from a file or from standard input and generates reverse DNS zone files. The reverse DNS zone files can be used directly by BIND. The SOA serial of the new zone file is incremented automatically.

Install the two files - dnsreversegen.sh and dnsreversegen.pl - in /usr/local/bin or another directory in $PATH.

dnsreversegen.sh uses the SOA records of existing reverse zones to generate the new zone files. If the zone does not exist the utility use3s the SOA record of the forward zone.

The reverse zone files are created in /tmp/dnsreversegen. Each run of the dnsreversegen.sh script clears the content of /tmp/dnsreversegen.
