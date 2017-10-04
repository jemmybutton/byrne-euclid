%    byrne-euclid 0.0.6
%    MetaPost library that implements most of the graphical
%    features present in Oliver Byrne's version of Euclid's "Elements"
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

%
% Here we define some things of general interest
%

u := 1cm;
pi := 3.1415926;
radian := 180/pi;
lineWidth := 2pt;
lineWidthThin := 1pt;
lineWidthHair := 1/2pt;
pointMarkSize := 4pt;
pointLinesScale := 1/2u;
scaleFactor := 1;
angleScale := 1;
globalRotation := 0;
magnitudeScale := 1/3;
magnitudeGap := 2lineWidth;
markLength := 3lineWidth;

boolean textLabels, autoLabelingMode, mainPictureMode;

textLabels := false;
textLabelShift := lineWidth;
autoLabelingMode := false;
mainPictureMode := false;

numeric dpLength[];
dpLength0 := 2lineWidth;
dpLength1 := 2lineWidth;

vardef sin primary x = (sind(x*radian)) enddef;

vardef cos primary x = (cosd(x*radian)) enddef;

color byred, byblue, byyellow, byblack;
byred := (.85, .3, .1);
byblue := (.15, .35, .6);
byyellow := (.95, .7, 0.1);
byblack := black;

linecap := butt;

vardef sign (expr x) =
    if x > 0: 1 fi
    if x < 0: -1 fi
    if x = 0: 1 fi
enddef;

vardef cycleval (expr v, l) =
    save rv;
    numeric rv;
    if (l > 0):
        if ((v mod l) < 0):
            rv := l - (v mod l);
        else:
            rv := (v mod l);
        fi;
    else:
        rv := 0;
    fi;
    rv
enddef;

vardef typeOf (expr v) =
    save determinedType;
    string determinedType;
    determinedType := "undefined";
    if (boolean v):
        determinedType := "boolean";
    elseif (color v):
        determinedType := "color";
    elseif (rgbcolor v):
        determinedType := "cmykcolor";
    elseif (cmykcolor v):
        determinedType := "color";
    elseif (numeric v):
        determinedType := "numeric";
    elseif (pair v):
        determinedType := "pair";
    elseif (path v):
        determinedType := "path";
    elseif (pen v):
        determinedType := "pen";
    elseif (picture v):
        determinedType := "picture";
    elseif (string v):
        determinedType := "string";
    elseif (transform v):
        determinedType := "transform";
    fi;
    determinedType
enddef;

vardef angleOpticalScale (expr v) =
    save va;
    numeric va;
    if (v > 60):
        va := 60;
    else:
        va := v;
    fi;
    ((va/60)**(-1/2))
enddef;

vardef appendList (suffix listName)(expr valueToAdd, whereToAdd, omitDuplicates) =
    if (not string listName) or (unknown listName):
        string listName;
        listName := "";
    fi;
    if length(listName) == 0:
        listName := valueToAdd;
    else:
        save valueExists;
        boolean valueExists;
        valueExists := false;
        if omitDuplicates:
            forsuffixes i=scantokens(listName):
                if (str i == valueToAdd):
                    valueExists := true;
                fi;
            endfor;
        fi;
        if not valueExists:
            if (whereToAdd == 1):
                listName := listName & ", " & valueToAdd;
            else:
                listName := valueToAdd & ", " & listName;
            fi;
        fi;
    fi;
enddef;

vardef setAttribute (expr attrGenus, attrSpecies, attrName, attrValue) =
    save finName;
    string finName;
    if not string scantokens(attrGenus & "Synonym").scantokens(attrName):
        finName := attrName;
    else:
        finName := scantokens(attrGenus & "Synonym").scantokens(attrName);
        if (boolean scantokens(attrGenus & "SynonymPartial").scantokens(attrName)):
            if scantokens(attrGenus & "SynonymPartial").scantokens(attrName):
                finName := attrName;
            fi;
        fi;
    fi;
    scantokens(typeOf(attrValue)) scantokens(attrGenus & attrSpecies).scantokens(finName);
    scantokens(attrGenus & attrSpecies).scantokens(finName) := attrValue;
enddef;

vardef setAttributeMulti (expr attrGenus, attrSpecies, attrName, attrValue, n) =
    save finName;
    string finName;
    if not string scantokens(attrGenus & "Synonym").scantokens(attrName):
        finName := attrName;
    else:
        finName := scantokens(attrGenus & "Synonym").scantokens(attrName);
        if (boolean scantokens(attrGenus & "SynonymPartial").scantokens(attrName)):
            if scantokens(attrGenus & "SynonymPartial").scantokens(attrName):
                finName := attrName;
            fi;
        fi;
    fi;
    if (typeOf(scantokens(attrGenus & attrSpecies).scantokens(finName)0) <> typeOf(attrValue)):
        scantokens(typeOf(attrValue)) scantokens(attrGenus & attrSpecies).scantokens(finName)[];
    fi;
    scantokens(attrGenus & attrSpecies).scantokens(finName)[n] := attrValue;
enddef;

vardef getAttribute (expr attrGenus, attrSpecies, attrName) =
    save finName;
    string finName;
    if not string scantokens(attrGenus & "Synonym").scantokens(attrName):
        finName := attrName;
    else:
        finName := scantokens(attrGenus & "Synonym").scantokens(attrName);
        if (boolean scantokens(attrGenus & "SynonymPartial").scantokens(attrName)):
            if scantokens(attrGenus & "SynonymPartial").scantokens(attrName):
                if known scantokens(attrGenus & attrSpecies).scantokens(attrName):
                    finName := attrName;
                fi;
            fi;
        fi;
    fi;
    scantokens(attrGenus & attrSpecies).scantokens(finName)
enddef;

vardef getAttributeMulti (expr attrGenus, attrSpecies, attrName, n) =
    save finName;
    string finName;
    if not string scantokens(attrGenus & "Synonym").scantokens(attrName):
        finName := attrName;
    else:
        finName := scantokens(attrGenus & "Synonym").scantokens(attrName);
        if (boolean scantokens(attrGenus & "SynonymPartial").scantokens(attrName)):
            if scantokens(attrGenus & "SynonymPartial").scantokens(attrName):
                if known scantokens(attrGenus & attrSpecies).scantokens(attrName)[n]:
                    finName := attrName;
                fi;
            fi;
        fi;
    fi;
    scantokens(attrGenus & attrSpecies).scantokens(finName)[n]
enddef;

vardef attributeExists(expr attrGenus, attrSpecies, attrName) =
    save rv;
    boolean rv;
    if known scantokens(attrGenus & attrSpecies).scantokens(attrName):
        rv := true;
    else:
        rv := false;
    fi;
    rv
enddef;

setAttribute("line", "Color", "noLine", white);
setAttribute("line", "Dashed", "noLine", 0);
setAttribute("line", "EndAName", "noLine", "noLine");
setAttribute("line", "EndBName", "noLine", "noLine");
setAttribute("line", "EndA", "noLine", inf);
setAttribute("line", "EndB", "noLine", inf);

vardef distanceToLine (expr givenPoint, givenLine) =
    save p;
    pair p[];
    p0 := point 0 of givenLine;
    p1 := point 0 of reverse(givenLine);
    p2 - givenPoint = whatever * ((p1-p0) rotated 90);
    p2 = whatever[p0, p1];
    p3 := p2;
    arclength(givenPoint -- p3)
enddef;

vardef angleValue (expr a, b, c) =
    save v;
    numeric v;
    v := angle(a-b) - angle(c-b);
    if (v > 180): v := v - 360; fi;
    if (v < -180): v := v + 360; fi;
    v
enddef;

vardef lineThickness(expr th) =
    if (th = 0):
        lineWidth
    elseif (th = 1):
        lineWidthThin
    elseif (th = 2):
        lineWidthHair
    else:
        lineWidth
    fi
enddef;

vardef byDashPattern(expr l, dp) =
    save d, n;
    numeric d[], n;
    n := ceiling(l/dpLength[dp]);
    d1 := 1/3(l/n);
    d2 := 1/3(l/n);
    dashpattern (on d1 off d2 on d1)
enddef;

def startTempScale(expr tmpScale) =
    begingroup
        save scaleFactor;
        scaleFactor := tmpScale;
enddef;

def stopTempScale =
    endgroup
enddef;

def startTempAngleScale(expr tmpScale) =
    begingroup
        save angleScale;
        angleScale := tmpScale;
enddef;

def stopTempAngleScale =
    endgroup
enddef;

def startGlobalRotation(expr ang) =
    begingroup
        save globalRotation;
        globalRotation := ang;
enddef;

def stopGlobalRotation =
    endgroup
enddef;

def startAutoLabeling =
    begingroup
        save autoLabelingMode;
        boolean autoLabelingMode;
        autoLabelingMode := true;
enddef;

def stopAutoLabeling =
    endgroup
enddef;

def startMainPictureMode =
    begingroup
        save mainPictureMode;
        boolean mainPictureMode;
        mainPictureMode := true;
enddef;

def stopMainPictureMode =
    endgroup
enddef;

%
% This section is dedicated to lines
%

vardef byLineRender (expr a, b, col, dp, th, c, d, ct, dt, s, sf) =
    save p, la, lineItself, lineBleeding, clippingPath, cutAngle, linePerp, lineStyShift, currentLineWidth, clippingPathPoint, aS, bS;
    picture p;
    path lineItself, lineBleeding, clippingPath;
    pair cutAngle[], linePerp, lineStyShift, clippingPathPoint[], aS, bS;
    la := angle(b-a);
    aS := a*sf;
    bS := b*sf;
    lineStyShift := (0, 0);
    currentLineWidth := lineThickness(th);
    if (abs(c-a) > 0) and (abs(unitvector(c-a)-unitvector(a-b)) > 1/100):
        if (ct = 0):
            cutAngle1 := unitvector(1/2[unitvector(b-a), unitvector(c-a)]);
        elseif (ct = 1):
            cutAngle1 := unitvector(1[unitvector(b-a), unitvector(c-a)]);
        fi;
    else:
        cutAngle1 := unitvector(b-a) rotated -90;
    fi;
    if (abs(d-b) > 0) and (abs(unitvector(d-b)-unitvector(b-a)) > 1/100):
        if (dt = 0):
            cutAngle2 := unitvector(1/2[unitvector(a-b), unitvector(d-b)]);
        elseif (dt = 1):
            cutAngle2 := unitvector(1[unitvector(a-b), unitvector(d-b)]);
        fi;
    else:
        cutAngle2 := unitvector(a-b) rotated 90;
    fi;
    if (sign(ypart(cutAngle2 rotated -la)) <> sign(ypart(cutAngle1 rotated -la))):
        cutAngle2 := cutAngle2 rotated 180;
    fi;
    lineItself := (a--b) scaled sf;
    linePerp := unitvector((point 0 of lineItself)-(point 1 of lineItself)) rotated 90;
    lineBleeding :=
        ((point 0 of lineItself) shifted (unitvector((point 0 of lineItself) - (point 1 of lineItself)) scaled dpLength[dp])) --
        lineItself -- ((point 1 of lineItself) shifted (unitvector((point 1 of lineItself) - (point 0 of lineItself)) scaled dpLength[dp]));
    p := image(
        lineStyShift := (linePerp scaled (1/2currentLineWidth*s));
        if (dp > 0):
            draw (lineItself shifted lineStyShift) withpen pencircle scaled currentLineWidth withcolor white;
            draw (lineItself shifted lineStyShift) withpen pencircle scaled currentLineWidth withcolor col
                dashed byDashPattern(arclength(lineItself), dp);
            draw (subpath(0, 1) of lineBleeding shifted lineStyShift) withpen pencircle scaled currentLineWidth withcolor col;
            draw (subpath(2, 3) of lineBleeding shifted lineStyShift) withpen pencircle scaled currentLineWidth withcolor col;
        else:
            draw (lineBleeding shifted lineStyShift) withpen pencircle scaled currentLineWidth withcolor col;
        fi;
        if (th < 0):
            draw (lineBleeding shifted (lineStyShift + (linePerp scaled 1/4currentLineWidth))) withpen pencircle scaled 1/2currentLineWidth withcolor black;
        fi;
    );
    clippingPathPoint1
        = whatever[aS shifted (linePerp*1/2lineWidth) shifted lineStyShift,
            bS shifted (linePerp*1/2lineWidth) shifted lineStyShift]
        = whatever[aS, aS shifted cutAngle1];
    clippingPathPoint2
        = whatever[aS shifted (linePerp*-1/2lineWidth) shifted lineStyShift,
            bS shifted (linePerp*-1/2lineWidth) shifted lineStyShift]
        = whatever[aS, aS shifted cutAngle1];
    clippingPathPoint3
        = whatever[aS shifted (linePerp*-1/2lineWidth) shifted lineStyShift,
            bS shifted (linePerp*-1/2lineWidth) shifted lineStyShift]
        = whatever[bS, bS shifted cutAngle2];
    clippingPathPoint4
        = whatever[aS shifted (linePerp*1/2lineWidth) shifted lineStyShift,
            bS shifted (linePerp*1/2lineWidth) shifted lineStyShift]
        = whatever[bS, bS shifted cutAngle2];
    clippingPath := clippingPathPoint1 -- clippingPathPoint2 -- clippingPathPoint3 -- clippingPathPoint4 -- cycle;
    clip p to clippingPath;
    p rotated globalRotation
enddef;

vardef byLineDefineWithName (suffix a, b)(expr col, dp, th)(suffix lineName) =
if mainPictureMode:
    appendList(allLinesList, str lineName, 1, true);
fi;
    setAttribute("line", "Angle", str lineName, angle(b-a));
    setAttribute("line", "Color", str lineName, col);
    setAttribute("line", "Dashed", str lineName, dp);
    setAttribute("line", "Thin", str lineName, th);
    setAttribute("line", "Length", str lineName, arclength(a--b));
    setAttribute("line", "EndA", str lineName, a);
    setAttribute("line", "EndB", str lineName, b);
    setAttribute("line", "Shift", str lineName, 0);
    setAttribute("line", "DirA", str lineName, a);
    setAttribute("line", "DirB", str lineName, b);
    setAttribute("line", "EndAType", str lineName, 0);
    setAttribute("line", "EndBType", str lineName, 0);
    setAttribute("line", "EndAName", str lineName, str a);
    setAttribute("line", "EndBName", str lineName, str b);
    setAttribute("line", "UseLineLabel", str lineName, false);
    setAttribute("line", "Label", str lineName, str lineName);
    setAttribute("line", "Synonym", str lineName, str lineName);
enddef;

vardef byLineDefine (suffix a, b) (expr col, dp, th) =
    byLineDefineWithName (a, b, col, dp, th) (scantokens(str a & str b));
enddef;

vardef byLineStylize (expr c, d, ct, dt, s) (suffix lineName) =
    setAttribute("line", "Shift", str lineName, s);
    setAttribute("line", "DirA", str lineName, c);
    setAttribute("line", "DirB", str lineName, d);
    setAttribute("line", "EndAType", str lineName, ct);
    setAttribute("line", "EndBType", str lineName, dt);
enddef;

vardef byLine (suffix a, b)(expr col, dp, th) =
    byLineDefine (a, b) (col, dp, th);
    byNamedLineFull(a, b, 0, 0, 0)(scantokens(str a & str b))
enddef;

vardef byLineFull (suffix a, b)(expr col, dp, th, c, d, ct, dt, s) =
    byLineDefine (a, b) (col, dp, th);
    byLineStylize (c, d, ct, dt, s)(scantokens(str a & str b));
    byNamedLine(scantokens(str a & str b))
enddef;

vardef byLineWithName (suffix a, b)(expr col, dp, th)(suffix lineName) =
    byLineDefineWithName (a, b, col, dp, th) (lineName);
    setAttribute("line", "UseLineLabel", str lineName, true);
    byNamedLineFull(a, b, 0, 0, 0)(lineName)
enddef;

vardef byNamedLineFull(expr c, d, ct, dt, s) (suffix lineName) =
    if (mainPictureMode):
        appendList(pointLinesList.scantokens(getAttribute("line", "EndAName", str lineName)), str lineName, 1, true);
        appendList(pointLinesList.scantokens(getAttribute("line", "EndBName", str lineName)), str lineName, 1, true);
    fi;
    byLineRender(getAttribute("line", "EndA", str lineName), getAttribute("line", "EndB", str lineName), getAttribute("line", "Color", str lineName), getAttribute("line", "Dashed", str lineName), getAttribute("line", "Thin", str lineName), c, d, ct, dt, s, scaleFactor)
enddef;

vardef byNamedLine(text linesList) =
    image(
        forsuffixes lN=linesList:
            draw byNamedLineFull(getAttribute("line", "DirA", str lN), getAttribute("line", "DirB", str lN), getAttribute("line", "EndAType", str lN), getAttribute("line", "EndBType", str lN), getAttribute("line", "Shift", str lN))(lN);
        endfor;
    )
enddef;

vardef byNamedLineSeq(expr s)(text linesList) =
    save lAname, lBname, lShift, lName, i, j, k, l, m, n, c, d, prp, pointNames;
    string lAname[], lBname[], lName[], c, d, pointNames;
    numeric i, j, k, l, m, n, prp, lShift[];
    pointNames := "";
    image(
        i := -1;
        forsuffixes lN=linesList:
            i := i + 1;
            lAname[i] := getAttribute("line", "EndAName", str lN);
            lBname[i] := getAttribute("line", "EndBName", str lN);
            lShift[i] := getAttribute("line", "Shift", str lN);
            lName[i] := str lN;
        endfor;
        if (i == 1):
            i := i + 1;
            lAname[i] := "noLine";
            lBname[i] := "noLine";
            lName[i] := "noLine";
        fi;
        if (i > 0):
            for j := 0 step 1 until i:
                k := cycleval (j - 1, i + 1);
                l := cycleval (j + 1, i + 1);
                m := 0;
                n := 0;
                if (lAname[k] == "noLine"):
                    k := cycleval (k - 1, i + 1);
                    m := 1;
                fi;
                if (lAname[l] == "noLine"):
                    l := cycleval (l + 1, i + 1);
                    n := 1;
                fi;
                c := lAname[j];
                d := lBname[j];
                prp := 0;
                if  (((lAname[j] == lAname[k]) or (lAname[j] == lBname[k]))
                        and (not ((m <> 0) and (lName[k] == lName[l])))) or
                    (((lBname[j] == lAname[l]) or (lBname[j] == lBname[l]))
                        and (not ((n <> 0) and (lName[k] == lName[l])))):
                    if (lAname[j] == lAname[k]):
                        if (m == 0): c := lBname[k]; fi;
                    elseif (lAname[j] == lBname[k]):
                        if (m == 0): c := lAname[k]; fi;
                    else:
                        m := 2;
                    fi;
                    if (lBname[j] == lAname[l]):
                        if (n == 0): d := lBname[l]; fi;
                    elseif (lBname[j] == lBname[l]):
                        if (n == 0): d := lAname[l]; fi;
                    else:
                        n := 2;
                    fi;
                    prp := 1;
                else:
                    if (lAname[j] == lAname[l]):
                        if (n == 0): c := lBname[l]; fi;
                    elseif (lAname[j] == lBname[l]):
                        if (n == 0): c := lAname[l]; fi;
                    else:
                        n := 2;
                    fi;
                    if (lBname[j] == lAname[k]):
                        if (m == 0): d := lBname[k]; fi;
                    elseif (lBname[j] == lBname[k]):
                        if (m == 0): d := lAname[k]; fi;
                    else:
                        m := 2;
                    fi;
                    prp := -1;
                fi;
                if (lName[j] <> "noLine"):
                    if (prp == 1):
                        pointNames := pointNames & lAname[j] & ", ";
                        if (n == 2):
                            pointNames := pointNames & lBname[j] & ", noPoint, ";
                        fi;
                    elseif (prp == -1):
                        pointNames := pointNames & lBname[j] & ", ";
                        if (n == 2):
                            pointNames := pointNames & lAname[j] & ", noPoint, ";
                        fi;
                    fi;
                    lShift[j] := s*prp;
                    draw byNamedLineFull(scantokens(c), scantokens(d), 0, 0, s*sign(prp))(scantokens(lName[j]));
                else:
                    prp := -2;
                fi;
            endfor;
            if (prp == 1) and (n <> 2):
                pointNames := pointNames & lBname[i];
            elseif (prp == -1) and (n <> 2):
                pointNames := pointNames & lAname[i];
            else:
                pointNames := substring (0, length(pointNames)-2) of pointNames;
            fi;
            if (textLabels and autoLabelingMode):
                draw byLabelsOnPolygon(scantokens pointNames)(1, s);
            fi;
        else:
            forsuffixes lN=linesList:
                setAttribute("line", "Shift", str lN, s);
                draw byNamedLineFull(getAttribute("line", "EndA", str lN), getAttribute("line", "EndB", str lN), 0, 0, s)(lN);
                if (textLabels and autoLabelingMode):
                    draw byLabelsOnPolygon(scantokens (getAttribute("line", "EndAName", str lN) & ", " & getAttribute("line", "EndBName", str lN)))(1, s);
                fi;
            endfor;
        fi;
    )
enddef;

vardef byMarkLine(expr pos, col)(suffix lineName) =
    setAttribute("mark", "Position", str lineName, pos);
    setAttribute("mark", "Color", str lineName, col);
    byNamedMarkLine(lineName)
enddef;

vardef byNamedMarkLine(suffix lineName) =
    save p, q;
    pair q[];
    picture p;
    p := image(
        q0 := getAttribute("mark", "Position", str lineName)[getAttribute("line", "EndA", str lineName), getAttribute("line", "EndB", str lineName)];
        q1 := q0 shifted (dir(getAttribute("line", "Angle", str lineName) + 90) scaled 1/2markLength);
        q2 := q0 shifted (dir(getAttribute("line", "Angle", str lineName) - 90) scaled 1/2markLength);
        q3 := (dir(getAttribute("line", "Angle", str lineName) - 90) scaled (1/2lineWidth*getAttribute("line", "Shift", str lineName)));
        draw (q1--q2) shifted q3 withpen pencircle scaled lineWidthThin withcolor getAttribute("mark", "Color", str lineName);
    );
    p rotated globalRotation
enddef;

vardef byFindLinePointedThere(expr a, b) =
    save endA, endB, endAC, endBC, endAA, endBA, chosenLine, lL;
    string chosenLine;
    pair endA, endB, endAC, endBC, endAA, endBA;
    numeric lL;
    endA := scantokens(a);
    endB := scantokens(b);
    forsuffixes lL=scantokens(pointLinesList.scantokens(a)):
        endAC := getAttribute("line", "EndA", str lL);
        endBC := getAttribute("line", "EndB", str lL);
        if (endAC == endA):
            endAA := endAC;
            endBA := endBC;
        elseif (endBC == endA):
            endAA := endBC;
            endBA := endAC;
        fi;
        if ((abs(angle(endBA - endAA) - angle(endB - endA)) mod 360) < 1):
            chosenLine := str lL;
        fi;
    endfor;
    chosenLine
enddef;

vardef byConstructCompoundLine(expr lineName) =
    save lineStart, lineEnd, newLine, compoundLineString, i;
    string lineStart, lineEnd, newLine, compoundLineString;
    numeric i;
    lineStart := substring (0, 1) of lineName;
    lineEnd := substring (1, 2) of lineName;
    i := 0;
    forever:
        i := i + 1;
        newLine := byFindLinePointedThere(lineStart, lineEnd);
        appendList (compoundLineString, newLine, 1, false);
        if (getAttribute("line", "EndAName", newLine) == lineStart):
            lineStart := getAttribute("line", "EndBName", newLine);
        elseif (getAttribute("line", "EndBName", newLine) == lineStart):
            lineStart := getAttribute("line", "EndAName", newLine);
        fi;
        exitif (i > 10) or
            (getAttribute("line", "EndAName", newLine) == lineEnd) or
            (getAttribute("line", "EndBName", newLine) == lineEnd);
    endfor;
    compoundLineString
enddef;

vardef byExpandLine (text linesList) =
    save i, lineString, compoundLineString, rv;
    numeric i;
    string lineString, compoundLineString, rv;
    i := 0;
    forsuffixes lN=linesList:
        i := i + 1;
        lineString := str lN;
    endfor;
    if not attributeExists("line", "Synonym", lineString):
        rv := byConstructCompoundLine(lineString);
    else:
        rv := lineString;
    fi;
    rv
enddef;

vardef byNamedCompoundLine(expr cu, pw)(text linesList) =
    byNamedCompoundLineRender(cu, pw)(scantokens(byExpandLine(linesList)))
enddef;

vardef byNamedCompoundLineRender(expr cu, pw)(text linesList) =
    save correctedLength, currentPosition, a, b, sc, totalLength, pwL, lineNames, endNames, i, j, angleCheck, lineNotStraight, lineNotContinuous, globalRotation;
    numeric correctedLength, currentPosition[], sc, totalLength, pwL, i, j, angleCheck[];
    globalRotation := 0;
    string lineNames[], endNames[];
    pair a, b;
    boolean lineNotStraight, lineNotContinuous;
    i := 0;
    totalLength := 0;
    lineNotStraight := false;
    lineNotContinuous := false;
    forsuffixes lN=linesList:
        lineNames[i] := getAttribute("line", "EndAName", str lN);
        lineNames[i+1] := getAttribute("line", "EndBName", str lN);
        if (i > 0):
            if (lineNames[i] <> lineNames[i-2])
                and (lineNames[i] <> lineNames[i-1])
                and (lineNames[i+1] <> lineNames[i-2])
                and (lineNames[i+1] <> lineNames[i-1]):
                lineNotContinuous := true;
            fi;
        fi;
        i := i + 2;
        angleCheck[i/2] := abs(cosd(getAttribute("line", "Angle", str lN)));
        if (abs(angleCheck[i/2] - angleCheck[1]) > 1/100):
            lineNotStraight := true;
        fi;
        totalLength := totalLength + getAttribute("line", "Length", str lN);
    endfor;
    if (lineNotStraight):
        errmessage("The line is not straight");
    fi;
    if (lineNotContinuous):
        errmessage("The line is not continuous");
    fi;
    if (pw <> 0):
        sc := cu**(1 - (1/pw));
        pwL := 1/pw;
    else:
        sc := cu/(totalLength*scaleFactor);
        pwL := 1;
    fi;
    currentPosition0 := 0;
    image(
        j := 0;
        forsuffixes lN=linesList:
            correctedLength := (getAttribute("line", "Length", str lN)**pwL)*sc;
            currentPosition1 := currentPosition0 + correctedLength;
            a := (currentPosition0, 0);
            b := (currentPosition1, 0);
            draw byLineRender(a, b, getAttribute("line", "Color", str lN), getAttribute("line", "Dashed", str lN), getAttribute("line", "Thin", str lN), a, b, 0, 0, 0, scaleFactor);
            currentPosition0 := currentPosition1;
            if (i > 2):
                if (j == 0):
                    if (getAttribute("line", "EndAName", str lN) == lineNames[2])
                        or (getAttribute("line", "EndAName", str lN) == lineNames[3]):
                        endNames[0] := getAttribute("line", "EndBName", str lN);
                    elseif (getAttribute("line", "EndBName", str lN) == lineNames[2])
                        or (getAttribute("line", "EndBName", str lN) == lineNames[3]):
                        endNames[0] := getAttribute("line", "EndAName", str lN);
                    fi;
                fi;
                if (j == (i-2)/2):
                    if (getAttribute("line", "EndAName", str lN) == lineNames[i-3])
                        or (getAttribute("line", "EndAName", str lN) == lineNames[i-4]):
                        endNames[1] := getAttribute("line", "EndBName", str lN);
                    elseif (getAttribute("line", "EndBName", str lN) == lineNames[i-3])
                        or (getAttribute("line", "EndBName", str lN) == lineNames[i-4]):
                        endNames[1] := getAttribute("line", "EndAName", str lN);
                    fi;
                fi;
            else:
                if (getAttribute("line", "UseLineLabel", str lN)):
                    endNames[0] := str lN;
                    endNames[1] := str lN;
                else:
                    endNames[0] := getAttribute("line", "EndAName", str lN);
                    endNames[1] := getAttribute("line", "EndBName", str lN);
                fi;
            fi;
            j := j + 1;
        endfor;
        if (textLabels and autoLabelingMode):
            if (endNames[0] <> endNames[1]):
                draw byTextLabel(pointLabel)(endNames[0], (0, 0), 90, textLabelShift);
                draw byTextLabel(pointLabel)(endNames[1], b, 90, textLabelShift);
            else:
                draw byTextLabel(lineLabel)(endNames[0], 1/2[(0, 0), b], 90, textLabelShift);
            fi;
        fi;
    )
enddef;

vardef generateLineSynonyms =
    if string allLinesList:
        save candidateName, originalName;
        string candidateName[], originalName;
        forsuffixes i=scantokens(allLinesList):
            originalName := str i;
            candidateName1 := getAttribute("line", "EndAName", originalName)
                & getAttribute("line", "EndBName", originalName);
            candidateName2 := getAttribute("line", "EndBName", originalName)
                & getAttribute("line", "EndAName", originalName);
            if not string getAttribute("line", "Synonym", candidateName1):
                setAttribute("line", "Synonym", candidateName1, originalName);
            fi;
            if not string getAttribute("line", "Synonym", candidateName2):
                setAttribute("line", "SynonymPartial", candidateName2, true);
                setAttribute("line", "Synonym", candidateName2, originalName);
                setAttribute("line", "EndA", candidateName2, getAttribute("line", "EndB", originalName));
                setAttribute("line", "EndB", candidateName2, getAttribute("line", "EndA", originalName));
                setAttribute("line", "EndAType", candidateName2, getAttribute("line", "EndBType", originalName));
                setAttribute("line", "EndBType", candidateName2, getAttribute("line", "EndAType", originalName));
                setAttribute("line", "EndAName", candidateName2, getAttribute("line", "EndBName", originalName));
                setAttribute("line", "EndBName", candidateName2, getAttribute("line", "EndAName", originalName));
                setAttribute("line", "DirA", candidateName2, getAttribute("line", "DirB", originalName));
                setAttribute("line", "DirB", candidateName2, getAttribute("line", "DirA", originalName));
                setAttribute("line", "Angle", candidateName2, 180 + getAttribute("line", "Angle", originalName));
            fi;
        endfor;
    fi;
enddef;

%
% Points
%

vardef byPointLabelDefine (suffix pointName)(expr t) =
    setAttribute("point", "Label", str pointName, t);
enddef;

vardef byPointMarkDefine (suffix pointName)(expr col, sty) =
    setAttribute("point", "Color", str pointName, col);
    setAttribute("point", "Style", str pointName, sty);
enddef;

vardef byPointMarkRender (suffix pointName) =
    image(
        if (getAttribute("point", "Style", str pointName) == 0):
            fill ((fullcircle scaled pointMarkSize) shifted (pointName scaled scaleFactor)) withcolor getAttribute("point", "Color", str pointName);
        fi;
    )
enddef;

vardef byNamedPointMark (suffix pointName) =
    image(
        draw byPointMarkRender(pointName);
        if (autoLabelingMode and textLabels):
            draw byTextLabel(pointLabel)(str pointName, pointName, 90, textLabelShift);
        fi;
    )
enddef;

vardef byPointMark (suffix pointName)(expr col, sty) =
    image(
        byPointMarkDefine(pointName)(col, sty);
        draw byNamedPointMark(pointName);
    )
enddef;

vardef byNamedPointLines (suffix pointName)(expr omitLines) =
string linesList, lineNames[], pointNames[];
linesList := pointLinesList.pointName;
pair distantEnd, distantEnds[];
numeric n, no, distL, maxDist, maxDistEndA, maxDistEndB, a[], angleL, minAngle, maxAngle, minAngleEndB, maxAngleEndA, maxAngleEndB, safeLine;
boolean omitLine[];
    image(
        n := 0;
        no := 0;
        maxDist := 0;
        maxAngle := 0;
        minAngle := 360;
        forsuffixes i = scantokens(linesList):
            n := n + 1;
            lineNames[n] := str i;
            omitLine[n] := false;
            if (length(omitLines) > 0):
                forsuffixes j = scantokens(omitLines):
                    if ((str i) == (str j)):
                        omitLine[n] := true;
                        no := no + 1;
                    fi;
                endfor;
            fi;
            if (not omitLine[n]):
                safeLine := n;
            fi;
            if (getAttribute("line", "EndAName", str i) == str pointName):
                distantEnds[n] := getAttribute("line", "EndA", str i) + (unitvector(getAttribute("line", "EndB", str i) - getAttribute("line", "EndA", str i)) scaled (pointLinesScale/scaleFactor));
                pointNames[n] := getAttribute("line", "EndBName", str i);
            else:
                distantEnds[n] := getAttribute("line", "EndB", str i) + (unitvector(getAttribute("line", "EndA", str i) - getAttribute("line", "EndB", str i)) scaled (pointLinesScale/scaleFactor));
                pointNames[n] := getAttribute("line", "EndAName", str i);
            fi;
        endfor;
        if (n - no > 1):
            for i := 1 step 1 until n:
                if (not omitLine[i]):
                    minAngle := 360;
                    for j := 1 step 1 until n:
                        if (not omitLine[j]):
                            distL := abs(distantEnds[i] - distantEnds[j]);
                            if (distL > maxDist):
                                maxDist := distL;
                                maxDistEndA := i;
                                maxDistEndB := j;
                            fi;
                            a1 := angle(distantEnds[i] - pointName);
                            a2 := angle(distantEnds[j] - pointName);
                            angleL := a2 - a1;
                            if (angleL < 0): angleL := angleL + 360; fi;
                            if (minAngle > angleL) and (angleL <> 0):
                                minAngle := angleL;
                                minAngleEndA := j;
                            fi;
                        fi;
                    endfor;
                    if (maxAngle <= minAngle + 1):
                        maxAngle := minAngle;
                        maxAngleEndA := minAngleEndA;
                        maxAngleEndB := i;
                    fi;
                fi;
            endfor;
            for i := 1 step 1 until n:
                if (i <> maxDistEndA) and (i <> maxDistEndB) and (not omitLine[i]):
                    draw byLineRender(pointName, distantEnds[i],
                        getAttribute("line", "Color", lineNames[i]), getAttribute("line", "Dashed", lineNames[i]), getAttribute("line", "Thin", lineNames[i]),
                        pointName, distantEnds[i], 0, 0, 0, scaleFactor);
                fi;
            endfor;
            draw byLineRender(pointName, distantEnds[maxDistEndA],
                getAttribute("line", "Color", lineNames[maxDistEndA]),
                getAttribute("line", "Dashed", lineNames[maxDistEndA]),
                getAttribute("line", "Thin", lineNames[maxDistEndA]),
                distantEnds[maxDistEndB], distantEnds[maxDistEndA], 0, 0, 0, scaleFactor);
            draw byLineRender(pointName, distantEnds[maxDistEndB],
                getAttribute("line", "Color", lineNames[maxDistEndB]),
                getAttribute("line", "Dashed", lineNames[maxDistEndB]),
                getAttribute("line", "Thin", lineNames[maxDistEndB]),
                distantEnds[maxDistEndA], distantEnds[maxDistEndB], 0, 0, 0, scaleFactor);
            if (textLabels):
                draw byLabelsOnPolygon(scantokens(pointNames[maxAngleEndA]),pointName,scantokens(pointNames[maxAngleEndB]))(2, 0);
            fi;
        else:
            draw byLineRender(pointName, distantEnds[safeLine],
                getAttribute("line", "Color", lineNames[safeLine]),
                getAttribute("line", "Dashed", lineNames[safeLine]),
                getAttribute("line", "Thin", lineNames[safeLine]),
                pointName, distantEnds[safeLine], 0, 0, 0, scaleFactor);
            if (textLabels):
                draw byLabelLineEnd (pointName, distantEnds[safeLine])(0);
            fi;
        fi;
    )
enddef;

%
% Arcs and circles
%

vardef byArcRender(expr o, b, e, r, col, dp, th, s, et) =
    save p, q, m, t, currentLineWidth;
    path p[];
    picture q;
    pair t[];
    numeric m[];
    numeric currentLineWidth;
    image(
        currentLineWidth := lineThickness(th);
        p0 := ((subpath (b, e) of fullcircle) scaled (r*scaleFactor + lineWidth*s + lineWidth)) shifted (o*scaleFactor);
        p1 := ((subpath (b, e) of fullcircle) scaled (r*scaleFactor)) shifted (o*scaleFactor);
        p2 := (fullcircle scaled (r*scaleFactor + lineWidth*s + lineWidth)) shifted (o*scaleFactor);
        p3 := ((subpath (b + sign(b-e)*1/4, e + sign(e-b)*1/4) of fullcircle) scaled (r*scaleFactor + lineWidth*s)) shifted (o*scaleFactor);
        q := image(
            draw p3 withpen pencircle scaled currentLineWidth withcolor col if (dp > 0): dashed byDashPattern(arclength(p1), dp) fi;
        );
        if (et = 0):
            p4 := p0--(o*scaleFactor)--cycle;
        else:
            t0 := point 0 of p1;
            t1 := point 0 of reverse(p1);
            t2 := 1/2[t0, t1];
            m0 := xpart (p2 intersectiontimes (t2 -- 2[t2, t0]));
            m1 := xpart (p2 intersectiontimes (t2 -- 2[t2, t1]));
            for i := -(8*3) step 8 until (8*3):
                if (abs(b - m0) > abs(b - (m0 + i))):
                    m0 := m0 + i;
                fi;
                if (abs(e - m1) > abs(e - (m1 + i))):
                    m1 := m1 + i;
                fi;
            endfor;
            p4 := (subpath(m0, m1) of p2) -- cycle;
        fi;
        clip q to p4;
        draw q;
    ) rotated globalRotation
enddef;

vardef byArcDefine (suffix o)(expr b, e, r, col, dp, th, s, et) (suffix arcName) =
    setAttribute("arc", "Color", str arcName, col);
    setAttribute("arc", "Dashed", str arcName, dp);
    setAttribute("arc", "Thin", str arcName, th);
    setAttribute("arc", "Shift", str arcName, s);
    setAttribute("arc", "Diameter", str arcName, 2r);
    setAttribute("arc", "Center", str arcName, o);
    setAttribute("arc", "CenterName", str arcName, str o);
    setAttribute("arc", "BName", str arcName, "");
    setAttribute("arc", "EName", str arcName, "");
    setAttribute("arc", "Begin", str arcName, b);
    setAttribute("arc", "End", str arcName, e);
    setAttribute("arc", "EndType", str arcName, et);
    setAttribute("arc", "Angle", str arcName, angle((point b of fullcircle) - (point e of fullcircle)));
    setAttribute("arc", "Synonym", str arcName, str arcName);
enddef;

vardef byArcBE (suffix o)(expr b, e, r, col, dp, th, s, et) (suffix arcName) =
    byArcDefine(o, b, e, r, col, dp, th, s, et) (arcName);
    byNamedArcExact(arcName)
enddef;

vardef byArc (suffix o, pb, pe)(expr r, col, dp, th, s, et) (suffix arcName) =
    save b, e;
    numeric b, e;
    b := xpart(((fullcircle scaled 2r) shifted o) intersectiontimes (o -- 2[o, pb]));
    e := xpart(((fullcircle scaled 2r) shifted o) intersectiontimes (o -- 2[o, pe]));
    if (b > e):
        b := b - 8;
    fi;
    byArcDefine(o, b, e, r, col, dp, th, s, et)(arcName);
    setAttribute("arc", "BName", str arcName, str pb);
    setAttribute("arc", "EName", str arcName, str pe);
    byNamedArcExact(arcName)
enddef;

vardef byNamedArcExact(text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(getAttribute("arc", "Center", str aN), getAttribute("arc", "Begin", str aN), getAttribute("arc", "End", str aN), getAttribute("arc", "Diameter", str aN), getAttribute("arc", "Color", str aN), getAttribute("arc", "Dashed", str aN), getAttribute("arc", "Thin", str aN), getAttribute("arc", "Shift", str aN), getAttribute("arc", "EndType", str aN));
        endfor;
        if (autoLabelingMode):
            draw byNamedArcLabel(arcslist);
        fi;
    )
enddef;

vardef byNamedArc(text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(getAttribute("arc", "Center", str aN), getAttribute("arc", "Begin", str aN), getAttribute("arc", "End", str aN), getAttribute("arc", "Diameter", str aN), getAttribute("arc", "Color", str aN), getAttribute("arc", "Dashed", str aN), getAttribute("arc", "Thin", str aN), 0, 0);
        endfor;
        if (autoLabelingMode):
            draw byNamedArcLabel(arcslist);
        fi;
    )
enddef;

vardef byNamedArcLabel (text arcslist) =
    save pointsListB, pointsListE, pointsListO, i, j, allArcsDefined;
    string pointsListB[], pointsListE[], pointsListO[];
    numeric i, j;
    boolean allArcsDefined;
    image(
        if (textLabels):
            i := -1;
            allArcsDefined := true;
            forsuffixes aN=arcslist:
                i := i + 1;
                pointsListB[i] := getAttribute("arc", "BName", str aN);
                pointsListE[i] := getAttribute("arc", "EName", str aN);
                pointsListO[i] := getAttribute("arc", "CenterName", str aN);
                if (getAttribute("arc", "BName", str aN) == "") or (getAttribute("arc", "EName", str aN) == ""):
                    allArcsDefined := false;
                fi;
            endfor;
            if allArcsDefined:
                for j := 0 step 1 until i:
                    if (pointsListB[j] <> pointsListE[cycleval(j-1, i+1)]):
                        draw byTextLabel(pointLabel)(
                            pointsListB[j],
                            scantokens(pointsListB[j]),
                            angle(scantokens(pointsListB[j])-scantokens(pointsListO[j])) - 90,
                            textLabelShift);
                    fi;
                    if (pointsListE[j] <> pointsListB[cycleval(j+1, i+1)]):
                        draw byTextLabel(pointLabel)(
                            pointsListE[j],
                            scantokens(pointsListE[j]),
                            angle(scantokens(pointsListE[j])-scantokens(pointsListO[j])) + 90,
                            textLabelShift);
                    fi;
                endfor;
            fi;
        fi;
    )
enddef;

vardef byCircleDefineFree (expr o, r, col, dp, th, s) (suffix circleName) =
    setAttribute("circle", "Color", str circleName, col);
    setAttribute("circle", "Dashed", str circleName, dp);
    setAttribute("circle", "Thin", str circleName, th);
    setAttribute("circle", "Shift", str circleName, s);
    setAttribute("circle", "Diameter", str circleName, 2r);
    setAttribute("circle", "Center", str circleName, o);
    setAttribute("circle", "CenterName", str circleName, "");
    setAttribute("circle", "AName", str circleName, "");
    setAttribute("circle", "BName", str circleName, "");
    setAttribute("circle", "CName", str circleName, "");
    setAttribute("circle", "Synonym", str circleName, str circleName);
enddef;

vardef byCircleDefineR (suffix o)(expr r, col, dp, th, s) (suffix circleName) =
    byCircleDefineFree(o, r, col, dp, th, s)(circleName);
    setAttribute("circle", "CenterName", str circleName, str o);
enddef;

vardef byCircleR (suffix o)(expr r, col, dp, th, s) (suffix circleName) =
    byCircleDefineR(o, r, col, dp, th, s)(circleName);
    byNamedCircle(circleName)
enddef;

vardef byCircle (suffix o, a)(expr col, dp, th, s) (suffix circleName) =
    byCircleDefineR(o, abs(a-o), col, dp, th, s)(circleName);
    setAttribute("circle", "AName", str circleName, str a);
    byNamedCircle(circleName)
enddef;

vardef byCircleABC (suffix a, b, c)(expr col, dp, th, s) (suffix circleName) =
    save o, r;
    pair o;
    numeric r;
    o = whatever[1/2[a, b], 1/2[a, b] shifted ((a-b) rotated 90)]
        = whatever[1/2[b, c], 1/2[b, c] shifted ((b-c) rotated 90)];
    r := abs(o - a);
    byCircleDefineFree(o, r, col, dp, th, s)(circleName);
    setAttribute("circle", "AName", str circleName, str a);
    setAttribute("circle", "BName", str circleName, str b);
    setAttribute("circle", "CName", str circleName, str c);
    byNamedCircle(circleName)
enddef;

vardef byNamedCircle(text circlesList) =
    image(
        forsuffixes cN=circlesList:
            draw byArcRender (getAttribute("circle", "Center", str cN), 0, 8, getAttribute("circle", "Diameter", str cN), getAttribute("circle", "Color", str cN), getAttribute("circle", "Dashed", str cN), getAttribute("circle", "Thin", str cN), getAttribute("circle", "Shift", str cN), 0);
            if (textLabels and autoLabelingMode):
                if (getAttribute("circle", "CenterName", str cN) <> ""):
                    draw byTextLabel(pointLabel)(
                        getAttribute("circle", "CenterName", str cN),
                        scantokens(getAttribute("circle", "CenterName", str cN)),
                        0, 0);
                fi;
                if (getAttribute("circle", "AName", str cN) <> ""):
                    draw byLabelCircle(getAttribute("circle", "AName", str cN), str cN);
                fi;
                if (getAttribute("circle", "BName", str cN) <> ""):
                    draw byLabelCircle(getAttribute("circle", "BName", str cN), str cN);
                fi;
                if (getAttribute("circle", "CName", str cN) <> ""):
                    draw byLabelCircle(getAttribute("circle", "CName", str cN), str cN);
                fi;
            fi;
        endfor;
    )
enddef;

%
% Arbitraty figures
%

vardef byArbitraryFigureDefine(expr p, col, dp, th)(suffix arbitraryFigureName) =
    setAttribute("arbitraryFigure", "Path", str arbitraryFigureName, p);
    setAttribute("arbitraryFigure", "Color", str arbitraryFigureName, col);
    setAttribute("arbitraryFigure", "Dashed", str arbitraryFigureName, dp);
    setAttribute("arbitraryFigure", "Thin", str arbitraryFigureName, th);
    setAttribute("arbitraryFigure", "Synonym", str arbitraryFigureName, str arbitraryFigureName);
enddef;

vardef byArbitraryFigure(expr p, col, dp, th)(suffix arbitraryFigureName) =
    byArbitraryFigureDefine(p, col, dp, th)(arbitraryFigureName);
    byNamedArbitraryFigure(arbitraryFigureName)
enddef;

vardef byNamedArbitraryFigure(text arbitraryFiguresList) =
    save p;
    path p;
    image(
        forsuffixes pN=arbitraryFiguresList:
            p := (getAttribute("arbitraryFigure", "Path", str pN) scaled scaleFactor);
            draw p withpen pencircle scaled lineThickness(getAttribute("arbitraryFigure", "Thin", str pN)) withcolor getAttribute("arbitraryFigure", "Color", str pN) if (getAttribute("arbitraryFigure", "Dashed", str pN) > 0): dashed byDashPattern(arclength(p), getAttribute("arbitraryFigure", "Dashed", str pN)) fi;
        endfor;
    ) rotated globalRotation
enddef;

%
% Filled figures
%

vardef byFilledCircleSegment (expr o, r, b, e, col) (suffix filledCircleSegmentName) =
    setAttribute("filledCircleSegment", "Color", str filledCircleSegmentName, col);
    setAttribute("filledCircleSegment", "Diameter", str filledCircleSegmentName, 2r);
    setAttribute("filledCircleSegment", "Begin", str filledCircleSegmentName, b);
    setAttribute("filledCircleSegment", "End", str filledCircleSegmentName, e);
    setAttribute("filledCircleSegment", "Center", str filledCircleSegmentName, o);
    setAttribute("filledCircleSegment", "Synonym", str filledCircleSegmentName, str filledCircleSegmentName);
    byNamedFilledCircleSegment(filledCircleSegmentName)
enddef;

vardef byNamedFilledCircleSegment(text filledCircleSegmentList) =
    save p;
    path p;
    image(
        forsuffixes csN=filledCircleSegmentList:
            fill ((subpath (getAttribute("filledCircleSegment", "Begin", str csN), getAttribute("filledCircleSegment", "End", str csN)) of fullcircle)--cycle) scaled (getAttribute("filledCircleSegment", "Diameter", str csN)*scaleFactor) shifted (getAttribute("filledCircleSegment", "Center", str csN)*scaleFactor) withcolor getAttribute("filledCircleSegment", "Color", str csN);
        endfor;
    ) rotated globalRotation
enddef;

vardef byFilledCircleSector (expr o, r, b, e, col) (suffix filledCircleSectorName) =
    setAttribute("filledCircleSector", "Color", str filledCircleSectorName, col);
    setAttribute("filledCircleSector", "Diameter", str filledCircleSectorName, 2r);
    setAttribute("filledCircleSector", "Begin", str filledCircleSectorName, b);
    setAttribute("filledCircleSector", "End", str filledCircleSectorName, e);
    setAttribute("filledCircleSector", "Center", str filledCircleSectorName, o);
    byNamedFilledCircleSector(filledCircleSectorName)
enddef;

vardef byNamedFilledCircleSector(text filledCircleSectorList) =
    image(
        forsuffixes csN=filledCircleSectorList:
            fill ((subpath (getAttribute("filledCircleSector", "Begin", str csN), getAttribute("filledCircleSector", "End", str csN)) of fullcircle)-- (0, 0) -- cycle) scaled (getAttribute("filledCircleSector", "Diameter", str csN)*scaleFactor) shifted (getAttribute("filledCircleSector", "Center", str csN)*scaleFactor) withcolor getAttribute("filledCircleSector", "Color", str csN);
        endfor;
    ) rotated globalRotation
enddef;

vardef byPolygonWithName(text pointsList)(expr col)(suffix polygonName)=
    save pL, p, tn;
    path p;
    string pL;
    numeric tn;
    pL := "";
    p := forsuffixes pN=pointsList: pN -- endfor cycle;
    tn := turningnumber(p);
    forsuffixes pN=pointsList:
        appendList(pL, str pN, -tn, false);
    endfor;
    setAttribute("polygon", "Path", str polygonName, p);
    setAttribute("polygon", "Color", str polygonName, col);
    setAttribute("polygon", "PointsList", str polygonName, pL);
    setAttribute("polygon", "Synonym", str polygonName, str polygonName);
    byNamedPolygon(polygonName)
enddef;

vardef byPolygon(text pointsList)(expr col)=
    save polygonName;
    string polygonName;
    polygonName := "";
    forsuffixes pN=pointsList:
        polygonName := polygonName & str pN;
    endfor;
    byPolygonWithName(pointsList)(col)(scantokens(polygonName))
enddef;

vardef byNamedPolygon(text polygonsList) =
    image(
        draw image(
            forsuffixes pN=polygonsList:
                if (getAttribute("polygon", "Color", str pN) <> white):
                    fill (getAttribute("polygon", "Path", str pN) scaled scaleFactor) withcolor getAttribute("polygon", "Color", str pN);
                else:
                    draw (getAttribute("polygon", "Path", str pN) scaled scaleFactor) withcolor black withpen pencircle scaled lineWidthThin;
                fi;
            endfor;
            ) rotated globalRotation;
        if (autoLabelingMode):
            draw byLabelPolygon(1)(polygonsList);
        fi;
    )
enddef;

vardef byMergePolygons(text polygonsList) =
    save pointsList, preList, postList, mergedList, points, postPoints, i, j, k, l, m, n, o, iteration, beforeJoin, polygonChecked, pointChecked;
    string pointsList[], preList[], postList[], mergedList, points[], postPoints[];
    numeric l, m, n, o, iteration;
    boolean beforeJoin, polygonChecked[], pointChecked[];
    n := -1;
    forsuffixes pN=polygonsList:
        n := n + 1;
        pointsList[n] := getAttribute("polygon", "PointsList", str pN);
        polygonChecked[n] := false;
    endfor;
    if (n > 0):
        iteration := -1;
        m := -1;
        forever:
            preList0 := "";
            postList0 := "";
            beforeJoin := true;
            iteration := iteration + 1;
            l := -1;
            forsuffixes i = scantokens(pointsList0):
                l := l + 1;
                if (l > m):
                    pointChecked[l] := false;
                fi;
                if (beforeJoin):
                    preList0 := preList0 & ", " & str i;
                    if (not pointChecked[l]):
                        for j := 1 step 1 until n:
                            if (beforeJoin and not polygonChecked[j]):
                                preList1 := "";
                                postList1 := "";
                                forsuffixes k=scantokens(pointsList[j]):
                                    if (beforeJoin):
                                        preList1 := preList1 & ", " & str k;
                                        if (k == i):
                                            beforeJoin := false;
                                            polygonChecked[j] := true;
                                            pointChecked[l] := true;
                                            o := l;
                                        fi;
                                    else:
                                        postList1 := postList1 & ", " & str k;
                                    fi;
                                endfor;
                            fi;
                        endfor;
                    fi;
                else:
                    postList0 := postList0 & ", " & str i;
                fi;
            endfor;
            if (not beforeJoin):
                mergedList := preList0 & postList1 & preList1 & postList0;
                mergedList := substring (2, length(mergedList)) of mergedList;
                pointsList0 := polygonCleanup(scantokens(mergedList));
                if (length(pointsList0) < length(mergedList)):
                    pointChecked[o] := false;
                    mergedList := pointsList0;
                fi;
                m := l;
            fi;
            exitif(beforeJoin or (iteration > 100));
        endfor;
    else:
        mergedList := pointsList0;
    fi;
    mergedList
enddef;

vardef polygonCleanup (text pointsList) =
    save cleanedList, points, m, n, iteration;
    string cleanedList, points[];
    numeric m, n, iteration;
    n := -1;
    forsuffixes pL = pointsList:
        n := n + 1;
        points[n] := str pL;
    endfor;
    iteration := -1;
    forever:
        iteration := iteration + 1;
        m := 0;
        for i := 0 step 1 until n:
            if (points[cycleval(i-2, n + 1)] == points[i]):
                m := m + 2;
            else:
                points[cycleval(i-m, n + 1)] := points[i];
            fi;
        endfor;
        n := n - m;
        exitif((m == 0) or (iteration > 100));
    endfor;
    for i := 0 step 1 until n:
        appendList(cleanedList, points[i], 1, false);
    endfor;
    cleanedList
enddef;

%
% Angles
%

vardef byAngleDefineWithName(suffix a, b, c)(expr col, sty)(suffix angleName) =
if mainPictureMode:
    appendList(pointAnglesList.b, str angleName, 1, true);
    appendList(anglePointsList, str b, 1, true);
fi;
    save p, q, d;
    path p;
    picture q;
    pair d;
    d := 1/2[unitvector(a-b),unitvector(c-b)];
    if (abs(d) == 0):
        d := (unitvector(a-c) rotated 90);
    fi;
    p := fullcircle rotated (180 + angle(d));
    p := subpath(xpart((p scaled u) intersectiontimes ((0, 0)--10[(0, 0), a - b])), xpart((p scaled u) intersectiontimes ((0, 0)--10[(0, 0), c - b]))) of p;
    setAttribute("angle", "Arc", str angleName, p);
    setAttribute("angle", "Val", str angleName, 180*arclength(p scaled 2)/pi);
    setAttribute("angle", "AVal", str angleName, angle(a-b));
    setAttribute("angle", "CVal", str angleName, angle(c-b));
    setAttribute("angle", "Direction", str angleName, angle(point (arctime arclength(p)/2 of p) of p));
    setAttribute("angle", "Color", str angleName, col);
    setAttributeMulti("angle", "OptionalColor", str angleName, white, 0);
    setAttribute("angle", "Style", str angleName, sty);
    setAttribute("angle", "Center", str angleName, b);
    setAttribute("angle", "AName", str angleName, str a);
    setAttribute("angle", "BName", str angleName, str b);
    setAttribute("angle", "CName", str angleName, str c);
    setAttribute("angle", "ScaleCorrection", str angleName, 1);
    setAttribute("angle", "Standalone", str angleName, 0);
    setAttribute("angle", "Synonym", str angleName, str angleName);
enddef;

vardef byAngleDefine(suffix a, b, c)(expr col, sty) =
    byAngleDefineWithName(a, b, c)(col, sty)(scantokens(str a & str b & str c));
enddef;

vardef byAngleWithName(suffix a, b, c)(expr col, sty)(suffix angleName) =
    byAngleDefineWithName(a, b, c, col, sty)(angleName);
    byNamedAngle(angleName)
enddef;

vardef byAngle(suffix a, b, c)(expr col, sty) =
    byAngleWithName(a, b, c)(col, sty)(scantokens(str a & str b & str c))
enddef;

vardef byAngleDefineExtendedWithName(suffix a, b, c)(expr col, sty)(suffix angleName)(text optionalColors) =
    save n;
    numeric n;
    n := 0;
    byAngleDefineWithName(a, b, c, col, sty)(angleName);
    forsuffixes oC=optionalColors:
        setAttributeMulti("angle", "OptionalColor", str angleName, oC, n);
        n := n + 1;
    endfor;
enddef;

vardef byAngleDefineExtended(suffix a, b, c)(expr col, sty)(text optionalColors) =
    byAngleDefineExtendedWithName(a, b, c)(col, sty)(scantokens(str a & str b & str c))(optionalColors);
enddef;

vardef byAngleExtendedWithName(suffix a, b, c)(expr col, sty)(suffix angleName)(text optionalColors) =
    byAngleDefineExtendedWithName(a, b, c)(col, sty)(angleName)(optionalColors);
    byNamedAngle(angleName)
enddef;

vardef byAngleExtended(suffix a, b, c)(expr col, sty)(text optionalColors) =
    byAngleExtendedWithName(a, b, c)(col, sty)(scantokens(str a & str b & str c))(optionalColors)
enddef;

vardef byNamedAngle(text anglesList) =
    save p, q;
    picture q;
    path p;
    image(
        forsuffixes aN=anglesList:
            setAttribute("angle", "ScaleCorrection", str aN, angleScale);
            p := getAttribute("angle", "Arc", str aN);
            q := image(
                if (getAttribute("angle", "Color", str aN) <> white):
                    if (typeOf(getAttribute("angle", "Style", str aN)) == "numeric"):
                        draw scantokens(byAngleMacroName[getAttribute("angle", "Style", str aN)]) (p, getAttribute("angle", "Color", str aN), angleOptionalColor.scantokens(angleSynonym.aN));
                    elseif (typeOf(getAttribute("angle", "Style", str aN)) == "string"):
                        draw scantokens("byAngleM" & getAttribute("angle", "Style", str aN)) (p, getAttribute("angle", "Color", str aN), angleOptionalColor.scantokens(angleSynonym.aN));
                    fi;
                else:
                    draw byAngleMWhite(p, 0, 0);
                fi;
            );
            draw (q shifted (getAttribute("angle", "Center", str aN) scaled scaleFactor)) rotated globalRotation;
        endfor;
    )
enddef;

string byAngleMacroName[];
byAngleMacroName[-2] := "byAngleMWhite";
byAngleMacroName[-1] := "byAngleMThinLine";
byAngleMacroName[0] := "byAngleMSolid";
byAngleMacroName[1] := "byAngleMLine";
byAngleMacroName[2] := "byAngleMDashedLine";

vardef byAngleMWhite (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidthThin);
    image(
        fill ((0, 0)--p--cycle) withcolor white;
        draw p withpen pencircle scaled lineWidthThin withcolor black;
    )
enddef;

vardef byAngleMSolid (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled (u*angleScale);
    image(
        fill ((0, 0)--p--cycle) withcolor angleColor;
    )
enddef;

vardef byAngleMLine (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidth);
    image(
        fill ((0, 0)--p--cycle) withcolor angleOptionalColors[0];
        draw p withpen pencircle scaled lineWidth withcolor angleColor;
    )
enddef;

vardef byAngleMThinLine (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidthThin);
    image(
        fill ((0, 0)--p--cycle) withcolor angleOptionalColors[0];
        draw p withpen pencircle scaled lineWidthThin withcolor angleColor;
    )
enddef;

vardef byAngleMDashedLine (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidth);
    image(
        draw p withpen pencircle scaled lineWidth withcolor angleColor dashed byDashPattern(arclength(p), 1);
    )
enddef;

% Following monstrosity draws dummy sides for angles which require them,
% essentially, it takes a list of angles, checks if they all are constructed
% on one point; then it browses through all angles, finds their sides
% and counts them; ones that occur twice it draws as is; ones that occur
% once it shifts inside an angle; and after that it clips everything
% to angle outline.
vardef byNamedAngleSidesFull(text anglesList)(text linesList)=
    save centerName, uniqueCenter, angleDir, angleCount, angleType, angleSide, anglePart ,angleNum, angleCheck, ac, as, p, n, compoundAnglePath, compoundAngleArc, b, e, outputImage, lineCol, lineTh, lineDash, pointName, scaleToUse;
    string centerName, pointName[];
    pair ac, p[];
    boolean uniqueCenter, angleCheck, doNotLabelCenter;
    numeric angleDir[], angleCount[], angleType[], angleSide[], angleNum, anglePart[], as[], n[], b, e, lineTh, lineDash, scaleToUse;
    path compoundAnglePath, compoundAngleArc;
    color lineCol;
    picture outputImage;
    centerName := "";
    uniqueCenter := true;
    doNotLabelCenter := false;
    scaleToUse := -1;
    forsuffixes aN=anglesList:
        ac := getAttribute("angle", "Center", str aN);
        if (centerName == ""):
            centerName := getAttribute("angle", "BName", str aN);
        elseif (centerName <> getAttribute("angle", "BName", str aN)):
            uniqueCenter := false;
        fi;
        if (getAttribute("angle", "Standalone", str aN) > 1):
            doNotLabelCenter := true;
        fi;
        if (getAttribute("angle", "ScaleCorrection", str aN) <> angleScale)
        and (getAttribute("angle", "ScaleCorrection", str aN) > scaleToUse):
            scaleToUse := getAttribute("angle", "ScaleCorrection", str aN);
        fi;
    endfor;
    if (scaleToUse < 0):
        scaleToUse := angleScale;
    fi;
    outputImage := image(
        startTempAngleScale(scaleToUse);
            if (uniqueCenter):
                angleNum := 0;
                forsuffixes aN=anglesList:
                    anglePart1 := angle(point 0 of getAttribute("angle", "Arc", str aN));
                    as1 := sign(ypart((direction 0 of getAttribute("angle", "Arc", str aN)) rotated -anglePart1));
                    anglePart2 := angle(point 0 of reverse(getAttribute("angle", "Arc", str aN)));
                    as2 := sign(ypart((direction 0 of reverse(getAttribute("angle", "Arc", str aN))) rotated -anglePart2));
                    for j=1,2:
                        angleCheck := true;
                        for i := 1 step 1 until angleNum:
                            if ((abs(angleDir[i] - anglePart[j]) mod 360) < 1):
                                angleCount[i] := angleCount[i] + 1;
                                angleCheck := false;
                                if (getAttribute("angle", "Style", str aN) == 0) or (getAttributeMulti("angle", "OptionalColor", str aN, 0) <> white):
                                    angleType[i] := 0;
                                fi;
                            fi;
                        endfor;
                        if (angleCheck):
                            angleNum := angleNum + 1;
                            angleDir[angleNum] := anglePart[j];
                            angleSide[angleNum] := as[j];
                            if (getAttribute("angle", "Style", str aN) <> 0) and (getAttributeMulti("angle", "OptionalColor", str aN, 0) == white):
                                angleType[angleNum] := 1;
                            else:
                                angleType[angleNum] := 0;
                            fi;
                            if (j == 1):
                                if (getAttribute("angle", "Standalone", str aN) > 0):
                                    pointName[angleNum] := "";
                                else:
                                    pointName[angleNum] := getAttribute("angle", "AName", str aN);
                                fi;
                            elseif (j == 2):
                                if (getAttribute("angle", "Standalone", str aN) > 0):
                                    pointName[angleNum] := "";
                                else:
                                    pointName[angleNum] := getAttribute("angle", "CName", str aN);
                                fi;
                            fi;
                            angleCount[angleNum] := 1;
                        fi;
                    endfor;
                endfor;
                j := 0;
                for i := 1 step 1 until angleNum:
                    if (angleCount[i] == 1):
                        j := j + 1;
                        n[j] := i;
                    fi;
                    if (angleType[i] <> 0):
                        p1 := (ac*scaleFactor);
                        p2 := ((dir(angleDir[i]) scaled (u * angleScale))) shifted (ac*scaleFactor);
                        lineCol := black;
                        lineDash := 0;
                        lineTh := 1;
                        forsuffixes lN=linesList:
                            if (getAttribute("line", "EndAName", str lN) == centerName):
                                if (abs(angle(getAttribute("line", "EndB", str lN) - getAttribute("line", "EndA", str lN)) - angleDir[i]) < 1):
                                    lineCol := getAttribute("line", "Color", str lN);
                                    lineDash := getAttribute("line", "Dashed", str lN);
                                    lineTh := getAttribute("line", "Thin", str lN);
                                fi;
                            elseif (getAttribute("line", "EndBName", str lN) == centerName):
                                if (abs(angle(getAttribute("line", "EndA", str lN) - getAttribute("line", "EndB", str lN)) - angleDir[i]) < 1):
                                    lineCol := getAttribute("line", "Color", str lN);
                                    lineDash := getAttribute("line", "Dashed", str lN);
                                    lineTh := getAttribute("line", "Thin", str lN);
                                fi;
                            fi;
                        endfor;
                        if (angleCount[i] > 1):
                            draw byLineRender (p1, p2, lineCol, lineDash, lineTh, p1, p2, t, 0, 0, 1);
                        else:
                            draw byLineRender (p1, p2, lineCol, lineDash, lineTh, p1, p2, 0, 0, -angleSide[i], 1);
                        fi;
                    fi;
                endfor;
                if (j == 2):
                    b := (angleDir[n[1]]/360)*8;
                    e := (angleDir[n[2]]/360)*8;
                    if (b > e): b := b - 8; fi;
                    if (angleSide[n[1]] > angleSide[n[2]]):
                        compoundAngleArc := ((subpath (b, e) of fullcircle) scaled (u * angleScale)) shifted (ac*scaleFactor);
                    else:
                        compoundAngleArc := ((subpath (b + 8, e) of fullcircle) scaled (u * angleScale)) shifted (ac*scaleFactor);
                    fi;
                    compoundAnglePath := compoundAngleArc -- (ac*scaleFactor) -- cycle;
                elseif (j <> 0):
                    errmessage("There are gaps in the compound angle");
                fi;
            else:
                errmessage("The angles are not concentric");
            fi;
        stopTempAngleScale;
    );
    clip outputImage to compoundAnglePath;
    image(
        startTempAngleScale(scaleToUse);
            draw outputImage rotated globalRotation;
            if (textLabels and autoLabelingMode) and (j==2):
                for i=1,2:
                    draw byTextLabel(pointLabel)(pointName[n[i]], ac + (dir(angleDir[n[i]])*1/2u*angleScale)/scaleFactor, angleDir[n[i]], textLabelShift);
                endfor;
                if not doNotLabelCenter:
                    draw byTextLabel(pointLabel)(centerName, ac, angle((point (arctime(1/2arclength(compoundAngleArc)) of compoundAngleArc) of compoundAngleArc) shifted (-ac*scaleFactor)) + 180, textLabelShift);
                fi;
            fi;
        stopTempAngleScale;
    )
enddef;

vardef byNamedAngleDummySides(text anglesList)=
    byNamedAngleSidesFull(anglesList)(noLine)
enddef;

vardef byNamedAngleSides(text anglesList)(text linesList) =
    image(
        draw byNamedAngle(anglesList);
        draw byNamedAngleSidesFull(anglesList)(linesList);
        )
enddef;

vardef byNamedAngleWithDummySides(text anglesList)=
    image(
        draw byNamedAngle(anglesList);
        draw byNamedAngleDummySides(anglesList);
        )
enddef;

vardef byNamedAngleResized (text anglesToUse) =
    save modAnglesList, modAnglesListNew, anglesToDraw, anglesAdded, angleIsAdded, useThisAngle, sc, v, numOfAngles, i, j, k;
    string modAnglesList, modAnglesListNew, anglesToDraw;
    numeric anglesAdded, sc, v, numOfAngles;
    boolean angleIsAdded, useThisAngle;
    numOfAngles := 0;
    forsuffixes k=anglesToUse:
        if (length(str k) > 0):
            if typeOf(getAttribute("angle", "Synonym", str k)) <> "string":
                errmessage("Angle " & str k & " is missing");
            fi;
            numOfAngles := numOfAngles + 1;
        fi;
    endfor;
    image(
        forsuffixes i=scantokens(anglePointsList):
            modAnglesList := pointAnglesList.i;
            modAnglesListNew := "";
            forsuffixes j=scantokens(modAnglesList):
                if (numOfAngles > 0):
                    useThisAngle := false;
                    forsuffixes k=anglesToUse:
                        if (str j == str k):
                            useThisAngle := true;
                        fi;
                    endfor;
                else:
                    useThisAngle := true;
                fi;
                if (useThisAngle):
                    if (length(modAnglesListNew) == 0):
                        modAnglesListNew := str j;
                    else:
                        modAnglesListNew := str j & ", " & modAnglesListNew;
                    fi;
                fi;
            endfor;
            modAnglesList := modAnglesListNew;
            if (length(modAnglesList)>0):
                forever:
                    anglesToDraw := "";
                    forever:
                        modAnglesListNew := "";
                        anglesAdded := 0;
                        forsuffixes j=scantokens(modAnglesList):
                            if (length(anglesToDraw) == 0):
                                anglesToDraw := str j;
                            else:
                                forsuffixes k=scantokens(anglesToDraw):
                                    if ((abs(getAttribute("angle", "AVal", str k) - getAttribute("angle", "AVal", str j)) mod 360) < 1)
                                    or ((abs(getAttribute("angle", "CVal", str k) - getAttribute("angle", "AVal", str j)) mod 360) < 1)
                                    or ((abs(getAttribute("angle", "AVal", str k) - getAttribute("angle", "CVal", str j)) mod 360) < 1)
                                    or ((abs(getAttribute("angle", "CVal", str k) - getAttribute("angle", "CVal", str j)) mod 360) < 1):
                                        appendList(anglesToDraw, str j, 1, true);
                                        anglesAdded := anglesAdded + 1;
                                    fi;
                                endfor;
                            fi;
                        endfor;
                        forsuffixes j=scantokens(modAnglesList):
                            angleIsAdded := false;
                            forsuffixes k=scantokens(anglesToDraw):
                                if ((str j) == (str k)):
                                    angleIsAdded := true;
                                fi;
                            endfor;
                            if not angleIsAdded:
                                appendList(modAnglesListNew, str j, 1, false);
                            fi;
                        endfor;
                        modAnglesList := modAnglesListNew;
                    exitif (anglesAdded == 0) or (length(modAnglesList)==0);
                    endfor;
                    v := 0;
                    forsuffixes k=scantokens(anglesToDraw):
                        %v := v + angleVal.k;
                        if (getAttribute("angle", "Val", str k) > v): v := getAttribute("angle", "Val", str k); fi;
                    endfor;
                    sc := angleOpticalScale(v);
                    startTempAngleScale(angleScale*sc);
                        draw byNamedAngle(scantokens(anglesToDraw));
                    stopTempAngleScale;
                exitif (length(modAnglesList)==0);
                endfor;
            fi;
        endfor;
    )
enddef;

vardef generateAngleSynonyms =
    if string anglePointsList:
        save n, candidateName, originalName;
        numeric n;
        string candidateName[], originalName;
        forsuffixes i=scantokens(anglePointsList):
            n := 0;
            forsuffixes j=scantokens(pointAnglesList.i):
                if (length(str j) > 0):
                    n := n + 1;
                    originalName := str j;
                    candidateName0 := getAttribute("angle", "BName", originalName);
                    candidateName1 := getAttribute("angle", "AName", originalName)
                        & getAttribute("angle", "BName", originalName)
                        & getAttribute("angle", "CName", originalName);
                    candidateName2 := getAttribute("angle", "CName", originalName)
                        & getAttribute("angle", "BName", originalName)
                        & getAttribute("angle", "AName", originalName);
                    if not string getAttribute("angle", "Synonym", candidateName1):
                        setAttribute("angle", "SynonymPartial", candidateName1, false);
                        setAttribute("angle", "Synonym", candidateName1, originalName);
                    fi;
                    if not string getAttribute("angle", "Synonym", candidateName2):
                        setAttribute("angle", "SynonymPartial", candidateName2, false);
                        setAttribute("angle", "Synonym", candidateName2, originalName);
                    fi;
                fi;
            endfor;
            if (n == 1):
                if not string getAttribute("angle", "Synonym", candidateName0):
                    setAttribute("angle", "SynonymPartial", candidateName0, false);
                    setAttribute("angle", "Synonym", candidateName0, originalName);
                fi;
            fi;
        endfor;
    fi;
enddef;

vardef twoRightAngles =
    save textLabels;
    boolean textLabels;
    textLabels := false;
    image(
        draw byNamedAngle(rightAngleWN,rightAngleNE);
        draw byNamedAngleDummySides(rightAngleWN,rightAngleNE);
    )
enddef;

vardef rightAngle =
    save textLabels;
    boolean textLabels;
    textLabels := false;
    image(
        draw byNamedAngle(rightAngleWN);
        draw byNamedAngleDummySides(rightAngleWN);
    )
enddef;

% Angles we often need
pair pointN, pointE, pointS, pointW, pointO;
pointN := (0, 2u*angleScale);
pointE := (2u*angleScale, 0);
pointS := (0, -2u*angleScale);
pointW := (-2u*angleScale, 0);
pointO := (0, 0);

byAngleDefineWithName (pointN, pointO, pointE)(black, 1)(rightAngleNE);
byAngleDefineWithName (pointE, pointO, pointS)(black, 1)(rightAngleES);
byAngleDefineWithName (pointS, pointO, pointW)(black, 1)(rightAngleSE);
byAngleDefineWithName (pointW, pointO, pointN)(black, 1)(rightAngleWN);

%
% Magnitudes
%

% along with 'magnitudesymbol' one symbol long 'magnitude' is also defined at the same time.
vardef byMagnitudeSymbolDefine (expr shp, col, sty)(suffix magnitudeSymbolName) =
    setAttribute("magnitude", "Color", str magnitudeSymbolName, col);
    setAttribute("magnitude", "Shape", str magnitudeSymbolName, shp);
    setAttribute("magnitude", "Style", str magnitudeSymbolName, sty);
    setAttributeMulti("magnitude", "Symbol", str magnitudeSymbolName, str magnitudeSymbolName, 1);
    setAttributeMulti("magnitude", "N", str magnitudeSymbolName, 1, 1);
    setAttribute("magnitude", "Alignment", str magnitudeSymbolName, 0);
    setAttribute("magnitude", "NumberOfRows", str magnitudeSymbolName, 1);
    setAttribute("magnitude", "Horizontal", str magnitudeSymbolName, false);
enddef;

vardef byNamedMagnitudeSymbol (expr n, hor)(suffix magnitudeSymbolName) =
    save p, q, i, s;
    path p;
    pair s[];
    picture q;
    p := (0, 0);
    if (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "circle"):
        p := fullcircle scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "semicircleUp"):
        p := ((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "semicircleDown"):
        p := (((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "sectorDown"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "sectorUp"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale) yscaled -1;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "wedgeUp"):
        p := (((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "wedgeDown"):
        p := ((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "square"):
        p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "halfsquare"):
            p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "rhombus"):
        p := ((0, 1/2) -- (-1/2, 0) -- (0, -1/2) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "halfrhombusUp"):
        p := ((0, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "miniTriangleUp"):
        p := ((-1/4, -1/4) -- (1/4, -1/4)  -- (0, 1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "miniTriangleDown"):
        p := ((-1/4, 1/4) -- (1/4, 1/4)  -- (0, -1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "miniSquare"):
        p := ((-1/4, -1/4) -- (1/4, -1/4) -- (1/4, 1/4) -- (-1/4, 1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) == "miniCircle"):
        p := fullcircle scaled (u*1/2magnitudeScale);
    fi;
    if (hor):
        s1 := (0, ypart(urcorner(p)) - ypart(lrcorner(p)));
        s2 := (0, magnitudeGap);
    else:
        s1 := (xpart(urcorner(p)) - xpart(ulcorner(p)), 0);
        s2 := (magnitudeGap, 0);
    fi;
    q := image(
        if (getAttribute("magnitude", "Style", str magnitudeSymbolName) == 0):
            fill p withcolor getAttribute("magnitude", "Color", str magnitudeSymbolName);
        else:
            draw p withpen (pencircle scaled lineWidthThin) withcolor getAttribute("magnitude", "Color", str magnitudeSymbolName);
        fi;
    );
    image(
        for i := 1 step 1 until n:
            draw q shifted (s1 scaled i) shifted (s2 scaled i);
        endfor;
    )
enddef;

vardef byMagnitudeDefine (suffix magnitudeName)(expr al, hor)(text rowsList)(text magnitudeSymbolsList) =
    setAttribute("magnitude", "Horizontal", str magnitudeName, hor);
    setAttribute("magnitude", "Alignment", str magnitudeName, al);
    save i;
    numeric i;
    i := 0;
    forsuffixes rN=rowsList:
        i := i + 1;
        setAttributeMulti("magnitude", "N", str magnitudeName, rN, i);
    endfor;
    setAttribute("magnitude", "NumberOfRows", str magnitudeName, i);
    i := 0;
    forever:
        forsuffixes sN=magnitudeSymbolsList:
            i := i + 1;
            if (i <= getAttribute("magnitude", "NumberOfRows", str magnitudeName)):
                setAttributeMulti("magnitude", "Symbol", str magnitudeName, str sN, i);
            fi;
        endfor;
    exitif (i >= getAttribute("magnitude", "NumberOfRows", str magnitudeName));
    endfor;
enddef;

vardef byNamedMagnitude (expr excl) (suffix magnitudeName) =
    save p, s, h, magC;
    picture p;
    pair s[];
    numeric h;
    h := 0;
    image(
        for magC := 1 step 1 until getAttribute("magnitude", "NumberOfRows", str magnitudeName):
            if (excl == 0) or ((excl < 0) and (magC <> -excl)) or ((excl > 0) and (magC == excl)):
                p := byNamedMagnitudeSymbol(getAttributeMulti("magnitude", "N", str magnitudeName, magC), getAttribute("magnitude", "Horizontal", str magnitudeName))(scantokens(getAttributeMulti("magnitude", "Symbol", str magnitudeName, magC)));
                if (getAttribute("magnitude", "Horizontal", str magnitudeName)):
                    if (getAttribute("magnitude", "Alignment", str magnitudeName) = 0):
                        s1 := 1/2[urcorner(p),lrcorner(p)];
                    elseif (getAttribute("magnitude", "Alignment", str magnitudeName) = 1):
                        s1 := lrcorner(p);
                    elseif (getAttribute("magnitude", "Alignment", str magnitudeName) = -1):
                        s1 := urcorner(p);
                    fi;
                    s2 := (h, 0);
                else:
                    if (getAttribute("magnitude", "Alignment", str magnitudeName) = 0):
                        s1 := 1/2[ulcorner(p),urcorner(p)];
                    elseif (getAttribute("magnitude", "Alignment", str magnitudeName) = 1):
                        s1 := urcorner(p);
                    elseif (getAttribute("magnitude", "Alignment", str magnitudeName) = -1):
                        s1 := ulcorner(p);
                    fi;
                    s2 := (0, -h);
                fi;
                draw p shifted -s1 shifted s2;
                if (getAttribute("magnitude", "Horizontal", str magnitudeName)):
                    h := h + (abs(ulcorner(p)-urcorner(p))) + magnitudeGap;
                else:
                    h := h + (abs(ulcorner(p)-llcorner(p))) + magnitudeGap;
                fi;
            fi;
        endfor;
    )
enddef;

%
% Text labels
%

vardef textLabelRender(expr t) =
    textext("\tf\ss " & t) scaled 2/5
enddef;

numeric textLabelAvSize;
textLabelAvSize := abs(ulcorner(textLabelRender("A")) - llcorner(textLabelRender("A")));

vardef byTextLabel(suffix labelType)(expr t, p, a, d) =
    save labelItself, bb;
    path bb;
    picture labelItself;
    if not string labelType.scantokens(t):
        string labelType.scantokens(t);
        labelType.scantokens(t) := t;
    fi;
    labelItself := textLabelRender(labelType.scantokens(t));
    labelItself := labelItself shifted -1/2[ulcorner(labelItself), lrcorner(labelItself)];
    if (d > 0):
        bb := ulcorner(labelItself) -- urcorner(labelItself) -- lrcorner(labelItself) -- llcorner(labelItself)--cycle;
        labelItself := labelItself shifted -(bb intersectionpoint ((0,0)--(dir(a+180+globalRotation)*1cm)));
    fi;
    image(
        draw labelItself shifted ((p scaled scaleFactor) rotated globalRotation) shifted (dir(a+globalRotation)*d);
    )
enddef;

vardef byLabelPoint(suffix p)(expr a, d) =
    image(
        if (textLabels):
            draw byTextLabel(pointLabel)(str p, p, a, textLabelShift*d);
        fi;
    )
enddef;

vardef byLabelLine(expr d)(text linesList) =
    save a;
    numeric a;
    if (d = 0):
        a := 90;
    else:
        a := -90;
    fi;
    image(
        if (textLabels):
        forsuffixes lN=linesList:
            if (getAttribute("line", "UseLineLabel", str lN)):
                draw byTextLabel(pointLabel)(getAttribute("line", "Label", str lN), 1/2[getAttribute("line", "EndA", str lN), getAttribute("line", "EndB", str lN)], getAttribute("line", "Angle", str lN) + a, textLabelShift);
            else:
                draw byTextLabel(pointLabel)(getAttribute("line", "EndAName", str lN), getAttribute("line", "EndA", str lN), getAttribute("line", "Angle", str lN) + a, textLabelShift);
                draw byTextLabel(pointLabel)(getAttribute("line", "EndBName", str lN), getAttribute("line", "EndB", str lN), getAttribute("line", "Angle", str lN) + a, textLabelShift);
            fi;
        endfor;
        fi;
    )
enddef;

vardef byLabelPolygon(expr d)(text polygonsList) =
    image(
        if (textLabels):
            draw byLabelsOnPolygon(scantokens byMergePolygons(polygonsList))(1, d);
        fi;
    )
enddef;

vardef byLabelCircle(expr l, cn) =
    save o, d;
    pair o;
    numeric d;
    o := getAttribute("circle", "Center", cn);
    d := lineThickness(getAttribute("circle", "Thin", cn))*(1/2-1/2getAttribute("circle", "Shift", cn));
    byTextLabel(pointLabel)(l, scantokens(l), angle(o - scantokens(l)), textLabelShift + d)
enddef;

vardef byLabelsOnCircle(text pointsList)(suffix cn) =
    save d, cn, t, s, c;
    string cn;
    numeric t, s;
    pair c;
    if string getAttribute("circle", "CenterName", str cn):
        t := getAttribute("circle", "Thin", str cn);
        s := getAttribute("circle", "Shift", str cn);
        c := getAttribute("circle", "Center", str cn);
    elseif string getAttribute("arc", "CenterName", str cn):
        t := getAttribute("arc", "Thin", str cn);
        s := getAttribute("arc", "Shift", str cn);
        c := getAttribute("arc", "Center", str cn);
    else:
        errmessage("There is no circle or arc named " & str cn);
    fi;
    d := lineThickness(t)*(1/2+1/2s);
    image(
        if (textLabels):
            forsuffixes pN=pointsList:
                draw byTextLabel(pointLabel)(str pN, pN, angle(pN - c), textLabelShift + d);
            endfor;
        fi;
    )
enddef;

vardef byLabelsOnPolygon(text pointsList)(expr sty, shft)=
    image(
        if(textLabels):
            save pointName, pointLoc, i, j, k, l, p, q, stump, sv;
            numeric i, j, k, l, stump, sv;
            string pointName[];
            pair pointLoc[], p[];
            i := -1;
            forsuffixes pN=pointsList:
                boolean pointDrawn.pN;
                pointDrawn.pN := false;
                i := i + 1;
                pointName[i] := str pN;
                if (pointName[i] <> "noPoint"):
                    pointLoc[i] := pN;
                fi;
                if (i > 0):
                    if (pointName[i] == pointName[i-1]):
                        i := i - 1;
                    fi;
                fi;
            endfor;
            if (pointName[i] == pointName[0]):
                i := i - 1;
            fi;
            if (i == 1):
                i := i + 1;
                pointName[i] := "noPoint";
            fi;
            for j := 0 step 1 until i:
                k := cycleval(j - 1, i + 1);
                l := cycleval(j + 1, i + 1);
                if (pointName[j] <> "noPoint"):
                    p1 := pointLoc[j];
                    stump := 0;
                    if (pointName[k] <> "noPoint") or (pointName[l] <> "noPoint"):
                        if (pointName[k] == "noPoint"):
                            p2 := pointLoc[l];
                            p0 := 2[p2, p1];
                            stump := -1;
                        elseif (pointName[l] == "noPoint"):
                            p0 := pointLoc[k];
                            p2 := 2[p0, p1];
                            stump := +1;
                        else:
                            p0 := pointLoc[k];
                            p2 := pointLoc[l];
                        fi;
                    fi;
                    pair q[];
                    q4 := unitvector(p1-p0) rotated 90;
                    q5 := unitvector(p2-p1) rotated 90;
                    if ((abs(angle(q4) - angle(q5)) mod 180) > 1):
                        q0 := p0 shifted q4;
                        q1 := p1 shifted q4;
                        q2 := p1 shifted q5;
                        q3 := p2 shifted q5;
                        q6 = whatever[q0, q1] = whatever[q2, q3];
                    else:
                        if (sty <> 1) or (stump <> 0):
                            q6 := p1 shifted q4;
                        else:
                            q6 := p1;
                        fi;
                    fi;
                    if (sty == 2) and ((j == 0) or (j == i)):
                        pointDrawn.scantokens(pointName[j]) := true;
                    fi;
                    if (q6 <> p1) and (not pointDrawn.scantokens(pointName[j])):
                        sv := byLabelAngleCompensate(p0, p1, p2, shft);
                        draw byTextLabel(pointLabel)(pointName[j], pointLoc[j], angle(q6-p1), textLabelShift+sv);
                        pointDrawn.scantokens(pointName[j]):= true;
                    fi;
                fi;
            endfor;
        fi;
    )
enddef;

vardef byLabelLineEnd (suffix a, b)(expr d) =
    image(
        if (textLabels):
            draw byTextLabel(pointLabel)(str a, a, angle(a-b), textLabelShift+(d*lineWidth));
        fi;
    )
enddef;

vardef byLabelAngleCompensate (expr a, b, c, s) =
    save ang, ins;
    numeric ang, ins;
    ang := angleValue(a, b, c)/2;
    if (sind(ang*2)>0):
        ins := (cosd(ang)/(2*sind(ang)))*textLabelAvSize;
    else:
        ins := 0;
    fi;
    (((abs(sind(ang)) + abs(cosd(ang)/abs(sind(ang))))*(lineWidth*(1/2-1/2s)))/2) + ins
enddef;
