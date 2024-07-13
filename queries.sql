
set pagesize 1000
set echo on
set markup html on spool on head "<title>BI-DBS - Matěj Razák(razakmat) - Výstup SQL příkazů </title> <style type ='text/css'><!--body {background: #ffffc6} --></style>" body "<h2>BI-DBS - Čtvrtek 11:00, Sudý týden, paralelka 722248018005 - Matěj Razák - Výstup SQL příkazů</h2>"
spool queries-log.html

       	
          --KOD DOTAZU: d1
 -- Jména studentů, kteří mají zapsaný v zimním semestru roku 2015 předmět Matematicka logika.

SELECT DISTINCT Jmeno,Prijmeni
FROM Student JOIN Zapis USING(Student_Key)
            JOIN Predmet USING(Kod_Predmet)
WHERE Semestr='Zimni' AND  S_Rok=2015 AND Nazev_Predmet='Matematická logika';
 

          --KOD DOTAZU: d2
 -- Jména zaměstnanců, kteří učili alespoň jeden předmět v zimním semestru školního roku 2014.

SELECT DISTINCT Jmeno, Prijmeni
FROM Zamestnanec JOIN Zapis USING(Zamestnanec_Key)
WHERE Semestr='Zimni' AND S_Rok=2014;
 

          --KOD DOTAZU: d3
 -- Budovy ve kterých se v zimním semestru roku 2015 neučí žádný předmět.

SELECT DISTINCT Adr_Mesto, Adr_Ulice,Adr_Cislo
FROM Budova B
WHERE B.Budova_Key NOT IN (SELECT Budova_Key 
                           FROM Budova JOIN Ucebna USING(Budova_Key) NATURAL JOIN Zapis 
                           WHERE Semestr='Zimni' AND S_Rok=2015);
 

          --KOD DOTAZU: d4
 -- Studenti, kteří si zapisují sport pouze v letních semestrech.

SELECT DISTINCT *
FROM
( 
SELECT S.*
  FROM Student S 
  WHERE Student_Key IN (SELECT Student_Key FROM Zapis_Sport)
  MINUS
  SELECT S.*
  FROM Student S 
  WHERE Student_Key IN (SELECT Student_Key FROM Zapis_Sport WHERE Semestr='Zimni')
);

 

          --KOD DOTAZU: d5
 -- Jména studentů, kteří si zapsali všechny vypsané předměty v zimním semestru 2015.

WITH
T1  AS (SELECT UNIQUE Student.Student_Key,Kod_Predmet
    FROM Zapis CROSS JOIN Student
    WHERE Semestr = 'Zimni' AND S_Rok=2015 ),
T2  AS (SELECT UNIQUE Student_Key,Kod_Predmet
        FROM Student JOIN Zapis USING(Student_Key) 
        WHERE Semestr = 'Zimni' AND S_Rok=2015),
T31 AS (SELECT * FROM  T1 MINUS SELECT * FROM T2),
T32 AS (SELECT UNIQUE Student_Key FROM T31),
T4  AS (SELECT UNIQUE Student_Key FROM T1),
T5  AS (SELECT DISTINCT *
              FROM T4 
              WHERE T4.Student_Key NOT IN (SELECT Student_Key FROM T32)) 
SELECT Jmeno,Prijmeni
FROM T5 JOIN Student USING(Student_Key)
ORDER BY Jmeno;


 

          --KOD DOTAZU: d6
 -- Vypsané předměty, které si studenti z dotazu č.5 nezapsali zimním semestru 2015.

SELECT DISTINCT Kod_Predmet
FROM Predmet JOIN Zapis USING(Kod_Predmet)
WHERE Semestr='Zimni' AND S_Rok=2015
MINUS
SELECT DISTINCT Kod_Predmet
FROM Student JOIN Zapis USING(Student_Key)
WHERE Semestr='Zimni' AND S_Rok=2015 AND Student_Key=1004;

 

          --KOD DOTAZU: d7
 -- Adresy budov ve kterých se někdy postupně vyučovaly všechny předměty katedry teoretické informatiky.

WITH
T1 AS (SELECT UNIQUE B.Budova_Key,P.Kod_Predmet
FROM Budova B CROSS JOIN Predmet P
WHERE (SELECT UNIQUE Katedra_Key FROM Katedra WHERE Nazev_Katedra='katedra teoretické informatiky')= P.Katedra_Key),
T2 AS (SELECT UNIQUE Budova_Key,Kod_Predmet 
FROM Zapis JOIN Predmet USING(Kod_Predmet)
JOIN Katedra USING (Katedra_Key)
WHERE Nazev_Katedra='katedra teoretické informatiky'),
T31 AS (SELECT * FROM T1 MINUS SELECT * FROM T2),
T32 AS (SELECT UNIQUE Budova_Key FROM T31),
T4 AS (SELECT UNIQUE Budova_Key FROM T1),
T5 AS (SELECT * FROM T4 WHERE T4.Budova_Key NOT IN (SELECT Budova_Key FROM T32)) 
SELECT Adr_Mesto,Adr_Ulice,Adr_Cislo,Budova_Key
FROM T5 JOIN Budova USING(Budova_Key);


 

          --KOD DOTAZU: d8
 -- Kontrola dotazu c.7. Předměty katedry teoretické informatiky které se nevyučovaly ve výsledné budově.

SELECT DISTINCT Kod_Predmet
FROM Predmet JOIN Katedra ON(Predmet.Katedra_Key=Katedra.Katedra_Key)
WHERE Nazev_Katedra='katedra teoretické informatiky'
MINUS
SELECT DISTINCT Kod_Predmet
FROM Zapis
WHERE Budova_Key=10;

 

          --KOD DOTAZU: d9
 -- Všem učitelům, kteří v roce 2015 a 2014 vyučovalo více než 1 předmět se zvedne plat o 15%.

UPDATE Zamestnanec Z
SET Plat = Plat * 1.15
WHERE (SELECT COUNT (Zamestnanec_Key) FROM (
       SELECT DISTINCT Zamestnanec_Key,Kod_Predmet,Semestr,S_Rok,Mistnost,Budova_Key FROM Zapis WHERE (S_Rok=2014 OR S_Rok=2015) )
       WHERE Zamestnanec_Key=Z.Zamestnanec_Key) > 1;
 

          --KOD DOTAZU: d10
 -- Počet učitelů, kteří učili předmět z jiné než ze svoji katedry.

SELECT COUNT (DISTINCT Zamestnanec_Key)
FROM Zapis JOIN Zamestnanec USING(Zamestnanec_Key) JOIN Predmet USING (Kod_Predmet)
WHERE Zamestnanec.Katedra_Key != Predmet.Katedra_Key;

 

          --KOD DOTAZU: d11
 -- Jména studentů, kteří získali v roce 2015 více než 10 kreditů seřazené podle získaných kreditu.

SELECT Jmeno,Prijmeni,SUM (Kredity) AS Pocet
FROM Zapis JOIN Vysledek USING(Zapis_Key) JOIN Predmet USING(Kod_Predmet) JOIN Student USING(Student_Key)
WHERE Znamka!='F' AND Zapis.S_Rok=2015
GROUP BY Student_Key,Jmeno,Prijmeni
HAVING SUM(Kredity) > 10
ORDER BY Pocet desc;




 

          --KOD DOTAZU: d12
 -- Počet různých předmětů, který se vyučuje v budově na adrese Praha 6 , Fakultni 5 .

SELECT COUNT (DISTINCT Kod_Predmet)
FROM Zapis JOIN Budova USING(Budova_Key)
WHERE S_Rok=2015 AND Semestr='Zimni' AND Adr_Mesto='Praha 6' AND Adr_Ulice='Fakultni' AND Adr_Cislo='5';
 

          --KOD DOTAZU: d13
 -- Studenti, kteří hráli Tenis i chodili na předmět BI-ZMA.

SELECT *
FROM Student
WHERE Student.Student_Key IN (SELECT Student_Key FROM Zapis_Sport WHERE Nazev_Sport='Tenis')
INTERSECT
SELECT *
FROM Student
WHERE Student.Student_Key IN (SELECT Student_Key FROM Zapis WHERE Kod_Predmet='BI-ZMA');
 

          --KOD DOTAZU: d14
 -- Jména studentů, kteří v roce 2014 měli zapsány nějaký předmět nebo sport.

(SELECT Jmeno,Prijmeni
FROM Student JOIN  Zapis_Sport USING(Student_Key)
WHERE S_Rok=2014)
UNION
(SELECT Jmeno,Prijmeni
FROM Student JOIN  Zapis USING(Student_Key)
WHERE S_Rok=2014);
 

          --KOD DOTAZU: d15
 -- Seznam Zaměstnanců kteří nepatří do žádné katedry a katedry které nemají žádné zaměstnance.

SELECT Katedra.Nazev_Katedra,Zamestnanec.Jmeno,Zamestnanec.Prijmeni
FROM Zamestnanec FULL OUTER JOIN Katedra ON Zamestnanec.Katedra_Key = Katedra.Katedra_Key
WHERE (Zamestnanec.Jmeno IS NULL OR Nazev_Katedra IS NULL);
 

          --KOD DOTAZU: d16
 -- Jména zaměstnanců se sloupcem s počtem záverečných prací které vedou.

SELECT Jmeno, Prijmeni, Zamestnanec_Key,
            COALESCE((SELECT COUNT(*)
            FROM Zaverecna_Prace P
            WHERE P.Zamestnanec_Key = Z.Zamestnanec_Key),0) AS Pocet_Praci
FROM Zamestnanec Z;
 

          --KOD DOTAZU: d17
 -- Jmena kateder s počtem předmětu menším než 4 (včetně žádného) seřazené podle abecedy.

SELECT Nazev_Katedra
FROM Katedra LEFT OUTER JOIN Predmet USING(Katedra_Key)
GROUP BY Nazev_Katedra
HAVING COUNT(*) < 4
ORDER By Nazev_Katedra desc;

 

          --KOD DOTAZU: d18
 -- Předměty, které nebyly nikdy vypsány. (3 různé formulace)

SELECT *
FROM Predmet
WHERE Predmet.Kod_Predmet NOT IN (SELECT Kod_Predmet FROM Zapis);

SELECT *
FROM Predmet P
WHERE NOT EXISTS (SELECT Kod_Predmet
                  FROM Zapis Z
                  WHERE Z.Kod_Predmet = P.Kod_Predmet);

SELECT *
FROM Predmet
MINUS
SELECT *
FROM Predmet
WHERE Kod_Predmet IN (SELECT Kod_Predmet FROM Zapis);


 

          --KOD DOTAZU: d19
 -- Studentovi zadej známky A ve všech jeho zapsaných předmětech v zimním semestru 2015.

INSERT INTO Vysledek (Zapis_Key , Znamka , Body)
SELECT Zapis_Key , 'A' , NULL
FROM Zapis
WHERE  Student_Key=1004 AND S_Rok=2015 AND Semestr='Zimni';
 

          --KOD DOTAZU: d20
 -- Studentovi smaž známky ke všem jeho zapsaným předmětům v zimním semestru 2015.

DELETE FROM Vysledek
WHERE Zapis_Key IN (SELECT Zapis_Key FROM Zapis WHERE Student_Key=1004 AND S_Rok=2015 AND Semestr='Zimni');
 

          --KOD DOTAZU: d21
 -- Vytvoří pohled VIEW Adresa se všemi adresami(Budovy + Koleje). A vypíše adresy v Praze, ale ne v Praze 6.

CREATE VIEW Adresa AS
((SELECT 'Budova' AS TYP ,Adr_Mesto,Adr_Ulice,Adr_Cislo
FROM Budova)
UNION
(SELECT 'Kolej' AS TYP ,Adr_Mesto,Adr_Ulice,Adr_Cislo
FROM Kolej));

SELECT *
FROM Adresa
WHERE Adr_Mesto LIKE '%Praha%'
MINUS
SELECT *
FROM Adresa
WHERE Adr_Mesto='Praha 6';
 

          --KOD DOTAZU: d22
 -- Jména studentů, kteří dostali nějaké A v letním semestru roku 2015.

SELECT DISTINCT Jmeno,Prijmeni
FROM Student NATURAL JOIN Zapis NATURAL JOIN Vysledek
WHERE Znamka='A' AND Semestr='Letni' AND S_Rok=2015;
 

          --KOD DOTAZU: d23
 -- Jména učitelů, kteří jsou vedoucími nějaké závěrečné práce a učili v zimním semestru roku 2015.

SELECT Jmeno,Prijmeni
FROM Zamestnanec NATURAL JOIN Zaverecna_Prace
INTERSECT
SELECT Jmeno,Prijmeni
FROM Zamestnanec NATURAL JOIN Zapis
WHERE Semestr='Zimni' AND S_Rok=2015;
 

          --KOD DOTAZU: d24
 -- Jmena a telefonní čísla studentů, kteří bydlí na jiné koleji než kolej Koudelka, společně s nazvem koleje na které bydlí.

SELECT DISTINCT Jmeno,Prijmeni,Tel_Cislo,Nazev_Kolej
FROM Student NATURAL JOIN Kolej
WHERE Nazev_Kolej != 'Koudelka';
 

          --KOD DOTAZU: d25
 -- Seznam všech vypsaných sportů včetně počtu vypsání(celkem), seřazené sestupně podle počtu.

SELECT Nazev_Sport,COUNT(Nazev_Sport)
FROM (SELECT DISTINCT Nazev_Sport,S_Rok,Semestr FROM Zapis_Sport)
GROUP BY Nazev_Sport
ORDER BY COUNT(Nazev_Sport) desc;
 

set markup html off
spool off
