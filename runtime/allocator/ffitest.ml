open Camlstack;;

(* DEBUG *)
(*
type recd = { mutable field1: int; mutable field2: int };;

inspect ((1,ref 1));;
inspect ({ field1 = 1; field2 = 2 });;
*)

let doGC() =
  print_mask ();
  Gc.full_major()
  (* Gc.print_stat (Pervasives.stdout) *)
;;

(* BYTE ARRAYS *)

let make n c =
  let str = mkbytes n in
  for i = 0 to (n-1) do
    Bytes.set str i c
  done;
  str;;

push_frame 0;;

let s = make 10 'a';;
let s2 = make 35 '<';;
Printf.printf "|%s| |%s|\n" (Bytes.unsafe_to_string s) (Bytes.unsafe_to_string s2);;

pop_frame ();;

(* ARRAYS *)

push_frame 0;;

let arr = Camlstack.mkarray 10 [1;2];;
doGC();;
arr.(0) <- [];
arr.(1) <- [];
arr.(2) <- [];
try 
  (arr.(11) <- [])
with Invalid_argument(_) -> print_string "out of bounds access handled\n";;
try 
  ignore(Camlstack.mkarray 10 1.0)
with Invalid_argument(_) -> print_string "illegal array contents handled\n";;

doGC();;

pop_frame ();;

(* LISTS *)

push_frame 0;;

(* allocates a list on the stack, where the list elements point to heap-allocated lists *)
let rec mklist n =
  if n = 0 then []
  else
    let l = mklist (n-1) in
    cons (n::[1;2;3]) l 

(* makes a (heap-allocated) pretty-printed string of a list *)
let rec string_of_list l p =
  match l with
      [] -> "[]"
    | h::t -> 
      let s = string_of_list t p in 
      (p h)^"::"^s
;;

let ex = mklist 10;;

Printf.printf "List result = %s\n" (string_of_list ex (fun l -> "("^(string_of_list l string_of_int)^")"));;
doGC();;
Printf.printf "List result = %s\n" (string_of_list ex (fun l -> "("^(string_of_list l string_of_int)^")"));;

pop_frame ();;

(* REFERENCES *)

push_frame 0;;

let rec mkrefs n =
  if n = 0 then []
  else
    let l = mkrefs (n-1) in
    (mkref [])::l 

let rec modrefs l =
  match l with
      [] -> ()
    | h::t -> h := [1;2]; modrefs t

let ex = mkrefs 10;;
let p = mkref_noscan 1;;
doGC();;
let ex = modrefs ex;;
doGC();;

pop_frame ();;

(* DATATYPES *)

push_frame 0;;

type dt =
    A
  | B of int
  | C of int * int (* note that this is allocated as a two-word block, not a pointer to one *)
  | D of int list

(* The following would be generated by the compiler. They are all
   in ffitest.c. There's no constructor for A because it's not boxed. *)
external mkdt_B : int -> dt = "stack_mkdt_B";;
external mkdt_C : int -> int -> dt = "stack_mkdt_C";;
external mkdt_D : int list -> dt = "stack_mkdt_D";;

let check x = if x then () else failwith "assertion failed";;

(*
check((C (1,2)) = (mkdt_C 1 2));;
check((B 1) = (mkdt_B 1));;
check((D [5;6]) = (mkdt_D [5;6]));;
*)

inspect (B 1);;
inspect (mkdt_B 1);;
(* The following fails -- ICK! It seems that polymorphic equality doesn't 
   try to follow pointers outside of the OCaml heap? *)
(*
assert ((B 1) = (mkdt_B 1));;
*)
inspect (C(2,3));;
inspect (mkdt_C 2 3);;
inspect (D [4;5]);;
inspect (mkdt_D [4;5]);;

pop_frame ();;

(* ERROR HANDLING *)

doGC();;

let _ = 
  try 
    ignore(cons "hello" [])
  with Failure s -> 
    Printf.printf "Tried to allocate with no frames pushed\n"
;;

let _ = 
  try 
    ignore(pop_frame ())
  with Failure s -> 
    Printf.printf "Tried to pop a frame with no frames pushed\n"
;;

let _ = 
  try 
    ignore(push_frame (-1))
  with Invalid_argument s -> 
    Printf.printf "Tried to allocate negatively-sized frame\n"
;;
