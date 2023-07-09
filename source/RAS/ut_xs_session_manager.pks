create or replace
package ut_xs_session_manager
  authid current_user
as
  /* maintain RAS sessions from a (DB Session) Global POV */
  
  /* attach DB Session to a RAS seession, create as needed */
  procedure attach_session( a_session in out nocopy ut_ras_session_info );
  
  /* detach from a RAS session */
  procedure detach_session( a_abort in boolean default false );
  
  /* destroy all known RAS sessions */
  procedure destroy_all_sessions;
  
  /* get a list of utPLSQL keywords used by RAS enhancement
   *
   * TODO
   */
  function  get_annotation_keys return ut_varchar2_list;
-- needs work
--  procedure process_annotations( a_test in out nocopy ut_test, ???? );
end;
/



  