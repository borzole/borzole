#!/usr/bin/perl -w

# gmail.pl v1.0
#
# Checks a GMail account's atom feed (via SSL) and formats the 
# results nicely in a console window
#  * usage: gmail.pl <username> <password>
#
# Required Perl modules:
#  * LWP::UserAgent		(for fetching the atom feed)
#  * XML::Parser		(for parsing the atom feed)
#
# Optional Perl module:
#  * DateTime::Format::ISO8601	(for formatting the date in the feed)
#
# If you only want to check one account, you can put the username 
# and password below (between the quotes), and run without arguments.
$username = (defined($ARGV[0])) ? $ARGV[0] : "";
$password = (defined($ARGV[1])) ? $ARGV[1] : "";
#~ $username = (defined($ARGV[0])) ? $ARGV[0] : "mylogin";
#~ $password = (defined($ARGV[1])) ? $ARGV[1] : "mypassword";
########################################################################
if ($username eq "" || $password eq "") {
 die("Usage: gmail.pl <username> <password>
 (or you can edit the script to use one account automatically)\n");
}

require LWP::UserAgent;
require XML::Parser;

$has_iso8601 = eval { require DateTime::Format::ISO8601; } ? 1 : 0;
if ($has_iso8601) { 
 require DateTime::Format::ISO8601; 
}

# fetch atom feed
my $browser = LWP::UserAgent->new;
$browser->agent("gmail.pl/1.0");
$browser->credentials(
 'mail.google.com:443',
 'New mail feed',
 $username."\@gmail.com",
 $password
);
unless (defined($xmlresponse = $browser->get('https://mail.google.com/mail/feed/atom')))
 { die($xmlresponse->status_line, "\n"); }
$xml = $xmlresponse->content;

# &hellip; (aka "...") is not defined in XML so 
# it's not displayed correctly. We're going to 
# replace it in the XML before parsing.
$xml =~ s/\&amp;hellip;/.../g;

my $p = new XML::Parser(Style => 'Subs');
$p->setHandlers(Char => \&char);

# some formatting things to use
%c = (
 'b' => "\033[1;34m",
 'r' => "\033[1;31m",
 'y' => "\033[1;33m",
 'g' => "\033[1;32m",
 'w' => "\033[1;37m",
 'G' => "\033[1;30m",
 'x' => "\033[0m"
);
$line = &gray('-' x 79) . "\n";

$p->parse($xml);
print "\n";

# procedures to deal with various elements
sub char {
 my (undef, $str) = @_;
 $char = $str;
}
sub title_ {
 my ($el) = @_;
 my $parent = ($el->current_element);
 if ($parent eq "feed") { print "\n " . &titlecolors($char) };
 if ($parent eq "entry") { $subj = " Subject: " . &red($char) };
}
sub summary_ {
 $summ = &white($char);
}
sub issued_ {
 if ($has_iso8601) {
  my $dt = DateTime::Format::ISO8601->parse_datetime( $char );
  $dt->set_time_zone("local");
  $date = $dt->strftime("%B %d, %G @ %r");
 } else {
  my @date = split(/T/,$char);
  $date = $date[0]." ".$date[1];
 }
}
sub modified_ {
 &issued_;
}
sub name_ {
 $auth = $char;
}
sub email_ {
 $auth = green($auth) . " [" . blue($char) . "]";
}
sub entry_ {
 print " From: $auth :: $date\n" . 
	$subj . "\n\n " .
	$summ . "\n" .
	$line;
}
sub fullcount_ {
 $ct = $char;
 if ($ct==0) {
  print " :: No new messages.\n\n";
  exit;
 } elsif ($ct==1) {
  print " :: " . &red(1) . &white(" new message.\n") . $line;
 } elsif ($ct>1) {
  print " :: " . &red($ct) . &white(" new messages.\n") . $line;
 }
}
# procedures to colorize the output
sub titlecolors {
 my ($str) = @_;
 my @ch = split(//,$str);
 my @g = splice(@ch,0,5);
 return($c{'b'} . $g[0] .
		$c{'r'} . $g[1] .
		$c{'y'} . $g[2] .
		$c{'b'} . $g[3] .
		$c{'g'} . $g[4] .
		$c{'x'} . join("",@ch));
}
sub white { return($c{'w'} . $_[0] . $c{'x'}); }
sub green { return($c{'g'} . $_[0] . $c{'x'}); }
sub blue  { return($c{'b'} . $_[0] . $c{'x'}); }
sub red   { return($c{'r'} . $_[0] . $c{'x'}); }
sub gray  { return($c{'G'} . $_[0] . $c{'x'}); }
