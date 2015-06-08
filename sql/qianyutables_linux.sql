CREATE DATABASE IF NOT EXISTS qianyu;
USE qianyu;

DROP TABLE IF EXISTS QianYuSrv;
DROP TABLE IF EXISTS Keywords;
DROP TABLE IF EXISTS TranscriptionWordChoice;
DROP TABLE IF EXISTS Transcription;
DROP TABLE IF EXISTS DebugLog;
DROP TABLE IF EXISTS ClientDevice;
DROP TABLE IF EXISTS VoiceProfile;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS AppInputContextMap;
DROP TABLE IF EXISTS AppInputContext;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS nlpsentences;
DROP TABLE IF EXISTS OptimizingData;
DROP TABLE IF EXISTS AudioProperty;
DROP TABLE IF EXISTS TranscriptionData;


#------------------------------------------------------------------------------
# System
# store system information
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS QianYuSrv
(
    id 				INT(10) NOT NULL AUTO_INCREMENT,	-- id
    name			VARCHAR(32),						-- name
    version			VARCHAR(32),						-- version
    PRIMARY KEY (id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


#------------------------------------------------------------------------------
# User
# store user information
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS User
(
    user_id 		INT(10) NOT NULL AUTO_INCREMENT,	-- user id
    name			VARCHAR(32),						-- user name
    age				SMALLINT,							-- user age
    gender			SMALLINT,							-- user sex
    info			VARCHAR(128), 						-- other related information 
    PRIMARY KEY (user_id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# ClientDevice
# a client mobile device
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ClientDevice
(
	device_id		INT(10) NOT NULL AUTO_INCREMENT, 	-- client device id, primary key, auto increment
    user_id			INT(10) NOT NULL, 					-- who is using the device, foreign key to User table
    phone_number	VARCHAR(20),						-- client phone number
    imei			VARCHAR(100),						-- IMEI number
    PRIMARY KEY (device_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
-- Add accuray field
CREATE INDEX ClientDevice_imei ON ClientDevice(imei);


#------------------------------------------------------------------------------
# VoiceProfile
# The voice model and related data that needed during transcribing
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VoiceProfile
(
	user_id 		INT(10) NOT NULL,					-- foreign key to User table
	model 			BLOB,								-- voice model binary data object 
	PRIMARY KEY (user_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# Company
# The customer company who has voice applications
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Company
(
	company_id		INT NOT NULL AUTO_INCREMENT,		-- COMPANY ID primary key
	name			VARCHAR(32) UNIQUE,						-- Company name
	address			VARCHAR(128),						-- Company address
	PRIMARY KEY (company_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE INDEX COMAPNY_NAME_IDX ON Company(name);
INSERT INTO `Company` VALUES ('1', '爱帮', '北京市朝阳区北苑路32号安全大厦20层');
INSERT INTO `Company` VALUES ('2', 'Pachira', '北京市海淀区知春路希格玛公寓');
INSERT INTO `Company` VALUES ('3', '酷我科技', '北京市海淀区中关村东路18号财智国际大厦A座1906室');
INSERT INTO `Company` VALUES ('4', '四维', '北京市朝阳区曙光西里5号北京凤凰置地广场A座写字楼10-17层');
INSERT INTO `Company` VALUES ('5', '捷通华声', '北京市海淀区中关村科技园');
INSERT INTO `Company` VALUES ('6', '多米', '北京朝阳区建国路71号惠通时代广场A2座102');
INSERT INTO `Company` VALUES ('7', '金山', '北京市海淀区小营西路38号');
INSERT INTO `Company` VALUES ('8', '联想', '北京市海淀区创业路');
#------------------------------------------------------------------------------
# Application
# The applications that we support voice transcribing
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Application
(
	app_id			INT NOT NULL AUTO_INCREMENT,		-- Application ID primary key
	company_id		INT NOT NULL,						-- Company ID that this app belongs to
	name			VARCHAR(128),						-- Application name
	description		VARCHAR(256),						-- Description of the application
	PRIMARY KEY (app_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE INDEX APPLICATION_COMNAME_IDX ON Application(company_id, name);
INSERT INTO `Application` VALUES ('1', '1', '爱帮爱逛', '爱帮爱逛');
INSERT INTO `Application` VALUES ('2', '2', 'pachira', '监控以及测试用');
INSERT INTO `Application` VALUES ('3', '3', '酷我', '酷我');
INSERT INTO `Application` VALUES ('4', '4', '四维', '四维');
INSERT INTO `Application` VALUES ('5', '5', '捷通华声', null);
INSERT INTO `Application` VALUES ('6', '6', '多米', '多米');
INSERT INTO `Application` VALUES ('7', '7', '金山', '金山');
INSERT INTO `Application` VALUES ('8', '8', '联想', '联想');
#------------------------------------------------------------------------------
# AppInputContext
# The input box context, e.g., different locations in an application
# Each input box context has its own keywords
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AppInputContext
(
	context_id		INT NOT NULL AUTO_INCREMENT,		-- Input box context ID
	app_id			INT NOT NULL,						-- Application ID
	description		VARCHAR(256),						-- Context description
	keywords		TEXT,								-- Keywords of this context
	PRIMARY KEY (context_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

-- app_id and description are unique
INSERT INTO `AppInputContext` VALUES ('-1', '3', 'kuwo1', null);
INSERT INTO `AppInputContext` VALUES ('-2', '3', 'kuwo2', null);
INSERT INTO `AppInputContext` VALUES ('1', '1', 'aibang', null);
INSERT INTO `AppInputContext` VALUES ('2', '1', '北京,business', NULL);
INSERT INTO `AppInputContext` VALUES ('3', '1', '成都,location', NULL);
INSERT INTO `AppInputContext` VALUES ('4', '1', '成都,business', NULL);
INSERT INTO `AppInputContext` VALUES ('5', '1', '广州,location', NULL);
INSERT INTO `AppInputContext` VALUES ('6', '1', '广州,business', NULL);
INSERT INTO `AppInputContext` VALUES ('7', '1', '杭州,location', NULL);
INSERT INTO `AppInputContext` VALUES ('8', '1', '杭州,business', NULL);
INSERT INTO `AppInputContext` VALUES ('9', '1', '南京,location', NULL);
INSERT INTO `AppInputContext` VALUES ('10', '1', '南京,business', NULL);
INSERT INTO `AppInputContext` VALUES ('11', '1', '上海,location', NULL);
INSERT INTO `AppInputContext` VALUES ('12', '1', '上海,business', NULL);
INSERT INTO `AppInputContext` VALUES ('13', '1', '深圳,location', NULL);
INSERT INTO `AppInputContext` VALUES ('14', '1', '深圳,business', NULL);
INSERT INTO `AppInputContext` VALUES ('15', '1', '武汉,location', NULL);
INSERT INTO `AppInputContext` VALUES ('16', '1', '武汉,business', NULL);
INSERT INTO `AppInputContext` VALUES ('17', '1', '西安,location', NULL);
INSERT INTO `AppInputContext` VALUES ('18', '1', '西安,business', NULL);
INSERT INTO `AppInputContext` VALUES ('19', '1', '郑州,location', NULL);
INSERT INTO `AppInputContext` VALUES ('20', '1', '郑州,business', NULL);
INSERT INTO `AppInputContext` VALUES ('21', '1', '北京,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('22', '1', '北京,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('23', '1', '成都,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('24', '1', '成都,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('25', '1', '广州,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('26', '1', '广州,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('27', '1', '杭州,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('28', '1', '杭州,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('29', '1', '南京,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('30', '1', '南京,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('31', '1', '上海,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('32', '1', '上海,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('33', '1', '深圳,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('34', '1', '深圳,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('35', '1', '武汉,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('36', '1', '武汉,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('37', '1', '西安,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('38', '1', '西安,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('39', '1', '郑州,transportation', NULL);
INSERT INTO `AppInputContext` VALUES ('40', '1', '郑州,train_station', NULL);
INSERT INTO `AppInputContext` VALUES ('41', '3', 'music,mixed', null);
INSERT INTO `AppInputContext` VALUES ('42', '2', 'pachira', null);
INSERT INTO `AppInputContext` VALUES ('43', '4', 'siwei', null);
INSERT INTO `AppInputContext` VALUES ('44', '5', 'sinovoice', null);
INSERT INTO `AppInputContext` VALUES ('45', '6', 'duomi', null);
INSERT INTO `AppInputContext` VALUES ('46', '7', 'kingsoft1', null);
INSERT INTO `AppInputContext` VALUES ('47', '7', 'kingsoft2', null);
INSERT INTO `AppInputContext` VALUES ('48', '7', 'kingsoft3', null);
INSERT INTO `AppInputContext` VALUES ('49', '8', 'lenovo1', null);
INSERT INTO `AppInputContext` VALUES ('50', '8', 'lenovo2', null);
INSERT INTO `AppInputContext` VALUES ('51', '8', 'lenovo3', null);
INSERT INTO `AppInputContext` VALUES ('52', '8', 'lenovo4', null);
INSERT INTO `AppInputContext` VALUES ('53', '8', 'lenovo5', null);

INSERT INTO `AppInputContext` VALUES ('60', '2', 'test1', null);
INSERT INTO `AppInputContext` VALUES ('61', '2', 'test2', null);
INSERT INTO `AppInputContext` VALUES ('62', '2', 'test3', null);
INSERT INTO `AppInputContext` VALUES ('63', '2', 'demo1', null);
INSERT INTO `AppInputContext` VALUES ('64', '2', 'demo2', null);
INSERT INTO `AppInputContext` VALUES ('65', '2', 'demo3', null);
INSERT INTO `AppInputContext` VALUES ('66', '2', 'pachira1', null);
INSERT INTO `AppInputContext` VALUES ('67', '2', 'pachira2', null);
INSERT INTO `AppInputContext` VALUES ('68', '2', 'pachira3', null);






#------------------------------------------------------------------------------
# AppInputContextMap
# Map application reminder string /comments string to context id
# One context id can be mapped to multiple reminders
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AppInputContextMap
(
	context_id		INT NOT NULL,						-- Input box context ID
	app_id			INT NOT NULL,						-- Application ID
	reminder		VARCHAR(200),						-- Context reminder
	word_freq_id    INT NOT NULL,						-- which context id we should map to, while seaching the keywords table for word freqency    
	PRIMARY KEY (context_id,word_freq_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
INSERT INTO `AppInputContextMap` VALUES (-1, 3, 'kuwo1', 3);
INSERT INTO `AppInputContextMap` VALUES ( 1, 1, '', 1);
INSERT INTO `AppInputContextMap` VALUES ( 1, 1, 'aibang', 2);
INSERT INTO `AppInputContextMap` VALUES (2, 1, '北京,business', 2);
INSERT INTO `AppInputContextMap` VALUES (3, 1, '成都,location', 4);
INSERT INTO `AppInputContextMap` VALUES (4, 1, '成都,business', 4);
INSERT INTO `AppInputContextMap` VALUES (5, 1, '广州,location', 6);
INSERT INTO `AppInputContextMap` VALUES (6, 1, '广州,business', 6);
INSERT INTO `AppInputContextMap` VALUES (7, 1, '杭州,location', 8);
INSERT INTO `AppInputContextMap` VALUES (8, 1, '杭州,business', 8);
INSERT INTO `AppInputContextMap` VALUES (9, 1, '南京,location', 10);
INSERT INTO `AppInputContextMap` VALUES (10, 1, '南京,business', 10);
INSERT INTO `AppInputContextMap` VALUES (11, 1, '上海,location', 12);
INSERT INTO `AppInputContextMap` VALUES (12, 1, '上海,business', 12);
INSERT INTO `AppInputContextMap` VALUES (13, 1, '深圳,location', 14);
INSERT INTO `AppInputContextMap` VALUES (14, 1, '深圳,business', 14);
INSERT INTO `AppInputContextMap` VALUES (15, 1, '武汉,location', 16);
INSERT INTO `AppInputContextMap` VALUES (16, 1, '武汉,business', 16);
INSERT INTO `AppInputContextMap` VALUES (17, 1, '西安,location', 18);
INSERT INTO `AppInputContextMap` VALUES (18, 1, '西安,business', 18);
INSERT INTO `AppInputContextMap` VALUES (19, 1, '郑州,location', 20);
INSERT INTO `AppInputContextMap` VALUES (20, 1, '郑州,business', 20);
INSERT INTO `AppInputContextMap` VALUES (21, 1, '北京,transportation', 2);
INSERT INTO `AppInputContextMap` VALUES (22, 1, '北京,train_station', 2);
INSERT INTO `AppInputContextMap` VALUES (23, 1, '成都,transportation', 4);
INSERT INTO `AppInputContextMap` VALUES (24, 1, '成都,train_station', 4);
INSERT INTO `AppInputContextMap` VALUES (25, 1, '广州,transportation', 6);
INSERT INTO `AppInputContextMap` VALUES (26, 1, '广州,train_station', 6);
INSERT INTO `AppInputContextMap` VALUES (27, 1, '杭州,transportation', 8);
INSERT INTO `AppInputContextMap` VALUES (28, 1, '杭州,train_station', 8);
INSERT INTO `AppInputContextMap` VALUES (29, 1, '南京,transportation', 10);
INSERT INTO `AppInputContextMap` VALUES (30, 1, '南京,train_station', 10);
INSERT INTO `AppInputContextMap` VALUES (31, 1, '上海,transportation', 12);
INSERT INTO `AppInputContextMap` VALUES (32, 1, '上海,train_station', 12);
INSERT INTO `AppInputContextMap` VALUES (33, 1, '深圳,transportation', 14);
INSERT INTO `AppInputContextMap` VALUES (34, 1, '深圳,train_station', 14);
INSERT INTO `AppInputContextMap` VALUES (35, 1, '武汉,transportation', 16);
INSERT INTO `AppInputContextMap` VALUES (36, 1, '武汉,train_station', 16);
INSERT INTO `AppInputContextMap` VALUES (37, 1, '西安,transportation', 18);
INSERT INTO `AppInputContextMap` VALUES (38, 1, '西安,train_station', 18);
INSERT INTO `AppInputContextMap` VALUES (39, 1, '郑州,transportation', 20);
INSERT INTO `AppInputContextMap` VALUES (40, 1, '郑州,train_station', 20);
INSERT INTO `AppInputContextMap` VALUES ( 41, 3, 'music,mixed', 41);
INSERT INTO `AppInputContextMap` VALUES ( 42, 2, 'pachira', 42);
INSERT INTO `AppInputContextMap` VALUES ( 43, 4, 'siwei', 43);
INSERT INTO `AppInputContextMap` VALUES ( 44, 5, 'sinovoice', 44);
INSERT INTO `AppInputContextMap` VALUES ( 45, 6, 'duomi', 45);
INSERT INTO `AppInputContextMap` VALUES ( 46, 7, 'kingsoft1', 46);
INSERT INTO `AppInputContextMap` VALUES ( 47, 7, 'kingsoft2', 47);
INSERT INTO `AppInputContextMap` VALUES ( 48, 7, 'kingsoft3', 48);
INSERT INTO `AppInputContextMap` VALUES ( 49, 8, 'lenovo1', 49);
INSERT INTO `AppInputContextMap` VALUES ( 50, 8, 'lenovo2', 50);
INSERT INTO `AppInputContextMap` VALUES ( 51, 8, 'lenovo3', 51);
INSERT INTO `AppInputContextMap` VALUES ( 52, 8, 'lenovo4', 52);
INSERT INTO `AppInputContextMap` VALUES ( 53, 8, 'lenovo5', 53);

INSERT INTO `AppInputContextMap` VALUES (60, 2, 'test1', 60);
INSERT INTO `AppInputContextMap` VALUES (61, 2, 'test2', 61);
INSERT INTO `AppInputContextMap` VALUES (62, 2, 'test3', 62);
INSERT INTO `AppInputContextMap` VALUES (63, 2, 'demo1', 63);
INSERT INTO `AppInputContextMap` VALUES (64, 2, 'demo2', 64);
INSERT INTO `AppInputContextMap` VALUES (65, 2, 'demo3', 65);
INSERT INTO `AppInputContextMap` VALUES (66, 2, 'pachira1', 66);
INSERT INTO `AppInputContextMap` VALUES (67, 2, 'pachira2', 67);
INSERT INTO `AppInputContextMap` VALUES (68, 2, 'pachira3', 68);

CREATE TABLE IF NOT EXISTS Transcription(
		id		INT(10) NOT NULL AUTO_INCREMENT,					-- the orignial transcription
		createTime			TIMESTAMP NOT NULL DEFAULT current_timestamp,	-- transcription time
		kid		VARCHAR(10),							--  context table
		cid		VARCHAR(10),							--  comppany id
		aid		VARCHAR(10),							--  app id
		requestid		VARCHAR(100) NOT NULL DEFAULT '0',							
		word_org		mediumtext,						-- the original word, NULL if choice is 0
		word_old		mediumtext,						-- the nlp word, 
		word_old_pinyin		mediumtext,						-- the nlp word pinyin
		usedTime		VARCHAR(20) DEFAULT '0',					-- used time of this recognize
		phone			VARCHAR(1024),						-- telephone number
		addr			VARCHAR(100),						
		device_id		VARCHAR(100),
		engine_id		VARCHAR(5) DEFAULT '-1',
		hostIp  VARCHAR(50) NOT NULL DEFAULT '127.0.0.1',
		uuid  VARCHAR(64),
		gender  VARCHAR(50) default '1',
		timeBoundary	mediumtext,
		batch		VARCHAR(64),
		scene		VARCHAR(10),
		error_code	VARCHAR(10),
		voice_type  VARCHAR(5),
		voice_path  VARCHAR(500),						-- 
		voice_length  VARCHAR(20) NOT NULL DEFAULT '0',
		voice_time  VARCHAR(20) NOT NULL DEFAULT '0',
		client_filename  VARCHAR(500),
		is_client_get			INT DEFAULT 0,	
		asr_error_code	VARCHAR(10),
		asr_log_id	VARCHAR(50),
		word_all_length	VARCHAR(50),
		PRIMARY KEY (id)
	) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
	
CREATE INDEX Transcription_uuid_idx ON Transcription(uuid);
CREATE INDEX Transcription_is_client_get_idx ON Transcription(is_client_get);
CREATE INDEX Transcription_createTime_idx ON Transcription(createTime);
CREATE INDEX Transcription_uuid_batch_idx ON Transcription(uuid,batch);


	CREATE TABLE IF NOT EXISTS TranscriptionWordChoice(
		id		INT(10) NOT NULL AUTO_INCREMENT,					-- the orignial transcription
		createTime			TIMESTAMP NOT NULL DEFAULT current_timestamp,	-- transcription time
		word_choice	VARCHAR(10),
		weight		VARCHAR(5),
		word		VARCHAR(256),
		word_old	VARCHAR(2048),
		hostIp  VARCHAR(50) NOT NULL DEFAULT '127.0.0.1',
		uuid  VARCHAR(64),
		trans_id	INT(10),
		PRIMARY KEY (id)
	) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


#------------------------------------------------------------------------------
# Keywords
# Keeps the keywords and their frequency/importance
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Keywords
(
	context_id		INT NOT NULL,						-- the context this keyword is used 
	word			VARCHAR(256),						-- the keyword
	frequency		INT NOT NULL						-- the frequency of the word
	-- , PRIMARY KEY (context_id, word) -- too long for primary key
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;




#------------------------------------------------------------------------------
# Debug log
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DebugLog
(
	log_id		INT(10) NOT NULL AUTO_INCREMENT,	-- primary key, auto increment
	device_id		INT(10) NOT NULL,					-- foreign key to Device table
	client_addr		VARCHAR(256),						-- client IP/Host name
	log		BLOB,								-- debug log
	time			TIMESTAMP NOT NULL DEFAULT current_timestamp,	-- transcription time
	PRIMARY KEY (log_id)
-- 	CONSTRAINT  FK_device_id FOREIGN KEY (device_id) REFERENCES ClientDevice(device_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;




#------------------------------------------------------------------------------
# nlpsentences
# store Nlp information
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS nlpsentences (
  sentences_id INT(10) NOT NULL AUTO_INCREMENT,
  sentences VARCHAR(256) ,
  start_time VARCHAR(96) ,
  end_time VARCHAR(96) ,
  source VARCHAR(256) ,
  detination VARCHAR(256) ,
  actions VARCHAR(256) ,
  remind VARCHAR(30) ,
  percentage VARCHAR(30) ,
  system_time VARCHAR(30),
 PRIMARY KEY (sentences_id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


CREATE TABLE IF NOT EXISTS OptimizingData (
  id INT(10) NOT NULL AUTO_INCREMENT,
  createTime			TIMESTAMP NOT NULL DEFAULT current_timestamp,
  word VARCHAR(1024) ,
  updateTime			TIMESTAMP ,
  is_update int(2) DEFAULT '0' NOT NULL,
  is_normal int(2) DEFAULT '0' NOT NULL,
  kid VARCHAR(10)  DEFAULT '0' NOT NULL,
  uuid  VARCHAR(50),		
  transid  VARCHAR(50),
 PRIMARY KEY (id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


CREATE TABLE IF NOT EXISTS AudioProperty (
  id INT(10) NOT NULL AUTO_INCREMENT,
  createTime			TIMESTAMP NOT NULL DEFAULT current_timestamp,
  rate VARCHAR(10) DEFAULT '8' NOT NULL,
  sample VARCHAR(10) DEFAULT '16' NOT NULL,
  format VARCHAR(10) DEFAULT 'pcm' NOT NULL,
  voiceType VARCHAR(10)  DEFAULT '0' NOT NULL,
  asrType  VARCHAR(10)  DEFAULT '70' NOT NULL,		
  isStreaming  char(2)  DEFAULT '0' NOT NULL,
  isSync	char(2) DEFAULT '11' NOT NULL,
  notSupportAsrFormat	varchar(10) DEFAULT '' NOT NULL,
  timeMolecular varchar(10) DEFAULT '1' NOT NULL,
  timeDenominator varchar(10) DEFAULT '1' NOT NULL,
  headerLength varchar(10) DEFAULT '0' NOT NULL,
 PRIMARY KEY (id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (1,'2014-04-16 10:02:13','16','8','wav','0','38','0','11','','1','16','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (2,'2014-04-16 10:15:30','16','16','wav','21','42','0','11','','1','32','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (3,'2014-04-16 10:16:27','16','8','wav','23','38','1','11','3','1','16','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (4,'2014-04-16 10:16:48','16','16','wav','22','42','1','11','3','1','32','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (5,'2014-04-16 10:17:33','16','8','pcm','26','70','0','11','','1','16','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (6,'2014-04-16 10:18:01','16','16','pcm','25','74','0','11','','1','32','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (7,'2014-04-16 10:19:31','16','8','pcm','11','70','1','11','3','1','16','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (8,'2014-04-16 10:20:06','16','16','pcm','24','74','1','11','3','1','32','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (9,'2014-04-16 10:22:20','4','6','vox','16','175','0','11','','1','1','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (10,'2014-04-16 10:25:55','16','8','amr','6','134','0','11','','1','1','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (11,'2014-04-16 10:26:03','16','8','amr','5','134','0','11','','1','1','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (12,'2014-04-16 10:26:15','16','8','amr','9','134','1','11','3','1','1','0');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (13,'2014-04-16 16:28:58','8','8','alaw','27','197','0','11','','1','1','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (14,'2014-04-16 16:30:36','8','8','alaw','28','197','1','11','3','1','1','44');
insert  into `AudioProperty`(`id`,`createTime`,`rate`,`sample`,`format`,`voiceType`,`asrType`,`isStreaming`,`isSync`,`notSupportAsrFormat`,`timeMolecular`,`timeDenominator`,`headerLength`) values (15,'2014-04-16 16:53:53','16','6','wav','29','46','0','11','','1','1','44');




CREATE TABLE IF NOT EXISTS TranscriptionData(
		id		INT(10) NOT NULL AUTO_INCREMENT,					-- the orignial transcription
		createTime			TIMESTAMP NOT NULL DEFAULT current_timestamp,	-- transcription time
		kid		VARCHAR(10),							--  context table
		cid		VARCHAR(10),							--  comppany id
		aid		VARCHAR(10),							--  app id
		requestid VARCHAR(100),
		phone			VARCHAR(20),						-- telephone number
		addr			VARCHAR(50),						
		device_id		VARCHAR(100),
		engine_id		VARCHAR(5) DEFAULT '-1',
		uuid  VARCHAR(64),
		batch		VARCHAR(64),
		voice_type  VARCHAR(5),
		voice_path  VARCHAR(2048),						 
		voice_length  VARCHAR(20) NOT NULL DEFAULT '0',
		client_filename  VARCHAR(500),
		grammar_name VARCHAR(100),
		is_trans char(2) NOT NULL DEFAULT '0',
		PRIMARY KEY (id)
	) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE INDEX TranscriptionData_IDX ON TranscriptionData(is_trans,uuid);