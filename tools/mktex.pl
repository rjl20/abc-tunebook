#!/usr/bin/perl
use Data::Dumper;
use File::Basename;
use Cwd 'abs_path';
my $dirname = dirname(abs_path($0));

# $base is SlowerThanDirt, DustyStrings, or Combined 
$base = $ARGV[0];

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
open(PS, "<$dirname/../out/${base}_Tunes.ps") or die "Can't open ${base}_Tunes.ps: $!\n";
while (<PS>) {
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
    } elsif (m/% --- \+ \((.*?)\) ---/) {
	$title = $1;
	$sort = $title;
	$sort =~ tr/A-Z/a-z/;
        $sort =~ s/[^a-z0-9]*//g;
	push(@{$bykey{$tunes{$parent}{key}}}, {title => "\$\\ast\$ $title", page => $page, sort => $sort});
	$bytitle{$sort} = {key => $tunes{$parent}{key}, page => $page, title => "\$\\ast\$ $title", parent => $parent};
    }
}
close PS;

# print Dumper(%bykey);
# print Dumper(%bytitle);

print <<'EOF';

\begin{center}
\large{Tunes By Key} \\
\end{center}
\begin{multicols}{2}
EOF


foreach $key (sort keys %bykey) {
    $pkey = $key;
    $pkey =~ s/\^/\\string^/g;
    print "\n\n\\noindent\n\\begin{center}\n";
    print '\textbf{Key of ' . $pkey . '} \\\\';
    print "\n\\end{center}\n";

    @tmp = sort { $a->{sort} cmp $b->{sort} } @{$bykey{$key}};
    for ($i=0; $i<=$#tmp; $i++) {
	print '\hyperlink{tunes.' . $tmp[$i]{page} . '}{' . $tmp[$i]{title} . '\dotfill' . $tmp[$i]{page} . '} \\\\';
	print "\n";
    }
}

print <<'EOF';
\end{multicols}

\clearpage

\begin{center}
\large{Tunes By Title} \\
\end{center}
\begin{multicols}{2}
\noindent
EOF

foreach $sortkey (sort keys %bytitle) {
    $key = $bytitle{$sortkey}{key};
    $key =~ s/\^/\\string^/g;
    print  '\hyperlink{tunes.' . $bytitle{$sortkey}{page} . '}{' . $bytitle{$sortkey}{title} . ' (' . $key . ')\dotfill' . $bytitle{$sortkey}{page} . '} \\\\';
    print "\n";
}

# The pdf inclusion stanza
print <<'EOF';
\end{multicols}

\cleardoublepage

\includepdf[
  pages=-,
  link=true,
  linkname=tunes,
  addtotoc={
EOF
#  offset=18 0,
foreach $sortkey (sort keys %bytitle) {
    $title = $bytitle{$sortkey}{title};
    $title =~ s/(.*), The/The \1/;
    $title =~ s/(.*), A/A \1/;
    if ($bytitle{$sortkey}{parent}) {
	next;
    } else {
	$idx .=  $bytitle{$sortkey}{page} . ", section, 1, " . $title . ", " . $sortkey . ",\n";
    }
}
$idx =~ s/,$//s;
$idx =~ s/\$\\ast\$ //g;
print $idx;

print "  }\n]{${dirname}/../out/${base}_Tunes.pdf}\n";

print "\\end{document}\n";

