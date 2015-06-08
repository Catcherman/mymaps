CREATE DATABASE IF NOT EXISTS AIBANG;
USE AIBANG;

DROP TABLE IF EXISTS AibangQueryLog;

CREATE TABLE IF NOT EXISTS AibangQueryLog
(
	city			VARCHAR(128),
	keyword			VARCHAR(256),
	location		VARCHAR(256),
	frequency		INT NOT NULL
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

-- convert aibang's data into csv format  
LOAD DATA INFILE 'C:/Documents and Settings/Quanzhong/My Documents/Pachira/Customer/ThinkIT/Data/QueryLog/client_query.csv'
REPLACE INTO TABLE AibangQueryLog character set 'gb2312'
FIELDS TERMINATED BY ',' ENCLOSED BY ''
(city, @dummy, @dummy, keyword, @dummy, @dummy, location, @dummy, @dummy, frequency)
;

-- export location data to csv file
USE AIBANG;
SELECT location, sum(frequency) FROM AibangQueryLog GROUP BY location ORDER BY sum(frequency) DESC 
INTO OUTFILE 'C:/Documents and Settings/Quanzhong/My Documents/Pachira/Customer/ThinkIT/Data/QueryLog/location.csv'
CHARACTER SET 'gb2312'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
;

-- export keyword data to csv file
USE AIBANG;
SELECT keyword, sum(frequency) FROM AibangQueryLog GROUP BY keyword ORDER BY sum(frequency) DESC
INTO OUTFILE 'C:/Documents and Settings/Quanzhong/My Documents/Pachira/Customer/ThinkIT/Data/QueryLog/keyword.csv'
CHARACTER SET 'gb2312'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n'
;
