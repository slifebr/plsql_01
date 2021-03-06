CREATE OR REPLACE Package oc_preco_utl is
  --|------------------------------------------------------------------------
  --| variaveis GLOBAIS PUBLICAS
  --|------------------------------------------------------------------------
  vgp_id_origem number;
  vgp_origem    varchar2(10);
  vgp_margem    number(15, 2);

  vgp_aux                    number(15, 2);
  vgp_preco_venda_liquido    number(15, 2);
  vgp_preco_venda_bruto      number(15, 2);
  vgp_preco_venda_bruto_simp number(15, 2);
  vgp_preco_kg               number(15, 2);

  vgp_custo_industrial        number(15, 2); -- CUSTO INDUSTRIAL
  vgp_royalties               number(15, 2); -- ROYALTIES
  vgp_despesas_comerciais     number(15, 2); -- DESPESAS COMERCIAIS
  vgp_contingencia_fabricacao number(15, 2); -- CONTIGNECIAS DE FABRICA�AO
  vgp_despesa_financeira      number(15, 2); -- DESPESAS DE FINANCEIRAS(IMPOSTOS)
  vgp_despesa_administrativa  number(15, 2); -- DESPESAS ADMINISTRATIVAS
  vgp_despesa_prazo           number(15, 2); -- DESPESAS DE PRAZO

  --

  vgt_preco    gs_preco_venda_prod%rowtype;
  vgpreg_param gs_param%rowtype;

  vgp_fator_bruto number;
  vgp_ipi_icms    number;
  vgp_custo_total number;
  vgp_vlor_ipi    number;

  vgp_fator_margem   number;
  vgp_fator_custos   number;
  vgp_fator_tributos number;

  --|------------------------------------------------------------------------
  --| Funcao: por margem - retorna o preco bruto
  --|------------------------------------------------------------------------
  function fnc_por_margem(p_margem         gs_preco_venda_prod.margem%type,
                          p_emp            cd_filiais.empresa%type,
                          p_fil            cd_filiais.filial%type,
                          p_v_custo_total  gs_preco_venda_prod.custo%type,
                          p_qtd            gs_preco_venda_prod.qtd%type,
                          p_per_royal      gs_preco_venda_prod.per_royal%type,
                          p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                          p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                          p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                          p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                          p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                          p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                          p_per_inss       gs_preco_venda_prod.per_inss%type,
                          p_per_iss        gs_preco_venda_prod.per_iss%type,
                          p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                          p_per_icms       gs_preco_venda_prod.per_icms%type,
                          p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                          p_per_csll       gs_preco_venda_prod.per_csll%type,
                          p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                          p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: POR PRECO LIQUIDO 
  --|------------------------------------------------------------------------
  function fnc_por_preco_liquido(p_preco_liquido  gs_preco_venda_prod.valor_produto_liq%type,
                                 p_emp            cd_filiais.empresa%type,
                                 p_fil            cd_filiais.filial%type,
                                 p_v_custo_total  gs_preco_venda_prod.custo%type,
                                 p_qtd            gs_preco_venda_prod.qtd%type,
                                 p_per_royal      gs_preco_venda_prod.per_royal%type,
                                 p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                                 p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                                 p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                                 p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                                 p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                                 p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                                 p_per_inss       gs_preco_venda_prod.per_inss%type,
                                 p_per_iss        gs_preco_venda_prod.per_iss%type,
                                 p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                                 p_per_icms       gs_preco_venda_prod.per_icms%type,
                                 p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                                 p_per_csll       gs_preco_venda_prod.per_csll%type,
                                 p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                                 p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: POR PRECO BRUTO
  --|------------------------------------------------------------------------
  function fnc_por_preco_bruto(p_preco_bruto    gs_preco_venda_prod.valor_produto_br%type,
                               p_emp            cd_filiais.empresa%type,
                               p_fil            cd_filiais.filial%type,
                               p_v_custo_total  gs_preco_venda_prod.custo%type,
                               p_qtd            gs_preco_venda_prod.qtd%type,
                               p_per_royal      gs_preco_venda_prod.per_royal%type,
                               p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                               p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                               p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                               p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                               p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                               p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                               p_per_inss       gs_preco_venda_prod.per_inss%type,
                               p_per_iss        gs_preco_venda_prod.per_iss%type,
                               p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                               p_per_icms       gs_preco_venda_prod.per_icms%type,
                               p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                               p_per_csll       gs_preco_venda_prod.per_csll%type,
                               p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                               p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: POR PESO  
  --|------------------------------------------------------------------------
  function fnc_por_peso(p_peso_liq       gs_preco_venda_prod.peso_liq%type,
                        p_valor_kg       number,
                        p_emp            cd_filiais.empresa%type,
                        p_fil            cd_filiais.filial%type,
                        p_v_custo_total  gs_preco_venda_prod.custo%type,
                        p_qtd            gs_preco_venda_prod.qtd%type,
                        p_per_royal      gs_preco_venda_prod.per_royal%type,
                        p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                        p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                        p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                        p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                        p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                        p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                        p_per_inss       gs_preco_venda_prod.per_inss%type,
                        p_per_iss        gs_preco_venda_prod.per_iss%type,
                        p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                        p_per_icms       gs_preco_venda_prod.per_icms%type,
                        p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                        p_per_csll       gs_preco_venda_prod.per_csll%type,
                        p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                        p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: preco tendo origem o orcamento
  --|------------------------------------------------------------------------
  function fnc_preco_orcto(p_emp          cd_filiais.empresa%type,
                           p_fil          cd_filiais.filial%type,
                           p_id_orcamprod oc_orcam_prod.id_orcamprod%type,
                           p_formula      char) return number;
  --|------------------------------------------------------------------------
  --| Funcao: preco tendo origem a proposta
  --|------------------------------------------------------------------------
  function fnc_preco_proposta(p_emp         cd_filiais.empresa%type,
                              p_fil         cd_filiais.filial%type,
                              p_seq_ocproit oc_prop_item.seq_ocproit%type,
                              p_formula     char,
                              p_preco_kg    number) return number;

  --|------------------------------------------------------------------------
  --| Funcao: preco margem zero tendo origem a proposta 
  --|------------------------------------------------------------------------
  function fnc_preco_proposta_margem_zero(p_emp         cd_filiais.empresa%type,
                                          p_fil         cd_filiais.filial%type,
                                          p_seq_ocproit oc_prop_item.seq_ocproit%type,
                                          p_seq         oc_proposta.seq_ocprop%type,
                                          p_formula     char,
                                          p_preco_kg    number) return number;
  --|------------------------------------------------------------------------
  --| Funcao: recupera preco bruto sem ipi
  --|------------------------------------------------------------------------
  function get_preco_bruto_simp_orcto(p_emp          cd_filiais.empresa%type,
                                      p_fil          cd_filiais.filial%type,
                                      p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: recupera preco bruto
  --|------------------------------------------------------------------------
  function get_preco_bruto_orcto(p_emp          cd_filiais.empresa%type,
                                 p_fil          cd_filiais.filial%type,
                                 p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: recupera preco liquido
  --|------------------------------------------------------------------------
  function get_preco_liquido_orcto(p_emp          cd_filiais.empresa%type,
                                   p_fil          cd_filiais.filial%type,
                                   p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: recupera preco margem
  --|------------------------------------------------------------------------
  function get_margem_orcto(p_emp          cd_filiais.empresa%type,
                            p_fil          cd_filiais.filial%type,
                            p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: recupera custo industrial
  --|------------------------------------------------------------------------   
  function get_custo_industrial(p_emp          cd_filiais.empresa%type,
                                p_fil          cd_filiais.filial%type,
                                p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;
  --|------------------------------------------------------------------------
  --| Funcao: recupera custo industrial
  --|------------------------------------------------------------------------   
  function get_preco_kg_orcto(p_emp          cd_filiais.empresa%type,
                              p_fil          cd_filiais.filial%type,
                              p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula contigencia de fabricacao
  --|------------------------------------------------------------------------   
  function get_contingencia_fabr_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa adm
  --|------------------------------------------------------------------------   
  function get_desp_adm_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa financeira
  --|------------------------------------------------------------------------   
  function get_desp_fin_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa comercial(comiss�o)
  --|------------------------------------------------------------------------   
  function get_desp_com_orcto(p_emp          cd_filiais.empresa%type,
                              p_fil          cd_filiais.filial%type,
                              p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula royalties
  --|------------------------------------------------------------------------   
  function get_royalties_orcto(p_emp          cd_filiais.empresa%type,
                               p_fil          cd_filiais.filial%type,
                               p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------
  --| Funcao: calcula pis/cofins
  --|------------------------------------------------------------------------   
  function get_piscof_orcto(p_emp          cd_filiais.empresa%type,
                            p_fil          cd_filiais.filial%type,
                            p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number;

  --|------------------------------------------------------------------------   
  --/
  --|------------------------------------------------------------------------   
  procedure gerar_revisao_preco(p_emp gs_preco_venda.empresa%type,
                                p_id  gs_preco_venda.nr_pc_seq%type);

end oc_preco_utl;
/
CREATE OR REPLACE Package Body oc_preco_utl Is

  --||
  --|| oc_forma_preco_utl.PKb : Calcula precos e impostos
  --||

  --|------------------------------------------------------------------------
  --| variaveis globais
  --|------------------------------------------------------------------------

  vg_ipi    number;
  vg_cpmf   number;
  vg_icms   number;
  vg_piscof number;
  vg_iss    number;
  vg_inss   number;
  vg_csll   number;
  vg_ir     number;

  vg_vl_royal   number;
  vg_vl_cpmf    number;
  vg_vl_fabric  number;
  regime_tribut varchar2(1);
  ---------------------------------------------------------------------------
  --/ Procedimentos e funcoes locais
  ---------------------------------------------------------------------------
  function get_preco_venda_prod(p_id_orcamprod number)
    return gs_preco_venda_prod%rowtype is
    cursor cr is
      select pvp.*
        from gs_preco_venda_prod pvp
       where pvp.id_orcamprod = p_id_orcamprod
         and pvp.rev = (select max(pvp2.rev)
                        from gs_preco_venda_prod pvp2
                        where pvp2.id_orcamprod = pvp.id_orcamprod
                        );
  
    vt_preco gs_preco_venda_prod%rowtype;
  begin
    vgt_preco := null;
    open cr;
    fetch cr
      into vt_preco;
    close cr;
  
    return vt_preco;
  end;

  ---------------------------------------------------------------------------
  --/ Procedimentos e funcoes locais
  ---------------------------------------------------------------------------

  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------         
  --|------------------------------------------------------------------------
  --|                        Funcoes: calculo de pre�o para orcto
  --|------------------------------------------------------------------------      
  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------  

  --|------------------------------------------------------------------------
  --| Funcao: POR MARGEM - retorna preco venda bruto
  --|------------------------------------------------------------------------
  function fnc_por_margem(p_margem         gs_preco_venda_prod.margem%type,
                          p_emp            cd_filiais.empresa%type,
                          p_fil            cd_filiais.filial%type,
                          p_v_custo_total  gs_preco_venda_prod.custo%type,
                          p_qtd            gs_preco_venda_prod.qtd%type,
                          p_per_royal      gs_preco_venda_prod.per_royal%type,
                          p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                          p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                          p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                          p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                          p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                          p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                          p_per_inss       gs_preco_venda_prod.per_inss%type,
                          p_per_iss        gs_preco_venda_prod.per_iss%type,
                          p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                          p_per_icms       gs_preco_venda_prod.per_icms%type,
                          p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                          p_per_csll       gs_preco_venda_prod.per_csll%type,
                          p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                          p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number IS
  
    --/
  
    v_ret             number;
    v_lucro           number(15, 2);
    v_sob_margem      number(15, 2);
    v_vl_fator_custos number(15, 2);
    /*
    Formula BDI( Budget Difference Income)
    AC = administra��o central;
    CF = custo financeiro;
    S = seguros;
    G = garantias;
    MI = margem de incerteza;
    TM = tributos municipais;
    TE = tributos estaduais;
    TF = tributos federais;
    MBC = margem bruta de contribui��o.
    
    BDI = ((1+AC+CF+S+G+MI)/(1-(TM+TE+TF+MBC))-1)*100
    Fonte: Livro Novo Conceito de BDI (Eng. Paulo Roberto Vilela Dias)
    */
  BEGIN
    --/-----------------------------------------------------------------------------
    --/variavel mandante para calculo do pre�o
    --/-----------------------------------------------------------------------------
    vgp_margem := nvl(p_margem, 0);
  
    --/-----------------------------------------------------------------------------      
    --/ custo industrial
    --/-----------------------------------------------------------------------------      
    if nvl(p_qtd, 0) = 0 then
      vgp_custo_industrial := p_v_custo_total / 1;
    else
      vgp_custo_industrial := p_v_custo_total / p_qtd;
    end if;
  
    -- variaveis adicionais para custo industrial
    vgp_contingencia_fabricacao := nvl(p_per_fabric, 0); -- / 100;      
    vgp_despesa_financeira      := nvl(p_per_desp_fin, 0); -- / 100;
    vgp_despesa_administrativa  := nvl(p_per_desp_adm, 0); -- / 100;
    --/-----------------------------------------------------------------------------
    --/ define fator Despesas | Contingencias
    --/ % sobre custo (por fora)   
    --/-----------------------------------------------------------------------------
    if vgpreg_param.bid = 'S' then
      vgp_fator_custos := (100 + vgp_contingencia_fabricacao +
                          vgp_despesa_financeira +
                          vgp_despesa_administrativa) / (100);
    else
      vgp_fator_custos := 100 / (100 - vgp_contingencia_fabricacao -
                          vgp_despesa_financeira -
                          vgp_despesa_administrativa);
    end if;
    --calcula custo industrial com taxas adicionais
  
    v_vl_fator_custos    := (vgp_custo_industrial * vgp_fator_custos) -
                            vgp_custo_industrial;
    vgp_custo_industrial := vgp_custo_industrial +
                            nvl(v_vl_fator_custos, 0);
  
    -- variaveis para calculo por dentro( margem sobre venda)
    vgp_despesas_comerciais := nvl(p_per_desp_com, 0); -- / 100;
    vgp_royalties           := nvl(p_per_royal, 0); -- / 100;
    --/-----------------------------------------------------------------------------
    --/ calcula fator margem + despesas comerciais(comissao) + royalties
    --/ % sobre venda (por dentro)   
    --/-----------------------------------------------------------------------------      
    vgp_fator_margem := (100 /
                        (100 - nvl(p_margem, 0) - nvl(vgp_royalties, 0) -
                        nvl(vgp_despesas_comerciais, 0)));
  
    vgp_preco_venda_liquido := vgp_fator_margem * vgp_custo_industrial;
    v_lucro                 := vgp_preco_venda_liquido -
                               vgp_custo_industrial;
  
    --/-----------------------------------------------------------------------------      
    --|CSLL DE RENDA SOBRE MARGEM
    --/-----------------------------------------------------------------------------      
    vg_csll := nvl(p_per_csll, 0);
  
    --/-----------------------------------------------------------------------------      
    --|IMPOSTO DE RENDA SOBRE MARGEM
    --/-----------------------------------------------------------------------------      
    vg_ir                   := nvl(p_per_ir, 0);
    v_sob_margem            := (v_lucro * (100 / (100 - vg_ir - vg_csll))) -
                               v_lucro;
    vgp_preco_venda_liquido := vgp_preco_venda_liquido + v_sob_margem;
    --/---------------------------------------------------------------
    --/tributos sobre preco com margem/ir/csll
    --/---------------------------------------------------------------
    vg_ipi  := nvl(p_per_ipi, 0); -- / 100; 
    vg_inss := nvl(p_per_inss, 0); -- / 100;  
    vg_iss  := nvl(p_per_iss, 0); -- / 100;    
    vg_icms := nvl(p_per_icms, 0); -- / 100;
    vg_cpmf := 0;
  
    if p_ipi_sim_nao = 'S' then
      --formula1
      -- vg_icms := (100/(100-(vg_icms*(1+vg_ipi/100))))-1)*100); --fica mais caro
    
      --formula2
      --B32*B40/100+B32
      vg_icms := nvl(vg_icms, 0) * (1 + vg_ipi / 100);
    end if;
  
    --/-----------------------------------------------------------------------------
    --/  pis cofins - se n�o inclui icms na base de calculo do pis/cofins
    --/----------------------------------------------------------------------------- 
    vg_piscof := nvl(p_per_pis_cofins, 0); -- / 100;        
    if vgpreg_param.ICMS_BPISCOF = 'N' then
      vg_piscof := vg_piscof - (vg_piscof * vg_icms / 100);
    end if;
    --/-----------------------------------------------------------------------------           
    --/ calcula preco bruto ...com impostos sem IPI
    --/ com pis/cofins  e icms normal
    --/-----------------------------------------------------------------------------           
  
    vgp_fator_tributos := 100 / (100 - (nvl(vg_icms, 0)) -- * (1 + vgp_ipi_icms/100))  
                          - nvl(vg_piscof, 0) - nvl(vg_inss, 0));
  
    vgp_preco_venda_bruto_simp := vgp_preco_venda_liquido *
                                  vgp_fator_tributos;
  
    --/ preco por kg 
    IF NVL(vgt_preco.peso_liq, 0) > 0 THEN
      vgp_preco_kg := vgp_preco_venda_bruto_simp / vgt_preco.peso_liq;
    ELSE
      vgp_preco_kg := 0;
    END IF;
    --/--------------------------------------------------------------------
    --/ preco com ipi
    vgp_preco_venda_bruto := (vgp_preco_venda_bruto_simp *
                             (1 + vg_ipi / 100));
    --/--------------------------------------------------------------------
    --/preco liquido sem os tributos/ir/csll
    vgp_preco_venda_liquido := vgp_preco_venda_liquido - v_sob_margem;
  
    V_RET := vgp_preco_venda_bruto;
    return v_ret;
  end;

  --|------------------------------------------------------------------------
  --| Funcao: POR PRECO LIQUIDO - retorna preco venda bruto
  --|------------------------------------------------------------------------
  function fnc_por_preco_bruto(p_preco_bruto    gs_preco_venda_prod.valor_produto_br%type,
                               p_emp            cd_filiais.empresa%type,
                               p_fil            cd_filiais.filial%type,
                               p_v_custo_total  gs_preco_venda_prod.custo%type,
                               p_qtd            gs_preco_venda_prod.qtd%type,
                               p_per_royal      gs_preco_venda_prod.per_royal%type,
                               p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                               p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                               p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                               p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                               p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                               p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                               p_per_inss       gs_preco_venda_prod.per_inss%type,
                               p_per_iss        gs_preco_venda_prod.per_iss%type,
                               p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                               p_per_icms       gs_preco_venda_prod.per_icms%type,
                               p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                               p_per_csll       gs_preco_venda_prod.per_csll%type,
                               p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                               p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number is
  
    v_ret          number(15, 2);
    v_fator_dentro number(15, 4);
    v_csll_aux     number(15, 4);
    v_ir_aux       number(15, 4);
    v_margem_aux   number(15, 4);
    v_soma_aux     number(15, 4);
  
    v_preco_sem_ipi    number(15, 2);
    v_preco_sem_trib   number(15, 2);
    v_preco_com_margem number(15, 2);
  
    v_vl_csll_aux        number(15, 4);
    v_vl_ir_aux          number(15, 4);
    v_lucro_aux          number(15, 2);
    v_sob_margem         number(15, 2);
    v_preco_sem_desp_com number(15, 2);
  begin
    --/-----------------------------------------------------------------------------
    --/variavel mandante para calculo do pre�o
    --/-----------------------------------------------------------------------------
    vgp_preco_venda_bruto := nvl(p_preco_bruto, 0);
  
    --/-----------------------------------------------------------------------------      
    --/ custo industrial
    --/-----------------------------------------------------------------------------      
    if nvl(p_qtd, 0) = 0 then
      vgp_custo_industrial := p_v_custo_total / 1;
    else
      vgp_custo_industrial := p_v_custo_total / p_qtd;
    end if;
    --/-----------------------------------------------------------------------------      
    --/ carrega parametros globais
    --/-----------------------------------------------------------------------------      
    vgp_contingencia_fabricacao := nvl(p_per_fabric, 0); -- / 100;
    vgp_despesa_financeira      := nvl(p_per_desp_fin, 0); -- / 100;
    vgp_despesa_administrativa  := nvl(p_per_desp_adm, 0); -- / 100;
    vg_ipi                      := nvl(p_per_ipi, 0); -- / 100; 
  
    --/-----------------------------------------------------------------------------
    --/ define fator Despesas | Contingencias
    --/ % sobre custo (por fora)   
    --/-----------------------------------------------------------------------------
    if vgpreg_param.bid = 'S' then
      vgp_fator_custos := (100 + vgp_contingencia_fabricacao +
                          vgp_despesa_financeira +
                          vgp_despesa_administrativa) / (100);
    else
      vgp_fator_custos := 100 / (100 - vgp_contingencia_fabricacao -
                          vgp_despesa_financeira -
                          vgp_despesa_administrativa);
    end if;
    --calcula custo industrial com taxas adicionais
    vgp_custo_industrial := vgp_custo_industrial * vgp_fator_custos;
  
    --/-----------------------------------------------------------------------------
    --/preco sem ipi
    --/-----------------------------------------------------------------------------      
    v_preco_sem_ipi            := vgp_preco_venda_bruto /
                                  (nvl(vg_ipi / 100, 0) + 1);
    vgp_preco_venda_bruto_simp := v_preco_sem_ipi;
  
    --/ preco por kg 
    IF vgt_preco.peso_liq > 0 THEN
      vgp_preco_kg := v_preco_sem_ipi / vgt_preco.peso_liq;
    ELSE
      vgp_preco_kg := 0;
    END IF;
    --/-----------------------------------------------------------------------------
    --/preco sem tributos
    --/-----------------------------------------------------------------------------       
    /*
    if p_ipi_sim_nao = 'S' then
       vgp_ipi_icms := vg_ipi;
    else
       vgp_ipi_icms := 0;
    end if;  
    */
    vg_icms := nvl(p_per_icms, 0); -- / 100;      
    if p_ipi_sim_nao = 'S' then
      --formula1
      -- vg_icms := (100/(100-(vg_icms*(1+vg_ipi/100))))-1)*100); --fica mais caro
    
      --formula2
      --B32*B40/100+B32
      vg_icms := nvl(vg_icms, 0) * (1 + vg_ipi / 100);
    end if;
  
    vg_inss := nvl(p_per_inss, 0); -- / 100;  
    vg_iss  := nvl(p_per_iss, 0); -- / 100;    
    vg_cpmf := 0;
  
    --/  pis cofins - se n�o inclui icms na base de calculo do pis/cofins
    vg_piscof := nvl(p_per_pis_cofins, 0); -- / 100;        
    if vgpreg_param.ICMS_BPISCOF = 'N' then
      vg_piscof := vg_piscof - (vg_piscof * vg_icms / 100);
    end if;
  
    --/ com pis/cofins ipi e icms normal dentro do preco
    v_fator_dentro   := (nvl(vg_icms, 0)) + nvl(vg_piscof, 0) +
                        nvl(vg_inss, 0);
    v_preco_sem_trib := v_preco_sem_ipi -
                        nvl((v_preco_sem_ipi * v_fator_dentro / 100), 0);
  
    --/-----------------------------------------------------------------------------
    --/ retira o ir /csll do  lucro
    --/----------------------------------------------------------------------------- 
    v_lucro_aux  := v_preco_sem_trib - vgp_custo_industrial;
    v_sob_margem := (v_lucro_aux * (nvl(p_per_csll, 0) + nvl(p_per_ir, 0)) / 100);
  
    vgp_preco_venda_liquido := v_preco_sem_trib - v_sob_margem;
    --/ retira despesas comerciais e  royalties  
    vgp_royalties           := nvl(p_per_royal, 0); -- / 100;
    vgp_despesas_comerciais := nvl(p_per_desp_com, 0); -- / 100;      
  
    --/ calcula preco sem royalties/despesas comerciais
    if 1 = 2 then
      -- n�o esta sendo usado neste momento
      -- se for descontar despesa para calcular margem
      v_preco_sem_desp_com := round(vgp_preco_venda_liquido -
                                    ((vgp_royalties +
                                    vgp_despesas_comerciais) *
                                    vgp_preco_venda_liquido / 100),
                                    2);
      vgp_margem           := 0;
    else
      v_preco_sem_desp_com := vgp_preco_venda_liquido;
      --| retira da margem as despesas comerciais
      vgp_margem := (vgp_royalties + vgp_despesas_comerciais) * -1;
    end if;
    --/calcula lucro liquido                                                                 
    v_lucro_aux := v_preco_sem_desp_com - vgp_custo_industrial;
  
    --/ calcula margem
    vgp_margem := vgp_margem +
                  round(v_lucro_aux / v_preco_sem_desp_com * 100, 2);
  
    v_ret := vgp_preco_venda_liquido;
  
    return v_ret;
  end;

  --|------------------------------------------------------------------------
  --| Funcao: preco tendo origem o orcamento
  --|------------------------------------------------------------------------
  function fnc_preco_orcto(p_emp          cd_filiais.empresa%type,
                           p_fil          cd_filiais.filial%type,
                           p_id_orcamprod oc_orcam_prod.id_orcamprod%type,
                           p_formula      char) return number is
    cursor crparam is
      select * from gs_param where empresa = p_emp;
  
    cursor crpreco is
      select a.* --a.preco_kg, a.peso_bruto, a.peso_liq  
        from gs_preco_venda_prod a
       where a.id_orcamprod = p_id_orcamprod; --6823
  
    vreg_preco gs_preco_venda_prod%rowtype;
  
    v_ret   number;
    v_preco number;
  
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    vgt_preco := get_preco_venda_prod(p_id_orcamprod);
  
    --/-----------------------------------------------------------------------------      
    --/ carrega parametros globais
    --/-----------------------------------------------------------------------------      
    open crparam;
    fetch crparam
      into vgpreg_param;
    close crparam;
  
    --/-----------------------------------------------------------------------------      
    IF vgt_preco.id_orcamprod is not null then
    
      vgp_id_origem := vgt_preco.id_orcamprod;
      vgp_origem    := 'ORCTO';
    
      if (p_formula is null and vgt_preco.formula_calc = 'M') or
         p_formula = 'M' then
        --/preco por margem
        v_ret := fnc_por_margem(vgt_preco.margem,
                                p_emp,
                                p_fil,
                                vgt_preco.custo * vgt_preco.qtd,
                                vgt_preco.qtd,
                                vgt_preco.per_royal,
                                vgt_preco.per_desp_com,
                                vgt_preco.per_fabric,
                                vgt_preco.per_desp_fin,
                                vgt_preco.per_desp_adm,
                                vgt_preco.ipi,
                                vgt_preco.per_ipi,
                                vgt_preco.per_inss,
                                vgt_preco.per_iss,
                                vgt_preco.per_pis_cofins,
                                vgt_preco.per_icms,
                                vgt_preco.csll_sll,
                                vgt_preco.per_csll,
                                vgt_preco.ir_sll,
                                vgt_preco.per_ir);
      elsif (p_formula is null and vgt_preco.formula_calc = 'L') or
            p_formula = 'L' then
        --/preco por margem
        v_ret := fnc_por_preco_bruto(vgt_preco.valor_produto_liq,
                                     p_emp,
                                     p_fil,
                                     vgt_preco.custo * vgt_preco.qtd,
                                     vgt_preco.qtd,
                                     vgt_preco.per_royal,
                                     vgt_preco.per_desp_com,
                                     vgt_preco.per_fabric,
                                     vgt_preco.per_desp_fin,
                                     vgt_preco.per_desp_adm,
                                     vgt_preco.ipi,
                                     vgt_preco.per_ipi,
                                     vgt_preco.per_inss,
                                     vgt_preco.per_iss,
                                     vgt_preco.per_pis_cofins,
                                     vgt_preco.per_icms,
                                     vgt_preco.csll_sll,
                                     vgt_preco.per_csll,
                                     vgt_preco.ir_sll,
                                     vgt_preco.per_ir);
      elsif (p_formula is null and vgt_preco.formula_calc = 'B') or
            p_formula = 'B' then
        --/preco por margem
        v_ret := fnc_por_preco_bruto(vgt_preco.valor_produto_br,
                                     p_emp,
                                     p_fil,
                                     vgt_preco.custo * vgt_preco.qtd,
                                     vgt_preco.qtd,
                                     vgt_preco.per_royal,
                                     vgt_preco.per_desp_com,
                                     vgt_preco.per_fabric,
                                     vgt_preco.per_desp_fin,
                                     vgt_preco.per_desp_adm,
                                     vgt_preco.ipi,
                                     vgt_preco.per_ipi,
                                     vgt_preco.per_inss,
                                     vgt_preco.per_iss,
                                     vgt_preco.per_pis_cofins,
                                     vgt_preco.per_icms,
                                     vgt_preco.csll_sll,
                                     vgt_preco.per_csll,
                                     vgt_preco.ir_sll,
                                     vgt_preco.per_ir);
      elsif (p_formula is null and vgt_preco.formula_calc = 'K') or
            p_formula = 'K' then
        --/preco por kg
      
        open crpreco;
        fetch crpreco
          into vreg_preco;
        close crpreco;
        if nvl(vreg_preco.peso_liq, 0) = 0 then
          v_preco := vreg_preco.peso * vreg_preco.preco_kg;
        else
          v_preco := vreg_preco.peso_liq * vreg_preco.preco_kg;
        end if;
      
        v_ret := fnc_por_preco_bruto(V_PRECO,
                                     p_emp,
                                     p_fil,
                                     vgt_preco.custo * vgt_preco.qtd,
                                     vgt_preco.qtd,
                                     vgt_preco.per_royal,
                                     vgt_preco.per_desp_com,
                                     vgt_preco.per_fabric,
                                     vgt_preco.per_desp_fin,
                                     vgt_preco.per_desp_adm,
                                     vgt_preco.ipi,
                                     vgt_preco.per_ipi,
                                     vgt_preco.per_inss,
                                     vgt_preco.per_iss,
                                     vgt_preco.per_pis_cofins,
                                     vgt_preco.per_icms,
                                     vgt_preco.csll_sll,
                                     vgt_preco.per_csll,
                                     vgt_preco.ir_sll,
                                     vgt_preco.per_ir);
        /*v_ret := fnc_por_peso( vgt_preco.peso_liq
        , vgt_preco.preco_kg  
        ,p_emp               
        ,p_fil              
        ,vgt_preco.custo * vgt_preco.qtd  
        ,vgt_preco.qtd                            
        ,vgt_preco.per_royal             
        ,vgt_preco.per_desp_com          
        ,vgt_preco.per_fabric            
        ,vgt_preco.per_desp_fin          
        ,vgt_preco.per_desp_adm          
        ,vgt_preco.ipi                   
        ,vgt_preco.per_ipi               
        ,vgt_preco.per_inss              
        ,vgt_preco.per_iss               
        ,vgt_preco.per_pis_cofins        
        ,vgt_preco.per_icms              
        ,vgt_preco.csll_sll              
        ,vgt_preco.per_csll              
        ,vgt_preco.ir_sll                
        ,vgt_preco.per_ir     );   */
      end if;
    end if;
    return v_ret;
  end;

  --|------------------------------------------------------------------------
  --| Funcao: preco tendo origem a proposta
  --|------------------------------------------------------------------------
  function fnc_preco_proposta(p_emp         cd_filiais.empresa%type,
                              p_fil         cd_filiais.filial%type,
                              p_seq_ocproit oc_prop_item.seq_ocproit%type,
                              p_formula     char,
                              p_preco_kg    number) return number is
    cursor crparam is
      select * from gs_param where empresa = p_emp;
  
    cursor crItem is
      select * from oc_prop_item i where i.seq_ocproit = p_seq_ocproit;
  
    cursor crpreco is
      select a.* --a.preco_kg, a.peso_bruto, a.peso_liq  
        from gs_preco_venda_prod a
       where a.seq_ocproit = p_seq_ocproit
       and a.rev = (select max(a2.rev) 
                     from gs_preco_venda_prod a2
                     where a2.seq_ocproit = a.seq_ocproit); --6823
  
    vreg_item  oc_prop_item%rowtype;
    vreg_preco gs_preco_venda_prod%rowtype;
  
    v_ret   number;
    v_preco number;
  begin
  
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    vreg_item := null;
    open crItem;
    fetch crItem
      into vreg_item;
    close crItem;
  
    --/-----------------------------------------------------------------------------      
    --/ carrega parametros globais
    --/-----------------------------------------------------------------------------      
    open crparam;
    fetch crparam
      into vgpreg_param;
    close crparam;
  
    --/-----------------------------------------------------------------------------      
    IF vgt_preco.id_orcamprod is not null then
    
      vgp_id_origem := vreg_item.seq_ocproit;
      vgp_origem    := 'PROP';
    
      if (p_formula is null and vreg_item.formula_calc = 'M') or
         p_formula = 'M' then
        --/preco por margem
        v_ret := fnc_por_margem(vreg_item.margem,
                                p_emp,
                                p_fil,
                                vreg_item.custo_unit * vreg_item.qtde,
                                vreg_item.qtde,
                                vreg_item.per_royal,
                                vreg_item.per_desp_com,
                                vreg_item.per_fabric,
                                vreg_item.per_desp_fin,
                                vreg_item.per_desp_adm,
                                vreg_item.ipi_incl_icms,
                                vreg_item.aliq_ipi,
                                vreg_item.perc_inss,
                                vreg_item.perc_iss,
                                vreg_item.perc_pc,
                                vreg_item.aliq_icms,
                                vreg_item.csll_sll,
                                vreg_item.perc_csll,
                                vreg_item.ir_sll,
                                vreg_item.perc_ir);
      elsif (p_formula is null and vreg_item.formula_calc = 'L') or
            p_formula = 'L' then
        --/preco por margem
        v_ret := fnc_por_preco_liquido(vreg_item.preco_unit,
                                       p_emp,
                                       p_fil,
                                       vreg_item.custo_unit * vreg_item.qtde,
                                       vreg_item.qtde,
                                       vreg_item.per_royal,
                                       vreg_item.per_desp_com,
                                       vreg_item.per_fabric,
                                       vreg_item.per_desp_fin,
                                       vreg_item.per_desp_adm,
                                       vreg_item.ipi_incl_icms,
                                       vreg_item.aliq_ipi,
                                       vreg_item.perc_inss,
                                       vreg_item.perc_iss,
                                       vreg_item.perc_pc,
                                       vreg_item.aliq_icms,
                                       vreg_item.csll_sll,
                                       vreg_item.perc_csll,
                                       vreg_item.ir_sll,
                                       vreg_item.perc_ir);
      elsif (p_formula is null and vreg_item.formula_calc = 'B') or
            p_formula = 'B' then
        --/preco por margem
        v_ret := fnc_por_preco_bruto(vreg_item.preco_unit_simp,
                                     p_emp,
                                     p_fil,
                                     vreg_item.custo_unit * vreg_item.qtde,
                                     vreg_item.qtde,
                                     vreg_item.per_royal,
                                     vreg_item.per_desp_com,
                                     vreg_item.per_fabric,
                                     vreg_item.per_desp_fin,
                                     vreg_item.per_desp_adm,
                                     vreg_item.ipi_incl_icms,
                                     vreg_item.aliq_ipi,
                                     vreg_item.perc_inss,
                                     vreg_item.perc_iss,
                                     vreg_item.perc_pc,
                                     vreg_item.aliq_icms,
                                     vreg_item.csll_sll,
                                     vreg_item.perc_csll,
                                     vreg_item.ir_sll,
                                     vreg_item.perc_ir);
      elsif (p_formula is null and vreg_item.formula_calc = 'K') or
            p_formula = 'K' then
        --/preco por kg
        open crpreco;
        fetch crpreco
          into vreg_preco;
        close crpreco;
        if nvl(vreg_preco.peso_bruto, 0) = 0 then
          v_preco := vreg_preco.peso_liq * vreg_preco.preco_kg;
        else
          v_preco := vreg_preco.peso_bruto * vreg_preco.preco_kg;
        end if;
      
        v_ret := fnc_por_preco_liquido(v_preco,
                                       p_emp,
                                       p_fil,
                                       vreg_item.custo_unit * vreg_item.qtde,
                                       vreg_item.qtde,
                                       vreg_item.per_royal,
                                       vreg_item.per_desp_com,
                                       vreg_item.per_fabric,
                                       vreg_item.per_desp_fin,
                                       vreg_item.per_desp_adm,
                                       vreg_item.ipi_incl_icms,
                                       vreg_item.aliq_ipi,
                                       vreg_item.perc_inss,
                                       vreg_item.perc_iss,
                                       vreg_item.perc_pc,
                                       vreg_item.aliq_icms,
                                       vreg_item.csll_sll,
                                       vreg_item.perc_csll,
                                       vreg_item.ir_sll,
                                       vreg_item.perc_ir);
        /* v_ret := fnc_por_peso( vreg_item.peso_unit
        ,p_preco_kg
        ,p_emp               
        ,p_fil              
        ,vreg_item.custo_unit * vreg_item.qtde  
        ,vreg_item.qtde                            
        ,vreg_item.per_royal             
        ,vreg_item.per_desp_com          
        ,vreg_item.per_fabric            
        ,vreg_item.per_desp_fin          
        ,vreg_item.per_desp_adm          
        ,vreg_item.ipi_incl_icms                   
        ,vreg_item.aliq_ipi               
        ,vreg_item.perc_inss
        ,vreg_item.perc_iss
        ,vreg_item.perc_pc
        ,vreg_item.aliq_icms              
        ,vreg_item.csll_sll              
        ,vreg_item.perc_csll
        ,vreg_item.ir_sll                
        ,vreg_item.perc_ir   );    */
      end if;
    end if;
    return v_ret;
  end;

  --|------------------------------------------------------------------------
  --| Funcao: preco tendo origem a proposta
  --|------------------------------------------------------------------------
  function fnc_preco_proposta_margem_zero(p_emp         cd_filiais.empresa%type,
                                          p_fil         cd_filiais.filial%type,
                                          p_seq_ocproit oc_prop_item.seq_ocproit%type,
                                          p_seq         oc_proposta.seq_ocprop%type,
                                          p_formula     char,
                                          p_preco_kg    number) return number is
    cursor crparam is
      select * from gs_param where empresa = p_emp;
  
    cursor crItem is
      select *
        from oc_prop_item i
       where i.seq_ocprop = p_seq
         and (p_seq_ocproit is null or i.seq_ocproit = p_seq_ocproit)
        ;
  
    --vreg_item oc_prop_item%rowtype;
    v_ret        number := 0;
    v_qtd        number := 1;
    v_preco_unit number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    --vreg_item := null;
    /*
     open crItem;
     fetch crItem into vreg_item;
     close crItem;
    */
    --/-----------------------------------------------------------------------------      
    --/ carrega parametros globais
    --/-----------------------------------------------------------------------------      
    open crparam;
    fetch crparam
      into vgpreg_param;
    close crparam;
  
    --/-----------------------------------------------------------------------------      
  
    --IF vgt_preco.id_orcamprod is not null then
    for vreg_item in crItem loop
      vgp_id_origem := vreg_item.seq_ocproit;
      vgp_origem    := 'PROP';
      if nvl(p_seq_ocproit, 0) = 0 then
        v_qtd := vreg_item.qtde;
      end if;
      v_preco_unit := nvl(fnc_por_margem(0 --vreg_item.margem  
                                        ,
                                         p_emp,
                                         p_fil,
                                         vreg_item.custo_unit *
                                         vreg_item.qtde,
                                         vreg_item.qtde,
                                         vreg_item.per_royal,
                                         vreg_item.per_desp_com,
                                         vreg_item.per_fabric,
                                         vreg_item.per_desp_fin,
                                         vreg_item.per_desp_adm,
                                         vreg_item.ipi_incl_icms,
                                         vreg_item.aliq_ipi,
                                         vreg_item.perc_inss,
                                         vreg_item.perc_iss,
                                         vreg_item.perc_pc,
                                         vreg_item.aliq_icms,
                                         vreg_item.csll_sll,
                                         vreg_item.perc_csll,
                                         vreg_item.ir_sll,
                                         vreg_item.perc_ir),
                          0);
      v_ret        := v_ret + (v_preco_unit * v_qtd);
    
    --end if;
    end loop;
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: POR PRECO LIQUIDO - retorna preco venda bruto
  --|------------------------------------------------------------------------
  function fnc_por_preco_liquido(p_preco_liquido  gs_preco_venda_prod.valor_produto_liq%type,
                                 p_emp            cd_filiais.empresa%type,
                                 p_fil            cd_filiais.filial%type,
                                 p_v_custo_total  gs_preco_venda_prod.custo%type,
                                 p_qtd            gs_preco_venda_prod.qtd%type,
                                 p_per_royal      gs_preco_venda_prod.per_royal%type,
                                 p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                                 p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                                 p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                                 p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                                 p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                                 p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                                 p_per_inss       gs_preco_venda_prod.per_inss%type,
                                 p_per_iss        gs_preco_venda_prod.per_iss%type,
                                 p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                                 p_per_icms       gs_preco_venda_prod.per_icms%type,
                                 p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                                 p_per_csll       gs_preco_venda_prod.per_csll%type,
                                 p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                                 p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number is
    v_ret          number(15, 2);
    v_fator_dentro number(15, 4);
    v_csll_aux     number(15, 4);
    v_ir_aux       number(15, 4);
    v_margem_aux   number(15, 4);
    v_soma_aux     number(15, 4);
  
    v_preco_sem_ipi    number(15, 2);
    v_preco_sem_trib   number(15, 2);
    v_preco_com_margem number(15, 2);
  
    v_vl_csll_aux        number(15, 4);
    v_vl_ir_aux          number(15, 4);
    v_lucro_aux          number(15, 2);
    v_sob_margem         number(15, 2);
    v_valor_liquido      number(15, 2);
    v_preco_sem_desp_com number(15, 2);
  begin
    --/-----------------------------------------------------------------------------
    --/variavel mandante para calculo do pre�o
    --/-----------------------------------------------------------------------------
    vgp_preco_venda_liquido := nvl(p_preco_liquido, 0);
  
    --/-----------------------------------------------------------------------------      
    --/ custo industrial
    --/-----------------------------------------------------------------------------      
    if nvl(p_qtd, 0) = 0 then
      vgp_custo_industrial := p_v_custo_total / 1;
    else
      vgp_custo_industrial := p_v_custo_total / p_qtd;
    end if;
    --/-----------------------------------------------------------------------------      
    --/ carrega parametros globais
    --/-----------------------------------------------------------------------------      
    vgp_contingencia_fabricacao := nvl(p_per_fabric, 0); -- / 100;
    vgp_despesa_financeira      := nvl(p_per_desp_fin, 0); -- / 100;
    vgp_despesa_administrativa  := nvl(p_per_desp_adm, 0); -- / 100;
    vg_ipi                      := nvl(p_per_ipi, 0); -- / 100; 
  
    --/-----------------------------------------------------------------------------
    --/ define fator Despesas | Contingencias
    --/ % sobre custo (por fora)   
    --/-----------------------------------------------------------------------------
    if vgpreg_param.bid = 'S' then
      vgp_fator_custos := (100 + vgp_contingencia_fabricacao +
                          vgp_despesa_financeira +
                          vgp_despesa_administrativa) / (100);
    else
      vgp_fator_custos := 100 / (100 - vgp_contingencia_fabricacao -
                          vgp_despesa_financeira -
                          vgp_despesa_administrativa);
    end if;
    --calcula custo industrial com taxas adicionais
    vgp_custo_industrial := vgp_custo_industrial * vgp_fator_custos;
  
    --/ valor sem desp comercial e royalties
    vgp_despesas_comerciais := nvl(p_per_desp_com, 0); -- / 100;
    vgp_royalties           := nvl(p_per_royal, 0); -- / 100;
  
    --/ calcula preco sem royalties/despesas comerciais
    if 1 = 2 then
      -- n�o esta sendo usado neste momento
      -- se for descontar despesa para calcular margem
      v_preco_sem_desp_com := round(vgp_preco_venda_liquido -
                                    ((vgp_royalties +
                                    vgp_despesas_comerciais) *
                                    vgp_preco_venda_liquido / 100),
                                    2);
      vgp_margem           := 0;
    else
      v_preco_sem_desp_com := vgp_preco_venda_liquido;
      --| retira da margem as despesas comerciais
      vgp_margem := (vgp_royalties + vgp_despesas_comerciais) * -1;
    end if;
    --/calcula lucro liquido                                                                 
    v_lucro_aux := v_preco_sem_desp_com - vgp_custo_industrial;
  
    --/ calcula margem
    vgp_margem := vgp_margem +
                  round(v_lucro_aux / v_preco_sem_desp_com * 100, 2);
    --/-----------------------------------------------------------------------------      
    --|CSLL DE RENDA SOBRE MARGEM
    --/-----------------------------------------------------------------------------      
    vg_csll := nvl(p_per_csll, 0);
  
    --/-----------------------------------------------------------------------------      
    --|IMPOSTO DE RENDA SOBRE MARGEM
    --/-----------------------------------------------------------------------------      
    vg_ir                   := nvl(p_per_ir, 0);
    v_sob_margem            := (v_lucro_aux *
                               (100 / (100 - vg_ir - vg_csll))) -
                               v_lucro_aux;
    vgp_preco_venda_liquido := vgp_preco_venda_liquido + v_sob_margem;
    --/---------------------------------------------------------------
    --/tributos sobre preco com margem/ir/csll
    --/---------------------------------------------------------------
    vg_ipi  := nvl(p_per_ipi, 0); -- / 100; 
    vg_inss := nvl(p_per_inss, 0); -- / 100;  
    vg_iss  := nvl(p_per_iss, 0); -- / 100;    
    vg_icms := nvl(p_per_icms, 0); -- / 100;
    vg_cpmf := 0;
  
    if p_ipi_sim_nao = 'S' then
      --formula1
      -- vg_icms := (100/(100-(vg_icms*(1+vg_ipi/100))))-1)*100); --fica mais caro
    
      --formula2
      --B32*B40/100+B32
      vg_icms := nvl(vg_icms, 0) * (1 + vg_ipi / 100);
    end if;
    --/-----------------------------------------------------------------------------
    --/  pis cofins - se n�o inclui icms na base de calculo do pis/cofins
    --/----------------------------------------------------------------------------- 
    vg_piscof := nvl(p_per_pis_cofins, 0); -- / 100;        
    if vgpreg_param.ICMS_BPISCOF = 'N' then
      vg_piscof := vg_piscof - (vg_piscof * vg_icms / 100);
    end if;
    --/-----------------------------------------------------------------------------           
    --/ calcula preco bruto ...com impostos sem IPI
    --/ com pis/cofins  e icms normal
    --/-----------------------------------------------------------------------------           
  
    vgp_fator_tributos := 100 / (100 - (nvl(vg_icms, 0)) -
                          nvl(vg_piscof, 0) - nvl(vg_inss, 0));
  
    vgp_preco_venda_bruto_simp := vgp_preco_venda_liquido *
                                  vgp_fator_tributos;
  
    --/ preco por kg 
    vgp_preco_kg := vgp_preco_venda_bruto_simp / vgt_preco.peso_liq;
    --/--------------------------------------------------------------------
    --/ preco com ipi
    vgp_preco_venda_bruto := (vgp_preco_venda_bruto_simp *
                             (1 + vg_ipi / 100));
    --/--------------------------------------------------------------------
    --/preco liquido sem os tributos/ir/csll
    vgp_preco_venda_liquido := vgp_preco_venda_liquido - v_sob_margem;
  
    V_RET := vgp_preco_venda_bruto;
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------
  --| Funcao: POR PESO  
  --|------------------------------------------------------------------------
  function fnc_por_peso(p_peso_liq       gs_preco_venda_prod.peso_liq%type,
                        p_valor_kg       number,
                        p_emp            cd_filiais.empresa%type,
                        p_fil            cd_filiais.filial%type,
                        p_v_custo_total  gs_preco_venda_prod.custo%type,
                        p_qtd            gs_preco_venda_prod.qtd%type,
                        p_per_royal      gs_preco_venda_prod.per_royal%type,
                        p_per_desp_com   gs_preco_venda_prod.per_desp_com%type,
                        p_per_fabric     gs_preco_venda_prod.per_fabric%type,
                        p_per_desp_fin   gs_preco_venda_prod.per_desp_fin%type,
                        p_per_desp_adm   gs_preco_venda_prod.per_desp_adm%type,
                        p_ipi_sim_nao    gs_preco_venda_prod.ipi%type,
                        p_per_ipi        gs_preco_venda_prod.per_ipi%type,
                        p_per_inss       gs_preco_venda_prod.per_inss%type,
                        p_per_iss        gs_preco_venda_prod.per_iss%type,
                        p_per_pis_cofins gs_preco_venda_prod.per_pis_cofins%type,
                        p_per_icms       gs_preco_venda_prod.per_icms%type,
                        p_CSLL_SLL       gs_preco_venda_prod.CSLL_SLL%type,
                        p_per_csll       gs_preco_venda_prod.per_csll%type,
                        p_IR_SLL         gs_preco_venda_prod.IR_SLL%type,
                        p_per_ir         gs_preco_venda_prod.per_ir%type)
    return number is
    v_ret               number(15, 2);
    v_preco_venda_bruto number(15, 2);
  begin
    --/-----------------------------------------------------------------------------
    --/variavel mandante para calculo do pre�o
    --/-----------------------------------------------------------------------------
    vgp_preco_venda_bruto := (p_valor_kg * p_peso_liq);
    v_preco_venda_bruto   := vgp_preco_venda_bruto * (p_per_ipi / 100 + 1);
    v_ret                 := fnc_por_preco_bruto(v_preco_venda_bruto,
                                                 p_emp,
                                                 p_fil,
                                                 p_v_custo_total,
                                                 p_qtd,
                                                 p_per_royal,
                                                 p_per_desp_com,
                                                 p_per_fabric,
                                                 p_per_desp_fin,
                                                 p_per_desp_adm,
                                                 p_ipi_sim_nao,
                                                 p_per_ipi,
                                                 p_per_inss,
                                                 p_per_iss,
                                                 p_per_pis_cofins,
                                                 p_per_icms,
                                                 p_CSLL_SLL,
                                                 p_per_csll,
                                                 p_IR_SLL,
                                                 p_per_ir);
  
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: recupera preco bruto sem ipi
  --|------------------------------------------------------------------------
  function get_preco_bruto_simp_orcto(p_emp          cd_filiais.empresa%type,
                                      p_fil          cd_filiais.filial%type,
                                      p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_preco_venda_bruto_simp;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_preco_venda_bruto_simp;
    end if;
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: recupera preco bruto c/ ipi
  --|------------------------------------------------------------------------
  function get_preco_bruto_orcto(p_emp          cd_filiais.empresa%type,
                                 p_fil          cd_filiais.filial%type,
                                 p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_preco_venda_bruto;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_preco_venda_bruto;
    end if;
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: recupera preco liquido
  --|------------------------------------------------------------------------
  function get_preco_liquido_orcto(p_emp          cd_filiais.empresa%type,
                                   p_fil          cd_filiais.filial%type,
                                   p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_preco_venda_liquido;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_preco_venda_liquido;
    end if;
    return v_ret;
  end;

  --|------------------------------------------------------------------------
  --| Funcao: recupera preco margem
  --|------------------------------------------------------------------------
  function get_margem_orcto(p_emp          cd_filiais.empresa%type,
                            p_fil          cd_filiais.filial%type,
                            p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_margem;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_margem;
    end if;
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: recupera custo industrial
  --|------------------------------------------------------------------------   
  function get_custo_industrial(p_emp          cd_filiais.empresa%type,
                                p_fil          cd_filiais.filial%type,
                                p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_custo_industrial;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_custo_industrial;
    end if;
    return v_ret;
  end;
  --|------------------------------------------------------------------------
  --| Funcao: recupera custo industrial
  --|------------------------------------------------------------------------   
  function get_preco_kg_orcto(p_emp          cd_filiais.empresa%type,
                              p_fil          cd_filiais.filial%type,
                              p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
  
    vgt_preco gs_preco_venda_prod%rowtype;
    v_aux     number;
    v_ret     number;
  
  begin
    -- vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    if vgp_id_origem = p_id_orcamprod AND vgp_origem = 'ORCTO' then
    
      v_ret := vgp_preco_kg;
    else
      v_aux := fnc_preco_orcto(p_emp, p_fil, p_id_orcamprod, null);
      v_ret := vgp_preco_kg;
    end if;
    return v_ret;
  end;

  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------         
  --|------------------------------------------------------------------------
  --|                        Funcao: despesas orcto
  --|------------------------------------------------------------------------      
  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------  

  --|------------------------------------------------------------------------
  --| Funcao: calcula contigencia de fabricacao
  --|------------------------------------------------------------------------   
  function get_contingencia_fabr_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    -- vgt_preco gs_preco_venda_prod%rowtype;
    v_ret number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
  
    if nvl(vgt_preco.per_fabric, 0) > 0 then
      v_ret := vgt_preco.qtd * vgt_preco.custo *
               nvl(vgt_preco.per_fabric, 0) / 100;
    end if;
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa adm
  --|------------------------------------------------------------------------   
  function get_desp_adm_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    v_ret number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
  
    if nvl(vgt_preco.per_desp_adm, 0) > 0 then
      v_ret := vgt_preco.qtd * vgt_preco.custo *
               nvl(vgt_preco.per_desp_adm, 0) / 100;
    end if;
  
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa financeira
  --|------------------------------------------------------------------------   
  function get_desp_fin_orcto(p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    v_ret number;
  begin
  
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
  
    if nvl(vgt_preco.per_desp_fin, 0) > 0 then
      v_ret := vgt_preco.qtd * vgt_preco.custo *
               nvl(vgt_preco.per_desp_fin, 0) / 100;
    end if;
  
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------
  --| Funcao: calcula despesa comercial(comiss�o)
  --|------------------------------------------------------------------------   
  function get_desp_com_orcto(p_emp          cd_filiais.empresa%type,
                              p_fil          cd_filiais.filial%type,
                              p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    v_ret       number;
    v_preco_liq number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
  
    if nvl(vgt_preco.per_desp_com, 0) > 0 then
      v_preco_liq := get_preco_liquido_orcto(p_emp, p_fil, p_id_orcamprod);
      v_ret       := vgt_preco.qtd * v_preco_liq *
                     nvl(vgt_preco.per_desp_com, 0) / 100;
    end if;
  
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------
  --| Funcao: calcula royalties
  --|------------------------------------------------------------------------   
  function get_royalties_orcto(p_emp          cd_filiais.empresa%type,
                               p_fil          cd_filiais.filial%type,
                               p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    v_ret       number;
    v_preco_liq number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
  
    if nvl(vgt_preco.per_royal, 0) > 0 then
      v_preco_liq := get_preco_liquido_orcto(p_emp, p_fil, p_id_orcamprod);
      v_ret       := vgt_preco.qtd * v_preco_liq *
                     nvl(vgt_preco.per_royal, 0) / 100;
    end if;
  
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------         
  --|------------------------------------------------------------------------
  --|                        Funcao: tributos orcto
  --|------------------------------------------------------------------------      
  --|------------------------------------------------------------------------   
  --|------------------------------------------------------------------------   

  --|------------------------------------------------------------------------
  --| Funcao: calcula pis/cofins
  --|------------------------------------------------------------------------   
  function get_piscof_orcto(p_emp          cd_filiais.empresa%type,
                            p_fil          cd_filiais.filial%type,
                            p_id_orcamprod oc_orcam_prod.id_orcamprod%type)
    return number is
    v_ret   number;
    v_preco number;
  begin
    --/-----------------------------------------------------------------------------      
    --/ carrega dados do orcamento
    --/-----------------------------------------------------------------------------      
    if vgt_preco.id_orcamprod is null or
       vgt_preco.id_orcamprod != p_id_orcamprod then
      vgt_preco := get_preco_venda_prod(p_id_orcamprod);
    end if;
    if nvl(vgt_preco.per_pis_cofins, 0) > 0 then
      v_preco := get_preco_bruto_simp_orcto(p_emp, p_fil, p_id_orcamprod);
      v_ret   := vgt_preco.qtd * v_preco * nvl(vgt_preco.per_pis_cofins, 0) / 100;
    end if;
  
    return v_ret;
  
  end;

  --|------------------------------------------------------------------------   
  --/ gerar revisao de preco
  --|------------------------------------------------------------------------   
  procedure gerar_revisao_preco(p_emp gs_preco_venda.empresa%type,
                                p_id  gs_preco_venda.nr_pc_seq%type) is
  cursor cr is
     select max(v2.rev)
       from gs_preco_venda v2
      where v2.empresa = p_emp
        and v2.nr_pc_seq = p_id;
                         
  V_ID NUMBER(9);
  v_rev gs_preco_venda.rev%type;
  
  begin
  
    --select gs_preco_venda_seq.nextval into v_id from dual;
    v_id := p_id;
    open cr;
    fetch cr into v_rev;
    close cr;
    
   
    insert into gs_preco_venda
      (empresa,
       nr_pc_seq,
       mercado,
       consumidor,
       seq_ocprop,
       cliente,
       data,
       moeda,
       comprador,
       vendedor,
       comissao,
       desp_financ,
       per_desp,
       desp_adm,
       per_adm,
       per_imposto,
       negociacao,
       formula_calc,
       per_fabric,
       vl_fabric,
       per_royal,
       vl_royal,
       cpmf,
       id_orcamvenda,
       per_ir,
       vl_ir,
       vl_comiss,
       rev,
       usu_incl,
       dt_incl)
      select empresa,
             v_id          nr_pc_seq,
             mercado,
             consumidor,
             seq_ocprop,
             cliente,
             data,
             moeda,
             comprador,
             vendedor,
             comissao,
             desp_financ,
             per_desp,
             desp_adm,
             per_adm,
             per_imposto,
             negociacao,
             formula_calc,
             per_fabric,
             vl_fabric,
             per_royal,
             vl_royal,
             cpmf,
             id_orcamvenda,
             per_ir,
             vl_ir,
             vl_comiss,
             v_rev+1,
             user          usu_incl,
             sysdate       dt_incl
        from gs_preco_venda v
       where v.empresa = p_emp
         and v.nr_pc_seq = p_id
         and v.rev = v_rev ;
  
    insert into gs_preco_venda_prod
      (empresa,
       nr_pc_seq,
       nr_pc_seq_pro,
       mercado,
       seq_ocproit,
       produto,
       custo,
       peso,
       qtd,
       vlr_fix,
       ipi,
       per_ipi,
       icms,
       per_icms,
       iss,
       per_iss,
       pis_cofins,
       per_pis_cofins,
       valor_produto,
       valor_produto_br,
       valor_produto_liq,
       vl_piscof,
       vl_icms,
       vl_ipi,
       vl_iss,
       id_orcamprod,
       produto_orc,
       descr_prod,
       per_csll,
       vl_csll,
       per_inss,
       vl_inss,
       peso_bruto,
       peso_liq,
       preco_kg,
       comissao,
       per_desp_fin,
       vl_desp_fin,
       per_desp_adm,
       per_desp_com,
       vl_desp_com,
       per_fabric,
       vl_contig_fabric,
       per_royal,
       vl_royal,
       per_ir,
       vl_ir,
       formula_calc,
       vl_desp_adm,
       csll_sll,
       ir_sll,
       margem,
       rev)
      select empresa,
             v_id nr_pc_seq,
             gs_preco_venda_prod_seq.nextval nr_pc_seq_pro,
             mercado,
             seq_ocproit,
             produto,
             custo,
             peso,
             qtd,
             vlr_fix,
             ipi,
             per_ipi,
             icms,
             per_icms,
             iss,
             per_iss,
             pis_cofins,
             per_pis_cofins,
             valor_produto,
             valor_produto_br,
             valor_produto_liq,
             vl_piscof,
             vl_icms,
             vl_ipi,
             vl_iss,
             id_orcamprod,
             produto_orc,
             descr_prod,
             per_csll,
             vl_csll,
             per_inss,
             vl_inss,
             peso_bruto,
             peso_liq,
             preco_kg,
             comissao,
             per_desp_fin,
             vl_desp_fin,
             per_desp_adm,
             per_desp_com,
             vl_desp_com,
             per_fabric,
             vl_contig_fabric,
             per_royal,
             vl_royal,
             per_ir,
             vl_ir,
             formula_calc,
             vl_desp_adm,
             csll_sll,
             ir_sll,
             margem,
             v_rev +1
        from gs_preco_venda_prod vp
       where vp.empresa = p_emp
         and vp.nr_pc_seq = p_id
         and vp.rev = v_rev;
         
       commit;
         
  exception
    when others then
      raise_application_error(-20100,'OC_PRECO_UTL.GERAR_REVISAO_PRECO:'||SQLERRM);
  end;

end;
/
