#############################################################################
##
#W  maps.gi                  GAP4 package `Utils'                 Stefan Kohl 
##                                                              Chris Wensley
#Y  Copyright (C) 2015-2019, The GAP Group 

#############################################################################
##
#F  EpimorphismByGenerators( <D1>, <D2> ) . epi: gen's of <D1>->gen's of <D2>
##
InstallMethod( EpimorphismByGenerators, "for groups", ReturnTrue, 
    [ IsGroup, IsGroup ], 0, 

function( G, H )
    if not ( IsFreeGroup( G ) ) then 
      Print( "Warning: calling GroupHomomorphismByImagesNC without checks\n" );
    fi; 
    
return GroupHomomorphismByImagesNC( G, H, GeneratorsOfGroup(G),
                                              GeneratorsOfGroup(H) );
end );

##############################################################################
##
#M  Pullback . . . . . . . . . for two group homomorphisms with a common range
##
InstallMethod( Pullback, "for two group homomorphisms", true, 
    [ IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function( nu, mu )

    local M, N, P, NxM, projM, pmu, projN, pnu, genNxM, e, genL, L, 
          imphi, phi, impsi, psi, info; 

    M := Source( mu ); 
    P := Range( mu ); 
    N := Source( nu ); 
    if not ( Range(nu) = P ) then 
        Error( "homs nu,mu should have a common range" );
    fi; 
    NxM := DirectProduct( N, M ); 
    genNxM := GeneratorsOfGroup( NxM ); 
    projN := Projection( NxM, 1 ); 
    pnu := projN * nu; 
    projM := Projection( NxM, 2 ); 
    pmu := projM * mu; 
    if IsFinite( NxM ) then 
        genL := [ ]; 
        L := Subgroup( NxM, [ One(NxM) ] ); 
        for e in NxM do 
            if ImageElm( pnu, e ) = ImageElm( pmu, e ) then 
                if not ( e in L ) then 
                    Add( genL, e ); 
                    L := Group( genL );
                fi;
            fi; 
        od;
    else 
        return fail; 
    fi;
    imphi := List( genL, g -> ImageElm( projN, g ) ); 
    phi := GroupHomomorphismByImages( L, N, genL, imphi ); 
    impsi := List( genL, g -> ImageElm( projM, g ) ); 
    psi := GroupHomomorphismByImages( L, M, genL, impsi ); 
    info := rec( directProduct := NxM, projections := [phi,psi] ); 
    SetPullbackInfo( L, info ); 
    return L;
end ); 

##############################################################################
##
#M  IdempotentEndomorphisms  . . . . . . . . . . . . . . . . . . . for a group  
#M  IdempotentEndomorphismsData  . . . . . . . . . . . . . . . . . for a group  
#M  IdempotentEndomorphismsWithImage . . . . .  for a group and a chosen image 
##
InstallMethod( IdempotentEndomorphismsWithImage, 
    "for a list of group generators and a chosen image", 
    [ IsList, IsGroup ], 0, 
function( genG, R ) 

    local G, numG, r, q, norm, n, reps, i, j, rc;

    G := Group( genG );
    if not IsSubgroup( G, R ) then 
        Error( "R should be a subgroup of G" ); 
    fi; 
    numG := Length( genG );
    r := Size( R ); 
    q := Size( G )/r;     
    norm := Filtered( NormalSubgroups( G ), N -> ( Size( N ) = q ) and 
                          IsTrivial( Intersection( N, R ) ) ); 
    n := Length( norm );
    reps := [ ]; 
    for i in [1..n] do 
        Add( reps, [ ] );
        for j in [1..numG] do 
            rc := norm[i]*genG[j]; 
            Add( reps[i], First( rc, g -> g in R ) );   
        od;
    od;
    return reps; 
end );

InstallMethod( IdempotentEndomorphismsData, "for a group", [ IsGroup ], 0, 
function( G ) 

    local genG, R, data, images; 

    genG := SmallGeneratingSet( G ); 
    images := [ ]; 
    for R in AllSubgroups( G ) do 
        data := IdempotentEndomorphismsWithImage( genG, R ); 
        if ( data <> [ ] ) then 
            Add( images, data ); 
        fi; 
    od;
    return rec( gens := genG, images := images );
end );

InstallMethod( IdempotentEndomorphisms, "for a group", [ IsGroup ], 0, 
function( G ) 

    local data, genG, images, len, L, i, im; 

    data := IdempotentEndomorphismsData( G ); 
    genG := data!.gens;
    G := Group( genG );  
    images := data!.images; 
    len := Length( images ); 
    L := [ ]; 
    for i in [1..len] do 
        for im in images[i] do 
            Add( L, GroupHomomorphismByImages( G, G, genG, im ) ); 
        od;  
    od;  
    return L;
end );
