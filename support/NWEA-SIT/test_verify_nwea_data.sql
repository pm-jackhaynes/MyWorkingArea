/* ************************************************************************************************* 

Insure your reporting criteria (Baseball Card Selection Tree Information) was loaded

************************************************************************************************* */
use mn_wayzatas_ods;

select 'MAX Group ID is: ', max(bb_group_id), ' and MUST be LESS than: ', pmi_admin.pmi_f_get_next_sequence('pm_bbcard_group', 1)
from pm_bbcard_group;

select 'MAX Group ID is: ', max(swatch_id), ' and MUST be LESS than: ', pmi_admin.pmi_f_get_next_sequence('c_color_swatch', 1) 
from c_color_swatch;

select * from pm_bbcard_group;
select * from pm_bbcard_measure where bb_group_id = 1000014;
select * from pm_bbcard_measure_item where bb_group_id = 1000014
order by bb_measure_id, sort_order;

select * from c_color_swatch;
select * from c_color_swatch_list;

select distinct m.bb_measure_code, m.moniker, m.bb_measure_id 
from pm_bbcard_measure m join pm_bbcard_measure_item mi on m.bb_measure_id = mi.bb_measure_id
where m.bb_group_id = 1000015;

select * from pm_bbcard_group;

-- Drop Foreign Keys

-- alter table pm_bbcard_measure_item drop foreign key  fk_pm_bbcard_measure_item_pm_bbcard_measure;
-- alter table pm_bbcard_measure  drop foreign key  fk_pm_bbcard_measure_pm_bbcard_group;
-- alter table pm_bbcard_measure_item drop foreign key fk_pm_bbcard_measure_item_pmi_sys_message;
-- alter table pm_bbcard_measure_select drop foreign key fk_pm_bbcard_measure_select_pm_bbcard_measure_item;

/* ************************************************************************************************* 

Refresh the selection critieria so that you can see the menu options available in the baseball
card menu.


************************************************************************************************* */

call mn_wayzata.etl_pm_bbcard_measure_select();

/* *************************************************************************************************

SQL to verify that you are creating the correct rows in the rpt_bbcard_detail Table

************************************************************************************************* */

select count(*) from rpt_bbcard_detail_nwea;  

select * from rpt_bbcard_detail_nwea
where student_id = 127747191 limit 100;

select s.last_name, s.first_name, rpt.school_year_id, rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, rpt.bb_measure_item_id, m.bb_measure_code, mi.bb_measure_item_code, rpt.score, rpt.score_color
from rpt_bbcard_detail_nwea rpt
join c_student s on rpt.student_id = s.student_id 
join pm_bbcard_measure m on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id
join pm_bbcard_measure_item mi on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id and rpt.bb_measure_item_id = mi.bb_measure_item_id
order by rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, rpt.bb_measure_item_id;

select s.last_name, s.first_name, rpt.school_year_id, rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, m.bb_measure_code, left(mi.bb_measure_item_code, length(mi.bb_measure_item_code) - 3) left_most, rpt.score, rpt.score_color, count(*)
from rpt_bbcard_detail_nwea rpt
join c_student s on rpt.student_id = s.student_id 
join pm_bbcard_measure m on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id
join pm_bbcard_measure_item mi on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id and rpt.bb_measure_item_id = mi.bb_measure_item_id
group by s.last_name, s.first_name, rpt.school_year_id, rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, m.bb_measure_code, left_most, rpt.score, rpt.score_color;

/*

    Find some data you can report on!

*/
select distinct s.last_name, s.first_name, sch.moniker
from mn_wayzata_ods.pmi_ods_nwea as ods
   join    mn_wayzata.c_student as s
      on      s.student_code = ods.student_id
   join    mn_wayzata.c_student_year sy
      on      s.student_id = sy.student_id
   join    mn_wayzata.c_school sch
      on      sy.school_id = sch.school_id
where ods.growth_measure_flag = 'False';

select '*** Group Code to be processed:', cast(v_bb_group_id as char) from dual;

select * from tmp_id_assign;
select * from tmp_pm_bbcard_group;
select * from tmp_date_conversion;
select * from tmp_stu_admin;



-- delete from c_color_swatch where swatch_id in (1000022, 1000023, 1000024);
-- delete from pm_bbcard_group where bb_group_id in (1000024);
-- delete from pm_bbcard_measure where bb_group_id = 1000024;
-- delete from pm_bbcard_measure_item where bb_group_id = 1000024;

select test_start_date, str_to_date(test_start_date, '%m/%d/%Y') from v_pmi_ods_cogat;
Select * from mn_wayzata_ods.pmi_ods_nwea;

select count(*) from pm_bbcard_measure_item 
where bb_group_id = 1000014 and
      moniker like '%Summer';

select count(*) from pm_bbcard_measure_item 
where bb_group_id = 1000014 and
      moniker like '%Winter';

select count(*) from pm_bbcard_measure_item 
where bb_group_id = 1000014 and
      moniker like '%Fall';

select count(*) from pm_bbcard_measure_item 
where bb_group_id = 1000014 and
      moniker like '%Spring';



/* ************************************************************************************************* 

Troubleshoot, resolve  a failure to upload data and upload data

************************************************************************************************* */


-- call mn_wayzata.etl_imp();  -- This executes over 80 upload steps so don't run it unless you 
-- have to.

select * from pmi_admin.imp_table_column where table_id = 1000130;

select distinct growth_measure_flag from mn_wayzata_ods.pmi_ods_nwea;

select * from mn_wayzata_ods.f_pmi_ods_nwea_20120112_092251 limit 100;

select max(length(c027)) from mn_wayzata_ods.f_pmi_ods_nwea_20120112_092251;

select count(*) from  mn_wayzata_ods.f_pmi_ods_nwea_20120112_115348;

call mn_wayzata_ods.imp_process_upload_log();
call mn_wayzata.etl_pm_bbcard_measure_select();

select count(*) from  mn_wayzata_ods.pmi_ods_nwea;

select  upload_id, client_id, table_id, auto_batch_id, upload_status_code, 
        import_table_name, upload_start_timestamp, last_edit_timestamp, 
        substring(comment from 1 for 30) as comment 
        from mn_wayzata_ods.imp_upload_log
where upload_start_timestamp > '2012-01-11';

update mn_wayzata_ods.imp_upload_log
set upload_status_code = 'm'
where upload_id = 3068223;

select c001, c002, c003 from mn_wayzata_ods.f_pmi_ods_nwea_20120112_092251 limit 3;
select c001, c002, c003 from mn_wayzata_ods.F_Pmi_Ods_Nwea_20120112_115348  limit 3;

select count(*) from rpt_bbcard_detail_nwea;  

select * from rpt_bbcard_detail_nwea
where student_id = 127747191 limit 100;

select * from mn_wayzata_ods.imp_table_column where table_id = 1000130;
select * from pmi_admin.imp_table_column where table_id = 1000130;

 -- After running the imp_sync procedure be sure the new values appear in the ods imp_table_column table.
 -- IMPORTANT: This drops the pmi_ods_nwea table so you might want to back up the infomration before running
call mn_wayzata_ods.imp_sync_table_def_to_admin_by_name('pmi_ods_nwea');
call mn_wayzata_ods.imp_drop_create_pmi_ods_table_by_name('pmi_ods_nwea');

show create table mn_wayzata_ods.pmi_ods_nwea;
-- create table mn_wayzata_ods.pmi_ods_nwea_jack as select * from mn_wayzata_ods.pmi_ods_nwea;
truncate mn_wayzata_ods.pmi_ods_nwea;

call mn_wayzata_ods.imp_process_upload_log();
call mn_wayzata.etl_pm_bbcard_measure_select();

select * from mn_wayzata_ods.pmi_ods_nwea order by student_id limit 100;

select distinct growth_measure_flag from mn_wayzata_ods.pmi_ods_nwea;


/*  ****************************************************************************************************************************************************************

      Create a backfill conditon for testing
      
 *  ************************************************************************************************************************************************************** */
  
use mn_wayzata;
select * from c_student where student_code = '034351';
-- delete from c_ayp_strand_student where student_id = 127698084;
-- delete from c_ayp_subject_student where student_id = 127698084;
-- delete from c_student_school_list where student_id = 127698084;
-- delete from c_student_year where student_id = 127698084;

select * from tmp_student_year_backfill;
select * from c_student_year where student_id = 127698084;


/*  ****************************************************************************************************************************************************************

      Backup pmi_ods_nwea data
      
 *  ************************************************************************************************************************************************************** */


use mn_wayzata_ods;
create table pmi_ods_nwea_jack as select * from pmi_ods_nwea;
select count(*) from pmi_ods_nwea_jack;

/*  ****************************************************************************************************************************************************************

      To create the tab delimited file using MySQL Workbench Export feature using the following queries.

      These tab delimited files are to be emailed to Randall so he can load the pm_bbcard_measure and pm_bbcard_measure_item tables.
      
 *  ************************************************************************************************************************************************************** */


use mn_wayzata;

select 
             bb_group_code
            ,bb_measure_code
            ,moniker
            ,sort_order
            ,coalesce(swatch_code, '')  swatch_code
            ,active_flag
            ,dynamic_creation_flag
from tmp_pm_bbcard_measure;

select 
             bb_group_code
            ,bb_measure_code
            ,bb_measure_item_code
            ,moniker
            ,sort_order
            ,coalesce(swatch_code, '')  swatch_code
            ,score_sort_type_code
            ,active_flag
            ,dynamic_creation_flag
from tmp_pm_bbcard_measure_item
order by bb_measure_code, bb_measure_item_code;

/*  ****************************************************************************************************************************************************************

      Restore pmi_ods_nwea using your backup pmi_ods_nwea_jack table
      
 *  ************************************************************************************************************************************************************** */

truncate mn_wayzata_ods.pmi_ods_nwea;
insert into mn_wayzata_ods.pmi_ods_nwea (
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
lexile_max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
)
select 
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
Lexile_Max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
From  mn_wayzata_ods.pmi_ods_nwea_jack;


/*  ****************************************************************************************************************************************************************

      Truncate pmi_ods_nwea and load your test data
      
 *  ************************************************************************************************************************************************************** */


-- Load Spring Data

truncate mn_wayzata_ods.pmi_ods_nwea;
insert into mn_wayzata_ods.pmi_ods_nwea (
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
lexile_max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
)
values
 (1                          -- row_num,
  ,'034351'                 -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Language Survey w/ Goals WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,1                         -- test_rit_score
  ,2                         -- test_std_err
  ,3                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,4                         -- lexiile_score
  ,5                         -- goal_rit_score1
  ,'A1'              -- goal_adjective1
  ,'Goal 1 name'              -- goal_name1
  ,7,
  'A2'
  ,'Goal 2 name'
  ,8
  ,'A3'
  ,'Goal 3 name'
  ,9,
  'A4'
  ,'Goal 4 name'
  ,10
  ,'A5'
  ,'Goal 5 name'
  ,11
  ,'A6'
  ,'Goal 6 name'
  ,12
  ,'A7'
  ,'Goal 7 name'
  ,13
  ,14
 ,'M'
 ,15
 ,'True'
 ,16
 ,16
 ,'10:01:02'
 ,17
 ,18
 ,19
 ,'A8'
 ,'Goal 8 name'
 ,20
 ,'A9'
 ,'Goal 9 name')
  , (2                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Math Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Msth'                    -- test_type_name
  ,20                         -- test_rit_score
  ,21                         -- test_std_err
  ,22                         -- test_percentil      
  ,'05/12/2010'              -- test_start_date
  ,23                         -- lexiile_score
  ,24                         -- goal_rit_score1
  ,'B!'              -- goal_adjective1
  ,'Goal 1B name'              -- goal_name1
  ,25
  ,'B2'
  ,'Goal 2B name'
  ,26
  ,'B3'
  ,'Goal 3B name'
  ,27,
  'B4'
  ,'Goal 4B name'
  ,28
  ,'B5'
  ,'Goal 5B name'
  ,29
  ,'B6'
  ,'Goal 6B name'
  ,30
  ,'B7'
  ,'Goal 7B name'
  ,31
  ,32
 ,'M'
 ,33
 ,'False'
 ,34
 ,35
 ,'10:02:03'
 ,36
 ,37
 ,38
 ,'A8'
 ,'Goal 8B name'
 ,39
 ,'A9'
 ,'Goal 9B name')
  , (3                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'NWEA Algebra I V2'  -- test_name
  ,'Math'                    -- test_type_name
  ,40                         -- test_rit_score
  ,41                         -- test_std_err
  ,42                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,43                         -- lexiile_score
  ,44                         -- goal_rit_score1
  ,'C!'              -- goal_adjective1
  ,'Goal 1C name'              -- goal_name1
  ,45,
  'C2'
  ,'Goal 2C name'
  ,46
  ,'C3'
  ,'Goal 3C name'
  ,47,
  'C4'
  ,'Goal 4C name'
  ,48
  ,'C5'
  ,'Goal 5C name'
  ,49
  ,'C6'
  ,'Goal 6C name'
  ,50
  ,'C7'
  ,'Goal 7C name'
  ,51
  ,52
 ,'M'
 ,53
 ,'True'
 ,54
 ,55
 ,'10:02:03'
 ,56
 ,57
 ,58
 ,'A8'
 ,'Goal 8C name'
 ,59
 ,'A9'
 ,'Goal 9C name')
  , (4                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Math (Combined Tests-all Goals)'  -- test_name
  ,'Math'                    -- test_type_name
  ,60                         -- test_rit_score
  ,61                         -- test_std_err
  ,62                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,63                         -- lexiile_score
  ,64                         -- goal_rit_score1
  ,'D!'              -- goal_adjective1
  ,'Goal 1D name'              -- goal_name1
  ,65,
  'D2'
  ,'Goal 2D name'
  ,66
  ,'D3'
  ,'Goal 3D name'
  ,67,
  'D4'
  ,'Goal 4D name'
  ,68
  ,'D5'
  ,'Goal 5D name'
  ,69
  ,'D6'
  ,'Goal 6D name'
  ,70
  ,'D7'
  ,'Goal 7D name'
  ,71
  ,72
 ,'M'
 ,73
 ,'False'
 ,74
 ,75
 ,'10:02:03'
 ,76
 ,77
 ,78
 ,'A8'
 ,'Goal 8D name'
 ,79
 ,'A9'
 ,'Goal 9D name')
  , (5                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Reading (Combined Tests-all Goals)'  -- test_name
  ,'Reading'                    -- test_type_name
  ,80                         -- test_rit_score
  ,81                         -- test_std_err
  ,82                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,83                         -- lexiile_score
  ,84                         -- goal_rit_score1
  ,'E!'              -- goal_adjective1
  ,'Goal 1E name'              -- goal_name1
  ,85,
  'E2'
  ,'Goal 2E name'
  ,86
  ,'E3'
  ,'Goal 3E name'
  ,87,
  'E4'
  ,'Goal 4E name'
  ,88
  ,'E5'
  ,'Goal 5E name'
  ,89
  ,'E6'
  ,'Goal 6E name'
  ,90
  ,'E7'
  ,'Goal 7E name'
  ,91
  ,92
 ,'M'
 ,93
 ,'True'
 ,94
 ,95
 ,'10:02:03'
 ,96
 ,97
 ,98
 ,'A8'
 ,'Goal 8E name'
 ,99
 ,'A9'
 ,'Goal 9E name')
  , (6                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,06                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Reading Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,101                         -- test_rit_score
  ,102                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,104                         -- lexiile_score
  ,105                         -- goal_rit_score1
  ,'F!'              -- goal_adjective1
  ,'Goal 1F name'              -- goal_name1
  ,106,
  'F2'
  ,'Goal 2F name'
  ,107
  ,'F3'
  ,'Goal 3F name'
  ,108,
  'F4'
  ,'Goal 4F name'
  ,109
  ,'F5'
  ,'Goal 5F name'
  ,110
  ,'F6'
  ,'Goal 6F name'
  ,111
  ,'F7'
  ,'Goal 7F name'
  ,112
  ,113
 ,'M'
 ,114
 ,'False'
 ,115
 ,116
 ,'10:02:03'
 ,117
 ,118
 ,119
 ,'A8'
 ,'Goal 8F name'
 ,120
 ,'A9'
 ,'Goal 9F name')
  , (7                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science Part 1 of 2 - Concepts/Processes V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,121                         -- test_rit_score
  ,122                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,124                         -- lexiile_score
  ,125                         -- goal_rit_score1
  ,'G!'              -- goal_adjective1
  ,'Goal 1G name'              -- goal_name1
  ,126,
  'G2'
  ,'Goal 2G name'
  ,127
  ,'G3'
  ,'Goal 3G name'
  ,128,
  'G4'
  ,'Goal 4G name'
  ,129
  ,'G5'
  ,'Goal 5G name'
  ,130
  ,'G6'
  ,'Goal 6G name'
  ,131
  ,'G7'
  ,'Goal 7G name'
  ,132
  ,133
 ,'M'
 ,134
 ,'True'
 ,135
 ,136
 ,'10:02:03'
 ,137
 ,138
 ,139
 ,'A8'
 ,'Goal 8G name'
 ,140
 ,'A9'
 ,'Goal 9G name')
  , (8                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Spring 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science General Science V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,2                         -- test_rit_score
  ,3                         -- test_std_err
  ,4                         -- test_percentil      
  ,'05/13/2010'              -- test_start_date
  ,5                         -- lexiile_score
  ,6                         -- goal_rit_score1
  ,'H!'              -- goal_adjective1
  ,'Goal 1H name'              -- goal_name1
  ,7,
  'H2'
  ,'Goal 2H name'
  ,8
  ,'H3'
  ,'Goal 3H name'
  ,9,
  'H4'
  ,'Goal 4H name'
  ,10
  ,'H5'
  ,'Goal 5H name'
  ,11
  ,'H6'
  ,'Goal 6H name'
  ,12
  ,'H7'
  ,'Goal 7H name'
  ,13
  ,14
 ,'M'
 ,15
 ,'False'
 ,16
 ,17
 ,'10:02:03'
 ,18
 ,19
 ,20
 ,'A8'
 ,'Goal 8H name'
 ,21
 ,'A9'
 ,'Goal 9H name');
 
 
-- Load Summer Data


insert into mn_wayzata_ods.pmi_ods_nwea (
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
lexile_max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
)
values
 (1                          -- row_num,
  ,'034351'                 -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Language Survey w/ Goals WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,1                         -- test_rit_score
  ,2                         -- test_std_err
  ,3                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,4                         -- lexiile_score
  ,5                         -- goal_rit_score1
  ,'A1'              -- goal_adjective1
  ,'Goal 1 name'              -- goal_name1
  ,7,
  'A2'
  ,'Goal 2 name'
  ,8
  ,'A3'
  ,'Goal 3 name'
  ,9,
  'A4'
  ,'Goal 4 name'
  ,10
  ,'A5'
  ,'Goal 5 name'
  ,11
  ,'A6'
  ,'Goal 6 name'
  ,12
  ,'A7'
  ,'Goal 7 name'
  ,13
  ,14
 ,'M'
 ,15
 ,'True'
 ,16
 ,16
 ,'10:01:02'
 ,17
 ,18
 ,19
 ,'A8'
 ,'Goal 8 name'
 ,20
 ,'A9'
 ,'Goal 9 name')
  , (2                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Math Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Msth'                    -- test_type_name
  ,20                         -- test_rit_score
  ,21                         -- test_std_err
  ,22                         -- test_percentil      
  ,'05/12/2010'              -- test_start_date
  ,23                         -- lexiile_score
  ,24                         -- goal_rit_score1
  ,'B!'              -- goal_adjective1
  ,'Goal 1B name'              -- goal_name1
  ,25
  ,'B2'
  ,'Goal 2B name'
  ,26
  ,'B3'
  ,'Goal 3B name'
  ,27,
  'B4'
  ,'Goal 4B name'
  ,28
  ,'B5'
  ,'Goal 5B name'
  ,29
  ,'B6'
  ,'Goal 6B name'
  ,30
  ,'B7'
  ,'Goal 7B name'
  ,31
  ,32
 ,'M'
 ,33
 ,'False'
 ,34
 ,35
 ,'10:02:03'
 ,36
 ,37
 ,38
 ,'A8'
 ,'Goal 8B name'
 ,39
 ,'A9'
 ,'Goal 9B name')
  , (3                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'NWEA Algebra I V2'  -- test_name
  ,'Math'                    -- test_type_name
  ,40                         -- test_rit_score
  ,41                         -- test_std_err
  ,42                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,43                         -- lexiile_score
  ,44                         -- goal_rit_score1
  ,'C!'              -- goal_adjective1
  ,'Goal 1C name'              -- goal_name1
  ,45,
  'C2'
  ,'Goal 2C name'
  ,46
  ,'C3'
  ,'Goal 3C name'
  ,47,
  'C4'
  ,'Goal 4C name'
  ,48
  ,'C5'
  ,'Goal 5C name'
  ,49
  ,'C6'
  ,'Goal 6C name'
  ,50
  ,'C7'
  ,'Goal 7C name'
  ,51
  ,52
 ,'M'
 ,53
 ,'True'
 ,54
 ,55
 ,'10:02:03'
 ,56
 ,57
 ,58
 ,'A8'
 ,'Goal 8C name'
 ,59
 ,'A9'
 ,'Goal 9C name')
  , (4                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Math (Combined Tests-all Goals)'  -- test_name
  ,'Math'                    -- test_type_name
  ,60                         -- test_rit_score
  ,61                         -- test_std_err
  ,62                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,63                         -- lexiile_score
  ,64                         -- goal_rit_score1
  ,'D!'              -- goal_adjective1
  ,'Goal 1D name'              -- goal_name1
  ,65,
  'D2'
  ,'Goal 2D name'
  ,66
  ,'D3'
  ,'Goal 3D name'
  ,67,
  'D4'
  ,'Goal 4D name'
  ,68
  ,'D5'
  ,'Goal 5D name'
  ,69
  ,'D6'
  ,'Goal 6D name'
  ,70
  ,'D7'
  ,'Goal 7D name'
  ,71
  ,72
 ,'M'
 ,73
 ,'False'
 ,74
 ,75
 ,'10:02:03'
 ,76
 ,77
 ,78
 ,'A8'
 ,'Goal 8D name'
 ,79
 ,'A9'
 ,'Goal 9D name')
  , (5                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Reading (Combined Tests-all Goals)'  -- test_name
  ,'Reading'                    -- test_type_name
  ,80                         -- test_rit_score
  ,81                         -- test_std_err
  ,82                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,83                         -- lexiile_score
  ,84                         -- goal_rit_score1
  ,'E!'              -- goal_adjective1
  ,'Goal 1E name'              -- goal_name1
  ,85,
  'E2'
  ,'Goal 2E name'
  ,86
  ,'E3'
  ,'Goal 3E name'
  ,87,
  'E4'
  ,'Goal 4E name'
  ,88
  ,'E5'
  ,'Goal 5E name'
  ,89
  ,'E6'
  ,'Goal 6E name'
  ,90
  ,'E7'
  ,'Goal 7E name'
  ,91
  ,92
 ,'M'
 ,93
 ,'True'
 ,94
 ,95
 ,'10:02:03'
 ,96
 ,97
 ,98
 ,'A8'
 ,'Goal 8E name'
 ,99
 ,'A9'
 ,'Goal 9E name')
  , (6                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,06                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Reading Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,101                         -- test_rit_score
  ,102                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,104                         -- lexiile_score
  ,105                         -- goal_rit_score1
  ,'F!'              -- goal_adjective1
  ,'Goal 1F name'              -- goal_name1
  ,106,
  'F2'
  ,'Goal 2F name'
  ,107
  ,'F3'
  ,'Goal 3F name'
  ,108,
  'F4'
  ,'Goal 4F name'
  ,109
  ,'F5'
  ,'Goal 5F name'
  ,110
  ,'F6'
  ,'Goal 6F name'
  ,111
  ,'F7'
  ,'Goal 7F name'
  ,112
  ,113
 ,'M'
 ,114
 ,'False'
 ,115
 ,116
 ,'10:02:03'
 ,117
 ,118
 ,119
 ,'A8'
 ,'Goal 8F name'
 ,120
 ,'A9'
 ,'Goal 9F name')
  , (7                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science Part 1 of 2 - Concepts/Processes V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,121                         -- test_rit_score
  ,122                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,124                         -- lexiile_score
  ,125                         -- goal_rit_score1
  ,'G!'              -- goal_adjective1
  ,'Goal 1G name'              -- goal_name1
  ,126,
  'G2'
  ,'Goal 2G name'
  ,127
  ,'G3'
  ,'Goal 3G name'
  ,128,
  'G4'
  ,'Goal 4G name'
  ,129
  ,'G5'
  ,'Goal 5G name'
  ,130
  ,'G6'
  ,'Goal 6G name'
  ,131
  ,'G7'
  ,'Goal 7G name'
  ,132
  ,133
 ,'M'
 ,134
 ,'True'
 ,135
 ,136
 ,'10:02:03'
 ,137
 ,138
 ,139
 ,'A8'
 ,'Goal 8G name'
 ,140
 ,'A9'
 ,'Goal 9G name')
  , (8                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Summer 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science General Science V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,2                         -- test_rit_score
  ,3                         -- test_std_err
  ,4                         -- test_percentil      
  ,'05/13/2010'              -- test_start_date
  ,5                         -- lexiile_score
  ,6                         -- goal_rit_score1
  ,'H!'              -- goal_adjective1
  ,'Goal 1H name'              -- goal_name1
  ,7,
  'H2'
  ,'Goal 2H name'
  ,8
  ,'H3'
  ,'Goal 3H name'
  ,9,
  'H4'
  ,'Goal 4H name'
  ,10
  ,'H5'
  ,'Goal 5H name'
  ,11
  ,'H6'
  ,'Goal 6H name'
  ,12
  ,'H7'
  ,'Goal 7H name'
  ,13
  ,14
 ,'M'
 ,15
 ,'False'
 ,16
 ,17
 ,'10:02:03'
 ,18
 ,19
 ,20
 ,'A8'
 ,'Goal 8H name'
 ,21
 ,'A9'
 ,'Goal 9H name');


-- Load Fall Data


insert into mn_wayzata_ods.pmi_ods_nwea (
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
lexile_max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
)
values
 (1                          -- row_num,
  ,'034351'                 -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Language Survey w/ Goals WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,1                         -- test_rit_score
  ,2                         -- test_std_err
  ,3                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,4                         -- lexiile_score
  ,5                         -- goal_rit_score1
  ,'A1'              -- goal_adjective1
  ,'Goal 1 name'              -- goal_name1
  ,7,
  'A2'
  ,'Goal 2 name'
  ,8
  ,'A3'
  ,'Goal 3 name'
  ,9,
  'A4'
  ,'Goal 4 name'
  ,10
  ,'A5'
  ,'Goal 5 name'
  ,11
  ,'A6'
  ,'Goal 6 name'
  ,12
  ,'A7'
  ,'Goal 7 name'
  ,13
  ,14
 ,'M'
 ,15
 ,'True'
 ,16
 ,16
 ,'10:01:02'
 ,17
 ,18
 ,19
 ,'A8'
 ,'Goal 8 name'
 ,20
 ,'A9'
 ,'Goal 9 name')
  , (2                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Math Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Msth'                    -- test_type_name
  ,20                         -- test_rit_score
  ,21                         -- test_std_err
  ,22                         -- test_percentil      
  ,'05/12/2010'              -- test_start_date
  ,23                         -- lexiile_score
  ,24                         -- goal_rit_score1
  ,'B!'              -- goal_adjective1
  ,'Goal 1B name'              -- goal_name1
  ,25
  ,'B2'
  ,'Goal 2B name'
  ,26
  ,'B3'
  ,'Goal 3B name'
  ,27,
  'B4'
  ,'Goal 4B name'
  ,28
  ,'B5'
  ,'Goal 5B name'
  ,29
  ,'B6'
  ,'Goal 6B name'
  ,30
  ,'B7'
  ,'Goal 7B name'
  ,31
  ,32
 ,'M'
 ,33
 ,'False'
 ,34
 ,35
 ,'10:02:03'
 ,36
 ,37
 ,38
 ,'A8'
 ,'Goal 8B name'
 ,39
 ,'A9'
 ,'Goal 9B name')
  , (3                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'NWEA Algebra I V2'  -- test_name
  ,'Math'                    -- test_type_name
  ,40                         -- test_rit_score
  ,41                         -- test_std_err
  ,42                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,43                         -- lexiile_score
  ,44                         -- goal_rit_score1
  ,'C!'              -- goal_adjective1
  ,'Goal 1C name'              -- goal_name1
  ,45,
  'C2'
  ,'Goal 2C name'
  ,46
  ,'C3'
  ,'Goal 3C name'
  ,47,
  'C4'
  ,'Goal 4C name'
  ,48
  ,'C5'
  ,'Goal 5C name'
  ,49
  ,'C6'
  ,'Goal 6C name'
  ,50
  ,'C7'
  ,'Goal 7C name'
  ,51
  ,52
 ,'M'
 ,53
 ,'True'
 ,54
 ,55
 ,'10:02:03'
 ,56
 ,57
 ,58
 ,'A8'
 ,'Goal 8C name'
 ,59
 ,'A9'
 ,'Goal 9C name')
  , (4                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Math (Combined Tests-all Goals)'  -- test_name
  ,'Math'                    -- test_type_name
  ,60                         -- test_rit_score
  ,61                         -- test_std_err
  ,62                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,63                         -- lexiile_score
  ,64                         -- goal_rit_score1
  ,'D!'              -- goal_adjective1
  ,'Goal 1D name'              -- goal_name1
  ,65,
  'D2'
  ,'Goal 2D name'
  ,66
  ,'D3'
  ,'Goal 3D name'
  ,67,
  'D4'
  ,'Goal 4D name'
  ,68
  ,'D5'
  ,'Goal 5D name'
  ,69
  ,'D6'
  ,'Goal 6D name'
  ,70
  ,'D7'
  ,'Goal 7D name'
  ,71
  ,72
 ,'M'
 ,73
 ,'False'
 ,74
 ,75
 ,'10:02:03'
 ,76
 ,77
 ,78
 ,'A8'
 ,'Goal 8D name'
 ,79
 ,'A9'
 ,'Goal 9D name')
  , (5                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Reading (Combined Tests-all Goals)'  -- test_name
  ,'Reading'                    -- test_type_name
  ,80                         -- test_rit_score
  ,81                         -- test_std_err
  ,82                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,83                         -- lexiile_score
  ,84                         -- goal_rit_score1
  ,'E!'              -- goal_adjective1
  ,'Goal 1E name'              -- goal_name1
  ,85,
  'E2'
  ,'Goal 2E name'
  ,86
  ,'E3'
  ,'Goal 3E name'
  ,87,
  'E4'
  ,'Goal 4E name'
  ,88
  ,'E5'
  ,'Goal 5E name'
  ,89
  ,'E6'
  ,'Goal 6E name'
  ,90
  ,'E7'
  ,'Goal 7E name'
  ,91
  ,92
 ,'M'
 ,93
 ,'True'
 ,94
 ,95
 ,'10:02:03'
 ,96
 ,97
 ,98
 ,'A8'
 ,'Goal 8E name'
 ,99
 ,'A9'
 ,'Goal 9E name')
  , (6                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,06                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Reading Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,101                         -- test_rit_score
  ,102                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,104                         -- lexiile_score
  ,105                         -- goal_rit_score1
  ,'F!'              -- goal_adjective1
  ,'Goal 1F name'              -- goal_name1
  ,106,
  'F2'
  ,'Goal 2F name'
  ,107
  ,'F3'
  ,'Goal 3F name'
  ,108,
  'F4'
  ,'Goal 4F name'
  ,109
  ,'F5'
  ,'Goal 5F name'
  ,110
  ,'F6'
  ,'Goal 6F name'
  ,111
  ,'F7'
  ,'Goal 7F name'
  ,112
  ,113
 ,'M'
 ,114
 ,'False'
 ,115
 ,116
 ,'10:02:03'
 ,117
 ,118
 ,119
 ,'A8'
 ,'Goal 8F name'
 ,120
 ,'A9'
 ,'Goal 9F name')
  , (7                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science Part 1 of 2 - Concepts/Processes V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,121                         -- test_rit_score
  ,122                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,124                         -- lexiile_score
  ,125                         -- goal_rit_score1
  ,'G!'              -- goal_adjective1
  ,'Goal 1G name'              -- goal_name1
  ,126,
  'G2'
  ,'Goal 2G name'
  ,127
  ,'G3'
  ,'Goal 3G name'
  ,128,
  'G4'
  ,'Goal 4G name'
  ,129
  ,'G5'
  ,'Goal 5G name'
  ,130
  ,'G6'
  ,'Goal 6G name'
  ,131
  ,'G7'
  ,'Goal 7G name'
  ,132
  ,133
 ,'M'
 ,134
 ,'True'
 ,135
 ,136
 ,'10:02:03'
 ,137
 ,138
 ,139
 ,'A8'
 ,'Goal 8G name'
 ,140
 ,'A9'
 ,'Goal 9G name')
  , (8                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Fall 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science General Science V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,2                         -- test_rit_score
  ,3                         -- test_std_err
  ,4                         -- test_percentil      
  ,'05/13/2010'              -- test_start_date
  ,5                         -- lexiile_score
  ,6                         -- goal_rit_score1
  ,'H!'              -- goal_adjective1
  ,'Goal 1H name'              -- goal_name1
  ,7,
  'H2'
  ,'Goal 2H name'
  ,8
  ,'H3'
  ,'Goal 3H name'
  ,9,
  'H4'
  ,'Goal 4H name'
  ,10
  ,'H5'
  ,'Goal 5H name'
  ,11
  ,'H6'
  ,'Goal 6H name'
  ,12
  ,'H7'
  ,'Goal 7H name'
  ,13
  ,14
 ,'M'
 ,15
 ,'False'
 ,16
 ,17
 ,'10:02:03'
 ,18
 ,19
 ,20
 ,'A8'
 ,'Goal 8H name'
 ,21
 ,'A9'
 ,'Goal 9H name');



-- Load Winter Data


insert into mn_wayzata_ods.pmi_ods_nwea (
row_num,
student_id,
student_name,
grade,
term_name,
measurement_scale_name,
test_name,
test_type_name ,
test_rit_score,
test_std_err,
test_percentile,
test_start_date,
lexile_score,
goal_rit_score1,
goal_adjective1,
goal_name1,
goal_rit_score2,
goal_adjective2,
goal_name2,
goal_rit_score3,
goal_adjective3,
goal_name3,
goal_rit_score4 ,
goal_adjective4,
goal_name4,
goal_rit_score5,
goal_adjective5,
goal_name5,
goal_rit_score6,
goal_adjective6,
goal_name6,
goal_rit_score7,
goal_adjective7,
goal_name7,
lexile_min,
lexile_max,
student_gender,
rit_reading_score,
growth_measure_flag,
rit_reading_min,
rit_reading_max,
test_start_time,
percent_correct,
projected_proficiency,
goal_rit_scrore_8,
goal_adj_8,
goal_name_8,
goal_rit_score_9,
goal_adj_9,
goal_name_9
)
values
 (1                          -- row_num,
  ,'034351'                 -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Language Survey w/ Goals WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,1                         -- test_rit_score
  ,2                         -- test_std_err
  ,3                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,4                         -- lexiile_score
  ,5                         -- goal_rit_score1
  ,'A1'              -- goal_adjective1
  ,'Goal 1 name'              -- goal_name1
  ,7,
  'A2'
  ,'Goal 2 name'
  ,8
  ,'A3'
  ,'Goal 3 name'
  ,9,
  'A4'
  ,'Goal 4 name'
  ,10
  ,'A5'
  ,'Goal 5 name'
  ,11
  ,'A6'
  ,'Goal 6 name'
  ,12
  ,'A7'
  ,'Goal 7 name'
  ,13
  ,14
 ,'M'
 ,15
 ,'True'
 ,16
 ,16
 ,'10:01:02'
 ,17
 ,18
 ,19
 ,'A8'
 ,'Goal 8 name'
 ,20
 ,'A9'
 ,'Goal 9 name')
  , (2                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Math Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Msth'                    -- test_type_name
  ,20                         -- test_rit_score
  ,21                         -- test_std_err
  ,22                         -- test_percentil      
  ,'05/12/2010'              -- test_start_date
  ,23                         -- lexiile_score
  ,24                         -- goal_rit_score1
  ,'B!'              -- goal_adjective1
  ,'Goal 1B name'              -- goal_name1
  ,25
  ,'B2'
  ,'Goal 2B name'
  ,26
  ,'B3'
  ,'Goal 3B name'
  ,27,
  'B4'
  ,'Goal 4B name'
  ,28
  ,'B5'
  ,'Goal 5B name'
  ,29
  ,'B6'
  ,'Goal 6B name'
  ,30
  ,'B7'
  ,'Goal 7B name'
  ,31
  ,32
 ,'M'
 ,33
 ,'False'
 ,34
 ,35
 ,'10:02:03'
 ,36
 ,37
 ,38
 ,'A8'
 ,'Goal 8B name'
 ,39
 ,'A9'
 ,'Goal 9B name')
  , (3                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'NWEA Algebra I V2'  -- test_name
  ,'Math'                    -- test_type_name
  ,40                         -- test_rit_score
  ,41                         -- test_std_err
  ,42                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,43                         -- lexiile_score
  ,44                         -- goal_rit_score1
  ,'C!'              -- goal_adjective1
  ,'Goal 1C name'              -- goal_name1
  ,45,
  'C2'
  ,'Goal 2C name'
  ,46
  ,'C3'
  ,'Goal 3C name'
  ,47,
  'C4'
  ,'Goal 4C name'
  ,48
  ,'C5'
  ,'Goal 5C name'
  ,49
  ,'C6'
  ,'Goal 6C name'
  ,50
  ,'C7'
  ,'Goal 7C name'
  ,51
  ,52
 ,'M'
 ,53
 ,'True'
 ,54
 ,55
 ,'10:02:03'
 ,56
 ,57
 ,58
 ,'A8'
 ,'Goal 8C name'
 ,59
 ,'A9'
 ,'Goal 9C name')
  , (4                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Math (Combined Tests-all Goals)'  -- test_name
  ,'Math'                    -- test_type_name
  ,60                         -- test_rit_score
  ,61                         -- test_std_err
  ,62                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,63                         -- lexiile_score
  ,64                         -- goal_rit_score1
  ,'D!'              -- goal_adjective1
  ,'Goal 1D name'              -- goal_name1
  ,65,
  'D2'
  ,'Goal 2D name'
  ,66
  ,'D3'
  ,'Goal 3D name'
  ,67,
  'D4'
  ,'Goal 4D name'
  ,68
  ,'D5'
  ,'Goal 5D name'
  ,69
  ,'D6'
  ,'Goal 6D name'
  ,70
  ,'D7'
  ,'Goal 7D name'
  ,71
  ,72
 ,'M'
 ,73
 ,'False'
 ,74
 ,75
 ,'10:02:03'
 ,76
 ,77
 ,78
 ,'A8'
 ,'Goal 8D name'
 ,79
 ,'A9'
 ,'Goal 9D name')
  , (5                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Primary Grades Reading (Combined Tests-all Goals)'  -- test_name
  ,'Reading'                    -- test_type_name
  ,80                         -- test_rit_score
  ,81                         -- test_std_err
  ,82                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,83                         -- lexiile_score
  ,84                         -- goal_rit_score1
  ,'E!'              -- goal_adjective1
  ,'Goal 1E name'              -- goal_name1
  ,85,
  'E2'
  ,'Goal 2E name'
  ,86
  ,'E3'
  ,'Goal 3E name'
  ,87,
  'E4'
  ,'Goal 4E name'
  ,88
  ,'E5'
  ,'Goal 5E name'
  ,89
  ,'E6'
  ,'Goal 6E name'
  ,90
  ,'E7'
  ,'Goal 7E name'
  ,91
  ,92
 ,'M'
 ,93
 ,'True'
 ,94
 ,95
 ,'10:02:03'
 ,96
 ,97
 ,98
 ,'A8'
 ,'Goal 8E name'
 ,99
 ,'A9'
 ,'Goal 9E name')
  , (6                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,06                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'Reading Survey w/ Goals 2-5 WY V4'  -- test_name
  ,'Reading'                    -- test_type_name
  ,101                         -- test_rit_score
  ,102                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,104                         -- lexiile_score
  ,105                         -- goal_rit_score1
  ,'F!'              -- goal_adjective1
  ,'Goal 1F name'              -- goal_name1
  ,106,
  'F2'
  ,'Goal 2F name'
  ,107
  ,'F3'
  ,'Goal 3F name'
  ,108,
  'F4'
  ,'Goal 4F name'
  ,109
  ,'F5'
  ,'Goal 5F name'
  ,110
  ,'F6'
  ,'Goal 6F name'
  ,111
  ,'F7'
  ,'Goal 7F name'
  ,112
  ,113
 ,'M'
 ,114
 ,'False'
 ,115
 ,116
 ,'10:02:03'
 ,117
 ,118
 ,119
 ,'A8'
 ,'Goal 8F name'
 ,120
 ,'A9'
 ,'Goal 9F name')
  , (7                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science Part 1 of 2 - Concepts/Processes V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,121                         -- test_rit_score
  ,122                         -- test_std_err
  ,98                         -- test_percentil      
  ,'05/11/2010'              -- test_start_date
  ,124                         -- lexiile_score
  ,125                         -- goal_rit_score1
  ,'G!'              -- goal_adjective1
  ,'Goal 1G name'              -- goal_name1
  ,126,
  'G2'
  ,'Goal 2G name'
  ,127
  ,'G3'
  ,'Goal 3G name'
  ,128,
  'G4'
  ,'Goal 4G name'
  ,129
  ,'G5'
  ,'Goal 5G name'
  ,130
  ,'G6'
  ,'Goal 6G name'
  ,131
  ,'G7'
  ,'Goal 7G name'
  ,132
  ,133
 ,'M'
 ,134
 ,'True'
 ,135
 ,136
 ,'10:02:03'
 ,137
 ,138
 ,139
 ,'A8'
 ,'Goal 8G name'
 ,140
 ,'A9'
 ,'Goal 9G name')
  , (8                          -- row_num,
  ,'034351'                  -- student_id
  ,'Haynes, Jack'            -- student_name
  ,05                        -- grade
  ,'Winter 2011'               -- term_name
  ,'measurement-sn'  -- measurement_scale_name
  ,'WY Science General Science V2'  -- test_name
  ,'Science'                    -- test_type_name
  ,2                         -- test_rit_score
  ,3                         -- test_std_err
  ,4                         -- test_percentil      
  ,'05/13/2010'              -- test_start_date
  ,5                         -- lexiile_score
  ,6                         -- goal_rit_score1
  ,'H!'              -- goal_adjective1
  ,'Goal 1H name'              -- goal_name1
  ,7,
  'H2'
  ,'Goal 2H name'
  ,8
  ,'H3'
  ,'Goal 3H name'
  ,9,
  'H4'
  ,'Goal 4H name'
  ,10
  ,'H5'
  ,'Goal 5H name'
  ,11
  ,'H6'
  ,'Goal 6H name'
  ,12
  ,'H7'
  ,'Goal 7H name'
  ,13
  ,14
 ,'M'
 ,15
 ,'False'
 ,16
 ,17
 ,'10:02:03'
 ,18
 ,19
 ,20
 ,'A8'
 ,'Goal 8H name'
 ,21
 ,'A9'
 ,'Goal 9H name');

