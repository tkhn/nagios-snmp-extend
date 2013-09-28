#!/usr/bin/perl
# nagios: +epn
#
# Pure Perl script for getting SNMP extend output.
# Oleksii Tykhonov, Supportex.net, 2010.
# http://supportex.net/


use POSIX;
use strict;
use Getopt::Long;
use lib  "/usr/lib64/nagios/plugins" ;
use utils qw(%ERRORS &print_revision &support &usage );
use Net::SNMP v5.1.0 qw(snmp_type_ntop DEBUG_ALL);
sub print_usage {print '';};

# SNMP stuff:
my $USER     = "yoursnmpuser";
my $PASS     = "strongspassword";
my $AUTHPROT = "yourAuthProt";
my $PRIVPROT = "yourProvProt";

# Host related
my $host_address;
my $snmp_port;
my $command;

GetOptions("port=s", \$snmp_port, "c=s", \$command, "H=s", \$host_address);
unless ( defined($host_address) && defined($command) )
{
print_usage();
}

if ( !defined($snmp_port) ) {$snmp_port = "161"; }

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}='';
$ENV{'ENV'}='';

my ($s, $error) = Net::SNMP->session(
                  -hostname => $host_address,
                  -version => "3",
                  -username     => $USER,
                  -authprotocol => $AUTHPROT,
                  -authpassword => $PASS,
                  -privpassword => $PASS,
                  -privprotocol => $PRIVPROT,
                  -port => $snmp_port );
if (!defined($s)) {
      printf("ERROR: %s.\n",  $error);
      exit 1;
}


my $oid = ".1.3.6.1.4.1.8072.1.3.2.3.1.2.";
$oid = $oid . length($command);

my @array = split(//, $command);
my $item;
my $ret = 3;
foreach $item (@array) {  $oid = $oid . "." .  ord($item); }

my $response = $s->get_request(
      -varbindlist => [$oid]
   );
$s->close;

my $output = $response->{$oid};
if (  $output =~ /OK/ ) { $ret = 0; }
if (  $output =~ /WARNING/ ) { $ret = 1; }
if (  $output =~ /CRITICAL/ ) { $ret = 2; }


print $output, "\n";
exit($ret);
