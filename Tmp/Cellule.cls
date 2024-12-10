 
 /*------------------------------------------------------------------------
    File        : Cellule
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mam
    Created     : Wed Jul 03 15:19:27 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Tmp.Cellule INHERITS System.Object: 
    DEF PRIVATE VAR Direction           AS Tmp.Directions NO-UNDO.
    DEF PUBLIC PROPERTY ID              AS INTE NO-UNDO 
        GET.
        SET.
    DEF PUBLIC PROPERTY PX              AS INTE NO-UNDO
        GET.
        SET.
    DEF PUBLIC PROPERTY PY              AS INTE NO-UNDO
        GET.
        SET. 
    DEF PUBLIC PROPERTY Cont            AS DECI NO-UNDO
        GET.
        SET.  
    DEF PUBLIC PROPERTY Heuristique     AS DECI NO-UNDO
        GET.
        SET.     
    DEF PRIVATE PROPERTY Statut         AS CHAR NO-UNDO
        GET.
        SET.
    DEF PUBLIC PROPERTY CoefRall        AS INTE INIT 1 NO-UNDO
        GET.
        SET.
    DEF PUBLIC PROPERTY Directions      AS Tmp.Directions NO-UNDO
        GET.
        SET.
    
        
    
    DEFINE PRIVATE VARIABLE v_AlphaX AS CHAR NO-UNDO INIT "ABCDEFGHIJKLMNOPQRST".
    
    CONSTRUCTOR PUBLIC Cellule ():
    
        Directions = tmp.Directions:DEFAULT.
        
    END CONSTRUCTOR.
    
    CONSTRUCTOR PUBLIC Cellule (INPUT pi_ID             AS INTE ,
                                INPUT pi_PX             AS INTE ,
                                INPUT pi_PY             AS INTE ,
                                INPUT pi_Cont           AS INTE ,
                                INPUT pi_heuristique    AS INTE ):
        THIS-OBJECT().
        ASSIGN 
            ID          = pi_ID
            PX          = pi_PX
            PY          = pi_PY
            Cont        = pi_Cont
            heuristique = pi_heuristique.
    
    END CONSTRUCTOR.
   
    CONSTRUCTOR PUBLIC Cellule (INPUT pi_Cellule AS tmp.cellule):
    
        THIS-OBJECT(pi_Cellule:ID, pi_Cellule:PX, pi_Cellule:PY, pi_Cellule:Statut).

    END CONSTRUCTOR.
    
    CONSTRUCTOR PUBLIC Cellule (INPUT pi_PX AS INTE,
        INPUT pi_PY AS INTE):
        THIS-OBJECT (0, pi_PX, pi_PY).
    END CONSTRUCTOR.
    
    CONSTRUCTOR PUBLIC Cellule (INPUT pi_ID AS INTE, 
        INPUT pi_PX AS INTE,
        INPUT pi_PY AS INTE):
        THIS-OBJECT(pi_ID, pi_PX, pi_PY, "XXX").
    END CONSTRUCTOR.
    
    CONSTRUCTOR PUBLIC Cellule (INPUT pi_ID AS INTE,
        INPUT pi_PX AS INTE,
        INPUT pi_PY AS INTE,
        INPUT pi_Statut AS CHAR):
        THIS-OBJECT().
        ASSIGN 
            ID     = pi_ID
            PX     = pi_PX
            PY     = pi_PY
            Statut = pi_Statut.
    END CONSTRUCTOR.
    
    METHOD PUBLIC LOGI DirectionPossible (pi_Direction AS Tmp.Directions):
         IF directions = Tmp.Directions:Toutes THEN 
            RETURN YES.
         IF pi_direction = Tmp.Directions:Nord THEN
            IF Directions = Tmp.Directions:Nord OR Directions = Tmp.Directions:NordEtEst OR Directions = Tmp.Directions:NordEtOuest THEN
                RETURN YES.
            ELSE
                RETURN NO.
         IF pi_direction = Tmp.Directions:Sud THEN
            IF Directions = Tmp.Directions:Sud OR Directions = Tmp.Directions:SudEtEst OR Directions = Tmp.Directions:SudEtOuest THEN
                RETURN YES.
            ELSE
                RETURN NO.
         IF pi_direction = Tmp.Directions:Est THEN
            IF Directions = Tmp.Directions:Est OR Directions = Tmp.Directions:NordEtEst OR Directions = Tmp.Directions:SudEtEst THEN
                RETURN YES.
            ELSE
                RETURN NO.
         IF pi_direction = Tmp.Directions:Ouest THEN
            IF Directions = Tmp.Directions:Ouest OR Directions = Tmp.Directions:NordEtOuest OR Directions = Tmp.Directions:SudEtOuest THEN
                RETURN YES.
            ELSE
                RETURN NO.
        
    END METHOD.
    
    METHOD PUBLIC VOID DevenirMur ():
        Statut = "MUR".
        CoefRall = 1 .
    END METHOD.

    METHOD PUBLIC LOGI EstMur ():
        IF Statut = "MUR" THEN
            RETURN YES.
        ELSE
            RETURN NO.
    END METHOD. 
    
    METHOD PUBLIC VOID DevenirRall ():
        Statut = "RAL".
        CoefRall = 2 .
    END METHOD.

    METHOD PUBLIC LOGI EstRall ():
        IF Statut = "RAL" THEN
            RETURN YES.
        ELSE
            RETURN NO.
        
    END METHOD. 
    
    METHOD PUBLIC VOID DevientParcouru ():
        IF Statut <> "RAL" THEN 
            Statut = "PAR". 
    END METHOD.
     
    METHOD PUBLIC LOGI EstParcouru ():
        IF Statut = "PAR" THEN
            RETURN YES.
        ELSE
            RETURN NO.
    END METHOD. 

    METHOD PUBLIC LOGI EstEgal (INPUT pi_Cellule AS Tmp.Cellule):
        IF PX = pi_Cellule:PX AND PY = pi_Cellule:PY THEN 
            RETURN YES.
        ELSE 
            RETURN NO.     
    END METHOD.

    METHOD PUBLIC VOID DevientNormal ():
        Statut = "XXX".
        CoefRall = 1 .
        Directions = Tmp.Directions:Toutes.
    END METHOD.
    
    METHOD PUBLIC VOID DevientDepart ():
        Statut = "DEP".
    END METHOD.
    
    METHOD PUBLIC VOID DevientArrivee ():
        Statut = "ARR".
    END METHOD.
    
    METHOD PUBLIC LOGI EstDepart ():
        IF Statut = "DEP" THEN
            RETURN YES.
        ELSE
            RETURN NO.
    END METHOD. 
    
    METHOD PUBLIC LOGI EstArrivee ():
        IF Statut = "ARR" THEN
            RETURN YES.
        ELSE
            RETURN NO.
    END METHOD. 
    
    METHOD PUBLIC OVERRIDE CHAR ToString (): 
        RETURN "(" + SUBSTRING(v_AlphaX ,PX,1) + " , " + STRING(PY) + ")".
    END METHOD.    
END CLASS.