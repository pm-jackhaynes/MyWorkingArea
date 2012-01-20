${HOST}
${DB_NAME}

select distinct 
    Rpt.Code         As Attend_Code,
    rpt.title        as attend_desc,
    NULL             as attend_category,
    NULL             as attend_category_desc,
    NULL             as attend_type_code,
    NULL             as attend_type_desc,
    st.state_abbr    as attend_state_code,
    st.moniker       as attend_state_desc,
    now()            as create_date,
    now()            as edit_date,
    1234             as last_edit_user_id,
    0                as z_etl_batch_id
from rpt_attendance rpt
join pmi_state_info st 
where st.state_abbr = UPPER(LEFT('${DB_NAME}', 2));


select * from md_calvertnet.rpt_attendance
limit 100;

select count(*) from md_calvertnet.rpt_attendance; -- 680K rows

select * from md_calvertnet.rpt_attendance limit 100;

-- Use SQL Developer to create the following output! I didn't and I had to format.

student_id  school_year_id  att_date              code      title         abbev   type      last_user_id  create_timestamp      last_edit_timestamp
4311433	    2009	          2008-10-21 00:00:00.0	C	    InSchool			            1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4311433	    2009	          2009-04-23 00:00:00.0	E	    Excused			                1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4311433	    2009	          2009-03-18 00:00:00.0	T	    Tardy			                1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4281300	    2009	          2008-10-27 00:00:00.0	D	    Early Rel			            1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4281300	    2009	          2009-03-11 00:00:00.0	V	    Activity			            1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4281300	    2009	          2008-11-12 00:00:00.0	U	    Unexcused			            1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0
4281300	    2009	          2009-02-04 00:00:00.0	T	    Tardy			                1234	      2009-06-06 01:02:36.0	2009-06-06 01:02:36.0


select * from md_calvertnet.pmi_state_info; -- 54 rows

SELECT DISTINCT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME like '%STATE%';

-- Use SQL Developer to create the following output!

TABLE_SCHEMA                                                     TABLE_NAME                                                       
---------------------------------------------------------------- ---------------------------------------------------------------- 
md_calvertnet                                                    pm_color_state_test_subject                                      
md_calvertnet                                                    pm_state_test                                                    4 rows
md_calvertnet                                                    pm_state_test_score_type                                         28 rows
md_calvertnet                                                    pm_state_test_scores                                             0 rows
md_calvertnet                                                    pm_state_test_subject                                            
md_calvertnet                                                    pm_state_test_subject_category                                   
md_calvertnet                                                    pmi_state_info                                                   
md_calvertnet_dw                                                 d_state_subj_area                                                
md_calvertnet_dw                                                 d_state_subj_cat                                                 
md_calvertnet_dw                                                 f_student_state_subj_area_perf                                   
md_calvertnet_dw                                                 f_student_state_subj_cat_perf

pmi_state_info 


Table rpt_attendance
====================
student_id, school_year_id, att_date, code, title, abbrev, type, last_user_id, create_timestamp, last_edit_timestamp
--------------------
student_id       int(10) PK
school_year_id   int(10)
att_date         datetime PK
code             varchar(50) PK
title            varchar(75)
abbrev           varchar(25)
type             varchar(50)
last_user_id     int(11)
create_timestamp datetime
last_edit_timestamp timestamp

c_attendance_type
c_attend_category

Table d_attend
==============
attend_key, attend_code, attend_desc, attend_category_code, attend_category_desc, attend_type_code, attend_type_desc, attend_state_code, attend_state_desc, create_date, edit_date, last_edit_user_id, z_etl_batch_id
--------------
attend_key       int(11) PK             Auto Incremented
attend_code      varchar(8)             rpt.code  (I chose the NUMERIC CODE vs the abbev of a single alpha character)
attend_desc      varchar(30)            rpt.title
attend_category_code varchar(12)        ?
attend_category_desc varchar(30)        ?
attend_type_code varchar(8)             ?
attend_type_desc varchar(15)            ?
attend_state_code varchar(16)           pm_state
attend_state_desc varchar(255)          ?
create_date      timestamp              now()
edit_date        timestamp              now()
last_edit_user_id int(10) unsigned      1234
z_etl_batch_id   mediumint(8) unsigned  0

