%    byrne-euclid 0.0.5
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

pi := 3.1415926;
radian := 180/pi;
lineWidth := 2pt;
lineWidthThin := 1pt;
lineWidthHair := 1/2pt;
u := 1cm;
scaleFactor := 1;
angleScale := 1;
globalRotation := 0;
magnitudeScale := 1/3;
magnitudeGap := 2lineWidth;
markLength := 5lineWidth;

boolean textLabels, autoLabelingMode;

textLabels := false;
textLabelShift := lineWidth;
autoLabelingMode := false;

numeric dpLength[];
dpLength0 := 2lineWidth;
dpLength1 := 2lineWidth;

vardef sin primary x = (sind(x*radian)) enddef;

vardef cos primary x = (cosd(x*radian)) enddef;

color byred, byblue, byyellow, lineColor.noLine;
byred := (.9, .15, .05);
byblue := (.05, .2, .7);
byyellow := (.9, .75, .1);

string lineEndAName.noLine, lineEndBName.noLine;

lineColor.noLine := white;
lineDashed.noLine := 0;
lineEndAName.noLine := "noLine";
lineEndBName.noLine := "noLine";
lineEndA.noLine := inf;
lineEndB.noLine := inf;

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
    if (sind(v) < 0): v := -v; fi;
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
color lineColor.lineName;
path line.lineName;
numeric lineShift.lineName, lineDashed.lineName, lineLength.lineName, lineAngle.lineName, lineEndAType.lineName, lineEndBType.lineName;
pair lineEndA.lineName, lineEndB.lineName, lineDirA.lineName, lineDirB.lineName;
string lineEndAName.lineName, lineEndBName.lineName;
    lineAngle.lineName := angle(b-a);
    lineColor.lineName := col;
    lineDashed.lineName := dp;
    lineThin.lineName := th;
    lineLength.lineName := arclength(a--b);
    lineEndA.lineName := a;
    lineEndB.lineName := b;
    lineShift.lineName := 0;
    lineDirA.lineName := a;
    lineDirB.lineName := b;
    lineEndAType.lineName := 0;
    lineEndBType.lineName := 0;
    lineEndAName.lineName := str a;
    lineEndBName.lineName := str b;
enddef;

vardef byLineDefine (suffix a, b) (expr col, dp, th) =
    byLineDefineWithName (a, b, col, dp, th) (scantokens(str a & str b));
enddef;

vardef byLineStylize (expr c, d, ct, dt, s) (suffix lineName) =
    lineShift.lineName := s;
    lineDirA.lineName := c;
    lineDirB.lineName := d;
    lineEndAType.lineName := ct;
    lineEndBType.lineName := dt;
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
    byNamedLineFull(a, b, 0, 0, 0)(lineName)
enddef;

vardef byNamedLineFull(expr c, d, ct, dt, s) (suffix lineName) =
    byLineRender(lineEndA.lineName, lineEndB.lineName, lineColor.lineName, lineDashed.lineName, lineThin.lineName, c, d, ct, dt, s, scaleFactor)
enddef;

vardef byNamedLine(text linesList) =
    image(
        forsuffixes lN=linesList:
            draw byNamedLineFull(lineDirA.lN, lineDirB.lN, lineEndAType.lN, lineEndBType.lN, lineShift.lN)(lN);
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
            lAname[i] := lineEndAName.lN;
            lBname[i] := lineEndBName.lN;
            lShift[i] := lineShift.lN;
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
                lineShift.lN := s;
                draw byNamedLineFull(lineEndA.lN, lineEndB.lN, 0, 0, s)(lN);
                if (textLabels and autoLabelingMode):
                    draw byLabelsOnPolygon(scantokens (lineEndAName.lN & ", " & lineEndBName.lN))(1, s);
                fi;
            endfor;
        fi;
    )
enddef;

vardef byMarkLine(expr pos, col)(suffix lineName) =
numeric markPosition.lineName;
color markColor.lineName;
    markPosition.lineName := pos;
    markColor.lineName := col;
    byNamedMarkLine(lineName)
enddef;

vardef byNamedMarkLine(suffix lineName) =
    save p, q;
    pair q[];
    picture p;
    p := image(
        q0 := markPosition.lineName[lineEndA.lineName, lineEndB.lineName];
        q1 := q0 shifted (dir(lineAngle.lineName + 90) scaled 1/2markLength);
        q2 := q0 shifted (dir(lineAngle.lineName - 90) scaled 1/2markLength);
        q3 := (dir(lineAngle.lineName - 90) scaled (1/2lineWidth*lineShift.lineName));
        draw (q1--q2) shifted q3 withpen pencircle scaled lineWidthThin withcolor markColor.lineName;
    );
    p rotated globalRotation
enddef;

vardef byNamedCompoundLine(expr cu, pw)(text linesList) =
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
        lineNames[i] := lineEndAName.lN;
        lineNames[i+1] := lineEndBName.lN;
        if (i > 0):
            if (lineNames[i] <> lineNames[i-2])
                and (lineNames[i] <> lineNames[i-1])
                and (lineNames[i+1] <> lineNames[i-2])
                and (lineNames[i+1] <> lineNames[i-1]):
                lineNotContinuous := true;
            fi;
        fi;
        i := i + 2;
        angleCheck[i/2] := abs(cosd(lineAngle.lN));
        if (abs(angleCheck[i/2] - angleCheck[1]) > 1/100):
            lineNotStraight := true;
        fi;
        totalLength := totalLength + lineLength.lN;
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
            correctedLength := (lineLength.lN**pwL)*sc;
            currentPosition1 := currentPosition0 + correctedLength;
            a := (currentPosition0, 0);
            b := (currentPosition1, 0);
            draw byLineRender(a, b, lineColor.lN, lineDashed.lN, lineThin.lN, a, b, 0, 0, 0, scaleFactor);
            currentPosition0 := currentPosition1;
            if (i > 2):
                if (j == 0):
                    if (lineEndAName.lN == lineNames[2])
                        or (lineEndAName.lN == lineNames[3]):
                        endNames[0] := lineEndBName.lN;
                    elseif (lineEndBName.lN == lineNames[2])
                        or (lineEndBName.lN == lineNames[3]):
                        endNames[0] := lineEndAName.lN;
                    fi;
                fi;
                if (j == (i-2)/2):
                    if (lineEndAName.lN == lineNames[i-3])
                        or (lineEndAName.lN == lineNames[i-4]):
                        endNames[1] := lineEndBName.lN;
                    elseif (lineEndBName.lN == lineNames[i-3])
                        or (lineEndBName.lN == lineNames[i-4]):
                        endNames[1] := lineEndAName.lN;
                    fi;
                fi;
            else:
                endNames[0] := lineEndAName.lN;
                endNames[1] := lineEndBName.lN;
            fi;
            j := j + 1;
        endfor;
        if (textLabels and autoLabelingMode):
            draw byTextLabel(endNames[0], (0, 0), 90, textLabelShift);
            draw byTextLabel(endNames[1], b, 90, textLabelShift);
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
color arcColor.arcName;
pair arcCenter.arcName;
numeric arcDiameter.arcName, arcShift.arcName, arcDashed.arcName, arcBegin.arcName, arcEnd.arcName, arcAngle.arcName, arcThin.arcName, arcEndType.arcName;
string arcCenterName.arcName, arcBName.arcName, arcEName.arcName;
    arcColor.arcName := col;
    arcDashed.arcName := dp;
    arcThin.arcName := th;
    arcShift.arcName := s;
    arcDiameter.arcName := 2r;
    arcCenter.arcName := o;
    arcCenterName.arcName := str o;
    arcBName.arcName := "";
    arcEName.arcName := "";
    arcBegin.arcName := b;
    arcEnd.arcName := e;
    arcEndType.arcName := et;
    arcAngle.arcName := angle((point b of fullcircle) - (point e of fullcircle));
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
    arcBName.arcName := str pb;
    arcEName.arcName := str pe;
    byNamedArcExact(arcName)
enddef;

vardef byNamedArcExact(text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(arcCenter.aN, arcBegin.aN, arcEnd.aN, arcDiameter.aN, arcColor.aN, arcDashed.aN, arcThin.aN, arcShift.aN, arcEndType.aN);
        endfor;
        if (textLabels and autoLabelingMode):
            draw byNamedArcLabel(arcslist);
        fi;
    )
enddef;

vardef byNamedArc(text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(arcCenter.aN, arcBegin.aN, arcEnd.aN, arcDiameter.aN, arcColor.aN, arcDashed.aN, arcThin.aN, 0, 0);
        endfor;
        if (textLabels and autoLabelingMode):
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
        i := -1;
        allArcsDefined := true;
        forsuffixes aN=arcslist:
            i := i + 1;
            pointsListB[i] := arcBName.aN;
            pointsListE[i] := arcEName.aN;
            pointsListO[i] := arcCenterName.aN;
            if (arcBName.aN == "") or (arcEName.aN == ""):
                allArcsDefined := false;
            fi;
        endfor;
        if allArcsDefined:
            for j := 0 step 1 until i:
                if (pointsListB[j] <> pointsListE[cycleval(j-1, i+1)]):
                    draw byTextLabel(
                        pointsListB[j],
                        scantokens(pointsListB[j]),
                        angle(scantokens(pointsListB[j])-scantokens(pointsListO[j])) - 90,
                        textLabelShift);
                fi;
                if (pointsListE[j] <> pointsListB[cycleval(j+1, i+1)]):
                    draw byTextLabel(
                        pointsListE[j],
                        scantokens(pointsListE[j]),
                        angle(scantokens(pointsListE[j])-scantokens(pointsListO[j])) + 90,
                        textLabelShift);
                fi;
            endfor;
        fi;
    )
enddef;

vardef byCircleDefineFree (expr o, r, col, dp, th, s) (suffix circleName) =
color circleColor.circleName;
pair circleCenter.circleName;
numeric circleDiameter.circleName, circleShift.circleName, circleDashed.circleName, circleThin.circleName;
string circleCenterName.circleName, circleAName.circleName, circleBName.circleName, circleCName.circleName;
    circleColor.circleName := col;
    circleDashed.circleName := dp;
    circleThin.circleName := th;
    circleShift.circleName := s;
    circleDiameter.circleName := 2r;
    circleCenter.circleName := o;
    circleCenterName.circleName := "";
    circleAName.circleName := "";
    circleBName.circleName := "";
    circleCName.circleName := "";
enddef;

vardef byCircleDefineR (suffix o)(expr r, col, dp, th, s) (suffix circleName) =
    byCircleDefineFree(o, r, col, dp, th, s)(circleName);
    circleCenterName.circleName := str o;
enddef;

vardef byCircleR (suffix o)(expr r, col, dp, th, s) (suffix circleName) =
    byCircleDefineR(o, r, col, dp, th, s)(circleName);
    byNamedCircle(circleName)
enddef;

vardef byCircle (suffix o, a)(expr col, dp, th, s) (suffix circleName) =
    byCircleDefineR(o, abs(a-o), col, dp, th, s)(circleName);
    circleAName.circleName := str a;
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
    circleAName.circleName := str a;
    circleBName.circleName := str b;
    circleCName.circleName := str c;
    byNamedCircle(circleName)
enddef;

vardef byNamedCircle(text circlesList) =
    image(
        forsuffixes cN=circlesList:
            draw byArcRender (circleCenter.cN, 0, 8, circleDiameter.cN, circleColor.cN, circleDashed.cN, circleThin.cN, circleShift.cN, 0);
            if (textLabels and autoLabelingMode):
                if (circleCenterName.cN <> ""):
                    draw byTextLabel(
                        circleCenterName.cN,
                        scantokens(circleCenterName.cN),
                        0, 0);
                fi;
                if (circleAName.cN <> ""):
                    draw byLabelCircle(circleAName.cN, str cN);
                fi;
                if (circleBName.cN <> ""):
                    draw byLabelCircle(circleBName.cN, str cN);
                fi;
                if (circleCName.cN <> ""):
                    draw byLabelCircle(circleCName.cN, str cN);
                fi;
            fi;
        endfor;
    )
endgroup
enddef;

%
% Arbitraty figures
%

vardef byArbitraryFigureDefine(expr p, col, dp, th)(suffix arbitraryFigureName) =
color arbitraryFigureColor.arbitraryFigureName;
path arbitraryFigurePath.arbitraryFigureName;
numeric arbitraryFigureDashed.arbitraryFigureName, arbitraryFigureThin.arbitraryFigureName;
    arbitraryFigurePath.arbitraryFigureName := p;
    arbitraryFigureColor.arbitraryFigureName := col;
    arbitraryFigureDashed.arbitraryFigureName := dp;
    arbitraryFigureThin.arbitraryFigureName := th;
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
            p := (arbitraryFigurePath.pN scaled scaleFactor);
            draw p withpen pencircle scaled lineThickness(arbitraryFigureThin.pN) withcolor arbitraryFigureColor.pN if (arbitraryFigureDashed.pN > 0): dashed byDashPattern(arclength(p), arbitraryFigureDashed.pN) fi;
        endfor;
    ) rotated globalRotation
enddef;

%
% Filled figures
%

vardef byFilledCircleSegment (expr o, r, b, e, col) (suffix filledCircleSegmentName) =
color filledCircleSegmentColor.filledCircleSegmentName;
pair filledCircleSegmentCenter.filledCircleSegmentName;
numeric filledCircleSegmentDiameter.filledCircleSegmentName, filledCircleSegmentBegin.filledCircleSegmentName, filledCircleSegmentEnd.filledCircleSegmentName;
    filledCircleSegmentColor.filledCircleSegmentName := col;
    filledCircleSegmentDiameter.filledCircleSegmentName := 2r;
    filledCircleSegmentBegin.filledCircleSegmentName := b;
    filledCircleSegmentEnd.filledCircleSegmentName := e;
    filledCircleSegmentCenter.filledCircleSegmentName := o;
    byNamedFilledCircleSegment(filledCircleSegmentName)
enddef;

vardef byNamedFilledCircleSegment(text filledCircleSegmentList) =
    save p;
    path p;
    image(
        forsuffixes csN=filledCircleSegmentList:
            fill ((subpath (filledCircleSegmentBegin.csN, filledCircleSegmentEnd.csN) of fullcircle)--cycle) scaled (filledCircleSegmentDiameter.csN*scaleFactor) shifted (filledCircleSegmentCenter.csN*scaleFactor) withcolor filledCircleSegmentColor.csN;
        endfor;
    ) rotated globalRotation
enddef;

vardef byFilledCircleSector (expr o, r, b, e, col) (suffix filledCircleSectorName) =
color filledCircleSectorColor.filledCircleSectorName;
pair filledCircleSectorCenter.filledCircleSectorName;
numeric filledCircleSectorDiameter.filledCircleSectorName, filledCircleSectorBegin.filledCircleSectorName, filledCircleSectorEnd.filledCircleSectorName;
    filledCircleSectorColor.filledCircleSectorName := col;
    filledCircleSectorDiameter.filledCircleSectorName := 2r;
    filledCircleSectorBegin.filledCircleSectorName := b;
    filledCircleSectorEnd.filledCircleSectorName := e;
    filledCircleSectorCenter.filledCircleSectorName := o;
    byNamedFilledCircleSector(filledCircleSectorName)
enddef;

vardef byNamedFilledCircleSector(text filledCircleSectorList) =
    image(
        forsuffixes csN=filledCircleSectorList:
            fill ((subpath (filledCircleSectorBegin.csN, filledCircleSectorEnd.csN) of fullcircle)-- (0, 0) -- cycle) scaled (filledCircleSectorDiameter.csN*scaleFactor) shifted (filledCircleSectorCenter.csN*scaleFactor) withcolor filledCircleSectorColor.csN;
        endfor;
    ) rotated globalRotation
enddef;

vardef byPolygonWithName(text pointsList)(expr col)(suffix polygonName)=
color polygonColor.polygonName, polygonPointsList.polygonName;
path polygonPath.polygonName;
string polygonPointsList.polygonName;
    polygonPath.polygonName := forsuffixes pN=pointsList: pN -- endfor cycle;
    polygonColor.polygonName := col;
    polygonPointsList.polygonName := "";
    forsuffixes pN=pointsList:
        if (polygonPointsList.polygonName <> ""):
            if (turningnumber(polygonPath.polygonName) == 1):
                polygonPointsList.polygonName := str pN & ", " & polygonPointsList.polygonName;
            else:
                polygonPointsList.polygonName := polygonPointsList.polygonName & ", " &  str pN;
            fi;
        else:
            polygonPointsList.polygonName := str pN;
        fi;
    endfor;
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
                if (polygonColor.pN <> white):
                    fill (polygonPath.pN scaled scaleFactor) withcolor polygonColor.pN;
                else:
                    draw (polygonPath.pN scaled scaleFactor) withcolor black withpen pencircle scaled lineWidthThin;
                fi;
            endfor;
            ) rotated globalRotation;
        if (textLabels and autoLabelingMode):
            draw byLabelsOnPolygon(scantokens byMergePolygons(polygonsList))(1, 1);
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
        pointsList[n] := polygonPointsList.pN;
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
    cleanedList := points[0];
    for i := 1 step 1 until n:
        cleanedList := cleanedList & ", " & points[i];
    endfor;
    cleanedList
enddef;

%
% Angles
%

vardef byAngleDefineWithName(suffix a, b, c)(expr col, sty)(suffix angleName) =
path angleArc.angleName;
color angleColor.angleName, angleOptionalColor.angleName[];
numeric angleDirection.angleName;
pair angleCenter.angleName;
string angleAName.angleName, angleBName.angleName, angleCName.angleName;
    save p, q;
    path p;
    picture q;
    p := fullcircle rotated (180 + angle(unitvector(1/2[a,c]-b)));
    p := subpath(xpart((p scaled u) intersectiontimes ((0, 0)--10[(0, 0), a - b])), xpart((p scaled u) intersectiontimes ((0, 0)--10[(0, 0), c - b]))) of p;
    angleArc.angleName := p;
    angleDirection.angleName := angle(point (arctime arclength(p)/2 of p) of p);
    angleColor.angleName := col;
    angleOptionalColor.angleName[0] := white;
    angleStyle.angleName := sty;
    angleCenter.angleName := b;
    angleAName.angleName := str a;
    angleBName.angleName := str b;
    angleCName.angleName := str c;
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

vardef byAngleExtendedWithName(suffix a, b, c)(expr col, sty)(suffix angleName)(text optionalColors) =
    save n;
    numeric n;
    n := 0;
    byAngleDefineWithName(a, b, c, col, sty)(angleName);
    forsuffixes oC=optionalColors:
        angleOptionalColor.angleName[n] := oC;
        n := n + 1;
    endfor;
    byNamedAngle(angleName)
enddef;

vardef byAngleExtended(suffix a, b, c)(expr col, sty)(text optionalColors) =
    byAngleExtendedWithName(a, b, c)(col, sty)(scantokens(str a & str b & str c))(optionalColors)
enddef;

vardef byNamedAngle(text anglesList) =
    save p, q;
    picture q;
    path p[];
    image(
        forsuffixes aN=anglesList:
            p1 := angleArc.aN scaled (u*angleScale);
            p2 := angleArc.aN scaled ((u*angleScale) - lineWidth);
            p3 := angleArc.aN scaled ((u*angleScale) - lineWidthThin);
            q := image(
                if ((angleColor.aN <> white) and (angleColor.aN <> white)):
                    if (angleStyle.aN = 0):
                        fill ((0, 0)--p1--cycle) withcolor angleColor.aN;
                    elseif (angleStyle.aN = 1):
                        fill ((0, 0)--p1--cycle) withcolor angleOptionalColor.aN[0];
                        draw p2 withpen pencircle scaled lineWidth withcolor angleColor.aN;
                    elseif (angleStyle.aN = 2):
                        draw p2 withpen pencircle scaled lineWidth withcolor angleColor.aN dashed byDashPattern(arclength(p2), 1);
                    elseif (angleStyle.aN = 3):
                        for i := 1 step -1/floor((u*angleScale)/2mm) until 0:
                            draw (p3 scaled i) withpen pencircle scaled lineWidthThin withcolor angleColor.aN;
                        endfor;
                    elseif (angleStyle.aN = -1):
                            draw p3 withpen pencircle scaled lineWidthThin withcolor angleColor.aN;
                    fi;
                else:
                    fill ((0, 0)--p1--cycle) withcolor white;
                    draw ((0, 0)--p3--cycle) withpen pencircle scaled lineWidthThin withcolor black;
                fi;
            );
            clip q to ((0, 0)--p1--cycle);
            draw (q shifted (angleCenter.aN scaled scaleFactor)) rotated globalRotation;
        endfor;
    )
enddef;

% Following monstrosity draws dummy sides for angles which require them,
% essentially, it takes a list of angles, checks if they all are constructed
% on one point; then it browses through all angles, finds their sides
% and counts them; ones that occur twice it draws as is; ones that occur
% once it shifts inside an angle; and after that it clips everything
% to angle outline.
vardef byNamedAngleSidesFull(text anglesList)(text linesList)=
    save centerName, uniqueCenter, angleDir, angleCount, angleType, angleSide, anglePart ,angleNum, angleCheck, ac, as, p, n, compoundAnglePath, compoundAngleArc, b, e, outputImage, lineCol, lineTh, lineDash, pointName;
    string centerName, pointName[];
    pair ac, p[];
    boolean uniqueCenter, angleCheck;
    numeric angleDir[], angleCount[], angleType[], angleSide[], angleNum, anglePart[], as[], n[], b, e, lineTh, lineDash;
    path compoundAnglePath, compoundAngleArc;
    color lineCol;
    picture outputImage;
    centerName := "";
    uniqueCenter := true;
    forsuffixes aN=anglesList:
        ac := angleCenter.aN;
        if (centerName == ""):
            centerName := angleBName.aN;
        elseif (centerName <> angleBName.aN):
            uniqueCenter := false;
        fi;
    endfor;
    outputImage := image(
        if (uniqueCenter):
            angleNum := 0;
            forsuffixes aN=anglesList:
                anglePart1 := angle(point 0 of angleArc.aN);
                as1 := sign(ypart((direction 0 of angleArc.aN) rotated -anglePart1));
                anglePart2 := angle(point 0 of reverse(angleArc.aN));
                as2 := sign(ypart((direction 0 of reverse(angleArc.aN)) rotated -anglePart2));
                for j=1,2:
                    angleCheck := true;
                    for i := 1 step 1 until angleNum:
                            if (abs(angleDir[i] - anglePart[j]) < 1):
                                angleCount[i] := angleCount[i] + 1;
                                angleCheck := false;
                                if (angleStyle.aN == 0) or (angleOptionalColor.aN[0] <> white):
                                    angleType[i] := 0;
                                fi;
                            fi;
                    endfor;
                    if (angleCheck):
                        angleNum := angleNum + 1;
                        angleDir[angleNum] := anglePart[j];
                        angleSide[angleNum] := as[j];
                        if (angleStyle.aN <> 0) and (angleOptionalColor.aN[0] == white):
                            angleType[angleNum] := 1;
                        else:
                            angleType[angleNum] := 0;
                        fi;
                        if (j == 1):
                            pointName[angleNum] := angleAName.aN;
                        elseif (j == 2):
                            pointName[angleNum] := angleCName.aN;
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
                        if (lineEndAName.lN == centerName):
                            if (abs(angle(lineEndB.lN - lineEndA.lN) - angleDir[i]) < 1):
                                lineCol := lineColor.lN;
                                lineDash := lineDashed.lN;
                                lineTh := lineThin.lN;
                            fi;
                        elseif (lineEndBName.lN == centerName):
                            if (abs(angle(lineEndA.lN - lineEndB.lN) - angleDir[i]) < 1):
                                lineCol := lineColor.lN;
                                lineDash := lineDashed.lN;
                                lineTh := lineThin.lN;
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
    );
    clip outputImage to compoundAnglePath;
    image(
        draw outputImage rotated globalRotation;
        if (textLabels and autoLabelingMode) and (j==2):
            for i=1,2:
                draw byTextLabel(pointName[n[i]], ac + (dir(angleDir[n[i]])*1/2u*angleScale)/scaleFactor, angleDir[n[i]], textLabelShift);
            endfor;
            draw byTextLabel(centerName, ac, angle((point (arctime(1/2arclength(compoundAngleArc)) of compoundAngleArc) of compoundAngleArc) shifted (-ac*scaleFactor)) + 180, textLabelShift);
        fi;
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
color magnitudeColor.magnitudeSymbolName;
string magnitudeShape.magnitudeSymbolName;
numeric magnitudeStyle.magnitudeSymbolName;
string magnitudeSymbol.magnitudeSymbolName[];
numeric magnitudeN.magnitudeSymbolName[], magnitudeAlignment.magnitudeSymbolName, magnitudeNumberOfRows.magnitudeSymbolName;
boolean magnitudeHorizontal.magnitudeSymbolName;
    magnitudeColor.magnitudeSymbolName := col;
    magnitudeShape.magnitudeSymbolName := shp;
    magnitudeStyle.magnitudeSymbolName := sty;
    magnitudeSymbol.magnitudeSymbolName[1] := str magnitudeSymbolName;
    magnitudeN.magnitudeSymbolName[1] := 1;
    magnitudeAlignment.magnitudeSymbolName := 0;
    magnitudeNumberOfRows.magnitudeSymbolName := 1;
    magnitudeHorizontal.magnitudeSymbolName := false;
enddef;

vardef byNamedMagnitudeSymbol (expr n, hor)(suffix magnitudeSymbolName) =
    save p, q, i, s;
    path p;
    pair s[];
    picture q;
    p := (0, 0);
    if (magnitudeShape.magnitudeSymbolName == "circle"):
        p := fullcircle scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "semicircleUp"):
        p := ((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "semicircleDown"):
        p := (((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "sectorDown"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "sectorUp"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale) yscaled -1;
    elseif (magnitudeShape.magnitudeSymbolName == "wedgeUp"):
        p := (((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "wedgeDown"):
        p := ((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "square"):
        p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "halfsquare"):
            p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "rhombus"):
        p := ((0, 1/2) -- (-1/2, 0) -- (0, -1/2) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "halfrhombusUp"):
        p := ((0, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "miniTriangleUp"):
        p := ((-1/4, -1/4) -- (1/4, -1/4)  -- (0, 1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "miniTriangleDown"):
        p := ((-1/4, 1/4) -- (1/4, 1/4)  -- (0, -1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "miniSquare"):
        p := ((-1/4, -1/4) -- (1/4, -1/4) -- (1/4, 1/4) -- (-1/4, 1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (magnitudeShape.magnitudeSymbolName == "miniCircle"):
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
        if (magnitudeStyle.magnitudeSymbolName == 0):
            fill p withcolor magnitudeColor.magnitudeSymbolName;
        else:
            draw p withpen (pencircle scaled lineWidthThin) withcolor magnitudeColor.magnitudeSymbolName;
        fi;
    );
    image(
        for i := 1 step 1 until n:
            draw q shifted (s1 scaled i) shifted (s2 scaled i);
        endfor;
    )
enddef;

vardef byMagnitudeDefine (suffix magnitudeName)(expr al, hor)(text rowsList)(text magnitudeSymbolsList) =
string magnitudeSymbol.magnitudeName[];
numeric magnitudeN.magnitudeName[], magnitudeAlignment.magnitudeName, magnitudeNumberOfRows.magnitudeName;
boolean magnitudeHorizontal.magnitudeName;
magnitudeHorizontal.magnitudeName := hor;
magnitudeAlignment.magnitudeName := al;
    save i;
    numeric i;
    i := 0;
    forsuffixes rN=rowsList:
        i := i + 1;
        magnitudeN.magnitudeName[i] := rN;
    endfor;
    magnitudeNumberOfRows.magnitudeName := i;
    i := 0;
    forever:
        forsuffixes sN=magnitudeSymbolsList:
            i := i + 1;
            if (i <= magnitudeNumberOfRows.magnitudeName):
                magnitudeSymbol.magnitudeName[i] := str sN;
            fi;
        endfor;
    exitif (i >= magnitudeNumberOfRows.magnitudeName);
    endfor;
enddef;

vardef byNamedMagnitude (expr excl) (suffix magnitudeName) =
    save p, s, h, magC;
    picture p;
    pair s[];
    numeric h;
    h := 0;
    image(
        for magC := 1 step 1 until magnitudeNumberOfRows.magnitudeName:
            if (excl == 0) or ((excl < 0) and (magC <> -excl)) or ((excl > 0) and (magC == excl)):
                p := byNamedMagnitudeSymbol(magnitudeN.magnitudeName[magC], magnitudeHorizontal.magnitudeName)(scantokens(magnitudeSymbol.magnitudeName[magC]));
                if (magnitudeHorizontal.magnitudeName):
                    if (magnitudeAlignment.magnitudeName = 0):
                        s1 := 1/2[urcorner(p),lrcorner(p)];
                    elseif (magnitudeAlignment.magnitudeName = 1):
                        s1 := lrcorner(p);
                    elseif (magnitudeAlignment.magnitudeName = -1):
                        s1 := urcorner(p);
                    fi;
                    s2 := (h, 0);
                else:
                    if (magnitudeAlignment.magnitudeName = 0):
                        s1 := 1/2[ulcorner(p),urcorner(p)];
                    elseif (magnitudeAlignment.magnitudeName = 1):
                        s1 := urcorner(p);
                    elseif (magnitudeAlignment.magnitudeName = -1):
                        s1 := ulcorner(p);
                    fi;
                    s2 := (0, -h);
                fi;
                draw p shifted -s1 shifted s2;
                if (magnitudeHorizontal.magnitudeName):
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

vardef byPointLabelDefine(suffix pointName)(expr t) =
string pointLabel.pointName;
    pointLabel.pointName := t;
enddef;

vardef byTextLabel(expr t, p, a, d) =
    save labelItself, bb;
    path bb;
    picture labelItself;
    if not string pointLabel.scantokens(t):
        string pointLabel.scantokens(t);
        pointLabel.scantokens(t) := t;
    fi;
    labelItself := textext("\tf\ss " & pointLabel.scantokens(t)) scaled 2/5;
    labelItself := labelItself shifted -1/2[ulcorner(labelItself), lrcorner(labelItself)];
    if (d > 0):
        bb := ulcorner(labelItself) -- urcorner(labelItself) -- lrcorner(labelItself) -- llcorner(labelItself)--cycle;
        labelItself := labelItself shifted -(bb intersectionpoint ((0,0)--(dir(a+180+globalRotation)*1cm)));
    fi;
    image(
        draw labelItself shifted ((p scaled scaleFactor) rotated globalRotation) shifted (dir(a+globalRotation)*d);
    )
enddef;

vardef byLabelCircle(expr l, cn) =
    save o, d;
    pair o;
    numeric d;
    o := circleCenter.scantokens(cn);
    d := lineThickness(circleThin.scantokens(cn))*(1/2-1/2circleShift.scantokens(cn));
    byTextLabel(l, scantokens(l), angle(o - scantokens(l)), textLabelShift + d)
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
                            stump := 1;
                        elseif (pointName[l] == "noPoint"):
                            p0 := pointLoc[k];
                            p2 := 2[p0, p1];
                            stump := 1;
                        else:
                            p0 := pointLoc[k];
                            p2 := pointLoc[l];
                        fi;
                    fi;
                    pair q[];
                    q4 := unitvector(p1-p0) rotated 90;
                    q5 := unitvector(p2-p1) rotated 90;
                    if (abs(angle(q4) - angle(q5))>1):
                        q0 := p0 shifted q4;
                        q1 := p1 shifted q4;
                        q2 := p1 shifted q5;
                        q3 := p2 shifted q5;
                        q6 = whatever[q0, q1] = whatever[q2, q3];
                    else:
                        if (sty <> 1) or (stump == 1):
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
                        draw byTextLabel(pointName[j], pointLoc[j], angle(q6-p1), textLabelShift+sv);
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
            draw byTextLabel(str a, a, angle(a-b), textLabelShift+(d*lineWidth));
        fi;
    )
enddef;

vardef byLabelAngleCompensate (expr a, b, c, s) =
    save ang;
    numeric ang;
    ang := angleValue(a, b, c)/2;
    ((abs(sind(ang)) + abs(cosd(ang)/sind(ang)))*(lineWidth*(1/2-1/2s)))/2
enddef;
