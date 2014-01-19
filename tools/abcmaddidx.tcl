#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}

# Create a tune index from the abcm2ps PostScript output
#	
# Copyright (C) 2007-2013 Jean-François Moine
# version 2013/03/16
#	- fix crash when %%header with 2 lines (reported by Chuck Boody)
# version 2011/04/18
#	- handle the secondary titles
# version 2010/06/11
#	- bad vertical space in index
#	- add option in usage
# version 2010/06/03
#	- more settable variables
#	- add option to set the index at the beginning
#	- do it work with abcm2ps-6.x.x
# version 2007/12/01
#	- loop when 1st title ends with ", The' and abcm2ps version < 5

# -- set your preferences here --
# below, you may force the fontname, fontsize and xmid (X middle)
# which are normally found in the input PostScript file
    set fontname {}
# example:
#    set fontname {/Helvetica exch selectfont}
    set fontsize 0
    set xmid 0
# title of the index page
    set index {index}
# the following values are used when fontname, fontsize or
# xmid cannot be found in the input PostScript file
    set fontname_d {F0}		;# default encoded font name
    set fontsize_d {20}		;# default encoded font size
    set xmid_d 300		;# default x middle of the page
# -- end preferences --

proc usage {} {
    puts {Add a tune index to a abcm2ps output.
Usage: ./abcmaddidx.tcl [options] <input abcm2ps file> <output file with index>
  <input abcm2ps file> may be '-' for stdin
  -b     set the index before the music}
	exit 1
}

proc main {} {
    global argv
    global fontname_d fontsize_d xmid_d fontname fontsize xmid index
    set fnin {}
    set fnout {}
    set before 0
    foreach p $argv {
	switch -- $p {
	    -b {
		set before 1
	    }
	    default {
		if {[string length $fnin] == 0} {
		    set fnin $p
		} elseif {[string length $fnout] == 0} {
		    set fnout $p
		} else {
			usage
		}
	    }
	}
    }
    if {$fnin == "-"} {
	set in stdin
    } else {
	set in [open $fnin r]
    }
    set out [open $fnout w]
    set page 1
    set titlelist {}
    set gsave {}
    set scale {}
    set margin {}

    # copy the header
    while {[gets $in line] >= 0} {
	if {[string compare $line {%%EndSetup}] == 0} {
	    puts $out "% -- Tune index
/mkidx{	x 0 M showr
	40 0 M show 20 0 RM
	{(  .  )show currentpoint pop xmax ge{exit}if}loop
	0 fh T
}!"
	    puts $out $line
	    break
	}
	puts $out $line
    }
    if {$before} {
	set before [tell $in]
    }
    while {[gets $in line] >= 0} {
	if {[string compare [string range $line 0 7] {%%Page: }] == 0} {
	    set page [lindex [split $line] 1]
	    if {[string length $gsave] == 0} {
		if {!$before} {
		    puts $out $line
		}
		gets $in line
		if {[string index $line 0] == "%"} {
		    if {!$before} {
			puts $out $line
		    }
		    gets $in line
		}
		set gsave $line
		while {1} {
		    if {!$before} {
			puts $out $line
		    }
		    if {[gets $in line] < 0} break
		    set tmp [split $line]
		    if {[string compare [string range $line 0 11] {% --- width }] == 0} {
			if {$xmid == 0} {
			    set xmid [expr {[lindex $line 3] * 0.5}]
			}
		    }
		    switch [lindex $tmp end] {
			scale {set scale $line}
			T {
			    if {[lindex $line 0] == 0} continue
			    set margin $line
			    break
			}
		    }
		}
	    }
	} elseif {[string compare [string range $line 0 5] {% --- }] == 0} {
	    set i [string first "(" $line]
	    set j [string last ")" $line]
	    if {$i > 0 && $j > 0} {
	      incr i
	      incr j -1
	      set title [string trim [string range $line $i $j]]
	      lappend titlelist "($title)($page)"
	      if {[string length $fontname] == 0
		|| $fontsize == 0 || $xmid == 0} {
		set i [string last ", " $title]
		if {$i > 0} {
		    incr i -1
		    set title [string range $title 0 $i]
		}
		while {1} {
		    if {!$before} {
			puts $out $line
		    }
		    if {[gets $in line] < 0} break
		    if {[string compare [string range $line 0 10] {% --- font }] == 0} {
			set tmp [split $line]
			if {$fontsize == 0} {
			    set fontsize [lindex $tmp 3]
			}
			if {[string length $fontname] == 0} {
			    set fontname [lindex $tmp 4]
			}
			break
		    }
		    if {[string first $title $line] >= 0} {
			set tmp [split $line]
			if {[string index [lindex $tmp 4] 0] == "M"} {
			    if {$fontsize == 0} {
				set fontsize [lindex $tmp 0]
			    }
			    if {[string length $fontname] == 0} {
				set fontname [lindex $tmp 1]
			    }
			    if {$xmid == 0} {
				set xmid [lindex $tmp 2]
			    }
			} else {
			    if {$fontsize == 0} {
				set fontsize [lindex $tmp 3]
			    }
			    if {[string length $fontname] == 0} {
				set fontname [lindex $tmp 4]
			    }
			    if {[string last "showc" $line] > 0
				&& [string index [lindex $tmp 2] 0] == "M"} {
				if {$xmid == 0} {
				    set xmid [lindex $tmp 0]
				}
			    } elseif {$xmid == 0} {
#				puts stderr "line: $line"
				puts stderr "xmid forced to $xmid_d"
				set xmid $xmid_d
			    }
			}
			if {[string index $fontname 0] != "F"} {
#			    puts stderr "line: $line"
#			    puts stderr "font: $fontname"
			    puts stderr "font forced to $fontsize_d $fontname_d"
			    set fontname $fontname_d
			    set fontsize $fontsize_d
			}
			break
		    }
		}
	      }
	    }
	} elseif {[string compare [string range $line 0 8] {%%Trailer}] == 0} {
	    break
	}
	if {!$before} {
	    puts $out $line
	}
    }
    # output the index
    set x [expr {$xmid * 2}]
    set ph [lindex $gsave 2]
    set lh [expr {($fontsize / 0.8) * [lindex $scale 0]}]
    set n [expr {int(($ph - 6 * $lh) / $lh)}]
    set titlelist [lsort $titlelist]
    set first 1
    if {$before} {
	set page 0
    }
    puts $out "% -- Tune index"
    while {[llength $titlelist] > 0} {
	set sublist [lrange $titlelist 0 [expr {$n - 1}]]
	set titlelist [lrange $titlelist $n end]
	incr page 1
	puts $out "%%Page: $page $page
$gsave
$scale
$margin
$fontsize $fontname
$x 40 sub /x 1 index def
/xmax exch 40 sub def
/fh -[expr {$fontsize * 1.25}] def
0 fh 1.6 mul T"
	if {$first} {
	    puts $out "x 2 div 0 M($index)showc
0 fh 1.6 mul T"
	    set first 0
	    incr n 2
	}
	foreach t $sublist {
	    puts $out "${t}mkidx"
	}
	puts $out "%%PageTrailer
grestore
showpage"
    }
    # if index at the beginning, copy the tunes
    if {$before} {
	seek $in $before
	while {[gets $in line] >= 0} {
	    if {[string compare [string range $line 0 7] {%%Page: }] == 0} {
		incr page
		puts $out "%%Page: $page $page"
	    } elseif {[string compare [string range $line 0 8] {%%Trailer}] == 0} {
		break
	    } else {
		puts $out $line
	    }
	}
    }
    # update the trailer
    puts $out "%%Trailer
%%Pages: $page
%EOF"
}

# -- main
if {$argc < 2} {
    usage
}

main
