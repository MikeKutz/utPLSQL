create or replace
package ut_xs_session_manager
  authid current_user
as
  procedure attach_session( a_session in out nocopy ut_ras_session_info );
  procedure detach_session( a_abort in boolean default false );
  procedure destroy_all_sessions;
  function  get_annotation_keys return ut_varchar2_list;
-- needs work
--  procedure process_annotations( a_test in out nocopy ut_test, ???? );
end;
/



  