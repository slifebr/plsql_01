create or replace package lib_data is

   --||
   --|| LIB_DATA.PKS : Rotinas manipulacao de datas
   --||
   function is_util(v_data in date) return char;
   --------------------------------------------------------------------------------
   function util(v_emp  in cd_empresas.empresa%type
                ,v_data in date
                ,v_fir  in cd_firmas.firma%type := null) return date;
   --------------------------------------------------------------------------------
   function dias_util_adm(v_emp    in cd_empresas.empresa%type
                         ,v_fir    in cd_firmas.firma%type := null
                         ,v_dt_ini in date
                         ,v_dt_fim in date
                          
                          ) return number;
   --------------------------------------------------------------------------------
   function tipo_fat(p_dt date
                    ,p_tp ft_condpag.tipo_fat%type) return date;
   --|-----------------------------------------------------------------------------------------
   function calcula_data(p_dt        date
                        ,p_dia       number
                        ,p_cid_local number
                        ,p_cid_ext   number
                        ,p_tipo      oc_prop_item.tipo_dias%type) return date;

   --|-----------------------------------------------------------------------------------------
   function calcula_dias(p_dt        date
                        ,p_entrega   date
                        ,p_cid_local number
                        ,p_cid_ext   number
                        ,p_tipo      oc_prop_item.tipo_dias%type) return number;
   --|--------------------------------------------------------------------------------------------
   function dy_to_d(p_dy varchar2) return number;
   --|--------------------------------------------------------------------------------------------
   function d_to_dy(p_d number) return varchar2;
   --|--------------------------------------------------------------------------------------------
   function ultimo_dia_util(p_dt date) return date;
end lib_data;
/
create or replace package body lib_data is

   --||
   --|| LIB_DATA.PKB : Rotinas manipulacao de datas
   --||

   --------------------------------------------------------------------------------
   function util(v_emp  in cd_empresas.empresa%type
                ,v_data in date
                ,v_fir  in cd_firmas.firma%type := null) return date
   /*
      || Retorna a data util a considerar
      || Caso Firma = 0, Dia Util Anterior
      */
    is
   
      cursor cr1(d date
                ,c cd_feriados.cod_cidade%type) is
         select 1
           from cd_feriados
          where trunc(data) = trunc(d)
            and cod_cidade = c;
   
      cursor cr2(d date
                ,u cd_feriados.uf%type) is
         select 1
           from cd_feriados
          where trunc(data) = trunc(d)
            and uf = u;
   
      cursor cr3(d date) is
         select 1
           from cd_feriados
          where trunc(data) = trunc(d)
            and uf is null
            and cod_cidade is null;
   
      v_num number;
   
      v_cid  cd_cidades.cod_cidade%type;
      v_uf   cd_cidades.uf%type;
      v_d    date;
      v_step number;
      v_fir2 cd_firmas.firma%type;
   
   begin
   
      v_step := 1;
      v_d    := v_data;
   
      --| Caso Firma 0, Dia Util Anterior
      if v_fir = 0 then
         v_step := -1;
         v_fir2 := null;
      else
         v_fir2 := v_fir;
      end if;
   
      --| Iniciando com a data informada, procura a primeira que
      --| nao seja feriado, na direcao dada por v_step
      loop
      
         --| Sabado
         if to_char(v_d,
                    'D') = '7' then
            if v_step < 0 then
               v_d := v_d - 1;
            else
               v_d := v_d + 2;
            end if;
            --| Domingo
         elsif to_char(v_d,
                       'D') = '1' then
            if v_step < 0 then
               v_d := v_d - 2;
            else
               v_d := v_d + 1;
            end if;
            --| Dia da semana
         else
            -- Ferido Nacional
            open cr3(v_d);
            fetch cr3
               into v_num;
            if cr3%notfound then
               v_num := 0;
            end if;
            close cr3;
            -- Feriado estadual
            if v_num = 0 and
               v_fir2 is not null then
               v_uf := cd_firmas_utl.uf_cob(v_fir2);
               open cr2(v_d,
                        v_uf);
               fetch cr2
                  into v_num;
               if cr2%notfound then
                  v_num := 0;
               end if;
               close cr2;
            end if;
            -- Feriado municipal
            if v_num = 0 and
               v_fir2 is not null then
               v_cid := cd_firmas_utl.cod_cidade_cob(v_fir2);
               open cr1(v_d,
                        v_cid);
               fetch cr1
                  into v_num;
               if cr1%notfound then
                  v_num := 0;
               end if;
               close cr1;
            end if;
            exit when v_num = 0;
            v_d := v_d + v_step;
         end if;
      
      end loop;
   
      return v_d;
   
   end;

   --------------------------------------------------------------------------------
   function dias_util_adm(v_emp    in cd_empresas.empresa%type
                         ,v_fir    in cd_firmas.firma%type := null
                         ,v_dt_ini in date
                         ,v_dt_fim in date
                          
                          ) return number
   /*
      || Retorna a QTDE DE DIAS  UTEIS a considerar
      || Caso Firma = 0, Dia Util Anterior
      */
    is
   
      cursor cr1(u cd_feriados.uf%type
                ,c cd_feriados.cod_cidade%type) is
         select count(data)
           from cd_feriados a
          where trunc(data) between v_dt_ini and v_dt_fim
            and cod_cidade = c
            and not exists
          (select b.data
                   from cd_feriados b
                  where b.data = a.data
                    and (b.uf is null or (b.uf = u and b.cod_cidade is null)));
   
      cursor cr2(u cd_feriados.uf%type) is
         select count(data)
           from cd_feriados a
          where trunc(data) between v_dt_ini and v_dt_fim
            and uf = u
            and cod_cidade is null
            and not exists (select b.data
                   from cd_feriados b
                  where b.data = a.data
                    and b.cod_cidade is null
                    and b.uf is null);
   
      cursor cr3 is
         select count(data)
           from cd_feriados
          where trunc(data) between v_dt_ini and v_dt_fim
            and uf is null
            and cod_cidade is null;
   
      v_num1 number;
      v_num2 number;
      v_num3 number;
   
      v_cid cd_cidades.cod_cidade%type;
      v_uf  cd_cidades.uf%type;
      v_ini date;
      v_fim date;
   
      v_ret number(9);
   
      v_fir2 cd_firmas.firma%type;
   
   begin
   
      if v_dt_ini is null then
         v_ini := trunc(sysdate);
      else
         v_ini := v_dt_ini;
      end if;
      --/---------------------------------------
      if v_dt_fim is null then
         v_fim := trunc(sysdate);
      else
         v_fim := v_dt_fim;
      end if;
      --/---------------------------------------
      if v_ini = v_fim then
         v_ret := 1;
      elsif v_fim < v_ini then
         v_ret := 0;
      else
         v_ret := (v_fim - v_ini) + 1;
      end if;
      -----------------------------------------
      --| Caso Firma 0, Dia Util Anterior
      if v_fir = 0 then
         v_fir2 := null;
      else
         v_fir2 := v_fir;
      end if;
   
      --| Iniciando com a data informada, procura a primeira que
      --| nao seja feriado, na direcao dada por v_step
   
      -- Ferido Nacional
      open cr3;
      fetch cr3
         into v_num3;
      if cr3%notfound then
         v_num3 := 0;
      end if;
      close cr3;
   
      -- Feriado estadual
      if v_fir2 is not null then
         v_uf := cd_firmas_utl.uf_cob(v_fir2);
         open cr2(v_uf);
         fetch cr2
            into v_num2;
         if cr2%notfound then
            v_num2 := 0;
         end if;
         close cr2;
      end if;
   
      -- Feriado municipal
      if v_fir2 is not null then
         v_uf  := cd_firmas_utl.uf_cob(v_fir2);
         v_cid := cd_firmas_utl.cod_cidade_cob(v_fir2);
         open cr1(v_uf,
                  v_cid);
         fetch cr1
            into v_num1;
         if cr1%notfound then
            v_num1 := 0;
         end if;
         close cr1;
      end if;
   
      v_ret := v_ret - (v_num1 + v_num2 + v_num3);
      --    end if;
   
      return v_ret;
   
   end;
   -------------------------------------------------------------------------------------
   function is_util(v_data in date) return char is
      v_dt date;
   begin
      v_dt := util(1,
                   v_data,
                   0);
      if v_dt = v_data then
         return 'S';
      else
         return 'N';
      end if;
   end;
   -------------------------------------------------------------------------------------
   -------------------------------------------------------------------------------------
   function tipo_fat(p_dt date
                    ,p_tp ft_condpag.tipo_fat%type) return date is
      v_ret date;
      v_dia number(4);
      --/Tipo de faturamento:FQ-Fora quinzena,FD-Fora dezena,FS-Fora Semana,FM-Fora mes 
   begin
   
      if p_tp = 'FQ' then
         v_dia := to_char(sysdate,
                          'dd');
         if v_dia <= 15 then
            --primeira quinzena
            v_ret := p_dt + (10 - v_dia) + 1;
         else
            -- segunda quinzena
            v_ret := last_day(p_dt) + 1;
         end if;
      
      elsif p_tp = 'FD' then
         v_dia := to_char(sysdate,
                          'dd');
         if v_dia <= 10 then
            --primeira dezena
            v_ret := p_dt + (10 - v_dia) + 1;
         elsif v_dia <= 20 then
            --segunda dezena
            v_ret := p_dt + (20 - v_dia) + 1;
         else
            -- terceira dezena
            v_ret := last_day(p_dt) + 1;
         end if;
      
      elsif p_tp = 'FS' then
         v_ret := trunc(p_dt + to_char(p_dt + (7 - to_char(p_dt,
                                                           'd')),
                                       'd'));
      else
         v_ret := trunc(last_day(p_dt) + 1);
      end if;
   
      return v_ret;
   end;
   --|-----------------------------------------------------------------------------------------
   function calcula_data_corrida(p_dt  date
                                ,p_dia number) return date is
      v_data date;
   begin
   
      v_data := p_dt + p_dia;
      return v_data;
   end;

   --|-----------------------------------------------------------------------------------------
   function calcula_data_uteis(p_dt        date
                              ,p_dia       number
                              ,p_cid_local number
                              ,p_cid_ext   number) return date is
      cursor cr(l_dt_i     date
               ,l_dt_f     date
               ,l_uf_local cd_feriados.uf%type
               ,l_uf_ext   cd_feriados.uf%type) is
         select max(aa2.data)
           from (select aa.*
                       ,rownum linha
                   from (select a.*
                           from (select datas_mes + level - 1 data
                                       ,to_char(datas_mes + level - 1,
                                                'd') dia_semana
                                   from (select l_dt_i datas_mes from dual)
                                 connect by datas_mes + level - 1 <= l_dt_f) a
                          where dia_semana not in (1,
                                                   7)
                            and not exists (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade in
                                        (p_cid_local,
                                         p_cid_ext))
                            and not exists
                          (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade is null
                                    and f.uf in (l_uf_local,
                                                 l_uf_ext))
                               
                            and not exists (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade is null
                                    and f.uf is null)
                          order by 1) aa) aa2
          where aa2.linha <= abs(p_dia);
   
      cursor cruf(p_cid cd_cidades.cod_cidade%type) is
         select uf from cd_cidades d where d.cod_cidade = p_cid;
   
      v_data     date;
      v_dt_ini   date;
      v_dt_fim   date;
      v_uf_local cd_feriados.uf%type;
      v_uf_ext   cd_feriados.uf%type;
      v_dia      number(4);
      v_meses    number(4);
   begin
   
      v_dt_ini := trunc(p_dt);
   
      --/ acha numero de meses pela média de dias uteis
      --/ arredondando para o inteiro seguinte
      v_meses := ceil(abs(p_dia) / 22);
      if p_dia < 0 then
         v_meses := v_meses * -1;
      end if;
   
      v_dt_fim := last_day(add_months(v_dt_ini,
                                      v_meses));
   
      v_uf_local := null;
   
      if p_cid_local is not null then
         open cruf(p_cid_local);
         fetch cruf
            into v_uf_local;
         close cruf;
      end if;
   
      v_uf_ext := v_uf_local;
   
      if p_cid_ext is not null and
         p_cid_ext != p_cid_local then
         open cruf(p_cid_ext);
         fetch cruf
            into v_uf_ext;
         close cruf;
      end if;
   
      open cr(v_dt_ini,
              v_dt_fim,
              v_uf_local,
              v_uf_ext);
      fetch cr
         into v_data;
      close cr;
   
      return v_data;
   end;
   --|-----------------------------------------------------------------------------------------
   function calcula_data(p_dt        date
                        ,p_dia       number
                        ,p_cid_local number
                        ,p_cid_ext   number
                        ,p_tipo      oc_prop_item.tipo_dias%type) return date is
      v_data      date;
      v_cid_local number;
      v_cid_ext   number;
   
      --| p_tipo (C)orrido
      --|        (U)teis
   begin
      if p_tipo = 'C' then
         v_data := calcula_data_corrida(p_dt,
                                        p_dia);
      else
         v_cid_local := p_cid_local;
         v_cid_ext   := p_cid_ext;
      
         if v_cid_local is null then
            v_cid_local := cd_firmas_utl.cod_cidade(101);
         end if;
      
         if v_cid_ext is null then
            v_cid_ext := v_cid_local;
         end if;
      
         v_data := calcula_data_uteis(p_dt,
                                      p_dia,
                                      v_cid_local,
                                      v_cid_ext);
      end if;
      return v_data;
   end;

   --|-----------------------------------------------------------------------------------------
   function calcula_dias_corrido(p_dt      date
                                ,p_entrega date) return number is
      v_dias number(4);
   begin
   
      v_dias := p_entrega - trunc(p_dt);
      return v_dias;
   end;

   --|-----------------------------------------------------------------------------------------
   function calcula_dias_uteis(p_dt        date
                              ,p_entrega   date
                              ,p_cid_local number
                              ,p_cid_ext   number) return number is
      cursor cr(l_dt_i     date
               ,l_dt_f     date
               ,l_uf_local cd_feriados.uf%type
               ,l_uf_ext   cd_feriados.uf%type) is
         select max(aa2.linha)
           from (select aa.*
                       ,rownum linha
                   from (select a.*
                           from (select datas_mes + level - 1 data
                                       ,to_char(datas_mes + level - 1,
                                                'd') dia_semana
                                   from (select l_dt_i datas_mes from dual)
                                 connect by datas_mes + level - 1 <= l_dt_f) a
                          where dia_semana not in (1,
                                                   7)
                            and not exists (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade in
                                        (p_cid_local,
                                         p_cid_ext))
                            and not exists
                          (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade is null
                                    and f.uf in (l_uf_local,
                                                 l_uf_ext))
                               
                            and not exists (select 1
                                   from cd_feriados f
                                  where f.data = a.data
                                    and f.cod_cidade is null
                                    and f.uf is null)
                          order by 1) aa) aa2
          where aa2.data <= p_entrega;
   
      cursor cruf(p_cid cd_cidades.cod_cidade%type) is
         select uf from cd_cidades d where d.cod_cidade = p_cid;
   
      v_dt_ini   date;
      v_dt_fim   date;
      v_uf_local cd_feriados.uf%type;
      v_uf_ext   cd_feriados.uf%type;
      v_dias     number(4);
      v_meses    number(4);
   begin
   
      v_dt_ini := trunc(p_dt);
   
      --/ acha numero de meses pela média de dias uteis
      --/ arredondando para o inteiro seguinte
      v_meses  := ceil((p_entrega - v_dt_ini) / 22);
      v_dt_fim := last_day(add_months(p_dt,
                                      v_meses));
   
      v_uf_local := null;
   
      if p_cid_local is not null then
         open cruf(p_cid_local);
         fetch cruf
            into v_uf_local;
         close cruf;
      end if;
   
      v_uf_ext := v_uf_local;
   
      if p_cid_ext is not null and
         p_cid_ext != p_cid_local then
         open cruf(p_cid_ext);
         fetch cruf
            into v_uf_ext;
         close cruf;
      end if;
   
      open cr(v_dt_ini,
              v_dt_fim,
              v_uf_local,
              v_uf_ext);
      fetch cr
         into v_dias;
      close cr;
   
      return v_dias;
   end;
   --|-----------------------------------------------------------------------------------------
   function calcula_dias(p_dt        date
                        ,p_entrega   date
                        ,p_cid_local number
                        ,p_cid_ext   number
                        ,p_tipo      oc_prop_item.tipo_dias%type) return number is
      v_dias number(4);
      --| p_tipo (C)orrido
      --|        (U)teis
   begin
   
      if p_tipo = 'C' then
         v_dias := calcula_dias_corrido(p_dt,
                                        p_entrega);
      else
         v_dias := calcula_dias_uteis(p_dt,
                                      p_entrega,
                                      p_cid_local,
                                      p_cid_ext);
      end if;
   
      return v_dias;
   end;
   --|--------------------------------------------------------------------------------------------
   function dy_to_d(p_dy varchar2) return number is
      v_ret number(1);
   begin
      select case
                when upper(p_dy) = 'DOM' then
                 1
                when upper(p_dy) = 'SEG' then
                 2
                when upper(p_dy) = 'TER' then
                 3
                when upper(p_dy) = 'QUA' then
                 4
                when upper(p_dy) = 'QUI' then
                 5
                when upper(p_dy) = 'SEX' then
                 6
                when upper(p_dy) = 'SAB' then
                 7
                else
                 0
             end
        into v_ret
        from dual;
      return v_ret;
   end;

   --|--------------------------------------------------------------------------------------------
   function d_to_dy(p_d number) return varchar2 is
      v_ret varchar2(20);
   begin
      select case
                when upper(p_d) = 1 then
                 'DOM'
                when upper(p_d) = 2 then
                 'SEG'
                when upper(p_d) = 3 then
                 'TER'
                when upper(p_d) = 4 then
                 'QUA'
                when upper(p_d) = 5 then
                 'QUI'
                when upper(p_d) = 6 then
                 'SEX'
                when upper(p_d) = 7 then
                 'SAB'
                else
                 ''
             end
        into v_ret
        from dual;
      return v_ret;
   end;
   --|--------------------------------------------------------------------------------------------
   function ultimo_dia_util(p_dt date) return date is
      v_ret date;
   begin
      if p_dt is null then
         v_ret := trunc(sysdate);
      else
         v_ret := last_day(p_dt);
      end if;
      select case
                when to_char(v_ret,
                             'D') in (1,
                                      7) then
                 case
                    when to_char(v_ret,
                                 'D') in (1) then
                     v_ret - 2
                    else
                     v_ret - 1
                 end
                else
                 last_day(v_ret)
             end ultimo_dia_util
        into v_ret
        from dual;
   
      while is_util(v_ret) = 'N' loop
         v_ret := v_ret - 1;
      end loop;
   
      return v_ret;
   end;

end lib_data;
/
