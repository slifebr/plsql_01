CREATE OR REPLACE Package Co_Requisicoes Is

   --||
   --|| CO_MAPA.PKS : Utilitarios aprovacao de cotacoes
   --||

   Procedure Gerar(p_Emp Cd_Filiais.Empresa%Type
                  ,p_Fil Cd_Filiais.Filial%Type
                  ,p_Tip Co_Itens_Req.Tipo_Compra%Type
                  ,p_Dta Co_Itens_Req.Dt_Entrega%Type
                  ,p_Ord Co_Itens_Req.Opos%Type
                  ,p_Sol Co_Requis.Num_Req%Type);

   --/----------------------------------------------------------------------------------------
   Procedure Prepara_Cotacao(p_Emp     Co_Itens_Req.Empresa%Type
                            ,p_Fil     Co_Itens_Req.Filial%Type
                            ,p_Num_Cot Co_Itens_Req.Num_Cot%Type);
   --/
   --|---------------------------------------------------------------
   function fnc_qtde_sol_cot(p_emp co_itens_req.empresa%type
                            ,p_fil co_itens_req.filial%type
                            ,p_sol co_itens_req.num_req%type
                            ,p_itm co_itens_req.item_req%type) return number;
End Co_Requisicoes;
/
CREATE OR REPLACE Package Body Co_Requisicoes Is

   --||
   --|| CO_REQUIS.PKB : Utilitarios Gera tabela temporaria para cotacao;
   --||

   --------------------------------------------------------------------------------
   Procedure Gerar(p_Emp Cd_Filiais.Empresa%Type
                  ,p_Fil Cd_Filiais.Filial%Type
                  ,p_Tip Co_Itens_Req.Tipo_Compra%Type
                  ,p_Dta Co_Itens_Req.Dt_Entrega%Type
                  ,p_Ord Co_Itens_Req.Opos%Type
                  ,p_Sol Co_Requis.Num_Req%Type)
   --||
      --|| Gera tabela para cotacao   O 99999999 FOI COLOCADO DEVIDO A UM ACERTO ERRADO
      --||
    Is
   
      Cursor Cr1 Is
         Select a.Empresa
               ,a.Filial
               ,a.Num_Req
               ,a.Item_Req
               ,a.Produto
               ,a.Qtde_Req
               ,round(a.Qtde_Aprovada,4) -
                round(fnc_qtde_sol_cot(a.empresa,
                                 a.filial,
                                 a.num_req,
                                 a.item_req),4) Qtde_Aprovada
                
               ,Rtrim(a.Complemento) Complemento
               ,a.Unidade
               ,a.Num_Cot
               ,a.Cotar
               ,a.Fil_Cot
               ,Decode(a.Dt_Urgencia,
                        Null,
                        DECODE(a.Dt_Entrega,NULL, TRUNC(SYSDATE) + 1, A.DT_ENTREGA),
                        a.Dt_Urgencia)Dt_NECESSIDADE
               ,b.Dt_Aprovacao
               ,Rtrim(a.Observacao) Observacao
               ,a.Opos
               ,a.Tipo_Compra
           From Co_Itens_Req a
               ,Co_Requis    b
               ,pp_ordens    d
          Where a.Empresa = b.Empresa
            And a.Filial = b.Filial
            And a.Num_Req = b.Num_Req
            And a.Empresa = p_Emp
            And b.Status = 'A'
            And a.Filial = p_Fil
            And (p_Tip Is Null Or a.Tipo_Compra = p_Tip)
               --And a.Num_Cot Is Null
            And a.Qtde_Req - Nvl(a.Qtd_Cancel,
                                 0) > 0
            And a.Qtde_Aprovada > 0
            And a.Produto <> 99999999
            and d.empresa  = a.empresa
            and d.filial   = a.filial
            and d.ordem    = a.opos
            and d.encerramento is null
            And pp_util.fnc_situacao(a.empresa
                                    ,a.filial
                                    ,d.contrato
                                    ,a.opos
                                    ,'COMPRA') = 'S'
            And (p_Dta Is Null Or
                Decode(a.Dt_Urgencia,
                        Null,
                        a.Dt_Entrega,
                        a.Dt_Urgencia) <= p_Dta)
            And (p_Ord Is Null Or Opos = p_Ord)
            And (p_Sol Is Null Or a.Num_Req = p_Sol)
               --And a.Cotar = 'N'
            and nvl(a.qtde_aprovada,
                    0) > 0
            and round(nvl(a.qtde_aprovada,
                    0),4)  > round(fnc_qtde_sol_cot(a.empresa,
                                          a.filial,
                                          a.num_req,
                                          a.item_req),4);
   
      Conta Number(9);
      V_PONTO DATE;
      V_LEAD number;
   Begin
   
      Delete From Tco_Requisicoes;
      Conta := 1;
      For Reg In Cr1 Loop
         V_LEAD := CE_PRODUTOS_UTL.Leadtime(REG.EMPRESA, REG.PRODUTO);
         --| DIAS CORRIDO
         v_ponto := PP_UTIL.FDIAS_C(reg.dt_necessidade , nvl(v_lead,0));
         Insert Into Tco_Requisicoes
         Values
            (Reg.Empresa
            ,Reg.Filial
            ,Reg.Num_Req
            ,Reg.Item_Req
            ,Reg.Produto
            ,Reg.Qtde_Req
            ,Reg.Qtde_Aprovada
            ,Reg.Complemento
            ,Reg.Unidade
            ,Reg.Num_Cot
            ,Reg.Cotar
            ,Reg.Fil_Cot
            ,Reg.Dt_NECESSIDADE
            ,Reg.Observacao
            ,Reg.Opos
            ,Conta
            ,Reg.Dt_Aprovacao
            ,Reg.Tipo_Compra
            ,v_ponto);
         Conta := Conta + 1;
      
      End Loop;
   
      Commit;
   
   Exception
      When Others Then
         Raise_Application_Error(-20100,
                                 Sqlerrm);
      
   End;

   --/----------------------------------------------------------------------------------------
   Procedure Prepara_Cotacao(p_Emp     Co_Itens_Req.Empresa%Type
                            ,p_Fil     Co_Itens_Req.Filial%Type
                            ,p_Num_Cot Co_Itens_Req.Num_Cot%Type) Is
   
      Cursor Cr_c Is
         Select MIN(DECODE(I.DT_URGENCIA,NULL,DECODE(I.DT_ENTREGA, NULL,TRUNC(SYSDATE)+1,I.DT_ENTREGA,I.DT_URGENCIA))) DT_NECES
               ,i.Empresa
               ,i.Filial
               ,Num_Cot
               ,Item_Cot
               ,0 Num_Req
               ,To_Number(Null) Item_Req
               ,i.Produto
               ,Sum(Qtde_Aprovada -
                    fnc_qtde_sol_cot(i.empresa,
                                     i.filial,
                                     i.num_req,
                                     i.item_req)) Qtde

               ,i.Unidade
               ,Co_Util.Complemento(i.Empresa,
                                    i.Produto,
                                    i.Num_Cot) Complemento
               ,Co_Utl.Observ_Cot(i.Empresa,
                                  i.Produto,
                                  i.Num_Cot,
                                  i.Item_Cot,
                                  Null) Observacao
               ,i.Agrupa
               ,i.Tipo_Compra
               
           From Co_Itens_Req i
               ,Ce_Produtos  p
          Where i.Empresa = p_Emp
            And i.Filial = p_Fil
            And Num_Cot = p_Num_Cot
            And i.Agrupa = 'S'
            And p.Empresa = i.Empresa
            And p.Produto = i.Produto
            And i.Item_Cot Is Null
          Group By i.Empresa
                  ,i.Filial
                  ,Num_Cot
                  ,Item_Cot
                  ,i.Produto
                  ,i.Unidade
                  ,i.Agrupa
                  ,i.Item_Cot
                  ,i.Tipo_Compra
         Union All
         Select (DECODE(I.DT_URGENCIA,NULL,DECODE(I.DT_ENTREGA, NULL,TRUNC(SYSDATE)+1,I.DT_ENTREGA,I.DT_URGENCIA)) ) DT_NECES                                  
               ,i.Empresa
               ,i.Filial
               ,Num_Cot
               ,Item_Cot
               ,i.Num_Req
               ,Item_Req
               ,i.Produto
               ,(Qtde_Aprovada -
                fnc_qtde_sol_cot(i.empresa,
                                  i.filial,
                                  i.num_req,
                                  i.item_req)) Qtde

               ,i.Unidade
               ,Complemento
               ,Observacao
               ,i.Agrupa
               ,i.Tipo_Compra
           From Co_Itens_Req i
               ,Ce_Produtos  p
          Where i.Empresa = p_Emp
            And i.Filial = p_Fil
            And Num_Cot = p_Num_Cot
            And i.Agrupa = 'N'
            And p.Empresa = i.Empresa
            And p.Produto = i.Produto
            And i.Item_Cot Is Null
            ORDER BY PRODUTO , 1 DESC ;
       
      Cursor Cr_i(Emp   Co_Itens.Empresa%Type
                 ,Fil   Co_Itens.Filial%Type
                 ,Num   Co_Itens.Num_Cot%Type
                 ,p_Prd Number
                 ,Itm   Co_Itens.Item_Req%Type) Is
         Select a.*
           From Co_Itens a
          Where a.Empresa = Emp
            And a.Filial = Fil
            And a.Num_Cot = Num
            And a.Produto = p_Prd
               --And a.Item_Cot = Itm
            And (Itm Is Null Or a.Item_Req = Itm);
   
      Cursor Crsolit(Emp   Co_Itens.Empresa%Type
                    ,Fil   Co_Itens.Filial%Type
                    ,Num   Co_Itens.Num_Cot%Type
                    ,p_It  Co_Itens_Req.Item_Req%Type
                    ,p_Prd Co_Itens_Req.Produto%Type) Is
         Select *
           From Co_Itens_Req
          Where Empresa = Emp
            And Filial = Fil
            And Num_Cot = Num
            And (p_It Is Null Or Item_Req = p_It)
            And (Item_Cot Is Null)
            And Produto = p_Prd
            And Agrupa = 'S';
   
      Cursor Cr_Sol2(p_Item Number) Is
         Select i.Num_Req
           From Co_Itens_Req i
          Where i.Empresa = p_Emp
            And i.Filial = p_Fil
            And Item_Req = p_Item;
   
      Cursor Cr_s(Emp  Co_Itens.Empresa%Type
                 ,Fil  Co_Itens.Filial%Type
                 ,Num  Co_Itens.Num_Cot%Type
                 ,Prod Co_Itens_Req.Produto%Type) Is
         Select Sum(Nvl(Qtd_Pc,
                        0)) Qtd_Pc
               ,Comprimento
               ,Largura
               ,i.Tipo_Compra
           From Co_Itens_Req i
          Where i.Empresa = Emp
            And i.Filial = Fil
            And Num_Cot = Num
            And Produto = Prod
            And i.Agrupa = 'S'
          Group By Comprimento
                  ,Largura
                  ,Tipo_Compra;
   
      Cursor Cr_n(p_Prd Number
                 ,p_itm number) Is
         Select Sum(Nvl(Qtd_Pc,
                        0)) Qtd_Pc
               ,Comprimento
               ,Largura
           From Co_Itens_Req i
          Where i.Empresa = p_Emp
            And i.Filial = p_Fil
            And Num_Cot = p_Num_Cot
            And Produto = p_Prd
            And i.Agrupa = 'N'
            and i.item_req = p_itm
          Group By Comprimento
                  ,Largura;
   
      Cursor Cr_Sol(p_Num_Req Number) Is
         Select Origem
           From Co_Requis i
          Where i.Empresa = p_Emp
            And i.Filial = p_Fil
            And Num_Req = p_Num_Req;
   
      Cursor Cr_Especific(v_Pro Ce_Produtos.Produto%Type) Is
         Select Rtrim(Substr(Nvl(Especific,
                                 '.'),
                             1,
                             50)) Especificacao
           From Ce_Produtos
          Where Empresa = p_Emp
            And Produto = v_Pro;
   
      v_Sol       Varchar2(1);
      v_Teste     Number;
      v_Qtpeca    Number;
      v_Qtpeca1   Number;
      v_Conta     Number;
      v_Comp3     Varchar2(4000);
      v_Comp      Varchar2(4000);
      v_Comp1     Varchar2(15);
      v_Compr     Number;
      v_Larg      Number;
      v_Compr1    Number;
      v_Larg1     Number;
      v_Sep       Varchar2(3);
      v_Comp2     Varchar2(4000);
      v_Lixo      Number(5);
      v_Tam       Number;
      v_Especific Varchar2(50);
      v_Item      Number(9) := 0;
      v_Erro      Varchar2(200);
      v_Lixo2     Varchar2(100);
      v_Solic     Number(9);
      v_lead_follow number(9);
      V_DT_NECES    DATE;
      V_PTO_CPRA    DATE;
      v_dt_ant date;
      v_prod_ant number;
              
      Erro Exception;
   Begin
   
      --grava os itens sumarizados  
   
      For Reg In Cr_c Loop
         if nvl(v_prod_ant,0) != reg.produto then
            v_prod_ant := reg.produto;
            v_dt_ant := null;
            
         end if;
         if v_dt_neces is null or v_dt_neces > reg.dt_neces then
            v_dt_ant  := reg.DT_NECES;
            v_dt_neces := reg.DT_NECES;

        end if;
         V_PTO_CPRA := pp_util.fdias_c(v_dt_neces,ce_produtos_utl.leadtime(reg.empresa, reg.produto));        
         v_Qtpeca1 := 0;
         v_Qtpeca  := 0;
         v_Compr   := 0;
         v_Larg    := 0;
         v_Conta   := 0;
         v_Compr1  := 0;
         v_Larg1   := 0;
         v_Comp    := Null;
         v_Comp    := Null;
         v_Lixo    := 1;
         v_Comp3   := Null;
      
         v_Lixo := 19;
      
         Open Cr_Especific(Reg.Produto);
         Fetch Cr_Especific
            Into v_Especific;
         Close Cr_Especific;
      
         v_Comp3 := Rtrim(Substr(Reg.Observacao,
                                 1,
                                 4000));
      
         If Reg.Agrupa = 'S' Then
            v_Comp1 := '  CONSIDERAR  ';
            v_Sep   := Null;
            v_Lixo  := 20;
         
            For Reg_s In Cr_s(Reg.Empresa,
                              Reg.Filial,
                              Reg.Num_Cot,
                              Reg.Produto) Loop
            
               v_Lixo    := 2;
               v_Qtpeca1 := v_Qtpeca1 + Nvl(Reg_s.Qtd_Pc,
                                            0);
               v_Qtpeca  := Nvl(Reg_s.Qtd_Pc,
                                0);
            
               If Reg.Unidade In ('KG',
                                  'MT',
                                  'M',
                                  'M2',
                                  'M3')
                  And Nvl(v_Qtpeca,
                          0) > 0
                  And (Nvl(Reg_s.Comprimento,
                           0) + Nvl(Reg_s.Largura,
                                         0)) > 0 Then
                  If Reg_s.Tipo_Compra Not In (9999) Then
                     --(1,5,15,13) then  
                     --/  não será gerado para estes tipos
                     v_Lixo := 21;
                  
                     If Length(v_Comp1 || Rtrim(v_Comp) || v_Sep ||
                               v_Qtpeca || ' PC ' || ' DE ' ||
                               Reg_s.Comprimento || ' MM ' || 'Espec. ' ||
                               v_Especific) < 4000 Then
                     
                        If v_Especific Is Not Null Then
                           v_Comp2 := v_Comp1 || Rtrim(v_Comp) || v_Sep ||
                                      v_Qtpeca || ' PC ' || ' DE ' ||
                                      Reg_s.Comprimento || ' MM ' ||
                                      'Espec. ' || v_Especific;
                        Else
                           v_Comp2 := v_Comp1 || Rtrim(v_Comp) || v_Sep ||
                                      v_Qtpeca || ' PC ' || ' DE ' ||
                                      Reg_s.Comprimento || ' MM ';
                        End If;
                     End If;
                  
                     v_Lixo := 3;
                     v_Tam  := Nvl(Length(Rtrim(v_Comp)),
                                   0) + Nvl(Length(Rtrim(v_Comp2)),
                                            0);
                  
                     If v_Tam > 4000 Then
                        v_Lixo := 4;
                     Else
                        v_Lixo := 5;
                        v_Sep  := Null;
                        v_Comp := v_Comp || Rtrim(v_Comp2);
                     End If;
                  
                     If Nvl(Reg_s.Largura,
                            0) > 0 Then
                        v_Lixo  := 6;
                        v_Comp2 := ' X ' || Reg_s.Largura || ' MM ';
                        If Nvl(Length(Rtrim(v_Comp)),
                               0) + Nvl(Length(Rtrim(v_Comp2)),
                                        0) > 4000 Then
                           v_Lixo := 7;
                           --sca_aviso('(7) Produto - '||reg.produto, 'Observ. gerada TEM MAIS DE 4000 CARACTERES... verifique! #');
                           --raise form_trigger_failure;
                        Else
                           v_Lixo := 8;
                           v_Comp := v_Comp || Rtrim(v_Comp2);
                        End If;
                     
                     End If;
                  
                     v_Sep := ' - ';
                  
                  End If; --/ se tipo_compra
               Else
                  v_Lixo := 9;
                  If Nvl(Length(Rtrim(v_Comp)),
                         0) + Nvl(Length(Rtrim(Substr(Reg.Complemento,
                                                      1,
                                                      4000))),
                                  0) > 4000 Then
                     v_Comp := 'Observ. gerada TEM MAIS DE 4000 CARACTERES... verifique! #' ||
                               Substr(Rtrim(v_Comp),
                                      1,
                                      3440);
                     Exit;
                  Else
                     If Nvl(Reg_s.Comprimento,
                            0) = 0
                        And Nvl(Reg_s.Largura,
                                0) = 0 Then
                        --and :co_cotacao.tipo_compra in (1,5,15,13) then 
                        v_Lixo  := 10;
                        v_Sep   := Null;
                        v_Comp  := Rtrim(Substr(Reg.Complemento,
                                                1,
                                                4000)); --null;
                        v_Comp3 := Null;
                     Else
                        v_Lixo := 11;
                        v_Sep  := Null;
                        v_Comp := Rtrim(Substr(Reg.Complemento,
                                               1,
                                               4000));
                     End If;
                  End If;
               End If;
            
               v_Lixo  := 12;
               v_Comp1 := Null;
               v_Comp2 := Null;
               v_Conta := v_Conta + 1;
               v_Compr := Reg_s.Comprimento;
               v_Larg  := Reg_s.Largura;
            
            End Loop;
         
            If v_Conta > 1 Then
               v_Compr := Null;
               v_Larg  := Null;
            End If;
         
            v_Lixo := 13;
            v_Item := v_Item + 1;
            v_lead_follow := ce_produtos_utl.leadtime_followup(reg.empresa, reg.produto);
            Insert Into Co_Itens
            Values
               (Reg.Empresa
               ,Reg.Filial
               ,Reg.Num_Cot
               ,Co_Itens_Seq.Nextval
               ,Reg.Produto
               ,Reg.Qtde
               ,Reg.Unidade
               ,Rtrim(Substr(v_Comp,
                             1,
                             4000))
               ,Rtrim(Substr(v_Comp3,
                             1,
                             4000))
               ,Null
               ,v_Qtpeca1
               ,v_Larg
               ,v_Compr
               ,Reg.Qtde
               ,Reg.Tipo_Compra
               ,v_Item
               ,NULL
               , --DT_APROV 
                NULL
               , --USU_APROV
                USER
               , --USU_INCL 
                SYSDATE
               , --DT_INCL  
                'N' --APROVADO 
                ,v_lead_follow
                , V_DT_NECES
               ,V_PTO_CPRA
                );
         Else
         
            Open Cr_Sol(Reg.Num_Req);
            Fetch Cr_Sol
               Into v_Sol;
            Close Cr_Sol;
         
            Open Cr_n(Reg.Produto,
                      reg.item_req);
            Fetch Cr_n
               Into v_Qtpeca
                   ,v_Compr
                   ,v_Larg;
            Close Cr_n;
         
            v_Comp := Null;
            v_Lixo := 14;
         
            If Reg.Unidade In ('KG',
                               'MT',
                               'M',
                               'M2',
                               'M3')
               And Nvl(v_Qtpeca,
                       0) > 0
               And (Nvl(v_Compr,
                        0) + Nvl(v_Larg,
                                      0)) > 0 Then
            
               v_Comp := Rtrim('CONSIDERAR    ' || v_Qtpeca || ' PC ' ||
                               v_Compr || ' MM');
               If Nvl(v_Larg,
                      0) > 0 Then
                  v_Comp := v_Comp || ' X ' || v_Larg || ' MM  ';
               End If;
            Else
               v_Tam := Nvl(Length(Rtrim(Reg.Complemento)),
                            0);
            
               If v_Tam > 4000 Then
                  v_Erro := 'Estouro de tamanho: ' || v_Tam;
                  --raise_application_error(-20101, v_erro);
                  Raise Erro;
                  Null;
               End If;
            
               v_Comp := Rtrim(Substr(Reg.Complemento,
                                      1,
                                      4000));
            End If;
         
            v_Lixo := 15;
            v_Item := v_Item + 1;
            v_lead_follow := ce_produtos_utl.leadtime_followup(reg.empresa, reg.produto);
            Insert Into Co_Itens
            Values
               (Reg.Empresa
               ,Reg.Filial
               ,Reg.Num_Cot
               ,Co_Itens_Seq.Nextval
               ,Reg.Produto
               ,Reg.Qtde
               ,Reg.Unidade
               ,Rtrim(Substr(v_Comp,
                             1,
                             4000))
               ,Rtrim(Substr(v_Comp3,
                             1,
                             4000))
               ,Reg.Item_Req
               ,v_Qtpeca
               ,v_Larg
               ,v_Compr
               ,Reg.Qtde
               ,Reg.Tipo_Compra
               ,v_Item
               ,NULL
               , --DT_APROV 
                NULL
               , --USU_APROV
                USER
               , --USU_INCL 
                SYSDATE
               , --DT_INCL  
                'N' --APROVADO 
               , v_lead_follow
               ,V_DT_NECES
               ,V_PTO_CPRA
                );
         
         End If;
      
      --post;
      
      End Loop;
      v_Lixo := 16;
      --grava o numero da cotacao para cada item da requisicao
      For Reg In Cr_c Loop
      
         v_Lixo2 := Null;
      
         For Reg_i In Cr_i(Reg.Empresa,
                           Reg.Filial,
                           Reg.Num_Cot,
                           Reg.Produto,
                           Reg.Item_Req) Loop
         
            If Nvl(Reg_i.Item_Req,
                   0) > 0 Then
               -- agrupa = 'N'
            
               v_Lixo  := 21;
               v_Lixo2 := '117 - ' || Reg_i.Item_Req || ' - ' ||
                          Reg.Num_Req;
            
               Update Co_Itens_Req
                  Set Item_Cot = Reg_i.Item_Cot
                Where Empresa = Reg_i.Empresa
                  And Filial = Reg_i.Filial
                  And Num_Cot = Reg_i.Num_Cot
                  And Item_Req = Reg_i.Item_Req;
            
               Begin
                  v_Solic := Null;
               
                  Open Cr_Sol2(Reg_i.Item_Req);
                  Fetch Cr_Sol2
                     Into v_Solic;
                  Close Cr_Sol2;
               
                  Insert Into Co_Solcot
                     (Id
                     ,Empresa
                     ,Filial
                     ,Num_Req
                     ,Item_Req
                     ,Num_Cot
                     ,Item_Cot
                     ,Qtde
                     ,Usu_Incl
                     ,Dt_Incl)
                  Values
                     (Co_Solcot_Seq.Nextval
                     ,Reg.Empresa
                     ,Reg.Filial
                     ,v_Solic
                     ,Reg_i.Item_Req
                     ,Reg_i.Num_Cot
                     ,Reg_i.Item_Cot
                     ,Reg_i.Qtde
                     ,User
                     ,Sysdate);
               Exception
                  When Dup_Val_On_Index Then
                     Null;
                  When Others Then
                     Raise_Application_Error(-20101,
                                             'CO_REQUISICOES.PREPARA_COTACAO:(1)' ||
                                             ' - ' || Reg.Produto || ' - ' ||
                                             Reg.Num_Req || ' - ' ||
                                             Reg.Item_Req || ' - ' ||
                                             Reg_i.Num_Cot || ' - ' ||
                                             Reg_i.Item_Cot || ' - ' ||
                                             Reg_i.Qtde);
                  
               End;
            
            Else
               v_Lixo2 := Null;
               For Reg_It In Crsolit(Reg.Empresa,
                                     Reg.Filial,
                                     Reg.Num_Cot,
                                     Null,
                                     Reg.Produto) Loop
               
                  v_Lixo2 := '33322 - ' || Reg_It.Item_Req;
               
                  If Nvl(Reg_It.Num_Req,
                         0) > 0 Then
                  
                     Update Co_Itens_Req
                        Set Item_Cot = Reg_i.Item_Cot
                      Where Empresa = Reg_i.Empresa
                        And Fil_Cot = Reg_i.Filial
                        And Num_Cot = Reg_i.Num_Cot
                        And Produto = Reg_i.Produto
                        And Item_Req = Reg_It.Item_Req
                        And Num_Req = Reg_It.Num_Req;
                  
                     Begin
                        Insert Into Co_Solcot
                           (Id
                           ,Empresa
                           ,Filial
                           ,Num_Req
                           ,Item_Req
                           ,Num_Cot
                           ,Item_Cot
                           ,Qtde
                           ,Usu_Incl
                           ,Dt_Incl)
                        Values
                           (Co_Solcot_Seq.Nextval
                           ,Reg.Empresa
                           ,Reg.Filial
                           ,Reg_It.Num_Req
                           ,Reg_It.Item_Req
                           ,Reg_i.Num_Cot
                           ,Reg_i.Item_Cot
                           ,Reg_it.Qtde_aprovada
                           ,User
                           ,Sysdate);
                     Exception
                        When Dup_Val_On_Index Then
                           Null;
                        When Others Then
                           Raise_Application_Error(-20105,
                                                   'CO_REQUISICOES.PREPARA_COTACAO:(2) ' ||
                                                   ' - ' || Reg.Produto ||
                                                   ' - ' || Reg_It.Num_Req ||
                                                   ' - ' || Reg_It.Item_Req ||
                                                   ' - ' || Reg_i.Num_Cot ||
                                                   ' - ' || Reg_i.Item_Cot ||
                                                   ' - ' || Reg_i.Qtde);
                     End;
                  End If;
               End Loop;
            
            End If;
         
         End Loop;
      
      End Loop;
   
      Commit;
   
      /*
      EXCEPTION
      
           WHEN ERRO  THEN
              rollback;
              raise_application_error(-20101,'PREPARA_COTACAO: '||v_erro );
           WHEN OTHERS THEN
              rollback;
             raise_application_error(-20101,'PREPARA_COTACAO: '||V_LIXO2 );
            -- RAISE;
      --          RAISE FORM_TRIGGER_FAILURE;
      */
   End;

   --|---------------------------------------------------------------
   function fnc_qtde_sol_cot(p_emp co_itens_req.empresa%type
                            ,p_fil co_itens_req.filial%type
                            ,p_sol co_itens_req.num_req%type
                            ,p_itm co_itens_req.item_req%type) return number is
      v_ret number;
   begin
      select sum(so.qtde - nvl(so.qtde_dev,0))
        into v_ret
        from co_solcot so
       where so.empresa = p_emp
         and so.filial = p_fil
         and so.num_req = p_sol
         and so.item_req = p_itm;
      
      if v_ret < 0 then
         v_ret := 0;
      end if;
      
      return nvl(v_ret,
                 0);
   
   end;
End Co_Requisicoes;
/
