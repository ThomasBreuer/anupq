#############################################################################
####
##
#A  anupq.gi                 ANUPQ share package               Eamonn O'Brien
#A                                                             & Frank Celler
##
#A  @(#)$Id$
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##
#H  $Log$
#H  Revision 1.20  2001/08/30 01:09:54  gap
#H  - Make better use of InfoANUPQ, levels now mean:
#H    1:non-(timing,memory usage) output from `pq' and general info.
#H    2:timing,memory usage output from `pq'
#H    3:non-user invoked output from `pq' of nature of 1, 2
#H    4:commands sent to `pq' (behind a `ToPQ> ' prompt)
#H    5:menus and prompts and other info. that is usually meaningless to a user
#H    Still need to rethink `OutputLevel := 0' in this scheme. For the moment
#H    I've added a behind-the-scenes option: `nonuser' which makes all the
#H    output from `Pq', `PqDescendants' and `StandardPresentation' etc. get
#H    Info-ed at ANUPQ level 3.
#H  - Rationalised the `Display' functions. Now there is just
#H    `PqDisplayPcPresentation' and it uses whatever is the current `pq' menu.
#H  - Rationalised the ..Set..PrintLevel functions in the same way, except it
#H    is now called `PqSetOutputLevel' (like the `OutputLevel' option).
#H  - A number of functions now call `PQ_SET_GROUP_DATA' which may in turn
#H    call `PQ_DATA' which between them set the fields `name', `class' (current
#H    class), `forder' (factored order) and `ngens' (the no. of gen'rs for each
#H    class up to the current class) of the data record associated with an
#H    interactive process.
#H  - There are now functions: `PqFactoredOrder', `PqOrder', `PqNrPcGenerators',
#H    `PqPClass' and `PqWeight' (weight of a generator) which determine their
#H    values by looking at the fields `class', `forder' and `ngens' of the data
#H    record associated with a process. `PqCurrentGroup' is not useful yet.
#H  - Fixed bug in `PqDoConsistencyCheck'.
#H  - `PqDoExponentChecks', `PqDisplayStructure' (was `PqPrintStructure') and
#H    `PqDisplayAutomorphisms' now have their non-process-id arguments as the
#H    option `Bounds'.
#H  - There is now a guard against `pq' seg-faults just from changing menu.
#H     GG
#H
#H  Revision 1.19  2001/08/19 20:57:20  gap
#H  Now more careful with the compatibility with GAP 4.2 (ensure that some
#H  other function hasn't already defined the GAP 4.3 functions we need).
#H  `PQ_READ_ALL_LINE' and `PQ_READ_NEXT_LINE' now use the library function
#H  `ReadAllLine' just committed. - GG
#H
#H  Revision 1.18  2001/08/17 20:10:53  gap
#H  Added options `BasicAlgorithm' and `TailorOutput' used in descendants
#H  functions, allowing now the full generality of the sub-options available
#H  in the construction of descendants menu item of the `pq' binary.
#H  Now when `PqPc{,SP}Presentation' is called the `name', `class' and `order'
#H  fields of the relevant `ANUPQData' record are set. Similarly when `PqPCover'
#H  is called the `pcoverclass' and `pcoverorder' are set.
#H  `PqRestorePcPresentation' now calls a display function in order to set the
#H  `name', `class' and `order' fields of the relevant `ANUPQData' record.
#H  (Actually, all of the above is actually done by the capitalised versions of
#H  these commands.) - GG
#H
#H  Revision 1.17  2001/08/14 15:05:39  gap
#H  Added option `QueueFactor' (used by `PqNextClass', when automorphisms
#H  have been added previously ... we don't check for that, just offer `pq'
#H  a queue factor = `QueueFactor' or 15 (if not provided by the user) if
#H  it asks for it). `PqSetMaximalOccurrences' determines the number of
#H  generators by `PQ_PQUOTIENT_CHK' which may need further modification.
#H  Small bug seen when there are comments at end of line in `PqExample' fixed.
#H  - GG
#H
#H  Revision 1.16  2001/08/10 16:51:24  gap
#H  Amended a comment. - GG
#H
#H  Revision 1.15  2001/08/10 16:46:04  gap
#H  Enhanced `PqExample' to work with more complicated files. Fixed minor bug
#H  in `...Display..' functions (ensured prompt was Info-ed at the right level).
#H  - GG
#H
#H  Revision 1.14  2001/08/08 21:37:06  gap
#H  Some fine-tuning of `PqExample' and `PQ_EVALUATE'. - GG
#H
#H  Revision 1.13  2001/08/08 13:03:42  gap
#H  Now just close the stream when ending a non-interactive function call,
#H  rather than giving the instructions to the `pq' to exit (doing this
#H  occasionally created a problem where GAP tried to read past the end of
#H  a stream). There is also now the final version of `PqExample'. - GG
#H
#H  Revision 1.12  2001/08/05 15:39:46  gap
#H  Fixed bug reported by Werner in `PQ_AUT_INPUT' ... the no. of generator
#H  images is now RankPGroup(gp) as its hould have been. There's also a
#H  preliminary version of `PqExample'. - GG
#H
#H  Revision 1.11  2001/08/02 17:27:08  gap
#H  Fixed a bug I introduced earlier in the week. Noone at Oberwolfach is looking
#H  at this ... otherwise they would have noticed. Added a `Relators' option so
#H  that unexpanded (by GAP) relators may now be passed to the `pq' binary. A
#H  function `PqGAPRelators' will convert the strings of a `Relators' option to
#H  relators that GAP understands. - GG
#H
#H  Revision 1.10  2001/07/25 20:04:01  gap
#H  Now treat all save/restore commands in a consistent way. All Standard
#H  Presentation menu commands are now there. - GG
#H
#H  Revision 1.9  2001/07/05 21:14:26  gap
#H  Bug fixes. ANUPQ_ARG_CHK now checks required options are set ... all
#H  functions that call it have been adjusted. The option `StepSize' had
#H  been mis-spelt `Stepsize' twice. - GG
#H
#H  Revision 1.8  2001/06/21 23:04:20  gap
#H  src/*, include/*, Makefile.in:
#H   - pq binary now calls itself version 1.5 (global variable PQ_VERSION
#H     added in include/pq_author.h for this)
#H   - added -v option (gives pq version)
#H   - added -G option (equivalent to `-g -i -k' + assumes talking to GAP via
#H     an iostream ... extern variable: GAP4iostream added in include/global.h
#H     for this)
#H   - some idiosyncrasies in the menus cleaned up.
#H  standalone-doc/*:
#H   - updated ... see newly added header in guide.tex for details.
#H  gap/lib/anustab.g[id]:
#H   - replace gap/lib/anustab.g ... original code is now in function
#H     `PqStabiliserOfAllowableSubgroup'
#H  init.g,read.g:
#H   - now read in gap/lib/anustab.g[id] so that `PqStabiliserOfAllowableSubgroup'
#H     is defined. ANUPQ share package now calls itself Version 1.1.
#H  gap/lib/anupqhead.g:
#H   - now uses -v option of pq to extract the version. ANUPQData.infile is no
#H     longer defined.
#H  gap/lib/*.g[id] (other):
#H   - now when not being called to create a setup file GAP calls pq with the -G
#H     option. The setup file has comment on first line telling user to use:
#H     the `-i -g -k' flags. Modifications made to call
#H     `PqStabiliserOfAllowableSubgroup' in the `ToPQ' function when a
#H     `PQ_REQUEST' is detected.
#H   - `PQ_REQUEST' takes a string as argument and returns a boolean. It detects
#H     when a `GAP, please compute stabilisers!\n' request has been emitted by
#H     the `pq' binary.
#H  - GG
#H
#H  Revision 1.7  2001/06/19 17:21:39  gap
#H  - Non-interactive functions now use iostreams (when not creating a SetupFile).
#H  - The `Verbose' option has now been eliminated; it's function is now provided
#H    by using `InfoANUPQ'.
#H  - Data recorded for a non-interactive function is now stored in the record
#H    `ANUPQData.ni' entirely analogous to the interactive function records
#H    `ANUPQData.io[<i>]'.
#H  - `ToPQ' now takes care of the cases where the `pq' binary calls GAP to
#H    compute stabilisers.
#H  - A header was added to `anustab.g'. - GG
#H
#H  Revision 1.6  2001/06/15 17:43:49  gap
#H  Correcting `success' variable check. - GG
#H
#H  Revision 1.5  2001/06/02 23:18:56  gap
#H  Bug fixes. - GG
#H
#H  Revision 1.4  2001/05/24 22:05:03  gap
#H  Added interactive versions of `[Epimorphism][Pq]StandardPresentation' and
#H  factored out as separate functions the various menu items these functions
#H  use. - GG
#H
#H  Revision 1.3  2001/05/17 22:40:57  gap
#H  pkg/anupq:
#H    Factored out the common code for interactive and non-interactive versions
#H    of `Pq' and `PqEpimorphism' and defined the two menu item functions
#H    `PqPcPresentation' and `PqWritePcPresentation' on which they depend.
#H    The intention is to put all functions based on menu items of the `pq'
#H    binary in the files gap/lib/anupqi.g[id]. - GG
#H
#H  Revision 1.2  2001/05/10 17:33:23  gap
#H  gap/lib/anupqios.g[id], doc/interact.tex:
#H    - defined and documented various interactive functions, in particular,
#H      `PqStart', `PqQuit', `PqQuitAll' and an interactive version of `Pq'.
#H  doc/intro.tex:
#H    - now describes `ANUPQData' and `InfoANUPQ'.
#H    - the Authors are in their own section.
#H  gap/lib/anupq4r2cpt.g[id]:
#H    - define functions as required for GAP 4.2 compatibility.
#H  - GG
#H
#H  Revision 1.1  2001/04/21 21:15:40  gap
#H  lib/
#H     *.g,*.gd:
#H     - following global variables modified to have `Pq' in them:
#H       `LetterInt' -> `PqLetterInt' (now defined in `anupga.g[id]')
#H       `EpimorphismStandardPresentation' -> `EpimorphismPqStandardPresentation'
#H       `StandardPresentation' -> `PqStandardPresentation'
#H       `FpGroupPcGroup' -> `PqFpGroupPcGroup'
#H       `IsIsomorphicPGroup' -> `IsPqIsomorphicPGroup'
#H       The last four functions now have methods of the same name as
#H       previously which are equivalent to the functions with `Pq' in them.
#H     anupqhead.g:
#H     - new file: defines `ANUPQData' record, `InfoANUPQ' and sets its level to 1,
#H       and outputs a banner.
#H     anupqprop.gd:
#H     - new file: contains previous contents of `anupq.gd'
#H     anupqopt.gd, anupqopt.gi:
#H     - new files: so far defines `ANUPQoptions', `SET_ANUPQ_OPTIONS'
#H     anupq.g -> anupq.gd, anupq.gi
#H     - headers put on files
#H     - `anupq.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anupq.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     anupq.gi:
#H     - `ANUPQoptions' moved to `anupqopt.g[id]' and generalised.
#H     - `Pq'
#H       now accepts options; modified error messages ... usage now says to use
#H       options
#H     anupga.g -> anupga.gd, anupga.gi
#H     - headers put on files
#H     - `anupga.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anupga.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     - `PqDescendants'
#H       now accepts options; its options are a field of the record in
#H       `ANUPQoptions' defined in `anupqopt.g[id]'
#H     anusp.g -> anusp.gd, anusp.gi
#H     - headers put on files
#H     - `anusp.gd' has all the `DeclareGlobalFunction' and `DeclareGlobalVariable'
#H       commands, and `anusp.gi' is the old `.g' file converted to using
#H       `InstallGlobalFunction' and `InstallValue'.
#H     - list of options for `StandardPresentation' etc. is now a field of the
#H       record `ANUPQoptions' in `anupqopt.g[id]'.
#H     - Operations/Methods declared and installed for
#H       `EpimorphismStandardPresentation', `StandardPresentation' and
#H       `FpGroupPcGroup', `IsIsomorphicPGroup' and each has a function
#H       counterpart with a `Pq' in its name.
#H     - `EpimorphismPqStandardPresentation', `PqStandardPresentation' now
#H       accept options. Their non-`Pq' method counterparts only accept
#H       options.
#H  - GG
#H
#H  Revision 1.2  2000/07/12 17:00:06  werner
#H  Further work towards completing the GAP 4 interface to the ANU PQ.
#H                                                                      WN
#H
#H  Revision 1.1.1.1  1998/08/12 18:50:54  gap
#H  First attempt at adapting the ANU pq to GAP 4. 
#H
##
Revision.anupq_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  ANUPQDirectoryTemporary( <dir> ) . . . . .  redefine ANUPQ temp directory
##
##  calls the UNIX command `mkdir' to create <dir>, which must be  a  string,
##  and if successful a directory  object  for  <dir>  is  both  assigned  to
##  `ANUPQData.tmpdir' and returned. The field  `ANUPQData.outfile'  is  also
##  set to be a file in `ANUPQData.tmpdir', and on exit from {\GAP} <dir>  is
##  removed.
##
InstallGlobalFunction(ANUPQDirectoryTemporary, function(dir)
local created;

  # check arguments
  if not IsString(dir) then
    Error(
      "usage: ANUPQDirectoryTemporary( <dir> ) : <dir> must be a string.\n");
  fi; 

  # create temporary directory
  created := Process(DirectoryCurrent(),
                     Filename( DirectoriesSystemPrograms(), "sh" ),
                     InputTextUser(),
                     OutputTextUser(),
                     [ "-c", Concatenation("mkdir ", dir) ]);
  if created = fail then
    return fail;
  fi;

  Add( DIRECTORIES_TEMPORARY, dir );
  ANUPQData.tmpdir  := Directory(dir);
  ANUPQData.outfile := Filename(ANUPQData.tmpdir, "PQ_OUTPUT");
  return ANUPQData.tmpdir;
end);

#############################################################################
##
#F  ANUPQerrorPq( <param> ) . . . . . . . . . . . . . . . . . report an error
##
InstallGlobalFunction( ANUPQerrorPq, function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"Prime\", <prime>\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"OutputLevel\", <level>\n",
    "    \"Verbose\"\n",
    "    \"SetupFile\", <file>\n",
    "    \"PqWorkspace\", <workspace>\n",
    "Illegal Parameter: \"", param, "\"" );
end );

#############################################################################
##
#F  ANUPQextractPqArgs( <args> )  . . . . . . . . . . . . . extract arguments
##
InstallGlobalFunction( ANUPQextractPqArgs, function( args )
    local   CR,  i,  act,  match;

    # allow to give only a prefix
    match := function( g, w )
    	return 1 < Length(g) 
               and Length(g) <= Length(w) 
               and w{[1..Length(g)]} = g;
    end;

    # extract arguments
    CR := rec();
    i  := 2;
    while i <= Length(args)  do
        act := args[i];
        if not IsString( act ) then ANUPQerrorPq( act ); fi;

    	# "ClassBound", <class>
        if match( act, "ClassBound" ) then
            i := i + 1;
            CR.ClassBound := args[i];

    	# "Prime", <prime>
        elif match( act, "Prime" )  then
            i := i + 1;
            CR.Prime := args[i];

    	# "Exponent", <exp>
        elif match( act, "Exponent" )  then
            i := i + 1;
            CR.Exponent := args[i];

        # "Metabelian"
        elif match( act, "Metabelian" ) then
            CR.Metabelian := true;

    	# "Output", <level>
        elif match( act, "OutputLevel" )  then
            i := i + 1;
            CR.OutputLevel := args[i];
    	    CR.Verbose     := true;

    	# "SetupFile", <file>
        elif match( act, "SetupFile" )  then
    	    i := i + 1;
            CR.SetupFile := args[i];

    	# "PqWorkspace", <workspace>
        elif match( act, "PqWorkspace" )  then
    	    i := i + 1;
            CR.PqWorkspace := args[i];

    	# "Verbose"
        elif match( act, "Verbose" ) then
            CR.Verbose := true;

    	# signal an error
    	else
            ANUPQerrorPq( act );

    	fi; 
    	i := i + 1; 
    od;
    return CR;

end );

#############################################################################
##
#V  ANUPQGlobalVariables
##
InstallValue( ANUPQGlobalVariables, 
              [ "F",          #  a free group
                "MapImages"   #  images of the generators in G
                ] );

#############################################################################
##
#F  ANUPQReadOutput . . . . read pq output without affecting global variables
##
InstallGlobalFunction( ANUPQReadOutput, function( file, globalvars )
    local   var,  result;

    for var in globalvars do
        HideGlobalVariables( var );
    od;

    Read( file );

    result := rec();

    for var in globalvars do
        if IsBoundGlobal( var ) then
            result.(var) := ValueGlobal( var );
        else
            result.(var) := fail;
        fi;
    od;

    for var in globalvars do
        UnhideGlobalVariables( var );
    od;
    
    return result;
end );

#############################################################################
##
#F  PqEpimorphism( <arg> : <options> )  . . . . .  epimorphism onto a p-group
##
InstallGlobalFunction( PqEpimorphism, function( arg )
    return PQ_EPIMORPHISM( arg );
end );

#############################################################################
##
#F  Pq( <arg> : <options> )  . . . . . . . . . . . . . . . . . prime quotient
##
InstallGlobalFunction( Pq, function( arg )
    local pQepi;

    pQepi := PQ_EPIMORPHISM( arg );
    if pQepi = true then
      return true; # the SetupFile case
    fi;
    return Image( pQepi );
end );

#############################################################################
##
#F  PQ_EPIMORPHISM( <args> : <options> ) . . . . . prime quotient epimorphism
##
InstallGlobalFunction( PQ_EPIMORPHISM, function( args )
    local   datarec;

    datarec := ANUPQ_ARG_CHK(1, "Pq", "group", IsFpGroup, 
                             "an fp group", args, ["Prime", "ClassBound"]);
    datarec.filter := ["Output file in", "Group presentation"];
    if datarec.calltype = "interactive" then      
        if IsBound(datarec.pQepi) then
            return datarec.pQepi; # it's already been computed
        fi;
    elif datarec.calltype = "GAP3compatible" then
        # ANUPQ_ARG_CHK calls PQ_EPIMORPHISM itself in this case
        # (so datarec.pQepi has already been computed)
        return datarec.pQepi;
    fi;

    PushOptions( rec(nonuser := true) );
    PQ_PC_PRESENTATION(datarec, "pQ");

    PQ_WRITE_PC_PRESENTATION(datarec, datarec.outfname);
    
    if datarec.calltype = "non-interactive" then
      PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL(datarec);
      if IsBound( datarec.setupfile ) then
        PopOptions();
        return true;
      fi;
    fi;
            
    # read group and images from file
    HideGlobalVariables( "F", "MapImages" );
    Read( datarec.outfname );
    datarec.pQuotient := ValueGlobal( "F" );
    datarec.pQepi := GroupHomomorphismByImages( 
                       datarec.group,
                       datarec.pQuotient,
                       GeneratorsOfGroup( datarec.group ),
                       ValueGlobal( "MapImages" )
                       );
    SetFeatureObj( datarec.pQepi, IsSurjective, true );
    UnhideGlobalVariables( "F", "MapImages" );
    PopOptions();
    return datarec.pQepi;
end );

#############################################################################
##
#F  PqRecoverDefinitions( <G> ) . . . . . . . . . . . . . . . . . definitions
##
##  This function finds a definition for each generator of the p-group <G>.
##  These definitions need not be the same as the ones used by pq.  But
##  they serve the purpose of defining each generator as a commutator or
##  power of earlier ones.  This is useful for extending an automorphism that
##  is given on a set of minimal generators of <G>.
##
InstallGlobalFunction( PqRecoverDefinitions, function( G )
    local   col,  gens,  definitions,  h,  g,  rhs,  gen;

    col  := ElementsFamily( FamilyObj( G ) )!.rewritingSystem;
    gens := GeneratorsOfRws( col );

    definitions := [];

    for h in [1..NumberGeneratorsOfRws( col )] do
        rhs := GetPowerNC( col, h );
        if Length( rhs ) = 1 then
            gen := Position( gens, rhs );
            if not IsBound( definitions[gen] ) then
                definitions[gen] := h;
            fi;
        fi;
        
        for g in [1..h-1] do
            rhs := GetConjugateNC( col, h, g );
            if Length( rhs ) = 2 then
                gen := SubSyllables( rhs, 2, 2 );
                gen := Position( gens, gen );
                if not IsBound( definitions[gen] ) then
                    definitions[gen] := [h, g];
                fi;
            fi;
        od;
    od;
    return definitions;
end );

#############################################################################
##
#F  PqAutomorphism( <epi>, <autoimages> ) . . . . . . . . . . . . definitions
##
##  Take an automorphism of the preimage and produce the induced automorphism
##  of the image of the epimorphism.
##
InstallGlobalFunction( PqAutomorphism, function( epi, autoimages )
    local   G,  p,  gens,  definitions,  d,  epimages,  i,  pos,  def,  
            phi;

    G      := Image( epi );
    p      := PrimeOfPGroup( G );
    gens   := GeneratorsOfGroup( G );
    
    autoimages := List( autoimages, im->Image( epi, im ) );

    ##  Get a definition for each generator.
    definitions := PqRecoverDefinitions( G );
    d := Number( [1..Length(definitions)], 
                 i->not IsBound( definitions[i] ) );

    ##  Find the images for the defining generators of G under the
    ##  automorphism.  We have to be careful, as some of the generators for
    ##  the source might be redundant as generators of G.
    epimages := List( GeneratorsOfGroup(Source(epi)), g->Image(epi,g) );
    for i in [1..d] do
        ##  Find G.i ...
        pos := Position( epimages, G.(i) );
        if pos = fail then 
            Error( "generators ", i, "not image of a generators" );
        fi;
        ##  ... and set its image.
        definitions[i] := autoimages[pos];
    od;
        
    ##  Replace each definition by its image under the automorphism.
    for i in [d+1..Length(definitions)] do
        def := definitions[i];
        if IsInt( def ) then
            definitions[i] := definitions[ def ]^p;
        else
            definitions[i] := Comm( definitions[ def[1] ],
                                    definitions[ def[2] ] );
        fi;
    od;
            
    phi := GroupHomomorphismByImages( G, G, gens, definitions );
    SetFeatureObj( phi, IsBijective, true );

    return phi;
end );

#############################################################################
##
#F  PqLeftNormComm( <words> ) . . . . . . . . . . . . .  left norm commutator
##
##  returns for a list <words> of words in the generators of a group the left
##  norm commutator of <words>, e.g.~if <w1>, <w2>, <w3>  are  words  in  the
##  generators of some free or fp group then  `PqLeftNormComm(  [<w1>,  <w2>,
##  <w3>] );' is equivalent to `Comm( Comm( <w1>, <w2> ), <w3> );'. Actually,
##  the only restriction on <words> is that they must constitute a  non-empty
##  list of group elements of the same group (so a list  of  permutations  is
##  allowed, for example).
##
InstallGlobalFunction( PqLeftNormComm, function( words )
local fam, comm, word;
  if not IsList(words) or IsEmpty(words) or 
     not ForAll(words, IsMultiplicativeElementWithInverse) then
    Error( "<words> should be a non-empty list of group elements\n" );
  else
    fam := FamilyObj(words[1]);
    if not ForAll(words, w -> IsIdenticalObj(FamilyObj(w), fam)) then
      Error( "<words> should belong to the same group\n" );
    fi;
  fi;
  comm := words[1];
  for word in words{[2 .. Length(words)]} do
    comm := Comm(comm, word);
  od;
  return comm;
end );

#############################################################################
##
#F  PqGAPRelators( <group>, <rels> ) . . . . . . . . pq relators as GAP words
##
##  returns, for a list <rels> of strings in the  string  representations  of
##  the generators of the fp or pc  group  <group>  prepared  as  a  list  of
##  relators for the `pq' binary, a list of words that {\GAP} understands.
##
##  *Note:*
##  The `pq' binary does not use `/' to indicate multiplication by an inverse
##  and uses square brackets to represent (left norm) commutators. Also, even
##  though the `pq' binary accepts relations, all elements of  <rels>  *must*
##  be in relator form, i.e.~a relation of form `<w1> = <w2>' must be written
##  as `<w1>*(<w2>)^-1'.
##
##  Here is an example (that demonstrates its use, but with  not  necessarily
##  appropriate relators for a $p$-quotient):
##
##  \beginexample
##  gap> F := FreeGroup("a", "b");
##  gap> PqGAPRelators(F, [ "a*b^2", "[a,b]^2*a", "([a,b,a,b,b]*a*b)^2*a" ]);
##  [ a*b^2, a^-1*b^-1*a*b*a^-1*b^-1*a*b*a, b^-1*a^-1*b^-1*a^-1*b*a*b^-1*a*b*a^
##      -1*b*a^-1*b^-1*a*b*a*b^-1*a^-1*b^-1*a^-1*b*a*b^-1*a*b^-1*a^-1*b*a^-1*b^
##      -1*a*b*a*b*a^-1*b*a*b^-1*a*b*a^-1*b*a^-1*b^-1*a*b*a*b^-1*a^-1*b^-1*a^
##      -1*b*a*b^-1*a*b^-1*a^-1*b*a^-1*b^-1*a*b*a*b^2*a*b*a ]
##  \endexample
##
InstallGlobalFunction( PqGAPRelators, function( group, rels )
local gens, relgens, diff, g;
  if not( IsFpGroup(group) or IsPcGroup(group) ) then
    Error("<group> must be an fp or pc group\n");
  fi;
  gens := List( GeneratorsOfGroup(group), String );
  if not ForAll(rels, rel -> Position(rel, '/') = fail) then
    Error( "pq binary does not understand `/' in relators\n" );
  fi;
  relgens := Set( Concatenation( 
                      List( rels, rel -> Filtered(
                                             SplitString(rel, "", "*[]()^, "),
                                             str -> Int(str) = fail) ) ) );
  diff := Difference(relgens, gens);
  if not IsEmpty(diff) then
    Error( "generators: ", diff, 
           "\nare not among the generators of the group supplied\n" );
  fi;
  CallFuncList(HideGlobalVariables, gens);
  for g in FreeGeneratorsOfFpGroup(group) do
    ASS_GVAR(String(g), g);
  od;
  rels := List( rels, rel -> EvalString(
                                 ReplacedString(
                                     ReplacedString(rel, "]", "])"),
                                     "[", "PqLeftNormComm(["
                                     ) ) );
  CallFuncList(UnhideGlobalVariables, gens);
  return rels;
end );

#############################################################################
##
#F  PQ_EVALUATE( <string> ) . . . . . . . . . evaluate a string emulating GAP
##
##  For each substring of the string <string> that is a statement (i.e.  ends
##  in a `;'), `PQ_EVALUATE( <string> )' evaluates it in the same way  {\GAP}
##  would. If the substring is further followed by  a  `;'  (i.e.  there  was
##  `;;'), this is an indication that the statement would produce no  output;
##  otherwise the output that the user would normally see if  she  typed  the
##  statement interactively is displayed.
##
InstallGlobalFunction(PQ_EVALUATE, function(string)
local from, pos, statement, parts, var;
  from := 0;
  pos := Position(string, ';', from);
  while pos <> fail do
    statement := string{[from + 1..pos]};
    statement := ReplacedString(statement," last "," ANUPQData.example.last ");
    if pos < Length(string) and string[pos + 1] = ';' then
      Read( InputTextString(statement) );
      from := pos + 1;
    else
      parts := SplitString(statement, "", " \n");
      if 1 < Length(parts) and parts[2] = ":=" then
        Read( InputTextString(statement) );
        Read( InputTextString( 
                  Concatenation( "View(", parts[1], "); Print(\"\\n\");" ) ) );
        ANUPQData.example.last := parts[1];
      else
        var := TemporaryGlobalVarName();
        Read( InputTextString( Concatenation(var, ":=", statement) ) );
        if ISBOUND_GLOBAL(var) then
          View( VALUE_GLOBAL(var) );
          Print( "\n" );
          ANUPQData.example.last := VALUE_GLOBAL(var);
          UNBIND_GLOBAL(var);
        fi;
      fi;
      from := pos;
    fi;
    pos := Position(string, ';', from);
  od;
end );

#############################################################################
##
#F  PqExample() . . . . . . . . . . execute a pq example or display the index
#F  PqExample( <example>[, PqStart][, Display] )
#F  PqExample( <example>[, PqStart][, <filename>] )
##
##  With no arguments,  or  with  single  argument  `"index"',  or  a  string
##  <example> that is not the name of a file in the `gap/examples' directory,
##  an index of available examples is displayed.
##
##  With just the one argument <example> that is the name of a  file  in  the
##  `gap/examples' directory, the example contained in that file is  executed
##  in its simplest form. Some examples accept options which you may  use  to
##  modify some of the options used in the commands of the example.  To  find
##  out which options an example  accepts, use  one  of  the  mechanisms  for
##  displaying the example described below.
##
##  Some examples have both non-interactive and interactive forms; those that
##  are non-interactive only have a name ending  in  `-ni';  those  that  are
##  interactive only have a name ending in `-i'; examples with  names  ending
##  in  `.g'  also  have  only  one  form;  all  other  examples  have   both
##  non-interactive and interactive forms and for these giving  `PqStart'  as
##  second argument invokes `PqStart' initially  and  makes  the  appropriate
##  adjustments  so  that  the  example  is  executed  or   displayed   using
##  interactive functions.
##
##  If `PqExample' is called with last (second or third)  argument  `Display'
##  then the example  is  displayed  without  being  executed.  If  the  last
##  argument is a non-empty  string  <filename>  then  the  example  is  also
##  displayed without being executed but is also written to a file with  that
##  name. Passing an empty string as last argument has  the  same  effect  as
##  passing `Display'.
##
##  *Note:*
##  The  variables  used  in  `PqExample'  are  local  to  the   running   of
##  `PqExample', so there's no  danger  of  having  some  of  your  variables
##  over-written. However, they are not  completely  lost  either.  They  are
##  saved to a record `ANUPQData.examples.vars', i.e.~if `F'  is  a  variable
##  used in the example then you will be able to access it after  `PqExample'
##  has finished as `ANUPQData.examples.vars.F'.
##
InstallGlobalFunction(PqExample, function(arg)
local name, file, instream, line, input, doPqStart, vars, var, printonly,
      filename, DoAltAction, GetNextLine, PrintLine, action, datarec, optname,
      linewidth, sizescreen, CheckForCompoundKeywords, iscompoundStatement,
      compoundDepth;

  sizescreen := SizeScreen();
  if sizescreen[1] < 80 then
    SizeScreen([80, sizescreen[2]]);
    linewidth := 80;
  else
    linewidth := sizescreen[1];
  fi;

  if IsEmpty(arg) then
    name := "index";
  else
    name := arg[1];
  fi;

  if name = "README" then
    file := fail;
  else
    file := Filename(DirectoriesPackageLibrary( "anupq", "gap/examples"), name);
  fi;
  if file = fail then
    Info(InfoANUPQ + InfoWarning, 1,
         "Sorry! There is no ANUPQ example with name `", name, "'",
         " ... displaying index.");
    name := "index";
    file := Filename(DirectoriesPackageLibrary( "anupq", "gap/examples"), name);
  fi;

  if name <> "index" then
    doPqStart := false;
    if Length(arg) > 1 then
      # At this point the name of the variable <printonly> doesn't make
      # sense; however, if the value assigned to <printonly> is `Display'
      # or an empty string then we ``print only'' and if it is a non-empty
      # string then it is assumed to be a filename and we `LogTo' that filename.
      printonly := arg[Minimum(3, Length(arg))];
      if arg[2] = PqStart then
        if 2 < Length(name) and 
           name{[Length(name) - 1 .. Length(name)]} in ["-i", "ni", ".g"] then
          Error( "example does not have a (different) interactive form\n" );
        fi;
        doPqStart := true;
      fi;
    else
      printonly := false;
    fi;

    DoAltAction := function()
      if doPqStart then
        if action[2] = "do" then
          # uncomment line
          line := line{[2..Length(line)]};
        else
          # replace a variable with a proc id
          line := ReplacedString( line, action[5], action[3] ); 
        fi;
      fi;
    end;

    if printonly = Display or IsString(printonly) then
      GetNextLine := function()
        local from, to;
        line := ReadLine(instream);
        if line = fail then
          return;
        elif IsBound(action) then
          action := SplitString(action, "", "# <>\n");
          DoAltAction();
          Unbind(action);
        elif 3 < Length(line) and line{[1..4]} = "#alt" then
          # only "#alt" actions recognised
          action := line;
        elif IsMatchingSublist(line, "#comment:") then
          line := ReplacedString(line, " supplying", "");
          from := Position(line, ' ');
          to   := Position(line, '<', from);
          Info(InfoANUPQ, 1, 
               "In the next command, you may", line{[from .. to - 1]});
          from := to + 1;
          to   := Position(line, '>') - 1;
          Info(InfoANUPQ, 1, "supplying to `PqExample' the option: `", 
                             line{[from .. to]}, "'");
        fi;
      end;

      if IsString(printonly) and printonly <> "" then
        filename := printonly;
        LogTo( filename ); #Make sure it's empty and writable
      fi;
      PrintLine := function()
        if IsMatchingSublist(line, "##") then 
          line := line{[2..Length(line)]};
        elif line[1] = '#' then
          return;
        fi;
        Print( ReplacedString(line, ";;", ";") );
      end;
      printonly := true; #now the name of the variable makes sense
    else
      printonly := false;
      ANUPQData.example := rec(options := rec());
      datarec := ANUPQData.example.options;

      CheckForCompoundKeywords := function()
        local compoundkeywords;
        compoundkeywords := Filtered( SplitString(line, "", " ;\n"),
                                      w -> w in ["do", "od", "if", "fi",
                                                 "repeat", "until"] );
        compoundDepth := compoundDepth 
                         + Number(compoundkeywords,
                                  w -> w in ["do", "if", "repeat"])
                         - Number(compoundkeywords,
                                  w -> w in ["od", "fi", "until"]);
        return not IsEmpty(compoundkeywords);
      end;

      GetNextLine := function()
        local from, to, bhsinput;
        repeat
          line := ReadLine(instream);
          if line = fail then return; fi;
        until not IsMatchingSublist(line, "#comment:");
        if IsBound(action) then
          action := SplitString(action, "", "# <>\n");
          if action[1] = "alt:" then
            DoAltAction();
          else
            # action[2] = name of a possible option passed to `PqExample'
            # action[4] = string to be replaced in <line> with the value
            #             of the option if ok and set
            optname := action[2];
            if IsDigitChar(optname[ Length(optname) ]) then
              optname := optname{[1..Length(optname) - 1]};
            fi;
            datarec.(action[2]) := ValueOption(action[2]);
            if datarec.(action[2]) = fail then
              Unbind( datarec.(action[2]) );
            else
              if not ANUPQoptionChecks.(optname)( datarec.(action[2]) ) then
                Info(InfoANUPQ, 1, "\"", action[2], "\" value must be a ",
                                   ANUPQoptionTypes.(optname), 
                                   ": option ignored.");
                Unbind( datarec.(action[2]) );
              else
                if action[1] = "add" then
                  line[1] := ' ';
                fi;
                if IsString( datarec.(action[2]) ) then
                  line := ReplacedString( line, action[4],
                                          Flat(['"',datarec.(action[2]),'"']) );
                else
                  line := ReplacedString( line, action[4], 
                                          String( datarec.(action[2]) ) );
                fi;
              fi;
            fi;
          fi;
          Unbind(action);
        elif IsMatchingSublist(line, "##") then
          ; # do nothing
        elif 3 < Length(line) and line{[1..4]} in ["#sub", "#add", "#alt"] then
          action := line;
        elif line[1] = '#' then
          # execute instructions behind the scenes
          bhsinput := "";
          repeat
            Append( bhsinput, 
                    ReplacedString(line{[2..Length(line)]},
                                   "datarec",
                                   "ANUPQData.example.options") );
            line := ReadLine(instream);
          until line[1] <> '#' or
                (3 < Length(line) and line{[1..4]} in ["#sub", "#add", "#com"]);
          Read( InputTextString(bhsinput) );
        fi;
      end;

      PrintLine := function()
        if IsMatchingSublist(line, "##") then 
          line := line{[2..Length(line)]};
        elif line[1] = '#' then
          return;
        fi;
        if input = "" then
          Print("gap> ");
        else
          Print(">    ");
        fi;
        Print( ReplacedString(line, ";;", ";") );
      end;
    fi;
  fi;
  
  instream := InputTextFile(file);
  if name <> "index" then
    FLUSH_PQ_STREAM_UNTIL( instream, 10, 1, ReadLine,
                           line -> IsMatchingSublist(line, "#Example") );
    line := FLUSH_PQ_STREAM_UNTIL( instream, 1, 10, ReadLine,
                                   line -> IsMatchingSublist(line, "#vars:") );
    if Length(line) + 21 < linewidth then
      Info(InfoANUPQ, 1, line{[Position(line, ' ')+1..Position(line, ';')-1]},
                         " are local to `PqExample'");
    else
      #this assumes one has been careful to ensure the `#vars:' line is not
      #longer than 72 characters.
      Info(InfoANUPQ, 1, line{[Position(line, ' ')+1..Position(line, ';')-1]},
                         " are local");
      Info(InfoANUPQ, 1, "to `PqExample'");
    fi;
    vars := SplitString(line, "", " ,;\n");
    vars := vars{[2 .. Length(vars)]};
    if not printonly then
      CallFuncList(HideGlobalVariables, vars);
    fi;
    line := FLUSH_PQ_STREAM_UNTIL(instream, 1, 10, ReadLine,
                                  line -> IsMatchingSublist(line, "#options:"));
    input := "";
    GetNextLine();
    while line <> fail do
      PrintLine();
      if line[1] <> '#' then
        if not printonly then
          if input = "" then
            compoundDepth := 0;
            iscompoundStatement := CheckForCompoundKeywords();
          elif iscompoundStatement and compoundDepth > 0 then
            CheckForCompoundKeywords();
          fi;
          if line <> "\n" then
            Append(input, line);
            if iscompoundStatement then
              if compoundDepth = 0 and Position(input, ';') <> fail then
                Read( InputTextString(input) );           
                iscompoundStatement := false;
                input := "";
              fi;
            elif Position(input, ';') <> fail then
              PQ_EVALUATE(input);
              input := "";
            fi;
          fi;
        fi;
      fi;
      GetNextLine();
    od;
    if printonly then
      if IsBound(filename) then
        LogTo();
      fi;
    else
      ANUPQData.example.vars := rec();
      for var in Filtered(vars, ISBOUND_GLOBAL) do 
        ANUPQData.example.vars.(var) := VALUE_GLOBAL(var);
      od;
      Info(InfoANUPQ, 1, "Variables used in `PqExample' are saved ",
                         "in `ANUPQData.example.vars'.");
      CallFuncList(UnhideGlobalVariables, vars);
    fi;
  else
    FLUSH_PQ_STREAM_UNTIL(instream, 1, 10, ReadLine, line -> line = fail);
  fi;
  CloseStream(instream);
  if linewidth <> sizescreen[1] then
    SizeScreen( sizescreen ); # restore what was there before
  fi;
end);

#E  anupq.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
