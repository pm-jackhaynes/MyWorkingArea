use mn_wayzata;

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

    if database() = 'mn_wayzata' then
    
        call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);
    
        drop table if exists `tmp_id_assign_bb_meas`;
        drop table if exists `tmp_id_assign_bb_meas_item`;
        drop table if exists `tmp_pm_bbcard_group`;
        drop table if exists `tmp_pm_bbcard_measure`;
        drop table if exists `tmp_pm_bbcard_measure_item`;
        
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

        -- nwea group code alread exists so we don't have to create one; however, we will have to create measures
        -- and measure items (level 2 and 3).

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

        values  ('nwea', 'langSurveyWGoals', 'Language Survey With Goals', 1, NULL, 1, 0, 1234, now())
               ,('nwea', 'mathSurveyWGoals', 'Math Survey With Goals', 2, NULL, 1, 0, 1234, now())
               ,('nwea', 'nweaAlgebra', 'NWEA Algebra', 3, NULL, 1, 0, 1234, now())
               ,('nwea', 'primaryMath', 'Primary - Math', 4, NULL, 1, 0, 1234, now())
               ,('nwea', 'primaryReading', 'Primary - Reading', 5, NULL, 1, 0, 1234, now())
               ,('nwea', 'readingSurveyWGoals', 'Reading Survey With Goals', 6, NULL, 1, 0, 1234, now())
               ,('nwea', 'scienceProcessConcepts', 'Science - Concepts / Processes', 7, NULL, 1, 0, 1234, now())
               ,('nwea', 'scienceGeneralScience', 'Science - General Science', 8, NULL, 1, 0, 1234, now())
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
        where   bb_group_code = 'nwea'
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
                 ('nwea', 'langSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Fall', 'Students Apply Writing Skills: Goal RIT Score 1 - Fall', 5, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Fall', 'Students Apply Writing Skills: Goal Adjective 1 - Fall', 6, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Fall', 'Students Use Conventions: Goal RIT Score 2 - Fall', 7, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Fall', 'Students Use Conventions: Goal Adjective 2 - Fall', 8, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Fall', 'Students Write: Expressive: Goal RIT Score 3 - Fall', 9, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Fall', 'Students Write: Expressive: Goal Adjective 3 - Fall', 10, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalRITScore4Fall', 'Students Write: Expository: Goal RIT Score 4 - Fall', 11, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Fall', 'Students Write: Expository: Goal Adjective 4 - Fall', 12, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRitScore5Fall', 'Goal RIT Score 5 - Fall', 13, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalAdj5Fall', 'Goal Adjective 5 - Fall', 14, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITScore6Fall', 'Goal IRIT Score 6 - Fall', 15, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITAdj6Fall', 'Goal Adjective 6 - Fall', 16, NULL,'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITScore7Fall', 'Goal RIT Score 7 - Fall', 17, NULL,'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITAdj7Fall', 'Goal Adjective 7 - Fall', 18, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 19, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 20, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'growtMeasureYNFall', 'Growth Measure - Fall', 21, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Fall', 'Number Concepts & Operations: Goal RIT Score 1 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Fall', 'Number Concepts & Operations: Goal Adjective 1 - Fall', 5, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalRITScore2Fall', 'Geometry: Goal RIT Score 2 - Fall', 6, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalAdj2Fall', 'Geometry: Goal RIT Adjective 2 - Fall', 7, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalRITScore3Fall', 'Measurement: Goal RIT Score 3 - Fall', 8, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalAdj3Fall', 'Measurement: Goal Adjective 3 - Fall', 9, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalRITScore4Fall', 'Algebra: Goal RIT Score 4 - Fall', 10, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalAdj4Fall', 'Algebra: Goal Adjective 4 - Fall', 11, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Fall', 'Data Analysis & Probability: Goal RIT Score 5 - Fall', 12, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Fall', 'Data Analysis & Probability: Goal Adjective 5 - Fall', 13, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea', 'mathSurveyWGoals', 'growtMeasureYNFall', 'Growth Measure - Fall', 14, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testPercentileFall', 'Test Percentile - Fall',3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'ritToReadingScoreFall', 'RIT to Reading Score 5 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Fall', 'Number Sense / Properties: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Fall', 'Number Sense / Properties: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Fall', 'Computation & Estimation with: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalAdj2Fall', 'Computation & Estimation with: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Fall', 'Patterns / Functions / Graph: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalAdj3Fall', 'Patterns / Functions / Graph: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalRITScore4Fall', 'Expressions: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalAdj4Fall', 'Expressions: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Fall', 'Equations & Inequalities: Goal RIT Score 5 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Fall', 'Equations & Inequalities: Goal Adjective 5 - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'growtMeasureYNFall', 'Growth Measure - Fall', 15, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalRITScore1Fall', 'Problem Solving: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalAdj1Fall', 'Problem Solving: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalRITScore2Fall', 'Number Sense: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalAdj2Fall', 'Number Sense: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalRITScore3Fall', 'Computation: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalAdj3Fall', 'Computation: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalRITScore4Fall', 'Measurement & Geometry: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalAdj4Fall', 'Measurement & Geometry: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalRITScore5Fall', 'Statistics & Probability: Goal RIT Score 5 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalAdj5Fall', 'Statistics & Probability: Goal Adjective 5 - Fall - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalRITScore6Fall', 'Algebra: Goal RIT Score 6 - Fall', 15, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalAdj6Fall', 'Algebra: Goal Adjective 6 - Fall', 16, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 17, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 18, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'growtMeasureYNFall', 'Growth Measure - Fall', 19, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea', 'primaryReading', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalRITScore1Fall', 'Phonological Awareness: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalAdj1Fall', 'Phonological Awareness: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalRITScore2Fall', 'Phonics: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalAdj2Fall', 'Phonics: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalRITScore3Fall', 'Concepts of Print: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalAdj3Fall', 'Concepts of Print: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalRITScore4Fall', 'Vocabulary & Word Structure: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalAdj4Fall', 'Vocabulary & Word Structure: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalRITScore5Fall', 'Comprehension: Goal RIT Score 4 - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalAdj5Fall', 'Comprehension: Goal Adjective 4 - Fall', 14, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalRITScore6Fall', 'Writing: Goal RIT Score 6 - Fall', 15, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalAdj6Fall', 'Writing: Goal Adjective 6 - Fall', 16, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 17, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 18, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'growtMeasureYNFall', 'Growth Measure - Fall', 19, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Fall', 'Decode / Vocab: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Fall', 'Decode / Vocab: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Fall', 'Comprehension: Goal RIT Score 2 - Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalAdj2Fall', 'Comprehension: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Fall', 'Understand / Interpret Lit: Goal RIT Score 3 - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Fall', 'Understand / Interpret Lit: Goal Adjective 3 - Fall', 10, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Fall', 'Understanding Inform Texts: Goal RIT Score 4 - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Fall', 'Understanding Inform Texts: Goal Adjective 4 - Fall', 12, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 13, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 14, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea', 'readingSurveyWGoals', 'growtMeasureYNFall', 'Growth Measure - Fall', 15, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingScoreFall', 'RIT to Reading Score - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Fall', 'Science as Inquiry: Goal RIT Score 1 - Fall', 5, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalAdj1Fall', 'Science as Inquiry: Goal Adjective 1 - Fall', 6, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Fall', 'Nature & Uniify Concepts: Goal RIT Score 2- Fall', 7, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Fall', 'Nature & Uniify Concepts: Goal Adjective 2 - Fall', 8, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 9, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 10, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea', 'scienceProcessConcepts', 'growtMeasureYNFall', 'Growth Measure - Fall', 11, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testRITScoreFall', 'Test RIT Score - Fall', 1, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testStdErrorFall', 'Test Std Error - Fall', 2, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testPercentileFall', 'Test Percentile - Fall', 3, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Fall', 'Life Science: Goal RIT Score 1 - Fall', 4, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalAdj1Fall', 'Science as Inquiry: Goal RIT Score 1 - Fall', 5, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Fall', 'Earth & Space Science: Goal RIT Score 2 - Fall', 6, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Fall', 'Earth & Space Science: Goal RIT Score 2 - Fall', 7, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalRITScore3Fall', 'Physical Science: Goal RIT Score 3 - Fall', 8, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalAdj3Fall', 'Physical Science: Goal Adjective 3 - Fall', 9, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMinFall', 'RIT to Reading Min - Fall', 10, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMaxFall', 'RIT to Reading Max - Fall', 11, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'growtMeasureYNFall', 'Growth Measure - Fall', 12, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
        
                -- SPRING
                ,('nwea', 'langSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Spg', 'Students Apply Writing Skills: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Spg', 'Students Apply Writing Skills: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Spg', 'Students Use Conventions: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Spg', 'Students Use Conventions: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Spg', 'Students Write: Expressive: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Spg', 'Students Write: Expressive: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalRITScore4Spg', 'Students Write: Expository: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Spg', 'Students Write: Expository: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRitScore5Spg', 'Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalAdj5Spg', 'Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITScore6Spg', 'Goal IRIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITAdj6Spg', 'Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITScore7Spg', 'Goal RIT Score 7 - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITAdj7Spg', 'Goal Adjective 7 - Spring', 118, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 119, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 120, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'growtMeasureYNSpg', 'Growth Measure - Spring', 121, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Spg', 'Number Concepts & Operations: Goal RIT Score 1 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Spg', 'Number Concepts & Operations: Goal Adjective 1 - Spring', 105, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalRITScore2Spg', 'Geometry: Goal RIT Score 2 - Spring', 106, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalAdj2Spg', 'Geometry: Goal RIT Adjective 2 - Spring', 107, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalRITScore3Spg', 'Measurement: Goal RIT Score 3 - Spring', 108, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalAdj3Spg', 'Measurement: Goal Adjective 3 - Spring', 109, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalRITScore4Spg', 'Algebra: Goal RIT Score 4 - Spring', 110, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalAdj4Spg', 'Algebra: Goal Adjective 4 - Spring', 111, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Spg', 'Data Analysis & Probability: Goal RIT Score 5 - Spring', 112, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Spg', 'Data Analysis & Probability: Goal Adjective 5 - Spring', 113, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea', 'mathSurveyWGoals', 'growtMeasureYNSpg', 'Growth Measure - Spring', 113, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testPercentileSpg', 'Test Percentile - Spring',103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'ritToReadingScoreSpg', 'RIT to Reading Score 5 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Spg', 'Number Sense / Properties: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Spg', 'Number Sense / Properties: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Spg', 'Computation & Estimation with: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalAdj2Spg', 'Computation & Estimation with: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Spg', 'Patterns / Functions / Graph: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalAdj3Spg', 'Patterns / Functions / Graph: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalRITScore4Spg', 'Expressions: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalAdj4Spg', 'Expressions: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Spg', 'Equations & Inequalities: Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Spg', 'Equations & Inequalities: Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'growtMeasureYNSpg', 'Growth Measure - Spring', 115, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalRITScore1Spg', 'Problem Solving: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalAdj1Spg', 'Problem Solving: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalRITScore2Spg', 'Number Sense: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalAdj2Spg', 'Number Sense: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalRITScore3Spg', 'Computation: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalAdj3Spg', 'Computation: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalRITScore4Spg', 'Measurement & Geometry: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalAdj4Spg', 'Measurement & Geometry: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalRITScore5Spg', 'Statistics & Probability: Goal RIT Score 5 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalAdj5Spg', 'Statistics & Probability: Goal Adjective 5 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalRITScore6Spg', 'Algebra: Goal RIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalAdj6Spg', 'Algebra: Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 118, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'growtMeasureYNSpg', 'Growth Measure - Spring', 120, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalRITScore1Spg', 'Phonological Awareness: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalAdj1Spg', 'Phonological Awareness: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalRITScore2Spg', 'Phonics: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalAdj2Spg', 'Phonics: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalRITScore3Spg', 'Concepts of Print: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalAdj3Spg', 'Concepts of Print: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalRITScore4Spg', 'Vocabulary & Word Structure: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalAdj4Spg', 'Vocabulary & Word Structure: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalRITScore5Spg', 'Comprehension: Goal RIT Score 4 - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalAdj5Spg', 'Comprehension: Goal Adjective 4 - Spring', 114, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalRITScore6Spg', 'Writing: Goal RIT Score 6 - Spring', 115, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalAdj6Spg', 'Writing: Goal Adjective 6 - Spring', 116, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 117, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 118, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'growtMeasureYNSpg', 'Growth Measure - Spring', 119, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Spg', 'Decode / Vocab: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Spg', 'Decode / Vocab: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Spg', 'Comprehension: Goal RIT Score 2 - Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalAdj2Spg', 'Comprehension: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Spg', 'Understand / Interpret Lit: Goal RIT Score 3 - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Spg', 'Understand / Interpret Lit: Goal Adjective 3 - Spring', 110, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Spg', 'Understanding Inform Texts: Goal RIT Score 4 - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Spg', 'Understanding Inform Texts: Goal Adjective 4 - Spring', 112, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 113, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 114, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea', 'readingSurveyWGoals', 'growtMeasureYNSpg', 'Growth Measure - Spring', 115, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingScoreSpg', 'RIT to Reading Score - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Spg', 'Science as Inquiry: Goal RIT Score 1 - Spring', 105, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalAdj1Spg', 'Science as Inquiry: Goal Adjective 1 - Spring', 106, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Spg', 'Nature & Uniify Concepts: Goal RIT Score 2- Spring', 107, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Spg', 'Nature & Uniify Concepts: Goal Adjective 2 - Spring', 108, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 109, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 110, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea', 'scienceProcessConcepts', 'growtMeasureYNSpg', 'Growth Measure - Spring', 111, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testRITScoreSpg', 'Test RIT Score - Spring', 101, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testStdErrorSpg', 'Test Std Error - Spring', 102, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testPercentileSpg', 'Test Percentile - Spring', 103, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Spg', 'Life Science: Goal RIT Score 1 - Spring', 104, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalAdj1Spg', 'Science as Inquiry: Goal RIT Score 1 - Spring', 105, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Spg', 'Earth & Space Science: Goal RIT Score 2 - Spring', 106, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Spg', 'Earth & Space Science: Goal RIT Score 2 - Spring', 107, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalRITScore3Spg', 'Physical Science: Goal RIT Score 3 - Spring', 108, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalAdj3Spg', 'Physical Science: Goal Adjective 3 - Spring', 109, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMinSpg', 'RIT to Reading Min - Spring', 110, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMaxSpg', 'RIT to Reading Max - Spring', 111, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'growtMeasureYNSpg', 'Growth Measure - Spring', 112, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
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