create schema dbliner
;
 
create table dbliner.dm$division(   
  id bigserial,
  name text,
  supervisor text,
  comments text,
  create_dttm timestamp default now(),
  update_dttm timestamp 
)  
;

create table dbliner.dm$space( 
   id bigserial,
   name text,
   author text,       
   division int,  
   comments text,
   status int default 0,
   create_dttm timestamp default now() ,
   update_dttm timestamp
)
;
create table dbliner.dm$dm_info( 
    id bigserial, 
    dm_space bigint, --dm$space.id  
    dm_alias text,        
    dm_author text,
    dm_author_fio text,
    dm_customer text,
    dm_table_name text,
    dm_info text,
    dm_comments text, 
    dm_status int default 0,
    dm_type text,
    dm_version int default 1,
    dm_version_desc text,
    create_dttm timestamp default now(), 
    update_dttm timestamp
)   
; 

create table dbliner.dm$dm_info_arch(  
    arch_id bigserial,
    arch_dttm timestamp default now(),
    id bigint, 
    dm_space bigint, --dm$space.id  
    dm_alias text,        
    dm_author text,
    dm_author_fio text,
    dm_customer text,
    dm_table_name text,
    dm_info text,
    dm_comments text, 
    dm_status int default 0,
    dm_type text,
    dm_version int default 1,
    dm_version_desc text,
    create_dttm timestamp default now(),
    update_dttm timestamp
)   
;

create table dbliner.dm$sql(
  id bigserial,                
  dm_name text, --dm$dm_info.dm_alias
  step_alias text,
  sql_text text,
  step_number int,
  opertype text,
  author text,
  comments text,
  version int,
  create_dttm timestamp default now() 
)    
; 
   
create table dbliner.dm$sql_arch( 
  arch_id bigserial,
  arch_dttm timestamp default now(),
  id bigint, 
  dm_name text,
  step_alias text,
  sql_text text,
  step_number int, 
  opertype text,
  author text,
  comments text,
  version int,
  create_dttm timestamp default now() 
)
;

create table dbliner.dm$sql_param(
   p_id bigint, --dm$sql.id 
   p_name text,
   p_value text,
   p_convert_dttm int default 0,
   p_date_format text,
   p_recalc_var int,
   create_dttm timestamp default now() 
)
; 

create table dbliner.dm$sql_param_arch(
   arch_id bigserial,
   arch_dttm timestamp default now(),
   p_id bigint, --dm$sql.id 
   p_name text,
   p_value text,
   p_convert_dttm int ,
   p_date_format text,
   p_recalc_var int,
   create_dttm timestamp 
)
;

create table dbliner.dm$mapping(
    id bigserial,
    dm_name text,
    dm_mapping text,
    create_dttm timestamp default now()
) 
;                             

create table dbliner.dm$messages(
    id bigserial,
    create_dttm timestamp default now(),
    pid int,                   
    messages text,
    dm_name text,
    msg_type text default 'I',
    worker_id int 
)     
; 
          
create table dbliner.dm$scheduller(
   id bigserial, 
   dm_name text,
   run_interval text,
   status int default 0,      
   num_day int,
   num_hour int,
   num_minute int,
   worker_id int,
   order_start int default 0, 
   forcibly_flg int default 0
)
;  

create table dbliner.dm$scheduller_log(
   id bigint,
   start_dttm timestamp default now(),
   count_job int,
   count_run int,
   count_err int,
   message text,
   state text,
   pid int 
)    
;                                   
   
create table dbliner.dm$running_log(
   id bigserial,  
   scheduller_id bigint, --dm$scheduller.id 
   sched_id bigint, --dm$scheduller_log.id 
   queue_id bigint, --dm$queues.id 
   log_date date default now()::date,
   dm_name text, --dm$dm_info.dm_alias
   start_dttm timestamp,
   end_dttm timestamp,
   status char(1),
   message text
)    
;                          

    
create table dbliner.dm$integration_log(
   id bigserial,     
   log_date date default now()::date, 
   alias text, 
   start_dttm timestamp,  
   end_dttm timestamp,
   system_name text,
   status char(1),
   message text  
)             
; 
      
create table dbliner.dm$operation_log(
   id bigserial,
   sched_id bigint, --dm$scheduller_log.id
   queue_id bigint, --dm$queues.id 
   dm_name text, --dm$dm_info.dm_alias 
   step_id bigint,
   log_dttm date default now()::date,
   start_dttm timestamp,
   end_dttm timestamp,
   row_exec bigint,
   status char(1), 
   message text
)                 
;   
        
create table dbliner.dm$queues(
   id bigserial, 
   dm_name text,      
   status int default 0,             
   sql_text text,
   message text,    
   author text,
   create_dttm timestamp default now(),
   update_dttm timestamp                      
) 
;    
       

create table dbliner.dm$query_history (
  id bigserial,
  sched_id bigint, --dm$scheduller_log.id or -1
  queue_id bigint, --dm$queues.id or -1 
  create_dttm timestamp default now(), 
  dm_name text,    --dm$dm_info.dm_alias 
  step_id bigint,  --dm$sql.id
  sql_text text
)
; 

create table dbliner.dm$query_variable_history (
  id bigserial,
  sched_id bigint, --dm$scheduller_log.id or -1
  queue_id bigint, --dm$queues.id or -1 
  create_dttm timestamp default now(),  
  step_id bigint,  --dm$sql.id  
  variable_name text,
  variable_value text
)        
;
                           
    
create table dbliner.dm$history_script(
    id bigserial,
    dm_name text,
    create_dttm timestamp default now(),    
    script text
)                     
; 

create or replace view dbliner.v_running_status as
select ('DM@' || rl.dm_name) "dm_name" ,
       case when s.run_interval = 'DAY' then rl.start_dttm
            when s.run_interval = 'WEEK' and to_char(rl.start_dttm, 'YYYY-IW') = to_char(now(), 'YYYY-IW') then now()
            when s.run_interval = 'WEEK' and to_char(rl.start_dttm, 'YYYY-IW') <> to_char(now(), 'YYYY-IW') then rl.start_dttm 
            when s.run_interval = 'MONTH' and to_char(rl.start_dttm, 'YYYY-MM') = to_char(now(), 'YYYY-MM') then now()
            when s.run_interval = 'MONTH' and to_char(rl.start_dttm, 'YYYY-MM') <> to_char(now(), 'YYYY-MM') then rl.start_dttm 
       else rl.start_dttm end "max_time_run" 
  from dbliner.dm$running_log rl    
    left join dbliner.dm$scheduller s  on rl.dm_name = s.dm_name and s.status = 0
where rl.start_dttm = (select max(start_dttm) from dbliner.dm$running_log where dm_name = rl.dm_name)
  and rl.status = 'C'
union all     
select ('DM@' || rl.alias) "dm_name",
       rl.start_dttm "max_time_run" 
  from dbliner.dm$integration_log rl 
where rl.start_dttm = (select max(start_dttm) from dbliner.dm$integration_log where alias = rl.alias)
  and rl.status = 'C'  
;


CREATE OR REPLACE FUNCTION dbliner.check_division_name(in_name text) 
  RETURNS integer                 
  LANGUAGE plpgsql 
as $function$
declare 
  out_data int := 0;    
begin  

  set search_path to dbliner; 
  select count(*) into out_data 
    from dm$division where name = in_name; 
  return out_data;
              
end;        
$function$               
;

CREATE OR REPLACE FUNCTION dbliner.check_division_id(in_id bigint) 
  RETURNS integer                 
  LANGUAGE plpgsql 
as $function$
declare 
  out_data int := 0;    
begin  

  set search_path to dbliner; 
  select count(*) into out_data 
    from dm$division where id = in_id; 
  return out_data;
              
end;        
$function$                 
;

CREATE OR REPLACE FUNCTION dbliner.add_division(in_name text, in_supervisor text, in_comments text) 
  RETURNS integer 
  LANGUAGE plpgsql 
as $function$
declare
  out_flag int := 0;
begin      
  
  set search_path to dbliner;
  if check_division_name(in_name) = 0 then 
     insert into dbliner.dm$division(name, supervisor, comments)
       values (in_name, in_supervisor, in_comments);
     out_flag := 1;
  end if; 
  return out_flag;
  
end;        
$function$   
;            

CREATE OR REPLACE FUNCTION dbliner.update_division(in_name text, in_supervisor text, in_comments text) 
  RETURNS void
  LANGUAGE plpgsql 
as $function$
declare
  out_flag int := 0;
begin      
  
  set search_path to dbliner;
  update dm$division 
     set supervisor = in_supervisor,
         comments = in_comments,
         update_dttm = clock_timestamp()
   where name = in_name; 
                        
end;         
$function$ 
;

                                                                  
CREATE OR REPLACE FUNCTION dbliner.delete_division(in_name text) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$
declare
  out_flag int := 0;
begin      
  
  set search_path to dbliner;
  if get_count_space_on_division(in_name) = 0 then
     delete from dm$division where name = in_name; 
     out_flag := 1;
  end if;
  return out_flag;
                          
end;        
$function$  
; 
               
              
CREATE OR REPLACE FUNCTION dbliner.get_division_id(in_name text) 
  RETURNS bigint
  LANGUAGE plpgsql 
as $function$                                            
declare                  
  out_id int := 0;
begin      
  
  set search_path to dbliner;
  if check_division_name(in_name) > 0 then 
     select id into out_id from dm$division where name = in_name; 
  end if;     
  return out_id;
  
end;        
$function$            
;  

CREATE OR REPLACE FUNCTION dbliner.get_division_name(in_id text) 
  RETURNS text
  LANGUAGE plpgsql 
as $function$                                            
declare                  
  out_name text := '';
begin      
  
  set search_path to dbliner;
  if check_division_id(in_id) > 0 then 
     select name into out_name from dm$division where id = in_id; 
  end if;           
  return out_name;
  
end;        
$function$            
;


           
CREATE OR REPLACE FUNCTION dbliner.get_count_space_on_division_name(in_name text) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare
  out_flag int := 0;                 
begin                                                        
        
  set search_path to dbliner;
  select count(*) into out_flag 
    from dm$space           
  where division = get_division_id(in_name); 
  return out_flag;            
        
end;        
$function$  
;


CREATE OR REPLACE FUNCTION dbliner.get_count_space_on_division_id(in_id bigint) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare
  out_flag int := 0;                 
begin                                                        
        
  set search_path to dbliner;
  select count(*) into out_flag 
    from dm$space           
  where division = in_id; 
  return out_flag;            
        
end;        
$function$  
;

                                                   
CREATE OR REPLACE FUNCTION dbliner.check_space_name(in_name text) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare                             
  out_flag int := 0;
begin                                                        
        
  set search_path to dbliner;
  select count(*) into out_flag  
    from dm$space 
  where name = in_name; 
  return out_flag;            
           
end;        
$function$ 
;


CREATE OR REPLACE FUNCTION dbliner.check_space_id(in_id bigint) 
  RETURNS int
  LANGUAGE plpgsql                   
as $function$                                            
declare                             
  out_flag int := 0;
begin                                                        
        
  set search_path to dbliner;
  select count(*) into out_flag  
    from dm$space 
  where id = in_id; 
  return out_flag;            
           
end;        
$function$  
;

CREATE OR REPLACE FUNCTION dbliner.get_space_id(in_name text) 
  RETURNS bigint
  LANGUAGE plpgsql                    
as $function$                                            
declare                             
  out_id bigint := 0;
begin                                                        
        
  set search_path to dbliner;
  select id into out_id  
    from dm$space 
  where name = in_name; 
  return out_id;            
           
end;        
$function$  
;

CREATE OR REPLACE FUNCTION dbliner.get_space_name(in_id bigint) 
  RETURNS text
  LANGUAGE plpgsql                    
as $function$                                            
declare                             
  out_name text := '';
begin                                                        
        
  set search_path to dbliner;
  select name into out_name  
    from dm$space 
  where id = in_id; 
  return out_id;            
           
end;        
$function$  
;
       
CREATE OR REPLACE FUNCTION dbliner.add_space(in_name text, in_author text, in_division bigint, in_comments text, in_status int) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare
  out_flag int := 0; 
begin                                                        
        
  set search_path to dbliner;
  if in_status not in (0,1) then 
     raise exception 'The status must be either 0 or 1'; 
  end if;
  if check_division_id(in_division) = 0 then 
     raise exception 'The division is not registered';
  end if;
  if check_space_name(in_name) = 0 then 
     insert into dm$space(name,author,division,comments,status)
        values (in_name, in_author, in_division, in_comments, in_status);        
     out_flag := 1;
  else
     raise exception 'Space already exists'; 
  end if;
  return out_flag;            
        
end;        
$function$           
;           

CREATE OR REPLACE FUNCTION dbliner.update_space_by_name(in_name text, in_author text, in_division bigint, in_comments text, in_status int) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare
  out_flag int := 0; 
begin                                                        
        
  set search_path to dbliner;
  if in_status not in (0,1) then 
     raise exception 'The status must be either 0 or 1'; 
  end if;
  if check_division_id(in_division) = 0 then 
     raise exception 'The division is not registered';
  end if;
  if check_space_name(in_name) = 1 then 
     update dm$space 
        set author = in_author,
            division = in_division,
            comments = in_comments,
            status = in_status
      where name = in_name;
     out_flag := 1;
  else
     raise exception 'Space not found'; 
  end if;
  return out_flag;            
        
end;        
$function$           
; 

      
CREATE OR REPLACE FUNCTION dbliner.update_space_by_id(in_id bigint, in_author text, in_division bigint, in_comments text, in_status int) 
  RETURNS int
  LANGUAGE plpgsql 
as $function$                                            
declare
  out_flag int := 0; 
begin                                                        
        
  set search_path to dbliner;
  if in_status not in (0,1) then 
     raise exception 'The status must be either 0 or 1'; 
  end if;
  if check_division_id(in_division) = 0 then 
     raise exception 'The division is not registered';
  end if;
  if check_space_id(in_id) = 1 then 
     update dm$space 
        set author = in_author,
            division = in_division,
            comments = in_comments,
            status = in_status
      where id = in_id;
     out_flag := 1;
  else
     raise exception 'Space not found'; 
  end if;
  return out_flag;            
        
end;        
$function$  
; 

CREATE OR REPLACE FUNCTION dbliner.get_count_dm_on_space_id(in_id bigint) 
  RETURNS bigint
  LANGUAGE plpgsql                    
as $function$                                            
declare                             
  out_count bigint := 0;
begin                                                        
        
  set search_path to dbliner;   
  select count(*) into out_count            
    from dm$dm_info
  where dm_space = in_id; 
  return out_count;            
           
end;                
$function$  
;   
      

CREATE OR REPLACE FUNCTION dbliner.get_count_dm_on_space_name(in_name text) 
  RETURNS bigint
  LANGUAGE plpgsql                    
as $function$                                            
declare                             
  out_count bigint := 0;
begin                                                        
        
  set search_path to dbliner;   
  select count(*) into out_count            
    from dm$dm_info
  where dm_space = get_space_id(in_name); 
  return out_count;            
           
end;        
$function$  
;


CREATE OR REPLACE FUNCTION dbliner.delete_space_on_name(in_name text) 
  RETURNS void
  LANGUAGE plpgsql                    
as $function$                                            
begin                                                        
        
  set search_path to dbliner;   
  if get_count_dm_on_space_name(in_name) = 0 then  
     delete from dm$space where name = in_name;  
  else                
     raise exception 'Processes have been detected in the space';  
  end if; 
                                         
end;        
$function$  
;                          

CREATE OR REPLACE FUNCTION dbliner.delete_space_on_id(in_id bigint) 
  RETURNS void
  LANGUAGE plpgsql                    
as $function$                                            
begin                                                        
        
  set search_path to dbliner;   
  if get_count_dm_on_space_id(in_id) = 0 then  
     delete from dm$space where id = in_id;  
  else                
     raise exception 'Processes have been detected in the space';    
  end if;         
                                         
end;        
$function$  
;

CREATE OR REPLACE FUNCTION dbliner.check_datamart_alias(in_dm_alias text) 
  RETURNS int
  LANGUAGE plpgsql                    
as $function$                                            
declare                             
  out_count int := 0;
begin                                                        
        
  set search_path to dbliner;   
  select count(*) into out_count            
    from dm$dm_info
  where dm_alias = in_dm_alias; 
  return out_count;            
           
end;        
$function$  
;

      
CREATE OR REPLACE FUNCTION dbliner.add_dm_info(in_dm_space bigint, 
                                                 in_dm_alias text, 
                                                 in_dm_author text, 
                                                 in_dm_author_fio text, 
                                                 in_dm_customer text,
                                                 in_dm_table_name text,
                                                 in_dm_info text,
                                                 in_dm_comments text,
                                                 in_dm_status int,
                                                 in_dm_type text,
                                                 in_dm_version int,
                                                 in_dm_version_desc text)
RETURNS bigint LANGUAGE plpgsql
as $function$                                            
declare
  out_flag bigint := 0;
begin                                                        
        
  set search_path to dbliner;
  if in_dm_status not in (0,1) then 
     raise exception 'The status must be either 0 or 1';
  end if;
  if check_space_id(in_dm_space) = 0 then 
     raise exception 'The space is not registered'; 
  end if; 
  if check_datamart_alias(in_dm_alias) = 0 then 
     insert into dm$dm_info(dm_space,dm_alias,dm_author,dm_author_fio,dm_customer,dm_table_name,dm_info,dm_comments,dm_status,dm_type,dm_version,dm_version_desc)
          values (in_dm_space, in_dm_alias, in_dm_author, in_dm_author_fio, in_dm_customer, in_dm_table_name, in_dm_info, in_dm_comments, in_dm_status, in_dm_type, in_dm_version, in_dm_version_desc)
     RETURNING id into out_flag;                                        
  else
     raise exception 'Datamart already exists'; 
  end if;
  return out_flag;            
           
end;        
$function$     
;         
  
create function dbliner.get_scheduller_log_id() 
  returns bigint
  language plpgsql 
as
$function$
declare 
  l_seq_name text := 'dbliner.seq_scheduller_log_id';
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

    
create or replace function dbliner.set_context(in_block text, in_name text, in_value text) 
  returns void              
  language plpgsql 
as               
$function$
declare
   l_sql text;
begin        
   l_sql := 'SET ' || in_block ||'.'||in_name || ' to ''' || in_value || ''''; 
   execute l_sql; 
end;         
$function$    
;
                
            
create or replace function dbliner.get_context(in_block text, in_name text)
  returns text 
  language plpgsql 
  IMMUTABLE 
as                                    
$function$
begin         
   return current_setting(in_block||'.'||in_name);  
exception               
   when others then return '-1'; 
end;         
$function$     
; 

create or replace function dbliner.set_default_context(in_worker_id int, in_stepid bigint)
  returns void 
  language plpgsql                                                         
as                                    
$function$                                        
declare
  i_row record;
begin  
   set search_path to dbliner;           
   for i_row in (select p_name, p_value from dm$sql_param where p_id = in_stepid) loop 
      begin
        perform set_context('RUNNER'||in_worker_id, i_row.p_name, i_row.p_value);  
      exception                                   
         when others then null;   
      end;
   end loop;

end;                    
$function$     
;   

create or replace function dbliner.clear_default_context(in_worker_id int, in_stepid bigint)
  returns void 
  language plpgsql  
as                                    
$function$                                        
declare
  i_row record;
begin  
   set search_path to dbliner;           
   for i_row in (select p_name, p_value from dm$sql_param where p_id = in_stepid) loop 
      begin
        perform set_context('RUNNER'||in_worker_id, i_row.p_name, '');            
         
      exception                                   
         when others then null;                       
      end;
   end loop;

end;                    
$function$     
;  


create or replace function dbliner.clear_all_default_context(in_worker_id int, in_dm_name text)
  returns void 
  language plpgsql                            
as                                    
$function$                                        
declare
  i_row record;
begin  
   set search_path to dbliner;           
   for i_row in (select p_name, p_value from dm$sql_param where p_id 
                   in (select id from dm$sql where dm_name = in_dm_name)) 
   loop
      begin
        perform set_context('RUNNER'||in_worker_id, i_row.p_name, '');            
         
      exception                                   
         when others then null;                       
      end;
   end loop;

end;                    
$function$     
; 

                          
create or replace function dbliner.set_variable(in_dm_name text, in_name text, in_val text, in_stepid bigint, in_worker_id int)   
  returns void
  language plpgsql                                             
as 
$function$
declare  
  l_set_def text; 
  rec record;
begin
  set search_path to dbliner;         
  l_set_def := coalesce(get_context('RUNNER'||in_worker_id,'FLG_TR'),'0');
  if l_set_def = '-1' or (in_name = 'FLG_TR') then 
     if in_stepid = 0 then       
        if in_name <> '' and in_val <> '' then 
           perform set_context('RUNNER'||in_worker_id, in_name, in_val);  
        end if;
     else
        perform clear_default_context(in_worker_id, in_stepid); 
        perform set_default_context(in_worker_id, in_stepid);
     end if;
  else                  
    for rec in (select p_name from dm$sql_param where p_id = in_stepid) loop
       if coalesce(get_context('RUNNER'||in_worker_id, rec.p_name), '') = '' then 
          raise exception 'Variable [%] not set, operation stopped', rec.p_name; 
       end if;
    end loop;
  end if; 
  if in_name is null and in_val is null and in_stepid = 0 then 
     perform clear_all_default_context(in_worker_id, in_dm_name);
  end if;                                    
end;                
$function$  
;        
                       
      
CREATE OR REPLACE FUNCTION dbliner.add_messages(in_pid int, in_messages text, in_dm_name text, in_msg_type text, in_worker_id int) 
  RETURNS void              
  LANGUAGE plpgsql 
as $function$ 
begin    
  set search_path to dbliner;
  insert into dm$messages(pid, messages, dm_name, msg_type, worker_id)
     values (in_pid, in_messages, in_dm_name, in_msg_type, in_worker_id); 
end;                               
$function$                                                        
;

   
CREATE OR REPLACE FUNCTION dbliner.get_status_mapping(in_dm_name text, in_worker_id int, i_pid int) 
  RETURNS text              
  LANGUAGE plpgsql 
as $function$
declare 
  o_result text;
  l_count_mapping int;
  l_count_success int;
  l_listnotvalid text;
begin    
  set search_path to dbliner;
  
  select count( m.dm_mapping), count(rs.dm_name), string_agg(case when rs.dm_name is null then m.dm_mapping end, ',')
  into l_count_mapping, l_count_success, l_listnotvalid
    from dm$mapping m
      left join v_running_status rs on upper( m.dm_mapping ) = upper( rs.dm_name ) 
            and rs.max_time_run::date = now()::date 
  where m.dm_name = in_dm_name; 
  if l_count_mapping = l_count_success then
     o_result := 'updated';
  else
     o_result := 'wait';
     perform add_messages(i_pid, 
                          'The following processes have not been executed:'||l_listnotvalid, 
                          in_dm_name,
                          'I',
                          in_worker_id); 
  end if;
  return  o_result;                  
end;                               
$function$                                                        
;  

CREATE OR REPLACE FUNCTION dbliner.save_query_history(in_sched_id bigint,in_queue_id bigint, in_dm_name text, 
                                                      in_step_id bigint, in_sql_text text)
  RETURNS void                                     
  LANGUAGE plpgsql 
as $function$                                       
begin
  insert into dbliner.dm$query_history(sched_id, queue_id, dm_name, step_id, sql_text)
     values (in_sched_id, in_queue_id, in_dm_name, in_step_id, in_sql_text); 
end;                                       
$function$ 
;


CREATE OR REPLACE FUNCTION dbliner.save_query_variable_history(in_sched_id bigint,in_queue_id bigint, 
                                                      in_step_id bigint, in_variable_name text, in_variable_value text)
  RETURNS void 
  LANGUAGE plpgsql 
as $function$
begin
  insert into dbliner.dm$query_variable_history(sched_id,queue_id,step_id,variable_name, variable_value)
    values (in_sched_id,in_queue_id,in_step_id,in_variable_name, in_variable_value);
end;                                       
$function$ 
;
                                       
             
CREATE OR REPLACE FUNCTION dbliner.replace_variable_in_sql(in_sql_text text, in_sql_id bigint, in_workid int, in_sched_id bigint, in_queue_id bigint) 
  RETURNS text  
  LANGUAGE plpgsql 
as $function$
declare 
  o_sql_text text;
  l_var_value text;             
  l_date_string text;
  l_sql text;
  rec record;
begin
  set search_path to dbliner; 
  o_sql_text := in_sql_text;
  for rec in (select p_name, p_value, p_convert_dttm, p_date_format from dm$sql_param where p_id = in_sql_id) loop 
     l_var_value := get_context('RUNNER'||in_workid, rec.p_name); 
     if rec.p_convert_dttm = 1 then
        l_sql := 'select to_char('||l_var_value||', '''|| rec.p_date_format ||''')'; 
        execute l_sql into l_date_string;
        o_sql_text := replace(o_sql_text, ':'||rec.p_name, ''||l_date_string||'');
        perform save_query_variable_history(in_sched_id, in_queue_id, in_sql_id, rec.p_name, l_date_string); 
     else
        o_sql_text := replace(o_sql_text, ':'||rec.p_name, ''||l_var_value||'');
        perform save_query_variable_history(in_sched_id, in_queue_id, in_sql_id, rec.p_name, l_var_value); 
     end if;                
     
  end loop;
  return o_sql_text; 
end;                
$function$ 
;      
           
CREATE OR REPLACE FUNCTION dbliner.exec_alter(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                    
  set search_path to dbliner;  
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint;
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_alter, %s]', sqlerrm); 
end;        
$function$                                                                    
;


CREATE OR REPLACE FUNCTION dbliner.exec_create(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                    
  set search_path to dbliner;
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint;
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                                             
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp(); 
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');    
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_create, %s]', sqlerrm); 
end;        
$function$ 
;  
                                                          
          
CREATE OR REPLACE FUNCTION dbliner.exec_delete(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin         
             
  set search_path to dbliner;
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;  
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint; 
  l_stet_start := clock_timestamp();           
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_delete, %s]', sqlerrm); 
end;        
$function$
;  

                
CREATE OR REPLACE FUNCTION dbliner.exec_begin(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                    
  set search_path to dbliner;
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint; 
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := 'do $exec$ begin '||replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id)||' end; $exec$'; 
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_begin, %s]', sqlerrm); 
end;        
$function$                                                                    
;            
              
CREATE OR REPLACE FUNCTION dbliner.exec_do(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                    
  set search_path to dbliner; 
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint; 
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := 'do $exec$ '||replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id)||' $exec$'; 
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_do, %s]', sqlerrm); 
end;          
$function$                                                                    
;
                       
CREATE OR REPLACE FUNCTION dbliner.exec_drop(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                    
  set search_path to dbliner;  
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint; 
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);  
      begin
         execute l_sql_text;
      exception
        when others then
          set search_path to dbliner;
             perform add_messages(in_pid, 'Info. SQL => '::text||l_sql_text, l_dm_name, 'I'::text, in_workid);
             perform add_messages(in_pid, 'Info. message => '::text||sqlerrm, l_dm_name, 'I'::text, in_workid);    
      end; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();    
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
end;        
$function$
; 

  
CREATE OR REPLACE FUNCTION dbliner.exec_insert(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text 
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                                   
  set search_path to dbliner; 
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint; 
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_insert, %s]', sqlerrm); 
end;        
$function$
; 
                          
                 
CREATE OR REPLACE FUNCTION dbliner.exec_update(in_pid int, in_sql_id bigint, in_workid int) 
  RETURNS text        
  LANGUAGE plpgsql               
as $function$
declare                
  l_sched_id bigint;
  l_queue_id bigint; 
  l_stet_start timestamp;
  l_step_finish timestamp;
  l_dm_name text;  
  l_sql_text text; 
  rec record;
  l_exec_count bigint := 0;
begin                   
  set search_path to dbliner; 
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint;
  l_stet_start := clock_timestamp();
  for rec in (select sql_text, dm_name from dm$sql where id = in_sql_id) loop  
      l_dm_name := rec.dm_name;
                                         
      l_sql_text := replace_variable_in_sql(rec.sql_text, in_sql_id, in_workid, l_sched_id, l_queue_id);
      perform save_query_history(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_sql_text);
      execute l_sql_text; 
      get diagnostics l_exec_count = ROW_COUNT;  
      l_step_finish := clock_timestamp();
      perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                l_step_finish, l_exec_count, 'C', '');
  end loop;                                                                                   
  return 'success';                 
exception
  when others then
     set search_path to dbliner;
     perform add_messages(in_pid, 'Error. SQL => '::text||l_sql_text, l_dm_name, 'F'::text, in_workid);
     perform add_messages(in_pid, 'Error. message => '::text||sqlerrm, l_dm_name, 'F'::text, in_workid);
     perform add_operation_log(l_sched_id, l_queue_id, l_dm_name, in_sql_id, l_stet_start, 
                                        l_step_finish, l_exec_count, 'F', sqlerrm);
     return format('err [exec_update, %s]', sqlerrm); 
end;        
$function$ 
;


CREATE OR REPLACE FUNCTION dbliner.add_running_log(in_sched_id bigint, in_queue_id bigint, in_log_date date, in_dm_name text,
                                                   in_start_dttm timestamp, in_end_dttm timestamp, in_status char(1), in_message text)
  RETURNS void 
  LANGUAGE plpgsql 
as $function$  
declare 
  l_scheduller_id bigint;
begin     
   l_scheduller_id := get_context('DM_SYSTEM','SCHEDULLER_ID')::bigint;  
   insert into dbliner.dm$running_log(scheduller_id, sched_id,queue_id,log_date,dm_name,start_dttm,end_dttm,status, message)
      values (l_scheduller_id, in_sched_id, in_queue_id, in_log_date, in_dm_name, in_start_dttm, in_end_dttm, in_status, in_message); 
end;        
$function$ 
;                                                              

CREATE OR REPLACE FUNCTION dbliner.add_operation_log(in_sched_id bigint, in_queue_id bigint, 
                                                   in_dm_name text, in_step_id bigint, in_log_date date, 
                                                   in_start_dttm timestamp, in_end_dttm timestamp, in_row_exec bigint,  in_status char(1), in_message text)
  RETURNS void                                                                               
  LANGUAGE plpgsql 
as $function$
begin
   insert into dbliner.dm$operation_log(sched_id,queue_id,dm_name,step_id,log_dttm,start_dttm,end_dttm,row_exec,status, message)
  values (in_sched_id, in_queue_id, in_dm_name, in_step_id, in_log_date, in_start_dttm, in_end_dttm, in_row_exec, in_status, in_message);
end;        
$function$ 
;
                                  
CREATE OR REPLACE FUNCTION dbliner.add_scheduller_log(in_id bigint, in_start_dttm timestamp, in_count_job int, in_count_run int,
                                                      in_count_err int, in_message text, in_state text, in_pid int)
  RETURNS void 
  LANGUAGE plpgsql 
as $function$
begin
  insert into dbliner.dm$scheduller_log(id, start_dttm, count_job, count_run, count_err, message, state, pid)
  values (in_id, in_start_dttm, in_count_job, in_count_run, in_count_err, in_message, in_state, in_pid);  
end;        
$function$ 
; 
                         
CREATE OR REPLACE FUNCTION dbliner.add_sql(in_dm_name text, in_step_alias text, in_sql_text text, 
                                           in_opertype text, in_author text, in_comments text, in_version int)
  RETURNS bigint 
  LANGUAGE plpgsql 
as $function$
declare
   out_sql_id bigint; 
   l_step_number int; 
   
begin  
  set search_path to dbliner;
  if in_opertype not in('ALTER','BEGIN','CREATE','DELETE','DO','DROP','INSERT','UPDATE') then 
     raise exception 'Unknown operation type'; 
  end if;
  select coalesce(max(step_number), 5) into l_step_number from dm$sql where dm_name = in_dm_name; 
  if (l_step_number < 5) or (l_step_number is null) then 
     l_step_number := 5;
  else 
     l_step_number := l_step_number + 1;
  end if; 
  
  insert into dm$sql(dm_name,step_alias,sql_text,step_number,opertype,author,comments,version)
    values (in_dm_name, in_step_alias, in_sql_text, l_step_number, in_opertype, in_author, in_comments, in_version) 
      returning id into out_sql_id;
  return out_sql_id;
end;        
$function$ 
;          

CREATE OR REPLACE FUNCTION dbliner.add_sql_param(in_p_id bigint, in_p_name text, in_p_value text, 
                                                 in_p_convert_dttm int, in_p_date_format text)
  RETURNS void 
  LANGUAGE plpgsql 
as $function$
declare 
  l_count_row int;
begin  
  set search_path to dbliner;
  select count(*) into l_count_row
    from dm$sql where id = in_p_id;
  if l_count_row = 1 then
     insert into dm$sql_param(p_id, p_name, p_value, p_convert_dttm, p_date_format, p_recalc_var)
        values (in_p_id, in_p_name, in_p_value, in_p_convert_dttm, in_p_date_format,0);
  end if;
end;        
$function$
;

CREATE OR REPLACE FUNCTION dbliner.add_scheduller(in_dm_name text, in_run_interval text, in_status int,
                                                  in_num_day int, in_num_hour int, in_num_minute int, 
                                                  in_worker_id int, in_order_start int, in_forcibly_flg int)
  RETURNS void 
  LANGUAGE plpgsql 
as $function$
begin
  insert into dbliner.dm$scheduller(dm_name,run_interval,status,num_day,num_hour,num_minute,worker_id,order_start, forcibly_flg)
     values (in_dm_name, in_run_interval, in_status, in_num_day, in_num_hour, in_num_minute, in_worker_id, in_order_start, in_forcibly_flg); 
end;        
$function$
;


CREATE OR REPLACE FUNCTION dbliner.add_mapping(in_dm_name text, in_dm_mapping text) 
  RETURNS void 
  LANGUAGE plpgsql 
as $function$  
begin
  insert into dbliner.dm$mapping(dm_name,dm_mapping)
    values (in_dm_name, in_dm_mapping); 
end;        
$function$
;

    
create or replace function dbliner.run_datamart(in_workid int, in_pid int, in_dm_name text) 
returns text                                    
language plpgsql                                               
as                                     
$function$              
declare 
  l_app_name text := 'DM:';
  l_app_name_run text := '';
  l_step_id bigint;  
  l_step_start text; 
  l_start_dm timestamp;
  l_end_dm timestamp;
  out_result text;
  l_sched_id bigint;
  l_queue_id bigint;
  rec record;
begin 
  set search_path to dbliner, public; 
  l_start_dm := clock_timestamp();   
  l_sched_id := get_context('DM_SYSTEM','SCHED_LOG_ID')::bigint;
  l_queue_id := get_context('DM_SYSTEM','TASK_ID')::bigint;
  l_app_name := l_app_name ||'W='||in_workid;
  l_app_name := l_app_name ||':R='||to_char(now(), 'HH24-MI-SS');
  l_app_name := l_app_name ||':S='||l_sched_id;
  l_app_name := l_app_name ||':T='||l_queue_id;
  l_app_name := l_app_name ||':D='||in_dm_name;
  
  execute format('set application_name=%L', l_app_name);  
  raise info 'Run datamart: %',in_dm_name;  
  for rec in (SELECT id,
                       dm_name,
                       step_alias,
                       sql_text,
                       step_number,
                       opertype
                  FROM dm$sql 
                 where dm_name = in_dm_name
                   and step_number >= get_context('DM_SYSTEM','RUN_STEP_NUMBER')::int  
                order by step_number) 
  loop               
       raise info 'Run step: %',rec.id;   
       raise info 'Run step type: %',rec.opertype;  
       l_step_id := rec.id;     
       l_step_start := to_char(clock_timestamp(), 'HH24-MI-SS');
       l_app_name_run := l_app_name||':N='||rec.step_number;
       l_app_name_run := l_app_name_run||':Q='||l_step_start;  
       execute format('set application_name=%L', l_app_name_run); 
       perform set_variable(in_dm_name , null::text, null::text, l_step_id , in_workid ); 
       if rec.opertype = 'ALTER' then
          out_result := exec_alter(in_pid , l_step_id, in_workid ); 
       elsif rec.opertype = 'BEGIN' then
          out_result := exec_begin(in_pid , l_step_id, in_workid ); 
       elsif rec.opertype = 'CREATE' then
          out_result := exec_create(in_pid , l_step_id, in_workid );
       elsif rec.opertype = 'DELETE' then
          out_result := exec_delete(in_pid , l_step_id, in_workid );
       elsif rec.opertype = 'DO' then
          out_result := exec_do(in_pid , l_step_id, in_workid );
       elsif rec.opertype = 'DROP' then
          out_result := exec_drop(in_pid , l_step_id, in_workid ); 
       elsif rec.opertype = 'INSERT' then
          out_result := exec_insert(in_pid , l_step_id, in_workid ); 
       elsif rec.opertype = 'UPDATE' then
          out_result := exec_update(in_pid , l_step_id, in_workid );
       else    
          perform add_messages(in_pid, format('Unknown operation type: %s, step: %s',rec.opertype, rec.id) , ''::text, 'I'::text, in_workid); 
       end if; 
       
       if out_result like 'err%' then 
          l_end_dm := clock_timestamp(); 
          raise info 'Step error: %',out_result; 
          perform add_running_log(l_sched_id , l_queue_id, now()::date, in_dm_name, l_start_dm, l_end_dm, 'E', out_result);
          return out_result;
       end if;
       
  end loop;                     
  l_end_dm := clock_timestamp(); 
  perform add_running_log(l_sched_id , l_queue_id, now()::date, in_dm_name, l_start_dm, l_end_dm, 'C', out_result); 
  return 'success';
exception
  when others then
     set search_path to dbliner, public; 
       l_end_dm := clock_timestamp();
       out_result := 'err: [run_datamart] '||sqlerrm;
       perform add_running_log(l_sched_id , l_queue_id, now()::date, in_dm_name, l_start_dm, l_end_dm, 'E', out_result);
       return out_result;
end;                                  
$function$                                                            
; 
         
       
create or replace function dbliner.run_scheduller(in_workid int) 
returns void                                    
language plpgsql 
as                                    
$function$              
declare                               
  l_pid int;
  l_sched_id bigint; 
  l_message text;  
  l_count_max_error int := 10;         
  l_count_row int := 0; 
  l_count_success int := 0;
  l_count_err int := 0; 
  l_scheduller_start timestamp := clock_timestamp();
  l_result text; 
  r_row record;
begin                                  
  set search_path to dbliner, public;   
              
  l_pid := pg_backend_pid();
  l_sched_id := get_scheduller_log_id();  
  perform set_variable('', 'FLG_TR', '-1', 0, in_workid); 
  perform set_context('DM_SYSTEM','WORKER_ID',in_workid::text); 
  perform set_context('DM_SYSTEM','SESSION_ID',l_pid::text);
  perform set_context('DM_SYSTEM','START_DATE',clock_timestamp()::text); 
  perform set_context('DM_SYSTEM','SCHED_LOG_ID',l_sched_id::text); 
  perform add_messages(l_pid, 'Starting scheduller'::text, ''::text, 'I'::text, in_workid); 
                                                            
  for r_row in (  with hist as ( 
                    
   select ss.id,
          count(case when rl.status = 'E' and ss.id = rl.sched_id and rl.log_date = now()::date then 1 end ) count_error_day, 
          count(case when rl.log_date = now()::date then 1 end) "count_run_day",
          coalesce(max(case when rl.status in('R','C') then rl.start_dttm end),'2000-01-01'::timestamp) last_running, 
          coalesce(max(rl.start_dttm),'2000-01-01'::timestamp) last_log_running,                                
          coalesce(max(case when ss.id = rl.scheduller_id and rl.status in('R','C') then rl.start_dttm end), '2000-01-01'::timestamp) last_running_default  
     from dm$scheduller ss                                               
     left join dm$running_log rl on ss.dm_name = rl.dm_name    
       and rl.log_date > now() - interval '60 day'
   group by ss.id                
       
),      
tmp as (
   select s.id, s.dm_name, s.run_interval, s.num_day, s.num_hour, s.num_minute, s.order_start, s.forcibly_flg,
          case when s.run_interval = 'EVERY_10' and last_running_default + interval '10 min' >= clock_timestamp() then 1
               when s.run_interval = 'EVERY_30' and last_running_default + interval '30 min' >= clock_timestamp() then 1
               when s.run_interval = 'EVERY_60' and last_running_default + interval '60 min' >= clock_timestamp() then 1 
               when s.run_interval = 'EVERY_120' and last_running_default + interval '120 min' >= clock_timestamp() then 1 
               when s.run_interval = 'DAY' and last_running_default::date >= now()::date then 1 
               when s.run_interval = 'WEEK' and s.num_day >= extract(dow from now()) then 1 
               when s.run_interval = 'MONTH' and s.num_day >= extract(day from now()) then 1
               when s.run_interval = 'WEEK' and to_char(last_running_default,'YYYY-IW') = to_char(now(),'YYYY-IW') then 1
               when s.run_interval = 'MONTH' and to_char(last_running_default,'YYYY-MM') = to_char(now(),'YYYY-MM') then 1
         else
           0
         end flg_calcs,
         hs.count_error_day,
         hs.count_run_day,                                        
         hs.last_running,
         hs.last_log_running                   
     from dm$scheduller s                                                    
       left join hist hs on s.id = hs.id                                                                                  
   where s.status = 0 
     and worker_id = coalesce(in_workid, worker_id)               
     and case when s.forcibly_flg = 0 then (to_char(now(), 'HH24.MI')::float >= (coalesce(num_hour, 0)||'.'||coalesce(num_minute, 0))::float )
              else           
                1 = 1
         end                           
     and not exists(select 1 from pg_catalog.pg_locks l where l.locktype = 'advisory' 
                              and ('x'||md5(s.dm_name))::bit(64)::bigint = classid::bigint<<32|objid::bigint 
                    )
)
select * from tmp t
  where t.flg_calcs = 0
  order by  
     case when t.order_start = 0 then 1000000
          else t.order_start
     end,
     case when t.run_interval in ('EVERY_10','EVERY_30','EVERY_60','EVERY_120') then to_char(t.last_log_running, 'YYYY-MM-DD HH24:MI')
               else t.dm_name 
     end 
  ) 
  loop
     -- checks
     l_count_row := l_count_row + 1; 
     perform set_context('DM_SYSTEM','SCHEDULLER_ID',r_row.id::text); 
     raise info 'SCHEDULLER_ID: %',r_row.id::text; 
     if not pg_try_advisory_lock(('x'||md5(r_row.dm_name))::bit(64)::bigint) then 
        l_message := '1. No lock has been set on the process';
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform pg_advisory_unlock_all();  
     elsif r_row.count_error_day > l_count_max_error then
        l_message := '2. Maximum number of process build errors';
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform pg_advisory_unlock_all(); 
     elsif (get_status_mapping(r_row.dm_name, in_workid, l_pid) <> 'updated') and (r_row.forcibly_flg = 0) then 
        l_message := '3. The mapping has not been built';
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform pg_advisory_unlock_all(); 
     elsif (get_status_mapping(r_row.dm_name, in_workid, l_pid) = 'wait') and (r_row.forcibly_flg = 1) and 
           (to_char(now(), 'HH24.MI')::float < (coalesce(r_row.num_hour, 0)||'.'||coalesce(r_row.num_minute, 0))::float) then
        l_message := '4. The time has not yet come for a forced start.';
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform pg_advisory_unlock_all(); 
     elsif r_row.count_error_day>0 and r_row.run_interval in ('DAY','WEEK','MONTH') 
           and r_row.last_log_running + interval '30 min' > now() then
        l_message := '5. Less than 30 minutes have passed since the previous build error.';
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform pg_advisory_unlock_all();  
     else     
        l_message:= 'Running datamarts: ' || r_row.dm_name;
        perform add_messages(l_pid, l_message::text, r_row.dm_name::text, 'I'::text, in_workid); 
        perform set_context('DM_SYSTEM','RUN_INTERVAL',r_row.run_interval::text); 
        l_result := run_datamart(in_workid , l_pid, r_row.dm_name::text);
        if l_result = 'success' then 
           l_count_success := l_count_success + 1; 
           exit;
        else
           l_count_err := l_count_err + 1;
        end if;                          
     end if;       
  end loop;                                                         
                     
  perform dbliner.add_scheduller_log(l_sched_id, l_scheduller_start, l_count_row, l_count_success, l_count_err, 'Finish', 'C', l_pid); 
exception          
  when others then 
     perform dbliner.add_messages(l_pid, 'Start scheduller: '||sqlerrm, '', 'E'::text, in_workid);
     perform dbliner.add_scheduller_log(l_sched_id, l_scheduller_start, l_count_row, l_count_success, l_count_err, sqlerrm, 'E', l_pid); 
end;                                    
$function$                                     
;

        
CREATE OR REPLACE FUNCTION dbliner.register_task(in_dm_name text, in_sql_text text, in_author text) 
  RETURNS void 
  LANGUAGE plpgsql 
as $function$
declare
begin
   insert into dbliner.dm$queues(dm_name, sql_text,author)
      values (in_dm_name, in_sql_text, in_author);
end;                                       
$function$  
;
         
CREATE OR REPLACE FUNCTION dbliner.run_task() 
  RETURNS void                           
  LANGUAGE plpgsql 
as $function$
declare
  r_row record; 
  l_pid int;
  l_workid int := 9;
  l_task_id bigint; 
  l_run_sql text; 
  i_update_sql text := '';   
  count_success int;
begin  
  set search_path to dbliner, public;  
  l_pid := pg_backend_pid();
  l_task_id := get_scheduller_log_id();      
  perform set_variable('', 'FLG_TR', '-1', 0, l_workid); 
  perform set_context('DM_SYSTEM','WORKER_ID',l_workid::text);   
  perform set_context('DM_SYSTEM','SESSION_ID',l_pid::text);
  perform set_context('DM_SYSTEM','START_DATE',clock_timestamp()::text); 
  perform set_context('DM_SYSTEM','TASK_ID',l_task_id::text);
  
  for r_row in (SELECT id,
                       dm_name,
                       sql_text
                  FROM dm$queues q
                 where status = 0
                   and not exists(select 1 from pg_catalog.pg_locks l where l.locktype = 'advisory' 
                                              and ('x'||md5(q.dm_name))::bit(64)::bigint = classid::bigint<<32|objid::bigint 
                                    ) order by id
  )
  loop 
    raise info 'Running task_id: %', r_row.id;
    if not pg_try_advisory_lock(('x'||md5(r_row.dm_name))::bit(64)::bigint) then 
       raise info 'Skipping the task % ',r_row.id; 
    elsif count_success > 0 then
       exit;    
    else 
       begin
         l_run_sql := 'do '|| r_row.sql_text;
         execute l_run_sql;   
         count_success := count_success + 1; 
         i_update_sql := i_update_sql || 'update dm$queues set status =1, update_dttm = clock_timestamp() where id = '||r_row.id||';'||chr(10); 
       exception  
         when others then   
             raise info 'err: %',sqlerrm; 
             perform add_messages(l_pid, format('err: [task => %s] '||sqlerrm, r_row.id), r_row.dm_name::text, 'E'::text, l_workid);
             i_update_sql := i_update_sql || 'update dm$queues set status =2, update_dttm = clock_timestamp(), message='''||sqlerrm||''' where id = '||r_row.id||';'||chr(10);   
       end;                                                                                                                
    end if;
  end loop;                   
  execute i_update_sql;
end;                                    
$function$
;