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