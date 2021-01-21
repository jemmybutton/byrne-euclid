%    lettrine-generator 0.1.0a
%    MetaPost lettrines generator
%    Copyright 2020 Sergey Slyusarev
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

numeric lettrineSize, plateWidth, plateHeight, borderWidth;
lettrineSize := 15mm;
plateWidth := 76mm;
plateHeight := 15mm;
borderWidth := 1mm;

color lettrineBGcolor, lettrineFGcolor;
lettrineBGcolor := black;
lettrineFGcolor := white;

input "lettrinessizes.txt";

string lettrinesFile, lettrineLine, lettrineSymbol[];
numeric lettrineCount[], lettrineNumber;
picture lettrineImage, currentLetter;
lettrinesFile := "lettrineslist.txt";
lettrineNumber := 0;

input ornament_engine;

def writeOutPicture (expr fileName, lettrinePicture) =
    outputtemplate := fileName;
    beginfig(lettrineNumber);
        draw lettrinePicture;
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

    picture lettrinePicture;

    if (lettrineLine = "plate"):
        brIterations := 3;
        lfIterations := 3;
        symMode := 1;
        lettrinePicture := image(
            path plateFrame[];
            plateFrame1 := reverse((unitsquare shifted (-1/2,-1/2)) xscaled plateWidth) yscaled plateHeight;
            plateFrame2 := ((reverse(unitsquare) shifted (-1/2,-1/2)) xscaled (plateWidth - borderWidth)) yscaled (plateHeight - borderWidth);
            fill plateFrame1 withcolor (0, 0, 0);
            draw (0, 0) withcolor (0, 1, 0);
            draw subpath (0, 1) of plateFrame2 withcolor (1, 1, 0);
            draw subpath (1, 3/2) of plateFrame2 withcolor (1, 1, 0);
            draw subpath (3/2, 2) of plateFrame2 withcolor (1, 1, 0);
            draw subpath (2, 4) of plateFrame2 withcolor (1, 0, 0);
        );
    elseif (lettrineLine = "tile"):
        brIterations := 3;
        lfIterations := 3;
        symMode := 2;
        lettrinePicture := image(
            draw (0, 0) withcolor (0, 1, 0);
        );
    else:
        brIterations := 2;
        lfIterations := 2;
        symMode := 0;
        lettrinePicture := image(
            path lettrineFrame[];
            lettrineFrame1 := reverse(unitsquare) scaled lettrineSize;
            lettrineFrame2 := reverse(unitsquare) scaled (lettrineSize - borderWidth) shifted (1/2borderWidth, 1/2borderWidth);
            fill lettrineFrame1 withcolor (0, 0, 0);
            draw subpath(0, 1) of lettrineFrame2 withcolor (1, 1, 0);
            draw subpath(1, 2) of lettrineFrame2 withcolor (1, 1, 0);
            draw subpath(2, 3) of lettrineFrame2 withcolor (1, 1, 0);
            draw subpath(3, 4) of lettrineFrame2 withcolor (1, 1, 0);
            for i within TEX(lettrineLine):
                currentLetter := (glyph (ASCII textpart i) of (fontpart i)) scaled (1/35);
                currentLetter := currentLetter shifted -1/2[urcorner(currentLetter), llcorner(currentLetter)] shifted (1/2lettrineSize, 1/2lettrineSize);
                for letterPart within currentLetter:
                    draw pathpart letterPart withcolor (1, 1, 0);
                    if (colorpart letterPart) = 0:
                        fill pathpart letterPart withcolor (1, 1, 0);
                    else:
                        fill pathpart letterPart withcolor (0, 0, 0);
                    fi;
                endfor;
            endfor;
        );
    fi;

    writeOutPicture(lettrineLine & decimal(lettrineCount - 1) & ".mps",
        produceOrnamentImage(lettrinePicture, 1, lettrineBGcolor, lettrineFGcolor, symMode, brIterations, lfIterations)
        );

endfor;
end
