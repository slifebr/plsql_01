create or replace package cd_aprova_utl is

  --------------------------------------------------------------------------------
  --|| CD_aprova_UTL : Utilitarios para Aprovacao - Especificacao
  --------------------------------------------------------------------------------

  vn_menu number(1);

  procedure gerar;
  procedure gerar_todos;
  procedure gerar_suprimentos;
  procedure gerar_comercial;
  procedure set_menu(p_origem in number);
  procedure gerar_adiant_af;
  --|-------------------------------------------------------------------
  --| FOLLOW-UP  DE SUPRIMENTOS   
  --|-------------------------------------------------------------------
  procedure gerar_follow_supr(p_emp cd_filiais.empresa%type,
                              p_fil cd_filiais.filial%type);
  procedure limpar_follow_supr;

  --|------------------------------------------------------------
  --|GERAR PENDENCIAS DE PRE-RECPCAO COM VENCIMENTOS VENCIDOS 
  --| OU A VENCER DENTRO DE 5 DIAS QUE NÃO ESTÁ EFETIVADO
  --|------------------------------------------------------------
  procedure gerar_prerec_fin;

  --|------------------------------------------------------------
  --| GERAR PENDENCIAS DE APROVAÇÕES ADMINISTRATIVAS 
  --| VIAGEM/VEICULOS
  --|------------------------------------------------------------
  procedure gerar_aprova_adm;

  --|------------------------------------------------------------
  --| GERAR OP's NOVA
  --|------------------------------------------------------------
  procedure gerar_op_nova;

  --|------------------------------------------------------------
  --| GERAR OP's Abertas pendentes de Encerramento 
  --|------------------------------------------------------------
  procedure gerar_op_aberta;
  procedure limpar_opos_pendente;
  --|------------------------------------------------------------
  --|retorna qtd de followup DE SUPR
  --|------------------------------------------------------------
  function fnc_conta_follow_supr(p_emp   number,
                                 p_fil   number,
                                 p_docto cd_follow_aprova.docto%type)
    return number;
  --|------------------------------------------------------------                      
  function get_menu return number;
  --|------------------------------------------------------------
  --|retorna data de folloew-up ou data original
  --|------------------------------------------------------------
  function fnc_dt_prev_aprov(p_num   cd_follow_aprova.num_acesso%type,
                             p_orig  cd_follow_aprova.origem%type,
                             p_docto cd_follow_aprova.docto%type,
                             p_dt    date) return date;

  --|------------------------------------------------------------
  --|retorna qtd de followup COMERCIAL
  --|------------------------------------------------------------
  function fnc_conta_follow(p_num   cd_follow_aprova.num_acesso%type,
                            p_orig  cd_follow_aprova.origem%type,
                            p_docto cd_follow_aprova.docto%type)
    return number;

  --|------------------------------------------------------------
  --|retorna SE TEM ACESSO AO PROCESSO
  --|------------------------------------------------------------
  function fnc_tem_acesso(p_tipo cd_aprova_usu.tipo%type,
                          p_acao cd_aprova_usu.acao%type) return boolean;

  --|------------------------------------------------------------
  --|retorna SE TEM ACESSO AO PROCESSO
  --|------------------------------------------------------------
  function fnc_tem_acesso_n(p_tipo cd_aprova_usu.tipo%type,
                            p_acao cd_aprova_usu.acao%type) return number;

  function produto_evento_comercial(p_org t_aprova_comercial.origem%type,
                                    p_num t_aprova_comercial.num_acesso%type)
    return varchar2;
end cd_aprova_utl;
/
create or replace package body cd_aprova_utl is

  --------------------------------------------------------------------------------
  --|| CD_aprova_UTL : Utilitarios para Aprovacao - Corpo
  --------------------------------------------------------------------------------
  procedure limpar_opos_pendente is
  begin
    DELETE FROM T_OPOS_PENDENTE;
    COMMIT;
  end;

  procedure gerar_todos
  
   is
    cursor curped is
      select a.*, p.firma
        from ft_aprov_ped a, ft_pedidos p
       where p.empresa = a.empresa
         and p.filial = a.filial
         and p.num_pedido = a.num_pedido
         and p.status in ('B');
  
    cursor curcargo(pc_cargo ft_cod_aprov.cargo%type,
                    pc_nivel ft_cod_aprov.nivel%type) is
      select *
        from cd_cargos
       where lib_cniv.sub_nivel(cargo, pc_cargo) = 'S'
          or (pc_nivel = 'S' and
              lib_cniv.nivel(cargo) = lib_cniv.nivel(pc_cargo));
  
    cursor curusr(pc_cargo ft_cod_aprov.cargo%type) is
      select *
        from cd_firmas
       where cargo = pc_cargo
         and usuario is not null;
  
    cursor curusr2 is
      select * from cd_firmas where usuario is not null;
  
    cursor cursol is
      select s.empresa,
             s.filial,
             s.num_req,
             i.tipo_compra,
             sum(i.qtde_aprovada *
                 co_ordens_utl.ultimo_preco(i.empresa, i.produto)) valor_prev,
             s.dt_req
        from co_requis s, co_itens_req i
       where s.status = 'E'
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_req = s.num_req
       group by s.empresa, s.filial, s.num_req, i.tipo_compra, s.dt_req;
  
    cursor currom is
      select x.empresa, x.filial, x.seq_rom, x.firma
        from ft_roman x
       where x.status = 'E';
  
    cursor curaprova(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_req c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    --| Cotacoes
    cursor curcot is
      select s.empresa,
             s.filial,
             s.num_cot,
             s.dt_cot,
             sum((c.qtde_neg * c.preco) +
                 (c.qtde_neg * c.preco * nvl(c.aliq_ipi, 0) / 100)) valor_cotado
        from co_cotacao s, co_itens i, co_itens_cot c
       where s.status in ('E', 'P')
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_cot = s.num_cot
         and c.empresa = i.empresa
         and c.filial = i.filial
         and c.num_req = i.num_cot
         and c.item_req = i.item_cot
         and c.escolha = 1
         and s.aprovador is null
         and c.ordem is null
         and exists (select 1
                from cd_firmas f, co_tipos_cot a
               where a.firma = f.firma
                 and a.tipo_compra = i.tipo_compra
                 and f.usuario = user)
       group by s.empresa, s.filial, s.num_cot, s.dt_cot;
  
    cursor curaprova2(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_cot c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    cursor curreq is
      select s.empresa, s.filial, s.num_req, s.produto, c.requisitante
        from ce_itens_req s, ce_requis c, cd_firmas f
       where c.empresa = s.empresa
         and c.filial = s.filial
         and c.num_req = s.num_req
         and c.requisitante = f.usuario
         and s.situacao = '1';
  
    cursor curpag is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 271;
  
    cursor currm is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 204;
  
    --/ SOLICITAC?ES PENDENTES DE COTAC?O
    cursor cursol_comp is
      select zz.*, necessidade - leadtime pto_compra
        from (select distinct s.empresa,
                              s.filial,
                              s.num_req,
                              i.tipo_compra,
                              i.produto,
                              p.descricao,
                              i.dt_entrega necessidade,
                              case
                                when nvl(p.leadtime, 0) = 0 then
                                 co_util.prazo_interno(i.empresa, i.filial)
                                else
                                 p.leadtime
                              end leadtime
                from co_requis s, co_itens_req i, ce_produtos p
               where s.status = 'A'
                 and i.empresa = s.empresa
                 and i.filial = s.filial
                 and i.num_req = s.num_req
                 and p.empresa = i.empresa
                 and p.produto = i.produto
                 and i.num_cot is null
                 and i.dt_entrega is not null) zz
       order by num_req, 9, produto;
  
    cursor craf is
      select empresa, filial, ordem, fornecedor, comprador, dt_ordem
        from co_ordens a
       where (user = 'GESTAO' or a.comprador = user or
             (user in (select usuario
                          from cd_firmas b, cd_cargos c
                         where b.usuario = user
                           and b.cargo = c.cargo
                           and c.compra = 'S')))
         and a.email_forn is null
       order by dt_ordem;
    --and a.dt_ordem >= '26/02/2008';
  
    cursor cr_solorc is
      select oc_util.fnc_nome_cliente_solic(s.id_solicorcam) cliente, s.*
        from oc_solic_orcam s
       where not exists (select 1
                from oc_orcam_venda v
               where v.id_solicorcam = s.id_solicorcam)
         and not exists
       (select 1
                from oc_orcam_prod p, oc_solic_orc_prod sp
               where p.id_solicorcprod = sp.id_solicorcprod
                 and sp.id_solicorcam = s.id_solicorcam)
         and (user = 'GESTAO' or
             user in
             (select u.usuario from cd_aprova_usu u where tipo = 'OC'))
         and s.status = 'E';
  
    cursor cr_orcto is
      select * from voc_orcto_pendente;
  
    cursor cr_prop is
      select * from voc_prop_pendente;
  
    v_cargo  ft_cod_aprov.cargo%type;
    v_nivel  ft_cod_aprov.nivel%type;
    v_motivo t_aprova.motivo%type;
    v_nome   cd_firmas.nome%type;
    v_ret    boolean;
    v_libera char(1);
    v_msg    varchar2(1000);
    v_alcada varchar2(1) := 'N';
    vl_prev  number(15, 2);
  begin
  
    -- Deletar temporaria
    delete t_aprova;
  
    -- Solicitacao de Compra (S)
    for regsol in cursol loop
    
      -- Tipo de Compra
      select descricao
        into v_nome
        from co_tipos_compra
       where tipo_compra = regsol.tipo_compra;
    
      -- Pessoas conforme tipo de compra
      for regaprova in curaprova(regsol.tipo_compra) loop
        v_alcada := 'N';
        -- Tabela Temporaria
        insert into t_aprova
        values
          ('S',
           regaprova.usuario,
           to_char(regsol.num_req),
           regsol.empresa,
           'SOLICITACAO COMPRA',
           regsol.filial,
           v_nome,
           regsol.num_req,
           null,
           null,
           null,
           v_alcada,
           regsol.valor_prev,
           regsol.dt_req);
      
      end loop;
    
    end loop;
    --|-------------------------------------------------------------
    --| Cotacao de Compra (C)
    --|-------------------------------------------------------------      
    for regcot in curcot loop
      -- Tabela Temporaria
      v_alcada := 'S';
      insert into t_aprova
      values
        ('C',
         user,
         to_char(regcot.num_cot),
         regcot.empresa,
         'COTACAO',
         regcot.filial,
         v_nome,
         regcot.num_cot,
         null,
         null,
         null,
         v_alcada,
         regcot.valor_cotado,
         regcot.dt_cot);
    end loop;
    --|-------------------------------------------------------------
    --| Solicitação Orcamento (SO): Solic. sem orcamento 
    --| 
    --|-------------------------------------------------------------      
    for regsolorc in cr_solorc loop
      -- Tabela Temporaria
    
      insert into t_aprova
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         sr_nota,
         parte,
         firma,
         alcada,
         vl_prev,
         dt_docto)
      values
        ('SOR',
         user,
         regsolorc.id_solicorcam,
         1 --EMPRESA
        ,
         'SOLICITACAO SEM ORCAMENTO' || chr(10) || 'DATA_ENTREGA : ' ||
         to_char(regsolorc.entrega_prop, 'dd/mm/rrrr') || chr(10) ||
         'Resp.: ' || regsolorc.resp,
         1 --FILIAL
        ,
         regsolorc.cliente,
         to_char(regsolorc.id_solicorcam),
         null,
         null,
         null,
         v_alcada,
         null,
         regsolorc.dt);
    end loop;
  
    --|-------------------------------------------------------------
    --| Orcamento (OR): Sem proposta com menos ou = a 3 dias para entrega de proposta
    --|-------------------------------------------------------------      
    for regorcto in cr_orcto loop
      -- Tabela Temporaria
    
      insert into t_aprova
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         sr_nota,
         parte,
         firma,
         alcada,
         vl_prev,
         dt_docto)
      values
        ('OR',
         user,
         regorcto.cd_orcam || '/' || regorcto.rev,
         1 --EMPRESA
        ,
         'ORCAMENTO-S/PROPOSTA' || chr(10) || 'DATA_ENTREGA : ' ||
         to_char(regorcto.prev_entrega, 'dd/mm/rrrr') || chr(10) ||
         'Resp.: ' || regorcto.resp,
         1 --FILIAL
        ,
         regorcto.nome_cli,
         to_char(regorcto.id_orcamvenda),
         null,
         null,
         null,
         v_alcada,
         regorcto.preco,
         regorcto.dt_orcam);
    end loop;
  
    --|--------------------------------------------------------------------------
    --| Proposta (PROP): Proposta com menos ou = a 3 dias para entrega ao Cliente
    --|--------------------------------------------------------------------------      
    for regprop in cr_prop loop
      -- Tabela Temporaria
    
      insert into t_aprova
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         sr_nota,
         parte,
         firma,
         alcada,
         vl_prev,
         dt_docto)
      values
        ('PROP',
         user,
         regprop.cd_prop || '/' || regprop.revisao,
         1 --EMPRESA
        ,
         'PROPOSTA-PENDENTE' || chr(10) || 'DATA_ENTREGA : ' ||
         to_char(regprop.prev_entrega, 'dd/mm/rrrr') || chr(10) ||
         'Resp.: ' || regprop.resp,
         1 --FILIAL
        ,
         regprop.nome_cli,
         to_char(regprop.seq_ocprop),
         null,
         null,
         null,
         v_alcada,
         regprop.preco_bruto,
         regprop.dt);
    end loop;
  
  end;

  --------------------------------------------------------------------------------
  procedure set_menu(p_origem in number) is
  begin
  
    vn_menu := p_origem;
  
  end;

  --------------------------------------------------------------------------------
  function get_menu return number is
  begin
  
    return vn_menu;
  
  end;

  --------------------------------------------------------------------------------
  procedure gerar2
  
   is
    cursor curped is
      select a.*, p.firma
        from ft_aprov_ped a, ft_pedidos p
       where p.empresa = a.empresa
         and p.filial = a.filial
         and p.num_pedido = a.num_pedido
         and p.status in ('B');
  
    cursor curcargo(pc_cargo ft_cod_aprov.cargo%type,
                    pc_nivel ft_cod_aprov.nivel%type) is
      select *
        from cd_cargos
       where lib_cniv.sub_nivel(cargo, pc_cargo) = 'S'
          or (pc_nivel = 'S' and
              lib_cniv.nivel(cargo) = lib_cniv.nivel(pc_cargo));
  
    cursor curusr(pc_cargo ft_cod_aprov.cargo%type) is
      select *
        from cd_firmas
       where cargo = pc_cargo
         and usuario is not null;
  
    cursor curusr2 is
      select * from cd_firmas where usuario is not null;
  
    cursor cursol is
      select s.empresa,
             s.filial,
             s.num_req,
             i.tipo_compra,
             sum(i.qtde_aprovada *
                 co_ordens_utl.ultimo_preco(i.empresa, i.produto)) valor_prev,
             s.dt_req
        from co_requis s, co_itens_req i
       where s.status = 'E'
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_req = s.num_req
       group by s.empresa, s.filial, s.num_req, i.tipo_compra, s.dt_req;
  
    cursor currom is
      select x.empresa, x.filial, x.seq_rom, x.firma
        from ft_roman x
       where x.status = 'E';
  
    cursor curaprova(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_req c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    --| Cotacoes
    cursor curcot is
      select s.empresa,
             s.filial,
             s.num_cot,
             s.dt_cot,
             sum((c.qtde_neg * c.preco) +
                 (c.qtde_neg * c.preco * nvl(c.aliq_ipi, 0) / 100)) valor_cotado
        from co_cotacao s, co_itens i, co_itens_cot c
       where s.status in ('E', 'P')
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_cot = s.num_cot
         and c.empresa = i.empresa
         and c.filial = i.filial
         and c.num_req = i.num_cot
         and c.item_req = i.item_cot
         and c.escolha = 1
         and s.aprovador is null
         and c.ordem is null
         and exists (select 1
                from cd_firmas f, co_tipos_cot a
               where a.firma = f.firma
                 and a.tipo_compra = i.tipo_compra
                 and f.usuario = user)
       group by s.empresa, s.filial, s.num_cot, s.dt_cot;
  
    cursor curaprova2(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_cot c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    cursor curreq is
      select s.empresa, s.filial, s.num_req, s.produto, c.requisitante
        from ce_itens_req s, ce_requis c, cd_firmas f
       where c.empresa = s.empresa
         and c.filial = s.filial
         and c.num_req = s.num_req
         and c.requisitante = f.usuario
         and s.situacao = '1';
  
    cursor curpag is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 271;
  
    cursor currm is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 204;
  
    --/ SOLICITAC?ES PENDENTES DE COTAC?O
    cursor cursol_comp is
      select zz.*, necessidade - leadtime pto_compra
        from (select distinct s.empresa,
                              s.filial,
                              s.num_req,
                              i.tipo_compra,
                              i.produto,
                              p.descricao,
                              i.dt_entrega necessidade,
                              case
                                when nvl(p.leadtime, 0) = 0 then
                                 co_util.prazo_interno(i.empresa, i.filial)
                                else
                                 p.leadtime
                              end leadtime
                from co_requis s, co_itens_req i, ce_produtos p
               where s.status = 'A'
                 and i.empresa = s.empresa
                 and i.filial = s.filial
                 and i.num_req = s.num_req
                 and p.empresa = i.empresa
                 and p.produto = i.produto
                 and i.num_cot is null
                 and i.dt_entrega is not null) zz
       order by num_req, 9, produto;
  
    cursor craf is
      select empresa, filial, ordem, fornecedor, comprador, dt_ordem
        from co_ordens a
       where (user = 'GESTAO' or a.comprador = user or
             (user in (select usuario
                          from cd_firmas b, cd_cargos c
                         where b.usuario = user
                           and b.cargo = c.cargo
                           and c.compra = 'S')))
         and a.email_forn is null
       order by dt_ordem;
    --and a.dt_ordem >= '26/02/2008';
  
    cursor cr_orcto is
      select * from voc_orcto_pendente;
  
    cursor cr_prop is
      select * from voc_prop_pendente;
    /*
    select upper(v.resp) resp
          ,v.dt_orcam
          ,v.dt_entrega_prop
          ,v.cd_orcam
          ,v.nome_cli
          ,v.id_orcamvenda
          ,v.rev
          ,case
              when v.dt_entrega_prop is null then
               v.dt_orcam + 5
              else
               v.dt_entrega_prop
           end prev_entrega
          ,v.dt_orcam - trunc(sysdate) prazo_entrega
          ,v.preco
          ,nvl(v.custo_prod,0) + nvl(v.custo_mo,0) custo
      from oc_orcam_venda v
     where (user = 'GESTAO' or
           user in (select u.usuario from oc_orcam_usu u))
       and v.rev = (select max(v2.rev)
                      from oc_orcam_venda v2
                     where v2.cd_orcam = v.cd_orcam)
       and not exists (select 1
              from oc_proposta p
             where p.id_orcamvenda = v.id_orcamvenda)
       and v.status = 'D'
       and v.dt_orcam >= '01/07/2015'
       and (case
              when v.dt_entrega_prop is null then
               v.dt_orcam + 5
              else
               v.dt_entrega_prop
           end )- trunc(sysdate) <= 3;
    */
    v_cargo  ft_cod_aprov.cargo%type;
    v_nivel  ft_cod_aprov.nivel%type;
    v_motivo t_aprova.motivo%type;
    v_nome   cd_firmas.nome%type;
    v_ret    boolean;
    v_libera char(1);
    v_msg    varchar2(1000);
    v_alcada varchar2(1) := 'N';
    vl_prev  number(15, 2);
  begin
  
    -- Deletar temporaria
    delete t_aprova;
  
    -- Solicitacao de Compra (S)
    for regsol in cursol loop
    
      -- Tipo de Compra
      select descricao
        into v_nome
        from co_tipos_compra
       where tipo_compra = regsol.tipo_compra;
    
      -- Pessoas conforme tipo de compra
      for regaprova in curaprova(regsol.tipo_compra) loop
        v_alcada := 'N';
        -- Tabela Temporaria
        insert into t_aprova
        values
          ('S',
           regaprova.usuario,
           to_char(regsol.num_req),
           regsol.empresa,
           'SOLICITACAO COMPRA',
           regsol.filial,
           v_nome,
           regsol.num_req,
           null,
           null,
           null,
           v_alcada,
           regsol.valor_prev,
           regsol.dt_req);
      
      end loop;
    
    end loop;
    --|-------------------------------------------------------------
    --| Cotacao de Compra (C)
    --|-------------------------------------------------------------      
    for regcot in curcot loop
      -- Tabela Temporaria
      v_alcada := 'S';
      insert into t_aprova
      values
        ('C',
         user,
         to_char(regcot.num_cot),
         regcot.empresa,
         'COTACAO',
         regcot.filial,
         v_nome,
         regcot.num_cot,
         null,
         null,
         null,
         v_alcada,
         regcot.valor_cotado,
         regcot.dt_cot);
    end loop;
    --|-------------------------------------------------------------
    --| Orcamento (OR): Sem proposta com menos ou = a 3 dias para entrega de proposta
    --|-------------------------------------------------------------      
    for regorcto in cr_orcto loop
      -- Tabela Temporaria
    
      insert into t_aprova
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         sr_nota,
         parte,
         firma,
         alcada,
         vl_prev,
         dt_docto)
      values
        ('OR',
         user,
         regorcto.cd_orcam || '/' || regorcto.rev,
         1 --EMPRESA
        ,
         'ORCAMENTO-S/PROPOSTA' || chr(10) || 'DATA_ENTREGA : ' ||
         to_char(regorcto.prev_entrega, 'dd/mm/rrrr') || chr(10) ||
         'Resp.: ' || regorcto.resp,
         1 --FILIAL
        ,
         regorcto.nome_cli,
         to_char(regorcto.id_orcamvenda),
         null,
         null,
         null,
         v_alcada,
         regorcto.preco,
         regorcto.dt_orcam);
    end loop;
  
    --|--------------------------------------------------------------------------
    --| Proposta (PROP): Proposta com menos ou = a 3 dias para entrega ao Cliente
    --|--------------------------------------------------------------------------      
    for regprop in cr_prop loop
      -- Tabela Temporaria
    
      insert into t_aprova
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         sr_nota,
         parte,
         firma,
         alcada,
         vl_prev,
         dt_docto)
      values
        ('PROP',
         user,
         regprop.cd_prop || '/' || regprop.revisao,
         1 --EMPRESA
        ,
         'PROPOSTA-PENDENTE' || chr(10) || 'DATA_ENTREGA : ' ||
         to_char(regprop.prev_entrega, 'dd/mm/rrrr') || chr(10) ||
         'Resp.: ' || regprop.resp,
         1 --FILIAL
        ,
         regprop.nome_cli,
         to_char(regprop.seq_ocprop),
         null,
         null,
         null,
         v_alcada,
         regprop.preco_bruto,
         regprop.dt);
    end loop;
    --|================================================================================      
    --|================================================================================
    --|================================================================================
    /*
      For regAF In crAF Loop
    
        Select NOME
          InTo V_NOME
          From CD_Firmas
         Where FIRMA = regAf.FORNECedor;
    
          -- Tabela Temporaria
          Insert InTo T_Aprova Values(  'A',
                                        user,
                                         To_Char( regAF.ORDEM ),
                                        regAF.EMPRESA,
                                        'COMPR.('|| regAF.comprador||') - EMAIL -'||to_char(regAF.dt_ordem,'dd/mm/rrrr'),
                                        regAF.FILIAL,
                                        V_NOME,
                                        regAF.ORDEM,
                                        Null,
                                        Null,
                                        Null );
    
        End Loop;
    */
    /*
      -- Recepcao de Mercadoria (M)
      For regPAG In curRM Loop
    
        -- Entidade da Nota
        v_msg := 'Recep.Merc./Cod fornec.:'||regPAG.COD_FORNEC;
    
        Select NOME
          InTo V_NOME
          From CD_Firmas
         Where FIRMA = regPAG.COD_FORNEC;
    
        -- Verifica se tem acesso ao botao
        V_LIBERA := Lib_Admin.LIBERA( 204, regPAG.EMPRESA, regPAG.FILIAL, 6 );
        If V_LIBERA = 'S' Then
    
          -- Tabela Temporaria
          Insert InTo T_Aprova Values(  'M',
                                        USER,
                                        To_Char( regPAG.NUM_NOTA ),
                                        regPAG.EMPRESA,
                                        'DIA UTIL/ORDEM DE COMPRA',
                                        regPAG.FILIAL,
                                        V_NOME,
                                        regPAG.NUM_NOTA,
                                        regPAG.SR_NOTA,
                                        regPAG.PARTE,
                                        regPAG.COD_FORNEC );
    
        End If;
    
      End Loop;
    
    */
    -- Pagamento Direto (D)
    /* 
     For regPAG In curPAG Loop
    
        -- Entidade da Nota
    
        v_msg := 'Pagto Direto: Cod fornec.:'||regPAG.COD_FORNEC;
    
        Select NOME
          InTo V_NOME
          From CD_Firmas
         Where FIRMA = regPAG.COD_FORNEC;
    
    
        -- Verifica se tem acesso ao botao
        V_LIBERA := Lib_Admin.LIBERA( 271, regPAG.EMPRESA, regPAG.FILIAL, 6 );
    
        If V_LIBERA = 'S' Then
    
          -- Tabela Temporaria
          Insert InTo T_Aprova Values(  'D',
                                        USER,
                                        To_Char( regPAG.NUM_NOTA ),
                                        regPAG.EMPRESA,
                                        'DIA UTIL/CONTRATO',
                                        regPAG.FILIAL,
                                        V_NOME,
                                        regPAG.NUM_NOTA,
                                        regPAG.SR_NOTA,
                                        regPAG.PARTE,
                                        regPAG.COD_FORNEC );
    
        End If;
    
      End Loop;
    */
    /*
    -- ROMANEIO
      For regROM In curROM Loop
    
        -- Entidade da Nota
        Select NOME
          InTo V_NOME
          From CD_Firmas
         Where FIRMA = regROM.FIRMA;
    
        -- Verifica se tem acesso ao botao
        V_LIBERA := Lib_Admin.LIBERA( 1160, regROM.EMPRESA, regROM.FILIAL, 4 );
    
        If V_LIBERA = 'S' Then
    
          -- Tabela Temporaria
          Insert InTo T_Aprova Values(  'X',
                                        USER,
                                        To_Char( regROM.SEQ_ROM ),
                                        regROM.EMPRESA,
                                        'PEDIDO NAO GERADO',
                                        regROM.FILIAL,
                                        V_NOME,
                                        regROM.SEQ_ROM,
                                        NULL,
                                        NULL,
                                        NULL);
    
        End If;
    
      End Loop;
    */
    -- Requisicao de Estoque (R)
    /*For regREQ In curREQ Loop
        -- Nome
    
        v_msg := 'Requis Estq.|Requisitante.:'||regREQ.REQUISITANTE;
    
      --  Select NOME
      --    InTo V_NOME
      --    From CD_Firmas
       --  Where USUARIO = regREQ.REQUISITANTE;
    
        -- Todos os usuarios do banco de dados
        For regUSR In curUSR2 Loop
    
          -- Usuario pode aprovar
          V_RET := CE_Req.APROVA( regREQ.EMPRESA, regREQ.PRODUTO, regUSR.USUARIO );
    
          If V_RET = True Then
    
            -- Tabela Temporaria
            Insert InTo T_Aprova Values(  'R',
                                          regUSR.USUARIO,
                                          To_Char( regREQ.NUM_REQ ),
                                          regREQ.EMPRESA,
                                          'PARA ESTOQUE',
                                          regREQ.FILIAL,
                                          V_NOME,
                                          regREQ.NUM_REQ,
                                          Null,
                                          Null,
                                          Null );
    
          End If;
    
        End Loop;
      End Loop;
    */
    /*
    -- Solicitacao de Compra (S)
    For regSOL In curSOL Loop
    
      -- Tipo de Compra
      Select DESCRICAO
        InTo V_NOME
        From CO_Tipos_Compra
       Where TIPO_COMPRA = regSOL.TIPO_COMPRA;
    
      -- Pessoas conforme tipo de compra
      For regAPROVA In curAPROVA( regSOL.TIPO_COMPRA ) Loop
    
        -- Tabela Temporaria
        Insert InTo T_Aprova Values(  'S',                             
                                      regAPROVA.USUARIO,
                                      To_Char(regSOL.NUM_REQ ),
                                      regSOL.EMPRESA,
                                      'PARA NEGOCIAR',
                                      regSOL.FILIAL,
                                      V_NOME,
                                      regSOL.NUM_REQ,
                                      Null,
                                      Null,
                                      Null );
    
      End Loop;
    
    End Loop;
    */
    /*
      -- Solicitacao de Compra Para cotar
      For regSOL In curSOL_COMP Loop
    
        -- Tipo de Compra
        Select DESCRICAO
          InTo V_NOME
          From CO_Tipos_Compra
         Where TIPO_COMPRA = regSOL.TIPO_COMPRA;
    
        -- Pessoas conforme tipo de compra
        For regAPROVA In curAPROVA( regSOL.TIPO_COMPRA ) Loop
    
          -- Tabela Temporaria
          Insert InTo T_Aprova Values(  'S',
                                        regAPROVA.USUARIO,
                                        To_Char(regSOL.NUM_REQ ),
                                        regSOL.EMPRESA,
                                        'COTAR SOLICITAC?O: PTO COMPRA:' || TO_CHAR(REGSOL.PTO_COMPRA,'DD/MM/RRRR') 
                                     || ' - Produto: '|| REGSOL.PRODUTO||'-'||REGSOL.DESCRICAO,
                                        regSOL.FILIAL,
                                        V_NOME,
                                        regSOL.NUM_REQ,
                                        Null,
                                        Null,
                                        Null );
    
        End Loop;
    
      End Loop;
    */
  
    /*
      -- Pedido de Nota Fiscal em Aberto (P)
      For regPED In curPED Loop
    
        -- Entidade do Pedido
        Select NOME
          InTo V_NOME
          From CD_Firmas
         Where FIRMA = regPED.FIRMA;
    
        -- Motivo para Aprovacao
        Select CARGO, NIVEL, MOTIVO
          InTo V_CARGO, V_NIVEL, V_MOTIVO
          From FT_Cod_Aprov
         Where CODIGO = regPED.CODIGO;
    
        -- Aprovadores conforme cargo
        For regCARGO In curCARGO( V_CARGO, V_NIVEL ) Loop
    
          -- Pessoas conforme cargo
          For regUSR In curUSR( regCARGO.CARGO ) Loop
    
              -- Tabela Temporaria
              Insert InTo T_Aprova Values(  'P',
                                            regUSR.USUARIO,
                                            To_Char(regPED.NUM_PEDIDO ),
                                            regPED.EMPRESA,
                                            V_MOTIVO,
                                            regPED.FILIAL,
                                            V_NOME,
                                            regPED.NUM_PEDIDO,
                                            Null,
                                            Null,
                                            Null );
    
          End Loop;
    
        End Loop;
    
      End Loop;
    */
  end;
  --|-------------------------------------------------------------------------------   
  procedure gerar is
    v_acesso boolean;
  begin
    -- if user != 'GESTAO' THEN
    gerar_suprimentos;
    gerar_comercial;
  
    --|follow-up de suprimentos
    if fnc_tem_acesso('FLW', 'A') then
      gerar_follow_supr(1, 1);
    end if;
  
    -- END IF;
  
    --|PENDENCIAS FINANCEIRAS DE PRE-RECPCAO
    if fnc_tem_acesso('FCF', 'A') then
      gerar_prerec_fin;
    end if;
    --| PENDENCIAS ADMINISTRATIVAS
  
    if fnc_tem_acesso('AD_0212', 'A') OR fnc_tem_acesso('AD_0211', 'A') OR
       fnc_tem_acesso('AD_0211E', 'A') THEN
    
      gerar_aprova_adm;
      --NULL;
    end if;
  
    --| OP's novas
    if fnc_tem_acesso('OP-N', 'A') then
      gerar_op_nova;
    end if;
  
    --| OP's abertas
    if fnc_tem_acesso('OP-A', 'A') then
      gerar_op_aberta;
    end if;
    
    --| adiantamentos de AF's
    if fnc_tem_acesso('CP_0105', 'A') then
      gerar_adiant_af;
    end if;    
  end;
  --|-------------------------------------------------------------------------------   

  procedure gerar_comercial is
  
    cursor cr_solorc is
      select * from voc_solic_orcto_pendente;
  
    cursor cr_orcto is
      select * from voc_orcto_pendente;
  
    cursor cr_prop is
      select * from voc_prop_pendente;
  
    v_motivo t_aprova.motivo%type;
    v_nome   cd_firmas.nome%type;
    v_ret    boolean;
    v_libera char(1);
    v_msg    varchar2(1000);
    v_alcada varchar2(1) := 'N';
    vl_prev  number(15, 2);
  
    v_status varchar2(100);
    v_rotina number(9);
  
  begin
  
    -- Deletar temporaria
    delete t_aprova_comercial;
    --|-------------------------------------------------------------
    --| Solicitação Orcamento (SO): Solic. sem orcamento 
    --| 
    --|-------------------------------------------------------------      
    for regsolorc in cr_solorc loop
      -- Tabela Temporaria
      v_rotina := lib_admin.rotina('oc_0190');
    
      insert into t_aprova_comercial
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         firma,
         vl_prev,
         dt_docto,
         dt_prev_entrega,
         dias,
         rotina,
         dt_entrega_prop)
      values
        ('SOR',
         user,
         regsolorc.id_solicorcam,
         1 --EMPRESA
        ,
         'SOLICITACAO SEM ORCAMENTO' || chr(10) || 'Contato: ' ||
         regsolorc.contato || chr(10) || 'Resp.: ' || regsolorc.resp ||
         chr(10) || 'Entrega-Prop: ' || regsolorc.dt_follow,
         1 --FILIAL
        ,
         regsolorc.cliente,
         to_char(regsolorc.id_solicorcam),
         null,
         null,
         regsolorc.dt,
         regsolorc.dt_follow,
         regsolorc.dt_follow - trunc(sysdate),
         v_rotina,
         regsolorc.dt_follow);
    end loop;
  
    --|-------------------------------------------------------------
    --| Orcamento (OR): Sem proposta com menos ou = a 3 dias para entrega de proposta
    --|-------------------------------------------------------------      
    for regorcto in cr_orcto loop
      -- Tabela Temporaria
    
      v_rotina := lib_admin.rotina('oc_0203m');
    
      insert into t_aprova_comercial
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         firma,
         vl_prev,
         dt_docto,
         dt_prev_entrega,
         dias,
         dt_entrega_prop)
      values
        ('OR',
         user,
         regorcto.cd_orcam || '/' || regorcto.rev,
         1 --EMPRESA
        ,
         'ORCAMENTO-S/PROPOSTA' || chr(10) || 'Contato: ' ||
         regorcto.contato || chr(10) || 'Resp.: ' || regorcto.resp ||
         chr(10) || 'Entrega-Prop: ' || regorcto.dt_follow,
         1 --FILIAL
        ,
         regorcto.nome_cli,
         to_char(regorcto.id_orcamvenda),
         null,
         regorcto.preco,
         regorcto.dt_orcam,
         regorcto.dt_follow,
         regorcto.dt_follow - trunc(sysdate),
         regorcto.dt_follow);
    end loop;
  
    --|--------------------------------------------------------------------------
    --| Proposta (PROP): Proposta com menos ou = a 3 dias para entrega ao Cliente
    --|--------------------------------------------------------------------------      
    for regprop in cr_prop loop
      -- Tabela Temporaria
      if regprop.status in ('I', 'L') then
        v_status := 'Impresso';
        v_rotina := lib_admin.rotina('oc_0201n');
      else
        v_status := 'Digitado';
        v_rotina := lib_admin.rotina('oc_0201');
      end if;
    
      insert into t_aprova_comercial
        (origem,
         aprovador,
         docto,
         empresa,
         motivo,
         filial,
         entidade,
         num_acesso,
         firma,
         vl_prev,
         dt_docto,
         dt_prev_entrega,
         dias,
         rotina,
         dt_entrega_prop)
      values
        ('PROP',
         user,
         regprop.cd_prop || '/' || regprop.revisao,
         1 --EMPRESA
        ,
         'PROPOSTA-PENDENTE' || chr(10) || 'Contato: ' || regprop.contato ||
         chr(10) || 'Resp.: ' || regprop.resp || chr(10) || 'Status.: ' ||
         v_status,
         1 --FILIAL
        ,
         regprop.nome_cli,
         to_char(regprop.seq_ocprop),
         null,
         regprop.preco_bruto,
         regprop.dt,
         regprop.dt_follow,
         regprop.dt_follow - trunc(sysdate),
         v_rotina,
         regprop.dt_follow);
    end loop;
  end;
  --|-------------------------------------------------------------------------------
  procedure gerar_suprimentos is
    cursor curped is
      select a.*, p.firma
        from ft_aprov_ped a, ft_pedidos p
       where p.empresa = a.empresa
         and p.filial = a.filial
         and p.num_pedido = a.num_pedido
         and p.status in ('B');
  
    cursor curcargo(pc_cargo ft_cod_aprov.cargo%type,
                    pc_nivel ft_cod_aprov.nivel%type) is
      select *
        from cd_cargos
       where lib_cniv.sub_nivel(cargo, pc_cargo) = 'S'
          or (pc_nivel = 'S' and
              lib_cniv.nivel(cargo) = lib_cniv.nivel(pc_cargo));
  
    cursor curusr(pc_cargo ft_cod_aprov.cargo%type) is
      select *
        from cd_firmas
       where cargo = pc_cargo
         and usuario is not null;
  
    cursor curusr2 is
      select * from cd_firmas where usuario is not null;
  
    cursor cursol is
      select s.empresa,
             s.filial,
             s.num_req,
             i.tipo_compra,
             sum(i.qtde_aprovada *
                 co_ordens_utl.ultimo_preco(i.empresa, i.produto)) valor_prev,
             s.dt_req
        from co_requis s, co_itens_req i
       where s.status = 'E'
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_req = s.num_req
       group by s.empresa, s.filial, s.num_req, i.tipo_compra, s.dt_req;
  
    cursor currom is
      select x.empresa, x.filial, x.seq_rom, x.firma
        from ft_roman x
       where x.status = 'E';
  
    cursor curaprova(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_req c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    --| Cotacoes
    cursor curcot is
      select s.empresa,
             s.filial,
             s.num_cot,
             s.dt_cot,
             sum((c.qtde_neg * c.preco) +
                 (c.qtde_neg * c.preco * nvl(c.aliq_ipi, 0) / 100)) valor_cotado
        from co_cotacao s, co_itens i, co_itens_cot c
       where s.status in ('E', 'P')
         and i.empresa = s.empresa
         and i.filial = s.filial
         and i.num_cot = s.num_cot
         and c.empresa = i.empresa
         and c.filial = i.filial
         and c.num_req = i.num_cot
         and c.item_req = i.item_cot
         and c.escolha = 1
         and s.aprovador is null
         and c.ordem is null
         and exists (select 1
                from cd_firmas f, co_tipos_cot a
               where a.firma = f.firma
                 and a.tipo_compra = i.tipo_compra
                 and f.usuario = user)
       group by s.empresa, s.filial, s.num_cot, s.dt_cot;
  
    cursor curaprova2(pc_tipo co_requis.tipo_compra%type) is
      select f.usuario
        from co_tipos_cot c, cd_firmas f
       where c.tipo_compra = pc_tipo
         and f.firma = c.firma
         and f.usuario is not null;
  
    cursor curreq is
      select s.empresa, s.filial, s.num_req, s.produto, c.requisitante
        from ce_itens_req s, ce_requis c, cd_firmas f
       where c.empresa = s.empresa
         and c.filial = s.filial
         and c.num_req = s.num_req
         and c.requisitante = f.usuario
         and s.situacao = '1';
  
    cursor curpag is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 271;
  
    cursor currm is
      select p.empresa,
             p.filial,
             p.num_nota,
             p.sr_nota,
             p.cod_fornec,
             p.parte
        from ce_notas p
       where p.situacao_nf = '2'
         and p.rotina_origem = 204;
  
    --/ SOLICITAC?ES PENDENTES DE COTAC?O
    cursor cursol_comp is
      select zz.*, necessidade - leadtime pto_compra
        from (select distinct s.empresa,
                              s.filial,
                              s.num_req,
                              i.tipo_compra,
                              i.produto,
                              p.descricao,
                              i.dt_entrega necessidade,
                              case
                                when nvl(p.leadtime, 0) = 0 then
                                 co_util.prazo_interno(i.empresa, i.filial)
                                else
                                 p.leadtime
                              end leadtime
                from co_requis s, co_itens_req i, ce_produtos p
               where s.status = 'A'
                 and i.empresa = s.empresa
                 and i.filial = s.filial
                 and i.num_req = s.num_req
                 and p.empresa = i.empresa
                 and p.produto = i.produto
                 and i.num_cot is null
                 and i.dt_entrega is not null) zz
       order by num_req, 9, produto;
  
    cursor craf is
      select empresa, filial, ordem, fornecedor, comprador, dt_ordem
        from co_ordens a
       where (user = 'GESTAO' or a.comprador = user or
             (user in (select usuario
                          from cd_firmas b, cd_cargos c
                         where b.usuario = user
                           and b.cargo = c.cargo
                           and c.compra = 'S')))
         and a.email_forn is null
       order by dt_ordem;
    --and a.dt_ordem >= '26/02/2008';
  
    v_cargo  ft_cod_aprov.cargo%type;
    v_nivel  ft_cod_aprov.nivel%type;
    v_motivo t_aprova.motivo%type;
    v_nome   cd_firmas.nome%type;
    v_ret    boolean;
    v_libera char(1);
    v_msg    varchar2(1000);
    v_alcada varchar2(1) := 'N';
    vl_prev  number(15, 2);
  begin
  
    -- Deletar temporaria
    delete t_aprova;
  
    -- Solicitacao de Compra (S)
    for regsol in cursol loop
    
      -- Tipo de Compra
      select descricao
        into v_nome
        from co_tipos_compra
       where tipo_compra = regsol.tipo_compra;
    
      -- Pessoas conforme tipo de compra
      for regaprova in curaprova(regsol.tipo_compra) loop
        v_alcada := 'N';
        -- Tabela Temporaria
        insert into t_aprova
        values
          ('S',
           regaprova.usuario,
           to_char(regsol.num_req),
           regsol.empresa,
           'SOLICITACAO COMPRA',
           regsol.filial,
           v_nome,
           regsol.num_req,
           null,
           null,
           null,
           v_alcada,
           regsol.valor_prev,
           regsol.dt_req);
      
      end loop;
    
    end loop;
    --|-------------------------------------------------------------
    --| Cotacao de Compra (C)
    --|-------------------------------------------------------------      
    for regcot in curcot loop
      -- Tabela Temporaria
      v_alcada := 'S';
      insert into t_aprova
      values
        ('C',
         user,
         to_char(regcot.num_cot),
         regcot.empresa,
         'COTACAO',
         regcot.filial,
         v_nome,
         regcot.num_cot,
         null,
         null,
         null,
         v_alcada,
         regcot.valor_cotado,
         regcot.dt_cot);
    end loop;
  end;
  --|------------------------------------------------------------
  --|retorna data de folloew-up ou data original
  --|------------------------------------------------------------
  function fnc_dt_prev_aprov(p_num   cd_follow_aprova.num_acesso%type,
                             p_orig  cd_follow_aprova.origem%type,
                             p_docto cd_follow_aprova.docto%type,
                             p_dt    date) return date is
    cursor cr is
      select dt_prev
        from cd_follow_aprova a
       where a.docto like p_docto || '%'
         and a.num_acesso = p_num
         and ((a.origem in ('PROP', 'OR', 'SOR') and
             p_orig in ('PROP', 'OR', 'SOR')) or (a.origem = p_orig))
       order by id desc;
  
    v_ret date;
  begin
    open cr;
    fetch cr
      into v_ret;
    close cr;
  
    if v_ret is null then
      v_ret := p_dt;
    end if;
  
    if v_ret is null then
      v_ret := trunc(sysdate);
    end if;
  
    return v_ret;
  
  end;
  --|------------------------------------------------------------
  --| GERAR OP's NOVAS 
  --|------------------------------------------------------------
  procedure gerar_op_nova IS
    cursor cr is
      SELECT ab.*
        FROM VOP_ABERTA AB
       WHERE NOT EXISTS (SELECT 1
                FROM PP_OPOS_STATUS ST
               WHERE ST.USUARIO = USER
                 AND ST.EMPRESA = AB.EMPRESA
                 AND ST.FILIAL = AB.filial
                 AND ST.OPOS = AB.opos
              --AND ST.STATUS = 'V'
              ); -- (N)ova | (V)isto | (A)berta (E)ncerrada
  begin
  
    for reg in cr loop
      /*
      IF USER = 'RROCHA' THEN
        insert into TEMP_OPOS_PENDENTE(EMPRESA,
                                  FILIAL,
                                  OPOS,
                                  STATUS,
                                  CONTRATO,
                                  ORCAMENTO,
                                  CLIENTE,
                                  DESCR,
                                  VL_OPOS,
                                  PREV_ENTREGA,
                                  Dt_Contrato)
                           values(reg.EMPRESA,
                                  reg.FILIAL,
                                  reg.OPOS,
                                  'N', --STATUS,
                                  reg.CONTRATO,
                                  reg.proposta,
                                  reg.cliente,
                                  reg.descricao,
                                  reg.vl_opos,
                                  reg.prev_entrega,
                                  reg.dt_contrato);
      END IF; 
      */
      insert into T_OPOS_PENDENTE
        (EMPRESA,
         FILIAL,
         OPOS,
         STATUS,
         CONTRATO,
         ORCAMENTO,
         CLIENTE,
         DESCR,
         VL_OPOS,
         PREV_ENTREGA,
         Dt_Contrato)
      values
        (reg.EMPRESA,
         reg.FILIAL,
         reg.OPOS,
         'N', --STATUS,
         reg.CONTRATO,
         reg.proposta,
         reg.cliente,
         reg.descricao,
         reg.vl_opos,
         reg.prev_entrega,
         reg.dt_contrato);
    end loop;
    commit;
  end;
  --|------------------------------------------------------------
  --| GERAR OP's Abertas pendentes de Encerramento 
  --|------------------------------------------------------------
  procedure gerar_op_aberta IS
    cursor cr is
      SELECT ab.*
        FROM VOP_ABERTA AB
       WHERE NOT EXISTS (SELECT 1
                FROM PP_OPOS_STATUS ST
               WHERE ST.USUARIO = USER
                 AND ST.EMPRESA = AB.EMPRESA
                 AND ST.FILIAL = AB.filial
                 AND ST.OPOS = AB.opos
                 AND ST.STATUS in ('V', 'VA', 'E')) -- (N)ova | (V)isto | (A)berta (E)ncerrada
         and not exists (select 1
                from T_OPOS_PENDENTE top
               where top.empresa = ab.empresa
                 and top.filial = ab.filial
                 and top.opos = ab.opos);
  begin
  
    for reg in cr loop
      insert into T_OPOS_PENDENTE
        (EMPRESA,
         FILIAL,
         OPOS,
         STATUS,
         CONTRATO,
         ORCAMENTO,
         CLIENTE,
         DESCR,
         VL_OPOS,
         PREV_ENTREGA,
         Dt_Contrato)
      values
        (reg.EMPRESA,
         reg.FILIAL,
         reg.OPOS,
         'A', --STATUS,
         reg.CONTRATO,
         reg.proposta,
         reg.cliente,
         reg.descricao,
         reg.vl_opos,
         reg.prev_entrega,
         reg.dt_contrato);
    end loop;
    commit;
  end;
  --|------------------------------------------------------------
  --|retorna qtd de followup
  --|------------------------------------------------------------
  function fnc_conta_follow(p_num   cd_follow_aprova.num_acesso%type,
                            p_orig  cd_follow_aprova.origem%type,
                            p_docto cd_follow_aprova.docto%type)
    return number is
    cursor cr is
      select count(a.id) conta
        from cd_follow_aprova a
       where a.docto like p_docto || '%'
         and a.num_acesso = p_num
         and ((a.origem in ('PROP', 'OR', 'SOR') and
             p_orig in ('PROP', 'OR', 'SOR')) or (a.origem = p_orig))
       order by id desc;
  
    v_ret number;
  begin
    open cr;
    fetch cr
      into v_ret;
    close cr;
  
    return nvl(v_ret, 0);
  
  end;

  --|-------------------------------------------------------------------
  --| FOLLOW-UP  DE SUPRIMENTOS   
  --|-------------------------------------------------------------------
  procedure limpar_follow_supr is
    pragma autonomous_transaction;
  begin
    delete from t_pend_flw_supr;
    commit;
  end;
  --|--------------------------------------------------------------------
  procedure gerar_follow_supr(p_emp cd_filiais.empresa%type,
                              p_fil cd_filiais.filial%type) is
    cursor cr is
      select o.ordem,
             o.dt_ordem,
             o.fornecedor,
             cd_firmas_utl.nome(o.fornecedor) nome,
             co_ordens_utl.vl_total_af(o.empresa, o.filial, o.ordem) vl_original_af,
             sum(co_ordens_utl.saldo_ordem(o.empresa,
                                           o.filial,
                                           o.ordem,
                                           io.item_req) * preco) vl_saldo_af
             
            ,
             min(co_ordens_utl.fnc_entrega(o.empresa,
                                           o.filial,
                                           o.ordem,
                                           io.item_req)) prev_entrega,
             min(nvl(io.prazo_entrega, 0) + o.dt_ordem) prev_entrega_orig,
             min(co_ordens_utl.fnc_dt_followup(io.empresa,
                                               io.filial,
                                               io.ordem,
                                               io.item_req)) dt_follow
        from co_itens_ord io, co_ordens o
       where io.empresa = o.empresa
         and io.filial = o.filial
         and io.ordem = o.ordem
         and o.status != 'X'
         and o.tipo = 'N'
         and o.empresa = p_emp
         and o.filial = p_fil
         and io.qtd - nvl(io.qtd_can, 0) > 0
         and exists
       (select 1
                from cd_aprova_usu usu
               where usu.usuario = user
                 and usu.tipo = 'FLW')
            
         and co_ordens_utl.fnc_dt_followup(io.empresa,
                                           io.filial,
                                           io.ordem,
                                           io.item_req) <= trunc(sysdate)
         and co_ordens_utl.saldo_ordem(o.empresa,
                                       o.filial,
                                       o.ordem,
                                       io.item_req) > 0
      
       group by o.empresa, o.filial, o.ordem, o.dt_ordem, o.fornecedor;
  
    cursor crp(p_af co_ordens.ordem%type) is
      select io.item,
             io.item_req,
             io.produto,
             ce_produtos_utl.descricao(io.empresa, io.produto) descr,
             io.qtd,
             co_ordens_utl.saldo_ordem(o.empresa,
                                       o.filial,
                                       o.ordem,
                                       io.item_req) saldo,
             co_ordens_utl.fnc_entrega(o.empresa,
                                       o.filial,
                                       o.ordem,
                                       io.item_req) prev_entrega,
             (nvl(io.prazo_entrega, 0) + o.dt_ordem) prev_entrega_orig,
             (co_ordens_utl.fnc_dt_followup(io.empresa,
                                            io.filial,
                                            io.ordem,
                                            io.item_req)) dt_follow
        from co_itens_ord io, co_ordens o
       where io.empresa = o.empresa
         and io.filial = o.filial
         and io.ordem = o.ordem
         and o.ordem = p_af
         and o.empresa = p_emp
         and o.filial = p_fil
         and io.qtd - nvl(io.qtd_can, 0) > 0
         and co_ordens_utl.fnc_dt_followup(io.empresa,
                                           io.filial,
                                           io.ordem,
                                           io.item_req) <= trunc(sysdate)
            
         and co_ordens_utl.saldo_ordem(o.empresa,
                                       o.filial,
                                       o.ordem,
                                       io.item_req) > 0
       order by io.item;
  
    v_rotina number(9);
    v_obs    varchar2(4000);
    v_sep    varchar2(10);
  
  begin
    v_rotina := lib_admin.rotina('CO_0204');
    limpar_follow_supr;
  
    for reg in cr loop
      begin
        v_obs := null;
        v_sep := null;
        for regp in crp(reg.ordem) loop
          v_obs := v_obs || v_sep || regp.item || ' | ' || regp.produto ||
                   ' | ' || regp.descr || chr(10) || 'Qtd Orig.: ' ||
                   regp.qtd || ' | ' || 'Sld.: ' || regp.saldo || chr(10) ||
                   'Prev. Entrega: ' ||
                   to_char(regp.prev_entrega, 'dd/mm/rrrr') || chr(10) ||
                   'Data Follow-up: ' ||
                   to_char(regp.dt_follow, 'dd/mm/rrrr');
          v_sep := chr(10);
        end loop;
      exception
        when others then
          null;
      end;
    
      insert into t_pend_flw_supr
        (aprovador,
         docto,
         cod_forn,
         fornecedor,
         dt_docto,
         dt_prev,
         vl_orig,
         vl_prev,
         rotina,
         obs,
         dt_follow)
      values
        (user,
         reg.ordem,
         reg.fornecedor,
         reg.nome,
         reg.dt_ordem,
         reg.prev_entrega,
         reg.vl_original_af,
         reg.vl_saldo_af,
         v_rotina,
         v_obs,
         reg.dt_follow);
    
    end loop;
    commit;
  end;
  --|------------------------------------------------------------
  --|GERAR PENDENCIAS DE PRE-RECPCAO COM VENCIMENTOS VENCIDOS 
  --| OU A VENCER DENTRO DE 5 DIAS QUE NÃO ESTÁ EFETIVADO
  --|------------------------------------------------------------
  procedure gerar_prerec_fin is
    cursor cr is
      select * from v_pend_prerec_fin V ORDER BY V.dt_vencto;
    v_rotina number(9);
  
  begin
    delete t_pend_prerec_fin;
  
    for reg in cr loop
      if reg.cod_oper in (888, 999) and reg.situacao_nf = 4 then
        v_rotina := lib_admin.rotina('CO_0205R');
      else
        v_rotina := lib_admin.rotina('CO_0205');
      end if;
    
      insert into t_pend_prerec_fin
        (num_nota,
         id,
         cod_fornec,
         nome,
         dt_emissao,
         dt_entrada,
         situacao_nf,
         descr_sit,
         dt_vencto,
         parcela,
         vlr_parcela,
         dias,
         rotina,
         cod_oper,
         chave_nfe,
         sr_nota,
         parte)
      values
        (reg.num_nota,
         reg.id,
         reg.cod_fornec,
         reg.nome,
         reg.dt_emissao,
         reg.dt_entrada,
         reg.situacao_nf,
         reg.descr_sit,
         reg.dt_vencto,
         reg.parcela,
         reg.vlr_parcela,
         reg.dias,
         v_rotina,
         reg.cod_oper,
         reg.chave_nfe,
         reg.sr_nota,
         reg.parte);
      commit;
    end loop;
  end;
  --|------------------------------------------------------------
  --| GERAR PENDENCIAS DE ADIANTAMENTOS 
  --| QUE NÃO FORAM EFETIVADOS.
  --|------------------------------------------------------------
  procedure gerar_adiant_af is
    cursor cr is
      select n.id,
             n.num_nota,
             n.sr_nota,
             n.cod_fornec,
             cd_firmas_utl.nome(n.cod_fornec) razao_social,
             n.vlr_nota,
             trunc(n.dt_emissao) dt,
             listagg('Vencto:' || to_char(parc.dt_vencto, 'dd/mm/rr') ||
                     ' - Valor: ' ||
                     ltrim(to_char(parc.vlr_parcela, '999g990d00')),
                     ' || ') within group(order by n.num_nota, n.sr_nota) over(partition by n.id) af
      
        from ce_notas     n,
             fn_tipos_doc d
             -- , ce_oc_nf oc
            ,
             ce_parc_nf parc
       where n.tipo_doc = d.tipo_doc
         and d.adiant = 'S'
         and n.situacao_nf != 1
         and not exists
       (select 1 from ce_itens_nf it where it.id_ce_nota = n.id)
         and n.dt_emissao >= '01/01/2018'
         and parc.id_ce_nota = n.id
       order by n.num_nota, n.sr_nota, parc.dt_vencto;
  
    v_rotina number(9);
  
  begin
  
    v_rotina := lib_admin.rotina('CP_0105');
  
    delete T_PEND_ADIANT_AF;
  
    for reg in cr loop
      insert into T_PEND_ADIANT_AF
        (aprovador,
         docto,
         cod_forn,
         fornecedor,
         dt_docto,
         valor,
         rotina,
         obs,
         id_docto)
      values
        (user,
         reg.num_nota,
         reg.cod_fornec,
         reg.razao_social,
         reg.dt,
         reg.vlr_nota,
         v_rotina,
         reg.af,
         reg.id);
    end loop;
    commit;    
  end;
  --|------------------------------------------------------------
  --| GERAR PENDENCIAS DE APROVAÇÕES ADMINISTRATIVAS 
  --| VIAGEM/VEICULOS
  --|------------------------------------------------------------
  procedure gerar_aprova_adm is
    cursor cr is
      SELECT 0 ORIGEM,
             V.ID,
             V.DT_VISITA DT_REQ,
             V.MOT_VISITA,
             V.LOCAL_VISITA,
             V.DESCR_VEIC,
             V.REQUISITANTE,
             TO_NUMBER(NULL) VALOR,
             STATUS_DESCR
        FROM VCD_REQ_VEICULOS_PEND V
       where cd_aprova_utl.fnc_tem_acesso_n('AD_0212', null) = 1
      UNION ALL
      SELECT 1              ORIGEM,
             V.ID,
             V.dt_req       DT_REQ,
             V.MOT_VISITA,
             V.LOCAL_VISITA,
             V.DESCR_VEIC,
             V.REQUISITANTE,
             VALOR,
             STATUS         STATUS_DESCR
        FROM VCD_DESP_VIAGEM_PEND V
       where cd_aprova_utl.fnc_tem_acesso_n('AD_0211', null) = 1
      UNION ALL
      SELECT 1              ORIGEM,
             V.ID,
             V.dt_req       DT_REQ,
             V.MOT_VISITA,
             V.LOCAL_VISITA,
             V.DESCR_VEIC,
             V.REQUISITANTE,
             VALOR,
             STATUS         STATUS_DESCR
        FROM vcd_desp_viagem_pend_encer V
       where cd_aprova_utl.fnc_tem_acesso_n('AD_0211E', null) = 1
       order by 3;
  
    v_rotina number(9);
    v_motivo t_aprova_adm.motivo%type;
    v_sep    varchar2(10);
  begin
    DELETE FROM t_aprova_adm;
    COMMIT;
    for reg in cr loop
    
      v_motivo := null;
      v_sep    := null;
      v_motivo := 'STATUS: ' || REG.STATUS_DESCR;
      v_sep    := chr(10);
      if reg.local_visita is not null then
        v_motivo := v_motivo || v_sep || 'Local: ' || reg.local_visita;
        v_sep    := chr(10);
      end if;
      if reg.descr_veic is not null then
        v_motivo := v_motivo || v_sep || 'Veículo: ' || reg.descr_veic;
        v_sep    := chr(10);
      end if;
    
      if reg.mot_visita is not null then
        v_motivo := v_motivo || v_sep || 'Motivo: ' || reg.mot_visita;
      end if;
    
      insert into t_aprova_adm
        (origem,
         aprovador,
         docto,
         motivo,
         num_acesso,
         vl_prev,
         dt_docto,
         REQUISITANTE)
      values
        (REG.ORIGEM,
         USER,
         reg.id, --docto,
         v_motivo,
         reg.id, --num_acesso,
         REG.VALOR, --vl_prev,
         reg.dt_req,
         REG.REQUISITANTE);
    end loop;
    commit;
  end;

  --|------------------------------------------------------------
  --|retorna qtd de followup DE SUPR
  --|------------------------------------------------------------
  function fnc_conta_follow_supr(p_emp   number,
                                 p_fil   number,
                                 p_docto cd_follow_aprova.docto%type)
    return number is
    cursor cr is
      select count(a.seq_itemfol) conta
        from co_itens_follow a
       where a.ordem = p_docto
         and a.empresa = p_emp
         and a.filial = p_fil;
  
    v_ret number;
  begin
    open cr;
    fetch cr
      into v_ret;
    close cr;
  
    return nvl(v_ret, 0);
  
  end;
  --|------------------------------------------------------------
  --|retorna SE TEM ACESSO AO PROCESSO
  --|------------------------------------------------------------
  function fnc_tem_acesso(p_tipo cd_aprova_usu.tipo%type,
                          p_acao cd_aprova_usu.acao%type) return boolean is
    cursor cr is
      select 1
        from cd_aprova_usu a
       where a.usuario = user
         and (P_ACAO IS NULL OR a.acao = UPPER(p_acao))
         and a.tipo = UPPER(p_tipo);
  
    v_achou number(1);
  
  begin
    /*
    if user = 'GESTAO' then
        return true;
    end if;
    */
  
    open cr;
    fetch cr
      into v_achou;
    close cr;
  
    if nvl(v_achou, 0) = 1 then
      return true;
    else
      return false;
    end if;
  
  end;
  --|------------------------------------------------------------
  function fnc_tem_acesso_n(p_tipo cd_aprova_usu.tipo%type,
                            p_acao cd_aprova_usu.acao%type) return number is
    cursor cr is
      select 1
        from cd_aprova_usu a
       where a.usuario = user
         and (P_ACAO IS NULL OR a.acao = UPPER(p_acao))
         and a.tipo = p_tipo;
  
    v_achou number(1) := 0;
  
  begin
    /*
    if user = 'GESTAO' then
        return true;
    end if;
    */
  
    open cr;
    fetch cr
      into v_achou;
    close cr;
    return v_achou;
  
  end;

  function produto_evento_comercial(p_org t_aprova_comercial.origem%type,
                                    p_num t_aprova_comercial.num_acesso%type)
    return varchar2 is
    --/
    cursor crsor(p_id number) is
      select pr.descr_prod ||
             decode(pr.complemento, null, null, '-' || pr.complemento) descr
        from oc_solic_orcam m, oc_solic_orc_prod pr
       where m.id_solicorcam = p_id
         and pr.id_solicorcam = m.id_solicorcam;
  
    --/
    cursor cror(p_id number) is
      select pr.descr_prod descr
        from oc_orcam_venda ve, oc_orcam_prod pr
       where pr.id_orcamvenda = ve.id_orcamvenda
         and ve.id_orcamvenda = p_id;
  
    --/
    cursor crprop(p_id number) is
      select pr.descr_compl descr
        from oc_proposta ve, oc_prop_item pr
       where pr.seq_ocprop = ve.seq_ocprop
         and ve.seq_ocprop = p_id;
  
    v_ret varchar2(4000);
    v_id  number(9);
    v_sep varchar2(10);
    v_num number(9);
  begin
    v_id := p_num;
  
    if p_org = 'SOR' then
    
      for regsor in crsor(v_id) loop
      
        v_num := nvl(v_num, 0) + 1;
      
        v_ret := v_ret || v_sep || lpad(v_num, 3, '0') || ' - ' ||
                 regsor.descr;
        v_sep := chr(10);
      end loop;
    
    elsif p_org = 'OR' then
    
      for regor in cror(v_id) loop
      
        v_num := nvl(v_num, 0) + 1;
      
        v_ret := v_ret || v_sep || lpad(v_num, 3, '0') || ' - ' ||
                 regor.descr;
      
        v_sep := chr(10);
      end loop;
    
    elsif p_org = 'PROP' then
    
      for regprop in crprop(v_id) loop
      
        v_num := nvl(v_num, 0) + 1;
      
        v_ret := v_ret || v_sep || lpad(v_num, 3, '0') || ' - ' ||
                 regprop.descr;
      
        v_sep := chr(10);
      end loop;
    end if;
  
    return v_ret;
  
  end;
end cd_aprova_utl;
/
