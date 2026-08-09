--Create process
do                 
$func$  
declare
  l_dm_name text := 'AA_TEST_DM_1'; 
  l_sql_id bigint;
begin      
  set search_path to dbliner, public;              
  perform add_dm_info(1 , l_dm_name, 'Root', 'Admin', 'root', 'datamarts.table_test', 'Test', 
                              'Test', 0, 'JOB', 1, '1.0.0');
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'create table datamarts.table_3 as select * from core.global where id=:ID::int', 'CREATE', 'admin', '', 1);
  perform add_sql_param(l_sql_id, 'ID' , '1', 0, '');
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'drop table if exists datamarts.table_test_3', 'DROP', 'admin', '', 1);
  l_sql_id := add_sql(l_dm_name, l_dm_name||'_1',                                               
                          'create table datamarts.table_test_3 as select * from datamarts.table_1', 'DROP', 'admin', '', 1);
  perform add_mapping(l_dm_name, 'DM@TEST_DM_1');                        
  perform add_scheduller(l_dm_name, 'DAY', 0, 0, 0, 0, 1, 999, 0);
end;                           
$func$ 

--Create task
-- Edititng default parameters process
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
