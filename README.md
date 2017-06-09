# dnsreversegen

Generate reverse DNS records (PTR) from  a forward DNS zone

Usage:
  dnsreversegen.sh [domain [zone file]]
  
dnsreversegen.sh reads the forward DNS zone either from a file or from standard input and generates reverse DNS zone files. The reverse DNS zone files can be used directly by BIND. The SOA serial of the new zone file is incremented automatically.

Install the two files - dnsreversegen.sh and dnsreversegen.pl - in /usr/local/bin or another directory in $PATH.

dnsreversegen.sh uses the SOA records of existing reverse zones to generate the new zone files. If the zone does not exist the utility creates a SOA record with some default values which will have to be updated when the zone file is installed on the name server. It is recommended that a stub reverse zone be created with the desired SOA record values befire running the utility.
