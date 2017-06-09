#!/bin/sh
#
# dnsreversegen.sh
#
# Generate reverse DNS zone from a forward DNS zone
#
#   Arguments (optional):
#     - a domain name
#     - a forward zone file - either file path or stdin
#
#   If the zone file has a $ORIGIN domain record it will override the domain provided as argument
#
#   Output: one zone file for each reverse zone quoted in the forward zone:
#     3.2.1.in-addr.arpa.txt
#   Where 3.2.1 are the first 3 bytes of the IP address in reverse order.
#
# dnsreversgen-20170609
#

export PATH=/bin:/usr/bin:$HOME/bin

test -d /tmp/dnsreversegen && rm -rf /tmp/dnsreversegen
mkdir -p /tmp/dnsreversegen/.tmp
cd /tmp/dnsreversegen/.tmp

# Generate the include files
while [ "$1" ] ; do
  DOMAIN=$1
  ZONEFILE=$2
  shift
  shift
  dnsreversegen.pl $DOMAIN $ZONEFILE
done

# Merge the include files
for TEXTFILE in *.txt ; do
  INCFILE=`echo $TEXTFILE | sed 's/\.txt//'`.inc
  test -f $TEXTFILE || continue
  sort -k 1 -t . -n $TEXTFILE > $INCFILE
done

# Add SOA records to the reverse zone.
for REVZONE in `ls *.inc | sed 's/\.inc//'` ; do
  REVFILE="../$REVZONE"
  REVFILETMP=`basename $REVFILE`
  test "$REVFILE" || continue
  SOAREC="`dig +short soa $REVZONE`"
  # Non-existant zone, put some default values in the SOA record
  test x"$SOAREC" = x && {
    SOAREC=`echo 'localhost. postmaster.localhost. 0 7200 1800 86400 300'`
  }
  test -f $REVFILE || {
    echo $SOAREC > $REVFILE
  }
  SOASERIAL=`echo $SOAREC | awk '{print $3}'`
  test $SOASERIAL -gt `date -d now '+%s'` && {
    SOANEXT=`date -d now '+%Y%m%d00'`
  } || {
    SOANEXT=`date -d now '+%s'`
  }
  test $SOASERIAL -ge $SOANEXT && {
    SOANEXT=`expr $SOASERIAL + 1`
  }
  (echo $SOAREC | awk '{printf "@\tIN SOA\t%s %s (%s %s %s %s %s)\n", $1,$2,$3,$4,$5,$6,$7}'
  dig +short ns $REVZONE | awk '{printf "\tIN NS\t%s\n",$1}'
  cat $REVZONE.inc
) > $REVFILETMP
  OLDSUM=`md5sum $REVFILE | awk '{print $1}'`
  NEWSUM=`md5sum $REVFILETMP | awk '{print $1}'`
  test $OLDSUM = $NEWSUM && continue
  NEWSERIAL=$SOANEXT
  test $NEWSERIAL -le $SOANEXT && {
    (echo $SOAREC | awk '{printf "@\tIN SOA\t%s %s ('"$NEWSERIAL"' %s %s %s %s)\n", $1,$2,$4,$5,$6,$7}'
    dig +short ns $REVZONE | awk '{printf "\tIN NS\t%s\n",$1}'
    cat $REVZONE.inc
) > $REVFILE
  }
done

exit 0
