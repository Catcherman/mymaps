CREATE DATABASE IF NOT EXISTS qianyu;
USE qianyu;

DROP TABLE IF EXISTS QianYuSrv;
DROP TABLE IF EXISTS Keywords;
DROP TABLE IF EXISTS TranscriptionWord;
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
    imei			VARCHAR(20),						-- IMEI number
    PRIMARY KEY (device_id),
    CONSTRAINT  FK_ClientDevice_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# VoiceProfile
# The voice model and related data that needed during transcribing
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VoiceProfile
(
	user_id 		INT(10) NOT NULL,					-- foreign key to User table
	model 			BLOB,								-- voice model binary data object 
	CONSTRAINT  FK_VoiceProfile_VoiceProfile_user_id FOREIGN KEY (user_id) REFERENCES User(user_id) 
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
	PRIMARY KEY (app_id),
	CONSTRAINT  FK_Application_company_id FOREIGN KEY (company_id) REFERENCES Company(company_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE INDEX APPLICATION_COMNAME_IDX ON Application(company_id, name);

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
	PRIMARY KEY (context_id),
	CONSTRAINT  FK_AppInputContext_app_id FOREIGN KEY (app_id) REFERENCES Application(app_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

-- app_id and description are unique
CREATE INDEX CONTEXT_APPIDDESC_IDX ON AppInputContext(app_id, description);

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
	PRIMARY KEY (app_id, reminder),
	CONSTRAINT  FK_AppInputContextMap_context_id FOREIGN KEY (context_id) REFERENCES AppInputContext(context_id),
	CONSTRAINT  FK_AppInputContextMap2_context_id FOREIGN KEY (word_freq_id) REFERENCES AppInputContext(context_id),
	CONSTRAINT  FK_AppInputContextMap_app_id FOREIGN KEY (app_id) REFERENCES Application(app_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# Transcription
# The fact table to record all transcriptions
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Transcription
(
	trans_id		INT(10) NOT NULL AUTO_INCREMENT,	-- primary key, auto increment
	device_id		INT(10) NOT NULL,					-- foreign key to Device table
	context_id		INT NOT NULL,						-- foreign key to input context table
	client_addr		VARCHAR(256),						-- client IP/Host name
	voice_type		INT DEFAULT 0,						-- Voice type, 6 PCM , 5 AMR (defined in SharedConstants) 
	voice_data		MEDIUMBLOB,								-- voice binary data object
	engine_id		INT,								-- the VR engine used for this transcription
	text			VARCHAR(256),						-- transcription result
	time			TIMESTAMP NOT NULL DEFAULT current_timestamp,	-- transcription time
	PRIMARY KEY (trans_id), 
--   to allows  FOREIGN KEY (device_id) REFERENCES ClientDevice(device_id),
	CONSTRAINT  FK_Transcription_context_id FOREIGN KEY (context_id) REFERENCES AppInputContext(context_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
#-----添加time列索引
alter table Transcription add index transid_time_idx(trans_id,time);
alter table Transcription add index contextid_time_idx(context_id,time);
#------------------------------------------------------------------------------
# TranscriptionWord
# The fact table to record all Corrections including original keywords
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS TranscriptionWord
(
	trans_id		INT(10) NOT NULL,					-- the orignial transcription
	word_seq		INT NOT NULL,						-- the sequence in the trascribed text
	start_pos		INT NOT NULL,						-- the start position in the voice data
	end_pos			INT NOT NULL,						-- the end position in the voice data
	word			VARCHAR(256),						-- the current word of choice
	word_org		VARCHAR(256),						-- the original word, NULL if choice is 0
	choice			INT NOT NULL,						-- the choice of the word, 0 means no choice
	gender			VARCHAR(20) DEFAULT NULL,			-- the gender of the voice
	usedTime		INT DEFAULT NULL,					-- used time of this recognize
	phone			VARCHAR(20),						-- telephone number
	oneCallID 		VARCHAR(50),						-- unique identifier of one call 
	ivrRecognizeID  VARCHAR(50),						-- ivr recognize id,which flow's recognize 
	PRIMARY KEY (trans_id, word_seq), 
	CONSTRAINT  FK_TranscriptionWord_trans_id FOREIGN KEY (trans_id) REFERENCES Transcription(trans_id)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE INDEX word_idx ON TranscriptionWord(word);
CREATE INDEX word_org_idx ON TranscriptionWord(word_org);

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

CREATE INDEX keyword_idx ON Keywords(context_id, word);



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

-- alter imei length
ALTER TABLE `qianyu`.`ClientDevice`  CHANGE `imei` `imei` VARCHAR(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL ;

-- Add accuray field
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `detail_information` INT(2) DEFAULT '0' NOT NULL;
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `real_input` VARCHAR(256) DEFAULT '' NULL; 
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `comment` VARCHAR(256) DEFAULT '' NULL;
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `phone` VARCHAR(20) DEFAULT '' NULL;
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `oneCallID` VARCHAR(50) DEFAULT '' NULL; 
ALTER TABLE `qianyu`.`TranscriptionWord` ADD COLUMN `ivrRecognizeID` VARCHAR(50) DEFAULT '' NULL;
ALTER TABLE `qianyu`.`Transcription` ADD INDEX `time` (`time`);
ALTER TABLE `qianyu`.`Transcription` ADD INDEX `voice_type` (`voice_type`);
ALTER TABLE `qianyu`.`ClientDevice` ADD INDEX `imei` (`imei`);