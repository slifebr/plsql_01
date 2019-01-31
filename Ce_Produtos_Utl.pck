CREATE OR REPLACE Package Ce_Produtos_Utl Is

   --||
   --|| CE_PRODUTOS_UTL.PKS : Utilitarios para CE_PRODUTOS
   --||

   Function Descricao(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Descricao%Type;
   --/
   Function Desenho(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Desenho%Type;

   Function Grupo(Emp In Ce_Produtos.Empresa%Type,
                  Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type;
   --/
   Function Cod_Grupo(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type;
   --/
      --/
   Function fb_Grupo(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.grupo%Type;
   --/
   Function Grupo1(Emp In Ce_Produtos.Empresa%Type,
                   Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type;
   --/
   Function Grupo_Descr(p_Emp Ce_Grupos.Empresa%Type,
                        p_Gr  Ce_Grupos.Grupo%Type)
      Return Ce_Grupos.Descricao%Type;

   --------------------------------------------------------------------------------
   Function Grupo_Descr(p_Emp Ce_Grupos.Empresa%Type,
                        p_Gr  Ce_Grupos.Grupo%Type,
                        p_Niv Number) Return Ce_Grupos.Descricao%Type;
   --------------------------------------------------------------------------------


   --/
   Function Unidade(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Uni_Est(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Uni_Sec(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Uni_Ven(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Uni_Val(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Uni_Emb(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type;
   --/
   Function Peso(Emp In Ce_Produtos.Empresa%Type,
                 Cod In Ce_Produtos.Produto%Type) Return Ce_Produtos.Peso%Type;
   --/
   Function Peso_Espec(Emp In Ce_Produtos.Empresa%Type,
                       Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Peso_Espec%Type;
   --------------------------------------------------------------------------------
   Function Cod_Clafis(Emp In Ce_Produtos.Empresa%Type,
                       Prd In Ce_Produtos.Produto%Type)
      Return Ft_Clafis.Cod_Clafis%Type;
   --/
   Function Cod_Nbm(Emp In Ce_Produtos.Empresa%Type,
                    Prd In Ce_Produtos.Produto%Type)
      Return Ft_Clafis.Cod_Nbm%Type;
   --/
   --------------------------------------------------------------------------------
   Function NCM_TO_COD(P_NCM FT_CLAFIS.COD_NBM%TYPE)
      Return Ft_Clafis.Cod_Clafis%Type;
      
   Procedure Saldo_Filial(Fil In Ce_Saldo.Filial%Type);
   --/
   Function Saldo_Atual(Emp In Ce_Produtos.Empresa%Type,
                        Cod In Ce_Produtos.Produto%Type)
      Return Ce_Saldo.Saldo_Fisico%Type;
   --/
   Function Saldo_Atual_Local(Emp In Ce_Produtos.Empresa%Type,
                              Cod In Ce_Produtos.Produto%Type,
                              Loc In Ce_Saldo_Local.Local%Type)
      Return Ce_Saldo_Local.Saldo_Fisico%Type;
   --/
   Function Codigo_Externo(Emp In Ce_Produtos.Empresa%Type,
                           Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Codigo_Externo%Type;
   --/
   Function Sufixo_Externo(Emp In Ce_Produtos.Empresa%Type,
                           Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Codigo_Externo%Type;
   --/
   Function Fabricante(Emp In Ce_Produtos.Empresa%Type,
                       Cod In Ce_Produtos.Produto%Type)
      Return Cd_Firmas.Reduzido%Type;
   --/
   Function Aplicacao(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Aplicacao%Type;
   ----------------------------------------------------------------
   Function Custo_Medio(Emp In Ce_Saldo.Empresa%Type,
                        Fil In Ce_Saldo.Filial%Type,
                        Cod In Ce_Produtos.Produto%Type) Return Number;
   Function Ult_Preco_Af(Emp In Ce_Saldo.Empresa%Type,
                         Fil In Ce_Saldo.Filial%Type,
                         Cod In Ce_Produtos.Produto%Type) Return Number;

   --------------------------------------------------------
   Function Ult_Preco_Nf(Emp In Ce_Saldo.Empresa%Type,
                         Fil In Ce_Saldo.Filial%Type,
                         Cod In Ce_Produtos.Produto%Type) Return Number;

   Function Ult_Custo(Emp In Ce_Saldo.Empresa%Type,
                      Fil In Ce_Saldo.Filial%Type,
                      Cod In Ce_Produtos.Produto%Type) Return Number;

   Function Data_Ult_Custo(Emp In Ce_Saldo.Empresa%Type,
                           Fil In Ce_Saldo.Filial%Type,
                           Cod In Ce_Produtos.Produto%Type) Return Date;
   --------------------------------------------------------------------------------
   Function Tipo_Cpra_Grupo(Emp In Ce_Grupos.Empresa%Type,
                            Gr  In Ce_Grupos.Grupo%Type)
      Return Co_Tipos_Compra.Tipo_Compra%Type;
   ---------------------------------------------------------------
   Function Cod_Conta(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Cg_Plano.Cod_Conta%Type;
   ------------------------------------------------------------------
   Function Cod_Fin(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Fn_Plano.Cod_Fin%Type;
   ------------------------------------------------------------------
   ------------------------------------------------------------------
   Function Cod_Fin(Emp In Ce_Grupos.Empresa%Type,
                    Gr  In Ce_Grupos.Grupo%Type) Return Fn_Plano.Cod_Fin%Type;
   ------------------------------------------------------------------
   ------------------------------------------------------------------
   Function Cod_Fin_Descr(p_Cta Fn_Plano.Cod_Fin%Type)
      Return Fn_Plano.Descricao%Type;
   ------------------------------------------------------------------

   Function Pc_Difer(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type) Return Number;
   ------------------------------------------------------------------
   Function Estoque(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Estoque%Type;

   --------------------------------------------------------------------------------
   Function servico(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.servico%Type;      
   ------------------------------------------------------------------
   Function Alt_Desc(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Alt_Desc%Type;
   ------------------------------------------------------------------
   Function Area_Res(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Area_Res%Type;

   ------------------------------------------------------------------
   Function Sld_Local_Filial(Emp In Ce_Produtos.Empresa%Type,
                             Fil In Ce_Saldo_Local.Filial%Type,
                             Cod In Ce_Produtos.Produto%Type,
                             Loc In Ce_Saldo_Local.Local%Type)
      Return Ce_Saldo_Local.Saldo_Fisico%Type;

   ------------------------------------------------------------------
   Function Desc_Produto(Emp In Ce_Produtos.Empresa%Type,
                         Pro In Ce_Produtos.Produto%Type) Return Varchar2;

   ------------------------------------------------------------------
   Function Local_Padrao(Emp In Ce_Uniprod.Empresa%Type,
                         Fil In Ce_Uniprod.Filial%Type,
                         Cod In Ce_Uniprod.Produto%Type)
      Return Ce_Uniprod.Loc_Padrao%Type;

   Function Local_Com_Saldo(Emp In Ce_Uniprod.Empresa%Type,
                            Fil In Ce_Uniprod.Filial%Type,
                            Cod In Ce_Uniprod.Produto%Type)
      Return Ce_Uniprod.Loc_Padrao%Type;

   Function Fn_Prod_Log(Emp  In Ce_Uniprod.Empresa%Type,
                        Pro  In Ce_Produtos.Produto%Type,
                        Acao Varchar2) Return Number;

   Function Fn_Registro_Prod(Emp   In Ce_Produtos.Empresa%Type,
                             Fil   In Cd_Filiais.Filial%Type,
                             Pro   In Ce_Produtos.Produto%Type,
                             p_Ini In Date,
                             p_Fim In Date) Return Char;

   Function Fn_Produto_Ativo(Emp In Ce_Produtos.Empresa%Type,
                             Pro In Ce_Produtos.Produto%Type) Return Char;
   --/
   Function Fn_Grupo_Familia(Emp In Ce_Grupos.Empresa%Type,
                             Gr  In Ce_Grupos.Grupo%Type,
                             Niv In Number) Return Ce_Grupos.Grupo%Type;
   -----------------------------------------------------------------------
   Function Fn_Grupo_Familia_Descr(Emp In Ce_Grupos.Empresa%Type,
                                   Gr  In Ce_Grupos.Grupo%Type,
                                   Niv In Number)
      Return Ce_Grupos.Descricao%Type;

   -----------------------------------------------------------------------
   Function Fn_Descr_Geral_Grupo(Emp In Ce_Grupos.Empresa%Type,
                                 Gr  In Ce_Grupos.Grupo%Type,
                                 Niv In Number) Return Varchar2;

   -----------------------------------------------------------------------
   Function Fn_Produto_Lead(Emp In Ce_Produtos.Empresa%Type,
                            Pro In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Leadtime%Type;

   -------------------------------------------------------------------------------
   Function Leadtime(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Leadtime%Type;
   --|-----------------------------------------------------------------------------------------
   Function leadtime_followup(Emp In Ce_Produtos.Empresa%Type,
                             Cod In Ce_Produtos.Produto%Type)
       Return ce_grupos.lead_followup%Type;
   --|---------------------------------------------------------------------------------------
   procedure  atualiza_ncm(p_emp number,p_prod number, p_clafis number);
   --|-------------------------------------------------------------------------------
   procedure gera_leadtime_followup_sup(Emp In Ce_Produtos.Empresa%Type,
                               Cod In Ce_Produtos.Produto%Type);
End Ce_Produtos_Utl;
/
CREATE OR REPLACE Package Body Ce_Produtos_Utl Is

   --||
   --|| CE_PRODUTOS_UTL.SQL : Utilitarios para CE_PRODUTOS
   --||

   --------------------------------------------------------------------------------
   /*
   || Variaveis globais
   */

   g_Filial Ce_Saldo.Filial%Type := 0;

   --------------------------------------------------------------------------------
   Function Descricao(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Descricao%Type
   /*
      || Retorna nome do produto
      */
    Is
   
      v_Campo Ce_Produtos.Descricao%Type;
   
   Begin
   
      Select Descricao
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Desenho(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Desenho%Type
   /*
      || Retorna nome do produto
      */
    Is
   
      v_Campo Ce_Produtos.Desenho%Type;
   
   Begin
   
      Select Desenho
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Cod_Grupo(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type
   /*
      || Retorna grupo
      */
    Is
   
      v_Campo Ce_Grupos.Descricao%Type;
      v_Grupo Ce_Produtos.Grupo%Type;
   
   Begin
   
      Select Grupo
        Into v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Grupo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Grupo(Emp In Ce_Produtos.Empresa%Type,
                  Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type
   /*
      || Retorna nome do grupo
      */
    Is
   
      v_Campo Ce_Grupos.Descricao%Type;
      v_Grupo Ce_Produtos.Grupo%Type;
   
   Begin
   
      Select Grupo
        Into v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Select Descricao
        Into v_Campo
        From Ce_Grupos
       Where Empresa = Emp
         And Grupo = v_Grupo;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;
--------------------------------------------------------------------------------
   Function fb_Grupo(Emp In Ce_Produtos.Empresa%Type,
                  Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.grupo%Type
   /*
      || Retorna grupo do produto
      */
    Is

      v_Grupo Ce_Produtos.Grupo%Type;
   
   Begin
   
      Select Grupo
        Into v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;

      Return v_grupo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;
   --------------------------------------------------------------------------------
   Function Grupo1(Emp In Ce_Produtos.Empresa%Type,
                   Cod In Ce_Produtos.Produto%Type)
      Return Ce_Grupos.Descricao%Type
   /*
      || Retorna nome do grupo nivel 1
      */
    Is
   
      v_Campo Ce_Grupos.Descricao%Type;
      v_Grupo Ce_Produtos.Grupo%Type;
   
   Begin
   
      Select Grupo
        Into v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      v_Grupo := Lib_Cniv.Cod_Nivel(v_Grupo, 1);
      Select Descricao
        Into v_Campo
        From Ce_Grupos
       Where Empresa = Emp
         And Grupo = v_Grupo;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;
   --------------------------------------------------------------------------------
   Function Grupo_Descr(p_Emp Ce_Grupos.Empresa%Type,
                        p_Gr  Ce_Grupos.Grupo%Type)
      Return Ce_Grupos.Descricao%Type Is
      Cursor Cr Is
         Select Descricao
           From Ce_Grupos
          Where Empresa = p_Emp
            And Grupo = p_Gr;
   
      v_Ret Ce_Grupos.Descricao%Type;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return v_Ret;
      --/
   End;
   --/
   --------------------------------------------------------------------------------
   Function Grupo_Descr(p_Emp Ce_Grupos.Empresa%Type,
                        p_Gr  Ce_Grupos.Grupo%Type,
                        p_Niv Number) Return Ce_Grupos.Descricao%Type Is
      Cursor Cr Is
         Select Descricao
           From Ce_Grupos
          Where Empresa = p_Emp
            And Grupo = p_Gr;
   
      v_Ret Varchar2(500);
      n     Integer;
      v_Niv Integer;
      v_Aux Varchar2(60);
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
      --/
      If Nvl(p_Niv, 0) > 1 Then
         v_Niv := Lib_Cniv.Nivel(p_Gr);
         If p_Niv < v_Niv Then
            For n In 1 .. p_Niv Loop
               v_Aux := Null;
               v_Aux := Lib_Cniv.Cod_Nivel(p_Gr, v_Niv - n);
               If v_Aux Is Not Null Then
                  v_Ret := v_Aux || '/' || v_Ret;
               End If;
            End Loop;
         End If;
      End If;
   
      Return v_Ret;
      --/
   End;
   --/

   

   --------------------------------------------------------------------------------
   Function Unidade(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade
      */
    Is
   
      v_Campo Ce_Produtos.Unidade%Type;
   
   Begin
   
      Select Unidade
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Uni_Est(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade de estoque na filial
      */
    Is
   
      Cursor Cr_u Is
         Select Uni_Est
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      v_Uni Ce_Produtos.Unidade%Type;
   
   Begin
   
      Open Cr_u;
      Fetch Cr_u
         Into v_Uni;
      If Cr_u%Notfound Or v_Uni Is Null Then
         Select Unidade
           Into v_Uni
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Cod;
      End If;
      Close Cr_u;
   
      Return v_Uni;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Uni_Sec(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade de estoque 2 na filial
      */
    Is
   
      Cursor Cr_u Is
         Select Uni_Sec
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      v_Uni Ce_Produtos.Unidade%Type;
   
   Begin
   
      Open Cr_u;
      Fetch Cr_u
         Into v_Uni;
      If Cr_u%Notfound Then
         Select Uni_Sec
           Into v_Uni
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Cod;
      End If;
      Close Cr_u;
   
      Return v_Uni;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Uni_Ven(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade de venda na filial
      */
    Is
   
      Cursor Cr_u Is
         Select Uni_Ven
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      v_Uni  Ce_Produtos.Unidade%Type;
      v_Uni2 Ce_Produtos.Unidade%Type;
   
   Begin
   
      Open Cr_u;
      Fetch Cr_u
         Into v_Uni;
      If Cr_u%Notfound Then
         Select Unidade, Uni_Ven
           Into v_Uni, v_Uni2
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Cod;
      End If;
      Close Cr_u;
   
      Return Nvl(v_Uni2, v_Uni);
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Uni_Val(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade de valor na filial
      */
    Is
   
      Cursor Cr_u Is
         Select Uni_Val
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      v_Uni  Ce_Produtos.Unidade%Type;
      v_Uni2 Ce_Produtos.Unidade%Type;
   
   Begin
   
      Open Cr_u;
      Fetch Cr_u
         Into v_Uni;
      If Cr_u%Notfound Then
         Select Unidade, Uni_Val
           Into v_Uni, v_Uni2
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Cod;
      End If;
      Close Cr_u;
   
      Return Nvl(v_Uni2, v_Uni);
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Uni_Emb(Emp In Cd_Empresas.Empresa%Type,
                    Fil In Cd_Filiais.Filial%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Unidade%Type
   /*
      || Retorna unidade de embarque na filial
      */
    Is
   
      Cursor Cr_u Is
         Select Uni_Emb
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      v_Uni  Ce_Produtos.Unidade%Type;
      v_Uni2 Ce_Produtos.Unidade%Type;
   
   Begin
   
      Open Cr_u;
      Fetch Cr_u
         Into v_Uni;
      If Cr_u%Notfound Then
         Select Unidade, Uni_Emb
           Into v_Uni, v_Uni2
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Cod;
      End If;
      Close Cr_u;
   
      Return Nvl(v_Uni2, v_Uni);
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Peso(Emp In Ce_Produtos.Empresa%Type,
                 Cod In Ce_Produtos.Produto%Type) Return Ce_Produtos.Peso%Type
   /*
      || Retorna peso
      */
    Is
   
      v_Campo Ce_Produtos.Peso%Type;
   
   Begin
   
      Select Peso
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Peso_Espec(Emp In Ce_Produtos.Empresa%Type,
                       Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Peso_Espec%Type
   /*
      || Retorna peso
      */
    Is
   
      v_Campo Ce_Produtos.Peso%Type;
   
   Begin
   
      Select Decode(Nvl(Peso_Espec, 0), 0, Peso, Peso_Espec)
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      --/
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Procedure Saldo_Filial(Fil In Ce_Saldo.Filial%Type)
   /*
      || Seta a filial corrente para retornar saldo
      */
    Is
   
   Begin
   
      g_Filial := Fil;
   
   End;

   --------------------------------------------------------------------------------
   Function Saldo_Atual(Emp In Ce_Produtos.Empresa%Type,
                        Cod In Ce_Produtos.Produto%Type)
      Return Ce_Saldo.Saldo_Fisico%Type
   /*
      || Retorna saldo fisico do produto
      */
    Is
   
      Cursor Cr Is
         Select Saldo_Fisico
           From Ce_Saldo
          Where Empresa = Emp
            And Filial = g_Filial
            And Produto = Cod
          Order By Empresa, Filial, Produto, Dt_Saldo Desc;
   
      v_Saldo Number;
   
   Begin
   
      If g_Filial Is Null Then
         Return Null;
      End If;
      Open Cr;
      Fetch Cr
         Into v_Saldo;
      Close Cr;
      Return v_Saldo;
   
   Exception
   
      When Others Then
         Return 0;
      
   End;

   --------------------------------------------------------------------------------
   Function Saldo_Atual_Local(Emp In Ce_Produtos.Empresa%Type,
                              Cod In Ce_Produtos.Produto%Type,
                              Loc In Ce_Saldo_Local.Local%Type)
      Return Ce_Saldo_Local.Saldo_Fisico%Type
   /*
      || Retorna saldo fisico do produto no local
      */
    Is
   
      Cursor Cr Is
         Select Saldo_Fisico
           From Ce_Saldo_Local
          Where Empresa = Emp
            And Filial = g_Filial
            And Local = Loc
            And Produto = Cod
          Order By Empresa, Filial, Local, Produto, Dt_Saldo Desc;
   
      v_Saldo Number;
   
   Begin
   
      If g_Filial Is Null Then
         Return Null;
      End If;
      Open Cr;
      Fetch Cr
         Into v_Saldo;
      Close Cr;
      Return v_Saldo;
   
   Exception
   
      When Others Then
         Return 0;
      
   End;

   --------------------------------------------------------------------------------
   Function Codigo_Externo(Emp In Ce_Produtos.Empresa%Type,
                           Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Codigo_Externo%Type
   /*
      || Retorna codigo externo do produto
      */
    Is
   
      v_Campo Ce_Produtos.Codigo_Externo%Type;
   
   Begin
   
      Select Codigo_Externo
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Sufixo_Externo(Emp In Ce_Produtos.Empresa%Type,
                           Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Codigo_Externo%Type
   /*
      || Retorna codigo sufixo externo
      */
    Is
   
      v_Campo Ce_Produtos.Sufixo_Externo%Type;
   
   Begin
   
      Select Sufixo_Externo
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Fabricante(Emp In Ce_Produtos.Empresa%Type,
                       Cod In Ce_Produtos.Produto%Type)
      Return Cd_Firmas.Reduzido%Type
   /*
      || Retorna codigo fantasia do fabricante
      */
    Is
   
      v_Campo Cd_Firmas.Reduzido%Type;
      v_Cod   Ce_Produtos.Cod_Fornec%Type;
   
   Begin
   
      Select Cod_Fornec
        Into v_Cod
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      If v_Cod Is Not Null Then
         Select Reduzido Into v_Campo From Cd_Firmas Where Firma = v_Cod;
      Else
         v_Campo := '';
      End If;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Aplicacao(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Aplicacao%Type
   /*
      || Retorna aplicacao do produto
      */
    Is
   
      v_Campo Ce_Produtos.Aplicacao%Type;
   
   Begin
   
      Select Aplicacao
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --------------------------------------------------------------------------------
   Function Custo_Medio(Emp In Ce_Saldo.Empresa%Type,
                        Fil In Ce_Saldo.Filial%Type,
                        Cod In Ce_Produtos.Produto%Type) Return Number
   /*
      || Retorna custo medio atual do produto na filial
      */
    Is
   
      Cursor Cr Is
         Select Saldo_Fisico, Custo_Medio
           From Ce_Saldo
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod
          Order By Dt_Saldo Desc;
      v_Fis Number;
      v_Fin Number;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Fis, v_Fin;
      If Cr%Found And v_Fis > 0 Then
         Close Cr;
         Return v_Fin;
      End If;
      Close Cr;
      Return 0;
   
   End;
   --------------------------------------------------------
   Function Ult_Preco_Af(Emp In Ce_Saldo.Empresa%Type,
                         Fil In Ce_Saldo.Filial%Type,
                         Cod In Ce_Produtos.Produto%Type) Return Number Is
      Cursor Cr Is
         Select Max(Dt_Ordem) Dt,
                Io.Preco + (Io.Preco * Nvl(Io.Aliq_Ipi, 0) / 100) +
                (Io.Preco * Nvl(Io.Aliq_Inss, 0) / 100) Preco
         
           From Co_Itens_Ord Io, Co_Ordens o
          Where Io.Empresa = o.Empresa
            And Io.Filial = o.Filial
            And Io.Ordem = o.Ordem
            And Io.Produto = Cod
            And Io.Empresa = Emp
            And Io.Filial = Fil
          Group By Io.Preco + (Io.Preco * Nvl(Io.Aliq_Ipi, 0) / 100) +
                   (Io.Preco * Nvl(Io.Aliq_Inss, 0) / 100)
          Order By 1 Desc;
   
      v_Ret Number(15, 2);
      v_Dt  Date;
   Begin
      Open Cr;
      Fetch Cr
         Into v_Dt, v_Ret;
      Close Cr;
      Return v_Ret;
   End;

   --------------------------------------------------------
   Function Ult_Preco_Nf(Emp In Ce_Saldo.Empresa%Type,
                         Fil In Ce_Saldo.Filial%Type,
                         Cod In Ce_Produtos.Produto%Type) Return Number Is
      Cursor Cr Is
         Select Max(o.Dt_Entrada) Dt,
                Io.Valor_Unit + (Io.Valor_Unit * Nvl(Io.Aliq_Ipi, 0) / 100) Preco
         
           From Ce_Itens_Nf Io, Ce_Notas o, Ft_Oper f
          Where Io.Empresa = o.Empresa
            And Io.Filial = o.Filial
            And Io.Num_Nota = o.Num_Nota
            And Io.Sr_Nota = o.Sr_Nota
            And Io.Parte = o.Parte
            And Io.Cod_Fornec = o.Cod_Fornec
            And f.Empresa = o.Empresa
            And f.Cod_Oper = o.Cod_Oper
            And f.Natureza = 'E'
            And Io.Produto = Cod
            And Io.Empresa = Emp
            And Io.Filial = Fil
          Group By Io.Valor_Unit +
                   (Io.Valor_Unit * Nvl(Io.Aliq_Ipi, 0) / 100)
          Order By 1 Desc;
   
      v_Ret Number(15, 2);
      v_Dt  Date;
   Begin
      Open Cr;
      Fetch Cr
         Into v_Dt, v_Ret;
      Close Cr;
      Return v_Ret;
   End;
   --------------------------------------------------------
   Function Ult_Custo(Emp In Ce_Saldo.Empresa%Type,
                      Fil In Ce_Saldo.Filial%Type,
                      Cod In Ce_Produtos.Produto%Type) Return Number
   /*
      || Retorna ultimo custo de entrada
      */
    Is
      Cursor Cr Is
         Select (Vlr_Tot_Mov / Qtde_Mov) Custo
           From Ce_Movest m
          Where Produto = Cod
            And Cod_Oper = 'REM'
            And Empresa = Emp
            And Filial = Fil
            And Dt_Mov = (Select Max(Dt_Mov)
                            From Ce_Movest M2
                           Where M2. Produto = m.Produto
                             And M2.Empresa = m.Empresa
                             And M2.Filial = m.Filial
                             And M2.Cod_Oper = m.Cod_Oper);
   
      v_Ret Number;
   Begin
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return Nvl(v_Ret, 0);
   
   End;
   --------------------------------------------------------
   Function Maior_Valor(Emp In Ce_Saldo.Empresa%Type,
                        Fil In Ce_Saldo.Filial%Type,
                        Cod In Ce_Produtos.Produto%Type) Return Number
   /*
      || Retorna o maior valor de entrada
      */
    Is
      Cursor Cr Is
         Select (Vlr_Tot_Mov / Qtde_Mov) Custo
           From Ce_Movest m
          Where Produto = Cod
            And Cod_Oper = 'REM'
            And Empresa = Emp
            And Filial = Fil
            And Vlr_Tot_Mov =
                (Select Max(Vlr_Tot_Mov)
                   From Ce_Movest M2
                  Where M2.Produto = m.Produto
                    And M2.Empresa = m.Empresa
                    And M2.Filial = m.Filial
                    And M2.Cod_Oper = m.Cod_Oper);
   
      v_Ret Number;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return Nvl(v_Ret, 0);
   
   End;
   --------------------------------------------------------
   Function Data_Ult_Custo(Emp In Ce_Saldo.Empresa%Type,
                           Fil In Ce_Saldo.Filial%Type,
                           Cod In Ce_Produtos.Produto%Type) Return Date
   /*
      || Retorna data ultimo custo de entrada
      */
    Is
      Cursor Cr Is
         Select Max(Dt_Mov)
           From Ce_Movest m
          Where Produto = Cod
            And Cod_Oper = 'REM'
            And Empresa = Emp
            And Filial = Fil;
   
      v_Ret Date;
   Begin
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return v_Ret;
   
   End;
   --------------------------------------------------------------------------------
   Function Tipo_Cpra_Grupo(Emp In Ce_Grupos.Empresa%Type,
                            Gr  In Ce_Grupos.Grupo%Type)
      Return Co_Tipos_Compra.Tipo_Compra%Type
   /*
      || Retorna TIPO DE COMPRA POR GRUPO
      */
    Is
   
      v_Cod Co_Tipos_Compra.Tipo_Compra%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select a.Tipo_Compra
           From Co_Aprov_Req a
          Where a.Empresa = Emp
            And a.Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
      Begin
         Select Tipo_Compra
           Into v_Cod
           From Co_Aprov_Req
          Where Empresa = Emp
            And Grupo = Gr;
      
         Return v_Cod;
      
      Exception
         When Others Then
            v_Cod   := Null;
            v_Grupo := Gr;
      End;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;
   --------------------------------------------------------------------------------
   Function Cod_Conta(Emp In Ce_Produtos.Empresa%Type,
                      Cod In Ce_Produtos.Produto%Type)
      Return Cg_Plano.Cod_Conta%Type
   /*
      || Retorna codigo contabil p/ o produto
      */
    Is
   
      v_Cod Cg_Plano.Cod_Conta%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Cod_Conta
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Cod_Conta, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;
   ------------------------------------------------------------------
   Function Cod_Fin(Emp In Ce_Grupos.Empresa%Type,
                    Gr  In Ce_Grupos.Grupo%Type) Return Fn_Plano.Cod_Fin%Type Is
      /*
         || Retorna conta financeira padrao p/ o grupo
      */
   
      v_Cod Fn_Plano.Cod_Fin%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Cod_Fin
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(Gr);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(Gr, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

   --------------------------------------------------------------------------------
   Function Cod_Fin(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Fn_Plano.Cod_Fin%Type
   /*
      || Retorna conta financeira padr?o p/ o produto
      */
    Is
   
      v_Cod Fn_Plano.Cod_Fin%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Cod_Fin
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Cod_Fin, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;
   ------------------------------------------------------------------
   Function Cod_Fin_Descr(p_Cta Fn_Plano.Cod_Fin%Type)
      Return Fn_Plano.Descricao%Type Is
   
      Cursor Cr Is
         Select Descricao From Fn_Plano Where Cod_Fin = p_Cta;
   
      v_Ret Fn_Plano.Descricao%Type;
   Begin
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return v_Ret;
   End;

   --------------------------------------------------------------------------------
   Function Pc_Difer(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type) Return Number
   /*
      || Retorna % diferenca maximo
      */
    Is
   
      v_Cod Number;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Pc_Difer
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Pc_Difer, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

   --------------------------------------------------------------------------------
   Function Estoque(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Estoque%Type
   /*
      || Retorna flag de produto estoque
      */
    Is
   
      v_Cod Ce_Produtos.Estoque%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Estoque
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Estoque, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

--------------------------------------------------------------------------------
   Function servico(Emp In Ce_Produtos.Empresa%Type,
                    Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.servico%Type
   /*
      || Retorna flag de produto servico
      */
    Is
   

      v_serv Ce_Produtos.servico%Type;   

   Begin
     v_serv := 'N';
     
      Select servico
        Into v_serv
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
         Return v_serv;
   
   Exception
   
      When Others Then
         Return v_serv;
      
   End;
   --------------------------------------------------------------------------------
   Function Alt_Desc(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Alt_Desc%Type
   /*
      || Retorna flag de alteracao descricao
      */
    Is
   
      v_Cod Ce_Produtos.Alt_Desc%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Alt_Desc
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Alt_Desc, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

   --------------------------------------------------------------------------------
   Function Area_Res(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Area_Res%Type
   /*
      || Retorna Area de resultado
      */
    Is
   
      v_Cod Ce_Produtos.Area_Res%Type;
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select Estoque
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
   
   Begin
   
      Select Area_Res, Grupo
        Into v_Cod, v_Grupo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
   
      If v_Cod Is Not Null Then
         Return v_Cod;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_Cod;
         Close Cr;
      
         Exit When v_Cod Is Not Null;
      End Loop;
   
      Return v_Cod;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

   --------------------------------------------------------------------------------
   Function Sld_Local_Filial(Emp In Ce_Produtos.Empresa%Type,
                             Fil In Ce_Saldo_Local.Filial%Type,
                             Cod In Ce_Produtos.Produto%Type,
                             Loc In Ce_Saldo_Local.Local%Type)
      Return Ce_Saldo_Local.Saldo_Fisico%Type
   /*
      || Retorna saldo fisico do produto no local de uma empresa e filial
      */
    Is
   
      Cursor Cr Is
         Select Saldo_Fisico
           From Ce_Saldo_Local
          Where Empresa = Emp
            And Filial = Fil
            And Local = Loc
            And Produto = Cod
          Order By Empresa, Filial, Local, Produto, Dt_Saldo Desc;
   
      v_Saldo Number;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Saldo;
      Close Cr;
      Return v_Saldo;
   
   Exception
   
      When Others Then
         Return 0;
      
   End;

   --------------------------------------------------------------------------------
   Function Desc_Produto(Emp In Ce_Produtos.Empresa%Type,
                         Pro In Ce_Produtos.Produto%Type) Return Varchar2
   /*
      || Retorna descricao do produto com suas caracteristicas
      */
   
    Is
      Cursor Curpro Is
         Select Descricao,
                To_Char(Prof * 100),
                To_Char(Larg * 100),
                To_Char(Comp * 100),
                Modelo,
                Cor
           From Ce_Produtos
          Where Empresa = Emp
            And Produto = Pro;
   
      v_Prof      Varchar2(200);
      v_Larg      Varchar2(200);
      v_Comp      Varchar2(200);
      v_Modelo    Ce_Produtos.Modelo%Type;
      v_Cor       Ce_Produtos.Cor%Type;
      v_Descricao Varchar2(4000);
   
   Begin
   
      Open Curpro;
      Fetch Curpro
         Into v_Descricao, v_Prof, v_Larg, v_Comp, v_Modelo, v_Cor;
      Close Curpro;
   
      If v_Prof Is Not Null Then
         v_Descricao := Rtrim(v_Descricao) || ' ' || Rtrim(v_Prof);
      End If;
   
      If v_Larg Is Not Null Then
         v_Descricao := Rtrim(v_Descricao) || ' x ' || Rtrim(v_Larg);
      End If;
   
      If v_Comp Is Not Null Then
         v_Descricao := Rtrim(v_Descricao) || ' x ' || Rtrim(v_Comp);
      End If;
   
      If v_Modelo Is Not Null Then
         v_Descricao := Rtrim(v_Descricao) || ' ' || Rtrim(v_Modelo);
      End If;
   
      If v_Cor Is Not Null Then
         v_Descricao := Rtrim(v_Descricao) || ' ' || Rtrim(v_Cor);
      End If;
   
      Return v_Descricao;
   
      /*
        SELECT descricao || ' ' || TO_CHAR( prof * 100 ) || 'x' || TO_CHAR( larg * 100 ) || 'x' || TO_CHAR( comp * 100 ) || ' ' || modelo || ' ' || cor
        INTO   v_campo
        FROM   CE_PRODUTOS
        WHERE  empresa = emp
        AND    produto = pro;
        RETURN v_campo;
      EXCEPTION
        WHEN OTHERS THEN
        RETURN '';
      */
   End;
   --------------------------------------------------------------------------------
   Function Local_Padrao(Emp In Ce_Uniprod.Empresa%Type,
                         Fil In Ce_Uniprod.Filial%Type,
                         Cod In Ce_Uniprod.Produto%Type)
      Return Ce_Uniprod.Loc_Padrao%Type
   /*
      || Retorna local padrao do produto
      */
    Is
   
      Cursor Cr Is
         Select Loc_Padrao
           From Ce_Uniprod
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod;
   
      Cursor Cr2 Is
         Select a.Local
           From Ce_Grupos a, Ce_Produtos b
          Where b.Empresa = Emp
            And a.Filial = Fil
            And b.Produto = Cod
            And a.Empresa = b.Empresa
            And a.Grupo = b.Grupo;
   
      v_Loc Ce_Uniprod.Loc_Padrao%Type;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Loc;
      Close Cr;
      If v_Loc Is Null Then
         Open Cr2;
         Fetch Cr2
            Into v_Loc;
         Close Cr2;
      End If;
   
      Return v_Loc;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;

   --------------------------------------------------------------------------------
   Function Local_Com_Saldo(Emp In Ce_Uniprod.Empresa%Type,
                            Fil In Ce_Uniprod.Filial%Type,
                            Cod In Ce_Uniprod.Produto%Type)
      Return Ce_Uniprod.Loc_Padrao%Type
   /*
      || Retorna local com maior saldo do produto
      */
    Is
   
      Cursor Cr Is
         Select Local, Saldo_Fisico
           From Ce_Saldo_Local l
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Cod
            And Dt_Saldo = (Select Max(Dt_Saldo)
                              From Ce_Saldo_Local L2
                             Where L2.Empresa = l.Empresa
                               And L2.Filial = l.Filial
                               And L2.Produto = l.Produto
                               And L2.Local = l.Local
                               And Dt_Saldo <= Sysdate)
          Order By 2 Desc;
   
      v_Loc   Ce_Uniprod.Loc_Padrao%Type;
      v_Saldo Number;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Loc, v_Saldo;
      Close Cr;
   
      Return v_Loc;
   
   Exception
   
      When Others Then
         Return Null;
      
   End Local_Com_Saldo;
   --------------------------------------------------------------------------------
   Function Cod_Clafis(Emp In Ce_Produtos.Empresa%Type,
                       Prd In Ce_Produtos.Produto%Type)
      Return Ft_Clafis.Cod_Clafis%Type Is
   
      v_Claf Ce_Produtos.Cod_Clafis%Type;
   
   Begin
   
      Select Cod_Clafis
        Into v_Claf
        From Ce_Produtos a
       Where a.Produto = Prd
         And a.Empresa = Emp;
   
      Return v_Claf;
   
   Exception
      When Others Then
         Return Null;
   End;
   --------------------------------------------------------------------------------
   Function Cod_Nbm(Emp In Ce_Produtos.Empresa%Type,
                    Prd In Ce_Produtos.Produto%Type)
      Return Ft_Clafis.Cod_Nbm%Type Is
   
      v_Claf Ce_Produtos.Cod_Clafis%Type;
      v_Nbm  Ft_Clafis.Cod_Nbm%Type;
   
   Begin
   
      Select Cod_Clafis
        Into v_Claf
        From Ce_Produtos a
       Where a.Produto = Prd
         And a.Empresa = Emp;
   
      If v_Claf Is Not Null Then
         Select Cod_Nbm
           Into v_Nbm
           From Ft_Clafis
          Where Cod_Clafis = v_Claf;
      Else
         v_Nbm := 0;
      End If;
      --/
      Return v_Nbm;
   
   Exception
      When Others Then
         Return 0;
   End;
   
   --------------------------------------------------------------------------------
   Function NCM_TO_COD(P_NCM FT_CLAFIS.COD_NBM%TYPE)
      Return Ft_Clafis.Cod_Clafis%Type Is
   
      v_Claf Ce_Produtos.Cod_Clafis%Type;
      v_Nbm  Ft_Clafis.Cod_Nbm%Type;
   
   Begin
         v_nbm := replace(replace(p_ncm,'.',''),'-','');
         Select Cod_Clafis
           Into v_Claf
           From Ft_Clafis
          Where replace(replace(Cod_nbm,'.',''),'-','') = v_nbm;
   
      Return v_Claf;
   
   Exception
      When Others Then
         Return null;
   End;
   ---------------------------------------
   Function Fn_Prod_Log(Emp  In Ce_Uniprod.Empresa%Type,
                        Pro  In Ce_Produtos.Produto%Type,
                        Acao Varchar2) Return Number Is
      /*
       cursor cr  is
        --select 1  from ce_produtos_log where empresa = emp  and
         --produto=pro and situacao=acao and sincronizado = 'N';
      */
   
      v_Aux1 Number;
      Pragma Autonomous_Transaction;
   Begin
      /*
       open cr;
         fetch cr into v_AUX1;
         close cr;
      */
      Return Nvl(v_Aux1, 0);
   End;

   ---------------------------------------------------------

   Function Fn_Registro_Prod(Emp   In Ce_Produtos.Empresa%Type,
                             Fil   In Cd_Filiais.Filial%Type,
                             Pro   In Ce_Produtos.Produto%Type,
                             p_Ini In Date,
                             p_Fim In Date) Return Char Is
      /*
        Verifica se produto existe saldo inicial ou se ouve movimentac?o no periodo
        para relatorio da produc?o
      */
   
      Cursor Cr(p_Dt Date) Is
         Select Round(Saldo_Fisico, 2)
           From Ce_Saldo
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Pro
            And Dt_Saldo <= p_Dt
          Order By Dt_Saldo Desc;
   
      Cursor Cr2 Is
         Select 'S'
           From Ce_Movest
          Where Empresa = Emp
            And Filial = Fil
            And Produto = Pro
            And Dt_Mov Between p_Ini And p_Fim
            And Rownum = 1;
   
      v_Saldo Number;
      v_Ret   Varchar2(1) := 'N';
   
   Begin
   
      Open Cr(p_Ini - 1);
      Fetch Cr
         Into v_Saldo;
      Close Cr;
   
      If v_Saldo > 0 Then
         v_Ret := 'S';
      End If;
   
      If v_Ret = 'N' Then
         Open Cr2;
         Fetch Cr2
            Into v_Ret;
         Close Cr2;
      End If;
   
      Return v_Ret;
   End;
   -----------------------------------------------------------------------------
   Function Fn_Produto_Ativo(Emp In Ce_Produtos.Empresa%Type,
                             Pro In Ce_Produtos.Produto%Type) Return Char Is
      Cursor Cr Is
         Select Situacao
           From Ce_Produtos
          Where Produto = Pro
            And Empresa = Emp;
   
      v_Ret Varchar2(1);
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return Nvl(v_Ret, 'S');
   
   End;
   -----------------------------------------------------------------------
   Function Fn_Grupo_Familia(Emp In Ce_Grupos.Empresa%Type,
                             Gr  In Ce_Grupos.Grupo%Type,
                             Niv In Number) Return Ce_Grupos.Grupo%Type Is
      Cursor Cr(Pe_Gr Ce_Grupos.Grupo%Type) Is
         Select Grupo
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = Pe_Gr;
   
      v_Gr  Ce_Grupos.Grupo%Type;
      v_Ret Ce_Grupos.Grupo%Type;
   
   Begin
      v_Gr  := Lib_Cniv.Cod_Nivel(Gr, Niv);
      v_Ret := Null;
      --/
      If v_Gr <> Gr Then
         Open Cr(v_Gr);
         Fetch Cr
            Into v_Ret;
         Close Cr;
      Else
         v_Ret := v_Gr;
      End If;
      --/
      Return v_Ret;
   End;

   -----------------------------------------------------------------------
   Function Fn_Grupo_Familia_Descr(Emp In Ce_Grupos.Empresa%Type,
                                   Gr  In Ce_Grupos.Grupo%Type,
                                   Niv In Number)
      Return Ce_Grupos.Descricao%Type Is
      Cursor Cr(Pe_Gr Ce_Grupos.Grupo%Type) Is
         Select Descricao
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = Pe_Gr;
   
      v_Gr  Ce_Grupos.Grupo%Type;
      v_Ret Ce_Grupos.Descricao%Type;
   
   Begin
      v_Gr  := Lib_Cniv.Cod_Nivel(Gr, Niv);
      v_Ret := Null;
      --/
      Open Cr(v_Gr);
      Fetch Cr
         Into v_Ret;
      Close Cr;
      --/
      Return v_Ret;
   End;

   -----------------------------------------------------------------------
   Function Fn_Descr_Geral_Grupo(Emp In Ce_Grupos.Empresa%Type,
                                 Gr  In Ce_Grupos.Grupo%Type,
                                 Niv In Number) Return Varchar2 Is
      Cursor Cr(Pe_Gr Ce_Grupos.Grupo%Type) Is
         Select Descricao
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = Pe_Gr;
   
      v_Gr  Ce_Grupos.Grupo%Type;
      v_Aux Varchar2(1000);
      v_Sep Varchar2(5);
      v_Ret Varchar2(1000);
      Idx   Number(4);
   
   Begin
   
      Idx := 1;
   
      While Idx <= Niv Loop
      
         v_Gr := Lib_Cniv.Cod_Nivel(Gr, Idx);
      
         Open Cr(v_Gr);
         Fetch Cr
            Into v_Aux;
         Close Cr;
      
         v_Ret := v_Ret || v_Sep || Rtrim(Ltrim(v_Aux));
         Idx   := Idx + 1;
         v_Sep := ' / ';
      
      End Loop;
   
      Return v_Ret;
   
   End;

   -----------------------------------------------------------------------
   Function Fn_Produto_Lead(Emp In Ce_Produtos.Empresa%Type,
                            Pro In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Leadtime%Type Is
      Cursor Cr Is
         Select Leadtime
           From Ce_Produtos
          Where Produto = Pro
            And Empresa = Emp;
   
      v_Ret Ce_Produtos.Leadtime%Type;
   
   Begin
   
      Open Cr;
      Fetch Cr
         Into v_Ret;
      Close Cr;
   
      Return Nvl(v_Ret, 0);
   
   End;

   ----------------------------------------------------------------------
   -------------------------------------------------------------------------------
   Function Leadtime(Emp In Ce_Produtos.Empresa%Type,
                     Cod In Ce_Produtos.Produto%Type)
      Return Ce_Produtos.Leadtime%Type
   /*
      || Retorna nome do produto
      */
    Is
   
      v_Campo Ce_Produtos.Leadtime%Type;
   
   Begin
   
      Select Leadtime
        Into v_Campo
        From Ce_Produtos
       Where Empresa = Emp
         And Produto = Cod;
      Return v_Campo;
   
   Exception
   
      When Others Then
         Return '';
      
   End;

   --|---------------------------------------------------------------------------------------
   procedure  atualiza_ncm(p_emp number,p_prod number, p_clafis number) is
     pragma autonomous_transaction;
     
   begin
       update ce_produtos 
         set cod_clafis = p_clafis
        where empresa = p_emp
          and produto = p_prod;

      commit;
           
   end;
   
   --|-----------------------------------------------------------------------------------------
   Function leadtime_followup(Emp In Ce_Produtos.Empresa%Type,
                             Cod In Ce_Produtos.Produto%Type)
       Return ce_grupos.lead_followup%Type
   /*
      || Retorna leadtime para followup de suprimentos do produto
   */
    Is
   
      
   
      Cursor Cr(g Ce_Grupos.Grupo%Type) Is
         Select lead_followup
           From Ce_Grupos
          Where Empresa = Emp
            And Grupo = g;
   
      v_Grupo Ce_Grupos.Grupo%Type;
      v_Nivel Ce_Grupos.Grupo%Type;
      n_Niv   Number;
      v_lead Ce_Grupos.lead_followup%Type;
   Begin
   
      Select d.valor LEADTIME_FOLLOWUP, Grupo
        Into v_lead, v_Grupo
        From Ce_Produtos p
           , (select d.empresa, d.produto, d.valor
               from ce_prod_dados d
               where d.codigo = 'LEADTIME_FOLLOWUP'
                 AND d.produto = cod
                 and d.empresa  = emp
             ) d
               
       Where p.Empresa = Emp
         And p.Produto = Cod
         and d.empresa(+) = p.empresa
         and d.produto(+) = p.produto;
   
      If v_lead Is Not Null Then
         Return v_lead;
      End If;
   
      -- Niveis do grupo
      n_Niv := Lib_Cniv.Nivel(v_Grupo);
   
      --| Para todos os niveis do grupo, comecando com o menor
      For n In Reverse 1 .. n_Niv Loop
      
         -- Acha o codigo neste nivel
         v_Nivel := Lib_Cniv.Cod_Nivel(v_Grupo, n);
      
         Open Cr(v_Nivel);
         Fetch Cr
            Into v_lead;
         Close Cr;
      
         Exit When v_lead Is Not Null;
      End Loop;
   
      Return v_lead;
   
   Exception
   
      When Others Then
         Return Null;
      
   End;   
   
   --|-------------------------------------------------------------------------------
   procedure gera_leadtime_followup_sup(Emp In Ce_Produtos.Empresa%Type,
                               Cod In Ce_Produtos.Produto%Type)

   is
   
   v_valor ce_grupos.lead_followup%type;
   v_grupo ce_grupos.grupo%type;
   begin
     
     v_valor := nvl(leadtime_followup(emp,cod),0);
     
     insert into ce_prod_dados(id,
                               empresa,
                               produto,
                               codigo,
                               descr,
                               valor,
                               origem)
                          values(ce_prod_dados_seq.nextval
                                , emp
                                ,cod
                                ,'LEADTIME_FOLLOWUP'
                                ,'LEADTIME PADRÃO DE FOLLOW-UP PARA SUPRIMENTOS'
                                ,v_valor
                                ,'A');
   exception
      when others then
          null;
   
   end;
   
   --/------------------------------------------------------------------------
   FUNCTION FNC_TBL_FT_ICMS_CTL (P_EMP  CE_PRODUTOS.EMPRESA%TYPE
                       ,P_PRD CE_PRODUTOs.PRODUTO%TYPE
                       ,P_CFO ft_icms_ctl.Cod_Cfo%TYPE
                       ,p_uf_orig ft_icms_ctl.Uf_Origem%TYPE
	                     ,p_uf_dest ft_icms_ctl.Uf_Destino%TYPE
                       )
                       RETURN ft_icms_ctl%ROWTYPE is

    CURSOR crPrd is
    select a.* 
      from ft_icms_ctl a
         , ft_clafis   b
         , ce_produtos c
     where c.cod_clafis = b.cod_clafis
       and a.cod_clafis = b.cod_clafis
       and a.cod_cfo   = P_cfo
       and c.produto   = P_PRD
       and c.empresa   = P_EMP
       and a.uf_origem = p_uf_orig
       and a.uf_origem = p_uf_dest ;
   
    CURSOR crNcm is
    select a.* 
      from ft_icms_ctl a
         , ft_clafis   b
         , ce_produtos c
     where c.cod_clafis = b.cod_clafis
       and a.cod_clafis = b.cod_clafis
       and a.cod_cfo   = P_cfo
       and c.produto   = P_PRD
       and c.empresa   = P_EMP
       and a.uf_origem = p_uf_orig
       and a.uf_origem = p_uf_dest ;
   
   V_RET ft_icms_ctl%ROWTYPE;
   begin
      return v_ret;
   end;
End Ce_Produtos_Utl;
/
