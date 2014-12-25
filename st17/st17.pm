package ST17; 
use strict;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request;
use Encode qw(encode decode);

my $st;

sub st17
{       
       
        my %List;
        $st = 2;

        my %commands =  (1 => \&add_elem,
                         2 => \&load_list,
                         3 => \&save_data,
                         4 => \&send_to_DB);
        


        print "The AutoPark Of Your Dream\n
        Menu of actions:\n
              1. Add new CAR\n
              2. Show the AutoPark\n
              3. Save the Autopark to DBM-File\n
              4. Send data to DB\n
              5. Quit\n";

        print " \nPlease, make your choice:   ";
       
        while (<STDIN>)
        {
                chomp;
                exit if $_ == 5;
                if ($commands{$_})
                {
                        $commands{$_}->(\%List);
                }
                else
                {
                        print "Incorrect command! Try again.";
                }
                print "\nPlease, make your choice:   ";
        }
}


sub add_elem
{      
        my($AutoPark) = @_;
        my $tmp = (sort {$a<=>$b} keys %$AutoPark)[-1] + 1;
        no warnings 'uninitialized';

        print "Model of car: ";
        chomp (my $model_of_car = <STDIN>);

        print "Power of engine: ";
        chomp (my $power_of_engine= <STDIN>);

        print "Price: ";
        chomp (my $price_of_car= <STDIN>);

        print "Select 1, if you want to specify the VIN-number of car, else select 0: ";
        chomp (my $vin_num= <STDIN>);

        %$AutoPark = (%$AutoPark, $tmp, [$model_of_car, $power_of_engine, $price_of_car, $vin_num]);

        print "The auto $model_of_car successfully added!\n";
}

sub load_list
{       
        no warnings 'uninitialized';
        my($AutoPark) = @_;
        my @buf_arr;
        my %hash_data;
        my $n = 0;

        if (dbmopen (%hash_data, 'autopark', undef))
        {
                foreach $n(sort keys %hash_data)
                {
                        my @buf_arr = split(/;/, $hash_data{$n});

                        %$AutoPark = (%$AutoPark, (sort {$a<=>$b} keys %$AutoPark)[-1] + 1, \@buf_arr);

                }
                dbmclose (%hash_data);
                print "\nSuccessfully loaded!\n";
        }
        else
        {
                print "\nError of loading!\n";
        }

        my $k = 0;

        foreach my $num (sort {$a<=>$b} keys %$AutoPark)
        {
                $k++;
                print "$k. ID = $num $AutoPark->{$num}[0] $AutoPark->{$num}[1], $AutoPark->{$num}[2] \n";
        }
        print "\nYour autopark is empty! \n" if $k == 0;
}

sub send_to_DB
{       
        my $s = 'http://localhost/cgi-bin/lab3.cgi';
        my($AutoPark) = @_;
        my $user_ag = new LWP::UserAgent;
        my $request_db;

        foreach my $n (sort {$a<=>$b} keys %$AutoPark)
        {
                $request_db = new HTTP::Request(GET => $s.'?st='.$st.'&model_of_car='.$AutoPark->{$n}[0].'&power_of_engine='.$AutoPark->{$n}[1].'&price_of_car='.$AutoPark->{$n}[2].'&vin_num='.$AutoPark->{$n}[3].'&type=edit_elem&Car_ID=');
                $user_ag->request($request_db);
        }
}

sub save_data
{
        my($AutoPark) = @_;
        my %hash_data;
        my $num = 0;
        my $k = 0;

        print "Name of your file: ";
        chomp (my $File_name = <STDIN>);

        if (dbmopen (%hash_data, $File_name, 0664))
        {
                %hash_data = ();

                foreach $num (sort {$a<=>$b} keys %$AutoPark)
                {
                        $k++;
                        $hash_data{$k} = join (";", ($AutoPark->{$num}[0], $AutoPark->{$num}[1], $AutoPark->{$num}[2], $AutoPark->{$num}[3]));

                }

                dbmclose (%hash_data);
                print "\nSuccessfully saved!\n";
        }
        else
        {
                print "\nError of saving!\n";
        }
}
return 1;