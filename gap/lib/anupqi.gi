#############################################################################
####
##
#W  anupqi.gi           ANUPQ Share Package                       Greg Gamble
##
##  This file installs interactive functions that execute individual pq  menu
##  options.
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqi_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  PQ_AUT_INPUT( <datarec>, <G> : <options> ) . . . . . . automorphism input
##
##  inputs automorphism data for `<datarec>.group' given by <options> to  the
##  `pq' binary derived from the pc group  <G>  (used  in  option  1  of  the
##  $p$-Group Generation menu and option 2 of the Standard Presentation menu).
##
InstallGlobalFunction( PQ_AUT_INPUT, function( datarec, G )
local rank, automorphisms, gens, i, j, aut, g, exponents;
  if VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec) then
    automorphisms := Pcgs( AutomorphismGroup(G) );
    if automorphisms = fail then
      Error( "option \"PcgsAutomorphisms\" used with insoluble",
             "automorphism group\n" );
    fi;
    automorphisms := Reversed( automorphisms );
  else
    automorphisms := GeneratorsOfGroup( AutomorphismGroup( G ) );
  fi;

  rank := RankPGroup( G );
  gens := PcgsPCentralSeriesPGroup( G );
  ToPQ(datarec, [ Length(automorphisms), "  #number of automorphisms" ]);
  for i in [1..Length(automorphisms)] do
    aut := automorphisms[i];
    for j in [1..Length(gens)] do
      g := gens[j];
      exponents := Flat( List( ExponentsOfPcElement( gens, Image( aut, g ) ),
                               e -> [ String(e), " "] ) );
      ToPQ(datarec, 
           [ exponents, " #gen'r exp'ts of im(aut ", i, ", gen ", j, ")" ]);
    od;
  od;
end );

#############################################################################
##
#F  PQ_PC_PRESENTATION( <datarec>, <menu> ) . . . . . .  p-Q/SP menu option 1
##
##  inputs  data  given  by  <options>  to  the   `pq'   binary   for   group
##  `<datarec>.group' to compute a  pc  presentation  (do  option  1  of  the
##  relevant menu) according to the  <menu>  menu,  where  <menu>  is  either
##  `"pQ"' (main $p$-Quotient menu) or `"SP' (Standard Presentation menu).
##
InstallGlobalFunction( PQ_PC_PRESENTATION, function( datarec, menu )
local gens, rels, pcp, p, pcgs, len, strp, i, j, Rel;

  pcp := Concatenation( menu, "pcp");
  if datarec.calltype = "interactive" and IsBound(datarec.(pcp)) and
     ForAll( REC_NAMES( datarec.(pcp) ), 
             optname -> ValueOption(optname) 
                        in [fail, datarec.(pcp).(optname)] ) then
     # only do it in the interactive case if it hasn't already been done
     # by checking whether options stored in `<datarec>.(<pcp>)' differ 
     # from those of a previous call ... if a check of an option value 
     # returns `fail' it is assumed the user intended the previous value
     # stored in `<datarec>.(<pcp>)' (this is potentially problematic for 
     # boolean options, to reverse a previous `true', `false' must be
     # explicitly set for the option on the subsequent function call)
        
     Info(InfoANUPQ, 1, "Using previously computed (", menu, 
                        ") pc presentation.");
     return;
  fi;

  PQ_MENU(datarec, menu);
  datarec.(pcp) := rec(); # options processed are stored here

  # Option 1 of p-Quotient/Standard Presentation Menu: defining the group
  ToPQk(datarec, ["1  #define group"]);
  p := VALUE_PQ_OPTION("Prime", fail, datarec.(pcp));
  ToPQk(datarec, ["prime ",    p]);
  ToPQk(datarec, ["class ",    VALUE_PQ_OPTION("ClassBound", fail, 
                                                              datarec.(pcp))]);
  ToPQk(datarec, ["exponent ", VALUE_PQ_OPTION("Exponent", 0, datarec.(pcp))]);
  if VALUE_PQ_OPTION( "Metabelian", false, datarec.(pcp) ) = true then
    ToPQk(datarec, [ "metabelian" ]);
  fi;
  ToPQk(datarec, ["output ", VALUE_PQ_OPTION("OutputLevel", 1, datarec.(pcp))]);

  if IsFpGroup(datarec.group) then
    gens := FreeGeneratorsOfFpGroup(datarec.group);
    rels := Filtered( RelatorsOfFpGroup(datarec.group), rel -> not IsOne(rel) );
  else
    pcgs := PcgsPCentralSeriesPGroup(datarec.group);
    len  := Length(pcgs);
    gens := List( [1..len], i -> Concatenation( "g", String(i) ) );
    strp := String(p);

    Rel := function(elt, eltstr)
      local rel, expts, factors;

      rel := eltstr;
      expts := ExponentsOfPcElement( pcgs, elt );
      if ForAny( expts, x -> x<>0 )  then
        factors 
            := Filtered(
                   List( [1..len], 
                         function(i)
                           if expts[i] = 0 then
                             return "";
                           fi;
                           return Concatenation(gens[i], "^", String(expts[i]));
                         end ),
                   factor -> factor <> "");
        Append(rel, "=");
        Append(rel, JoinStringsWithSeparator(factors));
      fi;
      return rel;
    end;

    rels := List( [1..len], 
                  i -> Rel( pcgs[i]^p, Concatenation(gens[i], "^", strp) ) );
    for i in [1..len] do
      for j in [1..i-1]  do
        Add(rels, Rel( Comm( pcgs[i], pcgs[j] ), 
                       Concatenation("[", gens[i], ",", gens[j], "]") ));
      od;
    od;
  fi;
  gens := JoinStringsWithSeparator( List(gens, String) );
  rels := JoinStringsWithSeparator( List(rels, String) );
  ToPQk(datarec, ["generators { ", gens, " }"]);
  ToPQ (datarec, ["relations  { ", rels, " };"]);
end );

#############################################################################
##
#F  PqPcPresentation( <i> : <options> ) . . user version of p-Q menu option 1
#F  PqPcPresentation( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data  given
##  by <options> for the group of  that  process  so  that  the  `pq'  binary
##  computes a pc presentation, where the group of a process is the one given
##  as first argument when `PqStart' was called to initiate that process (for
##  process <i> the group is stored as `ANUPQData.io[<i>].group').
##
##  *Note:* For those  familiar  with  the  `pq'  binary,  `PqPcPresentation'
##  performs option 1 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqPcPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PC_PRESENTATION( datarec, "pQ" );
end );

#############################################################################
##
#F  PQ_SAVE_PC_PRESENTATION( <datarec>, <filename> ) . . .  p-Q menu option 2
##
##  directs the `pq' binary to save the pc presentation  previously  computed
##  for  `<datarec>.group'  to  <filename>  using  option  2  of   the   main
##  $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SAVE_PC_PRESENTATION, function( datarec, filename )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ "2  #save pc presentation to file" ]);
  ToPQ(datarec, [ filename, "  #filename" ]);
end );

#############################################################################
##
#F  PqSavePcPresentation( <i>, <filename> ) . .  user ver. of p-Q menu opt. 2
#F  PqSavePcPresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to save the pc presentation previously computed for the  group  of
##  that process, where the group of a process is  the  one  given  as  first
##  argument when `PqStart' was called to initiate that process.
##
##  *Note:* For those familiar with the `pq'  binary,  `PqSavePcPresentation'
##  performs option 2 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqSavePcPresentation, function( arg )
local datarec, filename;
  if 0 = Length(arg) or Length(arg) > 2 then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  filename := arg[Length(arg)];
  if not IsString( filename ) then
    Error( "argument <filename> must be a string\n" );
  fi;
  arg := arg{[1..Length(arg) - 1]};
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SAVE_PC_PRESENTATION( datarec, filename );
end );

#############################################################################
##
#F  PQ_RESTORE_PC_PRESENTATION( <datarec>, <filename> ) . . p-Q menu option 3
##
##  directs the `pq' binary to restore the pc presentation  previously  saved
##  to <filename> using option 3 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PQ_RESTORE_PC_PRESENTATION, function( datarec, filename )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ "3  #restore pc presentation from file" ]);
  ToPQ(datarec, [ filename, "  #filename" ]);
end );

#############################################################################
##
#F  PqRestorePcPresentation( <i>, <filename> ) . user ver. of p-Q menu opt. 3
#F  PqRestorePcPresentation( <filename> )
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to restore the pc presentation previously saved to <filename>  for
##  the group of that process, where the group of a process is the one  given
##  as first argument when `PqStart' was called to initiate that process.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqRestorePcPresentation'
##  performs option 3 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqRestorePcPresentation, function( arg )
local datarec, filename;
  if 0 = Length(arg) or Length(arg) > 2 then
    Error( "expected 1 or 2 arguments\n" );
  fi;
  filename := arg[Length(arg)];
  if not IsString( filename ) then
    Error( "argument <filename> must be a string\n" );
  fi;
  arg := arg{[1..Length(arg) - 1]};
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_RESTORE_PC_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_DISPLAY_PC_PRESENTATION( <datarec> ) . . . . . . . . p-Q menu option 4
##
##  directs the  `pq'  binary  to  display  the  pc  presentation  previously
##  computed  (by   `PQ_PC_PRESENTATION')   or   restored   from   file   (by
##  `PQ_RESTORE_PC_PRESENTATION') using option 4  of  the  main  $p$-Quotient
##  menu.
##
InstallGlobalFunction( PQ_DISPLAY_PC_PRESENTATION, function( datarec )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ "4  #display pc presentation from file" ]);
end );

#############################################################################
##
#F  PqDisplayPcPresentation( <i> ) . . . .  user version of p-Q menu option 4
#F  PqDisplayPcPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary  to  display  the  pc   presentation   previously   computed   (by
##  `PqPcPresentation'; see~"PqPcPresentation") or  restored  from  file  (by
##  `PqRestorePcPresentation'; see~"PqRestorePcPresentation") for  the  group
##  of that process, where the group of a process is the one given  as  first
##  argument when `PqStart' was called to initiate that process. To  set  the
##  amount of  information  this  command  displays  you  may  wish  to  call
##  `PqSetPrintLevel' first (see~"PqSetPrintLevel").
##
##  *Note:* 
##  For  those  familiar  with  the  `pq'  binary,  `PqDisplayPcPresentation'
##  performs option 4 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqDisplayPcPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DISPLAY_PC_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SET_PRINT_LEVEL(<datarec>, <menu>, <lev>) . . p-Q/SP/A p-Q menu opt. 5
##
##  inputs data to the `pq' binary to set the print level  to  <lev>  in  the
##  <menu> menu, where <menu> is either `"pQ"' (main  $p$-Quotient  menu)  or
##  `"SP' (Standard Presentation  menu)  or  `"ApQ"'  (Advanced  $p$-Quotient
##  menu), by performing option 5 of <menu> menu.
##
InstallGlobalFunction( PQ_SET_PRINT_LEVEL, function( datarec, menu, lev )
  PQ_MENU(datarec, menu);
  ToPQ(datarec, [ "5  #set print level" ]);
  ToPQ(datarec, [ lev, "  #print level" ]);
end );

#############################################################################
##
#F  PqSetPrintLevel( <i>, <lev> ) . . . . . user version of p-Q menu option 5
#F  PqSetPrintLevel( <lev> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data to the
##  `pq' binary, to set the print level in the main $p$-Quotient menu.
##
##  *Note:* For  those  familiar  with  the  `pq'  binary,  `PqSetPrintLevel'
##  performs option 5 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqSetPrintLevel, function( arg )
local datarec, lev;
  if IsEmpty(arg) or 2 < Length(arg) then
    Error( "1 or 2 arguments expected\n");
  fi;
  lev := arg[Length(arg)];
  if not(lev in [0..3]) then
    Error( "argument <lev> should be an integer in [0 .. 3]\n" );
  fi;
  arg := arg{[1..Length(arg) - 1]};
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SET_PRINT_LEVEL( datarec, "SP", lev );
end );

#############################################################################
##
#F  PQ_NEXT_CLASS( <datarec> ) . . . . . . . . . . . . . .  p-Q menu option 6
##
##  directs the `pq' binary to calculate the next class of `<datarec>.group',
##  using option 6 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PQ_NEXT_CLASS, function( datarec )
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ "6  #calculate next class" ]);
end );

#############################################################################
##
#F  PqNextClass( <i> ) . . . . . . . . . .  user version of p-Q menu option 6
#F  PqNextClass()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  to calculate the next class of `<datarec>.group'.
##
##  *Note:* For those familiar with the `pq' binary,  `PqNextClass'  performs
##  option 6 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqNextClass, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_NEXT_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_P_COVER( <datarec> ) . . . . . . . . . . . . . . . . p-Q menu option 7
##
##  directs  the  `pq'  binary  to  compute   the   $p$-covering   group   of
##  `<datarec>.group', using option 7 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PQ_P_COVER, function( datarec )
local savefile;
  PQ_MENU(datarec, "pQ");
  ToPQ(datarec, [ "7  #compute p-cover" ]);
end );

#############################################################################
##
#F  PqPCover( <i> ) . . . . . . . . . . . . user version of p-Q menu option 7
#F  PqPCover()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  to compute the $p$-covering group of `<datarec>.group'.
##
##  *Note:* For those familiar with  the  `pq'  binary,  `PqPCover'  performs
##  option 7 of the main $p$-Quotient menu.
##
InstallGlobalFunction( PqPCover, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_P_COVER( datarec );
end );

#############################################################################
##
#F  PQ_COLLECT( <datarec>, <word> ) . . . . . . . . . . . A p-Q menu option 1
##
##  instructs the  `pq'  binary  to  do  a  collection  on  <word>  a  string
##  representing the product of three generators, e.g. `"x3*x2*x1"' (option 1
##  of the interactive $p$-Quotient menu).
##
InstallGlobalFunction( PQ_COLLECT, function( datarec, word )

  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQk(datarec, [ "1  #do individual collection" ]);
  FLUSH_PQ_STREAM_UNTIL(
      datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
      line -> 0 < Length(line) and line[Length(line)] = '\n');
  ToPQ(datarec, [ word, ";  #word to be collected" ]);
end );

#############################################################################
##
#F  PqCollect( <i>, <word> ) . . . . . .  user version of A p-Q menu option 1
#F  PqCollect( <word> )
##
##  for the <i>th or default interactive {\ANUPQ} process, instructs the `pq'
##  binary to do a collection on <word> a string representing the product  of
##  three generators, e.g. `"x3*x2*x1"'.
##
##  *Note:* For those familiar with the  `pq'  binary,  `PqCollect'  performs
##  option 1 of the Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollect, function( arg )
local datarec, word;
  if IsEmpty(arg) or 2 < Length(arg) then
    Error( "1 or 2 arguments expected\n");
  fi;
  word := arg[Length(arg)];
  if not IsString(word) then
    Error( "argument <word> should be a string e.g. \"x3*x2*x1\"\n" );
  fi;
  arg := arg{[1..Length(arg) - 1]};
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COLLECT( datarec, word );
end );

#############################################################################
##
#F  PQ_SOLVE_EQUATION( <datarec>, <a>, <b> ) . . . . . .  A p-Q menu option 2
##
##  inputs data to the `pq' binary for option 2 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SOLVE_EQUATION, function( datarec, a, b )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQk(datarec, [ "2  #solve equation" ]);
  FLUSH_PQ_STREAM_UNTIL(
      datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
      line -> 0 < Length(line) and line[Length(line)] = '\n');
  ToPQk(datarec, [ a, ";  #word to be collected" ]);
  FLUSH_PQ_STREAM_UNTIL(
      datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
      line -> 0 < Length(line) and line[Length(line)] = '\n');
  ToPQ(datarec, [ b, ";  #word to be collected" ]);
end );

#############################################################################
##
#F  PqSolveEquation( <i> ) . . . . . . .  user version of A p-Q menu option 2
#F  PqSolveEquation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSolveEquation' performs option 2 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSolveEquation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SOLVE_EQUATION( datarec );
end );

#############################################################################
##
#F  PQ_COMMUTATOR( <datarec>, <words>, <pow> ) . . . . .  A p-Q menu option 3
##
##  inputs data to the `pq' binary for option 3 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COMMUTATOR, function( datarec, words, pow )
local i;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "3  #commutator" ]);
  # @add argument checking@
  ToPQk(datarec, [ Length(words), "  #no. of components" ]);
  for i in [1..Length(words)] do
    FLUSH_PQ_STREAM_UNTIL(
        datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
        line -> 1 < Length(line) and 
                line{[Length(line) - 1..Length(line)]} = ":\n");
    ToPQk(datarec, [ words[i], ";  #word ", i ]);
  od;
  FLUSH_PQ_STREAM_UNTIL(datarec.stream, 4, 2, PQ_READ_NEXT_LINE, IS_PQ_PROMPT);
  ToPQ(datarec, [ pow, "  #power" ]);
end );

#############################################################################
##
#F  PqCommutator( <i> ) . . . . . . . . . user version of A p-Q menu option 3
#F  PqCommutator()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCommutator' performs option 3 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCommutator, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COMMUTATOR( datarec );
end );

#############################################################################
##
#F  PQ_DISPLAY_PRESENTATION( <datarec> ) . . . . . . . .  A p-Q menu option 4
##
##  inputs data to the `pq' binary for option 4 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DISPLAY_PRESENTATION, function( datarec )
end );

#############################################################################
##
#F  PqDisplayPresentation( <i> ) . . . .  user version of A p-Q menu option 4
#F  PqDisplayPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqDisplayPresentation' performs option 4 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDisplayPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DISPLAY_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SETUP_TABLES_FOR_NEXT_CLASS( <datarec> ) . . . . . A p-Q menu option 6
##
##  inputs data to the `pq' binary for option 6 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SETUP_TABLES_FOR_NEXT_CLASS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "6  #set up tables for next class" ]);
  #@datarec.class should be incremented here@
end );

#############################################################################
##
#F  PqSetupTablesForNextClass( <i> ) . .  user version of A p-Q menu option 6
#F  PqSetupTablesForNextClass()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSetupTablesForNextClass' performs option 6 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetupTablesForNextClass, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SETUP_TABLES_FOR_NEXT_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_INSERT_TAILS( <datarec>, <weight>, <which> )  . .  A p-Q menu option 7
##
##  inputs data to the `pq' binary for option 7 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_INSERT_TAILS, function( datarec, weight, which )
local intwhich;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "7  #insert tails" ]);
  ToPQ(datarec, [ weight, "  #weight of tails to add/compute" ]);
  #@check weight in [0..class]@
  repeat
    intwhich := Position( [ "all", "add", "compute" ], which );
    if intwhich = fail then
      Error( "<which> should be one of: \"all\", \"add\", \"compute\"\n",
             "To continue type: 'which := <value>; return;'\n" );
    fi;
  until intwhich <> fail;
  if which = "all" then
    which := "add and compute";
  fi;
  ToPQ(datarec, [ intwhich - 1, "  #", which ]);
end );

#############################################################################
##
#F  PqInsertTails( <i> ) . . . . . . . .  user version of A p-Q menu option 7
#F  PqInsertTails()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqInsertTails' performs option 7 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqInsertTails, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_INSERT_TAILS( datarec );
end );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECKS( <datarec>, <weight>, <type> ) . A p-Q menu opt 8
##
##  inputs data to the `pq' binary for option 8 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DO_CONSISTENCY_CHECKS, 
function( datarec, weight, type )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "8  #check consistency" ]);
  ToPQ(datarec, [ weight, "  #weight of tails to add/compute" ]);
  #@check type in: [0,1,2,3] 0 = `all' weight in [0..class]@
  ToPQ(datarec, [ type, "  #type" ]);
end );

#############################################################################
##
#F  PqDoConsistencyChecks( <i> ) . . . .  user version of A p-Q menu option 8
#F  PqDoConsistencyChecks()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqDoConsistencyChecks' performs option 8 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoConsistencyChecks, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DO_CONSISTENCY_CHECKS( datarec );
end );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_RELATIONS( <datarec> ) . . . . .  A p-Q menu option 9
##
##  inputs data to the `pq' binary for option 9 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COLLECT_DEFINING_RELATIONS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "9  #collect defining relations" ]);
end );

#############################################################################
##
#F  PqCollectDefiningRelations( <i> ) . . user version of A p-Q menu option 9
#F  PqCollectDefiningRelations()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCollectDefiningRelations' performs option 9 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollectDefiningRelations, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COLLECT_DEFINING_RELATIONS( datarec );
end );

#############################################################################
##
#F  PQ_DO_EXPONENT_CHECKS( <datarec>, <weight1>, <weight2> ) A p-Q menu optn 10
##
##  inputs data to the `pq' binary for option 10 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DO_EXPONENT_CHECKS, 
function( datarec, weight1, weight2 )
  #@does default only at the moment@
  if not IsBound(datarec.pQpcp.Exponent) or datarec.pQpcp.Exponent = 0 then
    Error( "no exponent law set\n" );
  fi;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "10  #do exponent checks" ]);
  ToPQ(datarec, [ weight1, "  #start weight"]);
  ToPQ(datarec, [ weight2, "  #end weight"]);
  ToPQ(datarec, [ 1, "  #do default check"]);
end );

#############################################################################
##
#F  PqDoExponentChecks( <i> ) . . . . .  user version of A p-Q menu option 10
#F  PqDoExponentChecks()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqDoExponentChecks' performs option 10 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoExponentChecks, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DO_EXPONENT_CHECKS( datarec );
end );

#############################################################################
##
#F  PQ_ELIMINATE_REDUNDANT_GENERATORS( <datarec> ) . . . A p-Q menu option 11
##
##  inputs data to the `pq' binary for option 11 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_ELIMINATE_REDUNDANT_GENERATORS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "11  #eliminate redundant generators" ]);
end );

#############################################################################
##
#F  PqEliminateRedundantGenerators( <i> )  user version of A p-Q menu option 11
#F  PqEliminateRedundantGenerators()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEliminateRedundantGenerators' performs option 11 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEliminateRedundantGenerators, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_ELIMINATE_REDUNDANT_GENERATORS( datarec );
end );

#############################################################################
##
#F  PQ_REVERT_TO_PREVIOUS_CLASS( <datarec> ) . . . . . . A p-Q menu option 12
##
##  inputs data to the `pq' binary for option 12 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_REVERT_TO_PREVIOUS_CLASS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "12  #revert to previous class" ]);
end );

#############################################################################
##
#F  PqRevertToPreviousClass( <i> ) . . . user version of A p-Q menu option 12
#F  PqRevertToPreviousClass()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqRevertToPreviousClass' performs option 12 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqRevertToPreviousClass, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_REVERT_TO_PREVIOUS_CLASS( datarec );
end );

#############################################################################
##
#F  PQ_SET_MAXIMAL_OCCURRENCES( <datarec>, <weights> ) . . A p-Q menu opt. 13
##
##  inputs data to the `pq' binary for option 13 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SET_MAXIMAL_OCCURRENCES, function( datarec, weights )
local ngens;
  ngens := Length( GeneratorsOfGroup( datarec.pQuotient ) );
  if ngens <> Length(weights) then
    Error( "no. of weights must be equal to the no. of generators of ",
           "weight 1 (", ngens, ")\n" );
  fi;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "13  #set maximal occurrences" ]);
  ToPQ(datarec, [ JoinStringsWithSeparator( List(weights, String), " " ),
                    "  #weights"]);
end );

#############################################################################
##
#F  PqSetMaximalOccurrences( <i> ) . . . user version of A p-Q menu option 13
#F  PqSetMaximalOccurrences()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSetMaximalOccurrences' performs option 13 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetMaximalOccurrences, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SET_MAXIMAL_OCCURRENCES( datarec );
end );

#############################################################################
##
#F  PQ_SET_METABELIAN( <datarec> ) . . . . . . . . . . . A p-Q menu option 14
##
##  inputs data to the `pq' binary for option 14 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SET_METABELIAN, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "14  #set metabelian" ]);
end );

#############################################################################
##
#F  PqSetMetabelian( <i> ) . . . . . . . user version of A p-Q menu option 14
#F  PqSetMetabelian()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSetMetabelian' performs option 14 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSetMetabelian, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SET_METABELIAN( datarec );
end );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECK( <datarec>, <c>, <b>, <a> ) . A p-Q menu option 15
##
##  inputs data to the `pq' binary for option 15 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DO_CONSISTENCY_CHECK, function( datarec, c, b, a )
  if not ForAll([c, b, a], IsPosInt) or c < b or b < a then
    Error( "generator indices must be non-increasing positive integers\n" );
  fi;
  #@more checking required here@
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "15  #do individual consistency check" ]);
  ToPQ(datarec, [ c, " ", b, " ", a, "  #generator indices"]);
end );

#############################################################################
##
#F  PqDoConsistencyCheck( <i> ) . . . .  user version of A p-Q menu option 15
#F  PqDoConsistencyCheck()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqDoConsistencyCheck' performs option 15 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDoConsistencyCheck, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DO_CONSISTENCY_CHECK( datarec );
end );

#############################################################################
##
#F  PQ_COMPACT( <datarec> ) . . . . . . . . . . . . . .  A p-Q menu option 16
##
##  inputs data to the `pq' binary for option 16 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COMPACT, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "16  #compact" ]);
end );

#############################################################################
##
#F  PqCompact( <i> ) . . . . . . . . . . user version of A p-Q menu option 16
#F  PqCompact()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCompact' performs option 16 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCompact, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COMPACT( datarec );
end );

#############################################################################
##
#F  PQ_ECHELONISE( <datarec> ) . . . . . . . . . . . . . A p-Q menu option 17
##
##  inputs data to the `pq' binary for option 17 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_ECHELONISE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  #@dependence@
  ToPQ(datarec, [ "17  #echelonise" ]);
end );

#############################################################################
##
#F  PqEchelonise( <i> ) . . . . . . . .  user version of A p-Q menu option 17
#F  PqEchelonise()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEchelonise' performs option 17 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEchelonise, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_ECHELONISE( datarec );
end );

#############################################################################
##
#F  PQ_SUPPLY_AND_EXTEND_AUTOMORPHISMS( <datarec>, <mlist> )  A p-Q menu opt 18
##
##  inputs data to the `pq' binary for option 18 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_SUPPLY_AND_EXTEND_AUTOMORPHISMS, 
function( datarec, mlist )
local rank, nauts, nexpts, i, j, aut, exponents;
  if not( IsList(mlist) and ForAll(mlist, IsMatrix) and
          ForAll(Flat(mlist), i -> IsInt(i) and i >= 0) ) then
    Error("expected list of matrices with non-negative integer coefficients\n");
  fi;
  rank := RankPGroup( datarec.pQuotient );
  if not ForAll(mlist, mat -> Length(mat) = rank) then
    Error("no. of rows in each matrix of <mlist> must be the rank of ",
          "p-quotient (", rank, ")\n");
  fi;
  nexpts := Length(mlist[1][1]);
  if not ForAll(mlist, mat -> Length(mat[1]) = nexpts) then
    Error("each matrix of <mlist> must have the same no. of columns\n");
  fi;
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "18  #supply and extend auts" ]);
  nauts := Length(mlist);
  ToPQ(datarec, [ nauts,  "  #no. of auts" ]);
  ToPQ(datarec, [ nexpts, "  #no. of exponents" ]);
  for i in [1..nauts] do
    aut := mlist[i];
    for j in [1..rank] do
      exponents := Flat( List( aut[j], e -> [ String(e), " "] ) );
      ToPQ(datarec, 
           [ exponents, " #gen'r exp'ts of im(aut ", i, ", gen ", j, ")" ]);
    od;
  od;
end );

#############################################################################
##
#F  PqSupplyAndExtendAutomorphisms( <i> )  user version of A p-Q menu option 18
#F  PqSupplyAndExtendAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSupplyAndExtendAutomorphisms' performs option 18 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqSupplyAndExtendAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SUPPLY_AND_EXTEND_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_CLOSE_RELATIONS( <datarec> ) . . . . . . . . . .  A p-Q menu option 19
##
##  inputs data to the `pq' binary for option 19 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_CLOSE_RELATIONS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "19  #close relations" ]);
end );

#############################################################################
##
#F  PqCloseRelations( <i> ) . . . . . .  user version of A p-Q menu option 19
#F  PqCloseRelations()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCloseRelations' performs option 19 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCloseRelations, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_CLOSE_RELATIONS( datarec );
end );

#############################################################################
##
#F  PQ_PRINT_STRUCTURE( <datarec> ) . . . . . . . . . .  A p-Q menu option 20
##
##  inputs data to the `pq' binary for option 20 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_PRINT_STRUCTURE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "20  #print structure" ]);
end );

#############################################################################
##
#F  PqPrintStructure( <i> ) . . . . . .  user version of A p-Q menu option 20
#F  PqPrintStructure()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqPrintStructure' performs option 20 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqPrintStructure, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PRINT_STRUCTURE( datarec );
end );

#############################################################################
##
#F  PQ_DISPLAY_AUTOMORPHISMS( <datarec> ) . . . . . . .  A p-Q menu option 21
##
##  inputs data to the `pq' binary for option 21 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_DISPLAY_AUTOMORPHISMS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "21  #display automorphisms" ]);
end );

#############################################################################
##
#F  PqDisplayAutomorphisms( <i> ) . . .  user version of A p-Q menu option 21
#F  PqDisplayAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqDisplayAutomorphisms' performs option 21 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqDisplayAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_DISPLAY_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_GENERATORS( <datarec> ) . . . .  A p-Q menu option 23
##
##  inputs data to the `pq' binary for option 23 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COLLECT_DEFINING_GENERATORS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "23  #collect defining generators" ]);
end );

#############################################################################
##
#F  PqCollectDefiningGenerators( <i> ) . user version of A p-Q menu option 23
#F  PqCollectDefiningGenerators()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCollectDefiningGenerators' performs option 23 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCollectDefiningGenerators, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COLLECT_DEFINING_GENERATORS( datarec );
end );

#############################################################################
##
#F  PQ_COMMUTATOR_DEFINING_GENERATORS( <datarec> ) . . . A p-Q menu option 24
##
##  inputs data to the `pq' binary for option 24 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_COMMUTATOR_DEFINING_GENERATORS, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "24  #commutator defining generators" ]);
end );

#############################################################################
##
#F  PqCommutatorDefiningGenerators( <i> )  user version of A p-Q menu option 24
#F  PqCommutatorDefiningGenerators()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqCommutatorDefiningGenerators' performs option 24 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqCommutatorDefiningGenerators, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_COMMUTATOR_DEFINING_GENERATORS( datarec );
end );

#############################################################################
##
#F  PQ_WRITE_PC_PRESENTATION( <datarec>, <outfile> ) . . A p-Q menu option 25
##
##  tells the `pq' binary to write a pc presentation to <outfile>  for  group
##  `<datarec>.group' (option 25 of the interactive $p$-Quotient menu).
##
InstallGlobalFunction( PQ_WRITE_PC_PRESENTATION, function( datarec, outfile )
  PrintTo(outfile, ""); #to ensure it's empty
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "25 #set output file" ]);
  ToPQ(datarec, [ outfile ]);
  ToPQ(datarec, [ "2  #output in GAP format" ]);
end );

#############################################################################
##
#F  PqWritePcPresentation( <i>, <outfile> ) .  user ver. of A p-Q menu op. 25
#F  PqWritePcPresentation( <outfile> )
##
##  for the <i>th or default interactive {\ANUPQ}  process,  tells  the  `pq'
##  binary to write a pc presentation to <outfile>  for  the  group  of  that
##  process for which a pc presentation has been previously  computed,  where
##  the group of a process is the one given as first argument when  `PqStart'
##  was called to initiate that process (for process <i> the group is  stored
##  as  `ANUPQData.io[<i>].group').  If  a  pc  presentation  has  not   been
##  previously computed by the `pq' binary, then `pq' is called to compute it
##  first, effectively invoking `PqPcPresentation' (see~"PqPcPresentation").
##
##  *Note:* For those familiar with the `pq' binary,  `PqPcWritePresentation'
##  performs option 25 of the interactive $p$-Quotient menu.
##
InstallGlobalFunction( PqWritePcPresentation, function( arg )
local outfile, datarec;
  if 2 < Length(arg) or IsEmpty(arg) then
    Error("expected one or two arguments.\n");
  fi;
  outfile := arg[ Length(arg) ];
  if not IsString(outfile) then
    Error("last argument must be a string (filename).\n");
  fi;
  Unbind( arg[ Length(arg) ] );
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  if not IsBound(datarec.pcp) then
    Info(InfoANUPQ, 1, "pq had not previously computed a pc presentation");
    Info(InfoANUPQ, 1, "... remedying that now.");
    PQ_PC_PRESENTATION( datarec, "pQ" );
  fi;
  PQ_WRITE_PC_PRESENTATION( datarec, outfile );
end );

#############################################################################
##
#F  PQ_EVALUATE_CERTAIN_FORMULAE( <datarec> ) . . . . .  A p-Q menu option 27
##
##  inputs data to the `pq' binary for option 27 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_EVALUATE_CERTAIN_FORMULAE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "27  #evaluate certain formulae" ]);
end );

#############################################################################
##
#F  PqEvaluateCertainFormulae( <i> ) . . user version of A p-Q menu option 27
#F  PqEvaluateCertainFormulae()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEvaluateCertainFormulae' performs option 27 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateCertainFormulae, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_EVALUATE_CERTAIN_FORMULAE( datarec );
end );

#############################################################################
##
#F  PQ_EVALUATE_ACTION( <datarec> ) . . . . . . . . . .  A p-Q menu option 28
##
##  inputs data to the `pq' binary for option 28 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_EVALUATE_ACTION, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "28  #evaluate action" ]);
end );

#############################################################################
##
#F  PqEvaluateAction( <i> ) . . . . . .  user version of A p-Q menu option 28
#F  PqEvaluateAction()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEvaluateAction' performs option 28 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateAction, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_EVALUATE_ACTION( datarec );
end );

#############################################################################
##
#F  PQ_EVALUATE_ENGEL_IDENTITY( <datarec> ) . . . . . .  A p-Q menu option 29
##
##  inputs data to the `pq' binary for option 29 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_EVALUATE_ENGEL_IDENTITY, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "29  #evaluate Engel identity" ]);
end );

#############################################################################
##
#F  PqEvaluateEngelIdentity( <i> ) . . . user version of A p-Q menu option 29
#F  PqEvaluateEngelIdentity()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqEvaluateEngelIdentity' performs option 29 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqEvaluateEngelIdentity, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_EVALUATE_ENGEL_IDENTITY( datarec );
end );

#############################################################################
##
#F  PQ_PROCESS_RELATIONS_FILE( <datarec> ) . . . . . . . A p-Q menu option 30
##
##  inputs data to the `pq' binary for option 30 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PQ_PROCESS_RELATIONS_FILE, function( datarec )
  PQ_MENU(datarec, "ApQ"); #we need options from the Advanced p-Q Menu
  ToPQ(datarec, [ "30  #process relations file" ]);
end );

#############################################################################
##
#F  PqProcessRelationsFile( <i> ) . . .  user version of A p-Q menu option 30
#F  PqProcessRelationsFile()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqProcessRelationsFile' performs option 30 of the
##  Advanced $p$-Quotient menu.
##
InstallGlobalFunction( PqProcessRelationsFile, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PROCESS_RELATIONS_FILE( datarec );
end );

#############################################################################
##
#F  PqSPPcPresentation( <i> : <options> ) . .  user version of SP menu opt. 1
#F  PqSPPcPresentation( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data  given
##  by <options> for the group of  that  process  so  that  the  `pq'  binary
##  computes a pc presentation, where the group of a process is the one given
##  as first argument when `PqStart' was called to initiate that process (for
##  process <i> the group is stored as `ANUPQData.io[<i>].group').
##
##  *Note:* For those familiar with  the  `pq'  binary,  `PqSPPcPresentation'
##  performs option 1 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPPcPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PC_PRESENTATION( datarec, "SP" );
end );

#############################################################################
##
#F  PQ_SP_STANDARD_PRESENTATION( <datarec> : <options> ) . . SP menu option 2
##
##  inputs data given by <options> to the `pq' binary to compute  a  standard
##  presentation  for  group  `<datarec>.group'  using  `<datarec>.pQuotient'
##  which must have been  previously  computed  and  option  2  of  the  main
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_STANDARD_PRESENTATION, function( datarec )
local savefile;
  PQ_MENU(datarec, "SP");

  ToPQ(datarec, [ "2  #compute standard presentation" ]);
  savefile := VALUE_PQ_OPTION("StandardPresentationFile",
                              Filename( ANUPQData.tmpdir, "SPres" ));
  ToPQ(datarec, [ savefile, "  #file for saving pres'n" ]);
  ToPQ(datarec, [ VALUE_PQ_OPTION("ClassBound", 63), "  #class bound" ]);

  PQ_AUT_INPUT( datarec, datarec.pQuotient );
  ToPQ(datarec, [ PQ_BOOL(datarec.PcgsAutomorphisms), 
                  "compute pcgs gen. seq. for auts." ]);
end );

#############################################################################
##
#F  PqSPStandardPresentation( <i> : <options> ) . user ver. of SP menu opt. 2
#F  PqSPStandardPresentation( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data  given
##  by <options> to compute a standard presentation for  the  group  of  that
##  process and a previously computed $p$-quotient of the  group,  where  the
##  group of a process is the one given as first argument when `PqStart'  was
##  called to initiate that process (for process <i> the group is  stored  as
##  `ANUPQData.io[<i>].group'   and   the   $p$-quotient   is    stored    as
##  `ANUPQData.io[<i>].pQuotient'). If a $p$-quotient of the  group  has  not
##  been previously computed a class 1 $p$-quotient is computed.
##
##  *Note:* For those familiar with  the  `pq'  binary,  `PqSPPcPresentation'
##  performs option 2 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPStandardPresentation, function( arg )
local ioIndex, datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  ioIndex := ANUPQ_IOINDEX(arg);
  datarec := ANUPQData.io[ ioIndex ];
  if not IsBound(datarec.pQuotient) then
    PQ_EPIMORPHISM(ioIndex);
  fi;
  PQ_SP_STANDARD_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SP_SAVE_PRESENTATION( <datarec> ) . . . . . . . . . . SP menu option 3
##
##  inputs data to the `pq' binary for option 3 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_SAVE_PRESENTATION, function( datarec )
end );

#############################################################################
##
#F  PqSPSavePresentation( <i> ) . . . . . .  user version of SP menu option 3
#F  PqSPSavePresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSPSavePresentation' performs option 3 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PqSPSavePresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SP_SAVE_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SP_DISPLAY_PRESENTATION( <datarec> ) . . . . . . . .  SP menu option 4
##
##  inputs data to the `pq' binary for option 4 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_DISPLAY_PRESENTATION, function( datarec )
end );

#############################################################################
##
#F  PqSPDisplayPresentation( <i> ) . . . . . user version of SP menu option 4
#F  PqSPDisplayPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSPDisplayPresentation' performs option 4 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PqSPDisplayPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SP_DISPLAY_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS( <datarec> ) . . .  SP menu option 6
##
##  inputs data to the `pq' binary for option 6 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS, function( datarec )
end );

#############################################################################
##
#F  PqSPCompareTwoFilePresentations( <i> ) . user version of SP menu option 6
#F  PqSPCompareTwoFilePresentations()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqSPCompareTwoFilePresentations' performs option 6 of the
##  Standard Presentation menu.
##
InstallGlobalFunction( PqSPCompareTwoFilePresentations, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS( datarec );
end );

#############################################################################
##
#F  PQ_SP_ISOMORPHISM( <datarec> ) . . . . . . . . . . . . . SP menu option 8
##
##  computes the mapping  from  the  automorphism  group  generators  to  the
##  generators of the standard presentation,  using  option  8  of  the  main
##  Standard Presentation menu.
##
InstallGlobalFunction( PQ_SP_ISOMORPHISM, function( datarec )
  PQ_MENU(datarec, "SP");
  ToPQ(datarec, [ "8  #compute isomorphism" ]);
end );

#############################################################################
##
#F  PqSPIsomorphism( <i> ) . . . . . . . . . user version of SP menu option 8
#F  PqSPIsomorphism()
##
##  for the <i>th or default interactive {\ANUPQ} process, directs  the  `pq'
##  binary to compute the isomorphism from the generators of the automorphism
##  group of `ANUPQData.io[<i>].pQuotient' to the generators for the standard
##  presentation.
##
##  *Note:* For  those  familiar  with  the  `pq'  binary,  `PqSPIsomorphism'
##  performs option 8 of the Standard Presentation menu.
##
InstallGlobalFunction( PqSPIsomorphism, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_SP_ISOMORPHISM( datarec );
end );

#############################################################################
##
#F  PQ_PG_SUPPLY_AUTS( <datarec> ) . . . . . . . . . . . . . pG menu option 1
##
##  defines the automorphism group of `<datarec>.group', using  option  1  of
##  the main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_SUPPLY_AUTS, function( datarec )
local gens;
  PQ_MENU(datarec, "pG");
  ToPQk(datarec, [ "1  #supply automorphism data" ]);
  PQ_AUT_INPUT( datarec, datarec.group );
end );

#############################################################################
##
#F  PqPGSupplyAutomorphisms( <i> ) . . . . . user version of pG menu option 1
#F  PqPGSupplyAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, supplies the  `pq'
##  binary with the automorphism group  data  needed  for  `<datarec>.group'.
##
##  *Note:*
##  For  those  familiar  with  the  `pq'  binary,  `PqPGSupplyAutomorphisms'
##  performs option 1 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGSupplyAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PG_SUPPLY_AUTS( datarec );
end );

#############################################################################
##
#F  PQ_PG_EXTEND_AUTOMORPHISMS( <datarec> ) . . . . . . . . p-G menu option 2
##
##  inputs data to the `pq' binary for option 2 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_EXTEND_AUTOMORPHISMS, function( datarec )
end );

#############################################################################
##
#F  PqPGExtendAutomorphisms( <i> ) . . . .  user version of p-G menu option 2
#F  PqPGExtendAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqPGExtendAutomorphisms' performs option 2 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGExtendAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PG_EXTEND_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_PG_RESTORE_GROUP_FROM_FILE( <datarec> ) . . . . . .  p-G menu option 3
##
##  inputs data to the `pq' binary for option 3 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_RESTORE_GROUP_FROM_FILE, function( datarec )
end );

#############################################################################
##
#F  PqPGRestoreGroupFromFile( <i> ) . . . . user version of p-G menu option 3
#F  PqPGRestoreGroupFromFile()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqPGRestoreGroupFromFile' performs option 3 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGRestoreGroupFromFile, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PG_RESTORE_GROUP_FROM_FILE( datarec );
end );

#############################################################################
##
#F  PQ_PG_DISPLAY_GROUP_PRESENTATION( <datarec> ) . . . . . p-G menu option 4
##
##  inputs data to the `pq' binary for option 4 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_DISPLAY_GROUP_PRESENTATION, function( datarec )
end );

#############################################################################
##
#F  PqPGDisplayGroupPresentation( <i> ) . . user version of p-G menu option 4
#F  PqPGDisplayGroupPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqPGDisplayGroupPresentation' performs option 4 of the
##  main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGDisplayGroupPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PG_DISPLAY_GROUP_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_PG_CONSTRUCT_DESCENDANTS( <datarec> : <options> ) .  p-G menu option 5
##
##  inputs  data  given  by  <options>  to  the  `pq'  binary  to   construct
##  descendants, using option 5 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_PG_CONSTRUCT_DESCENDANTS, function( datarec )
local firstStep, expectedNsteps;

  datarec.des := rec();
  # deal with the easy answer
  if VALUE_PQ_OPTION("OrderBound", 0, datarec.des) <> 0 and 
     datarec.des.OrderBound <= LogInt(Size(datarec.group), 
                                      PrimePGroup(datarec.group)) then
    return [];
  fi;

  # sanity checks
  if     VALUE_PQ_OPTION("SpaceEfficient", false, datarec.des) and 
     not VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec.des) then
    Error( "\"SpaceEfficient\" is only allowed in conjunction with ",
           "\"PcgsAutomorphisms\"\n");
  fi;
  if VALUE_PQ_OPTION("StepSize", datarec.des) <> fail then
    if datarec.des.OrderBound <> 0 then
      Error("\"StepSize\" and \"OrderBound\" must not be set simultaneously\n");
    fi;
    if IsList(datarec.des.StepSize) then
      firstStep := datarec.des.StepSize[1];
    else
      firstStep := datarec.des.StepSize;
    fi;
    if HasNuclearRank(datarec.group) and 
       firstStep > NuclearRank(datarec.group) then
      Error("the first \"StepSize\" element (= ", firstStep, ") must not be\n",
            "greater than the \"Nuclear Rank\" (= ",
            NuclearRank(datarec.group), ")\n");
    fi;
  fi;

  PQ_MENU(datarec, "pG");
  ToPQ(datarec, [ "5  #construct descendants" ]);
  ToPQ(datarec, [ VALUE_PQ_OPTION("ClassBound", 
                                  PClassPGroup(datarec.group) + 1, 
                                  datarec.des),
                   "  #class bound" ]);

  #Construct all descendants?
  if not IsBound(datarec.des.StepSize) then
    ToPQ(datarec, [ "1  #do construct all descendants" ]);
    #Set an order bound for descendants?
    if datarec.des.OrderBound <> 0 then
      ToPQ(datarec, [ "1  #do set an order bound" ]);
      ToPQ(datarec, [ datarec.des.OrderBound, "  #order bound" ]);
    else
      ToPQ(datarec, [ "0  #do not set an order bound" ]);
    fi;
  else
    ToPQ(datarec, [ "0  #do not construct all descendants" ]);
    #Constant step size?
    if IsInt(datarec.des.StepSize) then
      ToPQ(datarec, [ "1  #set constant step size" ]);
      ToPQ(datarec, [ datarec.des.StepSize, "  #step size" ]);
    else
      expectedNsteps := datarec.des.ClassBound - PClassPGroup(datarec.group);
      if Length(datarec.des.StepSize) <> expectedNsteps then
        Error( "the number of step-sizes in the \"StepSize\" list must\n",
               "equal ", expectedNsteps, " (the difference of \"ClassBound\"\n",
               "and the current class)\n" );
      fi;
      ToPQ(datarec, [ "0  #set variable step size" ]);
      ToPQ(datarec, [ JoinStringsWithSeparator(
                          List(datarec.des.StepSize, String), " "),
                       "  #step sizes" ]);
    fi;
  fi;
  ToPQ(datarec, [ PQ_BOOL(
                      VALUE_PQ_OPTION("PcgsAutomorphisms", false, datarec.des)
                      ),
                   "compute pcgs gen. seq. for auts." ]);
  ToPQ(datarec, [ "0  #do not use default algorithm" ]);
  ToPQ(datarec, [ VALUE_PQ_OPTION("RankInitialSegmentSubgroups", 0,
                                  datarec.des),
                   "  #rank of initial segment subgrp" ]);
  if datarec.des.PcgsAutomorphisms then
    ToPQ(datarec, [ PQ_BOOL(datarec.des.SpaceEfficient),
                   "be space efficient" ]);
  fi;
  ToPQ(datarec, [ PQ_BOOL(
                      VALUE_PQ_OPTION( "AllDescendants", false, datarec.des ) ),
                   "completely process terminal descendants" ]);
  ToPQ(datarec, [ VALUE_PQ_OPTION("Exponent", 0, datarec.des), "  #exponent" ]);
  ToPQ(datarec, [ PQ_BOOL( VALUE_PQ_OPTION("Metabelian", false, datarec.des) ),
                   "enforce metabelian law" ]);
  ToPQ(datarec, [ "1  #default output" ]); # There are > 18 questions to deal
                                           # with by not taking the default
                                           # ... maybe in the future we will
                                           # give the user more control
end );

#############################################################################
##
#F  PqPGConstructDescendants( <i> : <options> ) . user ver. of p-G menu op. 5
#F  PqPGConstructDescendants( : <options> )
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data  given
##  by <options> to the `pq' binary to  construct  descendants.  The  options
##  possible are all those given  for  `PqDescendants'  (see~"PqDescendants")
##  except for `SubList' and `SetupFile'.
##
##  *Note:* 
##  For those  familiar  with  the  `pq'  binary,  `PqPGConstructDescendants'
##  performs option 5 of the main $p$-Group Generation menu.
##
InstallGlobalFunction( PqPGConstructDescendants, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_PG_CONSTRUCT_DESCENDANTS( datarec );
end );

#############################################################################
##
#F  PQ_APG_SUPPLY_AUTOMORPHISMS( <datarec> ) . . . . . .  A p-G menu option 1
##
##  inputs data to the `pq' binary for option 1 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_SUPPLY_AUTOMORPHISMS, function( datarec )
end );

#############################################################################
##
#F  PqAPGSupplyAutomorphisms( <i> ) . . . user version of A p-G menu option 1
#F  PqAPGSupplyAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGSupplyAutomorphisms' performs option 1 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGSupplyAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_SUPPLY_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_APG_EXTEND_AUTOMORPHISMS( <datarec> ) . . . . . .  A p-G menu option 2
##
##  inputs data to the `pq' binary for option 2 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_EXTEND_AUTOMORPHISMS, function( datarec )
end );

#############################################################################
##
#F  PqAPGExtendAutomorphisms( <i> ) . . . user version of A p-G menu option 2
#F  PqAPGExtendAutomorphisms()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGExtendAutomorphisms' performs option 2 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGExtendAutomorphisms, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_EXTEND_AUTOMORPHISMS( datarec );
end );

#############################################################################
##
#F  PQ_APG_RESTORE_GROUP_FROM_FILE( <datarec> ) . . . . . A p-G menu option 3
##
##  inputs data to the `pq' binary for option 3 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_RESTORE_GROUP_FROM_FILE, function( datarec )
end );

#############################################################################
##
#F  PqAPGRestoreGroupFromFile( <i> ) . .  user version of A p-G menu option 3
#F  PqAPGRestoreGroupFromFile()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGRestoreGroupFromFile' performs option 3 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGRestoreGroupFromFile, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_RESTORE_GROUP_FROM_FILE( datarec );
end );

#############################################################################
##
#F  PQ_APG_DISPLAY_GROUP_PRESENTATION( <datarec> ) . . .  A p-G menu option 4
##
##  inputs data to the `pq' binary for option 4 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_DISPLAY_GROUP_PRESENTATION, function( datarec )
end );

#############################################################################
##
#F  PqAPGDisplayGroupPresentation( <i> )  user version of A p-G menu option 4
#F  PqAPGDisplayGroupPresentation()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGDisplayGroupPresentation' performs option 4 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGDisplayGroupPresentation, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_DISPLAY_GROUP_PRESENTATION( datarec );
end );

#############################################################################
##
#F  PQ_APG_SINGLE_STAGE( <datarec> ) . . . . . . . . . .  A p-G menu option 5
##
##  inputs data to the `pq' binary for option 5 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_SINGLE_STAGE, function( datarec )
end );

#############################################################################
##
#F  PqAPGSingleStage( <i> ) . . . . . . . user version of A p-G menu option 5
#F  PqAPGSingleStage()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGSingleStage' performs option 5 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGSingleStage, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_SINGLE_STAGE( datarec );
end );

#############################################################################
##
#F  PQ_APG_DEGREE( <datarec> ) . . . . . . . . . . . . .  A p-G menu option 6
##
##  inputs data to the `pq' binary for option 6 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_DEGREE, function( datarec )
end );

#############################################################################
##
#F  PqAPGDegree( <i> ) . . . . . . . . .  user version of A p-G menu option 6
#F  PqAPGDegree()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGDegree' performs option 6 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGDegree, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_DEGREE( datarec );
end );

#############################################################################
##
#F  PQ_APG_PERMUTATIONS( <datarec> ) . . . . . . . . . .  A p-G menu option 7
##
##  inputs data to the `pq' binary for option 7 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_PERMUTATIONS, function( datarec )
end );

#############################################################################
##
#F  PqAPGPermutations( <i> ) . . . . . .  user version of A p-G menu option 7
#F  PqAPGPermutations()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGPermutations' performs option 7 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGPermutations, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_PERMUTATIONS( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBITS( <datarec> ) . . . . . . . . . . . . .  A p-G menu option 8
##
##  inputs data to the `pq' binary for option 8 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBITS, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbits( <i> ) . . . . . . . . .  user version of A p-G menu option 8
#F  PqAPGOrbits()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbits' performs option 8 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbits, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_ORBITS( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVES( <datarec> ) . . . . . . A p-G menu option 9
##
##  inputs data to the `pq' binary for option 9 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVES, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbitRepresentatives( <i> ) . .  user version of A p-G menu option 9
#F  PqAPGOrbitRepresentatives()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbitRepresentatives' performs option 9 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentatives, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_ORBIT_REPRESENTATIVES( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVE( <datarec> ) . . . . . . A p-G menu option 10
##
##  inputs data to the `pq' binary for option 10 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVE, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbitRepresentative( <i> ) . .  user version of A p-G menu option 10
#F  PqAPGOrbitRepresentative()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbitRepresentative' performs option 10 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentative, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_ORBIT_REPRESENTATIVE( datarec );
end );

#############################################################################
##
#F  PQ_APG_STANDARD_MATRIX_LABEL( <datarec> ) . . . . .  A p-G menu option 11
##
##  inputs data to the `pq' binary for option 11 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_STANDARD_MATRIX_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGStandardMatrixLabel( <i> ) . .  user version of A p-G menu option 11
#F  PqAPGStandardMatrixLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGStandardMatrixLabel' performs option 11 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGStandardMatrixLabel, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_STANDARD_MATRIX_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_MATRIX_OF_LABEL( <datarec> ) . . . . . . . .  A p-G menu option 12
##
##  inputs data to the `pq' binary for option 12 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_MATRIX_OF_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGMatrixOfLabel( <i> ) . . . . .  user version of A p-G menu option 12
#F  PqAPGMatrixOfLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGMatrixOfLabel' performs option 12 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGMatrixOfLabel, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_MATRIX_OF_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP( <datarec> ) . .  A p-G menu option 13
##
##  inputs data to the `pq' binary for option 13 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP, function( datarec )
end );

#############################################################################
##
#F  PqAPGImageOfAllowableSubgroup( <i> ) user version of A p-G menu option 13
#F  PqAPGImageOfAllowableSubgroup()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGImageOfAllowableSubgroup' performs option 13 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGImageOfAllowableSubgroup, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP( datarec );
end );

#############################################################################
##
#F  PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT( <datarec> )  A p-G menu option 14
##
##  inputs data to the `pq' binary for option 14 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT, function( datarec )
end );

#############################################################################
##
#F  PqAPGRankClosureOfInitialSegment( <i> )  user version of A p-G menu option 14
#F  PqAPGRankClosureOfInitialSegment()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGRankClosureOfInitialSegment' performs option 14 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGRankClosureOfInitialSegment, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT( datarec );
end );

#############################################################################
##
#F  PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL( <datarec> ) .  A p-G menu option 15
##
##  inputs data to the `pq' binary for option 15 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL, function( datarec )
end );

#############################################################################
##
#F  PqAPGOrbitRepresentativeOfLabel( <i> )  user version of A p-G menu option 15
#F  PqAPGOrbitRepresentativeOfLabel()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGOrbitRepresentativeOfLabel' performs option 15 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGOrbitRepresentativeOfLabel, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL( datarec );
end );

#############################################################################
##
#F  PQ_APG_WRITE_COMPACT_DESCRIPTION( <datarec> ) . . .  A p-G menu option 16
##
##  inputs data to the `pq' binary for option 16 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_WRITE_COMPACT_DESCRIPTION, function( datarec )
end );

#############################################################################
##
#F  PqAPGWriteCompactDescription( <i> )  user version of A p-G menu option 16
#F  PqAPGWriteCompactDescription()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGWriteCompactDescription' performs option 16 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGWriteCompactDescription, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_WRITE_COMPACT_DESCRIPTION( datarec );
end );

#############################################################################
##
#F  PQ_APG_AUTOMORPHISM_CLASSES( <datarec> ) . . . . . . A p-G menu option 17
##
##  inputs data to the `pq' binary for option 17 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PQ_APG_AUTOMORPHISM_CLASSES, function( datarec )
end );

#############################################################################
##
#F  PqAPGAutomorphismClasses( <i> ) . .  user version of A p-G menu option 17
#F  PqAPGAutomorphismClasses()
##
##  for the <i>th or default interactive {\ANUPQ} process, inputs data
##  to the `pq' binary
##
##  *Note:* For those  familiar  with  the  `pq'  binary, 
##  `PqAPGAutomorphismClasses' performs option 17 of the
##  Advanced $p$-Group Generation menu.
##
InstallGlobalFunction( PqAPGAutomorphismClasses, function( arg )
local datarec;
  ANUPQ_IOINDEX_ARG_CHK(arg);
  datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
  PQ_APG_AUTOMORPHISM_CLASSES( datarec );
end );

#E  anupqi.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 