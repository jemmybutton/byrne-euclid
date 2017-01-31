%    lettrine-generator 0.0.1
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

vardef log(expr x, b) =
    (mlog(x)/256)/(mlog(2)/256)
enddef;

% here we define some measures, common to all images
numeric lS, mD;
lS := 7/5cm;
mD := 1/20cm;
bS := 2/3mm;

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
begingroup
    path outputPath[];
    outputPath1 := point 0 of p;
    outputPath2 := point 0 of p;
    for i := 0 step s until length(p):
        if(abs(direction i of p) > 0):
            outputPath1 := outputPath1 -- (point i of p shifted (unitvector(direction i of p rotated 90) scaled mD));
            outputPath2 := outputPath2 -- (point i of p shifted (unitvector(direction i of p rotated -90) scaled mD));
        else:
            outputPath1 := outputPath1 -- (point i of p shifted (unitvector(direction i - 1/100 of p rotated 90) scaled mD));
            outputPath2 := outputPath2 -- (point i of p shifted (unitvector(direction i - 1/100 of p rotated -90) scaled mD));
        fi;
    endfor;
    outputPath1..(point length(p) of p shifted (unitvector(direction (length(p) - 1/100) of p) scaled mD))..reverse(subpath(1, length(outputPath2)) of outputPath2)--cycle
endgroup
enddef;

vardef findRightSize (expr p, q, lni, li, lDir, l, n, i) =
begingroup
    save bp, ic, rv, s;
    path bp;
    numeric ic, rv, s;
    s := 1/2[lni, li];
    if (lni > 0):
        rv := s;
    else:
        rv := 0;
    fi;
    bp := (p scaled s) shifted q;
    ic := checkIfIntersects(bp, l, n);
    if (i > 0) and (li >= minBranchLength):
        if (ic = 0):
            rv := findRightSize(p, q, s, li, 1, l, n, i - 1);
        else:
            rv := findRightSize(p, q, lni, s, -1, l, n, i - 1);
        fi;
    else:
        if (ic <> 0):
            if (lDir = 1):
                rv := 1/2[s, li];
            elseif (lDir = -1):
                rv := 1/2[lni, li];
            fi;
        fi;
    fi;
    rv
endgroup
enddef;

vardef findRightPlace (expr n, pN) =
begingroup
    save tp, ts, s, t, sOld, i, j, rp, startPoint, endPoint, cO;
    path tp, rp;
    numeric ts, ti, s, t, sOld, i, j, startPoint, endPoint, cO;
    sOld := 0;
    rp := (0, 0);
    t := -1;
    if (uniformdeviate(10)>2) or (cycle p[n]):
        if (o[n] = 0): cO := 1; else: cO := 0; fi;
    else:
        cO := o[n];
    fi;
    o[pN + 1] := cO;
    endPoint := arclength(pm[n]);
    startPoint := uniformdeviate(1/2endPoint);
    for i := startPoint step bS until 1/2endPoint + startPoint:
        j := (arctime i of pm[n]);
        if (checkBranch (n, j) = 0) or (checkBranch (n, j) > sOld):
            if cycle p[n]:
                ts := abs(ulcorner(p[n]) - lrcorner(p[n]));
            else:
                ts := 1/2arclength(p[n]);
            fi;
            if (checkBranch (n, j) > 0):
                ts := checkBranch (n, j);
            fi;
            ti := 2 + log(ts/(1/4mm), 2);
            if (cO = 0):
                tp := q[cO] rotated (angle(direction j of pm[n]) - 90);
            else:
                tp := q[cO] rotated (angle(direction j of pm[n]) + 90);
            fi;
            s := findRightSize(tp, (point j of pm[n]), 0, ts, 0, n, pN, ti);
            if (arclength(tp scaled s) <= minBranchLength):
                pb[n] := addBranch (n, j, -1);
            else:
                pb[n] := addBranch (n, j, s);
            fi;
            if (s > sOld):
                pb[n] := addBranch (n, j, s);
                rp := tp scaled s shifted (point j of pm[n]);
                sOld := s;
                t := j;
            fi;
        fi;
    endfor;
    if (t >= 0):
        pb[n] := addBranch (n, t, -1);
    fi;
    rp
endgroup
enddef;

vardef checkIfIntersects (expr pathItself, l, n) =
begingroup
    save rv, m, t;
    numeric rv, t;
    rv := 0;
    t := xpart(pathItself firstIntersectionTimes po[l]);
    if (xpart((subpath(t + 1/100, length(pathItself)) of pathItself) intersectiontimes po[l]) >= 0)
        or (xpart((subpath(1/100, length(pathItself)) of pathItself) intersectiontimes po[l]) < 0)
        or (arclength(subpath (0, t) of pathItself) > 3mD)
        or (t < 0):
        rv := rv + 1;
    else:
        for m := 0 step 1 until n:
            if (l <> m)
                and ((xpart(pathItself intersectiontimes po[m]) >= 0)
                    or (xpart(pathItself intersectiontimes p[m]) >= 0)):
                rv := rv + 1;
            fi;
        endfor;
    fi;
    rv
endgroup
enddef;

vardef generateBranchesTemplate (expr p) =
begingroup
    save rv;
    path rv;
    rv := (0, 0);
    for i := 1 step 1 until round(arclength(p)/bS):
        rv := rv -- (0, 0);
    endfor;
    rv
endgroup
enddef;

vardef addBranch (expr pn, l, s) =
begingroup
    save rv, loc;
    path rv;
    numeric loc;
    loc := round((arclength(subpath(0, l) of pm[pn]))/bS);
    if (loc < length(pb[pn])) and (loc > 0):
        rv := (subpath (0, loc-1) of pb[pn])
            -- (s, ypart(point loc of pb[pn]))
            -- (subpath (loc+1, length(pb[pn])) of pb[pn]);
    elseif (loc = 0):
        rv := (s, ypart(point loc of pb[pn]))
            -- (subpath (loc+1, length(pb[pn])) of pb[pn]);
    elseif (loc = length(pb[pn])):
        rv := (subpath (0, loc-1) of pb[pn])
            -- (s, ypart(point loc of pb[pn]));
    fi;
    rv
endgroup
enddef;

vardef checkBranch (expr pn, l) =
begingroup
    save rv, loc;
    numeric loc, rv;
    loc := round((arclength(subpath(0, l) of pm[pn]))/bS);
    rv := xpart(point loc of pb[pn]);
    rv
endgroup
enddef;

figNum := 0;

picture currentLetter, cL;
path p[], pm[], pb[], po[], q[], candidateBranch;
% 'o[]' is for curl's orientation, 'cO' is for current curl orientation, 'p[]' is main for paths, 'pm[]' is for subpath of p[] that can yield 'buds', 'pb[]' is for 'buds', places where branches are, or tried to spring, 'q[]' is for curl templates, 'tp' is for temporary path in cycle, 's' is for scale, 'startFrom' is for cases when we only need boundry as invisible limit
numeric o[], cO, lC, tt[], ta, ln[], ll, lc, startFrom, symMode, numberOfIterations;
pair qi;
string shuffledNumbers;

q0 := ((1/2,0) for a := 60 step 60 until 360: .. (cosd(a), sind(a)) scaled 1/2(1-a/360) endfor) shifted (-1/2, 0);
q1 := q0 yscaled -1;
qi := (1/2, length(q0) - 2);

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
        if l <> "plate":
            pN := 0;
            p0 := (0,0)--(0, lS)--(lS, lS)--(lS, 0)--cycle;
            pm0 := p0;
            po0 := pathOutline(p0, 1/2);
            pb0 := generateBranchesTemplate(pm0);
            o0 := 0;
            currentLetter := TEX(l);
            for tp within currentLetter:
                cL := (glyph (ASCII textpart tp) of (fontpart tp)) scaled 100/2700;
                cL := cL shifted -1/2[urcorner(cL), llcorner(cL)] shifted (1/2lS, 1/2lS);
                draw cL;
                for item within cL:
                    pN := pN + 1;
                    p[pN] := pathpart item;
                    pm[pN] := p[pN];
                    po[pN] := pathOutline(p[pN], 1/8);
                    pb[pN] := generateBranchesTemplate(pm[pN]);
                    o[pN] := 0;
                endfor;
            endfor;
            startFrom := 0;
            symMode := 0;
            numberOfIterations := 12;
            minBranchLength := 1/6cm;
        else:
            p0 := (-80/2mm,-15/2mm)--(-80/2mm, 15/2mm)--(80/2mm, 15/2mm)--(80/2mm, -15/2mm)--cycle;
            pm0 := p0;
            p1 := (q0 rotated 15) scaled 18mm;
            pm1 := subpath (0, ypart(qi)) of p1;
            p2 := p1 rotated 180;
            pm2 := subpath (0, ypart(qi)) of p2;
            for i := 0 step 1 until 2:
                pN := i;
                po[i] := pathOutline(p[i], 1/2);
                pb[i] := generateBranchesTemplate(pm[i]);
                o[i] := 0;
            endfor;
            startFrom := 1;
            symMode := 1;
            numberOfIterations := 12;
            minBranchLength := 1/4cm;
        fi;
        for nn := 0 step 1 until numberOfIterations:
            shuffledNumbers := "";
            for i := startFrom step 1 until pN:
                if (uniformdeviate(1) > 1/2):
                    shuffledNumbers := shuffledNumbers & "," & decimal(i);
                else:
                    shuffledNumbers := decimal(i) & "," & shuffledNumbers;
                fi;
            endfor;
            shuffledNumbers := substring(0, length(shuffledNumbers)-1) of shuffledNumbers;
            for i=scantokens(shuffledNumbers):
                if (xpart(urcorner(pb[i])) >= 0):
                    candidateBranch := findRightPlace(i, pN);
                    if (arclength(candidateBranch) >= minBranchLength):
                        pN := pN + 1;
                        p[pN] := candidateBranch;
                        pm[pN] := subpath qi of p[pN];
                        po[pN] := pathOutline(p[pN], 1/2);
                        pb[pN] := generateBranchesTemplate(pm[pN]);
                        if(symMode = 1):
                            pN := pN + 1;
                            p[pN] := p[pN-1] rotated 180;
                            pm[pN] := pm[pN-1] rotated 180;
                            po[pN] := po[pN-1] rotated 180;
                            pb[pN] := pb[pN-1];
                            o[pN] := o[pN-1];
                        fi;
                    fi;
                fi;
            endfor;
        endfor;
        for i := startFrom step 1 until pN:
            draw p[i] if (i=0): withpen pensquare scaled 1/3mm else: withpen pencircle scaled 1/5mm fi;
            if (not cycle p[i]):
                draw (((fullcircle shifted (1/2, 0)) scaled 1/60cm) rotated (if (o[i]=1):-90 else:90 fi + angle(direction length(p[i]) of p[i]))) shifted point length(p[i]) of p[i] withpen pencircle scaled 1/5mm;
            fi;
        endfor;
    endfig;
endfor;
end
