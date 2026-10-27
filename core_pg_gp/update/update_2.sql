--Script creation function for transferring the code of the datamart/etl creation process
CREATE OR REPLACE FUNCTION dbliner.show_script_dm(in_dm_alias text)
  RETURNS text 
  LANGUAGE plpgsql 
as $function$              
declare                                                 
  out_ddl text := 'do 
$ddl_text$                     
declare
  l_step_id bigint; 
  l_dm_name text;
begin    
  set search_path to dbliner;
  l_dm_name := ''#datamart_name#'';
  ---------------------------------
  -- 1. backup datamart info and clear all
  ---------------------------------
  perform delete_datamart(l_dm_name);  
  ---------------------------------
  -- 2. Registry datamart
  --------------------------------- 
  #add_datamart_info#
  ---------------------------------
  -- 3. Add list sptep and default variable                             
  ---------------------------------    
  #add_list_step_datamart#
  ---------------------------------  
  -- 4. Add mapping                                   
  ---------------------------------
  #add_list_mapping#
  ---------------------------------
  -- 5. Add scheduller                             
  --------------------------------- 
  #add_scheduller# 
end;                              
$ddl_text$
';
 str text;  
 l_comment text := '';            
 rr record;
begin                       
  set search_path to dbliner;  
  out_ddl := replace(out_ddl, '#datamart_name#', in_dm_alias);  
                                                                 
  l_comment := 'Formation of step 2';  
                                          
  for rr in ( SELECT dm_space,
                       dm_alias,
                       dm_author,
                       dm_author_fio,  
                       dm_customer,      
                       dm_table_name,
                       dm_info,
                       dm_comments,
                       dm_status,
                       dm_type,
                       dm_version,
                       dm_version_desc
                  FROM dm$dm_info where dm_alias = in_dm_alias ) 
  loop                  
     str := 'perform add_dm_info('||rr.dm_space||
                                 ',l_dm_name,
                                 '''  ||rr.dm_author||
                                 ''','''||rr.dm_author_fio||
                                 ''','''||rr.dm_customer||
                                 ''','''||rr.dm_table_name||
                                 ''','''||rr.dm_info||
                                 ''','''||rr.dm_comments||
                                 ''','||rr.dm_status||
                                 ','''||rr.dm_type||
                                 ''','||rr.dm_version||
                                 ','''||rr.dm_version_desc||''');';
  end loop; 
  out_ddl := replace(out_ddl, '#add_datamart_info#', str);
  str := '';                  
  l_comment := 'Formation of step 3'; 
  
  for rr in (select * from (
                  SELECT 'A' "flg", 
                       id::text "row_1", 
                       dm_name "row_2",    
                       step_alias "row_3",   
                       sql_text "row_4",        
                       step_number::text  "row_5",
                       opertype "row_6",       
                       author "row_7",       
                       comments "row_8",   
                       version::text "row_9"  
                  FROM dm$sql where dm_name = in_dm_alias  
                 union all 
                  SELECT 'P' "flg",
                       p_id::text "row_1",  
                       p_name::text  "row_2",
                       p_value::text  "row_3",      
                       p_convert_dttm::text "row_4", 
                       (select step_number::text from dm$sql where id = p_id) "row_5",
                       p_date_format::text  "row_6",
                       p_recalc_var::text  "row_7",        
                       ''  "row_8",
                       ''  "row_9"    
                  FROM dm$sql_param where p_id in (select id from dm$sql where dm_name = in_dm_alias)     
                                                       
                ) a order by a."row_5"::bigint, a.flg) 
  loop   
     if rr."flg" = 'A' then  
        str := str||chr(10)|| 
        '  l_step_id = add_sql(l_dm_name,'''||rr."row_3"||''','''||replace(rr."row_4",'''','''''')||
        ''' ,'''||rr."row_6"||''' ,'''||rr."row_7"||''','''||rr."row_8"||''','|| rr."row_9"||');';  
     else                      
        str := str || chr(10) ||                                                               
        '  perform add_sql_param(l_step_id,'''||rr."row_2"||''','''||replace(rr."row_3",'''','''''')|| 
        ''','||rr."row_4"||','''||replace(rr."row_5",'''','''''')||''');';  
     end if;                                         
  end loop;                          
  out_ddl := replace(out_ddl, '#add_list_step_datamart#', str);                    
  
  str := ''; 
  l_comment := 'Formation of step 4'; 
  for rr in (SELECT id,
                   dm_name,
                   dm_mapping,
                   create_dttm
              FROM dm$mapping where dm_name = in_dm_alias)
  loop
     str := str || chr(10) || 'perform add_mapping(l_dm_name , '''|| rr.dm_mapping ||''' ); ';
  end loop;
  out_ddl := replace(out_ddl, '#add_list_mapping#', str);
  str := ''; 
  l_comment := 'Formation of step 5';
  for rr in (SELECT id,
               dm_name,
               run_interval,
               status,
               num_day,
               num_hour,
               num_minute,
               worker_id,
               order_start,
               forcibly_flg            
          FROM dm$scheduller where dm_name = in_dm_alias) 
  loop
    str := str || chr(10) || 
       'perform add_scheduller(l_dm_name,''' || rr.run_interval ||''' ,' || rr.status || 
       ',' || rr.num_day ||' ,' || rr.num_hour ||' ,' || rr.num_minute ||' ,' || rr.worker_id ||' ,' || rr.order_start ||
       ' , ' || rr.forcibly_flg ||' );';
  end loop;
  out_ddl := replace(out_ddl, '#add_scheduller#', str);
  return out_ddl;        
end;                             
$function$  
;
