delimiter //

drop procedure if exists etl_color_cogat //

####################################################################
# Insert cogat color data # 
####################################################################


create definer=`dbadmin`@`localhost` procedure etl_color_cogat()
contains sql
sql security invoker
comment '$Rev $Date: 2011-12-16 etl_color_cogat $'

begin 

/*
      Change History
            
            Date        Programmer           Description
            ----------  -------------------  -----------------------------------------------------
            12/12/2011  J. Haynes            New script

*/

    call set_db_vars(@client_id, @state_id, @db_name, @db_name_core, @db_name_ods, @db_name_ib, @db_name_view, @db_name_pend, @db_name_dw);
  
    select  count(*) 
    into    @view_color
    from    information_schema.tables t
    where   t.table_schema = @db_name_core
    and     t.table_name = 'v_pmi_ods_color_cogat';
    
    if @view_color > 0 then

        select  count(*) 
        into    @view_count
        from    v_pmi_ods_color_cogat;
               
        if @view_count > 0 then

            truncate TABLE pm_color_cogat;
            
            INSERT pm_color_cogat (bb_group_id, bb_measure_id, bb_measure_item_id, begin_year, end_year, min_score, max_score, color_id, last_user_id, create_timestamp, last_edit_timestamp)
            SELECT  g.bb_group_id
                   ,m.bb_measure_id
                   ,mi.bb_measure_item_id
                   ,ods.begin_year
                   ,ods.end_year
                   ,ods.min_score
                   ,ods.max_score
                   ,c.color_id 
                   ,1234
                   ,now()
                   ,now()  
            FROM v_pmi_ods_color_cogat ods
            JOIN  pm_bbcard_measure m
              ON    ods.measure_code = m.bb_measure_code
            JOIN pm_bbcard_measure_item mi 
              ON m.bb_measure_id = mi.bb_measure_id
             and ods.measure_item_code = mi.bb_measure_item_code
            JOIN  pm_bbcard_group g
              ON  g.bb_group_id = m.bb_group_id
              and g.bb_group_code = 'cogAT' 
            JOIN  pmi_color c
              ON    c.moniker = ods.color_name
            ON DUPLICATE key UPDATE last_user_id = 1234, min_score = ods.min_score, max_score= ods.max_score;

            delete  csl.*
            from    c_color_swatch_list as csl
            join    c_color_swatch as cs
                    on      csl.swatch_id = cs.swatch_id
                    and     cs.swatch_code = 'cogAT'
            ;

            set @rownum = 0;
            insert into c_color_swatch_list (
                 swatch_id
                ,client_id
                ,color_id
                ,sort_order
                ,last_user_id
                ,create_timestamp
                ,last_edit_timestamp
                ) 
            select  dt.swatch_id
                ,@client_id
                ,dt.color_id
                ,@rownum := @rownum + 1 as sort_order
                ,1234
                ,now()
                ,now()     
            from    (
                        select  cs.swatch_id, c.color_id,  min(csrc.min_score) as min_score
                        from    pmi_color as c
                        join    pm_color_cogat as csrc
                                on      c.color_id = csrc.color_id
                        join  c_color_swatch as cs
                                on      cs.swatch_code = 'cogAT'
                        where   c.active_flag = 1
                        group by cs.swatch_id, c.color_id
                    ) as dt
            order by dt.color_id
            on duplicate key update last_user_id = 1234
            ;
            
            set @sql_scan_log := concat('call ', @db_name_ods, '.imp_set_upload_file_status (\'', v_ods_table, '\', \'P\', \'ETL Load Successful\')');
        
            prepare sql_scan_log from @sql_scan_log;
            execute sql_scan_log;
            deallocate prepare sql_scan_log;

        end if;
    
    end if;
  
end 
//
