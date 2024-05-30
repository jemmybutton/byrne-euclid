\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{byrnebook}[2024/05/09]
\RequirePackage{kvoptions}
\DeclareStringOption[english]{booklanguage}
\ProcessKeyvalOptions*

\LoadClass{book}

\setcounter{tocdepth}{1}

\usepackage{geometry}
	\geometry{
 		a5paper,
		total={76mm,170mm},
		left=10mm,
		top=20mm,
		marginparwidth=54mm,
	}
\usepackage{byrne}
\usepackage[hidelinks]{hyperref}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{ccicons}
\usepackage{ebgaramond-maths}
\usepackage{graphicx}
\usepackage{ifthen}
\usepackage{marginnote}
\usepackage{xcolor}
\usepackage{array}
\usepackage{fancyhdr}
\usepackage{extramarks}
\usepackage{csquotes}
\usepackage{fontspec}
\usepackage{zref-clever}
\zcsetup{abbrev}
\usepackage[main=\byrnebook@booklanguage]{babel}

\pagestyle{fancy}
\fancyhead[LE,RO]{\thepage}
\fancyhead[CO,CE]{\rightmark}
\fancyhead[LO,RE]{}
\fancyfoot[LE,RO]{}
\fancyfoot[CO,CE]{}
\fancyfoot[LO,RE]{}
\renewcommand{\headrulewidth}{0pt}

\def\mpPre{u:=1cm;}

\DeclareOption{letters}{\def\mpPre{u:=1cm; textLabels := true;}}

\ProcessOptions\relax

\newdimen\LettrineSize
\newcount\LettrineScale
\newdimen\LettrinePadding
\newdimen\PlateWidth
\newdimen\PlateHeight
\newdimen\pictureIndent
\newdimen\PcH
\LettrineSize=1.5cm
\LettrineScale=300
\LettrinePadding=2mm
\PlateHeight=1.5cm
\PlateWidth=7.6cm
\def\LettrineTotalWidth{\dimexpr \LettrineSize + \LettrinePadding \relax}
\def\LettrineTotalHeight{\dimexpr \LettrineSize + \LettrinePadding \relax}
\def\LettrineTotalHeightMinusLine{\dimexpr \LettrineTotalHeight -0.8\baselineskip}
\def\defaultLettrineLines{4}
\pictureIndent=0cm
%\newdimen\oddpict
%\oddpict=\backspace
%\advance \oddpict by \textwidth
%\advance \oddpict by -\pictureIndent


\newwrite \lettrineslist
\openout \lettrineslist = lettrines/lettrineslist.txt\relax

\global\def\plateName{plate}

\def\putzero{0}

\def\sepSpace{\vskip 0.75\baselineskip}

\def\putLettrine#1{%
\write \lettrineslist{#1}%
\expandafter\ifx\csname ltrn#1\endcsname\relax%
	\global\expandafter\newcount\csname ltrn#1\endcsname\relax%
	\global\csname ltrn#1\endcsname 0%
\else%
	\global\expandafter\advance\csname ltrn#1\endcsname by 1%
\fi%
\IfFileExists{lettrines/#1\putzero.mps}%
	{\textdirection 0 \IfFileExists{lettrines/#1\the\csname ltrn#1\endcsname.mps}%
		{\ifx#1\plateName%
			\includegraphics[width=\PlateWidth]{lettrines/#1\the\csname ltrn#1\endcsname.mps}%
		\else%
			\includegraphics[height=\LettrineSize]{lettrines/#1\the\csname ltrn#1\endcsname.mps}%
		\fi}
		{\ifx#1\plateName%
			\includegraphics[width=\PlateWidth]{lettrines/#1\putzero.mps}%
		\else%
			\includegraphics[height=\LettrineSize]{lettrines/#1\putzero.mps}%
		\fi}}%
	{\IfFileExists{lettrines/#1.svg}%
		{\includegraphics[height=\LettrineSize]{lettrines/#1.svg}%
	}%
		{\IfFileExists{lettrines/#1.pdf}
			{\includegraphics[width=\LettrineSize,height=\LettrineSize]{lettrines/#1.pdf}%
			}
			{\ifx#1\plateName%
					\renderPlateOutlines{\plateName}{\the\PlateWidth}{\the\PlateHeight}					
				\else%
					\renderLettrineOutlines{#1}{\the\LettrineSize}{\the\LettrineScale}
				\fi}}}}

\def\renderLettrineOutlines#1#2#3{
	\expanded{\noexpand\begin{mplibcode}%
		beginfig(0);
		input byrne.mp;
		picture lettrineOutline, lettrinePicture;
		path lettrineFrame, lettrineBG;
		string filename;
		lettrineBG := reverse(fullsquare) scaled (#2);
		lettrineFrame := reverse(fullsquare) scaled (#2 - 2pt);
		fill lettrineBG withcolor black;
		draw lettrineFrame withcolor white;
		lettrineOutline := mpliboutlinetext("#1") scaled #3/100;
		lettrineOutline := lettrineOutline shifted -1/2[ulcorner(lettrineOutline), lrcorner(lettrineOutline)];
		lettrinePicture := textext("#1") scaled #3/100;
		lettrinePicture := lettrinePicture shifted -1/2[ulcorner(lettrinePicture), lrcorner(lettrinePicture)];
		draw lettrinePicture withcolor white;
		string pictureContents;
		pictureContents := "path givenOutline[];";
		pictureContents := pictureContents & "givenOutline0 := " & pathToString(lettrineBG) & "; ";
		pictureContents := pictureContents & "givenOutline1 := " & pathToString(lettrineFrame) & "; ";
		j := 1;
		for i within lettrineOutline:
			j := j + 1;
			pictureContents := pictureContents & "givenOutline" & decimal(j) & " := " & pathToString(pathpart i) & "; ";
		endfor;
		pictureContents := pictureContents & "numeric totalLines; totalLines := " & decimal(j) & ";";
		filename = "lettrines/lettrine_#1.mp";
		write pictureContents to filename;
		write EOF to filename;
		endfig;
	\noexpand\end{mplibcode}}
}
\def\renderPlateOutlines#1#2#3{
	\expanded{\noexpand\begin{mplibcode}%
		beginfig(0);
		input byrne.mp;
		path plateBG, plateFrame;
		string filename;
		plateBG := (reverse(fullsquare) xscaled (#2)) yscaled (#3);
		plateFrame := (reverse(fullsquare) xscaled (#2 - 2pt)) yscaled (#3 -2pt);
		fill plateBG withcolor black;
		draw plateFrame withcolor white;
		string pictureContents;
		pictureContents := "path givenOutline[];";
		pictureContents := pictureContents & "givenOutline0 := " & pathToString(plateBG) & "; ";
		pictureContents := pictureContents & "givenOutline1 := " & pathToString(plateFrame) & "; ";
		pictureContents := pictureContents & "givenOutline2 := " & pathToString((0,0)) & "; ";
		pictureContents := pictureContents & "numeric totalLines; totalLines := 2;";
		filename = "lettrines/lettrine_#1.mp";
		write pictureContents to filename;
		write EOF to filename;
		endfig;
	\noexpand\end{mplibcode}}
}		

% This thing removes space between an initial and the letter after it, if no space is needed
\directlua{
   formatting = formatting or {}
   function formatting.dedent (str)
    if string.sub(str, 0, 1) ==  " " then
      tex.print(str)
    else
      tex.print("\\,\\hskip -0.5\\LettrinePadding " .. str)
    end
  end
}

% This one is used standalone, e.g. in the Introduction
\def\regularLettrine#1#2{\initialIndentation{7}%
\noindent{\raisebox{0pt}[0pt][0pt]{\hskip-\LettrineSize\hskip-5pt\raisebox{0.5\baselineskip}{\raisebox{-\LettrineSize}{\putLettrine{#1}}}\hskip2pt}\textsc{\directlua{formatting.dedent([==[#2]==])}}}}

%\def\problem#1#2#3{%
%\vskip -\LettrineTotalHeight
%\hskip -\LettrineTotalWidth \hskip -\parindent \offset[y=\LettrineTotalHeightMinusLine,x=0pt]{\hbox{\putLettrine{#1}}}{\sc\hskip\LettrinePadding \ctxlua{formatting.dedent([==[#2]==])}\ \it #3} \vskip \baselineskip
%}

\newdimen\vPos
\newcommand{\problem}[4][4]{%
\createNewHypothesisLabel%
\pictureIndent=0cm%
\vPos=\pagetotal%
\initialIndentation[#1]{7}%
%\vbox{\hbox{\putLettrine{#2}}\vskip -\LettrineSize\vskip -0.5\baselineskip}%
\noindent{\raisebox{0pt}[0pt][0pt]{\hskip-\LettrineSize\hskip-5pt\raisebox{0.5\baselineskip}{\raisebox{-\LettrineSize}{\putLettrine{#2}}}\hskip2pt}\textsc{\directlua{formatting.dedent([==[#3]==])}}}\textit{ #4}%
\advance\vPos by -\pagetotal%
\advance\vPos by 3\baselineskip%
\ifnum\vPos>0%
\vskip \vPos%
\fi%
%\vskip 0.5\baselineskip%
\resetInitialIndentation%
}

\newdimen\pictureWithLettrineLineLength
\newdimen\pictureWithLettrineIndent
\newdimen\pictureOnlyLineLength
\newdimen\pictureWithLettrineLineLength
\newcount\Y
\newcount\Yy
\newcount\X
\X=0
\newcount\numOfIndLines

\newif\ifinsideII
\insideIIfalse

\newcount\linesofar

\toks0=\expandafter{\the\everypar}

\def\resetInitialIndentation{\parshape=0\global\numOfIndLines=0\global\def\par{\endgraf}}%\everypar=\expandafter{\the\toks0}\global\insideIIfalse}

\newcommand{\initialIndentation}[2][4]{
	\global\toks0=\expandafter{\the\everypar}
		\def\lettrineLines{#1}
	\ifinsideII\resetInitialIndentation\fi
	\global\insideIItrue
	\ \vskip 0pt
 %https://books.google.com/books?id=iDb2BwAAQBAJ&pg=PA107&lpg=PA107&dq=tex+parshape+paragraphs&source=bl&ots=GmFvQnIUr7&sig=oJ-mtVEwOttepWpGi2BABemAMWw&hl=en&sa=X&ved=0ahUKEwjxrbPk-uXKAhVClB4KHSxUBqwQ6AEIQTAF#v=onepage&q=tex%20parshape%20paragraphs&f=false
	\linesofar=0
	\global\numOfIndLines=#2
	\def\par{{\endgraf\global\linesofar=\prevgraf}}
	\everypar={\ifnum\linesofar<\numOfIndLines\prevgraf=\linesofar\else\resetInitialIndentation\fi} %
	\pictureOnlyLineLength=\textwidth
	\pictureWithLettrineLineLength=\textwidth
	\advance \pictureOnlyLineLength by -\pictureIndent
	\ifthenelse{\isodd{\thepage}}{
		\pictureWithLettrineLineLength=\pictureOnlyLineLength
		\advance \pictureWithLettrineLineLength by -\LettrineTotalWidth
		\def\partindent{0cm \pictureOnlyLineLength}
		\ifnum\textdirection=0
			\def\doubleindent{\LettrineTotalWidth \pictureWithLettrineLineLength}
		\fi
		\ifnum\textdirection=1
			\def\doubleindent{0cm \pictureWithLettrineLineLength}
		\fi
	}{
		\pictureWithLettrineIndent=\pictureIndent
		\advance \pictureWithLettrineIndent by \LettrineTotalWidth
		\pictureWithLettrineLineLength=\pictureOnlyLineLength
		\advance \pictureWithLettrineLineLength by -\LettrineTotalWidth
		\def\partindent{\pictureIndent \pictureOnlyLineLength}
		\ifnum\textdirection=0
			\def\doubleindent{\pictureWithLettrineIndent \pictureWithLettrineLineLength}
		\fi
		\ifnum\textdirection=1
			\def\doubleindent{0cm \pictureWithLettrineLineLength}
		\fi
	}
	\def\preinitindent{}
	\Yy=\lettrineLines
	\advance \Yy by 1 
	\Y=\lettrineLines
	\loop 
	\expandafter\def\expandafter\preinitindent\expandafter{\preinitindent\doubleindent}
	\advance \Y by -1 
	\ifnum \Y>0
	\repeat
	\def\initindent{\preinitindent}
	\global\X=#2
	\ifnum \X>\Yy
		\advance \X by -\lettrineLines 
		\loop 
			\expandafter\def\expandafter\initindent\expandafter{\initindent\partindent}
		\advance \X by -1 
		\ifnum \X>1
		\repeat
	\fi
	\parshape=#2
	\initindent
	0cm \textwidth
}

\newcounter {construction}
\newcounter {hypothesis}

\newcommand{\generateLabel}[2]{\label{#1#2}}

\newcommand{\createNewConstructionLabel}{\refstepcounter{construction}\generateLabel{construction}{\arabic{construction}}}
\def\constref{construction\arabic{construction}}

\newcommand{\createNewHypothesisLabel}{\refstepcounter{hypothesis}\generateLabel{hypothesis}{\arabic{hypothesis}}}
\def\hypref{hypothesis\arabic{hypothesis}}

\newcommand{\drawCurrentPictureInMargin}[1][center]{%
	\createNewConstructionLabel%
	\def\tmpalignment{#1}%
	\def\tmpmiddle{center}%
	\def\tmpinside{inside}%
	\ifx\tmpalignment\tmpmiddle%
	\marginnote{~\hfill\drawCurrentPicture\hfill~}%
	\fi%
	\ifx\tmpalignment\tmpinside%
	\marginnote{~\drawCurrentPicture~}%
	\fi%
}




\def\qedNB{\hfill\qedstr\vskip 10pt}
\def\qed{\qedNB\vfill\pagebreak}
\def\qefNB{\hfill\qefstr\vskip 10pt}
\def\qef{\qefNB\vfill\pagebreak}



\def\symb#1{\noindent{#1}\quad}

% tabular horizontal spacing
\setlength\tabcolsep{2pt}

% increased interline space
\renewcommand{\baselinestretch}{1.1} 

%
% Colors
%

\definecolor{byred}{rgb}{0.85, 0.3, 0.1}
\definecolor{byblue}{rgb}{0.15, 0.35, 0.6}
\definecolor{byyellow}{rgb}{0.95, 0.7, 0.1}
\definecolor{byblack}{rgb}{0, 0, 0}
\definecolor{bygrey}{rgb}{.8, .8, .8}

%
%
% Overriding standard book stuff below
%
%

\makeatletter

%
% Redefining parts
%

\def\@beginpart{~\vskip-2\baselineskip\noindent\putLettrine{\plateName}\vskip3\baselineskip}
\def\@parttextstyle#1{\noindent{~\hfill{\Large #1}\hfill~}}
\def\@endpart{\vskip\baselineskip}

\def\@part[#1]#2{%
    \ifnum \c@secnumdepth >-2\relax%
      \refstepcounter{part}%
      \addcontentsline{toc}{part}{\thepart\hspace{1em}#1}%
    \else%
      \addcontentsline{toc}{part}{#1}%
    \fi%
    \markboth{}{}%
    \@beginpart%
    \@parttextstyle{\bookString\ \thepart}%
    \@endpart}
    
\def\@spart#1{%
    \@beginpart%
    \@parttextstyle{#1}%
    \@endpart}

\renewcommand\part{%
  \if@openright
    \cleardoublepage
  \else
    \clearpage
  \fi
  \thispagestyle{plain}%
    %\@tempswafalse
  %\null\vfil
  \secdef\@part\@spart}
    
%
% Redefining chapters
%

\renewcommand\chapter{%\if@openright\cleardoublepage\else\clearpage\fi
	\newdimen\@minpageheight
	\@minpageheight = 0.5\pageheight
	\ifnum\pagetotal>\@minpageheight\clearpage\fi
                    %\thispagestyle{plain}%
                    \global\@topnum\z@
                    \@afterindentfalse
                    \secdef\@chapter\@schapter}

\def\@beginchapter{\removelastskip\vskip2\baselineskip}
\def\@chaptertextstyle#1{\noindent{~\hfill{\Large #1}\hfill~}}
\def\@endchapter{\vskip\baselineskip}

\def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne
                       \if@mainmatter
                         \refstepcounter{chapter}%
                         \typeout{\@chapapp\space\thechapter.}%
                         \addcontentsline{toc}{chapter}%
                                   {\protect\numberline{\thechapter}#1}%
                       \else
                         \addcontentsline{toc}{chapter}{#1}%
                       \fi
                    \else
                      \addcontentsline{toc}{chapter}{#1}%
                    \fi
                    \chaptermark{#1}%
                    \addtocontents{lof}{\protect\addvspace{10\p@}}%
                    \addtocontents{lot}{\protect\addvspace{10\p@}}%
                    \if@twocolumn
                      \@topnewpage[\@makechapterhead{#2}]%
                    \else
                      \@makechapterhead{#2}%
                      \@afterheading
                    \fi}
                    
\def\@makechapterhead#1{%
  \@beginchapter
  {\parindent \z@ \raggedright \normalfont
    \ifnum \c@secnumdepth >\m@ne
      \if@mainmatter
        \huge\bfseries \@chapapp\space \thechapter
        \par\nobreak
        \vskip 20\p@
      \fi
    \fi
    \interlinepenalty\@M
   \@chaptertextstyle{#1}% \Huge \bfseries #1\par\nobreak
   \@endchapter
  }}
  
\def\@schapter#1{\if@twocolumn
                   \@topnewpage[\@makeschapterhead{#1}]%
                 \else
                   \@makeschapterhead{#1}%
                   \@afterheading
                 \fi}
                 
\def\@makeschapterhead#1{%
  \@beginchapter
  {\parindent \z@ \raggedright
    \normalfont
    \interlinepenalty\@M
   \@chaptertextstyle{#1}
    \@endchapter
  }}
  
%
% New section types
%

\newcounter {definition}[part]
\newcounter {definitionAZ}[part]
\newcounter {axiom}[part]
\newcounter {postulate}[part]
\newcounter {proposition}[part]
\newcounter {propositionAZ}[part]
\newcounter {subproposition}[proposition]
\renewcommand\theaxiom {\thepart.\@arabic\c@axiom}
\renewcommand\thedefinition {\thepart.\@arabic\c@definition}
\renewcommand\thedefinitionAZ {\thepart.\@Alph\c@definitionAZ}
\renewcommand\thepostulate {\thepart.\@arabic\c@postulate}
\renewcommand\theproposition {\thepart.\@arabic\c@proposition}
\renewcommand\thepropositionAZ {\thepart.\@Alph\c@propositionAZ}
\renewcommand\theconstruction {\conststr}
\renewcommand\thehypothesis {\hypstr}
\renewcommand\thesubproposition {}

\newcommand{\axiommark}[1]{\markboth{#1}{#1}}%
\newcommand{\definitionmark}[1]{\markboth{#1}{#1}}%
\newcommand{\definitionAZmark}[1]{\markboth{#1}{#1}}%
\newcommand{\postulatemark}[1]{\markboth{#1}{#1}}%
\newcommand{\propositionmark}[1]{\markboth{#1}{#1}}%
\newcommand{\propositionAZmark}[1]{\markboth{#1}{#1}}%
\newcommand{\subpropositionmark}[1]{}

\newcommand\startaxiom{\@startsection{axiom}{1}{\z@}%
                                   {0.5\baselineskip}%
                                   {0.25\baselineskip}%
                                   {\large\centering}}

\newcommand\startdefinition[2][-1]{%
			\ifnum #1 = -1 \else%
			\setcounter{definition}{#1}%
			\addtocounter{definition}{-1}%
			\fi%
			\@startsection{definition}{1}{\z@}%
                                   {0.5\baselineskip}%
                                   {0.25\baselineskip}%
                                   {\large\centering}%
                                   {#2}}

\newcommand\startdefinitionAZ[2][-1]{
			\ifnum #1 = -1 \else%
			\setcounter{definitionAZ}{#1}%
			\addtocounter{definitionAZ}{-1}%
			\fi%
			\@startsection{definitionAZ}{1}{\z@}%
                                   {\baselineskip}%
                                   {\baselineskip}%
                                   {\large\centering}%
                                   {#2}}

\newcommand\startpostulate{\@startsection{postulate}{1}{\z@}%
                                   {0.5\baselineskip}%
                                   {0.25\baselineskip}%
                                   {\large\centering}}

%\newcommand\startproblem{\@startsection{proposition}{1}{\z@}%
%                                   {\baselineskip}%
%                                   {\baselineskip}%
%                                   {\large\centering}}
                                   
%\newcommand\starttheorem{\@startsection{proposition}{1}{\z@}%
%                                   {\baselineskip}%
%                                   {\baselineskip}%
%                                   {\large\centering}}
                                   
\newcommand{\startproblem}[2][-1]{\prepropositionskip\startpropositiondiv[#1]{#2}}
                                   
\newcommand{\starttheorem}[2][-1]{\prepropositionskip\startpropositiondiv[#1]{#2}}

\newcommand{\startproblemAZ}[2][-1]{\prepropositionskip\startpropositionAZdiv[#1]{#2}}
                                   
\newcommand{\starttheoremAZ}[2][-1]{\prepropositionskip\startpropositionAZdiv[#1]{#2}}

\newcommand{\prepropositionskip}{%
	\ifnum\pagetotal>0%
		\def\tmpbeforeskip{\baselineskip}%
		\def\tmpafterskip{\baselineskip}%
		\def\tmpstyle{\large\centering}%
	\else%
		~\vskip -3\baselineskip~
		\def\tmpbeforeskip{0pt}%
		\def\tmpafterskip{0pt}%
		\def\tmpstyle{\phantom}%
	\fi%
	}

\newcommand\startpropositiondiv[2][]{
			\ifnum #1 = -1 \else%
			\setcounter{proposition}{#1}%
			\addtocounter{proposition}{-1}%
			\fi%
			\@startsection{proposition}{1}{\z@}%
                                   {\tmpbeforeskip}%
                                   {\tmpafterskip}%
                                   {\tmpstyle}
                                   {#2}}
           
\newcommand\startpropositionAZdiv[2][0]{
			\ifnum #1 = -1 \else%
			\setcounter{propositionAZ}{#1}%
			\addtocounter{propositionAZ}{-1}%
			\fi%
			\@startsection{propositionAZ}{1}{\z@}%
                                   {\tmpbeforeskip}%
                                   {\tmpafterskip}%
                                   {\tmpstyle}
                                   {#2}}

\newcommand\startsubproposition{\@startsection{subproposition}{2}{\z@}%
                                   {\baselineskip}%
                                   {\baselineskip}%
                                   {\large\centering}}

\newcommand*\l@definition{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@definitionAZ{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@postulate{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@axiom{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@proposition{\@dottedtocline{1}{1.5em}{2.3em}}
\newcommand*\l@subproposition{\@dottedtocline{2}{1.5em}{2.3em}}
\newcommand*\l@propositionAZ{\@dottedtocline{1}{1.5em}{2.3em}}

%
% Other
%

\newcommand\byref[1]{(\zcref{#1})}
\newcommand\charspacing[2]{\addfontfeature{LetterSpace=#1} #2 \addfontfeature{LetterSpace=0}}

\emergencystretch 3em 

\newcommand\margincomment[1]{\marginnote{\footnotesize #1}}

%
% Localizables
%

\def\qedstr{Q. E. D.}
\def\qefstr{Q. E. F.}
\def\hypstr{hyp.}
\def\conststr{const.}

\def\inpropstr{pr.}
\def\inpoststr{post.}
\def\indefstr{def.}
\def\inaxstr{ax.}

\def\bookString{Book}

\zcLanguageSetup{english}{	
	type = axiom , 
	  Name-sg = Axiom ,
	  name-sg = axiom ,
	  Name-pl = Axioms ,
	  name-pl = axioms ,
	  Name-sg-ab = Ax. ,
	  name-sg-ab = ax. ,
	  Name-pl-ab = Ax. ,
	  name-pl-ab = ax. ,
	type = definition , 
	  Name-sg = Definition ,
	  name-sg = definition ,
	  Name-pl = Definitions ,
	  name-pl = definitions ,
	  Name-sg-ab = Def. ,
	  name-sg-ab = def. ,
	  Name-pl-ab = Def. ,
	  name-pl-ab = def. ,
	type = postulate , 
	  Name-sg = Postulate ,
	  name-sg = postulate ,
	  Name-pl = Postulate ,
	  name-pl = postulate ,
	  Name-sg-ab = Post. ,
	  name-sg-ab = post. ,
	  Name-pl-ab = Post. ,
	  name-pl-ab = post. ,
	type = proposition , 
	  Name-sg = Proposition ,
	  name-sg = proposition ,
	  Name-pl = Propositions ,
	  name-pl = propositions ,
	  Name-sg-ab = Prop. ,
	  name-sg-ab = prop. ,
	  Name-pl-ab = Prop. ,
	  name-pl-ab = prop. ,
	}

\zcLanguageSetup{russian}{	
	type = axiom , 
	  gender = f ,
	  case = n ,
	    Name-sg = Аксиома ,
	    name-sg = аксиома ,
	    Name-pl = Аксиомы ,
	    name-pl = аксиомы ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	  case = a ,
	    Name-sg = Аксиому ,
	    name-sg = аксиому ,
	    Name-pl = Аксиомы ,
	    name-pl = аксиомы ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	  case = g ,
	    Name-sg = Аксиомы ,
	    name-sg = аксиомы ,
	    Name-pl = Аксиом ,
	    name-pl = аксиом ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	  case = d ,
	    Name-sg = Аксиоме ,
	    name-sg = аксиоме ,
	    Name-pl = Аксиомам ,
	    name-pl = аксиомам ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	  case = i ,
	    Name-sg = Аксиомой ,
	    name-sg = аксиомой ,
	    Name-pl = Аксиомами ,
	    name-pl = аксиомами ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	  case = p ,
	    Name-sg = Аксиоме ,
	    name-sg = аксиоме ,
	    Name-pl = Аксиомах ,
	    name-pl = аксиомах ,
	    Name-sg-ab = Акс. ,
	    name-sg-ab = акс. ,
	    Name-pl-ab =Акс. ,
	    name-pl-ab = акс. ,
	type = definition , 
	  gender = f ,
	  case = n ,
	    Name-sg = Определение ,
	    name-sg = определение ,
	    Name-pl = Определения ,
	    name-pl = определения ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	  case = a ,
	    Name-sg = Определение ,
	    name-sg = определение ,
	    Name-pl = Определения ,
	    name-pl = определения ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	  case = g ,
	    Name-sg = Определения ,
	    name-sg = определения ,
	    Name-pl = Определений ,
	    name-pl = определений ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	  case = d ,
	    Name-sg = Определению ,
	    name-sg = определению ,
	    Name-pl = Определениям ,
	    name-pl = определениям ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	  case = i ,
	    Name-sg = Определением ,
	    name-sg = определением ,
	    Name-pl = Определениями ,
	    name-pl = определениями ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	  case = p ,
	    Name-sg = Определении ,
	    name-sg = определении ,
	    Name-pl = Определениях ,
	    name-pl = определениях ,
	    Name-sg-ab = Опр. ,
	    name-sg-ab = опр. ,
	    Name-pl-ab =Опр. ,
	    name-pl-ab = опр. ,
	type = postulate , 
	  gender = m ,
	  case = n ,
	    Name-sg = Постулат ,
	    name-sg = постулат ,
	    Name-pl = Постулаты ,
	    name-pl = постулаты ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	  case = a ,
	    Name-sg = Постулат ,
	    name-sg = постулат ,
	    Name-pl = Постулаты ,
	    name-pl = постулаты ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	  case = g ,
	    Name-sg = Постулата ,
	    name-sg = постулата ,
	    Name-pl = Постулатов ,
	    name-pl = постулатов ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	  case = d ,
	    Name-sg = Постулату ,
	    name-sg = постулату ,
	    Name-pl = Постулатам ,
	    name-pl = постулатам ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	  case = i ,
	    Name-sg = Постулатом ,
	    name-sg = постулатом ,
	    Name-pl = Постулатами ,
	    name-pl = постулатами ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	  case = p ,
	    Name-sg = Постулате ,
	    name-sg = постулате ,
	    Name-pl = Постулатах ,
	    name-pl = постулатах ,
	    Name-sg-ab = Пост. ,
	    name-sg-ab = пост. ,
	    Name-pl-ab =Пост. ,
	    name-pl-ab = пост. ,
	type = proposition , 
	  gender = n ,
	  case = n ,
	    Name-sg = Предложение ,
	    name-sg = предложение ,
	    Name-pl = Предложения ,
	    name-pl = предложения ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	  case = a ,
	    Name-sg = Предложение ,
	    name-sg = предложение ,
	    Name-pl = Предложения ,
	    name-pl = предложения ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	  case = g ,
	    Name-sg = Предложения ,
	    name-sg = предложения ,
	    Name-pl = Предложений ,
	    name-pl = предложений ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	  case = d ,
	    Name-sg = Предложению ,
	    name-sg = предложению ,
	    Name-pl = Предложениям ,
	    name-pl = предложениям ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	  case = i ,
	    Name-sg = Предложением ,
	    name-sg = предложением ,
	    Name-pl = Предложениями ,
	    name-pl = предложениями ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	  case = p ,
	    Name-sg = Предложении ,
	    name-sg = предложении ,
	    Name-pl = Предложениях ,
	    name-pl = предложениях ,
	    Name-sg-ab = Пр. ,
	    name-sg-ab = пр. ,
	    Name-pl-ab = Пр. ,
	    name-pl-ab = пр. ,
	}


\zcRefTypeSetup{hypothesis}{
  Name-sg =  ,
  name-sg =  ,
  Name-pl =  ,
  name-pl =  ,
}

\zcRefTypeSetup{construction}{
  Name-sg =  ,
  name-sg =  ,
  Name-pl =  ,
  name-pl =  ,
}

\AtBeginDocument{
  \@ifpackagewith{babel}{russian}{%
	\def\qedstr{Ч. Т. Д.}%
	\def\qefstr{Ч. Т. Д.}%
	\def\hypstr{гип.}%
	\def\conststr{постр.}%
	\def\inpropstr{пр.}%
	\def\inpoststr{пост.}%
	\def\indefstr{опр.}%
	\def\inaxstr{акс.}%
	\def\bookString{Книга}%
  }{}
}

\makeatother