CREATE OR REPLACE Package fn_concl_utl Is

  --||
  --|| FN_CONCL.PKS : Utilitarios para Relatorio de Conciliacao
  --||

  Function tem_triplicata(emp fn_ctrec.empresa%Type,
                          fil fn_ctrec.filial%Type,
                          tit fn_ctrec.num_titulo%Type,
                          seq fn_ctrec.seq_titulo%Type,
                          prt fn_ctrec.parte%Type) Return fn_ctrec.valor%Type;
  Pragma Restrict_References(tem_triplicata, Wnds, Wnps);

  --------------------------------------------------------------------------------
  function retorna_valor_ofx(chave varchar2) return varchar2;
  function retorna_valor_ofx(texto varchar2, chave varchar2) return varchar2;
  function retorna_chave_ofx(texto varchar2) return varchar2;
  function dtofx_para_dt(dtofx varchar2) return date;
  --------------------------------------------------------------------------------
  Procedure processa_extrato(p_emp   fn_contas.empresa%Type,
                             p_banco fn_bancos.banco%Type,
                             p_agenc fn_contas.agencia%Type,
                             p_cta   fn_contas.conta_trans%Type);

  --------------------------------------------------------------------------------
  Procedure processa_extrato_ofx(p_emp   fn_contas.empresa%Type,
                                 p_banco fn_bancos.banco%Type,
                                 p_agenc fn_contas.agencia%Type,
                                 p_cta   fn_contas.conta_trans%Type);
End fn_concl_utl;
/
CREATE OR REPLACE Package Body fn_concl_utl Is

  --||
  --|| FN_CONCL.PKB : Utilitarios para Relatorio de Conciliacao
  --||

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
  
 --|variaveis
  --/ zera tods as variaveis
  Type tlinha_ofx Is Record(
    empresa   Number(9),
    v_agencia Varchar2(50),
    v_conta   Varchar2(50),
    v_trans   Varchar2(50),
    v_data    Varchar2(100),
    v_oper    Varchar2(100),
    v_hist    Varchar2(500),
    v_doc     Varchar2(30),
    v_dia     Date,
    v_valor   Number(15, 2),
    v_ind     varchar2(20),
    v_ind_ini number,
    v_ind_fim number,
    status    Varchar2(1));  
    
  reg_linha_ofx tlinha_ofx;    
    
  --|------------------------------
  Procedure pl_limpa_linha Is
  Begin
    --/ zera tods as variaveis
    reg_linha.v_dia_ant := reg_linha.v_dia;
    reg_linha.empresa   := Null;
    reg_linha.v_tipo    := Null;
    reg_linha.v_agencia := Null;
    reg_linha.v_conta   := Null;
    reg_linha.v_id      := Null;
    reg_linha.v_data    := Null;
    reg_linha.v_oper    := Null;
    reg_linha.v_hist    := Null;
    reg_linha.v_hist2   := Null;
    reg_linha.v_val     := Null;
    reg_linha.v_valc    := Null;
    reg_linha.v_vald    := Null;
    reg_linha.v_doc     := Null;
    --reg_linha.v_dia     := NULL;
    reg_linha.v_seq   := Null;
    reg_linha.v_dec   := Null;
    reg_linha.v_par   := Null;
    reg_linha.v_valor := Null;
    reg_linha.v_trans := Null;
    reg_linha.status  := Null;
  End;
--|------------------------------
  Procedure pl_limpa_linha_ofx Is
  Begin
    --/ zera tods as variaveis

    reg_linha_ofx.empresa   := Null;
    reg_linha_ofx.v_agencia := Null;
    reg_linha_ofx.v_conta   := Null;
--    reg_linha.v_id      := Null;
    reg_linha_ofx.v_data    := Null;
    reg_linha_ofx.v_oper    := Null;
    reg_linha_ofx.v_hist    := Null;
    --reg_linha_ofx.v_val     := Null;
    reg_linha_ofx.v_doc     := Null;
    reg_linha_ofx.v_dia     := NULL;
    reg_linha_ofx.v_valor := Null;
    reg_linha_ofx.v_trans := Null;
    reg_linha_ofx.v_ind := Null;
--    reg_linha.status  := Null;
  End;  
  ---------------------------------------------------------------------------------
  Procedure atualiza_status(p_ind Number) Is
  Begin
    Update t_fn_extrato t Set t.status = 'P' Where t.num_linha = p_ind;
  End;
  ---------------------------------------------------------------------------------
  Procedure atualiza_status_ofx(p_ind_ini Number, p_ind_fim Number) Is
  Begin
    Update t_fn_extrato t Set t.status = 'P' 
     Where t.num_linha between p_ind_ini and p_ind_fim;
  End;  
  --------------------------------------------------------------------------------
  Function tem_triplicata(emp fn_ctrec.empresa%Type,
                          fil fn_ctrec.filial%Type,
                          tit fn_ctrec.num_titulo%Type,
                          seq fn_ctrec.seq_titulo%Type,
                          prt fn_ctrec.parte%Type) Return fn_ctrec.valor%Type
  
   Is
    Cursor curtitulo Is
      Select 1, vl_total_rec
        From fn_ctrec
       Where empresa = emp
         And filial = fil
         And num_titulo = tit
         And seq_titulo > seq
         And parte = prt;
  
    nretorno       Number;
    nvalretorno    fn_ctrec.valor%Type;
    v_valor        fn_ctrec.valor%Type;
    v_situacao     fn_ctrec.situacao%Type;
    v_vl_total_rec fn_ctrec.vl_total_rec%Type;
    v_pos_bxren    fn_prgen.pos_bxren%Type;
  
  Begin
    -- Posicao Baixa Parcial
    Select pos_bxren Into v_pos_bxren From fn_prgen;
  
    -- Titulo Leitura
    Select valor, situacao
      Into v_valor, v_situacao
      From fn_ctrec
     Where empresa = emp
       And filial = fil
       And num_titulo = tit
       And seq_titulo = seq
       And parte = prt;
  
    -- Localiza Triplicata
    Open curtitulo;
    Fetch curtitulo
      Into nretorno, v_vl_total_rec;
    If curtitulo%Notfound Then
      -- Nao Tem Triplicata, Retorna Valor Titulo Leitura
      nvalretorno := v_valor;
    Else
      -- Tem Triplicata, Porem Foi Renegociacao, Retorna Valor Titulo Leitura
      If v_situacao = v_pos_bxren Then
        nvalretorno := v_valor;
      Else
        -- Tem Triplicata, Porem Foi Baixa Parcial, Retorna Valor Recebido
        nvalretorno := v_vl_total_rec;
      End If;
    End If;
    Close curtitulo;
  
    Return nvalretorno;
  
  End;
  --|----------------------------------------------------------------------
  Procedure pl_gera_linha Is
  
    CURSOR CR_RAZAO(P_DIA   DATE,
                    P_VALOR NUMBER,
                    P_OPER  VARCHAR2,
                    P_HIST  VARCHAR2,
                    P_DOC   VARCHAR2,
                    P_TRANS VARCHAR2) IS
      select 1
        from fn_razao a
       where a.empresa = reg_linha.empresa
         and a.conta = reg_linha.v_conta
         and a.data = p_dia
         and a.valor = p_valor
         and a.operacao = p_oper
         and a.historico = p_hist
         and a.documento = p_doc
         and (p_trans is  null or a.trans_banc = p_trans);
  
    v_seq   Number(9);
    V_ACHOU number(1) := 0;
  
  Begin
  
    If nvl(reg_linha.v_valor, 0) > 0 And reg_linha.status <> 'P' Then
    
      OPEN CR_RAZAO(reg_linha.V_DIA,
                    reg_linha.V_VALOR,
                    reg_linha.V_OPER,
                    reg_linha.V_HIST,
                    reg_linha.V_DOC,
                    reg_linha.V_TRANS);
      FETCH CR_RAZAO
        INTO V_ACHOU;
      CLOSE CR_RAZAO;
    
      IF NVL(V_ACHOU, 0) = 0 THEN
      
        Select fn_razao_seq.nextval Into v_seq From dual;
        Begin
          Insert Into fn_razao
            (empresa,
             conta,
             data,
             seq_mov,
             parte,
             valor,
             operacao,
             historico,
             documento,
             conciliado,
             trans_banc,
             num_linha,
             dt_incl,
             usuario)
          Values
            (reg_linha.empresa,
             reg_linha.v_conta,
             reg_linha.v_dia,
             v_seq,
             0, --reg_linha.v_par,
             reg_linha.v_valor,
             reg_linha.v_oper,
             substr(reg_linha.v_hist || ' ' || Trim(reg_linha.v_hist2),
                    1,
                    500),
             reg_linha.v_doc,
             'N',
             reg_linha.v_trans,
             reg_linha.v_ind,
             Sysdate,
             User);
        
          atualiza_status(reg_linha.v_ind);
        
        Exception
          When Others Then
            Null;
        End;
      end if;
    End If;
    pl_limpa_linha;
  End;
  
--|----------------------------------------------------------------------
  Procedure pl_gera_linha_ofx Is
  
    CURSOR CR_RAZAO(P_DIA   DATE,
                    P_VALOR NUMBER,
                    P_OPER  VARCHAR2,
                    P_HIST  VARCHAR2,
                    P_DOC   VARCHAR2,
                    P_TRANS VARCHAR2) IS
      select 1
        from fn_razao a
       where a.empresa = reg_linha.empresa
         and a.conta = reg_linha.v_conta
         and a.data = p_dia
         and a.valor = p_valor
         and a.operacao = p_oper
         and a.historico = p_hist
         and a.documento = p_doc
         and (p_trans is  null or a.trans_banc = p_trans);
  
    v_seq   Number(9);
    V_ACHOU number(1) := 0;
  
  Begin
  
    If nvl(reg_linha_ofx.v_valor, 0) > 0 And nvl(reg_linha_ofx.status,'V') <> 'P' Then
    
      OPEN CR_RAZAO(reg_linha_ofx.V_DIA,
                    reg_linha_ofx.V_VALOR,
                    reg_linha_ofx.V_OPER,
                    reg_linha_ofx.V_HIST,
                    reg_linha_ofx.V_DOC,
                    reg_linha_ofx.V_TRANS);
      FETCH CR_RAZAO
        INTO V_ACHOU;
      CLOSE CR_RAZAO;
    
      IF NVL(V_ACHOU, 0) = 0 THEN
      
        Select fn_razao_seq.nextval Into v_seq From dual;
        Begin
          Insert Into fn_razao
            (empresa,
             conta,
             data,
             seq_mov,
             parte,
             valor,
             operacao,
             historico,
             documento,
             conciliado,
             trans_banc,
             num_linha,
             dt_incl,
             usuario)
          Values
            (reg_linha_ofx.empresa,
             reg_linha_ofx.v_conta,
             reg_linha_ofx.v_dia,
             v_seq,
             0, --reg_linha.v_par,
             reg_linha_ofx.v_valor,
             reg_linha_ofx.v_oper,
             reg_linha_ofx.v_hist,
             reg_linha_ofx.v_doc,
             'N',
             reg_linha_ofx.v_trans,
             reg_linha_ofx.v_ind,
             Sysdate,
             User);
        
          atualiza_status_ofx(reg_linha_ofx.v_ind_ini, reg_linha_ofx.v_ind_fim);
        /*
        Exception
          When Others Then
            Null;
            */
        End;
      end if;
    End If;
    pl_limpa_linha_ofx;
  End;  
  --|-------------------------------
  procedure monta_registro(pLinha int) is
    Cursor cr_ext Is
      Select fn_concl_utl.retorna_chave_ofx(a.linha) chave, a.*
        From t_fn_extrato a
       where status = 'V'
         and a.num_linha > pLinha
       order by a.num_linha;
  
    v_dt_txt varchar2(20);
    v_vl_txt varchar2(20);
    v_dt date;
    
    v_sinal number;
    v_linha varchar2(1000);
    v_id_trans varchar2(20);
    v_debug varchar2(1000);
  begin
    
    pl_limpa_linha_ofx;
    
    for reg in cr_ext loop
      v_linha := reg.num_linha||'-'||reg.linha;
      v_debug := v_linha;
      
      -- se for final da transacao, encerra
      if instr(fn_concl_utl.retorna_chave_ofx(reg.linha) , '</STMTTRN>') > 0 then
        reg_linha_ofx.v_ind_fim := reg.num_linha;
        exit;
      --<FITID>N1011E
      --/ id da transacao
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha), '<FITID>') > 0  then
        v_id_trans := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                          '<FITID>');
      --/ operacao
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha),'<TRNTYPE>') > 0 then
        
        reg_linha_ofx.v_trans := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                                   '<TRNTYPE>');
                                                                   
        v_debug := 'operacao: '|| reg_linha_ofx.v_trans || '-' ||v_linha;
        if upper(reg_linha_ofx.v_trans) in( 'CREDIT','DEP') then
          reg_linha_ofx.v_oper := 'E';
          v_sinal := 1;
        else
          reg_linha_ofx.v_oper := 'S';
          v_sinal := -1;
        end if;
    
      --/ data movto
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha) , '<DTPOSTED>') > 0  then
        v_dt_txt        := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                          '<DTPOSTED>');
        v_dt := to_date(substr(v_dt_txt, 1, 8), 'yyyymmdd');
        reg_linha_ofx.v_dia := v_dt;
    
      --/ valor
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha) , '<TRNAMT>')> 0  then

        v_vl_txt        := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                          '<TRNAMT>');
        v_debug := 'valor: '|| v_vl_txt || '-' ||v_linha;
        v_vl_txt := replace(v_vl_txt,'.',',');
        reg_linha_ofx.v_valor := to_number(v_vl_txt) * v_sinal;
       -- v_debug := 'valor(2): '|| v_vl_txt || '-' ||v_linha;
       -- v_vl_txt := to_number('1a'); -- provocar erro
      --/ documento
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha) , '<CHECKNUM>')> 0  then
        reg_linha_ofx.v_doc := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                          '<CHECKNUM>');
    
      --/ historico
      elsif instr(fn_concl_utl.retorna_chave_ofx(reg.linha) , '<MEMO>')> 0  then
        reg_linha_ofx.v_hist := fn_concl_utl.retorna_valor_ofx(reg.linha,
                                                           '<MEMO>');
      end if;
    
    --, fn_concl_utl.retorna_valor_ofx(a.linha,'<FITID>') FITID       
    end loop;
  exception 
    when others then
      raise_application_error(-20200,v_debug);
  end;
  --|----------------------------------------------------------------------

  Function processa_linha(p_emp         fn_razao.empresa%Type,
                          p_cd_agencia  fn_agencias.agencia%Type,
                          p_conta_trans fn_contas.conta_trans%Type,
                          linha         Varchar2,
                          r_par         fn_cnab1%Rowtype,
                          p_ind         Number) Return Number Is
  
    CURSOR CR_RAZAO(P_DIA   DATE,
                    P_VALOR NUMBER,
                    P_OPER  VARCHAR2,
                    P_HIST  VARCHAR2,
                    P_DOC   VARCHAR2,
                    P_TRANS VARCHAR2) IS
      select 1
        from fn_razao a
       where a.empresa = p_emp
         and a.conta = p_conta_trans
         and a.data = p_dia
         and a.valor = p_valor
         and a.operacao = p_oper
         and a.historico = p_hist
         and a.documento = p_doc
         and a.trans_banc = p_trans;
  
    v_id    Varchar2(50);
    v_data  Varchar2(100);
    v_oper  Varchar2(100);
    v_hist  Varchar2(500);
    v_hist2 Varchar2(100);
    v_val   Varchar2(100);
    v_doc   Varchar2(30);
    v_dia   Date;
    v_seq   fn_razao.seq_mov%Type;
    v_dec   Number;
    -- CD_AGENCIA VarChar2(7);
    v_par   Number;
    v_valor Number(15, 2);
    v_trans fn_razao.trans_banc%Type;
    v_cabec Number := 0;
    --|
    v_tipo    Varchar2(20);
    v_agencia Varchar2(50);
    v_conta   Varchar2(50);
    v_id      Varchar2(50);
    v_ind     Number(9);
    v_achou   number(1) := 0;
    /*
        if n = 1  then
          message('Arquivo n?o veio da agencia atual');
        elsif n = 2 then 
          message('Arquivo n?o veio da conta atual');
        elsif n = 3 then
          message('Arquivo n?o esta no formato do banco');
        elsif n = 4 then
          message('Conta Extrato Eletronico N?o Encontrada');
        elsif n = 5 then
          message('Inconsistencias de parametros entre conta/agencia/tipo/operac?o. Linha ' || to_char( v_conta2 ));
        elsif n = 9 then
          message('Erro na importac?o/inclus?o da linha do arquivo de concialiac?o');
        end if;  
    */
  
  Begin
    v_ind  := p_ind;
    v_data := rtrim(substr(linha,
                           r_par.data1,
                           r_par.data2 - r_par.data1 + 1));
    If v_data Is Not Null And lib_util.is_date(v_data) = 'S' Then
    
      v_hist  := rtrim(substr(linha,
                              r_par.hist1,
                              r_par.hist2 - r_par.hist1 + 1));
      v_hist2 := rtrim(substr(linha,
                              r_par.compl1,
                              r_par.compl2 - r_par.compl1 + 1));
      v_hist  := v_hist || ' - ' || v_hist2;
      v_val   := rtrim(ltrim(substr(linha,
                                    r_par.val1,
                                    r_par.val2 - r_par.val1 + 1)));
      v_doc   := (rtrim(substr(linha,
                               r_par.doc1,
                               r_par.doc2 - r_par.doc1 + 1)));
    
      v_trans := (rtrim(substr(linha,
                               r_par.trans_bc1,
                               r_par.trans_bc2 - r_par.trans_bc1 + 1)));
    
      v_oper := rtrim(substr(linha,
                             r_par.oper1,
                             r_par.oper2 - r_par.oper1 + 1));
      If rtrim(v_oper) = r_par.oper_e Then
        v_oper := 'E';
      Elsif rtrim(v_oper) = r_par.oper_s Then
        v_oper := 'S';
      Elsif rtrim(v_oper) = r_par.oper_a Then
        v_oper := 'A';
      Elsif rtrim(v_oper) = r_par.oper_r Then
        v_oper := 'R';
      Elsif rtrim(v_oper) = r_par.oper_t Then
        v_oper := 'T';
      Elsif rtrim(v_oper) = r_par.oper_d Then
        v_oper := 'D';
      End If;
    
      v_dia := to_date(v_data, r_par.frm_data);
      v_dec := r_par.dec_valor;
      If v_dec = 0 Then
        v_dec := 1;
      Else
        v_dec := 10 ** v_dec;
      End If;

      v_valor := (to_number(Replace(Replace(v_val, ',', ''), '.', '')) /
                 v_dec);

      If nvl(v_valor, 0) <> 0 Then
        Begin
          --/ retira zeros do inicio do docto
          v_doc := to_char(to_number(v_doc));
        Exception
          When Others Then
            Null;
        End;
      
        V_ACHOU := 0;
      
        OPEN CR_RAZAO(V_DIA, V_VALOR, V_OPER, V_HIST, V_DOC, V_TRANS);
        FETCH CR_RAZAO
          INTO V_ACHOU;
        CLOSE CR_RAZAO;
      
        IF NVL(V_ACHOU, 0) = 0 THEN
          Select fn_razao_seq.nextval Into v_seq From dual;
          Begin
            Insert Into fn_razao
            Values
              (p_emp --EMPRESA    NUMBER(9)    
              ,
               p_conta_trans --CONTA      VARCHAR2(30) 
              ,
               v_dia --DATA       DATE         
              ,
               v_seq --SEQ_MOV    NUMBER(9)    
              ,
               0 --v_par -- PARTE      NUMBER(9)    
              ,
               v_valor --VALOR      NUMBER(15,2) 
              ,
               v_oper --OPERACAO   CHAR(1)      
              ,
               v_hist --HISTORICO  VARCHAR2(500)
              ,
               v_doc --DOCUMENTO  VARCHAR2(30) 
              ,
               'N' --CONCILIADO CHAR(1)      
              ,
               v_trans --TRANS_BANC VARCHAR2(30) 
              ,
               p_ind --NUM_LINHA  NUMBER(6)    
              ,
               Sysdate --DT_INCL    DATE         
              ,
               User); --USUARIO    VARCHAR2(30) 
          
            atualiza_status(v_ind);
          Exception
            When Others Then
              Null;
              v_ind := Null;
          End;
        END IF;
      End If;
    Else
      atualiza_status(v_ind);
    End If;
    --end if;
    Return 0;
    /*
    exception
    
       when others then
          raise_application_error(-20100,
                                  sqlerrm);
          return 9;
       */
  End;
  --|--------------------------------------------------------------------------------
  Function processa_linha_brad(p_emp         fn_razao.empresa%Type,
                               p_cd_agencia  fn_agencias.agencia%Type,
                               p_conta_trans fn_contas.conta_trans%Type,
                               linha         Varchar2,
                               r_par         fn_cnab1%Rowtype,
                               p_ind         Number,
                               p_adic        Number) Return Number Is
  
    v_data     Varchar2(30);
    v_tipo     Varchar2(20);
    v_agencia  Varchar2(50);
    v_conta    Varchar2(50);
    v_id       Varchar2(50);
    v_data_aux Varchar2(100);
    v_oper     Varchar2(100);
    v_hist     Varchar2(500);
    v_hist2    Varchar2(100);
    v_val      Varchar2(100);
    v_valc     Varchar2(100);
    v_vald     Varchar2(100);
    v_doc      Varchar2(30);
    v_dia      Date;
    v_seq      fn_razao.seq_mov%Type;
    v_dec      Number;
    -- CD_AGENCIA VarChar2(7);
    v_par   Number;
    v_valor Number(15, 2);
    v_trans fn_razao.trans_banc%Type;
    v_fim   Boolean;
    v_achou number(1) := 0;
  
  Begin
  
    v_tipo := substr(linha,
                     r_par.ind1 + p_adic,
                     r_par.ind2 - r_par.ind1 + 1);
  
    v_agencia := p_cd_agencia;
    v_conta   := p_conta_trans;
  
    v_tipo := v_tipo;
  
    v_id := v_id;
    --v_data2 := v_data;
  
    v_valc := rtrim(ltrim(substr(linha,
                                 r_par.val1 + p_adic,
                                 r_par.val2 - r_par.val1 + 1)));
    v_vald := rtrim(ltrim(substr(linha,
                                 r_par.val3 + p_adic,
                                 r_par.val4 - r_par.val3 + 1)));
    v_valc := v_valc;
    v_vald := v_vald;
    v_fim  := False;
    If v_valc Is Not Null And v_vald Is Not Null Then
      v_fim := True;
    Elsif v_valc Is Not Null Then
      v_val  := v_valc;
      v_oper := r_par.oper_e;
    Else
      v_val  := v_vald;
      v_oper := r_par.oper_s;
    End If;
    v_oper := v_oper;
    v_val  := v_val;
    v_doc  := (rtrim(substr(linha,
                            r_par.doc1 + p_adic,
                            r_par.doc2 - r_par.doc1 + 1)));
    If Not v_fim Then
    
      v_trans := (rtrim(substr(linha,
                               r_par.trans_bc1 + p_adic,
                               r_par.trans_bc2 - r_par.trans_bc1 + 1)));
      v_trans := v_trans;
    
      If rtrim(v_oper) = r_par.oper_e Then
        v_oper := 'E';
      Elsif rtrim(v_oper) = r_par.oper_s Then
        v_oper := 'S';
      Elsif rtrim(v_oper) = r_par.oper_a Then
        v_oper := 'A';
      Elsif rtrim(v_oper) = r_par.oper_r Then
        v_oper := 'R';
      Elsif rtrim(v_oper) = r_par.oper_t Then
        v_oper := 'T';
      Elsif rtrim(v_oper) = r_par.oper_d Then
        v_oper := 'D';
      End If;
    
      v_dec := r_par.dec_valor;
    
      v_hist := rtrim(substr(linha,
                             r_par.hist1 + p_adic,
                             r_par.hist2 - r_par.hist1 + 1));
      v_hist := v_hist;
    
      v_hist2 := v_hist2;
      v_dia   := v_dia;
    
      If v_dec = 0 Then
        v_dec := 1;
      Else
        v_dec := 10 ** v_dec;
      End If;
      v_dec := v_dec;
    
      v_val   := Replace(Replace(v_val, '.', ''), ',', '');
      v_valor := (to_number(v_val) / v_dec);
      v_valor := v_valor;
    
      If nvl(v_valor, 0) > 0 Then
        Begin
          --/ retira zeros do inicio do docto
          v_doc := to_char(to_number(v_doc));
        Exception
          When Others Then
            Null;
        End;
      
        --/ PL_GERA_LINHA
        /*
         select fn_razao_seq.nextval
           into v_seq
           from dual;
        */
        reg_linha.empresa := p_emp;
        reg_linha.v_conta := p_conta_trans;
        reg_linha.v_par   := 0;
        reg_linha.v_valor := v_valor;
        reg_linha.v_oper  := v_oper;
        reg_linha.v_hist  := v_hist;
        reg_linha.v_doc   := v_doc;
        reg_linha.v_trans := v_trans;
        reg_linha.v_ind   := p_ind;
      
        /*
        insert into fn_razao
        values
           (p_emp --EMPRESA    NUMBER(9)    
           ,p_conta_trans --CONTA      VARCHAR2(30) 
           ,v_dia --DATA       DATE         
           ,v_seq --SEQ_MOV    NUMBER(9)    
           ,0 --v_par -- PARTE      NUMBER(9)    
           ,v_valor --VALOR      NUMBER(15,2) 
           ,v_oper --OPERACAO   CHAR(1)      
           ,v_hist --HISTORICO  VARCHAR2(500)
           ,v_doc --DOCUMENTO  VARCHAR2(30) 
           ,'N' --CONCILIADO CHAR(1)      
           ,v_trans --TRANS_BANC VARCHAR2(30) 
           ,p_ind --NUM_LINHA  NUMBER(6)    
           ,SYSDATE --DT_INCL    DATE         
           ,USER); --USUARIO    VARCHAR2(30) 
           */
      End If;
    End If;
  
    Return 0;
  
  Exception
  
    When Others Then
      Return 9;
    
  End;

  --------------------------------------------------------------------------------
  Procedure processa_extrato(p_emp   fn_contas.empresa%Type,
                             p_banco fn_bancos.banco%Type,
                             p_agenc fn_contas.agencia%Type,
                             p_cta   fn_contas.conta_trans%Type) Is
    Cursor cr Is
      Select * From fn_cnab1 Where banco = p_banco;
  
    Cursor cr_ext Is
      Select * From t_fn_extrato where status = 'V' Order By 1;
  
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
  
    Open cr;
    Fetch cr
      Into r_par;
    If cr%Notfound Then
      Close cr;
      raise_application_error(-20100,
                              'Recepc?o do Extrato' || 'Dados do banco ' ||
                              p_banco || ' n?o encontrados');
      Return;
    End If;
    Close cr;
  
    Begin
      If p_banco = 237 Then
        v_adic := nvl(r_par.deslocamento, 0);
        For reg In cr_ext Loop

          v_debug   := '1-Linha:' || reg.num_linha;
          linha     := reg.linha;
          v_conta2  := reg.num_linha;
          v_doc_aux := Null;
        
          v_debug := '2-Linha:' || reg.num_linha || ' # ' ||
                     r_par.linha_movto;
        
          If reg.num_linha >= r_par.linha_movto Then
            v_debug   := '3-Linha:';
            v_debug   := '3-0-Linha:' || nvl(r_par.data1, 0) || ' - ' ||
                         nvl(r_par.data2, 0); -- || ' - ' || r_par.data1 + 1;
            v_val_aux := Null;
            v_val_aux := rtrim(ltrim(substr(linha,
                                            r_par.val1 + v_adic,
                                            r_par.val2 + v_adic - r_par.val1 +
                                            v_adic + 1)));
            If v_val_aux Is Null Then
              v_val_aux := rtrim(ltrim(substr(linha,
                                              r_par.val3 + v_adic,
                                              r_par.val4 + v_adic -
                                              r_par.val3 + v_adic + 1)));
            End If;
          
            v_data_aux := Null;
            v_data_aux := rtrim(substr(linha,
                                       r_par.data1 + v_adic,
                                       r_par.data2 - r_par.data1 + 1));
            v_data_aux := Trim(v_data_aux);
            v_debug    := '3-2Linha:';
            If v_data_aux Is Null Then
              v_data_aux := to_char(reg_linha.v_dia_ant, r_par.frm_data);
            End If;
            v_debug := '3-33Linha:';
            If v_val_aux Is Not Null Then
              --reg_linha.v_dia is null then
              If lib_util.is_date(v_data_aux) = 'S' Then
              
                If v_val_aux Is Not Null And reg_linha.v_valor Is Not Null Then
                  If reg_linha.v_dia Is Null Then
                    reg_linha.v_dia := reg_linha.v_dia_ant;
                  End If;
                  v_debug := '3-9-0Linha:';
                  pl_gera_linha;
                  v_debug := '3-9-0-1Linha:';
                End If;
              
                reg_linha.v_dia  := to_date(v_data_aux, r_par.frm_data);
                reg_linha.v_data := reg_linha.v_dia;
              
                reg_linha.status := reg.status;
                v_debug          := '4-Linha:';
                n                := processa_linha_brad(p_emp,
                                                        p_agenc,
                                                        p_cta,
                                                        linha,
                                                        r_par,
                                                        reg.num_linha,
                                                        v_adic);
                v_debug          := '5-Linha:';
              Else
                v_debug := '3-9Linha:';
                atualiza_status(reg.num_linha);
                v_debug := '3-9-1Linha:';
              End If;
            
            Elsif nvl(reg_linha.v_valor, 0) Is Not Null Then
              v_debug           := '5-Linha:';
              reg_linha.v_hist2 := substr(reg_linha.v_hist2 || ' ' ||
                                          Trim(rtrim(substr(linha,
                                                            r_par.compl1 +
                                                            v_adic,
                                                            r_par.compl2 +
                                                            v_adic -
                                                            r_par.compl1 +
                                                            v_adic + 1))),
                                          1,
                                          1000);
              v_debug           := '5-1Linha:';
              --pl_gera_linha;
              atualiza_status(reg.num_linha);
            End If;
          
          End If;
        
        End Loop;
        --gera linha
        pl_gera_linha;
      Else
        For reg In cr_ext Loop
          If reg.num_linha >= r_par.linha_movto Then
            If reg.status != 'P' Then
              --|checar se e final do extrato
              v_fim := rtrim(substr(linha,
                                    r_par.hist1,
                                    r_par.hist2 - r_par.hist1 + 1));
              If p_banco = '001' /*banco do brasil*/
               Then
                If Trim(upper(v_fim)) = 'SALDO' Then
                  Exit;
                End If;
              End If;
            
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
                                      '(1)Arquivo n?o veio da agencia atual');
            Elsif n = 2 Then
              raise_application_error(-20103,
                                      '(2)Arquivo n?o veio da conta atual');
            Elsif n = 3 Then
              raise_application_error(-20104,
                                      '(3)Arquivo n?o esta no formato do banco');
            Elsif n = 4 Then
              raise_application_error(-20105,
                                      '(4)Conta Extrato Eletronico N?o Encontrada');
            Elsif n = 5 Then
              raise_application_error(-20106,
                                      '(5)Inconsistencias de parametros entre conta/agencia/tipo/operac?o. Linha ' ||
                                      to_char(v_conta2));
            Elsif n = 8 Then
              raise_application_error(-20107,
                                      '(8)Erro: mais de 10 linhas lida e nao achou conta');
            Elsif n = 9 Then
              raise_application_error(-20108,
                                      '(9)Erro na importac?o/inclus?o da linha do arquivo de concialiac?o');
            
            End If;
            Exit;
          End If;
        End Loop;
      End If;
    End;
    Commit;
    /*
    Exception
       When Others Then
          raise_application_error(-20101,
                                  v_debug || ' - ' || linha);
                                  */
    /*
      -- usado no caso do bradesco
          if v_doc is not null then
             pl_gera_linha (V_CONTA2, v_conta );
             v_conta1 := nvl(v_conta1,0) + nvl(v_conta,0);
             --/ zera tods as variaveis com excec?o da agencia/conta
             PL_LIMPA_VAR;    
          end if;
    */
  End;

  function retorna_valor_ofx(chave varchar2) return varchar2 is
  
    cursor cr(pchave varchar2) is
      select linha
        from T_FN_EXTRATO
       where status != 'P'
         and ltrim(linha) like pchave
       order by num_linha;
  
    retorno varchar2(1000);
   retorno2 varchar2(1000);
  begin
    --   <BANKID>
    open cr('%'||chave || '%');
    fetch cr
      into retorno;
    close cr;
 
    --retorno2 := retorno;
    if retorno is not null then
      retorno := trim(substr(trim(retorno), instr(retorno,chave)+length(chave)));

    end if;
    /*
   if chave = '<BANKID>' then
    raise_application_error(-20100, retorno2||'-'||length(retorno2) ||'-'||retorno);
  end if;    
  */
    return trim(retorno);
  end;

  function retorna_valor_ofx(texto varchar2, chave varchar2) return varchar2 is
    retorno varchar2(1000);
    pos     int := 0;
  begin
    --   <BANKID>
    pos := instr(texto, chave);
    if pos > 0 then
      retorno := substr(texto, pos + 1);
    end if;
  
    if retorno is not null then
      retorno := trim(substr(retorno, length(chave)));
    
    end if;
    return trim(retorno);
  end;

  function retorna_chave_ofx(texto varchar2) return varchar2 is
    retorno varchar2(1000);
    pos     int := -1;
  begin
    pos := instr(texto, '>');
    if pos > 0 then
      retorno := substr(texto, 0, pos);
    end if;
  
    return trim(retorno);
  end;

  function dtofx_para_dt(dtofx varchar2) return date is
    retorno date;
  begin
    if dtofx is not null then
      --20190321120000
      retorno := to_date(substr(dtofx, 1, 8), 'yyyymmdd');
    end if;
    return retorno;
  end;
  --------------------------------------------------------------------------------
  Procedure processa_extrato_ofx(p_emp   fn_contas.empresa%Type,
                                 p_banco fn_bancos.banco%Type,
                                 p_agenc fn_contas.agencia%Type,
                                 p_cta   fn_contas.conta_trans%Type) Is
  
    Cursor cr_ext Is
      Select fn_concl_utl.retorna_chave_ofx(a.linha) chave, a.*
        From t_fn_extrato a
       where status in ( 'V') --,'P')
         and fn_concl_utl.retorna_chave_ofx(a.linha) is not null
       order by a.num_linha;
  
  cursor crCta is
    select * from fn_contas c 
            where c.empresa = p_emp
              and c.banco = p_banco
              and c.conta = p_cta;
    --/-------------------------------
    
    reg_cta fn_contas%rowtype;
    v_banco varchar2(4);
    v_banco_extrato varchar2(20);
    v_cta_extrato varchar2(20);
  Begin

    open crCta;
    fetch crCta into reg_cta;
    close crCta;
    
    v_banco := reg_cta.banco ;
    if lib_util.is_numeric(v_banco) = 'S' then
      v_banco := lpad(v_banco,4,'0');
    end if;
    
                        
   v_banco_extrato := fn_concl_utl.retorna_valor_ofx('<BANKID>'); 
   if lib_util.is_numeric(v_banco_extrato) = 'S' then
      v_banco_extrato := lpad(v_banco_extrato,4,'0');
    end if;
    
   v_cta_extrato := fn_concl_utl.retorna_valor_ofx('<ACCTID>');            
   
    if v_banco_extrato != v_banco or
       v_cta_extrato   != reg_cta.cod_conta then
      raise_application_error(-20100,
      p_emp  ||' - '||
      p_banco ||' - '||
      p_agenc ||' - '||
      p_cta  ||' - '||
     'Banco('||v_banco_extrato||')('||v_banco||')/Conta-[cod_conta]('||v_cta_extrato||')('||reg_cta.cod_conta||')'||', não conferem com extrato importado!');
    end if;
  
    For reg In cr_ext Loop
      --checa se linha e inicio de uma transacao
      if instr(fn_concl_utl.retorna_chave_ofx(reg.linha), '<STMTTRN>') > 0  then
       /*
    raise_application_error(-20100, fn_concl_utl.retorna_valor_ofx('<BANKID>')  ||' - '||
                                 v_banco ||' - '||
                                 fn_concl_utl.retorna_valor_ofx('<ACCTID>') ||' - '||
                                 reg_cta.cod_conta);
      */       
        monta_registro(reg.num_linha);
        
        reg_linha_ofx.v_ind_ini := reg.num_linha;
        reg_linha_ofx.empresa   := p_emp;
        reg_linha_ofx.v_agencia := p_agenc;
        reg_linha_ofx.v_conta   := p_cta; 
        reg_linha_ofx.v_ind     := reg.num_linha;

        pl_gera_linha_ofx;
        
      end if;
    End Loop;
  
    Commit;
    /*
    , fn_concl_utl.retorna_valor_ofx(a.linha,'<BANKID>') banco
    , fn_concl_utl.retorna_valor_ofx(a.linha,'<ACCTID>') cta
    , fn_concl_utl.retorna_valor_ofx(a.linha,'<DTSTART>') dt_inicio
    , fn_concl_utl.retorna_valor_ofx(a.linha,'<DTEND>') dt_fim
    --/
    */
  
  End;

End fn_concl_utl;
/
