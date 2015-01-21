package ST13;
use strict;
use LWP::Simple;
use HTTP::Request;
use Encode qw(encode decode);

my @Objects=();
undef @Objects;

my @MenuItems = (
	"\nMenu\n_______________________\n
	1. Add",
	"2. Edit",
	"3. Delete",
	"4. Show",
	"5. Save",
	"6. Load",
	"7. Send to DB",
	"8. Exit\n_______________________\n");
	
my @ReferencesToMenuItems =(
	\&DoAdd,
	\&DoEdit,
	\&DoDelete,
	\&DoDisplay,
	\&DoSave,
	\&DoLoad,
	\&DoSendToDB);
	
my @list=(
	'movie',
	'producer',
	'score',
	'year',
	'oskar');
	
sub st13{
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
	
sub DoAdd{
	system("cls");
	my $object = {};
	foreach(@list){
		print "$_: ";
		chomp(my $atr = <STDIN>);
		if($_ eq $list[-1]){
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

sub DoEdit{
	DoDisplay();
	if(scalar(@Objects)!=0){
		system("cls");
		while(1){
			DoDisplay();
			print"\nEnter movie ID:\n";
			my $i=<STDIN>;
			if(scalar(@Objects[$i-1])!=0){
				my $object = {};
				foreach(@list){
					print "$_: ";
					chomp(my $atr = <STDIN>);
					if($_ eq $list[-1]){
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
				DoDisplay();
				last;	
			}
			else{
				print"\nEnter the correct number of object:\n";
			}
		}
	}	
	return 1;
};

sub DoDelete{
	DoDisplay();
	if(scalar(@Objects)!=0){
		while(1){
			print"\nEnter movie ID:\n";
			my $i=<STDIN>;
			if(scalar(@Objects[$i-1])!=0){
				splice(@Objects,$i-1,1);
				DoDisplay();
				last;
			}
			else{
				print"\nEnter the correct number of object:\n";
			}
		}
	}	
	return 1;
};

sub DoDisplay{	
	if(scalar(@Objects)==0){
		print"\nNo movie in db :(  ";
		print"Please add objects to the list, or load them from the file.\n\n";
	}
	else{
		my $counter=1;
		foreach (@Objects){
			print "\n\n_______________________\nMovie $counter\n";
			print "Movie - $_->{movie}\n";
			print "Producer - $_->{producer}\n";
			print "Score - $_->{score}\n";
			print "Year - $_->{year}\n";
			if ($_->{oskar}==1){
				print "Has Oskar ? - da";
			} else {
			print "Has Oskar ? - net";
			}
			$counter++;
		}	
	}
	return 1;
};

sub DoSave{
	my %hash;
	dbmopen(%hash, "myimdb", 0666) or die;
	%hash=();
	my $counter=0;
	foreach my $rh (@Objects){
		foreach my $o(@list){
			$hash{$counter} .= Encode::encode('windows-1251', Encode::decode('cp866', "$o,$rh->{$o};"));
		}
		$counter++;
	}
	dbmclose(%hash);
	return 1;	
};

sub DoLoad{
	@Objects=();
	my %hash=undef();
	dbmopen(%hash,"myimdb",0666) or die;
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
	DoDisplay();
};

sub DoSendToDB{
	my $url = 'http://localhost/cgi-bin/lab3.cgi';
	my $useragent = new LWP::UserAgent;
	my $student = 13; 
        
        $url.="?Num&student=$student&action=3&";
	foreach my $item(@Objects){
		my $raq = $url;
		foreach my $eln(@list){
			$raq.="$eln=$item->{$eln}&";
		}
		my $qwe = new HTTP::Request(GET =>Encode::encode('windows-1251', Encode::decode('cp866', $raq)));
		$useragent->request($qwe);
	}
}

return 1;
