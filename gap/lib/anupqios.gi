#############################################################################
####
##
#W  anupqios.gi         ANUPQ Share Package                       Greg Gamble
##
##  This file installs core functions used with iostreams.
##    
#H  @(#)$Id$
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqios_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  PQ_START( <workspace>, <setupfile> ) . . . open a stream for a pq process
##
##  ensures the images file written by the `pq' binary when in  the  Standard
##  Presentation menu is empty, opens an io stream  to  a  `pq'  process  (if
##  <setupfile> is `fail') or a file stream for a setup file (if  <setupfile>
##  is a filename i.e. a string) and returns  a  record  with  fields  `menu'
##  (current menu for the `pq' binary), `opts' (the runtime switches used  by
##  the `pq' process), `workspace' (the value of <workspace> which should  be
##  a positive integer), and `stream' (the io or file stream opened).
##
InstallGlobalFunction(PQ_START, function( workspace, setupfile )
local opts, iorec;
  PrintTo(ANUPQData.SPimages, ""); #to ensure it's empty
  if setupfile = fail then
    opts := [ "-G" ];
  else
    opts := [ "-i", "-k", "-g" ];
  fi;
  if workspace <> 10000000 then
    Append( opts, [ "-s", String(workspace) ] );
  fi;
  iorec := rec( menu := "SP", 
                opts := opts,
                workspace := workspace );
  if setupfile = fail then
    iorec.stream := InputOutputLocalProcess( ANUPQData.tmpdir, 
                                             ANUPQData.binary, 
                                             opts );
    if iorec.stream = fail then
      Error( "sorry! Run out of pseudo-ttys. Can't open an io stream.\n" );
    fi;
    FLUSH_PQ_STREAM_UNTIL(iorec.stream, 4, 2, PQ_READ_NEXT_LINE, IS_PQ_PROMPT);
  else
    iorec.stream := OutputTextFile(setupfile, false);
    iorec.setupfile := setupfile;
    ToPQk(iorec, [ "#call pq with flags: '",
                   JoinStringsWithSeparator(opts, " "),
                   "'" ]);
  fi;
  return iorec;
end );

#############################################################################
##
#F  PqStart(<G>,<workspace> : <options>) . Initiate interactive ANUPQ session
#F  PqStart(<G> : <options>)
#F  PqStart(<workspace> : <options>)
#F  PqStart( : <options>)
##
##  activate an iostream for an interactive {\ANUPQ} process (i.e.  `PqStart'
##  starts up a `pq' binary process and opens a {\GAP} iostream  to  ``talk''
##  to that process) and returns an integer <i> that can be used to  identify
##  that process. The argument <G>, if given, should be an *fp group* or  *pc
##  group* that the user  intends  to  manipute  using  interactive  {\ANUPQ}
##  functions. If `PqStart' is given an integer argument <workspace> then the
##  `pq' binary is started up with a workspace (an  integer  array)  of  size
##  <workspace> (i.e. $4 \times <workspace>$ bytes in a 32-bit  environment);
##  otherwise, the `pq' binary sets a default workspace of $10000000$.
##
##  The only <options> currently recognised  by  `PqStart'  are  `Prime'  and
##  `Exponent' (see~"Pq" for details) and if provided  they  are  essentially
##  global for the interactive {\ANUPQ} process, except that any  interactive
##  function interacting with the process and passing new  values  for  these
##  options will over-ride the global values.
##
InstallGlobalFunction(PqStart, function(arg)
local opts, iorec, G, workspace, optname;

  if 2 < Length(arg) then
    Error("at most two arguments expected.\n");
  fi;

  if not IsEmpty(arg) and IsGroup( arg[1] ) then
    G := arg[1];
    if not( IsFpGroup(G) or IsPcGroup(G) ) then
      Error( "argument <G> should be an fp group or a pc group\n" );
    fi;
    arg := arg{[2 .. Length(arg)]};
  fi;

  if not IsEmpty(arg) then
    workspace := arg[1];
    if not IsPosInt(workspace) then
      Error("argument <workspace> should be a positive integer.\n");
    fi;
  else
    workspace := 10000000;
  fi;

  iorec := PQ_START( workspace, fail );
  if IsBound( G ) then
    iorec.group := G;
  fi;
  iorec.calltype := "interactive";
  for optname in ANUPQGlobalOptions do
    SET_GLOBAL_PQ_OPTION(optname, iorec);
  od;

  Add( ANUPQData.io, iorec );
  return Length(ANUPQData.io);
end);

#############################################################################
##
#F  PqQuit( <i> )  . . . . . . . . . . . . Close an interactive ANUPQ session
#F  PqQuit()
##
##  closes the stream of the <i>th or default  interactive  {\ANUPQ}  process
##  and unbinds its `ANUPQData.io' record.
##
InstallGlobalFunction(PqQuit, function(arg)
local ioIndex;

  ioIndex := ANUPQ_IOINDEX(arg);
  # No need to bother about descending through the menus.
  CloseStream(ANUPQData.io[ioIndex].stream);
  Unbind(ANUPQData.io[ioIndex]);
end);

#############################################################################
##
#F  PqQuitAll() . . . . . . . . . . . .  Close all interactive ANUPQ sessions
##
##  closes the streams of all active interactive {\ANUPQ} process and unbinds
##  their `ANUPQData.io' records.
##
InstallGlobalFunction(PqQuitAll, function()
local ioIndex;

  for ioIndex in [1 .. Length(ANUPQData.io)] do
    if IsBound(ANUPQData.io[ioIndex]) then
      CloseStream(ANUPQData.io[ioIndex].stream);
      Unbind(ANUPQData.io[ioIndex]);
    fi;
  od;
end);

#############################################################################
##
#F  ANUPQ_IOINDEX . . . . the number identifying an interactive ANUPQ session
##
##  returns the index of the record in the `ANUPQData.io' list  corresponding
##  to an interactive {\ANUPQ} session. With  no  argument  the  first  bound
##  index in `ANUPQData.io' is returned. With integer (first)  argument  <i>,
##  <i> is returned if `ANUPQData.io[<i>]' is bound.
##
InstallGlobalFunction(ANUPQ_IOINDEX, function(arglist)
local ioIndex;

  if IsEmpty(arglist) then
    # Find the first bound ioIndex
    ioIndex := 1;
    while not(IsBound(ANUPQData.io[ioIndex])) and 
          ioIndex < Length(ANUPQData.io) do
      ioIndex := ioIndex + 1;
    od;
    if IsBound(ANUPQData.io[ioIndex]) then
      return ioIndex;
    else
      Info(InfoANUPQ + InfoWarning, 1, 
           "No interactive ANUPQ sessions are currently active");
      return fail;
    fi;
  elif IsBound(ANUPQData.io[ arglist[1] ]) then
    return arglist[1];
  else
    Error("no such interactive ANUPQ session\n");
  fi;
end);

#############################################################################
##
#F  ANUPQ_IOINDEX_ARG_CHK .  Checks ANUPQ_IOINDEX has the right no. of arg'ts
##
InstallGlobalFunction(ANUPQ_IOINDEX_ARG_CHK, function(arglist)
  if Length(arglist) > 1 then
    Info(InfoANUPQ + InfoWarning, 1,
         "Expected 0 or 1 arguments, all but first argument ignored");
  fi;
end);

#############################################################################
##
#F  PqProcessIndex( <i> ) . . . . . . . . . . . User version of ANUPQ_IOINDEX
#F  PqProcessIndex()
##
##  If given (at least) one integer  argument  `PqProcessIndex'  returns  its
##  first argument if it corresponds to  an  active  interactive  process  or
##  raises an error; otherwise, with no arguments,  it  returns  the  default
##  active interactive process. If the user provides more than  one  argument
##  then all arguments other than the  first  argument  are  ignored  (and  a
##  warning is issued to `Info' at `InfoANUPQ' or `InfoWarning' level 1).
##
InstallGlobalFunction(PqProcessIndex, function(arg)
  ANUPQ_IOINDEX_ARG_CHK(arg);
  return ANUPQ_IOINDEX(arg);
end);

#############################################################################
##
#F  PqProcessIndices() . . . . the list of active interactive ANUPQ processes
##
##  returns the list of (integer) indices of all active interactive  {\ANUPQ}
##  processes.
##
InstallGlobalFunction(PqProcessIndices, function()
  return Filtered( [1..Length(ANUPQData.io)], i -> IsBound( ANUPQData.io[i] ) );
end);

#############################################################################
##
#F  IsPqProcessAlive( <i> ) . .  checks an interactive ANUPQ process iostream
#F  IsPqProcessAlive()
##
##  return  `true'  if  the  {\GAP}  iostream  of  the  <i>th  (or   default)
##  interactive {\ANUPQ} process is alive (i.e. can still be written to),  or
##  `false', otherwise.
##
InstallGlobalFunction(IsPqProcessAlive, function(arg)
  ANUPQ_IOINDEX_ARG_CHK(arg);
  return not IsEndOfStream( ANUPQData.io[ ANUPQ_IOINDEX(arg) ].stream );
end);

#############################################################################
##
#V  PQ_MENUS . . . . . . . . . . . data describing the menus of the pq binary
##
##  a record whose fields are abbreviated names of  the  menus  of  the  `pq'
##  binary and whose values are themselves records with fields:
##
##    name
##        long name of menu;
##    depth
##        the number of times 0 must be passed to the `pq' binary for  it  to
##        exit;
##    prev
##        the menu one gets to from the current menu via option 0 (or `""' in
##        the case of the menu `SP';
##    nextopt
##        a record whose fields are the new menus of greater depth  that  can
##        be reached by an option of the current menu, and whose  values  are 
##        the corresponding numbers of the options of the current menu needed
##        to get to the new menus.
##
InstallValue(PQ_MENUS, rec(
  SP  := rec( name  := "Standard Presentation Menu",
              depth := 1, prev  := "",   nextopt := rec( pQ := 7 ) ),
  pQ  := rec( name  := "(Main) p-Quotient Menu",
              depth := 2, prev  := "SP", nextopt := rec( pG  := 9, ApQ := 8 ) ),
  pG  := rec( name  := "(Main) p-Group Generation Menu",
              depth := 3, prev  := "pQ", nextopt := rec( ApG := 6 ) ),
  ApQ := rec( name  := "Advanced p-Quotient Menu",
              depth := 3, prev  := "pQ", nextopt := rec() ),
  ApG := rec( name  := "Advanced p-Group Gen'n Menu",
              depth := 4, prev  := "pG", nextopt := rec() )
  ) );

#############################################################################
##
#F  PQ_MENU( <datarec>, <newmenu> ) . . . . . . change/get menu of pq process
#F  PQ_MENU( <datarec> )
##
InstallGlobalFunction(PQ_MENU, function(arg)
local datarec, newmenu, nextmenu, tomenu;
  datarec := arg[1];
  #!!!! Must check Option 1 or 3 of SP or pQ menu done before entering ApQ
  if 2 = Length(arg) then
    newmenu := arg[2];
    while datarec.menu <> newmenu do
      if PQ_MENUS.(datarec.menu).depth >= PQ_MENUS.(newmenu).depth then
        datarec.menu := PQ_MENUS.(datarec.menu).prev;
        tomenu := PQ_MENUS.(datarec.menu).name;
        ToPQk(datarec, [ 0 , "  #to ", tomenu]);
        FLUSH_PQ_STREAM_UNTIL(datarec.stream, 2, 2, PQ_READ_NEXT_LINE,
                              IS_PQ_PROMPT);
      elif datarec.menu = "pQ" and newmenu = "ApQ" then
        datarec.menu := "ApQ";
        tomenu := PQ_MENUS.(datarec.menu).name;
        ToPQk(datarec, [ PQ_MENUS.pQ.nextopt.ApQ, "  #to ", tomenu ]);
        FLUSH_PQ_STREAM_UNTIL(datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
                              IS_PQ_PROMPT);
      else
        nextmenu := RecNames( PQ_MENUS.(datarec.menu).nextopt )[1];
        tomenu := PQ_MENUS.(nextmenu).name;
        ToPQk(datarec, [ PQ_MENUS.(datarec.menu).nextopt.(nextmenu),
                         "  #to ", tomenu ]);
        FLUSH_PQ_STREAM_UNTIL(datarec.stream, 4, 2, PQ_READ_NEXT_LINE,
                              IS_PQ_PROMPT);
        datarec.menu := nextmenu;
      fi;
    od;
  fi;
  return datarec.menu;
end);

#############################################################################
##
#F  IS_PQ_PROMPT( <line> ) . . . .  checks whether the line is a prompt of pq
##
##  returns `true' if  the  string  <line>  ends  in  `": "'  or  `"? "',  or
##  otherwise returns `false'.
##
InstallGlobalFunction(IS_PQ_PROMPT, function(line)
local len;
  len := Length(line);
  return 1 < len  and line[len] = ' ' and line[len - 1] in ":?";
end);

#############################################################################
##
#F  IS_PQ_REQUEST( <line> ) . .  checks whether the line is a request from pq
##
##  returns `true' if the string <line> ends in `"!\n"' or otherwise  returns
##  `false'.
##
InstallGlobalFunction(IS_PQ_REQUEST, function(line)
local len;
  len := Length(line);
  return 1 < len  and line{[1 .. 3]} = "GAP" and line{[len - 1 .. len]} = "!\n";
end);

#############################################################################
##
#F  PQ_READ_ALL_LINE(<iostream>) . read line from stream until sentinel char.
##
##  Essentially, like `ReadLine' but does not return a line fragment; if  the
##  initial `ReadLine' call doesn't return `fail', it waits until it has  all
##  the line (i.e. a line that ends with a '\n',  or  "? "  or  ": ")  before
##  returning.
##
InstallGlobalFunction(PQ_READ_ALL_LINE, function(iostream)
local line, moreOfline;

  line := "";
  repeat
    moreOfline := ReadLine(iostream);
    if moreOfline <> fail then
      Append(line, moreOfline);
    #else
    #  Sleep(1);
    fi;
    Info(InfoANUPQ, 5, "PQ_READ_ALL_LINE line: ", line);
  until 0 < Length(line) and ( line[Length(line)] = '\n' or 
                               IS_PQ_PROMPT(line) or 
                               IS_PQ_REQUEST(line) );
  return line;
end);

#############################################################################
##
#F  PQ_READ_NEXT_LINE .  read complete line from stream but never return fail
##
##  Essentially, like `PQ_READ_ALL_LINE' but we know there is a complete line
##  to be got, so we wait for it, before returning.
##
InstallGlobalFunction(PQ_READ_NEXT_LINE, function(iostream)
local line;

  line := PQ_READ_ALL_LINE(iostream);
  while line = fail do
    #Sleep(1);
    line := PQ_READ_ALL_LINE(iostream);
  od;
  return line;
end);

#############################################################################
##
#F  FLUSH_PQ_STREAM_UNTIL(<stream>,<infoLev>,<infoLevMy>,<readln>,<IsMyLine>)
##  . . .  . . . . . . . . . . . read lines from a stream until a wanted line
##
##  calls <readln> (which should be one of `ReadLine', `PQ_READ_NEXT_LINE' or
##  `PQ_READ_ALL_LINE') to read lines from an  stream  <stream>  and  `Info's
##  each line read at `InfoANUPQ' level <infoLev> until a line <line> is read
##  for  which  `<IsMyLine>(<line>)'  is  `true';  <line>  is  `Info'-ed   at
##  `InfoANUPQ' level  <infoLevMy>  and  returned.  <IsMyLine>  should  be  a
##  boolean-valued function that expects a string as its only  argument,  and
##  <infoLev> and <infoLevMy> should be positive integers. An <infoLevMy>  of
##  10 means that the line  <line>  matched  by  `<IsMyLine>(<line>)'  should
##  never be `Info'-ed.
##
InstallGlobalFunction(FLUSH_PQ_STREAM_UNTIL, 
function(stream, infoLev, infoLevMy, readln, IsMyLine)
local line;

  if not IsInputStream(stream) then
    return fail;
  fi;

  line := readln(stream);
  while not IsMyLine(line) do
    Info(InfoANUPQ, infoLev, Chomp(line));
    line := readln(stream);
  od;
  if line <> fail and infoLevMy < 10 then
    Info(InfoANUPQ, infoLevMy, Chomp(line));
  fi;
  return line;
end);

#############################################################################
##
#F  ToPQk( <datarec>, <list> ) . . . . . . . . . writes a list to a pq stream
##
##  writes list <list> to iostream `<datarec>.stream' and `Info's  <list>  at
##  `InfoANUPQ' level 3 after a ```ToPQ> ''' prompt, and  returns  `true'  if
##  successful and `fail' otherwise. The ``k'' at the  end  of  the  function
##  name is mnemonic for ``keyword'' (for  ``keyword''  inputs  to  the  `pq'
##  binary one never wants to flush output).
##
InstallGlobalFunction(ToPQk, function(datarec, list)
local string;

  if not IsOutputTextStream(datarec.stream) and 
     IsEndOfStream(datarec.stream) then
    Info(InfoANUPQ + InfoWarning, 1, "Sorry. Process stream has died!");
    return fail;
  fi;
  string := Concatenation( List(list, x -> String(x)) );
  Info(InfoANUPQ, 3, "ToPQ> ", string);
  return WriteLine(datarec.stream, string);
end);

#############################################################################
##
#F  PqRead( <i> )  . . .  primitive read of a single line from ANUPQ iostream
#F  PqRead()
##
##  read a complete line of  {\ANUPQ}  output,  from  the  <i>th  or  default
##  interactive {\ANUPQ} process, if there is output to be read  and  returns
##  `fail' otherwise. When successful, the  line  is  returned  as  a  string
##  complete with trailing newline, colon, or question-mark character. Please
##  note that it is possible to be ``too  quick''  (i.e.~the  return  can  be
##  `fail' purely because the output from {\ANUPQ} is not there yet), but  if
##  `PqRead' finds any output at all, it waits for a complete line.  `PqRead'
##  also writes the line read via `Info' at `InfoANUPQ' level 2.  It  doesn't
##  try to distinguish banner and menu output from other output of  the  `pq'
##  binary.
##
InstallGlobalFunction(PqRead, function(arg)
local line;

  ANUPQ_IOINDEX_ARG_CHK(arg);
  line := PQ_READ_ALL_LINE( ANUPQData.io[ ANUPQ_IOINDEX(arg) ].stream );
  Info(InfoANUPQ, 2, Chomp(line));
  return line;
end);

#############################################################################
##
#F  PqReadAll( <i> ) . . . . . read all current output from an ANUPQ iostream
#F  PqReadAll()
##
##  read and return as many *complete* lines of  {\ANUPQ}  output,  from  the
##  <i>th or default interactive {\ANUPQ} process, as there are to  be  read,
##  *at the time of the call*,  as  a  list  of  strings  with  any  trailing
##  newlines removed and returns the empty list otherwise.  `PqReadAll'  also
##  writes each line read via `Info' at `InfoANUPQ' level 2. It  doesn't  try
##  to distinguish banner and menu output  from  other  output  of  the  `pq'
##  binary. Whenever `PqReadAll' finds only a partial line, it waits for  the
##  complete line, thus increasing the probability that it has  captured  all
##  the output to be had from {\ANUPQ}.
##
InstallGlobalFunction(PqReadAll, function(arg)
local lines, stream, line;

  ANUPQ_IOINDEX_ARG_CHK(arg);
  lines := [];
  stream := ANUPQData.io[ ANUPQ_IOINDEX(arg) ].stream;
  line := PQ_READ_ALL_LINE(stream);
  while line <> fail do
    line := Chomp(line);
    Info(InfoANUPQ, 2, line);
    Add(lines, line);
    line := PQ_READ_ALL_LINE(stream);
  od;
  return lines;
end);

#############################################################################
##
#F  PqReadUntil( <i>, <IsMyLine> ) .  read from ANUPQ iostream until a cond'n
#F  PqReadUntil( <IsMyLine> )
#F  PqReadUntil( <i>, <IsMyLine>, <Modify> )
#F  PqReadUntil( <IsMyLine>, <Modify> )
##
##  read complete lines  of  {\ANUPQ}  output,  from  the  <i>th  or  default
##  interactive {\ANUPQ} process, ``chomps'' them (i.e.~removes any  trailing
##  newline character), emits them to `Info' at `InfoANUPQ' level 2  (without
##  trying to distinguish banner and menu output from  other  output  of  the
##  `pq' binary), and applies the function <Modify> (where <Modify>  is  just
##  the identity map/function for the first two forms)  until  a  ``chomped''
##  line  <line>  for  which  `<IsMyLine>(  <Modify>(<line>)  )'   is   true.
##  `PqReadUntil' returns the list of <Modify>-ed ``chomped'' lines read.
##
InstallGlobalFunction(PqReadUntil, function(arg)
local idx1stfn, stream, IsMyLine, Modify, lines, line;

  idx1stfn := First([1..Length(arg)], i -> IsFunction(arg[i]));
  if idx1stfn = fail then
    Error("expected at least one function argument\n");
  elif Length(arg) > idx1stfn + 1 then
    Error("expected 1 or 2 function arguments, not ", 
          Length(arg) - idx1stfn + 1, "\n");
  elif idx1stfn > 2  then
    Error("expected 0 or 1 integer arguments, not ", idx1stfn - 1, "\n");
  else
    stream := ANUPQData.io[ ANUPQ_IOINDEX(arg{[1..idx1stfn - 1]}) ].stream;
    IsMyLine := arg[idx1stfn];
    if idx1stfn = Length(arg) then
      Modify := line -> line; # The identity function
    else
      Modify := arg[Length(arg)];
    fi;
    lines := [];
    repeat
      line := Chomp( PQ_READ_NEXT_LINE(stream) );
      Info(InfoANUPQ, 2, line);
      line := Modify(line);
      Add(lines, line);
    until IsMyLine(line);
    return lines;
  fi;
end);

#############################################################################
##
#F  PqWrite( <i>, <string> ) . . . . . . .  primitive write to ANUPQ iostream
#F  PqWrite( <string> )
##
##  write <string> to the <i>th  or  default  interactive  {\ANUPQ}  process;
##  <string> must be in exactly the form the {\ANUPQ} standalone expects. The
##  command is echoed via `Info' at `InfoANUPQ' level 3 (with a  ```ToPQ> '''
##  prompt); i.e.~do `SetInfoLevel(InfoANUPQ, 3);' to see what is transmitted
##  to the `pq' binary. `PqWrite' returns `true' if successful in writing  to
##  the stream of the interactive {\ANUPQ} process, and `fail' otherwise.
##
InstallGlobalFunction(PqWrite, function(arg)
local ioIndex, line;

  if Length(arg) in [1, 2] then
    ioIndex := ANUPQ_IOINDEX(arg{[1..Length(arg) - 1]});
    return ToPQk( ANUPQData.io[ioIndex], arg{[Length(arg)..Length(arg)]} );
  else
    Error("expected 1 or 2 arguments ... not ", Length(arg), " arguments\n");
  fi;
end);

#############################################################################
##
#F  ToPQ(<datarec>, <list>) .  write list to pq stream (& for iostream flush)
##
##  calls `ToPQk' to write list <list>  to  iostream  `<datarec>.stream'  and
##  `Info' <list> at `InfoANUPQ' level 3 after  a  ```ToPQ> '''  prompt,  and
##  then, if we are not just writing a setup  file  (determined  by  checking
##  whether `<datarec>.setupfile' is bound), calls `FLUSH_PQ_STREAM_UNTIL' to
##  flush all `pq' output at `InfoANUPQ' level 2, and finally returns  `true'
##  if successful and `fail' otherwise. If we are not writing  a  setup  file
##  the last line flushed (or `fail') is saved in `<datarec>.line'.
##
InstallGlobalFunction(ToPQ, function(datarec, list)
local ok;
  ok := ToPQk(datarec, list);
  if ok = true and not IsBound( datarec.setupfile ) then
    datarec.line := FLUSH_PQ_STREAM_UNTIL( datarec.stream, 2, 2,
                                           PQ_READ_NEXT_LINE, 
                                           line -> IS_PQ_PROMPT(line) or
                                                   IS_PQ_REQUEST(line) );
  
    while datarec.line <> fail and 
          PositionSublist(
              datarec.line, "GAP, please compute stabiliser!") <> fail do

      HideGlobalVariables( "ANUPQglb", "F", "gens", "relativeOrders",
                           "ANUPQsize", "ANUPQagsize" );
      Read( Filename( ANUPQData.tmpdir, "GAP_input" ) );
      Read( Filename( ANUPQData.tmpdir, "GAP_rep" ) );
      UnhideGlobalVariables( "ANUPQglb", "F", "gens", "relativeOrders",
                             "ANUPQsize", "ANUPQagsize" );
      ToPQ( datarec, [ "pq, stabiliser is ready!" ] );
    od;
  
    if IsString(datarec.line) then
      ok := true;
    else
      ok := fail;
    fi;
  fi;
  return ok;
end);

#############################################################################
##
#F  ANUPQ_ARG_CHK(<len>,<funcname>,<arg1>,<arg1type>,<arg1err>,<args>,<opts>)
##
##  This checks the  argument  list  <args>  for  functions  that  have  both
##  interactive and non-interactive versions; <len> is the length  of  <args>
##  for the non-interactive  version  of  the  function,  <funcname>  is  the
##  generic name of the function and is used  for  determining  the  list  of
##  options for the function when they  are  passed  in  one  of  the  {\GAP}
##  3-compatible ways only available non-interactively,  `<datarec>.(<arg1>)'
##  is where, non-interactively, the  first  argument  of  <args>  should  be
##  stored (and where interactively the corresponding variable  is  *already*
##  stored), <arg1type> is the type of the first argument when  the  function
##  is called non-interactively, <arg1err> is the error  message  given  when
##  non-interactively the first argument  is  not  of  type  <arg1type>,  and
##  <args>  is  the  list  of  arguments  passed  to  the  called   function.
##  `ANUPQ_ARG_CHK' returns <datarec> which  is  either  `ANUPQData'  in  the
##  non-interactive  case  or  `ANUPQData.io[<i>]'  for  some  <i>   in   the
##  interactive  case,  after   setting   <datarec>.calltype'   to   one   of
##  `"interactive"', `"non-interactive"' or `"GAP3compatible"'.  When  called
##  with options (i.e. not in the `"GAP3compatible"' way) it is checked  that
##  each option name (string) in the list <opts> is supplied (these represent
##  the minimal list of options the user must supply).
##
InstallGlobalFunction(ANUPQ_ARG_CHK, 
function(len, funcname, arg1, arg1type, arg1err, args, opts)
local interactive, ioArgs, datarec, optrec, optname, optnames;
  interactive := Length(args) < len or IsInt( args[1] );
  if interactive then
    ioArgs := args{[1..Length(args) - len + 1]};
    ANUPQ_IOINDEX_ARG_CHK(ioArgs);
    datarec := ANUPQData.io[ ANUPQ_IOINDEX(ioArgs) ];
    datarec.outfname := ANUPQData.outfile; # not always needed
    for optname in opts do
      VALUE_PQ_OPTION(optname, fail, datarec);
    od;
    #datarec.calltype := "interactive";    # PqStart sets this
  elif Length(args) = len then
    for optname in opts do
      VALUE_PQ_OPTION(optname, fail);
    od;
    if not arg1type( args[1] ) then
      Error( "first argument <args[1]> must be ", arg1err, ".\n" );
    fi;
    ANUPQData.ni := PQ_START( VALUE_PQ_OPTION( "PqWorkspace", 10000000 ),
                              VALUE_PQ_OPTION( "SetupFile" ) );
    datarec := ANUPQData.ni;
    datarec.(arg1) := args[1];
    if IsBound( datarec.setupfile ) then
      datarec.outfname := "PQ_OUTPUT";
    else
      datarec.outfname := ANUPQData.outfile; # not always needed
    fi;
    datarec.calltype := "non-interactive";
  else
    # GAP 3 way of passing options is supported in non-interactive use
    if IsRecord(args[len + 1]) then
      optrec := ShallowCopy(args[len + 1]);
      optnames := Set( REC_NAMES(optrec) );
      SubtractSet( optnames, Set( ANUPQoptions.(funcname) ) );
      if not IsEmpty(optnames) then
        Error(ANUPQoptError( funcname, optnames ), "\n");
      fi;
    else
      optrec := ANUPQextractOptions(funcname, args{[len + 1 .. Length(args)]});
    fi;
    PushOptions(optrec);
    PQ_FUNCTION.(funcname)( args{[1..len]} );
    PopOptions();
    datarec := ANUPQData.ni;
    datarec.calltype := "GAP3compatible";
  fi;
  return datarec;
end );

#############################################################################
##
#F  PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL( <datarec> )
##
##  writes the final commands to the `pq' stream/setup file so that the  `pq'
##  binary makes a clean exit.
##
InstallGlobalFunction(PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL, function(datarec)
local output, proc;
  PQ_MENU(datarec, "SP");
  ToPQk(datarec, [ "0  #exit program" ]);
  CloseStream(datarec.stream);

  if IsBound( datarec.setupfile ) then
    Info(InfoANUPQ, 1, "Input file: '", datarec.setupfile, "' written.");
    Info(InfoANUPQ, 1, "Run `pq' with '", datarec.opts, "' flags.");
    Info(InfoANUPQ, 1, "The result will be saved in: '", 
                       datarec.outfname, "'.");
  fi;
end );

#E  anupqios.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
