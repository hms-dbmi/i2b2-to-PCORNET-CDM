 CREATE OR REPLACE TRIGGER "TM_CZ"."TRG_CZ_JOB_ID"
  before insert on tm_cz.CZ_JOB_MASTER    for each row
  begin
    if inserting then
      if :NEW.JOB_ID is null then
        select SEQ_CZ_JOB_MASTER.nextval into :NEW.JOB_ID from dual;
      end if;
    end if;
  end;
