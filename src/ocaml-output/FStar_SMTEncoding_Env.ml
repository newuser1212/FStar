open Prims
exception Inner_let_rec 
let (uu___is_Inner_let_rec : Prims.exn -> Prims.bool) =
  fun projectee  ->
    match projectee with | Inner_let_rec  -> true | uu____67722 -> false
  
let add_fuel :
  'Auu____67731 .
    'Auu____67731 -> 'Auu____67731 Prims.list -> 'Auu____67731 Prims.list
  =
  fun x  ->
    fun tl1  ->
      let uu____67748 = FStar_Options.unthrottle_inductives ()  in
      if uu____67748 then tl1 else x :: tl1
  
let withenv :
  'Auu____67766 'Auu____67767 'Auu____67768 .
    'Auu____67766 ->
      ('Auu____67767 * 'Auu____67768) ->
        ('Auu____67767 * 'Auu____67768 * 'Auu____67766)
  = fun c  -> fun uu____67788  -> match uu____67788 with | (a,b) -> (a, b, c) 
let vargs :
  'Auu____67804 'Auu____67805 'Auu____67806 .
    (('Auu____67804,'Auu____67805) FStar_Util.either * 'Auu____67806)
      Prims.list ->
      (('Auu____67804,'Auu____67805) FStar_Util.either * 'Auu____67806)
        Prims.list
  =
  fun args  ->
    FStar_List.filter
      (fun uu___596_67853  ->
         match uu___596_67853 with
         | (FStar_Util.Inl uu____67863,uu____67864) -> false
         | uu____67870 -> true) args
  
let (escape : Prims.string -> Prims.string) =
  fun s  -> FStar_Util.replace_char s 39 95 
let (mk_term_projector_name :
  FStar_Ident.lident -> FStar_Syntax_Syntax.bv -> Prims.string) =
  fun lid  ->
    fun a  ->
      let uu____67903 =
        FStar_Util.format2 "%s_%s" lid.FStar_Ident.str
          (a.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
         in
      FStar_All.pipe_left escape uu____67903
  
let (primitive_projector_by_pos :
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident -> Prims.int -> Prims.string)
  =
  fun env  ->
    fun lid  ->
      fun i  ->
        let fail1 uu____67933 =
          let uu____67934 =
            FStar_Util.format2
              "Projector %s on data constructor %s not found"
              (Prims.string_of_int i) lid.FStar_Ident.str
             in
          failwith uu____67934  in
        let uu____67938 = FStar_TypeChecker_Env.lookup_datacon env lid  in
        match uu____67938 with
        | (uu____67944,t) ->
            let uu____67946 =
              let uu____67947 = FStar_Syntax_Subst.compress t  in
              uu____67947.FStar_Syntax_Syntax.n  in
            (match uu____67946 with
             | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
                 let uu____67973 = FStar_Syntax_Subst.open_comp bs c  in
                 (match uu____67973 with
                  | (binders,uu____67980) ->
                      if
                        (i < (Prims.parse_int "0")) ||
                          (i >= (FStar_List.length binders))
                      then fail1 ()
                      else
                        (let b = FStar_List.nth binders i  in
                         mk_term_projector_name lid
                           (FStar_Pervasives_Native.fst b)))
             | uu____68007 -> fail1 ())
  
let (mk_term_projector_name_by_pos :
  FStar_Ident.lident -> Prims.int -> Prims.string) =
  fun lid  ->
    fun i  ->
      let uu____68022 =
        FStar_Util.format2 "%s_%s" lid.FStar_Ident.str
          (Prims.string_of_int i)
         in
      FStar_All.pipe_left escape uu____68022
  
let (mk_term_projector :
  FStar_Ident.lident -> FStar_Syntax_Syntax.bv -> FStar_SMTEncoding_Term.term)
  =
  fun lid  ->
    fun a  ->
      let uu____68038 =
        let uu____68039 =
          let uu____68045 = mk_term_projector_name lid a  in
          (uu____68045,
            (FStar_SMTEncoding_Term.Arrow
               (FStar_SMTEncoding_Term.Term_sort,
                 FStar_SMTEncoding_Term.Term_sort)))
           in
        FStar_SMTEncoding_Term.mk_fv uu____68039  in
      FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV uu____68038
  
let (mk_term_projector_by_pos :
  FStar_Ident.lident -> Prims.int -> FStar_SMTEncoding_Term.term) =
  fun lid  ->
    fun i  ->
      let uu____68061 =
        let uu____68062 =
          let uu____68068 = mk_term_projector_name_by_pos lid i  in
          (uu____68068,
            (FStar_SMTEncoding_Term.Arrow
               (FStar_SMTEncoding_Term.Term_sort,
                 FStar_SMTEncoding_Term.Term_sort)))
           in
        FStar_SMTEncoding_Term.mk_fv uu____68062  in
      FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV uu____68061
  
let mk_data_tester :
  'Auu____68080 .
    'Auu____68080 ->
      FStar_Ident.lident ->
        FStar_SMTEncoding_Term.term -> FStar_SMTEncoding_Term.term
  =
  fun env  ->
    fun l  ->
      fun x  -> FStar_SMTEncoding_Term.mk_tester (escape l.FStar_Ident.str) x
  
type varops_t =
  {
  push: unit -> unit ;
  pop: unit -> unit ;
  snapshot: unit -> (Prims.int * unit) ;
  rollback: Prims.int FStar_Pervasives_Native.option -> unit ;
  new_var: FStar_Ident.ident -> Prims.int -> Prims.string ;
  new_fvar: FStar_Ident.lident -> Prims.string ;
  fresh: Prims.string -> Prims.string -> Prims.string ;
  reset_fresh: unit -> unit ;
  string_const: Prims.string -> FStar_SMTEncoding_Term.term ;
  next_id: unit -> Prims.int ;
  mk_unique: Prims.string -> Prims.string }
let (__proj__Mkvarops_t__item__push : varops_t -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> push1
  
let (__proj__Mkvarops_t__item__pop : varops_t -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> pop1
  
let (__proj__Mkvarops_t__item__snapshot :
  varops_t -> unit -> (Prims.int * unit)) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> snapshot1
  
let (__proj__Mkvarops_t__item__rollback :
  varops_t -> Prims.int FStar_Pervasives_Native.option -> unit) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> rollback1
  
let (__proj__Mkvarops_t__item__new_var :
  varops_t -> FStar_Ident.ident -> Prims.int -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> new_var
  
let (__proj__Mkvarops_t__item__new_fvar :
  varops_t -> FStar_Ident.lident -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> new_fvar
  
let (__proj__Mkvarops_t__item__fresh :
  varops_t -> Prims.string -> Prims.string -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> fresh1
  
let (__proj__Mkvarops_t__item__reset_fresh : varops_t -> unit -> unit) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> reset_fresh
  
let (__proj__Mkvarops_t__item__string_const :
  varops_t -> Prims.string -> FStar_SMTEncoding_Term.term) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> string_const
  
let (__proj__Mkvarops_t__item__next_id : varops_t -> unit -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> next_id1
  
let (__proj__Mkvarops_t__item__mk_unique :
  varops_t -> Prims.string -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { push = push1; pop = pop1; snapshot = snapshot1; rollback = rollback1;
        new_var; new_fvar; fresh = fresh1; reset_fresh; string_const;
        next_id = next_id1; mk_unique;_} -> mk_unique
  
let (varops : varops_t) =
  let initial_ctr = (Prims.parse_int "100")  in
  let ctr = FStar_Util.mk_ref initial_ctr  in
  let new_scope uu____69198 =
    let uu____69199 = FStar_Util.smap_create (Prims.parse_int "100")  in
    let uu____69205 = FStar_Util.smap_create (Prims.parse_int "100")  in
    (uu____69199, uu____69205)  in
  let scopes =
    let uu____69228 = let uu____69240 = new_scope ()  in [uu____69240]  in
    FStar_Util.mk_ref uu____69228  in
  let mk_unique y =
    let y1 = escape y  in
    let y2 =
      let uu____69292 =
        let uu____69296 = FStar_ST.op_Bang scopes  in
        FStar_Util.find_map uu____69296
          (fun uu____69384  ->
             match uu____69384 with
             | (names1,uu____69398) -> FStar_Util.smap_try_find names1 y1)
         in
      match uu____69292 with
      | FStar_Pervasives_Native.None  -> y1
      | FStar_Pervasives_Native.Some uu____69412 ->
          (FStar_Util.incr ctr;
           (let uu____69449 =
              let uu____69451 =
                let uu____69453 = FStar_ST.op_Bang ctr  in
                Prims.string_of_int uu____69453  in
              Prims.op_Hat "__" uu____69451  in
            Prims.op_Hat y1 uu____69449))
       in
    let top_scope =
      let uu____69503 =
        let uu____69513 = FStar_ST.op_Bang scopes  in
        FStar_List.hd uu____69513  in
      FStar_All.pipe_left FStar_Pervasives_Native.fst uu____69503  in
    FStar_Util.smap_add top_scope y2 true; y2  in
  let new_var pp rn =
    FStar_All.pipe_left mk_unique
      (Prims.op_Hat pp.FStar_Ident.idText
         (Prims.op_Hat "__" (Prims.string_of_int rn)))
     in
  let new_fvar lid = mk_unique lid.FStar_Ident.str  in
  let next_id1 uu____69647 = FStar_Util.incr ctr; FStar_ST.op_Bang ctr  in
  let fresh1 mname pfx =
    let uu____69741 =
      let uu____69743 = next_id1 ()  in
      FStar_All.pipe_left Prims.string_of_int uu____69743  in
    FStar_Util.format3 "%s_%s_%s" pfx mname uu____69741  in
  let reset_fresh uu____69753 = FStar_ST.op_Colon_Equals ctr initial_ctr  in
  let string_const s =
    let uu____69805 =
      let uu____69808 = FStar_ST.op_Bang scopes  in
      FStar_Util.find_map uu____69808
        (fun uu____69895  ->
           match uu____69895 with
           | (uu____69907,strings) -> FStar_Util.smap_try_find strings s)
       in
    match uu____69805 with
    | FStar_Pervasives_Native.Some f -> f
    | FStar_Pervasives_Native.None  ->
        let id1 = next_id1 ()  in
        let f =
          let uu____69923 = FStar_SMTEncoding_Util.mk_String_const id1  in
          FStar_All.pipe_left FStar_SMTEncoding_Term.boxString uu____69923
           in
        let top_scope =
          let uu____69927 =
            let uu____69937 = FStar_ST.op_Bang scopes  in
            FStar_List.hd uu____69937  in
          FStar_All.pipe_left FStar_Pervasives_Native.snd uu____69927  in
        (FStar_Util.smap_add top_scope s f; f)
     in
  let push1 uu____70043 =
    let uu____70044 =
      let uu____70056 = new_scope ()  in
      let uu____70066 = FStar_ST.op_Bang scopes  in uu____70056 ::
        uu____70066
       in
    FStar_ST.op_Colon_Equals scopes uu____70044  in
  let pop1 uu____70218 =
    let uu____70219 =
      let uu____70231 = FStar_ST.op_Bang scopes  in FStar_List.tl uu____70231
       in
    FStar_ST.op_Colon_Equals scopes uu____70219  in
  let snapshot1 uu____70388 = FStar_Common.snapshot push1 scopes ()  in
  let rollback1 depth = FStar_Common.rollback pop1 scopes depth  in
  {
    push = push1;
    pop = pop1;
    snapshot = snapshot1;
    rollback = rollback1;
    new_var;
    new_fvar;
    fresh = fresh1;
    reset_fresh;
    string_const;
    next_id = next_id1;
    mk_unique
  } 
type fvar_binding =
  {
  fvar_lid: FStar_Ident.lident ;
  smt_arity: Prims.int ;
  smt_id: Prims.string ;
  smt_token: FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ;
  smt_fuel_partial_app:
    FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ;
  fvb_thunked: Prims.bool }
let (__proj__Mkfvar_binding__item__fvar_lid :
  fvar_binding -> FStar_Ident.lident) =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> fvar_lid
  
let (__proj__Mkfvar_binding__item__smt_arity : fvar_binding -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> smt_arity
  
let (__proj__Mkfvar_binding__item__smt_id : fvar_binding -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> smt_id
  
let (__proj__Mkfvar_binding__item__smt_token :
  fvar_binding -> FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option)
  =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> smt_token
  
let (__proj__Mkfvar_binding__item__smt_fuel_partial_app :
  fvar_binding -> FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option)
  =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> smt_fuel_partial_app
  
let (__proj__Mkfvar_binding__item__fvb_thunked : fvar_binding -> Prims.bool)
  =
  fun projectee  ->
    match projectee with
    | { fvar_lid; smt_arity; smt_id; smt_token; smt_fuel_partial_app;
        fvb_thunked;_} -> fvb_thunked
  
let (check_valid_fvb : fvar_binding -> unit) =
  fun fvb  ->
    if
      ((FStar_Option.isSome fvb.smt_token) ||
         (FStar_Option.isSome fvb.smt_fuel_partial_app))
        && fvb.fvb_thunked
    then
      let uu____70635 =
        let uu____70637 = FStar_Ident.string_of_lid fvb.fvar_lid  in
        FStar_Util.format1 "Unexpected thunked SMT symbol: %s" uu____70637
         in
      failwith uu____70635
    else
      if fvb.fvb_thunked && (fvb.smt_arity <> (Prims.parse_int "0"))
      then
        (let uu____70645 =
           let uu____70647 = FStar_Ident.string_of_lid fvb.fvar_lid  in
           FStar_Util.format1 "Unexpected arity of thunked SMT symbol: %s"
             uu____70647
            in
         failwith uu____70645)
      else ()
  
let binder_of_eithervar :
  'Auu____70659 'Auu____70660 .
    'Auu____70659 ->
      ('Auu____70659 * 'Auu____70660 FStar_Pervasives_Native.option)
  = fun v1  -> (v1, FStar_Pervasives_Native.None) 
type env_t =
  {
  bvar_bindings:
    (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.term) FStar_Util.pimap
      FStar_Util.psmap
    ;
  fvar_bindings: (fvar_binding FStar_Util.psmap * fvar_binding Prims.list) ;
  depth: Prims.int ;
  tcenv: FStar_TypeChecker_Env.env ;
  warn: Prims.bool ;
  nolabels: Prims.bool ;
  use_zfuel_name: Prims.bool ;
  encode_non_total_function_typ: Prims.bool ;
  current_module_name: Prims.string ;
  encoding_quantifier: Prims.bool ;
  global_cache: FStar_SMTEncoding_Term.decls_elt FStar_Util.smap }
let (__proj__Mkenv_t__item__bvar_bindings :
  env_t ->
    (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.term) FStar_Util.pimap
      FStar_Util.psmap)
  =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> bvar_bindings
  
let (__proj__Mkenv_t__item__fvar_bindings :
  env_t -> (fvar_binding FStar_Util.psmap * fvar_binding Prims.list)) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> fvar_bindings
  
let (__proj__Mkenv_t__item__depth : env_t -> Prims.int) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> depth
  
let (__proj__Mkenv_t__item__tcenv : env_t -> FStar_TypeChecker_Env.env) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> tcenv
  
let (__proj__Mkenv_t__item__warn : env_t -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> warn
  
let (__proj__Mkenv_t__item__nolabels : env_t -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> nolabels
  
let (__proj__Mkenv_t__item__use_zfuel_name : env_t -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> use_zfuel_name
  
let (__proj__Mkenv_t__item__encode_non_total_function_typ :
  env_t -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> encode_non_total_function_typ
  
let (__proj__Mkenv_t__item__current_module_name : env_t -> Prims.string) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> current_module_name
  
let (__proj__Mkenv_t__item__encoding_quantifier : env_t -> Prims.bool) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> encoding_quantifier
  
let (__proj__Mkenv_t__item__global_cache :
  env_t -> FStar_SMTEncoding_Term.decls_elt FStar_Util.smap) =
  fun projectee  ->
    match projectee with
    | { bvar_bindings; fvar_bindings; depth; tcenv; warn; nolabels;
        use_zfuel_name; encode_non_total_function_typ; current_module_name;
        encoding_quantifier; global_cache;_} -> global_cache
  
let (print_env : env_t -> Prims.string) =
  fun e  ->
    let bvars =
      FStar_Util.psmap_fold e.bvar_bindings
        (fun _k  ->
           fun pi  ->
             fun acc  ->
               FStar_Util.pimap_fold pi
                 (fun _i  ->
                    fun uu____71316  ->
                      fun acc1  ->
                        match uu____71316 with
                        | (x,_term) ->
                            let uu____71331 =
                              FStar_Syntax_Print.bv_to_string x  in
                            uu____71331 :: acc1) acc) []
       in
    let allvars =
      let uu____71338 =
        FStar_All.pipe_right e.fvar_bindings FStar_Pervasives_Native.fst  in
      FStar_Util.psmap_fold uu____71338
        (fun _k  -> fun fvb  -> fun acc  -> (fvb.fvar_lid) :: acc) []
       in
    let last_fvar =
      match FStar_List.rev allvars with
      | [] -> ""
      | l::uu____71371 ->
          let uu____71374 = FStar_Syntax_Print.lid_to_string l  in
          Prims.op_Hat "...," uu____71374
       in
    FStar_String.concat ", " (last_fvar :: bvars)
  
let (lookup_bvar_binding :
  env_t ->
    FStar_Syntax_Syntax.bv ->
      (FStar_Syntax_Syntax.bv * FStar_SMTEncoding_Term.term)
        FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun bv  ->
      let uu____71396 =
        FStar_Util.psmap_try_find env.bvar_bindings
          (bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
         in
      match uu____71396 with
      | FStar_Pervasives_Native.Some bvs ->
          FStar_Util.pimap_try_find bvs bv.FStar_Syntax_Syntax.index
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
  
let (lookup_fvar_binding :
  env_t -> FStar_Ident.lident -> fvar_binding FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun lid  ->
      let uu____71457 =
        FStar_All.pipe_right env.fvar_bindings FStar_Pervasives_Native.fst
         in
      FStar_Util.psmap_try_find uu____71457 lid.FStar_Ident.str
  
let add_bvar_binding :
  'Auu____71481 .
    (FStar_Syntax_Syntax.bv * 'Auu____71481) ->
      (FStar_Syntax_Syntax.bv * 'Auu____71481) FStar_Util.pimap
        FStar_Util.psmap ->
        (FStar_Syntax_Syntax.bv * 'Auu____71481) FStar_Util.pimap
          FStar_Util.psmap
  =
  fun bvb  ->
    fun bvbs  ->
      FStar_Util.psmap_modify bvbs
        ((FStar_Pervasives_Native.fst bvb).FStar_Syntax_Syntax.ppname).FStar_Ident.idText
        (fun pimap_opt  ->
           let uu____71541 =
             let uu____71548 = FStar_Util.pimap_empty ()  in
             FStar_Util.dflt uu____71548 pimap_opt  in
           FStar_Util.pimap_add uu____71541
             (FStar_Pervasives_Native.fst bvb).FStar_Syntax_Syntax.index bvb)
  
let (add_fvar_binding :
  fvar_binding ->
    (fvar_binding FStar_Util.psmap * fvar_binding Prims.list) ->
      (fvar_binding FStar_Util.psmap * fvar_binding Prims.list))
  =
  fun fvb  ->
    fun uu____71595  ->
      match uu____71595 with
      | (fvb_map,fvb_list) ->
          let uu____71622 =
            FStar_Util.psmap_add fvb_map (fvb.fvar_lid).FStar_Ident.str fvb
             in
          (uu____71622, (fvb :: fvb_list))
  
let (fresh_fvar :
  Prims.string ->
    Prims.string ->
      FStar_SMTEncoding_Term.sort ->
        (Prims.string * FStar_SMTEncoding_Term.term))
  =
  fun mname  ->
    fun x  ->
      fun s  ->
        let xsym = varops.fresh mname x  in
        let uu____71656 =
          let uu____71657 = FStar_SMTEncoding_Term.mk_fv (xsym, s)  in
          FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV uu____71657  in
        (xsym, uu____71656)
  
let (gen_term_var :
  env_t ->
    FStar_Syntax_Syntax.bv ->
      (Prims.string * FStar_SMTEncoding_Term.term * env_t))
  =
  fun env  ->
    fun x  ->
      let ysym = Prims.op_Hat "@x" (Prims.string_of_int env.depth)  in
      let y =
        let uu____71682 =
          FStar_SMTEncoding_Term.mk_fv
            (ysym, FStar_SMTEncoding_Term.Term_sort)
           in
        FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV uu____71682  in
      let uu____71684 =
        let uu___821_71685 = env  in
        let uu____71686 = add_bvar_binding (x, y) env.bvar_bindings  in
        {
          bvar_bindings = uu____71686;
          fvar_bindings = (uu___821_71685.fvar_bindings);
          depth = (env.depth + (Prims.parse_int "1"));
          tcenv = (uu___821_71685.tcenv);
          warn = (uu___821_71685.warn);
          nolabels = (uu___821_71685.nolabels);
          use_zfuel_name = (uu___821_71685.use_zfuel_name);
          encode_non_total_function_typ =
            (uu___821_71685.encode_non_total_function_typ);
          current_module_name = (uu___821_71685.current_module_name);
          encoding_quantifier = (uu___821_71685.encoding_quantifier);
          global_cache = (uu___821_71685.global_cache)
        }  in
      (ysym, y, uu____71684)
  
let (new_term_constant :
  env_t ->
    FStar_Syntax_Syntax.bv ->
      (Prims.string * FStar_SMTEncoding_Term.term * env_t))
  =
  fun env  ->
    fun x  ->
      let ysym =
        varops.new_var x.FStar_Syntax_Syntax.ppname
          x.FStar_Syntax_Syntax.index
         in
      let y = FStar_SMTEncoding_Util.mkApp (ysym, [])  in
      let uu____71721 =
        let uu___827_71722 = env  in
        let uu____71723 = add_bvar_binding (x, y) env.bvar_bindings  in
        {
          bvar_bindings = uu____71723;
          fvar_bindings = (uu___827_71722.fvar_bindings);
          depth = (uu___827_71722.depth);
          tcenv = (uu___827_71722.tcenv);
          warn = (uu___827_71722.warn);
          nolabels = (uu___827_71722.nolabels);
          use_zfuel_name = (uu___827_71722.use_zfuel_name);
          encode_non_total_function_typ =
            (uu___827_71722.encode_non_total_function_typ);
          current_module_name = (uu___827_71722.current_module_name);
          encoding_quantifier = (uu___827_71722.encoding_quantifier);
          global_cache = (uu___827_71722.global_cache)
        }  in
      (ysym, y, uu____71721)
  
let (new_term_constant_from_string :
  env_t ->
    FStar_Syntax_Syntax.bv ->
      Prims.string -> (Prims.string * FStar_SMTEncoding_Term.term * env_t))
  =
  fun env  ->
    fun x  ->
      fun str  ->
        let ysym = varops.mk_unique str  in
        let y = FStar_SMTEncoding_Util.mkApp (ysym, [])  in
        let uu____71764 =
          let uu___834_71765 = env  in
          let uu____71766 = add_bvar_binding (x, y) env.bvar_bindings  in
          {
            bvar_bindings = uu____71766;
            fvar_bindings = (uu___834_71765.fvar_bindings);
            depth = (uu___834_71765.depth);
            tcenv = (uu___834_71765.tcenv);
            warn = (uu___834_71765.warn);
            nolabels = (uu___834_71765.nolabels);
            use_zfuel_name = (uu___834_71765.use_zfuel_name);
            encode_non_total_function_typ =
              (uu___834_71765.encode_non_total_function_typ);
            current_module_name = (uu___834_71765.current_module_name);
            encoding_quantifier = (uu___834_71765.encoding_quantifier);
            global_cache = (uu___834_71765.global_cache)
          }  in
        (ysym, y, uu____71764)
  
let (push_term_var :
  env_t -> FStar_Syntax_Syntax.bv -> FStar_SMTEncoding_Term.term -> env_t) =
  fun env  ->
    fun x  ->
      fun t  ->
        let uu___839_71792 = env  in
        let uu____71793 = add_bvar_binding (x, t) env.bvar_bindings  in
        {
          bvar_bindings = uu____71793;
          fvar_bindings = (uu___839_71792.fvar_bindings);
          depth = (uu___839_71792.depth);
          tcenv = (uu___839_71792.tcenv);
          warn = (uu___839_71792.warn);
          nolabels = (uu___839_71792.nolabels);
          use_zfuel_name = (uu___839_71792.use_zfuel_name);
          encode_non_total_function_typ =
            (uu___839_71792.encode_non_total_function_typ);
          current_module_name = (uu___839_71792.current_module_name);
          encoding_quantifier = (uu___839_71792.encoding_quantifier);
          global_cache = (uu___839_71792.global_cache)
        }
  
let (lookup_term_var :
  env_t -> FStar_Syntax_Syntax.bv -> FStar_SMTEncoding_Term.term) =
  fun env  ->
    fun a  ->
      let uu____71813 = lookup_bvar_binding env a  in
      match uu____71813 with
      | FStar_Pervasives_Native.None  ->
          let uu____71824 = lookup_bvar_binding env a  in
          (match uu____71824 with
           | FStar_Pervasives_Native.None  ->
               let uu____71835 =
                 let uu____71837 = FStar_Syntax_Print.bv_to_string a  in
                 let uu____71839 = print_env env  in
                 FStar_Util.format2
                   "Bound term variable not found  %s in environment: %s"
                   uu____71837 uu____71839
                  in
               failwith uu____71835
           | FStar_Pervasives_Native.Some (b,t) -> t)
      | FStar_Pervasives_Native.Some (b,t) -> t
  
let (mk_fvb :
  FStar_Ident.lident ->
    Prims.string ->
      Prims.int ->
        FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
          FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
            Prims.bool -> fvar_binding)
  =
  fun lid  ->
    fun fname  ->
      fun arity  ->
        fun ftok  ->
          fun fuel_partial_app  ->
            fun thunked  ->
              let fvb =
                {
                  fvar_lid = lid;
                  smt_arity = arity;
                  smt_id = fname;
                  smt_token = ftok;
                  smt_fuel_partial_app = fuel_partial_app;
                  fvb_thunked = thunked
                }  in
              check_valid_fvb fvb; fvb
  
let (new_term_constant_and_tok_from_lid_aux :
  env_t ->
    FStar_Ident.lident ->
      Prims.int ->
        Prims.bool ->
          (Prims.string * Prims.string FStar_Pervasives_Native.option *
            env_t))
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        fun thunked  ->
          let fname = varops.new_fvar x  in
          let uu____71938 =
            if thunked
            then (FStar_Pervasives_Native.None, FStar_Pervasives_Native.None)
            else
              (let ftok_name = Prims.op_Hat fname "@tok"  in
               let ftok = FStar_SMTEncoding_Util.mkApp (ftok_name, [])  in
               ((FStar_Pervasives_Native.Some ftok_name),
                 (FStar_Pervasives_Native.Some ftok)))
             in
          match uu____71938 with
          | (ftok_name,ftok) ->
              let fvb =
                mk_fvb x fname arity ftok FStar_Pervasives_Native.None
                  thunked
                 in
              let uu____72002 =
                let uu___873_72003 = env  in
                let uu____72004 = add_fvar_binding fvb env.fvar_bindings  in
                {
                  bvar_bindings = (uu___873_72003.bvar_bindings);
                  fvar_bindings = uu____72004;
                  depth = (uu___873_72003.depth);
                  tcenv = (uu___873_72003.tcenv);
                  warn = (uu___873_72003.warn);
                  nolabels = (uu___873_72003.nolabels);
                  use_zfuel_name = (uu___873_72003.use_zfuel_name);
                  encode_non_total_function_typ =
                    (uu___873_72003.encode_non_total_function_typ);
                  current_module_name = (uu___873_72003.current_module_name);
                  encoding_quantifier = (uu___873_72003.encoding_quantifier);
                  global_cache = (uu___873_72003.global_cache)
                }  in
              (fname, ftok_name, uu____72002)
  
let (new_term_constant_and_tok_from_lid :
  env_t ->
    FStar_Ident.lident -> Prims.int -> (Prims.string * Prims.string * env_t))
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        let uu____72043 =
          new_term_constant_and_tok_from_lid_aux env x arity false  in
        match uu____72043 with
        | (fname,ftok_name_opt,env1) ->
            let uu____72074 = FStar_Option.get ftok_name_opt  in
            (fname, uu____72074, env1)
  
let (new_term_constant_and_tok_from_lid_maybe_thunked :
  env_t ->
    FStar_Ident.lident ->
      Prims.int ->
        Prims.bool ->
          (Prims.string * Prims.string FStar_Pervasives_Native.option *
            env_t))
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        fun th  -> new_term_constant_and_tok_from_lid_aux env x arity th
  
let (lookup_lid : env_t -> FStar_Ident.lident -> fvar_binding) =
  fun env  ->
    fun a  ->
      let uu____72125 = lookup_fvar_binding env a  in
      match uu____72125 with
      | FStar_Pervasives_Native.None  ->
          let uu____72128 =
            let uu____72130 = FStar_Syntax_Print.lid_to_string a  in
            FStar_Util.format1 "Name not found: %s" uu____72130  in
          failwith uu____72128
      | FStar_Pervasives_Native.Some s -> (check_valid_fvb s; s)
  
let (push_free_var_maybe_thunked :
  env_t ->
    FStar_Ident.lident ->
      Prims.int ->
        Prims.string ->
          FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option ->
            Prims.bool -> env_t)
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        fun fname  ->
          fun ftok  ->
            fun thunked  ->
              let fvb =
                mk_fvb x fname arity ftok FStar_Pervasives_Native.None
                  thunked
                 in
              let uu___899_72177 = env  in
              let uu____72178 = add_fvar_binding fvb env.fvar_bindings  in
              {
                bvar_bindings = (uu___899_72177.bvar_bindings);
                fvar_bindings = uu____72178;
                depth = (uu___899_72177.depth);
                tcenv = (uu___899_72177.tcenv);
                warn = (uu___899_72177.warn);
                nolabels = (uu___899_72177.nolabels);
                use_zfuel_name = (uu___899_72177.use_zfuel_name);
                encode_non_total_function_typ =
                  (uu___899_72177.encode_non_total_function_typ);
                current_module_name = (uu___899_72177.current_module_name);
                encoding_quantifier = (uu___899_72177.encoding_quantifier);
                global_cache = (uu___899_72177.global_cache)
              }
  
let (push_free_var :
  env_t ->
    FStar_Ident.lident ->
      Prims.int ->
        Prims.string ->
          FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option -> env_t)
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        fun fname  ->
          fun ftok  ->
            push_free_var_maybe_thunked env x arity fname ftok false
  
let (push_free_var_thunk :
  env_t ->
    FStar_Ident.lident ->
      Prims.int ->
        Prims.string ->
          FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option -> env_t)
  =
  fun env  ->
    fun x  ->
      fun arity  ->
        fun fname  ->
          fun ftok  ->
            push_free_var_maybe_thunked env x arity fname ftok
              (arity = (Prims.parse_int "0"))
  
let (push_zfuel_name : env_t -> FStar_Ident.lident -> Prims.string -> env_t)
  =
  fun env  ->
    fun x  ->
      fun f  ->
        let fvb = lookup_lid env x  in
        let t3 =
          let uu____72278 =
            let uu____72286 =
              let uu____72289 = FStar_SMTEncoding_Util.mkApp ("ZFuel", [])
                 in
              [uu____72289]  in
            (f, uu____72286)  in
          FStar_SMTEncoding_Util.mkApp uu____72278  in
        let fvb1 =
          mk_fvb x fvb.smt_id fvb.smt_arity fvb.smt_token
            (FStar_Pervasives_Native.Some t3) false
           in
        let uu___917_72299 = env  in
        let uu____72300 = add_fvar_binding fvb1 env.fvar_bindings  in
        {
          bvar_bindings = (uu___917_72299.bvar_bindings);
          fvar_bindings = uu____72300;
          depth = (uu___917_72299.depth);
          tcenv = (uu___917_72299.tcenv);
          warn = (uu___917_72299.warn);
          nolabels = (uu___917_72299.nolabels);
          use_zfuel_name = (uu___917_72299.use_zfuel_name);
          encode_non_total_function_typ =
            (uu___917_72299.encode_non_total_function_typ);
          current_module_name = (uu___917_72299.current_module_name);
          encoding_quantifier = (uu___917_72299.encoding_quantifier);
          global_cache = (uu___917_72299.global_cache)
        }
  
let (force_thunk : fvar_binding -> FStar_SMTEncoding_Term.term) =
  fun fvb  ->
    if
      (Prims.op_Negation fvb.fvb_thunked) ||
        (fvb.smt_arity <> (Prims.parse_int "0"))
    then failwith "Forcing a non-thunk in the SMT encoding"
    else ();
    FStar_All.pipe_left FStar_SMTEncoding_Util.mkFreeV
      ((fvb.smt_id), FStar_SMTEncoding_Term.Term_sort, true)
  
let (try_lookup_free_var :
  env_t ->
    FStar_Ident.lident ->
      FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun l  ->
      let uu____72338 = lookup_fvar_binding env l  in
      match uu____72338 with
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
      | FStar_Pervasives_Native.Some fvb ->
          if fvb.fvb_thunked
          then
            let uu____72347 = force_thunk fvb  in
            FStar_Pervasives_Native.Some uu____72347
          else
            (match fvb.smt_fuel_partial_app with
             | FStar_Pervasives_Native.Some f when env.use_zfuel_name ->
                 FStar_Pervasives_Native.Some f
             | uu____72353 ->
                 (match fvb.smt_token with
                  | FStar_Pervasives_Native.Some t ->
                      (match t.FStar_SMTEncoding_Term.tm with
                       | FStar_SMTEncoding_Term.App (uu____72361,fuel::[]) ->
                           let uu____72365 =
                             let uu____72367 =
                               let uu____72369 =
                                 FStar_SMTEncoding_Term.fv_of_term fuel  in
                               FStar_All.pipe_right uu____72369
                                 FStar_SMTEncoding_Term.fv_name
                                in
                             FStar_Util.starts_with uu____72367 "fuel"  in
                           if uu____72365
                           then
                             let uu____72375 =
                               let uu____72376 =
                                 let uu____72377 =
                                   FStar_SMTEncoding_Term.mk_fv
                                     ((fvb.smt_id),
                                       FStar_SMTEncoding_Term.Term_sort)
                                    in
                                 FStar_All.pipe_left
                                   FStar_SMTEncoding_Util.mkFreeV uu____72377
                                  in
                               FStar_SMTEncoding_Term.mk_ApplyTF uu____72376
                                 fuel
                                in
                             FStar_All.pipe_left
                               (fun _72381  ->
                                  FStar_Pervasives_Native.Some _72381)
                               uu____72375
                           else FStar_Pervasives_Native.Some t
                       | uu____72384 -> FStar_Pervasives_Native.Some t)
                  | uu____72385 -> FStar_Pervasives_Native.None))
  
let (lookup_free_var :
  env_t ->
    FStar_Ident.lid FStar_Syntax_Syntax.withinfo_t ->
      FStar_SMTEncoding_Term.term)
  =
  fun env  ->
    fun a  ->
      let uu____72403 = try_lookup_free_var env a.FStar_Syntax_Syntax.v  in
      match uu____72403 with
      | FStar_Pervasives_Native.Some t -> t
      | FStar_Pervasives_Native.None  ->
          let uu____72407 =
            let uu____72409 =
              FStar_Syntax_Print.lid_to_string a.FStar_Syntax_Syntax.v  in
            FStar_Util.format1 "Name not found: %s" uu____72409  in
          failwith uu____72407
  
let (lookup_free_var_name :
  env_t -> FStar_Ident.lident FStar_Syntax_Syntax.withinfo_t -> fvar_binding)
  = fun env  -> fun a  -> lookup_lid env a.FStar_Syntax_Syntax.v 
let (lookup_free_var_sym :
  env_t ->
    FStar_Ident.lident FStar_Syntax_Syntax.withinfo_t ->
      ((FStar_SMTEncoding_Term.op,FStar_SMTEncoding_Term.term)
        FStar_Util.either * FStar_SMTEncoding_Term.term Prims.list *
        Prims.int))
  =
  fun env  ->
    fun a  ->
      let fvb = lookup_lid env a.FStar_Syntax_Syntax.v  in
      match fvb.smt_fuel_partial_app with
      | FStar_Pervasives_Native.Some
          { FStar_SMTEncoding_Term.tm = FStar_SMTEncoding_Term.App (g,zf);
            FStar_SMTEncoding_Term.freevars = uu____72471;
            FStar_SMTEncoding_Term.rng = uu____72472;_}
          when env.use_zfuel_name ->
          ((FStar_Util.Inl g), zf, (fvb.smt_arity + (Prims.parse_int "1")))
      | uu____72497 ->
          (match fvb.smt_token with
           | FStar_Pervasives_Native.None  when fvb.fvb_thunked ->
               let uu____72513 =
                 let uu____72518 = force_thunk fvb  in
                 FStar_Util.Inr uu____72518  in
               (uu____72513, [], (fvb.smt_arity))
           | FStar_Pervasives_Native.None  ->
               ((FStar_Util.Inl (FStar_SMTEncoding_Term.Var (fvb.smt_id))),
                 [], (fvb.smt_arity))
           | FStar_Pervasives_Native.Some sym ->
               (match sym.FStar_SMTEncoding_Term.tm with
                | FStar_SMTEncoding_Term.App (g,fuel::[]) ->
                    ((FStar_Util.Inl g), [fuel],
                      (fvb.smt_arity + (Prims.parse_int "1")))
                | uu____72559 ->
                    ((FStar_Util.Inl
                        (FStar_SMTEncoding_Term.Var (fvb.smt_id))), [],
                      (fvb.smt_arity))))
  
let (tok_of_name :
  env_t ->
    Prims.string ->
      FStar_SMTEncoding_Term.term FStar_Pervasives_Native.option)
  =
  fun env  ->
    fun nm  ->
      let uu____72582 =
        FStar_All.pipe_right env.fvar_bindings FStar_Pervasives_Native.fst
         in
      FStar_Util.psmap_find_map uu____72582
        (fun uu____72602  ->
           fun fvb  ->
             check_valid_fvb fvb;
             if fvb.smt_id = nm
             then fvb.smt_token
             else FStar_Pervasives_Native.None)
  
let (reset_current_module_fvbs : env_t -> env_t) =
  fun env  ->
    let uu___977_72618 = env  in
    let uu____72619 =
      let uu____72628 =
        FStar_All.pipe_right env.fvar_bindings FStar_Pervasives_Native.fst
         in
      (uu____72628, [])  in
    {
      bvar_bindings = (uu___977_72618.bvar_bindings);
      fvar_bindings = uu____72619;
      depth = (uu___977_72618.depth);
      tcenv = (uu___977_72618.tcenv);
      warn = (uu___977_72618.warn);
      nolabels = (uu___977_72618.nolabels);
      use_zfuel_name = (uu___977_72618.use_zfuel_name);
      encode_non_total_function_typ =
        (uu___977_72618.encode_non_total_function_typ);
      current_module_name = (uu___977_72618.current_module_name);
      encoding_quantifier = (uu___977_72618.encoding_quantifier);
      global_cache = (uu___977_72618.global_cache)
    }
  
let (get_current_module_fvbs : env_t -> fvar_binding Prims.list) =
  fun env  ->
    FStar_All.pipe_right env.fvar_bindings FStar_Pervasives_Native.snd
  
let (add_fvar_binding_to_env : fvar_binding -> env_t -> env_t) =
  fun fvb  ->
    fun env  ->
      let uu___982_72682 = env  in
      let uu____72683 = add_fvar_binding fvb env.fvar_bindings  in
      {
        bvar_bindings = (uu___982_72682.bvar_bindings);
        fvar_bindings = uu____72683;
        depth = (uu___982_72682.depth);
        tcenv = (uu___982_72682.tcenv);
        warn = (uu___982_72682.warn);
        nolabels = (uu___982_72682.nolabels);
        use_zfuel_name = (uu___982_72682.use_zfuel_name);
        encode_non_total_function_typ =
          (uu___982_72682.encode_non_total_function_typ);
        current_module_name = (uu___982_72682.current_module_name);
        encoding_quantifier = (uu___982_72682.encoding_quantifier);
        global_cache = (uu___982_72682.global_cache)
      }
  