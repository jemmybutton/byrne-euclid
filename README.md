MetaPost + ConTeXt rendition of [Oliver Byrne's "The first six books of the Elements of Euclid"](https://en.wikipedia.org/wiki/Oliver_Byrne_(mathematician)#Byrne.27s_Euclid)

![title](https://user-images.githubusercontent.com/7447349/41129584-737480dc-6abb-11e8-8f73-7b9a9afcb38a.png)

This project is not intended to create the exact copy of the original, but rather an attempt to implement all the most important features of it in a way that would allow easy modification and creation of similarly styled geometric proofs.

![comparison](https://user-images.githubusercontent.com/7447349/41129582-73108424-6abb-11e8-88db-bb9839fc17de.png)

This version of the book is made in a way that makes modifications, including translation, quite possible and even not that difficult. As a proof of concept Russian translation is made. Plus, although Byrne's book looks cool as it is, it might be helpful, as Edward Tufte points out, to supplement it with conventional letter designations. So, there's also option for this (it is turned on by default in the Russian translation and can be easily turned on in the English version).

![labels](https://user-images.githubusercontent.com/7447349/41129583-73391e52-6abb-11e8-85c3-aa3b3b5b1743.png)

In addition to all the colorful byrnian stuff, this edition features generated lettrines and vignettes, so there are no two identical initials in the whole book.

![lettrines](https://user-images.githubusercontent.com/7447349/41129581-72c673f2-6abb-11e8-9bcd-278ca23d35cf.png)

The book itself (byrne_context.tex) and Russian translation (byrne_ru_context.tex) are licensed under CC-BY-SA 4.0.

MetaPost library (byrne.mp) and lettrines generator (lettrines.mp) are licensed under GPLv3 or later.

Tested with TeXLive 2015 on Ubuntu 16.04

See releases for prepared .pdf
