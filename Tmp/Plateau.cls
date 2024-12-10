/*------------------------------------------------------------------------
    File        : Plateau
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : ram
    Created     : Thu Jun 27 08:46:54 CEST 2024
    Notes       : 
  ----------------------------------------------------------------------*/


BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Windows.Form FROM ASSEMBLY.
USING System.Drawing.Color FROM ASSEMBLY.
USING System.Drawing.Font FROM ASSEMBLY.
USING System.Drawing.Graphics FROM ASSEMBLY.
USING System.Drawing.Image FROM ASSEMBLY.
USING System.Drawing.Pen FROM ASSEMBLY.
USING System.Drawing.SolidBrush FROM ASSEMBLY.
USING System.Windows.Forms.MouseButtons FROM ASSEMBLY.
USING System.Windows.Forms.PaintEventArgs FROM ASSEMBLY.
USING System.Windows.Forms.Panel FROM ASSEMBLY.
USING System.Threading.Thread FROM ASSEMBLY.
USING Tmp.Directions FROM PROPATH.

CLASS Tmp.Plateau INHERITS Form:
    
    DEFINE PRIVATE VARIABLE B_Generation        AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE b_Play AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE b_Pause AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE b_precedent AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE B_sauver            AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE B_RechercheDeChemin AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE B_charger           AS System.Windows.Forms.Button        NO-UNDO.
    DEFINE PRIVATE VARIABLE components          AS System.ComponentModel.IContainer   NO-UNDO.
    DEFINE PRIVATE VARIABLE E_log               AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE Est AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE groupBox2           AS System.Windows.Forms.GroupBox      NO-UNDO.
    DEFINE PRIVATE VARIABLE label1              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE label2              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE label3              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE label4              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE label5              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE label6              AS System.Windows.Forms.Label         NO-UNDO.
    DEFINE PRIVATE VARIABLE NbrMurMini          AS System.Windows.Forms.NumericUpDown NO-UNDO.
    DEFINE PRIVATE VARIABLE NbrRall             AS System.Windows.Forms.NumericUpDown NO-UNDO.
    DEFINE PRIVATE VARIABLE Ouest AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE Nord AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton2        AS System.Windows.Forms.RadioButton   NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton1        AS System.Windows.Forms.RadioButton   NO-UNDO.
    DEFINE PRIVATE VARIABLE Sud AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE Suivant AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE T_CordonneeArrivee  AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE T_CordonneeDepart   AS System.Windows.Forms.TextBox       NO-UNDO.
    DEFINE PRIVATE VARIABLE Y_panel             AS Panel                              NO-UNDO.
    DEFINE PRIVATE VARIABLE v_Graph             AS Graphics                           NO-UNDO.
    DEFINE PRIVATE VARIABLE v_Plateau           AS Tmp.Cellule                        EXTENT NO-UNDO.
    DEFINE PRIVATE VARIABLE v_AlphaX            AS CHAR                               NO-UNDO INIT "ABCDEFGHIJKLMOPQRSTU".
    DEFINE PRIVATE VARIABLE v_Depart            AS tmp.cellule                        NO-UNDO.
    DEFINE PRIVATE VARIABLE v_Arrivee           AS tmp.cellule                        NO-UNDO.
    DEFINE PRIVATE VARIABLE v_Chemins           AS System.Collections.ArrayList       NO-UNDO.
    DEFINE PRIVATE VARIABLE v_Directions        AS Tmp.Directions                     NO-UNDO.            
    DEFINE PRIVATE VARIABLE v_Touche            AS CHAR                               NO-UNDO.
                     
    CONSTRUCTOR PUBLIC Plateau():
        SUPER().
        InitializeComponent().
        ResetPlateau().
        THIS-OBJECT:ComponentsCollection:Add(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID B_Generation_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEF VAR v_MurMinim AS INTE NO-UNDO.
        
        IF NbrMurMini:VALUE + NbrRall:VALUE <= 400 THEN 
        DO:
            IF VALID-OBJECT (v_Depart) THEN
                DELETE OBJECT v_Depart.
            IF VALID-OBJECT (v_Arrivee) THEN
                DELETE OBJECT v_Arrivee.
           
            T_CordonneeDepart:TEXT = "".
            T_CordonneeArrivee:TEXT = "".
            v_MurMinim = INTEGER(NbrMurMini:Value).
            ResetPlateau().
        
            GenererMur(v_MurMinim).
            GenererRall(INTEGER(NbrRall:Value)).
        END.
        ELSE 
            MESSAGE "Le nombre de murs ou de rallentisseurs exc‚de le nombre de c‚llules." VIEW-AS ALERT-BOX.
        REFRESH().
        RETURN.

    END METHOD.





    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID B_sauver_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        
        DEF VAR i                 AS INTE        NO-UNDO.
        DEF VAR j                 AS INTE        NO-UNDO.
        DEF VAR v_Ligne           AS CHAR        NO-UNDO.
        DEF VAR v_Fichier         AS CHAR        NO-UNDO.
        DEF VAR v_FichierValide   AS LOGI        NO-UNDO.
        DEF VAR v_CelluleCourante AS tmp.cellule NO-UNDO.

        SYSTEM-DIALOG GET-FILE v_Fichier 
            FILTERS "Source Files (*.txt)" "*.txt"
            ASK-OVERWRITE
            SAVE-AS
            UPDATE v_FichierValide.
            
        IF NOT v_FichierValide THEN 
            RETURN.
            
        IF SUBSTRING(v_Fichier , LENGTH (v_Fichier) - 3 , 4) <> ".txt" THEN 
            v_Fichier = v_Fichier + ".txt".
            
        OUTPUT TO VALUE(v_Fichier).
        DO i = 1 TO 20:
            DO j = 1 TO 20:
                v_CelluleCourante = v_Plateau[IdCellule(j , i)].
                IF v_CelluleCourante:EstMur() THEN 
                    v_Ligne = v_Ligne + "X".  
                ELSE 
                    IF v_CelluleCourante:EstDepart() THEN 
                        v_Ligne = v_Ligne + "D". 
                    ELSE 
                        IF v_CelluleCourante:EstArrivee() THEN 
                            v_Ligne = v_Ligne + "A".
                        ELSE 
                            IF v_CelluleCourante:EstRall() THEN 
                                v_Ligne = v_Ligne + "R".
                                ELSE 
                                    IF NOT v_celluleCourante:Directions = Tmp.Directions:Toutes THEN 
                                        v_Ligne = v_Ligne + STRING (v_CelluleCourante:Directions:GetValue()).
                                
                            ELSE
                                v_ligne = v_ligne + " ".
            END.
            EXPORT v_Ligne.
            v_Ligne = "".    
        END.
        OUTPUT CLOSE.
        
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID B_RechercheDeChemin_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        DEF VAR i AS INTE NO-UNDO.
        IF VALID-OBJECT (v_Depart) AND VALID-OBJECT (v_Arrivee) THEN 
        DO:
            IF NOT RechercheAStar() THEN 
            DO:
                MESSAGE "Aucun chemin n'est possible." VIEW-AS ALERT-BOX.
                IF VALID-OBJECT (v_Chemins) THEN 
                    DELETE OBJECT v_Chemins.
            END.
            DO i = 1 TO EXTENT(v_Plateau):
                IF v_Plateau[i]:EstParcouru() THEN
                    v_Plateau[i]:DevientNormal().
            END.
            REFRESH ().
        END.
        ELSE 
            MESSAGE "Veuillez d‚finir un point de d‚part et d'arriv‚e." VIEW-AS ALERT-BOX.
        RETURN.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID B_charger_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
	    
        DEF VAR i                    AS INTE                                NO-UNDO.
        DEF VAR j                    AS INTE                                NO-UNDO.
        DEF VAR k                    AS INTE                                NO-UNDO.
        DEF VAR v_Ligne              AS CHAR                                NO-UNDO.
        DEF VAR v_Fichier            AS CHAR                                NO-UNDO.
        DEF VAR v_RechercheDeFichier AS System.Windows.Forms.OpenFileDialog NO-UNDO.
        DEF VAR v_FichierValide      AS LOGI                                NO-UNDO.
        DEF VAR v_RefStatut          AS CHAR                                NO-UNDO.
        
        SYSTEM-DIALOG GET-FILE v_Fichier 
            FILTERS "Source Files (*.txt)" "*.txt"
            MUST-EXIST
            UPDATE v_FichierValide.
        IF NOT v_FichierValide THEN 
            RETURN.

        ResetPlateau().
        
        INPUT FROM VALUE (v_Fichier).
        REPEAT:
            DO i = 1 TO 20:
                v_Ligne = "".
                IMPORT v_Ligne.
                DO j = 1 TO 20:
                    CASE SUBSTRING ( v_Ligne, j , 1 ):
                        WHEN "X" THEN
                            DO:
                                v_Plateau[IdCellule( j , i)]:DevenirMur().
                            END.
                        WHEN "D" THEN
                            DO:
                                v_Depart = NEW Tmp.Cellule( v_Plateau[ IdCellule(j, i) ] ). 
                                v_Plateau[v_Depart:ID]:DevientDepart().
                            END. 
                        WHEN "A" THEN
                            DO:
                                v_Arrivee = NEW Tmp.Cellule(v_Plateau[IdCellule(j, i)]). 
                                v_Plateau[v_arrivee:ID]:DevientArrivee().
                            END.
                        WHEN "R" THEN
                            DO:
                                v_Plateau[IdCellule( j , i)]:DevenirRall().
                            END.
                    END.
                    IF SUBSTRING ( v_Ligne, j , 1 ) = "X" THEN 
                    DO:
                        v_Plateau[IdCellule( j , i)]:DevenirMur().
                    END.
                    ELSE 
                        IF SUBSTRING ( v_Ligne, j , 1 ) = "D" THEN
                        DO:
                            v_Depart = NEW Tmp.Cellule( v_Plateau[ IdCellule(j, i) ] ). 
                            v_Plateau[v_Depart:ID]:DevientDepart().
                        END. 
                        ELSE 
                            IF SUBSTRING ( v_Ligne, j , 1 ) = "A" THEN
                            DO:
                                v_Arrivee = NEW Tmp.Cellule(v_Plateau[IdCellule(j, i)]). 
                                v_Plateau[v_arrivee:ID]:DevientArrivee().
                            END.
                            ELSE 
                                IF SUBSTRING ( v_Ligne, j , 1 ) = "R" THEN
                                DO:
                                    v_Plateau[IdCellule( j , i)]:DevenirRall().
                                END.
                                ELSE 
                                    IF INTEGER (SUBSTRING ( v_Ligne, j , 1 )) > 0 AND INTEGER (SUBSTRING ( v_Ligne, j , 1 )) < 9 THEN 
                                        v_Plateau[IdCellule( j , i)]:Directions = Tmp.Directions:GetEnum(INTEGER (SUBSTRING ( v_Ligne, j , 1 ))).
                                
                END.
            END.
        END.
        
        REFRESH().
        	
        RETURN.

    END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID button3_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
		RETURN.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID button2_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
		RETURN.

	END METHOD.

    METHOD PRIVATE VOID InitializeComponent():
        THIS-OBJECT:Y_panel = NEW System.Windows.Forms.Panel().
        THIS-OBJECT:B_Generation = NEW System.Windows.Forms.Button().
        THIS-OBJECT:label1 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:NbrMurMini = NEW System.Windows.Forms.NumericUpDown().
        THIS-OBJECT:E_log = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:T_CordonneeDepart = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:T_CordonneeArrivee = NEW System.Windows.Forms.TextBox().
        THIS-OBJECT:label2 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:label3 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:label4 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:label5 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:B_RechercheDeChemin = NEW System.Windows.Forms.Button().
        THIS-OBJECT:B_sauver = NEW System.Windows.Forms.Button().
        THIS-OBJECT:B_charger = NEW System.Windows.Forms.Button().
        THIS-OBJECT:groupBox2 = NEW System.Windows.Forms.GroupBox().
        THIS-OBJECT:Ouest = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:Est = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:Sud = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:Nord = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:radioButton2 = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:radioButton1 = NEW System.Windows.Forms.RadioButton().
        THIS-OBJECT:NbrRall = NEW System.Windows.Forms.NumericUpDown().
        THIS-OBJECT:label6 = NEW System.Windows.Forms.Label().
        THIS-OBJECT:b_precedent = NEW System.Windows.Forms.Button().
        THIS-OBJECT:b_Pause = NEW System.Windows.Forms.Button().
        THIS-OBJECT:b_Play = NEW System.Windows.Forms.Button().
        THIS-OBJECT:Suivant = NEW System.Windows.Forms.Button().
        CAST(THIS-OBJECT:NbrMurMini, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:groupBox2:SuspendLayout().
        CAST(THIS-OBJECT:NbrRall, System.ComponentModel.ISupportInitialize):BeginInit().
        THIS-OBJECT:SuspendLayout().
        /*  */
        /* Y_panel */
        /*  */
        THIS-OBJECT:Y_panel:BackColor = System.Drawing.Color:White.
        THIS-OBJECT:Y_panel:Location = NEW System.Drawing.Point(10, 12).
        THIS-OBJECT:Y_panel:Name = "Y_panel".
        THIS-OBJECT:Y_panel:Size = NEW System.Drawing.Size(600, 600).
        THIS-OBJECT:Y_panel:TabIndex = 0.
        THIS-OBJECT:Y_panel:Paint:Subscribe(THIS-OBJECT:Panel_Paint).
        THIS-OBJECT:Y_panel:MouseClick:Subscribe(THIS-OBJECT:SelectionCellule).
        /*  */
        /* B_Generation */
        /*  */
        THIS-OBJECT:B_Generation:Location = NEW System.Drawing.Point(294, 618).
        THIS-OBJECT:B_Generation:Name = "B_Generation".
        THIS-OBJECT:B_Generation:Size = NEW System.Drawing.Size(75, 23).
        THIS-OBJECT:B_Generation:TabIndex = 1.
        THIS-OBJECT:B_Generation:Text = "G‚n‚rer".
        THIS-OBJECT:B_Generation:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:B_Generation:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:B_Generation:Click:Subscribe(THIS-OBJECT:B_Generation_Click).
        /*  */
        /* label1 */
        /*  */
        THIS-OBJECT:label1:Location = NEW System.Drawing.Point(12, 617).
        THIS-OBJECT:label1:Name = "label1".
        THIS-OBJECT:label1:Size = NEW System.Drawing.Size(67, 29).
        THIS-OBJECT:label1:TabIndex = 3.
        THIS-OBJECT:label1:Text = "Nombre de mur :".
        THIS-OBJECT:label1:TextAlign = System.Drawing.ContentAlignment:TopRight.
        THIS-OBJECT:label1:UseCompatibleTextRendering = TRUE.
        /*  */
        /* NbrMurMini */
        /*  */
        THIS-OBJECT:NbrMurMini:Location = NEW System.Drawing.Point(85, 621).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar0 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar0[1] = 400.
        arrayvar0[2] = 0.
        arrayvar0[3] = 0.
        arrayvar0[4] = 0.
        THIS-OBJECT:NbrMurMini:Maximum = Progress.Util.DecimalHelper:Create(arrayvar0).
        THIS-OBJECT:NbrMurMini:Name = "NbrMurMini".
        THIS-OBJECT:NbrMurMini:Size = NEW System.Drawing.Size(48, 20).
        THIS-OBJECT:NbrMurMini:TabIndex = 4.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar1 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar1[1] = 100.
        arrayvar1[2] = 0.
        arrayvar1[3] = 0.
        arrayvar1[4] = 0.
        THIS-OBJECT:NbrMurMini:Value = Progress.Util.DecimalHelper:Create(arrayvar1).
        /*  */
        /* E_log */
        /*  */
        THIS-OBJECT:E_log:Location = NEW System.Drawing.Point(626, 266).
        THIS-OBJECT:E_log:Multiline = TRUE.
        THIS-OBJECT:E_log:Name = "E_log".
        THIS-OBJECT:E_log:ReadOnly = TRUE.
        THIS-OBJECT:E_log:Size = NEW System.Drawing.Size(276, 364).
        THIS-OBJECT:E_log:TabIndex = 5.
        /*  */
        /* T_CordonneeDepart */
        /*  */
        THIS-OBJECT:T_CordonneeDepart:Location = NEW System.Drawing.Point(697, 73).
        THIS-OBJECT:T_CordonneeDepart:Name = "T_CordonneeDepart".
        THIS-OBJECT:T_CordonneeDepart:ReadOnly = TRUE.
        THIS-OBJECT:T_CordonneeDepart:Size = NEW System.Drawing.Size(86, 20).
        THIS-OBJECT:T_CordonneeDepart:TabIndex = 6.
        /*  */
        /* T_CordonneeArrivee */
        /*  */
        THIS-OBJECT:T_CordonneeArrivee:Location = NEW System.Drawing.Point(697, 99).
        THIS-OBJECT:T_CordonneeArrivee:Name = "T_CordonneeArrivee".
        THIS-OBJECT:T_CordonneeArrivee:ReadOnly = TRUE.
        THIS-OBJECT:T_CordonneeArrivee:Size = NEW System.Drawing.Size(86, 20).
        THIS-OBJECT:T_CordonneeArrivee:TabIndex = 7.
        /*  */
        /* label2 */
        /*  */
        THIS-OBJECT:label2:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(14.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label2:Location = NEW System.Drawing.Point(626, 238).
        THIS-OBJECT:label2:Name = "label2".
        THIS-OBJECT:label2:Size = NEW System.Drawing.Size(151, 25).
        THIS-OBJECT:label2:TabIndex = 8.
        THIS-OBJECT:label2:Text = "Fenˆtre de log".
        THIS-OBJECT:label2:UseCompatibleTextRendering = TRUE.
        /*  */
        /* label3 */
        /*  */
        THIS-OBJECT:label3:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label3:Location = NEW System.Drawing.Point(630, 73).
        THIS-OBJECT:label3:Name = "label3".
        THIS-OBJECT:label3:Size = NEW System.Drawing.Size(55, 19).
        THIS-OBJECT:label3:TabIndex = 9.
        THIS-OBJECT:label3:Text = "D‚part :".
        THIS-OBJECT:label3:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
        THIS-OBJECT:label3:UseCompatibleTextRendering = TRUE.
        /*  */
        /* label4 */
        /*  */
        THIS-OBJECT:label4:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label4:Location = NEW System.Drawing.Point(630, 100).
        THIS-OBJECT:label4:Name = "label4".
        THIS-OBJECT:label4:Size = NEW System.Drawing.Size(55, 19).
        THIS-OBJECT:label4:TabIndex = 10.
        THIS-OBJECT:label4:Text = "Arriv‚e :".
        THIS-OBJECT:label4:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
        THIS-OBJECT:label4:UseCompatibleTextRendering = TRUE.
        /*  */
        /* label5 */
        /*  */
        THIS-OBJECT:label5:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(14.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        THIS-OBJECT:label5:Location = NEW System.Drawing.Point(630, 14).
        THIS-OBJECT:label5:Name = "label5".
        THIS-OBJECT:label5:Size = NEW System.Drawing.Size(254, 45).
        THIS-OBJECT:label5:TabIndex = 13.
        THIS-OBJECT:label5:Text = "S‚lectionnez un d‚part et une arriv‚e".
        THIS-OBJECT:label5:UseCompatibleTextRendering = TRUE.
        /*  */
        /* B_RechercheDeChemin */
        /*  */
        THIS-OBJECT:B_RechercheDeChemin:Location = NEW System.Drawing.Point(789, 130).
        THIS-OBJECT:B_RechercheDeChemin:Name = "B_RechercheDeChemin".
        THIS-OBJECT:B_RechercheDeChemin:Size = NEW System.Drawing.Size(72, 19).
        THIS-OBJECT:B_RechercheDeChemin:TabIndex = 16.
        THIS-OBJECT:B_RechercheDeChemin:Text = "Start".
        THIS-OBJECT:B_RechercheDeChemin:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:B_RechercheDeChemin:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:B_RechercheDeChemin:Click:Subscribe(THIS-OBJECT:B_RechercheDeChemin_Click).
        /*  */
        /* B_sauver */
        /*  */
        THIS-OBJECT:B_sauver:Location = NEW System.Drawing.Point(508, 618).
        THIS-OBJECT:B_sauver:Name = "B_sauver".
        THIS-OBJECT:B_sauver:Size = NEW System.Drawing.Size(101, 23).
        THIS-OBJECT:B_sauver:TabIndex = 19.
        THIS-OBJECT:B_sauver:Text = "Sauver le plateau".
        THIS-OBJECT:B_sauver:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:B_sauver:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:B_sauver:Click:Subscribe(THIS-OBJECT:B_sauver_Click).
        /*  */
        /* B_charger */
        /*  */
        THIS-OBJECT:B_charger:Location = NEW System.Drawing.Point(399, 618).
        THIS-OBJECT:B_charger:Name = "B_charger".
        THIS-OBJECT:B_charger:Size = NEW System.Drawing.Size(105, 23).
        THIS-OBJECT:B_charger:TabIndex = 20.
        THIS-OBJECT:B_charger:Text = "Charger le plateau".
        THIS-OBJECT:B_charger:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:B_charger:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:B_charger:Click:Subscribe(THIS-OBJECT:B_charger_Click).
        /*  */
        /* groupBox2 */
        /*  */
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:Ouest).
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:Est).
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:Sud).
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:Nord).
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:radioButton2).
        THIS-OBJECT:groupBox2:Controls:Add(THIS-OBJECT:radioButton1).
        THIS-OBJECT:groupBox2:Location = NEW System.Drawing.Point(630, 158).
        THIS-OBJECT:groupBox2:Name = "groupBox2".
        THIS-OBJECT:groupBox2:Size = NEW System.Drawing.Size(254, 73).
        THIS-OBJECT:groupBox2:TabIndex = 21.
        THIS-OBJECT:groupBox2:TabStop = FALSE.
        THIS-OBJECT:groupBox2:Text = "Action de la molette ".
        THIS-OBJECT:groupBox2:UseCompatibleTextRendering = TRUE.
        /*  */
        /* Ouest */
        /*  */
        THIS-OBJECT:Ouest:Location = NEW System.Drawing.Point(192, 41).
        THIS-OBJECT:Ouest:Name = "Ouest".
        THIS-OBJECT:Ouest:Size = NEW System.Drawing.Size(56, 26).
        THIS-OBJECT:Ouest:TabIndex = 5.
        THIS-OBJECT:Ouest:Text = "Ouest".
        THIS-OBJECT:Ouest:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:Ouest:UseVisualStyleBackColor = TRUE.
        /*  */
        /* Est */
        /*  */
        THIS-OBJECT:Est:Location = NEW System.Drawing.Point(77, 41).
        THIS-OBJECT:Est:Name = "Est".
        THIS-OBJECT:Est:Size = NEW System.Drawing.Size(49, 26).
        THIS-OBJECT:Est:TabIndex = 4.
        THIS-OBJECT:Est:Text = "Est".
        THIS-OBJECT:Est:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:Est:UseVisualStyleBackColor = TRUE.
        /*  */
        /* Sud */
        /*  */
        THIS-OBJECT:Sud:Location = NEW System.Drawing.Point(6, 41).
        THIS-OBJECT:Sud:Name = "Sud".
        THIS-OBJECT:Sud:Size = NEW System.Drawing.Size(49, 26).
        THIS-OBJECT:Sud:TabIndex = 3.
        THIS-OBJECT:Sud:Text = "Sud".
        THIS-OBJECT:Sud:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:Sud:UseVisualStyleBackColor = TRUE.
        /*  */
        /* Nord */
        /*  */
        THIS-OBJECT:Nord:Location = NEW System.Drawing.Point(192, 15).
        THIS-OBJECT:Nord:Name = "Nord".
        THIS-OBJECT:Nord:Size = NEW System.Drawing.Size(52, 26).
        THIS-OBJECT:Nord:TabIndex = 2.
        THIS-OBJECT:Nord:Text = "Nord".
        THIS-OBJECT:Nord:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:Nord:UseVisualStyleBackColor = TRUE.
        /*  */
        /* radioButton2 */
        /*  */
        THIS-OBJECT:radioButton2:Location = NEW System.Drawing.Point(77, 15).
        THIS-OBJECT:radioButton2:Name = "radioButton2".
        THIS-OBJECT:radioButton2:Size = NEW System.Drawing.Size(104, 26).
        THIS-OBJECT:radioButton2:TabIndex = 1.
        THIS-OBJECT:radioButton2:Text = "Ralentissement".
        THIS-OBJECT:radioButton2:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:radioButton2:UseVisualStyleBackColor = TRUE.
        /*  */
        /* radioButton1 */
        /*  */
        THIS-OBJECT:radioButton1:Checked = TRUE.
        THIS-OBJECT:radioButton1:Location = NEW System.Drawing.Point(6, 15).
        THIS-OBJECT:radioButton1:Name = "radioButton1".
        THIS-OBJECT:radioButton1:Size = NEW System.Drawing.Size(49, 26).
        THIS-OBJECT:radioButton1:TabIndex = 0.
        THIS-OBJECT:radioButton1:TabStop = TRUE.
        THIS-OBJECT:radioButton1:Text = "Mur".
        THIS-OBJECT:radioButton1:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:radioButton1:UseVisualStyleBackColor = TRUE.
        /*  */
        /* NbrRall */
        /*  */
        THIS-OBJECT:NbrRall:Location = NEW System.Drawing.Point(228, 621).
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar2 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar2[1] = 400.
        arrayvar2[2] = 0.
        arrayvar2[3] = 0.
        arrayvar2[4] = 0.
        THIS-OBJECT:NbrRall:Maximum = Progress.Util.DecimalHelper:Create(arrayvar2).
        THIS-OBJECT:NbrRall:Name = "NbrRall".
        THIS-OBJECT:NbrRall:Size = NEW System.Drawing.Size(48, 20).
        THIS-OBJECT:NbrRall:TabIndex = 23.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
        DEFINE VARIABLE arrayvar3 AS INTEGER EXTENT 4 NO-UNDO.
        arrayvar3[1] = 100.
        arrayvar3[2] = 0.
        arrayvar3[3] = 0.
        arrayvar3[4] = 0.
        THIS-OBJECT:NbrRall:Value = Progress.Util.DecimalHelper:Create(arrayvar3).
        /*  */
        /* label6 */
        /*  */
        THIS-OBJECT:label6:Location = NEW System.Drawing.Point(155, 617).
        THIS-OBJECT:label6:Name = "label6".
        THIS-OBJECT:label6:Size = NEW System.Drawing.Size(67, 29).
        THIS-OBJECT:label6:TabIndex = 22.
        THIS-OBJECT:label6:Text = "Nombre de Rallentiseur :".
        THIS-OBJECT:label6:TextAlign = System.Drawing.ContentAlignment:TopRight.
        THIS-OBJECT:label6:UseCompatibleTextRendering = TRUE.
        /*  */
        /* b_precedent */
        /*  */
        THIS-OBJECT:b_precedent:Location = NEW System.Drawing.Point(634, 130).
        THIS-OBJECT:b_precedent:Name = "b_precedent".
        THIS-OBJECT:b_precedent:Size = NEW System.Drawing.Size(26, 20).
        THIS-OBJECT:b_precedent:TabIndex = 24.
        THIS-OBJECT:b_precedent:Text = "button1".
        THIS-OBJECT:b_precedent:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:b_precedent:UseVisualStyleBackColor = TRUE.
        /*  */
        /* b_Pause */
        /*  */
        THIS-OBJECT:b_Pause:Location = NEW System.Drawing.Point(663, 130).
        THIS-OBJECT:b_Pause:Name = "b_Pause".
        THIS-OBJECT:b_Pause:Size = NEW System.Drawing.Size(36, 20).
        THIS-OBJECT:b_Pause:TabIndex = 25.
        THIS-OBJECT:b_Pause:Text = "button1".
        THIS-OBJECT:b_Pause:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:b_Pause:UseVisualStyleBackColor = TRUE.
        /*  */
        /* b_Play */
        /*  */
        THIS-OBJECT:b_Play:Location = NEW System.Drawing.Point(701, 130).
        THIS-OBJECT:b_Play:Name = "b_Play".
        THIS-OBJECT:b_Play:Size = NEW System.Drawing.Size(36, 20).
        THIS-OBJECT:b_Play:TabIndex = 26.
        THIS-OBJECT:b_Play:Text = "button2".
        THIS-OBJECT:b_Play:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:b_Play:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:b_Play:Click:Subscribe(THIS-OBJECT:button2_Click).
        /*  */
        /* Suivant */
        /*  */
        THIS-OBJECT:Suivant:Location = NEW System.Drawing.Point(739, 130).
        THIS-OBJECT:Suivant:Name = "Suivant".
        THIS-OBJECT:Suivant:Size = NEW System.Drawing.Size(23, 20).
        THIS-OBJECT:Suivant:TabIndex = 27.
        THIS-OBJECT:Suivant:Text = "button3".
        THIS-OBJECT:Suivant:UseCompatibleTextRendering = TRUE.
        THIS-OBJECT:Suivant:UseVisualStyleBackColor = TRUE.
        THIS-OBJECT:Suivant:Click:Subscribe(THIS-OBJECT:button3_Click).
        /*  */
        /* Plateau */
        /*  */
        THIS-OBJECT:ClientSize = NEW System.Drawing.Size(920, 648).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:Suivant).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:b_Play).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:b_Pause).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:b_precedent).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:NbrRall).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label6).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:groupBox2).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:B_charger).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:B_sauver).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:B_RechercheDeChemin).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label5).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label4).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label3).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label2).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:T_CordonneeArrivee).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:T_CordonneeDepart).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:E_log).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:NbrMurMini).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:label1).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:B_Generation).
        THIS-OBJECT:Controls:Add(THIS-OBJECT:Y_panel).
        THIS-OBJECT:Name = "Plateau".
        THIS-OBJECT:Text = "Plateau".
        THIS-OBJECT:Load:Subscribe(THIS-OBJECT:Plateau_Load).
        CAST(THIS-OBJECT:NbrMurMini, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:groupBox2:ResumeLayout(FALSE).
        CAST(THIS-OBJECT:NbrRall, System.ComponentModel.ISupportInitialize):EndInit().
        THIS-OBJECT:ResumeLayout(FALSE).
        THIS-OBJECT:PerformLayout().
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.
    END METHOD.
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID Plateau_Load( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
		RETURN.

	END METHOD.

    METHOD PUBLIC VOID ResetPlateau ():

        DEF VAR i AS INTE NO-UNDO.
        DEF VAR j AS INTE NO-UNDO.
        
        EXTENT(v_Plateau) = 1.
        DO i = 1 TO 20:
            DO j = 1 TO 20:
                IF EXTENT(v_Plateau) = 1 THEN 
                DO:
                    v_Plateau[EXTENT(v_Plateau)] = NEW Tmp.Cellule(EXTENT(v_Plateau),i,j).
                END.
                DO:
                    EXTENT(v_Plateau) = EXTENT(v_Plateau) + 1. 
                    v_Plateau[EXTENT(v_Plateau)] = NEW Tmp.Cellule(EXTENT(v_Plateau),i,j).
                END.
            END.
        END.
        
        IF VALID-OBJECT (v_Chemins) THEN 
            DELETE OBJECT v_Chemins.
        IF VALID-OBJECT (v_Depart) THEN 
            DELETE OBJECT v_Depart.
        IF VALID-OBJECT (v_Arrivee) THEN 
            DELETE OBJECT v_Arrivee.
            
    END METHOD.
    
  
    



    /* M‚thode pour dessiner la grille */
    /***************************************************************************************************/
    METHOD PRIVATE VOID Panel_Paint(sender AS System.Object, e AS PaintEventArgs):
        
        DEF VAR v_graphics AS Graphics            NO-UNDO.
        DEF VAR v_pen      AS Pen                 NO-UNDO.
        DEF VAR v_brush    AS SolidBrush          NO-UNDO.
        DEF VAR v_font     AS System.Drawing.Font NO-UNDO.
        DEF VAR v_lettres  AS CHARACTER           NO-UNDO.
        DEF VAR i          AS INTEGER             NO-UNDO.
        DEF VAR v_randomX  AS INTEGER             NO-UNDO.
        DEF VAR v_randomY  AS INTEGER             NO-UNDO.
        DEF VAR v_X        AS INTE                NO-UNDO.
        DEF VAR v_Y        AS INTE                NO-UNDO.
        


        v_graphics  = e:Graphics.
        v_Graph     = e:Graphics.
        v_pen       = NEW Pen(Color:Black).
        v_brush     = NEW SolidBrush(Color:Black).
        v_font      = NEW Font("Arial", 10).

        /* Lettres pour l'axe des abscisses */
        v_lettres = "ABCDEFGHIJKLMNOPQRST".

        /* Dessiner les lignes horizontales et les labels */
        DO i = 0 TO 20:
            v_graphics:DrawLine(v_pen, 25, i * 25 + 25, 525, i * 25 + 25).
            IF i > 0 THEN
                v_graphics:DrawString(STRING(i), v_font, v_brush, 5, i * 25 + 10).
        END.

        /* Dessiner les lignes verticales et les labels */
        DO i = 0 TO 20:
            v_graphics:DrawLine(v_pen, i * 25 + 25, 25, i * 25 + 25, 525).
            IF i > 0 THEN
                v_graphics:DrawString(SUBSTRING(v_lettres, i, 1), v_font, v_brush, i * 25 + 10, 5).
        END.

        DELETE OBJECT v_pen.
        DELETE OBJECT v_brush.
        DELETE OBJECT v_font. 

        v_pen   = NEW Pen(Color:Black).
        v_brush = NEW SolidBrush(Color:LightBlue).

        /* Dessiner la cellule B4 en couleur */

        DELETE OBJECT v_pen.
        DELETE OBJECT v_brush.
        
        DO i = 1 TO EXTENT(v_Plateau):
            
            IF v_Plateau[i]:EstMur() THEN
            DO:
                //MESSAGE i VIEW-AS ALERT-BOX.
                v_brush = NEW SolidBrush(Color:Red).
                v_graphics:FillRectangle(v_brush,((v_Plateau[i]:PX - 1 )* 25 + 26) , ((v_Plateau[i]:PY - 1 ) * 25 + 26) , 24, 24).
            END.
            ELSE
            IF v_Plateau[i]:EstParcouru() THEN
            DO:
                IF v_Plateau[i]:Cont < 20 THEN
                    v_brush = NEW SolidBrush(COLOR:FromArgb( INTEGER(255 * v_Plateau[i]:Cont / 20) , INTEGER(204 + v_Plateau[i]:Cont) , 0)).
                ELSE
                    v_brush = NEW SolidBrush(COLOR:FromArgb( INTEGER(255 ) , INTEGER(204 ) , 0)).
                v_graphics:FillRectangle(v_brush,((v_Plateau[i]:PX - 1 )* 25 + 26) , ((v_Plateau[i]:PY - 1 ) * 25 + 26) , 24, 24).    
            END.
            ELSE
            IF v_Plateau[i]:EstRall() THEN
            DO:
                //MESSAGE i VIEW-AS ALERT-BOX.
                v_brush = NEW SolidBrush(Color:Orange).
                v_graphics:FillRectangle(v_brush,((v_Plateau[i]:PX - 1 )* 25 + 26) , ((v_Plateau[i]:PY - 1 ) * 25 + 26) , 24, 24).
            END.
            ELSE 
            IF v_plateau[i]:Directions = Tmp.Directions:Nord THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/Nord.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:NordEtEst THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/NordEtEst.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:NordEtOuest THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/NordEtOuest.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:Ouest THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/Ouest.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:SudEtOuest THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/SudEtOuest.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:Sud THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/Sud.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:SudEtEst THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/SudEtEst.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
            ELSE
            IF v_plateau[i]:Directions = Tmp.Directions:Est THEN 
            DO:
                v_graphics:DrawImage(IMAGE:FromFile("Tmp/Img/Est.png"), (v_Plateau[i]:PX - 1 ) * 25 + 26, (v_Plateau[i]:PY - 1 ) * 25 + 26, 24, 24).
            END.
        END.
        
        IF VALID-OBJECT(v_Arrivee) THEN
            ColorierArrivee(v_Arrivee:PX,v_Arrivee:PY , e).   
        IF VALID-OBJECT(v_Depart) THEN
            ColorierDepart(v_Depart:PX,v_Depart:PY , e).  

        DessinChemin(e).
        //MESSAGE "2" VIEW-AS ALERT-BOX.
        
    END METHOD.
    
    
    METHOD PUBLIC VOID GenererRall (pi_RallMinim AS INTE):
        DEF VAR v_RandomX AS INTE NO-UNDO.
        DEF VAR v_RandomY AS INTE NO-UNDO.
        DEF VAR v_Sortir  AS LOGI NO-UNDO.
        DEF VAR i         AS INTE NO-UNDO.
        DEF VAR j         AS INTE NO-UNDO.
        
        //ResetPlateau().
        
        DO i = 1 TO PI_RallMinim:
            v_Sortir = NO.
            REPEAT:
                v_RandomX = RANDOM( 0, 20).
                v_RandomY = RANDOM( 0, 20).
                                                        
                j = IdCellule(v_RandomX, v_RandomY).
                IF j <> ? THEN 
                DO:
                    IF NOT v_Plateau[j]:EstRall() AND NOT v_Plateau[j]:estMur() THEN 
                    DO:
                        v_Plateau[j]:DevenirRall().
                        v_Sortir = YES.
                    END.
                    IF v_Sortir THEN
                        LEAVE.
                END.
            END.
        END.
         
    END METHOD.
    
    METHOD PUBLIC VOID GenererMur (pi_MurMinim AS INTE):
        DEF VAR v_RandomX AS INTE NO-UNDO.
        DEF VAR v_RandomY AS INTE NO-UNDO.
        DEF VAR v_Sortir  AS LOGI NO-UNDO.
        DEF VAR i         AS INTE NO-UNDO.
        DEF VAR j         AS INTE NO-UNDO.
        
        //ResetPlateau().
        
        DO i = 1 TO PI_MurMinim :
            v_Sortir = NO.
            REPEAT:
                v_RandomX = RANDOM( 0, 20).
                v_RandomY = RANDOM( 0, 20).

                j = IdCellule(v_RandomX, v_RandomY).
                IF j <> ? THEN
                DO:
                    IF NOT v_Plateau[j]:EstRall() AND NOT v_Plateau[j]:estMur() THEN
                    DO:
                        v_Plateau[j]:DevenirMur().
                        v_Sortir = YES.
                    END.
                    IF v_Sortir THEN
                        LEAVE.
                END.
            END.
        END.
         
    END METHOD.
    
    METHOD PRIVATE INTE ComparaisonHeuristique (pi_Cellule1 AS tmp.cellule, pi_Cellule2 AS tmp.cellule) :
        
        IF MoinDeVirage:CHECKED THEN 
        DO:
            IF pi_Cellule1:heuristique < pi_Cellule2:heuristique THEN 
                RETURN 1.
            ELSE 
                IF pi_Cellule1:heuristique = pi_Cellule2:heuristique THEN 
                    RETURN 0.
                ELSE
                    RETURN -1.
        END.
        ELSE
        DO:
            IF pi_Cellule1:heuristique + pi_Cellule1:CoefRall < pi_Cellule2:heuristique + pi_Cellule1:CoefRall THEN 
                RETURN 1.
            ELSE
                IF pi_Cellule1:heuristique + pi_Cellule1:CoefRall = pi_Cellule2:heuristique + pi_Cellule2:CoefRall THEN 
                    RETURN 0.
                ELSE
                    RETURN -1.
        END.       
    END METHOD.
    
    METHOD PRIVATE LOGI RechercheAStar ():

        DEF VAR v_CellulesVisitees  AS System.Collections.ArrayList   NO-UNDO.
        DEF VAR v_CellulesCourantes AS OpenEdge.Core.Collections.List NO-UNDO.
        DEF VAR v_CelluleN          AS tmp.cellule                    NO-UNDO.
        DEF VAR v_CelluleE          AS tmp.cellule                    NO-UNDO.
        DEF VAR v_CelluleS          AS tmp.cellule                    NO-UNDO.
        DEF VAR v_CelluleW          AS tmp.cellule                    NO-UNDO.
        DEF VAR v_CelluleNE         AS tmp.Cellule                    NO-UNDO. 
        DEF VAR v_CelluleSE         AS tmp.Cellule                    NO-UNDO.
        DEF VAR v_CelluleSW         AS tmp.Cellule                    NO-UNDO.
        DEF VAR v_CelluleNW         AS tmp.Cellule                    NO-UNDO.
        DEF VAR v_Cellule           AS tmp.cellule                    NO-UNDO.
        DEF VAR v_CelluleAdjacente  AS tmp.cellule                    NO-UNDO.
        DEF VAR v_Curseur           AS INTE                           NO-UNDO.
        DEF VAR i                   AS INTE                           NO-UNDO.
        DEF VAR j                   AS INTE                           NO-UNDO.
        DEF VAR v_Cont              AS INTE                           NO-UNDO.
        DEF VAR v_CelluleDuChemin   AS tmp.cellule                    NO-UNDO.
        DEF VAR v_PremiereIteration AS LOGI                           NO-UNDO INIT YES.
        DEF VAR v_IDCellule         AS INTE                           NO-UNDO.

        IF VALID-OBJECT(v_Chemins) THEN
            DELETE OBJECT v_Chemins.
        ASSIGN
            v_CellulesVisitees  = NEW System.Collections.ArrayList ()
            v_CellulesCourantes = NEW OpenEdge.Core.Collections.List ().

        v_CellulesCourantes:ADD(v_Depart).
        v_CellulesVisitees:ADD(v_Depart:ID).

        DO WHILE v_CellulesCourantes:SIZE > 0 OR v_PremiereIteration :
            v_PremiereIteration = NO.
            v_Cellule = CAST (v_CellulesCourantes:GET(1) , tmp.cellule ).
            v_CellulesCourantes:Remove(1).

            IF v_Cellule:PX = v_arrivee:PX AND v_Cellule:PY = v_arrivee:PY THEN
            DO:
                //ReconstitutionChemin (v_Cellule)
                v_Chemins = NEW System.Collections.ArrayList().
                REPEAT:
                    v_Cont = v_Cellule:Cont.
                    CellulesAdjacente(v_Cellule,
                                      OUTPUT v_CelluleN,
                                      OUTPUT v_CelluleNE,
                                      OUTPUT v_CelluleE,
                                      OUTPUT v_CelluleSE,
                                      OUTPUT v_CelluleS,
                                      OUTPUT v_CelluleSW,
                                      OUTPUT v_CelluleW,
                                      OUTPUT v_CelluleNW,
                                      NO ).
                    DO i = 1 TO 8 :
                        CASE i :
                            WHEN 1 THEN
                                IF VALID-OBJECT (v_CelluleN) THEN
                                    v_CelluleAdjacente = v_CelluleN.
                            WHEN 2 THEN
                                IF VALID-OBJECT (v_CelluleNE) THEN
                                    v_CelluleAdjacente = v_CelluleNE.
                            WHEN 3 THEN
                                IF VALID-OBJECT (v_CelluleE) THEN
                                    v_CelluleAdjacente = v_CelluleE.
                            WHEN 4 THEN
                                IF VALID-OBJECT (v_CelluleSE) THEN
                                    v_CelluleAdjacente = v_CelluleSE.
                            WHEN 5 THEN
                                IF VALID-OBJECT (v_CelluleS) THEN
                                    v_CelluleAdjacente = v_CelluleS.
                            WHEN 6 THEN
                                IF VALID-OBJECT (v_CelluleSW) THEN
                                    v_CelluleAdjacente = v_CelluleSW.
                            WHEN 7 THEN
                                IF VALID-OBJECT (v_CelluleW) THEN
                                    v_CelluleAdjacente = v_CelluleW.
                            WHEN 8 THEN
                                IF VALID-OBJECT (v_CelluleNW) THEN
                                    v_CelluleAdjacente = v_CelluleNW.
                        END CASE.
                        //IF i = 1 OR i = 2 OR i = 3 OR i = 4 THEN
                            //MESSAGE v_CelluleAdjacente VIEW-AS ALERT-BOX.
                        IF MoinDeVirage:CHECKED THEN
                        DO:
                            IF VALID-OBJECT (v_CelluleAdjacente)
                               //AND NOT v_CelluleAdjacente:estMur()
                               AND (( v_CelluleAdjacente:Cont < v_Cont AND (i = 1 OR i = 3 OR i = 5 OR i = 7)) OR (v_CelluleAdjacente:Cont + 1 < v_Cont AND (i = 2 OR i = 4 OR i = 6 OR i = 8)))
                               AND v_CelluleAdjacente:Cont <> 0 THEN
                            DO:
                                v_Cont = v_CelluleAdjacente:Cont.
                                v_CelluleDuChemin = v_CelluleAdjacente.
                            END.
                        END.
                        ELSE
                        DO:
                            IF VALID-OBJECT (v_CelluleAdjacente)
                               //AND NOT v_CelluleAdjacente:estMur()
                               AND v_CelluleAdjacente:Cont - v_CelluleAdjacente:CoefRall < v_Cont
                               AND v_CelluleAdjacente:Cont <> 0 THEN
                            DO:
                                v_Cont = v_CelluleAdjacente:Cont.
                                v_CelluleDuChemin = v_CelluleAdjacente.
                            END.
                        END.
                        IF v_Cellule:Cont - v_Cellule:CoefRall = 0 THEN
                            RETURN YES.
                    END.

                    MESSAGE v_CelluleDuChemin v_CelluleDuChemin:Cont VIEW-AS ALERT-BOX.

                    v_Cellule = v_CelluleDuChemin.
                    v_Chemins:ADD (CAST(v_CelluleDuChemin , tmp.cellule)).

                END.
                RETURN YES.
            END.

            CellulesAdjacente(v_Cellule,
                              OUTPUT v_CelluleN,
                              OUTPUT v_CelluleNE,
                              OUTPUT v_CelluleE,
                              OUTPUT v_CelluleSE,
                              OUTPUT v_CelluleS,
                              OUTPUT v_CelluleSW,
                              OUTPUT v_CelluleW,
                              OUTPUT v_CelluleNW,
                              YES ).
            DO i = 1 TO 8 :

                CASE i :
                    WHEN 1 THEN
                        IF VALID-OBJECT (v_CelluleN) THEN
                            v_CelluleAdjacente = v_CelluleN.
                    WHEN 2 THEN
                        IF VALID-OBJECT (v_CelluleNE) THEN
                            v_CelluleAdjacente = v_CelluleNE.
                    WHEN 3 THEN
                        IF VALID-OBJECT (v_CelluleE) THEN
                            v_CelluleAdjacente = v_CelluleE.
                    WHEN 4 THEN
                        IF VALID-OBJECT (v_CelluleSE) THEN
                            v_CelluleAdjacente = v_CelluleSE.
                    WHEN 5 THEN
                        IF VALID-OBJECT (v_CelluleS) THEN
                            v_CelluleAdjacente = v_CelluleS.
                    WHEN 6 THEN
                        IF VALID-OBJECT (v_CelluleSW) THEN
                            v_CelluleAdjacente = v_CelluleSW.
                    WHEN 7 THEN
                        IF VALID-OBJECT (v_CelluleW) THEN
                            v_CelluleAdjacente = v_CelluleW.
                    WHEN 8 THEN
                        IF VALID-OBJECT (v_CelluleNW) THEN
                            v_CelluleAdjacente = v_CelluleNW.
                END CASE.

                IF  VALID-OBJECT (v_CelluleAdjacente)
                    AND NOT v_CelluleAdjacente:estMur()
                    AND NOT ( v_CellulesVisitees:CONTAINS(v_CelluleAdjacente:ID) OR v_CellulesCourantes:CONTAINS(v_CelluleAdjacente) OR (v_CellulesCourantes:CONTAINS(v_CelluleAdjacente) AND v_CelluleAdjacente:Cont < v_Cellule:Cont)) THEN 
                DO:
                    IF v_CelluleAdjacente:Directions = Tmp.Directions:Toutes THEN 
                        v_CelluleAdjacente:DevientParcouru().
                    IF MoinDeVirage:CHECKED THEN
                    DO:
                        IF i = 2 OR i = 4 OR i = 6 OR i = 8 THEN
                            v_CelluleAdjacente:Cont = v_Cellule:Cont + 2.
                        ELSE
                            v_CelluleAdjacente:Cont = v_Cellule:Cont + 1.
                    END.
                    ELSE
                    DO:
                        v_CelluleAdjacente:Cont = v_Cellule:Cont + 1 * v_CelluleAdjacente:CoefRall.
                    END.

                    v_CelluleAdjacente:Heuristique = v_CelluleAdjacente:Cont + SQRT(EXP(v_CelluleAdjacente:PX - v_Arrivee:PX, 2) + EXP(v_CelluleAdjacente:PY - v_Arrivee:PY , 2)).

                    ParcourCellules:
                    DO j = 1 TO v_CellulesCourantes:SIZE:
                        IF ComparaisonHeuristique(v_CelluleAdjacente , CAST(v_CellulesCourantes:GET(j) , Tmp.Cellule ) ) >= 0 THEN
                        DO:
                            v_CellulesCourantes:ADD(j , v_CelluleAdjacente).
                            LEAVE ParcourCellules.
                        END.
                    END.
                    IF NOT v_CellulesCourantes:CONTAINS(v_CelluleAdjacente) THEN
                    DO:
                        v_CellulesCourantes:ADD(v_CelluleAdjacente).
                    END.
                END.
            END.
            //REFRESH().
            /*E_Log:TEXT = E_Log:TEXT + " Liste Ferm‚e (v_CellulesVisitees): ".
            DO i = 0 TO v_CellulesVisitees:COUNT - 1 :
                v_IDCellule = v_CellulesVisitees[i].
                IF VALID-OBJECT(v_Plateau[v_IDCellule]) THEN
                    E_Log:TEXT = E_Log:TEXT + STRING (v_Plateau[v_IDCellule]) + " " + STRING (v_Plateau[v_IDCellule]:Cont ).
            END.
            E_Log:TEXT = E_Log:TEXT + " Liste Ouverte (v_CellulesCourantes): ".
            DO i = 1 TO v_CellulesCourantes:SIZE :
                v_IDCellule = CAST (v_CellulesCourantes:GET(i) , tmp.cellule):ID .
                IF VALID-OBJECT(v_CellulesCourantes:GET (i)) THEN
                    E_Log:TEXT = E_Log:TEXT + STRING (v_CellulesCourantes:GET(i)) + " " + STRING (v_Plateau[v_IDCellule]:Cont ).
            END.
            //MESSAGE " " VIEW-AS ALERT-BOX.
            E_Log:TEXT = "".*/
            //thread:sleep(100).
            v_CellulesVisitees:ADD(v_cellule:ID).
            //MESSAGE v_cellule VIEW-AS ALERT-BOX.
        END.
        
        RETURN NO.
    END METHOD.
    
    METHOD PRIVATE LOGI ReconstitutionChemin ( INPUT pi_Cellule AS tmp.cellule ):
        DEF VAR v_Cont             AS INTE        NO-UNDO.
        DEF VAR v_CelluleN         AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleNE        AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleE         AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleSE        AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleS         AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleSW        AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleW         AS tmp.cellule NO-UNDO.
        DEF VAR v_CelluleNW        AS tmp.cellule NO-UNDO.
        DEF VAR i                  AS INTE        NO-UNDO.
        DEF VAR v_CelluleAdjacente AS tmp.cellule NO-UNDO. 
        DEF VAR v_CelluleDuChemin  AS tmp.cellule NO-UNDO.   
        
        v_Chemins = NEW System.Collections.ArrayList().
        REPEAT:
            v_Cont = pi_Cellule:Cont.
            CellulesAdjacente(pi_Cellule,
                OUTPUT v_CelluleN,
                OUTPUT v_CelluleNE,
                OUTPUT v_CelluleE,
                OUTPUT v_CelluleSE,
                OUTPUT v_CelluleS,
                OUTPUT v_CelluleSW,
                OUTPUT v_CelluleW,
                OUTPUT v_CelluleNW,
                YES ).
            DO i = 1 TO 8 :
                        
                CASE i :
                    WHEN 1 THEN
                        IF VALID-OBJECT (v_CelluleN) THEN
                            v_CelluleAdjacente = v_CelluleN.
                    WHEN 2 THEN
                        IF VALID-OBJECT (v_CelluleNE) THEN
                            v_CelluleAdjacente = v_CelluleNE.
                    WHEN 3 THEN
                        IF VALID-OBJECT (v_CelluleE) THEN
                            v_CelluleAdjacente = v_CelluleE.
                    WHEN 4 THEN
                        IF VALID-OBJECT (v_CelluleSE) THEN
                            v_CelluleAdjacente = v_CelluleSE.
                    WHEN 5 THEN
                        IF VALID-OBJECT (v_CelluleS) THEN
                            v_CelluleAdjacente = v_CelluleS.
                    WHEN 6 THEN
                        IF VALID-OBJECT (v_CelluleSW) THEN
                            v_CelluleAdjacente = v_CelluleSW.
                    WHEN 7 THEN
                        IF VALID-OBJECT (v_CelluleW) THEN
                            v_CelluleAdjacente = v_CelluleW.
                    WHEN 8 THEN
                        IF VALID-OBJECT (v_CelluleNW) THEN
                            v_CelluleAdjacente = v_CelluleNW.
                END CASE.

                IF VALID-OBJECT (v_CelluleAdjacente)
                           //AND NOT v_CelluleAdjacente:estMur()
                    AND v_CelluleAdjacente:Cont < v_Cont
                    AND v_CelluleAdjacente:Cont <> 0 THEN
                DO:
                    v_Cont = v_CelluleAdjacente:Cont.
                    v_CelluleDuChemin = v_CelluleAdjacente.
                END.
                IF pi_Cellule:Cont = 1 THEN
                    RETURN YES.

            END.
            pi_Cellule = v_CelluleDuChemin.
            v_Chemins:ADD (CAST(v_CelluleDuChemin , tmp.cellule)).

        END.
        RETURN YES.
    END METHOD.
    
    METHOD PRIVATE LOGI DessinChemin (INPUT e AS PaintEventArgs).

        DEF VAR i           AS INTE       NO-UNDO.
        DEF VAR v_Graphique AS graphics   NO-UNDO.
        DEF VAR v_Pinceau   AS SolidBrush NO-UNDO.

        //DO i = 1 TO 10
        v_Graphique = e:Graphics.
        v_Pinceau   = NEW SolidBrush(COLOR:Green).
        IF VALID-OBJECT (v_Chemins) THEN                                                                                                               
        DO: 
            //MESSAGE v_chemins:COUNT VIEW-AS ALERT-BOX.
            
            DO i = 0 TO v_chemins:COUNT - 1:
                //E_Log:TEXT = E_log:TEXT + STRING (CAST(v_chemins[i], tmp.cellule)).
                v_Graphique:FillRectangle(v_Pinceau,((CAST(v_chemins[i], tmp.cellule):PX - 1 )* 25 + 26) , ((CAST(v_chemins[i], tmp.cellule):PY - 1 ) * 25 + 26) , 24, 24).
            END.
            //MESSAGE " " VIEW-AS ALERT-BOX.
            E_Log:TEXT = "".
        END.
        
    END METHOD .
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID SelectionCellule( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.MouseEventArgs ):
        DEF VAR v_X AS INTE NO-UNDO.
        DEF VAR v_Y AS INTE NO-UNDO.
        DEF VAR i   AS INTE NO-UNDO.
        DEF VAR j   AS INTE NO-UNDO.
                
        IF e:X > 26 AND e:X < 526 AND e:Y > 26 AND e:Y < 526 THEN 
        DO:
            v_X = TRUNCATE (e:X / 25 ,0).
            v_Y = TRUNCATE (e:Y / 25 ,0).
            i = IdCellule(v_X , v_Y).
            //MESSAGE i VIEW-AS ALERT-BOX.
            IF VALID-OBJECT(v_Chemins) THEN 
                DELETE OBJECT v_Chemins.
            IF e:BUTTON = MouseButtons:LEFT AND NOT v_Plateau[i]:EstMur() AND NOT v_Plateau[i]:EstRall() THEN 
            DO:
                IF VALID-OBJECT (v_Arrivee) THEN
                DO:
                    IF v_Arrivee:PX <> v_X OR v_Arrivee:PY <> v_Y THEN
                    DO:
                        
                        T_CordonneeDepart:TEXT  = "(" + SUBSTRING(v_AlphaX ,v_X,1) + " , " + STRING(v_Y) + ")".
                        
                        IF v_Plateau[i]:PX = v_X AND v_Plateau[i]:PY = v_Y THEN 
                        DO:
                            
                            v_Depart = NEW Tmp.Cellule(i , v_X , v_Y , 0 , 0).
                            DO i = 1 TO EXTENT (v_plateau) :
                                IF v_plateau[i]:EstDepart() THEN
                                    v_plateau[i]:DevientNormal().    
                            END.
                            v_Plateau[v_Depart:ID]:DevientDepart().
                        END. 
                    END.
                END.
                ELSE
                DO:
                    
                    T_CordonneeDepart:TEXT  = "(" + SUBSTRING(v_AlphaX ,v_X,1) + " , " + STRING(v_Y) + ")".
                    IF v_Plateau[i]:PX = v_X AND v_Plateau[i]:PY = v_Y THEN 
                    DO:
                        v_Depart = NEW Tmp.Cellule(i, v_X , v_Y , 0 , 0).
                        DO i = 1 TO EXTENT (v_plateau) :
                            IF v_plateau[i]:EstDepart() THEN
                                v_plateau[i]:DevientNormal().
                        END.
                        v_Plateau[v_Depart:ID]:DevientDepart(). 
                    END.
                END.      
            END.   
                
            IF e:BUTTON = MouseButtons:RIGHT AND v_Plateau[i]:PX = v_X AND v_Plateau[i]:PY = v_Y AND NOT v_Plateau[i]:EstMur() AND NOT v_Plateau[i]:EstRall() THEN 
            DO:
                    
                IF VALID-OBJECT (v_Depart) THEN 
                DO:
                    IF v_Depart:PX <> v_X OR v_Depart:PY <> v_Y THEN
                    DO:
                        T_CordonneeArrivee:TEXT = "(" + SUBSTRING(v_AlphaX ,v_X,1) + " , " + STRING(v_Y) + ")".
                        IF v_Plateau[i]:PX = v_X AND v_Plateau[i]:PY = v_Y THEN 
                        DO:
                            
                            v_Arrivee = NEW Tmp.Cellule(i, v_X , v_Y , 0 , 0). 
                            DO i = 1 TO EXTENT (v_plateau) :
                                IF v_plateau[i]:EstArrivee() THEN 
                                    v_plateau[i]:DevientNormal().    
                            END.
                            v_Plateau[v_arrivee:ID]:DevientArrivee().
                        END.   
                    END.
                END.
                ELSE
                DO:
                    T_CordonneeArrivee:TEXT = "(" + SUBSTRING(v_AlphaX ,v_X,1) + " , " + STRING(v_Y) + ")". 
                    IF v_Plateau[i]:PX = v_X AND v_Plateau[i]:PY = v_Y THEN 
                    DO:
                        v_Arrivee = NEW Tmp.Cellule(i, v_X , v_Y , 0 , 0). 
                        DO i = 1 TO EXTENT (v_plateau) :
                            IF v_plateau[i]:EstArrivee() THEN 
                                v_plateau[i]:DevientNormal().    
                        END.
                        v_Plateau[v_arrivee:ID]:DevientArrivee().
                    END.
                END. 
            END.   
            IF e:BUTTON = MouseButtons:Middle THEN
            DO:
                i = IdCellule(v_X, v_Y).
                IF VALID-OBJECT (v_Depart) THEN
                    IF v_Plateau[i]:EstEgal(v_Depart)THEN
                        RETURN.
                IF VALID-OBJECT (v_Arrivee) THEN
                    IF v_Plateau[i]:EstEgal(v_Arrivee)THEN
                        RETURN. 
                IF radioButton1:CHECKED THEN
                DO:
                    IF v_Plateau[i]:EstMur() THEN
                        v_Plateau[i]:DevientNormal().
                    ELSE 
                        v_Plateau[i]:DevenirMur().
                END.
                IF radioButton2:CHECKED THEN
                DO:
                    IF v_Plateau[i]:EstRall() THEN
                        v_Plateau[i]:DevientNormal().
                    ELSE
                        v_Plateau[i]:DevenirRall().
                END.          
                IF Nord:CHECKED THEN
                DO:
                    IF v_Plateau[i]:Directions = tmp.Directions:Nord THEN 
                        v_Plateau[i]:DevientNormal().
                    ELSE
                        IF v_Plateau[i]:Directions = tmp.Directions:Est THEN
                            v_Plateau[i]:Directions = tmp.Directions:NordEtEst.
                        ELSE
                            IF v_Plateau[i]:Directions = tmp.Directions:Ouest THEN
                                v_Plateau[i]:Directions = tmp.Directions:NordEtOuest.
                            ELSE
                                v_Plateau[i]:Directions = tmp.Directions:Nord.
                                
                END.          
                IF Sud:CHECKED THEN 
                DO:
                    IF v_Plateau[i]:Directions = tmp.Directions:Sud THEN 
                        v_Plateau[i]:DevientNormal().
                    ELSE
                        IF v_Plateau[i]:Directions = tmp.Directions:Est THEN
                            v_Plateau[i]:Directions = tmp.Directions:SudEtEst.
                        ELSE
                            IF v_Plateau[i]:Directions = tmp.Directions:Ouest THEN
                                v_Plateau[i]:Directions = tmp.Directions:SudEtOuest.
                            ELSE
                                v_Plateau[i]:Directions = tmp.Directions:Sud.
                END.          
                IF Est:CHECKED THEN 
                DO:
                    IF v_Plateau[i]:Directions = tmp.Directions:Est THEN
                        v_Plateau[i]:DevientNormal().
                    ELSE
                        IF v_Plateau[i]:Directions = tmp.Directions:Nord THEN
                            v_Plateau[i]:Directions = tmp.Directions:NordEtEst.
                        ELSE
                            IF v_Plateau[i]:Directions = tmp.Directions:Sud THEN
                                v_Plateau[i]:Directions = tmp.Directions:SudEtEst.
                            ELSE
                                v_Plateau[i]:Directions = tmp.Directions:Est.
                END.                 
                IF Ouest:CHECKED THEN 
                DO:
                    IF v_Plateau[i]:Directions = tmp.Directions:Ouest THEN
                        v_Plateau[i]:DevientNormal().
                    ELSE 
                        IF v_Plateau[i]:Directions = tmp.Directions:Nord THEN
                            v_Plateau[i]:Directions = tmp.Directions:NordEtOuest.
                        ELSE
                            IF v_Plateau[i]:Directions = tmp.Directions:Sud THEN
                                v_Plateau[i]:Directions = tmp.Directions:SudEtOuest.
                            ELSE
                                v_Plateau[i]:Directions = tmp.Directions:Ouest.
                END.                
            END.
        END.
        IF VALID-OBJECT (v_Chemins) THEN 
            DELETE OBJECT v_Chemins.
        REFRESH().
        RETURN.

    END METHOD.
    
    METHOD PUBLIC INTE IdCellule (INPUT pi_PX AS INTE , INPUT pi_PY AS INTE):
    
        DEF VAR i AS INTE NO-UNDO.
        DO i = 1 TO EXTENT (v_plateau):
            IF v_Plateau[i]:PX = pi_PX AND v_Plateau[i]:PY = pi_PY THEN
                RETURN v_Plateau[i]:ID .
        END.            
        
    END METHOD.     
    
    METHOD PUBLIC VOID ColorierDepart(INPUT pi_X AS INTE , INPUT pi_Y AS INTE , INPUT e AS PaintEventArgs):
        DEF VAR v_Graphique AS Graphics NO-UNDO.
        DEF VAR v_Image     AS Image    NO-UNDO.
    
        v_Graphique = e:Graphics.
    
        v_Graphique:DrawImage(IMAGE:FromFile("Tmp/Img/accueil.png"), pi_X * 25 + 1, pi_Y * 25 + 1, 24, 24).         
    END METHOD.
    
    METHOD PUBLIC VOID ColorierArrivee(INPUT pi_X AS INTE , INPUT pi_Y AS INTE, INPUT e AS PaintEventArgs):
        DEF VAR v_Graphique AS Graphics NO-UNDO.
        DEF VAR v_Image     AS Image    NO-UNDO.
        v_Graphique = e:Graphics.
        v_Graphique:DrawImage(IMAGE:FromFile("Tmp/Img/drapeau.png"), pi_X * 25 + 1, pi_Y * 25 + 1, 24, 24).
    END METHOD.
    
    METHOD PUBLIC VOID CellulesAdjacente (INPUT  pi_Cellule     AS Tmp.Cellule,
                                          OUTPUT pio_CelluleN   AS Tmp.Cellule,
                                          OUTPUT pio_CelluleNE  AS Tmp.Cellule,
                                          OUTPUT pio_CelluleE   AS Tmp.Cellule, 
                                          OUTPUT pio_CelluleSE  AS Tmp.Cellule,
                                          OUTPUT pio_CelluleS   AS Tmp.Cellule,
                                          OUTPUT pio_CelluleSW  AS Tmp.Cellule,
                                          OUTPUT pio_CelluleW   AS Tmp.Cellule,
                                          OUTPUT pio_CelluleNW  AS Tmp.Cellule,
                                          INPUT  pi_SansUnique  AS LOGI        ):
                                                
        DEF VAR j          AS INTE NO-UNDO.
        DEF VAR i          AS INTE NO-UNDO.
        DEF VAR v_borneMin AS INTE NO-UNDO.
        DEF VAR v_borneMax AS INTE NO-UNDO.

        v_BorneMin = TRUNCATE((pi_Cellule:ID - 2) / 20 , 0 ) * 20 + 1.
        v_BorneMax = v_BorneMin + 21.
        DO j = 1 TO 8 :
            CASE j:
                WHEN 1 THEN
                    DO:
                        i = pi_Cellule:ID - 1.
                        IF  (i > 1 AND i < 402)
                            AND (i > v_BorneMin AND i < v_BorneMax)
                            AND (NOT pi_SansUnique OR pi_Cellule:DirectionPossible(Tmp.Directions:Nord)) THEN
                        DO:
                            pio_CelluleN = v_Plateau[pi_Cellule:ID - 1].
                        END.
                    END.
                WHEN 2 THEN
                    DO:
                        i = pi_Cellule:ID + 20.
                        IF  (i > 1 AND i < 402)
                            AND (NOT pi_SansUnique OR pi_Cellule:DirectionPossible(Tmp.Directions:Est)) THEN
                        DO:
                            pio_CelluleE = v_Plateau[pi_Cellule:ID + 20].
                        END.
                    END.
                WHEN 3 THEN
                    DO:
                        i = pi_Cellule:ID + 1.
                        IF  (i > 1 AND i < 402)
                            AND (i > v_BorneMin AND i < v_BorneMax)
                            AND (NOT pi_SansUnique OR pi_Cellule:DirectionPossible(Tmp.Directions:Sud)) THEN
                        DO:
                            pio_CelluleS = v_Plateau[pi_Cellule:ID + 1].
                        END.
                    END.
                WHEN 4 THEN
                    DO:
                        i = pi_Cellule:ID - 20.
                        IF  (i > 1 AND i < 402)
                            AND (NOT pi_SansUnique OR pi_Cellule:DirectionPossible(Tmp.Directions:Ouest)) THEN
                        DO:
                            pio_CelluleW = v_Plateau[pi_Cellule:ID - 20].
                        END.
                    END.
                WHEN 5 THEN
                    DO:
                        i = pi_Cellule:ID + 19.
                        IF  (i > 1 AND i < 402)
                            AND FALSE
                            AND (i > v_BorneMin + 20 AND i < v_BorneMax + 20) 
                            AND NO  THEN
                        DO:
                            pio_CelluleNE = v_Plateau[pi_Cellule:ID + 19].
                        END.
                    END.
                WHEN 6 THEN 
                    DO:
                        i = pi_Cellule:ID + 21.
                        IF  (i > 1 AND i < 402) 
                            AND FALSE
                            AND (i > v_BorneMin + 20 AND i < v_BorneMax + 20) 
                            AND NO THEN
                        DO:
                            pio_CelluleSE = v_Plateau[pi_Cellule:ID + 21].
                        END.
                    END.
                WHEN 7 THEN
                    DO:
                        i = pi_Cellule:ID - 19.
                        IF  (i > 1 AND i < 402) 
                            AND FALSE
                            AND (i > v_BorneMin - 20 AND i < v_BorneMax - 20) 
                            AND NO THEN
                        DO:
                            pio_CelluleNW = v_Plateau[pi_Cellule:ID - 19].
                        END.
                    END.
                WHEN 8 THEN
                    DO:
                        i = pi_Cellule:ID - 21.
                        IF  (i > 1 AND i < 402)
                            AND FALSE
                            AND (i > v_BorneMin - 20 AND i < v_BorneMax - 20)
                            AND NO THEN
                        DO:
                            pio_CelluleSW = v_Plateau[pi_Cellule:ID - 21].
                        END.
                    END.
            END CASE.
        END.
    END METHOD.
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID ToucheEnfoncee( INPUT sender AS System.Object, INPUT e AS System.Windows.Forms.PreviewKeyDownEventArgs ):
		      MESSAGE e:KeyValue VIEW-AS ALERT-BOX.
		
		RETURN.

	END METHOD.

    DESTRUCTOR PUBLIC Plateau():
        IF VALID-OBJECT(Y_panel) THEN 
        DO:
            Y_panel:Dispose().
        END.
    END DESTRUCTOR.

END CLASS.
