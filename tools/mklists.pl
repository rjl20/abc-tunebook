#!/usr/bin/perl
use Text::CSV;
use Encode;
use File::Basename;
my $dirname = dirname(__FILE__);

# system('curl', '-o', "$dirname/../out/tunelist.csv", 'https://docs.google.com/spreadsheet/pub?key=0AiGRqa7-uLzmdDNESDR6YUhrUVg5LS16UEFXMzdINlE&single=true&gid=0&output=csv');

my %hoa = ( 'std' => [], 'dusty' => [], 'combined' => [] );
my $csv = Text::CSV->new({ binary => 1 }) or die "Cannot use CSV: ".Text::CSV->error_diag ();

open my $fh, "<:encoding(utf8)", "$dirname/../out/tunelist.csv" or die "tunelist.csv: $!";
while ( my $row = $csv->getline( $fh ) ) {
    if ($row->[2] > 2) {
	push $hoa{"std"}, $row;
    }
    if ($row->[3] > 2) {
	push $hoa{"dusty"}, $row;
    }
    if ($row->[4] > 2) {
	push $hoa{"combined"}, $row;
    }
}
$csv->eof or $csv->error_diag();
close $fh;

foreach $tbl (keys %hoa) {
    @tmp = @{ $hoa{$tbl} };
    @tmp = sort {
	$b[1] cmp $a[1]
	    ||
	    $a[0] cmp $b[0]
    } @tmp;

    open(OUT, ">$dirname/../out/$tbl.txt") or die "Can't open $tbl.txt: $!\n";
    for ($i=0; $i <= $#tmp; $i++) {
	print OUT "T:" . Encode::encode("ASCII", $tmp[$i][0]) . "\n";
    }
    close OUT;
}
