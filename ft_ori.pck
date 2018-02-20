create or replace package ft_ori is

   --||
   --|| FT_ORI.PKS : Pacote para controle de NF origem
   --||
   --|----------------------------------------------------------------------------
   function fnc_tipo_ori(emp    ft_notas.empresa%type
                        ,fil    ft_notas.filial%type
                        ,ped    ft_notas.num_nota%type
                        ,ser    ft_notas.sr_nota%type
                        ,par    ft_notas.parte%type
                        ,p_oper ft_notas.cod_oper%type)
      return ft_oper_ori.tipo%type;
   --|----------------------------------------------------------------------------                    

   function saldo_nf(emp ft_notas.empresa%type
                    ,fil ft_notas.filial%type
                    ,ped ft_notas.num_nota%type
                    ,ser ft_notas.sr_nota%type
                    ,par ft_notas.parte%type) return number;

   pragma restrict_references(saldo_nf,
                              wnds,
                              wnps);

   --| overload  
   /*                        
   function saldo_nf(emp    ft_notas.empresa%type
                    ,fil    ft_notas.filial%type
                    ,ped    ft_notas.num_nota%type
                    ,ser    ft_notas.sr_nota%type
                    ,par    ft_notas.parte%type
                    ,p_oper ft_notas.cod_oper%type) return number;
   
   pragma restrict_references(saldo_nf,
                              wnds,
                              wnps);
      */
   --------------------------------------------------------------------------------
   function saldo_nf(emp    ft_notas.empresa%type
                    ,fil    ft_notas.filial%type
                    ,ped    ft_notas.num_nota%type
                    ,ser    ft_notas.sr_nota%type
                    ,par    ft_notas.parte%type
                    ,p_tipo ft_oper_ori.tipo%type) return number;
   pragma restrict_references(saldo_nf,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------                            
   function saldo_item_nf(seq in ft_itens_nf.seq_item%type)
      return ft_itens_nf.qtd%type;
   pragma restrict_references(saldo_item_nf,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function saldo_item_nf(seq    in ft_itens_nf.seq_item%type
                         ,p_tipo ft_oper_ori.tipo%type) return number;
   pragma restrict_references(saldo_item_nf,
                              wnds,
                              wnps);
   --------------------------------------------------------------------------------
   function total_retorno(seq in ft_itens_nf.seq_item%type) return number;
   pragma restrict_references(total_retorno,
                              wnds,
                              wnps);

   --------------------------------------------------------------------------------
   function valor_retorno_industrializacao(p_id_nf   ft_notas.id%type
                                          ,p_id_item in ft_itens_nf.id%type)
      return number;
   pragma restrict_references(valor_retorno_industrializacao,
                              wnds,
                              wnps);
                              
   --------------------------------------------------------------------------------
   function qtde_retorno_industrializacao(p_id_nf   ft_notas.id%type
                                          ,p_id_item in ft_itens_nf.id%type)
      return number;  
   pragma restrict_references(qtde_retorno_industrializacao,
                              wnds,
                              wnps);                                  
   --|--------------------------------------------------------------                                                    
   function soma_fat_nf(seq in ft_itens_nf.seq_item%type
                       ,qtf in number) return boolean;
   function soma_dev_nf(seq in ft_itens_nf.seq_item%type
                       ,qtf in number) return boolean;
   function subtrai_fat_nf(seq in ft_itens_nf.seq_item%type
                          ,qtf in number) return boolean;
   function subtrai_dev_nf(seq in ft_itens_nf.seq_item%type
                          ,qtf in number) return boolean;
   function saldo_ped(emp ft_pedidos.empresa%type
                     ,fil ft_pedidos.filial%type
                     ,ped ft_pedidos.num_nota%type) return number;
   pragma restrict_references(saldo_ped,
                              wnds,
                              wnps);
   --|--------------------------------------------------------------
   function saldo_item_ped(seq in ft_itens_ped.seq_item%type)
      return ft_itens_ped.qtd_ped%type;
   pragma restrict_references(saldo_item_ped,
                              wnds,
                              wnps);

   function saldo_item_ped(seq    in ft_itens_ped.seq_item%type
                          ,p_tipo ft_oper_ori.tipo%type) return number;
   pragma restrict_references(saldo_item_ped,
                              wnds,
                              wnps);

   --|--------------------------------------------------------------                                                            
   function soma_fat_ped(seq in ft_itens_ped.seq_item%type
                        ,qtd in number) return boolean;
   function subtrai_fat_ped(seq in ft_itens_ped.seq_item%type
                           ,qtd in number) return boolean;
   procedure status_ped(emp ft_pedidos.empresa%type
                       ,fil ft_pedidos.filial%type
                       ,ped ft_pedidos.num_nota%type);
   procedure status_exp(emp ft_pedidos.empresa%type
                       ,fil ft_pedidos.filial%type
                       ,ped ft_pedidos.num_nota%type);
   function soma_fat_exp(seq in ft_itens_ped.seq_item%type
                        ,qtd in number) return boolean;
   function subtrai_fat_exp(seq in ft_itens_ped.seq_item%type
                           ,qtd in number) return boolean;
   function saldo_rm(emp ce_notas.empresa%type
                    ,fil ce_notas.filial%type
                    ,ped ce_notas.num_nota%type
                    ,ser ce_notas.sr_nota%type
                    ,fir ce_notas.cod_fornec%type) return number;
   function saldo_item_rm(seq in ce_itens_nf.id%type) return ce_itens_nf.qtd%type;
   function soma_dev_rm(seq in ce_itens_nf.id%type
                       ,qtf in number) return boolean;
   function subtrai_dev_rm(seq in ce_itens_nf.id%type
                          ,qtf in number) return boolean;

end ft_ori;
/
create or replace package body ft_ori is

   --||
   --|| FT_ORI.PKB : Pacote para controle de NF/Pedido origem
   --||

   --------------------------------------------------------------------------------
   /*
   || Rotinas exportadas
   */

   --------------------------------------------------------------------------------
   function saldo_nf(emp ft_notas.empresa%type
                    ,fil ft_notas.filial%type
                    ,ped ft_notas.num_nota%type
                    ,ser ft_notas.sr_nota%type
                    ,par ft_notas.parte%type) return number
   /*
      || Retorna saldo a faturar na nota
      */
    is
   
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
   
   begin
   
      select sum(qtd)
            ,sum(qtd_dev)
            ,sum(qtd_fat)
        into v_qtd
            ,v_qtd_dev
            ,v_qtd_fat
        from ft_itens_nf n
            ,ft_notas    nt
       where n.empresa = emp
         and n.filial = fil
         and n.num_nota = ped
         and n.sr_nota = ser
         and n.parte = par
         and nt.id = n.id_ft_nota
         and nt.status != 'C';
   
      v_saldo := nvl(v_qtd,
                     0) - abs(nvl(v_qtd_fat,
                                  0)) - abs(nvl(v_qtd_dev,
                                                0));
   
      return v_saldo;
   
   end;
   /*
   --------------------------------------------------------------------------------
   function saldo_nf(emp    ft_notas.empresa%type
                    ,fil    ft_notas.filial%type
                    ,ped    ft_notas.num_nota%type
                    ,ser    ft_notas.sr_nota%type
                    ,par    ft_notas.parte%type
                    ,p_oper ft_notas.cod_oper%type) return number
   
    is
      cursor cr is
         select n.id
               ,t.tipo
               ,sum(case
                       when t.tipo = 'Q' then
                        (it.qtd)
                       else
                        (it.qtd * it.pruni_sst + nvl(it.vl_ipi,
                                                     0))
                    end) qtd
           from ft_oper_ori t
               ,ft_notas    n
               ,ft_itens_nf it
          where t.empresa = emp
            and t.cod_oper = p_oper
            and n.empresa = emp
            and n.filial = fil
            and n.num_nota = ped
            and n.sr_nota = ser
            and n.parte = par
            and n.cod_oper = t.ref_oper
            and it.id_ft_nota = n.id
          group by n.id
                  ,t.tipo;
   
      cursor crq is
         select sum(n.qtd)
           from ft_itens_nf n
          where n.empresa = emp
            and n.filial = fil
            and n.doc_origem = ped
            and n.ser_origem = ser
            and n.parte = par;
   
      cursor crv is
         select sum(n.qtd * n.pruni_sst)
           from ft_itens_nf n
          where n.empresa = emp
            and n.filial = fil
            and n.doc_origem = ped
            and n.ser_origem = ser
            and n.parte = par;
   
      v_id      number(9);
      v_tipo    ft_oper_ori.tipo%type;
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
   
   begin
      open cr;
      fetch cr
         into v_id
             ,v_tipo
             ,v_qtd;
      -- ,v_qtd_dev
      -- ,v_qtd_fat;
      close cr;
   
      v_qtd_fat := 0;
   
      if v_tipo = 'Q' then
         open crq;
         fetch crq
            into v_qtd_fat;
         close crq;
      else
         open crv;
         fetch crv
            into v_qtd_fat;
         close crv;
      end if;
      v_saldo := nvl(v_qtd,
                     0)
                
                 - abs(nvl(v_qtd_fat,
                           0));
      return v_saldo;
   
   end;
   */
   --------------------------------------------------------------------------------
   function saldo_nf(emp    ft_notas.empresa%type
                    ,fil    ft_notas.filial%type
                    ,ped    ft_notas.num_nota%type
                    ,ser    ft_notas.sr_nota%type
                    ,par    ft_notas.parte%type
                    ,p_tipo ft_oper_ori.tipo%type) return number
   /*
      || Retorna saldo a faturar na nota
      */
    is
      cursor cr is
         select n.id
               ,sum(case
                       when p_tipo = 'Q' then
                        (it.qtd)
                       else
                        (it.qtd * it.pruni_sst + nvl(it.vl_ipi,
                                                     0))
                    end) qtd
           from ft_notas    n
               ,ft_itens_nf it
          where n.empresa = emp
            and n.filial = fil
            and n.num_nota = ped
            and n.sr_nota = ser
            and n.parte = par
            and it.id_ft_nota = n.id
            and n.status != 'C'
          group by n.id;
   
      cursor crq is
         select sum(n.qtd)
           from ft_itens_nf n
               ,ft_notas    nt
          where n.empresa = emp
            and n.filial = fil
            and n.doc_origem = ped
            and n.ser_origem = ser
            and n.parte = par
            and nt.id = n.id_ft_nota
            and nt.status != 'C';
   
      cursor crv is
         select sum(n.qtd * n.pruni_sst)
           from ft_itens_nf n
               ,ft_notas    nt
          where n.empresa = emp
            and n.filial = fil
            and n.doc_origem = ped
            and n.ser_origem = ser
            and n.parte = par
            and nt.id = n.id_ft_nota
            and nt.status != 'C';
   
      v_id      number(9);
      v_tipo    ft_oper_ori.tipo%type;
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
   
   begin
      open cr;
      fetch cr
         into v_id
             ,v_qtd;
      close cr;
   
      v_qtd_fat := 0;
   
      if p_tipo = 'Q' then
         open crq;
         fetch crq
            into v_qtd_fat;
         close crq;
      else
         open crv;
         fetch crv
            into v_qtd_fat;
         close crv;
      end if;
      --
      v_saldo := nvl(v_qtd,
                     0) - abs(nvl(v_qtd_fat,
                                  0));
      return v_saldo;
   
   end;
   --------------------------------------------------------------------------------
   function saldo_item_nf(seq in ft_itens_nf.seq_item%type)
      return ft_itens_nf.qtd%type
   /*
      || Retorna saldo do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_qtd_ret number;
      v_ret     number;
   begin
   
      select qtd
            ,qtd_dev
        into v_qtd
            ,v_qtd_dev
        from ft_itens_nf n
            ,ft_notas    nt
       where n.id = seq
         and nt.id = n.id_ft_nota
         and nt.status != 'C';
   
      v_qtd_ret := total_retorno(seq);
      v_ret     := nvl(v_qtd,
                       0) - nvl(v_qtd_ret,
                                0) - nvl(v_qtd_dev,
                                         0);
      return v_ret;
   
   exception
   
      when others then
         return 0;
      
   end;

   --------------------------------------------------------------------------------
   function saldo_item_nf(seq    in ft_itens_nf.seq_item%type
                         ,p_tipo ft_oper_ori.tipo%type) return number
   /*
      || Retorna saldo do item da nota
      */
    is
   
      cursor cr is
         select sum(case
                       when p_tipo = 'Q' then
                        (it.qtd)
                       else
                        (it.qtd * it.pruni_sst + nvl(it.vl_ipi,
                                                     0))
                    end) qtd
           from ft_notas    n
               ,ft_itens_nf it
          where it.id = seq
            and it.id_ft_nota = n.id
            and n.status != 'C';
   
      cursor crq is
         select sum(n.qtd)
           from ft_itens_nf n
               ,ft_notas    nt
          where n.seq_origem = seq
            and nt.id = n.id_ft_nota
            and nt.status != 'C';
   
      cursor crv is
         select sum(n.qtd * n.pruni_sst)
           from ft_itens_nf n
               ,ft_notas    nt
          where n.seq_origem = seq
            and nt.id = n.id_ft_nota
            and nt.status != 'C';
   
      v_id      number(9);
      v_tipo    ft_oper_ori.tipo%type;
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
   
   begin
      open cr;
      fetch cr
         into v_qtd;
   
      close cr;
   
      v_qtd_fat := 0;
   
      if p_tipo = 'Q' then
         open crq;
         fetch crq
            into v_qtd_fat;
         close crq;
      else
         open crv;
         fetch crv
            into v_qtd_fat;
         close crv;
      end if;
      v_saldo := nvl(v_qtd,
                     0)
                
                 - abs(nvl(v_qtd_fat,
                           0));
      return v_saldo;
   
   end;
   --|----------------------------------------------------------------------------
   function fnc_tipo_ori(emp    ft_notas.empresa%type
                        ,fil    ft_notas.filial%type
                        ,ped    ft_notas.num_nota%type
                        ,ser    ft_notas.sr_nota%type
                        ,par    ft_notas.parte%type
                        ,p_oper ft_notas.cod_oper%type)
      return ft_oper_ori.tipo%type is
      cursor cr is
         select ori.tipo
           from ft_notas    n
               ,ft_oper_ori ori
          where n.empresa = emp
            and n.filial = fil
            and n.num_nota = ped
            and n.sr_nota = ser
            and n.parte = par
            and ori.empresa = n.empresa
            and ori.cod_oper = p_oper
            and ori.ref_oper = n.cod_oper;
      v_ret ft_oper_ori.tipo%type;
   begin
      v_ret := 'Q';
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return v_ret;
   
   end;
   --------------------------------------------------------------------------------
   function total_retorno(seq in ft_itens_nf.seq_item%type) return number
   /*
      || total do item retornado
      */
    is
   
      cursor cr is
         select sum(it.qtd) from ce_itens_nf it where it.seq_ori = seq;
   
      v_ret number;
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
   
      return nvl(v_ret,
                 0);
   
   end;

   --------------------------------------------------------------------------------
   function valor_retorno_industrializacao(p_id_nf   ft_notas.id%type
                                          ,p_id_item in ft_itens_nf.id%type)
      return number is
      cursor cr is
         select sum(valor)
           from (select sum(it2.qtd * it2.valor_unit) valor
                   from ft_notas    n2
                       ,ft_itens_nf it2
                       ,ft_notas    n
                  where it2.id_ft_nota = n2.id
                    and it2.doc_origem = n.num_nota
                    and it2.sr_nota    = n.sr_nota
                    and n.id           = p_id_nf
                    and it2.seq_origem = p_id_item
                 union all
                 select sum(it3.qtd * it3.valor_unit) valor
                   from ce_itens_nf it3
                  where it3.seq_ori = p_id_item);
   
      v_ret number(15,
                   2);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   end;
   
   --------------------------------------------------------------------------------
   function qtde_retorno_industrializacao(p_id_nf   ft_notas.id%type
                                          ,p_id_item in ft_itens_nf.id%type)
      return number is
      cursor cr is
         select sum(qtde)
           from (select sum(it2.qtd ) qtde
                   from ft_notas    n2
                       ,ft_itens_nf it2
                       ,ft_notas    n
                  where it2.id_ft_nota = n2.id
                    and it2.doc_origem = n.num_nota
                    and it2.sr_nota    = n.sr_nota
                    and n.id           = p_id_nf
                    and it2.seq_origem = p_id_item
                 union all
                 select sum(it3.qtd ) qtde
                   from ce_itens_nf it3
                  where it3.seq_ori = p_id_item);
   
      v_ret number(15,
                   6);
   begin
      open cr;
      fetch cr
         into v_ret;
      close cr;
      return nvl(v_ret,
                 0);
   end;
   --------------------------------------------------------------------------------
   function soma_fat_nf(seq in ft_itens_nf.seq_item%type
                       ,qtf in number) return boolean
   /*
      || Altera qtd faturada do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
   
   begin
   
      select qtd
            ,qtd_fat
            ,qtd_dev
        into v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
        from ft_itens_nf
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_fat + qtf > v_qtd then
         return false;
      end if;
   
      update ft_itens_nf set qtd_fat = qtd_fat + qtf where seq_item = seq;
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function soma_dev_nf(seq in ft_itens_nf.seq_item%type
                       ,qtf in number) return boolean
   /*
      || Altera qtd devolvida do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
   
   begin
   
      select qtd
            ,qtd_fat
            ,qtd_dev
        into v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
        from ft_itens_nf i
            ,ft_notas    n
       where i.id = seq
         and n.id = i.id_ft_nota
         and n.status != 'C';
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if nvl(v_qtd_dev,
             0) + qtf > v_qtd then
         return false;
      end if;
   
      update ft_itens_nf
         set qtd_dev = nvl(qtd_dev,
                           0) + qtf
       where id = seq;
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function subtrai_fat_nf(seq in ft_itens_nf.seq_item%type
                          ,qtf in number) return boolean
   /*
      || Subtrai qtd faturada do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
   
   begin
   
      select qtd
            ,qtd_fat
            ,qtd_dev
        into v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
        from ft_itens_nf
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_fat - qtf < 0 then
         return false;
      end if;
   
      update ft_itens_nf set qtd_fat = qtd_fat - qtf where seq_item = seq;
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function subtrai_dev_nf(seq in ft_itens_nf.seq_item%type
                          ,qtf in number) return boolean
   /*
      || Subtrai qtd devolvida do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
   
   begin
      begin
         select qtd
               ,qtd_fat
               ,qtd_dev
           into v_qtd
               ,v_qtd_fat
               ,v_qtd_dev
           from ft_itens_nf
          where seq_item = seq;
      exception
         when others then
            return true;
      end;
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);


   if v_qtd_dev - qtf < 0 then
      update ft_itens_nf set qtd_dev = 0 where seq_item = seq;
   else
      update ft_itens_nf set qtd_dev = qtd_dev - qtf where seq_item = seq;
   end if;
  
   -- if user = 'GESTAO' THEN
     -- RAISE_APPLICATION_ERROR(-20100,seq || ' ## ' ||v_qtd_fat || ' - '||  v_qtd_dev ||' # '|| qtf );
   -- END IF;

      return true;
   
   exception
   
      when others then
         return false;
     
   end;

   --------------------------------------------------------------------------------
   function saldo_ped(emp ft_pedidos.empresa%type
                     ,fil ft_pedidos.filial%type
                     ,ped ft_pedidos.num_nota%type) return number
   /*
      || Retorna saldo a faturar no pedido
      */
    is
   
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
      v_qtd_can number;
   
   begin
   
      select sum(qtd_ped)
            ,sum(qtd_dev)
            ,sum(qtd_fat)
            ,sum(qtd_can)
        into v_qtd
            ,v_qtd_dev
            ,v_qtd_fat
            ,v_qtd_can
        from ft_itens_ped
       where empresa = emp
         and filial = fil
         and num_pedido = ped;
   
      v_saldo := nvl(v_qtd,
                     0) - nvl(v_qtd_fat,
                              0) - nvl(v_qtd_can,
                                       0);
   
      return v_saldo;
   
   end;

   --------------------------------------------------------------------------------
   function saldo_item_ped(seq in ft_itens_ped.seq_item%type)
      return ft_itens_ped.qtd_ped%type
   /*
      || Retorna saldo do item do pedido
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_qtd_can number;
   
   begin
   
      select qtd_ped
            ,qtd_fat
            ,qtd_dev
            ,qtd_can
        into v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
            ,v_qtd_can
        from ft_itens_ped
       where seq_item = seq;
      return nvl(v_qtd,
                 0) - nvl(v_qtd_fat,
                          0) - nvl(v_qtd_can,
                                   0);
   
   exception
   
      when others then
         return 0;
      
   end;

   function saldo_item_ped(seq    in ft_itens_ped.seq_item%type
                          ,p_tipo ft_oper_ori.tipo%type) return number is
      cursor cr is
         select n.id
               ,sum(case
                       when p_tipo = 'Q' then
                        (it.qtd)
                       else
                        (it.qtd * it.pruni_sst + nvl(it.vl_ipi,
                                                     0))
                    end) qtd
           from ft_notas    n
               ,ft_itens_nf it
          where it.id = seq
            and it.id_ft_nota = n.id
            and n.status != 'C'
          group by n.id;
   
      cursor crq is
         select sum(n.qtd_ped)
           from ft_itens_ped n
               ,ft_pedidos   p
          where n.seq_origem = seq
            and p.empresa = n.empresa
            and p.filial = n.filial
            and p.num_pedido = n.num_pedido
            and p.status not in ('X',
                                 'R');
   
      cursor crv is
         select sum(n.qtd_ped * n.valor_unit)
           from ft_itens_ped n
               ,ft_pedidos   p
          where n.seq_origem = seq
            and p.empresa = n.empresa
            and p.filial = n.filial
            and p.num_pedido = n.num_pedido
            and p.status not in ('X',
                                 'R');
   
      v_id number(9);
   
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
   
   begin
      open cr;
      fetch cr
         into v_id
             ,v_qtd;
   
      close cr;
   
      v_qtd_fat := 0;
   
      if p_tipo = 'Q' then
         open crq;
         fetch crq
            into v_qtd_fat;
         close crq;
      else
         open crv;
         fetch crv
            into v_qtd_fat;
         close crv;
      end if;
      v_saldo := nvl(v_qtd,
                     0)
                
                 - abs(nvl(v_qtd_fat,
                           0));
      return v_saldo;
   
   end;
   --------------------------------------------------------------------------------
   function soma_fat_ped(seq in ft_itens_ped.seq_item%type
                        ,qtd in number) return boolean
   /*
      || Altera qtd faturada do item do pedido
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_qtd_can number;
   
      v_emp ft_pedidos.empresa%type;
      v_fil ft_pedidos.filial%type;
      v_num ft_pedidos.num_pedido%type;
   
   begin
   
      select empresa
            ,filial
            ,num_pedido
            ,qtd_ped
            ,qtd_fat
            ,qtd_dev
            ,qtd_can
        into v_emp
            ,v_fil
            ,v_num
            ,v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
            ,v_qtd_can
        from ft_itens_ped
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
      v_qtd_can := nvl(v_qtd_can,
                       0);
   
      if v_qtd - v_qtd_fat - v_qtd_can - qtd < 0 then
         return false;
      end if;
   
      update ft_itens_ped
         set qtd_fat = nvl(qtd_fat,
                           0) + qtd
       where seq_item = seq;
   
      status_ped(v_emp,
                 v_fil,
                 v_num);
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function subtrai_fat_ped(seq in ft_itens_ped.seq_item%type
                           ,qtd in number) return boolean
   /*
      || Altera qtd faturada do item do pedido
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_emp     ft_pedidos.empresa%type;
      v_fil     ft_pedidos.filial%type;
      v_num     ft_pedidos.num_pedido%type;
   
   begin
   
      select empresa
            ,filial
            ,num_pedido
            ,qtd_ped
            ,qtd_fat
            ,qtd_dev
        into v_emp
            ,v_fil
            ,v_num
            ,v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
        from ft_itens_ped
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_fat - qtd < 0 then
         return false;
      end if;
   
      update ft_itens_ped set qtd_fat = qtd_fat - qtd where seq_item = seq;
   
      status_ped(v_emp,
                 v_fil,
                 v_num);
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   procedure status_ped(emp ft_pedidos.empresa%type
                       ,fil ft_pedidos.filial%type
                       ,ped ft_pedidos.num_nota%type)
   /*
      || Atualiza status do pedido dependendo das quantidades
      */
    is
   
      v_status  ft_pedidos.status%type;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
      v_qtd_can number;
   
   begin
   
      select sum(qtd_ped)
            ,sum(qtd_dev)
            ,sum(qtd_fat)
            ,sum(qtd_can)
        into v_qtd
            ,v_qtd_dev
            ,v_qtd_fat
            ,v_qtd_can
        from ft_itens_ped
       where empresa = emp
         and filial = fil
         and num_pedido = ped;
   
      if nvl(v_qtd_fat,
             0) = 0 then
         v_status := 'A';
      elsif v_qtd - nvl(v_qtd_fat,
                        0) - nvl(v_qtd_can,
                                 0) > 0 then
         v_status := 'P';
      else
         v_status := 'F';
      end if;
      update ft_pedidos
         set status = v_status
       where empresa = emp
         and filial = fil
         and num_pedido = ped;
   
   end;

   --------------------------------------------------------------------------------
   procedure status_exp(emp ft_pedidos.empresa%type
                       ,fil ft_pedidos.filial%type
                       ,ped ft_pedidos.num_nota%type)
   /*
      || Atualiza status do pedido dependendo das quantidades (para expedicao)
      */
    is
   
      v_status  ft_pedidos.status%type;
      v_qtd     number;
      v_qtd_dev number;
      v_qtd_fat number;
      v_qtd_can number;
   
   begin
   
      select sum(qtd_ped)
            ,sum(qtd_dev)
            ,sum(qtd_fat)
            ,sum(qtd_can)
        into v_qtd
            ,v_qtd_dev
            ,v_qtd_fat
            ,v_qtd_can
        from ft_itens_ped
       where empresa = emp
         and filial = fil
         and num_pedido = ped;
   
      if nvl(v_qtd_fat,
             0) = 0 then
         v_status := 'A';
      else
         v_status := 'P';
      end if;
      update ft_pedidos
         set status = v_status
       where empresa = emp
         and filial = fil
         and num_pedido = ped;
   
   end;

   --------------------------------------------------------------------------------
   function soma_fat_exp(seq in ft_itens_ped.seq_item%type
                        ,qtd in number) return boolean
   /*
      || Altera qtd faturada do item do pedido (na expedicao)
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_qtd_can number;
   
      v_emp ft_pedidos.empresa%type;
      v_fil ft_pedidos.filial%type;
      v_num ft_pedidos.num_pedido%type;
      v_ret boolean;
   
   begin
   
      select empresa
            ,filial
            ,num_pedido
            ,qtd_ped
            ,qtd_fat
            ,qtd_dev
            ,qtd_can
        into v_emp
            ,v_fil
            ,v_num
            ,v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
            ,v_qtd_can
        from ft_itens_ped
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
      v_qtd_can := nvl(v_qtd_can,
                       0);
   
      if v_qtd - v_qtd_fat - v_qtd_can - qtd < 0 then
         v_ret := false;
      else
         v_ret := true;
      end if;
   
      update ft_itens_ped
         set qtd_fat = nvl(qtd_fat,
                           0) + qtd
       where seq_item = seq;
   
      status_exp(v_emp,
                 v_fil,
                 v_num);
   
      return v_ret;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function subtrai_fat_exp(seq in ft_itens_ped.seq_item%type
                           ,qtd in number) return boolean
   /*
      || Altera qtd faturada do item do pedido
      */
    is
   
      v_qtd     number;
      v_qtd_fat number;
      v_qtd_dev number;
      v_emp     ft_pedidos.empresa%type;
      v_fil     ft_pedidos.filial%type;
      v_num     ft_pedidos.num_pedido%type;
   
   begin
   
      select empresa
            ,filial
            ,num_pedido
            ,qtd_ped
            ,qtd_fat
            ,qtd_dev
        into v_emp
            ,v_fil
            ,v_num
            ,v_qtd
            ,v_qtd_fat
            ,v_qtd_dev
        from ft_itens_ped
       where seq_item = seq;
   
      v_qtd_fat := nvl(v_qtd_fat,
                       0);
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_fat - qtd < 0 then
         return false;
      end if;
   
      update ft_itens_ped set qtd_fat = qtd_fat - qtd where seq_item = seq;
   
      status_exp(v_emp,
                 v_fil,
                 v_num);
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function saldo_rm(emp ce_notas.empresa%type
                    ,fil ce_notas.filial%type
                    ,ped ce_notas.num_nota%type
                    ,ser ce_notas.sr_nota%type
                    ,fir ce_notas.cod_fornec%type) return number
   /*
      || Retorna saldo a faturar na nota
      */
    is
   
      v_saldo   number;
      v_qtd     number;
      v_qtd_dev number;
   
   begin
   
      select sum(a.qtd)
            ,sum(b.qtd_dev)
        into v_qtd
            ,v_qtd_dev
        from ce_itens_nf a
            ,ce_itdev_nf b
       where a.empresa = emp
         and a.filial = fil
         and a.num_nota = ped
         and a.sr_nota = ser
         and a.cod_fornec = fir
         and a.parte = 0
         and a.id = b.seq_item(+);
   
      v_saldo := nvl(v_qtd,
                     0) - nvl(v_qtd_dev,
                              0);
   
      return v_saldo;
   
   end;

   --------------------------------------------------------------------------------
   function saldo_item_rm(seq in ce_itens_nf.id%type) return ce_itens_nf.qtd%type
   /*
      || Retorna saldo do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_dev number;
   
   begin
   
      select a.qtd
            ,b.qtd_dev
        into v_qtd
            ,v_qtd_dev
        from ce_itens_nf a
            ,ce_itdev_nf b
       where a.id = seq
         and a.id = b.seq_item(+);
   
      return nvl(v_qtd,
                 0) - nvl(v_qtd_dev,
                          0);
   
   exception
   
      when others then
         return 0;
      
   end;

   --------------------------------------------------------------------------------
   function soma_dev_rm(seq in ce_itens_nf.id%type
                       ,qtf in number) return boolean
   /*
      || Altera qtd devolvida do item da nota
      */
    is
   
      cursor cr1 is
         select 1 from ce_itdev_nf where seq_item = seq;
   
      v_num     number;
      v_qtd     number;
      v_qtd_dev number;
   
   begin
   
      select a.qtd
            ,b.qtd_dev
        into v_qtd
            ,v_qtd_dev
        from ce_itens_nf a
            ,ce_itdev_nf b
       where a.id = seq
         and a.id = b.seq_item(+);
   
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_dev + qtf > v_qtd then
         return false;
      end if;
   
      open cr1;
      fetch cr1
         into v_num;
      if cr1%notfound then
         v_num := 0;
      end if;
      close cr1;
   
      if v_num = 0 then
         insert into ce_itdev_nf
         values
            (seq
            ,qtf);
      else
         update ce_itdev_nf
            set qtd_dev = nvl(qtd_dev,
                              0) + qtf
          where seq_item = seq;
      end if;
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

   --------------------------------------------------------------------------------
   function subtrai_dev_rm(seq in ce_itens_nf.id%type
                          ,qtf in number) return boolean
   /*
      || Subtrai qtd devolvida do item da nota
      */
    is
   
      v_qtd     number;
      v_qtd_dev number;
   
   begin
   
      select a.qtd
            ,b.qtd_dev
        into v_qtd
            ,v_qtd_dev
        from ce_itens_nf a
            ,ce_itdev_nf b
       where a.id = seq
         and a.id = b.seq_item(+);
   
      v_qtd_dev := nvl(v_qtd_dev,
                       0);
   
      if v_qtd_dev - qtf < 0 then
         return false;
      end if;
   
      if qtf = v_qtd_dev then
         delete from ce_itdev_nf where seq_item = seq;
      else
         update ce_itdev_nf set qtd_dev = qtd_dev - qtf where seq_item = seq;
      end if;
   
      return true;
   
   exception
   
      when others then
         return false;
      
   end;

end ft_ori;
/
