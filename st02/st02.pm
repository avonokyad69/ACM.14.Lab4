package ST02;
use strict;
use LWP::UserAgent;
use LWP::Simple;
use HTTP::Request;

my @MODULES = (\&Add, \&Edit, \&Delete, \&MyPrint, \&MySave, \&MyLoad, \&SendToDB);
my @NAMES = ('Add', 'Edit', 'Delete', 'Print', 'Save', 'Load', 'Send to DB', 'Exit');
my @Params = ('Name', 'Surname', 'Age', 'SS');
my @Elements = ();
my $file = 'st02\Files\Data';

sub st02
{
	while(1)
	{
		my $ch = menu();
		if(defined $MODULES[$ch])
		{
			$MODULES[$ch]->();
		}
		else
		{
			return 1;
		}
	}
}

sub SendToDB{
	my $url = 'http://localhost/cgi-bin/lab3.cgi';
	my $ua = new LWP::UserAgent;
	my $req;
	$url.="?ElN=&student=2&wtd=3&";
	foreach my $el(@Elements){
		my $raq = $url;
		foreach my $eln(@Params){
			$raq.="$eln=$el->{$eln}&";
		}
		my $qwe = new HTTP::Request(GET =>$raq);
		$ua->request($qwe);
	}
}

sub menu
{
	my $i = 0;
	print "\n------------------------------\n";
	foreach my $s(@NAMES)
	{
		$i++;
		print "$i. $s\n";
	}
	print "------------------------------\n";
	my $ch = <STDIN>;
	return ($ch-1);
}

sub Add
{
	my $r2h = {};
	foreach my $param (@Params)
	{
		print "\n$param: ";
		chomp(my $str = <STDIN>);
		$r2h->{$param} = $str;
	}
	@Elements = (@Elements, $r2h);
}
 
sub Edit
{
	print 'N: ';
	my $n = <STDIN>;
	my $r2h = {};
	foreach my $param (@Params)
	{
		print "\n$param: ";
		chomp(my $str = <STDIN>);
		$r2h->{$param} = $str;
	}
	@Elements[$n-1] = $r2h;
}

sub Delete
{
	print 'N: ';
	my $n = <STDIN>;
	defined(@Elements[$n-1]) || return 1;
	splice(@Elements, $n-1, 1);
}

sub MyPrint
{
	foreach my $element (@Elements)
	{
		print "\n";
		foreach my $param (@Params)
		{
			print "\n$param: $element->{$param}";
		}
	}
}

sub MySave
{
	my %f; dbmopen(%f, $file, 0666) || return 1;
	%f = ();
	my $i = 0;
	foreach my $element (@Elements)
	{
		foreach my $param (@Params)
		{
			$f{$i}.= "$param<==>$element->{$param}<===>";
		}
		$i++;
	}
	dbmclose(%f);
}

sub MyLoad
{
	my %f; dbmopen(%f, $file, 0) || return 1;
	@Elements = ();
	foreach my $element(values %f)
	{
		my $r2h = {};
		my @list = split(/<===>/, $element);
		foreach my $param(@list)
		{
			my ($key, $val) = split(/<==>/, $param);
			$r2h->{$key}=$val;
			#print "\n $key    $val";
		}
		@Elements=(@Elements,$r2h);
	}
	dbmclose(%f);
}

return 1;