#!/usr/bin/perl

use strict;
use st01::st01;
use st05::st05;
use st10::st10;
use st12::st12;
use st15::st15;
use st17::st17;
use st18::st18;
use st21::st21;

my @MODULES = 
(
	\&ST01::st01,
	\&ST05::st05,
	\&ST10::st10,
	\&ST12::st12,
	\&ST15::st15,
	\&ST17::st17,
	\&ST18::st18,
	\&ST21::st21
);

my @NAMES = 
(
	"Student 01",
	"05. Girgushkina",
	"10. Kuklianov",
	"Kushnikov V.", #12
	"15. Pridachin",
	"17. Tikhonov",
	"18. Chaldina",
	"21. Shilenkov"
);

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

while(1)
{
	my $ch = menu();
	if(defined $MODULES[$ch])
	{
		print $NAMES[$ch]." launching...\n\n";
		$MODULES[$ch]->();
	}
	else
	{
		exit();
	}
}
