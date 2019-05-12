%    lettrine-generator 0.1.0a
%    MetaPost lettrines generator
%    Copyright 2019 Sergey Slyusarev
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

TEXPRE("%&latex" & char(10) & "\documentclass{article}\usepackage[utf8]{inputenc}\usepackage[russian]{babel}\begin{document}");
TEXPOST("\end{document}");

outputformat := "eps";

numeric lettrineSize, plateWidth, plateHeight, tileWidth, tileHeight, borderWidth;
lettrineSize := 15mm;
plateWidth := 76mm;
plateHeight := 15mm;
tileWidth := 25mm;
tileHeight := 25mm;
borderWidth := 1mm;

vardef log(expr x, b) =
    (mlog(x)/256)/(mlog(2)/256)
enddef;

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

vardef pathOutline (expr p, d) =
    save outlinepen;
    pen outlinepen;
    outlinepen = makepen(for i := 0 step 10 until 350: dir(i) scaled d -- endfor cycle);
    envelope outlinepen of p
enddef;

vardef shuffleNumbers (expr n) =
    save shuffledNumbers;
    string shuffledNumbers;
    shuffledNumbers := "";
    for i := 0 step 1 until n:
        if length(shuffledNumbers) = 0:
            shuffledNumbers := decimal(i);
        else:
            if (uniformdeviate(1) > 1/2):
                shuffledNumbers := shuffledNumbers & ", " & decimal(i);
            else:
                shuffledNumbers := decimal(i) & ", " & shuffledNumbers;
            fi;
        fi;
    endfor;
    shuffledNumbers
enddef;

string lettrinesFile, lettrineLine, lettrineSymbol[];
numeric lettrineCount[], lettrine lettrineNumber;
picture lettrineImage, currentLetter;
lettrinesFile := "lettrineslist.txt";
lettrineNumber := 0;

path branchPath[], branchOutline[], meristemPath[];
pair branchOrigin[];
string branchType[], meristemType[];
numeric branchNumber, branchAngle[], branchScale[], meristemOrientation[], meristemParentBranch[];
boolean branchActive[], branchFlipped[];

vardef makeBranchPath@#(expr brOrigin, brAngle, brScale, brFlipped) =
    applyBranchTransform(branchTemplate@#, brOrigin, brAngle, brScale, brFlipped, stemVector@#)
enddef;

vardef applyBranchTransform (expr p, brOrigin, brAngle, brScale, brFlipped, brStem) =
    save somePath, someStem;
    path somePath;
    pair someStem;
    if brFlipped:
        somePath := p yscaled -1;
        if cycle p:
            somePath := reverse somePath;
        fi;
        someStem := brStem yscaled -1;
    else:
        somePath := p;
        someStem := brStem;
    fi;
    if brScale > 0:
        somePath := somePath scaled (brScale*scaleFactor);
    fi;
    somePath := somePath shifted (someStem*outlineThickness);
    (somePath rotated brAngle) shifted brOrigin
enddef;

vardef addBranch@#(expr brPath, brActive, brOrigin, brAngle, brScale, brFlipped, postpone) =
    save brPathToStore;
    path brPathToStore;
    if (length(str @#) > 0):
        branchType[branchNumber + 1] := str @#;
        brPathToStore := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
    else:
        branchType[branchNumber + 1] := "generic";
        brPathToStore := brPath;
    fi;
    branchPath[branchNumber + 1] := brPathToStore;
    branchOutline[branchNumber + 1] := pathOutline(brPathToStore, outlineThickness);
    branchActive[branchNumber + 1] := brActive;
    branchOrigin[branchNumber + 1] := brOrigin;
    branchAngle[branchNumber + 1] := brAngle;
    branchScale[branchNumber + 1] := brScale;
    branchFlipped[branchNumber + 1] := brFlipped;
    if not postpone:
        toNextBranch;
    fi;
enddef;

vardef toNextBranch =
    branchNumber := branchNumber + 1;
enddef;

vardef addMeristem@#(expr mrPath, mrOrientation, mrParentBranch) =
    meristemNumber := meristemNumber + 1;
    meristemPath[meristemNumber] := mrPath;
    meristemOrientation[meristemNumber] := mrOrientation;
    meristemParentBranch[meristemNumber] := mrParentBranch;
    if (length(str @#) > 0):
        meristemType[meristemNumber] := str @#;
    else:
        meristemType[meristemNumber] := "generic";
    fi;
enddef;

vardef addBranchMeristem =
    save mrOrientation, mrPath;
    path mrPath;
    numeric mrOrientation;
    for i := 0 step 1 until branchMeristemCount.scantokens(branchType[branchNumber]) - 1:
        mrOrientation := branchMeristemOrientation.scantokens(branchType[branchNumber])[i];
        mrPath := branchMeristem.scantokens(branchType[branchNumber])[i];
        if branchFlipped[branchNumber]:
            mrOrientation := -mrOrientation;
            mrPath := mrPath yscaled -1;
            mrPath := reverse(mrPath);
        fi;
        mrPath := mrPath scaled scaleFactor;
        addMeristem.scantokens(branchType[branchNumber])(
            ((mrPath
                scaled branchScale[branchNumber])
                rotated branchAngle[branchNumber])
                shifted branchOrigin[branchNumber],
            mrOrientation,
            branchNumber);
    endfor;
enddef;

vardef addSymBranches =
    save i, j, brOrigin;
    pair brOrigin;
    if symMode = 1:
        addBranch.scantokens(branchType[branchNumber])(
            (0, 0),
            branchActive[branchNumber],
            branchOrigin[branchNumber] rotated 180,
            branchAngle[branchNumber] + 180,
            branchScale[branchNumber],
            branchFlipped[branchNumber],
            false);
    elseif symMode = 2:
        brOrigin := branchOrigin[branchNumber];
        for i := -1 step 1 until 1:
            for j := -1 step 1 until 1:
                if (i <> 0) or (j <> 0):
                    addBranch.scantokens(branchType[branchNumber])(
                        (0, 0),
                        false,
                        brOrigin shifted (i*tileWidth, j*tileHeight),
                        branchAngle[branchNumber],
                        branchScale[branchNumber],
                        branchFlipped[branchNumber],
                        false);
                fi;
            endfor;
        endfor;
    fi;
enddef;

vardef addBud@#(expr mrNumber, mrLoc, s, w) =
    save mrLocTime, l;
    mrLocTime := floor(mrLoc/meristemResolution);
    if not known meristemBuds.@#[mrNumber]:
        meristemBuds.@#[mrNumber] := (branchMaxSize@#, 0);
        for i := 1 step 1 until floor(arclength(meristemPath[mrNumber])/meristemResolution):
            meristemBuds.@#[mrNumber] := meristemBuds.@#[mrNumber] -- (branchMaxSize@#, 0);
        endfor;
    fi;
    l := length(meristemBuds.@#[mrNumber]);
    if l > w + 2:
        if mrLocTime < w:
            meristemBuds.@#[mrNumber] :=
                for i := 1 step 1 until w: (s, 0) -- endfor
                (subpath (w, l) of meristemBuds.@#[mrNumber]);
        elseif mrLocTime > l - w:
            meristemBuds.@#[mrNumber] :=
                (subpath (0, l - w) of meristemBuds.@#[mrNumber])
                for i := 1 step 1 until w: -- (s, 0) endfor;
        else:
            meristemBuds.@#[mrNumber] :=
                (subpath (0, mrLocTime - ((w + 1)/2)) of meristemBuds.@#[mrNumber])
                for i := 1 step 1 until w: -- (s, 0) endfor
                -- (subpath (mrLocTime + ((w + 1)/2), l) of meristemBuds.@#[mrNumber]);
        fi;
    else:
        meristemBuds.@#[mrNumber] := (s, 0) for i := 1 step 1 until l: -- (s, 0) endfor;
    fi;
enddef;

vardef checkBud@#(expr mrNumber, mrLoc) =
    save mrLocTime, branchExists, rv;
    boolean branchExists;
    branchExists := false;
    if str @# <> "common":
        if checkBud.common(mrNumber, mrLoc) = 0:
            branchExists := true;
        fi;
    fi;
    if not branchExists:
        mrLocTime := floor(mrLoc/meristemResolution);
        if not known meristemBuds.@#[mrNumber]:
            rv := branchMaxSize@#;
        else:
            rv := xpart(point mrLocTime of meristemBuds.@#[mrNumber]);
        fi;
    else:
        rv := 0;
    fi;
    rv
enddef;

vardef checkIfBudsLeft@#(expr mrNumber) =
    if not known meristemBuds.@#[mrNumber]:
        true
    else:
        xpart(urcorner(meristemBuds.@#[mrNumber])) >= branchMinSize@#
    fi
enddef;

vardef positionBranch@#(expr mrNumber) =
    save brTemplate, mrTime, brAngle, brOrigin, brSizeUpperLimit, brMaxScale, brMaxScaleLoc, brFlipped;
    path brTemplate, brCandidatePath;
    numeric mrTime, brAngle, brScale, brMaxScale, brMaxScaleLoc;
    pair brOrigin;
    boolean brFlipped;
    if meristemOrientation[mrNumber] = 1:
        brFlipped := true;
    else:
        brFlipped := false;
    fi;
    brMaxScale := 0;
    brMaxScaleLoc := 0;
    if checkIfBudsLeft@#(mrNumber):
        for i := 0 step meristemResolution until arclength(meristemPath[mrNumber]):
            brSizeUpperLimit := checkBud@#(mrNumber, i);
            if (brSizeUpperLimit >= branchMinSize@#) and (brSizeUpperLimit > brMaxScale):
                mrTime := arctime i of meristemPath[mrNumber];
                brAngle := 90 + angle(1/2[
                    direction (mrTime-1/100) of meristemPath[mrNumber],
                    direction (mrTime+1/100) of meristemPath[mrNumber]]);
                brOrigin := point mrTime of meristemPath[mrNumber];
                brScale := findRightSize@#(
                    brFlipped,
                    brOrigin,
                    brAngle,
                    meristemParentBranch[mrNumber],
                    branchMinSize@#, brSizeUpperLimit);
                addBud@#(mrNumber, i, brScale, 1);
                if brScale > brMaxScale:
                    addBranch@#((0,0), true, brOrigin, brAngle, brScale, brFlipped, true);
                    brMaxScale := brScale;
                    brMaxScaleLoc := i;
                fi;
            fi;
        endfor;
        if (brMaxScale >= branchMinSize@#):
            toNextBranch;
            addBud.common(mrNumber, brMaxScaleLoc, 0, 5);
            addBranchMeristem;
            addSymBranches;
        fi;
    fi;
enddef;

vardef findRightSize@#(expr brFlipped, brOrigin, brAngle, brParent, minSize, maxSize) =
    save s, rv, intersects;
    boolean intersects;
    rv := maxSize + 2branchSizeResolution;
    forever:
        rv := rv - 2branchSizeResolution;
        intersects := checkIfIntersects(
            makeBranchPath@#(brOrigin, brAngle, rv, brFlipped),
            brParent);
        exitif ((rv < minSize) or (not intersects));
    endfor;
    if (not checkIfIntersects(
        makeBranchPath@#(brOrigin, brAngle, rv + branchSizeResolution, brFlipped),
        brParent)):
        rv := rv + branchSizeResolution;
    fi;
    rv
enddef;

vardef checkIfIntersects(expr brPath, brParent) =
    save intersects, s, i, bbCorners, isInsidePath, isInsideOutline;
    boolean intersects, isInsidePath, isInsideOutline;
    numeric s[], i;
    pair bbCorners[];
    intersects := false;
    i := brParent;
    s0 := xpart(brPath firstIntersectionTimes branchOutline[i]) + 1/10;
    s1 := 0;
    if s0 < 0:
        intersects := true;
    else:
        if cycle brPath:
            s1 := xpart(reverse(brPath) firstIntersectionTimes branchOutline[i]) + 1/10;
        fi;
        if (arclength(subpath (0, s0) of brPath) > 1/3arclength(brPath))
            or (arclength(subpath (length(brPath) - s1, length(brPath)) of brPath) > 1/3arclength(brPath)):
            intersects := true;
        elseif xpart((subpath (s0, length(brPath) - s1) of brPath)
                intersectiontimes branchOutline[i]) >= 0:
            intersects := true;
        elseif xpart((subpath (1/10, length(brPath) - 1/10) of brPath) intersectiontimes branchPath[i]) > 0:
            intersects := true;
        fi;
    fi;
    if not intersects:
        bbCorners0 := llcorner(brPath);
        bbCorners1 := urcorner(brPath);
        i := -1;
        forever:
            i := i + 1;
            exitif (i > branchNumber) or intersects;
            if (i <> brParent):
                bbCorners2 := llcorner(branchOutline[i]);
                bbCorners3 := urcorner(branchOutline[i]);
                bbCorners4 := llcorner(branchPath[i]);
                bbCorners5 := urcorner(branchPath[i]);
                isInsideOutline :=
                    (not ((xpart(bbCorners0) < xpart(bbCorners2)) and (xpart(bbCorners1) < xpart(bbCorners2))))
                    and (not ((xpart(bbCorners0) > xpart(bbCorners3)) and (xpart(bbCorners1) > xpart(bbCorners3))))
                    and (not ((ypart(bbCorners0) < ypart(bbCorners2)) and (ypart(bbCorners1) < ypart(bbCorners2))))
                    and (not ((ypart(bbCorners0) > ypart(bbCorners3)) and (ypart(bbCorners1) > ypart(bbCorners3))));
                isInsidePath :=
                    (not ((xpart(bbCorners0) < xpart(bbCorners4)) and (xpart(bbCorners1) < xpart(bbCorners4))))
                    and (not ((xpart(bbCorners0) > xpart(bbCorners5)) and (xpart(bbCorners1) > xpart(bbCorners5))))
                    and (not ((ypart(bbCorners0) < ypart(bbCorners4)) and (ypart(bbCorners1) < ypart(bbCorners4))))
                    and (not ((ypart(bbCorners0) > ypart(bbCorners5)) and (ypart(bbCorners1) > ypart(bbCorners5))));
                if isInsideOutline or isInsidePath:
                    if (xpart(brPath intersectiontimes branchOutline[i]) >= 0):
                        intersects := true;
                    elseif (xpart(brPath intersectiontimes branchPath[i]) >= 0):
                        intersects := true;
                    fi;
                fi;
            fi;
        endfor;
    fi;
    intersects
enddef;

% Every type of branches is described here

path branchTemplate.curlA, branchMeristem.curlA[];
numeric branchMeristemOrientation.curlA[],branchMeristemCount.curlA, branchMazSize.curlA;
pair stemVector.curlA;
branchTemplate.curlA := ((1/2,0) for a := 60 step 60 until 360: .. (cosd(a), sind(a)) scaled 1/2(1-a/360) endfor) shifted (-1/2, 0);
branchTemplate.curlA := branchTemplate.curlA rotated 15;
branchMeristem.curlA0 := subpath (1/2, length(branchTemplate.curlA) - 2) of branchTemplate.curlA;
branchMeristemOrientation.curlA0 := 1;
branchMeristem.curlA1 := reverse(subpath (1/4, length(branchTemplate.curlA) - 4) of branchTemplate.curlA);
branchMeristemOrientation.curlA1 := -1;
branchMeristemCount.curlA := 2;
branchMinSize.curlA := 2mm;
branchMaxSize.curlA := 1cm;
stemVector.curlA := (0, 0);

path branchTemplate.curlB, branchMeristem.curlB[];
numeric branchMeristemOrientation.curlB[], branchMeristemCount.curlB, branchMazSize.curlB;
pair stemVector.curlB;
branchTemplate.curlB := ((1/2,0) for a := 60 step 60 until 630: .. (cosd(a), sind(a)) scaled 1/2(1-a/540) endfor) shifted (-1/2, 0);
branchTemplate.curlB := branchTemplate.curlB rotated 15;
branchMeristem.curlB0 := subpath (1/2, length(branchTemplate.curlB) - 3) of branchTemplate.curlB;
branchMeristemOrientation.curlB0 := 1;
branchMeristem.curlB1 := reverse(subpath (1/4, length(branchTemplate.curlB) - 6) of branchTemplate.curlB);
branchMeristemOrientation.curlB1 := -1;
branchMeristemCount.curlB := 2;
branchMinSize.curlB := 2mm;
branchMaxSize.curlB := 1cm;
stemVector.curlB := (0, 0);

path branchTemplate.leafA;
numeric branchMeristemCount.leafA, branchMinSize.leafA, branchMazSize.leafA;
pair stemVector.leafA;
branchTemplate.leafA := (0, 0){dir(90)} .. (subpath (2, 7) of (fullcircle scaled 2/3) shifted (-3/4, 2/3)) .. {dir(-90)} cycle;
branchTemplate.leafA := branchTemplate.leafA rotated 15;
branchMeristemCount.leafA := 0;
branchMinSize.leafA := 2/3mm;
branchMaxSize.leafA := 1/6cm;
stemVector.leafA := (0, 0);

path branchTemplate.leafB;
numeric branchMeristemCount.leafB, branchMinSize.leafB, branchMazSize.leafB;
pair stemVector.leafB;
branchTemplate.leafB := (0, 0){dir(90)} .. (subpath (2, 5) of (fullcircle scaled 3/4) shifted (-4/5, 3/4)){dir(60)} .. {dir(-90)} cycle;
branchTemplate.leafB := branchTemplate.leafB rotated 15;
branchMeristemCount.leafB := 0;
branchMinSize.leafB := 2/3mm;
branchMaxSize.leafB := 1/6cm;
stemVector.leafB := (0, 0);

path branchTemplate.berryA;
numeric branchMeristemCount.berryA, branchMinSize.berryA, branchMazSize.berryA;
pair stemVector.berryA;
branchTemplate.berryA := fullcircle shifted(-1/2, 0);
branchMeristemCount.berryA := 0;
branchMinSize.berryA := 1/2mm;
branchMaxSize.berryA := 1/4cm;
stemVector.berryA := (-1, 0);

branchMaxSize.common := infinity;

string branchTypesList;
branchTypesList := "common, curlA, curlB, leafA, leafB, berryA";

vardef branchPic@#(expr brPath, brOrigin, brAngle, brScale, brFlipped) =
    save brType, p;
    string brType;
    path p[];
    brType = str @#;
    image(
        if (brType = "curlA") or (brType = "curlB"):
            p0 := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
            p1 := ((fullcircle shifted (1/2, 0)) scaled 1/2pt) rotated (angle(direction 0 of reverse(p0)) - 90);
            if brFlipped:
                p1 := p1 rotated 180;
            fi;
            draw p1 shifted (point 0 of reverse(p0)) withpen pencircle scaled 1/2pt withcolor white;
            draw p0 withpen pencircle scaled 1/2pt withcolor white;
        elseif (brType = "leafA"):
            p0 := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
            draw p0 withcolor white withpen pencircle scaled 1/4pt;
            fill p0 withcolor white;
            if brScale > 1mm:
                p1 := applyBranchTransform(
                    ((fullcircle scaled (3/4brScale*scaleFactor - 1/2mm)) shifted ((-3/4, 2/3) scaled brScale*scaleFactor)) rotated 15,
                    brOrigin, brAngle, -brScale, brFlipped, stemVector@#);
                fill p1 withcolor black;
            fi;
        elseif (brType = "leafB"):
            p0 := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
            draw p0 withcolor white withpen pencircle scaled 1/4pt;
            fill p0 withcolor white;
        else:
            draw brPath withcolor white withpen pencircle scaled 1/2pt;
        fi;
    )
enddef;

def makeLettrinePicture (expr fileName) =
    outputtemplate := fileName;
    beginfig(lettrineNumber);
        draw lettrineImage;
        for i := 0 step 1 until branchNumber:
            if branchActive[i]:
                draw branchPic.scantokens(branchType[i])
                    (
                        branchPath[i],
                        branchOrigin[i],
                        branchAngle[i],
                        branchScale[i],
                        branchFlipped[i]
                    );
            %else:
            %    draw branchPath[i] withcolor red;
            fi;
        endfor;
    endfig;
enddef;

forever:
    lettrineLine := readfrom(lettrinesFile);
    exitif (lettrineLine = EOF);
    lettrineSymbol[lettrineNumber] := lettrineLine;
    lettrineNumber := lettrineNumber + 1;
    lettrineCount := 0;
    if (lettrineNumber > 0):
        for i := 0 step 1 until lettrineNumber - 1:
            if (lettrineLine = lettrineSymbol[i]):
                lettrineCount := lettrineCount + 1;
            fi;
        endfor;
    fi;

    branchNumber := -1;
    meristemNumber := -1;

    forsuffixes i := scantokens(branchTypesList):
        path meristemBuds.i[];
    endfor;

    lettrineImage := image(
        if (lettrineLine = "plate"):
            meristemResolution := 2/3mm;
            branchSizeResolution := 1/6mm;
            outlineThickness := 2/5mm;
            branchIterations := 3;
            leafIterations := 3;
            scaleFactor := 1;
            symMode := 1;
            fill ((unitsquare shifted (-1/2,-1/2)) xscaled plateWidth) yscaled plateHeight withcolor black;
            addBranch (((reverse(unitsquare) shifted (-1/2,-1/2)) xscaled (plateWidth - borderWidth)) yscaled (plateHeight - borderWidth),
                true, (0, 0), 0, 1, false, false);
            addMeristem (subpath(0, 1) of branchPath0, 1, branchNumber);
            addMeristem (subpath(1, 3/2) of branchPath0, 1, branchNumber);
            addMeristem (subpath(3/2, 2) of branchPath0, 1, branchNumber);
            addBranch.curlA((0,0), true, (0, 0), 0, 3/2cm, false, false);
            addBranchMeristem;
            addSymBranches;
        elseif (lettrineLine = "tile"):
            meristemResolution := 1/2mm;
            branchSizeResolution := 1/6mm;
            outlineThickness := 1/3mm;
            branchIterations := 3;
            leafIterations := 3;
            scaleFactor := 1;
            symMode := 2;
            addBranch (((unitsquare shifted (-1/2,-1/2)) xscaled 2tileWidth) yscaled 2tileHeight,
                false, (0, 0), 0, 1, false, false);
            addBranch.curlA((0,0), true, (0, 0), 0 + uniformdeviate(360), 3/2cm, false, false);
            addBranchMeristem;
            addSymBranches;
            addBranch.curlA((0,0), true, (0, 0), 180 + branchAngle[1], 3/2cm, false, false);
            addBranchMeristem;
            addSymBranches;
        else:
            meristemResolution := 1/2mm;
            branchSizeResolution := 1/6mm;
            outlineThickness := 1/3mm;
            branchIterations := 2;
            leafIterations := 2;
            scaleFactor := 1;
            symMode := 0;
            fill reverse(unitsquare) scaled lettrineSize withcolor black;
            addBranch (reverse(unitsquare) scaled (lettrineSize - borderWidth) shifted (1/2borderWidth, 1/2borderWidth), true, (0, 0), 0, 1, false, false);
            addMeristem (subpath(0, 1) of branchPath0, 1, branchNumber);
            addMeristem (subpath(1, 2) of branchPath0, 1, branchNumber);
            addMeristem (subpath(2, 3) of branchPath0, 1, branchNumber);
            addMeristem (subpath(3, 4) of branchPath0, 1, branchNumber);
            picture texLetter;
            texLetter := TEX(lettrineLine);
            for i within texLetter:
                currentLetter := (glyph (ASCII textpart i) of (fontpart i)) scaled (1/35);
                currentLetter := currentLetter shifted -1/2[urcorner(currentLetter), llcorner(currentLetter)] shifted (1/2lettrineSize, 1/2lettrineSize);
                for letterPart within currentLetter:
                    if (colorpart letterPart) = 0:
                        fill (pathpart letterPart) withcolor white;
                    else:
                        fill (pathpart letterPart) withcolor black;
                    fi;
                    addBranch (pathpart letterPart, true, (0, 0), 0, 1, false, false);
                    addMeristem (pathpart letterPart, 1, branchNumber);
                endfor;
            endfor;
        fi;
    );

    for j := 0 step 1 until branchIterations:
        for i = scantokens shuffleNumbers(meristemNumber):
            if(uniformdeviate(2) > 1):
                positionBranch.curlA(i);
            else:
                positionBranch.curlB(i);
            fi;
        endfor;
    endfor;
    for j := 0 step 1 until leafIterations:
        for i = scantokens shuffleNumbers(meristemNumber):
            if(uniformdeviate(2) > 1):
                positionBranch.leafA(i);
            else:
                positionBranch.leafB(i);
            fi;
        endfor;
    endfor;

    makeLettrinePicture(lettrineLine & decimal(lettrineCount - 1) & ".mps");

endfor;
end
