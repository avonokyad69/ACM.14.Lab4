package ST15;
use strict;
use LWP::Simple;
use HTTP::Request;
use Encode qw(encode decode);

my @Objects=();
undef @Objects;

my @MenuItems = (
	"\nMenu\n_______________________\n1. Add",
	"2. Edit",
	"3. Delete",
	"4. Display",
	"5. Save to file",
	"6. Load from file",
	"7. Send to DB",
	"8. Exit\n_______________________\n");
	
my @ReferencesToMenuItems =(
	\&Add,
	\&Edit,
	\&Delete,
	\&Display,
	\&SaveToFile,
	\&LoadFromFile,
	\&SendToDB);
	
my @Attributes=(
	'Name',
	'Attribute1',
	'Attribute2',
	'Attribute3',
	'UniqueAttribute');
	
sub st15{
	my $ch;
	while(1){
		foreach (@MenuItems){
			print "$_\n";
		}
		chomp ($ch = <STDIN>);
		if($ch>=1 && $ch<=7){
			$ReferencesToMenuItems[$ch-1]->();	
		}
		else{
			last if ($ch eq 8);	
		}	
	}
};
	
sub Add{
	system("cls");
	my $object = {};
	foreach(@Attributes){
		print "$_: ";
		chomp(my $atr = <STDIN>);
		if($_ eq $Attributes[-1]){
			while(1){
				if($atr eq "yes") {
					$atr=1;
					last;
				}
				if($atr eq "no") {
					$atr=0;
					last;
				}
				chomp($atr = <STDIN>);
				print "please enter yes/no: ";
			}
		}
		$object->{$_} = $atr;
	}
	@Objects=(@Objects,$object);
};

sub Edit{
	Display();
	if(scalar(@Objects)!=0){
		system("cls");
		while(1){
			Display();
			print"\nPlease enter the number of the object for editing:\n";
			my $i=<STDIN>;
			if(scalar(@Objects[$i-1])!=0){
				my $object = {};
				foreach(@Attributes){
					print "$_: ";
					chomp(my $atr = <STDIN>);
					if($_ eq $Attributes[-1]){
						while(1){							
							if($atr eq "yes") {
								$atr=1;
								last;
							}
							if($atr eq "no") {
								$atr=0;
								last;
							}
							chomp($atr = <STDIN>);
							print "\nplease enter yes/no: ";
						}
					}
					$object->{$_} = $atr;
				}
				@Objects[$i-1]= $object;
				Display();
				last;	
			}
			else{
				print"\nEnter the correct number of object:\n";
			}
		}
	}	
	return 1;
};

sub Delete{
	Display();
	if(scalar(@Objects)!=0){
		while(1){
			print"\nPlease enter the number of the object to delete:\n";
			my $i=<STDIN>;
			if(scalar(@Objects[$i-1])!=0){
				splice(@Objects,$i-1,1);
				Display();
				last;
			}
			else{
				print"\nEnter the correct number of object:\n";
			}
		}
	}	
	return 1;
};

sub Display{	
	if(scalar(@Objects)==0){
		print"\nThere are no objects in the list. ";
		print"Please add objects to the list, or load them from the file.\n\n";
	}
	else{
		my $counter=1;
		foreach (@Objects){
			print "\n\n_______________________\nObject $counter\n";
			print "Name - $_->{Name}\n";
			print "Attribute1 - $_->{Attribute1}\n";
			print "Attribute2 - $_->{Attribute2}\n";
			print "Attribute3 - $_->{Attribute3}\n";
			if ($_->{UniqueAttribute}==1){
				print "Unique - yes\n";
			}
			$counter++;
		}	
	}
	return 1;
};

sub SaveToFile{
	my %hash=();
	dbmopen(%hash, "basename", 0644) or die;
	%hash=undef();
	my $counter=0;
	foreach my $rh (@Objects){
		foreach my $o(@Attributes){
			$hash{$counter} .= Encode::encode('windows-1251', Encode::decode('cp866', "$o,$rh->{$o};"));
		}
		$counter++;
	}
	dbmclose(%hash);
	return 1;	
};

sub LoadFromFile{
	@Objects=();
	my %hash=undef();
	dbmopen(%hash,"basename",0644) or die;
	foreach my $k(sort keys %hash){
		$hash{$k} = Encode::encode('cp866', Encode::decode('windows-1251', $hash{$k}));
		my $ref2hash = {};
		my @array = split(/;/,$hash{$k});
		foreach my $ar(@array){
			my ($key, $val) = split(/,/, $ar);
			$ref2hash->{$key}=$val;
		}
		@Objects=(@Objects,$ref2hash);
	}
	dbmclose(%hash);
	Display();
};

sub SendToDB{
	my $url = 'http://localhost/cgi-bin/lab3.cgi';
	my $useragent = new LWP::UserAgent;
	my $student = 5; #На момент, когда залил сюда лабу
        
        $url.="?Num&student=$student&action=3&";
	foreach my $item(@Objects){
		my $raq = $url;
		foreach my $eln(@Attributes){
			$raq.="$eln=$item->{$eln}&";
		}
		my $qwe = new HTTP::Request(GET =>Encode::encode('windows-1251', Encode::decode('cp866', $raq)));
		$useragent->request($qwe);
	}
}

return 1;
