CREATE OR REPLACE TYPE ObAdresseTy AS OBJECT (
numRue      INT,
nomRue	    VARCHAR2 (10),
ville       VARCHAR2 (10),
departement VARCHAR2 (10),
Pays        VARCHAR2 (10), 
MAP MEMBER FUNCTION TriDepVille RETURN VARCHAR2  --fonction de tri par département puis par ville
);

 

CREATE OR REPLACE  TYPE BODY ObAdresseTy IS --détails de la fonction de tri
MAP MEMBER FUNCTION TriDepVille RETURN VARCHAR2 IS
  BEGIN
      RETURN departement||ville;  -- on commence par le département PUIS la ville car un département contient plusieurs villes
  END TriDepVille;
END;

CREATE OR REPLACE TYPE ObEntrepriseTy AS OBJECT (
num       INT,		-- numéro identificateur de l'entreprise, PK
nom       VARCHAR2 (50),
adresse   ObAdresseTy,
contacte  INT   );

CREATE OR REPLACE  TYPE ObStageTy  AS OBJECT(    
num          INT,
nom          VARCHAR2 (20),
dateSage     date,
entreprise   REF ObEntrepriseTy );

CREATE OR REPLACE TYPE obEtudiantTy AS OBJECT(
num       INT,  	   -- numéro identificateur de l'étudiant, PK
nom       VARCHAR2 (20),    
prenom    VARCHAR2 (20),   
email     VARCHAR2 (20),   
debutScol NUMBER(4),	   --  Année du début de la 2ème année (Pour nous = 2015) 
finScol   NUMBER(4),       --  Année de fin de la 2ème année (Pour nous = 2016)
stage    REF ObStageTy	   --  Un étudiant possède un stage, donc on met un object stage dan sétudiant - NULL si un étduaint n'a pas trouvé de stage
);

CREATE OR REPLACE TYPE ObStatistiqueTy AS OBJECT (
stagiaire              INT,	     -- nb étudiants avec stage cette année, remplie avec un triger
nonStagiaire           INT,   	     -- nb étudiants sans stage cette anée, remplie avec un triger
nonStagiareAnneeN      INT,          -- nb étudiants sans stage à une année N (donnée) utltérieure
stagiaireParEntreprise INT,          -- nb  stagiaires pris par chaque entreprise durant les n dernières années
moyStagiaire           FLOAT, 	     -- nb moyen de stagiaires encadrés par les entreprises dans les n dernières années
stageParZone           INT,          -- nb stages par zone géographique choisi par l'utilisateur (département, ville)
stageTot               INT, 	     -- nb stages pour toutes les zones géographiques (département, ville)


MEMBER FUNCTION NbStagiaire  return INT,	 -- retourne la valeur du Premier attribut : "NbS"
MEMBER FUNCTION NbnonStagiaire  return INT,	 -- retourne la valeur du second attribut : "nonNbS"
MEMBER FUNCTION nonStagiaireParA  return INT,	 -- retourne la valeur du troisième attribut : "nonStagiareAnneeN"
MEMBER FUNCTION stagiaireParEntr  return INT, 	 -- retourne la valeur du quatrième attribut : "stagiaireParEntreprise"
MEMBER FUNCTION moyStagiaireA     return FLOAT,  -- retourne la valeur du cinquième attribut : "moyStagiaire"
MEMBER FUNCTION stageParZoneA     return INT,	 -- retourne la valeur du sixème attribut : "stageParZone"
MEMBER FUNCTION StagTotal         return INT 	 -- retourne la valeur du spetième attribut : "stageTot" 
);

-- création des tables : on ne créer pas la table ADRESSE car elle n'est d'aucune utilité vu qu'on a déjà l'objet adresse
CREATE TABLE ENTREPRISE of ObEntrepriseTy (num  PRIMARY KEY);
CREATE TABLE STAGE of ObStageTy (num  PRIMARY KEY);
CREATE TABLE ETUDIANT of ObEtudiantTy (num  PRIMARY KEY,
CHECK (debutScol < finScol ) );
CREATE TABLE STATISTIQUE of ObStatistiqueTy;

CREATE OR REPLACE TYPE BODY ObStatistiqueTy IS
MEMBER FUNCTION NbStagiaire  return INT IS
NbS INT;
BEGIN 
SELECT COUNT(*) INTO NbS
FROM ETUDIANT e, STAGE s
WHERE e.stage.num=s.num
AND finScol='2016';
RETURN NbS;
END NbStagiaire;
END;

CREATE TRIGGER TrigNbS 
AFTER INSERT ON ETUDIANT, STAGE
EXECUTE FUNCTION NbStagiaire();

