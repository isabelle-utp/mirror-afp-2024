(*  Title:      Jinja/JVM/JVMListExample.thy
    ID:         $Id: JVMListExample.thy,v 1.10 2009-07-14 09:00:10 fhaftmann Exp $
    Author:     Stefan Berghofer, Gerwin Klein
*)

header {* \isaheader{Example for generating executable code from JVM semantics}\label{sec:JVMListExample} *}

theory JVMListExample
imports "../Common/SystemClasses" JVMExec Efficient_Nat
begin

definition list_name :: string
where
  "list_name == ''list''"

definition test_name :: string
where
  "test_name == ''test''"

definition val_name :: string
where
  "val_name == ''val''"

definition next_name :: string
where
  "next_name == ''next''"

definition append_name :: string
where
  "append_name == ''append''"

definition makelist_name :: string
where
  "makelist_name == ''makelist''"

definition append_ins :: bytecode
where
  "append_ins == 
       [Load 0,
        Getfield next_name list_name,
        Load 0,
        Getfield next_name list_name,
        Push Null,
        CmpEq,
        IfFalse 7,
        Pop,
        Load 0,
        Load 1,
        Putfield next_name list_name,
        Push Unit,
        Return,
        Load 1,       
        Invoke append_name 1,
        Return]"

definition list_class :: "jvm_method class"
where
  "list_class ==
    (Object,
     [(val_name, Integer), (next_name, Class list_name)],
     [(append_name, [Class list_name], Void,
        (3, 0, append_ins, [(1, 2, NullPointer, 7, 0)]))])"

definition make_list_ins :: bytecode
where
  "make_list_ins ==
       [New list_name,
        Store 0,
        Load 0,
        Push (Intg 1),
        Putfield val_name list_name,
        New list_name,
        Store 1,
        Load 1,
        Push (Intg 2),
        Putfield val_name list_name,
        New list_name,
        Store 2,
        Load 2,
        Push (Intg 3),
        Putfield val_name list_name,
        Load 0,
        Load 1,
        Invoke append_name 1,
        Pop,
        Load 0,
        Load 2,
        Invoke append_name 1,
        Return]"

definition test_class :: "jvm_method class"
where
  "test_class ==
    (Object, [],
     [(makelist_name, [], Void, (3, 2, make_list_ins, []))])"

definition E :: jvm_prog
where
  "E == SystemClasses @ [(list_name, list_class), (test_name, test_class)]"


consts_code
  "new_Addr"
   ("\<module>new'_addr {* 0::nat *} {* Suc *}
               {* %x. case x of None => True | Some y => False *} {* Some *}")
attach {*
fun new_addr z s alloc some hp =
  let fun nr i = if alloc (hp i) then some i else nr (s i);
  in nr z end;
*}

  "undefined" ("(error \"undefined\")")
  "undefined :: val" ("{* Unit *}")
  "undefined :: cname" ("Object")

declare method_def2 [unfolded Method_def, OF exI, OF conjI, code_ind]
declare fields_def2 [code_ind]
lemmas [code_unfold] = SystemClasses_def [unfolded ObjectC_def NullPointerC_def ClassCastC_def OutOfMemoryC_def]

subsection {* Single step execution *}

code_module JVM
contains
  test = "exec (E, start_state E test_name makelist_name)"

ML {* JVM.test *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* JVM.exec (JVM.E, JVM.the it) *}
ML {* val JVM.Some (_, (f, _)) = it *}
ML {* if snd (JVM.the (f 3)) (JVM.val_name, JVM.list_name) = JVM.Some (JVM.Intg 1) then () else error "wrong result" *}
ML {* if snd (JVM.the (f 3)) (JVM.next_name, JVM.list_name) = JVM.Some (JVM.Addr 4) then () else error "wrong result" *}
ML {* if snd (JVM.the (f 4)) (JVM.val_name, JVM.list_name) = JVM.Some (JVM.Intg 2) then () else error "wrong result" *}
ML {* if snd (JVM.the (f 4)) (JVM.next_name, JVM.list_name) = JVM.Some (JVM.Addr 5) then () else error "wrong result" *}
ML {* if snd (JVM.the (f 5)) (JVM.val_name, JVM.list_name) = JVM.Some (JVM.Intg 3) then () else error "wrong result" *}
ML {* if snd (JVM.the (f 5)) (JVM.next_name, JVM.list_name) = JVM.Some JVM.Null then () else error "wrong result" *}

end
