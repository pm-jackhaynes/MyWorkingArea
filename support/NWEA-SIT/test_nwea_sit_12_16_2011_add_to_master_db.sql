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
        
                -- WINTER
                ,('nwea', 'langSurveyWGoals', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingScoreWin', 'RIT to Reading Score - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Win', 'Students Apply Writing Skills: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Win', 'Students Apply Writing Skills: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Win', 'Students Use Conventions: Goal RIT Score 2 - Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Win', 'Students Use Conventions: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Win', 'Students Write: Expressive: Goal RIT Score 3 - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Win', 'Students Write: Expressive: Goal Adjective 3 - Winter', 210, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalRITScore4Win', 'Students Write: Expository: Goal RIT Score 4 - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Win', 'Students Write: Expository: Goal Adjective 4 - Winter', 212, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRitScore5Win', 'Goal RIT Score 5 - Winter', 213, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalAdj5Win', 'Goal Adjective 5 - Winter', 214, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITScore6Win', 'Goal IRIT Score 6 - Winter', 215, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITAdj6Win', 'Goal Adjective 6 - Winter', 216, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITScore7Win', 'Goal RIT Score 7 - Winter', 217, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITAdj7Win', 'Goal Adjective 7 - Winter', 218, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 219, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 220, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'growtMeasureYNWin', 'Growth Measure - Winter', 221, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Win', 'Number Concepts & Operations: Goal RIT Score 1 - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Win', 'Number Concepts & Operations: Goal Adjective 1 - Winter', 205, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalRITScore2Win', 'Geometry: Goal RIT Score 2 - Winter', 206, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalAdj2Win', 'Geometry: Goal RIT Adjective 2 - Winter', 207, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalRITScore3Win', 'Measurement: Goal RIT Score 3 - Winter', 208, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalAdj3Win', 'Measurement: Goal Adjective 3 - Winter', 209, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalRITScore4Win', 'Algebra: Goal RIT Score 4 - Winter', 210, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalAdj4Win', 'Algebra: Goal Adjective 4 - Winter', 211, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Win', 'Data Analysis & Probability: Goal RIT Score 5 - Winter', 212, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Win', 'Data Analysis & Probability: Goal Adjective 5 - Winter', 213, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea', 'mathSurveyWGoals', 'growtMeasureYNWin', 'Growth Measure - Winter', 213, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testPercentileWin', 'Test Percentile - Winter',203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'ritToReadingScoreWin', 'RIT to Reading Score 5 - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Win', 'Number Sense / Properties: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Win', 'Number Sense / Properties: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Win', 'Computation & Estimation with: Goal RIT Score 2 - Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalAdj2Win', 'Computation & Estimation with: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Win', 'Patterns / Functions / Graph: Goal RIT Score 3 - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalAdj3Win', 'Patterns / Functions / Graph: Goal Adjective 3 - Winter', 210, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalRITScore4Win', 'Expressions: Goal RIT Score 4 - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalAdj4Win', 'Expressions: Goal Adjective 4 - Winter', 212, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Win', 'Equations & Inequalities: Goal RIT Score 5 - Winter', 213, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Win', 'Equations & Inequalities: Goal Adjective 5 - Winter', 214, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'growtMeasureYNWin', 'Growth Measure - Winter', 215, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingScoreWin', 'RIT to Reading Score - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalRITScore1Win', 'Problem Solving: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalAdj1Win', 'Problem Solving: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalRITScore2Win', 'Number Sense: Goal RIT Score 2 - Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalAdj2Win', 'Number Sense: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalRITScore3Win', 'Computation: Goal RIT Score 3 - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalAdj3Win', 'Computation: Goal Adjective 3 - Winter', 210, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalRITScore4Win', 'Measurement & Geometry: Goal RIT Score 4 - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalAdj4Win', 'Measurement & Geometry: Goal Adjective 4 - Winter', 212, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalRITScore5Win', 'Statistics & Probability: Goal RIT Score 5 - Winter', 213, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalAdj5Win', 'Statistics & Probability: Goal Adjective 5 - Winter', 214, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalRITScore6Win', 'Algebra: Goal RIT Score 6 - Winter', 215, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalAdj6Win', 'Algebra: Goal Adjective 6 - Winter', 216, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 217, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 218, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'growtMeasureYNWin', 'Growth Measure - Winter', 220, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingScoreWin', 'RIT to Reading Score - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalRITScore1Win', 'Phonological Awareness: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalAdj1Win', 'Phonological Awareness: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalRITScore2Win', 'Phonics: Goal RIT Score 2 - Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalAdj2Win', 'Phonics: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalRITScore3Win', 'Concepts of Print: Goal RIT Score 3 - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalAdj3Win', 'Concepts of Print: Goal Adjective 3 - Winter', 210, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalRITScore4Win', 'Vocabulary & Word Structure: Goal RIT Score 4 - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalAdj4Win', 'Vocabulary & Word Structure: Goal Adjective 4 - Winter', 212, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalRITScore5Win', 'Comprehension: Goal RIT Score 4 - Winter', 213, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalAdj5Win', 'Comprehension: Goal Adjective 4 - Winter', 214, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalRITScore6Win', 'Writing: Goal RIT Score 6 - Winter', 215, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalAdj6Win', 'Writing: Goal Adjective 6 - Winter', 216, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 217, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 218, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'growtMeasureYNWin', 'Growth Measure - Winter', 219, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingScoreWin', 'RIT to Reading Score - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Win', 'Decode / Vocab: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Win', 'Decode / Vocab: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Win', 'Comprehension: Goal RIT Score 2 - Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalAdj2Win', 'Comprehension: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Win', 'Understand / Interpret Lit: Goal RIT Score 3 - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Win', 'Understand / Interpret Lit: Goal Adjective 3 - Winter', 210, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Win', 'Understanding Inform Texts: Goal RIT Score 4 - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Win', 'Understanding Inform Texts: Goal Adjective 4 - Winter', 212, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 213, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 214, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea', 'readingSurveyWGoals', 'growtMeasureYNWin', 'Growth Measure - Winter', 215, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingScoreWin', 'RIT to Reading Score - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Win', 'Science as Inquiry: Goal RIT Score 1 - Winter', 205, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalAdj1Win', 'Science as Inquiry: Goal Adjective 1 - Winter', 206, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Win', 'Nature & Uniify Concepts: Goal RIT Score 2- Winter', 207, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Win', 'Nature & Uniify Concepts: Goal Adjective 2 - Winter', 208, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 209, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 210, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea', 'scienceProcessConcepts', 'growtMeasureYNWin', 'Growth Measure - Winter', 211, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testRITScoreWin', 'Test RIT Score - Winter', 201, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testStdErrorWin', 'Test Std Error - Winter', 202, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testPercentileWin', 'Test Percentile - Winter', 203, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Win', 'Life Science: Goal RIT Score 1 - Winter', 204, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalAdj1Win', 'Science as Inquiry: Goal RIT Score 1 - Winter', 205, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Win', 'Earth & Space Science: Goal RIT Score 2 - Winter', 206, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Win', 'Earth & Space Science: Goal RIT Score 2 - Winter', 207, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalRITScore3Win', 'Physical Science: Goal RIT Score 3 - Winter', 208, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalAdj3Win', 'Physical Science: Goal Adjective 3 - Winter', 209, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMinWin', 'RIT to Reading Min - Winter', 210, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMaxWin', 'RIT to Reading Max - Winter', 211, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'growtMeasureYNWin', 'Growth Measure - Winter', 212, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
        
                -- SUMMER
                ,('nwea', 'langSurveyWGoals', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingScoreSum', 'RIT to Reading Score - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritSkillGoalRITScore1Sum', 'Students Apply Writing Skills: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntApplyWritgSkillGoalAdj1Sum', 'Students Apply Writing Skills: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalRITScore2Sum', 'Students Use Conventions: Goal RIT Score 2 - Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntUseConventionGoalAdj2Sum', 'Students Use Conventions: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalRITScore3Sum', 'Students Write: Expressive: Goal RIT Score 3 - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpressiveGoalAdj3Sum', 'Students Write: Expressive: Goal Adjective 3 - Summer', 310, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalRITScore4Sum', 'Students Write: Expository: Goal RIT Score 4 - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'stdntWriteExpositoryGoalAdj4Sum', 'Students Write: Expository: Goal Adjective 4 - Summer', 312, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRitScore5Sum', 'Goal RIT Score 5 - Summer', 313, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalAdj5Sum', 'Goal Adjective 5 - Summer', 314, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITScore6Sum', 'Goal IRIT Score 6 - Summer', 315, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalIRITAdj6Sum', 'Goal Adjective 6 - Summer', 316, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITScore7Sum', 'Goal RIT Score 7 - Summer', 317, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'goalRITAdj7Sum', 'Goal Adjective 7 - Summer', 318, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 319, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 320, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'langSurveyWGoals', 'growtMeasureYNSum', 'Growth Measure - Summer', 321, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalRITScore1Sum', 'Number Concepts & Operations: Goal RIT Score 1 - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'nbrConceptOperationGoalAdj1Sum', 'Number Concepts & Operations: Goal Adjective 1 - Summer', 305, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalRITScore2Sum', 'Geometry: Goal RIT Score 2 - Summer', 306, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'geoGoalAdj2Sum', 'Geometry: Goal RIT Adjective 2 - Summer', 307, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalRITScore3Sum', 'Measurement: Goal RIT Score 3 - Summer', 308, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'measurementGoalAdj3Sum', 'Measurement: Goal Adjective 3 - Summer', 309, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalRITScore4Sum', 'Algebra: Goal RIT Score 4 - Summer', 310, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'algebraGoalAdj4Sum', 'Algebra: Goal Adjective 4 - Summer', 311, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalRITScore5Sum', 'Data Analysis & Probability: Goal RIT Score 5 - Summer', 312, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'mathSurveyWGoals', 'dataAnalProbGoalAdj5Sum', 'Data Analysis & Probability: Goal Adjective 5 - Summer', 313, NULL, 'a', 1, 0, 1234, now() )              
                ,('nwea', 'mathSurveyWGoals', 'growtMeasureYNSum', 'Growth Measure - Summer', 313, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'testPercentileSum', 'Test Percentile - Summer',303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'ritToReadingScoreSum', 'RIT to Reading Score 5 - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalRITScore1Sum', 'Number Sense / Properties: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'nbrSensePropAndGoalAdj1Sum', 'Number Sense / Properties: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalRITScore2Sum', 'Computation & Estimation with: Goal RIT Score 2 - Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'compAndEstWithGoalAdj2Sum', 'Computation & Estimation with: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalRITScore3Sum', 'Patterns / Functions / Graph: Goal RIT Score 3 - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'patFunctGraphGoalAdj3Sum', 'Patterns / Functions / Graph: Goal Adjective 3 - Summer', 310, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalRITScore4Sum', 'Expressions: Goal RIT Score 4 - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'expressionGoalAdj4Sum', 'Expressions: Goal Adjective 4 - Summer', 312, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalRITScore5Sum', 'Equations & Inequalities: Goal RIT Score 5 - Summer', 313, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'equatAndInequalityGoalAdj5Sum', 'Equations & Inequalities: Goal Adjective 5 - Summer', 314, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'nweaAlgebra', 'growtMeasureYNSum', 'Growth Measure - Summer', 315, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingScoreSum', 'RIT to Reading Score - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalRITScore1Sum', 'Problem Solving: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'probSolveGoalAdj1Sum', 'Problem Solving: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalRITScore2Sum', 'Number Sense: Goal RIT Score 2 - Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'nbrSenseGoalAdj2Sum', 'Number Sense: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalRITScore3Sum', 'Computation: Goal RIT Score 3 - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'compGoalAdj3Sum', 'Computation: Goal Adjective 3 - Summer', 310, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalRITScore4Sum', 'Measurement & Geometry: Goal RIT Score 4 - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'measureAndGeometryGoalAdj4Sum', 'Measurement & Geometry: Goal Adjective 4 - Summer', 312, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalRITScore5Sum', 'Statistics & Probability: Goal RIT Score 5 - Summer', 313, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'statAndProbGoalAdj5Sum', 'Statistics & Probability: Goal Adjective 5 - Summer', 314, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalRITScore6Sum', 'Algebra: Goal RIT Score 6 - Summer', 315, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'algebraGoalAdj6Sum', 'Algebra: Goal Adjective 6 - Summer', 316, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 317, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 318, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryMath', 'growtMeasureYNSum', 'Growth Measure - Summer', 320, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingScoreSum', 'RIT to Reading Score - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalRITScore1Sum', 'Phonological Awareness: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonAwareGoalAdj1Sum', 'Phonological Awareness: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalRITScore2Sum', 'Phonics: Goal RIT Score 2 - Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'phonicsGoalAdj2Sum', 'Phonics: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalRITScore3Sum', 'Concepts of Print: Goal RIT Score 3 - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'conceptOfPrintGoalAdj3Sum', 'Concepts of Print: Goal Adjective 3 - Summer', 310, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalRITScore4Sum', 'Vocabulary & Word Structure: Goal RIT Score 4 - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'vocAndWordStructGoalAdj4Sum', 'Vocabulary & Word Structure: Goal Adjective 4 - Summer', 312, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalRITScore5Sum', 'Comprehension: Goal RIT Score 4 - Summer', 313, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'comprehensionGoalAdj5Sum', 'Comprehension: Goal Adjective 4 - Summer', 314, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalRITScore6Sum', 'Writing: Goal RIT Score 6 - Summer', 315, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'writingGoalAdj6Sum', 'Writing: Goal Adjective 6 - Summer', 316, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 317, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 318, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'primaryReading', 'growtMeasureYNSum', 'Growth Measure - Summer', 319, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingScoreSum', 'RIT to Reading Score - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallRITScore1Sum', 'Decode / Vocab: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'decodeVocabGoallAdj1Sum', 'Decode / Vocab: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalRITScore2Sum', 'Comprehension: Goal RIT Score 2 - Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'comprehensionGoalAdj2Sum', 'Comprehension: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalRITScore3Sum', 'Understand / Interpret Lit: Goal RIT Score 3 - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'undersstandInterLitGoalAdj3Sum', 'Understand / Interpret Lit: Goal Adjective 3 - Summer', 310, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalRITScore4Sum', 'Understanding Inform Texts: Goal RIT Score 4 - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'understandInfoTextsGoalAdj4Sum', 'Understanding Inform Texts: Goal Adjective 4 - Summer', 312, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 313, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'readingSurveyWGoals', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 314, NULL, 'n', 1, 0, 1234, now() )               
                ,('nwea', 'readingSurveyWGoals', 'growtMeasureYNSum', 'Growth Measure - Summer', 315, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingScoreSum', 'RIT to Reading Score - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalRITScore1Sum', 'Science as Inquiry: Goal RIT Score 1 - Summer', 305, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'scienceInqGoalAdj1Sum', 'Science as Inquiry: Goal Adjective 1 - Summer', 306, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalRITScore2Sum', 'Nature & Uniify Concepts: Goal RIT Score 2- Summer', 307, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'natureUnityConceptGoalAdj2Sum', 'Nature & Uniify Concepts: Goal Adjective 2 - Summer', 308, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 309, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceProcessConcepts', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 310, NULL, 'n', 1, 0, 1234, now() )                
                ,('nwea', 'scienceProcessConcepts', 'growtMeasureYNSum', 'Growth Measure - Summer', 311, 'pmiRedGreen', 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testRITScoreSum', 'Test RIT Score - Summer', 301, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testStdErrorSum', 'Test Std Error - Summer', 302, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'testPercentileSum', 'Test Percentile - Summer', 303, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalRITScore1Sum', 'Life Science: Goal RIT Score 1 - Summer', 304, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'lifeScienceGoalAdj1Sum', 'Science as Inquiry: Goal RIT Score 1 - Summer', 305, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalRITScore2Sum', 'Earth & Space Science: Goal RIT Score 2 - Summer', 306, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'earthSpaceScienceGoalAdj2Sum', 'Earth & Space Science: Goal RIT Score 2 - Summer', 307, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalRITScore3Sum', 'Physical Science: Goal RIT Score 3 - Summer', 308, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'phyScienceGoalAdj3Sum', 'Physical Science: Goal Adjective 3 - Summer', 309, NULL, 'a', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMinSum', 'RIT to Reading Min - Summer', 310, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'ritToReadingMaxSum', 'RIT to Reading Max - Summer', 311, NULL, 'n', 1, 0, 1234, now() )
                ,('nwea', 'scienceGeneralScience', 'growtMeasureYNSum', 'Growth Measure - Summer', 312, 'pmiRedGreen', 'a', 1, 0, 1234, now() )        
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