CREATE OR REPLACE FUNCTION check_contract_service() RETURNS TRIGGER AS $check_contract_service$
    DECLARE
        event integer DEFAULT -1;
    BEGIN
        event := (SELECT event_id FROM contract WHERE contract.contract_id = NEW.contract_id);
        IF event <> NEW.event_id THEN
            ROLLBACK;
            RAISE EXCEPTION 'Not permission event';
        END IF;
        RETURN NULL;
    END;
$check_contract_service$ LANGUAGE plpgsql;

CREATE TRIGGER check_contract_service AFTER INSERT OR UPDATE ON contract_service
    FOR EACH ROW
    EXECUTE PROCEDURE check_contract_service();