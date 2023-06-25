create or replace type ut_ras_events under ut_output_reporter_base (
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
  /**
   * Events Listener used to support Real Application Security (RAS)
   * sessions.
   *
   * This event should automatically be imported when --%RASEnabled flag is used.
   */
  
  /* null constructor function */
  constructor function ut_ras_events(self in out nocopy ut_ras_events) return self as result,
  
  
  /**
   * attach/detach RAS Session
   *
   * Session is created as needed
   */
  overriding member procedure before_calling_test(self in out nocopy ut_ras_events, a_test in ut_test),
  overriding member procedure after_calling_test(self in out nocopy ut_ras_events, a_test in ut_test),

  /*
   * read package annotation and set globals
   */
  overriding member procedure before_calling_suite(self in out nocopy ut_ras_events, a_suite in ut_logical_suite),
  overriding member procedure after_calling_suite(self in out nocopy ut_ras_events, a_suite in ut_logical_suite),
  
  /*
   * destroys all RAS Sessions
  */
  member procedure on_finalize2(self in out nocopy ut_ras_events, a_run in ut_run),

  overriding member function get_description return varchar2

) final;
/
