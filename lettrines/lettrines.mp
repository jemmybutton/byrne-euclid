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

% here we define some measures, common to all images
numeric lS, mD;
lS := 7/5cm;
mD := 1/25cm;
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

vardef findRightSize (expr p, q, lni, li, l, n, i) (suffix pp) =
begingroup
    save bp, ic, rv, s;
    path bp;
    numeric ic, rv, s;
    s := 1/3[lni, li];
    if (lni > 0):
        rv := s;
    else:
        rv := 0;
    fi;
    bp := (p scaled s) shifted q;
    ic := checkIfIntersects(bp, l, n)(pp);
    if (i > 0) and (li > 1/8cm):
        if (ic = 0):
            rv := findRightSize(p, q, s, li, l, n, i - 1)(pp);
        else:
            rv := findRightSize(p, q, lni, s, l, n, i - 1)(pp);
        fi;
    fi;
    rv
endgroup
enddef;

vardef checkIfIntersects (expr p, l, n)(suffix pp) =
begingroup
    save rv, m, t;
    numeric rv, t;
    rv := 0;
    t := xpart(p firstIntersectionTimes po[l]);
    if (xpart((subpath(t + 1/100, length(p)) of p) intersectiontimes po[l]) >= 0)
        or (xpart((subpath(1/100, length(p)) of p) intersectiontimes po[l]) < 0)
        or (arclength(subpath (0, t) of p) > 3mD):
        rv := rv + 1;
    else:
        for m := 0 step 1 until n:
            if (l <> m) and (xpart(p intersectiontimes po[m]) >= 0):
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
    for i := 1mm step bS until arclength(p):
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
    loc := round((arclength(subpath(0, l) of p[pn]))/bS);
    if (s = 0):
        rv := (subpath (0, loc-1) of pb[pn])
            -- (1, ypart(point loc of pb[pn]))
            -- (subpath (loc+1, length(pb[pn])) of pb[pn]);
    else:
        rv := (subpath (0, loc-1) of pb[pn])
            -- (xpart(point loc of pb[pn]), 1)
            -- (subpath (loc+1, length(pb[pn])) of pb[pn]);
    fi;
    rv
endgroup
enddef;

vardef checkBranch (expr pn, l, s) =
begingroup
    save rv, loc;
    numeric loc, rv;
    loc := round((arclength(subpath(0, l) of p[pn]))/bS);
    if (s = 0):
        rv := xpart(point loc of pb[pn]);
    else:
        rv := xpart(point loc of pb[pn]);
    fi;
    rv
endgroup
enddef;

figNum := 0;

picture currentLetter, cL;
path p[], pb[], po[], q[], tp;
% 'o[]' is for curl's orientation, 'cO' is for current curl orientation, lC is temporary for length that curl shares with its parent, 'p[]' is main for paths, 'pb[]' is for 'buds', places where branches are, or tried to spring, 'q[]' is for curl templates, 'tp' is for temporary path in cycle, 's' is for scale, 'startFrom' is for cases when we only need boundry as invisible limit
numeric o[], cO, lC, tt[], ta, ln[], ll, lc, s, startFrom, symMode, numberOfIterations;
pair sP;

q0 := ((1/2,0) for a := 60 step 60 until 360: .. (cosd(a), sind(a)) scaled 1/2(1-a/360) endfor) shifted (-1/2, 0);
q1 := q0 yscaled -1;

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
            po0 := pathOutline(p0, 1/2);
            pb0 := generateBranchesTemplate(p0);
            o0 := 0;
            currentLetter := TEX(l);
            for tp within currentLetter:
                cL := (glyph (ASCII textpart tp) of (fontpart tp)) scaled 100/2700;
                cL := cL shifted -1/2[urcorner(cL), llcorner(cL)] shifted (1/2lS, 1/2lS);%(-1/2[xpart(urcorner(cL)), xpart(ulcorner(cL))], 0) shifted (1/2lS, 40/160cm);
                draw cL;
                for item within cL:
                    pN := pN + 1;
                    p[pN] := pathpart item;
                    po[pN] := pathOutline(p[pN], 1/8);
                    pb[pN] := generateBranchesTemplate(p[pN]);
                    o[pN] := 0;
                endfor;
            endfor;
            startFrom := 0;
            symMode := 0;
            numberOfIterations := 150;
        else:
            pN := 0;
            p0 := (-80/2mm,-15/2mm)--(-80/2mm, 15/2mm)--(80/2mm, 15/2mm)--(80/2mm, -15/2mm)--cycle;
            po0 := pathOutline(p0, 1/2);
            pb0 := generateBranchesTemplate(p0);
            o0 := 0;
            pN := 1;
            p1 := (fullcircle scaled 8mm);
            po1 := pathOutline(p1, 1/2);
            pb1 := generateBranchesTemplate(p1);
            o1 := 0;
            pN := 2;
            p2 := (fullcircle scaled 5mm) shifted (85/4mm, 0);
            po2 := pathOutline(p2, 1/2);
            pb2 := generateBranchesTemplate(p2);
            o2 := 0;
            pN := 3;
            p3 := (fullcircle scaled 5mm) shifted (-85/4mm, 0);
            po3 := pathOutline(p3, 1/2);
            pb3 := generateBranchesTemplate(p3);
            o3 := 0;
            startFrom := 1;
            symMode := 1;
            numberOfIterations := 200;
        fi;
        for nn := 0 step 1 until numberOfIterations:
            for i := startFrom step 1 until pN:
                if (cycle p[i]):
                    t := arctime uniformdeviate(arclength(p[i])) of p[i];
                else:
                    t := arctime (2mm + uniformdeviate(arclength(p[i])-4mm)) of p[i];
                fi;
                if checkBranch (i, t, 0) = 0:
                    if (uniformdeviate(10)>3) or (cycle p[i]):
                        if (o[i] = 0): cO := 1; else: cO := 0; fi;
                    else:
                        cO := o[i];
                    fi;
                    pb[i] := addBranch (i, t, 0);
                    if (cO = 0):
                        tp := q[cO] rotated (angle(direction t of p[i]) - 90);
                    else:
                        tp := q[cO] rotated (angle(direction t of p[i]) + 90);
                    fi;
                    s := findRightSize(tp, (point t of p[i]), 0, 1/2arclength(p[i]), i, pN, 10)(p);
                    if (s > 1/8cm):
                        pN := pN + 1;
                        p[pN] := tp scaled s shifted (point t of p[i]);
                        po[pN] := pathOutline(p[pN], 1/2);
                        pb[pN] := generateBranchesTemplate(p[pN]);
                        o[pN] := cO;
                        if(symMode = 1):
                            pN := pN + 1;
                            p[pN] := p[pN-1] rotated 180;
                            po[pN] := po[pN-1] rotated 180;
                            pb[pN] := pb[pN-1];
                            o[pN] := cO;
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
