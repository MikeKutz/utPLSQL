clear screen
set serveroutput on

exec ut_runner.purge_cache();
exec ut.run();

