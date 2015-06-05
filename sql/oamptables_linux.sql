CREATE DATABASE IF NOT EXISTS qianoamp;
USE qianoamp;
DROP TABLE IF EXISTS oamp_user;
DROP TABLE IF EXISTS oamp_role;
DROP TABLE IF EXISTS oamp_permission;
DROP TABLE IF EXISTS oamp_user_role;
DROP TABLE IF EXISTS oamp_role_permission;
DROP TABLE IF EXISTS oamp_access_log;
DROP TABLE IF EXISTS oamp_email;
DROP TABLE IF EXISTS oamp_monitor_config;
DROP TABLE IF EXISTS oamp_process;
DROP TABLE IF EXISTS oamp_alarm;
DROP TABLE IF EXISTS oamp_machine;
DROP TABLE IF EXISTS dingding_company;
DROP TABLE IF EXISTS oamp_request_details;
DROP TABLE IF EXISTS oamp_tts;

CREATE TABLE `oamp_tts` (
  `id` int(10) NOT NULL auto_increment,
  `TTSText` varchar(32) NOT NULL,
  `createDate` varchar(32) NOT NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;



#------------------------------------------------------------------------------
# oamp_user
# store user information
#------------------------------------------------------------------------------
CREATE TABLE `oamp_user` (
  `id` int(10) NOT NULL auto_increment,
  `name` varchar(32) default NULL,
  `loginName` varchar(32) NOT NULL,
  `pwd` varchar(32) NOT NULL,
  `createDate` DATETIME NOT NULL,
  `phone` varchar(256) NOT NULL default '',
  `mail` varchar(256) default NULL,
  `app_id` int(11) NOT NULL,
  `user_state` int(5) NOT NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
#username:admin,password:admin
INSERT INTO `oamp_user` VALUES (null,'admin','admin','d9d1ff138f1b4f0e67097eefd9277ba4','2011-08-02 09:08:34','',NULL,0,1);
INSERT INTO `oamp_user` VALUES (null,'pachira','pachira','21232f297a57a5a743894a0e4a801fc3','2011-08-13 13:00:34','',NULL,0,2);

#------------------------------------------------------------------------------
#oamp_role
#------------------------------------------------------------------------------
CREATE TABLE `oamp_role` (
  `role_id` int(10) NOT NULL auto_increment,
  `role_name` varchar(20) NOT NULL,
  `role_createDate` DATETIME NOT NULL,
  `role_state` int(10) NOT NULL,
  PRIMARY KEY (`role_id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
INSERT INTO `oamp_role` VALUES (null,'超级管理员','2011-08-02 09:18:34',1);
INSERT INTO `oamp_role` VALUES (null,'管理员','2011-08-13 13:10:34',2);
#------------------------------------------------------------------------------
#oamp_user_role
#------------------------------------------------------------------------------
CREATE TABLE `oamp_user_role` (
  `user_role_id` int(10) NOT NULL auto_increment,
  `id` int(10) NOT NULL,
  `role_id` int(10) NOT NULL,
  PRIMARY KEY (`user_role_id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


INSERT INTO `oamp_user_role` VALUES (null,1,1);
INSERT INTO `oamp_user_role` VALUES (null,2,2);
#------------------------------------------------------------------------------
#oamp_permission
#------------------------------------------------------------------------------
CREATE TABLE `oamp_permission` (
   `permission_id` int(10) NOT NULL auto_increment,
   `menu_id` int(10) NOT NULL,
   `message` varchar(50) NULL,
   `jump_path` varchar(50) NULL,
   `menu_show_message` varchar(50) NOT NULL,
   `createDate` DATETIME,
   `per_state` int(5) NOT NULL,
   PRIMARY KEY (`permission_id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

INSERT INTO oamp_permission VALUES (1,0,'Administration','','管理系统','2011-07-02 10:21:00',2);
INSERT INTO oamp_permission VALUES (2,1,'Admin','','管理','2011-07-03 10:21:00',2);
INSERT INTO oamp_permission VALUES (3,2,'Reset Password','/QianYuSrv/oamp/pwdReset','重设密码','2011-07-04 10:21:00',2);
INSERT INTO oamp_permission VALUES (9,1,'Accounting','','统计','2011-08-02',2);
INSERT INTO oamp_permission VALUES (10,9,'Total Visits','/QianYuSrv/oamp/accMonth','访问总量','2011-07-09 10:21:00',2);
INSERT INTO oamp_permission VALUES (15,9,'Total TTS','/QianYuSrv/oamp/ttstext','TTS文本记录','2011-07-09 10:21:00',2);
INSERT INTO oamp_permission VALUES (11,9,'Voice Data','/QianYuSrv/oamp/viewVoice','声音数据','2011-07-10 10:21:00',2);
INSERT INTO oamp_permission VALUES (12,9,'Transaction Statistic','/QianYuSrv/oamp/checkVoice','统计识别率','2011-07-11 10:21:00',1);
INSERT INTO oamp_permission VALUES (13,9,'Count Voice data','/QianYuSrv/oamp/countVoice','统计识别数据','2011-07-12 10:21:00',1);
INSERT INTO oamp_permission VALUES (14,9,'View All Transactions Data','/QianYuSrv/oamp/allVoice','统计数据','2011-07-13 10:21:00',1);
INSERT INTO oamp_permission VALUES (16,1,'Monitor','','监控','2011-07-15 10:21:00',2);
INSERT INTO oamp_permission VALUES (17,16,'Process Config','/QianYuSrv/oamp/processConfig','进程配置','2011-07-16 10:21:00',1);
INSERT INTO oamp_permission VALUES (18,16,'Alarm Config','/QianYuSrv/oamp/monitorConfig','报警管理','2011-07-17 10:21:00',2);
INSERT INTO oamp_permission VALUES (19,16,'Alarm Search','/QianYuSrv/oamp/alarmSearch','报警查询','2011-07-18 10:21:00',2);
INSERT INTO oamp_permission VALUES (20,16,'Disk Status','/QianYuSrv/oamp/disk','磁盘状态','2011-07-19 10:21:00',2);
INSERT INTO oamp_permission VALUES (21,16,'System Status','/QianYuSrv/oamp/machineInfo?type=system','系统状态','2011-07-20 10:21:00',2);
INSERT INTO oamp_permission VALUES (24,1,'Maintenance','','维护','2011-07-23 10:21:00',1);
INSERT INTO oamp_permission VALUES (25,24,'Client Debug Log','/QianYuSrv/oamp/debugLog?op=clientDebugLog','客户端日志','2011-07-24 10:21:00',1);
INSERT INTO oamp_permission VALUES (27,1,'Permission','','权限管理','2011-07-26 10:21:00',1);
INSERT INTO oamp_permission VALUES (28,27,'User Management','/QianYuSrv/oamp/user','用户管理','2011-07-27 10:21:00',1);
INSERT INTO oamp_permission VALUES (29,27,'Role Management','/QianYuSrv/oamp/role','角色管理','2011-07-28 10:21:00',1);
INSERT INTO oamp_permission VALUES (30,27,'Resources Management','/QianYuSrv/oamp/permission','资源管理','2011-07-29 10:21:00',1);
INSERT INTO oamp_permission VALUES (31,16,'License Tool','/QianYuSrv/oamp//machineInfoUpload','授权管理','2011-07-22 10:21:00',2);
INSERT INTO oamp_permission VALUES (32,2,'Voice Download','/QianYuSrv/oamp/voiceDownload','声音下载','2011-07-05 10:21:00',2);
INSERT INTO oamp_permission VALUES (33,2,'NLP Config Files','/QianYuSrv/nlp/nlpFileUpload','NLP配置文件','2012-06-19 10:21:00',2);

INSERT INTO oamp_permission VALUES (34, 54, 'Holiday Config', '/QianYuSrv/nlp/QueryFestivalTxtSrv', '节日配置', '2012-07-27 12:51:28', '1');
INSERT INTO oamp_permission VALUES (35, 54, 'Timescale Config', '/QianYuSrv/nlp/TimePeriodTxtSrv?flag=queryTD', '时间段配置', '2012-08-03 15:48:07', '1');
INSERT INTO oamp_permission VALUES (36, 54, 'Exception Config', '/QianYuSrv/nlp/ExceptionWordsTxtSrv?flag=queryEW', '例外管理', '2012-08-03 15:48:29', '1');
INSERT INTO oamp_permission VALUES (37, 54, 'Action Config', '/QianYuSrv/operateTxt/actions.jsp', '行为配置', '2012-08-03 15:48:55', '1');
INSERT INTO oamp_permission VALUES (38, 54, 'Location Config', '/QianYuSrv/operateTxt/locations.jsp', '地点配置', '2012-08-03 15:49:15', '1');
INSERT INTO oamp_permission VALUES (39, 54, 'Remind Time', '/QianYuSrv/nlp/DefaultNumTxtSrv?flag=queryRemind', '提醒时间', '2012-08-03 15:49:37', '1');
INSERT INTO oamp_permission VALUES (40, 54, 'Default Time', '/QianYuSrv/nlp/DefaultNumTxtSrv?flag=queryHour', '默认时刻', '2012-08-03 15:49:58', '1');
INSERT INTO oamp_permission VALUES (41, 54, 'Testing Page', '/QianYuSrv/testPage/testPage.html', '测试页面', '2012-08-03 15:50:20', '1');
INSERT INTO oamp_permission VALUES (42, 54, 'History Data', '/QianYuSrv/admin/nlpsentencesList.jsp', '历史数据', '2012-08-03 15:50:39', '1');
INSERT INTO oamp_permission VALUES (54, 1, 'NLP', '', '文件管理', '2012-08-03 15:32:18', '1');
INSERT INTO oamp_permission VALUES (55, 2, 'config kid', '/QianYuSrv/AppInputContextSrv?t=o&p=1', 'kid设置', '2012-08-13 15:32:18', '1');
INSERT INTO oamp_permission VALUES (56, 2, 'config company', '/QianYuSrv/CompanySrv', '公司设置', '2012-08-13 15:32:18', '1');
insert into oamp_permission values (57,9, 'Total Transaction', '/QianYuSrv/oamp/totalVoice', '语音识别总数', '2012-12-06 14:33:32', 1);
insert into oamp_permission values (58,9, 'Count All Transaction', '/QianYuSrv/oamp/multiSrv', '语音识别结果统计', '2012-12-06 14:33:32', 1);
insert into oamp_permission values (59,9, 'Total Voice Data', '/QianYuSrv/oamp/multiSrvVoice', '服务器语音识别数据统计信息一览', '2012-12-06 14:33:32', 1);
insert into oamp_permission values(60,9,"CompanyDict","/QianYuSrv/oamp/dingding/company?op=list","鼎顶词库",now(),1);

#------------------------------------------------------------------------------
#oamp_role_permission
#------------------------------------------------------------------------------
CREATE TABLE `oamp_role_permission` (
   `role_permission_id` int(10) NOT NULL auto_increment,
   `permission_id` int(10) NOT NULL,
   `role_id` int(10) NOT NULL,
  PRIMARY KEY (`role_permission_id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
#------------------------------------------------------------------------------
INSERT INTO oamp_role_permission VALUES(null,1,1);
INSERT INTO oamp_role_permission VALUES(null,2,1);
INSERT INTO oamp_role_permission VALUES(null,3,1);
INSERT INTO oamp_role_permission VALUES(null,9,1);
INSERT INTO oamp_role_permission VALUES(null,10,1);
INSERT INTO oamp_role_permission VALUES(null,11,1);
INSERT INTO oamp_role_permission VALUES(null,12,1);
INSERT INTO oamp_role_permission VALUES(null,13,1);
INSERT INTO oamp_role_permission VALUES(null,14,1);
INSERT INTO oamp_role_permission VALUES(null,16,1);
INSERT INTO oamp_role_permission VALUES(null,17,1);
INSERT INTO oamp_role_permission VALUES(null,18,1);
INSERT INTO oamp_role_permission VALUES(null,19,1);
INSERT INTO oamp_role_permission VALUES(null,20,1);
INSERT INTO oamp_role_permission VALUES(null,21,1);
INSERT INTO oamp_role_permission VALUES(null,24,1);
INSERT INTO oamp_role_permission VALUES(null,25,1);
INSERT INTO oamp_role_permission VALUES(null,27,1);
INSERT INTO oamp_role_permission VALUES(null,28,1);
INSERT INTO oamp_role_permission VALUES(null,29,1);
INSERT INTO oamp_role_permission VALUES(null,30,1);
INSERT INTO oamp_role_permission VALUES(null,1,2);
INSERT INTO oamp_role_permission VALUES(null,2,2);
INSERT INTO oamp_role_permission VALUES(null,3,2);
INSERT INTO oamp_role_permission VALUES(null,5,2);
INSERT INTO oamp_role_permission VALUES(null,9,2);
INSERT INTO oamp_role_permission VALUES(null,10,2);
INSERT INTO oamp_role_permission VALUES(null,11,2);
INSERT INTO oamp_role_permission VALUES(null,15,2);
INSERT INTO oamp_role_permission VALUES(null,16,2);
INSERT INTO oamp_role_permission VALUES(null,18,2);
INSERT INTO oamp_role_permission VALUES(null,19,2);
INSERT INTO oamp_role_permission VALUES(null,20,2);
INSERT INTO oamp_role_permission VALUES(null,21,2);
INSERT INTO oamp_role_permission VALUES(null,22,2);
INSERT INTO oamp_role_permission VALUES(null,32,1);
INSERT INTO oamp_role_permission VALUES(null,32,2);

INSERT INTO oamp_role_permission VALUES (null, 34, '1');
INSERT INTO oamp_role_permission VALUES (null, 35, '1');
INSERT INTO oamp_role_permission VALUES (null, 36, '1');
INSERT INTO oamp_role_permission VALUES (null, 37, '1');
INSERT INTO oamp_role_permission VALUES (null, 38, '1');
INSERT INTO oamp_role_permission VALUES (null, 39, '1');
INSERT INTO oamp_role_permission VALUES (null, 40, '1');
INSERT INTO oamp_role_permission VALUES (null, 41, '1');
INSERT INTO oamp_role_permission VALUES (null, 42, '1');
INSERT INTO oamp_role_permission VALUES (null, 43, '1');
INSERT INTO oamp_role_permission VALUES (null, 54, '1');
INSERT INTO oamp_role_permission VALUES (null, 55, '1');
INSERT INTO oamp_role_permission VALUES (null, 56, '1');
INSERT INTO oamp_role_permission VALUES (null, 57, '1');
INSERT INTO oamp_role_permission VALUES (null, 58, '1');
INSERT INTO oamp_role_permission VALUES (null, 59, '1');
insert into oamp_role_permission values (null,60,'1');
#------------------------------------------------------------------------------
# oamp_access_log
# client access information
#------------------------------------------------------------------------------
CREATE TABLE `oamp_access_log` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(50) default NULL,
  `access_time` timestamp NOT NULL default current_timestamp,
  `trans_time` int(11) default NULL,
  `ip` varchar(25) default NULL,
  `params` varchar(500) default NULL,
  `url` varchar(256) default NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


#------------------------------------------------------------------------------
# oamp_email
# config monitor person email
#------------------------------------------------------------------------------
CREATE TABLE `oamp_email` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `email` varchar(50) default NULL,
  `phone` varchar(20) default NULL,
  PRIMARY KEY  (`id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# oamp_process
# config process table
#------------------------------------------------------------------------------
CREATE TABLE `oamp_process` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `process_name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
insert  into `oamp_process`(`id`,`name`,`process_name`) values (3,'RMSVCG','rmsvr.exe'),(4,'LICVCG','LicenseSVR.exe'),(5,'RECVCG','RecSvr.exe'),(17,'TESVCG','testcli.exe');
#------------------------------------------------------------------------------
# oamp_monitor_config
# config monitor table
#------------------------------------------------------------------------------
CREATE TABLE `oamp_monitor_config` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `person_email` varchar(100) default NULL,
  `category` varchar(20) default 'interface',
  `url` varchar(200) default NULL,
  `process_id` int(11) default NULL,
  `return_content` varchar(50) default NULL,
  `time_interval` int(11) default NULL,
  `number_alert` int(11) default NULL,
  `is_start` int(11) default '1',
  `start_time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `mail_content` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
insert  into `oamp_monitor_config`(`id`,`name`,`person_email`,`category`,`url`,`process_id`,`return_content`,`time_interval`,`number_alert`,`is_start`,`start_time`,`mail_content`) values (10,'LICVCG','zhen_li@pachiratec.com;','process','',4,'',5,3,0,'2010-09-03 00:00:00',''),(11,'RECVCG','zhen_li@pachiratech.com','process','',5,'',5,3,0,'2010-09-13 00:00:00',''),(13,'RMSVCG','zhen_li@pachiratech.com','process','',3,'',5,3,0,'2010-09-13 00:00:00',''),(16,'monitorAudio','zhen_li@pachiratech.com;','interface','http://localhost/QianYuSrv/monitor/monitorAudio.jsp',0,'true',2,3,0,'2010-09-13 00:00:00',''),(19,'TESVCG','zhen_li@pachiratech.com;lizhen2882@126.com','process','',17,'',5,3,0,'2011-09-15 00:00:00','');

#------------------------------------------------------------------------------
# oamp_alarm
# record alerm some content
#------------------------------------------------------------------------------
CREATE TABLE `oamp_alarm` (
  `id` int(11) NOT NULL auto_increment,
  `date` datetime default '0000-00-00 00:00:00',
  `name` varchar(50) default NULL,
  `category` varchar(20) default NULL,
  `ip` varchar(24) default NULL,
  `to_mail` varchar(200) default NULL,
  `content` varchar(200) default NULL,
  `is_send` int(1) default '0',
  PRIMARY KEY  (`id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

#------------------------------------------------------------------------------
# oamp_machine
# 
#------------------------------------------------------------------------------
CREATE TABLE `oamp_machine` (
	`id` int(10) NOT NULL AUTO_INCREMENT,
   `name` varchar(50) DEFAULT NULL,
   `ip` varchar(50) DEFAULT NULL,
   `jmx_port` varchar(5) DEFAULT NULL,
   `web_port` varchar(5) DEFAULT NULL,
   `status` int(1) DEFAULT '1',
   PRIMARY KEY (`id`)
)DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
# init machine table
insert into oamp_machine(`name`,ip,jmx_port,web_port) values('localhost','127.0.0.1','9999','80');

CREATE TABLE IF NOT EXISTS dingding_company (
  id INT(10) NOT NULL AUTO_INCREMENT,
  `createTime` timestamp NOT NULL default CURRENT_TIMESTAMP,
  name VARCHAR(200) NOT NULL UNIQUE,
  is_index_add char(2) NOT NULL default '0',
  name_length INT(200) NOT NULL , 
 PRIMARY KEY (id) 
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE INDEX dingding_company_createTime_IDX ON dingding_company(createTime);
CREATE INDEX dingding_company_nameLength_IDX ON dingding_company(name_length);


-- ----------------------------
-- Table structure for `oamp_request_details`
-- ----------------------------

CREATE TABLE `oamp_request_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `org_time` timestamp NULL DEFAULT NULL,
  `servlet_name` varchar(255) DEFAULT NULL,
  `is_monitor` int(1) DEFAULT NULL,
  `server_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
CREATE INDEX dingding_request_orgtime_IDX ON oamp_request_details(org_time);
CREATE INDEX dingding_request_servletname_IDX ON oamp_request_details(servlet_name);
CREATE INDEX dingding_request_servername_IDX ON oamp_request_details(server_name);
