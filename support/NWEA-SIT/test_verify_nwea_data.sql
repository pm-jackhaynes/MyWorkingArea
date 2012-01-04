use wy_sub1s_ods;

select 'MAX Group ID is: ', max(bb_group_id), ' and MUST be equal to or larger than: ', pmi_admin.pmi_f_get_next_sequence('pm_bbcard_group', 1)
from pm_bbcard_group;

select 'MAX Group ID is: ', max(swatch_id), ' and MUST be equal to or larger than: ', pmi_admin.pmi_f_get_next_sequence('c_color_swatch', 1) 
from c_color_swatch;

select * from pm_bbcard_group;
select * from pm_bbcard_measure where bb_group_id = 1000023;
select * from pm_bbcard_measure_item where bb_group_id = 1000023
order by bb_measure_id, sort_order;

select * from c_color_swatch;
select * from c_color_swatch_list;

select count(*) from rpt_bbcard_detail_cogat;  

/* ************************************************************************************************* 

Refresh the selection critieria so that you can see the menu options available in the baseball
card menu.


************************************************************************************************* */

call wy_sub1.etl_pm_bbcard_measure_select();

/* *************************************************************************************************

SQL to verify that you are creating the correct rows in the rpt_bbcard_detail Table

************************************************************************************************* */
          
select * from rpt_bbcard_detail_cogat 
where student_id = 127747191 limit 100;

select s.last_name, s.first_name, rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, rpt.bb_measure_item_id, m.bb_measure_code, mi.bb_measure_item_code, rpt.score, rpt.score_color
from rpt_bbcard_detail_cogat rpt
join c_student s on rpt.student_id = s.student_id and s.student_id = 127747191
join pm_bbcard_measure m on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id
join pm_bbcard_measure_item mi on rpt.bb_group_id = m.bb_group_id and rpt.bb_measure_id = m.bb_measure_id and rpt.bb_measure_item_id = mi.bb_measure_item_id
order by rpt.student_id, rpt.bb_group_id, rpt.bb_measure_id, rpt.bb_measure_item_id;

create table pmi_ods_cogat_jack as select * from pmi_ods_cogat;
select count(*) from pmi_ods_cogat_jack;

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
Select * from wy_sub1_ods.pmi_ods_cogat;
        

/*  ****************************************************************************************************************************************************************

      Restore pmi_ods_nwea using your backup pmi_ods_nwea_jack table
      
 *  ************************************************************************************************************************************************************** */

truncate wy_sub1_ods.pmi_ods_nwea;
insert into wy_sub1_ods.pmi_ods_nwea (
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
lexile_max
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
Lexile_Max
From  wy_sub1_ods.pmi_ods_nwea_jack;

/*  ****************************************************************************************************************************************************************

      Truncate pmi_ods_nwea and load your test data
      
 *  ************************************************************************************************************************************************************** */

truncate wy_sub1_ods.pmi_ods_nwea;
insert into wy_sub1_ods.pmi_ods_nwea (
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
lexile_max
)
values
 (1                          -- row_num,
  ,370905181                 -- student_id
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
  ,14)
  , (2                          -- row_num,
  ,370905181                  -- student_id
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
  ,32)
  , (3                          -- row_num,
  ,370905181                  -- student_id
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
  ,52)
  , (4                          -- row_num,
  ,370905181                  -- student_id
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
  ,72)
  , (5                          -- row_num,
  ,370905181                  -- student_id
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
  ,92)
  , (6                          -- row_num,
  ,370905181                  -- student_id
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
  ,14)
  , (7                          -- row_num,
  ,370905181                  -- student_id
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
  ,133)
  , (8                          -- row_num,
  ,370905181                  -- student_id
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
  ,14);
