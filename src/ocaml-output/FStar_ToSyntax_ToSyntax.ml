open Prims
let desugar_disjunctive_pattern:
  (FStar_Syntax_Syntax.pat',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.withinfo_t ->
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax option ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax -> FStar_Syntax_Syntax.branch Prims.list
  =
  fun pat  ->
    fun when_opt  ->
      fun branch1  ->
        match pat.FStar_Syntax_Syntax.v with
        | FStar_Syntax_Syntax.Pat_disj pats ->
            FStar_All.pipe_right pats
              (FStar_List.map
                 (fun pat1  ->
                    FStar_Syntax_Util.branch (pat1, when_opt, branch1)))
        | uu____46 ->
            let uu____47 = FStar_Syntax_Util.branch (pat, when_opt, branch1) in
            [uu____47]
let trans_aqual:
  FStar_Parser_AST.arg_qualifier option ->
    FStar_Syntax_Syntax.arg_qualifier option
  =
  fun uu___196_59  ->
    match uu___196_59 with
    | Some (FStar_Parser_AST.Implicit ) -> Some FStar_Syntax_Syntax.imp_tag
    | Some (FStar_Parser_AST.Equality ) -> Some FStar_Syntax_Syntax.Equality
    | uu____62 -> None
let trans_qual:
  FStar_Range.range ->
    FStar_Ident.lident option ->
      FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier
  =
  fun r  ->
    fun maybe_effect_id  ->
      fun uu___197_73  ->
        match uu___197_73 with
        | FStar_Parser_AST.Private  -> FStar_Syntax_Syntax.Private
        | FStar_Parser_AST.Assumption  -> FStar_Syntax_Syntax.Assumption
        | FStar_Parser_AST.Unfold_for_unification_and_vcgen  ->
            FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
        | FStar_Parser_AST.Inline_for_extraction  ->
            FStar_Syntax_Syntax.Inline_for_extraction
        | FStar_Parser_AST.NoExtract  -> FStar_Syntax_Syntax.NoExtract
        | FStar_Parser_AST.Irreducible  -> FStar_Syntax_Syntax.Irreducible
        | FStar_Parser_AST.Logic  -> FStar_Syntax_Syntax.Logic
        | FStar_Parser_AST.TotalEffect  -> FStar_Syntax_Syntax.TotalEffect
        | FStar_Parser_AST.Effect_qual  -> FStar_Syntax_Syntax.Effect
        | FStar_Parser_AST.New  -> FStar_Syntax_Syntax.New
        | FStar_Parser_AST.Abstract  -> FStar_Syntax_Syntax.Abstract
        | FStar_Parser_AST.Opaque  ->
            (FStar_Errors.warn r
               "The 'opaque' qualifier is deprecated since its use was strangely schizophrenic. There were two overloaded uses: (1) Given 'opaque val f : t', the behavior was to exclude the definition of 'f' to the SMT solver. This corresponds roughly to the new 'irreducible' qualifier. (2) Given 'opaque type t = t'', the behavior was to provide the definition of 't' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of 'unfoldable' (which is currently the default).";
             FStar_Syntax_Syntax.Visible_default)
        | FStar_Parser_AST.Reflectable  ->
            (match maybe_effect_id with
             | None  ->
                 raise
                   (FStar_Errors.Error
                      ("Qualifier reflect only supported on effects", r))
             | Some effect_id -> FStar_Syntax_Syntax.Reflectable effect_id)
        | FStar_Parser_AST.Reifiable  -> FStar_Syntax_Syntax.Reifiable
        | FStar_Parser_AST.Noeq  -> FStar_Syntax_Syntax.Noeq
        | FStar_Parser_AST.Unopteq  -> FStar_Syntax_Syntax.Unopteq
        | FStar_Parser_AST.DefaultEffect  ->
            raise
              (FStar_Errors.Error
                 ("The 'default' qualifier on effects is no longer supported",
                   r))
        | FStar_Parser_AST.Inline  ->
            raise (FStar_Errors.Error ("Unsupported qualifier", r))
        | FStar_Parser_AST.Visible  ->
            raise (FStar_Errors.Error ("Unsupported qualifier", r))
let trans_pragma: FStar_Parser_AST.pragma -> FStar_Syntax_Syntax.pragma =
  fun uu___198_79  ->
    match uu___198_79 with
    | FStar_Parser_AST.SetOptions s -> FStar_Syntax_Syntax.SetOptions s
    | FStar_Parser_AST.ResetOptions sopt ->
        FStar_Syntax_Syntax.ResetOptions sopt
    | FStar_Parser_AST.LightOff  -> FStar_Syntax_Syntax.LightOff
let as_imp: FStar_Parser_AST.imp -> FStar_Syntax_Syntax.arg_qualifier option
  =
  fun uu___199_86  ->
    match uu___199_86 with
    | FStar_Parser_AST.Hash  -> Some FStar_Syntax_Syntax.imp_tag
    | uu____88 -> None
let arg_withimp_e imp t = (t, (as_imp imp))
let arg_withimp_t imp t =
  match imp with
  | FStar_Parser_AST.Hash  -> (t, (Some FStar_Syntax_Syntax.imp_tag))
  | uu____121 -> (t, None)
let contains_binder: FStar_Parser_AST.binder Prims.list -> Prims.bool =
  fun binders  ->
    FStar_All.pipe_right binders
      (FStar_Util.for_some
         (fun b  ->
            match b.FStar_Parser_AST.b with
            | FStar_Parser_AST.Annotated uu____130 -> true
            | uu____133 -> false))
let rec unparen: FStar_Parser_AST.term -> FStar_Parser_AST.term =
  fun t  ->
    match t.FStar_Parser_AST.tm with
    | FStar_Parser_AST.Paren t1 -> unparen t1
    | uu____138 -> t
let tm_type_z: FStar_Range.range -> FStar_Parser_AST.term =
  fun r  ->
    let uu____142 =
      let uu____143 = FStar_Ident.lid_of_path ["Type0"] r in
      FStar_Parser_AST.Name uu____143 in
    FStar_Parser_AST.mk_term uu____142 r FStar_Parser_AST.Kind
let tm_type: FStar_Range.range -> FStar_Parser_AST.term =
  fun r  ->
    let uu____147 =
      let uu____148 = FStar_Ident.lid_of_path ["Type"] r in
      FStar_Parser_AST.Name uu____148 in
    FStar_Parser_AST.mk_term uu____147 r FStar_Parser_AST.Kind
let rec is_comp_type:
  FStar_ToSyntax_Env.env -> FStar_Parser_AST.term -> Prims.bool =
  fun env  ->
    fun t  ->
      match t.FStar_Parser_AST.tm with
      | FStar_Parser_AST.Name l ->
          let uu____156 = FStar_ToSyntax_Env.try_lookup_effect_name env l in
          FStar_All.pipe_right uu____156 FStar_Option.isSome
      | FStar_Parser_AST.Construct (l,uu____160) ->
          let uu____167 = FStar_ToSyntax_Env.try_lookup_effect_name env l in
          FStar_All.pipe_right uu____167 FStar_Option.isSome
      | FStar_Parser_AST.App (head1,uu____171,uu____172) ->
          is_comp_type env head1
      | FStar_Parser_AST.Paren t1 -> is_comp_type env t1
      | FStar_Parser_AST.Ascribed (t1,uu____175,uu____176) ->
          is_comp_type env t1
      | FStar_Parser_AST.LetOpen (uu____179,t1) -> is_comp_type env t1
      | uu____181 -> false
let unit_ty: FStar_Parser_AST.term =
  FStar_Parser_AST.mk_term
    (FStar_Parser_AST.Name FStar_Syntax_Const.unit_lid)
    FStar_Range.dummyRange FStar_Parser_AST.Type_level
let compile_op_lid:
  Prims.int -> Prims.string -> FStar_Range.range -> FStar_Ident.lident =
  fun n1  ->
    fun s  ->
      fun r  ->
        let uu____191 =
          let uu____193 =
            let uu____194 =
              let uu____197 = FStar_Parser_AST.compile_op n1 s in
              (uu____197, r) in
            FStar_Ident.mk_ident uu____194 in
          [uu____193] in
        FStar_All.pipe_right uu____191 FStar_Ident.lid_of_ids
let op_as_term env arity rng op =
  let r l dd =
    let uu____230 =
      let uu____231 =
        FStar_Syntax_Syntax.lid_as_fv
          (FStar_Ident.set_lid_range l op.FStar_Ident.idRange) dd None in
      FStar_All.pipe_right uu____231 FStar_Syntax_Syntax.fv_to_tm in
    Some uu____230 in
  let fallback uu____236 =
    match FStar_Ident.text_of_id op with
    | "=" -> r FStar_Syntax_Const.op_Eq FStar_Syntax_Syntax.Delta_equational
    | ":=" ->
        r FStar_Syntax_Const.write_lid FStar_Syntax_Syntax.Delta_equational
    | "<" -> r FStar_Syntax_Const.op_LT FStar_Syntax_Syntax.Delta_equational
    | "<=" ->
        r FStar_Syntax_Const.op_LTE FStar_Syntax_Syntax.Delta_equational
    | ">" -> r FStar_Syntax_Const.op_GT FStar_Syntax_Syntax.Delta_equational
    | ">=" ->
        r FStar_Syntax_Const.op_GTE FStar_Syntax_Syntax.Delta_equational
    | "&&" ->
        r FStar_Syntax_Const.op_And FStar_Syntax_Syntax.Delta_equational
    | "||" -> r FStar_Syntax_Const.op_Or FStar_Syntax_Syntax.Delta_equational
    | "+" ->
        r FStar_Syntax_Const.op_Addition FStar_Syntax_Syntax.Delta_equational
    | "-" when arity = (Prims.parse_int "1") ->
        r FStar_Syntax_Const.op_Minus FStar_Syntax_Syntax.Delta_equational
    | "-" ->
        r FStar_Syntax_Const.op_Subtraction
          FStar_Syntax_Syntax.Delta_equational
    | "/" ->
        r FStar_Syntax_Const.op_Division FStar_Syntax_Syntax.Delta_equational
    | "%" ->
        r FStar_Syntax_Const.op_Modulus FStar_Syntax_Syntax.Delta_equational
    | "!" ->
        r FStar_Syntax_Const.read_lid FStar_Syntax_Syntax.Delta_equational
    | "@" ->
        let uu____238 = FStar_Options.ml_ish () in
        if uu____238
        then
          r FStar_Syntax_Const.list_append_lid
            FStar_Syntax_Syntax.Delta_equational
        else
          r FStar_Syntax_Const.list_tot_append_lid
            FStar_Syntax_Syntax.Delta_equational
    | "^" ->
        r FStar_Syntax_Const.strcat_lid FStar_Syntax_Syntax.Delta_equational
    | "|>" ->
        r FStar_Syntax_Const.pipe_right_lid
          FStar_Syntax_Syntax.Delta_equational
    | "<|" ->
        r FStar_Syntax_Const.pipe_left_lid
          FStar_Syntax_Syntax.Delta_equational
    | "<>" ->
        r FStar_Syntax_Const.op_notEq FStar_Syntax_Syntax.Delta_equational
    | "~" ->
        r FStar_Syntax_Const.not_lid
          (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "2"))
    | "==" -> r FStar_Syntax_Const.eq2_lid FStar_Syntax_Syntax.Delta_constant
    | "<<" ->
        r FStar_Syntax_Const.precedes_lid FStar_Syntax_Syntax.Delta_constant
    | "/\\" ->
        r FStar_Syntax_Const.and_lid
          (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "1"))
    | "\\/" ->
        r FStar_Syntax_Const.or_lid
          (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "1"))
    | "==>" ->
        r FStar_Syntax_Const.imp_lid
          (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "1"))
    | "<==>" ->
        r FStar_Syntax_Const.iff_lid
          (FStar_Syntax_Syntax.Delta_defined_at_level (Prims.parse_int "2"))
    | uu____241 -> None in
  let uu____242 =
    let uu____246 =
      compile_op_lid arity op.FStar_Ident.idText op.FStar_Ident.idRange in
    FStar_ToSyntax_Env.try_lookup_lid env uu____246 in
  match uu____242 with | Some t -> Some (fst t) | uu____253 -> fallback ()
let sort_ftv: FStar_Ident.ident Prims.list -> FStar_Ident.ident Prims.list =
  fun ftv  ->
    let uu____263 =
      FStar_Util.remove_dups
        (fun x  -> fun y  -> x.FStar_Ident.idText = y.FStar_Ident.idText) ftv in
    FStar_All.pipe_left
      (FStar_Util.sort_with
         (fun x  ->
            fun y  ->
              FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))
      uu____263
let rec free_type_vars_b:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.binder ->
      (FStar_ToSyntax_Env.env* FStar_Ident.ident Prims.list)
  =
  fun env  ->
    fun binder  ->
      match binder.FStar_Parser_AST.b with
      | FStar_Parser_AST.Variable uu____288 -> (env, [])
      | FStar_Parser_AST.TVariable x ->
          let uu____291 = FStar_ToSyntax_Env.push_bv env x in
          (match uu____291 with | (env1,uu____298) -> (env1, [x]))
      | FStar_Parser_AST.Annotated (uu____300,term) ->
          let uu____302 = free_type_vars env term in (env, uu____302)
      | FStar_Parser_AST.TAnnotated (id,uu____306) ->
          let uu____307 = FStar_ToSyntax_Env.push_bv env id in
          (match uu____307 with | (env1,uu____314) -> (env1, []))
      | FStar_Parser_AST.NoName t ->
          let uu____317 = free_type_vars env t in (env, uu____317)
and free_type_vars:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.term -> FStar_Ident.ident Prims.list
  =
  fun env  ->
    fun t  ->
      let uu____322 =
        let uu____323 = unparen t in uu____323.FStar_Parser_AST.tm in
      match uu____322 with
      | FStar_Parser_AST.Labeled uu____325 ->
          failwith "Impossible --- labeled source term"
      | FStar_Parser_AST.Tvar a ->
          let uu____331 = FStar_ToSyntax_Env.try_lookup_id env a in
          (match uu____331 with | None  -> [a] | uu____338 -> [])
      | FStar_Parser_AST.Wild  -> []
      | FStar_Parser_AST.Const uu____342 -> []
      | FStar_Parser_AST.Uvar uu____343 -> []
      | FStar_Parser_AST.Var uu____344 -> []
      | FStar_Parser_AST.Projector uu____345 -> []
      | FStar_Parser_AST.Discrim uu____348 -> []
      | FStar_Parser_AST.Name uu____349 -> []
      | FStar_Parser_AST.Assign (uu____350,t1) -> free_type_vars env t1
      | FStar_Parser_AST.Requires (t1,uu____353) -> free_type_vars env t1
      | FStar_Parser_AST.Ensures (t1,uu____357) -> free_type_vars env t1
      | FStar_Parser_AST.NamedTyp (uu____360,t1) -> free_type_vars env t1
      | FStar_Parser_AST.Paren t1 -> free_type_vars env t1
      | FStar_Parser_AST.Ascribed (t1,t',tacopt) ->
          let ts = t1 :: t' ::
            (match tacopt with | None  -> [] | Some t2 -> [t2]) in
          FStar_List.collect (free_type_vars env) ts
      | FStar_Parser_AST.Construct (uu____372,ts) ->
          FStar_List.collect
            (fun uu____382  ->
               match uu____382 with | (t1,uu____387) -> free_type_vars env t1)
            ts
      | FStar_Parser_AST.Op (uu____388,ts) ->
          FStar_List.collect (free_type_vars env) ts
      | FStar_Parser_AST.App (t1,t2,uu____394) ->
          let uu____395 = free_type_vars env t1 in
          let uu____397 = free_type_vars env t2 in
          FStar_List.append uu____395 uu____397
      | FStar_Parser_AST.Refine (b,t1) ->
          let uu____401 = free_type_vars_b env b in
          (match uu____401 with
           | (env1,f) ->
               let uu____410 = free_type_vars env1 t1 in
               FStar_List.append f uu____410)
      | FStar_Parser_AST.Product (binders,body) ->
          let uu____416 =
            FStar_List.fold_left
              (fun uu____423  ->
                 fun binder  ->
                   match uu____423 with
                   | (env1,free) ->
                       let uu____435 = free_type_vars_b env1 binder in
                       (match uu____435 with
                        | (env2,f) -> (env2, (FStar_List.append f free))))
              (env, []) binders in
          (match uu____416 with
           | (env1,free) ->
               let uu____453 = free_type_vars env1 body in
               FStar_List.append free uu____453)
      | FStar_Parser_AST.Sum (binders,body) ->
          let uu____459 =
            FStar_List.fold_left
              (fun uu____466  ->
                 fun binder  ->
                   match uu____466 with
                   | (env1,free) ->
                       let uu____478 = free_type_vars_b env1 binder in
                       (match uu____478 with
                        | (env2,f) -> (env2, (FStar_List.append f free))))
              (env, []) binders in
          (match uu____459 with
           | (env1,free) ->
               let uu____496 = free_type_vars env1 body in
               FStar_List.append free uu____496)
      | FStar_Parser_AST.Project (t1,uu____499) -> free_type_vars env t1
      | FStar_Parser_AST.Attributes cattributes ->
          FStar_List.collect (free_type_vars env) cattributes
      | FStar_Parser_AST.Abs uu____502 -> []
      | FStar_Parser_AST.Let uu____506 -> []
      | FStar_Parser_AST.LetOpen uu____513 -> []
      | FStar_Parser_AST.If uu____516 -> []
      | FStar_Parser_AST.QForall uu____520 -> []
      | FStar_Parser_AST.QExists uu____527 -> []
      | FStar_Parser_AST.Record uu____534 -> []
      | FStar_Parser_AST.Match uu____541 -> []
      | FStar_Parser_AST.TryWith uu____549 -> []
      | FStar_Parser_AST.Bind uu____557 -> []
      | FStar_Parser_AST.Seq uu____561 -> []
let head_and_args:
  FStar_Parser_AST.term ->
    (FStar_Parser_AST.term* (FStar_Parser_AST.term* FStar_Parser_AST.imp)
      Prims.list)
  =
  fun t  ->
    let rec aux args t1 =
      let uu____590 =
        let uu____591 = unparen t1 in uu____591.FStar_Parser_AST.tm in
      match uu____590 with
      | FStar_Parser_AST.App (t2,arg,imp) -> aux ((arg, imp) :: args) t2
      | FStar_Parser_AST.Construct (l,args') ->
          ({
             FStar_Parser_AST.tm = (FStar_Parser_AST.Name l);
             FStar_Parser_AST.range = (t1.FStar_Parser_AST.range);
             FStar_Parser_AST.level = (t1.FStar_Parser_AST.level)
           }, (FStar_List.append args' args))
      | uu____615 -> (t1, args) in
    aux [] t
let close:
  FStar_ToSyntax_Env.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term =
  fun env  ->
    fun t  ->
      let ftv =
        let uu____629 = free_type_vars env t in
        FStar_All.pipe_left sort_ftv uu____629 in
      if (FStar_List.length ftv) = (Prims.parse_int "0")
      then t
      else
        (let binders =
           FStar_All.pipe_right ftv
             (FStar_List.map
                (fun x  ->
                   let uu____641 =
                     let uu____642 =
                       let uu____645 = tm_type x.FStar_Ident.idRange in
                       (x, uu____645) in
                     FStar_Parser_AST.TAnnotated uu____642 in
                   FStar_Parser_AST.mk_binder uu____641 x.FStar_Ident.idRange
                     FStar_Parser_AST.Type_level
                     (Some FStar_Parser_AST.Implicit))) in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t))
             t.FStar_Parser_AST.range t.FStar_Parser_AST.level in
         result)
let close_fun:
  FStar_ToSyntax_Env.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term =
  fun env  ->
    fun t  ->
      let ftv =
        let uu____656 = free_type_vars env t in
        FStar_All.pipe_left sort_ftv uu____656 in
      if (FStar_List.length ftv) = (Prims.parse_int "0")
      then t
      else
        (let binders =
           FStar_All.pipe_right ftv
             (FStar_List.map
                (fun x  ->
                   let uu____668 =
                     let uu____669 =
                       let uu____672 = tm_type x.FStar_Ident.idRange in
                       (x, uu____672) in
                     FStar_Parser_AST.TAnnotated uu____669 in
                   FStar_Parser_AST.mk_binder uu____668 x.FStar_Ident.idRange
                     FStar_Parser_AST.Type_level
                     (Some FStar_Parser_AST.Implicit))) in
         let t1 =
           let uu____674 =
             let uu____675 = unparen t in uu____675.FStar_Parser_AST.tm in
           match uu____674 with
           | FStar_Parser_AST.Product uu____676 -> t
           | uu____680 ->
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.App
                    ((FStar_Parser_AST.mk_term
                        (FStar_Parser_AST.Name
                           FStar_Syntax_Const.effect_Tot_lid)
                        t.FStar_Parser_AST.range t.FStar_Parser_AST.level),
                      t, FStar_Parser_AST.Nothing)) t.FStar_Parser_AST.range
                 t.FStar_Parser_AST.level in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t1))
             t1.FStar_Parser_AST.range t1.FStar_Parser_AST.level in
         result)
let rec uncurry:
  FStar_Parser_AST.binder Prims.list ->
    FStar_Parser_AST.term ->
      (FStar_Parser_AST.binder Prims.list* FStar_Parser_AST.term)
  =
  fun bs  ->
    fun t  ->
      match t.FStar_Parser_AST.tm with
      | FStar_Parser_AST.Product (binders,t1) ->
          uncurry (FStar_List.append bs binders) t1
      | uu____701 -> (bs, t)
let rec is_var_pattern: FStar_Parser_AST.pattern -> Prims.bool =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatWild  -> true
    | FStar_Parser_AST.PatTvar (uu____706,uu____707) -> true
    | FStar_Parser_AST.PatVar (uu____710,uu____711) -> true
    | FStar_Parser_AST.PatAscribed (p1,uu____715) -> is_var_pattern p1
    | uu____716 -> false
let rec is_app_pattern: FStar_Parser_AST.pattern -> Prims.bool =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatAscribed (p1,uu____721) -> is_app_pattern p1
    | FStar_Parser_AST.PatApp
        ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar uu____722;
           FStar_Parser_AST.prange = uu____723;_},uu____724)
        -> true
    | uu____730 -> false
let replace_unit_pattern:
  FStar_Parser_AST.pattern -> FStar_Parser_AST.pattern =
  fun p  ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatConst (FStar_Const.Const_unit ) ->
        FStar_Parser_AST.mk_pattern
          (FStar_Parser_AST.PatAscribed
             ((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild
                 p.FStar_Parser_AST.prange), unit_ty))
          p.FStar_Parser_AST.prange
    | uu____734 -> p
let rec destruct_app_pattern:
  FStar_ToSyntax_Env.env ->
    Prims.bool ->
      FStar_Parser_AST.pattern ->
        ((FStar_Ident.ident,FStar_Ident.lident) FStar_Util.either*
          FStar_Parser_AST.pattern Prims.list* FStar_Parser_AST.term option)
  =
  fun env  ->
    fun is_top_level1  ->
      fun p  ->
        match p.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatAscribed (p1,t) ->
            let uu____760 = destruct_app_pattern env is_top_level1 p1 in
            (match uu____760 with
             | (name,args,uu____777) -> (name, args, (Some t)))
        | FStar_Parser_AST.PatApp
            ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id,uu____791);
               FStar_Parser_AST.prange = uu____792;_},args)
            when is_top_level1 ->
            let uu____798 =
              let uu____801 = FStar_ToSyntax_Env.qualify env id in
              FStar_Util.Inr uu____801 in
            (uu____798, args, None)
        | FStar_Parser_AST.PatApp
            ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id,uu____807);
               FStar_Parser_AST.prange = uu____808;_},args)
            -> ((FStar_Util.Inl id), args, None)
        | uu____818 -> failwith "Not an app pattern"
let rec gather_pattern_bound_vars_maybe_top:
  FStar_Ident.ident FStar_Util.set ->
    FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Util.set
  =
  fun acc  ->
    fun p  ->
      let gather_pattern_bound_vars_from_list =
        FStar_List.fold_left gather_pattern_bound_vars_maybe_top acc in
      match p.FStar_Parser_AST.pat with
      | FStar_Parser_AST.PatWild  -> acc
      | FStar_Parser_AST.PatConst uu____842 -> acc
      | FStar_Parser_AST.PatVar (uu____843,Some (FStar_Parser_AST.Implicit ))
          -> acc
      | FStar_Parser_AST.PatName uu____845 -> acc
      | FStar_Parser_AST.PatTvar uu____846 -> acc
      | FStar_Parser_AST.PatOp uu____850 -> acc
      | FStar_Parser_AST.PatApp (phead,pats) ->
          gather_pattern_bound_vars_from_list (phead :: pats)
      | FStar_Parser_AST.PatVar (x,uu____856) -> FStar_Util.set_add x acc
      | FStar_Parser_AST.PatList pats ->
          gather_pattern_bound_vars_from_list pats
      | FStar_Parser_AST.PatTuple (pats,uu____862) ->
          gather_pattern_bound_vars_from_list pats
      | FStar_Parser_AST.PatOr pats ->
          gather_pattern_bound_vars_from_list pats
      | FStar_Parser_AST.PatRecord guarded_pats ->
          let uu____871 = FStar_List.map FStar_Pervasives.snd guarded_pats in
          gather_pattern_bound_vars_from_list uu____871
      | FStar_Parser_AST.PatAscribed (pat,uu____876) ->
          gather_pattern_bound_vars_maybe_top acc pat
let gather_pattern_bound_vars:
  FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Util.set =
  let acc =
    FStar_Util.new_set
      (fun id1  ->
         fun id2  ->
           if id1.FStar_Ident.idText = id2.FStar_Ident.idText
           then Prims.parse_int "0"
           else Prims.parse_int "1") (fun uu____885  -> Prims.parse_int "0") in
  fun p  -> gather_pattern_bound_vars_maybe_top acc p
type bnd =
  | LocalBinder of (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual)
  | LetBinder of (FStar_Ident.lident* FStar_Syntax_Syntax.term)
let uu___is_LocalBinder: bnd -> Prims.bool =
  fun projectee  ->
    match projectee with | LocalBinder _0 -> true | uu____903 -> false
let __proj__LocalBinder__item___0:
  bnd -> (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) =
  fun projectee  -> match projectee with | LocalBinder _0 -> _0
let uu___is_LetBinder: bnd -> Prims.bool =
  fun projectee  ->
    match projectee with | LetBinder _0 -> true | uu____923 -> false
let __proj__LetBinder__item___0:
  bnd -> (FStar_Ident.lident* FStar_Syntax_Syntax.term) =
  fun projectee  -> match projectee with | LetBinder _0 -> _0
let binder_of_bnd: bnd -> (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual)
  =
  fun uu___200_941  ->
    match uu___200_941 with
    | LocalBinder (a,aq) -> (a, aq)
    | uu____946 -> failwith "Impossible"
let as_binder:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.arg_qualifier option ->
      (FStar_Ident.ident option* FStar_Syntax_Syntax.term) ->
        (FStar_Syntax_Syntax.binder* FStar_ToSyntax_Env.env)
  =
  fun env  ->
    fun imp  ->
      fun uu___201_963  ->
        match uu___201_963 with
        | (None ,k) ->
            let uu____972 = FStar_Syntax_Syntax.null_binder k in
            (uu____972, env)
        | (Some a,k) ->
            let uu____976 = FStar_ToSyntax_Env.push_bv env a in
            (match uu____976 with
             | (env1,a1) ->
                 (((let uu___222_987 = a1 in
                    {
                      FStar_Syntax_Syntax.ppname =
                        (uu___222_987.FStar_Syntax_Syntax.ppname);
                      FStar_Syntax_Syntax.index =
                        (uu___222_987.FStar_Syntax_Syntax.index);
                      FStar_Syntax_Syntax.sort = k
                    }), (trans_aqual imp)), env1))
type env_t = FStar_ToSyntax_Env.env
type lenv_t = FStar_Syntax_Syntax.bv Prims.list
let mk_lb:
  ((FStar_Syntax_Syntax.bv,FStar_Syntax_Syntax.fv) FStar_Util.either*
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax*
    (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax) -> FStar_Syntax_Syntax.letbinding
  =
  fun uu____1000  ->
    match uu____1000 with
    | (n1,t,e) ->
        {
          FStar_Syntax_Syntax.lbname = n1;
          FStar_Syntax_Syntax.lbunivs = [];
          FStar_Syntax_Syntax.lbtyp = t;
          FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid;
          FStar_Syntax_Syntax.lbdef = e
        }
let no_annot_abs:
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  = fun bs  -> fun t  -> FStar_Syntax_Util.abs bs t None
let mk_ref_read tm =
  let tm' =
    let uu____1050 =
      let uu____1060 =
        let uu____1061 =
          FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.sread_lid
            FStar_Syntax_Syntax.Delta_constant None in
        FStar_Syntax_Syntax.fv_to_tm uu____1061 in
      let uu____1062 =
        let uu____1068 =
          let uu____1073 = FStar_Syntax_Syntax.as_implicit false in
          (tm, uu____1073) in
        [uu____1068] in
      (uu____1060, uu____1062) in
    FStar_Syntax_Syntax.Tm_app uu____1050 in
  FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos
let mk_ref_alloc tm =
  let tm' =
    let uu____1107 =
      let uu____1117 =
        let uu____1118 =
          FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.salloc_lid
            FStar_Syntax_Syntax.Delta_constant None in
        FStar_Syntax_Syntax.fv_to_tm uu____1118 in
      let uu____1119 =
        let uu____1125 =
          let uu____1130 = FStar_Syntax_Syntax.as_implicit false in
          (tm, uu____1130) in
        [uu____1125] in
      (uu____1117, uu____1119) in
    FStar_Syntax_Syntax.Tm_app uu____1107 in
  FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos
let mk_ref_assign t1 t2 pos =
  let tm =
    let uu____1178 =
      let uu____1188 =
        let uu____1189 =
          FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.swrite_lid
            FStar_Syntax_Syntax.Delta_constant None in
        FStar_Syntax_Syntax.fv_to_tm uu____1189 in
      let uu____1190 =
        let uu____1196 =
          let uu____1201 = FStar_Syntax_Syntax.as_implicit false in
          (t1, uu____1201) in
        let uu____1204 =
          let uu____1210 =
            let uu____1215 = FStar_Syntax_Syntax.as_implicit false in
            (t2, uu____1215) in
          [uu____1210] in
        uu____1196 :: uu____1204 in
      (uu____1188, uu____1190) in
    FStar_Syntax_Syntax.Tm_app uu____1178 in
  FStar_Syntax_Syntax.mk tm None pos
let is_special_effect_combinator: Prims.string -> Prims.bool =
  fun uu___202_1241  ->
    match uu___202_1241 with
    | "repr" -> true
    | "post" -> true
    | "pre" -> true
    | "wp" -> true
    | uu____1242 -> false
let rec sum_to_universe:
  FStar_Syntax_Syntax.universe -> Prims.int -> FStar_Syntax_Syntax.universe =
  fun u  ->
    fun n1  ->
      if n1 = (Prims.parse_int "0")
      then u
      else
        (let uu____1250 = sum_to_universe u (n1 - (Prims.parse_int "1")) in
         FStar_Syntax_Syntax.U_succ uu____1250)
let int_to_universe: Prims.int -> FStar_Syntax_Syntax.universe =
  fun n1  -> sum_to_universe FStar_Syntax_Syntax.U_zero n1
let rec desugar_maybe_non_constant_universe:
  FStar_Parser_AST.term ->
    (Prims.int,FStar_Syntax_Syntax.universe) FStar_Util.either
  =
  fun t  ->
    let uu____1261 =
      let uu____1262 = unparen t in uu____1262.FStar_Parser_AST.tm in
    match uu____1261 with
    | FStar_Parser_AST.Wild  ->
        let uu____1265 =
          let uu____1266 = FStar_Unionfind.fresh None in
          FStar_Syntax_Syntax.U_unif uu____1266 in
        FStar_Util.Inr uu____1265
    | FStar_Parser_AST.Uvar u ->
        FStar_Util.Inr (FStar_Syntax_Syntax.U_name u)
    | FStar_Parser_AST.Const (FStar_Const.Const_int (repr,uu____1272)) ->
        let n1 = FStar_Util.int_of_string repr in
        (if n1 < (Prims.parse_int "0")
         then
           raise
             (FStar_Errors.Error
                ((Prims.strcat
                    "Negative universe constant  are not supported : " repr),
                  (t.FStar_Parser_AST.range)))
         else ();
         FStar_Util.Inl n1)
    | FStar_Parser_AST.Op (op_plus,t1::t2::[]) ->
        let u1 = desugar_maybe_non_constant_universe t1 in
        let u2 = desugar_maybe_non_constant_universe t2 in
        (match (u1, u2) with
         | (FStar_Util.Inl n1,FStar_Util.Inl n2) -> FStar_Util.Inl (n1 + n2)
         | (FStar_Util.Inl n1,FStar_Util.Inr u) ->
             let uu____1311 = sum_to_universe u n1 in
             FStar_Util.Inr uu____1311
         | (FStar_Util.Inr u,FStar_Util.Inl n1) ->
             let uu____1318 = sum_to_universe u n1 in
             FStar_Util.Inr uu____1318
         | (FStar_Util.Inr u11,FStar_Util.Inr u21) ->
             let uu____1325 =
               let uu____1326 =
                 let uu____1329 =
                   let uu____1330 = FStar_Parser_AST.term_to_string t in
                   Prims.strcat
                     "This universe might contain a sum of two universe variables "
                     uu____1330 in
                 (uu____1329, (t.FStar_Parser_AST.range)) in
               FStar_Errors.Error uu____1326 in
             raise uu____1325)
    | FStar_Parser_AST.App uu____1333 ->
        let rec aux t1 univargs =
          let uu____1352 =
            let uu____1353 = unparen t1 in uu____1353.FStar_Parser_AST.tm in
          match uu____1352 with
          | FStar_Parser_AST.App (t2,targ,uu____1358) ->
              let uarg = desugar_maybe_non_constant_universe targ in
              aux t2 (uarg :: univargs)
          | FStar_Parser_AST.Var max_lid1 ->
              if
                FStar_List.existsb
                  (fun uu___203_1370  ->
                     match uu___203_1370 with
                     | FStar_Util.Inr uu____1373 -> true
                     | uu____1374 -> false) univargs
              then
                let uu____1377 =
                  let uu____1378 =
                    FStar_List.map
                      (fun uu___204_1382  ->
                         match uu___204_1382 with
                         | FStar_Util.Inl n1 -> int_to_universe n1
                         | FStar_Util.Inr u -> u) univargs in
                  FStar_Syntax_Syntax.U_max uu____1378 in
                FStar_Util.Inr uu____1377
              else
                (let nargs =
                   FStar_List.map
                     (fun uu___205_1392  ->
                        match uu___205_1392 with
                        | FStar_Util.Inl n1 -> n1
                        | FStar_Util.Inr uu____1396 -> failwith "impossible")
                     univargs in
                 let uu____1397 =
                   FStar_List.fold_left
                     (fun m  -> fun n1  -> if m > n1 then m else n1)
                     (Prims.parse_int "0") nargs in
                 FStar_Util.Inl uu____1397)
          | uu____1401 ->
              let uu____1402 =
                let uu____1403 =
                  let uu____1406 =
                    let uu____1407 =
                      let uu____1408 = FStar_Parser_AST.term_to_string t1 in
                      Prims.strcat uu____1408 " in universe context" in
                    Prims.strcat "Unexpected term " uu____1407 in
                  (uu____1406, (t1.FStar_Parser_AST.range)) in
                FStar_Errors.Error uu____1403 in
              raise uu____1402 in
        aux t []
    | uu____1413 ->
        let uu____1414 =
          let uu____1415 =
            let uu____1418 =
              let uu____1419 =
                let uu____1420 = FStar_Parser_AST.term_to_string t in
                Prims.strcat uu____1420 " in universe context" in
              Prims.strcat "Unexpected term " uu____1419 in
            (uu____1418, (t.FStar_Parser_AST.range)) in
          FStar_Errors.Error uu____1415 in
        raise uu____1414
let rec desugar_universe:
  FStar_Parser_AST.term -> FStar_Syntax_Syntax.universe =
  fun t  ->
    let u = desugar_maybe_non_constant_universe t in
    match u with
    | FStar_Util.Inl n1 -> int_to_universe n1
    | FStar_Util.Inr u1 -> u1
let check_fields env fields rg =
  let uu____1454 = FStar_List.hd fields in
  match uu____1454 with
  | (f,uu____1460) ->
      (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env f;
       (let record =
          FStar_ToSyntax_Env.fail_or env
            (FStar_ToSyntax_Env.try_lookup_record_by_field_name env) f in
        let check_field uu____1468 =
          match uu____1468 with
          | (f',uu____1472) ->
              (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env f';
               (let uu____1474 =
                  FStar_ToSyntax_Env.belongs_to_record env f' record in
                if uu____1474
                then ()
                else
                  (let msg =
                     FStar_Util.format3
                       "Field %s belongs to record type %s, whereas field %s does not"
                       f.FStar_Ident.str
                       (record.FStar_ToSyntax_Env.typename).FStar_Ident.str
                       f'.FStar_Ident.str in
                   raise (FStar_Errors.Error (msg, rg))))) in
        (let uu____1478 = FStar_List.tl fields in
         FStar_List.iter check_field uu____1478);
        (match () with | () -> record)))
let rec desugar_data_pat:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.pattern ->
      Prims.bool -> (env_t* bnd* FStar_Syntax_Syntax.pat)
  =
  fun env  ->
    fun p  ->
      fun is_mut  ->
        let check_linear_pattern_variables p1 =
          let rec pat_vars p2 =
            match p2.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_dot_term uu____1634 ->
                FStar_Syntax_Syntax.no_names
            | FStar_Syntax_Syntax.Pat_wild uu____1639 ->
                FStar_Syntax_Syntax.no_names
            | FStar_Syntax_Syntax.Pat_constant uu____1640 ->
                FStar_Syntax_Syntax.no_names
            | FStar_Syntax_Syntax.Pat_var x ->
                FStar_Util.set_add x FStar_Syntax_Syntax.no_names
            | FStar_Syntax_Syntax.Pat_cons (uu____1642,pats) ->
                FStar_All.pipe_right pats
                  (FStar_List.fold_left
                     (fun out  ->
                        fun uu____1664  ->
                          match uu____1664 with
                          | (p3,uu____1670) ->
                              let uu____1671 = pat_vars p3 in
                              FStar_Util.set_union out uu____1671)
                     FStar_Syntax_Syntax.no_names)
            | FStar_Syntax_Syntax.Pat_disj [] -> failwith "Impossible"
            | FStar_Syntax_Syntax.Pat_disj (hd1::tl1) ->
                let xs = pat_vars hd1 in
                let uu____1685 =
                  let uu____1686 =
                    FStar_Util.for_all
                      (fun p3  ->
                         let ys = pat_vars p3 in
                         (FStar_Util.set_is_subset_of xs ys) &&
                           (FStar_Util.set_is_subset_of ys xs)) tl1 in
                  Prims.op_Negation uu____1686 in
                if uu____1685
                then
                  raise
                    (FStar_Errors.Error
                       ("Disjunctive pattern binds different variables in each case",
                         (p2.FStar_Syntax_Syntax.p)))
                else xs in
          pat_vars p1 in
        (match (is_mut, (p.FStar_Parser_AST.pat)) with
         | (false ,uu____1691) -> ()
         | (true ,FStar_Parser_AST.PatVar uu____1692) -> ()
         | (true ,uu____1696) ->
             raise
               (FStar_Errors.Error
                  ("let-mutable is for variables only",
                    (p.FStar_Parser_AST.prange))));
        (let push_bv_maybe_mut =
           if is_mut
           then FStar_ToSyntax_Env.push_bv_mutable
           else FStar_ToSyntax_Env.push_bv in
         let resolvex l e x =
           let uu____1724 =
             FStar_All.pipe_right l
               (FStar_Util.find_opt
                  (fun y  ->
                     (y.FStar_Syntax_Syntax.ppname).FStar_Ident.idText =
                       x.FStar_Ident.idText)) in
           match uu____1724 with
           | Some y -> (l, e, y)
           | uu____1732 ->
               let uu____1734 = push_bv_maybe_mut e x in
               (match uu____1734 with | (e1,x1) -> ((x1 :: l), e1, x1)) in
         let rec aux loc env1 p1 =
           let pos q =
             FStar_Syntax_Syntax.withinfo q
               FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
               p1.FStar_Parser_AST.prange in
           let pos_r r q =
             FStar_Syntax_Syntax.withinfo q
               FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r in
           match p1.FStar_Parser_AST.pat with
           | FStar_Parser_AST.PatOp op ->
               let uu____1783 =
                 let uu____1784 =
                   let uu____1785 =
                     let uu____1789 =
                       let uu____1790 =
                         let uu____1793 =
                           FStar_Parser_AST.compile_op (Prims.parse_int "0")
                             op.FStar_Ident.idText in
                         (uu____1793, (op.FStar_Ident.idRange)) in
                       FStar_Ident.mk_ident uu____1790 in
                     (uu____1789, None) in
                   FStar_Parser_AST.PatVar uu____1785 in
                 {
                   FStar_Parser_AST.pat = uu____1784;
                   FStar_Parser_AST.prange = (p1.FStar_Parser_AST.prange)
                 } in
               aux loc env1 uu____1783
           | FStar_Parser_AST.PatOr [] -> failwith "impossible"
           | FStar_Parser_AST.PatOr (p2::ps) ->
               let uu____1805 = aux loc env1 p2 in
               (match uu____1805 with
                | (loc1,env2,var,p3,uu____1824) ->
                    let uu____1829 =
                      FStar_List.fold_left
                        (fun uu____1842  ->
                           fun p4  ->
                             match uu____1842 with
                             | (loc2,env3,ps1) ->
                                 let uu____1865 = aux loc2 env3 p4 in
                                 (match uu____1865 with
                                  | (loc3,env4,uu____1881,p5,uu____1883) ->
                                      (loc3, env4, (p5 :: ps1))))
                        (loc1, env2, []) ps in
                    (match uu____1829 with
                     | (loc2,env3,ps1) ->
                         let pat =
                           FStar_All.pipe_left pos
                             (FStar_Syntax_Syntax.Pat_disj (p3 ::
                                (FStar_List.rev ps1))) in
                         (loc2, env3, var, pat, false)))
           | FStar_Parser_AST.PatAscribed (p2,t) ->
               let uu____1927 = aux loc env1 p2 in
               (match uu____1927 with
                | (loc1,env',binder,p3,imp) ->
                    let binder1 =
                      match binder with
                      | LetBinder uu____1952 -> failwith "impossible"
                      | LocalBinder (x,aq) ->
                          let t1 =
                            let uu____1958 = close_fun env1 t in
                            desugar_term env1 uu____1958 in
                          (if
                             (match (x.FStar_Syntax_Syntax.sort).FStar_Syntax_Syntax.n
                              with
                              | FStar_Syntax_Syntax.Tm_unknown  -> false
                              | uu____1960 -> true)
                           then
                             (let uu____1961 =
                                FStar_Syntax_Print.bv_to_string x in
                              let uu____1962 =
                                FStar_Syntax_Print.term_to_string
                                  x.FStar_Syntax_Syntax.sort in
                              let uu____1963 =
                                FStar_Syntax_Print.term_to_string t1 in
                              FStar_Util.print3_warning
                                "Multiple ascriptions for %s in pattern, type %s was shadowed by %s"
                                uu____1961 uu____1962 uu____1963)
                           else ();
                           LocalBinder
                             (((let uu___223_1965 = x in
                                {
                                  FStar_Syntax_Syntax.ppname =
                                    (uu___223_1965.FStar_Syntax_Syntax.ppname);
                                  FStar_Syntax_Syntax.index =
                                    (uu___223_1965.FStar_Syntax_Syntax.index);
                                  FStar_Syntax_Syntax.sort = t1
                                })), aq)) in
                    (loc1, env', binder1, p3, imp))
           | FStar_Parser_AST.PatWild  ->
               let x =
                 FStar_Syntax_Syntax.new_bv
                   (Some (p1.FStar_Parser_AST.prange))
                   FStar_Syntax_Syntax.tun in
               let uu____1969 =
                 FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_wild x) in
               (loc, env1, (LocalBinder (x, None)), uu____1969, false)
           | FStar_Parser_AST.PatConst c ->
               let x =
                 FStar_Syntax_Syntax.new_bv
                   (Some (p1.FStar_Parser_AST.prange))
                   FStar_Syntax_Syntax.tun in
               let uu____1979 =
                 FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_constant c) in
               (loc, env1, (LocalBinder (x, None)), uu____1979, false)
           | FStar_Parser_AST.PatTvar (x,aq) ->
               let imp = aq = (Some FStar_Parser_AST.Implicit) in
               let aq1 = trans_aqual aq in
               let uu____1995 = resolvex loc env1 x in
               (match uu____1995 with
                | (loc1,env2,xbv) ->
                    let uu____2009 =
                      FStar_All.pipe_left pos
                        (FStar_Syntax_Syntax.Pat_var xbv) in
                    (loc1, env2, (LocalBinder (xbv, aq1)), uu____2009, imp))
           | FStar_Parser_AST.PatVar (x,aq) ->
               let imp = aq = (Some FStar_Parser_AST.Implicit) in
               let aq1 = trans_aqual aq in
               let uu____2025 = resolvex loc env1 x in
               (match uu____2025 with
                | (loc1,env2,xbv) ->
                    let uu____2039 =
                      FStar_All.pipe_left pos
                        (FStar_Syntax_Syntax.Pat_var xbv) in
                    (loc1, env2, (LocalBinder (xbv, aq1)), uu____2039, imp))
           | FStar_Parser_AST.PatName l ->
               let l1 =
                 FStar_ToSyntax_Env.fail_or env1
                   (FStar_ToSyntax_Env.try_lookup_datacon env1) l in
               let x =
                 FStar_Syntax_Syntax.new_bv
                   (Some (p1.FStar_Parser_AST.prange))
                   FStar_Syntax_Syntax.tun in
               let uu____2050 =
                 FStar_All.pipe_left pos
                   (FStar_Syntax_Syntax.Pat_cons (l1, [])) in
               (loc, env1, (LocalBinder (x, None)), uu____2050, false)
           | FStar_Parser_AST.PatApp
               ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatName l;
                  FStar_Parser_AST.prange = uu____2068;_},args)
               ->
               let uu____2072 =
                 FStar_List.fold_right
                   (fun arg  ->
                      fun uu____2090  ->
                        match uu____2090 with
                        | (loc1,env2,args1) ->
                            let uu____2120 = aux loc1 env2 arg in
                            (match uu____2120 with
                             | (loc2,env3,uu____2138,arg1,imp) ->
                                 (loc2, env3, ((arg1, imp) :: args1)))) args
                   (loc, env1, []) in
               (match uu____2072 with
                | (loc1,env2,args1) ->
                    let l1 =
                      FStar_ToSyntax_Env.fail_or env2
                        (FStar_ToSyntax_Env.try_lookup_datacon env2) l in
                    let x =
                      FStar_Syntax_Syntax.new_bv
                        (Some (p1.FStar_Parser_AST.prange))
                        FStar_Syntax_Syntax.tun in
                    let uu____2187 =
                      FStar_All.pipe_left pos
                        (FStar_Syntax_Syntax.Pat_cons (l1, args1)) in
                    (loc1, env2, (LocalBinder (x, None)), uu____2187, false))
           | FStar_Parser_AST.PatApp uu____2200 ->
               raise
                 (FStar_Errors.Error
                    ("Unexpected pattern", (p1.FStar_Parser_AST.prange)))
           | FStar_Parser_AST.PatList pats ->
               let uu____2213 =
                 FStar_List.fold_right
                   (fun pat  ->
                      fun uu____2227  ->
                        match uu____2227 with
                        | (loc1,env2,pats1) ->
                            let uu____2249 = aux loc1 env2 pat in
                            (match uu____2249 with
                             | (loc2,env3,uu____2265,pat1,uu____2267) ->
                                 (loc2, env3, (pat1 :: pats1)))) pats
                   (loc, env1, []) in
               (match uu____2213 with
                | (loc1,env2,pats1) ->
                    let pat =
                      let uu____2301 =
                        let uu____2304 =
                          let uu____2309 =
                            FStar_Range.end_range p1.FStar_Parser_AST.prange in
                          pos_r uu____2309 in
                        let uu____2310 =
                          let uu____2311 =
                            let uu____2319 =
                              FStar_Syntax_Syntax.lid_as_fv
                                FStar_Syntax_Const.nil_lid
                                FStar_Syntax_Syntax.Delta_constant
                                (Some FStar_Syntax_Syntax.Data_ctor) in
                            (uu____2319, []) in
                          FStar_Syntax_Syntax.Pat_cons uu____2311 in
                        FStar_All.pipe_left uu____2304 uu____2310 in
                      FStar_List.fold_right
                        (fun hd1  ->
                           fun tl1  ->
                             let r =
                               FStar_Range.union_ranges
                                 hd1.FStar_Syntax_Syntax.p
                                 tl1.FStar_Syntax_Syntax.p in
                             let uu____2342 =
                               let uu____2343 =
                                 let uu____2351 =
                                   FStar_Syntax_Syntax.lid_as_fv
                                     FStar_Syntax_Const.cons_lid
                                     FStar_Syntax_Syntax.Delta_constant
                                     (Some FStar_Syntax_Syntax.Data_ctor) in
                                 (uu____2351, [(hd1, false); (tl1, false)]) in
                               FStar_Syntax_Syntax.Pat_cons uu____2343 in
                             FStar_All.pipe_left (pos_r r) uu____2342) pats1
                        uu____2301 in
                    let x =
                      FStar_Syntax_Syntax.new_bv
                        (Some (p1.FStar_Parser_AST.prange))
                        FStar_Syntax_Syntax.tun in
                    (loc1, env2, (LocalBinder (x, None)), pat, false))
           | FStar_Parser_AST.PatTuple (args,dep1) ->
               let uu____2383 =
                 FStar_List.fold_left
                   (fun uu____2400  ->
                      fun p2  ->
                        match uu____2400 with
                        | (loc1,env2,pats) ->
                            let uu____2431 = aux loc1 env2 p2 in
                            (match uu____2431 with
                             | (loc2,env3,uu____2449,pat,uu____2451) ->
                                 (loc2, env3, ((pat, false) :: pats))))
                   (loc, env1, []) args in
               (match uu____2383 with
                | (loc1,env2,args1) ->
                    let args2 = FStar_List.rev args1 in
                    let l =
                      if dep1
                      then
                        FStar_Syntax_Util.mk_dtuple_data_lid
                          (FStar_List.length args2)
                          p1.FStar_Parser_AST.prange
                      else
                        FStar_Syntax_Util.mk_tuple_data_lid
                          (FStar_List.length args2)
                          p1.FStar_Parser_AST.prange in
                    let uu____2522 =
                      FStar_ToSyntax_Env.fail_or env2
                        (FStar_ToSyntax_Env.try_lookup_lid env2) l in
                    (match uu____2522 with
                     | (constr,uu____2535) ->
                         let l1 =
                           match constr.FStar_Syntax_Syntax.n with
                           | FStar_Syntax_Syntax.Tm_fvar fv -> fv
                           | uu____2538 -> failwith "impossible" in
                         let x =
                           FStar_Syntax_Syntax.new_bv
                             (Some (p1.FStar_Parser_AST.prange))
                             FStar_Syntax_Syntax.tun in
                         let uu____2540 =
                           FStar_All.pipe_left pos
                             (FStar_Syntax_Syntax.Pat_cons (l1, args2)) in
                         (loc1, env2, (LocalBinder (x, None)), uu____2540,
                           false)))
           | FStar_Parser_AST.PatRecord [] ->
               raise
                 (FStar_Errors.Error
                    ("Unexpected pattern", (p1.FStar_Parser_AST.prange)))
           | FStar_Parser_AST.PatRecord fields ->
               let record =
                 check_fields env1 fields p1.FStar_Parser_AST.prange in
               let fields1 =
                 FStar_All.pipe_right fields
                   (FStar_List.map
                      (fun uu____2581  ->
                         match uu____2581 with
                         | (f,p2) -> ((f.FStar_Ident.ident), p2))) in
               let args =
                 FStar_All.pipe_right record.FStar_ToSyntax_Env.fields
                   (FStar_List.map
                      (fun uu____2596  ->
                         match uu____2596 with
                         | (f,uu____2600) ->
                             let uu____2601 =
                               FStar_All.pipe_right fields1
                                 (FStar_List.tryFind
                                    (fun uu____2613  ->
                                       match uu____2613 with
                                       | (g,uu____2617) ->
                                           f.FStar_Ident.idText =
                                             g.FStar_Ident.idText)) in
                             (match uu____2601 with
                              | None  ->
                                  FStar_Parser_AST.mk_pattern
                                    FStar_Parser_AST.PatWild
                                    p1.FStar_Parser_AST.prange
                              | Some (uu____2620,p2) -> p2))) in
               let app =
                 let uu____2625 =
                   let uu____2626 =
                     let uu____2630 =
                       let uu____2631 =
                         let uu____2632 =
                           FStar_Ident.lid_of_ids
                             (FStar_List.append
                                (record.FStar_ToSyntax_Env.typename).FStar_Ident.ns
                                [record.FStar_ToSyntax_Env.constrname]) in
                         FStar_Parser_AST.PatName uu____2632 in
                       FStar_Parser_AST.mk_pattern uu____2631
                         p1.FStar_Parser_AST.prange in
                     (uu____2630, args) in
                   FStar_Parser_AST.PatApp uu____2626 in
                 FStar_Parser_AST.mk_pattern uu____2625
                   p1.FStar_Parser_AST.prange in
               let uu____2634 = aux loc env1 app in
               (match uu____2634 with
                | (env2,e,b,p2,uu____2653) ->
                    let p3 =
                      match p2.FStar_Syntax_Syntax.v with
                      | FStar_Syntax_Syntax.Pat_cons (fv,args1) ->
                          let uu____2675 =
                            let uu____2676 =
                              let uu____2684 =
                                let uu___224_2685 = fv in
                                let uu____2686 =
                                  let uu____2688 =
                                    let uu____2689 =
                                      let uu____2693 =
                                        FStar_All.pipe_right
                                          record.FStar_ToSyntax_Env.fields
                                          (FStar_List.map
                                             FStar_Pervasives.fst) in
                                      ((record.FStar_ToSyntax_Env.typename),
                                        uu____2693) in
                                    FStar_Syntax_Syntax.Record_ctor
                                      uu____2689 in
                                  Some uu____2688 in
                                {
                                  FStar_Syntax_Syntax.fv_name =
                                    (uu___224_2685.FStar_Syntax_Syntax.fv_name);
                                  FStar_Syntax_Syntax.fv_delta =
                                    (uu___224_2685.FStar_Syntax_Syntax.fv_delta);
                                  FStar_Syntax_Syntax.fv_qual = uu____2686
                                } in
                              (uu____2684, args1) in
                            FStar_Syntax_Syntax.Pat_cons uu____2676 in
                          FStar_All.pipe_left pos uu____2675
                      | uu____2712 -> p2 in
                    (env2, e, b, p3, false)) in
         let uu____2715 = aux [] env p in
         match uu____2715 with
         | (uu____2726,env1,b,p1,uu____2730) ->
             ((let uu____2736 = check_linear_pattern_variables p1 in
               FStar_All.pipe_left FStar_Pervasives.ignore uu____2736);
              (env1, b, p1)))
and desugar_binding_pat_maybe_top:
  Prims.bool ->
    FStar_ToSyntax_Env.env ->
      FStar_Parser_AST.pattern ->
        Prims.bool -> (env_t* bnd* FStar_Syntax_Syntax.pat option)
  =
  fun top  ->
    fun env  ->
      fun p  ->
        fun is_mut  ->
          let mklet x =
            let uu____2755 =
              let uu____2756 =
                let uu____2759 = FStar_ToSyntax_Env.qualify env x in
                (uu____2759, FStar_Syntax_Syntax.tun) in
              LetBinder uu____2756 in
            (env, uu____2755, None) in
          if top
          then
            match p.FStar_Parser_AST.pat with
            | FStar_Parser_AST.PatOp x ->
                let uu____2770 =
                  let uu____2771 =
                    let uu____2774 =
                      FStar_Parser_AST.compile_op (Prims.parse_int "0")
                        x.FStar_Ident.idText in
                    (uu____2774, (x.FStar_Ident.idRange)) in
                  FStar_Ident.mk_ident uu____2771 in
                mklet uu____2770
            | FStar_Parser_AST.PatVar (x,uu____2776) -> mklet x
            | FStar_Parser_AST.PatAscribed
                ({
                   FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                     (x,uu____2780);
                   FStar_Parser_AST.prange = uu____2781;_},t)
                ->
                let uu____2785 =
                  let uu____2786 =
                    let uu____2789 = FStar_ToSyntax_Env.qualify env x in
                    let uu____2790 = desugar_term env t in
                    (uu____2789, uu____2790) in
                  LetBinder uu____2786 in
                (env, uu____2785, None)
            | uu____2792 ->
                raise
                  (FStar_Errors.Error
                     ("Unexpected pattern at the top-level",
                       (p.FStar_Parser_AST.prange)))
          else
            (let uu____2798 = desugar_data_pat env p is_mut in
             match uu____2798 with
             | (env1,binder,p1) ->
                 let p2 =
                   match p1.FStar_Syntax_Syntax.v with
                   | FStar_Syntax_Syntax.Pat_var uu____2812 -> None
                   | FStar_Syntax_Syntax.Pat_wild uu____2813 -> None
                   | uu____2814 -> Some p1 in
                 (env1, binder, p2))
and desugar_binding_pat:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.pattern -> (env_t* bnd* FStar_Syntax_Syntax.pat option)
  = fun env  -> fun p  -> desugar_binding_pat_maybe_top false env p false
and desugar_match_pat_maybe_top:
  Prims.bool ->
    FStar_ToSyntax_Env.env ->
      FStar_Parser_AST.pattern -> (env_t* FStar_Syntax_Syntax.pat)
  =
  fun uu____2818  ->
    fun env  ->
      fun pat  ->
        let uu____2821 = desugar_data_pat env pat false in
        match uu____2821 with | (env1,uu____2828,pat1) -> (env1, pat1)
and desugar_match_pat:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.pattern -> (env_t* FStar_Syntax_Syntax.pat)
  = fun env  -> fun p  -> desugar_match_pat_maybe_top false env p
and desugar_term:
  FStar_ToSyntax_Env.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun e  ->
      let env1 = FStar_ToSyntax_Env.set_expect_typ env false in
      desugar_term_maybe_top false env1 e
and desugar_typ:
  FStar_ToSyntax_Env.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun e  ->
      let env1 = FStar_ToSyntax_Env.set_expect_typ env true in
      desugar_term_maybe_top false env1 e
and desugar_machine_integer:
  FStar_ToSyntax_Env.env ->
    Prims.string ->
      (FStar_Const.signedness* FStar_Const.width) ->
        FStar_Range.range ->
          (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
            FStar_Syntax_Syntax.syntax
  =
  fun env  ->
    fun repr  ->
      fun uu____2840  ->
        fun range  ->
          match uu____2840 with
          | (signedness,width) ->
              let uu____2848 = FStar_Const.bounds signedness width in
              (match uu____2848 with
               | (lower,upper) ->
                   let value =
                     let uu____2856 = FStar_Util.ensure_decimal repr in
                     FStar_Util.int_of_string uu____2856 in
                   let tnm =
                     Prims.strcat "FStar."
                       (Prims.strcat
                          (match signedness with
                           | FStar_Const.Unsigned  -> "U"
                           | FStar_Const.Signed  -> "")
                          (Prims.strcat "Int"
                             (match width with
                              | FStar_Const.Int8  -> "8"
                              | FStar_Const.Int16  -> "16"
                              | FStar_Const.Int32  -> "32"
                              | FStar_Const.Int64  -> "64"))) in
                   (if
                      Prims.op_Negation
                        ((lower <= value) && (value <= upper))
                    then
                      (let uu____2859 =
                         let uu____2860 =
                           let uu____2863 =
                             FStar_Util.format2
                               "%s is not in the expected range for %s" repr
                               tnm in
                           (uu____2863, range) in
                         FStar_Errors.Error uu____2860 in
                       raise uu____2859)
                    else ();
                    (let private_intro_nm =
                       Prims.strcat tnm
                         (Prims.strcat ".__"
                            (Prims.strcat
                               (match signedness with
                                | FStar_Const.Unsigned  -> "u"
                                | FStar_Const.Signed  -> "") "int_to_t")) in
                     let intro_nm =
                       Prims.strcat tnm
                         (Prims.strcat "."
                            (Prims.strcat
                               (match signedness with
                                | FStar_Const.Unsigned  -> "u"
                                | FStar_Const.Signed  -> "") "int_to_t")) in
                     let lid =
                       FStar_Ident.lid_of_path
                         (FStar_Ident.path_of_text intro_nm) range in
                     let lid1 =
                       let uu____2871 =
                         FStar_ToSyntax_Env.try_lookup_lid env lid in
                       match uu____2871 with
                       | Some (intro_term,uu____2878) ->
                           (match intro_term.FStar_Syntax_Syntax.n with
                            | FStar_Syntax_Syntax.Tm_fvar fv ->
                                let private_lid =
                                  FStar_Ident.lid_of_path
                                    (FStar_Ident.path_of_text
                                       private_intro_nm) range in
                                let private_fv =
                                  let uu____2886 =
                                    FStar_Syntax_Util.incr_delta_depth
                                      fv.FStar_Syntax_Syntax.fv_delta in
                                  FStar_Syntax_Syntax.lid_as_fv private_lid
                                    uu____2886 fv.FStar_Syntax_Syntax.fv_qual in
                                let uu___225_2887 = intro_term in
                                {
                                  FStar_Syntax_Syntax.n =
                                    (FStar_Syntax_Syntax.Tm_fvar private_fv);
                                  FStar_Syntax_Syntax.tk =
                                    (uu___225_2887.FStar_Syntax_Syntax.tk);
                                  FStar_Syntax_Syntax.pos =
                                    (uu___225_2887.FStar_Syntax_Syntax.pos);
                                  FStar_Syntax_Syntax.vars =
                                    (uu___225_2887.FStar_Syntax_Syntax.vars)
                                }
                            | uu____2892 ->
                                failwith
                                  (Prims.strcat "Unexpected non-fvar for "
                                     intro_nm))
                       | None  ->
                           let uu____2897 =
                             FStar_Util.format1 "%s not in scope\n" tnm in
                           failwith uu____2897 in
                     let repr1 =
                       (FStar_Syntax_Syntax.mk
                          (FStar_Syntax_Syntax.Tm_constant
                             (FStar_Const.Const_int (repr, None)))) None
                         range in
                     let uu____2916 =
                       let uu____2919 =
                         let uu____2920 =
                           let uu____2930 =
                             let uu____2936 =
                               let uu____2941 =
                                 FStar_Syntax_Syntax.as_implicit false in
                               (repr1, uu____2941) in
                             [uu____2936] in
                           (lid1, uu____2930) in
                         FStar_Syntax_Syntax.Tm_app uu____2920 in
                       FStar_Syntax_Syntax.mk uu____2919 in
                     uu____2916 None range)))
and desugar_name:
  (FStar_Syntax_Syntax.term' -> FStar_Syntax_Syntax.term) ->
    (FStar_Syntax_Syntax.term ->
       (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
         FStar_Syntax_Syntax.syntax)
      -> env_t -> Prims.bool -> FStar_Ident.lid -> FStar_Syntax_Syntax.term
  =
  fun mk1  ->
    fun setpos  ->
      fun env  ->
        fun resolve  ->
          fun l  ->
            let uu____2978 =
              FStar_ToSyntax_Env.fail_or env
                ((if resolve
                  then FStar_ToSyntax_Env.try_lookup_lid
                  else FStar_ToSyntax_Env.try_lookup_lid_no_resolve) env) l in
            match uu____2978 with
            | (tm,mut) ->
                let tm1 = setpos tm in
                if mut
                then
                  let uu____2996 =
                    let uu____2997 =
                      let uu____3002 = mk_ref_read tm1 in
                      (uu____3002,
                        (FStar_Syntax_Syntax.Meta_desugared
                           FStar_Syntax_Syntax.Mutable_rval)) in
                    FStar_Syntax_Syntax.Tm_meta uu____2997 in
                  FStar_All.pipe_left mk1 uu____2996
                else tm1
and desugar_attributes:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.term Prims.list -> FStar_Syntax_Syntax.cflags Prims.list
  =
  fun env  ->
    fun cattributes  ->
      let desugar_attribute t =
        let uu____3016 =
          let uu____3017 = unparen t in uu____3017.FStar_Parser_AST.tm in
        match uu____3016 with
        | FStar_Parser_AST.Var
            { FStar_Ident.ns = uu____3018; FStar_Ident.ident = uu____3019;
              FStar_Ident.nsstr = uu____3020; FStar_Ident.str = "cps";_}
            -> FStar_Syntax_Syntax.CPS
        | uu____3022 ->
            let uu____3023 =
              let uu____3024 =
                let uu____3027 =
                  let uu____3028 = FStar_Parser_AST.term_to_string t in
                  Prims.strcat "Unknown attribute " uu____3028 in
                (uu____3027, (t.FStar_Parser_AST.range)) in
              FStar_Errors.Error uu____3024 in
            raise uu____3023 in
      FStar_List.map desugar_attribute cattributes
and desugar_term_maybe_top:
  Prims.bool -> env_t -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term =
  fun top_level  ->
    fun env  ->
      fun top  ->
        let mk1 e =
          (FStar_Syntax_Syntax.mk e) None top.FStar_Parser_AST.range in
        let setpos e =
          let uu___226_3056 = e in
          {
            FStar_Syntax_Syntax.n = (uu___226_3056.FStar_Syntax_Syntax.n);
            FStar_Syntax_Syntax.tk = (uu___226_3056.FStar_Syntax_Syntax.tk);
            FStar_Syntax_Syntax.pos = (top.FStar_Parser_AST.range);
            FStar_Syntax_Syntax.vars =
              (uu___226_3056.FStar_Syntax_Syntax.vars)
          } in
        let uu____3063 =
          let uu____3064 = unparen top in uu____3064.FStar_Parser_AST.tm in
        match uu____3063 with
        | FStar_Parser_AST.Wild  -> setpos FStar_Syntax_Syntax.tun
        | FStar_Parser_AST.Labeled uu____3065 -> desugar_formula env top
        | FStar_Parser_AST.Requires (t,lopt) -> desugar_formula env t
        | FStar_Parser_AST.Ensures (t,lopt) -> desugar_formula env t
        | FStar_Parser_AST.Attributes ts ->
            failwith
              "Attributes should not be desugared by desugar_term_maybe_top"
        | FStar_Parser_AST.Const (FStar_Const.Const_int (i,Some size)) ->
            desugar_machine_integer env i size top.FStar_Parser_AST.range
        | FStar_Parser_AST.Const c -> mk1 (FStar_Syntax_Syntax.Tm_constant c)
        | FStar_Parser_AST.Op
            ({ FStar_Ident.idText = "=!="; FStar_Ident.idRange = r;_},args)
            ->
            let e =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Op ((FStar_Ident.mk_ident ("==", r)), args))
                top.FStar_Parser_AST.range top.FStar_Parser_AST.level in
            desugar_term env
              (FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Op ((FStar_Ident.mk_ident ("~", r)), [e]))
                 top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
        | FStar_Parser_AST.Op (op_star,uu____3097::uu____3098::[]) when
            ((FStar_Ident.text_of_id op_star) = "*") &&
              (let uu____3100 =
                 op_as_term env (Prims.parse_int "2")
                   top.FStar_Parser_AST.range op_star in
               FStar_All.pipe_right uu____3100 FStar_Option.isNone)
            ->
            let rec flatten1 t =
              match t.FStar_Parser_AST.tm with
              | FStar_Parser_AST.Op
                  ({ FStar_Ident.idText = "*";
                     FStar_Ident.idRange = uu____3109;_},t1::t2::[])
                  ->
                  let uu____3113 = flatten1 t1 in
                  FStar_List.append uu____3113 [t2]
              | uu____3115 -> [t] in
            let targs =
              let uu____3118 =
                let uu____3120 = unparen top in flatten1 uu____3120 in
              FStar_All.pipe_right uu____3118
                (FStar_List.map
                   (fun t  ->
                      let uu____3124 = desugar_typ env t in
                      FStar_Syntax_Syntax.as_arg uu____3124)) in
            let uu____3125 =
              let uu____3128 =
                FStar_Syntax_Util.mk_tuple_lid (FStar_List.length targs)
                  top.FStar_Parser_AST.range in
              FStar_ToSyntax_Env.fail_or env
                (FStar_ToSyntax_Env.try_lookup_lid env) uu____3128 in
            (match uu____3125 with
             | (tup,uu____3135) ->
                 mk1 (FStar_Syntax_Syntax.Tm_app (tup, targs)))
        | FStar_Parser_AST.Tvar a ->
            let uu____3138 =
              let uu____3141 =
                FStar_ToSyntax_Env.fail_or2
                  (FStar_ToSyntax_Env.try_lookup_id env) a in
              fst uu____3141 in
            FStar_All.pipe_left setpos uu____3138
        | FStar_Parser_AST.Uvar u ->
            raise
              (FStar_Errors.Error
                 ((Prims.strcat "Unexpected universe variable "
                     (Prims.strcat (FStar_Ident.text_of_id u)
                        " in non-universe context")),
                   (top.FStar_Parser_AST.range)))
        | FStar_Parser_AST.Op (s,args) ->
            let uu____3155 =
              op_as_term env (FStar_List.length args)
                top.FStar_Parser_AST.range s in
            (match uu____3155 with
             | None  ->
                 raise
                   (FStar_Errors.Error
                      ((Prims.strcat "Unexpected or unbound operator: "
                          (FStar_Ident.text_of_id s)),
                        (top.FStar_Parser_AST.range)))
             | Some op ->
                 if (FStar_List.length args) > (Prims.parse_int "0")
                 then
                   let args1 =
                     FStar_All.pipe_right args
                       (FStar_List.map
                          (fun t  ->
                             let uu____3177 = desugar_term env t in
                             (uu____3177, None))) in
                   mk1 (FStar_Syntax_Syntax.Tm_app (op, args1))
                 else op)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____3184; FStar_Ident.ident = uu____3185;
              FStar_Ident.nsstr = uu____3186; FStar_Ident.str = "Type0";_}
            -> mk1 (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_zero)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____3188; FStar_Ident.ident = uu____3189;
              FStar_Ident.nsstr = uu____3190; FStar_Ident.str = "Type";_}
            ->
            mk1 (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown)
        | FStar_Parser_AST.Construct
            ({ FStar_Ident.ns = uu____3192; FStar_Ident.ident = uu____3193;
               FStar_Ident.nsstr = uu____3194; FStar_Ident.str = "Type";_},
             (t,FStar_Parser_AST.UnivApp )::[])
            ->
            let uu____3204 =
              let uu____3205 = desugar_universe t in
              FStar_Syntax_Syntax.Tm_type uu____3205 in
            mk1 uu____3204
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____3206; FStar_Ident.ident = uu____3207;
              FStar_Ident.nsstr = uu____3208; FStar_Ident.str = "Effect";_}
            -> mk1 (FStar_Syntax_Syntax.Tm_constant FStar_Const.Const_effect)
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____3210; FStar_Ident.ident = uu____3211;
              FStar_Ident.nsstr = uu____3212; FStar_Ident.str = "True";_}
            ->
            FStar_Syntax_Syntax.fvar
              (FStar_Ident.set_lid_range FStar_Parser_Const.true_lid
                 top.FStar_Parser_AST.range)
              FStar_Syntax_Syntax.Delta_constant None
        | FStar_Parser_AST.Name
            { FStar_Ident.ns = uu____3214; FStar_Ident.ident = uu____3215;
              FStar_Ident.nsstr = uu____3216; FStar_Ident.str = "False";_}
            ->
            FStar_Syntax_Syntax.fvar
              (FStar_Ident.set_lid_range FStar_Parser_Const.false_lid
                 top.FStar_Parser_AST.range)
              FStar_Syntax_Syntax.Delta_constant None
        | FStar_Parser_AST.Projector
            (eff_name,{ FStar_Ident.idText = txt;
                        FStar_Ident.idRange = uu____3220;_})
            when
            (is_special_effect_combinator txt) &&
              (FStar_ToSyntax_Env.is_effect_name env eff_name)
            ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env eff_name;
             (let uu____3222 =
                FStar_ToSyntax_Env.try_lookup_effect_defn env eff_name in
              match uu____3222 with
              | Some ed ->
                  let lid = FStar_Syntax_Util.dm4f_lid ed txt in
                  FStar_Syntax_Syntax.fvar lid
                    (FStar_Syntax_Syntax.Delta_defined_at_level
                       (Prims.parse_int "1")) None
              | None  ->
                  let uu____3226 =
                    FStar_Util.format2
                      "Member %s of effect %s is not accessible (using an effect abbreviation instead of the original effect ?)"
                      (FStar_Ident.text_of_lid eff_name) txt in
                  failwith uu____3226))
        | FStar_Parser_AST.Assign (ident,t2) ->
            let t21 = desugar_term env t2 in
            let uu____3230 =
              FStar_ToSyntax_Env.fail_or2
                (FStar_ToSyntax_Env.try_lookup_id env) ident in
            (match uu____3230 with
             | (t1,mut) ->
                 (if Prims.op_Negation mut
                  then
                    raise
                      (FStar_Errors.Error
                         ("Can only assign to mutable values",
                           (top.FStar_Parser_AST.range)))
                  else ();
                  mk_ref_assign t1 t21 top.FStar_Parser_AST.range))
        | FStar_Parser_AST.Var l ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env l;
             desugar_name mk1 setpos env true l)
        | FStar_Parser_AST.Name l ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env l;
             desugar_name mk1 setpos env true l)
        | FStar_Parser_AST.Projector (l,i) ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env l;
             (let name =
                let uu____3250 = FStar_ToSyntax_Env.try_lookup_datacon env l in
                match uu____3250 with
                | Some uu____3255 -> Some (true, l)
                | None  ->
                    let uu____3258 =
                      FStar_ToSyntax_Env.try_lookup_root_effect_name env l in
                    (match uu____3258 with
                     | Some new_name -> Some (false, new_name)
                     | uu____3266 -> None) in
              match name with
              | Some (resolve,new_name) ->
                  let uu____3274 =
                    FStar_Syntax_Util.mk_field_projector_name_from_ident
                      new_name i in
                  desugar_name mk1 setpos env resolve uu____3274
              | uu____3275 ->
                  let uu____3279 =
                    let uu____3280 =
                      let uu____3283 =
                        FStar_Util.format1
                          "Data constructor or effect %s not found"
                          l.FStar_Ident.str in
                      (uu____3283, (top.FStar_Parser_AST.range)) in
                    FStar_Errors.Error uu____3280 in
                  raise uu____3279))
        | FStar_Parser_AST.Discrim lid ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env lid;
             (let uu____3286 = FStar_ToSyntax_Env.try_lookup_datacon env lid in
              match uu____3286 with
              | None  ->
                  let uu____3288 =
                    let uu____3289 =
                      let uu____3292 =
                        FStar_Util.format1 "Data constructor %s not found"
                          lid.FStar_Ident.str in
                      (uu____3292, (top.FStar_Parser_AST.range)) in
                    FStar_Errors.Error uu____3289 in
                  raise uu____3288
              | uu____3293 ->
                  let lid' = FStar_Syntax_Util.mk_discriminator lid in
                  desugar_name mk1 setpos env true lid'))
        | FStar_Parser_AST.Construct (l,args) ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env l;
             (let uu____3305 = FStar_ToSyntax_Env.try_lookup_datacon env l in
              match uu____3305 with
              | Some head1 ->
                  let uu____3308 =
                    let uu____3313 = mk1 (FStar_Syntax_Syntax.Tm_fvar head1) in
                    (uu____3313, true) in
                  (match uu____3308 with
                   | (head2,is_data) ->
                       (match args with
                        | [] -> head2
                        | uu____3326 ->
                            let uu____3330 =
                              FStar_Util.take
                                (fun uu____3341  ->
                                   match uu____3341 with
                                   | (uu____3344,imp) ->
                                       imp = FStar_Parser_AST.UnivApp) args in
                            (match uu____3330 with
                             | (universes,args1) ->
                                 let universes1 =
                                   FStar_List.map
                                     (fun x  -> desugar_universe (fst x))
                                     universes in
                                 let args2 =
                                   FStar_List.map
                                     (fun uu____3377  ->
                                        match uu____3377 with
                                        | (t,imp) ->
                                            let te = desugar_term env t in
                                            arg_withimp_e imp te) args1 in
                                 let head3 =
                                   if universes1 = []
                                   then head2
                                   else
                                     mk1
                                       (FStar_Syntax_Syntax.Tm_uinst
                                          (head2, universes1)) in
                                 let app =
                                   mk1
                                     (FStar_Syntax_Syntax.Tm_app
                                        (head3, args2)) in
                                 if is_data
                                 then
                                   mk1
                                     (FStar_Syntax_Syntax.Tm_meta
                                        (app,
                                          (FStar_Syntax_Syntax.Meta_desugared
                                             FStar_Syntax_Syntax.Data_app)))
                                 else app)))
              | None  ->
                  let error_msg =
                    let uu____3409 =
                      FStar_ToSyntax_Env.try_lookup_effect_name env l in
                    match uu____3409 with
                    | None  ->
                        Prims.strcat "Constructor "
                          (Prims.strcat l.FStar_Ident.str " not found")
                    | Some uu____3411 ->
                        Prims.strcat "Effect "
                          (Prims.strcat l.FStar_Ident.str
                             " used at an unexpected position") in
                  raise
                    (FStar_Errors.Error
                       (error_msg, (top.FStar_Parser_AST.range)))))
        | FStar_Parser_AST.Sum (binders,t) ->
            let uu____3416 =
              FStar_List.fold_left
                (fun uu____3433  ->
                   fun b  ->
                     match uu____3433 with
                     | (env1,tparams,typs) ->
                         let uu____3464 = desugar_binder env1 b in
                         (match uu____3464 with
                          | (xopt,t1) ->
                              let uu____3480 =
                                match xopt with
                                | None  ->
                                    let uu____3485 =
                                      FStar_Syntax_Syntax.new_bv
                                        (Some (top.FStar_Parser_AST.range))
                                        FStar_Syntax_Syntax.tun in
                                    (env1, uu____3485)
                                | Some x -> FStar_ToSyntax_Env.push_bv env1 x in
                              (match uu____3480 with
                               | (env2,x) ->
                                   let uu____3497 =
                                     let uu____3499 =
                                       let uu____3501 =
                                         let uu____3502 =
                                           no_annot_abs tparams t1 in
                                         FStar_All.pipe_left
                                           FStar_Syntax_Syntax.as_arg
                                           uu____3502 in
                                       [uu____3501] in
                                     FStar_List.append typs uu____3499 in
                                   (env2,
                                     (FStar_List.append tparams
                                        [(((let uu___227_3515 = x in
                                            {
                                              FStar_Syntax_Syntax.ppname =
                                                (uu___227_3515.FStar_Syntax_Syntax.ppname);
                                              FStar_Syntax_Syntax.index =
                                                (uu___227_3515.FStar_Syntax_Syntax.index);
                                              FStar_Syntax_Syntax.sort = t1
                                            })), None)]), uu____3497))))
                (env, [], [])
                (FStar_List.append binders
                   [FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName t)
                      t.FStar_Parser_AST.range FStar_Parser_AST.Type_level
                      None]) in
            (match uu____3416 with
             | (env1,uu____3528,targs) ->
                 let uu____3540 =
                   let uu____3543 =
                     FStar_Syntax_Util.mk_dtuple_lid
                       (FStar_List.length targs) top.FStar_Parser_AST.range in
                   FStar_ToSyntax_Env.fail_or env1
                     (FStar_ToSyntax_Env.try_lookup_lid env1) uu____3543 in
                 (match uu____3540 with
                  | (tup,uu____3550) ->
                      FStar_All.pipe_left mk1
                        (FStar_Syntax_Syntax.Tm_app (tup, targs))))
        | FStar_Parser_AST.Product (binders,t) ->
            let uu____3558 = uncurry binders t in
            (match uu____3558 with
             | (bs,t1) ->
                 let rec aux env1 bs1 uu___206_3581 =
                   match uu___206_3581 with
                   | [] ->
                       let cod =
                         desugar_comp top.FStar_Parser_AST.range env1 t1 in
                       let uu____3591 =
                         FStar_Syntax_Util.arrow (FStar_List.rev bs1) cod in
                       FStar_All.pipe_left setpos uu____3591
                   | hd1::tl1 ->
                       let bb = desugar_binder env1 hd1 in
                       let uu____3607 =
                         as_binder env1 hd1.FStar_Parser_AST.aqual bb in
                       (match uu____3607 with
                        | (b,env2) -> aux env2 (b :: bs1) tl1) in
                 aux env [] bs)
        | FStar_Parser_AST.Refine (b,f) ->
            let uu____3618 = desugar_binder env b in
            (match uu____3618 with
             | (None ,uu____3622) -> failwith "Missing binder in refinement"
             | b1 ->
                 let uu____3628 = as_binder env None b1 in
                 (match uu____3628 with
                  | ((x,uu____3632),env1) ->
                      let f1 = desugar_formula env1 f in
                      let uu____3637 = FStar_Syntax_Util.refine x f1 in
                      FStar_All.pipe_left setpos uu____3637))
        | FStar_Parser_AST.Abs (binders,body) ->
            let binders1 =
              FStar_All.pipe_right binders
                (FStar_List.map replace_unit_pattern) in
            let uu____3652 =
              FStar_List.fold_left
                (fun uu____3659  ->
                   fun pat  ->
                     match uu____3659 with
                     | (env1,ftvs) ->
                         (match pat.FStar_Parser_AST.pat with
                          | FStar_Parser_AST.PatAscribed (uu____3674,t) ->
                              let uu____3676 =
                                let uu____3678 = free_type_vars env1 t in
                                FStar_List.append uu____3678 ftvs in
                              (env1, uu____3676)
                          | uu____3681 -> (env1, ftvs))) (env, []) binders1 in
            (match uu____3652 with
             | (uu____3684,ftv) ->
                 let ftv1 = sort_ftv ftv in
                 let binders2 =
                   let uu____3692 =
                     FStar_All.pipe_right ftv1
                       (FStar_List.map
                          (fun a  ->
                             FStar_Parser_AST.mk_pattern
                               (FStar_Parser_AST.PatTvar
                                  (a, (Some FStar_Parser_AST.Implicit)))
                               top.FStar_Parser_AST.range)) in
                   FStar_List.append uu____3692 binders1 in
                 let rec aux env1 bs sc_pat_opt uu___207_3721 =
                   match uu___207_3721 with
                   | [] ->
                       let body1 = desugar_term env1 body in
                       let body2 =
                         match sc_pat_opt with
                         | Some (sc,pat) ->
                             let body2 =
                               let uu____3750 =
                                 let uu____3751 =
                                   FStar_Syntax_Syntax.pat_bvs pat in
                                 FStar_All.pipe_right uu____3751
                                   (FStar_List.map
                                      FStar_Syntax_Syntax.mk_binder) in
                               FStar_Syntax_Subst.close uu____3750 body1 in
                             (FStar_Syntax_Syntax.mk
                                (FStar_Syntax_Syntax.Tm_match
                                   (sc, [(pat, None, body2)]))) None
                               body2.FStar_Syntax_Syntax.pos
                         | None  -> body1 in
                       let uu____3793 =
                         no_annot_abs (FStar_List.rev bs) body2 in
                       setpos uu____3793
                   | p::rest ->
                       let uu____3801 = desugar_binding_pat env1 p in
                       (match uu____3801 with
                        | (env2,b,pat) ->
                            let uu____3813 =
                              match b with
                              | LetBinder uu____3832 -> failwith "Impossible"
                              | LocalBinder (x,aq) ->
                                  let sc_pat_opt1 =
                                    match (pat, sc_pat_opt) with
                                    | (None ,uu____3863) -> sc_pat_opt
                                    | (Some p1,None ) ->
                                        let uu____3886 =
                                          let uu____3889 =
                                            FStar_Syntax_Syntax.bv_to_name x in
                                          (uu____3889, p1) in
                                        Some uu____3886
                                    | (Some p1,Some (sc,p')) ->
                                        (match ((sc.FStar_Syntax_Syntax.n),
                                                 (p'.FStar_Syntax_Syntax.v))
                                         with
                                         | (FStar_Syntax_Syntax.Tm_name
                                            uu____3914,uu____3915) ->
                                             let tup2 =
                                               let uu____3917 =
                                                 FStar_Syntax_Util.mk_tuple_data_lid
                                                   (Prims.parse_int "2")
                                                   top.FStar_Parser_AST.range in
                                               FStar_Syntax_Syntax.lid_as_fv
                                                 uu____3917
                                                 FStar_Syntax_Syntax.Delta_constant
                                                 (Some
                                                    FStar_Syntax_Syntax.Data_ctor) in
                                             let sc1 =
                                               let uu____3921 =
                                                 let uu____3924 =
                                                   let uu____3925 =
                                                     let uu____3935 =
                                                       mk1
                                                         (FStar_Syntax_Syntax.Tm_fvar
                                                            tup2) in
                                                     let uu____3938 =
                                                       let uu____3940 =
                                                         FStar_Syntax_Syntax.as_arg
                                                           sc in
                                                       let uu____3941 =
                                                         let uu____3943 =
                                                           let uu____3944 =
                                                             FStar_Syntax_Syntax.bv_to_name
                                                               x in
                                                           FStar_All.pipe_left
                                                             FStar_Syntax_Syntax.as_arg
                                                             uu____3944 in
                                                         [uu____3943] in
                                                       uu____3940 ::
                                                         uu____3941 in
                                                     (uu____3935, uu____3938) in
                                                   FStar_Syntax_Syntax.Tm_app
                                                     uu____3925 in
                                                 FStar_Syntax_Syntax.mk
                                                   uu____3924 in
                                               uu____3921 None
                                                 top.FStar_Parser_AST.range in
                                             let p2 =
                                               let uu____3959 =
                                                 FStar_Range.union_ranges
                                                   p'.FStar_Syntax_Syntax.p
                                                   p1.FStar_Syntax_Syntax.p in
                                               FStar_Syntax_Syntax.withinfo
                                                 (FStar_Syntax_Syntax.Pat_cons
                                                    (tup2,
                                                      [(p', false);
                                                      (p1, false)]))
                                                 FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
                                                 uu____3959 in
                                             Some (sc1, p2)
                                         | (FStar_Syntax_Syntax.Tm_app
                                            (uu____3979,args),FStar_Syntax_Syntax.Pat_cons
                                            (uu____3981,pats)) ->
                                             let tupn =
                                               let uu____4008 =
                                                 FStar_Syntax_Util.mk_tuple_data_lid
                                                   ((Prims.parse_int "1") +
                                                      (FStar_List.length args))
                                                   top.FStar_Parser_AST.range in
                                               FStar_Syntax_Syntax.lid_as_fv
                                                 uu____4008
                                                 FStar_Syntax_Syntax.Delta_constant
                                                 (Some
                                                    FStar_Syntax_Syntax.Data_ctor) in
                                             let sc1 =
                                               let uu____4018 =
                                                 let uu____4019 =
                                                   let uu____4029 =
                                                     mk1
                                                       (FStar_Syntax_Syntax.Tm_fvar
                                                          tupn) in
                                                   let uu____4032 =
                                                     let uu____4038 =
                                                       let uu____4044 =
                                                         let uu____4045 =
                                                           FStar_Syntax_Syntax.bv_to_name
                                                             x in
                                                         FStar_All.pipe_left
                                                           FStar_Syntax_Syntax.as_arg
                                                           uu____4045 in
                                                       [uu____4044] in
                                                     FStar_List.append args
                                                       uu____4038 in
                                                   (uu____4029, uu____4032) in
                                                 FStar_Syntax_Syntax.Tm_app
                                                   uu____4019 in
                                               mk1 uu____4018 in
                                             let p2 =
                                               let uu____4060 =
                                                 FStar_Range.union_ranges
                                                   p'.FStar_Syntax_Syntax.p
                                                   p1.FStar_Syntax_Syntax.p in
                                               FStar_Syntax_Syntax.withinfo
                                                 (FStar_Syntax_Syntax.Pat_cons
                                                    (tupn,
                                                      (FStar_List.append pats
                                                         [(p1, false)])))
                                                 FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
                                                 uu____4060 in
                                             Some (sc1, p2)
                                         | uu____4084 ->
                                             failwith "Impossible") in
                                  ((x, aq), sc_pat_opt1) in
                            (match uu____3813 with
                             | (b1,sc_pat_opt1) ->
                                 aux env2 (b1 :: bs) sc_pat_opt1 rest)) in
                 aux env [] None binders2)
        | FStar_Parser_AST.App
            (uu____4125,uu____4126,FStar_Parser_AST.UnivApp ) ->
            let rec aux universes e =
              let uu____4138 =
                let uu____4139 = unparen e in uu____4139.FStar_Parser_AST.tm in
              match uu____4138 with
              | FStar_Parser_AST.App (e1,t,FStar_Parser_AST.UnivApp ) ->
                  let univ_arg = desugar_universe t in
                  aux (univ_arg :: universes) e1
              | uu____4145 ->
                  let head1 = desugar_term env e in
                  mk1 (FStar_Syntax_Syntax.Tm_uinst (head1, universes)) in
            aux [] top
        | FStar_Parser_AST.App uu____4148 ->
            let rec aux args e =
              let uu____4169 =
                let uu____4170 = unparen e in uu____4170.FStar_Parser_AST.tm in
              match uu____4169 with
              | FStar_Parser_AST.App (e1,t,imp) when
                  imp <> FStar_Parser_AST.UnivApp ->
                  let arg =
                    let uu____4180 = desugar_term env t in
                    FStar_All.pipe_left (arg_withimp_e imp) uu____4180 in
                  aux (arg :: args) e1
              | uu____4187 ->
                  let head1 = desugar_term env e in
                  mk1 (FStar_Syntax_Syntax.Tm_app (head1, args)) in
            aux [] top
        | FStar_Parser_AST.Bind (x,t1,t2) ->
            let xpat =
              FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (x, None))
                x.FStar_Ident.idRange in
            let k =
              FStar_Parser_AST.mk_term (FStar_Parser_AST.Abs ([xpat], t2))
                t2.FStar_Parser_AST.range t2.FStar_Parser_AST.level in
            let bind1 =
              let uu____4204 =
                let uu____4205 =
                  FStar_Ident.lid_of_path ["bind"] x.FStar_Ident.idRange in
                FStar_Parser_AST.Var uu____4205 in
              FStar_Parser_AST.mk_term uu____4204 x.FStar_Ident.idRange
                FStar_Parser_AST.Expr in
            let uu____4206 =
              FStar_Parser_AST.mkExplicitApp bind1 [t1; k]
                top.FStar_Parser_AST.range in
            desugar_term env uu____4206
        | FStar_Parser_AST.Seq (t1,t2) ->
            let uu____4209 =
              let uu____4210 =
                let uu____4215 =
                  desugar_term env
                    (FStar_Parser_AST.mk_term
                       (FStar_Parser_AST.Let
                          (FStar_Parser_AST.NoLetQualifier,
                            [((FStar_Parser_AST.mk_pattern
                                 FStar_Parser_AST.PatWild
                                 t1.FStar_Parser_AST.range), t1)], t2))
                       top.FStar_Parser_AST.range FStar_Parser_AST.Expr) in
                (uu____4215,
                  (FStar_Syntax_Syntax.Meta_desugared
                     FStar_Syntax_Syntax.Sequence)) in
              FStar_Syntax_Syntax.Tm_meta uu____4210 in
            mk1 uu____4209
        | FStar_Parser_AST.LetOpen (lid,e) ->
            let env1 = FStar_ToSyntax_Env.push_namespace env lid in
            let uu____4226 =
              let uu____4231 = FStar_ToSyntax_Env.expect_typ env1 in
              if uu____4231 then desugar_typ else desugar_term in
            uu____4226 env1 e
        | FStar_Parser_AST.Let (qual1,(pat,_snd)::_tl,body) ->
            let is_rec = qual1 = FStar_Parser_AST.Rec in
            let ds_let_rec_or_app uu____4256 =
              let bindings = (pat, _snd) :: _tl in
              let funs =
                FStar_All.pipe_right bindings
                  (FStar_List.map
                     (fun uu____4298  ->
                        match uu____4298 with
                        | (p,def) ->
                            let uu____4312 = is_app_pattern p in
                            if uu____4312
                            then
                              let uu____4322 =
                                destruct_app_pattern env top_level p in
                              (uu____4322, def)
                            else
                              (match FStar_Parser_AST.un_function p def with
                               | Some (p1,def1) ->
                                   let uu____4351 =
                                     destruct_app_pattern env top_level p1 in
                                   (uu____4351, def1)
                               | uu____4366 ->
                                   (match p.FStar_Parser_AST.pat with
                                    | FStar_Parser_AST.PatAscribed
                                        ({
                                           FStar_Parser_AST.pat =
                                             FStar_Parser_AST.PatVar
                                             (id,uu____4380);
                                           FStar_Parser_AST.prange =
                                             uu____4381;_},t)
                                        ->
                                        if top_level
                                        then
                                          let uu____4394 =
                                            let uu____4402 =
                                              let uu____4405 =
                                                FStar_ToSyntax_Env.qualify
                                                  env id in
                                              FStar_Util.Inr uu____4405 in
                                            (uu____4402, [], (Some t)) in
                                          (uu____4394, def)
                                        else
                                          (((FStar_Util.Inl id), [],
                                             (Some t)), def)
                                    | FStar_Parser_AST.PatVar (id,uu____4430)
                                        ->
                                        if top_level
                                        then
                                          let uu____4442 =
                                            let uu____4450 =
                                              let uu____4453 =
                                                FStar_ToSyntax_Env.qualify
                                                  env id in
                                              FStar_Util.Inr uu____4453 in
                                            (uu____4450, [], None) in
                                          (uu____4442, def)
                                        else
                                          (((FStar_Util.Inl id), [], None),
                                            def)
                                    | uu____4477 ->
                                        raise
                                          (FStar_Errors.Error
                                             ("Unexpected let binding",
                                               (p.FStar_Parser_AST.prange))))))) in
              let uu____4487 =
                FStar_List.fold_left
                  (fun uu____4511  ->
                     fun uu____4512  ->
                       match (uu____4511, uu____4512) with
                       | ((env1,fnames,rec_bindings),((f,uu____4556,uu____4557),uu____4558))
                           ->
                           let uu____4598 =
                             match f with
                             | FStar_Util.Inl x ->
                                 let uu____4612 =
                                   FStar_ToSyntax_Env.push_bv env1 x in
                                 (match uu____4612 with
                                  | (env2,xx) ->
                                      let uu____4623 =
                                        let uu____4625 =
                                          FStar_Syntax_Syntax.mk_binder xx in
                                        uu____4625 :: rec_bindings in
                                      (env2, (FStar_Util.Inl xx), uu____4623))
                             | FStar_Util.Inr l ->
                                 let uu____4630 =
                                   FStar_ToSyntax_Env.push_top_level_rec_binding
                                     env1 l.FStar_Ident.ident
                                     FStar_Syntax_Syntax.Delta_equational in
                                 (uu____4630, (FStar_Util.Inr l),
                                   rec_bindings) in
                           (match uu____4598 with
                            | (env2,lbname,rec_bindings1) ->
                                (env2, (lbname :: fnames), rec_bindings1)))
                  (env, [], []) funs in
              match uu____4487 with
              | (env',fnames,rec_bindings) ->
                  let fnames1 = FStar_List.rev fnames in
                  let rec_bindings1 = FStar_List.rev rec_bindings in
                  let desugar_one_def env1 lbname uu____4703 =
                    match uu____4703 with
                    | ((uu____4715,args,result_t),def) ->
                        let args1 =
                          FStar_All.pipe_right args
                            (FStar_List.map replace_unit_pattern) in
                        let def1 =
                          match result_t with
                          | None  -> def
                          | Some t ->
                              let t1 =
                                let uu____4741 = is_comp_type env1 t in
                                if uu____4741
                                then
                                  ((let uu____4743 =
                                      FStar_All.pipe_right args1
                                        (FStar_List.tryFind
                                           (fun x  ->
                                              let uu____4748 =
                                                is_var_pattern x in
                                              Prims.op_Negation uu____4748)) in
                                    match uu____4743 with
                                    | None  -> ()
                                    | Some p ->
                                        raise
                                          (FStar_Errors.Error
                                             ("Computation type annotations are only permitted on let-bindings without inlined patterns; replace this pattern with a variable",
                                               (p.FStar_Parser_AST.prange))));
                                   t)
                                else
                                  (let uu____4751 =
                                     ((FStar_Options.ml_ish ()) &&
                                        (let uu____4752 =
                                           FStar_ToSyntax_Env.try_lookup_effect_name
                                             env1
                                             FStar_Syntax_Const.effect_ML_lid in
                                         FStar_Option.isSome uu____4752))
                                       &&
                                       ((Prims.op_Negation is_rec) ||
                                          ((FStar_List.length args1) <>
                                             (Prims.parse_int "0"))) in
                                   if uu____4751
                                   then FStar_Parser_AST.ml_comp t
                                   else FStar_Parser_AST.tot_comp t) in
                              let uu____4757 =
                                FStar_Range.union_ranges
                                  t1.FStar_Parser_AST.range
                                  def.FStar_Parser_AST.range in
                              FStar_Parser_AST.mk_term
                                (FStar_Parser_AST.Ascribed (def, t1, None))
                                uu____4757 FStar_Parser_AST.Expr in
                        let def2 =
                          match args1 with
                          | [] -> def1
                          | uu____4760 ->
                              FStar_Parser_AST.mk_term
                                (FStar_Parser_AST.un_curry_abs args1 def1)
                                top.FStar_Parser_AST.range
                                top.FStar_Parser_AST.level in
                        let body1 = desugar_term env1 def2 in
                        let lbname1 =
                          match lbname with
                          | FStar_Util.Inl x -> FStar_Util.Inl x
                          | FStar_Util.Inr l ->
                              let uu____4770 =
                                let uu____4771 =
                                  FStar_Syntax_Util.incr_delta_qualifier
                                    body1 in
                                FStar_Syntax_Syntax.lid_as_fv l uu____4771
                                  None in
                              FStar_Util.Inr uu____4770 in
                        let body2 =
                          if is_rec
                          then FStar_Syntax_Subst.close rec_bindings1 body1
                          else body1 in
                        mk_lb (lbname1, FStar_Syntax_Syntax.tun, body2) in
                  let lbs =
                    FStar_List.map2
                      (desugar_one_def (if is_rec then env' else env))
                      fnames1 funs in
                  let body1 = desugar_term env' body in
                  let uu____4791 =
                    let uu____4792 =
                      let uu____4800 =
                        FStar_Syntax_Subst.close rec_bindings1 body1 in
                      ((is_rec, lbs), uu____4800) in
                    FStar_Syntax_Syntax.Tm_let uu____4792 in
                  FStar_All.pipe_left mk1 uu____4791 in
            let ds_non_rec pat1 t1 t2 =
              let t11 = desugar_term env t1 in
              let is_mutable = qual1 = FStar_Parser_AST.Mutable in
              let t12 = if is_mutable then mk_ref_alloc t11 else t11 in
              let uu____4827 =
                desugar_binding_pat_maybe_top top_level env pat1 is_mutable in
              match uu____4827 with
              | (env1,binder,pat2) ->
                  let tm =
                    match binder with
                    | LetBinder (l,t) ->
                        let body1 = desugar_term env1 t2 in
                        let fv =
                          let uu____4848 =
                            FStar_Syntax_Util.incr_delta_qualifier t12 in
                          FStar_Syntax_Syntax.lid_as_fv l uu____4848 None in
                        FStar_All.pipe_left mk1
                          (FStar_Syntax_Syntax.Tm_let
                             ((false,
                                [{
                                   FStar_Syntax_Syntax.lbname =
                                     (FStar_Util.Inr fv);
                                   FStar_Syntax_Syntax.lbunivs = [];
                                   FStar_Syntax_Syntax.lbtyp = t;
                                   FStar_Syntax_Syntax.lbeff =
                                     FStar_Syntax_Const.effect_ALL_lid;
                                   FStar_Syntax_Syntax.lbdef = t12
                                 }]), body1))
                    | LocalBinder (x,uu____4856) ->
                        let body1 = desugar_term env1 t2 in
                        let body2 =
                          match pat2 with
                          | None  -> body1
                          | Some
                              {
                                FStar_Syntax_Syntax.v =
                                  FStar_Syntax_Syntax.Pat_wild uu____4859;
                                FStar_Syntax_Syntax.ty = uu____4860;
                                FStar_Syntax_Syntax.p = uu____4861;_}
                              -> body1
                          | Some pat3 ->
                              let uu____4865 =
                                let uu____4868 =
                                  let uu____4869 =
                                    let uu____4885 =
                                      FStar_Syntax_Syntax.bv_to_name x in
                                    let uu____4886 =
                                      desugar_disjunctive_pattern pat3 None
                                        body1 in
                                    (uu____4885, uu____4886) in
                                  FStar_Syntax_Syntax.Tm_match uu____4869 in
                                FStar_Syntax_Syntax.mk uu____4868 in
                              uu____4865 None body1.FStar_Syntax_Syntax.pos in
                        let uu____4899 =
                          let uu____4900 =
                            let uu____4908 =
                              let uu____4909 =
                                let uu____4910 =
                                  FStar_Syntax_Syntax.mk_binder x in
                                [uu____4910] in
                              FStar_Syntax_Subst.close uu____4909 body2 in
                            ((false,
                               [mk_lb
                                  ((FStar_Util.Inl x),
                                    (x.FStar_Syntax_Syntax.sort), t12)]),
                              uu____4908) in
                          FStar_Syntax_Syntax.Tm_let uu____4900 in
                        FStar_All.pipe_left mk1 uu____4899 in
                  if is_mutable
                  then
                    FStar_All.pipe_left mk1
                      (FStar_Syntax_Syntax.Tm_meta
                         (tm,
                           (FStar_Syntax_Syntax.Meta_desugared
                              FStar_Syntax_Syntax.Mutable_alloc)))
                  else tm in
            let uu____4930 = is_rec || (is_app_pattern pat) in
            if uu____4930
            then ds_let_rec_or_app ()
            else ds_non_rec pat _snd body
        | FStar_Parser_AST.If (t1,t2,t3) ->
            let x =
              FStar_Syntax_Syntax.new_bv (Some (t3.FStar_Parser_AST.range))
                FStar_Syntax_Syntax.tun in
            let t_bool1 =
              let uu____4939 =
                let uu____4940 =
                  FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.bool_lid
                    FStar_Syntax_Syntax.Delta_constant None in
                FStar_Syntax_Syntax.Tm_fvar uu____4940 in
              mk1 uu____4939 in
            let uu____4941 =
              let uu____4942 =
                let uu____4958 =
                  let uu____4961 = desugar_term env t1 in
                  FStar_Syntax_Util.ascribe uu____4961
                    ((FStar_Util.Inl t_bool1), None) in
                let uu____4979 =
                  let uu____4989 =
                    let uu____4998 =
                      FStar_Syntax_Syntax.withinfo
                        (FStar_Syntax_Syntax.Pat_constant
                           (FStar_Const.Const_bool true))
                        FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
                        t2.FStar_Parser_AST.range in
                    let uu____5001 = desugar_term env t2 in
                    (uu____4998, None, uu____5001) in
                  let uu____5009 =
                    let uu____5019 =
                      let uu____5028 =
                        FStar_Syntax_Syntax.withinfo
                          (FStar_Syntax_Syntax.Pat_wild x)
                          FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
                          t3.FStar_Parser_AST.range in
                      let uu____5031 = desugar_term env t3 in
                      (uu____5028, None, uu____5031) in
                    [uu____5019] in
                  uu____4989 :: uu____5009 in
                (uu____4958, uu____4979) in
              FStar_Syntax_Syntax.Tm_match uu____4942 in
            mk1 uu____4941
        | FStar_Parser_AST.TryWith (e,branches) ->
            let r = top.FStar_Parser_AST.range in
            let handler = FStar_Parser_AST.mk_function branches r r in
            let body =
              FStar_Parser_AST.mk_function
                [((FStar_Parser_AST.mk_pattern
                     (FStar_Parser_AST.PatConst FStar_Const.Const_unit) r),
                   None, e)] r r in
            let a1 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.App
                   ((FStar_Parser_AST.mk_term
                       (FStar_Parser_AST.Var FStar_Syntax_Const.try_with_lid)
                       r top.FStar_Parser_AST.level), body,
                     FStar_Parser_AST.Nothing)) r top.FStar_Parser_AST.level in
            let a2 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.App (a1, handler, FStar_Parser_AST.Nothing))
                r top.FStar_Parser_AST.level in
            desugar_term env a2
        | FStar_Parser_AST.Match (e,branches) ->
            let desugar_branch uu____5120 =
              match uu____5120 with
              | (pat,wopt,b) ->
                  let uu____5131 = desugar_match_pat env pat in
                  (match uu____5131 with
                   | (env1,pat1) ->
                       let wopt1 =
                         match wopt with
                         | None  -> None
                         | Some e1 ->
                             let uu____5141 = desugar_term env1 e1 in
                             Some uu____5141 in
                       let b1 = desugar_term env1 b in
                       desugar_disjunctive_pattern pat1 wopt1 b1) in
            let uu____5143 =
              let uu____5144 =
                let uu____5160 = desugar_term env e in
                let uu____5161 = FStar_List.collect desugar_branch branches in
                (uu____5160, uu____5161) in
              FStar_Syntax_Syntax.Tm_match uu____5144 in
            FStar_All.pipe_left mk1 uu____5143
        | FStar_Parser_AST.Ascribed (e,t,tac_opt) ->
            let annot =
              let uu____5180 = is_comp_type env t in
              if uu____5180
              then
                let uu____5185 = desugar_comp t.FStar_Parser_AST.range env t in
                FStar_Util.Inr uu____5185
              else
                (let uu____5191 = desugar_term env t in
                 FStar_Util.Inl uu____5191) in
            let tac_opt1 = FStar_Util.map_opt tac_opt (desugar_term env) in
            let uu____5196 =
              let uu____5197 =
                let uu____5215 = desugar_term env e in
                (uu____5215, (annot, tac_opt1), None) in
              FStar_Syntax_Syntax.Tm_ascribed uu____5197 in
            FStar_All.pipe_left mk1 uu____5196
        | FStar_Parser_AST.Record (uu____5231,[]) ->
            raise
              (FStar_Errors.Error
                 ("Unexpected empty record", (top.FStar_Parser_AST.range)))
        | FStar_Parser_AST.Record (eopt,fields) ->
            let record = check_fields env fields top.FStar_Parser_AST.range in
            let user_ns =
              let uu____5252 = FStar_List.hd fields in
              match uu____5252 with | (f,uu____5259) -> f.FStar_Ident.ns in
            let get_field xopt f =
              let found =
                FStar_All.pipe_right fields
                  (FStar_Util.find_opt
                     (fun uu____5283  ->
                        match uu____5283 with
                        | (g,uu____5287) ->
                            f.FStar_Ident.idText =
                              (g.FStar_Ident.ident).FStar_Ident.idText)) in
              let fn = FStar_Ident.lid_of_ids (FStar_List.append user_ns [f]) in
              match found with
              | Some (uu____5291,e) -> (fn, e)
              | None  ->
                  (match xopt with
                   | None  ->
                       let uu____5299 =
                         let uu____5300 =
                           let uu____5303 =
                             FStar_Util.format2
                               "Field %s of record type %s is missing"
                               f.FStar_Ident.idText
                               (record.FStar_ToSyntax_Env.typename).FStar_Ident.str in
                           (uu____5303, (top.FStar_Parser_AST.range)) in
                         FStar_Errors.Error uu____5300 in
                       raise uu____5299
                   | Some x ->
                       (fn,
                         (FStar_Parser_AST.mk_term
                            (FStar_Parser_AST.Project (x, fn))
                            x.FStar_Parser_AST.range x.FStar_Parser_AST.level))) in
            let user_constrname =
              FStar_Ident.lid_of_ids
                (FStar_List.append user_ns
                   [record.FStar_ToSyntax_Env.constrname]) in
            let recterm =
              match eopt with
              | None  ->
                  let uu____5309 =
                    let uu____5315 =
                      FStar_All.pipe_right record.FStar_ToSyntax_Env.fields
                        (FStar_List.map
                           (fun uu____5329  ->
                              match uu____5329 with
                              | (f,uu____5335) ->
                                  let uu____5336 =
                                    let uu____5337 = get_field None f in
                                    FStar_All.pipe_left FStar_Pervasives.snd
                                      uu____5337 in
                                  (uu____5336, FStar_Parser_AST.Nothing))) in
                    (user_constrname, uu____5315) in
                  FStar_Parser_AST.Construct uu____5309
              | Some e ->
                  let x = FStar_Ident.gen e.FStar_Parser_AST.range in
                  let xterm =
                    let uu____5348 =
                      let uu____5349 = FStar_Ident.lid_of_ids [x] in
                      FStar_Parser_AST.Var uu____5349 in
                    FStar_Parser_AST.mk_term uu____5348 x.FStar_Ident.idRange
                      FStar_Parser_AST.Expr in
                  let record1 =
                    let uu____5351 =
                      let uu____5358 =
                        FStar_All.pipe_right record.FStar_ToSyntax_Env.fields
                          (FStar_List.map
                             (fun uu____5372  ->
                                match uu____5372 with
                                | (f,uu____5378) -> get_field (Some xterm) f)) in
                      (None, uu____5358) in
                    FStar_Parser_AST.Record uu____5351 in
                  FStar_Parser_AST.Let
                    (FStar_Parser_AST.NoLetQualifier,
                      [((FStar_Parser_AST.mk_pattern
                           (FStar_Parser_AST.PatVar (x, None))
                           x.FStar_Ident.idRange), e)],
                      (FStar_Parser_AST.mk_term record1
                         top.FStar_Parser_AST.range
                         top.FStar_Parser_AST.level)) in
            let recterm1 =
              FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range
                top.FStar_Parser_AST.level in
            let e = desugar_term env recterm1 in
            (match e.FStar_Syntax_Syntax.n with
             | FStar_Syntax_Syntax.Tm_meta
                 ({
                    FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_app
                      ({
                         FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar
                           fv;
                         FStar_Syntax_Syntax.tk = uu____5394;
                         FStar_Syntax_Syntax.pos = uu____5395;
                         FStar_Syntax_Syntax.vars = uu____5396;_},args);
                    FStar_Syntax_Syntax.tk = uu____5398;
                    FStar_Syntax_Syntax.pos = uu____5399;
                    FStar_Syntax_Syntax.vars = uu____5400;_},FStar_Syntax_Syntax.Meta_desugared
                  (FStar_Syntax_Syntax.Data_app ))
                 ->
                 let e1 =
                   let uu____5422 =
                     let uu____5423 =
                       let uu____5433 =
                         let uu____5434 =
                           let uu____5436 =
                             let uu____5437 =
                               let uu____5441 =
                                 FStar_All.pipe_right
                                   record.FStar_ToSyntax_Env.fields
                                   (FStar_List.map FStar_Pervasives.fst) in
                               ((record.FStar_ToSyntax_Env.typename),
                                 uu____5441) in
                             FStar_Syntax_Syntax.Record_ctor uu____5437 in
                           Some uu____5436 in
                         FStar_Syntax_Syntax.fvar
                           (FStar_Ident.set_lid_range
                              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                              e.FStar_Syntax_Syntax.pos)
                           FStar_Syntax_Syntax.Delta_constant uu____5434 in
                       (uu____5433, args) in
                     FStar_Syntax_Syntax.Tm_app uu____5423 in
                   FStar_All.pipe_left mk1 uu____5422 in
                 FStar_All.pipe_left mk1
                   (FStar_Syntax_Syntax.Tm_meta
                      (e1,
                        (FStar_Syntax_Syntax.Meta_desugared
                           FStar_Syntax_Syntax.Data_app)))
             | uu____5465 -> e)
        | FStar_Parser_AST.Project (e,f) ->
            (FStar_ToSyntax_Env.fail_if_qualified_by_curmodule env f;
             (let uu____5469 =
                FStar_ToSyntax_Env.fail_or env
                  (FStar_ToSyntax_Env.try_lookup_dc_by_field_name env) f in
              match uu____5469 with
              | (constrname,is_rec) ->
                  let e1 = desugar_term env e in
                  let projname =
                    FStar_Syntax_Util.mk_field_projector_name_from_ident
                      constrname f.FStar_Ident.ident in
                  let qual1 =
                    if is_rec
                    then
                      Some
                        (FStar_Syntax_Syntax.Record_projector
                           (constrname, (f.FStar_Ident.ident)))
                    else None in
                  let uu____5482 =
                    let uu____5483 =
                      let uu____5493 =
                        FStar_Syntax_Syntax.fvar
                          (FStar_Ident.set_lid_range projname
                             (FStar_Ident.range_of_lid f))
                          FStar_Syntax_Syntax.Delta_equational qual1 in
                      let uu____5494 =
                        let uu____5496 = FStar_Syntax_Syntax.as_arg e1 in
                        [uu____5496] in
                      (uu____5493, uu____5494) in
                    FStar_Syntax_Syntax.Tm_app uu____5483 in
                  FStar_All.pipe_left mk1 uu____5482))
        | FStar_Parser_AST.NamedTyp (uu____5500,e) -> desugar_term env e
        | FStar_Parser_AST.Paren e -> desugar_term env e
        | uu____5503 when
            top.FStar_Parser_AST.level = FStar_Parser_AST.Formula ->
            desugar_formula env top
        | uu____5504 ->
            FStar_Parser_AST.error "Unexpected term" top
              top.FStar_Parser_AST.range
        | FStar_Parser_AST.Let (uu____5505,uu____5506,uu____5507) ->
            failwith "Not implemented yet"
        | FStar_Parser_AST.QForall (uu____5514,uu____5515,uu____5516) ->
            failwith "Not implemented yet"
        | FStar_Parser_AST.QExists (uu____5523,uu____5524,uu____5525) ->
            failwith "Not implemented yet"
and desugar_args:
  FStar_ToSyntax_Env.env ->
    (FStar_Parser_AST.term* FStar_Parser_AST.imp) Prims.list ->
      (FStar_Syntax_Syntax.term* FStar_Syntax_Syntax.arg_qualifier option)
        Prims.list
  =
  fun env  ->
    fun args  ->
      FStar_All.pipe_right args
        (FStar_List.map
           (fun uu____5549  ->
              match uu____5549 with
              | (a,imp) ->
                  let uu____5557 = desugar_term env a in
                  arg_withimp_e imp uu____5557))
and desugar_comp:
  FStar_Range.range ->
    FStar_ToSyntax_Env.env ->
      FStar_Parser_AST.term ->
        (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax
  =
  fun r  ->
    fun env  ->
      fun t  ->
        let fail msg = raise (FStar_Errors.Error (msg, r)) in
        let is_requires uu____5574 =
          match uu____5574 with
          | (t1,uu____5578) ->
              let uu____5579 =
                let uu____5580 = unparen t1 in uu____5580.FStar_Parser_AST.tm in
              (match uu____5579 with
               | FStar_Parser_AST.Requires uu____5581 -> true
               | uu____5585 -> false) in
        let is_ensures uu____5591 =
          match uu____5591 with
          | (t1,uu____5595) ->
              let uu____5596 =
                let uu____5597 = unparen t1 in uu____5597.FStar_Parser_AST.tm in
              (match uu____5596 with
               | FStar_Parser_AST.Ensures uu____5598 -> true
               | uu____5602 -> false) in
        let is_app head1 uu____5611 =
          match uu____5611 with
          | (t1,uu____5615) ->
              let uu____5616 =
                let uu____5617 = unparen t1 in uu____5617.FStar_Parser_AST.tm in
              (match uu____5616 with
               | FStar_Parser_AST.App
                   ({ FStar_Parser_AST.tm = FStar_Parser_AST.Var d;
                      FStar_Parser_AST.range = uu____5619;
                      FStar_Parser_AST.level = uu____5620;_},uu____5621,uu____5622)
                   -> (d.FStar_Ident.ident).FStar_Ident.idText = head1
               | uu____5623 -> false) in
        let is_smt_pat uu____5629 =
          match uu____5629 with
          | (t1,uu____5633) ->
              let uu____5634 =
                let uu____5635 = unparen t1 in uu____5635.FStar_Parser_AST.tm in
              (match uu____5634 with
               | FStar_Parser_AST.Construct
                   (cons1,({
                             FStar_Parser_AST.tm = FStar_Parser_AST.Construct
                               (smtpat,uu____5638);
                             FStar_Parser_AST.range = uu____5639;
                             FStar_Parser_AST.level = uu____5640;_},uu____5641)::uu____5642::[])
                   ->
                   (FStar_Ident.lid_equals cons1 FStar_Syntax_Const.cons_lid)
                     &&
                     (FStar_Util.for_some
                        (fun s  -> smtpat.FStar_Ident.str = s)
                        ["SMTPat"; "SMTPatT"; "SMTPatOr"])
               | uu____5661 -> false) in
        let is_decreases = is_app "decreases" in
        let pre_process_comp_typ t1 =
          let uu____5679 = head_and_args t1 in
          match uu____5679 with
          | (head1,args) ->
              (match head1.FStar_Parser_AST.tm with
               | FStar_Parser_AST.Name lemma when
                   (lemma.FStar_Ident.ident).FStar_Ident.idText = "Lemma" ->
                   let unit_tm =
                     ((FStar_Parser_AST.mk_term
                         (FStar_Parser_AST.Name FStar_Syntax_Const.unit_lid)
                         t1.FStar_Parser_AST.range
                         FStar_Parser_AST.Type_level),
                       FStar_Parser_AST.Nothing) in
                   let nil_pat =
                     ((FStar_Parser_AST.mk_term
                         (FStar_Parser_AST.Name FStar_Syntax_Const.nil_lid)
                         t1.FStar_Parser_AST.range FStar_Parser_AST.Expr),
                       FStar_Parser_AST.Nothing) in
                   let req_true =
                     let req =
                       FStar_Parser_AST.Requires
                         ((FStar_Parser_AST.mk_term
                             (FStar_Parser_AST.Name
                                FStar_Syntax_Const.true_lid)
                             t1.FStar_Parser_AST.range
                             FStar_Parser_AST.Formula), None) in
                     ((FStar_Parser_AST.mk_term req t1.FStar_Parser_AST.range
                         FStar_Parser_AST.Type_level),
                       FStar_Parser_AST.Nothing) in
                   let args1 =
                     match args with
                     | [] ->
                         raise
                           (FStar_Errors.Error
                              ("Not enough arguments to 'Lemma'",
                                (t1.FStar_Parser_AST.range)))
                     | ens::[] -> [unit_tm; req_true; ens; nil_pat]
                     | ens::smtpat::[] when is_smt_pat smtpat ->
                         [unit_tm; req_true; ens; smtpat]
                     | req::ens::[] when
                         (is_requires req) && (is_ensures ens) ->
                         [unit_tm; req; ens; nil_pat]
                     | ens::dec::[] when
                         (is_ensures ens) && (is_decreases dec) ->
                         [unit_tm; req_true; ens; nil_pat; dec]
                     | ens::dec::smtpat::[] when
                         ((is_ensures ens) && (is_decreases dec)) &&
                           (is_smt_pat smtpat)
                         -> [unit_tm; req_true; ens; smtpat; dec]
                     | req::ens::dec::[] when
                         ((is_requires req) && (is_ensures ens)) &&
                           (is_decreases dec)
                         -> [unit_tm; req; ens; nil_pat; dec]
                     | more -> unit_tm :: more in
                   let head_and_attributes =
                     FStar_ToSyntax_Env.fail_or env
                       (FStar_ToSyntax_Env.try_lookup_effect_name_and_attributes
                          env) lemma in
                   (head_and_attributes, args1)
               | FStar_Parser_AST.Name l when
                   FStar_ToSyntax_Env.is_effect_name env l ->
                   let uu____5896 =
                     FStar_ToSyntax_Env.fail_or env
                       (FStar_ToSyntax_Env.try_lookup_effect_name_and_attributes
                          env) l in
                   (uu____5896, args)
               | FStar_Parser_AST.Name l when
                   (let uu____5910 = FStar_ToSyntax_Env.current_module env in
                    FStar_Ident.lid_equals uu____5910
                      FStar_Syntax_Const.prims_lid)
                     && ((l.FStar_Ident.ident).FStar_Ident.idText = "Tot")
                   ->
                   (((FStar_Ident.set_lid_range
                        FStar_Parser_Const.effect_Tot_lid
                        head1.FStar_Parser_AST.range), []), args)
               | FStar_Parser_AST.Name l when
                   (let uu____5919 = FStar_ToSyntax_Env.current_module env in
                    FStar_Ident.lid_equals uu____5919
                      FStar_Syntax_Const.prims_lid)
                     && ((l.FStar_Ident.ident).FStar_Ident.idText = "GTot")
                   ->
                   (((FStar_Ident.set_lid_range
                        FStar_Parser_Const.effect_GTot_lid
                        head1.FStar_Parser_AST.range), []), args)
               | FStar_Parser_AST.Name l when
                   (((l.FStar_Ident.ident).FStar_Ident.idText = "Type") ||
                      ((l.FStar_Ident.ident).FStar_Ident.idText = "Type0"))
                     || ((l.FStar_Ident.ident).FStar_Ident.idText = "Effect")
                   ->
                   (((FStar_Ident.set_lid_range
                        FStar_Parser_Const.effect_Tot_lid
                        head1.FStar_Parser_AST.range), []),
                     [(t1, FStar_Parser_AST.Nothing)])
               | uu____5939 ->
                   let default_effect =
                     let uu____5941 = FStar_Options.ml_ish () in
                     if uu____5941
                     then FStar_Parser_Const.effect_ML_lid
                     else
                       ((let uu____5944 =
                           FStar_Options.warn_default_effects () in
                         if uu____5944
                         then
                           FStar_Errors.warn head1.FStar_Parser_AST.range
                             "Using default effect Tot"
                         else ());
                        FStar_Parser_Const.effect_Tot_lid) in
                   (((FStar_Ident.set_lid_range default_effect
                        head1.FStar_Parser_AST.range), []),
                     [(t1, FStar_Parser_AST.Nothing)])) in
        let uu____5957 = pre_process_comp_typ t in
        match uu____5957 with
        | ((eff,cattributes),args) ->
            (if (FStar_List.length args) = (Prims.parse_int "0")
             then
               (let uu____5987 =
                  let uu____5988 = FStar_Syntax_Print.lid_to_string eff in
                  FStar_Util.format1 "Not enough args to effect %s"
                    uu____5988 in
                fail uu____5987)
             else ();
             (let is_universe uu____5995 =
                match uu____5995 with
                | (uu____5998,imp) -> imp = FStar_Parser_AST.UnivApp in
              let uu____6000 = FStar_Util.take is_universe args in
              match uu____6000 with
              | (universes,args1) ->
                  let universes1 =
                    FStar_List.map
                      (fun uu____6031  ->
                         match uu____6031 with
                         | (u,imp) -> desugar_universe u) universes in
                  let uu____6036 =
                    let uu____6044 = FStar_List.hd args1 in
                    let uu____6049 = FStar_List.tl args1 in
                    (uu____6044, uu____6049) in
                  (match uu____6036 with
                   | (result_arg,rest) ->
                       let result_typ = desugar_typ env (fst result_arg) in
                       let rest1 = desugar_args env rest in
                       let uu____6080 =
                         let is_decrease uu____6103 =
                           match uu____6103 with
                           | (t1,uu____6110) ->
                               (match t1.FStar_Syntax_Syntax.n with
                                | FStar_Syntax_Syntax.Tm_app
                                    ({
                                       FStar_Syntax_Syntax.n =
                                         FStar_Syntax_Syntax.Tm_fvar fv;
                                       FStar_Syntax_Syntax.tk = uu____6118;
                                       FStar_Syntax_Syntax.pos = uu____6119;
                                       FStar_Syntax_Syntax.vars = uu____6120;_},uu____6121::[])
                                    ->
                                    FStar_Syntax_Syntax.fv_eq_lid fv
                                      FStar_Syntax_Const.decreases_lid
                                | uu____6143 -> false) in
                         FStar_All.pipe_right rest1
                           (FStar_List.partition is_decrease) in
                       (match uu____6080 with
                        | (dec,rest2) ->
                            let decreases_clause =
                              FStar_All.pipe_right dec
                                (FStar_List.map
                                   (fun uu____6209  ->
                                      match uu____6209 with
                                      | (t1,uu____6216) ->
                                          (match t1.FStar_Syntax_Syntax.n
                                           with
                                           | FStar_Syntax_Syntax.Tm_app
                                               (uu____6223,(arg,uu____6225)::[])
                                               ->
                                               FStar_Syntax_Syntax.DECREASES
                                                 arg
                                           | uu____6247 -> failwith "impos"))) in
                            let no_additional_args =
                              let is_empty l =
                                match l with
                                | [] -> true
                                | uu____6259 -> false in
                              (((is_empty decreases_clause) &&
                                  (is_empty rest2))
                                 && (is_empty cattributes))
                                && (is_empty universes1) in
                            if
                              no_additional_args &&
                                (FStar_Ident.lid_equals eff
                                   FStar_Syntax_Const.effect_Tot_lid)
                            then FStar_Syntax_Syntax.mk_Total result_typ
                            else
                              if
                                no_additional_args &&
                                  (FStar_Ident.lid_equals eff
                                     FStar_Syntax_Const.effect_GTot_lid)
                              then FStar_Syntax_Syntax.mk_GTotal result_typ
                              else
                                (let flags =
                                   if
                                     FStar_Ident.lid_equals eff
                                       FStar_Syntax_Const.effect_Lemma_lid
                                   then [FStar_Syntax_Syntax.LEMMA]
                                   else
                                     if
                                       FStar_Ident.lid_equals eff
                                         FStar_Syntax_Const.effect_Tot_lid
                                     then [FStar_Syntax_Syntax.TOTAL]
                                     else
                                       if
                                         FStar_Ident.lid_equals eff
                                           FStar_Syntax_Const.effect_ML_lid
                                       then [FStar_Syntax_Syntax.MLEFFECT]
                                       else
                                         if
                                           FStar_Ident.lid_equals eff
                                             FStar_Syntax_Const.effect_GTot_lid
                                         then
                                           [FStar_Syntax_Syntax.SOMETRIVIAL]
                                         else [] in
                                 let flags1 =
                                   FStar_List.append flags cattributes in
                                 let rest3 =
                                   if
                                     FStar_Ident.lid_equals eff
                                       FStar_Syntax_Const.effect_Lemma_lid
                                   then
                                     match rest2 with
                                     | req::ens::(pat,aq)::[] ->
                                         let pat1 =
                                           match pat.FStar_Syntax_Syntax.n
                                           with
                                           | FStar_Syntax_Syntax.Tm_fvar fv
                                               when
                                               FStar_Syntax_Syntax.fv_eq_lid
                                                 fv
                                                 FStar_Parser_Const.nil_lid
                                               ->
                                               let nil =
                                                 FStar_Syntax_Syntax.mk_Tm_uinst
                                                   pat
                                                   [FStar_Syntax_Syntax.U_succ
                                                      FStar_Syntax_Syntax.U_zero] in
                                               let pattern =
                                                 let uu____6351 =
                                                   FStar_Syntax_Syntax.fvar
                                                     (FStar_Ident.set_lid_range
                                                        FStar_Parser_Const.pattern_lid
                                                        pat.FStar_Syntax_Syntax.pos)
                                                     FStar_Syntax_Syntax.Delta_constant
                                                     None in
                                                 FStar_Syntax_Syntax.mk_Tm_uinst
                                                   uu____6351
                                                   [FStar_Syntax_Syntax.U_zero] in
                                               (FStar_Syntax_Syntax.mk_Tm_app
                                                  nil
                                                  [(pattern,
                                                     (Some
                                                        FStar_Syntax_Syntax.imp_tag))])
                                                 None
                                                 pat.FStar_Syntax_Syntax.pos
                                           | uu____6363 -> pat in
                                         let uu____6364 =
                                           let uu____6371 =
                                             let uu____6378 =
                                               let uu____6384 =
                                                 (FStar_Syntax_Syntax.mk
                                                    (FStar_Syntax_Syntax.Tm_meta
                                                       (pat1,
                                                         (FStar_Syntax_Syntax.Meta_desugared
                                                            FStar_Syntax_Syntax.Meta_smt_pat))))
                                                   None
                                                   pat1.FStar_Syntax_Syntax.pos in
                                               (uu____6384, aq) in
                                             [uu____6378] in
                                           ens :: uu____6371 in
                                         req :: uu____6364
                                     | uu____6420 -> rest2
                                   else rest2 in
                                 FStar_Syntax_Syntax.mk_Comp
                                   {
                                     FStar_Syntax_Syntax.comp_univs =
                                       universes1;
                                     FStar_Syntax_Syntax.effect_name = eff;
                                     FStar_Syntax_Syntax.result_typ =
                                       result_typ;
                                     FStar_Syntax_Syntax.effect_args = rest3;
                                     FStar_Syntax_Syntax.flags =
                                       (FStar_List.append flags1
                                          decreases_clause)
                                   })))))
and desugar_formula:
  env_t -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term =
  fun env  ->
    fun f  ->
      let connective s =
        match s with
        | "/\\" -> Some FStar_Syntax_Const.and_lid
        | "\\/" -> Some FStar_Syntax_Const.or_lid
        | "==>" -> Some FStar_Syntax_Const.imp_lid
        | "<==>" -> Some FStar_Syntax_Const.iff_lid
        | "~" -> Some FStar_Syntax_Const.not_lid
        | uu____6436 -> None in
      let mk1 t = (FStar_Syntax_Syntax.mk t) None f.FStar_Parser_AST.range in
      let pos t = t None f.FStar_Parser_AST.range in
      let setpos t =
        let uu___228_6477 = t in
        {
          FStar_Syntax_Syntax.n = (uu___228_6477.FStar_Syntax_Syntax.n);
          FStar_Syntax_Syntax.tk = (uu___228_6477.FStar_Syntax_Syntax.tk);
          FStar_Syntax_Syntax.pos = (f.FStar_Parser_AST.range);
          FStar_Syntax_Syntax.vars = (uu___228_6477.FStar_Syntax_Syntax.vars)
        } in
      let desugar_quant q b pats body =
        let tk =
          desugar_binder env
            (let uu___229_6507 = b in
             {
               FStar_Parser_AST.b = (uu___229_6507.FStar_Parser_AST.b);
               FStar_Parser_AST.brange =
                 (uu___229_6507.FStar_Parser_AST.brange);
               FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
               FStar_Parser_AST.aqual =
                 (uu___229_6507.FStar_Parser_AST.aqual)
             }) in
        let desugar_pats env1 pats1 =
          FStar_List.map
            (fun es  ->
               FStar_All.pipe_right es
                 (FStar_List.map
                    (fun e  ->
                       let uu____6540 = desugar_term env1 e in
                       FStar_All.pipe_left
                         (arg_withimp_t FStar_Parser_AST.Nothing) uu____6540)))
            pats1 in
        match tk with
        | (Some a,k) ->
            let uu____6549 = FStar_ToSyntax_Env.push_bv env a in
            (match uu____6549 with
             | (env1,a1) ->
                 let a2 =
                   let uu___230_6557 = a1 in
                   {
                     FStar_Syntax_Syntax.ppname =
                       (uu___230_6557.FStar_Syntax_Syntax.ppname);
                     FStar_Syntax_Syntax.index =
                       (uu___230_6557.FStar_Syntax_Syntax.index);
                     FStar_Syntax_Syntax.sort = k
                   } in
                 let pats1 = desugar_pats env1 pats in
                 let body1 = desugar_formula env1 body in
                 let body2 =
                   match pats1 with
                   | [] -> body1
                   | uu____6570 ->
                       mk1
                         (FStar_Syntax_Syntax.Tm_meta
                            (body1, (FStar_Syntax_Syntax.Meta_pattern pats1))) in
                 let body3 =
                   let uu____6579 =
                     let uu____6582 =
                       let uu____6583 = FStar_Syntax_Syntax.mk_binder a2 in
                       [uu____6583] in
                     no_annot_abs uu____6582 body2 in
                   FStar_All.pipe_left setpos uu____6579 in
                 let uu____6588 =
                   let uu____6589 =
                     let uu____6599 =
                       FStar_Syntax_Syntax.fvar
                         (FStar_Ident.set_lid_range q
                            b.FStar_Parser_AST.brange)
                         (FStar_Syntax_Syntax.Delta_defined_at_level
                            (Prims.parse_int "1")) None in
                     let uu____6600 =
                       let uu____6602 = FStar_Syntax_Syntax.as_arg body3 in
                       [uu____6602] in
                     (uu____6599, uu____6600) in
                   FStar_Syntax_Syntax.Tm_app uu____6589 in
                 FStar_All.pipe_left mk1 uu____6588)
        | uu____6606 -> failwith "impossible" in
      let push_quant q binders pats body =
        match binders with
        | b::b'::_rest ->
            let rest = b' :: _rest in
            let body1 =
              let uu____6655 = q (rest, pats, body) in
              let uu____6659 =
                FStar_Range.union_ranges b'.FStar_Parser_AST.brange
                  body.FStar_Parser_AST.range in
              FStar_Parser_AST.mk_term uu____6655 uu____6659
                FStar_Parser_AST.Formula in
            let uu____6660 = q ([b], [], body1) in
            FStar_Parser_AST.mk_term uu____6660 f.FStar_Parser_AST.range
              FStar_Parser_AST.Formula
        | uu____6665 -> failwith "impossible" in
      let uu____6667 =
        let uu____6668 = unparen f in uu____6668.FStar_Parser_AST.tm in
      match uu____6667 with
      | FStar_Parser_AST.Labeled (f1,l,p) ->
          let f2 = desugar_formula env f1 in
          FStar_All.pipe_left mk1
            (FStar_Syntax_Syntax.Tm_meta
               (f2,
                 (FStar_Syntax_Syntax.Meta_labeled
                    (l, (f2.FStar_Syntax_Syntax.pos), p))))
      | FStar_Parser_AST.QForall ([],uu____6675,uu____6676) ->
          failwith "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QExists ([],uu____6682,uu____6683) ->
          failwith "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QForall (_1::_2::_3,pats,body) ->
          let binders = _1 :: _2 :: _3 in
          let uu____6702 =
            push_quant (fun x  -> FStar_Parser_AST.QForall x) binders pats
              body in
          desugar_formula env uu____6702
      | FStar_Parser_AST.QExists (_1::_2::_3,pats,body) ->
          let binders = _1 :: _2 :: _3 in
          let uu____6723 =
            push_quant (fun x  -> FStar_Parser_AST.QExists x) binders pats
              body in
          desugar_formula env uu____6723
      | FStar_Parser_AST.QForall (b::[],pats,body) ->
          desugar_quant FStar_Syntax_Const.forall_lid b pats body
      | FStar_Parser_AST.QExists (b::[],pats,body) ->
          desugar_quant FStar_Syntax_Const.exists_lid b pats body
      | FStar_Parser_AST.Paren f1 -> desugar_formula env f1
      | uu____6748 -> desugar_term env f
and typars_of_binders:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_ToSyntax_Env.env* (FStar_Syntax_Syntax.bv*
        FStar_Syntax_Syntax.arg_qualifier option) Prims.list)
  =
  fun env  ->
    fun bs  ->
      let uu____6752 =
        FStar_List.fold_left
          (fun uu____6765  ->
             fun b  ->
               match uu____6765 with
               | (env1,out) ->
                   let tk =
                     desugar_binder env1
                       (let uu___231_6793 = b in
                        {
                          FStar_Parser_AST.b =
                            (uu___231_6793.FStar_Parser_AST.b);
                          FStar_Parser_AST.brange =
                            (uu___231_6793.FStar_Parser_AST.brange);
                          FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
                          FStar_Parser_AST.aqual =
                            (uu___231_6793.FStar_Parser_AST.aqual)
                        }) in
                   (match tk with
                    | (Some a,k) ->
                        let uu____6803 = FStar_ToSyntax_Env.push_bv env1 a in
                        (match uu____6803 with
                         | (env2,a1) ->
                             let a2 =
                               let uu___232_6815 = a1 in
                               {
                                 FStar_Syntax_Syntax.ppname =
                                   (uu___232_6815.FStar_Syntax_Syntax.ppname);
                                 FStar_Syntax_Syntax.index =
                                   (uu___232_6815.FStar_Syntax_Syntax.index);
                                 FStar_Syntax_Syntax.sort = k
                               } in
                             (env2,
                               ((a2, (trans_aqual b.FStar_Parser_AST.aqual))
                               :: out)))
                    | uu____6824 ->
                        raise
                          (FStar_Errors.Error
                             ("Unexpected binder",
                               (b.FStar_Parser_AST.brange))))) (env, []) bs in
      match uu____6752 with | (env1,tpars) -> (env1, (FStar_List.rev tpars))
and desugar_binder:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.binder ->
      (FStar_Ident.ident option* FStar_Syntax_Syntax.term)
  =
  fun env  ->
    fun b  ->
      match b.FStar_Parser_AST.b with
      | FStar_Parser_AST.TAnnotated (x,t) ->
          let uu____6874 = desugar_typ env t in ((Some x), uu____6874)
      | FStar_Parser_AST.Annotated (x,t) ->
          let uu____6878 = desugar_typ env t in ((Some x), uu____6878)
      | FStar_Parser_AST.TVariable x ->
          let uu____6881 =
            (FStar_Syntax_Syntax.mk
               (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown))
              None x.FStar_Ident.idRange in
          ((Some x), uu____6881)
      | FStar_Parser_AST.NoName t ->
          let uu____6896 = desugar_typ env t in (None, uu____6896)
      | FStar_Parser_AST.Variable x -> ((Some x), FStar_Syntax_Syntax.tun)
let mk_data_discriminators quals env t tps k datas =
  let quals1 =
    FStar_All.pipe_right quals
      (FStar_List.filter
         (fun uu___208_6945  ->
            match uu___208_6945 with
            | FStar_Syntax_Syntax.Abstract  -> true
            | FStar_Syntax_Syntax.Private  -> true
            | uu____6946 -> false)) in
  let quals2 q =
    let uu____6954 =
      (let uu____6955 = FStar_ToSyntax_Env.iface env in
       Prims.op_Negation uu____6955) ||
        (FStar_ToSyntax_Env.admitted_iface env) in
    if uu____6954
    then FStar_List.append (FStar_Syntax_Syntax.Assumption :: q) quals1
    else FStar_List.append q quals1 in
  FStar_All.pipe_right datas
    (FStar_List.map
       (fun d  ->
          let disc_name = FStar_Syntax_Util.mk_discriminator d in
          let uu____6962 =
            quals2
              [FStar_Syntax_Syntax.OnlyName;
              FStar_Syntax_Syntax.Discriminator d] in
          {
            FStar_Syntax_Syntax.sigel =
              (FStar_Syntax_Syntax.Sig_declare_typ
                 (disc_name, [], FStar_Syntax_Syntax.tun));
            FStar_Syntax_Syntax.sigrng = (FStar_Ident.range_of_lid disc_name);
            FStar_Syntax_Syntax.sigquals = uu____6962;
            FStar_Syntax_Syntax.sigmeta = FStar_Syntax_Syntax.default_sigmeta
          }))
let mk_indexed_projector_names:
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_Syntax.fv_qual ->
      FStar_ToSyntax_Env.env ->
        FStar_Ident.lid ->
          FStar_Syntax_Syntax.binder Prims.list ->
            FStar_Syntax_Syntax.sigelt Prims.list
  =
  fun iquals  ->
    fun fvq  ->
      fun env  ->
        fun lid  ->
          fun fields  ->
            let p = FStar_Ident.range_of_lid lid in
            let uu____6986 =
              FStar_All.pipe_right fields
                (FStar_List.mapi
                   (fun i  ->
                      fun uu____6996  ->
                        match uu____6996 with
                        | (x,uu____7001) ->
                            let uu____7002 =
                              FStar_Syntax_Util.mk_field_projector_name lid x
                                i in
                            (match uu____7002 with
                             | (field_name,uu____7007) ->
                                 let only_decl =
                                   ((let uu____7009 =
                                       FStar_ToSyntax_Env.current_module env in
                                     FStar_Ident.lid_equals
                                       FStar_Syntax_Const.prims_lid
                                       uu____7009)
                                      ||
                                      (fvq <> FStar_Syntax_Syntax.Data_ctor))
                                     ||
                                     (let uu____7010 =
                                        let uu____7011 =
                                          FStar_ToSyntax_Env.current_module
                                            env in
                                        uu____7011.FStar_Ident.str in
                                      FStar_Options.dont_gen_projectors
                                        uu____7010) in
                                 let no_decl =
                                   FStar_Syntax_Syntax.is_type
                                     x.FStar_Syntax_Syntax.sort in
                                 let quals q =
                                   if only_decl
                                   then
                                     let uu____7021 =
                                       FStar_List.filter
                                         (fun uu___209_7023  ->
                                            match uu___209_7023 with
                                            | FStar_Syntax_Syntax.Abstract 
                                                -> false
                                            | uu____7024 -> true) q in
                                     FStar_Syntax_Syntax.Assumption ::
                                       uu____7021
                                   else q in
                                 let quals1 =
                                   let iquals1 =
                                     FStar_All.pipe_right iquals
                                       (FStar_List.filter
                                          (fun uu___210_7032  ->
                                             match uu___210_7032 with
                                             | FStar_Syntax_Syntax.Abstract 
                                                 -> true
                                             | FStar_Syntax_Syntax.Private 
                                                 -> true
                                             | uu____7033 -> false)) in
                                   quals (FStar_Syntax_Syntax.OnlyName ::
                                     (FStar_Syntax_Syntax.Projector
                                        (lid, (x.FStar_Syntax_Syntax.ppname)))
                                     :: iquals1) in
                                 let decl =
                                   {
                                     FStar_Syntax_Syntax.sigel =
                                       (FStar_Syntax_Syntax.Sig_declare_typ
                                          (field_name, [],
                                            FStar_Syntax_Syntax.tun));
                                     FStar_Syntax_Syntax.sigrng =
                                       (FStar_Ident.range_of_lid field_name);
                                     FStar_Syntax_Syntax.sigquals = quals1;
                                     FStar_Syntax_Syntax.sigmeta =
                                       FStar_Syntax_Syntax.default_sigmeta
                                   } in
                                 if only_decl
                                 then [decl]
                                 else
                                   (let dd =
                                      let uu____7039 =
                                        FStar_All.pipe_right quals1
                                          (FStar_List.contains
                                             FStar_Syntax_Syntax.Abstract) in
                                      if uu____7039
                                      then
                                        FStar_Syntax_Syntax.Delta_abstract
                                          FStar_Syntax_Syntax.Delta_equational
                                      else
                                        FStar_Syntax_Syntax.Delta_equational in
                                    let lb =
                                      let uu____7043 =
                                        let uu____7046 =
                                          FStar_Syntax_Syntax.lid_as_fv
                                            field_name dd None in
                                        FStar_Util.Inr uu____7046 in
                                      {
                                        FStar_Syntax_Syntax.lbname =
                                          uu____7043;
                                        FStar_Syntax_Syntax.lbunivs = [];
                                        FStar_Syntax_Syntax.lbtyp =
                                          FStar_Syntax_Syntax.tun;
                                        FStar_Syntax_Syntax.lbeff =
                                          FStar_Syntax_Const.effect_Tot_lid;
                                        FStar_Syntax_Syntax.lbdef =
                                          FStar_Syntax_Syntax.tun
                                      } in
                                    let impl =
                                      let uu____7048 =
                                        let uu____7049 =
                                          let uu____7055 =
                                            let uu____7057 =
                                              let uu____7058 =
                                                FStar_All.pipe_right
                                                  lb.FStar_Syntax_Syntax.lbname
                                                  FStar_Util.right in
                                              FStar_All.pipe_right uu____7058
                                                (fun fv  ->
                                                   (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v) in
                                            [uu____7057] in
                                          ((false, [lb]), uu____7055, []) in
                                        FStar_Syntax_Syntax.Sig_let
                                          uu____7049 in
                                      {
                                        FStar_Syntax_Syntax.sigel =
                                          uu____7048;
                                        FStar_Syntax_Syntax.sigrng = p;
                                        FStar_Syntax_Syntax.sigquals = quals1;
                                        FStar_Syntax_Syntax.sigmeta =
                                          FStar_Syntax_Syntax.default_sigmeta
                                      } in
                                    if no_decl then [impl] else [decl; impl])))) in
            FStar_All.pipe_right uu____6986 FStar_List.flatten
let mk_data_projector_names iquals env uu____7097 =
  match uu____7097 with
  | (inductive_tps,se) ->
      (match se.FStar_Syntax_Syntax.sigel with
       | FStar_Syntax_Syntax.Sig_datacon
           (lid,uu____7105,t,uu____7107,n1,uu____7109) when
           Prims.op_Negation
             (FStar_Ident.lid_equals lid FStar_Syntax_Const.lexcons_lid)
           ->
           let uu____7112 = FStar_Syntax_Util.arrow_formals t in
           (match uu____7112 with
            | (formals,uu____7122) ->
                (match formals with
                 | [] -> []
                 | uu____7136 ->
                     let filter_records uu___211_7144 =
                       match uu___211_7144 with
                       | FStar_Syntax_Syntax.RecordConstructor
                           (uu____7146,fns) ->
                           Some (FStar_Syntax_Syntax.Record_ctor (lid, fns))
                       | uu____7153 -> None in
                     let fv_qual =
                       let uu____7155 =
                         FStar_Util.find_map se.FStar_Syntax_Syntax.sigquals
                           filter_records in
                       match uu____7155 with
                       | None  -> FStar_Syntax_Syntax.Data_ctor
                       | Some q -> q in
                     let iquals1 =
                       if
                         FStar_List.contains FStar_Syntax_Syntax.Abstract
                           iquals
                       then FStar_Syntax_Syntax.Private :: iquals
                       else iquals in
                     let uu____7162 = FStar_Util.first_N n1 formals in
                     (match uu____7162 with
                      | (uu____7174,rest) ->
                          mk_indexed_projector_names iquals1 fv_qual env lid
                            rest)))
       | uu____7188 -> [])
let mk_typ_abbrev:
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.univ_name Prims.list ->
      (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list ->
        FStar_Syntax_Syntax.typ ->
          FStar_Syntax_Syntax.term ->
            FStar_Ident.lident Prims.list ->
              FStar_Syntax_Syntax.qualifier Prims.list ->
                FStar_Range.range -> FStar_Syntax_Syntax.sigelt
  =
  fun lid  ->
    fun uvs  ->
      fun typars  ->
        fun k  ->
          fun t  ->
            fun lids  ->
              fun quals  ->
                fun rng  ->
                  let dd =
                    let uu____7226 =
                      FStar_All.pipe_right quals
                        (FStar_List.contains FStar_Syntax_Syntax.Abstract) in
                    if uu____7226
                    then
                      let uu____7228 =
                        FStar_Syntax_Util.incr_delta_qualifier t in
                      FStar_Syntax_Syntax.Delta_abstract uu____7228
                    else FStar_Syntax_Util.incr_delta_qualifier t in
                  let lb =
                    let uu____7231 =
                      let uu____7234 =
                        FStar_Syntax_Syntax.lid_as_fv lid dd None in
                      FStar_Util.Inr uu____7234 in
                    let uu____7235 =
                      let uu____7238 = FStar_Syntax_Syntax.mk_Total k in
                      FStar_Syntax_Util.arrow typars uu____7238 in
                    let uu____7241 = no_annot_abs typars t in
                    {
                      FStar_Syntax_Syntax.lbname = uu____7231;
                      FStar_Syntax_Syntax.lbunivs = uvs;
                      FStar_Syntax_Syntax.lbtyp = uu____7235;
                      FStar_Syntax_Syntax.lbeff =
                        FStar_Syntax_Const.effect_Tot_lid;
                      FStar_Syntax_Syntax.lbdef = uu____7241
                    } in
                  {
                    FStar_Syntax_Syntax.sigel =
                      (FStar_Syntax_Syntax.Sig_let ((false, [lb]), lids, []));
                    FStar_Syntax_Syntax.sigrng = rng;
                    FStar_Syntax_Syntax.sigquals = quals;
                    FStar_Syntax_Syntax.sigmeta =
                      FStar_Syntax_Syntax.default_sigmeta
                  }
let rec desugar_tycon:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.decl ->
      FStar_Syntax_Syntax.qualifier Prims.list ->
        FStar_Parser_AST.tycon Prims.list ->
          (env_t* FStar_Syntax_Syntax.sigelts)
  =
  fun env  ->
    fun d  ->
      fun quals  ->
        fun tcs  ->
          let rng = d.FStar_Parser_AST.drange in
          let tycon_id uu___212_7274 =
            match uu___212_7274 with
            | FStar_Parser_AST.TyconAbstract (id,uu____7276,uu____7277) -> id
            | FStar_Parser_AST.TyconAbbrev
                (id,uu____7283,uu____7284,uu____7285) -> id
            | FStar_Parser_AST.TyconRecord
                (id,uu____7291,uu____7292,uu____7293) -> id
            | FStar_Parser_AST.TyconVariant
                (id,uu____7309,uu____7310,uu____7311) -> id in
          let binder_to_term b =
            match b.FStar_Parser_AST.b with
            | FStar_Parser_AST.Annotated (x,uu____7335) ->
                let uu____7336 =
                  let uu____7337 = FStar_Ident.lid_of_ids [x] in
                  FStar_Parser_AST.Var uu____7337 in
                FStar_Parser_AST.mk_term uu____7336 x.FStar_Ident.idRange
                  FStar_Parser_AST.Expr
            | FStar_Parser_AST.Variable x ->
                let uu____7339 =
                  let uu____7340 = FStar_Ident.lid_of_ids [x] in
                  FStar_Parser_AST.Var uu____7340 in
                FStar_Parser_AST.mk_term uu____7339 x.FStar_Ident.idRange
                  FStar_Parser_AST.Expr
            | FStar_Parser_AST.TAnnotated (a,uu____7342) ->
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a)
                  a.FStar_Ident.idRange FStar_Parser_AST.Type_level
            | FStar_Parser_AST.TVariable a ->
                FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a)
                  a.FStar_Ident.idRange FStar_Parser_AST.Type_level
            | FStar_Parser_AST.NoName t -> t in
          let tot =
            FStar_Parser_AST.mk_term
              (FStar_Parser_AST.Name FStar_Syntax_Const.effect_Tot_lid) rng
              FStar_Parser_AST.Expr in
          let with_constructor_effect t =
            FStar_Parser_AST.mk_term
              (FStar_Parser_AST.App (tot, t, FStar_Parser_AST.Nothing))
              t.FStar_Parser_AST.range t.FStar_Parser_AST.level in
          let apply_binders t binders =
            let imp_of_aqual b =
              match b.FStar_Parser_AST.aqual with
              | Some (FStar_Parser_AST.Implicit ) -> FStar_Parser_AST.Hash
              | uu____7363 -> FStar_Parser_AST.Nothing in
            FStar_List.fold_left
              (fun out  ->
                 fun b  ->
                   let uu____7366 =
                     let uu____7367 =
                       let uu____7371 = binder_to_term b in
                       (out, uu____7371, (imp_of_aqual b)) in
                     FStar_Parser_AST.App uu____7367 in
                   FStar_Parser_AST.mk_term uu____7366
                     out.FStar_Parser_AST.range out.FStar_Parser_AST.level) t
              binders in
          let tycon_record_as_variant uu___213_7378 =
            match uu___213_7378 with
            | FStar_Parser_AST.TyconRecord (id,parms,kopt,fields) ->
                let constrName =
                  FStar_Ident.mk_ident
                    ((Prims.strcat "Mk" id.FStar_Ident.idText),
                      (id.FStar_Ident.idRange)) in
                let mfields =
                  FStar_List.map
                    (fun uu____7407  ->
                       match uu____7407 with
                       | (x,t,uu____7414) ->
                           FStar_Parser_AST.mk_binder
                             (FStar_Parser_AST.Annotated
                                ((FStar_Syntax_Util.mangle_field_name x), t))
                             x.FStar_Ident.idRange FStar_Parser_AST.Expr None)
                    fields in
                let result =
                  let uu____7418 =
                    let uu____7419 =
                      let uu____7420 = FStar_Ident.lid_of_ids [id] in
                      FStar_Parser_AST.Var uu____7420 in
                    FStar_Parser_AST.mk_term uu____7419
                      id.FStar_Ident.idRange FStar_Parser_AST.Type_level in
                  apply_binders uu____7418 parms in
                let constrTyp =
                  FStar_Parser_AST.mk_term
                    (FStar_Parser_AST.Product
                       (mfields, (with_constructor_effect result)))
                    id.FStar_Ident.idRange FStar_Parser_AST.Type_level in
                let uu____7423 =
                  FStar_All.pipe_right fields
                    (FStar_List.map
                       (fun uu____7435  ->
                          match uu____7435 with
                          | (x,uu____7441,uu____7442) ->
                              FStar_Syntax_Util.unmangle_field_name x)) in
                ((FStar_Parser_AST.TyconVariant
                    (id, parms, kopt,
                      [(constrName, (Some constrTyp), None, false)])),
                  uu____7423)
            | uu____7469 -> failwith "impossible" in
          let desugar_abstract_tc quals1 _env mutuals uu___214_7491 =
            match uu___214_7491 with
            | FStar_Parser_AST.TyconAbstract (id,binders,kopt) ->
                let uu____7505 = typars_of_binders _env binders in
                (match uu____7505 with
                 | (_env',typars) ->
                     let k =
                       match kopt with
                       | None  -> FStar_Syntax_Util.ktype
                       | Some k -> desugar_term _env' k in
                     let tconstr =
                       let uu____7533 =
                         let uu____7534 =
                           let uu____7535 = FStar_Ident.lid_of_ids [id] in
                           FStar_Parser_AST.Var uu____7535 in
                         FStar_Parser_AST.mk_term uu____7534
                           id.FStar_Ident.idRange FStar_Parser_AST.Type_level in
                       apply_binders uu____7533 binders in
                     let qlid = FStar_ToSyntax_Env.qualify _env id in
                     let typars1 = FStar_Syntax_Subst.close_binders typars in
                     let k1 = FStar_Syntax_Subst.close typars1 k in
                     let se =
                       {
                         FStar_Syntax_Syntax.sigel =
                           (FStar_Syntax_Syntax.Sig_inductive_typ
                              (qlid, [], typars1, k1, mutuals, []));
                         FStar_Syntax_Syntax.sigrng = rng;
                         FStar_Syntax_Syntax.sigquals = quals1;
                         FStar_Syntax_Syntax.sigmeta =
                           FStar_Syntax_Syntax.default_sigmeta
                       } in
                     let _env1 =
                       FStar_ToSyntax_Env.push_top_level_rec_binding _env id
                         FStar_Syntax_Syntax.Delta_constant in
                     let _env2 =
                       FStar_ToSyntax_Env.push_top_level_rec_binding _env' id
                         FStar_Syntax_Syntax.Delta_constant in
                     (_env1, _env2, se, tconstr))
            | uu____7545 -> failwith "Unexpected tycon" in
          let push_tparams env1 bs =
            let uu____7571 =
              FStar_List.fold_left
                (fun uu____7587  ->
                   fun uu____7588  ->
                     match (uu____7587, uu____7588) with
                     | ((env2,tps),(x,imp)) ->
                         let uu____7636 =
                           FStar_ToSyntax_Env.push_bv env2
                             x.FStar_Syntax_Syntax.ppname in
                         (match uu____7636 with
                          | (env3,y) -> (env3, ((y, imp) :: tps))))
                (env1, []) bs in
            match uu____7571 with
            | (env2,bs1) -> (env2, (FStar_List.rev bs1)) in
          match tcs with
          | (FStar_Parser_AST.TyconAbstract (id,bs,kopt))::[] ->
              let kopt1 =
                match kopt with
                | None  ->
                    let uu____7697 = tm_type_z id.FStar_Ident.idRange in
                    Some uu____7697
                | uu____7698 -> kopt in
              let tc = FStar_Parser_AST.TyconAbstract (id, bs, kopt1) in
              let uu____7703 = desugar_abstract_tc quals env [] tc in
              (match uu____7703 with
               | (uu____7710,uu____7711,se,uu____7713) ->
                   let se1 =
                     match se.FStar_Syntax_Syntax.sigel with
                     | FStar_Syntax_Syntax.Sig_inductive_typ
                         (l,uu____7716,typars,k,[],[]) ->
                         let quals1 = se.FStar_Syntax_Syntax.sigquals in
                         let quals2 =
                           let uu____7725 =
                             FStar_All.pipe_right quals1
                               (FStar_List.contains
                                  FStar_Syntax_Syntax.Assumption) in
                           if uu____7725
                           then quals1
                           else
                             ((let uu____7730 =
                                 FStar_Range.string_of_range
                                   se.FStar_Syntax_Syntax.sigrng in
                               let uu____7731 =
                                 FStar_Syntax_Print.lid_to_string l in
                               FStar_Util.print2
                                 "%s (Warning): Adding an implicit 'assume new' qualifier on %s\n"
                                 uu____7730 uu____7731);
                              FStar_Syntax_Syntax.Assumption
                              ::
                              FStar_Syntax_Syntax.New
                              ::
                              quals1) in
                         let t =
                           match typars with
                           | [] -> k
                           | uu____7735 ->
                               let uu____7736 =
                                 let uu____7739 =
                                   let uu____7740 =
                                     let uu____7748 =
                                       FStar_Syntax_Syntax.mk_Total k in
                                     (typars, uu____7748) in
                                   FStar_Syntax_Syntax.Tm_arrow uu____7740 in
                                 FStar_Syntax_Syntax.mk uu____7739 in
                               uu____7736 None se.FStar_Syntax_Syntax.sigrng in
                         let uu___233_7757 = se in
                         {
                           FStar_Syntax_Syntax.sigel =
                             (FStar_Syntax_Syntax.Sig_declare_typ (l, [], t));
                           FStar_Syntax_Syntax.sigrng =
                             (uu___233_7757.FStar_Syntax_Syntax.sigrng);
                           FStar_Syntax_Syntax.sigquals = quals2;
                           FStar_Syntax_Syntax.sigmeta =
                             (uu___233_7757.FStar_Syntax_Syntax.sigmeta)
                         }
                     | uu____7759 -> failwith "Impossible" in
                   let env1 = FStar_ToSyntax_Env.push_sigelt env se1 in
                   let env2 =
                     let uu____7762 = FStar_ToSyntax_Env.qualify env1 id in
                     FStar_ToSyntax_Env.push_doc env1 uu____7762
                       d.FStar_Parser_AST.doc in
                   (env2, [se1]))
          | (FStar_Parser_AST.TyconAbbrev (id,binders,kopt,t))::[] ->
              let uu____7772 = typars_of_binders env binders in
              (match uu____7772 with
               | (env',typars) ->
                   let k =
                     match kopt with
                     | None  ->
                         let uu____7792 =
                           FStar_Util.for_some
                             (fun uu___215_7793  ->
                                match uu___215_7793 with
                                | FStar_Syntax_Syntax.Effect  -> true
                                | uu____7794 -> false) quals in
                         if uu____7792
                         then FStar_Syntax_Syntax.teff
                         else FStar_Syntax_Syntax.tun
                     | Some k -> desugar_term env' k in
                   let t0 = t in
                   let quals1 =
                     let uu____7800 =
                       FStar_All.pipe_right quals
                         (FStar_Util.for_some
                            (fun uu___216_7802  ->
                               match uu___216_7802 with
                               | FStar_Syntax_Syntax.Logic  -> true
                               | uu____7803 -> false)) in
                     if uu____7800
                     then quals
                     else
                       if
                         t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula
                       then FStar_Syntax_Syntax.Logic :: quals
                       else quals in
                   let qlid = FStar_ToSyntax_Env.qualify env id in
                   let se =
                     let uu____7810 =
                       FStar_All.pipe_right quals1
                         (FStar_List.contains FStar_Syntax_Syntax.Effect) in
                     if uu____7810
                     then
                       let uu____7812 =
                         let uu____7816 =
                           let uu____7817 = unparen t in
                           uu____7817.FStar_Parser_AST.tm in
                         match uu____7816 with
                         | FStar_Parser_AST.Construct (head1,args) ->
                             let uu____7829 =
                               match FStar_List.rev args with
                               | (last_arg,uu____7845)::args_rev ->
                                   let uu____7852 =
                                     let uu____7853 = unparen last_arg in
                                     uu____7853.FStar_Parser_AST.tm in
                                   (match uu____7852 with
                                    | FStar_Parser_AST.Attributes ts ->
                                        (ts, (FStar_List.rev args_rev))
                                    | uu____7868 -> ([], args))
                               | uu____7873 -> ([], args) in
                             (match uu____7829 with
                              | (cattributes,args1) ->
                                  let uu____7894 =
                                    desugar_attributes env cattributes in
                                  ((FStar_Parser_AST.mk_term
                                      (FStar_Parser_AST.Construct
                                         (head1, args1))
                                      t.FStar_Parser_AST.range
                                      t.FStar_Parser_AST.level), uu____7894))
                         | uu____7900 -> (t, []) in
                       match uu____7812 with
                       | (t1,cattributes) ->
                           let c =
                             desugar_comp t1.FStar_Parser_AST.range env' t1 in
                           let typars1 =
                             FStar_Syntax_Subst.close_binders typars in
                           let c1 = FStar_Syntax_Subst.close_comp typars1 c in
                           let quals2 =
                             FStar_All.pipe_right quals1
                               (FStar_List.filter
                                  (fun uu___217_7915  ->
                                     match uu___217_7915 with
                                     | FStar_Syntax_Syntax.Effect  -> false
                                     | uu____7916 -> true)) in
                           {
                             FStar_Syntax_Syntax.sigel =
                               (FStar_Syntax_Syntax.Sig_effect_abbrev
                                  (qlid, [], typars1, c1,
                                    (FStar_List.append cattributes
                                       (FStar_Syntax_Util.comp_flags c1))));
                             FStar_Syntax_Syntax.sigrng = rng;
                             FStar_Syntax_Syntax.sigquals = quals2;
                             FStar_Syntax_Syntax.sigmeta =
                               FStar_Syntax_Syntax.default_sigmeta
                           }
                     else
                       (let t1 = desugar_typ env' t in
                        mk_typ_abbrev qlid [] typars k t1 [qlid] quals1 rng) in
                   let env1 = FStar_ToSyntax_Env.push_sigelt env se in
                   let env2 =
                     FStar_ToSyntax_Env.push_doc env1 qlid
                       d.FStar_Parser_AST.doc in
                   (env2, [se]))
          | (FStar_Parser_AST.TyconRecord uu____7924)::[] ->
              let trec = FStar_List.hd tcs in
              let uu____7937 = tycon_record_as_variant trec in
              (match uu____7937 with
               | (t,fs) ->
                   let uu____7947 =
                     let uu____7949 =
                       let uu____7950 =
                         let uu____7955 =
                           let uu____7957 =
                             FStar_ToSyntax_Env.current_module env in
                           FStar_Ident.ids_of_lid uu____7957 in
                         (uu____7955, fs) in
                       FStar_Syntax_Syntax.RecordType uu____7950 in
                     uu____7949 :: quals in
                   desugar_tycon env d uu____7947 [t])
          | uu____7960::uu____7961 ->
              let env0 = env in
              let mutuals =
                FStar_List.map
                  (fun x  ->
                     FStar_All.pipe_left (FStar_ToSyntax_Env.qualify env)
                       (tycon_id x)) tcs in
              let rec collect_tcs quals1 et tc =
                let uu____8048 = et in
                match uu____8048 with
                | (env1,tcs1) ->
                    (match tc with
                     | FStar_Parser_AST.TyconRecord uu____8162 ->
                         let trec = tc in
                         let uu____8175 = tycon_record_as_variant trec in
                         (match uu____8175 with
                          | (t,fs) ->
                              let uu____8206 =
                                let uu____8208 =
                                  let uu____8209 =
                                    let uu____8214 =
                                      let uu____8216 =
                                        FStar_ToSyntax_Env.current_module
                                          env1 in
                                      FStar_Ident.ids_of_lid uu____8216 in
                                    (uu____8214, fs) in
                                  FStar_Syntax_Syntax.RecordType uu____8209 in
                                uu____8208 :: quals1 in
                              collect_tcs uu____8206 (env1, tcs1) t)
                     | FStar_Parser_AST.TyconVariant
                         (id,binders,kopt,constructors) ->
                         let uu____8262 =
                           desugar_abstract_tc quals1 env1 mutuals
                             (FStar_Parser_AST.TyconAbstract
                                (id, binders, kopt)) in
                         (match uu____8262 with
                          | (env2,uu____8293,se,tconstr) ->
                              (env2,
                                ((FStar_Util.Inl
                                    (se, constructors, tconstr, quals1)) ::
                                tcs1)))
                     | FStar_Parser_AST.TyconAbbrev (id,binders,kopt,t) ->
                         let uu____8371 =
                           desugar_abstract_tc quals1 env1 mutuals
                             (FStar_Parser_AST.TyconAbstract
                                (id, binders, kopt)) in
                         (match uu____8371 with
                          | (env2,uu____8402,se,tconstr) ->
                              (env2,
                                ((FStar_Util.Inr (se, binders, t, quals1)) ::
                                tcs1)))
                     | uu____8466 ->
                         failwith "Unrecognized mutual type definition") in
              let uu____8490 =
                FStar_List.fold_left (collect_tcs quals) (env, []) tcs in
              (match uu____8490 with
               | (env1,tcs1) ->
                   let tcs2 = FStar_List.rev tcs1 in
                   let docs_tps_sigelts =
                     FStar_All.pipe_right tcs2
                       (FStar_List.collect
                          (fun uu___219_8740  ->
                             match uu___219_8740 with
                             | FStar_Util.Inr
                                 ({
                                    FStar_Syntax_Syntax.sigel =
                                      FStar_Syntax_Syntax.Sig_inductive_typ
                                      (id,uvs,tpars,k,uu____8776,uu____8777);
                                    FStar_Syntax_Syntax.sigrng = uu____8778;
                                    FStar_Syntax_Syntax.sigquals = uu____8779;
                                    FStar_Syntax_Syntax.sigmeta = uu____8780;_},binders,t,quals1)
                                 ->
                                 let t1 =
                                   let uu____8812 =
                                     typars_of_binders env1 binders in
                                   match uu____8812 with
                                   | (env2,tpars1) ->
                                       let uu____8829 =
                                         push_tparams env2 tpars1 in
                                       (match uu____8829 with
                                        | (env_tps,tpars2) ->
                                            let t1 = desugar_typ env_tps t in
                                            let tpars3 =
                                              FStar_Syntax_Subst.close_binders
                                                tpars2 in
                                            FStar_Syntax_Subst.close tpars3
                                              t1) in
                                 let uu____8848 =
                                   let uu____8859 =
                                     mk_typ_abbrev id uvs tpars k t1 
                                       [id] quals1 rng in
                                   ((id, (d.FStar_Parser_AST.doc)), [],
                                     uu____8859) in
                                 [uu____8848]
                             | FStar_Util.Inl
                                 ({
                                    FStar_Syntax_Syntax.sigel =
                                      FStar_Syntax_Syntax.Sig_inductive_typ
                                      (tname,univs,tpars,k,mutuals1,uu____8896);
                                    FStar_Syntax_Syntax.sigrng = uu____8897;
                                    FStar_Syntax_Syntax.sigquals =
                                      tname_quals;
                                    FStar_Syntax_Syntax.sigmeta = uu____8899;_},constrs,tconstr,quals1)
                                 ->
                                 let mk_tot t =
                                   let tot1 =
                                     FStar_Parser_AST.mk_term
                                       (FStar_Parser_AST.Name
                                          FStar_Syntax_Const.effect_Tot_lid)
                                       t.FStar_Parser_AST.range
                                       t.FStar_Parser_AST.level in
                                   FStar_Parser_AST.mk_term
                                     (FStar_Parser_AST.App
                                        (tot1, t, FStar_Parser_AST.Nothing))
                                     t.FStar_Parser_AST.range
                                     t.FStar_Parser_AST.level in
                                 let tycon = (tname, tpars, k) in
                                 let uu____8951 = push_tparams env1 tpars in
                                 (match uu____8951 with
                                  | (env_tps,tps) ->
                                      let data_tpars =
                                        FStar_List.map
                                          (fun uu____8990  ->
                                             match uu____8990 with
                                             | (x,uu____8998) ->
                                                 (x,
                                                   (Some
                                                      (FStar_Syntax_Syntax.Implicit
                                                         true)))) tps in
                                      let tot_tconstr = mk_tot tconstr in
                                      let uu____9003 =
                                        let uu____9018 =
                                          FStar_All.pipe_right constrs
                                            (FStar_List.map
                                               (fun uu____9070  ->
                                                  match uu____9070 with
                                                  | (id,topt,doc1,of_notation)
                                                      ->
                                                      let t =
                                                        if of_notation
                                                        then
                                                          match topt with
                                                          | Some t ->
                                                              FStar_Parser_AST.mk_term
                                                                (FStar_Parser_AST.Product
                                                                   ([
                                                                    FStar_Parser_AST.mk_binder
                                                                    (FStar_Parser_AST.NoName
                                                                    t)
                                                                    t.FStar_Parser_AST.range
                                                                    t.FStar_Parser_AST.level
                                                                    None],
                                                                    tot_tconstr))
                                                                t.FStar_Parser_AST.range
                                                                t.FStar_Parser_AST.level
                                                          | None  -> tconstr
                                                        else
                                                          (match topt with
                                                           | None  ->
                                                               failwith
                                                                 "Impossible"
                                                           | Some t -> t) in
                                                      let t1 =
                                                        let uu____9103 =
                                                          close env_tps t in
                                                        desugar_term env_tps
                                                          uu____9103 in
                                                      let name =
                                                        FStar_ToSyntax_Env.qualify
                                                          env1 id in
                                                      let quals2 =
                                                        FStar_All.pipe_right
                                                          tname_quals
                                                          (FStar_List.collect
                                                             (fun
                                                                uu___218_9109
                                                                 ->
                                                                match uu___218_9109
                                                                with
                                                                | FStar_Syntax_Syntax.RecordType
                                                                    fns ->
                                                                    [
                                                                    FStar_Syntax_Syntax.RecordConstructor
                                                                    fns]
                                                                | uu____9116
                                                                    -> [])) in
                                                      let ntps =
                                                        FStar_List.length
                                                          data_tpars in
                                                      let uu____9122 =
                                                        let uu____9133 =
                                                          let uu____9134 =
                                                            let uu____9135 =
                                                              let uu____9143
                                                                =
                                                                let uu____9146
                                                                  =
                                                                  let uu____9149
                                                                    =
                                                                    FStar_All.pipe_right
                                                                    t1
                                                                    FStar_Syntax_Util.name_function_binders in
                                                                  FStar_Syntax_Syntax.mk_Total
                                                                    uu____9149 in
                                                                FStar_Syntax_Util.arrow
                                                                  data_tpars
                                                                  uu____9146 in
                                                              (name, univs,
                                                                uu____9143,
                                                                tname, ntps,
                                                                mutuals1) in
                                                            FStar_Syntax_Syntax.Sig_datacon
                                                              uu____9135 in
                                                          {
                                                            FStar_Syntax_Syntax.sigel
                                                              = uu____9134;
                                                            FStar_Syntax_Syntax.sigrng
                                                              = rng;
                                                            FStar_Syntax_Syntax.sigquals
                                                              = quals2;
                                                            FStar_Syntax_Syntax.sigmeta
                                                              =
                                                              FStar_Syntax_Syntax.default_sigmeta
                                                          } in
                                                        ((name, doc1), tps,
                                                          uu____9133) in
                                                      (name, uu____9122))) in
                                        FStar_All.pipe_left FStar_List.split
                                          uu____9018 in
                                      (match uu____9003 with
                                       | (constrNames,constrs1) ->
                                           ((tname, (d.FStar_Parser_AST.doc)),
                                             [],
                                             {
                                               FStar_Syntax_Syntax.sigel =
                                                 (FStar_Syntax_Syntax.Sig_inductive_typ
                                                    (tname, univs, tpars, k,
                                                      mutuals1, constrNames));
                                               FStar_Syntax_Syntax.sigrng =
                                                 rng;
                                               FStar_Syntax_Syntax.sigquals =
                                                 tname_quals;
                                               FStar_Syntax_Syntax.sigmeta =
                                                 FStar_Syntax_Syntax.default_sigmeta
                                             })
                                           :: constrs1))
                             | uu____9272 -> failwith "impossible")) in
                   let name_docs =
                     FStar_All.pipe_right docs_tps_sigelts
                       (FStar_List.map
                          (fun uu____9337  ->
                             match uu____9337 with
                             | (name_doc,uu____9352,uu____9353) -> name_doc)) in
                   let sigelts =
                     FStar_All.pipe_right docs_tps_sigelts
                       (FStar_List.map
                          (fun uu____9392  ->
                             match uu____9392 with
                             | (uu____9403,uu____9404,se) -> se)) in
                   let uu____9420 =
                     let uu____9424 =
                       FStar_List.collect FStar_Syntax_Util.lids_of_sigelt
                         sigelts in
                     FStar_Syntax_MutRecTy.disentangle_abbrevs_from_bundle
                       sigelts quals uu____9424 rng in
                   (match uu____9420 with
                    | (bundle,abbrevs) ->
                        let env2 = FStar_ToSyntax_Env.push_sigelt env0 bundle in
                        let env3 =
                          FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt
                            env2 abbrevs in
                        let data_ops =
                          FStar_All.pipe_right docs_tps_sigelts
                            (FStar_List.collect
                               (fun uu____9458  ->
                                  match uu____9458 with
                                  | (uu____9470,tps,se) ->
                                      mk_data_projector_names quals env3
                                        (tps, se))) in
                        let discs =
                          FStar_All.pipe_right sigelts
                            (FStar_List.collect
                               (fun se  ->
                                  match se.FStar_Syntax_Syntax.sigel with
                                  | FStar_Syntax_Syntax.Sig_inductive_typ
                                      (tname,uu____9502,tps,k,uu____9505,constrs)
                                      when
                                      (FStar_List.length constrs) >
                                        (Prims.parse_int "1")
                                      ->
                                      let quals1 =
                                        se.FStar_Syntax_Syntax.sigquals in
                                      let quals2 =
                                        if
                                          FStar_List.contains
                                            FStar_Syntax_Syntax.Abstract
                                            quals1
                                        then FStar_Syntax_Syntax.Private ::
                                          quals1
                                        else quals1 in
                                      mk_data_discriminators quals2 env3
                                        tname tps k constrs
                                  | uu____9520 -> [])) in
                        let ops = FStar_List.append discs data_ops in
                        let env4 =
                          FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt
                            env3 ops in
                        let env5 =
                          FStar_List.fold_left
                            (fun acc  ->
                               fun uu____9529  ->
                                 match uu____9529 with
                                 | (lid,doc1) ->
                                     FStar_ToSyntax_Env.push_doc env4 lid
                                       doc1) env4 name_docs in
                        (env5,
                          (FStar_List.append [bundle]
                             (FStar_List.append abbrevs ops)))))
          | [] -> failwith "impossible"
let desugar_binders:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_ToSyntax_Env.env* FStar_Syntax_Syntax.binder Prims.list)
  =
  fun env  ->
    fun binders  ->
      let uu____9551 =
        FStar_List.fold_left
          (fun uu____9558  ->
             fun b  ->
               match uu____9558 with
               | (env1,binders1) ->
                   let uu____9570 = desugar_binder env1 b in
                   (match uu____9570 with
                    | (Some a,k) ->
                        let uu____9580 =
                          as_binder env1 b.FStar_Parser_AST.aqual
                            ((Some a), k) in
                        (match uu____9580 with
                         | (binder,env2) -> (env2, (binder :: binders1)))
                    | uu____9590 ->
                        raise
                          (FStar_Errors.Error
                             ("Missing name in binder",
                               (b.FStar_Parser_AST.brange))))) (env, [])
          binders in
      match uu____9551 with
      | (env1,binders1) -> (env1, (FStar_List.rev binders1))
let rec desugar_effect:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.decl ->
      FStar_Parser_AST.qualifiers ->
        FStar_Ident.ident ->
          FStar_Parser_AST.binder Prims.list ->
            FStar_Parser_AST.term ->
              FStar_Parser_AST.decl Prims.list ->
                (FStar_ToSyntax_Env.env* FStar_Syntax_Syntax.sigelt
                  Prims.list)
  =
  fun env  ->
    fun d  ->
      fun quals  ->
        fun eff_name  ->
          fun eff_binders  ->
            fun eff_typ  ->
              fun eff_decls  ->
                let env0 = env in
                let monad_env =
                  FStar_ToSyntax_Env.enter_monad_scope env eff_name in
                let uu____9668 = desugar_binders monad_env eff_binders in
                match uu____9668 with
                | (env1,binders) ->
                    let eff_t = desugar_term env1 eff_typ in
                    let for_free =
                      let uu____9681 =
                        let uu____9682 =
                          let uu____9686 =
                            FStar_Syntax_Util.arrow_formals eff_t in
                          fst uu____9686 in
                        FStar_List.length uu____9682 in
                      uu____9681 = (Prims.parse_int "1") in
                    let mandatory_members =
                      let rr_members = ["repr"; "return"; "bind"] in
                      if for_free
                      then rr_members
                      else
                        FStar_List.append rr_members
                          ["return_wp";
                          "bind_wp";
                          "if_then_else";
                          "ite_wp";
                          "stronger";
                          "close_wp";
                          "assert_p";
                          "assume_p";
                          "null_wp";
                          "trivial"] in
                    let name_of_eff_decl decl =
                      match decl.FStar_Parser_AST.d with
                      | FStar_Parser_AST.Tycon
                          (uu____9714,(FStar_Parser_AST.TyconAbbrev
                                       (name,uu____9716,uu____9717,uu____9718),uu____9719)::[])
                          -> FStar_Ident.text_of_id name
                      | uu____9736 ->
                          failwith "Malformed effect member declaration." in
                    let uu____9737 =
                      FStar_List.partition
                        (fun decl  ->
                           let uu____9743 = name_of_eff_decl decl in
                           FStar_List.mem uu____9743 mandatory_members)
                        eff_decls in
                    (match uu____9737 with
                     | (mandatory_members_decls,actions) ->
                         let uu____9753 =
                           FStar_All.pipe_right mandatory_members_decls
                             (FStar_List.fold_left
                                (fun uu____9764  ->
                                   fun decl  ->
                                     match uu____9764 with
                                     | (env2,out) ->
                                         let uu____9776 =
                                           desugar_decl env2 decl in
                                         (match uu____9776 with
                                          | (env3,ses) ->
                                              let uu____9784 =
                                                let uu____9786 =
                                                  FStar_List.hd ses in
                                                uu____9786 :: out in
                                              (env3, uu____9784))) (env1, [])) in
                         (match uu____9753 with
                          | (env2,decls) ->
                              let binders1 =
                                FStar_Syntax_Subst.close_binders binders in
                              let actions_docs =
                                FStar_All.pipe_right actions
                                  (FStar_List.map
                                     (fun d1  ->
                                        match d1.FStar_Parser_AST.d with
                                        | FStar_Parser_AST.Tycon
                                            (uu____9814,(FStar_Parser_AST.TyconAbbrev
                                                         (name,action_params,uu____9817,
                                                          {
                                                            FStar_Parser_AST.tm
                                                              =
                                                              FStar_Parser_AST.Construct
                                                              (uu____9818,
                                                               (def,uu____9820)::
                                                               (cps_type,uu____9822)::[]);
                                                            FStar_Parser_AST.range
                                                              = uu____9823;
                                                            FStar_Parser_AST.level
                                                              = uu____9824;_}),doc1)::[])
                                            when Prims.op_Negation for_free
                                            ->
                                            let uu____9851 =
                                              desugar_binders env2
                                                action_params in
                                            (match uu____9851 with
                                             | (env3,action_params1) ->
                                                 let action_params2 =
                                                   FStar_Syntax_Subst.close_binders
                                                     action_params1 in
                                                 let uu____9863 =
                                                   let uu____9864 =
                                                     FStar_ToSyntax_Env.qualify
                                                       env3 name in
                                                   let uu____9865 =
                                                     let uu____9866 =
                                                       desugar_term env3 def in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_List.append
                                                          binders1
                                                          action_params2)
                                                       uu____9866 in
                                                   let uu____9869 =
                                                     let uu____9870 =
                                                       desugar_typ env3
                                                         cps_type in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_List.append
                                                          binders1
                                                          action_params2)
                                                       uu____9870 in
                                                   {
                                                     FStar_Syntax_Syntax.action_name
                                                       = uu____9864;
                                                     FStar_Syntax_Syntax.action_unqualified_name
                                                       = name;
                                                     FStar_Syntax_Syntax.action_univs
                                                       = [];
                                                     FStar_Syntax_Syntax.action_params
                                                       = action_params2;
                                                     FStar_Syntax_Syntax.action_defn
                                                       = uu____9865;
                                                     FStar_Syntax_Syntax.action_typ
                                                       = uu____9869
                                                   } in
                                                 (uu____9863, doc1))
                                        | FStar_Parser_AST.Tycon
                                            (uu____9874,(FStar_Parser_AST.TyconAbbrev
                                                         (name,action_params,uu____9877,defn),doc1)::[])
                                            when for_free ->
                                            let uu____9896 =
                                              desugar_binders env2
                                                action_params in
                                            (match uu____9896 with
                                             | (env3,action_params1) ->
                                                 let action_params2 =
                                                   FStar_Syntax_Subst.close_binders
                                                     action_params1 in
                                                 let uu____9908 =
                                                   let uu____9909 =
                                                     FStar_ToSyntax_Env.qualify
                                                       env3 name in
                                                   let uu____9910 =
                                                     let uu____9911 =
                                                       desugar_term env3 defn in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_List.append
                                                          binders1
                                                          action_params2)
                                                       uu____9911 in
                                                   {
                                                     FStar_Syntax_Syntax.action_name
                                                       = uu____9909;
                                                     FStar_Syntax_Syntax.action_unqualified_name
                                                       = name;
                                                     FStar_Syntax_Syntax.action_univs
                                                       = [];
                                                     FStar_Syntax_Syntax.action_params
                                                       = action_params2;
                                                     FStar_Syntax_Syntax.action_defn
                                                       = uu____9910;
                                                     FStar_Syntax_Syntax.action_typ
                                                       =
                                                       FStar_Syntax_Syntax.tun
                                                   } in
                                                 (uu____9908, doc1))
                                        | uu____9915 ->
                                            raise
                                              (FStar_Errors.Error
                                                 ("Malformed action declaration; if this is an \"effect for free\", just provide the direct-style declaration. If this is not an \"effect for free\", please provide a pair of the definition and its cps-type with arrows inserted in the right place (see examples).",
                                                   (d1.FStar_Parser_AST.drange))))) in
                              let actions1 =
                                FStar_List.map FStar_Pervasives.fst
                                  actions_docs in
                              let eff_t1 =
                                FStar_Syntax_Subst.close binders1 eff_t in
                              let lookup s =
                                let l =
                                  FStar_ToSyntax_Env.qualify env2
                                    (FStar_Ident.mk_ident
                                       (s, (d.FStar_Parser_AST.drange))) in
                                let uu____9934 =
                                  let uu____9935 =
                                    FStar_ToSyntax_Env.fail_or env2
                                      (FStar_ToSyntax_Env.try_lookup_definition
                                         env2) l in
                                  FStar_All.pipe_left
                                    (FStar_Syntax_Subst.close binders1)
                                    uu____9935 in
                                ([], uu____9934) in
                              let mname =
                                FStar_ToSyntax_Env.qualify env0 eff_name in
                              let qualifiers =
                                FStar_List.map
                                  (trans_qual d.FStar_Parser_AST.drange
                                     (Some mname)) quals in
                              let se =
                                if for_free
                                then
                                  let dummy_tscheme =
                                    let uu____9947 =
                                      FStar_Syntax_Syntax.mk
                                        FStar_Syntax_Syntax.Tm_unknown None
                                        FStar_Range.dummyRange in
                                    ([], uu____9947) in
                                  let uu____9957 =
                                    let uu____9958 =
                                      let uu____9959 =
                                        let uu____9960 = lookup "repr" in
                                        snd uu____9960 in
                                      let uu____9965 = lookup "return" in
                                      let uu____9966 = lookup "bind" in
                                      {
                                        FStar_Syntax_Syntax.cattributes = [];
                                        FStar_Syntax_Syntax.mname = mname;
                                        FStar_Syntax_Syntax.univs = [];
                                        FStar_Syntax_Syntax.binders =
                                          binders1;
                                        FStar_Syntax_Syntax.signature =
                                          eff_t1;
                                        FStar_Syntax_Syntax.ret_wp =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.bind_wp =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.if_then_else =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.ite_wp =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.stronger =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.close_wp =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.assert_p =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.assume_p =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.null_wp =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.trivial =
                                          dummy_tscheme;
                                        FStar_Syntax_Syntax.repr = uu____9959;
                                        FStar_Syntax_Syntax.return_repr =
                                          uu____9965;
                                        FStar_Syntax_Syntax.bind_repr =
                                          uu____9966;
                                        FStar_Syntax_Syntax.actions =
                                          actions1
                                      } in
                                    FStar_Syntax_Syntax.Sig_new_effect_for_free
                                      uu____9958 in
                                  {
                                    FStar_Syntax_Syntax.sigel = uu____9957;
                                    FStar_Syntax_Syntax.sigrng =
                                      (d.FStar_Parser_AST.drange);
                                    FStar_Syntax_Syntax.sigquals = qualifiers;
                                    FStar_Syntax_Syntax.sigmeta =
                                      FStar_Syntax_Syntax.default_sigmeta
                                  }
                                else
                                  (let rr =
                                     FStar_Util.for_some
                                       (fun uu___220_9969  ->
                                          match uu___220_9969 with
                                          | FStar_Syntax_Syntax.Reifiable  ->
                                              true
                                          | FStar_Syntax_Syntax.Reflectable
                                              uu____9970 -> true
                                          | uu____9971 -> false) qualifiers in
                                   let un_ts = ([], FStar_Syntax_Syntax.tun) in
                                   let uu____9977 =
                                     let uu____9978 =
                                       let uu____9979 = lookup "return_wp" in
                                       let uu____9980 = lookup "bind_wp" in
                                       let uu____9981 = lookup "if_then_else" in
                                       let uu____9982 = lookup "ite_wp" in
                                       let uu____9983 = lookup "stronger" in
                                       let uu____9984 = lookup "close_wp" in
                                       let uu____9985 = lookup "assert_p" in
                                       let uu____9986 = lookup "assume_p" in
                                       let uu____9987 = lookup "null_wp" in
                                       let uu____9988 = lookup "trivial" in
                                       let uu____9989 =
                                         if rr
                                         then
                                           let uu____9990 = lookup "repr" in
                                           FStar_All.pipe_left
                                             FStar_Pervasives.snd uu____9990
                                         else FStar_Syntax_Syntax.tun in
                                       let uu____9999 =
                                         if rr
                                         then lookup "return"
                                         else un_ts in
                                       let uu____10001 =
                                         if rr then lookup "bind" else un_ts in
                                       {
                                         FStar_Syntax_Syntax.cattributes = [];
                                         FStar_Syntax_Syntax.mname = mname;
                                         FStar_Syntax_Syntax.univs = [];
                                         FStar_Syntax_Syntax.binders =
                                           binders1;
                                         FStar_Syntax_Syntax.signature =
                                           eff_t1;
                                         FStar_Syntax_Syntax.ret_wp =
                                           uu____9979;
                                         FStar_Syntax_Syntax.bind_wp =
                                           uu____9980;
                                         FStar_Syntax_Syntax.if_then_else =
                                           uu____9981;
                                         FStar_Syntax_Syntax.ite_wp =
                                           uu____9982;
                                         FStar_Syntax_Syntax.stronger =
                                           uu____9983;
                                         FStar_Syntax_Syntax.close_wp =
                                           uu____9984;
                                         FStar_Syntax_Syntax.assert_p =
                                           uu____9985;
                                         FStar_Syntax_Syntax.assume_p =
                                           uu____9986;
                                         FStar_Syntax_Syntax.null_wp =
                                           uu____9987;
                                         FStar_Syntax_Syntax.trivial =
                                           uu____9988;
                                         FStar_Syntax_Syntax.repr =
                                           uu____9989;
                                         FStar_Syntax_Syntax.return_repr =
                                           uu____9999;
                                         FStar_Syntax_Syntax.bind_repr =
                                           uu____10001;
                                         FStar_Syntax_Syntax.actions =
                                           actions1
                                       } in
                                     FStar_Syntax_Syntax.Sig_new_effect
                                       uu____9978 in
                                   {
                                     FStar_Syntax_Syntax.sigel = uu____9977;
                                     FStar_Syntax_Syntax.sigrng =
                                       (d.FStar_Parser_AST.drange);
                                     FStar_Syntax_Syntax.sigquals =
                                       qualifiers;
                                     FStar_Syntax_Syntax.sigmeta =
                                       FStar_Syntax_Syntax.default_sigmeta
                                   }) in
                              let env3 =
                                FStar_ToSyntax_Env.push_sigelt env0 se in
                              let env4 =
                                FStar_ToSyntax_Env.push_doc env3 mname
                                  d.FStar_Parser_AST.doc in
                              let env5 =
                                FStar_All.pipe_right actions_docs
                                  (FStar_List.fold_left
                                     (fun env5  ->
                                        fun uu____10014  ->
                                          match uu____10014 with
                                          | (a,doc1) ->
                                              let env6 =
                                                let uu____10023 =
                                                  FStar_Syntax_Util.action_as_lb
                                                    mname a in
                                                FStar_ToSyntax_Env.push_sigelt
                                                  env5 uu____10023 in
                                              FStar_ToSyntax_Env.push_doc
                                                env6
                                                a.FStar_Syntax_Syntax.action_name
                                                doc1) env4) in
                              let env6 =
                                let uu____10025 =
                                  FStar_All.pipe_right quals
                                    (FStar_List.contains
                                       FStar_Parser_AST.Reflectable) in
                                if uu____10025
                                then
                                  let reflect_lid =
                                    FStar_All.pipe_right
                                      (FStar_Ident.id_of_text "reflect")
                                      (FStar_ToSyntax_Env.qualify monad_env) in
                                  let quals1 =
                                    [FStar_Syntax_Syntax.Assumption;
                                    FStar_Syntax_Syntax.Reflectable mname] in
                                  let refl_decl =
                                    {
                                      FStar_Syntax_Syntax.sigel =
                                        (FStar_Syntax_Syntax.Sig_declare_typ
                                           (reflect_lid, [],
                                             FStar_Syntax_Syntax.tun));
                                      FStar_Syntax_Syntax.sigrng =
                                        (d.FStar_Parser_AST.drange);
                                      FStar_Syntax_Syntax.sigquals = quals1;
                                      FStar_Syntax_Syntax.sigmeta =
                                        FStar_Syntax_Syntax.default_sigmeta
                                    } in
                                  FStar_ToSyntax_Env.push_sigelt env5
                                    refl_decl
                                else env5 in
                              let env7 =
                                FStar_ToSyntax_Env.push_doc env6 mname
                                  d.FStar_Parser_AST.doc in
                              (env7, [se])))
and desugar_redefine_effect:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.decl ->
      (FStar_Ident.lident option ->
         FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier)
        ->
        FStar_Parser_AST.qualifier Prims.list ->
          FStar_Ident.ident ->
            FStar_Parser_AST.binder Prims.list ->
              FStar_Parser_AST.term ->
                (FStar_ToSyntax_Env.env* FStar_Syntax_Syntax.sigelt
                  Prims.list)
  =
  fun env  ->
    fun d  ->
      fun trans_qual1  ->
        fun quals  ->
          fun eff_name  ->
            fun eff_binders  ->
              fun defn  ->
                let env0 = env in
                let env1 = FStar_ToSyntax_Env.enter_monad_scope env eff_name in
                let uu____10050 = desugar_binders env1 eff_binders in
                match uu____10050 with
                | (env2,binders) ->
                    let uu____10061 =
                      let uu____10071 = head_and_args defn in
                      match uu____10071 with
                      | (head1,args) ->
                          let lid =
                            match head1.FStar_Parser_AST.tm with
                            | FStar_Parser_AST.Name l -> l
                            | uu____10096 ->
                                let uu____10097 =
                                  let uu____10098 =
                                    let uu____10101 =
                                      let uu____10102 =
                                        let uu____10103 =
                                          FStar_Parser_AST.term_to_string
                                            head1 in
                                        Prims.strcat uu____10103 " not found" in
                                      Prims.strcat "Effect " uu____10102 in
                                    (uu____10101,
                                      (d.FStar_Parser_AST.drange)) in
                                  FStar_Errors.Error uu____10098 in
                                raise uu____10097 in
                          let ed =
                            FStar_ToSyntax_Env.fail_or env2
                              (FStar_ToSyntax_Env.try_lookup_effect_defn env2)
                              lid in
                          let uu____10105 =
                            match FStar_List.rev args with
                            | (last_arg,uu____10121)::args_rev ->
                                let uu____10128 =
                                  let uu____10129 = unparen last_arg in
                                  uu____10129.FStar_Parser_AST.tm in
                                (match uu____10128 with
                                 | FStar_Parser_AST.Attributes ts ->
                                     (ts, (FStar_List.rev args_rev))
                                 | uu____10144 -> ([], args))
                            | uu____10149 -> ([], args) in
                          (match uu____10105 with
                           | (cattributes,args1) ->
                               let uu____10176 = desugar_args env2 args1 in
                               let uu____10181 =
                                 desugar_attributes env2 cattributes in
                               (lid, ed, uu____10176, uu____10181)) in
                    (match uu____10061 with
                     | (ed_lid,ed,args,cattributes) ->
                         let binders1 =
                           FStar_Syntax_Subst.close_binders binders in
                         let sub1 uu____10215 =
                           match uu____10215 with
                           | (uu____10222,x) ->
                               let uu____10226 =
                                 FStar_Syntax_Subst.open_term
                                   ed.FStar_Syntax_Syntax.binders x in
                               (match uu____10226 with
                                | (edb,x1) ->
                                    (if
                                       (FStar_List.length args) <>
                                         (FStar_List.length edb)
                                     then
                                       raise
                                         (FStar_Errors.Error
                                            ("Unexpected number of arguments to effect constructor",
                                              (defn.FStar_Parser_AST.range)))
                                     else ();
                                     (let s =
                                        FStar_Syntax_Util.subst_of_list edb
                                          args in
                                      let uu____10246 =
                                        let uu____10247 =
                                          FStar_Syntax_Subst.subst s x1 in
                                        FStar_Syntax_Subst.close binders1
                                          uu____10247 in
                                      ([], uu____10246)))) in
                         let mname = FStar_ToSyntax_Env.qualify env0 eff_name in
                         let ed1 =
                           let uu____10251 =
                             let uu____10252 =
                               sub1 ([], (ed.FStar_Syntax_Syntax.signature)) in
                             snd uu____10252 in
                           let uu____10258 =
                             sub1 ed.FStar_Syntax_Syntax.ret_wp in
                           let uu____10259 =
                             sub1 ed.FStar_Syntax_Syntax.bind_wp in
                           let uu____10260 =
                             sub1 ed.FStar_Syntax_Syntax.if_then_else in
                           let uu____10261 =
                             sub1 ed.FStar_Syntax_Syntax.ite_wp in
                           let uu____10262 =
                             sub1 ed.FStar_Syntax_Syntax.stronger in
                           let uu____10263 =
                             sub1 ed.FStar_Syntax_Syntax.close_wp in
                           let uu____10264 =
                             sub1 ed.FStar_Syntax_Syntax.assert_p in
                           let uu____10265 =
                             sub1 ed.FStar_Syntax_Syntax.assume_p in
                           let uu____10266 =
                             sub1 ed.FStar_Syntax_Syntax.null_wp in
                           let uu____10267 =
                             sub1 ed.FStar_Syntax_Syntax.trivial in
                           let uu____10268 =
                             let uu____10269 =
                               sub1 ([], (ed.FStar_Syntax_Syntax.repr)) in
                             snd uu____10269 in
                           let uu____10275 =
                             sub1 ed.FStar_Syntax_Syntax.return_repr in
                           let uu____10276 =
                             sub1 ed.FStar_Syntax_Syntax.bind_repr in
                           let uu____10277 =
                             FStar_List.map
                               (fun action  ->
                                  let uu____10280 =
                                    FStar_ToSyntax_Env.qualify env2
                                      action.FStar_Syntax_Syntax.action_unqualified_name in
                                  let uu____10281 =
                                    let uu____10282 =
                                      sub1
                                        ([],
                                          (action.FStar_Syntax_Syntax.action_defn)) in
                                    snd uu____10282 in
                                  let uu____10288 =
                                    let uu____10289 =
                                      sub1
                                        ([],
                                          (action.FStar_Syntax_Syntax.action_typ)) in
                                    snd uu____10289 in
                                  {
                                    FStar_Syntax_Syntax.action_name =
                                      uu____10280;
                                    FStar_Syntax_Syntax.action_unqualified_name
                                      =
                                      (action.FStar_Syntax_Syntax.action_unqualified_name);
                                    FStar_Syntax_Syntax.action_univs =
                                      (action.FStar_Syntax_Syntax.action_univs);
                                    FStar_Syntax_Syntax.action_params =
                                      (action.FStar_Syntax_Syntax.action_params);
                                    FStar_Syntax_Syntax.action_defn =
                                      uu____10281;
                                    FStar_Syntax_Syntax.action_typ =
                                      uu____10288
                                  }) ed.FStar_Syntax_Syntax.actions in
                           {
                             FStar_Syntax_Syntax.cattributes = cattributes;
                             FStar_Syntax_Syntax.mname = mname;
                             FStar_Syntax_Syntax.univs = [];
                             FStar_Syntax_Syntax.binders = binders1;
                             FStar_Syntax_Syntax.signature = uu____10251;
                             FStar_Syntax_Syntax.ret_wp = uu____10258;
                             FStar_Syntax_Syntax.bind_wp = uu____10259;
                             FStar_Syntax_Syntax.if_then_else = uu____10260;
                             FStar_Syntax_Syntax.ite_wp = uu____10261;
                             FStar_Syntax_Syntax.stronger = uu____10262;
                             FStar_Syntax_Syntax.close_wp = uu____10263;
                             FStar_Syntax_Syntax.assert_p = uu____10264;
                             FStar_Syntax_Syntax.assume_p = uu____10265;
                             FStar_Syntax_Syntax.null_wp = uu____10266;
                             FStar_Syntax_Syntax.trivial = uu____10267;
                             FStar_Syntax_Syntax.repr = uu____10268;
                             FStar_Syntax_Syntax.return_repr = uu____10275;
                             FStar_Syntax_Syntax.bind_repr = uu____10276;
                             FStar_Syntax_Syntax.actions = uu____10277
                           } in
                         let se =
                           let for_free =
                             let uu____10297 =
                               let uu____10298 =
                                 let uu____10302 =
                                   FStar_Syntax_Util.arrow_formals
                                     ed1.FStar_Syntax_Syntax.signature in
                                 fst uu____10302 in
                               FStar_List.length uu____10298 in
                             uu____10297 = (Prims.parse_int "1") in
                           let uu____10320 =
                             let uu____10322 = trans_qual1 (Some mname) in
                             FStar_List.map uu____10322 quals in
                           {
                             FStar_Syntax_Syntax.sigel =
                               (if for_free
                                then
                                  FStar_Syntax_Syntax.Sig_new_effect_for_free
                                    ed1
                                else FStar_Syntax_Syntax.Sig_new_effect ed1);
                             FStar_Syntax_Syntax.sigrng =
                               (d.FStar_Parser_AST.drange);
                             FStar_Syntax_Syntax.sigquals = uu____10320;
                             FStar_Syntax_Syntax.sigmeta =
                               FStar_Syntax_Syntax.default_sigmeta
                           } in
                         let monad_env = env2 in
                         let env3 = FStar_ToSyntax_Env.push_sigelt env0 se in
                         let env4 =
                           FStar_ToSyntax_Env.push_doc env3 ed_lid
                             d.FStar_Parser_AST.doc in
                         let env5 =
                           FStar_All.pipe_right
                             ed1.FStar_Syntax_Syntax.actions
                             (FStar_List.fold_left
                                (fun env5  ->
                                   fun a  ->
                                     let doc1 =
                                       FStar_ToSyntax_Env.try_lookup_doc env5
                                         a.FStar_Syntax_Syntax.action_name in
                                     let env6 =
                                       let uu____10336 =
                                         FStar_Syntax_Util.action_as_lb mname
                                           a in
                                       FStar_ToSyntax_Env.push_sigelt env5
                                         uu____10336 in
                                     FStar_ToSyntax_Env.push_doc env6
                                       a.FStar_Syntax_Syntax.action_name doc1)
                                env4) in
                         let env6 =
                           let uu____10338 =
                             FStar_All.pipe_right quals
                               (FStar_List.contains
                                  FStar_Parser_AST.Reflectable) in
                           if uu____10338
                           then
                             let reflect_lid =
                               FStar_All.pipe_right
                                 (FStar_Ident.id_of_text "reflect")
                                 (FStar_ToSyntax_Env.qualify monad_env) in
                             let quals1 =
                               [FStar_Syntax_Syntax.Assumption;
                               FStar_Syntax_Syntax.Reflectable mname] in
                             let refl_decl =
                               {
                                 FStar_Syntax_Syntax.sigel =
                                   (FStar_Syntax_Syntax.Sig_declare_typ
                                      (reflect_lid, [],
                                        FStar_Syntax_Syntax.tun));
                                 FStar_Syntax_Syntax.sigrng =
                                   (d.FStar_Parser_AST.drange);
                                 FStar_Syntax_Syntax.sigquals = quals1;
                                 FStar_Syntax_Syntax.sigmeta =
                                   FStar_Syntax_Syntax.default_sigmeta
                               } in
                             FStar_ToSyntax_Env.push_sigelt env5 refl_decl
                           else env5 in
                         let env7 =
                           FStar_ToSyntax_Env.push_doc env6 mname
                             d.FStar_Parser_AST.doc in
                         (env7, [se]))
and desugar_decl:
  env_t -> FStar_Parser_AST.decl -> (env_t* FStar_Syntax_Syntax.sigelts) =
  fun env  ->
    fun d  ->
      let trans_qual1 = trans_qual d.FStar_Parser_AST.drange in
      match d.FStar_Parser_AST.d with
      | FStar_Parser_AST.Pragma p ->
          let se =
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_pragma (trans_pragma p));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = [];
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta
            } in
          (if p = FStar_Parser_AST.LightOff
           then FStar_Options.set_ml_ish ()
           else ();
           (env, [se]))
      | FStar_Parser_AST.Fsdoc uu____10365 -> (env, [])
      | FStar_Parser_AST.TopLevelModule id -> (env, [])
      | FStar_Parser_AST.Open lid ->
          let env1 = FStar_ToSyntax_Env.push_namespace env lid in (env1, [])
      | FStar_Parser_AST.Include lid ->
          let env1 = FStar_ToSyntax_Env.push_include env lid in (env1, [])
      | FStar_Parser_AST.ModuleAbbrev (x,l) ->
          let uu____10377 = FStar_ToSyntax_Env.push_module_abbrev env x l in
          (uu____10377, [])
      | FStar_Parser_AST.Tycon (is_effect,tcs) ->
          let quals =
            if is_effect
            then FStar_Parser_AST.Effect_qual :: (d.FStar_Parser_AST.quals)
            else d.FStar_Parser_AST.quals in
          let tcs1 =
            FStar_List.map
              (fun uu____10398  ->
                 match uu____10398 with | (x,uu____10403) -> x) tcs in
          let uu____10406 = FStar_List.map (trans_qual1 None) quals in
          desugar_tycon env d uu____10406 tcs1
      | FStar_Parser_AST.TopLevelLet (isrec,lets) ->
          let quals = d.FStar_Parser_AST.quals in
          let attrs = d.FStar_Parser_AST.attrs in
          let attrs1 = FStar_List.map (desugar_term env) attrs in
          let expand_toplevel_pattern =
            (isrec = FStar_Parser_AST.NoLetQualifier) &&
              (match lets with
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatOp uu____10421;
                    FStar_Parser_AST.prange = uu____10422;_},uu____10423)::[]
                   -> false
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                      uu____10428;
                    FStar_Parser_AST.prange = uu____10429;_},uu____10430)::[]
                   -> false
               | ({
                    FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed
                      ({
                         FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                           uu____10438;
                         FStar_Parser_AST.prange = uu____10439;_},uu____10440);
                    FStar_Parser_AST.prange = uu____10441;_},uu____10442)::[]
                   -> false
               | (p,uu____10451)::[] ->
                   let uu____10456 = is_app_pattern p in
                   Prims.op_Negation uu____10456
               | uu____10457 -> false) in
          if Prims.op_Negation expand_toplevel_pattern
          then
            let as_inner_let =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Let
                   (isrec, lets,
                     (FStar_Parser_AST.mk_term
                        (FStar_Parser_AST.Const FStar_Const.Const_unit)
                        d.FStar_Parser_AST.drange FStar_Parser_AST.Expr)))
                d.FStar_Parser_AST.drange FStar_Parser_AST.Expr in
            let ds_lets = desugar_term_maybe_top true env as_inner_let in
            let uu____10468 =
              let uu____10469 =
                FStar_All.pipe_left FStar_Syntax_Subst.compress ds_lets in
              uu____10469.FStar_Syntax_Syntax.n in
            (match uu____10468 with
             | FStar_Syntax_Syntax.Tm_let (lbs,uu____10475) ->
                 let fvs =
                   FStar_All.pipe_right (snd lbs)
                     (FStar_List.map
                        (fun lb  ->
                           FStar_Util.right lb.FStar_Syntax_Syntax.lbname)) in
                 let quals1 =
                   match quals with
                   | uu____10495::uu____10496 ->
                       FStar_List.map (trans_qual1 None) quals
                   | uu____10498 ->
                       FStar_All.pipe_right (snd lbs)
                         (FStar_List.collect
                            (fun uu___221_10502  ->
                               match uu___221_10502 with
                               | {
                                   FStar_Syntax_Syntax.lbname =
                                     FStar_Util.Inl uu____10504;
                                   FStar_Syntax_Syntax.lbunivs = uu____10505;
                                   FStar_Syntax_Syntax.lbtyp = uu____10506;
                                   FStar_Syntax_Syntax.lbeff = uu____10507;
                                   FStar_Syntax_Syntax.lbdef = uu____10508;_}
                                   -> []
                               | {
                                   FStar_Syntax_Syntax.lbname =
                                     FStar_Util.Inr fv;
                                   FStar_Syntax_Syntax.lbunivs = uu____10515;
                                   FStar_Syntax_Syntax.lbtyp = uu____10516;
                                   FStar_Syntax_Syntax.lbeff = uu____10517;
                                   FStar_Syntax_Syntax.lbdef = uu____10518;_}
                                   ->
                                   FStar_ToSyntax_Env.lookup_letbinding_quals
                                     env
                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)) in
                 let quals2 =
                   let uu____10530 =
                     FStar_All.pipe_right lets
                       (FStar_Util.for_some
                          (fun uu____10536  ->
                             match uu____10536 with
                             | (uu____10539,t) ->
                                 t.FStar_Parser_AST.level =
                                   FStar_Parser_AST.Formula)) in
                   if uu____10530
                   then FStar_Syntax_Syntax.Logic :: quals1
                   else quals1 in
                 let lbs1 =
                   let uu____10547 =
                     FStar_All.pipe_right quals2
                       (FStar_List.contains FStar_Syntax_Syntax.Abstract) in
                   if uu____10547
                   then
                     let uu____10552 =
                       FStar_All.pipe_right (snd lbs)
                         (FStar_List.map
                            (fun lb  ->
                               let fv =
                                 FStar_Util.right
                                   lb.FStar_Syntax_Syntax.lbname in
                               let uu___234_10559 = lb in
                               {
                                 FStar_Syntax_Syntax.lbname =
                                   (FStar_Util.Inr
                                      (let uu___235_10560 = fv in
                                       {
                                         FStar_Syntax_Syntax.fv_name =
                                           (uu___235_10560.FStar_Syntax_Syntax.fv_name);
                                         FStar_Syntax_Syntax.fv_delta =
                                           (FStar_Syntax_Syntax.Delta_abstract
                                              (fv.FStar_Syntax_Syntax.fv_delta));
                                         FStar_Syntax_Syntax.fv_qual =
                                           (uu___235_10560.FStar_Syntax_Syntax.fv_qual)
                                       }));
                                 FStar_Syntax_Syntax.lbunivs =
                                   (uu___234_10559.FStar_Syntax_Syntax.lbunivs);
                                 FStar_Syntax_Syntax.lbtyp =
                                   (uu___234_10559.FStar_Syntax_Syntax.lbtyp);
                                 FStar_Syntax_Syntax.lbeff =
                                   (uu___234_10559.FStar_Syntax_Syntax.lbeff);
                                 FStar_Syntax_Syntax.lbdef =
                                   (uu___234_10559.FStar_Syntax_Syntax.lbdef)
                               })) in
                     ((fst lbs), uu____10552)
                   else lbs in
                 let names =
                   FStar_All.pipe_right fvs
                     (FStar_List.map
                        (fun fv  ->
                           (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)) in
                 let s =
                   {
                     FStar_Syntax_Syntax.sigel =
                       (FStar_Syntax_Syntax.Sig_let (lbs1, names, attrs1));
                     FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                     FStar_Syntax_Syntax.sigquals = quals2;
                     FStar_Syntax_Syntax.sigmeta =
                       FStar_Syntax_Syntax.default_sigmeta
                   } in
                 let env1 = FStar_ToSyntax_Env.push_sigelt env s in
                 let env2 =
                   FStar_List.fold_left
                     (fun env2  ->
                        fun id  ->
                          FStar_ToSyntax_Env.push_doc env2 id
                            d.FStar_Parser_AST.doc) env1 names in
                 (env2, [s])
             | uu____10587 ->
                 failwith "Desugaring a let did not produce a let")
          else
            (let uu____10591 =
               match lets with
               | (pat,body)::[] -> (pat, body)
               | uu____10602 ->
                   failwith
                     "expand_toplevel_pattern should only allow single definition lets" in
             match uu____10591 with
             | (pat,body) ->
                 let fresh_toplevel_name =
                   FStar_Ident.gen FStar_Range.dummyRange in
                 let fresh_pat =
                   let var_pat =
                     FStar_Parser_AST.mk_pattern
                       (FStar_Parser_AST.PatVar (fresh_toplevel_name, None))
                       FStar_Range.dummyRange in
                   match pat.FStar_Parser_AST.pat with
                   | FStar_Parser_AST.PatAscribed (pat1,ty) ->
                       let uu___236_10618 = pat1 in
                       {
                         FStar_Parser_AST.pat =
                           (FStar_Parser_AST.PatAscribed (var_pat, ty));
                         FStar_Parser_AST.prange =
                           (uu___236_10618.FStar_Parser_AST.prange)
                       }
                   | uu____10619 -> var_pat in
                 let main_let =
                   desugar_decl env
                     (let uu___237_10623 = d in
                      {
                        FStar_Parser_AST.d =
                          (FStar_Parser_AST.TopLevelLet
                             (isrec, [(fresh_pat, body)]));
                        FStar_Parser_AST.drange =
                          (uu___237_10623.FStar_Parser_AST.drange);
                        FStar_Parser_AST.doc =
                          (uu___237_10623.FStar_Parser_AST.doc);
                        FStar_Parser_AST.quals = (FStar_Parser_AST.Private ::
                          (d.FStar_Parser_AST.quals));
                        FStar_Parser_AST.attrs =
                          (uu___237_10623.FStar_Parser_AST.attrs)
                      }) in
                 let build_projection uu____10642 id =
                   match uu____10642 with
                   | (env1,ses) ->
                       let main =
                         let uu____10655 =
                           let uu____10656 =
                             FStar_Ident.lid_of_ids [fresh_toplevel_name] in
                           FStar_Parser_AST.Var uu____10656 in
                         FStar_Parser_AST.mk_term uu____10655
                           FStar_Range.dummyRange FStar_Parser_AST.Expr in
                       let lid = FStar_Ident.lid_of_ids [id] in
                       let projectee =
                         FStar_Parser_AST.mk_term (FStar_Parser_AST.Var lid)
                           FStar_Range.dummyRange FStar_Parser_AST.Expr in
                       let body1 =
                         FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Match
                              (main, [(pat, None, projectee)]))
                           FStar_Range.dummyRange FStar_Parser_AST.Expr in
                       let bv_pat =
                         FStar_Parser_AST.mk_pattern
                           (FStar_Parser_AST.PatVar (id, None))
                           FStar_Range.dummyRange in
                       let id_decl =
                         FStar_Parser_AST.mk_decl
                           (FStar_Parser_AST.TopLevelLet
                              (FStar_Parser_AST.NoLetQualifier,
                                [(bv_pat, body1)])) FStar_Range.dummyRange [] in
                       let uu____10684 = desugar_decl env1 id_decl in
                       (match uu____10684 with
                        | (env2,ses') -> (env2, (FStar_List.append ses ses'))) in
                 let bvs =
                   let uu____10695 = gather_pattern_bound_vars pat in
                   FStar_All.pipe_right uu____10695 FStar_Util.set_elements in
                 FStar_List.fold_left build_projection main_let bvs)
      | FStar_Parser_AST.Main t ->
          let e = desugar_term env t in
          let se =
            {
              FStar_Syntax_Syntax.sigel = (FStar_Syntax_Syntax.Sig_main e);
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = [];
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta
            } in
          (env, [se])
      | FStar_Parser_AST.Assume (id,t) ->
          let f = desugar_formula env t in
          let lid = FStar_ToSyntax_Env.qualify env id in
          let env1 =
            FStar_ToSyntax_Env.push_doc env lid d.FStar_Parser_AST.doc in
          (env1,
            [{
               FStar_Syntax_Syntax.sigel =
                 (FStar_Syntax_Syntax.Sig_assume (lid, f));
               FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
               FStar_Syntax_Syntax.sigquals =
                 [FStar_Syntax_Syntax.Assumption];
               FStar_Syntax_Syntax.sigmeta =
                 FStar_Syntax_Syntax.default_sigmeta
             }])
      | FStar_Parser_AST.Val (id,t) ->
          let quals = d.FStar_Parser_AST.quals in
          let t1 =
            let uu____10716 = close_fun env t in desugar_term env uu____10716 in
          let quals1 =
            let uu____10719 =
              (FStar_ToSyntax_Env.iface env) &&
                (FStar_ToSyntax_Env.admitted_iface env) in
            if uu____10719
            then FStar_Parser_AST.Assumption :: quals
            else quals in
          let lid = FStar_ToSyntax_Env.qualify env id in
          let se =
            let uu____10724 = FStar_List.map (trans_qual1 None) quals1 in
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_declare_typ (lid, [], t1));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = uu____10724;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta
            } in
          let env1 = FStar_ToSyntax_Env.push_sigelt env se in
          let env2 =
            FStar_ToSyntax_Env.push_doc env1 lid d.FStar_Parser_AST.doc in
          (env2, [se])
      | FStar_Parser_AST.Exception (id,None ) ->
          let uu____10732 =
            FStar_ToSyntax_Env.fail_or env
              (FStar_ToSyntax_Env.try_lookup_lid env)
              FStar_Syntax_Const.exn_lid in
          (match uu____10732 with
           | (t,uu____10740) ->
               let l = FStar_ToSyntax_Env.qualify env id in
               let qual1 = [FStar_Syntax_Syntax.ExceptionConstructor] in
               let se =
                 {
                   FStar_Syntax_Syntax.sigel =
                     (FStar_Syntax_Syntax.Sig_datacon
                        (l, [], t, FStar_Syntax_Const.exn_lid,
                          (Prims.parse_int "0"),
                          [FStar_Syntax_Const.exn_lid]));
                   FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                   FStar_Syntax_Syntax.sigquals = qual1;
                   FStar_Syntax_Syntax.sigmeta =
                     FStar_Syntax_Syntax.default_sigmeta
                 } in
               let se' =
                 {
                   FStar_Syntax_Syntax.sigel =
                     (FStar_Syntax_Syntax.Sig_bundle ([se], [l]));
                   FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                   FStar_Syntax_Syntax.sigquals = qual1;
                   FStar_Syntax_Syntax.sigmeta =
                     FStar_Syntax_Syntax.default_sigmeta
                 } in
               let env1 = FStar_ToSyntax_Env.push_sigelt env se' in
               let env2 =
                 FStar_ToSyntax_Env.push_doc env1 l d.FStar_Parser_AST.doc in
               let data_ops = mk_data_projector_names [] env2 ([], se) in
               let discs =
                 mk_data_discriminators [] env2 FStar_Syntax_Const.exn_lid []
                   FStar_Syntax_Syntax.tun [l] in
               let env3 =
                 FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env2
                   (FStar_List.append discs data_ops) in
               (env3, (FStar_List.append (se' :: discs) data_ops)))
      | FStar_Parser_AST.Exception (id,Some term) ->
          let t = desugar_term env term in
          let t1 =
            let uu____10768 =
              let uu____10772 = FStar_Syntax_Syntax.null_binder t in
              [uu____10772] in
            let uu____10773 =
              let uu____10776 =
                let uu____10777 =
                  FStar_ToSyntax_Env.fail_or env
                    (FStar_ToSyntax_Env.try_lookup_lid env)
                    FStar_Syntax_Const.exn_lid in
                fst uu____10777 in
              FStar_All.pipe_left FStar_Syntax_Syntax.mk_Total uu____10776 in
            FStar_Syntax_Util.arrow uu____10768 uu____10773 in
          let l = FStar_ToSyntax_Env.qualify env id in
          let qual1 = [FStar_Syntax_Syntax.ExceptionConstructor] in
          let se =
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_datacon
                   (l, [], t1, FStar_Syntax_Const.exn_lid,
                     (Prims.parse_int "0"), [FStar_Syntax_Const.exn_lid]));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = qual1;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta
            } in
          let se' =
            {
              FStar_Syntax_Syntax.sigel =
                (FStar_Syntax_Syntax.Sig_bundle ([se], [l]));
              FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
              FStar_Syntax_Syntax.sigquals = qual1;
              FStar_Syntax_Syntax.sigmeta =
                FStar_Syntax_Syntax.default_sigmeta
            } in
          let env1 = FStar_ToSyntax_Env.push_sigelt env se' in
          let env2 =
            FStar_ToSyntax_Env.push_doc env1 l d.FStar_Parser_AST.doc in
          let data_ops = mk_data_projector_names [] env2 ([], se) in
          let discs =
            mk_data_discriminators [] env2 FStar_Syntax_Const.exn_lid []
              FStar_Syntax_Syntax.tun [l] in
          let env3 =
            FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env2
              (FStar_List.append discs data_ops) in
          (env3, (FStar_List.append (se' :: discs) data_ops))
      | FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect
          (eff_name,eff_binders,defn)) ->
          let quals = d.FStar_Parser_AST.quals in
          desugar_redefine_effect env d trans_qual1 quals eff_name
            eff_binders defn
      | FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect
          (eff_name,eff_binders,eff_typ,eff_decls)) ->
          let quals = d.FStar_Parser_AST.quals in
          desugar_effect env d quals eff_name eff_binders eff_typ eff_decls
      | FStar_Parser_AST.SubEffect l ->
          let lookup l1 =
            let uu____10824 =
              FStar_ToSyntax_Env.try_lookup_effect_name env l1 in
            match uu____10824 with
            | None  ->
                let uu____10826 =
                  let uu____10827 =
                    let uu____10830 =
                      let uu____10831 =
                        let uu____10832 = FStar_Syntax_Print.lid_to_string l1 in
                        Prims.strcat uu____10832 " not found" in
                      Prims.strcat "Effect name " uu____10831 in
                    (uu____10830, (d.FStar_Parser_AST.drange)) in
                  FStar_Errors.Error uu____10827 in
                raise uu____10826
            | Some l2 -> l2 in
          let src = lookup l.FStar_Parser_AST.msource in
          let dst = lookup l.FStar_Parser_AST.mdest in
          let uu____10836 =
            match l.FStar_Parser_AST.lift_op with
            | FStar_Parser_AST.NonReifiableLift t ->
                let uu____10858 =
                  let uu____10863 =
                    let uu____10867 = desugar_term env t in ([], uu____10867) in
                  Some uu____10863 in
                (uu____10858, None)
            | FStar_Parser_AST.ReifiableLift (wp,t) ->
                let uu____10885 =
                  let uu____10890 =
                    let uu____10894 = desugar_term env wp in
                    ([], uu____10894) in
                  Some uu____10890 in
                let uu____10899 =
                  let uu____10904 =
                    let uu____10908 = desugar_term env t in ([], uu____10908) in
                  Some uu____10904 in
                (uu____10885, uu____10899)
            | FStar_Parser_AST.LiftForFree t ->
                let uu____10922 =
                  let uu____10927 =
                    let uu____10931 = desugar_term env t in ([], uu____10931) in
                  Some uu____10927 in
                (None, uu____10922) in
          (match uu____10836 with
           | (lift_wp,lift) ->
               let se =
                 {
                   FStar_Syntax_Syntax.sigel =
                     (FStar_Syntax_Syntax.Sig_sub_effect
                        {
                          FStar_Syntax_Syntax.source = src;
                          FStar_Syntax_Syntax.target = dst;
                          FStar_Syntax_Syntax.lift_wp = lift_wp;
                          FStar_Syntax_Syntax.lift = lift
                        });
                   FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                   FStar_Syntax_Syntax.sigquals = [];
                   FStar_Syntax_Syntax.sigmeta =
                     FStar_Syntax_Syntax.default_sigmeta
                 } in
               (env, [se]))
let desugar_decls:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.decl Prims.list ->
      (env_t* FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun env  ->
    fun decls  ->
      FStar_List.fold_left
        (fun uu____10982  ->
           fun d  ->
             match uu____10982 with
             | (env1,sigelts) ->
                 let uu____10994 = desugar_decl env1 d in
                 (match uu____10994 with
                  | (env2,se) -> (env2, (FStar_List.append sigelts se))))
        (env, []) decls
let open_prims_all:
  (FStar_Parser_AST.decoration Prims.list -> FStar_Parser_AST.decl)
    Prims.list
  =
  [FStar_Parser_AST.mk_decl
     (FStar_Parser_AST.Open FStar_Syntax_Const.prims_lid)
     FStar_Range.dummyRange;
  FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open FStar_Syntax_Const.all_lid)
    FStar_Range.dummyRange]
let desugar_modul_common:
  FStar_Syntax_Syntax.modul option ->
    FStar_ToSyntax_Env.env ->
      FStar_Parser_AST.modul ->
        (env_t* FStar_Syntax_Syntax.modul* Prims.bool)
  =
  fun curmod  ->
    fun env  ->
      fun m  ->
        let env1 =
          match (curmod, m) with
          | (None ,uu____11036) -> env
          | (Some
             { FStar_Syntax_Syntax.name = prev_lid;
               FStar_Syntax_Syntax.declarations = uu____11039;
               FStar_Syntax_Syntax.exports = uu____11040;
               FStar_Syntax_Syntax.is_interface = uu____11041;_},FStar_Parser_AST.Module
             (current_lid,uu____11043)) when
              (FStar_Ident.lid_equals prev_lid current_lid) &&
                (FStar_Options.interactive ())
              -> env
          | (Some prev_mod,uu____11048) ->
              FStar_ToSyntax_Env.finish_module_or_interface env prev_mod in
        let uu____11050 =
          match m with
          | FStar_Parser_AST.Interface (mname,decls,admitted) ->
              let uu____11070 =
                FStar_ToSyntax_Env.prepare_module_or_interface true admitted
                  env1 mname in
              (uu____11070, mname, decls, true)
          | FStar_Parser_AST.Module (mname,decls) ->
              let uu____11080 =
                FStar_ToSyntax_Env.prepare_module_or_interface false false
                  env1 mname in
              (uu____11080, mname, decls, false) in
        match uu____11050 with
        | ((env2,pop_when_done),mname,decls,intf) ->
            let uu____11098 = desugar_decls env2 decls in
            (match uu____11098 with
             | (env3,sigelts) ->
                 let modul =
                   {
                     FStar_Syntax_Syntax.name = mname;
                     FStar_Syntax_Syntax.declarations = sigelts;
                     FStar_Syntax_Syntax.exports = [];
                     FStar_Syntax_Syntax.is_interface = intf
                   } in
                 (env3, modul, pop_when_done))
let as_interface: FStar_Parser_AST.modul -> FStar_Parser_AST.modul =
  fun m  ->
    match m with
    | FStar_Parser_AST.Module (mname,decls) ->
        FStar_Parser_AST.Interface (mname, decls, true)
    | i -> i
let desugar_partial_modul:
  FStar_Syntax_Syntax.modul option ->
    env_t -> FStar_Parser_AST.modul -> (env_t* FStar_Syntax_Syntax.modul)
  =
  fun curmod  ->
    fun env  ->
      fun m  ->
        let m1 =
          let uu____11132 =
            (FStar_Options.interactive ()) &&
              (let uu____11133 =
                 let uu____11134 =
                   let uu____11135 = FStar_Options.file_list () in
                   FStar_List.hd uu____11135 in
                 FStar_Util.get_file_extension uu____11134 in
               uu____11133 = "fsti") in
          if uu____11132 then as_interface m else m in
        let uu____11138 = desugar_modul_common curmod env m1 in
        match uu____11138 with
        | (x,y,pop_when_done) ->
            (if pop_when_done
             then (let uu____11148 = FStar_ToSyntax_Env.pop () in ())
             else ();
             (x, y))
let desugar_modul:
  FStar_ToSyntax_Env.env ->
    FStar_Parser_AST.modul -> (env_t* FStar_Syntax_Syntax.modul)
  =
  fun env  ->
    fun m  ->
      let uu____11160 = desugar_modul_common None env m in
      match uu____11160 with
      | (env1,modul,pop_when_done) ->
          let env2 = FStar_ToSyntax_Env.finish_module_or_interface env1 modul in
          ((let uu____11171 =
              FStar_Options.dump_module
                (modul.FStar_Syntax_Syntax.name).FStar_Ident.str in
            if uu____11171
            then
              let uu____11172 = FStar_Syntax_Print.modul_to_string modul in
              FStar_Util.print1 "%s\n" uu____11172
            else ());
           (let uu____11174 =
              if pop_when_done
              then
                FStar_ToSyntax_Env.export_interface
                  modul.FStar_Syntax_Syntax.name env2
              else env2 in
            (uu____11174, modul)))
let desugar_file:
  env_t ->
    FStar_Parser_AST.file ->
      (FStar_ToSyntax_Env.env* FStar_Syntax_Syntax.modul Prims.list)
  =
  fun env  ->
    fun f  ->
      let uu____11185 =
        FStar_List.fold_left
          (fun uu____11192  ->
             fun m  ->
               match uu____11192 with
               | (env1,mods) ->
                   let uu____11204 = desugar_modul env1 m in
                   (match uu____11204 with
                    | (env2,m1) -> (env2, (m1 :: mods)))) (env, []) f in
      match uu____11185 with | (env1,mods) -> (env1, (FStar_List.rev mods))
let add_modul_to_env:
  FStar_Syntax_Syntax.modul ->
    FStar_ToSyntax_Env.env -> FStar_ToSyntax_Env.env
  =
  fun m  ->
    fun en  ->
      let uu____11228 =
        FStar_ToSyntax_Env.prepare_module_or_interface false false en
          m.FStar_Syntax_Syntax.name in
      match uu____11228 with
      | (en1,pop_when_done) ->
          let en2 =
            let uu____11234 =
              FStar_ToSyntax_Env.set_current_module en1
                m.FStar_Syntax_Syntax.name in
            FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt uu____11234
              m.FStar_Syntax_Syntax.exports in
          let env = FStar_ToSyntax_Env.finish_module_or_interface en2 m in
          if pop_when_done
          then
            FStar_ToSyntax_Env.export_interface m.FStar_Syntax_Syntax.name
              env
          else env