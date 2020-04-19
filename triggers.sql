CREATE OR REPLACE FUNCTION check_constraint_row() RETURNS trigger AS $empt_stamp$
    BEGIN
        RETURN NEW;
    END;
$empt_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER empt_stamp AFTER INSERT OR UPDATE ON contract_service
    FOR EACH ROW
    EXECUTE FUNCTION check_constraint_row();