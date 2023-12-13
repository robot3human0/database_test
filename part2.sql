--==part2.1==--
CREATE OR REPLACE PROCEDURE add_p2p_checks(
    checking_peer varchar,
    checked_peer varchar,
    task_name varchar,
    check_status status,
    check_time time) AS
$$
DECLARE
check_id bigint;
    today    date := CURRENT_DATE;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Peers WHERE nickname = checking_peer)
        OR NOT EXISTS(SELECT 1 FROM Peers WHERE nickname = checked_peer) THEN
        RAISE EXCEPTION 'Both peers should be registered in the Peers table';
END IF;

    IF checking_peer = checked_peer THEN
        RAISE EXCEPTION 'The checking peer cannot check by himself';
END IF;

    IF check_status = 'Start' THEN
        INSERT INTO checks (id, peer, task, date)
        VALUES ((SELECT (max(id) + 1) FROM checks), checked_peer, task_name, today)
        RETURNING id INTO check_id;
ELSE
SELECT p2p.check_id
INTO check_id
FROM p2p
         JOIN checks c on p2p.check_id = c.id
WHERE checkingpeer = checking_peer
  AND peer = checked_peer
  AND task = task_name
  AND state = 'Start';
END IF;
INSERT INTO P2P (id, check_id, checkingPeer, state, time)
VALUES ((SELECT (max(id) + 1) FROM p2p), check_id, checking_peer, check_status, check_time);
END;
$$ LANGUAGE plpgsql;

--------TEST CASE----------
CALL add_p2p_checks('hirokose', 'richesea', 'C6_s21_matrix', 'Start', '08:00:00'); -- SUCCESS
CALL add_p2p_checks('hirokose', 'richesea', 'C6_s21_matrix', 'Success', '08:45:00'); -- SUCCESS
CALL add_p2p_checks('lavondas', 'flashern', 'L0_Linux', 'Start', '08:00:00'); -- FAILURE
-----------------------------------------------------------------

--==part 2.2==--
CREATE OR REPLACE PROCEDURE add_verter_check(
    checking_peer varchar,
    task_name varchar,
    check_status status,
    check_time time) AS
$$
DECLARE
check_id_4_verter bigint;
BEGIN
SELECT c.id
INTO check_id_4_verter
FROM p2p
         JOIN checks c on p2p.check_id = c.id
WHERE state = 'Success'
  AND c.task = task_name
  AND checkingpeer = checking_peer
ORDER BY date DESC, p2p.time DESC LIMIT 1;
IF check_id_4_verter IS NULL THEN
        RAISE EXCEPTION 'No successful P2P check found for the specified task and peer';
ELSE
        INSERT INTO verter
        VALUES ((SELECT coalesce(max(id), 0)
                 FROM verter) + 1, check_id_4_verter, check_status, check_time);
END IF;
END;
$$ LANGUAGE plpgsql;

--------TEST CASE----------
CALL add_verter_check('hirokose', 'C6_s21_matrix', 'Start', '08:46:02'); -- SUCCESS
CALL add_verter_check('hirokose', 'C6_s21_matrix', 'Success', '08:47:48'); -- SUCCESS
CALL add_verter_check('richesea', 'C6_s21_matrix', 'Start', '08:46:02'); -- SUCCESS
CALL add_verter_check('richesea', 'C6_s21_matrix', 'Failure', '08:46:02'); -- SUCCESS
CALL add_verter_check('Flashern', 'C6_s21_matrix', 'Start', '08:46:02'); -- SUCCESS
-----------------------------------------------------------------

--==part 2.3==--
CREATE OR REPLACE FUNCTION add_points() RETURNS TRIGGER AS
$trans_point$
DECLARE
new_id           bigint  := (SELECT coalesce(max(id), 0)
                                 FROM transferredpoints) + 1;
    new_ching_peer   varchar := new.checkingpeer;
    new_chck_peer    varchar := (SELECT peer
                                 FROM checks
                                 WHERE id = new.check_id);
    new_pointsamount integer;
BEGIN
    IF new.state = 'Start' THEN
SELECT pointsamount
INTO new_pointsamount
FROM transferredpoints
WHERE checkingpeer = new_ching_peer
  AND checkedpeer = new_chck_peer;
IF new_pointsamount IS NULL THEN
            INSERT INTO transferredpoints VALUES (new_id, new_ching_peer, new_chck_peer, 1);
ELSE
SELECT id
INTO new_id
FROM transferredpoints
WHERE checkingpeer = new_ching_peer AND checkedpeer = new_chck_peer;
UPDATE transferredpoints SET pointsamount = new_pointsamount + 1 WHERE id = new_id;
END IF;
END IF;
RETURN NULL;
END;
$trans_point$ LANGUAGE plpgsql;


CREATE TRIGGER trg_p2p_add_point
    AFTER
        INSERT OR UPDATE
                      ON p2p
                      FOR EACH ROW
                      EXECUTE PROCEDURE add_points();

--------TEST CASE----------
CALL add_p2p_checks('wendybor', 'myeshask', 'CPP1_s21_matrix+', 'Start', '08:00:00');
CALL add_p2p_checks('lavondas', 'myeshask', 'CPP2_s21_containers', 'Start', '09:14:00');
CALL add_p2p_checks('pearlecr', 'karleenk', 'C5_s21_decimal', 'Start', '11:10:00');
CALL add_p2p_checks('pearlecr', 'karleenk', 'C5_s21_decimal', 'Success', '11:12:31');

-----------------------------------------------------------------
--==part 2.4==--
CREATE OR REPLACE FUNCTION check_before_add() RETURNS TRIGGER AS
$$
DECLARE
max_xp integer := (SELECT maxxp
                       FROM tasks
                                JOIN checks c on tasks.title = c.task
                                JOIN p2p p on c.id = p.check_id
                       WHERE state = 'Success'
                         AND check_id = new.check_id);
BEGIN
    IF max_xp IS NULL OR new.xpamount > max_xp THEN
        RETURN NULL;
ELSE
        RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_xp
    BEFORE INSERT
    ON xp
    FOR EACH ROW
    EXECUTE FUNCTION check_before_add();

delete from xp where id = 40;
select coalesce(max(id), 0) + 1 from xp;
--------TEST CASE----------
INSERT INTO xp VALUES ((SELECT coalesce(max(id), 0) FROM xp) + 1, 44, 300); -- FAIL (Причина: проверка провалена)
INSERT INTO xp VALUES ((SELECT coalesce(max(id), 0) FROM xp) + 1, 45, 777); -- FAIL (Причина: количиство очков привышает возможное)
INSERT INTO xp VALUES ((SELECT coalesce(max(id), 0) FROM xp) + 1, 45, 300); -- SUCCESS
INSERT INTO xp VALUES ((SELECT coalesce(max(id), 0) FROM xp) + 1, 46, 300); -- FAIL (Причина: проверка еще не завершена)
-----------------------------------------------------------------
