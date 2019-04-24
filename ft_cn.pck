create or replace package ft_cn is

--||
--|| Funcao : Pacote para cancelamento de notas fiscais
--||

procedure cancela_nota(emp  in  ft_notas.empresa%type,
                       fil  in  ft_notas.filial%type,
                       num  in  ft_notas.num_nota%type,
                       ser  in  ft_notas.sr_nota%type,
                       dta  in  date,
                       par  in  number
                      );
procedure cancela_devol(emp  in  ft_devol.empresa%type,
                        fil  in  ft_devol.filial%type,
                        num  in  ft_devol.num_nota%type,
                        ser  in  ft_devol.sr_nota%type,
                        fir  in  ft_devol.firma%type,
                        par  in  ft_devol.parte%type,
                        dta  in  date
                       );
function checa_cl_nota(emp  in  ft_notas.empresa%type,
                       fil  in  ft_notas.filial%type,
                       num  in  ft_notas.num_nota%type,
                       ser  in  ft_notas.sr_nota%type,
                       dta  in  date,
                       par  in  ft_notas.parte%type
                      ) return number;
function checa_cl_dev(emp  in  ft_devol.empresa%type,
                      fil  in  ft_devol.filial%type,
                      num  in  ft_devol.num_nota%type,
                      ser  in  ft_devol.sr_nota%type,
                      fir  in  ft_devol.firma%type,
                      par  in  ft_devol.parte%type,
                      dta  in  date
                     ) return number;

end ft_cn;
/
create or replace package body ft_cn is

  --||
  --|| Funcao : Pacote para cancelamento de notas fiscais
  --||

  --------------------------------------------------------------------------------
  /*
  || Rotinas internas
  */
  --------------------------------------------------------------------------------
  procedure cl_adiant_nf(emp in ft_notas.empresa%type,
                         fil in ft_notas.filial%type,
                         num in ft_notas.num_nota%type,
                         ser in ft_notas.sr_nota%type,
                         dta in date)
  /*
    || Integracao com adiantamento para cancelamento de devolucoes (nossa nota)
    */
   is

    reg      ft_notas%rowtype;
    reg_cfo  ft_cfo%rowtype;
    reg_oper ft_oper%rowtype;
    reg_ori  ft_notas%rowtype;

    type reg_dev_t is record(
      firma cd_firmas.firma%type,
      CC    char(1),
      valor number);
    type tab_dev_t is table of reg_dev_t index by binary_integer;

    tab_dev tab_dev_t;

    v_ind number;
    i     number;

    cursor cri is
      select *
        from ft_itens_nf
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser;

    v_valor  number;
    v_firma  cd_firmas.firma%type;
    v_avista ft_condpag.a_vista%type;
    v_CC     char(1);
    v_doc_origem number(9);
  begin

    --| Le a nota
    if ser <> '999' then
      select *
        into reg
        from ft_notas
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = 0;
    else
      select *
        into reg
        from ft_notas
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = 1;
    end if;

    --| Le FT_OPER para verificar natureza
    select * into reg_oper from ft_oper where cod_oper = reg.cod_oper;

    --| Se nao for entrada - cancela
    if reg_oper.natureza <> 'E' then
      return;
    end if;

    v_ind := 0;

    -- Percorre os itens verificando as NF origem que geram contas a receber
    for rgi in cri loop

      -- Se tiver nota origem
      if rgi.doc_origem is not null and rgi.fil_origem is not null and
         rgi.ser_origem is not null then

        -- Le a operacao e o cfo da nota origem
        select *
          into reg_ori
          from ft_notas
         where empresa = rgi.empresa and filial = rgi.fil_origem and
               num_nota = rgi.doc_origem and sr_nota = rgi.ser_origem and
               parte = 0;
               
        v_doc_origem := rgi.doc_origem;
        
        select * into reg_cfo from ft_cfo where cod_cfo = reg_ori.cod_cfo;

        -- Se nota origem atualiza c.receber
        if reg_cfo.atl_crec = 'S' then

          -- Se for operacao de remessa, a firma e o agente1
          select *
            into reg_oper
            from ft_oper
           where cod_oper = reg_ori.cod_oper;
          if reg_oper.remessa = 'S' and reg_ori.agente1 is not null then
            v_firma := reg_ori.agente1;
          else
            v_firma := reg_ori.firma;
          end if;

          --| Le Condicao de Pagamento
          select a_vista
            into v_avista
            from ft_condpag
           where cod_condpag = reg_ori.cod_condpag;

          --| Gerar conta corrente caso NAO seja a vista, senao, gera adiantamento
          v_CC := 'N';
          if false and v_avista <> 'S' then
            v_CC := 'S';
          end if;

          -- Guarda firmas e valores a lancar no adiantamento na tabela intena tab_dev
          i := 0;
          for n in 1 .. v_ind loop
            if tab_dev(n).firma = v_firma and tab_dev(n).CC = v_CC then
              i := n;
              exit;
            end if;
          end loop;
          if i = 0 then
            v_ind := v_ind + 1;
            tab_dev(v_ind).firma := v_firma;
            tab_dev(v_ind).CC := v_CC;
            tab_dev(v_ind).valor := (rgi.qtd_val * rgi.valor_unit);
          else
            tab_dev(i).valor := tab_dev(i)
                               .valor + (rgi.qtd_val * rgi.valor_unit);
          end if;
        end if;

      end if;

    end loop;

    --| Se existe(m) valor(es) a devolver - gera adiantamento(s)
    for n in 1 .. v_ind loop

      --| Lancamento em conta corrente
      if tab_dev(n).CC = 'S' then
        null;
        /*
        insert into gc_conta_corrente values
          (emp,
           fil,
           tab_dev(n).firma,
           gc_conta_corrente_seq.nextval,
           v_hs,
           reg.dt_emissao,
           tab_dev(n).valor,
           to_char(num),
           'CANCELAMENTO DEVOLUCAO N.F. ' || to_char(num) || '.' || ser,
           '',
           user,
           null,
           sysdate
          );
        */
        --| Lancamento em adiantamento
      else
        insert into fn_adiant
        values
          (emp,
           tab_dev(n).firma,
           reg.dt_emissao,
           fn_adiant_seq.nextval,
           'A',
           'U',
           tab_dev(n).valor,
           to_char(num) || '.' || ser,
           null,
           'CANCELAMENTO DEVOLUCAO N.F. ' || to_char(num) || '.' || ser,
           user,
           null,
           trunc(sysdate),
           reg.parte,
           null,
           v_doc_origem,
           reg.firma,null);

      end if;

    end loop;

  end;

  --------------------------------------------------------------------------------
  procedure cl_adiant_dev(emp in ft_devol.empresa%type,
                          fil in ft_devol.filial%type,
                          num in ft_devol.num_nota%type,
                          ser in ft_devol.sr_nota%type,
                          fir in ft_devol.firma%type,
                          par in ft_devol.parte%type,
                          dta in date)
  /*
    || Integracao com adiantamento para cancelamento de devolucoes (nota cliente)
    */
   is

    reg      ft_devol%rowtype;
    reg_cfo  ft_cfo%rowtype;
    reg_oper ft_oper%rowtype;
    reg_ori  ft_notas%rowtype;

    type reg_dev_t is record(
      firma cd_firmas.firma%type,
      CC    char(1),
      valor number);
    type tab_dev_t is table of reg_dev_t index by binary_integer;

    tab_dev tab_dev_t;

    v_ind number;
    i     number;

    cursor cri is
      select *
        from ft_itens_dev
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and firma = fir and parte = par;

    v_valor  number;
    v_firma  cd_firmas.firma%type;
    v_avista ft_condpag.a_vista%type;
    v_CC     char(1);

  begin

    --| Le a nota
    select *
      into reg
      from ft_devol
     where empresa = emp and filial = fil and num_nota = num and
           sr_nota = ser and firma = fir and parte = par;

    --| Le FT_OPER para verificar natureza
    select * into reg_oper from ft_oper where cod_oper = reg.cod_oper;

    --| Se nao for entrada - cancela
    if reg_oper.natureza <> 'E' then
      return;
    end if;

    v_ind := 0;

    -- Percorre os itens verificando as NF origem que geram contas a receber
    for rgi in cri loop

      -- Se tiver nota origem
      if rgi.doc_origem is not null and rgi.fil_origem is not null and
         rgi.ser_origem is not null then

        -- Le a operacao e o cfo da nota origem
        select *
          into reg_ori
          from ft_notas
         where empresa = rgi.empresa and filial = rgi.fil_origem and
               num_nota = rgi.doc_origem and sr_nota = rgi.ser_origem and
               parte = par;
        select * into reg_cfo from ft_cfo where cod_cfo = reg_ori.cod_cfo;

        -- Se nota origem atualiza c.receber
        if reg_cfo.atl_crec = 'S' then

          -- Se for operacao de remessa, a firma e o agente1
          select *
            into reg_oper
            from ft_oper
           where cod_oper = reg_ori.cod_oper;
          if reg_oper.remessa = 'S' and reg_ori.agente1 is not null then
            v_firma := reg_ori.agente1;
          else
            v_firma := reg_ori.firma;
          end if;

          --| Le Condicao de Pagamento
          select a_vista
            into v_avista
            from ft_condpag
           where cod_condpag = reg_ori.cod_condpag;

          --| Gerar conta corrente caso NAO seja a vista, senao, gera adiantamento
          v_CC := 'N';
          if false and v_avista <> 'S' then
            v_CC := 'S';
          end if;

          -- Guarda firmas e valores a lancar no adiantamento na tabela intena tab_dev
          i := 0;
          for n in 1 .. v_ind loop
            if tab_dev(n).firma = v_firma and tab_dev(n).CC = v_CC then
              i := n;
              exit;
            end if;
          end loop;
          if i = 0 then
            v_ind := v_ind + 1;
            tab_dev(v_ind).firma := v_firma;
            tab_dev(v_ind).CC := v_CC;
            tab_dev(v_ind).valor := (rgi.qtd_val * rgi.valor_unit);
          else
            tab_dev(i).valor := tab_dev(i)
                               .valor + (rgi.qtd_val * rgi.valor_unit);
          end if;
        end if;

      end if;

    end loop;

    --| Se existe(m) valor(es) a devolver - gera adiantamento(s)
    for n in 1 .. v_ind loop

      --| Lancamento em conta corrente
      if tab_dev(n).CC = 'S' then
        null;
        /*
        insert into gc_conta_corrente values
          (emp,
           fil,
           tab_dev(n).firma,
           gc_conta_corrente_seq.nextval,
           v_hs,
           reg.dt_emissao,
           tab_dev(n).valor,
           to_char(num),
           'CANCELAMENTO DEVOLUCAO N.F. ' || to_char(num) || '.' || ser,
           '',
           user,
           null,
           sysdate
          );
        */
        --| Lancamento em adiantamento
      else
        insert into fn_adiant
        values
          (emp,
           tab_dev(n).firma,
           reg.dt_emissao,
           fn_adiant_seq.nextval,
           'A',
           'U',
           tab_dev(n).valor,
           to_char(num) || '.' || ser,
           null,
           'CANCELAMENTO DEVOLUCAO N.F. ' || to_char(num) || '.' || ser,
           user,
           null,
           trunc(sysdate),
           0,
           null,
           num,
           tab_dev(n).firma,null);

      end if;

    end loop;

  end;

  --------------------------------------------------------------------------------
  /*
  || Rotinas exportadas
  */
  --------------------------------------------------------------------------------
  procedure cancela_nota(emp in ft_notas.empresa%type,
                         fil in ft_notas.filial%type,
                         num in ft_notas.num_nota%type,
                         ser in ft_notas.sr_nota%type,
                         dta in date,
                         par in number)
  /*
    || Cancela nota
    */
   is

    cursor crn is
      select *
        from ft_notas
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;
    reg ft_notas%rowtype;

    cursor cri is
      select *
        from ft_itens_nf
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;

    cursor cro is
      select distinct num_titulo, seq_titulo, parte
        from fn_itens_dup
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;

    cursor cr_exe(a number) is
      select * from cg_exerc where empresa = emp and ano = a for update;
    rex cg_exerc%rowtype;

    cursor cr_l(an cg_lancto.ano%type, lt cg_lancto.lote%type) is
      select * from cg_lancto where ano = an and lote = lt;

    cursor cr_cc(em cg_lancto.empresa%type, a cg_lancto.ano%type, sq cg_lancto.seq_lancto%type) is
      select *
        from cg_lancto_cc
       where empresa = em and ano = a and seq_lancto = sq;

    cursor cr_ar(em cg_lancto.empresa%type, a cg_lancto.ano%type, sq cg_lancto.seq_lancto%type) is
      select *
        from cg_lancto_ar
       where empresa = em and ano = a and seq_lancto = sq;

    cursor cr_mvs(seq ce_movest.seq_mov%type) is
      select vlr_tot_mov / qtde_mov custo
        from ce_movest
       where seq_mov = seq;

    cursor cr_lf(e fs_livros.empresa%type, f fs_livros.filial%type, c fs_livros.firma%type, t fs_livros.tip_docto%type, n fs_livros.num_docto%type, s fs_livros.ser_docto%type, l fs_livros.tip_livro%type) is
      select *
        from fs_livros
       where empresa = e and filial = f and tip_livro = l and num_docto = n and
             ser_docto = s and tip_docto = t and firma = c
         for update;
    reg_lf fs_livros%rowtype;

    cursor cr_loc(o ft_oper_loc.cod_oper%type, e ft_oper_loc.empresa%type, f ft_oper_loc.filial%type) is
      select *
        from ft_oper_loc
       where cod_oper = o and empresa = e and filial = f;
    reg_loc ft_oper_loc%rowtype;

    cursor cr_sal(e cg_lancto.empresa%type, a number) is
      select mes from cg_exerc where empresa = e and ano = a;

    cursor cr_ip(s ft_itens_ped.seq_item%type) is
      select * from ft_itens_ped where seq_item = s for update;
    reg_ip ft_itens_ped%rowtype;

    v_dt_cancela date;
    v_td         fs_livros.tip_docto%type;
    v_ano        number;
    v_mes        number;

    v_custo1  number;
    v_custo2  number;
    v_qtd_ped number;
    v_qtd_fat number;
    v_qtd_can number;
    v_avista  ft_condpag.a_vista%type;

    reg_cfo     ft_cfo%rowtype;
    reg_oper    ft_oper%rowtype;
    v_status    ft_pedidos.status%type;
    v_num       number;
    v_lote      cg_lancto.lote%type;
    v_seq       cg_lancto.seq_lancto%type;
    v_nat       cg_lancto.natureza%type;
    v_ret       number;
    v_livro     char(1);
    v_tp        char(1);
    v_ori       number;
    v_dif       number;
    v_sal       number;
    v_integrar  cg_prgen.integrar%type;
    v_local     ce_locest.local%type;
    v_fil_local ce_locest.filial%type;
    v_total     number;
    v_firma     number;
    v_dtmax     date;
    v_codfirma  cd_firmas.firma%type;
    v_filial    ce_locest.filial%type;
    v_codfirma2 cd_firmas.firma%type;
    v_aux       char(1);
  begin

    --| Verifica se pode cancelar
    if par = 0 then
      v_ret := checa_cl_nota(emp, fil, num, ser, dta, par);
      if v_ret <> 0 then
        raise_application_error(-20101,
                                'Nota nao pode ser cancelada : Erro ' ||
                                to_char(v_ret));
        return;
      end if;
    end if;

    --| Verifica contabilizacao
    select integrar into v_integrar from cg_prgen;
    if v_integrar = 'S' then
      open cr_sal(emp, to_number(to_char(dta, 'YYYY')));
      fetch cr_sal
        into v_mes;
      if cr_sal%notfound then
        close cr_sal;
        raise_application_error(-20101,
                                'Exercicio da data de cancelamento n?o foi aberto na contabilidade');
      end if;
      if v_mes >= to_number(to_char(dta, 'MM')) then
        close cr_sal;
        raise_application_error(-20101,
                                'MES da data de cancelamento ja foi fechado na contabilidade');
      end if;
      close cr_sal;
    end if;

    --| Le a nota
    open crn;
    fetch crn
      into reg;
    if crn%notfound then
      close crn;
      return;
    end if;
    close crn;

    --| Verifica fechamento do livro
    select data_fecha
      into v_dtmax
      from fs_prfil
     where empresa = emp and filial = fil;
    if v_dtmax >= dta then
      raise_application_error(-20199,
                              'Data ja bloqueada no departamento Fiscal');
    end if;

    --| Le CFO para verificar os procedimento de integracao
    select * into reg_cfo from ft_cfo where cod_cfo = reg.cod_cfo;

    --| Le FT_OPER para verificar natureza  CHECAR
    select * into reg_oper from ft_oper where cod_oper = reg.cod_oper;

    --| Le o tipo de documento de nota fiscal
    select tipo_doc into v_td from ft_prgen;

    v_total := 0;

    --| Filial de Destino quando transferencia
    if reg_oper.transfer = 'S' Then
      select filial into v_filial from cd_firmas where firma = reg.firma;
    end if;

    --| Para cada item da nota
    for reg_i in cri loop

      --| Atualiza estoque
      if reg_i.seq_movest1 is not null then
        delete from ce_movest where seq_mov = reg_i.seq_movest1;
      end if;
      if reg_i.seq_movest2 is not null then
        delete from ce_movest where seq_mov = reg_i.seq_movest2;
      end if;

      -- Atualiza Estoque Transferencia
      if reg_oper.transfer = 'S' and v_filial is not null and
         v_filial <> reg_i.filial then
        delete ce_movest
         where empresa = reg_i.empresa and filial = v_filial and
               produto = reg_i.produto and num_docto = reg_i.num_nota and
               dt_mov = reg.dt_emissao;
      end if;

      v_total := v_total + (reg_i.qtd * reg_i.valor_unit);

      --| Atualiza qtd faturada no pedido se for expedicao
      open cr_ip(reg_i.seq_pedido);
      fetch cr_ip
        into reg_ip;
      if nvl(reg_ip.qtd_fat, 0) > 0 then
        if reg_ip.qtd_fat <= reg_i.qtd then
          update ft_itens_ped
             set qtd_fat = 0, qtd_emb = 0
           where current of cr_ip;
        else
          update ft_itens_ped
             set qtd_fat = qtd_fat - reg_i.qtd,
                 qtd_emb = qtd_emb - reg_i.qtd
           where current of cr_ip;
        end if;
      end if;
      close cr_ip;

    end loop;

    --| Contas a receber
    if reg_cfo.atl_crec = 'S' then

      --| Verifica se operacao de remessa, que gera cobranca para o agente1
      if reg_oper.remessa = 'S' and reg.agente1 is not null then
        v_firma := reg.agente1;
      else
        v_firma := reg.firma;
      end if;

      --| Gerar conta corrente caso NAO seja a vista, senao, gera contas a receber
      if false then
        null;
        /*
        delete from gc_conta_corrente
         where empresa = reg.empresa and
               filial = reg.filial and
               firma = reg.firma and
               docto = to_char(reg.num_nota);
        */
      end if;

      --| Para cada registro de fn_orig_dup (ligacao notas x titulos)
      for reg4 in crO Loop
        delete fn_itens_dup
         where empresa = emp and filial = fil and
               num_titulo = reg4.num_titulo and
               seq_titulo = reg4.seq_titulo and parte = reg4.parte;
        -- Elimina historico
        delete fn_hist_dup
         where empresa = emp and filial = fil and
               num_titulo = reg4.num_titulo and
               seq_titulo = reg4.seq_titulo and parte = reg4.parte;
        -- Elimina titulo
        delete fn_ctrec
         where empresa = emp and filial = fil and
               num_titulo = reg4.num_titulo and
               seq_titulo = reg4.seq_titulo and parte = reg4.parte;
      End Loop;
    end if;

    --| Cancela lancamento no adiantamento
    cl_adiant_nf(emp, fil, num, ser, dta);

    --| Se operacao foi de transferencia : grava nota de entrada na filial destino
    --| e atualiza a nota de saida para apontar para a de entrada
    if reg_oper.transfer = 'S' and reg_cfo.atl_estq = 'S' and
       reg.fl_dest is not null and reg.nf_dest is not null and
       reg.sr_dest is not null and reg.fr_dest is not null then
      delete from ce_notas
       where empresa = emp and filial = reg.fl_dest and
             num_nota = reg.nf_dest and sr_nota = reg.sr_dest and
             cod_fornec = reg.fr_dest and parte = par;
    end if;

    --| Atualiza nota
    update ft_notas
       set status = 'C', dt_cancela = trunc(dta)
     where empresa = emp and filial = fil and num_nota = num and
           sr_nota = ser and parte = par;

    --| Livro fiscal

    if par = 0 then
      --| Codigo de emitente
      if reg_oper.natureza = 'E' and reg_oper.escrit_fil = 'S' then
        select firma
          into v_codfirma
          from cd_firmas
         where empresa = emp and filial = fil;
      else
        v_codfirma := reg.firma;
      end if;
      v_aux := reg_oper.natureza;

      if reg_oper.servico = 'S' then
        V_AUX := 'P';
      END IF;

      --open cr_lf(emp, fil, v_codfirma, v_td, num, ser, reg_oper.natureza);
      open cr_lf(emp, fil, v_codfirma, v_td, num, ser, V_AUX);
      fetch cr_lf
        into reg_lf;
      if cr_lf%found then
        --RAISE_APPLICATION_ERROR(-20100,' FIRMA '||reg_lf.firma||'tipo livro  '|| reg_lf.tip_livro ||'NUM '||reg_lf.num_docto||'SER '||reg_lf.ser_docto|| 'V_AUX '||reg_lf.tip_docto);
        update fs_livros
           set dt_cancela = trunc(dta),
               observacao = 'NOTA FISCAL CANCELADA',
               val_docto  = 0
         where current of cr_lf;
        update fs_itens_livro
           set base_calc  = 0,
               base_sub   = 0,
               valor_00   = 0,
               valor_10   = 0,
               valor_20   = 0,
               valor_30   = 0,
               valor_40   = 0,
               valor_41   = 0,
               valor_50   = 0,
               valor_51   = 0,
               valor_60   = 0,
               valor_70   = 0,
               valor_90   = 0,
               vlr_contab = 0
         where empresa = reg_lf.empresa and filial = reg_lf.filial and
               tip_livro = reg_lf.tip_livro and
               num_docto = reg_lf.num_docto and
               ser_docto = reg_lf.ser_docto and
               tip_docto = reg_lf.tip_docto and firma = reg_lf.firma;
      end if;

      close cr_lf;

      -- Sendo transferencia, cancela no LF a NF destino
      if reg_oper.transfer = 'S' Then
        select firma
          into v_codfirma2
          from cd_firmas
         where empresa = emp and filial = v_filial;
        open cr_lf(emp, v_filial, v_codfirma2, v_td, num, ser, 'E');
        fetch cr_lf
          into reg_lf;
        if cr_lf%found then
          delete from fs_itens_livro
           where empresa = reg_lf.empresa and filial = reg_lf.filial and
                 tip_livro = reg_lf.tip_livro and
                 num_docto = reg_lf.num_docto and
                 ser_docto = reg_lf.ser_docto and
                 tip_docto = reg_lf.tip_docto and firma = reg_lf.firma;
          delete fs_livros where current of cr_lf;
        end if;
        close cr_lf;
      end if;

    end if;

    --| Contas a pagar
    if reg_cfo.atl_cpag = 'S' then
      null;
    end if;

    --| Atualiza o pedido
    --| Se voltou todo o saldo fica como Faturado Parcial. Senao fica como A Faturar
    if par = 0 or ser = '999' then
      v_status := 'A';
      select sum(qtd_ped), sum(qtd_fat), sum(qtd_can)
        into v_qtd_ped, v_qtd_fat, v_qtd_can
        from ft_itens_ped
       where empresa = emp and filial = reg.fil_pedido and
             num_pedido = reg.num_pedido;
      v_qtd_ped := nvl(v_qtd_ped, 0);
      v_qtd_fat := nvl(v_qtd_fat, 0);
      v_qtd_can := nvl(v_qtd_can, 0);

      if v_qtd_ped > 0 then
        if v_qtd_fat = 0 then
          v_status := 'A';
        else
          v_status := 'P';
        end if;
        update ft_pedidos
           set status = v_status
         where empresa = emp and filial = reg.fil_pedido and
               num_pedido = reg.num_pedido;
      end if;
    end if;

    --| Atualiza Devolucao
    --update ft_devol set status = 'C'
    -- where empresa = emp and
    --       filial = fil and
    --       num_nota_ent = num and
    --       sr_nota_ent = ser;

    -- Atualizacao limite de credito
    if reg_oper.natureza = 'S' and reg_oper.credito = 'S' then
      begin
        select a_vista
          into v_avista
          from ft_condpag
         where cod_condpag = reg.cod_condpag;
        if v_avista = 'N' then
          if reg_oper.remessa = 'N' then
            update cd_firmas
               set vl_usado = nvl(vl_usado, 0) - v_total
             where firma = reg.firma;
          else
            update cd_firmas
               set vl_usado = nvl(vl_usado, 0) - v_total
             where firma = reg.agente1;
          end if;
        end if;
      exception
        when others then
          null;
      end;
    end if;

    --| Estorna contabilidade
    if v_integrar = 'S' and reg.lote_cont is not null then

      v_ano := to_number(to_char(dta, 'yyyy'));
      open cr_exe(v_ano);
      fetch cr_exe
        into rex;
      v_lote := rex.ult_lote + 1;
      v_seq  := rex.ult_lancto;

      -- Estorna o lote da baixa
      for reg_l in cr_l(v_ano, reg.lote_cont) loop
        if reg_l.natureza = 'D' then
          v_nat := 'C';
        else
          v_nat := 'D';
        end if;
        v_seq := v_seq + 1;
        insert into cg_lancto
        values
          (v_ano,
           reg_l.empresa,
           v_seq,
           v_lote,
           null,
           reg_l.cod_conta,
           trunc(dta),
           reg_l.valor,
           v_nat,
           'Estorno de : ' || reg_l.historico,
           reg_l.cod_afonte,
           reg_l.cod_terceiro,
           reg_l.cenario,
           reg_l.origem,
           reg_l.informado);

        for reg_cc in cr_cc(reg_l.empresa, v_ano, reg_l.seq_lancto) loop
          insert into cg_lancto_cc
          values
            (v_ano,
             reg_cc.empresa,
             v_seq,
             reg_cc.ccusto,
             reg_cc.valor,
             v_nat,
             trunc(dta),
             reg_l.cod_conta,
             reg_l.cenario,
             reg_cc.versao);

        end loop;
        for reg_ar in cr_ar(reg_l.empresa, v_ano, reg_l.seq_lancto) loop
          insert into cg_lancto_ar
          values
            (v_ano,
             reg_ar.empresa,
             v_seq,
             reg_ar.area_res,
             reg_ar.valor,
             v_nat,
             trunc(dta),
             reg_l.cod_conta,
             reg_l.cenario);

        end loop;

      end loop;

      --| Atualiza o registro da nota
      update ft_notas
         set lote_cont = lote_cont || ' / ' || to_char(v_lote)
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;

      --| Atualiza registro de devolucao
      --update ft_devol set lote_cont = lote_cont || ' / ' || to_char(v_lote)
      -- where empresa = emp and
      --       filial = fil and
      --       num_nota_ent = num and
      --       sr_nota_ent = ser;

      update cg_exerc
         set ult_lote = v_lote, ult_Lancto = v_seq
       where current of cr_exe;

      close cr_exe;

    end if;
    commit;
  end;

  --------------------------------------------------------------------------------
  procedure cancela_devol(emp in ft_devol.empresa%type,
                          fil in ft_devol.filial%type,
                          num in ft_devol.num_nota%type,
                          ser in ft_devol.sr_nota%type,
                          fir in ft_devol.firma%type,
                          par in ft_devol.parte%type,
                          dta in date)
  /*
    || Cancela devolucao
    */
   is

    cursor crn is
      select *
        from ft_devol
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and firma = fir and parte = par;
    reg ft_devol%rowtype;

    cursor cri is
      select *
        from ft_itens_dev
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and firma = fir and parte = par;

    cursor cr_exe(a number) is
      select * from cg_exerc where empresa = emp and ano = a for update;
    rex cg_exerc%rowtype;

    cursor cr_l(an cg_lancto.ano%type, lt cg_lancto.lote%type) is
      select * from cg_lancto where ano = an and lote = lt;

    cursor cr_cc(em cg_lancto.empresa%type, sq cg_lancto.seq_lancto%type) is
      select * from cg_lancto_cc where empresa = em and seq_lancto = sq;

    cursor cr_ar(em cg_lancto.empresa%type, sq cg_lancto.seq_lancto%type) is
      select * from cg_lancto_ar where empresa = em and seq_lancto = sq;

    cursor cr_loc(o ft_oper_loc.cod_oper%type, e ft_oper_loc.empresa%type, f ft_oper_loc.filial%type) is
      select *
        from ft_oper_loc
       where cod_oper = o and empresa = e and filial = f;
    reg_loc ft_oper_loc%rowtype;

    cursor cr_sal(e cg_lancto.empresa%type, a number) is
      select mes from cg_exerc where empresa = e and ano = a;

    cursor cr_lf(e fs_livros.empresa%type, f fs_livros.filial%type, c fs_livros.firma%type, t fs_livros.tip_docto%type, n fs_livros.num_docto%type, s fs_livros.ser_docto%type, l fs_livros.tip_livro%type) is
      select *
        from fs_livros
       where empresa = e and filial = f and tip_livro = l and num_docto = n and
             ser_docto = s and tip_docto = t and firma = c
         for update;
    reg_lf fs_livros%rowtype;

    reg_cfo     ft_cfo%rowtype;
    reg_oper    ft_oper%rowtype;
    v_m         varchar2(100);
    v_o         char(1);
    v_status    ft_pedidos.status%type;
    v_num       number;
    v_oper_cde  ce_operacoes.cod_oper%type;
    v_lote      cg_lancto.lote%type;
    v_seq       cg_lancto.seq_lancto%type;
    v_nat       cg_lancto.natureza%type;
    v_oper_desc ce_operacoes.descricao%type;
    v_local     ce_locest.local%type;
    v_ret       number;
    v_ano       number;
    v_mes       number;
    v_integrar  cg_prgen.integrar%type;
    v_td        fs_livros.tip_docto%type;
    v_dtmax     date;

  begin

    --| Verifica se pode cancelar
    v_ret := checa_cl_dev(emp, fil, num, ser, fir, par, dta);

    if v_ret <> 0 then
      raise_application_error(-20100,
                              'Nota nao pode ser cancelada : Erro ' ||
                              to_char(v_ret));
      return;
    end if;

    --| Le o tipo de documento de nota fiscal
    select tipo_doc into v_td from ft_prgen;

    --| Verifica contabilizacao
    select integrar into v_integrar from cg_prgen;
    if v_integrar = 'S' then
      open cr_sal(emp, to_number(to_char(dta, 'YYYY')));
      fetch cr_sal
        into v_mes;
      if cr_sal%notfound then
        close cr_sal;
        raise_application_error(-20101,
                                'Exercicio da data de cancelamento n?o foi aberto na contabilidade');
      end if;
      if v_mes >= to_number(to_char(dta, 'MM')) then
        close cr_sal;
        raise_application_error(-20101,
                                'MES da data de cancelamento ja foi fechado na contabilidade');
      end if;
      close cr_sal;
    end if;

    --| Le a nota
    open crn;
    fetch crn
      into reg;
    close crn;

    --| Verifica fechamento do livro
    select data_fecha
      into v_dtmax
      from fs_prfil
     where empresa = emp and filial = fil;
    if v_dtmax >= dta then
      raise_application_error(-20199,
                              'Data ja bloqueada no departamento Fiscal');
    end if;

    --| Le CFO para verificar os procedimento de integracao
    select * into reg_cfo from ft_cfo where cod_cfo = reg.cod_cfo;

    --| Le FT_OPER para verificar natureza
    select * into reg_oper from ft_oper where cod_oper = reg.cod_oper;

    --| Movimento do estoque
    --| Para cada item da nota
    for reg_i in cri loop

      if reg_i.seq_movest is not null then
        delete from ce_movest where seq_mov = reg_i.seq_movest;
      end if;

    end loop;

    --| Cancela lancamento no adiantamento
    cl_adiant_dev(emp, fil, num, ser, fir, par, dta);

    --| Atualiza o pedido
    v_status := 'A';
    update ft_pedidos
       set status = v_status
     where empresa = emp and filial = fil and num_pedido = reg.num_pedido;

    --| Atualiza Devolucao
    update ft_devol
       set status = 'C'
     where empresa = emp and filial = fil and num_nota = num and
           sr_nota = ser and firma = fir and parte = par;

    --| Livro fiscal
    if par = 0 then
      open cr_lf(emp, fil, fir, v_td, num, ser, reg_oper.natureza);
      fetch cr_lf
        into reg_lf;
      if cr_lf%found then
        update fs_livros
           set dt_cancela = trunc(dta),
               observacao = 'NOTA FISCAL CANCELADA',
               val_docto  = 0
         where current of cr_lf;
        update fs_itens_livro
           set base_calc  = 0,
               base_sub   = 0,
               valor_00   = 0,
               valor_10   = 0,
               valor_20   = 0,
               valor_30   = 0,
               valor_40   = 0,
               valor_41   = 0,
               valor_50   = 0,
               valor_51   = 0,
               valor_60   = 0,
               valor_70   = 0,
               valor_90   = 0,
               vlr_contab = 0
         where empresa = reg_lf.empresa and filial = reg_lf.filial and
               tip_livro = reg_lf.tip_livro and
               num_docto = reg_lf.num_docto and
               ser_docto = reg_lf.ser_docto and
               tip_docto = reg_lf.tip_docto and firma = reg_lf.firma;
      end if;
      close cr_lf;
    end if;

    --| Estorna contabilidade
    if v_integrar = 'S' and reg.lote_cont is not null then

      v_ano := to_number(to_char(dta, 'yyyy'));
      open cr_exe(v_ano);
      fetch cr_exe
        into rex;
      v_lote := rex.ult_lote + 1;
      v_seq  := rex.ult_lancto;

      -- Estorna o lote da baixa
      for reg_l in cr_l(v_ano, reg.lote_cont) loop
        if reg_l.natureza = 'D' then
          v_nat := 'C';
        else
          v_nat := 'D';
        end if;
        v_seq := v_seq + 1;
        insert into cg_lancto
        values
          (v_ano,
           reg_l.empresa,
           v_seq,
           v_lote,
           null,
           reg_l.cod_conta,
           trunc(dta),
           reg_l.valor,
           v_nat,
           'Estorno de : ' || reg_l.historico,
           reg_l.cod_afonte,
           reg_l.cod_terceiro,
           reg_l.cenario,
           reg_l.origem,
           reg_l.informado);

        for reg_cc in cr_cc(reg_l.empresa, reg_l.seq_lancto) loop
          insert into cg_lancto_cc
          values
            (v_ano,
             reg_cc.empresa,
             v_seq,
             reg_cc.ccusto,
             reg_cc.valor,
             v_nat,
             trunc(dta),
             reg_l.cod_conta,
             reg_l.cenario,
             reg_cc.versao);

        end loop;
        for reg_ar in cr_ar(reg_l.empresa, reg_l.seq_lancto) loop
          insert into cg_lancto_ar
          values
            (v_ano,
             reg_ar.empresa,
             v_seq,
             reg_ar.area_res,
             reg_ar.valor,
             v_nat,
             trunc(dta),
             reg_l.cod_conta,
             reg_l.cenario);

        end loop;

      end loop;

      --| Atualiza registro de devolucao
      update ft_devol
         set lote_cont = lote_cont || ' / ' || v_lote
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and firma = fir and parte = par;

      update cg_exerc
         set ult_lote = v_lote, ult_lancto = v_seq
       where current of cr_exe;

      close cr_exe;
    end if;

  end;

  --------------------------------------------------------------------------------
  function checa_cl_nota(emp in ft_notas.empresa%type,
                         fil in ft_notas.filial%type,
                         num in ft_notas.num_nota%type,
                         ser in ft_notas.sr_nota%type,
                         dta in date,
                         par in ft_notas.parte%type) return number
  /*
    || Verifica se parametros de cancelameno sao validos
    */
   is

    cursor crn is
      select *
        from ft_notas
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;
    reg ft_notas%rowtype;

    cursor cro is
      select *
        from fn_itens_dup
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and parte = par;

    cursor crt(nt fn_ctrec.num_titulo%type, sq fn_ctrec.seq_titulo%type) is
      select situacao
        from fn_ctrec
       where empresa = emp and filial = fil and num_titulo = nt and
             seq_titulo = sq and parte = par;

    v_aberto fn_ctrec.situacao%type;
    v_sit    fn_ctrec.situacao%type;
    nErro    number;
    v_fat    number;
    v_dev    number;

  begin

    --| Le a nota
    open crn;
    fetch crn
      into reg;
    close crn;

    --| Ja cancelada
    if reg.status = 'C' then
      return 1;
    end if;

    --| Data de cancelamento invalida (< emissao)
    if trunc(reg.dt_emissao) > trunc(dta) then
      return 2;
    end if;

    --| Se ja houver qtd faturada (nota mae) ou devolvida
    select sum(qtd_fat), sum(qtd_dev)
      into v_fat, v_dev
      from ft_itens_nf
     where empresa = emp and filial = fil and num_nota = num and
           sr_nota = ser and parte = par;
    if nvl(v_dev, 0) > 0 then
      return 3;
    end if;

    --| Se algum titulo ja tenha sido pago ou renegociado
    nErro := 0;
    select pos_aberto into v_aberto from fn_prgen;
    for reg_ori in cro loop
      open crt(reg_ori.num_titulo, reg_ori.seq_titulo);
      fetch crt
        into v_sit;
      if crt%found and v_sit <> v_aberto then
        close crt;
        nErro := 4;
        exit;
      end if;
      close crt;
    end loop;

    if nErro > 0 then
      return nErro;
    end if;

    return 0;

  end;

  --------------------------------------------------------------------------------
  function checa_cl_dev(emp in ft_devol.empresa%type,
                        fil in ft_devol.filial%type,
                        num in ft_devol.num_nota%type,
                        ser in ft_devol.sr_nota%type,
                        fir in ft_devol.firma%type,
                        par in ft_devol.parte%type,
                        dta in date) return number
  /*
    || Verifica se parametros de cancelamento de devolucao sao validos
    */
   is

    cursor crn is
      select *
        from ft_devol
       where empresa = emp and filial = fil and num_nota = num and
             sr_nota = ser and firma = fir and parte = par;
    reg ft_devol%rowtype;

    v_aberto fn_ctrec.situacao%type;
    v_sit    fn_ctrec.situacao%type;
    nErro    number;
    v_fat    number;
    v_dev    number;

  begin

    --| Le a nota
    open crn;
    fetch crn
      into reg;
    close crn;

    --| Ja cancelada
    if reg.status = 'C' then
      return 1;
    end if;

    --| Tem nota de entrada
    --if reg.num_nota_ent is not null  then
    --  return 3;
    --  end if;

    --| Data de cancelamento invalida (< emissao)
    if trunc(reg.dt_emissao) > trunc(dta) then
      return 2;
    end if;

    if nErro > 0 then
      return nErro;
    end if;

    return 0;

  end;

end ft_cn;
/
