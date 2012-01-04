delimiter //
drop procedure if exists etl_rpt_bbcard_detail_cogat  //
create definer=`dbadmin`@`localhost` procedure etl_rpt_bbcard_detail_cogat ()

contains sql
sql security invoker

comment '$Rev: $Date: 2011-12-16 etl_rpt_bbcard_detail_cogat $'


proc: begin

/*
      Change History
            
            Date        Programmer           Description
            ----------  -------------------  -----------------------------------------------------
            12/16/2011  J. Haynes            New script

*/

    declare v_ods_table varchar(64);
    declare v_ods_view varchar(64);
    declare v_view_exists tinyint(1);
    declare v_bb_group_id int(11);
    declare v_backfill_needed smallint(6);
    declare v_date_format_mask varchar(15) default '%m%d%Y';
    declare v_grade_unassigned_id  int(10);
    declare v_school_unassigned_id  int(10);

    call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);

    set v_ods_table = 'pmi_ods_cogat';
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
        where   bb_group_code = 'cogAT'
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
        
        set @cogat_date_format_mask := pmi_f_get_etl_setting('cogatDateFormatMask');
    
        if @cogat_date_format_mask is not null then
            set v_date_format_mask = @cogat_date_format_mask;
        end if;
        
        drop table if exists `tmp_stu_admin`;
        drop table if exists `tmp_date_conversion`;
        drop table if exists `tmp_student_year_backfill`;
        drop table if exists `tmp_school`;  
        
        create table `tmp_stu_admin` (
          `student_code` varchar(15) NOT NULL,
          `row_num` int(10) NOT NULL,
          `student_id` int(10) NOT NULL,
          `school_year_id` smallint(4) NOT NULL,
          `grade_code` varchar(15) default null,
          `grade_id` int(10) default null,
          `school_code` varchar(15) default null,
          `backfill_needed_flag` tinyint(1),
          primary key (`student_id`, `school_year_id`)
        ) engine=innodb default charset=latin1
        ;
    
        create table `tmp_date_conversion` (
          `date_tested` varchar(10) NOT NULL
         ,`school_year_id` int unsigned,
         primary key (`school_year_id`),
          key (`date_tested`)
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
            date_tested
        )
        select distinct 
            date_tested
        from v_pmi_ods_cogat ods;

        update tmp_date_conversion tdc
        join c_school_year sy
           on str_to_date(tdc.date_tested, v_date_format_mask) between sy.begin_date and sy.end_date
        set tdc.school_year_id = sy.school_year_id;

        --  Get the student data and determine if backloading of Student Year information is needed.
        --  We will also get the current school year information for the date the test was
        --  administered. This year infomration will be used to generate the new report data.

        insert  tmp_stu_admin (
                row_num
               ,student_id
               ,student_code
               ,school_year_id
               ,grade_code
               ,grade_id
               ,school_code
               ,backfill_needed_flag
        )
        select  max(ods.row_num)
               ,s.student_id
               ,ods.student_id
               ,tdc.school_year_id
               ,ods.grade
               ,NULL -- Dont know grade id just yet
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_cogat as ods
        join    tmp_date_conversion tdc
                on ods.date_tested = tdc.date_tested
        join    c_student as s
                on    s.student_state_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        where   ods.student_id is not null
        group by ods.student_id
        union all
        select  max(ods.row_num)
               ,s.student_id
               ,ods.student_id
               ,tdc.school_year_id
               ,ods.grade
               ,NULL -- Dont know grade id just yet
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_cogat as ods
        join    tmp_date_conversion tdc
                on ods.date_tested = tdc.date_tested
        join    c_student as s
                on    s.fid_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        where   ods.student_id is not null
        group by ods.student_id
        union all
        select  max(ods.row_num)
               ,s.student_id
               ,ods.student_id
               ,tdc.school_year_id
               ,ods.grade
               ,NULL -- Dont know grade id just yet
               ,NULL -- Dont' know school code just yet
               ,case when sty.school_year_id is null then 1 end as backfill_needed_flag
        from    v_pmi_ods_cogat as ods
        join    tmp_date_conversion tdc
                on ods.date_tested = tdc.date_tested
        join    c_student as s
                on    s.student_code = ods.student_id
        left join c_student_year as sty
                on    sty.student_id = s.student_id
                and   sty.school_year_id = tdc.school_year_id
        where   ods.student_id is not null
        group by ods.student_id
        order by 1
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

        -- Incomming report data will be incremental in nature so we only want to add/update report records

        insert rpt_bbcard_detail_cogat (
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
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'ageStdScore' then ods.sas_verbal 
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'ussScore' then ods.uss_verbal 
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'ageScorePctRank' then ods.age_pct_rank_1 
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'ageScoreStanRank' then ods.age_stanine_1 
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'rrdScorePctRank' then ods.grade_pct_rank_1 
                    when m.bb_measure_code = 'verbal' and mi.bb_measure_item_code = 'grdScoreStanRank' then ods.grade_stanine_1 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'ageStdScore' then ods.sas_quant 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'ussScore' then ods.uss_quant 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'ageScorePctRank' then ods.age_pct_rank_2 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'ageScoreStanRank' then ods.age_stanine_2 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'grdScorePctRank' then ods.grade_pct_rank_2 
                    when m.bb_measure_code = 'quantitative' and mi.bb_measure_item_code = 'grdScoreStanRank' then grade_stanine_2 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'ageStdScore' then ods.sas_nonverbal 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'ussScore' then ods.uss_nonverbal 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'ageScorePctRank' then ods.age_pct_rank_3 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'ageScoreStanRank' then ods.age_stanine_3 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'grdScorePctRank' then ods.grade_pct_rank_3 
                    when m.bb_measure_code = 'nonVerbal' and mi.bb_measure_item_code = 'grdScoreStanRank' then ods.grade_stanine_3 
                    when mi.bb_measure_item_code = 'cmpAgeStdScore' then ods.sas_comp1
                    when mi.bb_measure_item_code = 'cmpUssScaleScore1' then ods.uss_comp1
                    when mi.bb_measure_item_code = 'cmpUssScaleScore2' then ods.uss_comp2
                    when mi.bb_measure_item_code = 'cmpUssScaleScore3' then ods.uss_comp3
                    when mi.bb_measure_item_code = 'cmpUssScaleScore4' then ods.uss_comp4
                    when mi.bb_measure_item_code = 'cmpVqGradePct' then ods.grade_pct_rank_4
                    when mi.bb_measure_item_code = 'cmpVnGradePct' then ods.grade_pct_rank_5
                    when mi.bb_measure_item_code = 'cmpQnGradePct' then ods.grade_pct_rank_6
                    when mi.bb_measure_item_code = 'cmpVqnGradePct' then ods.grade_pct_rank_7
                    when mi.bb_measure_item_code = 'cmpVqAgePct' then ods.age_pct_rank_4
                    when mi.bb_measure_item_code = 'cmpVnAgePct' then ods.age_pct_rank_5
                    when mi.bb_measure_item_code = 'cmpQnAgePct' then ods.age_pct_rank_6
                    when mi.bb_measure_item_code = 'cmpVqnAgePct' then ods.age_pct_rank_6
                    when mi.bb_measure_item_code = 'cmpVqGrdStan' then ods.grade_stanine_4
                    when mi.bb_measure_item_code = 'cmpVnGrdStan' then ods.grade_stanine_5
                    when mi.bb_measure_item_code = 'cmpQnGrdStan' then ods.grade_stanine_6
                    when mi.bb_measure_item_code = 'cmpVqnGrdtan' then ods.grade_stanine_7
                    when mi.bb_measure_item_code = 'cmpVqAgeStan' then ods.age_stanine_4
                    when mi.bb_measure_item_code = 'cmpVnAgeStan' then ods.age_stanine_5
                    when mi.bb_measure_item_code = 'cmpQnAgeStan' then ods.age_stanine_6
                    when mi.bb_measure_item_code = 'cmpVqnAgeStan' then ods.age_stanine_7
                    when mi.bb_measure_item_code = 'abilityProfile' then concat(coalesce(ods.ability_profile_1,''), coalesce(ods.ability_profile_2,''))
             end) as score
            ,'a'
            ,null
            ,1234
            ,now()
        from    v_pmi_ods_cogat as ods
        join    tmp_date_conversion tdc
                on ods.date_tested = tdc.date_tested
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
        
        update rpt_bbcard_detail_cogat as rpt
        join pm_color_cogat as c
                on   rpt.bb_group_id = c.bb_group_id
                 and rpt.bb_measure_id = c.bb_measure_id
                 and rpt.bb_measure_item_id = c.bb_measure_item_id 
                 and rpt.score between c.min_score and c.max_score
                 and rpt.school_year_id BETWEEN c.begin_year AND c.end_year
        join pmi_color as pmic
               on c.color_id = pmic.color_id
        set score_color = pmic.moniker;

        set @sql_scan_log := concat('call ', @db_name_ods, '.imp_set_upload_file_status (\'', v_ods_table, '\', \'P\', \'ETL Load Successful\')');

        prepare sql_scan_log from @sql_scan_log;
        execute sql_scan_log;
        deallocate prepare sql_scan_log;
        /*
        drop table if exists `tmp_stu_admin`;
        drop table if exists `tmp_date_conversion`;
        drop table if exists `tmp_student_year_backfill`;
        drop table if exists `tmp_school`;  
        */

    end if;

end proc
//
call etl_rpt_bbcard_detail_cogat()
//