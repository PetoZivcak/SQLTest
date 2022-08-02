--1A
SELECT 'Ppocet obci ktore maju rovnake meno s inou je:' || ' ' || count(distinct obec.nazov)
FROM obec
         right join obec o ON obec.nazov = o.nazov and obec.id != O.id
where obec.id is not null;
--1A

--1B
-- SELECT obec.nazov
-- FROM obec
-- where  obec.nazov in
-- (SELECT distinct obec.nazov
-- FROM obec right join obec o ON obec.nazov=o.nazov and obec.id != O.id
-- where obec.id is not null)
--
-- group by obec.nazov
--
-- order by count(obec.nazov) desc

SELECT obec.nazov, count(obec.nazov)
FROM obec
where obec.nazov in
      (SELECT distinct obec.nazov
       FROM obec
                right join obec o ON obec.nazov = o.nazov and obec.id != O.id
       where obec.id is not null)

group by obec.nazov

order by count(obec.nazov) desc
LIMIT 1
;


--1B

--2
SELECT 'Pocet okresov v Kosickom kraji je:' as info, count(okres.id) as pocet_okresov
FROM okres
         INNER JOIN kraj k on k.id = okres.id_kraj
WHERE k.nazov = 'Kosicky kraj'
--2

--3
SELECT 'Pocet obci v Kosickom kraji je:' as info, count(obec.id) as pocet_obci
FROM obec
         INNER JOIN okres o on o.id = obec.id_okres
         INNER JOIN kraj k on k.id = o.id_kraj
WHERE K.nazov = 'Kosicky kraj'
--3

--4
SELECT 'Najvacsia obec v r 2012 bola: ' || '' || obec.nazov || ' ' || 'a mala' || ' ' || p.zeny + p.zeny || '' ||
       ' obyvatelov'
FROM obec
         INNER JOIN populacia p on obec.id = p.id_obec
WHERE p.muzi + p.zeny = (SELECT max(p.muzi + p.zeny)
                         FROM obec
                                  INNER JOIN populacia p on obec.id = p.id_obec
                         WHERE p.rok = 2012)

--4

--5
SELECT 'Okres Sabinov mal v r 2012' || ' ' || sum(populacia.muzi + populacia.zeny) || ' ' || 'obyvatelov'
FROM populacia
         INNER JOIN obec o on o.id = populacia.id_obec
         INNER JOIN okres o2 on o.id_okres = o2.id
WHERE o2.nazov = 'Sabinov'
  and populacia.rok = '2012'
--5

--6
--Pocty obyvatelov
SELECT POPULACIA.rok, SUM(muzi + zeny)
FROM populacia
GROUP BY populacia.rok
ORDER BY rok DESC;

--trend vývoja
SELECT populacia.rok || '-' || populacia.rok - 1                  as porovnanie,
       sum((populacia.zeny - p.zeny) + (populacia.muzi - p.muzi)) as prirastor_resp_ubytok_obyvatelstva
FROM populacia
         inner join populacia p on p.id_obec = populacia.id_obec
where populacia.rok = p.rok + 1
group by populacia.rok
order by populacia.rok desc;
--6

--7
SELECT 'Obec' || ' ' || o.nazov || ' ' || 'z Okresu Tvrdosin s populaciou ' || ' ' || populacia.muzi + populacia.zeny ||
       ' osob bola najmensia v danom okrese'
FROM populacia
         INNER JOIN obec o on o.id = populacia.id_obec
         INNER JOIN okres o2 on o2.id = o.id_okres
WHERE o2.nazov = 'Tvrdosin'
  and populacia.rok = '2010'
  and muzi + populacia.zeny =
      (SELECT min(muzi + populacia.zeny)
       FROM populacia
                INNER JOIN obec o on o.id = populacia.id_obec
                INNER JOIN okres o2 on o2.id = o.id_okres
       WHERE o2.nazov = 'Tvrdosin'
         and populacia.rok = '2010')
--7

--8
SELECT obec.nazov as nazvy_obci_s_populaciou_pod_5000
FROM obec
         INNER JOIN populacia p on obec.id = p.id_obec
WHERE P.muzi + P.zeny <= 5000
  AND P.rok = 2010
--8

--9
SELECT obec.nazov as nazov_obce, round(CAST(p.zeny AS DECIMAL) / CAST(P.muzi AS DECIMAL), 4) as pomer_zeny_muzi
FROM obec
         INNER JOIN populacia p on obec.id = p.id_obec
WHERE p.zeny + p.muzi > 20000
  and p.rok = 2012
order by CAST(p.zeny AS DECIMAL) / CAST(P.muzi AS DECIMAL) DESC
LIMIT 10
--9

--10

SELECT k.nazov,
       sum(p.muzi + p.zeny)    as kraj,
       count(distinct obec.id) as pocet_obci,
       count(distinct o.id)    as pocet_okresov
FROM obec
         INNER JOIN okres o on o.id = obec.id_okres
         INNER JOIN kraj k on k.id = o.id_kraj
         INNER JOIN populacia p on obec.id = p.id_obec
WHERE P.rok = 2012
group by k.id

--creatin view
CREATE OR REPLACE VIEW STATS AS
(
SELECT k.nazov,
       sum(p.muzi + p.zeny)    as kraj,
       count(distinct obec.id) as pocet_obci,
       count(distinct o.id)    as pocet_okresov
FROM obec
         INNER JOIN okres o on o.id = obec.id_okres
         INNER JOIN kraj k on k.id = o.id_kraj
         INNER JOIN populacia p on obec.id = p.id_obec
WHERE P.rok = 2012
group by k.id)

--10

--11

SELECT o.nazov,
       sum(populacia.zeny + populacia.muzi)                       as populacia_last_YEAR,
       sum(p.zeny + p.muzi)                                       as populacia_YEAR_before,
       sum((populacia.zeny - p.zeny) + (populacia.muzi - p.muzi)) as prirastor_resp_ubytok_obyvatelstva
FROM populacia
         inner join populacia p on p.id_obec = populacia.id_obec
         inner join obec o on o.id = populacia.id_obec
where populacia.rok = p.rok + 1 and ((populacia.zeny - p.zeny) + (populacia.muzi - p.muzi)) <= 0 and
      populacia.rok = (select populacia.rok
                       from populacia
                       order by populacia.rok desc
                       limit 1)
   or populacia.rok = (select populacia.rok + 1
                       from populacia
                       order by populacia.rok desc
                       limit 1)
group by populacia.rok, o.id
order by sum((populacia.zeny - p.zeny) + (populacia.muzi - p.muzi)) asc
--11

--12
SELECT 'Pocet obci, ktorych pocet obyvatelov v roku 2012 je nizsi, ako bol slovensky priemer v danom roku je: ' || '' ||
       count(populacia.id_obec)
FROM populacia
WHERE populacia.rok = 2012
  and populacia.muzi + populacia.zeny < (SELECT avg(populacia.muzi + populacia.zeny)
                                         FROM populacia
                                         WHERE populacia.rok = 2012)
--12

--13
CREATE TABLE myNewTable
(
    id   int generated always as identity,
    name VARCHAR(30) NOT NULL,
    age  INT         NOT NULL CHECK ( age > 0 )
);
--13





