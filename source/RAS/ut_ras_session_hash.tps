create or replace type ut_ras_session_hash authid current_user as object (
    ras_info  json_object_t,
    constructor function ut_ras_session_hash return self as result,
    member procedure set_user( a_username_uid in varchar2, a_sessionid in raw ),
    member function get_sessionid( a_username_uid in varchar2 ) return raw,
    member function user_exists( a_username_uid in varchar2 ) return boolean,
    member function get_all_users return ut_principal_list -- something, pipelined
) final not persistable;
/
