use fl_flagler;

delimiter //

drop procedure if exists test_pmnr_2012_01_13_etl_load_prmr_color //

-- ####################################################################
-- # Insert cogat color data # 
-- ####################################################################


create definer=`dbadmin`@`localhost` procedure test_pmnr_2012_01_13_etl_load_prmr_color()
contains sql
sql security invoker
comment '$Rev $Date: 2012-01-13 test_pmnr_2012_01_13_etl_load_prmr_color $'

begin 

/*
      Change History
            
            Date        Programmer           Description
            ----------  -------------------  -----------------------------------------------------
            01/13/2012  J. Haynes            New script

*/


   truncate table pm_bbcard_color_pmrn;

   SET @cnt = 1000001;

   WHILE @cnt <= 1000014 DO
   
        /*
        
             cnt = 1000001 PK
             cnt = 1000002 KG
             cnt = 1000003 thru 14 Grade 1 thru Grade 12
             
        */
        
        -- success 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'success';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'success';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'success';
        
        
        -- kReadFluency 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadFluency';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadFluency';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadFluency';
        
        
        -- kReadAccuracy 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadAccuracy';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadAccuracy';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'kReadAccuracy';
        
        -- vocRawScore 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocRawScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocRawScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocRawScore';
        
        
        -- vocPercent 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'vocPercent';
        
        
        -- spellPercent 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'spellPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'spellPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'spellPercent';
        
        
        -- readCompPercent 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompPercent';
        
        -- readCompScale 
        
        /*
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompScale';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompScale';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompScale';
        
        */
        -- readCompAbility 
        
        /*
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompAbility';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompAbility';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompAbility';
        
        */
        -- readCompLexile 
        /*
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompLexile';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompLexile';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'readCompLexile';
        
        */
        
        -- mazePercent 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazePercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazePercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazePercent';
        
        -- mazeStandardScore 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeStandardScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeStandardScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeStandardScore';
        
        -- mazeAdjScore 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeAdjScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeAdjScore';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'mazeAdjScore';
        
        -- wordAnalysisPercent 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisPercent';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisPercent';
        
        -- wordAnalysisStandard 
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisStandard';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisStandard';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisStandard';
        
        -- wordAnalysisAbility 
        
        /*
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 1, 0, 15, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisAbility';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 2, 15, 84, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisAbility';
        
        Insert Into `pm_bbcard_color_pmrn` (
          `bb_group_id`,
          `bb_measure_id`,
          `bb_measure_item_id`,
          `grade_level_id`,
          `color_id`,
          `min_Score`,
          `max_score`,
          `last_user_id`,
          `create_Timestamp`,
          `last_Edit_Timestamp`
        )  
        Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, @cnt, 3, 84, 9999, 1234, now(), now()
        From Pm_Bbcard_Group G 
             Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
             Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
        where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisAbility';
        
        */
        
        SET @cnt = @cnt + 1;

   END WHILE;

end 
//

call test_pmnr_2012_01_13_etl_load_prmr_color()
//
