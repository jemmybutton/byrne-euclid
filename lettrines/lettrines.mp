%    lettrine-generator 0.0.3
%    MetaPost lettrines generator
%    Copyright 2018 Sergey Slyusarev
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

TEXPRE("%&latex" & char(10) & "\documentclass{article}\usepackage[utf8]{inputenc}\usepackage[russian]{babel}\begin{document}"); %\usepackage{tempora}
TEXPOST("\end{document}");

outputformat := "eps";

vardef log(expr x, b) =
    (mlog(x)/256)/(mlog(2)/256)
enddef;

% here we define some measures, common to all images
numeric lettrineSize, plateWidth, plateHeight, tileWidth, tileHeight, borderWidth, minimalDistance, budDistance;
lettrineSize := 3/2cm;
plateWidth := 76mm;
plateHeight := 15mm;
tileWidth := 25mm;
tileHeight := 25mm;
borderWidth := 1mm;

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
    save outputPath;
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
    save sproutPath, sproutMaxSize, sproutSize, sproutBaseDirection, successfulSproutLocation, sproutFittingIterations, sproutSizeOld, i, j, rp, startPoint, endPoint, currentBranchOrientationRelative, sideActive;
    path sproutPath, rp;
    pair sproutBaseDirection;
    numeric sproutMaxSize, sproutSize, successfulSproutLocation, sproutFittingIterations, sproutSizeOld, i, j, startPoint, endPoint, currentBranchOrientationRelative;
    boolean sideActive[];
    sproutSizeOld := 0;
    rp := (0, 0);
    successfulSproutLocation := -1;
    if (uniformdeviate(10)>5) or (cycle branchPath[branchNumber]):
        if (branchOrientation[branchNumber] = 0):
            candidateBranchOrientation := 1;
        else:
            candidateBranchOrientation := 0;
        fi;
        currentBranchOrientationRelative := 0;
    else:
        candidateBranchOrientation := branchOrientation[branchNumber];
        currentBranchOrientationRelative := 1;
    fi;
    sideActive[0] := (xpart(urcorner(branchBuds[branchNumber])) >= 0);
    sideActive[1] := (ypart(urcorner(branchBuds[branchNumber])) >= 0);
    if (not sideActive[currentBranchOrientationRelative]) and (not cycle branchPath[branchNumber]):
        currentBranchOrientationRelative := abs(currentBranchOrientationRelative - 1);
        candidateBranchOrientation := abs(candidateBranchOrientation - 1);
    fi;
    if sideActive[currentBranchOrientationRelative]:
        startPoint := 0;
        endPoint := arclength(branchMeristem[branchNumber]);
        for i := startPoint step budDistance until endPoint:
            j := (arctime i of branchMeristem[branchNumber]);
            if (checkBud (branchNumber, j, currentBranchOrientationRelative) = 0)
                or (checkBud (branchNumber, j, currentBranchOrientationRelative) > sproutSizeOld):
                if (checkBud (branchNumber, j, currentBranchOrientationRelative) > 0):
                    sproutMaxSize := checkBud (branchNumber, j, currentBranchOrientationRelative);
                else:
                    if cycle branchPath[branchNumber]:
                        sproutMaxSize := abs(ulcorner(branchPath[branchNumber]) - lrcorner(branchPath[branchNumber]));
                    else:
                        sproutMaxSize := 1/2arclength(branchPath[branchNumber]);
                    fi;
                fi;
                sproutFittingIterations := log(sproutMaxSize/branchScalePrecision, 2);
                sproutBaseDirection := direction j of branchMeristem[branchNumber];
                if sproutBaseDirection = (0, 0):
                    sproutBaseDirection := 1/2[direction (j-1/100) of branchMeristem[branchNumber], direction (j+1/100) of branchMeristem[branchNumber]];
                fi;
                if (candidateBranchOrientation = 0):
                    sproutPath := branchTemplate[candidateBranchOrientation + 2branchStyleIndex] rotated (angle(sproutBaseDirection) - 90);
                else:
                    sproutPath := branchTemplate[candidateBranchOrientation + 2branchStyleIndex] rotated (angle(sproutBaseDirection) + 90);
                fi;
                sproutSize := findRightSize(sproutPath, (point j of branchMeristem[branchNumber]), branchStyleIndex, 0, 3minBranchLength[branchStyleIndex], 0, branchNumber, totalBranches, sproutFittingIterations);
                if (arclength(sproutPath scaled sproutSize) <= minBranchLength[branchStyleIndex]):
                    addBud (branchNumber, j, -1, currentBranchOrientationRelative);
                else:
                    addBud (branchNumber, j, sproutSize, currentBranchOrientationRelative);
                fi;
                if (sproutSize > sproutSizeOld):
                    rp := sproutPath scaled sproutSize shifted (point j of branchMeristem[branchNumber]);
                    sproutSizeOld := sproutSize;
                    successfulSproutLocation := j;
                fi;
            fi;
        endfor;
        if (successfulSproutLocation >= 0):
            addBud (branchNumber, successfulSproutLocation, -1, currentBranchOrientationRelative);
        fi;
    fi;
    rp
enddef;

vardef checkIfIntersects (expr pathItself, l, n) =
    save rv, m, t, s;
    numeric rv, t[], s[];
    rv := 0;
    t0 := xpart(pathItself firstIntersectionTimes branchOutline[l]);
    s0 := 1/100;
    if cycle pathItself:
        t1 := xpart(reverse(pathItself) firstIntersectionTimes branchOutline[l]);
        s1 := s0;
    else:
        t1 := 0;
        s1 := 0;
    fi;
    if (xpart((subpath(t0 + s0, length(pathItself) - t1 - s1) of pathItself) intersectiontimes branchOutline[l]) >= 0)
        or (xpart((subpath(s0, length(pathItself) - s1) of pathItself) intersectiontimes branchOutline[l]) < 0)
        or (xpart((subpath(s0, length(pathItself) - s1) of pathItself) intersectiontimes branchPath[l]) >= 0)
        or (arclength(subpath (0, t0) of pathItself) > 3minimalDistance)
        or (t0 < 0):
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
    for i := 1 step 1 until round(arclength(p)/budDistance):
        rv := rv -- (0, 0);
    endfor;
    rv
enddef;

def addBud (expr pn, l, s, o) =
    begingroup
    save rv, loc, p, pnr;
    path rv;
    pair p;
    numeric loc, pnr;
    if (branchIsCloneOf[pn] >= 0):
        pnr := branchIsCloneOf[pn];
    else:
        pnr := pn;
    fi;
    loc := round((arclength(subpath(0, l) of branchMeristem[pnr]))/budDistance);
    if (o = 0):
        p := (s, ypart(point loc of branchBuds[pnr]));
    else:
        p := (xpart(point loc of branchBuds[pnr]), s);
    fi;
    if (loc < length(branchBuds[pnr])) and (loc > 0):
        rv := (subpath (0, loc-1) of branchBuds[pnr])
            -- p
            -- (subpath (loc+1, length(branchBuds[pnr])) of branchBuds[pnr]);
    elseif (loc <= 0):
        rv := p
            -- (subpath (loc+1, length(branchBuds[pnr])) of branchBuds[pnr]);
    elseif (loc >= length(branchBuds[pnr])):
        rv := (subpath (0, loc-1) of branchBuds[pnr])
            -- p;
    fi;
    branchBuds[pnr] := rv;
    branchBuds[pn] := rv;
    endgroup
enddef;

vardef checkBud (expr pn, l, o) =
    save rv, loc;
    numeric rv, loc;
    loc := round((arclength(subpath(0, l) of branchMeristem[pn]))/budDistance);
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
                branchIsActive[totalBranchesNumber] := 0;
                branchStyle[totalBranchesNumber] := branchStyle[n];
                branchIsCloneOf[totalBranchesNumber] := n;
            fi;
        endfor;
    endfor;
enddef;

def addBranch (expr p, o, a, sty, cn) =
    totalBranchesNumber := totalBranchesNumber + 1;
    branchPath[totalBranchesNumber] := p;
    if (sty < 0):
        branchMeristem[totalBranchesNumber] := p;
    else:
        branchMeristem[totalBranchesNumber] := subpath branchMeristemSpan[sty] of p;
    fi;
    branchBuds[totalBranchesNumber] := generateBranchesTemplate(branchMeristem[totalBranchesNumber]);
    branchOutline[totalBranchesNumber] := pathOutline(branchPath[totalBranchesNumber], 1/2);
    branchOrientation[totalBranchesNumber] := o;
    branchIsActive[totalBranchesNumber] := a;
    branchStyle[totalBranchesNumber] := sty;
    branchIsCloneOf[totalBranchesNumber] := cn;
enddef;

figNum := 0;

picture currentLetter, cL;
path branchPath[], branchMeristem[], branchBuds[], branchOutline[], branchTemplate[], candidateBranch;
numeric branchOrientation[], branchStyle[], branchIsCloneOf[], branchIsActive[], candidateBranchOrientation, symMode, numberOfIterations, totalBranchesNumber, branchScalePrecision;
numeric ln[], ll, lc;
pair branchMeristemSpan[];
string shuffledNumbers;
picture lettrineImage;

branchTemplate0 := ((1/2,0) for a := 60 step 60 until 360: .. (cosd(a), sind(a)) scaled 1/2(1-a/360) endfor) shifted (-1/2, 0);
branchTemplate1 := branchTemplate0 yscaled -1;
branchMeristemSpan0 := (1/2, length(branchTemplate0) - 2);
branchTemplate2 := ((1/2,0) for a := 60 step 60 until 630: .. (cosd(a), sind(a)) scaled 1/2(1-a/540) endfor) shifted (-1/2, 0);
branchTemplate3 := branchTemplate2 yscaled -1;
branchMeristemSpan1 := (1/2, length(branchTemplate2) - 3);
branchTemplate4 := (0, 0){dir(90)} .. (-1/2, 1) .. (-1, 1/2) .. (-1/2, 2/3) .. {dir(-90)} cycle;
branchTemplate5 := (branchTemplate4 rotated 30) yscaled -1;
branchMeristemSpan2 := (1/5, 1/4);
branchTemplate6 := (0, 0){dir(90)} .. (-1/2, 1) .. {dir(-90)}(-1, 1/2){dir(60)} .. {dir(-90)} cycle;
branchTemplate7 := (branchTemplate6 rotated 45) yscaled -1;
branchMeristemSpan3 := (1/5, 1/4);
%branchTemplate4 := ((1/2,0) for a := 60 step 60 until 630: .. (cosd(a), sind(a)) scaled 1/2(1-a/540) endfor) shifted (-1/2, 0);
%branchTemplate5 := branchTemplate4 yscaled -1;
%branchMeristemSpan2 := (1/2, length(branchTemplate2) - 3);

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
            branchScalePrecision := 1/8mm;
            totalBranchesNumber := -1;
            if ((l <> "plate") and (l <> "tile")):
                symMode := 0;
                numberOfIterations := 8;
                minBranchLength[0] := 1/6cm;
                minimalDistance := 1/18cm;
                budDistance := 1/4mm;
                addBranch (reverse(unitsquare) scaled lettrineSize, 0, 0, -1, -1);
                fill branchPath0 withcolor black;
                addBranch (reverse(unitsquare) scaled (lettrineSize - borderWidth) shifted (1/2borderWidth, 1/2borderWidth), 0, 1, -1, -1);
                currentLetter := TEX(l);
                for tp within currentLetter:
                    cL := (glyph (ASCII textpart tp) of (fontpart tp)) scaled (1/35);
                    cL := cL shifted -1/2[urcorner(cL), llcorner(cL)] shifted (1/2lettrineSize, 1/2lettrineSize);
                    for item within cL:
                        if (colorpart item) = 0:
                            fill (pathpart item) withcolor white;
                        else:
                            fill (pathpart item) withcolor black;
                        fi;
                        addBranch (pathpart item, 0, 1, -1, -1);
                    endfor;
                endfor;
            elseif (l = "plate"):
                symMode := 1;
                numberOfIterations := 12;
                minBranchLength[0] := 1/5cm;
                minimalDistance := 1/20cm;
                budDistance := 2/3mm;
                addBranch (
                    ((unitsquare shifted (-1/2,-1/2)) xscaled plateWidth) yscaled plateHeight,
                    0, 0, -1, -1);
                fill branchPath0 withcolor black;
                addBranch (
                    ((reverse(unitsquare) shifted (-1/2,-1/2)) xscaled (plateWidth - borderWidth)) yscaled (plateHeight - borderWidth),
                    0, 1, -1, -1);
                addBranch (
                    (branchTemplate0 rotated 15) scaled 18mm,
                    0, 1, 0, -1);
                addBranch (
                    branchPath2 rotated 180,
                    0, 1, 0, -1);
            elseif (l = "tile"):
                symMode := 2;
                numberOfIterations := 10;
                minBranchLength[0] := 1/4cm;
                minimalDistance := 1/20cm;
                budDistance := 2/3mm;
                addBranch (
                    ((unitsquare shifted (-1/2,-1/2)) xscaled 2tileWidth) yscaled 2tileHeight,
                    0, 0, -1, -1);
                addBranch (
                    (branchTemplate0 rotated uniformdeviate(360)) scaled 6mm,
                    0, 1, 0, -1);
                addBranch (
                    (branchPath1 scaled 2) rotated 180,
                    0, 1, 0, 1);
                makeAdjacentTiles(1);
                makeAdjacentTiles(2);
            fi;
            minBranchLength1 := 3/2minBranchLength0;
            minBranchLength2 := 1/2minBranchLength0;
            minBranchLength3 := 1/2minBranchLength0;
            boolean firstPart;
            firstPart := true;
            for nn := 0 step 1 until numberOfIterations:
                if (nn > 1/2numberOfIterations) and firstPart:
                    branchScalePrecision := 1/12mm;
                    firstPart := false;
                    minimalDistance := 1/20cm;
                    budDistance := 1/10mm;
                    for i := 1 step 1 until totalBranchesNumber:
                        if (branchIsActive[i] = 1):
                            branchBuds[i] := generateBranchesTemplate(branchMeristem[i]);
                            branchOutline[i] := pathOutline(branchPath[i], 1/2);
                        fi;
                    endfor;
                fi;
                shuffledNumbers := "";
                for i := 0 step 1 until totalBranchesNumber:
                    if ((xpart(urcorner(branchBuds[i])) >= 0) or (ypart(urcorner(branchBuds[i])) >= 0)) and (branchIsActive[i] = 1):
                        if length(shuffledNumbers) = 0:
                            shuffledNumbers := decimal(i);
                        else:
                            if (uniformdeviate(1) > 1/2):
                                shuffledNumbers := shuffledNumbers & ", " & decimal(i);
                            else:
                                shuffledNumbers := decimal(i) & ", " & shuffledNumbers;
                            fi;
                        fi;
                    fi;
                endfor;
                for i = scantokens(shuffledNumbers):
                    if firstPart:
                        if (uniformdeviate(1) > 1/2):
                            sty := 0;
                        else:
                            sty := 1;
                        fi;
                    else:
                        if (uniformdeviate(1) > 1/2):
                            sty := 2;
                        else:
                            sty := 3;
                        fi;
                    fi;
                    candidateBranch := positionBranch(i, totalBranchesNumber, sty);
                    if (arclength(candidateBranch) >= minBranchLength[sty]):
                        addBranch (candidateBranch, candidateBranchOrientation, 1, sty, -1);
                        if(symMode = 1):
                            x := totalBranchesNumber;
                            addBranch (candidateBranch rotated 180, candidateBranchOrientation, 2, sty, x);
                        fi;
                        if(symMode = 2):
                            makeAdjacentTiles(totalBranchesNumber);
                        fi;
                    fi;
                endfor;
            endfor;
            for i := 0 step 1 until totalBranchesNumber:
                if (branchIsActive[i] > 0):
                    if branchStyle[i] >= 2:
                        draw branchPath[i] withpen pencircle scaled 1/12mm withcolor white;
                        fill branchPath[i] withcolor white;
                    else:
                        draw branchPath[i] if (i=0): withpen pensquare scaled 1/3mm else: withpen pencircle scaled 1/6mm fi withcolor white;
                    fi;
                    if (not cycle branchPath[i]):
                        draw (((fullcircle shifted (1/2, 0)) scaled 1/60cm) rotated (if (branchOrientation[i]=1):-90 else:90 fi + angle(direction length(branchPath[i]) of branchPath[i]))) shifted point length(branchPath[i]) of branchPath[i] withpen pencircle scaled 1/5mm withcolor white;
                    fi;
                %else:
                %    draw branchPath[i] withcolor red;
                fi;
            endfor;
        );
        lettrineImage := lettrineImage shifted -llcorner(lettrineImage);
        draw lettrineImage;
    endfig;
endfor;
end
