%    byrne-euclid 0.2.1
%    MetaPost library that implements most of the graphical
%    features present in Oliver Byrne's version of Euclid's "Elements"
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
defaultScaleFactor := 1;
angleScale := 1;
globalRotation := 0;
magnitudeScale := 5/18;
magnitudeGap := 3/2lineWidth;
markLength := 3lineWidth;
rayExtension := 1/3u;

boolean textLabels, ghostLines, autoRightAngles, omitDuplicateTextLabels, autoLabelingMode, mainPictureMode;

textLabels := false;
ghostLines := true;
autoRightAngles := false;
omitDuplicateTextLabels := false;
textLabelShift := lineWidth;
autoLabelingMode := false;
mainPictureMode := false;

boolean solidAngleMode;

solidAngleMode := false;

numeric dpLength[];
dpLength0 := 2lineWidth;
dpLength1 := 2lineWidth;

vardef sin primary x = (sind(x*radian)) enddef;

vardef cos primary x = (cosd(x*radian)) enddef;

vardef arcsind primary x = angle((1+-+x,x)) enddef;

vardef arccosd primary x = angle((x,1+-+x)) enddef;

vardef pathToString (expr p) =
save outputString, endpoint, i;
    string outputString;
    if (length(p) > 0):
        outputString :=
            "(" & decimal(xpart(point 0 of p)) & ", " & decimal(ypart(point 0 of p)) & ")"
            & ".. controls (" & decimal(xpart(postcontrol 0 of p)) & ", " & decimal(ypart(postcontrol 0 of p)) & ") and "
            & "(" & decimal(xpart(precontrol 1 of p)) & ", " & decimal(ypart(precontrol 1 of p)) & ")";
        if (cycle p):
            endpoint := length(p) - 1;
        else:
            endpoint := length(p);
        fi;
        for i := 1 step 1 until endpoint:
            outputString := outputString
                & ".. (" & decimal(xpart(point i of p)) & ", " & decimal(ypart(point i of p)) & ")";
            if ((i < length(p)) or (cycle p)):
                outputString := outputString
                    & ".. controls (" & decimal(xpart(postcontrol i of p)) & ", " & decimal(ypart(postcontrol i of p)) & ") and "
                    & "(" & decimal(xpart(precontrol i + 1 of p)) & ", " & decimal(ypart(precontrol i + 1 of p)) & ")";
            fi;
        endfor;
        if (cycle p):
            outputString := outputString & " .. cycle";
        fi;
    else:
        outputString :=
            "(" & decimal(xpart(point 0 of p)) & ", " & decimal(ypart(point 0 of p)) & ")";
    fi;
    outputString
enddef;

color byred, byblue, byyellow, byblack, bygrey,
    byredN, byblueN, byyellowN, byblackN, bygreyN,
    outlineColor.byredN, outlineColor.byblueN, outlineColor.byyellowN, outlineColor.byblackN, outlineColor.bygreyN,
    bytransparent, byDefaultAngleOptionalColor;
byred := (.85, .3, .1);
byblue := (.15, .35, .6);
byyellow := (.95, .7, 0.1);
byblack := black;
bygrey := (.8, .8, .8);
byredN := white;
byblueN := white;
byyellowN := white;
byblackN := white;
bygreyN := white;
outlineColor.byredN := byred;
outlineColor.byblueN := byblue;
outlineColor.byyellowN := byyellow;
outlineColor.byblackN := byblack;
outlineColor.bygreyN := bygrey;
bytransparent := 0.99white;

byDefaultAngleOptionalColor := white;

linecap := butt;

vardef sign (expr x) =
    if x > 0: 1 fi
    if x < 0: -1 fi
    if x = 0: 1 fi
enddef;

vardef colorLightness (expr col) =
save r, g, b;
    if color col:
        r := redpart(col);
        g := greenpart(col);
        b := bluepart(col);
    elseif cmykcolor col:
        r := (1 - cyanpart(col)) * (1 - blackpart(col));
        g := (1 - magentapart(col)) * (1 - blackpart(col));
        b := (1 - yellowpart(col)) * (1 - blackpart(col));
    fi;
    (0.2126*r) + (0.7152*g) + (0.0722*b) % from here https://en.wikipedia.org/wiki/Relative_luminance but it doesn't work this way; to be corrected
enddef;

vardef isWhite (expr col) =
    if (colorLightness(col) = 1): % arbitrary value
        true
    else:
        false
    fi
enddef;

vardef isLight (expr col) =
    if (colorLightness(col) > 0.95): % arbitrary value
        true
    else:
        false
    fi
enddef;

vardef defineColor@#(expr col) =
    if (typeOf(col) = "color"):
        color @#;
    else:
        cmykcolor @#;
    fi;
    @# := col;
enddef;

vardef selectOutlineColor@# =
    if (typeOf(outlineColor.@#) = "color") or (typeOf(outlineColor.@#) = "cmykcolor"):
        outlineColor.@#
    else:
        black
    fi
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
    elseif (cmykcolor v):
        determinedType := "cmykcolor";
    elseif (color v):
        determinedType := "color";
    elseif (rgbcolor v):
        determinedType := "rgbcolor";
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

vardef lineThickness (expr th) =
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

vardef byDashPattern (expr l, dp) =
    save d, n;
    numeric d[], n;
    n := ceiling(l/(1/3dpLength[dp]));
    if (n mod 3) <> 2:
        n := n - (n mod 3) + 2;
    fi;
    d1 := 2(l/n);
    d2 := l/n;
    dashpattern (on d1 off d2)
enddef;

def startTempScale (expr tmpScale) =
    begingroup
        save scaleFactor;
        scaleFactor := tmpScale;
enddef;

def stopTempScale =
    endgroup
enddef;

def startTempAngleScale (expr tmpScale) =
    begingroup
        save angleScale;
        angleScale := tmpScale;
enddef;

def stopTempAngleScale =
    endgroup
enddef;

def startGlobalRotation (expr ang) =
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

def startOffspringPictureMode =
    begingroup
        save uniqueTextLabels, omitDuplicateTextLabels;
        string uniqueTextLabels;
        boolean omitDuplicateTextLabels;
        omitDuplicateTextLabels := true;
        uniqueTextLabels := "";
enddef;

def stopOffspringPictureMode =
    endgroup
enddef;

def startMainPictureMode =
    begingroup
        save mainPictureMode, ghostPicture;
        boolean mainPictureMode;
        picture ghostPicture;
        ghostPicture := image();
        mainPictureMode := true;
enddef;

picture ghostPicture;
ghostPicture := image();

def stopMainPictureMode =
    endgroup
enddef;

%
% This section is devoted to lists
%

vardef appendList (suffix listName)(expr valueToAdd, whereToAdd, omitDuplicates) =
    if (not string listName) or (unknown listName):
        string listName;
        listName := "";
    fi;
    if length(listName) = 0:
        listName := valueToAdd;
    else:
        save valueExists;
        boolean valueExists;
        valueExists := false;
        if omitDuplicates:
            valueExists := isInList (valueToAdd, listName);
        fi;
        if not valueExists:
            if (whereToAdd = 1):
                listName := listName & ", " & valueToAdd;
            else:
                listName := valueToAdd & ", " & listName;
            fi;
        fi;
    fi;
enddef;

vardef isInList (expr valueToLookFor)(suffix listName) =
    save rv, i;
    boolean rv;
    rv := false;
    if (not string listName) or (unknown listName):
        string listName;
        listName := "";
    fi;
    forsuffixes i=scantokens(listName):
        if (str i = valueToLookFor):
            rv := true;
        fi;
    endfor;
    rv
enddef;

vardef setAttribute@#(expr attrGenus, attrSpecies, attrName, attrValue) =
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
    if str @# = "":
        scantokens(typeOf(attrValue)) scantokens(attrGenus & attrSpecies).scantokens(finName);
    elseif (typeOf(scantokens(attrGenus & attrSpecies).scantokens(finName)0) <> typeOf(attrValue)):
        scantokens(typeOf(attrValue)) scantokens(attrGenus & attrSpecies).scantokens(finName)[];
    fi;
    scantokens(attrGenus & attrSpecies).scantokens(finName)@# := attrValue;
enddef;

vardef getAttribute@#(expr attrGenus, attrSpecies, attrName) =
    save finName;
    string finName;
    if not string scantokens(attrGenus & "Synonym").scantokens(attrName):
        finName := attrName;
    else:
        finName := scantokens(attrGenus & "Synonym").scantokens(attrName);
        if (boolean scantokens(attrGenus & "SynonymPartial").scantokens(attrName)):
            if scantokens(attrGenus & "SynonymPartial").scantokens(attrName):
                if known scantokens(attrGenus & attrSpecies).scantokens(attrName)@#:
                    finName := attrName;
                fi;
            fi;
        fi;
    fi;
    scantokens(attrGenus & attrSpecies).scantokens(finName)@#
enddef;

vardef attributeExists (expr attrGenus, attrSpecies, attrName) =
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
setAttribute("line", "Synonym", "noLine", "noLine");

setAttribute("line", "Color", "dummyLine", bygrey);
setAttribute("line", "Dashed", "dummyLine", 0);
setAttribute("line", "Thin", "dummyLine", 1);

%
% Some general 3D stuff
%

color projectionAngle;
projectionAngle := (0, 0, 0);

color rotationAxisB.X, rotationAxisE.X, rotationAxisB.Y, rotationAxisE.Y, rotationAxisB.Z, rotationAxisE.Z;
string rotationAxisPart.X, rotationAxisPart.Y, rotationAxisPart.Z;
rotationAxisB.X := (0, 0, 0);
rotationAxisE.X := (1, 0, 0);
rotationAxisPart.X := "redpart";
rotationAxisB.Y := (0, 0, 0);
rotationAxisE.Y := (0, 1, 0);
rotationAxisPart.Y := "greenpart";
rotationAxisB.Z := (0, 0, 0);
rotationAxisE.Z := (0, 0, 1);
rotationAxisPart.Z := "bluepart";

primarydef somecolor colorrotated someangle =
    rotateColor(somecolor, someangle)
enddef;

% Rotation order can be selected like this rotateColor.XYZ,
% or by setting defaultRotationOrder

string defaultRotationOrder;
defaultRotationOrder := "ZYX";

vardef rotateColor@#(expr somecolor, someangle) =
    save rotationOrder, argumentString, rv;
    string rotationOrder[], argumentString;
    color rv;
    argumentString := str @#;
    if argumentString = "":
        argumentString := defaultRotationOrder;
    fi;
    for i := 0 step 1 until length(argumentString) - 1:
        rotationOrder[i] = substring (i, i + 1) of argumentString;
    endfor;
    rv := somecolor;
    rv := byRotateAroundAxis(
            rotationAxisB.scantokens(rotationOrder0),
            rotationAxisE.scantokens(rotationOrder0),
            scantokens(rotationAxisPart.scantokens(rotationOrder0))(someangle), rv);
    rv := byRotateAroundAxis(
            rotationAxisB.scantokens(rotationOrder1),
            rotationAxisE.scantokens(rotationOrder1),
            scantokens(rotationAxisPart.scantokens(rotationOrder1))(someangle), rv);
    rv := byRotateAroundAxis(
            rotationAxisB.scantokens(rotationOrder2),
            rotationAxisE.scantokens(rotationOrder2),
            scantokens(rotationAxisPart.scantokens(rotationOrder2))(someangle), rv);
    rv
enddef;

primarydef colorone crossproduct colortwo =
begingroup
    save xp, yp, zp;
    numeric xp[], yp[], zp[];
    xp1 := (redpart colorone)/cm;
    yp1 := (greenpart colorone)/cm;
    zp1 := (bluepart colorone)/cm;
    xp2 := (redpart colortwo)/cm;
    yp2 := (greenpart colortwo)/cm;
    zp2 := (bluepart colortwo)/cm;
    xp3 := ((yp1*zp2) - (zp1*yp2))*cm;
    yp3 := ((zp1*xp2) - (xp1*zp2))*cm;
    zp3 := ((xp1*yp2) - (yp1*xp2))*cm;
    (xp3, yp3, zp3)
endgroup
enddef;

primarydef colorone dotprodXYZ colortwo =
begingroup
    save xp, yp, zp;
    numeric xp[], yp[], zp[];
    xp1 := (redpart colorone);
    yp1 := (greenpart colorone);
    zp1 := (bluepart colorone);
    xp2 := (redpart colortwo);
    yp2 := (greenpart colortwo);
    zp2 := (bluepart colortwo);
    xp1*xp2 + yp1*yp2 + zp1*zp2
endgroup
enddef;

vardef isInPlane (expr colPoint, colPlaneA, colPlaneB, colPlaneC) =
    save vecsToCompare, rv;
    color vecsToCompare[];
    boolean rv;
    rv := false;
    if (colPoint = colPlaneA)
        or (colPoint = colPlaneB)
        or (colPoint = colPlaneC):
        rv := true;
    else:
        vecsToCompare1 := colPlaneA-colPlaneB;
        vecsToCompare2 := colPlaneC-colPlaneB;
        vecsToCompare3 := colPoint-colPlaneB;
    fi;
    if not rv:
        if ((absXYZ(unitvectorXYZ(vecsToCompare1) - unitvectorXYZ(vecsToCompare3)) < 1/100)
            or (absXYZ(unitvectorXYZ(vecsToCompare1) + unitvectorXYZ(vecsToCompare3)) < 1/100)
            or (absXYZ(unitvectorXYZ(vecsToCompare2) - unitvectorXYZ(vecsToCompare3)) < 1/100)
            or (absXYZ(unitvectorXYZ(vecsToCompare2) + unitvectorXYZ(vecsToCompare3)) < 1/100)):
            rv := true;
        else:
            vecsToCompare4 := unitvectorXYZ(vecsToCompare1 crossproduct vecsToCompare2);
            vecsToCompare5 := unitvectorXYZ(vecsToCompare3 crossproduct vecsToCompare2);
            if ((absXYZ(vecsToCompare4 - vecsToCompare5) < 1/100)
                or (absXYZ(vecsToCompare4 + vecsToCompare5) < 1/100)):
                rv := true;
            else:
                rv := false;
            fi;
        fi;
    fi;
    rv
enddef;

vardef unitvectorXYZ (expr somecolor) =
    save vecLength;
    numeric vecLength;
    vecLength := absXYZ(somecolor);
    if (vecLength > 0):
        somecolor/vecLength
    else:
        errmessage("Can't construct a unit vector from a zero-length vector");
    fi
enddef;

vardef absXYZ (expr somecolor) =
    (sqrt(
        ((redpart somecolor)/1cm)**2
        + ((greenpart somecolor)/1cm)**2
        + ((bluepart somecolor)/1cm)**2)*1cm)
enddef;

vardef lineAndPlaneIntersection (expr lineA, lineB, planeA, planeB, planeC) =
    save planeNormal, planeOrigin, lineD;
    color planeNormal, planeOrigin;
    numeric lineD;
    planeNormal := unitvectorXYZ((planeA-planeB) crossproduct (planeC-planeB));
    planeOrigin := planeB;
    lineD := ((planeNormal/cm) dotprodXYZ ((planeOrigin - lineA)/cm))
            /((planeNormal/cm) dotprodXYZ ((lineB - lineA)/cm));
    lineA + ((lineB-lineA)*lineD)
enddef;

vardef spaceRotated (suffix somepath)(expr someangle) =
    save rv, tv, spacepoint, op, rp, tp;
    path rv, tv;
    color spacepoint[];
    pair op[], rp[], tp[];
    if (typeOf(thirdDimension.somepath) <> "path"):
        path thirdDimension.somepath;
        thirdDimension.somepath := somepath scaled 0;
    fi;
    for i := 0 step 1 until length(somepath):
        op0 := point i of somepath;
        spacepoint0 :=
            (xpart(op0), ypart(op0),
                xpart(point i of thirdDimension.somepath)
                ) colorrotated someangle;
        rp0 := (redpart(spacepoint0), greenpart(spacepoint0));
        tp0 := (bluepart(spacepoint0), 0);
        if (i = 0):
            rv := rp0;
            tv := tp0;
        else:
            op1 := postcontrol (i-1) of somepath;
            spacepoint1 :=
                (xpart(op1), ypart(op1),
                    xpart(postcontrol (i-1) of thirdDimension.somepath)
                    ) colorrotated someangle;
            rp1 := (redpart(spacepoint1), greenpart(spacepoint1));
            tp1 := (bluepart(spacepoint1), 0);
            op2 := precontrol i of somepath;
            spacepoint2 :=
                (xpart(op2), ypart(op2),
                    xpart(precontrol i of thirdDimension.somepath)
                    ) colorrotated someangle;
            rp2 := (redpart(spacepoint2), greenpart(spacepoint2));
            tp2 := (bluepart(spacepoint2), 0);
            rv := rv .. controls rp1 and rp2 ..
                if ((i < length(somepath)) or (not cycle somepath)):
                    rp0
                else:
                    cycle
                fi;
            tv := tv .. controls tp1 and tp2 ..
                if ((i < length(somepath)) or (not cycle somepath)):
                    tp0
                else:
                    cycle
                fi;
        fi;
    endfor;
    thirdDimension.somepath := tv;
    rv
enddef;

vardef bySetProjection@#(expr xa, ya, za) =
    projectionAngle := (xa, ya, za);
    byRotatePoints@#(xa, ya, za, false)();
    if str @# <> "":
        defaultRotationOrder := str @#;
    fi;
enddef;

vardef byPutPointsInSpace (text pL) =
    byRotatePoints(0, 0, 0, true)(pL);
enddef;

% Gets a either a 2d or a 3d point and returns a 3d point

vardef byGetPointXYZ (suffix givenPoint) =
    if (typeOf(givenPoint) = "color"):
        givenPoint
    elseif (typeOf(pointXYZ.givenPoint) = "color"):
        pointXYZ.givenPoint
    else:
        errmessage("Point " & str givenPoint & " has no representation in space");
    fi
enddef;

vardef byRotateAroundAxis (expr lineEndA, lineEndB, a, pointA) =
    save vecA, vecB, rV, q;
    color vecA, vecB, rV;
    cmykcolor q[];
    vecA := pointA - lineEndA;
    vecB := unitvectorXYZ(lineEndB - lineEndA);
    q1 := (0, redpart(vecA), greenpart(vecA), bluepart(vecA));
    q2 := (cosd(a/2), sind(a/2)*redpart(vecB), sind(a/2)*greenpart(vecB), sind(a/2)*bluepart(vecB));
    q3 := (cyanpart(q2), -magentapart(q2), -yellowpart(q2), -blackpart(q2));
    q4 := (q2 hamiltonProduct q1) hamiltonProduct q3;
    rV := (magentapart(q4), yellowpart(q4), blackpart(q4)) + lineEndA;
    rV
enddef;

vardef byRotatePointsAroundAxis (suffix lineEndA, lineEndB)(expr a)(text pointsList) =
    save lineEndAxyz, lineEndBxyz, pN;
    color lineEndAxyz, lineEndBxyz;
    if (typeOf(lineEndA) = "color"):
        lineEndAxyz := lineEndA;
    else:
        byPutPointsInSpace(lineEndA);
        lineEndAxyz := pointXYZ.lineEndA;
    fi;
    if (typeOf(lineEndB) = "color"):
        lineEndBxyz := lineEndB;
    else:
        byPutPointsInSpace(lineEndB);
        lineEndBxyz := pointXYZ.lineEndB;
    fi;
    forsuffixes pN := pointsList:
        if (typeOf(pN) = "color"):
            pN := byRotateAroundAxis(lineEndAxyz, lineEndBxyz, a, pN);
        elseif (typeOf(pN) = "pair"):
            byPutPointsInSpace(pN);
            pointXYZ.pN := byRotateAroundAxis(lineEndAxyz, lineEndBxyz, a, pointXYZ.pN);
        fi;
    endfor;
enddef;

primarydef colorone hamiltonProduct colortwo =
begingroup
    save a, b, c, d;
    numeric a[], b[], c[], d[];
    a1 := cyanpart(colorone);
    b1 := magentapart(colorone);
    c1 := yellowpart(colorone);
    d1 := blackpart(colorone);
    a2 := cyanpart(colortwo);
    b2 := magentapart(colortwo);
    c2 := yellowpart(colortwo);
    d2 := blackpart(colortwo);
    (
        (a1*a2) - (b1*b2) - (c1*c2) - (d1*d2),
        (a1*b2) + (b1*a2) + (c1*d2) - (d1*c2),
        (a1*c2) - (b1*d2) + (c1*a2) + (d1*b2),
        (a1*d2) + (b1*c2) - (c1*b2) + (d1*a2)
    )
endgroup
enddef;

vardef isRightAngle (suffix a, b, c) =
    save d, rv;
    numeric d;
    boolean rv;
    if (attributeExists("point", "XYZ", str a)
        and attributeExists("point", "XYZ", str b)
        and attributeExists("point", "XYZ", str c)):
        d := unitvectorXYZ(pointXYZ.a - pointXYZ.b) dotprodXYZ unitvectorXYZ(pointXYZ.c - pointXYZ.b);
    else:
        d := unitvector(a - b) dotprod unitvector(c - b);
    fi;
    if (abs(d) < 1/1000):
        rv := true;
    else:
        rv := false;
    fi;
    rv
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
    cutAngle1 := unitvector(b-a) rotated -90;
    if (abs(c-a) > 0):
        if (abs(unitvector(c-a)-unitvector(a-b)) > 1/100):
            if (ct = 0):
                cutAngle1 := unitvector(1/2[unitvector(b-a), unitvector(c-a)]);
            elseif (ct = 1):
                cutAngle1 := unitvector(1[unitvector(b-a), unitvector(c-a)]);
            fi;
        fi;
    fi;
    cutAngle2 := unitvector(a-b) rotated 90;
    if (abs(d-b) > 0):
        if (abs(unitvector(d-b)-unitvector(b-a)) > 1/100):
            if (dt = 0):
                cutAngle2 := unitvector(1/2[unitvector(a-b), unitvector(d-b)]);
            elseif (dt = 1):
                cutAngle2 := unitvector(1[unitvector(a-b), unitvector(d-b)]);
            fi;
        fi;
    fi;
    if (sign(ypart(cutAngle2 rotated -la)) <> sign(ypart(cutAngle1 rotated -la))):
        cutAngle2 := cutAngle2 rotated 180;
    fi;
    lineItself := (a--b) scaled sf;
    linePerp := unitvector((point 0 of lineItself)-(point 1 of lineItself)) rotated 90;
    lineBleeding :=
        ((point 0 of lineItself) shifted (unitvector((point 0 of lineItself) - (point 1 of lineItself)) scaled dpLength[dp])) --
        lineItself -- ((point 1 of lineItself) shifted (unitvector((point 1 of lineItself) - (point 0 of lineItself)) scaled dpLength[dp]));
    lineStyShift := (linePerp scaled (1/2currentLineWidth*s));
    p := image(
        pickup  pencircle scaled currentLineWidth;
        if (dp > 0):
            draw (lineItself shifted lineStyShift) withcolor white;
            draw (lineItself shifted lineStyShift) withcolor col
                dashed byDashPattern(arclength(lineItself), dp);
            draw (subpath(0, 1) of lineBleeding shifted lineStyShift) withcolor col;
            draw (subpath(2, 3) of lineBleeding shifted lineStyShift) withcolor col;
        else:
            draw (lineBleeding shifted lineStyShift) withcolor col;
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
    if mainPictureMode and ghostLines:
        save gP;
        picture gP;
        gP := ghostPicture;
        ghostPicture := image(
            draw gP;
            begingroup;
                save ghostLines;
                boolean ghostLines;
                ghostLines := false;
                draw byLineRender (a, b, white, dp, 2, c, d, ct, dt, s, sf);
                % draw byLineRender (a, b, col, dp, 2, c, d, ct, dt, s, sf);
            endgroup;
            );
    fi;
    p rotated globalRotation
enddef;

vardef byReturnLineLength (suffix a, b) =
    if byIsPointInSpace(a, b):
        absXYZ(pointXYZ.a - pointXYZ.b)
    else:
        abs(a-b)
    fi
enddef;

vardef byLineDefine@#(suffix a, b)(expr col, dp, th) =
if str @# = "":
    byLineDefine.scantokens(str a & str b)(a, b)(col, dp, th);
else:
    save lA;
    if mainPictureMode:
        appendList(allLinesList, str @#, 1, true);
    fi;
    if byIsPointInSpace(a, b):
        if (typeOf(a) = "pair") and (typeOf(b) = "pair"):
            if (a <> b):
                lA := angle(b-a);
            else:
                lA := 0;
            fi;
        else:
            lA := 0;
        fi;
    else:
        if (a <> b):
            lA := angle(b-a);
        else:
            lA := 0;
        fi;
    fi;
    setAttribute("line", "Angle", str @#, lA);
    setAttribute("line", "Color", str @#, col);
    setAttribute("line", "Dashed", str @#, dp);
    setAttribute("line", "Thin", str @#, th);
    setAttribute("line", "EndA", str @#, a);
    setAttribute("line", "EndB", str @#, b);
    setAttribute("line", "Shift", str @#, 0);
    setAttribute("line", "DirA", str @#, a);
    setAttribute("line", "DirB", str @#, b);
    setAttribute("line", "EndAType", str @#, 0);
    setAttribute("line", "EndBType", str @#, 0);
    setAttribute("line", "EndAName", str @#, str a);
    setAttribute("line", "EndBName", str @#, str b);
    setAttribute("line", "DirAName", str @#, str a);
    setAttribute("line", "DirBName", str @#, str b);
    setAttribute("line", "UseLineLabel", str @#, false);
    setAttribute("line", "Label", str @#, str @#);
    setAttribute("line", "Synonym", str @#, str @#);
fi;
enddef;

vardef byLineStylize (suffix c, d)(expr ct, dt, s) (suffix lineName) =
    setAttribute("line", "Shift", str lineName, s);
    setAttribute("line", "DirA", str lineName, c);
    setAttribute("line", "DirB", str lineName, d);
    setAttribute("line", "DirAName", str lineName, str c);
    setAttribute("line", "DirBName", str lineName, str d);
    setAttribute("line", "EndAType", str lineName, ct);
    setAttribute("line", "EndBType", str lineName, dt);
enddef;

vardef byLine@#(suffix a, b)(expr col, dp, th) =
if str @# = "":
    byLine.scantokens(str a & str b)(a, b)(col, dp, th)
else:
    byLineDefine@#(a, b, col, dp, th);
    byNamedLineFull(a, b, 0, 0, 0)(@#)
fi
enddef;

vardef byLineFull@#(suffix a, b)(expr col, dp, th)(suffix c, d)(expr ct, dt, s) =
if str @# = "":
    byLineFull.scantokens(str a & str b)(a, b)(col, dp, th)(c, d)(ct, dt, s)
else:
    byLineDefine@#(a, b) (col, dp, th);
    byLineStylize (c, d, ct, dt, s)(@#);
    byNamedLine(@#)
fi
enddef;

% This one's behaviour is slightly off, since it affects line label type

vardef byLineWithName (suffix a, b)(expr col, dp, th)(suffix lineLabel) =
    byLineDefine.lineLabel(a, b, col, dp, th);
    setAttribute("line", "UseLineLabel", str lineLabel, true);
    byNamedLineFull(a, b, 0, 0, 0)(lineLabel)
enddef;

vardef byNamedLineFull (expr c, d, ct, dt, s) (suffix lineName) =
    if (mainPictureMode):
        appendList(pointLinesList.scantokens(getAttribute("line", "EndAName", str lineName)), str lineName, 1, true);
        appendList(pointLinesList.scantokens(getAttribute("line", "EndBName", str lineName)), str lineName, 1, true);
    fi;
    byLineRender(
        scantokens(getAttribute("line", "EndAName", str lineName)),
        scantokens(getAttribute("line", "EndBName", str lineName)),
        getAttribute("line", "Color", str lineName),
        getAttribute("line", "Dashed", str lineName),
        getAttribute("line", "Thin", str lineName),
        c, d, ct, dt, s, scaleFactor)
enddef;

vardef byNamedLine (text linesList) =
    image(
        forsuffixes lN=linesList:
            draw byNamedLineFull(
                scantokens(getAttribute("line", "DirAName", str lN)),
                scantokens(getAttribute("line", "DirBName", str lN)),
                getAttribute("line", "EndAType", str lN),
                getAttribute("line", "EndBType", str lN),
                getAttribute("line", "Shift", str lN))(lN);
        endfor;
    )
enddef;

vardef byNamedLineSeq (expr s)(text linesListRaw) =
    save lAname, lBname, lShift, lName, i, j, k, l, m, n, c, d, prp, pointNames, linesList;
    string lAname[], lBname[], lName[], c, d, pointNames, linesList;
    numeric i, j, k, l, m, n, prp, lShift[];
    linesList := byExpandLines(linesListRaw);
    pointNames := "";
    image(
        i := -1;
        forsuffixes lN=scantokens(linesList):
            i := i + 1;
            lAname[i] := getAttribute("line", "EndAName", str lN);
            lBname[i] := getAttribute("line", "EndBName", str lN);
            lShift[i] := getAttribute("line", "Shift", str lN);
            lName[i] := str lN;
        endfor;
        if (i = 1):
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
                if (lAname[k] = "noLine"):
                    k := cycleval (k - 1, i + 1);
                    m := 1;
                fi;
                if (lAname[l] = "noLine"):
                    l := cycleval (l + 1, i + 1);
                    n := 1;
                fi;
                c := lAname[j];
                d := lBname[j];
                prp := 0;
                if  (((lAname[j] = lAname[k]) or (lAname[j] = lBname[k]))
                        and (not ((m <> 0) and (lName[k] = lName[l])))) or
                    (((lBname[j] = lAname[l]) or (lBname[j] = lBname[l]))
                        and (not ((n <> 0) and (lName[k] = lName[l])))):
                    if (lAname[j] = lAname[k]):
                        if (m = 0): c := lBname[k]; fi;
                    elseif (lAname[j] = lBname[k]):
                        if (m = 0): c := lAname[k]; fi;
                    else:
                        m := 2;
                    fi;
                    if (lBname[j] = lAname[l]):
                        if (n = 0): d := lBname[l]; fi;
                    elseif (lBname[j] = lBname[l]):
                        if (n = 0): d := lAname[l]; fi;
                    else:
                        n := 2;
                    fi;
                    prp := 1;
                else:
                    if (lAname[j] = lAname[l]):
                        if (n = 0): c := lBname[l]; fi;
                    elseif (lAname[j] = lBname[l]):
                        if (n = 0): c := lAname[l]; fi;
                    else:
                        n := 2;
                    fi;
                    if (lBname[j] = lAname[k]):
                        if (m = 0): d := lBname[k]; fi;
                    elseif (lBname[j] = lBname[k]):
                        if (m = 0): d := lAname[k]; fi;
                    else:
                        m := 2;
                    fi;
                    prp := -1;
                fi;
                if (lName[j] <> "noLine"):
                    if (prp = 1):
                        pointNames := pointNames & lAname[j] & ", ";
                        if (n = 2):
                            pointNames := pointNames & lBname[j] & ", noPoint, ";
                        fi;
                    elseif (prp = -1):
                        pointNames := pointNames & lBname[j] & ", ";
                        if (n = 2):
                            pointNames := pointNames & lAname[j] & ", noPoint, ";
                        fi;
                    fi;
                    lShift[j] := s*prp;
                    draw byNamedLineFull(scantokens(c), scantokens(d), 0, 0, s*sign(prp))(scantokens(lName[j]));
                else:
                    prp := -2;
                fi;
            endfor;
            if (prp = 1) and (n <> 2):
                pointNames := pointNames & lBname[i];
            elseif (prp = -1) and (n <> 2):
                pointNames := pointNames & lAname[i];
            else:
                pointNames := substring (0, length(pointNames)-2) of pointNames;
            fi;
            if (textLabels and autoLabelingMode):
                draw byLabelsOnPolygon(scantokens pointNames)(1, s);
            fi;
        else:
            forsuffixes lN=scantokens(linesList):
                setAttribute("line", "Shift", str lN, s);
                draw byNamedLineFull(
                    scantokens(getAttribute("line", "EndAName", str lN)),
                    scantokens(getAttribute("line", "EndBName", str lN)),
                    0, 0, s)(lN);
                if (textLabels and autoLabelingMode):
                    draw byLabelsOnPolygon(scantokens (getAttribute("line", "EndAName", str lN) & ", " & getAttribute("line", "EndBName", str lN)))(1, s);
                fi;
            endfor;
        fi;
    )
enddef;

vardef byMarkLine (expr pos, col)(suffix lineName) =
    setAttribute("mark", "Position", str lineName, pos);
    setAttribute("mark", "Color", str lineName, col);
    byNamedMarkLine(lineName)
enddef;

vardef byNamedMarkLine(suffix lineName) =
    save p, q;
    pair q[];
    picture p;
    p := image(
        q0 := getAttribute("mark", "Position", str lineName)[
            scantokens(getAttribute("line", "EndAName", str lineName)),
            scantokens(getAttribute("line", "EndBName", str lineName))
            ];
        q1 := q0 shifted (dir(getAttribute("line", "Angle", str lineName) + 90) scaled 1/2markLength);
        q2 := q0 shifted (dir(getAttribute("line", "Angle", str lineName) - 90) scaled 1/2markLength);
        q3 := (dir(getAttribute("line", "Angle", str lineName) - 90) scaled (1/2lineWidth*getAttribute("line", "Shift", str lineName)));
        draw (q1--q2) shifted q3 withpen pencircle scaled lineWidthThin withcolor getAttribute("mark", "Color", str lineName);
    );
    p rotated globalRotation
enddef;

vardef byFindLinePointedThere (expr a, b) =
    save endA, endB, endAC, endBC, endAA, endBA, chosenLine, lL;
    string chosenLine;
    pair endA, endB, endAC, endBC, endAA, endBA;
    numeric lL;
    endA := scantokens(a);
    endB := b;
    if known pointLinesList.scantokens(a):
        forsuffixes lL=scantokens(pointLinesList.scantokens(a)):
            endAC := scantokens(getAttribute("line", "EndAName", str lL));
            endBC := scantokens(getAttribute("line", "EndBName", str lL));
            if (endAC = endA):
                endAA := endAC;
                endBA := endBC;
            elseif (endBC = endA):
                endAA := endBC;
                endBA := endAC;
            fi;
            if ((abs(angle(endBA - endAA) - angle(endB - endA)) mod 360) < 1):
                chosenLine := str lL;
            fi;
        endfor;
    fi;
    if unknown chosenLine:
        chosenLine := "";
    fi;
    chosenLine
enddef;

vardef byConstructCompoundLine (expr lineName) =
    save lineStart, lEnd, newLine, lEndA, lEndB, compoundLineString, i, j, cPointA, cPointB;
    string lineStart, lEnd, newLine, lEndA, lEndB, compoundLineString, cPointA, cPointB;
    numeric i, j;
    j := 0;
    if (length(lineName) = 2):
        lineStart := substring (0, 1) of lineName;
        lEnd := substring (1, 2) of lineName;
    else:
        for i := 1 step 1 until length(lineName):
            cPointA := substring (0, i) of lineName;
            cPointB := substring (i, length(lineName)) of lineName;
            if known scantokens(cPointA): % for some reason 'and' doesn't work here
                if known scantokens(cPointB):
                    j := j + 1;
                    lineStart := cPointA;
                    lEnd := cPointB;
                fi;
            fi;
        endfor;
    fi;
    if unknown lineStart:
        errmessage("Can't find points for line: " & lineName);
    fi;
    if j > 1:
        errmessage("Ambiguous line name: " & lineName);
    fi;
    i := 0;
    forever:
        i := i + 1;
        newLine := byFindLinePointedThere(lineStart, scantokens(lEnd));
        if (newLine = ""):
            errmessage("There's no line from " & lineStart & " to " & lEnd);
        fi;
        appendList (compoundLineString, newLine, 1, false);
        lEndA := getAttribute("line", "EndAName", newLine);
        lEndB := getAttribute("line", "EndBName", newLine);
        if (lEndA = lineStart):
            lineStart := lEndB;
        elseif (lEndB = lineStart):
            lineStart := lEndA;
        fi;
        exitif (i > 10);
        exitif (lEndA = lEnd);
        exitif (lEndB = lEnd);
    endfor;
    compoundLineString
enddef;

vardef byExpandLines (text linesList) =
    save lineString, compoundLineString;
    string lineString, compoundLineString;
    forsuffixes lN=linesList:
        if attributeExists("line", "Synonym", str lN):
            appendList(lineString, str lN, 1, false);
        else:
            appendList(lineString, byConstructCompoundLine(str lN), 1, false);
        fi;
    endfor;
    lineString
enddef;

vardef byNamedCompoundLine (expr cu, pw)(text linesList) =
    byNamedCompoundLineRender(cu, pw, 0)(scantokens(byExpandLines(linesList)))
enddef;

vardef byNamedCompoundRay (expr cu, pw)(text linesList) =
    byNamedCompoundLineRender(cu, pw, 1)(scantokens(byExpandLines(linesList)))
enddef;

vardef byNamedCompoundIndLine (expr cu, pw)(text linesList) =
    byNamedCompoundLineRender(cu, pw, 2)(scantokens(byExpandLines(linesList)))
enddef;

vardef byNamedCompoundLineRender (expr cu, pw, sty)(text linesList) =
    save correctedLength, currentPosition, a, b, sc, totalLength, pwL, lineNames, endNames, i, j, angleCheck, lineNotStraight, lineNotContinuous, globalRotation, extensionNames, textLabelImage;
    numeric correctedLength, currentPosition[], sc, totalLength, pwL, i, j, angleCheck[];
    globalRotation := 0;
    string lineNames[], endNames[], extensionNames[];
    pair a, b;
    picture textLabelImage[];
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
        totalLength := totalLength
            + byReturnLineLength(
                scantokens(getAttribute("line", "EndAName", str lN)),
                scantokens(getAttribute("line", "EndBName", str lN)));
    endfor;
    if (lineNotStraight):
        message("The line is not straight");
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
            correctedLength := (byReturnLineLength(
                scantokens(getAttribute("line", "EndAName", str lN)),
                scantokens(getAttribute("line", "EndBName", str lN))
                    )**pwL)*sc;
            currentPosition1 := currentPosition0 + correctedLength;
            a := (currentPosition0, 0);
            b := (currentPosition1, 0);
            draw byLineRender(
                a, b,
                getAttribute("line", "Color", str lN),
                getAttribute("line", "Dashed", str lN),
                getAttribute("line", "Thin", str lN),
                a, b, 0, 0, 0, scaleFactor);
            currentPosition0 := currentPosition1;
            if (i > 2):
                if (j = 0):
                    extensionNames3 := str lN;
                    if (getAttribute("line", "EndAName", str lN) = lineNames[2])
                        or (getAttribute("line", "EndAName", str lN) = lineNames[3]):
                        endNames[0] := getAttribute("line", "EndBName", str lN);
                    elseif (getAttribute("line", "EndBName", str lN) = lineNames[2])
                        or (getAttribute("line", "EndBName", str lN) = lineNames[3]):
                        endNames[0] := getAttribute("line", "EndAName", str lN);
                    fi;
                fi;
                if (j = (i-2)/2):
                    extensionNames2 := str lN;
                    if (getAttribute("line", "EndAName", str lN) = lineNames[i-3])
                        or (getAttribute("line", "EndAName", str lN) = lineNames[i-4]):
                        endNames[1] := getAttribute("line", "EndBName", str lN);
                    elseif (getAttribute("line", "EndBName", str lN) = lineNames[i-3])
                        or (getAttribute("line", "EndBName", str lN) = lineNames[i-4]):
                        endNames[1] := getAttribute("line", "EndAName", str lN);
                    fi;
                fi;
            else:
                endNames[0] := getAttribute("line", "EndAName", str lN);
                endNames[1] := getAttribute("line", "EndBName", str lN);
                if (getAttribute("line", "UseLineLabel", str lN)):
                    endNames[2] := str lN;
                fi;
            fi;
            j := j + 1;
        endfor;
        extensionNames0 := byFindLinePointedThere(endNames1, 2[scantokens(endNames0), scantokens(endNames1)]);
        extensionNames1 := byFindLinePointedThere(endNames0, 2[scantokens(endNames1), scantokens(endNames0)]);
        if extensionNames0 = "":
            extensionNames0 := "dummyLine";
        else:
            extensionNames2 := extensionNames0;
        fi;
        if extensionNames1 = "":
            extensionNames1 := "dummyLine";
        else:
            extensionNames3 := extensionNames1;
        fi;
        if (sty > 0):
            draw byLineRender(b, b shifted (rayExtension/scaleFactor, 0),
                getAttribute("line", "Color", extensionNames0),
                getAttribute("line", "Dashed", extensionNames0),
                getAttribute("line", "Thin", extensionNames2),
                b, b shifted (rayExtension/scaleFactor, 0), 0, 0, 0, scaleFactor);
        fi;
        if (sty > 1):
            draw byLineRender((0, 0), (0, 0) shifted (-rayExtension/scaleFactor, 0),
                getAttribute("line", "Color", extensionNames1),
                getAttribute("line", "Dashed", extensionNames1),
                getAttribute("line", "Thin", extensionNames3),
                (0, 0), (0, 0) shifted (-rayExtension/scaleFactor, 0), 0, 0, 0, scaleFactor);
        fi;
        if (textLabels and autoLabelingMode):
            if unknown endNames[2]:
                textLabelImage1 := byTextLabel(pointLabel)(endNames[0], (0, 0), 90, textLabelShift);
                textLabelImage2 := byTextLabel(pointLabel)(endNames[1], b, 90, textLabelShift);
                draw textLabelImage1;
                draw textLabelImage2;
                % these are only needed to make the image symmetrical in order to have
                % the line with and without labels at the same level in text.
                draw (textLabelImage1 yscaled -1) withcolor white;
                draw (textLabelImage2 yscaled -1) withcolor white;
            else:
                textLabelImage1 := byTextLabel(lineLabel)(endNames[2], 1/2[(0, 0), b], 90, textLabelShift);
                draw textLabelImage1;
                draw (textLabelImage1 yscaled -1) withcolor white;
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
                setAttribute("line", "DirAName", candidateName2, getAttribute("line", "DirBName", originalName));
                setAttribute("line", "DirBName", candidateName2, getAttribute("line", "DirAName", originalName));
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

vardef byPointLabelRemove (text pointsList) =
    forsuffixes i=pointsList:
    	byPointLabelDefine(i, "");
    endfor;
enddef;

vardef byPointMarkDefine (suffix pointName)(expr col, sty) =
    setAttribute("point", "Color", str pointName, col);
    setAttribute("point", "Style", str pointName, sty);
enddef;

vardef byPointXYZDefine@#(expr ox, oy, oz) =
if str @# = "":
    errmessage("byPointXYZDefine needs a name (byPointXYZDefine.somename...)");
else:
    if mainPictureMode:
        appendList(allPointsList, str @#, 1, true);
    fi;
        setAttribute("point", "XYZ", str @#, (ox, oy, oz));
        pair @#;
        color pointXYZ.@#;
        @# := (ox, oy);
        pointXYZ.@# := (ox, oy, oz);
fi;
enddef;

vardef byPointXYZEmpty (text pointNames) =
    forsuffixes pN = pointNames:
        if mainPictureMode:
            appendList(allPointsList, str pN, 1, true);
        fi;
        color pointXYZ.pN;
    endfor;
enddef;

vardef byIsPointInSpace (text pointNames) =
    save pN;
    (true forsuffixes pN = pointNames:
        and (typeOf(pointXYZ.pN) = "color")
    endfor)
enddef;

% in order to automatically project points they need to be added
% to allPointsList list.
vardef byPair (text pointsList) =
    save i;
    pair pointsList;
    forsuffixes i := pointsList:
        appendList(allPointsList, str i, 1, true);
        numeric pointXYZ.i;
    endfor;
enddef;

% @# here stands for rotation order, e. g. byRotatePoints.XYZ

vardef byRotatePoints@#(expr xa, ya, za, toRotate)(text pointsList) =
    save oxyz, pointsToProcess;
    color oxyz;
    string pointsToProcess;
    forsuffixes i=pointsList:
        appendList(pointsToProcess, str i, 1, true);
    endfor;
    if (length(pointsToProcess) = 0):
        pointsToProcess := allPointsList;
    fi;
    forsuffixes i=scantokens(pointsToProcess):
        if (known i) or (known pointXYZ.i):
            if attributeExists("point", "XYZ", str i):
                oxyz := getAttribute("point", "XYZ", str i);
            elseif typeOf(i) = "pair":
                byPointXYZDefine.i(xpart i, ypart i, 0);
                oxyz := getAttribute("point", "XYZ", str i);
            else:
                errmessage("Point " & str i & " doesn't exist");
            fi;
            oxyz := rotateColor@#(oxyz, (xa, ya, za));
            pair i;
            i := (redpart(oxyz), greenpart(oxyz));
            if toRotate:
                setAttribute("point", "XYZ", str i, oxyz);
            fi;
        fi;
    endfor;
enddef;

vardef byPointMarkRender (expr p, col, sty) =
    image(
        if (sty = 0):
            fill ((fullcircle scaled pointMarkSize) shifted (p scaled scaleFactor)) withcolor col;
        fi;
    )
enddef;

vardef byNamedPointMark (text pointsList) =
    image(
        forsuffixes pN=pointsList:
            appendList(pL, str pN, 1, false);
            draw byPointMarkRender(pN, getAttribute("point", "Color", str pN), getAttribute("point", "Style", str pN)) rotated globalRotation;
            if (autoLabelingMode and textLabels):
                draw byTextLabel(pointLabel)(str pN, pN, 90, textLabelShift);
            fi;
        endfor;
    )
enddef;

vardef byPointMark (suffix pointName)(expr col, sty) =
    image(
        byPointMarkDefine(pointName)(col, sty);
        draw byNamedPointMark(pointName);
    )
enddef;

vardef byNamedPointLines (suffix pointName)(expr omitLines) =
save linesList, lineNames, pointNames, distantEnd, distantEnds, n, no, distL, maxDist, maxDistEndA, maxDistEndB, a, angleL, minAngle, maxAngle, minAngleEndB, maxAngleEndA, maxAngleEndB, safeLine;
string linesList, lineNames[], pointNames[];
linesList := pointLinesList.pointName;
pair distantEnd, distantEnds[];
numeric n, no, distL, maxDist, maxDistEndA, maxDistEndB, a[], angleL, minAngle, maxAngle, minAngleEndB, maxAngleEndA, maxAngleEndB, safeLine;
picture labelImage, linesImage;
boolean omitLine[];
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
                if ((str i) = (str j)):
                    omitLine[n] := true;
                    no := no + 1;
                fi;
            endfor;
        fi;
        if (not omitLine[n]):
            safeLine := n;
        fi;
        if (getAttribute("line", "EndAName", str i) = str pointName):
            distantEnds[n] :=
                scantokens(getAttribute("line", "EndAName", str i))
                + (unitvector(scantokens(getAttribute("line", "EndBName", str i))
                    - scantokens(getAttribute("line", "EndAName", str i))) scaled (pointLinesScale/scaleFactor)
                    );
            pointNames[n] := getAttribute("line", "EndBName", str i);
        else:
            distantEnds[n] :=
                scantokens(getAttribute("line", "EndBName", str i))
                + (unitvector(scantokens(getAttribute("line", "EndAName", str i))
                    - scantokens(getAttribute("line", "EndBName", str i))) scaled (pointLinesScale/scaleFactor)
                    );
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
        linesImage := image(
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
                );
        labelImage := image(
            if (textLabels):
                draw byLabelsOnPolygon(scantokens(pointNames[maxAngleEndA]),pointName,scantokens(pointNames[maxAngleEndB]))(2, 0);
            fi;
            );
    else:
        linesImage := image(
            draw byLineRender(pointName, distantEnds[safeLine],
                getAttribute("line", "Color", lineNames[safeLine]),
                getAttribute("line", "Dashed", lineNames[safeLine]),
                getAttribute("line", "Thin", lineNames[safeLine]),
                pointName, distantEnds[safeLine], 0, 0, 0, scaleFactor);
            );
        labelImage := image(
            if (textLabels):
                draw byLabelLineEnd (pointName, distantEnds[safeLine])(0);
            fi;
            );
    fi;
    image(
        draw labelImage;
        % this thing is intended to make the overall picture symmetrical
        % when all the lines are horizontal.
        draw labelImage rotatedabout(pointName scaled scaleFactor, 180) withcolor white;
        draw linesImage;
        )
enddef;

%
% Arcs and circles
%

vardef byCirclePathGenerate (expr sr, pv) =
    save circPath, xp, xang, yang;
    path circPath;
    color pvt;
    numeric xang, yang;
    pair xp;
    circPath := fullcircle;
    xp := (bluepart(pv), greenpart(pv));
    xang := angle(xp);
    pvt := (redpart(pv), ypart(xp rotated -xang), xpart(xp rotated -xang));
    yang := angle((bluepart(pvt), redpart(pvt)));
    circPath := spaceRotated(circPath)((-xang, yang, 0)); % plane vector to angles conversion should eventually go somewhere
    circPath := spaceRotated(circPath)(sr);
    circPath := spaceRotated(circPath)(projectionAngle);
    circPath
enddef;

vardef byArcRender (expr o, b, e, r, sr, pv, col, dp, th, s, et) =
    save p, q, m, t, currentLineWidth, srCircle;
    path p[], srCircle;
    picture q;
    pair t[];
    numeric m[];
    numeric currentLineWidth;
    save thirdDimension;
    image(
        srCircle := byCirclePathGenerate(sr, pv);
        currentLineWidth := lineThickness(th);
        p0 := ((subpath (b, e) of srCircle) scaled (r*scaleFactor + lineWidth*s + lineWidth)) shifted (o*scaleFactor);
        p1 := ((subpath (b, e) of srCircle) scaled (r*scaleFactor)) shifted (o*scaleFactor);
        p2 := (srCircle scaled (r*scaleFactor + lineWidth*s + lineWidth)) shifted (o*scaleFactor);
        p3 := ((subpath (b, e) of srCircle) scaled (r*scaleFactor + lineWidth*s)) shifted (o*scaleFactor);
        p4 := ((subpath (b + sign(b-e)*1/16, b) of srCircle) scaled (r*scaleFactor + lineWidth*s)) shifted (o*scaleFactor);
        p5 := ((subpath (e, e + sign(e-b)*1/16) of srCircle) scaled (r*scaleFactor + lineWidth*s)) shifted (o*scaleFactor);
        q := image(
            draw p3 withpen pencircle scaled currentLineWidth withcolor col if (dp > 0): dashed byDashPattern(arclength(p3), dp) fi;
            draw p4 withpen pencircle scaled currentLineWidth withcolor col;
            draw p5 withpen pencircle scaled currentLineWidth withcolor col;
        );
        if mainPictureMode and ghostLines:
            save gP;
            picture gP;
            gP := ghostPicture;
            ghostPicture := image(
                draw gP;
                draw p3 withcolor white withpen pencircle scaled lineWidthHair;
                );
        fi;
        if (et = 0):
            p6 := p0--(o*scaleFactor)--cycle;
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
            p6 := (subpath(m0, m1) of p2) -- cycle;
        fi;
        clip q to p6;
        draw q;
    ) rotated globalRotation
enddef;

vardef byArcDefineBE@#(suffix o)(expr b, e, r, col, dp, th, s, et) =
if str @# = "":
    byArcDefineBE.scantokens(str o)(b, e, r, col, dp, th, s, et);
else:
    setAttribute("arc", "Color", str @#, col);
    setAttribute("arc", "Dashed", str @#, dp);
    setAttribute("arc", "Thin", str @#, th);
    setAttribute("arc", "Shift", str @#, s);
    setAttribute("arc", "Diameter", str @#, 2r);
    setAttribute("arc", "Center", str @#, o);
    setAttribute("arc", "CenterName", str @#, str o);
    setAttribute("arc", "BName", str @#, "");
    setAttribute("arc", "EName", str @#, "");
    setAttribute("arc", "Begin", str @#, b);
    setAttribute("arc", "End", str @#, e);
    setAttribute("arc", "EndType", str @#, et);
    setAttribute("arc", "Angle", str @#, angle((point b of fullcircle) - (point e of fullcircle)));
    setAttribute("arc", "SpaceRotation", str @#, (0,0,0));
    setAttribute("arc", "PlaneVector", str @#, (0,0,1));
    setAttribute("arc", "Synonym", str @#, str @#);
fi;
enddef;

vardef byArcBE@#(suffix o)(expr b, e, r, col, dp, th, s, et) =
if str @# = "":
    byArcBE.scantokens(str o)(o)(b, e, r, col, dp, th, s, et)
else:
    byArcDefineBE.@#(o, b, e, r, col, dp, th, s, et);
    byNamedArcExact(@#)
fi
enddef;

vardef byArcDefine@#(suffix o, pb, pe)(expr r, col, dp, th, s, et) =
if str @# = "":
    byArcDefine.scantokens(str pb & str o & str pe)(o, pb, pe)(r, col, dp, th, s, et);
else:
    save b, e;
    numeric b, e;
    b := xpart(((fullcircle scaled 2r) shifted o) intersectiontimes (o -- 2[o, pb]));
    e := xpart(((fullcircle scaled 2r) shifted o) intersectiontimes (o -- 2[o, pe]));
    if (b > e):
        b := b - 8;
    fi;
    byArcDefineBE.@#(o, b, e, r, col, dp, th, s, et);
    setAttribute("arc", "BName", str @#, str pb);
    setAttribute("arc", "EName", str @#, str pe);
fi;
enddef;

vardef byArc@#(suffix o, pb, pe)(expr r, col, dp, th, s, et) =
if str @# = "":
    byArc.scantokens(str pb & str o & str pe)(o, pb, pe)(r, col, dp, th, s, et)
else:
    byArcDefine.@#(o, pb, pe, r, col, dp, th, s, et);
    byNamedArcExact(@#)
fi
enddef;

vardef byNamedArcExact (text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(
                scantokens(getAttribute("arc", "CenterName", str aN)),
                getAttribute("arc", "Begin", str aN),
                getAttribute("arc", "End", str aN),
                getAttribute("arc", "Diameter", str aN),
                getAttribute("arc", "SpaceRotation", str aN),
                getAttribute("arc", "PlaneVector", str aN),
                getAttribute("arc", "Color", str aN),
                getAttribute("arc", "Dashed", str aN),
                getAttribute("arc", "Thin", str aN),
                getAttribute("arc", "Shift", str aN),
                getAttribute("arc", "EndType", str aN));
        endfor;
        if (autoLabelingMode):
            draw byNamedArcLabel(arcslist);
        fi;
    )
enddef;

vardef byNamedArc (text arcslist) =
    image(
        forsuffixes aN=arcslist:
            draw byArcRender(
                scantokens(getAttribute("arc", "CenterName", str aN)),
                getAttribute("arc", "Begin", str aN),
                getAttribute("arc", "End", str aN),
                getAttribute("arc", "Diameter", str aN),
                getAttribute("arc", "SpaceRotation", str aN),
                getAttribute("arc", "PlaneVector", str aN),
                getAttribute("arc", "Color", str aN),
                getAttribute("arc", "Dashed", str aN),
                getAttribute("arc", "Thin", str aN), 0, 0);
        endfor;
        if (autoLabelingMode):
            draw byNamedArcLabel(arcslist);
        fi;
    )
enddef;

vardef byNamedArcLabel (text arcslist) =
    save pointsListB, pointsListE, pointsListO, pointsListD, labelPos, labelVec, labelAng, i, j, k, allArcsDefined, beginFree, endFree, pointsListCrv;
    string pointsListB[], pointsListE[], pointsListO[];
    numeric i, j, k, pointsListD[], labelAng;
    boolean allArcsDefined, beginFree, endFree;
    color labelVec;
    pair labelPos;
    path pointsListCrv[];
    image(
        if (textLabels):
            i := -1;
            allArcsDefined := true;
            forsuffixes aN=arcslist:
                i := i + 1;
                pointsListB[i] := getAttribute("arc", "BName", str aN);
                pointsListE[i] := getAttribute("arc", "EName", str aN);
                pointsListO[i] := getAttribute("arc", "CenterName", str aN);
                pointsListR[i] := getAttribute("arc", "Diameter", str aN);
                begingroup
                    save thirdDimension;
                    pointsListCrv[i] := subpath
                        (getAttribute("arc", "Begin", str aN), getAttribute("arc", "End", str aN))
                        of byCirclePathGenerate (getAttribute("arc", "SpaceRotation", str aN), getAttribute("arc", "PlaneVector", str aN));
                endgroup;
                if (getAttribute("arc", "BName", str aN) = "")
                    or (getAttribute("arc", "EName", str aN) = ""):
                    allArcsDefined := false;
                fi;
            endfor;
            if allArcsDefined:
                for j := 0 step 1 until i:
                    beginFree := true;
                    endFree := true;
                    for k := 0 step 1 until i:
                        if (j <> k):
                            if (pointsListB[j] = pointsListE[k]):
                                beginFree := false;
                            fi;
                            if (pointsListE[j] = pointsListB[k]):
                                endFree := false;
                            fi;
                        fi;
                    endfor;
                    if beginFree:
                        labelAng := angle(direction 0 of pointsListCrv[j]) + 180;
                        labelPos := ((point 0 of pointsListCrv[j]) * pointsListR[j]) + scantokens(pointsListO[j]);
                        draw byTextLabel(pointLabel)(
                            pointsListB[j],
                            labelPos,
                            labelAng,
                            textLabelShift);
                    fi;
                    if endFree:
                        labelAng := angle(direction 0 of reverse(pointsListCrv[j])) + 180;
                        labelPos := ((point 0 of reverse(pointsListCrv[j])) * pointsListR[j]) + scantokens(pointsListO[j]);
                        draw byTextLabel(pointLabel)(
                            pointsListE[j],
                            labelPos,
                            labelAng,
                            textLabelShift);
                    fi;
                endfor;
            fi;
        fi;
    )
enddef;

vardef byCircleDefineFree@#(expr o, r, col, dp, th, s) =
if str @# = "":
    byCircleDefineFree.aCircle(o, r, col, dp, th, s);
else:
    setAttribute("circle", "Color", str @#, col);
    setAttribute("circle", "Dashed", str @#, dp);
    setAttribute("circle", "Thin", str @#, th);
    setAttribute("circle", "Shift", str @#, s);
    setAttribute("circle", "Diameter", str @#, 2r);
    setAttribute("circle", "Center", str @#, o);
    setAttribute("circle", "CenterName", str @#, "");
    setAttribute("circle", "AName", str @#, "");
    setAttribute("circle", "BName", str @#, "");
    setAttribute("circle", "CName", str @#, "");
    setAttribute("circle", "SpaceRotation", str @#, (0,0,0));
    setAttribute("circle", "PlaneVector", str @#, (0,0,1));
    setAttribute("circle", "Synonym", str @#, str @#);
fi;
enddef;

vardef byCircleDefineR@#(suffix o)(expr r, col, dp, th, s) =
if str @# = "":
    byCircleDefineR.scantokens(str o)(o)(r, col, dp, th, s)
else:
    byCircleDefineFree.@#(o, r, col, dp, th, s);
    setAttribute("circle", "CenterName", str @#, str o);
fi;
enddef;

vardef byCircleR@#(suffix o)(expr r, col, dp, th, s) =
if str @# = "":
    byCircleR.scantokens(str o)(o)(r, col, dp, th, s)
else:
    byCircleDefineR.@#(o, r, col, dp, th, s);
    byNamedCircle(@#)
fi
enddef;

vardef byCircle@#(suffix o, a)(expr col, dp, th, s) =
if str @# = "":
    byCircle.scantokens(str o & str a)(o, a)(col, dp, th, s)
else:
    byCircleDefineR.@#(o, abs(a-o), col, dp, th, s);
    setAttribute("circle", "AName", str @#, str a);
    byNamedCircle(@#)
fi
enddef;

vardef byCircleABC@#(suffix a, b, c)(expr col, dp, th, s) =
if str @# = "":
    byCircleABC.scantokens(str a & str b & str c)(a, b, c)(col, dp, th, s)
else:
    save o, r;
    pair o;
    numeric r;
    o := byFindCircleCenterABC(a, b, c);
    if byIsPointInSpace(a, b, c):
        r := absXYZ(pointXYZ.a - byFindCircleCenterABCinSpace(pointXYZ.a, pointXYZ.b, pointXYZ.c));
    else:
        r := abs(o - a);
    fi;
    byCircleDefineFree.@#(o, r, col, dp, th, s);
    setAttribute("circle", "AName", str @#, str a);
    setAttribute("circle", "BName", str @#, str b);
    setAttribute("circle", "CName", str @#, str c);
    if byIsPointInSpace(a, b, c):
        save pv;
        color pv;
        pv := unitvectorXYZ((pointXYZ.a - pointXYZ.b) crossproduct (pointXYZ.c - pointXYZ.b));
        setAttribute("circle", "PlaneVector", str @#, pv);
    fi;
    byNamedCircle(@#)
fi
enddef;

vardef byFindCircleCenterABC (suffix a, b, c) =
    save rv;
    pair rv;
    if byIsPointInSpace(a, b, c):
        save rvInSpace;
        color rvInSpace;
        rvInSpace := byFindCircleCenterABCinSpace(pointXYZ.a, pointXYZ.b, pointXYZ.c) colorrotated projectionAngle;
        rv := (redpart(rvInSpace), greenpart(rvInSpace));
    else:
        rv = whatever[1/2[a, b], 1/2[a, b] shifted ((a-b) rotated 90)]
            = whatever[1/2[b, c], 1/2[b, c] shifted ((b-c) rotated 90)];
    fi;
    rv
enddef;

vardef byFindCircleCenterABCinSpace (expr a, b, c) =
    save vec;
    color vec[];
    vec0 := ((a - b) crossproduct (c - b));
    vec1 := byRotateAroundAxis (a - b, (0, 0, 0), 90, vec0);
    vec2 := byRotateAroundAxis (c - b, (0, 0, 0), 90, vec0);
    vec3 = whatever[1/2[a, b], 1/2[a, b] + vec1]
        = whatever[1/2[b, c], 1/2[b, c] + vec2]; % Fails from time to time because of some roundoff errors
    vec3
enddef;

vardef byReturnCircleCenter (expr circleName) =
    if (getAttribute("circle", "CenterName", circleName) <> ""):
        scantokens(getAttribute("circle", "CenterName", circleName))
    elseif (getAttribute("circle", "BName", circleName) <> ""):
        byFindCircleCenterABC(
            scantokens(getAttribute("circle", "AName", circleName)),
            scantokens(getAttribute("circle", "BName", circleName)),
            scantokens(getAttribute("circle", "CName", circleName))
            )
    else:
        getAttribute("circle", "Center", str cN)
    fi
enddef;

vardef byNamedCircle (text circlesList) =
    save circlecenter;
    pair circlecenter;
    image(
        forsuffixes cN=circlesList:
            circlecenter := byReturnCircleCenter(str cN);
            draw byArcRender (
                circlecenter, 0, 8,
                getAttribute("circle", "Diameter", str cN),
                getAttribute("circle", "SpaceRotation", str cN),
                getAttribute("circle", "PlaneVector", str cN),
                getAttribute("circle", "Color", str cN),
                getAttribute("circle", "Dashed", str cN),
                getAttribute("circle", "Thin", str cN),
                getAttribute("circle", "Shift", str cN), 0);
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

vardef byArbitraryFigureDefine@#(expr p, col, dp, th) =
if str @# = "":
    byArbitraryFigureDefine.anArbitraryFigure(p, col, dp, th);
else:
    setAttribute("arbitraryFigure", "Path", str @#, p);
    setAttribute("arbitraryFigure", "Color", str @#, col);
    setAttribute("arbitraryFigure", "Dashed", str @#, dp);
    setAttribute("arbitraryFigure", "Thin", str @#, th);
    setAttribute("arbitraryFigure", "Synonym", str @#, str @#);
fi;
enddef;

vardef byArbitraryFigure@#(expr p, col, dp, th) =
if str @# = "":
    byArbitraryFigure.anArbitraryFigure(p, col, dp, th)
else:
    byArbitraryFigureDefine@#(p, col, dp, th);
    byNamedArbitraryFigure(@#)
fi
enddef;

vardef byNamedArbitraryFigure (text arbitraryFiguresList) =
    save p;
    path p;
    image(
        forsuffixes pN=arbitraryFiguresList:
            p := getAttribute("arbitraryFigure", "Path", str pN);
            draw byArbitraryFigureRender
                (p, getAttribute("arbitraryFigure", "Color", str pN),
                    getAttribute("arbitraryFigure", "Dashed", str pN),
                    getAttribute("arbitraryFigure", "Thin", str pN));
        endfor;
    ) rotated globalRotation
enddef;

vardef byArbitraryFigureRender (expr p, col, dp, th) =
    image(
        draw (p scaled scaleFactor)
            withpen pencircle scaled lineThickness(th)
            withcolor col
            if (dp > 0):
                dashed byDashPattern(arclength(p), dp)
            fi;
        )
enddef;

vardef byArbitraryCurveDefine@#(text pointsList)(expr col, dp, th) =
if str @# = "":
    byArbitraryCurveDefine.anArbitraryCurve(pointsList)(col, dp, th);
else:
    save pL, p;
    string pL;
    path p;
    pL := "";
    p := byListToPath(pointsList);
    forsuffixes pN=pointsList:
        appendList(pL, str pN, 1, false);
    endfor;
    setAttribute("arbitraryCurve", "PointsList", str @#, pL);
    setAttribute("arbitraryCurve", "Path", str @#, p);
    setAttribute("arbitraryCurve", "Color", str @#, col);
    setAttribute("arbitraryCurve", "Dashed", str @#, dp);
    setAttribute("arbitraryCurve", "Thin", str @#, th);
    setAttribute("arbitraryCurve", "Synonym", str @#, str @#);
fi;
enddef;

vardef byNamedArbitraryCurve (text curvesList) =
    save p;
    path p;
    image(
        forsuffixes cN=curvesList:
            p := byListToPath(scantokens(getAttribute("arbitraryCurve", "PointsList", str cN)));
            draw byArbitraryFigureRender
                (p, getAttribute("arbitraryCurve", "Color", str cN),
                    getAttribute("arbitraryCurve", "Dashed", str cN),
                    getAttribute("arbitraryCurve", "Thin", str cN)) rotated globalRotation;
            if (autoLabelingMode):
                if (textLabels):
                    draw byLabelsOnPolygon(scantokens(getAttribute("arbitraryCurve", "PointsList", str cN)), noPoint)(1, 0);
                fi;
            fi;
        endfor;
        )
enddef;

vardef byListToPath(text pointsList) =
    save pathString, rp;
    string pathString;
    path rp;
    pathString := "";
    forsuffixes pN=pointsList:
        pathString := pathString & str pN & "..";
    endfor;
    rp := scantokens(substring (0, length(pathString) - 2) of pathString);
    rp
enddef;

vardef byArbitraryCurve@#(text pointsList)(expr col, dp, th) =
if str @# = "":
    byArbitraryCurve.anArbitraryCurve(pointsList)(col, dp, th)
else:
    byArbitraryCurveDefine@#(pointsList)(col, dp, th);
    byNamedArbitraryCurve(@#)
fi
enddef;

%
% Filled figures
%

vardef byFilledCircleSegment@#(suffix o)(expr r, b, e, col) =
if str @# = "":
    byFilledCircleSegment.o(o, r, b, e, col)
else:
    setAttribute("filledCircleSegment", "Color", str @#, col);
    setAttribute("filledCircleSegment", "Diameter", str @#, 2r);
    setAttribute("filledCircleSegment", "Begin", str @#, b);
    setAttribute("filledCircleSegment", "End", str @#, e);
    setAttribute("filledCircleSegment", "CenterName", str @#, str o);
    setAttribute("filledCircleSegment", "Synonym", str @#, str @#);
    byNamedFilledCircleSegment(@#)
fi
enddef;

vardef byNamedFilledCircleSegment (text filledCircleSegmentList) =
    save p;
    path p;
    image(
        forsuffixes csN=filledCircleSegmentList:
            fill (
                (subpath
                    (getAttribute("filledCircleSegment", "Begin", str csN),
                    getAttribute("filledCircleSegment", "End", str csN))
                        of fullcircle)
                    --cycle)
                    scaled (getAttribute("filledCircleSegment", "Diameter", str csN)*scaleFactor)
                    shifted (scantokens(getAttribute("filledCircleSegment", "CenterName", str csN))*scaleFactor)
                    withcolor getAttribute("filledCircleSegment", "Color", str csN);
        endfor;
    ) rotated globalRotation
enddef;

vardef byFilledCircleSector@#(suffix o)(expr r, b, e, col) =
if str @# = "":
    byFilledCircleSector.o(o, r, b, e, col)
else:
    setAttribute("filledCircleSector", "Color", str @#, col);
    setAttribute("filledCircleSector", "Diameter", str @#, 2r);
    setAttribute("filledCircleSector", "Begin", str @#, b);
    setAttribute("filledCircleSector", "End", str @#, e);
    setAttribute("filledCircleSector", "CenterName", str @#, str o);
    byNamedFilledCircleSector(@#)
fi
enddef;

vardef byNamedFilledCircleSector (text filledCircleSectorList) =
    image(
        forsuffixes csN=filledCircleSectorList:
            fill ((subpath
                    (getAttribute("filledCircleSector", "Begin", str csN),
                    getAttribute("filledCircleSector", "End", str csN))
                    of fullcircle) -- (0, 0) -- cycle)
                        scaled (getAttribute("filledCircleSector", "Diameter", str csN)*scaleFactor)
                        shifted (scantokens(getAttribute("filledCircleSector", "CenterName", str csN))*scaleFactor)
                        withcolor getAttribute("filledCircleSector", "Color", str csN);
        endfor;
    ) rotated globalRotation
enddef;

vardef byPolygonDefine@#(text pointsList)(suffix col) =
if str @# = "":
    byPolygonDefine.scantokens(byPolygonName(pointsList))(pointsList)(col);
else:
    save pL, pLraw, p, tn;
    path p;
    string pL, pLraw;
    numeric tn;
    pL := "";
    pLraw := "";
    p := forsuffixes pN=pointsList: pN -- endfor cycle;
    tn := turningnumber(p);
    forsuffixes pN=pointsList:
        appendList(pL, str pN, -tn, false);
        appendList(pLraw, str pN, 1, false);
    endfor;
    setAttribute("polygon", "Color", str @#, col);
    setAttribute("polygon", "ColorName", str @#, str col);
    setAttribute("polygon", "Transparency", str @#, 1);
    setAttribute("polygon", "PointsList", str @#, pL);
    setAttribute("polygon", "PointsListRaw", str @#, pLraw);
    setAttribute("polygon", "Synonym", str @#, str @#);
fi;
enddef;

vardef byPolygonPathFromList (expr pointsList) =
    forsuffixes pN=scantokens(pointsList): pN -- endfor cycle
enddef;

vardef byPolygon@#(text pointsList)(suffix col) =
if str @# = "":
    byPolygon.scantokens(byPolygonName(pointsList))(pointsList)(col)
else:
    byPolygonDefine.@#(pointsList)(col);
    byNamedPolygon(@#)
fi
enddef;

vardef byPolygonName(text pointsList) =
    save polygonName;
    string polygonName;
    polygonName := "";
    forsuffixes pN=pointsList:
        polygonName := polygonName & str pN;
    endfor;
    polygonName
enddef;

vardef byNamedPolygon (text polygonsList) =
    save polyPath, polyCol, polyTransp, polyGhost, shadingFunctionExists;
    path polyPath;
    numeric polyTransp;
    picture polyGhost;
    boolean shadingFunctionExists;
    image(
        draw image(
            forsuffixes pN=polygonsList:
                polyPath := byPolygonPathFromList(getAttribute("polygon", "PointsList", str pN)) scaled scaleFactor;
                defineColor.polyCol(getAttribute("polygon", "Color", str pN));
                polyTransp := getAttribute("polygon", "Transparency", str pN);
                if known shadingFor.scantokens(getAttribute("polygon", "ColorName", str pN)):
                    shadingFunctionExists := true;
                else:
                    shadingFunctionExists := false;
                fi;
                if (not isWhite(polyCol)):
                    if not shadingFunctionExists:
                        fill polyPath
                            withcolor
                                if polyTransp = 1:
                                    polyCol
                                else:
                                    transparent(1, polyTransp, polyCol)
                                fi;
                    else:
                        shadingFunction.scantokens(getAttribute("polygon", "ColorName", str pN))
                            (polyPath, polyCol)(scantokens(getAttribute("polygon", "PointsListRaw", str pN)));
                    fi;
                fi;
                polyGhost := image(
                    if not shadingFunctionExists:
                        if (not isLight(polyCol)):
                            draw ghostPicture;
                        fi;
                        draw polyPath
                            withcolor polyCol
                            withpen pencircle scaled 2lineWidth;
                    fi;
                    );
                clip polyGhost to polyPath;
                draw polyGhost;
                if (isLight(polyCol)) and not shadingFunctionExists:
                    draw (byPolygonPathFromList(getAttribute("polygon", "PointsList", str pN)) scaled scaleFactor)
                        withcolor selectOutlineColor.scantokens(getAttribute("polygon", "ColorName", str pN))
                        withpen pencircle scaled lineWidthThin;
                fi;
                if mainPictureMode and ghostLines:
                    save gP;
                    picture gP;
                    gP := ghostPicture;
                    ghostPicture := image(
                        draw gP;
                        draw polyPath withcolor white withpen pencircle scaled lineWidthHair;
                        );
                fi;
            endfor;
            ) rotated globalRotation;
        if (autoLabelingMode):
            draw byLabelPolygon(1)(polygonsList);
        fi;
    )
enddef;

vardef byMergePolygons (text polygonsList) =
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
                                        if (k = i):
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
            if (points[cycleval(i-2, n + 1)] = points[i]):
                m := m + 2;
            else:
                points[cycleval(i-m, n + 1)] := points[i];
            fi;
        endfor;
        n := n - m;
        exitif((m = 0) or (iteration > 100));
    endfor;
    for i := 0 step 1 until n:
        appendList(cleanedList, points[i], 1, false);
    endfor;
    cleanedList
enddef;

%
% Angles
%

vardef byAngleDefine@#(suffix a, b, c)(expr col, sty) =
if str @# = "":
    byAngleDefine.scantokens(str a & str b & str c)(a, b, c)(col, sty);
else:
    if mainPictureMode:
        appendList(pointAnglesList.b, str @#, 1, true);
        appendList(anglePointsList, str b, 1, true);
    fi;
        save p, q, d, ad, ac, at;
        path p;
        picture q;
        numeric ad, at;
        boolean ac;
        if autoRightAngles:
            if isRightAngle(a, b, c):
                at := 1;
            else:
                at := 0;
            fi;
        else:
            at := 0;
        fi;
        p := byConstructAngleArc(a, b, c, at);
        ad := angle(point (arctime arclength(p)/2 of p) of p);
        if (ypart(unitvector(a-b) rotated -ad)) > 0:
            ac := true;
        else:
            ac := false;
        fi;
        setAttribute("angle", "Arc", str @#, p);
        setAttribute("angle", "ArcClockwise", str @#, ac);
        setAttribute("angle", "ArcType", str @#, at);
        setAttribute("angle", "Val", str @#, 180*arclength(p scaled 2)/pi);
        setAttribute("angle", "AVal", str @#, angle(a-b));
        setAttribute("angle", "CVal", str @#, angle(c-b));
        setAttribute("angle", "Direction", str @#, ad);
        setAttribute("angle", "Color", str @#, col);
        setAttribute0("angle", "OptionalColor", str @#, byDefaultAngleOptionalColor);
        setAttribute("angle", "Style", str @#, sty);
        setAttribute("angle", "AName", str @#, str a);
        setAttribute("angle", "BName", str @#, str b);
        setAttribute("angle", "CName", str @#, str c);
        setAttribute("angle", "ScaleCorrection", str @#, 1);
        setAttribute("angle", "Standalone", str @#, 0);
        setAttribute("angle", "Synonym", str @#, str @#);
fi;
enddef;

vardef byConstructAngleArc (suffix a, b, c)(expr s) =
    save p, d, cutTime, q;
    pair d;
    path p[];
    color q[];
    numeric cutTime[];
    d := 1/2[unitvector(a-b),unitvector(c-b)];
    if (abs(d) = 0):
        d := (unitvector(a-c) rotated 90);
    fi;
    if (s = 0):
        p0 := fullcircle;
        if (attributeExists("point", "XYZ", str a)
            and attributeExists("point", "XYZ", str b)
            and attributeExists("point", "XYZ", str c)):
            p0 := byFullCircleToPlane(
                getAttribute("point", "XYZ", str a),
                getAttribute("point", "XYZ", str b),
                getAttribute("point", "XYZ", str c)
                );
        fi;
        cutTime1 := xpart((p0 scaled u) intersectiontimes ((0, 0)--10[(0, 0), a - b]));
        cutTime2 := xpart((p0 scaled u) intersectiontimes ((0, 0)--10[(0, 0), c - b]));
        p1 := subpath (cutTime1, cutTime2) of p0;
        p2 := subpath (cutTime1 - length(p0), cutTime2) of p0;
        p3 := subpath (cutTime1 + length(p0), cutTime2) of p0;
        if (arclength(p2) > arclength(p3)):
            p4 := p3;
        else:
            p4 := p2;
        fi;
        if (arclength(p1) < arclength(p4)):
            p4 := p1;
        fi;
    elseif (s = 1):
        if (attributeExists("point", "XYZ", str a)
            and attributeExists("point", "XYZ", str b)
            and attributeExists("point", "XYZ", str c)):
            q1 := unitvectorXYZ(pointXYZ.a - pointXYZ.b) colorrotated projectionAngle;
            q3 := unitvectorXYZ(pointXYZ.c - pointXYZ.b) colorrotated projectionAngle;
            q2 := q1 + q3;
            p4 := 1/2(redpart(q1), greenpart(q1))
                -- 1/2(redpart(q2), greenpart(q2))
                -- 1/2(redpart(q3), greenpart(q3));
        else:
            p4 := 1/2unitvector(a - b)
                -- 1/2(unitvector(a - b) + unitvector(c - b))
                -- 1/2unitvector(c - b);
        fi;
    fi;
    p4
enddef;

vardef byIsArcClockwise (expr p) =
    save rv;
    boolean rv;
    if ypart(direction (1/2length(p)) of (p rotated -angle(point 1/2length(p) of p))) < 0:
        rv := true;
    else:
        rv := false;
    fi;
    rv
enddef;

vardef byFullCircleToPlane (expr colPlaneA, colPlaneB, colPlaneC) =
    save dvec, fvec, p;
    color dvec;
    pair fvec;
    path p;
    dvec := unitvectorXYZ((colPlaneA-colPlaneB) crossproduct (colPlaneC-colPlaneB));
    dvec := dvec colorrotated projectionAngle;
    fvec := (redpart dvec, greenpart dvec);
    if (abs(fvec) > 0):
        p := ((fullcircle rotated -angle(fvec)) xscaled sqrt(1-abs(fvec)**2)) rotated angle(fvec);
    else:
        p := fullcircle;
    fi;
    p
enddef;

vardef byAngle@#(suffix a, b, c)(expr col, sty) =
if str @# = "":
    byAngle.scantokens(str a & str b & str c)(a, b, c, col, sty)
else:
    byAngleDefine@#(a, b, c, col, sty);
    byNamedAngle(@#)
fi
enddef;

vardef byAngleDefineExtended@#(suffix a, b, c)(expr col, sty)(text optionalColors) =
if str @# = "":
    byAngleDefineExtended.scantokens(str a & str b & str c)(a, b, c)(col, sty)(optionalColors);
else:
    save n;
    numeric n;
    n := 0;
    byAngleDefine.@#(a, b, c, col, sty);
    forsuffixes oC=optionalColors:
        setAttribute[n]("angle", "OptionalColor", str @#, oC);
        n := n + 1;
    endfor;
fi;
enddef;

vardef byAngleExtended@#(suffix a, b, c)(expr col, sty)(text optionalColors) =
if str @# = "":
    byAngleExtended.scantokens(str a & str b & str c)(a, b, c)(col, sty)(optionalColors)
else:
    byAngleDefineExtended@#(a, b, c)(col, sty)(optionalColors);
    byNamedAngle(@#)
fi
enddef;

vardef byNamedAngle (text anglesList) =
    save p, q, processedAL;
    picture q;
    path p;
    string processedAL;
    image(
        processedAL := byProcessAnglesList(anglesList);
        forsuffixes aN=scantokens(processedAL):
            setAttribute("angle", "ScaleCorrection", str aN, angleScale);
            p := byConstructAngleArc(
                scantokens(getAttribute("angle", "AName", str aN)),
                scantokens(getAttribute("angle", "BName", str aN)),
                scantokens(getAttribute("angle", "CName", str aN)),
                getAttribute("angle", "ArcType", str aN));
            q := image(
                if (getAttribute("angle", "Color", str aN) <> white):
                    if (typeOf(getAttribute("angle", "Style", str aN)) = "numeric"):
                        draw scantokens(byAngleMacroName[getAttribute("angle", "Style", str aN)]) (p, getAttribute("angle", "Color", str aN), angleOptionalColor.scantokens(angleSynonym.aN));
                    elseif (typeOf(getAttribute("angle", "Style", str aN)) = "string"):
                        draw scantokens("byAngleM" & getAttribute("angle", "Style", str aN)) (p, getAttribute("angle", "Color", str aN), angleOptionalColor.scantokens(angleSynonym.aN));
                    fi;
                else:
                    draw byAngleMWhite(p, 0, 0);
                fi;
                if solidAngleMode and (textLabels and autoLabelingMode):
                    draw (p scaled (1/3angleScale*u))--(0,0)--cycle withcolor white;
                    fill (p scaled (1/3angleScale*u))--(0,0)--cycle withcolor white;
                fi;
            );
            draw (q shifted (scantokens(getAttribute("angle", "BName", str aN)) scaled scaleFactor)) rotated globalRotation;
        endfor;
    )
enddef;

vardef byNamedSolidAngle (text anglesList) =
    save solidAngleMode, processedAL, centerName, rv;
    boolean solidAngleMode;
    string processedAL, centerName;
    processedAL := byProcessAnglesList(anglesList);
    solidAngleMode := true;
    image(
        forsuffixes aN := scantokens(processedAL):
            centerName := getAttribute("angle", "BName", str aN);
        endfor;
        draw byNamedAngle(anglesList);
        if (textLabels and autoLabelingMode):
            draw byTextLabel(pointLabel)(centerName, scantokens(centerName), 0, 0);
        fi;
    )
enddef;

vardef byProcessAnglesList@#(text anglesListToProcess)=
    save processedAnglesList, compoundAngleString, splitAnglePoints;
    string processedAnglesList, compoundAngleString, splitAnglePoints;
    processedAnglesList := "";
    splitAnglePoints := "";
    forsuffixes aN=anglesListToProcess:
        if attributeExists("angle", "Synonym", str aN):
            appendList(processedAnglesList, str aN, 1, false);
        else:
            splitAnglePoints := bySplitStringIntoAngles(str aN);
            if (known aN) and (length(splitAnglePoints) = 0):
                compoundAngleString := pointAnglesList.aN;
            else:
                compoundAngleString := byConstructCompoundAngle(scantokens(splitAnglePoints));
            fi;
            if compoundAngleString <> "":
                appendList(processedAnglesList, compoundAngleString, 1, false);
                if str @# <> "":
                    appendList(@#, splitAnglePoints, 1, false);
                fi;
            else:
                errmessage("Unknown angle: " & str aN);
            fi;
        fi;
    endfor;
    processedAnglesList
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
    save p, rv;
    path p[];
    picture rv;
    p0 := angleArc scaled ((u*angleScale) - lineWidth);
    p1 := (0, 0)--p0--cycle;
    p2 := (0, 0)--(angleArc scaled (u*angleScale))--cycle;
    rv := image(
        if (angleOptionalColors[0] <> bytransparent):
            fill p2 withcolor angleOptionalColors[0];
        fi;
        draw p0 withpen pencircle scaled lineWidth withcolor angleColor;
    );
    clip rv to p2;
    rv
enddef;

vardef byAngleMThinLine (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidthThin);
    image(
        if (angleOptionalColors[0] <> bytransparent):
            fill ((0, 0)--p--cycle) withcolor angleOptionalColors[0];
        fi;
        draw p withpen pencircle scaled lineWidthThin withcolor angleColor;
    )
enddef;

vardef byAngleMDashedLine (expr angleArc, angleColor)(suffix angleOptionalColors) =
    save p;
    path p;
    p := angleArc scaled ((u*angleScale) - lineWidth);
    image(
        if (angleOptionalColors[0] <> bytransparent):
            fill (p--(0,0)--cycle) withcolor angleOptionalColors[0];
        fi;
        draw p withpen pencircle scaled lineWidth withcolor angleColor dashed byDashPattern(arclength(p), 1);
    )
enddef;

% Following monstrosity draws dummy sides for angles which require them,
% essentially, it takes a list of angles, checks if they all are constructed
% on one point; then it browses through all angles, finds their sides
% and counts them; ones that occur twice it draws as is; ones that occur
% once it shifts inside an angle; and after that it clips everything
% to angle outline.
vardef byNamedAngleSidesFull (text anglesList)(text linesList)=
    save centerName, uniqueCenter, angleGenArc, angleDir, angleCount, angleType, angleSide, anglePart, angleNum, angleCheck,
        ac, as, p, n, compoundAnglePath, compoundAngleArc, b, e, outputImage, lineCol, lineTh, lineDash, pointName, scaleToUse,
        processedAnglesList, processedLinesList,
        planePoints, threeDMode, projectedCircle, labelVector,
        enteredAnglePointsList, pointNameToUse;
    string centerName, pointName[], processedAnglesList, processedLinesList,enteredAnglePointsList, pointNameToUse;
    pair ac, p[], labelVector;
    boolean uniqueCenter, angleCheck, doNotLabelCenter, threeDMode;
    numeric angleDir[], angleCount[], angleType[], angleSide[], angleNum, anglePart[], as[], n[], b, e, lineTh, lineDash, scaleToUse;
    path angleGenArc, compoundAnglePath, compoundAngleArc, projectedCircle;
    color planePoints[];
    picture outputImage;
    centerName := "";
    uniqueCenter := true;
    doNotLabelCenter := false;
    scaleToUse := -1;
    enteredAnglePointsList := "";
    processedAnglesList := byProcessAnglesList.enteredAnglePointsList(anglesList);
    forsuffixes lN=linesList:
        appendList(processedLinesList, str lN, 1, false);
    endfor;
    threeDMode := false;
    forsuffixes aN=scantokens(processedAnglesList):
        ac := scantokens(getAttribute("angle", "BName", str aN));
        if (centerName = ""):
            centerName := getAttribute("angle", "BName", str aN);
            if (attributeExists("point", "XYZ", getAttribute("angle", "AName", str aN))
                and attributeExists("point", "XYZ", getAttribute("angle", "BName", str aN))
                and attributeExists("point", "XYZ", getAttribute("angle", "CName", str aN))):
                threeDMode := true;
                planePoints1 := getAttribute("point", "XYZ", getAttribute("angle", "AName", str aN));
                planePoints2 := getAttribute("point", "XYZ", getAttribute("angle", "BName", str aN));
                planePoints3 := getAttribute("point", "XYZ", getAttribute("angle", "CName", str aN));
                projectedCircle := byFullCircleToPlane(planePoints1, planePoints2, planePoints3);
            else:
                projectedCircle := fullcircle;
            fi;
        elseif (centerName <> getAttribute("angle", "BName", str aN)):
            uniqueCenter := false;
        elseif threeDMode:
            if (not isInPlane(getAttribute("point", "XYZ", getAttribute("angle", "AName", str aN)),
                    planePoints1, planePoints2, planePoints3))
                or (not isInPlane(getAttribute("point", "XYZ", getAttribute("angle", "CName", str aN)),
                    planePoints1, planePoints2, planePoints3)):
                errmessage("The angles " & processedAnglesList & " are not coplanar");
            fi;
        fi;
        if (getAttribute("angle", "Standalone", str aN) > 1):
            doNotLabelCenter := true;
        fi;
        if (getAttribute("angle", "ScaleCorrection", str aN) <> angleScale)
        and (getAttribute("angle", "ScaleCorrection", str aN) > scaleToUse):
            scaleToUse := getAttribute("angle", "ScaleCorrection", str aN);
        fi;
    endfor;
    if (length(processedLinesList) = 0):
        if (known pointLinesList.scantokens(centerName)):
            processedLinesList := pointLinesList.scantokens(centerName);
        fi;
    fi;
    if (scaleToUse < 0):
        scaleToUse := angleScale;
    fi;
    outputImage := image(
        startTempAngleScale(scaleToUse);
            if (uniqueCenter):
                angleNum := 0;
                forsuffixes aN=scantokens(processedAnglesList):
                    angleGenArc := byConstructAngleArc(
                        scantokens(getAttribute("angle", "AName", str aN)),
                        scantokens(getAttribute("angle", "BName", str aN)),
                        scantokens(getAttribute("angle", "CName", str aN)),
                        getAttribute("angle", "ArcType", str aN));
                    anglePart1 := angle(point 0 of angleGenArc);
                    as1 := sign(ypart((direction 0 of angleGenArc) rotated -anglePart1));
                    anglePart2 := angle(point 0 of reverse(angleGenArc));
                    as2 := sign(ypart((direction 0 of reverse(angleGenArc)) rotated -anglePart2));
                    for j=1,2:
                        angleCheck := true;
                        for i := 1 step 1 until angleNum:
                            if ((abs(angleDir[i] - anglePart[j]) mod 360) < 1):
                                angleCount[i] := angleCount[i] + 1;
                                angleCheck := false;
                                if ((getAttribute("angle", "Style", str aN) = 0)
                                    or ((getAttribute0("angle", "OptionalColor", str aN) <> white)
                                        and (getAttribute0("angle", "OptionalColor", str aN) <> bytransparent)))
                                    and (getAttribute("angle", "ArcType", str aN) <> 1):
                                    angleType[i] := 0;
                                fi;
                            fi;
                        endfor;
                        if angleCheck:
                            angleNum := angleNum + 1;
                            angleDir[angleNum] := anglePart[j];
                            angleSide[angleNum] := as[j];
                            if ((getAttribute("angle", "Style", str aN) <> 0)
                                    and (isWhite(getAttribute0("angle", "OptionalColor", str aN))
                                        or (getAttribute0("angle", "OptionalColor", str aN) = bytransparent)))
                                or ((getAttribute("angle", "Style", str aN) = 0)
                                    and isWhite(getAttribute("angle", "Color", str aN)))
                                or (getAttribute("angle", "ArcType", str aN) = 1):
                                angleType[angleNum] := 1;
                            else:
                                angleType[angleNum] := 0;
                            fi;
                            if (j = 1):
                                if (getAttribute("angle", "Standalone", str aN) > 0):
                                    pointName[angleNum] := "";
                                else:
                                    pointName[angleNum] := getAttribute("angle", "AName", str aN);
                                fi;
                            elseif (j = 2):
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
                    if (angleCount[i] = 1):
                        j := j + 1;
                        n[j] := i;
                    fi;
                    if (angleType[i] <> 0):
                        p1 := (ac*scaleFactor);
                        p2 := ((dir(angleDir[i]) scaled (1/2u * angleScale))) shifted p1;
                        defineColor.lineCol(black);
                        lineDash := 0;
                        lineTh := 1;
                        forsuffixes lN=scantokens(processedLinesList):
                            if (getAttribute("line", "EndAName", str lN) = centerName):
                                if (abs(angle(
                                        scantokens(getAttribute("line", "EndBName", str lN))
                                        - scantokens(getAttribute("line", "EndAName", str lN)))
                                        - angleDir[i]) < 1):
                                    defineColor.lineCol(getAttribute("line", "Color", str lN));
                                    lineDash := getAttribute("line", "Dashed", str lN);
                                    lineTh := getAttribute("line", "Thin", str lN);
                                fi;
                            elseif (getAttribute("line", "EndBName", str lN) = centerName):
                                if (abs(angle(
                                        scantokens(getAttribute("line", "EndAName", str lN))
                                        - scantokens(getAttribute("line", "EndBName", str lN)))
                                        - angleDir[i]) < 1):
                                    defineColor.lineCol(getAttribute("line", "Color", str lN));
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
                if (j = 2):
                    if not threeDMode:
                        b := (angleDir[n[1]]/360)*8;
                        e := (angleDir[n[2]]/360)*8;
                    else:
                        b := xpart(projectedCircle intersectiontimes ((0, 0) -- dir(angleDir[n[1]])*10));
                        e := xpart(projectedCircle intersectiontimes ((0, 0) -- dir(angleDir[n[2]])*10));
                    fi;
                    if (b > e): b := b - length(projectedCircle); fi;
                    if (angleSide[n[1]] > angleSide[n[2]]):
                        compoundAngleArc := ((subpath (b, e) of projectedCircle) scaled (u * angleScale)) shifted (ac*scaleFactor);
                    else:
                        compoundAngleArc := ((subpath (b + 8, e) of projectedCircle) scaled (u * angleScale)) shifted (ac*scaleFactor);
                    fi;
                    compoundAnglePath := compoundAngleArc -- (ac*scaleFactor) -- cycle;
                elseif (j <> 0):
                    errmessage("There are gaps in a compound angle");
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
            if (textLabels and autoLabelingMode) and (j=2):
                for i=1,2:
                    if not threeDMode:
                        labelVector := dir(angleDir[n[i]]);
                    else:
                        labelVector := (projectedCircle intersectionpoint ((0, 0) -- dir(angleDir[n[i]])*10)) scaled 2;
                    fi;
                    pointNameToUse := pointName[n[i]];
                    if length(enteredAnglePointsList) > 0:
                        show(enteredAnglePointsList);
                        forsuffixes j = scantokens(enteredAnglePointsList):
                            if (str j <> centerName):
                                if ((abs(
                                    angle(scantokens(pointNameToUse) - scantokens(centerName))
                                    - angle(j - scantokens(centerName))
                                    ) mod 360) < 1):
                                    pointNameToUse := str j;
                                fi;
                            fi;
                        endfor;
                    fi;
                    draw byTextLabel(pointLabel)(pointNameToUse,
                        ac + (labelVector*1/2u*angleScale)/scaleFactor, angleDir[n[i]], textLabelShift);
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
                        if (getAttribute("angle", "Synonym", str j) = getAttribute("angle", "Synonym", str k)):
                            useThisAngle := true;
                        fi;
                    endfor;
                else:
                    useThisAngle := true;
                fi;
                if (useThisAngle):
                    if (length(modAnglesListNew) = 0):
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
                            if (length(anglesToDraw) = 0):
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
                                if ((str j) = (str k)):
                                    angleIsAdded := true;
                                fi;
                            endfor;
                            if not angleIsAdded:
                                appendList(modAnglesListNew, str j, 1, false);
                            fi;
                        endfor;
                        modAnglesList := modAnglesListNew;
                    exitif (anglesAdded = 0) or (length(modAnglesList)=0);
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
                exitif (length(modAnglesList)=0);
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
            pointAnglesList.i := sortPointAnglesList(pointAnglesList.i);
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
            if (n = 1):
                if not string getAttribute("angle", "Synonym", candidateName0):
                    setAttribute("angle", "SynonymPartial", candidateName0, false);
                    setAttribute("angle", "Synonym", candidateName0, originalName);
                fi;
            fi;
        endfor;
    fi;
enddef;

vardef sortPointAnglesList (expr anglesListToSort) =
    save preList, postList, nPre, nPost, isSorted, value, firstValue, lastValue, rv;
    string preList, postList, rv;
    boolean isSorted;
    numeric value, firstValue, lastValue, nPre, nPost;
    lastValue := -360;
    isSorted := true;
    preList := "";
    postList := "";
    nPre := 0;
    nPost := 0;
    forsuffixes i=scantokens(anglesListToSort):
        value := getAttribute("angle", "Direction", str i);
        if (unknown firstValue):
            firstValue := value;
            appendList(postList, str i, 0, true);
        fi;
        if (value < firstValue):
            appendList(preList, str i, 0, true);
            nPre := nPre + 1;
        else:
            appendList(postList, str i, 0, true);
            nPost := nPost + 1;
        fi;
        if (lastValue > value):
            isSorted := false;
        fi;
        lastValue := value;
    endfor;
    if (isSorted):
        rv := anglesListToSort;
    else:
        if (nPre > 1):
            preList := sortPointAnglesList(preList);
        fi;
        if (nPre > 0):
            preList := preList & ", ";
        fi;
        if (nPost > 1):
            postList := sortPointAnglesList(postList);
        fi;
        rv := preList & postList;
    fi;
    rv
enddef;

vardef bySplitStringIntoAngles (expr angleName) =
    save pointA, pointB, pointC, cPointA, cPointB, cPointC, n;
    string pointA, pointB, pointC, cPointA, cPointB, cPointC, rv;
    numeric n;
    n := 0;
    for i := 1 step 1 until (length(angleName) - 2):
        for j := i + 1 step 1 until (length(angleName) - 1):
            cPointA := substring (0, i) of angleName;
            cPointB := substring (i, j) of angleName;
            cPointC := substring (j, length(angleName)) of angleName;
            if known scantokens(cPointA):
                if known scantokens(cPointB):
                    if known scantokens(cPointC):
                        n := n + 1;
                        pointA := cPointA;
                        pointB := cPointB;
                        pointC := cPointC;
                    fi;
                fi;
            fi;
        endfor;
    endfor;
    if (known scantokens(angleName)) and (n = 0):
        rv := "";
    else:
        if n = 0:
            errmessage("Can't find points for angle: " & lineName);
        fi;
        if n > 1:
            errmessage("Ambiguous angle name: " & lineName);
        fi;
        rv := pointA & ", " & pointB & ", " & pointC;
    fi;
    rv
enddef;

vardef byConstructCompoundAngle (suffix pointA, pointB, pointC) =
    save angleList, isFirst, isLast, cwA, cwC, cwAName, cwCName, dirA, dirC, rv, threeDMode, notInPlane;
    string cwAName, cwCName, angleList, rv;
    boolean isFirst, isLast, threeDMode, notInPlane;
    pair cwA, cwC, dirA, dirC;
    angleList := "";
    dirA := pointA - pointB;
    dirC := pointC - pointB;
    threeDMode := false;
    if byIsPointInSpace(pointA, pointB, pointC):
        threeDMode := true;
    fi;
    isFirst := false;
    isLast := false;
    forsuffixes i=scantokens(pointAnglesList.pointB & ", " & pointAnglesList.pointB):
        if byIsArcClockwise(byConstructAngleArc(
            scantokens(getAttribute("angle", "AName", str i)),
            scantokens(getAttribute("angle", "BName", str i)),
            scantokens(getAttribute("angle", "CName", str i)),
            getAttribute("angle", "ArcType", str i))):
            cwAName := getAttribute("angle", "CName", str i);
            cwCName := getAttribute("angle", "AName", str i);
        else:
            cwAName := getAttribute("angle", "AName", str i);
            cwCName := getAttribute("angle", "CName", str i);
        fi;
        cwA := scantokens(cwAName) - scantokens(getAttribute("angle", "BName", str i));
        cwC := scantokens(cwCName) - scantokens(getAttribute("angle", "BName", str i));
        notInPlane := false;
        if threeDMode:
            if (not isInPlane(pointXYZ.scantokens(cwAName),
                pointXYZ.pointA,
                pointXYZ.pointB,
                pointXYZ.pointC))
            or (not isInPlane(pointXYZ.scantokens(cwCName),
                pointXYZ.pointA,
                pointXYZ.pointB,
                pointXYZ.pointC)):
                notInPlane := true;
            fi;
        fi;
        if not notInPlane:
            if ((abs(angle(dirA) - angle(cwA)) mod 360) < 1) and (not isFirst):
                isFirst := true;
            fi;
            if isFirst and not isLast:
                appendList(angleList, str i, 1, true)
            fi;
            if ((abs(angle(dirC) - angle(cwC)) mod 360) < 1) and isFirst:
                isLast := true;
            fi;
        fi;
    endfor;
    if (not isFirst) or (not isLast):
        errmessage("Can't construct angle: " & str pointA & str pointB & str pointC);
    fi;
    rv := angleList;
    rv
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

def byDefineGenericRightAngles =
    byAngleDefine.rightAngleNE (pointN, pointO, pointE)(black, 1);
    byAngleDefine.rightAngleES (pointE, pointO, pointS)(black, 1);
    byAngleDefine.rightAngleSE (pointS, pointO, pointW)(black, 1);
    byAngleDefine.rightAngleWN (pointW, pointO, pointN)(black, 1);
enddef;

byDefineGenericRightAngles;

%
% Arrows
%

def commonArrowSettings =
    save ahlength, ahangle;
    ahlength := 7pt;
    ahangle := 30;
enddef;

vardef byRotationArrowDefine@#(suffix axisA, axisB, pointA) (expr ang, col, sty) =
if str @# = "":
    byRotationArrowDefine.scantokens(str axisA & str axisB & str pointA)(axisA, axisB, pointA) (ang, col, sty);
else:
    setAttribute("rotationarrow", "AxisA", str @#, axisA);
    setAttribute("rotationarrow", "AxisB", str @#, axisB);
    setAttribute("rotationarrow", "Point", str @#, pointA);
    setAttribute("rotationarrow", "AxisAName", str @#, str axisA);
    setAttribute("rotationarrow", "AxisBName", str @#, str axisB);
    setAttribute("rotationarrow", "PointName", str @#, str pointA);
    setAttribute("rotationarrow", "Angle", str @#, ang);
    setAttribute("rotationarrow", "Color", str @#, col);
    setAttribute("rotationarrow", "Style", str @#, sty);
    setAttribute("rotationarrow", "Synonym", str @#, str @#);
fi;
enddef;

vardef byGenerateRotationArrowPath (expr axisA, axisB, pointA, ang) =
    save arrowPath, spacePoint;
    path arrowPath;
    color spacePoint;
    spacePoint := pointA colorrotated projectionAngle;
    arrowPath := (redpart(spacePoint), greenpart(spacePoint));
    for i := 0 step (ang/floor(ang/5)) until ang:
        spacePoint := byRotateAroundAxis (axisA, axisB, i, pointA) colorrotated projectionAngle;
        arrowPath := arrowPath -- (redpart(spacePoint), greenpart(spacePoint));
    endfor;
    arrowPath
enddef;

vardef byNamedRotationArrow (text arrowsList) =
    save arrowPath, arrowPoint, arrowStyle;
    path arrowPath;
    color arrowPoint;
    numeric arrowStyle;
    commonArrowSettings;
    image(
        forsuffixes aN=arrowsList:
            arrowPath := byGenerateRotationArrowPath(
                pointXYZ.scantokens(getAttribute("rotationarrow", "AxisAName", str aN)),
                pointXYZ.scantokens(getAttribute("rotationarrow", "AxisBName", str aN)),
                pointXYZ.scantokens(getAttribute("rotationarrow", "PointName", str aN)),
                getAttribute("rotationarrow", "Angle", str aN)
                ) scaled scaleFactor;
            arrowStyle := getAttribute("rotationarrow", "Style", str aN);
            if arrowStyle = 0:
                arrowPath := subpath (0, (arctime (arclength(arrowPath) - ahlength) of arrowPath)) of arrowPath;
                drawarrow arrowPath withpen (pencircle scaled lineWidthThin) withcolor getAttribute("rotationarrow", "Color", str aN);
            else:
                arrowPath := subpath ((arctime ahlength of arrowPath), (arctime (arclength(arrowPath) - ahlength) of arrowPath)) of arrowPath;
                drawdblarrow arrowPath withpen (pencircle scaled lineWidthThin) withcolor getAttribute("rotationarrow", "Color", str aN);
            fi;
        endfor;
    ) rotated globalRotation
enddef;


vardef byFlatArrowDefine@#(suffix pointA, pointB) (expr col, sty, typ) =
if str @# = "":
    byFlatArrowDefine.scantokens(str pointA & str pointB)(pointA, pointB) (col, sty, typ);
else:
    setAttribute("flatarrow", "PointA", str @#, pointA);
    setAttribute("flatarrow", "PointB", str @#, pointB);
    setAttribute("flatarrow", "PointAName", str @#, str pointA);
    setAttribute("flatarrow", "PointBName", str @#, str pointB);
    setAttribute("flatarrow", "Type", str @#, typ);
    setAttribute("flatarrow", "Color", str @#, col);
    setAttribute("flatarrow", "Style", str @#, sty);
    setAttribute("flatarrow", "Synonym", str @#, str @#);
fi;
enddef;

vardef byNamedFlatArrow (text arrowsList) =
    save arrowPath, arrowStyle, arrowPoint;
    path arrowPath;
    numeric arrowStyle;
    pair arrowPoint[];
    commonArrowSettings;
    image(
        forsuffixes aN=arrowsList:
            arrowType := getAttribute("flatarrow", "Type", str aN);
            arrowStyle := getAttribute("flatarrow", "Style", str aN);
            arrowPoint1 := scantokens(getAttribute("flatarrow", "PointAName", str aN));
            arrowPoint2 := scantokens(getAttribute("flatarrow", "PointBName", str aN));
            if arrowType = 0:
                arrowPath := arrowPoint1 -- arrowPoint2;
            elseif arrowType = 1:
                arrowPath := arrowPoint1
                    .. 1/2[arrowPoint1, arrowPoint2]
                        shifted (((arrowPoint2 - arrowPoint1) scaled 1/8) rotated 90)
                    .. arrowPoint2;
            fi;
            arrowPath := arrowPath scaled scaleFactor;
            if arrowStyle = 0:
                arrowPath := subpath (
                    0,
                    arctime (arclength(arrowPath) - ahlength) of arrowPath
                    ) of arrowPath;
                drawarrow arrowPath withpen (pencircle scaled lineWidthThin) withcolor getAttribute("flatarrow", "Color", str aN);
            else:
                arrowPath := subpath (
                    arctime ahlength of arrowPath,
                    arctime (arclength(arrowPath) - ahlength) of arrowPath
                    ) of arrowPath;
                drawdblarrow arrowPath withpen (pencircle scaled lineWidthThin) withcolor getAttribute("flatarrow", "Color", str aN);
            fi;
        endfor;
    ) rotated globalRotation
enddef;

%
% Magnitudes
%

% along with 'magnitudesymbol' one symbol long 'magnitude' is also defined at the same time.
vardef byMagnitudeSymbolDefine@#(expr shp, col, sty) =
if str @# = "":
    byMagnitudeSymbolDefine.scantokens(shp)(shp, col, sty);
else:
    setAttribute("magnitude", "Color", str @#, col);
    setAttribute("magnitude", "Shape", str @#, shp);
    setAttribute("magnitude", "Style", str @#, sty);
    setAttribute1("magnitude", "Symbol", str @#, str @#);
    setAttribute1("magnitude", "N", str @#, 1);
    setAttribute("magnitude", "Alignment", str @#, 0);
    setAttribute("magnitude", "NumberOfRows", str @#, 1);
    setAttribute("magnitude", "Horizontal", str @#, false);
fi;
enddef;

vardef byNamedMagnitudeSymbol (expr n, hor)(suffix magnitudeSymbolName) =
    save p, q, i, s, magnitudeSizeCor;
    path p;
    pair s[];
    picture q;
    numeric magnitudeSizeCor;
    p := (0, 0);
    magnitudeSizeCor := 1;
    if (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "circle"):
        p := fullcircle scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "semicircleUp"):
        p := ((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "semicircleDown"):
        p := (((subpath (0, 4) of fullcircle) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "sectorDown"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "sectorUp"):
        p := ((subpath (0, 4) of fullcircle) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale) yscaled -1;
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "wedgeUp"):
        p := (((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) yscaled -1) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "wedgeDown"):
        p := ((1/2, 0) -- (1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (0, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "square"):
        p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, -1/2) -- (1/2, -1/2) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "halfsquare"):
        p := ((1/2, 1/2) -- (-1/2, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "rhombus"):
        p := ((0, 1/2) -- (-1/2, 0) -- (0, -1/2) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "halfrhombusUp"):
        p := ((0, 1/2) -- (-1/2, 0) -- (1/2, 0) -- cycle) scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "miniTriangleUp"):
        p := ((-1/4, -1/4) -- (1/4, -1/4)  -- (0, 1/4) -- cycle) scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "miniTriangleDown"):
        p := ((-1/4, 1/4) -- (1/4, 1/4)  -- (0, -1/4) -- cycle) scaled (u*magnitudeScale);
        magnitudeSizeCor := 8/7;
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "miniSquare"):
        p := ((-1/4, -1/4) -- (1/4, -1/4) -- (1/4, 1/4) -- (-1/4, 1/4) -- cycle) scaled (u*magnitudeScale);
    elseif (getAttribute("magnitude", "Shape", str magnitudeSymbolName) = "miniCircle"):
        p := fullcircle scaled (u*1/2magnitudeScale);
        magnitudeSizeCor := 8/7;
    fi;
    if (hor):
        s1 := (0, ypart(urcorner(p)) - ypart(lrcorner(p)));
        s2 := (0, magnitudeGap);
    else:
        s1 := (xpart(urcorner(p)) - xpart(ulcorner(p)), 0);
        s2 := (magnitudeGap, 0);
    fi;
    p := p scaled magnitudeSizeCor;
    q := image(
        draw p withpen (pencircle scaled lineWidthThin) withcolor getAttribute("magnitude", "Color", str magnitudeSymbolName);
        if (getAttribute("magnitude", "Style", str magnitudeSymbolName) = 0):
            fill p withcolor getAttribute("magnitude", "Color", str magnitudeSymbolName);
        fi;
    );
    image(
        for i := 1 step 1 until n:
            draw q shifted (s1 scaled i) shifted (s2 scaled i);
        endfor;
    )
enddef;

vardef byMagnitudeDefine@#(expr al, hor)(text rowsList)(text magnitudeSymbolsList) =
if str @# = "":
    errmessage("byMagnitudeDefine needs a name (byMagnitudeDefine.somename...)");
else:
    setAttribute("magnitude", "Horizontal", str @#, hor);
    setAttribute("magnitude", "Alignment", str @#, al);
    save i;
    numeric i;
    i := 0;
    forsuffixes rN=rowsList:
        i := i + 1;
        setAttribute[i]("magnitude", "N", str @#, rN);
    endfor;
    setAttribute("magnitude", "NumberOfRows", str @#, i);
    i := 0;
    forever:
        forsuffixes sN=magnitudeSymbolsList:
            i := i + 1;
            if (i <= getAttribute("magnitude", "NumberOfRows", str @#)):
                setAttribute[i]("magnitude", "Symbol", str @#, str sN);
            fi;
        endfor;
    exitif (i >= getAttribute("magnitude", "NumberOfRows", str @#));
    endfor;
fi;
enddef;

vardef byNamedMagnitude (expr excl) (suffix magnitudeName) =
    save p, s, h, magC;
    picture p;
    pair s[];
    numeric h;
    h := 0;
    image(
        for magC := 1 step 1 until getAttribute("magnitude", "NumberOfRows", str magnitudeName):
            if (excl = 0) or ((excl < 0) and (magC <> -excl)) or ((excl > 0) and (magC = excl)):
                p := byNamedMagnitudeSymbol(getAttribute[magC]("magnitude", "N", str magnitudeName), getAttribute("magnitude", "Horizontal", str magnitudeName))(scantokens(getAttribute[magC]("magnitude", "Symbol", str magnitudeName)));
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

% If using metafun, use textext

if known metafunversion:
    vardef textLabelRender(expr t) =
        textext("\tf\ss " & t) scaled 2/5
    enddef;
else:
    input TEX;
    TEXPRE("%&latex" & char(10) & "\documentclass{article}\usepackage[utf8]{inputenc}\usepackage[russian]{babel}\begin{document}");
    TEXPOST("\end{document}");
    vardef textLabelRender(expr t) =
        TEX("\textsf{" & t & "}") scaled 2/5
    enddef;
fi;

numeric textLabelAvSize;
textLabelAvSize := abs(ulcorner(textLabelRender("A")) - llcorner(textLabelRender("A")));

vardef byTextLabel(suffix labelType)(expr t, p, a, d) =
    save labelItself, labelString, bb;
    path bb;
    picture labelItself;
    string labelString;
    if not string labelType.scantokens(t):
        string labelType.scantokens(t);
        labelType.scantokens(t) := t;
    fi;
    labelString := str labelType & "." & t;
    if (not isInList(labelString, uniqueTextLabels)) or (not omitDuplicateTextLabels):
        appendList(uniqueTextLabels, labelString, 1, false);
        labelItself := textLabelRender(labelType.scantokens(t));
        labelItself := labelItself shifted -1/2[ulcorner(labelItself), lrcorner(labelItself)];
        if (d > 0):
            bb := ulcorner(labelItself) -- urcorner(labelItself) -- lrcorner(labelItself) -- llcorner(labelItself)--cycle;
            labelItself := labelItself shifted -(bb intersectionpoint ((0,0)--(dir(a+180+globalRotation)*1cm)));
        fi;
        labelItself := image(
            draw labelItself shifted ((p scaled scaleFactor) rotated globalRotation) shifted (dir(a+globalRotation)*d);
        );
    else:
        labelItself := image();
    fi;
    labelItself
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
                draw byTextLabel(pointLabel)(getAttribute("line", "Label", str lN),
                    1/2[scantokens(getAttribute("line", "EndAName", str lN)),
                        scantokens(getAttribute("line", "EndBName", str lN))],
                    getAttribute("line", "Angle", str lN) + a, textLabelShift);
            else:
                draw byTextLabel(pointLabel)(
                    getAttribute("line", "EndAName", str lN),
                    scantokens(getAttribute("line", "EndAName", str lN)),
                    getAttribute("line", "Angle", str lN) + a,
                    textLabelShift);
                draw byTextLabel(pointLabel)(
                    getAttribute("line", "EndBName", str lN),
                    scantokens(getAttribute("line", "EndBName", str lN)),
                    getAttribute("line", "Angle", str lN) + a,
                    textLabelShift);
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
    save d, t, s, c;
    numeric t, s;
    pair c;
    if string getAttribute("circle", "CenterName", str cn):
        t := getAttribute("circle", "Thin", str cn);
        s := getAttribute("circle", "Shift", str cn);
        c := byReturnCircleCenter(str cn);
    elseif string getAttribute("arc", "CenterName", str cn):
        t := getAttribute("arc", "Thin", str cn);
        s := getAttribute("arc", "Shift", str cn);
        c := scantokens(getAttribute("arc", "CenterName", str cn));
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
                    if (pointName[i] = pointName[i-1]):
                        i := i - 1;
                    fi;
                fi;
            endfor;
            if (pointName[i] = pointName[0]):
                i := i - 1;
            fi;
            if (i = 1):
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
                        if (pointName[k] = "noPoint"):
                            p2 := pointLoc[l];
                            p0 := 2[p2, p1];
                            stump := -1;
                        elseif (pointName[l] = "noPoint"):
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
                    if (sty = 2) and ((j = 0) or (j = i)):
                        pointDrawn.scantokens(pointName[j]) := true;
                    fi;
                    if (sty = 3) and (j = 0):
                        pointDrawn.scantokens(pointName[j]) := true;
                    fi;
                    if (sty = 4) and (j = i):
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
