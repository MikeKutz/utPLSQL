create or replace package body ut_session_context as
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
  gc_context_name constant varchar2(30) := ut_utils.ut_owner()||'_INFO';

  procedure set_context(a_name varchar2, a_value varchar2) is
  begin
    dbms_session.set_context( gc_context_name, a_name, a_value );
  end;

  procedure clear_context(a_name varchar2) is
  begin
    dbms_session.clear_context( namespace => gc_context_name, attribute => a_name );
  end;

  procedure clear_all_context is
  begin
    dbms_session.clear_all_context( namespace => gc_context_name );
  end;

  function is_ut_run return boolean is
    l_paths    varchar2(32767);
  begin
    l_paths := get_context('RUN_PATHS');
    
    return l_paths is not null;
  end;

  function get_namespace return varchar2 is
  begin
    return gc_context_name;
  end;

  function get_context(a_name in varchar2) return varchar2
  as
    l_value  varchar2(32767);
  begin
    if a_name is null
    then
      return null;
    end if;

    -- SYS_CONTEXT is cleared when entering a RAS Session
    -- use XS_SYS_CONTEXT instead.
    if ut_ras_utils.is_ras_session
    then
      select xs_sys_context( gc_context_name, a_name)
        into l_value
      from dual;
    else
      l_value := sys_context(gc_context_name, a_name);
    end if;
  
    return l_value;
  end;

  function list_attributes return ut_varchar2_list
  as
    l_return_value  ut_varchar2_list := new ut_varchar2_list();
  begin
    l_return_value.extend(15);
    
    l_return_value( 1 )  := 'CONVERAGE_RUN_ID';
    l_return_value( 2 )  := 'RUN_PATHS';
    l_return_value( 3 )  := 'SUITE_DESCRIPTION';
    l_return_value( 4 )  := 'SUITE_PACKAGE';
    l_return_value( 5 )  := 'SUITE_PATH';
    l_return_value( 6 )  := 'SUITE_START_TIME';
    l_return_value( 7 )  := 'CURRENT_EXECUTABLE_NAME';
    l_return_value( 8 )  := 'CURRNT_EXECUTABLE_TYPE';
    l_return_value( 9 )  := 'CONTEXT_DESCRIPTION';
    l_return_value( 10 ) := 'CONTEXT_NAME';
    l_return_value( 11 ) := 'CONTEXT_PATH';
    l_return_value( 12 ) := 'CONTEXT_START_TIME';
    l_return_value( 13 ) := 'TEST_DESCRIPTION';
    l_return_value( 14 ) := 'TEST_NAME';
    l_return_value( 15 ) := 'TEST_START_TIME';
  
    return l_return_value;
  end;

end;
/