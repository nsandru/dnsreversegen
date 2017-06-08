# dnsreversegen

Generate reverse DNS records (PTR) from  a forward DNS zone

Usage:
<<<<<<< HEAD
  dnsreversegen.sh [domain [zone file]]
  
dnsreversegen reads the forward DNS zone either from a file or from standard input and generates reverse DNS zone files

=======
  dnsreversegen.pl [domain [zone file]]
  
dnsreversegen.pl reads the forward DNS zone either from a file or from standard input and generates reverse DNS records pointing
to the domain given in the command line. A file containing the PTR records is generated for each reverse zone. These files can be included in the reverse zone files.
>>>>>>> f8895783b09de108a3c76e887b0982b2d5348c13
