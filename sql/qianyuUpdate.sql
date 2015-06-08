USE qianyu;
DROP TABLE IF EXISTS Nlpsentences;

#------------------------------------------------------------------------------
# Nlpsentences
# store Nlp information
#------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Nlpsentences (
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