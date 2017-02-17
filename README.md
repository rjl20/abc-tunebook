abc-tunebook
============

Old-time tune transcriptions in ABC format, mainly from jams around Seattle:

* Slower Than Dirt: http://slowerthandirt.org/
* Dusty Strings Second Sunday: http://store.dustystrings.com/t-3-ms-JMS-oldtime.aspx
* Wedgwood Alehouse Tuesday Jam: http://wedgwoodalehouse.com/

To Do:

* Write script to extract incipits, sorted by key and title

About the scripts: the code is terrible. I'm a sysadmin, not a
developer.  If someone wants to clean these up, that'd be great;
otherwise, they work well enough for my purposes now that I'll
probably only work on them when I need them to do something else.

Dependencies
------------

* abcm2ps-8.13.1 (December 10, 2016)
* TeX Live 2016
* Fonts: Playfair Display, Planscribe NF

The table of contents generating code relies on output from abcm2ps which 
may change from version to version.

Playfair is a free font, Planscribe is commercial. You might want to change
the fonts definitions in the various .fmt files to use whatever fonts
you prefer.

LICENSE
-------

The transcriptions, tools, and support files included in this
repository are licensed under the [Creative Commons Attribution-ShareAlike
4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
The _compositions_ are not mine to license, except any which I personally
composed. What this means is that, as with any other printed collection of 
sheet music, it is up to the performer to determine the licensing status of 
the compositions depicted by the sheet music. Public performance or recording 
may require the payment of licensing fees.

Most of the tunes in this collection will be what I consider "traditional", 
which is to say that they've been played for so long that nobody knows who 
composed them. Some are not. I will do my best to provide attribution to 
composers where I can find them.