
delimiter //
drop procedure if exists cogat_11_23_2011_add_to_master_db  //
create definer=`dbadmin`@`localhost` procedure cogat_11_23_2011_add_to_master_db ()

contains sql
sql security invoker
comment '$Rev $Date: 2011-12-16 cogat_11_23_2011_add_to_master_db $'

proc: begin

/*
      Change History
            
            Date        Programmer           Description
            12/16/2011  J. Haynes            New Script

*/

    if database() = 'md_hcps' then
    
        call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);
    
        drop table if exists `tmp_id_assign`;
        drop table if exists `tmp_id_assign_bb_meas`;
        drop table if exists `tmp_id_assign_bb_meas_item`;
        drop table if exists `tmp_id_assign_swatch_list`;
        drop table if exists `tmp_pm_bbcard_group`;
        drop table if exists `tmp_pm_bbcard_measure`;
        drop table if exists `tmp_pm_bbcard_measure_item`;
        drop table if exists `tmp_pm_bbcard_measure_item_base_explode`;
        drop table if exists `tmp_c_color_swatch`;
        
        # New ID's tables
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
          `bb_measure_item_code` varchar(30) NOT NULL,
          `moniker` varchar(50) NOT NULL,
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

        CREATE TABLE `tmp_pm_bbcard_measure_item_base_explode` (
          `bb_group_code` varchar(20) NOT NULL,
          `bb_measure_item_code` varchar(30) NOT NULL,
          `moniker` varchar(50) NOT NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `swatch_code` varchar(25) default NULL,
          `score_sort_type_code` enum('a','m','n') NOT NULL,
          UNIQUE KEY `uq_tmp_pm_bbcard_measure_item_base_explode` (`bb_group_code`,`bb_measure_item_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;

        CREATE TABLE `tmp_c_color_swatch` (
          `swatch_code` varchar(25) default NULL,
          `sort_order` decimal(9,2) NOT NULL default '0.00',
          `active_flag` tinyint(1) NOT NULL default '1',
          `state_id` int(10) NOT NULL,
          `last_user_id` int(10) NOT NULL,
          UNIQUE KEY `uq_tmp_c_color_swatch` (`swatch_code`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1
        ;
        
       
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

        values('cogAT','CogAT', @sort_order, 1, 1234, now())
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

       -- Create a color swatch that can be used for configuring the color
       -- scheme that will support the clients baseball card reporting. 
       -- Default colors are usually Red, Yellow and Green.
       
        insert tmp_c_color_swatch (
            swatch_code
            ,sort_order
            ,active_flag
            ,state_id
            ,last_user_id
        )
        
        values ('cogAT', 0, 1, 0, 1234)
        ;

        select count(*) 
        into   @swatch_count
        from   C_Color_Swatch 
        where swatch_code = 'cogAT';
        
        IF @swatch_count = 0 THEN
            select  pmi_admin.pmi_f_get_next_sequence('c_color_swatch', 1) 
            into    @color_swatch_id
            from    dual;
        else 
            select  swatch_id
            into    @color_swatch_id
            from   C_Color_Swatch 
            where swatch_code = 'cogAT';
        end if; 

        select  max(swatch_id) from c_color_swatch
            into    @max_color_swatch_id;

        truncate table tmp_id_assign;
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
        --    ,state_id
            ,last_user_id
            ,create_timestamp
        )

        select  coalesce(tmpid.new_id, tar.swatch_id)
            ,src.swatch_code
            ,src.sort_order
            ,src.active_flag
      --       ,0
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
       -- one can use for the report.
            
        insert c_color_swatch_list (
            swatch_id,
            client_id,
            color_id,
            sort_order,
            last_user_id    
           ) values
           (     @color_swatch_id, @client_id, 1, 1, 1234)  -- red
               ,(@color_swatch_id, @client_id, 2, 2, 1234)  -- yellow
               ,(@color_swatch_id, @client_id, 3, 3, 1234)  -- green
               ,(@color_swatch_id, @client_id, 4, 4, 1234)  -- blue
        on duplicate key update sort_order = values(sort_order)
            ,last_user_id = values(last_user_id)
        ;

       -- Create the level 2 items that will appear on the Selection Menu
       -- supporting the clients baseball card reporting.

       -- By default, we will make the measures active and with dynamic creation set to false
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

        values  ('cogAT', 'verbal', 'Verbal', 1, NULL, 1, 0, 1234, now())
               ,('cogAT', 'quantitative', 'Quanititative', 2, NULL, 1, 0, 1234, now())
               ,('cogAT', 'nonVerbal', 'Nonverbal', 3, NULL, 1, 0, 1234, now())
               ,('cogAT', 'composite', 'Composite', 4, NULL, 1, 0, 1234, now())
               ,('cogAT', 'abilityProfile', 'Ability Profile', 5, NULL, 1, 0, 1234, now())
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
        where   bb_group_code = 'cogAt'
        ;

        -- Create all the common items associated with the Measures except abilityProfile and 
        -- composite. We will create the unique ones for these two later.
        
        -- color_id is set at this level. We do not want color for abilityProfile and Universal
        -- Scale Scores.
        
        insert tmp_pm_bbcard_measure_item_base_explode (
            bb_group_code
            ,bb_measure_item_code
            ,moniker
            ,sort_order
            ,swatch_code
            ,score_sort_type_code
        )
        
        values   ('cogAt', 'ageStdScore', 'Age Score - Standard Score', 1, 'cogAT','n')
                ,('cogAT', 'ussScore', 'Universal Scale Score', 2, NULL,'n')
                ,('cogAt', 'ageScorePctRank', 'Age Score - Percentile Rank', 3, 'cogAT','n')
                ,('cogAt', 'ageScoreStanRank', 'Age Score - Stanine Rank', 4, 'cogAT','n')
                ,('cogAt', 'grdScorePctRank', 'Grade Score - Percentile Rank', 5, 'cogAT','n')
                ,('cogAt', 'grdScoreStanRank', 'Grade Score - Stanine Rank', 6, 'cogAT','n')
        ;
                        
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
        
        select  'cogAt'
            ,pbm.bb_measure_code
            ,exp.bb_measure_item_code
            ,exp.moniker
            ,exp.sort_order
            ,exp.swatch_code
            ,exp.score_sort_type_code
            ,1
            ,0
            ,1234
            ,now() 
            
        from    pm_bbcard_measure as pbm
        cross join    tmp_pm_bbcard_measure_item_base_explode as exp
        where   pbm.bb_group_id = @bb_group_id and pbm.bb_measure_code not in ('abilityProfile', 'composite')
        ;

        -- color_id is set at this level. We do not want color for abilityProfile and Universal
        -- Scale Scores.

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
                 ('cogAt', 'composite', 'cmpAgeStdScore', 'Age Score - Standard Score', 1, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpUssScaleScore1', 'Universal Scale Score Comp 1', 2, NULL,'n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpUssScaleScore2', 'Universal Scale Score Comp 2', 3, NULL,'n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpUssScaleScore3', 'Universal Scale Score Comp 3', 4, NULL,'n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpUssScaleScore4', 'Universal Scale Score Comp 4', 5, NULL,'n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqGradePct', 'Comp: V+Q Grade Percent', 6, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVnGradePct', 'Comp: V+N Grade Percent', 7, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpQnGradePct', 'Comp: Q+N Grade Percent', 8, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqnGradePct', 'Comp: V+Q+N Grade Percent', 9, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqAgePct', 'Comp: V+Q Age Percent', 10, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVnAgePct', 'Comp: V+N Age Percent', 11, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpQnAgePct', 'Comp: Q+N Age Percent', 12, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqnAgePct', 'Comp: V+Q+N Age Percent', 13, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqGrdStan', 'Comp: V+Q Grade Stanine', 14, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVnGrdStan', 'Comp: V+N Grade Stanine', 15, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpQnGrdStan', 'Comp: Q+N Grade Stanine', 16, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqnGrdStan', 'Comp: V+Q+N Grade Stanine', 17, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqAgeStan', 'Comp: V+Q Age Stanine', 18, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVnAgeStan', 'Comp: V+N Age Stanine', 19, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpQnAgeStan', 'Comp: Q+N Age Stanine', 20, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'composite', 'cmpVqnAgeStan', 'Comp: V+Q+N Age Stanine', 21, 'cogAT','n', 1, 0, 1234, now() )
                ,('cogAt', 'abilityProfile', 'abilityProfile', 'Ability Profile', 1, NULL,'a', 1, 0, 1234, now() )
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
        drop table if exists `tmp_pm_bbcard_measure_item`;
        drop table if exists `tmp_pm_bbcard_measure_item_base_explode`;
        drop table if exists `tmp_c_color_swatch`;
        */

    end if;
    
end proc;
//

call cogat_11_23_2011_add_to_master_db()
//