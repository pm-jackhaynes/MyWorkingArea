        -- Query to recreate the cogat color table
            
            
            use md_hcps;
            
            truncate md_hcps_ods.pmi_ods_color_cogat;
            insert into md_hcps_ods.pmi_ods_color_cogat
                       (row_num
                       ,measure_code
                       ,measure_item_code
                       ,begin_year
                       ,end_year
                       ,min_score
                       ,max_score
                       ,color_name
                       )
                       SELECT   1
                               ,m.bb_measure_code
                               ,mi.bb_measure_item_code
                               ,cg.begin_year
                               ,cg.end_year
                               ,cg.min_score
                               ,cg.max_score
                               ,c.moniker     
                        FROM pm_color_cogat cg
                        JOIN  pm_bbcard_measure m
                          ON    cg.bb_measure_id = m.bb_measure_id
                        JOIN pm_bbcard_measure_item mi 
                          ON m.bb_measure_id = mi.bb_measure_id
                         and cg.bb_measure_item_id = mi.bb_measure_item_id
                        JOIN  pm_bbcard_group g
                          ON  g.bb_group_id = m.bb_group_id
                          and g.bb_group_code = 'cogAT' 
                        JOIN  pmi_color c
                          ON    c.color_id = cg.color_id
                        order by m.bb_measure_id
                                ,mi.bb_measure_item_id
                                ,cg.min_score;
                                
                select * from pm_color_cogat
                order by bb_measure_id, bb_measure_item_id, color_id;



delimiter ;

-- Proc calls

-- call cogat_11_23_2011_add_to_master_db();

use fl_flagler;

truncate table pm_bbcard_color_pmrn;

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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 1, 0, 15, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 2, 15, 84, 1234, now(), now()
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
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 1000015, 3, 84, 9999, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'pmrn' and m.Bb_Measure_Code =  'wordAnalysisAbility';

*/



/* 


        Verifying that colors took!

*/

update rpt_bbcard_detail_pmrn
set score_color = null;


        update rpt_bbcard_detail_pmrn as rpt
        join pm_bbcard_color_pmrn as c
                on   rpt.bb_group_id = c.bb_group_id
                 and rpt.bb_measure_id = c.bb_measure_id
                 and rpt.bb_measure_item_id = c.bb_measure_item_id 
                 and rpt.score between c.min_score and c.max_score
        join pmi_color as pmic
               on c.color_id = pmic.color_id
        set score_color = pmic.moniker;

select * from  rpt_bbcard_detail_pmrn where student_id = 127738061 limit 100;

call fl_flagler.etl_pm_bbcard_measure_select();

select distinct m.bb_measure_code, m.moniker, m.bb_measure_id 
from pm_bbcard_measure m join pm_bbcard_measure_item mi on m.bb_measure_id = mi.bb_measure_id
where m.bb_group_id = 1000015;

select * from pm_bbcard_group;