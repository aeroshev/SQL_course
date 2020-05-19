CREATE OR REPLACE FUNCTION count_total_cost(number_contract integer) RETURNS money AS $$
DECLARE
    total_cost money = 0.0;
    event_contract integer = 0;
BEGIN
    IF number_contract < 1 OR (SELECT contract_id FROM contract WHERE contract_id = number_contract) IS NULL THEN
        RAISE EXCEPTION 'Illegal id contract';
    END IF;

    event_contract := (SELECT event_id FROM contract WHERE contract.contract_id = number_contract);
    --Count total payment for provided service--
    total_cost := total_cost + coalesce((SELECT sum(price) FROM contract_service AS cs JOIN service AS s
        ON cs.service_id = s.service_id WHERE cs.contract_id = number_contract), 0.0::money);
    --Count price of executed event--
    total_cost := total_cost + coalesce((SELECT sum(rent_cost) FROM event WHERE event.event_id = event_contract),
        0.0::money);
    --Count total payment for rent premises--
    total_cost := total_cost + coalesce((SELECT sum(price) FROM rental_agreement AS ra JOIN premises AS p
        ON ra.premises_id = p.premises_id WHERE ra.event_id = event_contract), 0.0::money);
    --Count total payment for invite stars--
    total_cost := total_cost + coalesce((SELECT sum(fee) FROM event JOIN subsidiary_agreement AS sa ON
        event.event_id = sa.event_id JOIN star ON sa.star_id = star .star_id WHERE event.event_id = event_contract),
        0.0::money);

    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE push_service_in_contract(IN id_contract integer DEFAULT 0, IN id_service integer DEFAULT 0,
                                          INOUT status varchar(45) DEFAULT 'OK')
LANGUAGE plpgsql
AS $$
DECLARE
    valid_contract integer;
    valid_service integer;
    current_event integer;
BEGIN
    valid_contract := (SELECT contract_id FROM contract WHERE contract_id = id_contract);
    IF valid_contract IS NULL THEN
        status := 'Invalid id_contract';
        RETURN;
    END IF;
    valid_service := (SELECT service_id FROM service WHERE service_id = id_service);
    IF valid_service IS NULL THEN
        status := 'Invalid id_service';
        RETURN;
    END IF;

    current_event := (SELECT event_id FROM contract WHERE contract_id = valid_contract);

    IF (SELECT service_id FROM possible_service WHERE service_id = valid_service AND event_id = current_event) IS NULL THEN
        status := 'Service don not possible for this contract';
        RETURN;
    END IF;

    INSERT INTO contract_service (contract_id, service_id, event_id) VALUES
        (valid_contract, valid_service, current_event);
END;
$$;