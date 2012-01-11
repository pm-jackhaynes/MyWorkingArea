use mn_wayzata;

-- use mn_wayzata;

/*

MyISAM table 'rpt_bbcard_detail_nwea' is in use (most likely by a MERGE table). Try FLUSH TABLES.
Bug #9687	merge table does not always release/closes tables from union if dropped 
It appears that once the web application accesses the cogat report table, it doesn't release it.
*/

delimiter //
drop procedure if exists etl_rpt_bbcard_detail_nwea  //
create definer=`dbadmin`@`localhost` procedure etl_rpt_bbcard_detail_nwea ()

contains sql
sql security invoker

comment '$Rev: $Date: 2011-12-20 etl_rpt_bbcard_detail_nwea $'


proc: begin

/*
      Change History
            
            Date        Programmer           Description
            ----------  -------------------  -----------------------------------------------------
            12/20/2011  J. Haynes            New script

*/

    declare v_ods_table varchar(64);
    declare v_ods_view varchar(64);
    declare v_view_exists tinyint(1);
    declare v_bb_group_id int(11);
    declare v_backfill_needed smallint(6);
    declare v_date_format_mask varchar(15) default '%m/%d/%Y';  -- Dates will come in as mm/dd/yyyy
    declare v_grade_unassigned_id  int(10);
    declare v_school_unassigned_id  int(10);

    call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);

    set v_ods_table = 'pmi_ods_nwea';
    set v_ods_view = concat('v_', v_ods_table);

    select  count(*)
    into    v_view_exists
    from    information_schema.views t
    where   t.table_schema = database()
    and     t.table_name = v_ods_view;

    if v_view_exists > 0 then

        select  bb_group_id
        into    v_bb_group_id
        from    pm_bbcard_group
        where   bb_group_code = 'nwea-rit'
        ;
        
        select  grade_level_id
        into    v_grade_unassigned_id
        from    c_grade_level
        where   grade_code = 'unassigned'
        ;
        
        select school_id
        into    v_school_unassigned_id 
        from    c_school
        where   school_code = 'unassigned'
        ;
        
        select '*** Group Code to be processed:', cast(v_bb_group_id as char) from dual;
        
        set @nwea_date_format_mask := pmi_f_get_etl_setting('nweaDateFormatMask');
    
        if @nwea_date_format_mask is not null then
            set v_date_format_mask = @nwea_date_format_mask;
        end if;
        
        select '*** Format Mask to be processed:', v_date_format_mask from dual;

        
        drop table if exists `tmp_stu_admin`;
        drop table if exists `tmp_date_conversion`;
        drop table if exists `tmp_student_year_backfill`;
        
          create table `tmp_stu_admin` (
          `student_code` varchar(15) NOT NULL,
          `row_num` int(10) NOT NULL,
          `test_name` varchar(75) default null,
          `student_id` int(10) NOT NULL,
          `school_year_id` smallint(4) NOT NULL,
          `grade_code` varchar(15) default null,
          `grade_id` int(10) default null,
          `school_code` varchar(15) default null,
          `backfill_needed_flag` tinyint(1),
          primary key (`student_id`, `test_name`, `grade_code`, `school_year_id`)
        ) engine=innodb default charset=latin1
        ;
        
        create table `tmp_date_conversion` (
          `test_start_date` varchar(20) NOT NULL
         ,`school_year_id` int unsigned,
         primary key (`test_start_date`),
          key (`school_year_id`)
        ) engine=innodb default charset=latin1
        ;
        
        create table `tmp_student_year_backfill` (
           `ods_row_num` int(10) not null,
           `student_id` int(10) not null,
           `school_year_id` smallint(4) not null,
           `grade_level_id` int(10) null,
           `school_id` int(10) null,
           primary key  (`ods_row_num`),
           unique key `uq_tmp_student_year_backfill` (`student_id`, `school_year_id`)
         ) engine=innodb default charset=latin1
         ;

        --
        --  To expedite processing, we will determine the unique dates the tests were taken 
        --  and the current school year for those dates.
        --
        
        insert tmp_date_conversion (
            test_start_date
        )
        select distinct 
            test_start_date
        from v_pmi_ods_nwea ods;

        update tmp_date_conversion tdc
        join c_school_year sy
           on str_to_date(tdc.test_start_date, v_date_format_mask) between sy.begin_date and sy.end_date
        set tdc.school_year_id = sy.school_year_id;

        --  Get the student data and determine if backloading of Student Year information is needed.
        --  We will also get the current school year information for the date the test was
        --  administered. This year infomration will be used to generate the new report data.

        insert  tmp_stu_admin (
                row_num
               ,student_id
               ,test_name
               ,student_code
               ,school_year_id
               ,grade_code
               ,grade_id
               ,school_code
               ,backfill_needed_flag
        )
        select  ods.row_num
               ,s.student_id
               ,ods.test_name
               ,ods.student_id
               ,tdc.school_year_id
               ,coalesce(gl.grade_code, 'unassigned')
               ,coalesce(gl.grade_level_id, 1000015)
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_nwea as ods
        join    tmp_date_conversion tdc
                on ods.test_start_date = tdc.test_start_date
        join    c_student as s
                on    s.student_state_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        left join c_grade_level as gl
                on sty.grade_level_id  = gl.grade_level_id
        where   ods.student_id is not null
        union all
        select  ods.row_num
               ,s.student_id
               ,ods.test_name
               ,ods.student_id
               ,tdc.school_year_id
               ,coalesce(gl.grade_code, 'unassigned')
               ,coalesce(gl.grade_level_id, 1000015)
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_nwea as ods
        join    tmp_date_conversion tdc
                on ods.test_start_date = tdc.test_start_date
        join    c_student as s
                on    s.fid_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        left join c_grade_level as gl
                on sty.grade_level_id  = gl.grade_level_id
        where   ods.student_id is not null
        union all
        select  ods.row_num
               ,s.student_id
               ,ods.test_name
               ,ods.student_id
               ,tdc.school_year_id
               ,coalesce(gl.grade_code, 'unassigned')
               ,coalesce(gl.grade_level_id, 1000015)
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_nwea as ods
        join    tmp_date_conversion tdc
                on ods.test_start_date = tdc.test_start_date
        join    c_student as s
                on    s.student_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        left join c_grade_level as gl
                on sty.grade_level_id  = gl.grade_level_id
        where   ods.student_id is not null
        on duplicate key update row_num = values(row_num)
        ;        
        -- Now ascertain our internal grade_id based on customers grade code and if possible the school's code
        -- Note: Because school code would be very difficult to ascertain based on the incomming data file, 
        --       we have opted to flag the new student year row with an unassigned school id.
        
        update tmp_stu_admin sadmin
        left join v_pmi_xref_grade_level as gxref
                on sadmin.grade_code = gxref.client_grade_code
        left join c_grade_level as grd
                on gxref.pmi_grade_code = grd.grade_code
        set sadmin.grade_id = coalesce(grd.grade_level_id, v_grade_unassigned_id)
        ;

        -- #########################################
        -- Backfill for c_student_year 
        -- Need to detect and load c_student_year 
        -- records when supporting ones that don't exist
        -- ##############################################

        select count(*)
        into v_backfill_needed
        from tmp_stu_admin
        where backfill_needed_flag = 1
        ;

        if v_backfill_needed > 0 then

            insert tmp_student_year_backfill (
                   ods_row_num
                  ,student_id
                  ,school_year_id
                  ,grade_level_id
                  ,school_id
            )
            select   sadmin.row_num
                    ,sadmin.student_id
                    ,sadmin.school_year_id
                    ,sadmin.grade_id
                    ,v_school_unassigned_id
            from tmp_stu_admin as sadmin
            where sadmin.backfill_needed_flag = 1
            on duplicate key update grade_level_id = values(grade_level_id)
                ,school_id = values(school_id)
            ;

            -- ##########################################
            -- proc developed to standardize loading c_student_year. 
            -- This proc reads the tmp_student_year_backfill table and loads
            -- c_student_year with these rows.
            -- ############################################

            call etl_hst_load_backfill_stu_year();

        end if;

        -- Incoming report data will be incremental in nature so we only want to add/update report records
        
        insert rpt_bbcard_detail_nwea (
            bb_group_id
            ,bb_measure_id
            ,bb_measure_item_id
            ,student_id
            ,school_year_id
            ,score
            ,score_type
            ,score_color
            ,last_user_id
            ,create_timestamp
        )
        select  m.bb_group_id
            ,m.bb_measure_id
            ,mi.bb_measure_item_id
            ,s.student_id
            ,tdc.school_year_id  -- Is the current school year for the date the test was taken
            ,max(case 
                 when ods.term_name like 'Fall%' then 
                    case
                         when ods.test_name like '%Primary%Reading%' then
                            case
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonAwareGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonAwareGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonicsGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonicsGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'conceptOfPrintGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'conceptOfPrintGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'vocAndWordStructGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'vocAndWordStructGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'comprehensionGoalRITScore5Fall'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'comprehensionGoalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'writingGoalRITScore6Fall'  then ods.goal_rit_score6 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'writingGoalAdj6Fall'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min   
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max    
                                when m.bb_measure_code = 'primaryReading'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Primary%Math%' then
                            case
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score    
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'probSolveGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'probSolveGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'nbrSenseGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'nbrSenseGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'compGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'compGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'measureAndGeometryGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'measureAndGeometryGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'statAndProbGoalRITScore5Fall'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'statAndProbGoalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'algebraGoalRITScore6Fall'  then ods.goal_rit_score6 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'algebraGoalAdj6Fall'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min   
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'equatAndInequalityGoalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryMath'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                        when ods.test_name like '%Language%Survey%' then
                           case
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntApplyWritSkillGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntApplyWritgSkillGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntUseConventionGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntUseConventionGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpressiveGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpressiveGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpositoryGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpositoryGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRitScore5Fall'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalIRITScore6Fall'  then ods.goal_rit_score6
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalIRITAdj6Fall'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRITScore7Fall'  then ods.goal_rit_score7 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRITAdj7Fall'  then ods.goal_adjective7 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max  -- Not Foud
                                when m.bb_measure_code = 'langSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Math%Survey%' then
                            case
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'nbrConceptOperationGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'nbrConceptOperationGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'geoGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'geoGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'measurementGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'measurementGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'algebraGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'algebraGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'dataAnalProbGoalRITScore5Fall'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'dataAnalProbGoalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'mathSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%NWEA Algebra%' then
                            case
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score    
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'nbrSensePropAndGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'nbrSensePropAndGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'compAndEstWithGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'compAndEstWithGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'patFunctGraphGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'patFunctGraphGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'expressionGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'expressionGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'equatAndInequalityGoalRITScore5Fall'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'equatAndInequalityGoalAdj5Fall'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'nweaAlgebra'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Reading%Survey%' then
                            case
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'decodeVocabGoallRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'decodeVocabGoallAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'comprehensionGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'comprehensionGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'undersstandInterLitGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'undersstandInterLitGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'understandInfoTextsGoalRITScore4Fall'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'understandInfoTextsGoalAdj4Fall'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'readingSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Science%Concepts%' then 
                            case
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'scienceInqGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'scienceInqGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'natureUnityConceptGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'natureUnityConceptGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'scienceProcessConcepts'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Science%General Science%' then
                            case
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testRITScoreFall'  then ods.test_rit_score 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testStdErrorFall'  then ods.test_std_err 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testPercentileFall'  then ods.test_percentile 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingScoreFall'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'lifeScienceGoalRITScore1Fall'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'lifeScienceGoalAdj1Fall'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'earthSpaceScienceGoalRITScore2Fall'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'earthSpaceScienceGoalAdj2Fall'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'phyScienceGoalRITScore3Fall'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'phyScienceGoalAdj3Fall'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingMinFall'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingMaxFall'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'scienceGeneralScience'  and mi.bb_measure_item_code = 'growtMeasureYNFall'  then ods.growth_measure_flag                               
                            end
                    end
                 when ods.term_name like 'Spring%' then 
                    case
                         when ods.test_name like '%Primary%Reading%' then
                            case
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score    
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonAwareGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonAwareGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonicsGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'phonicsGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'conceptOfPrintGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'conceptOfPrintGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'vocAndWordStructGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'vocAndWordStructGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'comprehensionGoalRITScore5Spg'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'comprehensionGoalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'writingGoalRITScore6Spg'  then ods.goal_rit_score6 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'writingGoalAdj6Spg'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min   
                                when m.bb_measure_code = 'primaryReading' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max    
                                when m.bb_measure_code = 'primaryReading'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Primary%Math%' then
                            case
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score    
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'probSolveGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'probSolveGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'nbrSenseGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'nbrSenseGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'compGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'compGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'measureAndGeometryGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'measureAndGeometryGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'statAndProbGoalRITScore5Spg'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'statAndProbGoalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'algebraGoalRITScore6Spg'  then ods.goal_rit_score6 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'algebraGoalAdj6Spg'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min   
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'primaryMath' and mi.bb_measure_item_code = 'equatAndInequalityGoalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'primaryMath'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                        when ods.test_name like '%Language%Survey%' then  -- 'Language Survey w/ Goals WY V4'
                           case
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntApplyWritSkillGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntApplyWritgSkillGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntUseConventionGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntUseConventionGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpressiveGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpressiveGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpositoryGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'stdntWriteExpositoryGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRitScore5Spg'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalIRITScore6Spg'  then ods.goal_rit_score6
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalIRITAdj6Spg'  then ods.goal_adjective6 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRITScore7Spg'  then ods.goal_rit_score7 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'goalRITAdj7Spg'  then ods.goal_adjective7 
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'langSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max  -- Not Foud
                                when m.bb_measure_code = 'langSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Math%Survey%' then
                            case
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'nbrConceptOperationGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'nbrConceptOperationGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'geoGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'geoGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'measurementGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'measurementGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'algebraGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'algebraGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'dataAnalProbGoalRITScore5Spg'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'mathSurveyWGoals' and mi.bb_measure_item_code = 'dataAnalProbGoalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'mathSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%NWEA Algebra%' then
                            case
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score    
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'nbrSensePropAndGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'nbrSensePropAndGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'compAndEstWithGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'compAndEstWithGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'patFunctGraphGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'patFunctGraphGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'expressionGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'expressionGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'equatAndInequalityGoalRITScore5Spg'  then ods.goal_rit_score5 
                                when m.bb_measure_code = 'nweaAlgebra' and mi.bb_measure_item_code = 'equatAndInequalityGoalAdj5Spg'  then ods.goal_adjective5 
                                when m.bb_measure_code = 'nweaAlgebra'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Reading%Survey%' then
                            case
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'decodeVocabGoallRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'decodeVocabGoallAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'comprehensionGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'comprehensionGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'undersstandInterLitGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'undersstandInterLitGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'understandInfoTextsGoalRITScore4Spg'  then ods.goal_rit_score4 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'understandInfoTextsGoalAdj4Spg'  then ods.goal_adjective4 
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'readingSurveyWGoals' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'readingSurveyWGoals'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Science%Concepts%' then 
                            case
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'scienceInqGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'scienceInqGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'natureUnityConceptGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'natureUnityConceptGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'scienceProcessConcepts' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max   
                                when m.bb_measure_code = 'scienceProcessConcepts'  and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                         when ods.test_name like '%Science%General Science%' then
                            case
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testRITScoreSpg'  then ods.test_rit_score 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testStdErrorSpg'  then ods.test_std_err 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'testPercentileSpg'  then ods.test_percentile 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingScoreSpg'  then ods.rit_reading_score   
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'lifeScienceGoalRITScore1Spg'  then ods.goal_rit_score1
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'lifeScienceGoalAdj1Spg'  then ods.goal_adjective1 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'earthSpaceScienceGoalRITScore2Spg'  then ods.goal_rit_score2 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'earthSpaceScienceGoalAdj2Spg'  then ods.goal_adjective2 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'phyScienceGoalRITScore3Spg'  then ods.goal_rit_score3 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'phyScienceGoalAdj3Spg'  then ods.goal_adjective3 
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingMinSpg'  then ods.rit_reading_min  
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'ritToReadingMaxSpg'  then ods.rit_reading_max
                                when m.bb_measure_code = 'scienceGeneralScience' and mi.bb_measure_item_code = 'growtMeasureYNSpg'  then ods.growth_measure_flag                               
                            end
                    end
             end) as score
            ,'a'
            , NULL  -- Don't know color yet
            ,1234
            ,now()
        from    v_pmi_ods_nwea as ods
        join    tmp_date_conversion tdc
                on ods.test_start_date = tdc.test_start_date
        join    tmp_stu_admin sadmin
                on ods.row_num = sadmin.row_num
        join    c_student as s
                on      s.student_code = ods.student_id
        join    pm_bbcard_measure as m
                on      m.bb_group_id = v_bb_group_id
        join    pm_bbcard_measure_item as mi
                on      m.bb_group_id = mi.bb_group_id
                   and  m.bb_measure_id = mi.bb_measure_id
        group by m.bb_group_id
            ,m.bb_measure_id
            ,mi.bb_measure_item_id
            ,s.student_id
            ,tdc.school_year_id
        having score is not null
        on duplicate key update score = values(score)
            ,score_type = values(score_type)
            ,score_color = values(score_color)
            ,last_user_id = values(last_user_id)
            ,last_edit_timestamp = values(last_edit_timestamp)
        ;
        
        update rpt_bbcard_detail_nwea as rpt
        join pm_bbcard_measure_item mi
                on   rpt.bb_group_id = mi.bb_group_id
                 and rpt.bb_measure_id = mi.bb_measure_id
                 and rpt.bb_measure_item_id = mi.bb_measure_item_id and mi.bb_measure_item_code like 'growtMeasureYN%'
        set rpt.score_color = CASE rpt.score
                 when 'True'  then 'Green'
                 when 'False' then 'Red'
        end;
            
        set @sql_scan_log := concat('call ', @db_name_ods, '.imp_set_upload_file_status (\'', v_ods_table, '\', \'P\', \'ETL Load Successful\')');

        prepare sql_scan_log from @sql_scan_log;
        execute sql_scan_log;
        deallocate prepare sql_scan_log;
        /*
        drop table if exists `tmp_stu_admin`;
        drop table if exists `tmp_date_conversion`;
        drop table if exists `tmp_student_year_backfill`;
        */
        
    end if;

end proc
//


call etl_rpt_bbcard_detail_nwea ()
//
