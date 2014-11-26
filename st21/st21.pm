package ST21;
use strict;
use LWP::Simple;
use HTTP::Request;
use Encode qw(encode decode);

my %list = (
	1 => 'Add',
	2 => 'Edit',
	3 => 'Delete',
	4 => 'Show_all',
	5 => 'Save_to_file',
	6 => 'Load_from_file',
	7 => 'Send_to_DB',
	8 => 'Exit');
	
my %Items =();

sub menu
{
	system("cls");
	foreach my $name (sort keys %list)
	{
		print "$name: $list{$name}\n";
	}
	print "==========================\n";
	print "Select the menu item: ";
	
	chomp(my $choice = <STDIN>);	
	return($choice);	
}

sub Add
{
	my $cap = '';
	print "Enter the data\n";
	print "Name: "; chomp(my $name = <STDIN>);
	print "Position: "; chomp(my $pos = <STDIN>);
	print "Age: "; chomp(my $age = <STDIN>);
	print "Club: "; chomp(my $club = <STDIN>);
	print "Captain: "; chomp(my $cap2 = <STDIN>);
	if($cap2 ne '') {$cap = 'Captain';}
	push(@{$Items{$name}}, $pos, $age, $club, $cap);
}
 
sub Edit
{
	Show_all();

	print "Write Name of player to change: ";
	chomp(my $name = <STDIN>);
	if(exists($Items{$name}))
	{
		print "Position: "; chomp(my $pos = <STDIN>);
		print "Age: "; chomp(my $age = <STDIN>);
		print "Club: "; chomp(my $club = <STDIN>);
		print "Captain: "; chomp(my $cap = <STDIN>);
		@{$Items{$name}}[0] = $pos;
		@{$Items{$name}}[1] = $age;
		@{$Items{$name}}[2] = $club;
		@{$Items{$name}}[3] = $cap;
	}
	else
	{
		print "\nThere is no such person\n\n";
	};
}
 
sub Delete
{
	Show_all();

	print "Write Name of player to delete: ";
	chomp(my $name = <STDIN>);
	if(exists($Items{$name}))
	{
		delete($Items{$name});
	}
	else
	{
		print "\nThere is no such person:\n\n";
	}
}

sub Show_all
{
	system("cls");
	print "==========================\n";
	foreach my $name (keys %Items)
	{
		print "$name: @{$Items{$name}}\n";
	}	
	print "==========================\n";
	system("pause");
}

sub Save_to_file
{	
	print "Save to file\n";
	my %buff = ();
	dbmopen(%buff,"st21/Shilenkov_dbm",0644) || die "Error open to file!";
	
	my $buffStr;
	foreach my $name (keys %Items)
	{
		$buffStr = undef();		
		$buffStr = @{$Items{$name}}[0].":".@{$Items{$name}}[1].":".@{$Items{$name}}[2].":".@{$Items{$name}}[3].";";
		$buff{$name} = $buffStr;
	};
	
	dbmclose(%buff);
}

sub Load_from_file
{	
	print "Load from file\n";
	my %buff = ();
	%Items = ();
	dbmopen(%buff,"st21/Shilenkov_dbm",0644) || die "Error open to file!";
	
	print "==========================\n";
	
	foreach my $name (keys %buff)
	{
		my @buffStr = undef();
		@buffStr = split(/;/, $buff{$name}); 
		foreach my $buffElem (@buffStr)
		{
			my @Value = split(/:/, $buffElem);
			push(@{$Items{$name}}, $Value[0], $Value[1], $Value[2], $Value[3]);
		};
	};
	
	Show_all();
	
	dbmclose(%buff);
}

sub Send_to_DB
{
	my $url = 'http://localhost/cgi-bin/lab3.cgi';
	my $student = get $url;
	die "Couldn't get $url" unless defined $student;
	if($student =~ m/\d+(?=(. 21. Shilenkov))/){
		$student = $&;
	}else{
		print "Номер не найден!";
		system("pause");
		return;
	}
	my $useragent = new LWP::UserAgent;

	$url.="?choice=1&student=$student&";
		
	foreach my $name (keys %Items)
	{
		my $buffurl = $url;		
		$buffurl .= "name_=$name&pos_=@{$Items{$name}}[0]&age_=@{$Items{$name}}[1]&club_=@{$Items{$name}}[2]&cap_=@{$Items{$name}}[3]&btn=%D0%A1%D0%BE%D1%85%D1%80%D0%B0%D0%BD%D0%B8%D1%82%D1%8C";
		my $request = new HTTP::Request(GET =>Encode::encode('windows-1251', Encode::decode('cp866', $buffurl)));
		$useragent->request($request);
	}
}

sub st21
{
	while(1)
	{
		my $choice = menu();
		if($choice == 8)
		{
			system("cls");
			return;
		}
		if(exists($list{$choice}))
		{
			system("cls");
			print "The selected function: $list{$choice}\n";
			my $func_call = \&{$list{$choice}};
			&$func_call();
		} else
		{
			print "==========================\n";
			print "There is no such menu item: $choice\n";
			print "==========================\n\n";
			system("pause");
		}
	}
}

1;
