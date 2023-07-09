create table ut_suite_cache 
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project
  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
  of ut_suite_cache_row
  nested table warnings store as ut_suite_cache_warnings
  nested table before_all_list store as ut_suite_cache_before_all
    ( nested table ras_session.enabled_roles store as ut_ras_session_001
      nested table ras_session.disabled_roles store as ut_ras_session_002
      nested table ras_session.external_roles store as ut_ras_session_002b
      nested table ras_session.ns_attrib_list store as ut_ras_session_003
    )
  nested table after_all_list store as ut_suite_cache_after_all
    ( nested table ras_session.enabled_roles store as ut_ras_session_004
      nested table ras_session.disabled_roles store as ut_ras_session_005
      nested table ras_session.external_roles store as ut_ras_session_005b
      nested table ras_session.ns_attrib_list store as ut_ras_session_006
    )
  nested table before_each_list store as ut_suite_cache_before_each
    ( nested table ras_session.enabled_roles store as ut_ras_session_007
      nested table ras_session.disabled_roles store as ut_ras_session_008
      nested table ras_session.external_roles store as ut_ras_session_008b
      nested table ras_session.ns_attrib_list store as ut_ras_session_009
    )
  nested table after_each_list store as ut_suite_cache_after_each
    ( nested table ras_session.enabled_roles store as ut_ras_session_010
      nested table ras_session.disabled_roles store as ut_ras_session_011
      nested table ras_session.external_roles store as ut_ras_session_011b
      nested table ras_session.ns_attrib_list store as ut_ras_session_012
    )
  nested table before_test_list store as ut_suite_cache_before_test
    ( nested table ras_session.enabled_roles store as ut_ras_session_013
      nested table ras_session.disabled_roles store as ut_ras_session_014
      nested table ras_session.external_roles store as ut_ras_session_014b
      nested table ras_session.ns_attrib_list store as ut_ras_session_015
    )
  nested table after_test_list store as ut_suite_cache_after_test
    ( nested table ras_session.enabled_roles store as ut_ras_session_016
      nested table ras_session.disabled_roles store as ut_ras_session_017
      nested table ras_session.external_roles store as ut_ras_session_017b
      nested table ras_session.ns_attrib_list store as ut_ras_session_018
    )
  nested table expected_error_codes store as ut_suite_cache_throws
  nested table tags store as ut_suite_cache_tags return as locator
      nested table item.ras_session.enabled_roles store as ut_ras_session_item_1
      nested table item.ras_session.disabled_roles store as ut_ras_session_item_2
      nested table item.ras_session.external_roles store as ut_ras_session_item_2b
      nested table item.ras_session.ns_attrib_list store as ut_ras_session_item_3
/

alter table ut_suite_cache modify (object_owner not null, path not null, self_type not null, object_name not null, name not null, parse_time not null)
/
alter table ut_suite_cache add constraint ut_suite_cache_pk primary key (id)
/
alter table ut_suite_cache add constraint ut_suite_cache_uk1 unique (object_owner, path)
/
alter table ut_suite_cache add constraint ut_suite_cache_uk2 unique (object_owner, object_name, line_no)
/

alter table ut_suite_cache add constraint ut_suite_cache_schema_fk foreign key (object_owner, object_name)
references ut_suite_cache_package(object_owner, object_name) on delete cascade
/
