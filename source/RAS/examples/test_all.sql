clear screen
set serveroutput on

exec ut_runner.rebuild_annotation_cache( 'HR' );
exec ut.run();

