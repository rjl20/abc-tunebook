#!/usr/bin/perl
use Data::Dumper;
use File::Basename;
my $dirname = dirname(__FILE__);

$combined = "$dirname/../Combined_Tunebook.abc";
%books = ( 
    combined => 'Combined Slower Than Dirt / Dusty Strings Second Sunday Tunebook',
    dusty => 'Dusty Strings Second Sunday Tunebook',
    std => 'Slower Than Dirt Tunebook'
    );

open(ABC, "<$combined") or die "Can't open $combined: $!\n";

$x = -1;
$tune = undef;

# Load up the combined tunebook into a @tmp array
while (<ABC>) {
    chomp;
    s/\s*$//;

    if (m/^X:/) {
	$x++;
	$tune = $x;
	next;
    }
    if (m/^\s*$/) {
	$tune = undef;
	next;
    }
    if ((m/^T:(.*)$/) && (!$tmp[$tune]{title})) {
	my $title = $1;
	$title =~ tr/A-Z/a-z/;
	$title =~ s/[^a-z0-9]*//g;
	$tmp[$tune]{title} = $title;
    }
    if ((m/^K:(.*)$/) && (!$tmp[$tune]{key})) {
	$tmp[$tune]{key} = $1;
    }
    if (defined($tune)) {
	$tmp[$tune]{text} .= $_ . "\n";
    }
}
close ABC;


# Transfer @tmp into %tunes, keyed to squashed title
for ($i=0; $i<=$#tmp; $i++) {
    $tunes{$tmp[$i]{title}}{key} = $tmp[$i]{key};
    $tunes{$tmp[$i]{title}}{title} = $tmp[$i]{title};
    $tunes{$tmp[$i]{title}}{text} = $tmp[$i]{text};
}
@tmp = undef;

# Load up %tunebooks, keyed to book shortcode, with appropriate %tunes.
foreach $book (keys %books) {
    $tunebooks{$book} = [];
    $i=0;
    open(LIST, "<$dirname/../out/$book.txt") or die "Can't open $book.txt: $!\n";
    while (<LIST>) {
	chomp;
	($foo, $title) = split(/:/, $_, 2);
	$otitle = $title;
	$title =~ s/^\s*//;
	$title =~ s/\s*$//;
	$title =~ tr/A-Z/a-z/;
	$title =~ s/[^a-z0-9]*//g;
	if ($tunes{$title}) {
	    push($tunebooks{$book}, {
		sort => $title,
		title => $otitle,
		key => $tunes{$title}{key},
		text => $tunes{$title}{text}
		 });
	    $i++;
	} else {
	    print "$book - \"$otitle\" missing\n";
	}
    }
    close LIST;
}


foreach $book (keys %books) {
# Sort each %tunebook(s) by squashed title
    @tmp = sort {
#	$a->{key} cmp $b->{key} 
#	||
	$a->{sort} cmp $b->{sort}
    } @{$tunebooks{$book}};
    # And spit out an abc file in sorted order
    open(ABC, ">$dirname/../out/$book.abc") or die "Can't open $book.abc: $!\n";
    for ($i = 0; $i<=$#tmp; $i++) {
	print ABC "X:" . ($i+1) . "\n";
	print ABC $tmp[$i]{text} . "\n";
    }
    close ABC;
}



	
