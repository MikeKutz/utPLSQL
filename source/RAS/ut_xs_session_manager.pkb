create or replace
package body ut_xs_session_manager
as
  xs_sessions  ut_ras := new ut_ras();
  
  procedure attach_session( a_session in out nocopy ut_ras_session_info )
  as
  begin
    -- xs_sessions.get_or_create_session( a_session );
    xs_sessions.ad_hoc_attach_session( a_session );
  end;

  procedure detach_session( a_abort in boolean default false )
  as
  begin
    xs_sessions.detach_session( a_abort );
  end;

  procedure destroy_all_sessions
  as
  begin
    xs_sessions.destroy_all_sessions;
  end;
  
  function  get_annotation_keys return ut_varchar2_list
  as
  begin
    return new ut_varchar2_list();
  end;
-- needs work
--  procedure process_annotations( a_test in out nocopy ut_test, ???? );
end;
/
