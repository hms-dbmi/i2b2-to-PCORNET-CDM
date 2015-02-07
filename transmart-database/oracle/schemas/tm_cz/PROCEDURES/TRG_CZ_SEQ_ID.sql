CREATE OR REPLACE TRIGGER "TM_CZ"."TRG_CZ_SEQ_ID"
  before insert on tm_cz.CZ_JOB_AUDIT    for each row
  begin
    if inserting then
      if :NEW.SEQ_ID is null then
        select SEQ_CZ_JOB_AUDIT.nextval into :NEW.SEQ_ID from dual;
      end if;
    end if;
  end;
/
ALTER TRIGGER "TM_CZ"."TRG_CZ_SEQ_ID" ENABLE;