--Create process
do                 
$func$  
declare
  l_dm_name text := 'TEST_DM_1'; 
  l_sql_id bigint;
begin      
  set search_path to dbliner, public;
  --backup datamart configuration and delete 
  perform delete_datamart(l_dm_name); 
  --registry datamart
  perform add_dm_info(1 , l_dm_name, 'Root', 'Admin', 'root', 'datamarts.table_test', 'Test', 
                              'Test', 0, 'JOB', 1, '1.0.0');
  -- add step 
  l_sql_id := add_sql(l_dm_name, 
                      l_dm_name||'_1',
                      'drop table if exists datamarts.table_tmp', 
                      'DROP', 
                      'admin', 
                      '', 
                      1);
  -- add step                              
  l_sql_id := add_sql(l_dm_name, 
                      l_dm_name||'_1',
                      'create table datamarts.table_tmp as select * from core.global where id=:ID::int', 
                      'CREATE', 
                      'admin', 
                      '', 
                      1);  
  -- add parameter default run
  perform add_sql_param(l_sql_id, 'ID' , '1', 0, ''); 
  --create scheduler default run
  perform add_scheduller(l_dm_name, 'DAY', 0, 0, 2, 0, 1, 1, 0);
end;                           
$func$ 

--Create process
do                 
$func$  
declare
  l_dm_name text := 'AA_TEST_DM_1'; 
  l_sql_id bigint;
begin      
  set search_path to dbliner, public; 
  --backup datamart configuration and delete 
  perform delete_datamart(l_dm_name); 
  --registry datamart
  perform add_dm_info(1 , l_dm_name, 'Root', 'Admin', 'root', 'datamarts.table_test', 'Test', 
                              'Test', 0, 'JOB', 1, '1.0.0'); 
  --add step
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'drop table if exists datamarts.table_1', 'DROP', 'admin', '', 1);
  --add step                        
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                      'create table datamarts.table_1 as select count(*) from datamarts.table_tmp', 
                      'CREATE', 
                      'admin', 
                      '', 
                      1);
  --add step      
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'drop table if exists datamarts.dm$data', 'DROP', 'admin', '', 1);
  --add step
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'create table datamarts.dm$data as select * from datamarts.table_1', 'DROP', 'admin', '', 1);
  --add a dependency on another process
  perform add_mapping(l_dm_name, 'DM@TEST_DM_1'); 
  --add scheduler  
  perform add_scheduller(l_dm_name, 'DAY', 0, 0, 0, 0, 1, 999, 0);      
end;                             
$func$ 
;

--Create task
-- Create a separate task to recalculate a storefront with parameters different from the default ones  
do             
$$            
declare            
   l_sql text;
begin  
   l_sql := 'do
$func$
declare
  out_res text;
  in_workid int := 9; 
  in_dm_name text := ''TEST_DM_1''; 
  l_pid int; 
begin   
  set search_path to dbliner; 
  l_pid := pg_backend_pid();
  perform set_variable('''', null, null, 0, 9); 
  perform set_context(''RUNNER9'' , ''ID'' , ''2'');
  perform set_variable('''', ''FLG_TR'', ''1'', 0, 9);
  out_res := run_datamart(9 , l_pid , in_dm_name );
  raise info ''Result: %'', out_res;
end;   
$func$';
  perform dbliner.register_task('TEST_DM_1', l_sql, 'admin');
   
end;
$$
;      
