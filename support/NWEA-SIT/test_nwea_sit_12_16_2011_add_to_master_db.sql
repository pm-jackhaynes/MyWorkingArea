use wy_sub1;

/*

    Before you edit for production:

        Uncomment the state_id column in the color_swatch insert
        Uncomment the drop tables at the end of the proc
        Change the database from md_hcps to pmi_data
        
    SQL for Testing:
    
        select * from tmp_id_assign;
        select * from tmp_pm_bbcard_group;
        select * from pm_bbcard_group;
        select * from pm_bbcard_measure where bb_group_id = 1000025;
        select * from pm_bbcard_measure_item where bb_group_id = 1000025
           order by bb_measure_id, sort_order;
        select * from pm_bbcard_measure_item 
           where bb_group_id = 1000025 and score_sort_type_code = 'n' and bb_measure_item_code  not like '%Adj%';
        select * from c_color_swatch;
        select * from c_color_swatch_list;

        -- delete from c_color_swatch where swatch_id in (1000022, 1000023, 1000024);
        -- delete from pm_bbcard_group where bb_group_id in (1000024);
        -- delete from pm_bbcard_measure where bb_group_id = 1000024;
        -- delete from pm_bbcard_measure_item where bb_group_id = 1000024;
*/

delimiter //
drop procedure if exists nwea_12_16_2011_add_to_master_db  //
create definer=`dbadmin`@`localhost` procedure nwea_12_16_2011_add_to_master_db ()

contains sql
sql security invoker
comment '$Rev $Date: 2011-12-16 nwea_12_16_2011_add_to_master_db $'

proc: begin

/*
      Change History
            
            Date        Programmer           Description
            12/16/2011  J. Haynes            New Script

*/

    if database() = 'wy_sub1' then
    
        call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);
    
        drop table if exists `tmp_id_assign`;
        drop table if exists `tmp_id_assign_bb_meas`;
        drop table if exists `tmp_id_assign_bb_meas_item`;
        drop table if exists `tmp_pm_bbcard_group`;
        drop table if exists `tmp_pm_bbcard_measure`;
        drop table if exists `tmp_pm_bbcard_measure_item`;
        
        -- New ID's tables
        create table `tmp_id_assign` (
          `new_id` int(11) not null,
          `base_code` varchar(50) not null,
          primary key  (`new_id`),
          unique key `uq_tmp_id_assign` (`base_code`)
        ) engine=innodb default charset=latin1
        ;
        create table `tmp_id_assign_bb_meas` (
          `bb_group_id` int(11) not null,
          `new_id` int(11) not null,
          `base_code` varchar(50) not null,
          primary key  (`bb_group_id`,`new_id`),
          unique key `uq_tmp_id_assign_bb_meas` (`bb_group_id`,`base_code`)
        ) engine=innodb default charset=latin1
        ;
        create table `tmp_id_assign_bb_meas_item` (
          `bb_group_id` int(11) NOT NULL,
          `bb_measure_id` int(11) NOT NULL,
          `new_id` int(11) not null,
          `base_code` varchar(50) not null,
          primary key  (`bb_group_id`,`bb_measure_id`,`new_id`),
          unique key `uq_tmp_id_assign_bb_meas_item` (`bb_group_id`,`bb_measure_id`,`base_code`)
        );

        CREATE TABLE `tmp_pm_bbcard_group` (
          `bb_group_code` varchar(20) NOT NULL,
          `moniker` varchar(50) NOT NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `active_flag` tinyint(1) NOT NULL default '1',
          `last_user_id` int(10) NOT NULL,
          `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
          `last_edit_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
          UNIQUE KEY `uq_tmp_pm_bbcard_group` (`bb_group_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;
        CREATE TABLE `tmp_pm_bbcard_measure` (
          `bb_group_code` varchar(20) NOT NULL,
          `bb_measure_code` varchar(40) NOT NULL,
          `moniker` varchar(75) NOT NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `swatch_code` varchar(25) default NULL,
          `active_flag` tinyint(1) NOT NULL default '1',
--          `state_id` int(10) NOT NULL,
          `dynamic_creation_flag` tinyint(1) NOT NULL default '0',
          `last_user_id` int(10) NOT NULL,
          `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
          `last_edit_timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
          UNIQUE KEY `uq_tmp_pm_bbcard_measure` (`bb_group_code`,`bb_measure_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;
        CREATE TABLE `tmp_pm_bbcard_measure_item` (
          `bb_group_code` varchar(20) NOT NULL,
          `bb_measure_code` varchar(40) NOT NULL,
          `bb_measure_item_code` varchar(40) NOT NULL,
          `moniker` varchar(120) NOT NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `swatch_code` varchar(25) default NULL,
          `score_sort_type_code` enum('a','m','n') NOT NULL,
          `active_flag` tinyint(1) NOT NULL default '1',
          `dynamic_creation_flag` tinyint(1) NOT NULL default '0',
          `last_user_id` int(11) NOT NULL,
          `create_timestamp` datetime NOT NULL default '1980-12-31 00:00:00',
          UNIQUE KEY `uq_tmp_pm_bbcard_measure_item` (`bb_group_code`,`bb_measure_code`,`bb_measure_item_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;

       -- We will be using a standard color swatch that supports False: Red, True: Green so the following
       -- color swatch logic will most likey be eliminated.
          
        /*

        CREATE TABLE `tmp_c_color_swatch` (
          `swatch_code` varchar(25) default NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `active_flag` tinyint(1) NOT NULL default '1',
          `state_id` int(10) NOT NULL,
          `last_user_id` int(10) NOT NULL,
          UNIQUE KEY `uq_tmp_c_color_swatch` (`swatch_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;
        */
        
       
        --  Create the level 1 items that will appear on the Selection Menu
        --  supporting the clients baseball card reporting.
             
        select  max(sort_order) + 1
        into    @sort_order
        from    pm_bbcard_group
        ;
       
        insert tmp_pm_bbcard_group (
            bb_group_code
            ,moniker
            ,sort_order
            ,active_flag
            ,last_user_id
            ,create_timestamp
        )

        values('nwea-rit','NWEA', @sort_order, 1, 1234, now())
        on duplicate key update sort_order = values(sort_order)
            ,moniker = values(moniker)
            ,sort_order = values(sort_order)
            ,active_flag = values(active_flag)
        ;

        -- Obtain a new id only for records that are not already in the target table.
        
        insert  tmp_id_assign (new_id, base_code)
        select  pmi_admin.pmi_f_get_next_sequence('pm_bbcard_group', 1), src.bb_group_code
        from    tmp_pm_bbcard_group as src
        left join   pm_bbcard_group as tar
                on      src.bb_group_code = tar.bb_group_code
        where   tar.bb_group_id is null
        ;
        


        insert pm_bbcard_group (
            bb_group_id
            ,bb_group_code
            ,moniker
            ,sort_order
            ,active_flag
            ,last_user_id
            ,create_timestamp
        )
        
        select  coalesce(tmpid.new_id, tar.bb_group_id)
            ,src.bb_group_code
            ,src.moniker
            ,src.sort_order
            ,src.active_flag
            ,src.last_user_id
            ,src.create_timestamp
            
        from    tmp_pm_bbcard_group as src
        left join   tmp_id_assign as tmpid
                on      src.bb_group_code = tmpid.base_code
        left join  pm_bbcard_group as tar
                on      src.bb_group_code = tar.bb_group_code
        on duplicate key update sort_order = values(sort_order)
            ,active_flag = values(active_flag)
            ,last_user_id = values(last_user_id)
        ;

       -- We will be using a standard color swatch that supports False: Red, True: Green so the following
       -- color swatch logic will most likey be eliminated.
          
        /*
        insert tmp_c_color_swatch (
            swatch_code
            ,sort_order
            ,active_flag
            ,state_id
            ,last_user_id
        )
        
        values ('nwea-rit', 0, 1, 0, 1234)
        ;

        select count(*) 
        into   @swatch_count
        from   C_Color_Swatch 
        where swatch_code = 'nwea-rit';
        
        IF @swatch_count = 0 THEN
            select  pmi_admin.pmi_f_get_next_sequence('c_color_swatch', 1) 
            into    @color_swatch_id
            from    dual;
        else 
            select  swatch_id
            into    @color_swatch_id
            from   C_Color_Swatch 
            where swatch_code = 'nwea-rit';
        end if; 

        select  max(swatch_id) from c_color_swatch
            into    @max_color_swatch_id;

        insert  tmp_id_assign (new_id, base_code)
        select  @color_swatch_id, src.swatch_code
        from    tmp_c_color_swatch as src
        left join   c_color_swatch as tar
                on      src.swatch_code = tar.swatch_code
        where   tar.swatch_id is null
        ;

        insert c_color_swatch (
            swatch_id
            ,swatch_code
            ,sort_order
            ,active_flag
            -- ,state_id
            ,last_user_id
            ,create_timestamp
        )

        select  coalesce(tmpid.new_id, tar.swatch_id)
            ,src.swatch_code
            ,src.sort_order
            ,src.active_flag
            -- ,0
            ,1234
            ,now()
            
        from    tmp_c_color_swatch as src
        left join   tmp_id_assign as tmpid
                on      src.swatch_code = tmpid.base_code
        left join   c_color_swatch as tar
                on      src.swatch_code = tar.swatch_code
        on duplicate key update sort_order = values(sort_order)
            ,active_flag = values(active_flag)
            ,last_user_id = values(last_user_id)
        ;

       -- Create a color swatch list. This is the AVAILABLE list of colors
       -- one can use for the report. Currently, there is only two colors that are 
       -- needed. The child either advanced or didn't advance.
            
        insert c_color_swatch_list (
            swatch_id,
            client_id,
            color_id,
            sort_order,
            last_user_id    
           ) values
           (     @color_swatch_id, @client_id, 1, 1, 1234)  -- red
               ,(@color_swatch_id, @client_id, 3, 3, 1234)  -- green
        on duplicate key update sort_order = values(sort_order)
            ,last_user_id = values(last_user_id)
        ;
        
        */

       -- Create the level 2 items that will appear on the Selection Menu
       -- supporting the clients baseball card reporting.

       -- By default, we will make the measures active and with dynamic creation set to false.
       -- color_id is not set at the measure level because we want to control colors at the
       -- measeure item level.
       
        insert tmp_pm_bbcard_measure (
            bb_group_code
            ,bb_measure_code
            ,moniker
            ,sort_order
            ,swatch_code
            ,active_flag
            ,dynamic_creation_flag
            ,last_user_id
            ,create_timestamp
        )

        values  ('nwea-rit', 'langSurveyWGoals', 'Language Survey With Goals', 1, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'mathSurveyWGoals', 'Math Survey With Goals', 2, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'nweaAlgebra', 'NWEA Algebra', 3, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'primaryMath', 'Primary - Math', 4, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'primaryReading', 'Primary - Reading', 5, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'readingSurveyWGoals', 'Reading Survey With Goals', 6, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'scienceProcessConcepts', 'Science - Concepts / Processes', 7, NULL, 1, 0, 1234, now())
               ,('nwea-rit', 'scienceGeneralScience', 'Science - General Science', 8, NULL, 1, 0, 1234, now())
        ;


        -- Assign Measure Ids to the new measures

        insert  tmp_id_assign_bb_meas (bb_group_id, new_id, base_code)
        select  bbg.bb_group_id, pmi_admin.pmi_f_get_next_sequence('pm_bbcard_measure', 1), src.bb_measure_code
        from    tmp_pm_bbcard_measure as src
        join    pm_bbcard_group as bbg
                on      src.bb_group_code = bbg.bb_group_code
        left join   pm_bbcard_measure as tar
                on      bbg.bb_group_id = tar.bb_group_id
                and     src.bb_measure_code = tar.bb_measure_code
        where   tar.bb_measure_id is null
        ;

        insert pm_bbcard_measure (
            bb_group_id
            ,bb_measure_id
            ,bb_measure_code
            ,moniker
            ,sort_order
            ,swatch_id
            ,active_flag
            ,dynamic_creation_flag
            ,last_user_id
            ,create_timestamp
        ) 
        
        select  bbg.bb_group_id
            ,coalesce(tmpid.new_id, tar.bb_measure_id)
            ,src.bb_measure_code
            ,src.moniker
            ,src.sort_order
            ,cs.swatch_id
            ,src.active_flag
            ,src.dynamic_creation_flag
            ,src.last_user_id
            ,src.create_timestamp
            
        from    tmp_pm_bbcard_measure as src
        join    pm_bbcard_group as bbg
                on      src.bb_group_code = bbg.bb_group_code
        left join   c_color_swatch as cs
                on      src.swatch_code = cs.swatch_code
        left join   tmp_id_assign_bb_meas as tmpid
                on      bbg.bb_group_id = tmpid.bb_group_id
                and     src.bb_measure_code = tmpid.base_code
        left join   pm_bbcard_measure as tar
                on      bbg.bb_group_id = tar.bb_group_id
                and     src.bb_measure_code = tar.bb_measure_code
        on duplicate key update moniker = values(moniker)
            ,sort_order = values(sort_order)
            ,swatch_id = values(swatch_id)
            ,active_flag = values(active_flag)
            ,dynamic_creation_flag = values(dynamic_creation_flag)
            ,last_user_id = values(last_user_id)
        ;

       -- Create the level 3 items that will appear on the Selection Menu
       -- supporting the clients baseball card reporting.

        select  bb_group_id
        into    @bb_group_id
        from    pm_bbcard_group
        where   bb_group_code = 'nwea-rit'
        ;

        -- color_id is set at this level. We will only provide colors for the Met/Not Met Column which is only about 8 columns.
        -- We do not know what color swatch will be used so TRUE: Green FALSE: Red so for now it is null.

        insert tmp_pm_bbcard_measure_item (
             bb_group_code
            ,bb_measure_code
            ,bb_measure_item_code
            ,moniker
            ,sort_order
            ,swatch_code
            ,score_sort_type_code
            ,active_flag
            ,dynamic_creation_flag
            ,last_user_id
            ,create_timestamp
        ) 
        values
        
                -- FALL 
                 ('nwea-rit', 'langSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Fall', 'Students Apply Writing Skills: Goal RIT Score 1 - Fall', 5, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Fall', 'Students Apply Writing Skills: Goal Adjective 1 - Fall', 6, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Fall', 'Students Use Conventions: Goal RIT Score 2 - Fall', 7, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Fall', 'Students Use Conventions: Goal Adjective 2 - Fall', 8, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Fall', 'Students Write: Expressive: Goal RIT Score 3 - Fall', 9, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Fall', 'Students Write: Expressive: Goal Adjective 3 - Fall', 10, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWrite fExpositoryGoalRITScore4Fall', 'Students Write: Expository: Goal RIT Score 4 - Fall', 11, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Fall', 'Students Write: Expository: Goal Adjective 4 - Fall', 12, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRitScore5Fall', 'Goal RIT Score 5 - Fall', 13, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalAdj5Fall', 'Goal Adjective 5 - Fall', 14, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalIRITScore6Fall', 'Goal IRIT Score 6 - Fall', 15, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalIRITAdj6Fall', 'Goal Adjective 6 - Fall', 16, NULL,'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRITScore7Fall', 'Goal RIT Score 7 - Fall', 17, NULL,'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRITAdj7Fall', 'Goal Adjective 7 - Fall', 18, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 19, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 20, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Fall', 'Number Concepts & Operations: Goal RIT Score 1 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Fall', 'Number Concepts & Operations: Goal Adjective 1 - Fall', 5, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'geoGoalRITScore2Fall', 'Geometry: Goal RIT Score 2 - Fall', 6, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'geoGoalAdj2Fall', 'Geometry: Goal RIT Adjective 2 - Fall', 7, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'measurementGoalRITScore3Fall', 'Measurement: Goal RIT Score 3 - Fall', 8, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'measurementGoalAdj3Fall', 'Measurement: Goal Adjective 3 - Fall', 9, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'algebraGoalRITScore4Fall', 'Algebra: Goal RIT Score 4 - Fall', 10, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'algebraGoalAdj4Fall', 'Algebra: Goal Adjective 4 - Fall', 11, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Fall', 'Data Analysis & Probability: Goal RIT Score 5 - Fall', 12, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Fall', 'Data Analysis & Probability: Goal Adjective 5 - Fall', 13, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea-rit', 'nweaAlgebra', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'testPercentileFall', 'Test Percentile - Fall',3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'ritToReadingScoreFall', 'RIT to Reading Score 5 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Fall', 'Number Sense / Properties: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Fall', 'Number Sense / Properties: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Fall', 'Computation & Estimation with: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'compAndEstWithGoalAdj2Fall', 'Computation & Estimation with: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Fall', 'Patterns / Functions / Graph: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'patFunctGraphGoalAdj3Fall', 'Patterns / Functions / Graph: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'expressionGoalRITScore4Fall', 'Expressions: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'expressionGoalAdj4Fall', 'Expressions: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Fall', 'Equations & Inequalities: Goal RIT Score 5 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Fall', 'Equations & Inequalities: Goal Adjective 5 - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'probSolveGoalRITScore1Fall', 'Problem Solving: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'probSolveGoalAdj1Fall', 'Problem Solving: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'nbrSenseGoalRITScore2Fall', 'Number Sense: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'nbrSenseGoalAdj2Fall', 'Number Sense: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'compGoalRITScore3Fall', 'Computation: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'compGoalAdj3Fall', 'Computation: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'measureAndGeometryGoalRITScore4Fall', 'Measurement & Geometry: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'measureAndGeometryGoalAdj4Fall', 'Measurement & Geometry: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'statAndProbGoalRITScore5Fall', 'Statistics & Probability: Goal RIT Score 5 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'statAndProbGoalAdj5Fall', 'Statistics & Probability: Goal Adjective 5 - Fall - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'algebraGoalRITScore6Fall', 'Algebra: Goal RIT Score 6 - Fall', 15, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'algebraGoalAdj6Fall', 'Algebra: Goal Adjective 6 - Fall', 16, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 17, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 18, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea-rit', 'primaryReading', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonAwareGoalRITScore1Fall', 'Phonological Awareness: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonAwareGoalAdj1Fall', 'Phonological Awareness: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonicsGoalRITScore2Fall', 'Phonics: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonicsGoalAdj2Fall', 'Phonics: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'conceptOfPrintGoalRITScore3Fall', 'Concepts of Print: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'conceptOfPrintGoalAdj3Fall', 'Concepts of Print: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'vocAndWordStructGoalRITScore4Fall', 'Vocabulary & Word Structure: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'vocAndWordStructGoalAdj4Fall', 'Vocabulary & Word Structure: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'comprehensionGoalRITScore5Fall', 'Comprehension: Goal RIT Score 4 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'comprehensionGoalAdj5Fall', 'Comprehension: Goal Adjective 4 - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'writingGoalRITScore6Fall', 'Writing: Goal RIT Score 6 - Fall', 15, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'writingGoalAdj6Fall', 'Writing: Goal Adjective 6 - Fall', 16, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 17, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 18, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Fall', 'Decode / Vocab: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Fall', 'Decode / Vocab: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Fall', 'Comprehension: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'comprehensionGoalAdj2Fall', 'Comprehension: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Fall', 'Understand / Interpret Lit: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Fall', 'Understand / Interpret Lit: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Fall', 'Understanding Inform Texts: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Fall', 'Understanding Inform Texts: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 14, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea-rit', 'scienceProcessConcepts', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Fall', 'Science as Inquiry: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'scienceInqGoalAdj1Fall', 'Science as Inquiry: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Fall', 'Nature & Uniify Concepts: Goal RIT Score 2- Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Fall', 'Nature & Uniify Concepts: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 10, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea-rit', 'scienceGeneralScience', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Fall', 'Life Science: Goal RIT Score 1 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'lifeScienceGoalAdj1Fall', 'Science as Inquiry: Goal RIT Score 1 - Fall', 5, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Fall', 'Earth & Space Science: Goal RIT Score 2 - Fall', 6, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Fall', 'Earth & Space Science: Goal RIT Score 2 - Fall', 7, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'phyScienceGoalRITScore3Fall', 'Physical Science: Goal RIT Score 3 - Fall', 8, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'phyScienceGoalAdj3Fall', 'Physical Science: Goal Adjective 3 - Fall', 9, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 10, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
        
                -- SPRING
                ,('nwea-rit', 'langSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Spg', 'Students Apply Writing Skills: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Spg', 'Students Apply Writing Skills: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Spg', 'Students Use Conventions: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Spg', 'Students Use Conventions: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Spg', 'Students Write: Expressive: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Spg', 'Students Write: Expressive: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpositoryGoalRITScore4Spg', 'Students Write: Expository: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Spg', 'Students Write: Expository: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRitScore5Spg', 'Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalAdj5Spg', 'Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalIRITScore6Spg', 'Goal IRIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalIRITAdj6Spg', 'Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRITScore7Spg', 'Goal RIT Score 7 - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'goalRITAdj7Spg', 'Goal Adjective 7 - Spring', 118, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 119, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'langSurveyWGoals', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 120, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Spg', 'Number Concepts & Operations: Goal RIT Score 1 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Spg', 'Number Concepts & Operations: Goal Adjective 1 - Spring', 105, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'geoGoalRITScore2Spg', 'Geometry: Goal RIT Score 2 - Spring', 106, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'geoGoalAdj2Spg', 'Geometry: Goal RIT Adjective 2 - Spring', 107, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'measurementGoalRITScore3Spg', 'Measurement: Goal RIT Score 3 - Spring', 108, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'measurementGoalAdj3Spg', 'Measurement: Goal Adjective 3 - Spring', 109, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'algebraGoalRITScore4Spg', 'Algebra: Goal RIT Score 4 - Spring', 110, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'algebraGoalAdj4Spg', 'Algebra: Goal Adjective 4 - Spring', 111, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Spg', 'Data Analysis & Probability: Goal RIT Score 5 - Spring', 112, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Spg', 'Data Analysis & Probability: Goal Adjective 5 - Spring', 113, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea-rit', 'nweaAlgebra', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'testPercentileSpg', 'Test Percentile - Spring',103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'ritToReadingScoreSpg', 'RIT to Reading Score 5 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Spg', 'Number Sense / Properties: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Spg', 'Number Sense / Properties: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Spg', 'Computation & Estimation with: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'compAndEstWithGoalAdj2Spg', 'Computation & Estimation with: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Spg', 'Patterns / Functions / Graph: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'patFunctGraphGoalAdj3Spg', 'Patterns / Functions / Graph: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'expressionGoalRITScore4Spg', 'Expressions: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'expressionGoalAdj4Spg', 'Expressions: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Spg', 'Equations & Inequalities: Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Spg', 'Equations & Inequalities: Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'probSolveGoalRITScore1Spg', 'Problem Solving: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'probSolveGoalAdj1Spg', 'Problem Solving: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'nbrSenseGoalRITScore2Spg', 'Number Sense: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'nbrSenseGoalAdj2Spg', 'Number Sense: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'compGoalRITScore3Spg', 'Computation: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'compGoalAdj3Spg', 'Computation: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'measureAndGeometryGoalRITScore4Spg', 'Measurement & Geometry: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'measureAndGeometryGoalAdj4Spg', 'Measurement & Geometry: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'statAndProbGoalRITScore5Spg', 'Statistics & Probability: Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'statAndProbGoalAdj5Spg', 'Statistics & Probability: Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'algebraGoalRITScore6Spg', 'Algebra: Goal RIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'algebraGoalAdj6Spg', 'Algebra: Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryMath', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 118, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonAwareGoalRITScore1Spg', 'Phonological Awareness: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonAwareGoalAdj1Spg', 'Phonological Awareness: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonicsGoalRITScore2Spg', 'Phonics: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'phonicsGoalAdj2Spg', 'Phonics: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'conceptOfPrintGoalRITScore3Spg', 'Concepts of Print: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'conceptOfPrintGoalAdj3Spg', 'Concepts of Print: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'vocAndWordStructGoalRITScore4Spg', 'Vocabulary & Word Structure: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'vocAndWordStructGoalAdj4Spg', 'Vocabulary & Word Structure: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'comprehensionGoalRITScore5Spg', 'Comprehension: Goal RIT Score 4 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'comprehensionGoalAdj5Spg', 'Comprehension: Goal Adjective 4 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'writingGoalRITScore6Spg', 'Writing: Goal RIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'writingGoalAdj6Spg', 'Writing: Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'primaryReading', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 118, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Spg', 'Decode / Vocab: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Spg', 'Decode / Vocab: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Spg', 'Comprehension: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'comprehensionGoalAdj2Spg', 'Comprehension: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Spg', 'Understand / Interpret Lit: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Spg', 'Understand / Interpret Lit: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Spg', 'Understanding Inform Texts: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Spg', 'Understanding Inform Texts: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'readingSurveyWGoals', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 114, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea-rit', 'scienceProcessConcepts', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Spg', 'Science as Inquiry: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'scienceInqGoalAdj1Spg', 'Science as Inquiry: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Spg', 'Nature & Uniify Concepts: Goal RIT Score 2- Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Spg', 'Nature & Uniify Concepts: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceProcessConcepts', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 110, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea-rit', 'scienceGeneralScience', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Spg', 'Life Science: Goal RIT Score 1 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'lifeScienceGoalAdj1Spg', 'Science as Inquiry: Goal RIT Score 1 - Spring', 105, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Spg', 'Earth & Space Science: Goal RIT Score 2 - Spring', 106, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Spg', 'Earth & Space Science: Goal RIT Score 2 - Spring', 107, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'phyScienceGoalRITScore3Spg', 'Physical Science: Goal RIT Score 3 - Spring', 108, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'phyScienceGoalAdj3Spg', 'Physical Science: Goal Adjective 3 - Spring', 109, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 110, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea-rit', 'scienceGeneralScience', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
        ;
                
        insert tmp_id_assign_bb_meas_item ( bb_group_id, bb_measure_id, new_id, base_code)
        select  bm.bb_group_id, bm.bb_measure_id, pmi_admin.pmi_f_get_next_sequence('pm_bbcard_measure_item', 1), src.bb_measure_item_code
        from    tmp_pm_bbcard_measure_item as src
        join    pm_bbcard_group as bg
                on      src.bb_group_code = bg.bb_group_code
        join    pm_bbcard_measure as bm
                on      bg.bb_group_id = bm.bb_group_id
                and     src.bb_measure_code = bm.bb_measure_code
        ;

        insert pm_bbcard_measure_item (
            bb_group_id
            ,bb_measure_id
            ,bb_measure_item_id
            ,bb_measure_item_code
            ,moniker
            ,sort_order
            ,swatch_id
            ,score_sort_type_code
            ,active_flag
            ,last_user_id
            ,create_timestamp
        )

        select  tmpid.bb_group_id
            ,tmpid.bb_measure_id
            ,coalesce(tmpid.new_id, tar.bb_measure_item_id)
            ,src.bb_measure_item_code
            ,src.moniker
            ,src.sort_order
            ,cs.swatch_id
            ,src.score_sort_type_code
            ,src.active_flag
            ,src.last_user_id
            ,src.create_timestamp

        from    tmp_pm_bbcard_measure_item as src
        join    pm_bbcard_group as bg
                on      src.bb_group_code = bg.bb_group_code
        join    pm_bbcard_measure as bm
                on      bg.bb_group_id = bm.bb_group_id
                and     src.bb_measure_code = bm.bb_measure_code
        left join   c_color_swatch as cs
                on      src.swatch_code = cs.swatch_code
        left join   tmp_id_assign_bb_meas_item as tmpid
                on      bm.bb_group_id = tmpid.bb_group_id
                and     bm.bb_measure_id = tmpid.bb_measure_id
                and     src.bb_measure_item_code = tmpid.base_code
        left join   pm_bbcard_measure_item as tar
                on      bm.bb_group_id = tar.bb_group_id
                and     bm.bb_measure_id = tar.bb_measure_id
                and     src.bb_measure_item_code = tar.bb_measure_item_code
        on duplicate key update moniker = values(moniker)
            ,sort_order = values(sort_order)
            ,swatch_id = values(swatch_id)
            ,score_sort_type_code = values(score_sort_type_code)
            ,active_flag = values(active_flag)
            ,last_user_id = values(last_user_id)
        ;

        -- ###########
        --  Cleanup  
        -- ###########
        /*
        drop table if exists `tmp_id_assign`;
        drop table if exists `tmp_id_assign_bb_meas`;
        drop table if exists `tmp_id_assign_bb_meas_item`;
        drop table if exists `tmp_pm_bbcard_group`;
        drop table if exists `tmp_pm_bbcard_measure`;

        */

    end if;
    
end proc;
//

call nwea_12_16_2011_add_to_master_db()
//