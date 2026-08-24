create table dbliner.dm$scheduller_arch( 
      arch_id bigint,
      arch_dttm timestamp without time zone default now() NULL,
      id bigint,
      dm_name text NULL,
      run_interval text NULL,
      status integer,
      num_day integer NULL,
      num_hour integer NULL,
      num_minute integer NULL,
      worker_id integer NULL,
      order_start integer,
      forcibly_flg integer
)
;  

create table dbliner.dm$mapping_arch(
      arch_id bigint,
      arch_dttm timestamp without time zone default now() NULL,
      id bigint,
      dm_name text NULL,
      dm_mapping text NULL,
      create_dttm timestamp
)
;


 

CREATE OR REPLACE FUNCTION dbliner.get_datamart_archive_id() RETURNS bigint LANGUAGE plpgsql
as $function$
declare     
  l_seq_name text := 'dbliner.seq_archive_id';
  l_seq_ddl text := 'create sequence '||l_seq_name||' INCREMENT by 1 minvalue 1';
begin                                             
  return nextval(l_seq_name);
exception
   when others then             
      execute l_seq_ddl;
      return nextval(l_seq_name);
end;        
$function$
;

CREATE OR REPLACE FUNCTION dbliner.archive_dm_info(in_archive_id bigint, in_dm_name text) RETURNS integer LANGUAGE plpgsql
as $function$
declare  
  out_status int := 0;
  l_row_exec int;
begin 
  set search_path to dbliner; 
  insert into dm$dm_info_arch(arch_id,id,dm_space,dm_alias,dm_author,dm_author_fio,dm_customer,dm_table_name,dm_info,dm_comments,dm_status,dm_type,dm_version,dm_version_desc,create_dttm, update_dttm)
     SELECT in_archive_id,
       id,
       dm_space,
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
       dm_version_desc,
       create_dttm,
       update_dttm
  FROM dm$dm_info where dm_alias = in_dm_name;
  get diagnostics l_row_exec = ROW_COUNT;
  if l_row_exec > 0 then
     out_status := 1;
  end if; 
  return out_status;
end;                        
$function$ 
;


CREATE OR REPLACE FUNCTION dbliner.archive_dm_sql(in_archive_id bigint, in_dm_name text) 
RETURNS void LANGUAGE plpgsql
as $function$
begin 
  set search_path to dbliner; 
  insert into dm$sql_arch(arch_id,id,dm_name,step_alias,sql_text,step_number,opertype,author,comments,version, create_dttm)
    SELECT in_archive_id,
       id,
       dm_name,
       step_alias,
       sql_text,
       step_number,                          
       opertype,
       author,
       comments,
       version,
       create_dttm
  FROM dm$sql where dm_name = in_dm_name; 
end;                                  
$function$
;

CREATE OR REPLACE FUNCTION dbliner.archive_dm_sql_param(in_archive_id bigint, in_dm_name text) 
RETURNS void LANGUAGE plpgsql
as $function$
begin 
  set search_path to dbliner; 
  insert into dm$sql_param_arch(arch_id,p_id,p_name,p_value,p_convert_dttm,p_date_format,p_recalc_var, create_dttm)
    SELECT in_archive_id,
       p_id,
       p_name,
       p_value,
       p_convert_dttm,
       p_date_format,
       p_recalc_var,
       create_dttm
  FROM dm$sql_param where p_id in ( select id from dm$sql where dm_name = in_dm_name);
end;                        
$function$
;
                                                                            
CREATE OR REPLACE FUNCTION dbliner.archive_mapping(in_archive_id bigint, in_dm_name text) 
  RETURNS void LANGUAGE plpgsql
as $function$
begin
  set search_path to dbliner; 
  insert into dm$mapping_arch(arch_id,id,dm_name,dm_mapping, create_dttm)
     SELECT in_archive_id,
       id,
       dm_name,
       dm_mapping,
       create_dttm
  FROM dm$mapping where dm_name = in_dm_name;   
end;
$function$
;


CREATE OR REPLACE FUNCTION dbliner.archive_scheduller(in_archive_id bigint, in_dm_name text) 
  RETURNS void LANGUAGE plpgsql
as $function$
begin
  set search_path to dbliner; 
  insert into dm$scheduller_arch(arch_id,id,dm_name,run_interval,status,num_day,num_hour,num_minute,worker_id,order_start, forcibly_flg)
     SELECT in_archive_id,
       id,
       dm_name,
       run_interval,
       status,
       num_day,
       num_hour,
       num_minute,
       worker_id,
       order_start,
       forcibly_flg
  FROM dm$scheduller where dm_name =  in_dm_name
  ;
end;      
$function$
;  

  
CREATE OR REPLACE FUNCTION dbliner.delete_scheduller_all(in_dm_name text) 
  RETURNS void LANGUAGE plpgsql
as $function$
begin
  set search_path to dbliner; 
  delete from dm$scheduller where dm_name =  in_dm_name 
  ; 
end;      
$function$
;
                                           
CREATE OR REPLACE FUNCTION dbliner.delete_mapping(in_dm_name text) 
  RETURNS void LANGUAGE plpgsql
as $function$
begin
  set search_path to dbliner; 
  delete FROM dm$mapping where dm_name = in_dm_name;   
end;
$function$
; 


CREATE OR REPLACE FUNCTION dbliner.delete_dm_sql_param(in_dm_name text) 
RETURNS void LANGUAGE plpgsql
as $function$
begin 
  set search_path to dbliner; 
  delete FROM dm$sql_param where p_id in ( select id from dbliner.dm$sql where dm_name = in_dm_name);
end;                        
$function$
;

CREATE OR REPLACE FUNCTION dbliner.delete_dm_sql(in_dm_name text) 
RETURNS void LANGUAGE plpgsql
as $function$
begin 
  set search_path to dbliner; 
  delete FROM dm$sql where dm_name = in_dm_name; 
end;                                  
$function$
;
   
CREATE OR REPLACE FUNCTION dbliner.delete_dm_info(in_dm_name text) 
RETURNS void LANGUAGE plpgsql
as $function$
begin 
  set search_path to dbliner; 
  delete FROM dm$dm_info where dm_alias = in_dm_name;
end;                        
$function$ 
;
                
CREATE OR REPLACE FUNCTION dbliner.delete_datamart(in_dm_name text)
  RETURNS void                                                   
  LANGUAGE plpgsql 
as $function$
declare
  l_arch_id bigint;
begin
  set search_path to dbliner;
  if check_datamart_alias(in_dm_name) > 0 then 
     l_arch_id := get_datamart_archive_id(); 
     --backup data
     perform archive_dm_info(l_arch_id, in_dm_name);
     perform archive_dm_sql(l_arch_id, in_dm_name);
     perform archive_dm_sql_param(l_arch_id, in_dm_name);
     perform archive_mapping(l_arch_id, in_dm_name);
     perform archive_scheduller(l_arch_id, in_dm_name);
     
     --delete proccess
     perform delete_scheduller_all(in_dm_name);
     perform delete_mapping(in_dm_name); 
     perform delete_dm_sql_param(in_dm_name);
     perform delete_dm_sql(in_dm_name); 
     perform delete_dm_info(in_dm_name);
  end if;      
end;        
$function$  
;