package ST12;
use strict;
use LWP::UserAgent;
use LWP::Simple;
use HTTP::Request;
use Encode qw(encode decode);

my $pathfile='st12\Datafiles\654';
my @DATABASE =();
my @MODULES =(	
	\&add,
	\&edit,
	\&delete,
	\&show,
	\&save,
	\&load,
	\&SendToDB
	);
my @ElNames=(
	'Название',
	'Жесткость',
	'Прогиб',
	'Ширина',
	'Система_закладных',
	'Форма',
	'Сердечник',
	'Супердоска'
	);
my @NAMES =(
	'Добавить объект',
	'Редактировать объект',
	'Удалить объект',
	'Вывести на экран',
	'Сохранить в файл',
	'Загрузить из файла',
	'Отправить в DB',
	'Выход из программы'
	);
	
sub SendToDB{
	my $url = 'http://localhost/cgi-bin/lab3.cgi';
	my $content = get $url;
	my $student;
	die "Couldn't get $url" unless defined $content;
	if($content =~ m/\d. Kushnikov V.|\d\d. Kushnikov V./i){
		$student = unpack("x0 A2", $&);
	}else{
		system("cls");
		print "Номер не найден!";
		return;
	}
	$student += 0 ;
	my $ua = new LWP::UserAgent;
	my $req;
	$url.="?ElN=&student=$student&wtd=3&";
	foreach my $el(@DATABASE){
		my $raq = $url;
		foreach my $eln(@ElNames){
			$raq.="$eln=$el->{$eln}&";
		}
		my $qwe = new HTTP::Request(GET =>Encode::encode('windows-1251', Encode::decode('cp866', $raq)));
		$ua->request($qwe);
	}
}

sub menu{
	my $i = 0;
	print "\n------------------------------\n";
	foreach my $s(@NAMES){
		$i++;
		print "$i. $s\n";
	}
	print "------------------------------\n";
	my $ch = <STDIN>;
	return ($ch-1);
}
sub st12{
	while(1){
		my $ch = menu();
		if ($ch==7){return;}
		if($ch>=0&&defined $MODULES[$ch]){
			$MODULES[$ch]->();
		}
		else{
			system("cls");
			print "Внимательнее!";
			next;
		}
	}
}

sub add{
	system("cls");
	my $ref2hash = {};
	my $i = 0;
	foreach my $e(@ElNames){
		$i++;
		print "$i.$e: ";
		chomp(my $str = <STDIN>);
		$ref2hash->{$e} = $str;
	}
	@DATABASE=(@DATABASE,$ref2hash);
}

sub show{
	system("cls");
	if (!defined $DATABASE[0]) {	
		print "База пуста\n";
		return;
	};
	my $i = 0;
	#print "Названия всех объектов:\n";
	foreach my $ref2hash(@DATABASE){
		$i++;
		#print "$i.$ref2hash->{$ElNames[0]}\n";
		print "\n$i.$ElNames[0]: $ref2hash->{$ElNames[0]}";
		foreach my $o(@ElNames)		{
		 	if ($o eq $ElNames[0]) {next;}
		 	print "\n\t$o: $ref2hash->{$o}";
		}
	}
}

sub edit{
	system("cls");
	if (!defined $DATABASE[0]) {	
		print "Редактировать нечего\n";
		return;
	};
	while(1){
		print 'Номер редактируемого объекта: ';
		my $n = <STDIN>-1;
		if ($n<0||!defined $DATABASE[$n]){
			system("cls");
			print "Объекта с таким номером не существует\n";
			next;
		}
		my $ref2hash = $DATABASE[$n];
		$n = 0;
		foreach my $e(@ElNames){
			$n++;
			print "\n$n.$e: $ref2hash->{$e}";
		}
		print "\n\nНомер редактиремого параметра: ";
		$n = <STDIN>-1;
		if ($n<0||!defined $ElNames[$n]){
			system("cls");
			print "Параметра с таким номером не существует\n";
			next;
		}
		print "\nУкажите изменения\n$ElNames[$n]: ";
		chomp(my $m = <STDIN>);
		$ref2hash->{$ElNames[$n]} = $m;
		last;
	}
}

sub delete{
	system("cls");
	if (!defined $DATABASE[0]) {	
		print "Удалять нечего\n";
		return;
		};
	while(1){
		print "Номер удаляемого объекта: ";
		my $n = <STDIN>-1;
		if ($n<0||!defined $DATABASE[$n]){
			system("cls");
			print "Объекта с таким номером не существует\n";
			next;
		}
		splice(@DATABASE, $n, 1);
		last;
	}
}

sub save{#ничего лучше в голову не пришло для сохранения/загрузки
	system("cls");
	print "Файл(0 для использования ст.ф.): ";
	chomp(my $str = <STDIN>);
	if(!$str){$str=$pathfile};
	my %g;
	if(!dbmopen(%g, $str, 0644)){
		print "$!";
		return;
	}
	%g = ();
	my $i = 0;
	foreach my $ref2hash(@DATABASE){
		foreach my $o(@ElNames){
			$g{$i} .= Encode::encode('windows-1251', Encode::decode('cp866', "$o<==>$ref2hash->{$o}<===>"));
		}
		$i++;
	}
	dbmclose(%g);
}

sub load{
	system("cls");
	print "Файл(0 для использования ст.ф.): ";
	chomp(my $name = <STDIN>);
	if(!$name){$name=$pathfile};
	my %g;
	if(!dbmopen(%g, $name, 0)){
		print "\nНе могу открыть $name!";
		return;
	}
	@DATABASE=();
	foreach my $value(values %g){
		$value = Encode::encode('cp866', Encode::decode('windows-1251', $value));
		my $ref2hash = {};
		my @array = split(/<===>/, $value);
		foreach my $ar(@array){
			my ($key, $val) = split(/<==>/, $ar);
			$ref2hash->{$key}=$val;
		}
		@DATABASE=(@DATABASE,$ref2hash);
	}
	dbmclose(%g);
}