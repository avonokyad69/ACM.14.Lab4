package Lab4;
use 5.010;
use strict;
use warnings;
use utf8;
use Encode;
use HTTP::Cookies;
use HTML::TableExtract;
use LWP;
use Data::Dumper;
use HTTP::Request::Common qw(POST);

my $tcp = HTML::TableExtract->new();


my $server = "109.87.186.59";
my $port = "8888";
my $script_path = "/cgi-bin/test3.cgi";
my $url = "http://".$server.":".$port.$script_path;
my $ua = new LWP::UserAgent;
my $cookies = HTTP::Cookies->new();
$ua->agent("Mozzila/8.0");
$cookies->set_cookie(0, 'db_type', 'mysql', '/', $server, $port, 0, 0, 86400, 0);
$ua->cookie_jar($cookies);

my $student = "Student name";

my @elements = ();

sub main()
{
	my $choice = 0;
	my @commands = (sub {say "good bye !"}, \&add, \&edit, \&del, \&show);
	my @menu = ("", "[1].add", "[2].edit", "[3].del", "[4].show", "[0].exit");

	do
	{
		print "-" x 5, "[MENU]", "-" x 5;
		
		say foreach(@menu);
		print "command: ";
		chomp($choice = <STDIN>); 
		if ($choice =~ /^\d+$/) 
		{
			if($choice >= 0 && $choice <= 4)
			{
				$commands[$choice]->();
			}
		}
		else
		{
			$choice = -1;
			say "error command";
		}
		
	}while($choice != 0);
	#############################################################################
}

sub add()
{	

	print "author: "; chomp(my $author = <STDIN>);
	print "title: "; chomp(my $title = <STDIN>);
	print "year: "; chomp(my $year = <STDIN>);
	Encode::from_to($author, 'cp866', 'utf8'); utf8::decode($author);
	Encode::from_to($title, 'cp866', 'utf8');	utf8::decode($title);
	Encode::from_to($year, 'cp866', 'utf8');	utf8::decode($year);
	my $req = 	POST $url,
				Content_Type => 'form-data',
				Content => [
							a_a 	=> 	$author,
							a_n 	=> 	$title,
							a_y 	=> 	$year,
							add 	=> 	"add",
							db_type =>	"mysql",
							student	=>	$student,
							];	
	my $res = $ua->request($req);

	if($res->is_success)
	{
		print "\t\tAdd ok.\n";
	} else {
		print "\t\tAdd fail.\n";
		my $html = $res->content;
		Encode::from_to($html, 'utf8', 'cp866');
		print $html;
	}
	return 0;
}

sub edit()
{
	print "edit elem by id == ";
	chomp(my $index = <STDIN>);
	
	
	print "author: "; chomp(my $author = <STDIN>);
	print "title: "; chomp(my $title = <STDIN>);
	print "year: "; chomp(my $year = <STDIN>);
	Encode::from_to($author, 'cp866', 'utf8'); utf8::decode($author);
	Encode::from_to($title, 'cp866', 'utf8');	utf8::decode($title);
	Encode::from_to($year, 'cp866', 'utf8');	utf8::decode($year);
			
	my $req = 	POST $url,
				Content_Type => 'form-data',
				Content => [
							id		=>	$index,
							e_a 	=> 	$author,
							e_n 	=> 	$title,
							e_y 	=> 	$year,
							set 	=> 	"set",
							db_type =>	"mysql",
							student	=>	$student,
							];
	
	my $res = $ua->request($req);

	if($res->is_success)
	{
		print "\t\tEdit Ok.\n";
	
	} else {
		print "\t\tEdit fail.\n";
		
		my $html = $res->content;
		
		Encode::from_to($html, 'utf8', 'cp866');
	
		print $html;
	}
	return 0;
}


sub del()
{
	print "delete elem by id == ";
	chomp(my $index = <STDIN>);
	if (!($index =~ /^\d+$/))
	{
		my $str = "ID должен быть числом !\n";
		utf8::encode($str); Encode::from_to($str, 'utf8', 'cp866');
		print $str;
		return 0;
	}
	
	my $req = 	POST $url,
				Content_Type => 'form-data',
				Content => [
							id		=>	$index,
							yes 	=> 	"yes",
							db_type =>	"mysql",
							student	=>	$student,
							];

	my $res = $ua->request($req);
	if($res->is_success)
	{
		print "\t\tDelete Ok.\n";
	} else {
		print "\t\tDelete fail.\n";
		
		my $html = $res->content;

		Encode::from_to($html, 'utf8', 'cp866');
		print $html;
	}	
	return 0;
}


sub show()
{	

	my $params = "?student=$student&db_type=mysql";
	my $req = new HTTP::Request( POST => $url.$params );
	$req->content_type("'text/html; charset='utf8'");
	
	my $res = $ua->request($req);
	if($res->is_success)
	{
		my $html = $res->content;
		Encode::from_to($html, 'utf8', 'cp866');
		#$tcp->parse();
		my $te = HTML::TableExtract->new( );
		$te->parse($html);
		
		my @tables = $te->tables;
		my $table = $tables[1];
		foreach my $row ( $table->rows($table) ) {
			foreach my $cell (@$row)
			{
				if(defined $cell){ print $cell."\t";}
			}
			say "";
		}
		
	
	} else {
		print "\t\tPrint fail.\n";
		my $html = $res->content;
		Encode::from_to($html, 'utf8', 'cp866');
		print $html;
	}	
	return 0;
}




return 1;