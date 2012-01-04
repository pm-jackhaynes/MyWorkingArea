
delimiter //

drop table if exists `rpt_bbcard_detail`  //

CREATE TABLE `rpt_bbcard_detail` (
  `bb_group_id` int(10) NOT NULL,
  `bb_measure_id` int(10) NOT NULL,
  `bb_measure_item_id` int(10) NOT NULL,
  `student_id` int(10) NOT NULL,
  `school_year_id` int(10) NOT NULL,
  `score` varchar(20) default NULL,
  `score_type` enum('a','n') NOT NULL,
  `score_color` varchar(20) default NULL,
  `last_user_id` int(10) NOT NULL,
  `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
  `last_edit_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  KEY `ak_rpt_bbcard_detail` (`bb_group_id`,`bb_measure_id`,`bb_measure_item_id`,`student_id`,`school_year_id`),
  KEY `ind_rpt_bbcard_detail_stu` (`student_id`)
) ENGINE=MRG_MyISAM DEFAULT CHARSET=latin1 
  UNION=(`rpt_bbcard_detail_access`,`rpt_bbcard_detail_assessment`,
         `rpt_bbcard_detail_college_prep`,`rpt_bbcard_detail_ga_writing`,
         `rpt_bbcard_detail_grades`,`rpt_bbcard_detail_iri`,
         `rpt_bbcard_detail_lag_lead_hst_strand`,
         `rpt_bbcard_detail_lag_lead_hst_subject`,
         `rpt_bbcard_detail_lexile`,`rpt_bbcard_detail_nwea`,
         `rpt_bbcard_detail_pmrn`,`rpt_bbcard_detail_running_record`,
         `rpt_bbcard_detail_snap`,`rpt_bbcard_detail_terranova`,
         `rpt_bbcard_detail_smi_quartile`, `rpt_bbcard_detail_cogat`)
 //
         


drop table if exists `rpt_bbcard_detail_cogat`
 //

CREATE TABLE `rpt_bbcard_detail_cogat` (
  `bb_group_id` int(10) NOT NULL,
  `bb_measure_id` int(10) NOT NULL,
  `bb_measure_item_id` int(10) NOT NULL,
  `student_id` int(10) NOT NULL,
  `school_year_id` int(10) NOT NULL,
  `score` varchar(20) default NULL,
  `score_type` enum('a','n') NOT NULL,
  `score_color` varchar(20) default NULL,
  `last_user_id` int(10) NOT NULL,
  `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
  `last_edit_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bb_group_id`,`bb_measure_id`,`bb_measure_item_id`,`student_id`,`school_year_id`),
  KEY `ind_rpt_bbcard_detail_cogat_stu` (`student_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
 //
