MetaPost + TeX rendition of [Oliver Byrne's "The first six books of the
Elements of Euclid"](https://en.wikipedia.org/wiki/Oliver_Byrne_(mathematician)#Byrne.27s_Euclid)

![title](https://user-images.githubusercontent.com/7447349/41129584-737480dc-6abb-11e8-8f73-7b9a9afcb38a.png)

This project is not intended to create the exact copy of the original, but
rather is an attempt to implement all its most important features in a way that
would allow easy modification and creation of similarly styled geometric proofs.

At the moment, all the code for this purpose exists as a standalone LaTeX
[package](https://github.com/jemmybutton/byrne-latex), is 
[on CTAN](https://www.ctan.org/pkg/byrne),and can be used by employing 
`\usepackage{byrne}`.

![comparison](https://user-images.githubusercontent.com/7447349/52147564-2c240580-2678-11e9-9803-01a2b7c970da.png)

Beyond merely reproducing Byrne's original design elements, this version
features some improvments over the original. E.g., it has a mechanism to
add small letters to Byrne's colorful diagrams, as suggested by Edward
Tufte in [Envisioning Information](https://www.edwardtufte.com/tufte/books_ei).
This feature is turned on by default in the Russian version and can be
turned on with one line in the English version (save for some layout
changes which arise due to letter designations taking more space).

![labels](https://user-images.githubusercontent.com/7447349/52147400-a30cce80-2677-11e9-9a2a-3b7f88419c90.png)

This edition features generated initials and vignettes, so there are no 
two identical initials in the whole book. This feature is pretty much 
work-in-progress, and, when ready (i.e. when it starts producing 
satisfactory results), is likely to become a part of 
[fiziko](https://github.com/jemmybutton/fiziko) library.

![lettrines](https://user-images.githubusercontent.com/7447349/52147399-a2743800-2677-11e9-83a1-d25620253263.png)

The book itself (byrne-en-latex.tex) and its Russian translation
(byrne-ru-latex.tex) are licensed under CC-BY-SA 4.0.

MetaPost library (byrne.mp) and initials generator (lettrines.mp) are 
licensed under GPLv3 or later.

To build the book run `lualatex byrne-en-latex.tex` or
`lualatex byrne-ru-latex.tex` within the book directory. To generate the
initials run `mpost lettrines.mp` within `\lettrines` directory.

See releases for prepared .pdfs (at the moment it's an older ConTeXt 
version). See Actions for fresher pdfs (unless they are expired).
