%    lettrine-generator 0.0.3
%    MetaPost lettrines generator
%    Copyright 2017 Sergey Slyusarev
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

input TEX;

TEXPRE("%&latex" & char(10) & "\documentclass{article}\usepackage[utf8]{inputenc}\usepackage[russian]{babel}\usepackage{gentium}\begin{document}");
TEXPOST("\end{document}");

%outputformat := "svg";

vardef log(expr x, b) =
    (mlog(x)/256)/(mlog(2)/256)
enddef;

% here we define some measures, common to all images
numeric lettrineSize, plateWidth, plateHeight, tileWidth, tileHeight, minimalDistance, branchDistance;
lettrineSize := 6/5cm;
plateWidth := 76mm;
plateHeight := 15mm;
tileWidth := 25mm;
tileHeight := 25mm;
minimalDistance := 1/25cm;
branchDistance := 2/3mm;

% this macro is taken directly from 'fiziko.mp', it simply takes first intersection time from the 'p' point of view
primarydef p firstIntersectionTimes q =
begingroup
    save t;
    pair t[];
    t1 := p intersectiontimes q;
    t2 := p intersectiontimes reverse(q);
    if xpart(t1) < xpart(t2):
        t3 := t1;
    else:
        t3 := (xpart(t2), length(q) - ypart(t2));
    fi;
    if xpart(t1) < 0: t3 := t2; fi;
    t3
endgroup
enddef;

% creates outline for a path, that determines how close two lines can get
vardef pathOutline (expr p, s) =
    path outputPath[];
    outputPath1 := point 0 of p;
    outputPath2 := point 0 of p;
    for i := 0 step s until length(p):
        if(abs(direction i of p) > 0):
            outputPath1 := outputPath1 -- (point i of p shifted (unitvector(direction i of p rotated 90) scaled minimalDistance));
            outputPath2 := outputPath2 -- (point i of p shifted (unitvector(direction i of p rotated -90) scaled minimalDistance));
        else:
            outputPath1 := outputPath1 -- (point i of p shifted (unitvector(direction i - 1/100 of p rotated 90) scaled minimalDistance));
            outputPath2 := outputPath2 -- (point i of p shifted (unitvector(direction i - 1/100 of p rotated -90) scaled minimalDistance));
        fi;
    endfor;
    outputPath1..(point length(p) of p shifted (unitvector(direction (length(p) - 1/100) of p) scaled minimalDistance))..reverse(subpath(1, length(outputPath2)) of outputPath2)--cycle
enddef;

vardef findRightSize (expr givenBranchPath, givenBranchOrigin, sty, minSize, maxSize, lDir, branchNumber, totalBranches, i) =
    save branchToCheck, branchIntersections, rv, s;
    path branchToCheck;
    numeric branchIntersections, rv, s;
    s := 1/2[minSize, maxSize];
    if (minSize > 0):
        rv := s;
    else:
        rv := 0;
    fi;
    branchToCheck := (givenBranchPath scaled s) shifted givenBranchOrigin;
    branchIntersections := checkIfIntersects(branchToCheck, branchNumber, totalBranches);
    if (i > 0) and (maxSize >= minBranchLength[sty]):
        if (branchIntersections = 0):
            rv := findRightSize(givenBranchPath, givenBranchOrigin, sty, s, maxSize, 1, branchNumber, totalBranches, i - 1);
        else:
            rv := findRightSize(givenBranchPath, givenBranchOrigin, sty, minSize, s, -1, branchNumber, totalBranches, i - 1);
        fi;
    else:
        if (branchIntersections <> 0):
            if (lDir = 1):
                rv := 1/2[s, maxSize];
            elseif (lDir = -1):
                rv := 1/2[minSize, s];
            fi;
        fi;
    fi;
    rv
enddef;

vardef positionBranch (expr branchNumber, totalBranches, branchStyleIndex) =
    save sproutPath, sproutMaxSize, sproutSize, successfulSproutLocation, sproutFittingIterations, sproutSizeOld, i, j, rp, startPoint, endPoint, currentBranchOrientation, currentBranchOrientationRelative;
    path sproutPath, rp;
    numeric sproutMaxSize, sproutSize, successfulSproutLocation, sproutFittingIterations, sproutSizeOld, i, j, startPoint, endPoint, currentBranchOrientation, currentBranchOrientationRelative;
    sproutSizeOld := 0;
    rp := (0, 0);
    successfulSproutLocation := -1;
    if (uniformdeviate(10)>2) or (cycle branchPath[branchNumber]):
        if (branchOrientation[branchNumber] = 0):
            currentBranchOrientation := 1;
        else:
            currentBranchOrientation := 0;
        fi;
        currentBranchOrientationRelative := 0;
    else:
        currentBranchOrientation := branchOrientation[branchNumber];
        currentBranchOrientationRelative := 1;
    fi;
    branchOrientation[totalBranches + 1] := currentBranchOrientation;
    endPoint := arclength(branchMeristem[branchNumber]);
    startPoint := uniformdeviate(1/2endPoint);
    for i := startPoint step branchDistance until 1/2endPoint + startPoint:
        j := (arctime i of branchMeristem[branchNumber]);
        if (checkBranch (branchNumber, j, currentBranchOrientationRelative) = 0)
            or (checkBranch (branchNumber, j, currentBranchOrientationRelative) > sproutSizeOld):
            if (checkBranch (branchNumber, j, currentBranchOrientationRelative) > 0):
                sproutMaxSize := checkBranch (branchNumber, j, currentBranchOrientationRelative);
            else:
                if cycle branchPath[branchNumber]:
                    sproutMaxSize := abs(ulcorner(branchPath[branchNumber]) - lrcorner(branchPath[branchNumber]));
                else:
                    sproutMaxSize := 1/2arclength(branchPath[branchNumber]);
                fi;
            fi;
            sproutFittingIterations := 2 + log(sproutMaxSize/branchScalePrecision, 2);
            if (currentBranchOrientation = 0):
                sproutPath := branchTemplate[currentBranchOrientation + 2branchStyleIndex] rotated (angle(direction j of branchMeristem[branchNumber]) - 90);
            else:
                sproutPath := branchTemplate[currentBranchOrientation + 2branchStyleIndex] rotated (angle(direction j of branchMeristem[branchNumber]) + 90);
            fi;
            sproutSize := findRightSize(sproutPath, (point j of branchMeristem[branchNumber]), branchStyleIndex, 0, sproutMaxSize, 0, branchNumber, totalBranches, sproutFittingIterations);
            if (arclength(sproutPath scaled sproutSize) <= minBranchLength[branchStyleIndex]):
                branchBuds[branchNumber] := addBranch (branchNumber, j, -1, currentBranchOrientationRelative);
            else:
                branchBuds[branchNumber] := addBranch (branchNumber, j, sproutSize, currentBranchOrientationRelative);
            fi;
            if (sproutSize > sproutSizeOld):
                rp := sproutPath scaled sproutSize shifted (point j of branchMeristem[branchNumber]);
                sproutSizeOld := sproutSize;
                successfulSproutLocation := j;
            fi;
        fi;
    endfor;
    if (successfulSproutLocation >= 0):
        branchBuds[branchNumber] := addBranch (branchNumber, successfulSproutLocation, -1, currentBranchOrientationRelative);
    fi;
    rp
enddef;

vardef checkIfIntersects (expr pathItself, l, n) =
    save rv, m, t;
    numeric rv, t;
    rv := 0;
    t := xpart(pathItself firstIntersectionTimes branchOutline[l]);
    if (xpart((subpath(t + 1/100, length(pathItself)) of pathItself) intersectiontimes branchOutline[l]) >= 0)
        or (xpart((subpath(1/100, length(pathItself)) of pathItself) intersectiontimes branchOutline[l]) < 0)
        or (xpart((subpath(1/100, length(pathItself)) of pathItself) intersectiontimes branchPath[l]) >= 0)
        or (arclength(subpath (0, t) of pathItself) > 3minimalDistance)
        or (t < 0):
        rv := rv + 1;
    else:
        for m := 0 step 1 until n:
            if (l <> m)
                and ((xpart(pathItself intersectiontimes branchOutline[m]) >= 0)
                    or (xpart(pathItself intersectiontimes branchPath[m]) >= 0)):
                rv := rv + 1;
            fi;
        endfor;
    fi;
    rv
enddef;

vardef generateBranchesTemplate (expr p) =
    save rv;
    path rv;
    rv := (0, 0);
    for i := 1 step 1 until round(arclength(p)/branchDistance):
        rv := rv -- (0, 0);
    endfor;
    rv
enddef;

vardef addBranch (expr pn, l, s, o) =
    save rv, loc, p;
    path rv;
    pair p;
    numeric loc;
    loc := round((arclength(subpath(0, l) of branchMeristem[pn]))/branchDistance);
    if (o = 0):
        p := (s, ypart(point loc of branchBuds[pn]));
    else:
        p := (xpart(point loc of branchBuds[pn]), s);
    fi;
    if (loc < length(branchBuds[pn])) and (loc > 0):
        rv := (subpath (0, loc-1) of branchBuds[pn])
            -- p
            -- (subpath (loc+1, length(branchBuds[pn])) of branchBuds[pn]);
    elseif (loc = 0):
        rv := p
            -- (subpath (loc+1, length(branchBuds[pn])) of branchBuds[pn]);
    elseif (loc = length(branchBuds[pn])):
        rv := (subpath (0, loc-1) of branchBuds[pn])
            -- p;
    fi;
    rv
enddef;

vardef checkBranch (expr pn, l, o) =
    save rv, loc;
    numeric loc, rv;
    loc := round((arclength(subpath(0, l) of branchMeristem[pn]))/branchDistance);
    if (o = 0):
        rv := xpart(point loc of branchBuds[pn]);
    else:
        rv := ypart(point loc of branchBuds[pn]);
    fi;
    rv
enddef;

def makeAdjacentTiles (expr n) =
    for xs := -1 step 1 until 1:
        for ys := -1 step 1 until 1:
            if (xs <> 0) or (ys <> 0):
                totalBranchesNumber := totalBranchesNumber + 1;
                branchPath[totalBranchesNumber] := branchPath[n] shifted (xs*tileWidth, ys*tileHeight);
                branchMeristem[totalBranchesNumber] := branchMeristem[n] shifted (xs*tileWidth, ys*tileHeight);
                branchOutline[totalBranchesNumber] := branchOutline[n] shifted (xs*tileWidth, ys*tileHeight);
                branchBuds[totalBranchesNumber] := branchBuds[n];
                branchOrientation[totalBranchesNumber] := branchOrientation[n];
                branchIsActive[totalBranchesNumber] := false;
            fi;
        endfor;
    endfor;
enddef;

figNum := 0;

picture currentLetter, cL;
path branchPath[], branchMeristem[], branchBuds[], branchOutline[], branchTemplate[], candidateBranch;
numeric branchOrientation[], symMode, numberOfIterations, totalBranchesNumber, branchScalePrecision;
numeric ln[], ll, lc;
boolean branchIsActive[];
pair branchMeristemSpan[];
string shuffledNumbers;
picture lettrineImage;

branchScalePrecision := 1/6mm;
branchTemplate0 := ((1/2,0) for a := 60 step 60 until 360: .. (cosd(a), sind(a)) scaled 1/2(1-a/360) endfor) shifted (-1/2, 0);
branchTemplate1 := branchTemplate0 yscaled -1;
branchMeristemSpan0 := (1/2, length(branchTemplate0) - 2);
branchTemplate2 := ((1/2,0) for a := 60 step 60 until 630: .. (cosd(a), sind(a)) scaled 1/2(1-a/540) endfor) shifted (-1/2, 0);
branchTemplate3 := branchTemplate2 yscaled -1;
branchMeristemSpan1 := (1/2, length(branchTemplate2) - 3);

string lettrinesFile, l, ls[];
lettrinesFile := "lettrineslist.txt";
ll := 0;

forever:
    l := readfrom(lettrinesFile);
    exitif (l = EOF);
    lc := 0;
    if (ll = 0):
        ls[ll] := l;
        ln[ll] := 0;
        ll := ll + 1;
    else:
        echk := 0;
        for i := 0 step 1 until ll - 1:
            if (l = ls[i]):
                ln[i] := ln[i] + 1;
                echk := 1;
                lc := ln[i];
            fi;
        endfor;
        if (echk = 0):
            ls[ll] := l;
            ln[ll] := 0;
            lc := 0;
            ll := ll + 1
        fi;
    fi;
    figNum := figNum + 1;
    outputtemplate := l & decimal(lc) & ".mps";
    beginfig(figNum);
        lettrineImage := image(
            if ((l <> "plate") and (l <> "tile")):
                totalBranchesNumber := 0;
                branchPath0 := (0,0)--(0, lettrineSize)--(lettrineSize, lettrineSize)--(lettrineSize, 0)--cycle;
                branchMeristem0 := branchPath0;
                branchOutline0 := pathOutline(branchPath0, 1/2);
                branchBuds0 := generateBranchesTemplate(branchMeristem0);
                branchOrientation0 := 0;
                branchIsActive0 := true;
                currentLetter := TEX(l);
                for tp within currentLetter:
                    cL := (glyph (ASCII textpart tp) of (fontpart tp)) scaled 1/36;
                    cL := cL shifted -1/2[urcorner(cL), llcorner(cL)] shifted (1/2lettrineSize, 1/2lettrineSize);
                    draw cL;
                    for item within cL:
                        totalBranchesNumber := totalBranchesNumber + 1;
                        branchPath[totalBranchesNumber] := pathpart item;
                        branchMeristem[totalBranchesNumber] := branchPath[totalBranchesNumber];
                        branchOutline[totalBranchesNumber] := pathOutline(branchPath[totalBranchesNumber], 1/8);
                        branchBuds[totalBranchesNumber] := generateBranchesTemplate(branchMeristem[totalBranchesNumber]);
                        branchOrientation[totalBranchesNumber] := 0;
                        branchIsActive[totalBranchesNumber] := true;
                    endfor;
                endfor;
                symMode := 0;
                numberOfIterations := 12;
                minBranchLength[0] := 1/6cm;
            elseif (l = "plate"):
                branchPath0 := (-plateWidth/2,-plateHeight/2)--(-plateWidth/2, plateHeight/2)--(plateWidth/2, plateHeight/2)--(plateWidth/2, -plateHeight/2)--cycle;
                branchMeristem0 := branchPath0;
                branchPath1 := (branchTemplate0 rotated 15) scaled 18mm;
                branchMeristem1 := subpath (0, ypart(branchMeristemSpan0)) of branchPath1;
                branchPath2 := branchPath1 rotated 180;
                branchMeristem2 := subpath (0, ypart(branchMeristemSpan0)) of branchPath2;
                for i := 0 step 1 until 2:
                    totalBranchesNumber := i;
                    branchOutline[i] := pathOutline(branchPath[i], 1/2);
                    branchBuds[i] := generateBranchesTemplate(branchMeristem[i]);
                    branchOrientation[i] := 0;
                    branchIsActive[i] := true;
                endfor;
                branchIsActive[0] := false;
                symMode := 1;
                numberOfIterations := 12;
                minBranchLength[0] := 1/4cm;
            elseif (l = "tile"):
                branchPath0 := (-tileWidth,-tileHeight)--(-tileWidth, tileHeight)--(tileWidth, tileHeight)--(tileWidth, -tileWidth)--cycle;
                branchMeristem0 := branchPath0;
                branchPath1 := (branchTemplate0 rotated uniformdeviate(360)) scaled 6mm;
                branchMeristem1 := subpath (0, ypart(branchMeristemSpan0)) of branchPath1;
                branchPath2 := (branchPath1 scaled 2) rotated 180;
                branchMeristem2 := (branchMeristem1 scaled 2) rotated 180;
                for i := 0 step 1 until 2:
                    totalBranchesNumber := i;
                    branchOutline[i] := pathOutline(branchPath[i], 1/2);
                    branchBuds[i] := generateBranchesTemplate(branchMeristem[i]);
                    branchOrientation[i] := 0;
                    branchIsActive[i] := true;
                endfor;
                branchIsActive[0] := false;
                makeAdjacentTiles(1);
                makeAdjacentTiles(2);
                symMode := 2;
                numberOfIterations := 12;
                minBranchLength[0] := 1/4cm;
            fi;
            minBranchLength1 := 3/2minBranchLength0;
            for nn := 0 step 1 until numberOfIterations:
                shuffledNumbers := "";
                for i := 0 step 1 until totalBranchesNumber:
                    if (uniformdeviate(1) > 1/2):
                        shuffledNumbers := shuffledNumbers & "," & decimal(i);
                    else:
                        shuffledNumbers := decimal(i) & "," & shuffledNumbers;
                    fi;
                endfor;
                shuffledNumbers := substring(0, length(shuffledNumbers)-1) of shuffledNumbers;
                for i=scantokens(shuffledNumbers):
                    if (xpart(urcorner(branchBuds[i])) >= 0) and (branchIsActive[i]):
                        if (uniformdeviate(1) > 1/2):
                            sty := 0;
                        else:
                            sty := 1;
                        fi;
                        candidateBranch := positionBranch(i, totalBranchesNumber, sty);
                        if (arclength(candidateBranch) >= minBranchLength[sty]):
                            totalBranchesNumber := totalBranchesNumber + 1;
                            branchPath[totalBranchesNumber] := candidateBranch;
                            branchMeristem[totalBranchesNumber] := subpath branchMeristemSpan[sty] of branchPath[totalBranchesNumber];
                            branchOutline[totalBranchesNumber] := pathOutline(branchPath[totalBranchesNumber], 1/2);
                            branchBuds[totalBranchesNumber] := generateBranchesTemplate(branchMeristem[totalBranchesNumber]);
                            branchIsActive[totalBranchesNumber] := true;
                            if(symMode = 1):
                                totalBranchesNumber := totalBranchesNumber + 1;
                                branchPath[totalBranchesNumber] := branchPath[totalBranchesNumber-1] rotated 180;
                                branchMeristem[totalBranchesNumber] := branchMeristem[totalBranchesNumber-1] rotated 180;
                                branchOutline[totalBranchesNumber] := branchOutline[totalBranchesNumber-1] rotated 180;
                                branchBuds[totalBranchesNumber] := branchBuds[totalBranchesNumber-1];
                                branchOrientation[totalBranchesNumber] := branchOrientation[totalBranchesNumber-1];
                                branchIsActive[totalBranchesNumber] := true;
                            fi;
                            if(symMode = 2):
                                makeAdjacentTiles(totalBranchesNumber);
                            fi;
                        fi;
                    fi;
                endfor;
            endfor;
            for i := 0 step 1 until totalBranchesNumber:
                if branchIsActive[i]:
                    draw branchPath[i] if (i=0): withpen pensquare scaled 1/3mm else: withpen pencircle scaled 1/5mm fi;
                    if (not cycle branchPath[i]):
                        draw (((fullcircle shifted (1/2, 0)) scaled 1/60cm) rotated (if (branchOrientation[i]=1):-90 else:90 fi + angle(direction length(branchPath[i]) of branchPath[i]))) shifted point length(branchPath[i]) of branchPath[i] withpen pencircle scaled 1/5mm;
                    fi;
                fi;
            endfor;
        );
        lettrineImage := lettrineImage shifted -llcorner(lettrineImage);
        draw lettrineImage;
    endfig;
endfor;
end
