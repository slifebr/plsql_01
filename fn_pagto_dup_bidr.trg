CREATE OR REPLACE TRIGGER fn_pagto_dup_bidr
before insert or Delete on fn_pagto_dup
for each row

declare

  v_adiant fn_tipos_doc.adiant%type;
  v_contabil char(1);
  reg_tit fn_ctrec%rowtype;
  v_saldo number;
  V_DOCUMENTO FN_CtRec.DOCUMENTO%Type;
  V_INTEGRADO CHAR(1);

begin

  --| Le o registro de tipo de documento para ver se e um adiantamento
  If Inserting Then
    select adiant into v_adiant from fn_tipos_doc
     where tipo_doc = :new.tipo_doc;
    --| Acha documento
    Select f.DOCUMENTO
         , t.contabil
      InTo V_DOCUMENTO
         , v_contabil
      From FN_CtRec     f
         , fn_tipos_tit t
     Where f.EMPRESA    = :New.EMPRESA
       And f.FILIAL     = :New.FILIAL
       And f.NUM_TITULO = :New.NUM_TITULO
       And f.SEQ_TITULO = :New.SEQ_TITULO
       And f.PARTE      = :New.PARTE
       and t.tipo_tit = f.tipo_tit;
  Else
    select adiant into v_adiant from fn_tipos_doc
     where tipo_doc = :Old.tipo_doc;
    --| Acha documento
    Select f.DOCUMENTO
         , t.contabil
      InTo V_DOCUMENTO
         , v_contabil
      From FN_CtRec     f
         , fn_tipos_tit t
     Where f.EMPRESA    = :Old.EMPRESA
       And f.FILIAL     = :Old.FILIAL
       And f.NUM_TITULO = :Old.NUM_TITULO
       And f.SEQ_TITULO = :Old.SEQ_TITULO
       And f.PARTE      = :Old.PARTE
       and t.tipo_tit = f.tipo_tit;
  End If;


  --| Se for documento de adiantamento, verifica saldo e grava a utilizacao


if V_contabil  = 'S' and v_adiant = 'S' then
  if v_adiant = 'S' then
    If Inserting  Then
      select * into reg_tit from fn_ctrec
       where empresa = :new.empresa and
             filial = :new.filial and
             num_titulo = :new.num_titulo and
             seq_titulo = :new.seq_titulo and
             parte = :new.parte;
      v_saldo := nvl(fn_adian.saldo(:new.empresa, Nvl( :New.FIRMA, reg_tit.firma ), reg_tit.dt_baixa, 'A'), 0);
      if :new.valor > v_saldo then
        raise_application_error(-20123, 'Saldo de adiantamento insuficiente');
        Null;
      end if;

      insert into fn_adiant values (
        :new.empresa,
        Nvl( :New.FIRMA, reg_tit.firma ),
        reg_tit.dt_baixa,
        fn_adiant_seq.nextval,
        'A',
        'U',
        :new.valor,
        to_char(V_documento),
        null,
        'Utilizacao no titulo ' || to_char(:new.num_titulo)||'-'||To_Char(:New.SEQ_TITULO),
        user,
        :new.conta,
        sysdate,
        :new.parte,
        Null,
        :new.num_titulo,
        Nvl( :New.FIRMA, reg_tit.firma )
        ,null
        );
    Else
      select * into reg_tit from fn_ctrec
       where empresa = :Old.empresa and
             filial = :Old.filial and
             num_titulo = :Old.num_titulo and
             seq_titulo = :Old.seq_titulo and
             parte = :old.parte;
      insert into fn_adiant values (
        :Old.empresa,
        Nvl( :Old.FIRMA, reg_tit.firma ),
        SysDate,
        fn_adiant_seq.nextval,
        'A',
        'R',
        :Old.valor,
        to_char(:Old.num_titulo),
        null,
        'Estorno de : Utilizacao de adiantamento do titulo ' || to_char(:Old.num_titulo),
        user,
        :Old.conta,
        sysdate,
        :old.parte,
        Null,
        :Old.num_titulo,
        Nvl( :Old.FIRMA, reg_tit.firma )
        ,null
        );
    End If;

  end if;
END IF;
end;
/
