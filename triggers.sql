--Trigger for table contract service (Check permission service for event)--
CREATE OR REPLACE FUNCTION check_contract_service() RETURNS TRIGGER AS $check_contract_service$
    DECLARE
        event integer DEFAULT -1;
    BEGIN
        event := (SELECT event_id FROM contract WHERE contract.contract_id = NEW.contract_id);
        IF event <> NEW.event_id THEN
            RAISE EXCEPTION 'Not permission event';
        END IF;
        RETURN NULL;
    END;
$check_contract_service$ LANGUAGE plpgsql;

CREATE TRIGGER check_contract_service AFTER INSERT OR UPDATE ON contract_service
    FOR EACH ROW
    EXECUTE PROCEDURE check_contract_service();


--Trigger for table payment (Check ownership new payment user)--
CREATE OR REPLACE FUNCTION check_of_payment() RETURNS TRIGGER AS $check_payement$
    DECLARE
        paying_user int;
        contract_user int;
    BEGIN
        paying_user := (SELECT user_id FROM paydoc WHERE paydoc.paydoc_id = NEW.paydoc_id);
        contract_user := (SELECT user_id FROM contract WHERE contract.contract_id = NEW.contract_id);

        IF paying_user <> contract_user THEN
            RAISE EXCEPTION 'No match between contract and user';
        END IF;
        RETURN NULL;
    END;
    $check_payement$ LANGUAGE plpgsql;

CREATE TRIGGER check_payment AFTER INSERT OR UPDATE ON payment
    FOR EACH ROW
    EXECUTE PROCEDURE check_of_payment();