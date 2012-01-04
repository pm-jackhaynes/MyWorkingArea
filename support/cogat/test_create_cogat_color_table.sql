delimiter //

Create Table `pm_color_cogat` (
  `bb_group_id` int(10) NOT NULL,
  `bb_measure_id` int(10) NOT NULL,
  `bb_measure_item_id` int(10) NOT NULL,
  `begin_year` smallint(6) NOT NULL,
  `end_year` smallint(6) NOT NULL,
  `color_id` int(11) NOT NULL,
  `min_score` decimal(6,1) default NULL,
  `max_score` decimal(6,1) default NULL,
  `last_user_id` int(11) NOT NULL,
  `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
  `last_edit_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bb_group_id`, `bb_measure_id`, `bb_measure_item_id`, `color_id`, `begin_year` ),
  KEY `fk_pm_color_cogat_pmi_color` (`color_id`),
  CONSTRAINT `fk_pm_color_cogat_pm_bbcard_measure_item` FOREIGN KEY (`bb_group_id`,`bb_measure_id`,`bb_measure_item_id`) REFERENCES `pm_bbcard_measure_item` (`bb_group_id`,`bb_measure_id`,`bb_measure_item_id`)  ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_pm_color_cogat_pmi_color` FOREIGN KEY (`color_id`) REFERENCES `pmi_color` (`color_id`)  ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
//