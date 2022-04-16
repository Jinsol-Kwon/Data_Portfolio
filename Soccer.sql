SELECT * FROM worldcups;

SELECT * FROM worldcupmatches; 

SELECT * FROM worldcupplayers;

UPDATE worldcups SET Attendance = REPLACE(Attendance, '.', '');
SELECT Year, Attendance FROM worldcups;

CREATE TABLE worldcupmatches_ SELECT DISTINCT Year, Datetime, Stage, Stadium, City,
Home_Team_Name, Home_Team_Goals, Away_Team_Goals, Away_Team_Name, Attendance, RoundID, MatchID
FROM worldcupmatches;

CREATE TABLE worldcupplayers_ SELECT DISTINCT RoundID, MatchID, Team_Initials,
Line_up, Shirt_Number, Player_Name, Position, Event FROM worldcupplayers;

SELECT Year, SUBSTRING(Datetime, 1, 11), Home_Team_Name, Away_Team_Name, Home_Team_Goals,
Away_Team_Goals, abs(Home_Team_Goals - Away_Team_Goals) AS Goals_Difference
FROM worldcupmatches_
ORDER BY Goals_Difference DESC;

SELECT Year, SUBSTRING(Datetime, 1, 11), Home_Team_Name, Away_Team_Name, Home_Team_Goals,
Away_Team_Goals, (Home_Team_Goals + Away_Team_Goals) AS Total_Goals
FROM worldcupmatches_
ORDER BY Total_Goals DESC;

SELECT Player_Name, MAX((CHAR_LENGTH(REPLACE(Event,'G','GL')) - CHAR_LENGTH(Event))
+ (CHAR_LENGTH(REPLACE(Event,'P','PG')) - CHAR_LENGTH(Event))
- (CHAR_LENGTH(Event) - CHAR_LENGTH(REPLACE(Event,'MP','M')))) AS Goals, 
Year, Datetime, Home_Team_Name, Away_Team_Name
FROM worldcupplayers_
LEFT JOIN worldcupmatches_
ON worldcupplayers_.MatchID = worldcupmatches_.MatchID
GROUP BY Player_Name, Year, Datetime, Home_Team_Name, Away_Team_Name
ORDER BY Goals DESC;

SELECT worldcupplayers_.MatchID, Year, Datetime, Home_Team_Name,
Away_Team_Name,
SUM(CHAR_LENGTH(REPLACE(Event,'R','RC')) - CHAR_LENGTH(Event)) AS Red_Cards
FROM worldcupplayers_
LEFT JOIN worldcupmatches_
ON worldcupplayers_.MatchID = worldcupmatches_.MatchID
GROUP BY worldcupplayers_.MatchID, Year, Datetime, Home_Team_Name, Away_Team_Name
ORDER BY Red_Cards DESC;

SELECT worldcupplayers_.MatchID, Year, Datetime, Home_Team_Name,
Away_Team_Name,
SUM((CHAR_LENGTH(REPLACE(Event, 'Y', 'YC')) - CHAR_LENGTH(Event))
- (CHAR_LENGTH(REPLACE(Event, 'RSY', 'RFSY')) - CHAR_LENGTH(Event))) AS Yellow_Cards
FROM worldcupplayers_
LEFT JOIN worldcupmatches_
ON worldcupplayers_.MatchID = worldcupmatches_.MatchID
GROUP BY worldcupplayers_.MatchID, Year, Datetime, Home_Team_Name, Away_Team_Name
ORDER BY Yellow_Cards DESC;

SELECT Year, SUBSTRING(Datetime, 1, 11), Home_Team_Name, Away_Team_Name, Attendance
FROM worldcupmatches
ORDER BY Attendance DESC
LIMIT 5;

SELECT COUNT(DISTINCT(Teams)) FROM (SELECT Home_Team_Name AS Teams FROM worldcupmatches
UNION SELECT Away_Team_Name FROM worldcupmatches) AS Teams_List;

SELECT DISTINCT(Teams) FROM (SELECT Home_Team_Name AS Teams FROM worldcupmatches
UNION SELECT Away_Team_Name FROM worldcupmatches) AS Teams_List;

CREATE TEMPORARY TABLE Teams_
(SELECT Winner AS Team FROM worldcups
UNION
SELECT Runners_Up FROM worldcups
UNION
SELECT Third FROM worldcups
UNION
SELECT Fourth FROM worldcups);

ALTER TABLE Teams_
ADD COLUMN Number INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE Teams_
ADD COLUMN Top_4 INT NOT NULL;

CREATE TEMPORARY TABLE Teams_2 SELECT Team, Number FROM Teams_;

DELIMITER // 
CREATE PROCEDURE Top_4_Number()
BEGIN
DECLARE a INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE Country VARCHAR(100);
DECLARE Top_4_Times INT DEFAULT 0;
SELECT COUNT(*) FROM Teams_2 INTO b;
SET a = 1;
SET b = b + 1;
SET Top_4_Times = 0;
WHILE a < b DO
SELECT Team FROM Teams_2 WHERE Number = a INTO Country;
SELECT COUNT(*) FROM worldcups WHERE (Winner = Country) OR (Runners_Up = Country)
OR (Third = Country) OR (Fourth = Country) INTO Top_4_Times;
UPDATE Teams_ SET Top_4 = Top_4_Times WHERE Number = a; 
SET a = a + 1;
END WHILE;
END;
//

CALL Top_4_Number();

SELECT Team, Top_4 FROM Teams_
ORDER BY Top_4 DESC;

CREATE TEMPORARY TABLE World_Cups_Teams
(SELECT Home_Team_Name AS Team FROM worldcupmatches_
UNION
SELECT Away_Team_Name FROM worldcupmatches_);

ALTER TABLE World_Cups_Teams
ADD COLUMN Number INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE World_Cups_Teams
ADD COLUMN Appearance INT NOT NULL;

DELIMITER // 
CREATE PROCEDURE Number_Appearance()
BEGIN
DECLARE a INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE Country VARCHAR(100);
DECLARE Number_Appearance INT DEFAULT 0;
SELECT COUNT(*) FROM World_Cups_Teams INTO b;
SET Number_Appearance = 0;
SET a = 1;
SET b = b + 1;
WHILE a < b DO
SELECT Team FROM World_Cups_Teams WHERE Number = a INTO Country;
SELECT COUNT(DISTINCT(Year)) FROM worldcupmatches_
WHERE Home_Team_Name = Country OR Away_Team_Name = Country INTO Number_Appearance;
UPDATE World_Cups_Teams SET Appearance = Number_Appearance WHERE Number = a;
SET a = a + 1;
END WHILE;
END;
//

CALL Number_Appearance();

SELECT Team, Appearance FROM World_Cups_Teams
ORDER BY Appearance DESC;
