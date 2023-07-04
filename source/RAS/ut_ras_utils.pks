create or replace
package ut_ras_utils
  authid current_user
as
  /* "source of truth" for all RAS functionality */
  
  function is_ras_session return boolean;
  
  procedure ad_hoc_attach( a_session in ut_ras_session_info );
  
  procedure detach_session( a_abort in boolean default false);
  
  function get_context_values return ut_ns_attrib_list;
  
  function ut_attrib_to_xs_attrib( a_ut_vals in ut_ns_attrib_list) return dbms_xs_nsattrlist;
-- function ut_principals_to_xs_principals( .. ) return dbms_xs_principallist;
-- procedure append_context_values( dest in out nocopy ut__ns_attrib_list );
-- procedure consolidate_roles( dest in out nocopy ut_principal_list, source in ut_principal_list, unsource in ut_principal_list);

end;
/
