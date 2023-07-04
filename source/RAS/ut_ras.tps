create or replace type ut_ras authid current_user as object (
  ras_sessions  ut_ras_session_hash,
  constructor function ut_ras return self as result,
  member procedure get_or_create_session( self in out nocopy ut_ras, a_session_info in out nocopy ut_ras_session_info ),
  member procedure ad_hoc_attach_session( self in out nocopy ut_ras, a_session_info   in out ut_ras_session_info ),

  
  member procedure detach_session( a_abort in boolean default false),
  
  member procedure destroy_all_sessions( self in out nocopy ut_ras ),

  -- DEPRECATE
  member procedure attach_session( user_name             in ut_principal
                                ,enable_roles          in ut_principal_list default null
                                ,enable_external_roles in ut_principal_list default null
                                ,disable_roles         in ut_principal_list default null
                                ,ns_attributes         in ut_ns_attrib_list default null
                                ),
  member procedure attach_session( a_username in varchar2 ),
  member procedure attach_external_session( a_username in varchar2 )
) final not persistable;
