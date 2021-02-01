%    lettrine-generator 0.2.0a
%    MetaPost lettrines generator
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

input ornament_engine;

outputformat := "eps";

color lettrineBGcolor, lettrineFGcolor;
lettrineBGcolor := black;
lettrineFGcolor := white;

string lettrinesFile, lettrineLine, lettrineSymbol[];
numeric lettrineCount[], lettrineNumber;
picture lettrineImage, currentLetter;
lettrinesFile := "lettrineslist.txt";
lettrineNumber := 0;

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
        lfIterations := 2;
        symMode := 1;
        lettrinePicture := image(
            scantokens(readfrom("lettrine_" & lettrineLine & ".mp"));
            closefrom("lettrine_" & lettrineLine & ".mp");
            fill givenOutline0 withcolor (0,0,0);
            draw subpath (0,2) of givenOutline1 withcolor (1,1,0);
            draw subpath (2,4) of givenOutline1 withcolor (1,0,0);
            for i := 2 step 1 until totalLines:
                draw givenOutline[i] withcolor (1,1,0);
                if cycle givenOutline[i]:
                    if (turningnumber (givenOutline[i]) > 0):
                        fill givenOutline[i] withcolor (1,0,0);
                    else:
                        fill givenOutline[i] withcolor (0,0,0);
                    fi;
                fi;
            endfor;
        );
    elseif (lettrineLine = "tile"):
        brIterations := 3;
        lfIterations := 2;
        symMode := 2;
        lettrinePicture := image(
            draw (0, 0) withcolor (0, 1, 0);
        );
    else:
        brIterations := 2;
        lfIterations := 2;
        symMode := 0;
        lettrinePicture := image(
            scantokens(readfrom("lettrine_" & lettrineLine & ".mp"));
            closefrom("lettrine_" & lettrineLine & ".mp");
            fill givenOutline0 withcolor (0,0,0);
            draw subpath (0,1) of givenOutline1 withcolor (1,1,0);
            draw subpath (1,2) of givenOutline1 withcolor (1,1,0);
            draw subpath (2,3) of givenOutline1 withcolor (1,1,0);
            draw subpath (3,4) of givenOutline1 withcolor (1,1,0);
            for i := 2 step 1 until totalLines:
                draw givenOutline[i] withcolor (1,1,0);
                if cycle givenOutline[i]:
                    if (turningnumber (givenOutline[i]) > 0):
                        fill givenOutline[i] withcolor (1,0,0);
                    else:
                        fill givenOutline[i] withcolor (0,0,0);
                    fi;
                fi;
            endfor;
        );
    fi;

    writeOutPicture(lettrineLine & decimal(lettrineCount - 1) & ".mps",
        produceOrnamentImage(lettrinePicture, 1, lettrineBGcolor, lettrineFGcolor, symMode, brIterations, lfIterations)
        );

endfor;
end
