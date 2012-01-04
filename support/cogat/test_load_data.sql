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

call cogat_11_23_2011_add_to_master_db();


-- Stanine

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 1, 0, 4, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Stan%';

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 2, 4, 6, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Stan%';

     
Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 3, 6, 9, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Stan%';

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 4, 9, 10, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Stan%';


-- Standard Age

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 1, 0, 89, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Age%' and mi.Bb_Measure_Item_Code not like '%Stan%' and mi.Bb_Measure_Item_Code not like '%PctRank%';

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 2, 89, 113, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Age%' and mi.Bb_Measure_Item_Code not like '%Stan%' and mi.Bb_Measure_Item_Code not like '%PctRank%';
     
Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 3, 113, 125, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Age%' and mi.Bb_Measure_Item_Code not like '%Stan%' and mi.Bb_Measure_Item_Code not like '%PctRank%';


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 4, 125, 999, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%Age%' and mi.Bb_Measure_Item_Code not like '%Stan%' and mi.Bb_Measure_Item_Code not like '%PctRank%';

-- Percentile Rank


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 1, 0, 26, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%PctRank%';

Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 2, 26, 75, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%PctRank%';
     
Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 3, 75, 125, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%PctRank%';


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 4, 125, 999, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
where g.bb_group_code = 'cogAT' and mi.Bb_Measure_Item_Code like '%PctRank%';


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 1, 0, 26, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
Where G.Bb_Group_Code = 'cogAT' And Mi.Bb_Measure_Item_Code Like '%GradePct%';


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 2, 26, 75, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
Where G.Bb_Group_Code = 'cogAT' And Mi.Bb_Measure_Item_Code Like '%GradePct%';

     
Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 3, 75, 126, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
Where G.Bb_Group_Code = 'cogAT' And Mi.Bb_Measure_Item_Code Like '%GradePct%';


Insert Into `pm_color_cogat` (
  `bb_group_id`,
  `bb_measure_id`,
  `bb_measure_item_id`,
  `begin_year`,
  `end_year`,
  `color_id`,
  `min_Score`,
  `max_score`,
  `last_user_id`,
  `create_Timestamp`,
  `last_Edit_Timestamp`
)  
Select mi.bb_group_id, mi.bb_measure_id, mi.bb_measure_item_id, 2010, 9999, 4, 126, 999, 1234, now(), now()
From Pm_Bbcard_Group G 
     Join Pm_Bbcard_Measure M On G.Bb_Group_Id = m.bb_group_id
     Join Pm_Bbcard_Measure_Item Mi On M.Bb_Measure_Id = Mi.Bb_Measure_Id 
Where G.Bb_Group_Code = 'cogAT' And Mi.Bb_Measure_Item_Code Like '%GradePct%';
