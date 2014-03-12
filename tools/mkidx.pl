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
}
close ABC;


# Transfer @tmp into %tunes, keyed to squashed title
for ($i=0; $i<=$#tmp; $i++) {
    $tunes{$tmp[$i]{title}}{key} = $tmp[$i]{key};
    $tunes{$tmp[$i]{title}}{title} = $tmp[$i]{title};
#    $tunes{$tmp[$i]{title}}{text} = $tmp[$i]{text};
}
@tmp = undef;

# Now suck in the postscript, looking for pages and tunes
while (<>) {
    if (m/%%Page: (\d+) /) {
	$page = $1;
    }

    if (m/% --- \d+ \((.*?)\) ---/) {
	$title = $1;
	$sort = $title;
	$sort =~ tr/A-Z/a-z/;
        $sort =~ s/[^a-z0-9]*//g;
	$parent = $sort;
	push(@{$bykey{$tunes{$sort}{key}}}, {title => $title, page => $page, sort => $sort});
	$bytitle{$sort} = {key => $tunes{$sort}{key}, page => $page, title => $title};
    }

    if (m/% --- \+ \((.*?)\) ---/) {
	$title = $1;
	$sort = $title;
	$sort =~ tr/A-Z/a-z/;
        $sort =~ s/[^a-z0-9]*//g;
	push(@{$bykey{$tunes{$parent}{key}}}, {title => "\\ast $title", page => $page, sort => $sort});
	$bytitle{$sort} = {key => $tunes{$parent}{key}, page => $page, title => "\\ast $title"};
    }
    
}

# print Dumper(%bykey);
# print Dumper(@bypage);

print "\n\n";
print '\noindent' . "\n";
print '\begin{center}' . "\n";
print '\large{Tunes By Key} \\\\' . "\n";
print '\end{center}' . "\n";


foreach $key (sort keys %bykey) {
    print '\textbf{Key of ' . $key . '} \\\\';
    print "\n";

    @tmp = sort { $a->{sort} cmp $b->{sort} } @{$bykey{$key}};
    for ($i=0; $i<=$#tmp; $i++) {
	print '\-\hspace{4ex}\hyperlink{tunes.' . $tmp[$i]{page} . '}{' . $tmp[$i]{title} . '\dotfill' . $tmp[$i]{page} . '} \\\\';
	print "\n";
    }
}

print "\n\n";
print '\noindent' . "\n";
print '\begin{center}' . "\n";
print '\large{Tunes By Title} \\\\' . "\n";
print '\end{center}' . "\n";

foreach $sortkey (sort keys %bytitle) {
    print  '\hyperlink{tunes.' . $bytitle{$sortkey}{page} . '}{' . $bytitle{$sortkey}{title} . ' (' . $bytitle{$sortkey}{key} . ')\dotfill' . $bytitle{$sortkey}{page} . '} \\\\';
    print "\n";
}


