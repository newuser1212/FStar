open Prims
let (id_eq_lid : FStar_Ident.ident -> FStar_Ident.lident -> Prims.bool) =
  fun i  ->
    fun l  -> i.FStar_Ident.idText = (l.FStar_Ident.ident).FStar_Ident.idText
  
let (is_val : FStar_Ident.ident -> FStar_Parser_AST.decl -> Prims.bool) =
  fun x  ->
    fun d  ->
      match d.FStar_Parser_AST.d with
      | FStar_Parser_AST.Val (y,uu____54992) ->
          x.FStar_Ident.idText = y.FStar_Ident.idText
      | uu____54994 -> false
  
let (is_type : FStar_Ident.ident -> FStar_Parser_AST.decl -> Prims.bool) =
  fun x  ->
    fun d  ->
      match d.FStar_Parser_AST.d with
      | FStar_Parser_AST.Tycon (uu____55009,uu____55010,tys) ->
          FStar_All.pipe_right tys
            (FStar_Util.for_some
               (fun uu____55050  ->
                  match uu____55050 with
                  | (t,uu____55059) ->
                      (FStar_Parser_AST.id_of_tycon t) = x.FStar_Ident.idText))
      | uu____55065 -> false
  
let (definition_lids :
  FStar_Parser_AST.decl -> FStar_Ident.lident Prims.list) =
  fun d  ->
    match d.FStar_Parser_AST.d with
    | FStar_Parser_AST.TopLevelLet (uu____55077,defs) ->
        FStar_Parser_AST.lids_of_let defs
    | FStar_Parser_AST.Tycon (uu____55091,uu____55092,tys) ->
        FStar_All.pipe_right tys
          (FStar_List.collect
             (fun uu___429_55137  ->
                match uu___429_55137 with
                | (FStar_Parser_AST.TyconAbbrev
                   (id1,uu____55147,uu____55148,uu____55149),uu____55150) ->
                    let uu____55163 = FStar_Ident.lid_of_ids [id1]  in
                    [uu____55163]
                | (FStar_Parser_AST.TyconRecord
                   (id1,uu____55165,uu____55166,uu____55167),uu____55168) ->
                    let uu____55201 = FStar_Ident.lid_of_ids [id1]  in
                    [uu____55201]
                | (FStar_Parser_AST.TyconVariant
                   (id1,uu____55203,uu____55204,uu____55205),uu____55206) ->
                    let uu____55249 = FStar_Ident.lid_of_ids [id1]  in
                    [uu____55249]
                | uu____55250 -> []))
    | uu____55257 -> []
  
let (is_definition_of :
  FStar_Ident.ident -> FStar_Parser_AST.decl -> Prims.bool) =
  fun x  ->
    fun d  ->
      let uu____55270 = definition_lids d  in
      FStar_Util.for_some (id_eq_lid x) uu____55270
  
let rec (prefix_with_iface_decls :
  FStar_Parser_AST.decl Prims.list ->
    FStar_Parser_AST.decl ->
      (FStar_Parser_AST.decl Prims.list * FStar_Parser_AST.decl Prims.list))
  =
  fun iface1  ->
    fun impl  ->
      let qualify_kremlin_private impl1 =
        let krem_private =
          FStar_Parser_AST.mk_term
            (FStar_Parser_AST.Const
               (FStar_Const.Const_string
                  ("KremlinPrivate", (impl1.FStar_Parser_AST.drange))))
            impl1.FStar_Parser_AST.drange FStar_Parser_AST.Expr
           in
        let uu___495_55313 = impl1  in
        {
          FStar_Parser_AST.d = (uu___495_55313.FStar_Parser_AST.d);
          FStar_Parser_AST.drange = (uu___495_55313.FStar_Parser_AST.drange);
          FStar_Parser_AST.doc = (uu___495_55313.FStar_Parser_AST.doc);
          FStar_Parser_AST.quals = (uu___495_55313.FStar_Parser_AST.quals);
          FStar_Parser_AST.attrs = (krem_private ::
            (impl1.FStar_Parser_AST.attrs))
        }  in
      match iface1 with
      | [] -> ([], [qualify_kremlin_private impl])
      | iface_hd::iface_tl ->
          (match iface_hd.FStar_Parser_AST.d with
           | FStar_Parser_AST.Tycon (uu____55338,uu____55339,tys) when
               FStar_All.pipe_right tys
                 (FStar_Util.for_some
                    (fun uu___430_55379  ->
                       match uu___430_55379 with
                       | (FStar_Parser_AST.TyconAbstract
                          uu____55387,uu____55388) -> true
                       | uu____55404 -> false))
               ->
               FStar_Errors.raise_error
                 (FStar_Errors.Fatal_AbstractTypeDeclarationInInterface,
                   "Interface contains an abstract 'type' declaration; use 'val' instead")
                 impl.FStar_Parser_AST.drange
           | FStar_Parser_AST.Val (x,t) ->
               let def_ids = definition_lids impl  in
               let defines_x = FStar_Util.for_some (id_eq_lid x) def_ids  in
               if Prims.op_Negation defines_x
               then
                 let uu____55438 =
                   FStar_All.pipe_right def_ids
                     (FStar_Util.for_some
                        (fun y  ->
                           FStar_All.pipe_right iface_tl
                             (FStar_Util.for_some
                                (is_val y.FStar_Ident.ident))))
                    in
                 (if uu____55438
                  then
                    let uu____55457 =
                      let uu____55463 =
                        let uu____55465 =
                          let uu____55467 =
                            FStar_All.pipe_right def_ids
                              (FStar_List.map FStar_Ident.string_of_lid)
                             in
                          FStar_All.pipe_right uu____55467
                            (FStar_String.concat ", ")
                           in
                        FStar_Util.format2
                          "Expected the definition of %s to precede %s"
                          x.FStar_Ident.idText uu____55465
                         in
                      (FStar_Errors.Fatal_WrongDefinitionOrder, uu____55463)
                       in
                    FStar_Errors.raise_error uu____55457
                      impl.FStar_Parser_AST.drange
                  else (iface1, [qualify_kremlin_private impl]))
               else
                 (let mutually_defined_with_x =
                    FStar_All.pipe_right def_ids
                      (FStar_List.filter
                         (fun y  -> Prims.op_Negation (id_eq_lid x y)))
                     in
                  let rec aux mutuals iface2 =
                    match (mutuals, iface2) with
                    | ([],uu____55548) -> ([], iface2)
                    | (uu____55559::uu____55560,[]) -> ([], [])
                    | (y::ys,iface_hd1::iface_tl1) ->
                        if is_val y.FStar_Ident.ident iface_hd1
                        then
                          let uu____55592 = aux ys iface_tl1  in
                          (match uu____55592 with
                           | (val_ys,iface3) ->
                               ((iface_hd1 :: val_ys), iface3))
                        else
                          (let uu____55625 =
                             let uu____55627 =
                               FStar_List.tryFind
                                 (is_val y.FStar_Ident.ident) iface_tl1
                                in
                             FStar_All.pipe_left FStar_Option.isSome
                               uu____55627
                              in
                           if uu____55625
                           then
                             let uu____55642 =
                               let uu____55648 =
                                 let uu____55650 =
                                   FStar_Parser_AST.decl_to_string iface_hd1
                                    in
                                 let uu____55652 =
                                   FStar_Ident.string_of_lid y  in
                                 FStar_Util.format2
                                   "%s is out of order with the definition of %s"
                                   uu____55650 uu____55652
                                  in
                               (FStar_Errors.Fatal_WrongDefinitionOrder,
                                 uu____55648)
                                in
                             FStar_Errors.raise_error uu____55642
                               iface_hd1.FStar_Parser_AST.drange
                           else aux ys iface2)
                     in
                  let uu____55666 = aux mutually_defined_with_x iface_tl  in
                  match uu____55666 with
                  | (take_iface,rest_iface) ->
                      (rest_iface,
                        (FStar_List.append (iface_hd :: take_iface) [impl])))
           | uu____55697 ->
               let uu____55698 = prefix_with_iface_decls iface_tl impl  in
               (match uu____55698 with
                | (iface2,ds) -> (iface2, (iface_hd :: ds))))
  
let (check_initial_interface :
  FStar_Parser_AST.decl Prims.list -> FStar_Parser_AST.decl Prims.list) =
  fun iface1  ->
    let rec aux iface2 =
      match iface2 with
      | [] -> ()
      | hd1::tl1 ->
          (match hd1.FStar_Parser_AST.d with
           | FStar_Parser_AST.Tycon (uu____55755,uu____55756,tys) when
               FStar_All.pipe_right tys
                 (FStar_Util.for_some
                    (fun uu___431_55796  ->
                       match uu___431_55796 with
                       | (FStar_Parser_AST.TyconAbstract
                          uu____55804,uu____55805) -> true
                       | uu____55821 -> false))
               ->
               FStar_Errors.raise_error
                 (FStar_Errors.Fatal_AbstractTypeDeclarationInInterface,
                   "Interface contains an abstract 'type' declaration; use 'val' instead")
                 hd1.FStar_Parser_AST.drange
           | FStar_Parser_AST.Val (x,t) ->
               let uu____55833 = FStar_Util.for_some (is_definition_of x) tl1
                  in
               if uu____55833
               then
                 let uu____55836 =
                   let uu____55842 =
                     FStar_Util.format2
                       "'val %s' and 'let %s' cannot both be provided in an interface"
                       x.FStar_Ident.idText x.FStar_Ident.idText
                      in
                   (FStar_Errors.Fatal_BothValAndLetInInterface, uu____55842)
                    in
                 FStar_Errors.raise_error uu____55836
                   hd1.FStar_Parser_AST.drange
               else
                 (let uu____55848 =
                    FStar_All.pipe_right hd1.FStar_Parser_AST.quals
                      (FStar_List.contains FStar_Parser_AST.Assumption)
                     in
                  if uu____55848
                  then
                    FStar_Errors.raise_error
                      (FStar_Errors.Fatal_AssumeValInInterface,
                        "Interfaces cannot use `assume val x : t`; just write `val x : t` instead")
                      hd1.FStar_Parser_AST.drange
                  else ())
           | uu____55858 -> ())
       in
    aux iface1;
    FStar_All.pipe_right iface1
      (FStar_List.filter
         (fun d  ->
            match d.FStar_Parser_AST.d with
            | FStar_Parser_AST.TopLevelModule uu____55868 -> false
            | uu____55870 -> true))
  
let rec (ml_mode_prefix_with_iface_decls :
  FStar_Parser_AST.decl Prims.list ->
    FStar_Parser_AST.decl ->
      (FStar_Parser_AST.decl Prims.list * FStar_Parser_AST.decl Prims.list))
  =
  fun iface1  ->
    fun impl  ->
      match impl.FStar_Parser_AST.d with
      | FStar_Parser_AST.TopLevelLet (uu____55903,defs) ->
          let xs = FStar_Parser_AST.lids_of_let defs  in
          let uu____55920 =
            FStar_List.partition
              (fun d  ->
                 FStar_All.pipe_right xs
                   (FStar_Util.for_some
                      (fun x  -> is_val x.FStar_Ident.ident d))) iface1
             in
          (match uu____55920 with
           | (val_xs,rest_iface) ->
               (rest_iface, (FStar_List.append val_xs [impl])))
      | uu____55958 -> (iface1, [impl])
  
let (ml_mode_check_initial_interface :
  FStar_Parser_AST.decl Prims.list -> FStar_Parser_AST.decl Prims.list) =
  fun iface1  ->
    FStar_All.pipe_right iface1
      (FStar_List.filter
         (fun d  ->
            match d.FStar_Parser_AST.d with
            | FStar_Parser_AST.Val uu____55983 -> true
            | uu____55989 -> false))
  
let (prefix_one_decl :
  FStar_Parser_AST.decl Prims.list ->
    FStar_Parser_AST.decl ->
      (FStar_Parser_AST.decl Prims.list * FStar_Parser_AST.decl Prims.list))
  =
  fun iface1  ->
    fun impl  ->
      match impl.FStar_Parser_AST.d with
      | FStar_Parser_AST.TopLevelModule uu____56022 -> (iface1, [impl])
      | uu____56027 ->
          let uu____56028 = FStar_Options.ml_ish ()  in
          if uu____56028
          then ml_mode_prefix_with_iface_decls iface1 impl
          else prefix_with_iface_decls iface1 impl
  
let (initialize_interface :
  FStar_Ident.lident ->
    FStar_Parser_AST.decl Prims.list -> unit FStar_Syntax_DsEnv.withenv)
  =
  fun mname  ->
    fun l  ->
      fun env  ->
        let decls =
          let uu____56070 = FStar_Options.ml_ish ()  in
          if uu____56070
          then ml_mode_check_initial_interface l
          else check_initial_interface l  in
        let uu____56077 = FStar_Syntax_DsEnv.iface_decls env mname  in
        match uu____56077 with
        | FStar_Pervasives_Native.Some uu____56086 ->
            let uu____56091 =
              let uu____56097 =
                let uu____56099 = FStar_Ident.string_of_lid mname  in
                FStar_Util.format1 "Interface %s has already been processed"
                  uu____56099
                 in
              (FStar_Errors.Fatal_InterfaceAlreadyProcessed, uu____56097)  in
            let uu____56103 = FStar_Ident.range_of_lid mname  in
            FStar_Errors.raise_error uu____56091 uu____56103
        | FStar_Pervasives_Native.None  ->
            let uu____56110 =
              FStar_Syntax_DsEnv.set_iface_decls env mname decls  in
            ((), uu____56110)
  
let (prefix_with_interface_decls :
  FStar_Parser_AST.decl ->
    FStar_Parser_AST.decl Prims.list FStar_Syntax_DsEnv.withenv)
  =
  fun impl  ->
    fun env  ->
      let uu____56132 =
        let uu____56137 = FStar_Syntax_DsEnv.current_module env  in
        FStar_Syntax_DsEnv.iface_decls env uu____56137  in
      match uu____56132 with
      | FStar_Pervasives_Native.None  -> ([impl], env)
      | FStar_Pervasives_Native.Some iface1 ->
          let uu____56153 = prefix_one_decl iface1 impl  in
          (match uu____56153 with
           | (iface2,impl1) ->
               let env1 =
                 let uu____56179 = FStar_Syntax_DsEnv.current_module env  in
                 FStar_Syntax_DsEnv.set_iface_decls env uu____56179 iface2
                  in
               (impl1, env1))
  
let (interleave_module :
  FStar_Parser_AST.modul ->
    Prims.bool -> FStar_Parser_AST.modul FStar_Syntax_DsEnv.withenv)
  =
  fun a  ->
    fun expect_complete_modul  ->
      fun env  ->
        match a with
        | FStar_Parser_AST.Interface uu____56210 -> (a, env)
        | FStar_Parser_AST.Module (l,impls) ->
            let uu____56226 = FStar_Syntax_DsEnv.iface_decls env l  in
            (match uu____56226 with
             | FStar_Pervasives_Native.None  -> (a, env)
             | FStar_Pervasives_Native.Some iface1 ->
                 let uu____56242 =
                   FStar_List.fold_left
                     (fun uu____56266  ->
                        fun impl  ->
                          match uu____56266 with
                          | (iface2,impls1) ->
                              let uu____56294 = prefix_one_decl iface2 impl
                                 in
                              (match uu____56294 with
                               | (iface3,impls') ->
                                   (iface3,
                                     (FStar_List.append impls1 impls'))))
                     (iface1, []) impls
                    in
                 (match uu____56242 with
                  | (iface2,impls1) ->
                      let uu____56343 =
                        let uu____56352 =
                          FStar_Util.prefix_until
                            (fun uu___432_56371  ->
                               match uu___432_56371 with
                               | {
                                   FStar_Parser_AST.d = FStar_Parser_AST.Val
                                     uu____56373;
                                   FStar_Parser_AST.drange = uu____56374;
                                   FStar_Parser_AST.doc = uu____56375;
                                   FStar_Parser_AST.quals = uu____56376;
                                   FStar_Parser_AST.attrs = uu____56377;_} ->
                                   true
                               | uu____56385 -> false) iface2
                           in
                        match uu____56352 with
                        | FStar_Pervasives_Native.None  -> (iface2, [])
                        | FStar_Pervasives_Native.Some (lets,one_val,rest) ->
                            (lets, (one_val :: rest))
                         in
                      (match uu____56343 with
                       | (iface_lets,remaining_iface_vals) ->
                           let impls2 = FStar_List.append impls1 iface_lets
                              in
                           let env1 =
                             let uu____56452 = FStar_Options.interactive ()
                                in
                             if uu____56452
                             then
                               FStar_Syntax_DsEnv.set_iface_decls env l
                                 remaining_iface_vals
                             else env  in
                           let a1 = FStar_Parser_AST.Module (l, impls2)  in
                           (match remaining_iface_vals with
                            | uu____56464::uu____56465 when
                                expect_complete_modul ->
                                let err =
                                  let uu____56470 =
                                    FStar_List.map
                                      FStar_Parser_AST.decl_to_string
                                      remaining_iface_vals
                                     in
                                  FStar_All.pipe_right uu____56470
                                    (FStar_String.concat "\n\t")
                                   in
                                let uu____56480 =
                                  let uu____56486 =
                                    let uu____56488 =
                                      FStar_Ident.string_of_lid l  in
                                    FStar_Util.format2
                                      "Some interface elements were not implemented by module %s:\n\t%s"
                                      uu____56488 err
                                     in
                                  (FStar_Errors.Fatal_InterfaceNotImplementedByModule,
                                    uu____56486)
                                   in
                                let uu____56492 = FStar_Ident.range_of_lid l
                                   in
                                FStar_Errors.raise_error uu____56480
                                  uu____56492
                            | uu____56497 -> (a1, env1)))))
  