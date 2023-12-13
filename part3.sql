--==Part 3.1==--
create or replace function getTransferredPoints()
    returns table
            (
                peer1        varchar,
                peer2        varchar,
                pointsAmount integer
            ) as $$
begin
return query select t1.checkingpeer,
                            t1.checkedpeer,
                            (t1.pointsamount -
                             t2.pointsamount) as poinstAmount
                     from transferredpoints t1
                              join transferredpoints t2 on t1.checkingpeer = t2.checkedpeer and
                                                           t1.checkedpeer = t2.checkingpeer and t1.id < t2.id;
end
$$ language plpgsql;

select * from getTransferredPoints();

--==Part 3.2==--
create or replace function getSuccessedTasks()
    returns table
            (
                peer varchar,
                task varchar,
                XP   integer
            ) as $$
begin
return query select checks.peer AS peer,
                            checks.task AS task,
                            xp.xpamount AS xp
                     from xp
                              join checks on xp.check_id = checks.id;
end
$$ language plpgsql;

select * from getSuccessedTasks();

--==Part 3.3==--
create or replace function getPeersHaventLeftCampus(giga date)
    returns table
            (
                peer varchar
            ) as $$
begin
return query
select tt.peer
from timeTracking tt
where date = giga
group by 1
having count(state) < 3
order by 1;
end
$$ language plpgsql;

SELECT * FROM getPeersHaventLeftCampus('2023-02-13');

--==Part 3.4==--
create or replace function getAmountPoints()
    returns table
            (
                peer         varchar,
                pointsChange bigint
            ) as $$
begin
return query select tableCheckingPeer.checkingpeer                                              as peer,
                            coalesce(tableCheckingPeer.suming, 0) - coalesce(tableCheckedPeer.sumed, 0) as pointsChange
                     from (select checkingpeer,
                                  sum(pointsamount) as suming
                           from transferredpoints
                           group by checkingpeer) as tableCheckingPeer
                              join (select checkedpeer,
                                           sum(pointsamount) as sumed
                                    from transferredpoints
                                    group by checkedpeer) as tableCheckedPeer
                                   on tableCheckingPeer.checkingpeer = tableCheckedPeer.checkedpeer
                     order by pointsChange desc;
end
$$ language plpgsql;

select * from getamountpoints();

--==Part 3.5==--
create or replace function getAmountPoints2()
    returns table
            (
                peer         varchar,
                pointsChange bigint
            ) as $$
begin
return query with p1 as (select peer1,
                                        sum(pointsAmount) as pa1
                                 from gettransferredpoints()
                                 group by peer1),
                          p2 as (select peer2,
                                        sum(pointsAmount) as pa2
                                 from getTransferredPoints()
                                 group by peer2)
select coalesce(p1.peer1, p2.peer2)              as peer,
       coalesce(p1.pa1, 0) - coalesce(p2.pa2, 0) as pointsChange
from p1
         full join p2 on p1.peer1 = p2.peer2
order by pointsChange desc;
end
$$ language plpgsql;

select * from getamountpoints2();

--==Part 3.6==--
create or replace function frequentlyCheckedTask()
    returns table
            (
                day  date,
                task varchar
            ) as $$
begin
return query with t1 as (select checks.task as t, checks.date as d, count(*) as counts
                                 from checks
                                 group by t, d),
                          t2 as (select t1.t, t1.d, rank() over (partition by t1.d order by t1.counts desc) as rank
                                 from t1)
select t2.d, t2.t
from t2
where rank = 1;
end
$$ language plpgsql;

select * from frequentlyCheckedTask();

--==Part 3.7==--
create or replace function getPeersCompleteBlock(needle varchar)
    returns table
            (
                Peer varchar,
                Day  date
            ) as $$
begin
return query with lastTaskBlock as (select max(title) as title
                                            from tasks
                                            where title similar to needle || '[0-9]%'),
                          successfulChecks as (select checks.peer,
                                                      checks.task,
                                                      checks.date
                                               from xp
                                                        join checks on xp.check_id = checks.id)
select sc.peer,
       sc.date
from successfulChecks sc
         join lastTaskBlock ltb on sc.task = ltb.title;
end
$$ language plpgsql;

select * from getPeersCompleteBlock('CPP');

--==Part 3.8==--
create or replace function getRecommendedPeers()
    returns table
            (
                Peer            varchar,
                RecommendedPeer varchar
            ) as $$
begin
return query with allFriends as (select *
                                         from (select distinct friends.peer1 as peer,
                                                               friends.peer2 as friend
                                               from friends
                                               union
                                               select friends.peer2,
                                                      friends.peer1
                                               from friends) t),
                          countRecommended as (select allFriends.peer,
                                                      count(recommendations.recommendedpeer) as rating,
                                                      recommendations.recommendedpeer
                                               from allFriends
                                                        join recommendations on allFriends.friend = recommendations.peer
                                               where allFriends.peer != recommendations.recommendedpeer
                                               group by allFriends.peer, recommendations.recommendedpeer),
                          findfavorite as (select countRecommended.peer, max(rating) as maxRating
                                           from countRecommended
                                           group by countRecommended.peer)
select countRecommended.peer as Peer, countRecommended.RecommendedPeer
from countRecommended
         join findfavorite on countRecommended.peer = findfavorite.peer and
                              countRecommended.rating = findfavorite.maxRating;
end
$$ language plpgsql;

select * from getRecommendedPeers();

--==Part 3.9==--
create or replace function getStatisticsAboutBeginTasks(block1 varchar, block2 varchar)
    returns table
            (
                StartedBlock1      bigint,
                StartedBlock2      bigint,
                StartedBothBlocks  bigint,
                DidntStartAnyBlock bigint
            ) as $$
begin
return query with startedBlock1 as (select distinct peer
                                            from checks
                                            where checks.task similar to block1 || '[0-9]%'),
                          startedBlock2 as (select distinct peer
                                            from checks
                                            where checks.task similar to block2 || '[0-9]%'),
                          startedBothBlocks as (select startedBlock1.peer
                                                FROM startedBlock1
                                                intersect
                                                select startedBlock2.peer
                                                from startedBlock2),
                          didntStartAnyBlock AS (select nickname as peer
                                                 from peers
                                                 except
                                                 (select peer
                                                  from startedBlock1
                                                  union
                                                  select peer
                                                  from startedBlock2)),
                          countPeers as (select count(nickname) from peers)
select (select count(peer) * 100 from startedBlock1) / (select * from countPeers),
       (select count(peer) * 100 from startedBlock2) / (select * from countPeers),
       (select count(peer) * 100 from startedBothBlocks) / (select * from countPeers),
       (select count(peer) * 100 from didntStartAnyBlock) / (select * from countPeers);
end
$$ language plpgsql;

select * from getStatisticsAboutBeginTasks('C', 'DO');

--==Part 3.10==--
create or replace function getSuccessfulUnsuccessfulChecksBirthday()
    returns table
            (
                SuccessfulChecks   bigint,
                UnsuccessfulChecks bigint
            ) as $$
begin
return query with getFormattedPeers as (select peers.nickname,
                                                       substr(birthday::text, 6) as part
                                                from peers),
                          getStatusChecks AS (select checks.peer,
                                                     date,
                                                     p2p.state    as pState,
                                                     verter.state as vState
                                              from checks
                                                       join p2p on checks.id = p2p.check_id
                                                       left join verter on checks.id = verter.check_id
                                              where p2p.state in ('Success', 'Failure')
                                                and (verter.state in ('Success', 'Failure') or verter.state is null)),
                          getAbobas as (select distinct *
                                        from getStatusChecks
                                                 join getFormattedPeers on date::text like '%' || part
                                        where getStatusChecks.peer = getFormattedPeers.nickname),
                          countSuccess as (select count(*) as successful
                                           from getAbobas
                                           where pState = 'Success'
                                             and (vState = 'Success' or vState is null)),
                          countUnsuccess as (select count(*) as unSuccessful
                                             from getAbobas
                                             where pState = 'Failure'
                                               and (vState = 'Failure' or vState is null)),
                          countPeers as (select count(nickname) from peers)
select (select successful * 100 from countSuccess) /
       (select * from countPeers),
       (select unSuccessful * 100 from countUnsuccess) /
       (select * from countPeers);
end
$$ language plpgsql;

select * from getSuccessfulUnsuccessfulChecksBirthday();

--==Part 3.11==--
create or replace function getPeersSuccessfullyCompleteTheseTwoTasks(task1 varchar, task2 varchar, task3 varchar)
    returns table
            (
                peer varchar
            ) as $$
begin
return query with task1 as (select checks.peer
                                    from getSuccessedTasks() as checks
                                    where checks.task like task1),
                          task2 as (select checks.peer
                                    from getSuccessedTasks() as checks
                                    where checks.task like task2),
                          task3 as (select checks.peer
                                    from getSuccessedTasks() as checks
                                    where checks.task not like task3),
                          result as (select task1.peer
                                     from task1
                                     intersect
                                     select task2.peer
                                     from task2
                                     intersect
                                     select task3.peer
                                     from task3)
select result.peer
from result;
end
$$ language plpgsql;

select * from getPeersSuccessfullyCompleteTheseTwoTasks('C7_SmartCalc_v1.0', 'C3_s21_stringplus', 'D01_Linux');

--==Part 3.12==--
create or replace procedure parents_count() as $$
begin
        create temporary table task_hierarchy_table (task varchar, prevcount integer);
with recursive task_hierarchy as (
    select title, parenttask, 0 as prevcount
    from tasks
    where parenttask is null
    union all
    select t.title, t.parenttask, th.prevcount + 1
    from tasks t
             join task_hierarchy th on t.parenttask = th.title
)
insert into task_hierarchy_table select title as task, prevcount
                                 from task_hierarchy;
end;
$$ language plpgsql;

----------test case----------
call parents_count();
select * from task_hierarchy_table;

--==Part 3.13==--
create or replace function getLuckyDays(N bigint)
    returns table
            (
                date date
            ) as $$
begin
return query with t as (select c.date,
                                       case
                                           when xp.id is null then null
                                           when xp.xpamount >= t2.maxxp * 0.8 then true
                                           else null
                                           end as t
                                from checks c
                                         left join xp on c.id = xp.check_id
                                         join tasks t2 on c.task = t2.title
                                group by c.date, xp.id, maxxp)
select t.date
from t
group by t.date
having count(t.date) >= N
   and count(t.t) = count(t.date);
end
$$ language plpgsql;

select * from getLuckyDays(4);

--==Part 3.14==--
create or replace function getTheBestPeer()
    returns table
            (
                Peer varchar,
                XP   bigint
            ) as $$
begin
return query select c.peer, sum(xpamount) xp
                     from xp
                              join checks c on c.id = xp.check_id
                     group by c.peer
                     order by xp desc
                     limit 1;
end
$$ language plpgsql;

select * from getthebestpeer();

--==Part 3.15==--
create or replace function getLark(t time, nt bigint)
    returns table
            (
                Peer varchar
            ) as $$
begin
return query with tt as (select tt.peer,
                                        count(tt.peer) as amount
                                 from timetracking tt
                                 where (time < t)
                                   and state = 1
                                 group by tt.peer)
select tt.peer
from tt
where amount >= nt;
end
$$ language plpgsql;

select * from getlark('14:00:00', 1);

--==Part 3.16==--
create or replace function getOwl(d integer, nt bigint)
    returns table
            (
                Peer varchar
            ) as $$
begin
return query with tt as (select tt.peer,
                                        count(tt.peer) as amount
                                 from timetracking tt
                                 where date > current_date - d
                                   and state = 2
                                 group by tt.peer)
select tt.peer
from tt
where amount >= nt;
end
$$ language plpgsql;

select * from getOwl(60, 2);


--==Part 3.17==--
create or replace function early_entry() returns table (month text, earlyentries numeric) as $$
begin
return query
    with peers_birth_to_int as  (select nickname, birthday, to_char(birthday, 'TMMonth') as month_of_birth from peers),
                 month_of_a_year as (select to_char(dd, 'mm') as id, to_char(moy.dd, 'TMMonth') as month from (select generate_series('2023-01-01'::timestamp, '2023-12-01'::timestamp, '1 month'::interval) dd) moy),
                 timetracking_till_afternoon as (select count(*), to_char(tg.date, 'TMMonth') as month, tg.peer from timetracking tg where tg.state = 1 and time < '12:00:00' group by 2, 3),
                 timetracking_month as (select count(*), to_char(tg.date, 'TMMonth') as month, peer from timetracking tg where tg.state = 1 group by 2, 3),
                 born_that_month as (select distinct moay.id, moay.month, tm.count, pbti.nickname  from peers_birth_to_int pbti
                                                                                                    left join month_of_a_year moay on pbti.month_of_birth = moay.month
                                                                                                    left join timetracking_month tm on pbti.month_of_birth = tm.month
                                                                                                   where pbti.nickname = tm.peer
                                                                                                   order by moay.id),
                 born_come_till_twelve as (select distinct moay.id, moay.month, tta.count, pbti.nickname from peers_birth_to_int pbti
                                                                                                            left join month_of_a_year moay on pbti.month_of_birth = moay.month
                                                                                                            left join timetracking_till_afternoon tta on pbti.month_of_birth = tta.month
                                                                                                         where pbti.nickname = tta.peer
                                                                                                         order by moay.id),
                 what_a_hell as (select btm.id, btm.month, sum(count) from born_that_month btm where btm.month in (select m1.month from month_of_a_year m1) group by 2, 1 order by btm.id),
                 dope as (select bctt.id, bctt.month, sum(count) from born_come_till_twelve bctt where bctt.month in (select m2.month from month_of_a_year m2) group by 2, 1 order by bctt.id)
select moay2.month, round(coalesce((100 / wah.sum * dp.sum), 0), 0) as earlyentries from month_of_a_year moay2 left join dope dp on moay2.id = dp.id left join what_a_hell wah on dp.id = wah.id;
end;
$$ language plpgsql;

----------test case----------
select * from early_entry();

-- Для пущей наглядности раскоментировать строки ниже и применить их
insert into peers
values ('asasinag', '1916-03-08'),
       ('krisdans', '1999-04-28'),
       ('nadinabr', '2005-04-01');
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-12', '06:20:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-12', '14:56:12', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-14', '07:34:08', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-15', '21:20:54', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-23', '12:20:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-23', '20:40:09', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-12', '06:20:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-12', '14:56:12', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-14', '07:34:08', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-15', '21:20:54', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-23', '12:20:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'myeshask', '2023-01-23', '20:40:09', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'asasinag', '2023-03-08', '06:06:06', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'asasinag', '2023-03-09', '21:21:21', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'asasinag', '2023-03-14', '23:43:35', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'asasinag', '2023-03-15', '18:17:16', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-03', '09:20:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-03', '20:40:09', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-05', '10:12:23', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-05', '20:22:39', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-24', '09:44:51', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'krisdans', '2023-04-24', '20:01:13', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'nadinabr', '2023-04-08', '07:17:59', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'nadinabr', '2023-04-08', '18:59:01', 2);
insert into timetracking values ((select max(id) from timetracking) + 1, 'nadinabr', '2023-04-16', '13:14:15', 1);
insert into timetracking values ((select max(id) from timetracking) + 1, 'nadinabr', '2023-04-16', '19:02:00', 2);
select * from early_entry();
