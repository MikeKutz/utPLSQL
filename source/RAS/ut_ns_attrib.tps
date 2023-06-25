clear screen
set serveroutput on

exec ut.run( 'HR', ut_ras_events() );
--exec ut.run();