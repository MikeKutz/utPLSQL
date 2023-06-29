set current_user = ut3;
@@ut_principal.tps
@@ut_principal.tpb
@@ut_principal_list.tps
@@ut_ns_attrib.tps
@@ut_ns_attrib.tpb
@@ut_ns_attrib_list.tps
@@ut_ras_session_hash.tps
@@ut_ras_session_hash.tpb
@@ut_ras.tps
@@ut_ras.tpb
@@ut_ras_events.tps
@@ut_ras_events.tpb

grant execute on ut3.ut_principal to public;
grant execute on ut3.ut_principal_list to public;
grant execute on ut3.ut_ns_attrib to public;
grant execute on ut3.ut_ns_attrib_list to public;
grant execute on ut3.ut_ras_session_hash to public;
grant execute on ut3.ut_ras to public;
grant execute on ut3.ut_ras_events to public;

create public synonym ut_principal for ut3.ut_principal;
create public synonym ut_principal_list for ut3.ut_principal_list;
create public synonym ut_ns_attrib for ut3.ut_ns_attrib;
create public synonym ut_ns_attrib_list for ut3.ut_ns_attrib_list;
create public synonym ut_ras_session_hash for ut3.ut_ras_session_hash;
create public synonym ut_ras for ut3.ut_ras;
create public synonym ut_ras_events for ut3.ut_ras_events;
