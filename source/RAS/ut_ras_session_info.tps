create or replace type ut_ras_session_info authid current_user as object (
  principal      ut_principal,
  enabled_roles  ut_principal_list,
  disabled_roles ut_principal_list,
  external_roles ut_principal_list,
  ns_attrib_list ut_ns_attrib_list,
  sessionid      raw(32),
  disabled       number(1)
);
