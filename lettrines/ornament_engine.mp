%    ornament_engine 0.2.0a
%    MetaPost ornaments generator
%    Copyright 2021 Sergey Slyusarev
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

%
% Some global variables
%

numeric outlineThickness, meristemResolution, branchSizeResolution;

outlineThickness := 1/3mm;
meristemResolution := 2outlineThickness;
branchSizeResolution := 1/2outlineThickness;

numeric tileWidth, tileHeight;
tileWidth := 25mm;
tileHeight := 25mm;


%
% Functions of general use
%

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
    interim linecap := rounded;
    save outlinepen, uncycledpath;
    path uncycledpath, rv;
    uncycledpath := subpath (0, length(p)) of p;
    pen outlinepen;
    outlinepen = makepen(for i := 0 step 10 until 350: dir(i) scaled d -- endfor cycle);
    envelope outlinepen of uncycledpath
enddef;

vardef formNumbersString (expr n) =
save i;
    "0" for i := 1 step 1 until n: & ", " & decimal(i) endfor
enddef;

vardef shuffleNumbers (expr n) =
save residualNumbers, updatedResidualNumbers, shuffledNumbers, randomPick, i, j, k;
    string residualNumbers, updatedResidualNumbers, shuffledNumbers;
    numeric randomPick, i, j, k;
    residualNumbers := formNumbersString(n);
    shuffledNumbers := "";
    for j := n step -1 until 1:
        randomPick := round(uniformdeviate(j));
        k := 0;
        updatedResidualNumbers := "";
        for i = scantokens(residualNumbers):
            k := k + 1;
            if (k <> randomPick):
                if (length(updatedResidualNumbers) > 0):
                    updatedResidualNumbers := updatedResidualNumbers & ", ";
                fi;
                updatedResidualNumbers := updatedResidualNumbers & decimal(i);
            else:
                if (length(shuffledNumbers) > 0):
                    shuffledNumbers := shuffledNumbers & ", ";
                fi;
                shuffledNumbers := shuffledNumbers & decimal(i);
            fi;
        endfor;
        residualNumbers := updatedResidualNumbers;
    endfor;
    residualNumbers & ", " & shuffledNumbers
enddef;

%
% Functions used for ornament generation
%

path branchPath[], branchOutline[], meristemPath[];
pair branchOrigin[];
string branchType[], meristemType[], meristemOrder[];
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
        somePath := somePath scaled (brScale);
    fi;
    somePath := somePath shifted (someStem*(outlineThickness*ornamentScaleFactor));
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
    branchOutline[branchNumber + 1] := pathOutline(brPathToStore, (outlineThickness*ornamentScaleFactor));
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
    meristemOrder[meristemNumber] := shuffleNumbers(floor(arclength(meristemPath[meristemNumber])/(meristemResolution*ornamentScaleFactor)));
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
        mrPath := mrPath;
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
    if symmetryMode = 1:
        addBranch.scantokens(branchType[branchNumber])(
            (0, 0),
            branchActive[branchNumber],
            branchOrigin[branchNumber] rotated 180,
            branchAngle[branchNumber] + 180,
            branchScale[branchNumber],
            branchFlipped[branchNumber],
            false);
    elseif symmetryMode = 2:
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
    elseif symmetryMode = 3:
        addBranch.scantokens(branchType[branchNumber])(
            (0, 0),
            branchActive[branchNumber],
            branchOrigin[branchNumber] xscaled -1,
            180 - branchAngle[branchNumber],
            branchScale[branchNumber],
            not branchFlipped[branchNumber],
            false);
        addBranch.scantokens(branchType[branchNumber-1])(
            (0, 0),
            branchActive[branchNumber-1],
            branchOrigin[branchNumber-1] rotated 180,
            branchAngle[branchNumber-1] + 180,
            branchScale[branchNumber-1],
            branchFlipped[branchNumber-1],
            false);
        addBranch.scantokens(branchType[branchNumber-2])(
            (0, 0),
            branchActive[branchNumber-2],
            branchOrigin[branchNumber-2] yscaled -1,
            -branchAngle[branchNumber-2],
            branchScale[branchNumber-2],
            not branchFlipped[branchNumber-2],
            false);
        fi;
enddef;

vardef addBud@#(expr mrNumber, mrLocTime, s, w) =
    save l;
    if not known meristemBuds.@#[mrNumber]:
        meristemBuds.@#[mrNumber] := (branchMaxSize@# * ornamentScaleFactor, 0);
        for i := 1 step 1 until floor(arclength(meristemPath[mrNumber])/(meristemResolution*ornamentScaleFactor)):
            meristemBuds.@#[mrNumber] := meristemBuds.@#[mrNumber] -- (branchMaxSize@# * ornamentScaleFactor, 0);
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

vardef checkBud@#(expr mrNumber, mrLocTime) =
    save branchExists, rv;
    boolean branchExists;
    branchExists := false;
    if str @# <> "common":
        if checkBud.common(mrNumber, mrLocTime) = 0:
            branchExists := true;
        fi;
    fi;
    if not branchExists:
        if not known meristemBuds.@#[mrNumber]:
            if (branchMaxSize@# < infinity):
                rv := branchMaxSize@# * ornamentScaleFactor;
            else:
                rv := branchMaxSize@#;
            fi;
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
        xpart(urcorner(meristemBuds.@#[mrNumber])) >= branchMinSize@# * ornamentScaleFactor
    fi
enddef;

vardef sortBuds@#(expr mrNumber, budsList) =
save pivot, i, preList, postList, nPre, nPost, isSorted, budValue, lastValue, rv;
    numeric pivot, budValue, lastValue, nPre, nPost;
    string preList, postList, rv;
    boolean isSorted;
    isSorted := true;
    preList := "";
    postList := "";
    nPre := 0;
    nPost := 0;
    lastValue := infinity;
    for i = scantokens(budsList):
        budValue := checkBud@#(mrNumber, i);
        if (unknown pivot):
            pivot := budValue;
        fi;
        if (budValue < pivot):
            if (length(postList) > 0):
                postList :=  ", " & postList;
            fi;
            postList := decimal(i) & postList;
            nPost := nPost + 1;
        elseif (budValue > pivot):
            if (length(preList) > 0):
                preList := ", " & preList;
            fi;
            preList := decimal(i) & preList;
            nPre := nPre + 1;
        else:
            if (length(preList) > 0):
                preList := preList & ", ";
            fi;
            preList := preList & decimal(i);
            nPre := nPre + 1;
        fi;
        if (budValue > lastValue):
            isSorted := false;
        fi;
        lastValue := budValue;
    endfor;
    if isSorted:
        rv := budsList;
    else:
        if ((nPre > 0) and (nPost > 0)):
            rv := sortBuds@#(mrNumber, preList) & ", " & sortBuds@#(mrNumber, postList);
        else:
            rv := sortBuds@#(mrNumber, preList & postList);
        fi;
    fi;
    rv
enddef;

vardef positionBranch@#(expr mrNumber) =
    save brTemplate, mrTime, budTime, brAngle, brOrigin, brSizeUpperLimit, brMaxScale, brMaxScaleLoc, brFlipped, directionVector;
    path brTemplate, brCandidatePath;
    numeric mrTime, budTime, brAngle, brScale, brMaxScale, brMaxScaleLoc;
    pair brOrigin, directionVector;
    boolean brFlipped;
    if meristemOrientation[mrNumber] = 1:
        brFlipped := true;
    else:
        brFlipped := false;
    fi;
    brMaxScale := 0;
    brMaxScaleLoc := 0;
    if checkIfBudsLeft@#(mrNumber):
        for budTime = scantokens(sortBuds@#(mrNumber, meristemOrder[mrNumber])):
            brSizeUpperLimit := checkBud@#(mrNumber, budTime);
            if (brSizeUpperLimit >= branchMinSize@# * ornamentScaleFactor) and (brSizeUpperLimit > brMaxScale):
                mrTime := arctime ((meristemResolution*ornamentScaleFactor)*budTime) of meristemPath[mrNumber];
                if (arclength(meristemPath[mrNumber]) > 0):
                    directionVector := 1/2[
                        direction (mrTime-1/100) of meristemPath[mrNumber],
                        direction (mrTime+1/100) of meristemPath[mrNumber]];
                    if (directionVector = (0, 0)):
                        directionVector := 1/2[
                            direction (mrTime-101/100) of meristemPath[mrNumber],
                            direction (mrTime+101/100) of meristemPath[mrNumber]];
                    fi;
                    brAngle := 90 + angle(directionVector);
                else:
                    brAngle := uniformdeviate(360);
                fi;
                brOrigin := point mrTime of meristemPath[mrNumber];
                brScale := findRightSize@#(
                    brFlipped,
                    brOrigin,
                    brAngle,
                    meristemParentBranch[mrNumber],
                    branchMinSize@# * ornamentScaleFactor, brSizeUpperLimit);
                addBud@#(mrNumber, budTime, brScale, 1);
                if brScale > brMaxScale:
                    addBranch@#((0,0), true, brOrigin, brAngle, brScale, brFlipped, true);
                    brMaxScale := brScale;
                    brMaxScaleLocTime := budTime;
                fi;
            fi;
        endfor;
        meristemOrder[mrNumber] := sortBuds@#(mrNumber, meristemOrder[mrNumber]);
        if (brMaxScale >= branchMinSize@# * ornamentScaleFactor):
            toNextBranch;
            addBud.common(mrNumber, brMaxScaleLocTime, 0, 5);
            addBranchMeristem;
            addSymBranches;
        fi;
    fi;
enddef;

vardef findRightSize@#(expr brFlipped, brOrigin, brAngle, brParent, minSize, maxSize) =
    save s, rv, intersects;
    boolean intersects;
    rv := maxSize + 2(branchSizeResolution*ornamentScaleFactor);
    forever:
        rv := rv - 2(branchSizeResolution*ornamentScaleFactor);
        intersects := checkIfIntersects(
            makeBranchPath@#(brOrigin, brAngle, rv, brFlipped),
            brParent);
        exitif ((rv < minSize) or (not intersects));
    endfor;
    if (not checkIfIntersects(
        makeBranchPath@#(brOrigin, brAngle, rv + (branchSizeResolution*ornamentScaleFactor), brFlipped),
        brParent)):
        rv := rv + (branchSizeResolution*ornamentScaleFactor);
    fi;
    rv
enddef;

vardef checkIfIntersects(expr brPath, brParent) =
    save intersects, s, i, bbCorners, isInsideOutline;
    boolean intersects, isInsideOutline;
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
                isInsideOutline :=
                    (not ((xpart(bbCorners0) < xpart(bbCorners2)) and (xpart(bbCorners1) < xpart(bbCorners2))))
                    and (not ((xpart(bbCorners0) > xpart(bbCorners3)) and (xpart(bbCorners1) > xpart(bbCorners3))))
                    and (not ((ypart(bbCorners0) < ypart(bbCorners2)) and (ypart(bbCorners1) < ypart(bbCorners2))))
                    and (not ((ypart(bbCorners0) > ypart(bbCorners3)) and (ypart(bbCorners1) > ypart(bbCorners3))));
                if isInsideOutline:
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

branchMaxSize.common := 20cm; % to make meaningful in the future

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
            draw p1 shifted (point 0 of reverse(p0)) withpen pencircle scaled 1/2pt withcolor ornamentForegroundColor;
            draw p0 withpen pencircle scaled 1/2pt withcolor ornamentForegroundColor;
        elseif (brType = "leafA"):
            p0 := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
            draw p0 withcolor ornamentForegroundColor withpen pencircle scaled 1/4pt;
            fill p0 withcolor ornamentForegroundColor;
            if brScale > 1mm:
                p1 := applyBranchTransform(
                    ((fullcircle scaled (3/4brScale - 1/2mm)) shifted ((-3/4, 2/3) scaled brScale)) rotated 15,
                    brOrigin, brAngle, -brScale, brFlipped, stemVector@#);
                fill p1 withcolor ornamentBackgroundColor;
            fi;
        elseif (brType = "leafB"):
            p0 := makeBranchPath@#(brOrigin, brAngle, brScale, brFlipped);
            draw p0 withcolor ornamentForegroundColor withpen pencircle scaled 1/4pt;
            fill p0 withcolor ornamentForegroundColor;
        else:
            if(length(brPath) > 0):
                draw brPath withcolor ornamentForegroundColor withpen pencircle scaled 1/2;
            fi;
        fi;
    )
enddef;

%
% Fills stand for fills, paths stand for branches.
% Colors determine properties.
% red = 1, means "branch is visible"
% green = 1, means "branch has meristem"
%

def pictureToBranches (expr seedPicture) =
begingroup
save pathToMakeBranch, numberOfParts, i, minSize;
    path pathToMakeBranch[];
    numeric numberOfParts, minSize;
    minSize := 20meristemResolution * ornamentScaleFactor;
    for particularPath within seedPicture:
        if not filled particularPath:
            pathToMakeBranch0 := pathpart particularPath;
            numberOfParts := ceiling(arclength(pathToMakeBranch0) / minSize);
            if (numberOfParts = 0):
                numberOfParts := 1;
            fi;
            for i := 1 step 1 until numberOfParts:
                pathToMakeBranch1 := subpath (
                    (arctime ((i - 1) * arclength(pathToMakeBranch0)/numberOfParts) of pathToMakeBranch0),
                    (arctime (i * arclength(pathToMakeBranch0)/numberOfParts) of pathToMakeBranch0)
                    ) of pathToMakeBranch0;
                addBranch (pathToMakeBranch1, redpart(colorpart particularPath) = 1, (0, 0), 0, 1, false, false);
                if (greenpart(colorpart particularPath) = 1):
                    addMeristem (pathToMakeBranch1, 1, branchNumber);
                fi;
            endfor;
        fi;
    endfor;
endgroup
enddef;

vardef produceOrnamentImage(expr seedPicture, ornScaleFactor, bgColor, fgColor, symMode, branchIterations, leafIterations) =
save branchNumber, meristemNumber, symmetryMode, ornamentBackgroundColor, ornamentForegroundColor;
save ornamentScaleFactor, ornamentImage;

    ornamentScaleFactor := ornScaleFactor;

    color ornamentBackgroundColor, ornamentForegroundColor;
    ornamentForegroundColor := fgColor;
    ornamentBackgroundColor := bgColor;
    branchNumber := -1;
    meristemNumber := -1;
    symmetryMode := symMode;

    forsuffixes i := scantokens(branchTypesList):
        path meristemBuds.i[];
    endfor;

    picture ornamentImage;
    pictureToBranches(seedPicture);

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

    image(
        for particularPath within seedPicture:
            if filled particularPath:
                if (redpart(colorpart particularPath) = 1):
                    fill pathpart particularPath withcolor ornamentForegroundColor;
                else:
                    fill pathpart particularPath withcolor ornamentBackgroundColor;
                fi;
            fi;
        endfor;
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
            fi;
        endfor;
        )
enddef;
