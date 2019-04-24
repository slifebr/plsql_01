CREATE OR REPLACE Procedure processa_extrato_ofx(p_emp   fn_contas.empresa%Type,
                                 p_banco fn_bancos.banco%Type,
                                 p_agenc fn_contas.agencia%Type,
                                 p_cta   fn_contas.conta_trans%Type) Is
--|variaveis
  --/ zera tods as variaveis
  Type tlinha Is Record(
    empresa   Number(9),
    v_tipo    Varchar2(20),
    v_agencia Varchar2(50),
    v_conta   Varchar2(50),
    v_trans   Varchar2(50),
    v_id      Varchar2(50),
    v_data    Varchar2(100)
    
    ,
    v_oper    Varchar2(100),
    v_hist    Varchar2(500),
    v_hist2   Varchar2(1000),
    v_val     Varchar2(100),
    v_valc    Varchar2(100),
    v_vald    Varchar2(100),
    v_doc     Varchar2(30),
    v_dia     Date,
    v_dia_ant Date,
    v_seq     Number(9),
    v_dec     Number,
    v_par     Number,
    v_valor   Number(15, 2),
    v_ind     Number,
    status    Varchar2(1));

  reg_linha tlinha;
  
    Cursor cr Is
      Select * From fn_cnab1 Where banco = p_banco;

    Cursor cr_ext Is
      Select fn_concl_utl.retorna_chave_ofx(a.linha) chave,
             a.*
        From t_fn_extrato_ofx a
       where status = 'V'
         and fn_concl_utl.retorna_chave_ofx(a.linha) is not null
       order by a.num_linha;

    linha Varchar2(1800);
    r_par fn_cnab1%Rowtype;
    n     Number;

    v_linha Number;

    v_conta1  Number;
    v_conta2  Number;
    v_doc_aux Varchar2(30);
    v_cabec   Varchar2(100);
    ---|
    v_tipo     Varchar2(20);
    v_agencia  Varchar2(50);
    v_conta    Varchar2(50);
    v_trans    Varchar2(50);
    v_id       Varchar2(50);
    v_data_aux Varchar2(100);
    v_oper     Varchar2(100);
    v_hist     Varchar2(500);
    v_hist2    Varchar2(100);
    v_fim      Varchar2(500);
    v_val      Varchar2(100);
    v_valc     Varchar2(100);
    v_vald     Varchar2(100);
    v_doc      Varchar2(30);
    v_dia      Date;
    v_seq      fn_razao.seq_mov%Type;
    v_dec      Number;
    -- CD_AGENCIA VarChar2(7);
    v_par     Number;
    v_valor   Number(15, 2);
    v_val_aux Varchar2(30);
    v_debug   Varchar2(30);
    v_adic    Number(4);
    --|-------------------------------
  Begin
    if fn_concl_utl.retorna_valor_ofx('<BANKID>') != p_banco or
       fn_concl_utl.retorna_valor_ofx('<ACCTID>') != p_cta then
       raise_application_error (-20100,'Banco/Conta(Código Interno), não conferem com extrato importado!');
    end if;
    /*
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<BANKID>') banco
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<ACCTID>') cta
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<DTSTART>') dt_inicio
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<DTEND>') dt_fim
     --/
     */
    For reg In cr_ext Loop
      null;
    /*

     , fn_concl_utl.retorna_valor_ofx(a.linha,'<TRNTYPE>') operacao
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<DTPOSTED>') dt_movto
     , (fn_concl_utl.retorna_valor_ofx(a.linha,'<TRNAMT>')) valor
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<FITID>') FITID
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<CHECKNUM>') docto
     , fn_concl_utl.retorna_valor_ofx(a.linha,'<MEMO>') historico
     */
      /*
      If reg.num_linha >= r_par.linha_movto Then
        If reg.status != 'P' Then
          --|checar se é final do extrato
          v_fim := rtrim(substr(linha,
                                r_par.hist1,
                                r_par.hist2 - r_par.hist1 + 1));

          linha := reg.linha;
          n     := processa_linha(p_emp,
                                  p_agenc,
                                  p_cta,
                                  linha,
                                  r_par,
                                  reg.num_linha);

        End If;
      End If;
      If nvl(n, 0) > 0 Then
        If n = 1 Then
          raise_application_error(-20102,
                                  '(1)Arquivo não veio da agencia atual');
        Elsif n = 2 Then
          raise_application_error(-20103,
                                  '(2)Arquivo não veio da conta atual');
        Elsif n = 3 Then
          raise_application_error(-20104,
                                  '(3)Arquivo não esta no formato do banco');
        Elsif n = 4 Then
          raise_application_error(-20105,
                                  '(4)Conta Extrato Eletrônico Não Encontrada');
        Elsif n = 5 Then
          raise_application_error(-20106,
                                  '(5)Inconsistências de parâmetros entre conta/agencia/tipo/operação. Linha ' ||
                                  to_char(v_conta2));
        Elsif n = 8 Then
          raise_application_error(-20107,
                                  '(8)Erro: mais de 10 linhas lida e nao achou conta');
        Elsif n = 9 Then
          raise_application_error(-20108,
                                  '(9)Erro na importação/inclusão da linha do arquivo de concialiação');

        End If;
        Exit;
      End If;
      */
    End Loop;

    Commit;

  End;
/
