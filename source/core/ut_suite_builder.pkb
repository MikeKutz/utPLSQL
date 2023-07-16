create or replace package body ut_suite_builder is
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

  subtype t_annotation_text     is varchar2(4000);
  subtype t_annotation_name     is varchar2(4000);
  subtype t_object_name         is varchar2(500);
  subtype t_annotation_position is binary_integer;

  gc_suite                       constant t_annotation_name := 'suite';
  gc_suitepath                   constant t_annotation_name := 'suitepath';
  gc_tags                        constant t_annotation_name := 'tags';
  gc_test                        constant t_annotation_name := ut_utils.gc_test_execute;
  gc_disabled                    constant t_annotation_name := 'disabled';
  gc_displayname                 constant t_annotation_name := 'displayname';
  gc_beforeall                   constant t_annotation_name := ut_utils.gc_before_all;
  gc_beforeeach                  constant t_annotation_name := ut_utils.gc_before_each;
  gc_beforetest                  constant t_annotation_name := ut_utils.gc_before_test;
  gc_afterall                    constant t_annotation_name := ut_utils.gc_after_all;
  gc_aftereach                   constant t_annotation_name := ut_utils.gc_after_each;
  gc_aftertest                   constant t_annotation_name := ut_utils.gc_after_test;
  gc_throws                      constant t_annotation_name := 'throws';
  gc_rollback                    constant t_annotation_name := 'rollback';
  gc_context                     constant t_annotation_name := 'context';
  gc_name                        constant t_annotation_name := 'name';
  gc_endcontext                  constant t_annotation_name := 'endcontext';
  -- RAS Annotations
  gc_ras_user                    constant t_annotation_name := 'xsuser';
  gc_ras_ext_user                constant t_annotation_name := 'xsextuser';
  gc_ras_role                    constant t_annotation_name := 'xsrole';
  gc_ras_ext_role                constant t_annotation_name := 'xsextrole';
  gc_ras_ns_attrib               constant t_annotation_name := 'xsnsattr';

  type tt_annotations is table of t_annotation_name;

  gc_supported_annotations       constant tt_annotations
    := tt_annotations(
      gc_suite,
      gc_suitepath,
      gc_tags,
      gc_test,
      gc_disabled,
      gc_displayname,
      gc_beforeall,
      gc_beforeeach,
      gc_beforetest,
      gc_afterall,
      gc_aftereach,
      gc_aftertest,
      gc_throws,
      gc_rollback,
      gc_context,
      gc_name,
      gc_endcontext
  ) multiset union tt_annotations (
      gc_ras_user,
      gc_ras_ext_user,
      gc_ras_role,
      gc_ras_ext_role,
      gc_ras_ns_attrib
  );

  type tt_executables is table of ut_executables index by t_annotation_position;

  type t_annotation is record(
    name                  t_annotation_name,
    text                  t_annotation_text,
    procedure_name        t_object_name
  );

  type tt_annotations_by_line is table of t_annotation index by t_annotation_position;

  --list of annotation texts for a given annotation indexed by annotation position:
  --This would hold: ('some', 'other') for a single annotation name recurring in a single procedure example
  --  --%beforetest(some)
  --  --%beforetest(other)
  --  --%test(some test with two before test procedures)
  --  procedure some_test ...
  -- when you'd like to have two beforetest procedures executed in a single test
  type tt_annotation_texts is table of t_annotation_text index by t_annotation_position;

  type tt_annotations_by_name is table of tt_annotation_texts index by t_annotation_name;

  type tt_annotations_by_proc is table of tt_annotations_by_name index by t_object_name;

  type t_annotations_info is record (
    owner       t_object_name,
    name        t_object_name,
    parse_time  timestamp,
    by_line     tt_annotations_by_line,
    by_proc     tt_annotations_by_proc,
    by_name     tt_annotations_by_name
  );
  
  type t_annotation_params is record (
        p1 t_annotation_text,
        p2 t_annotation_text,
        p3 t_annotation_text,
        p4 t_annotation_text
  );
  
  type tt_annotation_params is table of t_annotation_params index by t_annotation_position;
  
  function parse_first_annotation( a_input in out nocopy tt_annotation_texts ) return t_annotation_params
  as
    l_return_value t_annotation_params := new t_annotation_params();
    l_annot_pos    t_annotation_position;
    l_all_values   ut_varchar2_list;
  begin
    if a_input is null then return l_return_value; end if;

    if a_input.count >= 1 then
      l_annot_pos := a_input.first;
      
      l_all_values := ut_utils.string_to_table(a_input(l_annot_pos), ',');
      

      if l_all_values.count >= 4 then
          l_return_value.p4 := l_all_values(4);
      end if;
      if l_all_values.count >= 3 then
          l_return_value.p3 := l_all_values(3);
      end if;
      if l_all_values.count >= 2 then
          l_return_value.p2 := l_all_values(2);
      end if;
      if l_all_values.count >= 1 then
          l_return_value.p1 := l_all_values(1);
      end if;
    end if;

    return l_return_value;
  end;
  
  function parse_all_annotations( a_input in out nocopy tt_annotation_texts ) return tt_annotation_params
  as
    l_return_value tt_annotation_params; -- AA are already initialized
    l_annot_pos    t_annotation_position;
    l_all_values   ut_varchar2_list;
    i              int := 0;
  begin
    l_annot_pos := a_input.first;
    
    while( l_annot_pos is not null )
    loop
      i := i + 1;
      l_all_values := ut_utils.string_to_table(a_input(l_annot_pos), ',');

      if l_all_values.count >= 4 then
          l_return_value(i).p4 := l_all_values(4);
      end if;
      if l_all_values.count >= 3 then
          l_return_value(i).p3 := l_all_values(3);
      end if;
      if l_all_values.count >= 2 then
          l_return_value(i).p2 := l_all_values(2);
      end if;
      if l_all_values.count >= 1 then
          l_return_value(i).p1 := l_all_values(1);
      end if;
    
      l_annot_pos := a_input.next( l_annot_pos );
    end loop;
    
    return l_return_value;
  end;

  -- parse_as_one
  function parse_single_values( a_input in out nocopy tt_annotation_texts ) return ut_varchar2_list
  as
    l_return_value  ut_varchar2_list := new ut_varchar2_list();
    l_annot_pos    t_annotation_position;
    l_all_values   ut_varchar2_list;
  begin
    l_annot_pos := a_input.first;
    
    while( l_annot_pos is not null )
    loop
      l_all_values := ut_utils.string_to_table(a_input(l_annot_pos), ',');
      
      for i in 1 .. l_all_values.count
      loop
        l_return_value.extend();
        l_return_value( l_return_value.last ) := upper(trim( l_all_values(i) ));
      end loop;

      l_annot_pos := a_input.next( l_annot_pos );
    end loop;

    return l_return_value;
  end;
  
  -- parse_roles
  function parse_xs_roles( a_input in out nocopy tt_annotation_texts ) return ut_principal_list
  as
    l_return_value   ut_principal_list := ut_principal_list();
    l_parsed_values  ut_varchar2_list;
  begin
    l_parsed_values := parse_single_values( a_input );
    
    for i in 1 .. l_parsed_values.count
    loop
      l_return_value.extend();
      l_return_value( l_return_value.last ) := new ut_principal( l_parsed_values(i) );
    end loop;

    return l_return_value;    
  end;

  function parse_ns_attribs( a_input in out nocopy tt_annotation_texts ) return ut_ns_attrib_list
  as
    l_buffer         tt_annotation_params;
    l_return_value   ut_ns_attrib_list := new ut_ns_attrib_list();
  begin
    l_buffer := parse_all_annotations( a_input );
    
    for i in 1 .. l_buffer.count
    loop
      l_return_value.extend();
      l_return_value( l_return_value.last ) := new ut_ns_attrib(
                        trim(l_buffer(i).p1),
                        trim(l_buffer(i).p2),
                        trim(l_buffer(i).p3) );
    end loop;
    
    return l_return_value;
  end;

  
  procedure delete_annotations_range(
    a_annotations in out nocopy t_annotations_info,
    a_start_pos   t_annotation_position,
    a_end_pos     t_annotation_position
  ) is
    l_pos         t_annotation_position := a_start_pos;
    l_annotation  t_annotation;
  begin
    while l_pos is not null and l_pos <= a_end_pos loop
      l_annotation := a_annotations.by_line(l_pos);
      if l_annotation.procedure_name is not null and a_annotations.by_proc.exists(l_annotation.procedure_name) then
        a_annotations.by_proc.delete(l_annotation.procedure_name);
      elsif a_annotations.by_name.exists(l_annotation.name) then
        a_annotations.by_name(l_annotation.name).delete(l_pos);
        if a_annotations.by_name(l_annotation.name).count = 0 then
          a_annotations.by_name.delete(l_annotation.name);
        end if;
      end if;
      l_pos := a_annotations.by_line.next( l_pos );
    end loop;
    a_annotations.by_line.delete(a_start_pos, a_end_pos);
  end;


  procedure add_items_to_list(a_list in out nocopy ut_suite_items, a_items ut_suite_items) is
  begin
    for i in 1 .. a_items.count loop
      a_list.extend();
      a_list(a_list.last) := a_items(i);
    end loop;
  end;

  -----------------------------------------------
  -- Processing annotations
  -----------------------------------------------

  procedure add_annotation_ignored_warning(
    a_suite          in out nocopy ut_suite_item,
    a_annotation     t_annotation_name,
    a_message        varchar2,
    a_line_no        binary_integer,
    a_procedure_name t_object_name := null
  ) is
  begin
    a_suite.put_warning(
      replace(a_message,'%%%','"--%'||a_annotation||'"')|| ' Annotation ignored.',
      a_procedure_name,
      a_line_no
    );
  end;

  function get_rollback_type(a_rollback_type_name varchar2) return ut_utils.t_rollback_type is
    l_rollback_type ut_utils.t_rollback_type;
  begin
    l_rollback_type :=
      case lower(a_rollback_type_name)
        when 'manual' then ut_utils.gc_rollback_manual
        when 'auto' then ut_utils.gc_rollback_auto
      end;
     return l_rollback_type;
  end;

  procedure add_to_throws_numbers_list(
    a_suite           in out nocopy ut_suite,
    a_list            in out nocopy ut_varchar2_rows,
    a_procedure_name  t_object_name,
    a_throws_ann_text tt_annotation_texts
  ) is
    l_annotation_pos binary_integer;

  begin
    l_annotation_pos := a_throws_ann_text.first;
    while l_annotation_pos is not null loop
      if a_throws_ann_text(l_annotation_pos) is null then
        a_suite.put_warning(
          '"--%throws" annotation requires a parameter. Annotation ignored.',
          a_procedure_name,
          l_annotation_pos
        );
      else
        ut_utils.append_to_list(
          a_list,
          ut_utils.convert_collection( ut_utils.trim_list_elements ( ut_utils.string_to_table( a_throws_ann_text(l_annotation_pos), ',' ) ) )
        );
      end if;
      l_annotation_pos := a_throws_ann_text.next(l_annotation_pos);
    end loop;
  end;

  procedure add_tags_to_suite_item(
    a_suite           in out nocopy ut_suite,
    a_tags_ann_text   tt_annotation_texts,
    a_list            in out nocopy ut_varchar2_rows,
    a_procedure_name  t_object_name := null
  ) is
    l_annotation_pos binary_integer;
    l_tags_list ut_varchar2_list := ut_varchar2_list();
    l_tag_items ut_varchar2_list;
  begin
    l_annotation_pos := a_tags_ann_text.first;
    while l_annotation_pos is not null loop
      if a_tags_ann_text(l_annotation_pos) is null then
        a_suite.put_warning(
          '"--%tags" annotation requires a tag value populated. Annotation ignored.',
          a_procedure_name,
          l_annotation_pos
        );
      else
        l_tag_items := ut_utils.trim_list_elements(ut_utils.string_to_table(a_tags_ann_text(l_annotation_pos),','));
        if l_tag_items is not empty then
          for i in 1 .. l_tag_items.count loop
            if regexp_like(l_tag_items(i),'^[^-](\S)+$') then
              l_tags_list.extend();
              l_tags_list(l_tags_list.last) := l_tag_items(i);
            else
              a_suite.put_warning(
                'Invalid value "'||l_tag_items(i)||'" for "--%tags" annotation. See documentation for details on valid tag values. Annotation value ignored.',
                a_procedure_name,
                l_annotation_pos
              );
            end if;
          end loop;
        end if;
      end if;
      l_annotation_pos := a_tags_ann_text.next(l_annotation_pos);
    end loop;
    --remove empty strings from table list e.g. tag1,,tag2 and convert to rows
    a_list := ut_utils.convert_collection( ut_utils.filter_list(set(l_tags_list),ut_utils.gc_word_no_space) );
  end;

  procedure set_seq_no(
    a_list in out nocopy ut_executables
  ) is
  begin
    if a_list is not null then
      for i in 1 .. a_list.count loop
        a_list(i).seq_no := i;
      end loop;
    end if;
  end;

  function convert_list(
    a_list tt_executables
  ) return ut_executables is
    l_result ut_executables := ut_executables();
    l_pos   t_annotation_position := a_list.first;
  begin
    while l_pos is not null loop
      for i in 1 .. a_list(l_pos).count loop
        l_result.extend;
        l_result(l_result.last) := a_list(l_pos)(i);
      end loop;
      l_pos := a_list.next(l_pos);
    end loop;
    return l_result;
  end;

  function add_executables(
    a_owner            t_object_name,
    a_package_name     t_object_name,
    a_annotation_texts tt_annotation_texts,
    a_event_name       ut_event_manager.t_event_name
  ) return tt_executables is
    l_executables     ut_executables;
    l_result          tt_executables;
    l_annotation_pos  binary_integer;
    l_procedures_list ut_varchar2_list;
    l_procedures_pos  binary_integer;
    l_components_list ut_varchar2_list;
  begin
    l_annotation_pos := a_annotation_texts.first;
    while l_annotation_pos is not null loop
      l_procedures_list :=
        ut_utils.filter_list(
          ut_utils.trim_list_elements(
            ut_utils.string_to_table(a_annotation_texts(l_annotation_pos), ',')
          )
          , '[[:alpha:]]+'
        );

      l_procedures_pos := l_procedures_list.first;
      l_executables := ut_executables();
      while l_procedures_pos is not null loop
        l_components_list := ut_utils.string_to_table(l_procedures_list(l_procedures_pos), '.');

        l_executables.extend;
        l_executables(l_executables.last) :=
          case(l_components_list.count())
            when 1 then
              ut_executable(a_owner, a_package_name, l_components_list(1), a_event_name)
            when 2 then
              ut_executable(a_owner,l_components_list(1), l_components_list(2), a_event_name)
            when 3 then
              ut_executable(l_components_list(1), l_components_list(2), l_components_list(3), a_event_name)
            else
              null
          end;
        l_procedures_pos := l_procedures_list.next(l_procedures_pos);
      end loop;
      l_result(l_annotation_pos) := l_executables;
      l_annotation_pos := a_annotation_texts.next(l_annotation_pos);
    end loop;
    return l_result;
  end;

  procedure warning_on_duplicate_annot(
    a_suite          in out nocopy ut_suite_item,
    a_annotations    tt_annotations_by_name,
    a_for_annotation varchar2,
    a_procedure_name  t_object_name := null
  ) is
    l_line_no           binary_integer;
  begin
    if a_annotations.exists(a_for_annotation) and a_annotations(a_for_annotation).count > 1 then
      --start from second occurrence of annotation
      l_line_no := a_annotations(a_for_annotation).next( a_annotations(a_for_annotation).first );
      while l_line_no is not null loop
        add_annotation_ignored_warning( a_suite, a_for_annotation, 'Duplicate annotation %%%.', l_line_no, a_procedure_name );
        l_line_no := a_annotations(a_for_annotation).next( l_line_no );
      end loop;
    end if;
  end;

  procedure warning_bad_annot_combination(
    a_suite               in out nocopy ut_suite_item,
    a_procedure_name      t_object_name,
    a_proc_annotations    tt_annotations_by_name,
    a_for_annotation      varchar2,
    a_invalid_annotations ut_varchar2_list
  ) is
    l_annotation_name t_annotation_name;
    l_line_no         binary_integer;
  begin
    if a_proc_annotations.exists(a_for_annotation) then
      l_annotation_name := a_proc_annotations.first;
      while l_annotation_name is not null loop
        if l_annotation_name member of a_invalid_annotations then
          l_line_no := a_proc_annotations(l_annotation_name).first;
          while l_line_no is not null loop
            add_annotation_ignored_warning(
                a_suite, l_annotation_name, 'Annotation %%% cannot be used with "--%'|| a_for_annotation || '".',
                l_line_no, a_procedure_name
            );
            l_line_no := a_proc_annotations(l_annotation_name).next(l_line_no);
          end loop;
        end if;
        l_annotation_name := a_proc_annotations.next(l_annotation_name);
      end loop;
    end if;
  end;

  procedure add_test(
    a_suite            in out nocopy ut_suite,
    a_suite_items      in out nocopy ut_suite_items,
    a_procedure_name   t_object_name,
    a_annotations      t_annotations_info
  ) is
    l_test             ut_test;
    l_annotation_texts tt_annotation_texts;
    l_proc_annotations tt_annotations_by_name :=  a_annotations.by_proc(a_procedure_name);
  begin

    if not l_proc_annotations.exists(gc_test) then
      return;
    end if;
    warning_on_duplicate_annot( a_suite, l_proc_annotations, gc_test, a_procedure_name);
    warning_on_duplicate_annot( a_suite, l_proc_annotations, gc_displayname, a_procedure_name);
    warning_on_duplicate_annot( a_suite, l_proc_annotations, gc_rollback, a_procedure_name);
    warning_bad_annot_combination(
        a_suite, a_procedure_name, l_proc_annotations, gc_test,
        ut_varchar2_list(gc_beforeeach, gc_aftereach, gc_beforeall, gc_afterall)
    );

    l_test := ut_test(a_suite.object_owner, a_suite.object_name, a_procedure_name, l_proc_annotations( gc_test).first);
    l_test.parse_time  := a_annotations.parse_time;

    if l_proc_annotations.exists( gc_displayname) then
      l_annotation_texts := l_proc_annotations( gc_displayname);
      --take the last definition if more than one was provided
      l_test.description := l_annotation_texts(l_annotation_texts.first);
      --TODO if more than one - warning
    else
      l_test.description := l_proc_annotations(gc_test)(l_proc_annotations(gc_test).first);
    end if;
    l_test.path := a_suite.path ||'.'||a_procedure_name;

    if l_proc_annotations.exists(gc_rollback) then
      l_annotation_texts := l_proc_annotations(gc_rollback);
      l_test.rollback_type := get_rollback_type(l_annotation_texts(l_annotation_texts.first));
      if l_test.rollback_type is null then
        add_annotation_ignored_warning(
            a_suite, gc_rollback, 'Annotation %%% must be provided with one of values: "auto" or "manual".',
            l_annotation_texts.first, a_procedure_name
        );
      end if;
    end if;

    if l_proc_annotations.exists( gc_beforetest) then
      l_test.before_test_list := convert_list(
          add_executables( l_test.object_owner, l_test.object_name, l_proc_annotations( gc_beforetest ), gc_beforetest )
      );
      set_seq_no(l_test.before_test_list);
    end if;
    if l_proc_annotations.exists( gc_aftertest) then
      l_test.after_test_list := convert_list(
          add_executables( l_test.object_owner, l_test.object_name, l_proc_annotations( gc_aftertest ), gc_aftertest )
      );
      set_seq_no(l_test.after_test_list);
    end if;

    if l_proc_annotations.exists( gc_tags) then
      add_tags_to_suite_item(a_suite, l_proc_annotations( gc_tags), l_test.tags, a_procedure_name);
    end if;

    if l_proc_annotations.exists( gc_throws) then
      add_to_throws_numbers_list(a_suite, l_test.expected_error_codes, a_procedure_name, l_proc_annotations( gc_throws));
    end if;
    l_test.disabled_flag := ut_utils.boolean_to_int( l_proc_annotations.exists( gc_disabled));

    if l_proc_annotations.exists(gc_disabled) then
      l_annotation_texts := l_proc_annotations( gc_disabled);
      --take the last definition if more than one was provided    
      l_test.disabled_reason := l_annotation_texts(l_annotation_texts.first);
    end if;

    -- process RAS User tag
    <<ras_tags>>
    declare
      l_ras_principal ut_principal;
      l_data          t_annotation_params;
      l_ns_attribs    ut_ns_attrib_list;
      l_ext_roles     ut_principal_list;
      l_roles         ut_principal_list;
    begin
      -- User
      warning_on_duplicate_annot( a_suite, l_proc_annotations, gc_ras_user, a_procedure_name);
      warning_bad_annot_combination(
          a_suite, a_procedure_name, l_proc_annotations, gc_ras_user,
          ut_varchar2_list( gc_ras_ext_user )
      );
   
      if l_proc_annotations.exists( gc_ras_user ) or l_proc_annotations.exists( gc_ras_ext_user )
      then
        if l_proc_annotations.exists( gc_ras_user )
        then
          l_data := parse_first_annotation(l_proc_annotations( gc_ras_user ) );
          l_ras_principal := new ut_principal( l_data.p1 );
        else
          l_data := parse_first_annotation(l_proc_annotations( gc_ras_ext_user ) );
          l_ras_principal := new ut_principal( l_data.p1 );
          l_ras_principal.is_external := ut_utils.boolean_to_int(true);
        end if;


        if l_data.p2 is not null
        then
          l_ras_principal.unique_identifier := l_data.p2;
        end if;
        
        -- NS Attributes
        if l_proc_annotations.exists( gc_ras_ns_attrib )
        then
          l_ns_attribs := parse_ns_attribs( l_proc_annotations( gc_ras_ns_attrib ) );
        end if;
        
        -- parse disabled roles
        /* TODO */
        
        -- parse internal roles
        if l_proc_annotations.exists( gc_ras_role ) 
        then
          l_roles := parse_xs_roles( l_proc_annotations( gc_ras_role ) );
        end if;
  
        -- parse external roles
        if l_proc_annotations.exists( gc_ras_ext_role ) 
        then
          l_ext_roles := parse_xs_roles( l_proc_annotations( gc_ras_ext_role ) );
        end if;
        
        -- preserve parsed information
        l_test.item.ras_session := new ut_ras_session_info( l_ras_principal, l_roles, null, l_ext_roles, l_ns_attribs, null,  ut_utils.boolean_to_int(false));
      end if;
    end;
    
    
    -- if l_proc_annotations.exists( gc_ras_disable ) then
    --   l_test.item.ras_session.disabled := 1

    a_suite_items.extend;
    a_suite_items( a_suite_items.last ) := l_test;

  end;

  procedure propagate_before_after_each(
    a_suite_items in out nocopy ut_suite_items,
    a_before_each_list tt_executables,
    a_after_each_list  tt_executables
  ) is
    l_test      ut_test;
    l_context   ut_logical_suite;
    begin
      if a_suite_items is not null then
        for i in 1 .. a_suite_items.count loop
          if a_suite_items(i) is of (ut_test) then
            l_test := treat( a_suite_items(i) as ut_test);
            l_test.before_each_list := convert_list(a_before_each_list) multiset union all l_test.before_each_list;
            set_seq_no(l_test.before_each_list);
            l_test.after_each_list := l_test.after_each_list multiset union all convert_list(a_after_each_list);
            set_seq_no(l_test.after_each_list);
            a_suite_items(i) := l_test;
          elsif a_suite_items(i) is of (ut_logical_suite) then
            l_context := treat(a_suite_items(i) as ut_logical_suite);
            propagate_before_after_each( l_context.items, a_before_each_list, a_after_each_list);
            a_suite_items(i) := l_context;
          end if;
        end loop;
      end if;
    end;

  procedure process_before_after_annot(
    a_list             in out nocopy tt_executables,
    a_annotation_name  t_annotation_name,
    a_procedure_name   t_object_name,
    a_proc_annotations tt_annotations_by_name,
    a_suite            in out nocopy ut_suite
  ) is
  begin
    if a_proc_annotations.exists(a_annotation_name) and not a_proc_annotations.exists(gc_test) then
      a_list( a_proc_annotations(a_annotation_name).first ) := ut_executables(ut_executable(a_suite.object_owner,  a_suite.object_name, a_procedure_name, a_annotation_name));
      warning_on_duplicate_annot(a_suite, a_proc_annotations, a_annotation_name, a_procedure_name);
    --TODO add warning if annotation has text - text ignored
    end if;
  end;

  procedure get_annotated_procedures(
    a_proc_annotations t_annotations_info,
    a_suite            in out nocopy ut_suite,
    a_suite_items      in out nocopy ut_suite_items,
    a_before_each_list in out nocopy tt_executables,
    a_after_each_list  in out nocopy tt_executables,
    a_before_all_list  in out nocopy tt_executables,
    a_after_all_list   in out nocopy tt_executables
  ) is
    l_procedure_name   t_object_name;
  begin
    l_procedure_name := a_proc_annotations.by_proc.first;
    while l_procedure_name is not null loop
      add_test( a_suite, a_suite_items, l_procedure_name, a_proc_annotations );
      process_before_after_annot(a_before_each_list, gc_beforeeach, l_procedure_name, a_proc_annotations.by_proc(l_procedure_name), a_suite);
      process_before_after_annot(a_after_each_list,  gc_aftereach,  l_procedure_name, a_proc_annotations.by_proc(l_procedure_name), a_suite);
      process_before_after_annot(a_before_all_list,  gc_beforeall,  l_procedure_name, a_proc_annotations.by_proc(l_procedure_name), a_suite);
      process_before_after_annot(a_after_all_list,   gc_afterall,   l_procedure_name, a_proc_annotations.by_proc(l_procedure_name), a_suite);
      l_procedure_name := a_proc_annotations.by_proc.next( l_procedure_name );
    end loop;
  end;

  procedure build_suitepath(
    a_suite              in out nocopy ut_suite,
    a_annotations        t_annotations_info
  ) is
    l_annotation_text    t_annotation_text;
  begin
    if a_annotations.by_name.exists(gc_suitepath) then
      l_annotation_text := trim(a_annotations.by_name(gc_suitepath)(a_annotations.by_name(gc_suitepath).first));
      if l_annotation_text is not null then
        if regexp_like(l_annotation_text,'^((\w|[$#])+\.)*(\w|[$#])+$') then
          a_suite.path := l_annotation_text||'.'||a_suite.object_name;
        else
          add_annotation_ignored_warning(
              a_suite, gc_suitepath||'('||l_annotation_text||')',
              'Invalid path value in annotation %%%.', a_annotations.by_name(gc_suitepath).first
          );
        end if;
      else
        add_annotation_ignored_warning(
            a_suite, gc_suitepath, '%%% annotation requires a non-empty parameter value.',
            a_annotations.by_name(gc_suitepath).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_annotations.by_name, gc_suitepath);
    end if;
    a_suite.path := lower(coalesce(a_suite.path, a_suite.object_name));
  end;

  procedure add_tests_to_items(
    a_suite              in out nocopy ut_suite,
    a_annotations        t_annotations_info,
    a_suite_items        in out nocopy ut_suite_items
  ) is
    l_before_each_list   tt_executables;
    l_after_each_list    tt_executables;
    l_before_all_list    tt_executables;
    l_after_all_list     tt_executables;
    l_rollback_type      ut_utils.t_rollback_type;
    l_annotation_text    t_annotation_text;
  begin
    if a_annotations.by_name.exists(gc_displayname) then
      l_annotation_text := trim(a_annotations.by_name(gc_displayname)(a_annotations.by_name(gc_displayname).first));
      if l_annotation_text is not null then
        a_suite.description := l_annotation_text;
      else
        add_annotation_ignored_warning(
            a_suite, gc_displayname, '%%% annotation requires a non-empty parameter value.',
            a_annotations.by_name(gc_displayname).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_annotations.by_name, gc_displayname);
    end if;

    if a_annotations.by_name.exists(gc_rollback) then
      l_rollback_type := get_rollback_type(a_annotations.by_name(gc_rollback)(a_annotations.by_name(gc_rollback).first));
      if l_rollback_type is null then
        add_annotation_ignored_warning(
            a_suite, gc_rollback, '%%% annotation requires one of values as parameter: "auto" or "manual".',
            a_annotations.by_name(gc_rollback).first
        );
      end if;
      warning_on_duplicate_annot(a_suite, a_annotations.by_name, gc_rollback);
    end if;
    if a_annotations.by_name.exists(gc_beforeall) then
      l_before_all_list := add_executables( a_suite.object_owner, a_suite.object_name, a_annotations.by_name(gc_beforeall), gc_beforeall );
    end if;
    if a_annotations.by_name.exists(gc_afterall) then
      l_after_all_list := add_executables( a_suite.object_owner, a_suite.object_name, a_annotations.by_name(gc_afterall), gc_afterall );
    end if;

    if a_annotations.by_name.exists(gc_beforeeach) then
      l_before_each_list := add_executables( a_suite.object_owner, a_suite.object_name, a_annotations.by_name(gc_beforeeach), gc_beforeeach );
    end if;
    if a_annotations.by_name.exists(gc_aftereach) then
      l_after_each_list := add_executables( a_suite.object_owner, a_suite.object_name, a_annotations.by_name(gc_aftereach), gc_aftereach );
    end if;

    if a_annotations.by_name.exists(gc_tags) then
      add_tags_to_suite_item(a_suite, a_annotations.by_name(gc_tags),a_suite.tags);
    end if;
    
    a_suite.disabled_flag := ut_utils.boolean_to_int(a_annotations.by_name.exists(gc_disabled));
    if a_annotations.by_name.exists(gc_disabled) then
      a_suite.disabled_reason := a_annotations.by_name(gc_disabled)(a_annotations.by_name(gc_disabled).first);
    end if;
    
    --process procedure annotations for suite
    get_annotated_procedures(a_annotations, a_suite, a_suite_items, l_before_each_list, l_after_each_list, l_before_all_list, l_after_all_list);

    a_suite.set_rollback_type(l_rollback_type);
    propagate_before_after_each( a_suite_items, l_before_each_list, l_after_each_list);
    a_suite.before_all_list := convert_list(l_before_all_list);
    set_seq_no(a_suite.before_all_list);
    a_suite.after_all_list  := convert_list(l_after_all_list);
    set_seq_no(a_suite.after_all_list);
  end;

  function get_next_annotation_of_type(
    a_start_position      t_annotation_position,
    a_annotation_type     varchar2,
    a_package_annotations in tt_annotations_by_name
  ) return t_annotation_position is
    l_result t_annotation_position;
  begin
    if a_package_annotations.exists(a_annotation_type) then
      l_result := a_package_annotations(a_annotation_type).first;
      while l_result <= a_start_position loop
        l_result := a_package_annotations(a_annotation_type).next(l_result);
      end loop;
    end if;
    return l_result;
  end;

  function get_endcontext_position(
    a_context_ann_pos     t_annotation_position,
    a_package_annotations in tt_annotations_by_line
  ) return t_annotation_position is
    l_result t_annotation_position;
    l_open_count integer := 1;
    l_idx t_annotation_position := a_package_annotations.next(a_context_ann_pos);
  begin
    while l_open_count > 0 and l_idx is not null loop
      if ( a_package_annotations(l_idx).name = gc_context ) then
        l_open_count := l_open_count+1;
      elsif ( a_package_annotations(l_idx).name = gc_endcontext ) then
        l_open_count := l_open_count-1;
        l_result := l_idx;
      end if;
      l_idx := a_package_annotations.next(l_idx);
    end loop;
    if ( l_open_count > 0 ) then
      l_result := null;
    end if;
    return l_result;
  end;

  function has_nested_context(
    a_context_ann_pos t_annotation_position,
    a_package_annotations in tt_annotations_by_name
  ) return boolean is
    l_next_endcontext_pos t_annotation_position := 0;
    l_next_context_pos t_annotation_position := 0;
  begin
    if ( a_package_annotations.exists(gc_endcontext) and a_package_annotations.exists(gc_context)) then
      l_next_endcontext_pos := get_next_annotation_of_type(a_context_ann_pos, gc_endcontext, a_package_annotations);
      l_next_context_pos := a_package_annotations(gc_context).next(a_context_ann_pos);
    end if;
    return ( l_next_context_pos < l_next_endcontext_pos );
  end;

  function get_annotations_in_context(
    a_annotations        t_annotations_info,
    a_context_pos        t_annotation_position,
    a_end_context_pos    t_annotation_position
  ) return t_annotations_info is
    l_result          t_annotations_info;
    l_position        t_annotation_position;
    l_procedure_name  t_object_name;
    l_annotation_name t_annotation_name;
    l_annotation_text t_annotation_text;
  begin
    l_position := a_context_pos;
    l_result.owner := a_annotations.owner;
    l_result.name := a_annotations.name;
    l_result.parse_time := a_annotations.parse_time;
    while l_position is not null and l_position <= a_end_context_pos loop
      l_result.by_line(l_position) := a_annotations.by_line(l_position);
      l_procedure_name  := l_result.by_line(l_position).procedure_name;
      l_annotation_name := l_result.by_line(l_position).name;
      l_annotation_text := l_result.by_line(l_position).text;
      if l_procedure_name is not null then
        l_result.by_proc(l_procedure_name)(l_annotation_name)(l_position) := l_annotation_text;
      else
        l_result.by_name(l_annotation_name)(l_position) := l_annotation_text;
      end if;
      l_position := a_annotations.by_line.next(l_position);
    end loop;
    return l_result;
  end;

  procedure get_context_items(
    a_parent             in out nocopy ut_suite,
    a_annotations        in out nocopy t_annotations_info,
    a_suite_items        out nocopy ut_suite_items,
    a_parent_context_pos in integer := 0,
    a_parent_end_context_pos in integer default null
  ) is
    l_context_pos          t_annotation_position;
    l_next_context_pos     t_annotation_position;
    l_end_context_pos      t_annotation_position;
    l_ctx_annotations      t_annotations_info;
    l_context              ut_suite_context;
    l_context_no           binary_integer := 1;
    l_context_items        ut_suite_items;
    type tt_context_names is table of boolean index by t_object_name;
    l_used_context_names   tt_context_names;
    l_context_name         t_object_name;
    l_default_context_name t_object_name;
    function get_context_name(
      a_parent in out nocopy ut_suite,
      a_start_position binary_integer
    ) return varchar2 is
      l_result         t_annotation_name;
      l_found          boolean;
      l_end_position   binary_integer;
      l_annotation_pos binary_integer;
      l_context_names  tt_annotation_texts;
    begin
      if a_annotations.by_name.exists(gc_name) then
        l_context_names := a_annotations.by_name( gc_name );
        -- Maximum end-position to look for %name annotation is either the next %context or the next %endcontext annotation
        l_end_position :=
          least(
              coalesce( get_next_annotation_of_type(a_start_position, gc_endcontext, a_annotations.by_name), a_annotations.by_line.last ),
              coalesce( get_next_annotation_of_type(a_start_position, gc_context, a_annotations.by_name), a_annotations.by_line.last )
            );
        l_annotation_pos := l_context_names.first;

        while l_annotation_pos is not null loop
          if l_annotation_pos > a_start_position and l_annotation_pos < l_end_position then
            if l_found then
              add_annotation_ignored_warning(a_parent, gc_name,'Duplicate annotation %%%.', l_annotation_pos);
            else
              l_result := l_context_names(l_annotation_pos);
            end if;
            l_found := true;
          end if;
          l_annotation_pos := l_context_names.next(l_annotation_pos);
        end loop;
      end if;
      return l_result;
    end;
  begin
    a_suite_items := ut_suite_items();
    if not a_annotations.by_name.exists(gc_context) then
      return;
    end if;

    l_context_pos := a_annotations.by_name( gc_context).next(a_parent_context_pos);

    while l_context_pos is not null loop
      l_default_context_name := 'nested_context_#'||l_context_no;
      l_context_name := null;
      l_end_context_pos := get_endcontext_position(l_context_pos, a_annotations.by_line );
      l_next_context_pos := a_annotations.by_name(gc_context).next(l_context_pos);
      l_context_name := get_context_name(a_parent, l_context_pos);
      if not regexp_like( l_context_name, '^(\w|[$#])+$' ) or l_context_name is null then
        if not regexp_like( l_context_name, '^(\w|[$#])+$' ) then
          a_parent.put_warning(
            'Invalid value "'||l_context_name||'" for context name.' ||
            ' Context name ignored and fallback to auto-name "'||l_default_context_name||'" ',
            null,
            l_context_pos
          );
        end if;
        l_context_name := l_default_context_name;
      end if;
      if l_used_context_names.exists(l_context_name) then
        add_annotation_ignored_warning(
          a_parent, gc_name,
          'Context name "'||l_context_name||'" already used in this scope. Name must be unique.' ||
            ' Using fallback name '||l_default_context_name||'.', l_context_pos );
        l_context_name := l_default_context_name;
      end if;
      l_used_context_names(l_context_name) := true;

      l_context := ut_suite_context(a_parent.object_owner, a_parent.object_name, l_context_name, l_context_pos );
      l_context.path := a_parent.path||'.'||l_context_name;
      l_context.description := coalesce( a_annotations.by_line( l_context_pos ).text, l_context_name );
      l_context.parse_time  := a_annotations.parse_time;

      --if nested context found
      if has_nested_context(l_context_pos, a_annotations.by_name) then
        get_context_items( l_context, a_annotations, l_context_items, l_context_pos, l_end_context_pos );
      else
        l_context_items  := ut_suite_items();
      end if;

      if l_end_context_pos is null then
        a_parent.put_warning(
          'Missing "--%endcontext" annotation for a "--%context" annotation. The end of package is considered end of context.',
          null,
          l_context_pos
        );
        l_end_context_pos := a_annotations.by_line.last;
      end if;

      --create a sub-set of annotations to process as sub-suite (context)
      l_ctx_annotations := get_annotations_in_context( a_annotations, l_context_pos, l_end_context_pos);

      warning_on_duplicate_annot( l_context, l_ctx_annotations.by_name, gc_context );

      add_tests_to_items( l_context, l_ctx_annotations, l_context_items );
      add_items_to_list(a_suite_items, l_context_items);
      a_suite_items.extend;
      a_suite_items(a_suite_items.last) := l_context;
      -- remove annotations within context after processing them
      delete_annotations_range(a_annotations, l_context_pos, l_end_context_pos);

      exit when not a_annotations.by_name.exists( gc_context);

      l_context_pos := a_annotations.by_name( gc_context).next( l_context_pos);
      -- don't go on when the next context is outside the parent's context boundaries
      if (a_parent_end_context_pos <= l_context_pos ) then
        l_context_pos := null;
      end if;
      l_context_no := l_context_no + 1;
    end loop;
  end;

  procedure warning_on_extra_endcontext(
    a_suite              in out nocopy ut_suite,
    a_package_ann_index  tt_annotations_by_name
  ) is
    l_annotation_pos  t_annotation_position;
  begin
    if a_package_ann_index.exists(gc_endcontext) then
      l_annotation_pos := a_package_ann_index(gc_endcontext).first;
      while l_annotation_pos is not null loop
        add_annotation_ignored_warning(
            a_suite, gc_endcontext, 'Extra %%% annotation found. Cannot find corresponding "--%context".',
            l_annotation_pos
        );
        l_annotation_pos := a_package_ann_index(gc_endcontext).next(l_annotation_pos);
      end loop;
    end if;
  end;

  procedure warning_on_unknown_annotations(
    a_suite in out nocopy ut_suite_item,
    a_annotations tt_annotations_by_line
  ) is
    l_line_no t_annotation_position :=  a_annotations.first;
  begin
    while l_line_no is not null loop
      if a_annotations(l_line_no).name not member of (gc_supported_annotations) then
        add_annotation_ignored_warning(
            a_suite,
            a_annotations(l_line_no).name,
            'Unsupported annotation %%%.',
            l_line_no,
            a_annotations(l_line_no).procedure_name
        );
      end if;
      l_line_no := a_annotations.next(l_line_no);
    end loop;
  end;

  function convert_package_annotations(a_object ut_annotated_object) return t_annotations_info is
    l_result          t_annotations_info;
    l_annotation      t_annotation;
    l_annotation_no   binary_integer;
    l_annotation_pos  binary_integer;
  begin
    l_result.owner := a_object.object_owner;
    l_result.name  := lower(trim(a_object.object_name));
    l_result.parse_time := a_object.parse_time;
    l_annotation_no := a_object.annotations.first;
    while l_annotation_no is not null loop
      l_annotation_pos  := a_object.annotations(l_annotation_no).position;
      l_annotation.name := a_object.annotations(l_annotation_no).name;
      l_annotation.text := a_object.annotations(l_annotation_no).text;
      l_annotation.procedure_name := lower(trim(a_object.annotations(l_annotation_no).subobject_name));
      l_result.by_line( l_annotation_pos) := l_annotation;
      if l_annotation.procedure_name is null then
        l_result.by_name( l_annotation.name)( l_annotation_pos) := l_annotation.text;
      else
        l_result.by_proc(l_annotation.procedure_name)(l_annotation.name)(l_annotation_pos) := l_annotation.text;
      end if;
      l_annotation_no := a_object.annotations.next(l_annotation_no);
    end loop;
    return l_result;
  end;

  procedure create_suite_item_list( a_annotated_object ut_annotated_object, a_suite_items out nocopy ut_suite_items ) is
    l_annotations      t_annotations_info;
    l_annotation_pos   t_annotation_position;
    l_suite            ut_suite;
  begin
    l_annotations := convert_package_annotations( a_annotated_object );

    if l_annotations.by_name.exists(gc_suite) then
      l_annotation_pos := l_annotations.by_name(gc_suite).first;
      l_suite := ut_suite(l_annotations.owner, l_annotations.name, l_annotation_pos);
      l_suite.description := l_annotations.by_name( gc_suite)( l_annotation_pos);
      l_suite.parse_time  := l_annotations.parse_time;
      warning_on_unknown_annotations(l_suite, l_annotations.by_line);

      warning_on_duplicate_annot( l_suite, l_annotations.by_name, gc_suite );

      build_suitepath( l_suite, l_annotations );
      get_context_items( l_suite, l_annotations, a_suite_items );
      --create suite tests and add
      add_tests_to_items( l_suite, l_annotations, a_suite_items );

      --by this time all contexts were consumed and l_annotations should not have any context/endcontext annotation in it.
      warning_on_extra_endcontext( l_suite, l_annotations.by_name );

      a_suite_items.extend;
      a_suite_items( a_suite_items.last) := l_suite;
    end if;
  end;

end ut_suite_builder;
/
