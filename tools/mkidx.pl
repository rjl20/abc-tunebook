#!/usr/bin/perl
use Data::Dumper;
use File::Basename;
my $dirname = dirname(__FILE__);

# First, load up the combined abc file the same way mkabc does

$combined = "$dirname/../Combined_Tunebook.abc";
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
# Don't care about this
#    if (defined($tune)) {
#	$tmp[$tune]{text} .= $_ . "\n";
#    }
}
close ABC;


# Transfer @tmp into %tunes, keyed to squashed title
for ($i=0; $i<=$#tmp; $i++) {
    $tunes{$tmp[$i]{title}}{key} = $tmp[$i]{key};
    $tunes{$tmp[$i]{title}}{title} = $tmp[$i]{title};
#    $tunes{$tmp[$i]{title}}{text} = $tmp[$i]{text};
}
@tmp = undef;


while (<>) {
    if (m/%%Page: (\d+) /) {
	$page = $1;
    }

    if (m/% --- \d+ \((.*?)\) ---/) {
	$title = $1;
	$sort = $title;
	$sort =~ tr/A-Z/a-z/;
        $sort =~ s/[^a-z0-9]*//g;
	push(@{$bykey{$tunes{$sort}{key}}}, {title => $title, page => $page});
	push(@{$bypage[$page]}, {title => $title, key => $tunes{$sort}{key}});

    }
    if (m/% --- \+ \(([^\)]+)\) ---/) {
	$alt = $1;
	push(@{$bykey{$tunes{$sort}{key}}}, { title => $alt, page => $page });
	push(@{$bypage[$page]}, {title => $alt, key => $tunes{$sort}{key}});
    }
}

# print Dumper(%bykey);
# print Dumper(@bypage);

print "\n\n=== Tunes By Key ===\n";

foreach $key (sort keys %bykey) {
    print "=== Key of $key ===\n";
    @tmp = sort { $a->{title} cmp $b->{title} } @{$bykey{$key}};
    for ($i=0; $i<=$#tmp; $i++) {
	printf("%40s\n", $tmp[$i]{title} . " " . $tmp[$i]{page});
    }
}

print "\n\n=== Alphabetic Index ===\n";

$max = $#bypage;
for ($i=1; $i <= $max; $i++) {
    @tmp = sort { $bypage[$a]{title} cmp $bypage[$b]{title} } @{$bypage[$i]};
    for ($n=0; $n<=$#tmp; $n++) {
	printf("%40s\n", ($tmp[$n]{title} . " (" . $tmp[$n]{key} . ") " . $i));
    }
}

