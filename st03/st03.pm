#!C:\Perl64\bin\perl.exe
package ST03;
use 5.010;
use strict;
use warnings;
use utf8;
use Encode;
use HTTP::Cookies;
use LWP;
use Data::Dumper;
use HTTP::Request::Common qw(POST);

my $server = "109.87.186.59";
my $port = "8888";
my $script_path = "/cgi-bin/lab3/test3.cgi";
my $url = "http://".$server.":".$port.$script_path;
my $ua = new LWP::UserAgent;
my $cookies = HTTP::Cookies->new();
$ua->agent("Mozzila/8.0");
$cookies->set_cookie(0, 'db_type', 'mysql', '/', $server, $port, 0, 0, 86400, 0);
$ua->cookie_jar($cookies);

my $st = "Student name";
my @book = ( 
	"AUTHOR",
	"TITLE",
	"YEAR",
	);
my @books = ();

sub st03()
{
	my $choice = 0;
	my @commands = (sub {say "good bye !"}, \&add, \&edit, \&del, \&show, \&send_to_server);
	my @menu = ("", "[1].add", "[2].edit", "[3].del", "[4].show", "[5].send to server", "[0].exit");

	do
	{
		print "-" x 5, "[MENU]", "-" x 5;
		say foreach(@menu);
		print "command: ";
		chomp($choice = <STDIN>); 
		if ($choice =~ /^\d+$/)
		{
			if($choice >= 0 && $choice <= 5)
			{
				load();
				$commands[$choice]->();
				save();
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
	push @books, 
	{
		$book[0] => $author,
		$book[1] => $title,
		$book[2] => $year
	};
	return 0;
}
sub edit()
{
	print "edit elem by index == ";
	chomp(my $index = <STDIN>);
	if ($index =~ /^\d+$/) 
	{
		if($index >= 0 && $index <= $#books)
		{
			print "author: "; chomp(my $author = <STDIN>);
			print "title: "; chomp(my $title = <STDIN>);
			print "year: "; chomp(my $year = <STDIN>);
			
			$books[$index]->{$book[0]} = $author;
			$books[$index]->{$book[1]} = $title;
			$books[$index]->{$book[2]} = $year;
		}
	}
	return 0;
}

sub del()
{
	print "delete elem by index == ";
	chomp(my $index = <STDIN>);
	if ($index =~ /^\d+$/) 
	{
		if($index >= 0 && $index <= $#books)
		{
			splice @books, $index, 1;
		}
	}
	return 0;
}

sub show()
{
	print "\t$_" foreach(@book);
	say "";
	my $i = 0;

	for my $href ( @books ) 
	{
		say "[".$i++."]\t$href->{$book[0]}\t$href->{$book[1]}\t$href->{$book[2]}";		
	}	
	return 0;
}

sub save()
{
	dbmopen(my %recs, "dbmfile", 0644) || die "Cannot open DBM dbmfile: $!";
	%recs = ();
	my $i = 0;	
	for my $elem ( @books )
	{
		$recs {$i++} = join("\t", 
			$elem->{$book[0]},
			$elem->{$book[1]},
			$elem->{$book[2]}
			);
	}
	# Закрыли
	dbmclose(%recs);
	return 0;
}

sub load()
{
	dbmopen(my %recs, "dbmfile", 0644) || die "Cannot open DBM dbmfile: $!";
	splice @books, 0, $#books + 1; 
	while ((my $key, my $val) = each %recs)
	{
		my @cur_entry = split /\t/, $val;
		push @books, 
		{
			$book[0] => $cur_entry[0],
			$book[1] => $cur_entry[1],
			$book[2] => $cur_entry[2]
		};
	}
	dbmclose(%recs);	
	return 0;
}

sub send_to_server
{
	for my $href ( @books ) 
	{
		
		my($author, $title, $year) = values $href;
		my $req = 	POST $url,
					Content_Type => 'form-data',
					Content => [
								a_a 	=> 	$author,
								a_n 	=> 	$title,
								a_y 	=> 	$year,
								add 	=> 	"add",
								db_type =>	"mysql",
								student	=>	$st,
								];	
		my $res = $ua->request($req);

		if($res->is_success)
		{
			print "\t\tAdd ok.\n";
		} else {
			print "\t\tAdd fail.\n";
		}
	}
	return 0;
}




return 1;