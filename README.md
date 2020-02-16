[![Build Status](https://travis-ci.org/jemmybutton/byrne-euclid.svg?branch=master)](https://travis-ci.org/jemmybutton/byrne-euclid)

MetaPost + ConTeXt rendition of [Oliver Byrne's "The first six books of the
Elements of
Euclid"](https://en.wikipedia.org/wiki/Oliver_Byrne_(mathematician)#Byrne.27s_Euclid)

![title](https://user-images.githubusercontent.com/7447349/41129584-737480dc-6abb-11e8-8f73-7b9a9afcb38a.png)

This project is not intended to create the exact copy of the original, but
rather is an attempt to implement all its most important features in a way that
would allow easy modification and creation of similarly styled geometric proofs.

![comparison](https://user-images.githubusercontent.com/7447349/52147564-2c240580-2678-11e9-9803-01a2b7c970da.png)

This version of the book is made in a way that makes modifications, including
translation, quite possible and even not that difficult. As a proof of concept
Russian translation was made. Plus, although Byrne's book looks cool as it is,
it might be helpful, as Edward Tufte points out, to supplement it with
conventional letter designations. So, there's also option for that (it is turned
on by default in the Russian version and can be easily turned on in the English
version).

![labels](https://user-images.githubusercontent.com/7447349/52147400-a30cce80-2677-11e9-9a2a-3b7f88419c90.png)

In addition to all the colorful byrnian stuff, this edition features generated
lettrines and vignettes, so there are no two identical initials in the whole
book.

![lettrines](https://user-images.githubusercontent.com/7447349/52147399-a2743800-2677-11e9-83a1-d25620253263.png)

The book itself (byrne_context.tex) and Russian translation
(byrne_ru_context.tex) are licensed under CC-BY-SA 4.0.

MetaPost library (byrne.mp) and lettrines generator (lettrines.mp) are licensed
under GPLv3 or later.

To build the book from command line run `context byrne_context.tex` within the
book directory. To generate lettrines run `mpost lettrines.mp` within
`\lettrines` directory.

See releases for prepared .pdf
