package ST18;
use 5.010;
use strict;
use warnings;
use utf8;
use Encode;
use HTTP::Cookies;
#use HTML::TableExtract;
use LWP;
use Data::Dumper;

my $tcp;# = HTML::TableExtract->new();

# Адрес сервера
my $server = "109.87.186.59";
# Порт который прослушивает веб сервер
my $port = "8888";
# Путь к скрипту относительно сервера
my $script_path = "/cgi-bin/test/Lab3.pm";
# Полная строка сервер:порт/скрипт
my $url = "http://".$server.":".$port.$script_path;
# Юзер агент ()
my $ua = new LWP::UserAgent;
# Создаем куки
my $cookies = HTTP::Cookies->new();
# Скажем серверу что мы Firefox :D
$ua->agent("Mozzila/8.0");
# Формируем куки
$cookies->set_cookie(0, 'db_type', 'mysql', '/', $server, $port, 0, 0, 86400, 0);
$ua->cookie_jar($cookies);

my $student = "Student name";

my @elements = ();

sub st18()
{
	#############################################################################
	my $choice = 0;
	# Массив ссылок на подпрограммы
	my @commands = (sub {say "good bye !"}, \&add, \&edit, \&del, \&show);
	# Массив надписей меню
	my @menu = ("", "[1].add", "[2].edit", "[3].del", "[4].show", "[0].exit");

	do
	{
		print "-" x 5, "[MENU]", "-" x 5;
		# Выводим меню
		say foreach(@menu);
		print "command: ";
		# Читаем команду
		chomp($choice = <STDIN>); 
		if ($choice =~ /^\d+$/) #число целочисленное
		{
			if($choice >= 0 && $choice <= 4)
			{
				# Выполняем вызов подпрограммы
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

# Добавление
sub add()
{	
	# Запрашиваем все необходимые данные
	print "name: "; chomp(my $name = <STDIN>);
	print "surname: "; chomp(my $surname = <STDIN>);
	print "age: "; chomp(my $age = <STDIN>);
	print "tel: "; chomp(my $tel = <STDIN>);
	# С консоли забираем в cp866, нужно конвертировать
	Encode::from_to($name, 'cp866', 'utf8'); utf8::decode($name);
	Encode::from_to($surname, 'cp866', 'utf8');	utf8::decode($surname);
	Encode::from_to($age, 'cp866', 'utf8');	utf8::decode($age);
	Encode::from_to($tel, 'cp866', 'utf8');	utf8::decode($tel);
	# Формируем строку запрос
	my $params = "?name=$name&surname=$surname&age=$age&tel=$tel&act=0&student=$student&db_type=mysql&btn=Добавить";
	my $req = new HTTP::Request( GET => $url.$params );
	# Определяем тип контента хтмл страничка в кодировке utf-8
	$req->content_type("'text/html; charset='utf8'");
	# Отправляем запрос
	my $res = $ua->request($req);
	# Проверяем успешен ли результат работы запроса и проверяем контент на наличие строки успешного добавления в базу
	if($res->is_success && index($res->content, "MySQL INSERT...") != -1)
	{
		print "\t\tAdd Ok.\n";
	# Иначе выводим сообщение об ошибке
	} else {
		print "\t\tAdd fail.\n";
		# Получаем html код ответа
		my $html = $res->content;
		# Конвертируем в печатаемый вид
		Encode::from_to($html, 'utf8', 'cp866');
		# Печатаем
		print $html;
	}
	return 0;
}

# Редактирование
sub edit()
{
	print "edit elem by id == ";
	chomp(my $index = <STDIN>);
	
	print "name: "; chomp(my $name = <STDIN>);
	print "surname: "; chomp(my $surname = <STDIN>);
	print "age: "; chomp(my $age = <STDIN>);
	print "tel: "; chomp(my $tel = <STDIN>);
	# С консоли забираем в cp866, нужно конвертировать
	Encode::from_to($name, 'cp866', 'utf8'); utf8::decode($name);
	Encode::from_to($surname, 'cp866', 'utf8');	utf8::decode($surname);
	Encode::from_to($age, 'cp866', 'utf8');	utf8::decode($age);
	Encode::from_to($tel, 'cp866', 'utf8');	utf8::decode($tel);
			
	# Формируем строку запрос
	my $params = "?index=$index&name=$name&surname=$surname&age=$age&tel=$tel&act=1&student=$student&db_type=mysql&btn=Добавить";
	my $req = new HTTP::Request( GET => $url.$params );
	# Определяем тип контента хтмл страничка в кодировке utf-8
	$req->content_type("'text/html; charset='utf8'");
	# Отправляем запрос
	my $res = $ua->request($req);
	# Проверяем успешен ли результат работы запроса и проверяем контент на наличие строки успешного редактирования
	if($res->is_success && index($res->content, "MySQL UPDATE...") != -1)
	{
		print "\t\tEdit Ok.\n";
	# Иначе выводим сообщение об ошибке
	} else {
		print "\t\tEdit fail.\n";
		# Получаем html код ответа
		my $html = $res->content;
		# Конвертируем в печатаемый вид
		Encode::from_to($html, 'utf8', 'cp866');
		# Печатаем
		print $html;
	}
	return 0;
}

# Удалить
sub del()
{
	print "delete elem by index == ";
	chomp(my $index = <STDIN>);
	if (!($index =~ /^\d+$/))
	{
		my $str = "Индекс должен быть числом !\n";
		utf8::encode($str); Encode::from_to($str, 'utf8', 'cp866');
		print $str;
		return 0;
	}
	# Формируем строку запрос
	my $params = "?index=$index&act=2&student=$student&db_type=mysql&btn=Удалить";
	my $req = new HTTP::Request( GET => $url.$params );
	# Определяем тип контента хтмл страничка в кодировке utf-8
	$req->content_type("'text/html; charset='utf8'");
	# Отправляем запрос
	my $res = $ua->request($req);
	# Проверяем успешен ли результат работы запроса и проверяем контент на наличие строки успешного добавления в базу
	if($res->is_success && index($res->content, "MySQL DELETE...") != -1)
	{
		print "\t\tDelete Ok.\n";
	# Иначе выводим сообщение об ошибке
	} else {
		print "\t\tDelete fail.\n";
		# Получаем html код ответа
		my $html = $res->content;
		# Конвертируем в печатаемый вид
		Encode::from_to($html, 'utf8', 'cp866');
		# Печатаем
		print $html;
	}	
	return 0;
}

# Вывод на экран
sub show()
{	
	# Формируем строку запрос
	my $params = "?act=5&student=$student&db_type=mysql&btn=Показать";
	my $req = new HTTP::Request( GET => $url.$params );
	# Определяем тип контента хтмл страничка в кодировке utf-8
	$req->content_type("'text/html; charset='utf8'");
	# Отправляем запрос
	my $res = $ua->request($req);
	# Проверяем успешен ли результат работы
	if($res->is_success)
	{
		# Получаем html код ответа
		my $html = $res->content;
		# Конвертируем в печатаемый вид
		Encode::from_to($html, 'utf8', 'cp866');
		#$tcp->parse();
		my $te = HTML::TableExtract->new( );
		$te->parse($html);
		# Для всех таблиц (в ответе должна быть хотя бы одна)
		foreach my $table ($te->tables) {
			# Выбираем строку
			foreach my $row ( $table->rows($table) ) {
				# Выбираем ячейку
				foreach my $cell (@$row)
				{
					# Если ячейка определена - выводим данные (из за атрибута collspan может быть помечена как undef)
					if(defined $cell){ print $cell."\t";}
				}
				say "";
			}
		}
		
	# Иначе выводим сообщение об ошибке
	} else {
		print "\t\tPrint fail.\n";
		# Получаем html код ответа
		my $html = $res->content;
		# Конвертируем в печатаемый вид
		Encode::from_to($html, 'utf8', 'cp866');
		# Печатаем
		print $html;
	}	
	return 0;
}




return 1;