# dnsrevgersegen

Generate reverse DNS records (PTR) from  a forward DNS zone

Usage:
  dnsreversegen [domain [zone file]]
  
dnsreversegen reads the forward DNS zone either from a file or from standard input and generates reverse DNS records pointing to
the domain given in the command line.
