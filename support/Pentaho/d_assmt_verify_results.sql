/* ************************************************************************************************************

    VERIFY RESULTS
    
   *********************************************************************************************************** */

${HOST}
${DB_NAME}

select count(*) from md_calvertnet.sam_test;

select * from fl_flagler_dw.d_assmt asmt
order by test_id;

Table d_assmt
=============
assmt_key, test_id, test_title, test_code, subj_area_key, school_year, create_date, edit_date, last_edit_user_id, z_etl_batch_id
-------------
assmt_key        int(11) PK
test_id          int(11)        sam.test_id
test_title       varchar(255)   sam.monkier
test_code        varchar(255)   sam.monkier
subj_area_key    int(11)        sam.course_type_id = subj.curriculum_id
school_year      year(4)        active school year
create_date      timestamp      now()
edit_date        timestamp      now()
last_edit_user_id int(10) unsigned  1234
z_etl_batch_id   mediumint(8) unsigned 0


select sam.test_id               as test_id,
       sam.moniker               as test_title,
       sam.import_xref_code      as test_code,
       sam.course_type_id        as curriculum_id,
       sy.school_year_id         as school_year,
       now()                     as create_date,
       now()                     as edit_date,
       '1234'                    as last_edit_user_id,
       0                         as z_etl_batch_id
from md_calvertnet.sam_test  sam
join c_school_year sy 
where sy.active_flag = 1 and sam.purge_flag = 0 and sam.import_xref_code is not null;
;  -- returns 483 records

-- The above query matched every row but one so this seems to be the join I will need.

select * from md_calvertnet_dw.d_assmt limit 100;

-- Nothing in Table


select *from md_calvertnet_dw.d_subj_area;

2	0	Not Assigned	Not Assigned	Not Assigned	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
3	1000000	Other	Other	Other	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
4	1000001	Language Arts	Language Arts	Language Arts	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
5	1000002	Math	Math	Math	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
6	1000003	Science	Science	Science	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
7	1000004	Social Studies	Social Studies	Social Studies	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
8	1000005	Reading	Reading	Reading	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
9	1000006	Algebra	Algebra	Algebra	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0
10	1000007	English	English	English	2011-10-29 11:01:58.0	2011-10-29 11:01:58.0	1234	0


/* ************************************************************************************************************

    TABLE DEFINIITIONS AND SAMPLE DATA 

   *********************************************************************************************************** */
   


Table sam_test
==============
test_id          int(11) PK
import_xref_code varchar(255)
moniker          varchar(255)
answer_source_code char(1)
generation_method_code char(1)
search_tag       tinytext
external_answer_source_id int(11)
mastery_level    int(11)
threshold_level  int(11)
external_grading_flag tinyint(1)
course_type_id   int(11)
answer_set_id    int(11)
lexmark_form_id  int(11)
force_rescore_flag tinyint(1)
purge_flag       tinyint(1)
client_id        int(11)
owner_id         int(11)
print_job_id     int(11)
scan_template_job_id int(11)
office_scan_template_job_id int(11)
office_print_job_id int(11)
valid_fsl_flag   tinyint(1)
show_on_device_flag tinyint(1)
pmomr_form_paper_size_code enum('legal','letter')
pmomr_form_page_orient_code enum('l','p')
pmomr_form_font_size tinyint(4)
pmomr_form_column_count tinyint(1)
uploaded_test_doc mediumtext
doc_upload_timestamp datetime
last_user_id     int(11)
create_timestamp datetime
last_edit_timestamp timestamp

retrieve tests where purge_flag = 0 

Table d_subj_area
=================
subj_area_key, curriculum_id, subj_code, subj_area_title, subj_area_desc, create_date, edit_date, last_edit_user_id, z_etl_batch_id
-----------------
subj_area_key    int(11) PK
curriculum_id    int(11)
subj_code        varchar(50)
subj_area_title  varchar(50)
subj_area_desc   varchar(50)
create_date      timestamp
edit_date        timestamp
last_edit_user_id int(10) unsigned
z_etl_batch_id   mediumint(8) unsigned


Table d_assmt
=============
assmt_key, test_id, test_title, test_code, subj_area_key, school_year, create_date, edit_date, last_edit_user_id, z_etl_batch_id
-------------
assmt_key        int(11) PK
test_id          int(11)        sam.test_id
test_title       varchar(255)   sam.monkier
test_code        varchar(255)   sam.monkier
subj_area_key    int(11)        sam.course_type_id = subj.curriculum_id
school_year      year(4)        active school year
create_date      timestamp      now()
edit_date        timestamp      now()
ast_edit_user_id int(10) unsigned  1234
z_etl_batch_id   mediumint(8) unsigned 0


Table c_course  22K rows
==============
course_id, course_code, client_id, moniker, course_type_id, active_flag, last_user_id, create_timestamp, last_edit_timestamp
--------------
course_id        int(11) PK
course_code      varchar(35)
client_id        int(11)
moniker          varchar(50)
course_type_id   int(10)
active_flag      tinyint(1)
last_user_id     int(10)
create_timestamp datetime
last_edit_timestamp timestamp

Table c_course_type
===================
course_type_id, client_id, moniker, last_user_id, create_timestamp, last_edit_timestamp
-------------------
course_type_id   int(10) PK
client_id        int(11)
moniker          varchar(50)
last_user_id     int(10)
create_timestamp datetime
last_edit_timestamp timestamp

0	0	Not Assigned	1234	2008-07-22 12:01:27.0	2008-07-22 12:01:27.0
1000000	0	Other	1234	2007-05-07 14:43:06.0	2006-11-29 16:55:45.0
1000001	0	Language Arts	1234	2007-05-07 14:43:06.0	2006-11-29 16:55:45.0
1000002	0	Math	1234	2007-05-07 14:43:06.0	2006-11-29 16:55:45.0
1000003	0	Science	1234	2007-05-07 14:43:06.0	2006-11-29 16:55:45.0
1000004	0	Social Studies	1234	2007-05-07 14:43:06.0	2006-11-29 16:55:45.0
1000005	0	Reading	1234	2007-05-07 14:43:06.0	2007-01-18 12:48:10.0
1000006	0	Algebra	1234	2007-05-07 14:43:06.0	2007-01-18 12:45:41.0
1000007	0	English	1234	2007-05-07 14:43:06.0	2007-01-18 12:45:41.0


