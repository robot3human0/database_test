create database test;
-- drop database test;
----------Создаем таблицы----------
--==Peers table==--
create table if not exists Peers
(
    nickname varchar primary key,
    birthday date not null
);

--==Tasks table==--
create table if not exists Tasks
(
    title      varchar primary key default null,
    parentTask varchar, foreign key(parentTask) references Tasks (title),
    maxXP      integer not null
);

--==Статус проверки==--
create type status as enum ('Start', 'Success', 'Failure');

--==Checks table==--
create table if not exists Checks
(
    id   bigint primary key,
    peer varchar, foreign key(peer) references Peers (nickname),
    task varchar references Tasks (title),
    date date
);

--==P2P table==--
create table if not exists P2P
(
    id           bigint primary key,
    check_id     bigint, foreign key(check_id) references Checks (id),
    checkingPeer varchar, foreign key(checkingPeer) references Peers (nickname),
    state        status,
    time         time
);

--==Verter table==--
create table if not exists Verter
(
    id       bigint primary key,
    check_id bigint, foreign key(check_id) references Checks (id),
    state    status,
    time     time
);

--==TransferredPoints table==--
create table if not exists TransferredPoints
(
    id           bigint primary key,
    checkingPeer varchar, foreign key(checkingPeer) references Peers (nickname),
    checkedPeer  varchar, foreign key(checkedPeer) references Peers (nickname),
    pointsAmount integer
);

--==Friend table==--
create table if not exists Friends
(
    id    bigint primary key,
    peer1 varchar, foreign key(peer1) references Peers (nickname),
    peer2 varchar, foreign key(peer2) references Peers (nickname)
);

--==Recommendations table==--
create table if not exists Recommendations
(
    id              bigint primary key,
    peer            varchar, foreign key(peer) references Peers (nickname),
    recommendedPeer varchar, foreign key(recommendedPeer) references Peers (nickname)
);

--==XP table==--
create table if not exists XP
(
    id       bigint primary key,
    check_id bigint, foreign key(check_id) references Checks (id),
    xpAmount integer
);

--==TimeTracking==--
create table if not exists TimeTracking
(
    id    bigint primary key,
    peer  varchar, foreign key(peer) references Peers (nickname),
    date  date,
    time  time,
    state integer
);

----------Заполнение базы данных----------
--==Peers insert==--
insert into Peers
values('windhelg', '1994-11-30'),
      ('hirokose', '1993-11-06'),
      ('myeshask', '1988-01-04'),
      ('karleenk', '2002-05-11'),
      ('wendybor', '1994-05-05'),
      ('richesea', '2003-02-07'),
      ('flashern', '2000-10-14'),
      ('sherlynt', '1994-06-30'),
      ('lavondas', '1998-11-14'),
      ('flaviate', '1998-10-13'),
      ('pearlecr', '1962-12-24');

--==Task insert==--
insert into Tasks
values ('C2_SimpleBashUtils', null, 350),
       ('C3_s21_stringplus', 'C2_SimpleBashUtils', 700),
       ('C4_s21_math', 'C3_s21_stringplus', 300),
       ('C5_s21_decimal', 'C3_s21_stringplus', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 300),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix' ,650),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 1000),
       ('D01_Linux', 'C3_s21_stringplus', 300),
       ('DO2_LinuxNetwork', 'D01_Linux', 350),
       ('DO3_LinuxMonitoring_v1.0', 'DO2_LinuxNetwork', 350),
       ('DO4_LinuxMonitoring_v2.0','DO3_LinuxMonitoring_v1.0', 501),
       ('DO5_SimpleDocker' ,'DO3_LinuxMonitoring_v1.0', 300),
       ('DO6_CICD', 'DO5_SimpleDocker', 402),
       ('CPP1_s21_matrix+' , 'C8_3DViewer_v1.0', 300),
       ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
       ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 600),
       ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 750),
       ('CPP5_3DViewer_v2.1', 'CPP4_3DViewer_v2.0', 600),
       ('CPP6_3DViewer_v2.2', 'CPP4_3DViewer_v2.0', 800),
       ('CPP7_MLP', 'CPP4_3DViewer_v2.0', 700);

--==Friends insert==--
insert into Friends
values ('1', 'windhelg', 'myeshask'),
       ('2', 'karleenk', 'hirokose'),
       ('3', 'windhelg', 'wendybor'),
       ('4', 'karleenk', 'richesea'),
       ('5', 'myeshask', 'richesea'),
       ('6', 'sherlynt', 'flaviate'),
       ('7', 'flaviate', 'windhelg'),
       ('8', 'flaviate', 'myeshask'),
       ('9', 'flashern', 'lavondas'),
       ('10', 'wendybor', 'flashern'),
       ('11', 'lavondas', 'sherlynt'),
       ('12', 'hirokose', 'pearlecr');

--==Recommendations insert==--
insert into Recommendations
values ('1', 'myeshask', 'karleenk'),
       ('2', 'wendybor', 'myeshask'),
       ('3', 'karleenk', 'hirokose'),
       ('4', 'windhelg', 'wendybor'),
       ('5', 'hirokose', 'windhelg'),
       ('6', 'richesea', 'myeshask'),
       ('7', 'windhelg', 'lavondas'),
       ('8', 'lavondas', 'wendybor'),
       ('9', 'flashern', 'flaviate'),
       ('10', 'flaviate', 'pearlecr');

--==TimeTracking insert==--
insert into TimeTracking
values ('1', 'wendybor', '2023-02-12', '12:20:23', 1),
       ('2', 'wendybor', '2023-02-12', '14:56:12', 2),
       ('3', 'wendybor', '2023-02-12', '15:08:32', 1),
       ('4', 'wendybor', '2023-02-12', '21:20:54', 2),
       ('5', 'myeshask', '2023-02-12', '10:20:23', 1),
       ('6', 'myeshask', '2023-02-12', '20:40:09', 2),
       ('7', 'windhelg', '2023-01-04', '06:33:31', 1),
       ('8', 'windhelg', '2023-01-04', '14:03:18', 2),
       ('9', 'karleenk', '2023-01-04', '14:15:01', 1),
       ('10', 'karleenk', '2023-01-04', '14:16:22', 2),
       ('11', 'richesea', '2023-02-07', '08:48:47', 1),
       ('12', 'richesea', '2023-02-07', '21:21:41', 2),
       ('13', 'flashern', '2023-02-12', '02:00:18', 1),
       ('14', 'flashern', '2023-02-12', '08:00:00', 2),
       ('15', 'hirokose', '2023-02-13', '16:25:07', 1),
       ('16', 'hirokose', '2023-02-14', '07:25:07', 2),
       ('17', 'lavondas', '2023-03-22', '16:27:11', 1),
       ('18', 'lavondas', '2023-03-23', '07:32:31', 2),
       ('19', 'wendybor', '2023-03-23', '08:00:07', 1),
       ('20', 'wendybor', '2023-03-23', '16:00:14', 2),
       ('21', 'pearlecr', '2023-03-24', '08:01:01', 1),
       ('22', 'pearlecr', '2023-03-23', '15:57:44', 2),
       ('23', 'myeshask', '2023-04-23', '11:11:01', 1),
       ('24', 'myeshask', '2023-04-23', '14:08:01', 2),
       ('25', 'flaviate', '2023-04-23', '14:24:21', 1),
       ('26', 'flaviate', '2023-04-23', '18:44:57', 2),
       ('27', 'flaviate', '2023-05-18', '12:20:23', 1),
       ('28', 'flaviate', '2023-05-18', '14:56:12', 2),
       ('29', 'wendybor', '2023-05-17', '15:08:32', 1),
       ('30', 'wendybor', '2023-05-17', '21:20:54', 2),
       ('31', 'karleenk', '2023-05-19', '10:20:23', 1),
       ('32', 'karleenk', '2023-05-19', '20:40:09', 2),
       ('33', 'windhelg', '2023-05-27', '06:33:31', 1),
       ('34', 'windhelg', '2023-05-27', '14:03:18', 2),
       ('35', 'karleenk', '2023-05-29', '14:15:01', 1),
       ('36', 'karleenk', '2023-05-29', '14:16:22', 2),
       ('37', 'richesea', '2023-04-30', '08:48:47', 1),
       ('38', 'richesea', '2023-04-30', '21:21:41', 2),
       ('39', 'flashern', '2023-03-31', '02:00:18', 1),
       ('40', 'flashern', '2023-03-31', '08:00:00', 2),
       ('41', 'hirokose', '2023-04-20', '16:25:07', 1),
       ('42', 'hirokose', '2023-04-21', '07:25:07', 2),
       ('43', 'lavondas', '2023-01-15', '16:27:11', 1),
       ('44', 'lavondas', '2023-01-16', '07:32:31', 2),
       ('45', 'wendybor', '2023-02-07', '08:00:07', 1),
       ('46', 'wendybor', '2023-02-07', '16:00:14', 2),
       ('47', 'pearlecr', '2023-04-05', '08:01:01', 1),
       ('48', 'pearlecr', '2023-04-06', '15:57:44', 2),
       ('49', 'myeshask', '2023-05-05', '11:11:01', 1),
       ('50', 'myeshask', '2023-05-05', '14:08:01', 2),
       ('51', 'flaviate', '2023-01-02', '14:24:21', 1),
       ('52', 'flaviate', '2023-01-02', '18:44:57', 2);

--==Checks inserts==-
insert into Checks
values ('1', 'windhelg', 'C2_SimpleBashUtils', '2023-01-10'),
       ('2', 'windhelg', 'C3_s21_stringplus', '2023-02-05'),
       ('3', 'windhelg', 'C4_s21_math', '2023-02-21'),
       ('4', 'windhelg', 'C5_s21_decimal', '2023-03-06'),
       ('5', 'windhelg', 'C6_s21_matrix', '2023-03-30'),
       ('6', 'windhelg', 'C7_SmartCalc_v1.0', '2023-04-10'),
       ('7', 'windhelg', 'C8_3DViewer_v1.0', '2023-04-30'),

       ('8', 'myeshask', 'C2_SimpleBashUtils', '2023-01-04'),
       ('9', 'myeshask', 'C3_s21_stringplus', '2023-02-07'),
       ('10', 'myeshask', 'C4_s21_math', '2023-02-19'),
       ('11', 'myeshask', 'C5_s21_decimal', '2023-03-04'),
       ('12', 'myeshask', 'C6_s21_matrix', '2023-03-29'),
       ('13', 'myeshask', 'C7_SmartCalc_v1.0', '2023-04-10'),
       ('14', 'myeshask', 'C8_3DViewer_v1.0', '2023-04-30'),

       ('15', 'sherlynt', 'C2_SimpleBashUtils', '2023-01-09'),
       ('16', 'sherlynt', 'C3_s21_stringplus', '2023-02-04'),
       ('17', 'sherlynt', 'C4_s21_math', '2023-02-21'),
       ('18', 'sherlynt', 'C5_s21_decimal', '2023-03-05'),
       ('19', 'sherlynt', 'C6_s21_matrix', '2023-03-24'),
       ('20', 'sherlynt', 'C7_SmartCalc_v1.0', '2023-04-10'),
       ('21', 'sherlynt', 'C8_3DViewer_v1.0', '2023-04-30'),

       ('22', 'flaviate', 'C2_SimpleBashUtils', '2023-01-02'),
       ('23', 'flaviate', 'C3_s21_stringplus', '2023-02-01'),
       ('24', 'flaviate', 'C4_s21_math', '2023-02-11'),
       ('25', 'flaviate', 'C5_s21_decimal', '2023-03-01'),
       ('26', 'flaviate', 'C6_s21_matrix', '2023-03-13'),
       ('27', 'flaviate', 'C7_SmartCalc_v1.0', '2023-04-01'),
       ('28', 'flaviate', 'C8_3DViewer_v1.0', '2023-04-04'),

       ('29', 'lavondas', 'C2_SimpleBashUtils', '2023-01-05'),
       ('30', 'lavondas', 'C3_s21_stringplus', '2023-02-06'),
       ('31', 'lavondas', 'C4_s21_math', '2023-02-16'),
       ('32', 'lavondas', 'C5_s21_decimal', '2023-03-02'),

       ('33', 'flashern', 'C2_SimpleBashUtils', '2023-01-04'),
       ('34', 'flashern', 'C3_s21_stringplus', '2023-02-09'),
       ('35', 'flashern', 'C4_s21_math', '2023-02-11'),

       ('36', 'karleenk', 'C2_SimpleBashUtils', '2023-01-05'),
       ('37', 'karleenk', 'C3_s21_stringplus', '2023-02-04'),
       ('38', 'karleenk', 'C4_s21_math', '2023-02-15'),

       ('39', 'pearlecr', 'C2_SimpleBashUtils', '2023-01-05'),
       ('40', 'pearlecr', 'C3_s21_stringplus', '2023-02-04'),
       ('41', 'pearlecr', 'C4_s21_math', '2023-02-15'),

       ('42', 'hirokose', 'C2_SimpleBashUtils', '2023-01-05'),
       ('43', 'hirokose', 'C3_s21_stringplus', '2023-02-04'),
       ('44', 'hirokose', 'C4_s21_math', '2023-02-15');

--==P2P inserts==-
insert into P2P
values ('1', '1', 'sherlynt', 'Start', '10:43:28'),
       ('2', '1', 'sherlynt', 'Success', '14:12:45'),
       ('3', '2', 'myeshask', 'Start', '11:43:28'),
       ('4', '2', 'myeshask', 'Success', '12:12:45'),
       ('5', '3', 'flashern', 'Start', '12:43:28'),
       ('6', '3', 'flashern', 'Success', '15:12:45'),
       ('7', '4', 'flaviate', 'Start', '17:43:28'),
       ('8', '4', 'flaviate', 'Success', '18:12:45'),
       ('9', '5', 'lavondas', 'Start', '09:43:28'),
       ('10', '5', 'lavondas', 'Success', '10:12:45'),
       ('11', '6', 'sherlynt', 'Start', '17:43:28'),
       ('12', '6', 'sherlynt', 'Success', '21:12:45'),
       ('13', '7', 'flashern', 'Start', '10:43:28'),
       ('14', '7', 'flashern', 'Failure', '17:12:45'),

       ('15', '8', 'windhelg', 'Start', '10:43:28'),
       ('16', '8', 'windhelg', 'Success', '11:12:45'),
       ('17', '9', 'lavondas', 'Start', '13:43:28'),
       ('18', '9', 'lavondas', 'Success', '16:12:45'),
       ('19', '10', 'pearlecr', 'Start', '12:43:28'),
       ('20', '10', 'pearlecr', 'Success', '15:12:45'),
       ('21', '11', 'hirokose', 'Start', '11:43:28'),
       ('22', '11', 'hirokose', 'Success', '12:12:45'),
       ('23', '12', 'windhelg', 'Start', '16:43:28'),
       ('24', '12', 'windhelg', 'Success', '18:12:45'),
       ('25', '13', 'karleenk', 'Start', '21:43:28'),
       ('26', '13', 'karleenk', 'Success', '22:12:45'),
       ('27', '14', 'lavondas', 'Start', '04:43:28'),
       ('28', '14', 'lavondas', 'Failure', '07:12:45'),

       ('29', '15', 'myeshask', 'Start', '01:43:28'),
       ('30', '15', 'myeshask', 'Success', '02:12:45'),
       ('31', '16', 'wendybor', 'Start', '03:43:28'),
       ('32', '16', 'wendybor', 'Success', '04:12:45'),
       ('33', '17', 'hirokose', 'Start', '12:43:28'),
       ('34', '17', 'hirokose', 'Success', '15:12:45'),
       ('35', '18', 'richesea', 'Start', '14:43:28'),
       ('36', '18', 'richesea', 'Success', '15:12:45'),
       ('37', '19', 'richesea', 'Start', '09:43:28'),
       ('38', '19', 'richesea', 'Success', '11:12:45'),
       ('39', '20', 'flashern', 'Start', '17:43:28'),
       ('40', '20', 'flashern', 'Success', '22:12:45'),
       ('41', '21', 'flaviate', 'Start', '11:43:28'),
       ('42', '21', 'flaviate', 'Failure', '17:12:45'),

       ('43', '22', 'windhelg', 'Start', '04:22:11'),
       ('44', '22', 'windhelg', 'Success', '06:19:00'),
       ('45', '23', 'sherlynt', 'Start', '00:44:44'),
       ('46', '23', 'sherlynt', 'Success', '02:43:45'),
       ('47', '24', 'pearlecr', 'Start', '12:39:28'),
       ('48', '24', 'pearlecr', 'Success', '15:15:45'),
       ('49', '25', 'karleenk', 'Start', '11:00:03'),
       ('50', '25', 'karleenk', 'Success', '12:08:54'),
       ('51', '26', 'myeshask', 'Start', '19:54:33'),
       ('52', '26', 'myeshask', 'Success', '20:57:31'),
       ('53', '27', 'flashern', 'Start', '21:52:05'),
       ('54', '27', 'flashern', 'Success', '23:43:45'),
       ('55', '28', 'windhelg', 'Start', '03:00:00'),
       ('56', '28', 'windhelg', 'Success', '04:00:02'),

       ('57', '29', 'myeshask', 'Start', '06:33:50'),
       ('58', '29', 'myeshask', 'Success', '20:33:22'),
       ('59', '30', 'flashern', 'Start', '03:17:36'),
       ('60', '30', 'flashern', 'Success', '06:01:17'),
       ('61', '31', 'myeshask', 'Start', '04:31:48'),
       ('62', '31', 'myeshask', 'Success', '05:02:49'),
       ('63', '32', 'windhelg', 'Start', '06:35:36'),
       ('64', '32', 'windhelg', 'Success', '10:40:34'),

       ('65', '33', 'flaviate', 'Start', '06:33:50'),
       ('66', '33', 'flaviate', 'Success', '08:38:00'),
       ('67', '34', 'lavondas', 'Start', '15:04:55'),
       ('68', '34', 'lavondas', 'Success', '16:53:16'),
       ('69', '35', 'hirokose', 'Start', '22:56:03'),
       ('70', '35', 'hirokose', 'Success', '23:40:37'),

       ('71', '36', 'hirokose', 'Start', '19:04:00'),
       ('72', '36', 'hirokose', 'Success', '21:34:22'),
       ('73', '37', 'pearlecr', 'Start', '18:59:02'),
       ('74', '37', 'pearlecr', 'Success', '20:14:34'),
       ('75', '38', 'windhelg', 'Start', '20:33:55'),
       ('76', '38', 'windhelg', 'Failure', '21:11:00'),

       ('77', '39', 'sherlynt', 'Start', '12:34:16'),
       ('78', '39', 'sherlynt', 'Success', '20:07:21'),
       ('79', '40', 'myeshask', 'Start', '14:58:26'),
       ('80', '40', 'myeshask', 'Success', '17:54:10'),
       ('81', '41', 'wendybor', 'Start', '16:48:28'),
       ('82', '41', 'wendybor', 'Success', '21:06:59'),

       ('83', '42', 'richesea', 'Start', '03:36:57'),
       ('84', '42', 'richesea', 'Success', '04:46:10'),
       ('85', '43', 'wendybor', 'Start', '09:02:00'),
       ('86', '43', 'wendybor', 'Success', '11:46:18'),
       ('87', '44', 'windhelg', 'Start', '03:34:37'),
       ('88', '44', 'windhelg', 'Failure', '05:39:53');

--==Verter inserts==-
insert into Verter
values ('1', '1', 'Start', '14:12:45'),
       ('2', '1', 'Success', '14:15:45'),
       ('3', '2', 'Start', '12:12:45'),
       ('4', '2', 'Success', '12:16:45'),
       ('5', '3', 'Start', '15:12:45'),
       ('6', '3', 'Success', '15:14:45'),
       ('7', '4', 'Start', '18:12:45'),
       ('8', '4', 'Success', '18:13:45'),
       ('9', '5', 'Start', '10:12:45'),
       ('10', '5', 'Success', '10:19:45'),

       ('11', '8', 'Start', '11:12:45'),
       ('12', '8', 'Success', '11:14:48'),
       ('13', '9', 'Start', '16:12:45'),
       ('14', '9', 'Success', '16:15:45'),
       ('15', '10', 'Start', '15:12:45'),
       ('16', '10', 'Success', '15:13:39'),
       ('17', '11', 'Start', '12:12:28'),
       ('18', '11', 'Success', '12:14:45'),
       ('19', '12', 'Start', '18:12:28'),
       ('20', '12', 'Success', '18:17:45'),

       ('21', '15', 'Start', '02:12:28'),
       ('22', '15', 'Success', '02:16:31'),
       ('23', '16', 'Start', '04:12:28'),
       ('24', '16', 'Success', '04:13:45'),
       ('25', '17', 'Start', '15:12:28'),
       ('26', '17', 'Success', '15:15:45'),
       ('27', '18', 'Start', '15:12:28'),
       ('28', '18', 'Success', '15:13:45'),
       ('29', '19', 'Start', '11:14:28'),
       ('30', '19', 'Success', '11:20:00'),

       ('31', '22', 'Start', '06:19:11'),
       ('32', '22', 'Success', '06:20:00'),
       ('33', '23', 'Start', '02:43:44'),
       ('34', '23', 'Success', '02:44:45'),
       ('35', '24', 'Start', '15:39:28'),
       ('36', '24', 'Success', '15:41:45'),
       ('37', '25', 'Start', '12:08:03'),
       ('38', '25', 'Success', '12:10:54'),
       ('39', '26', 'Start', '20:57:33'),
       ('40', '26', 'Success', '21:00:31'),

       ('41', '29', 'Start', '20:33:50'),
       ('42', '29', 'Success', '20:35:22'),
       ('43', '30', 'Start', '06:02:36'),
       ('44', '30', 'Success', '06:03:17'),
       ('45', '31', 'Start', '05:02:48'),
       ('46', '31', 'Success', '05:05:49'),
       ('47', '32', 'Start', '10:40:36'),
       ('48', '32', 'Success', '10:42:34'),

       ('49', '33', 'Start', '08:38:50'),
       ('50', '33', 'Success', '08:40:00'),
       ('51', '34', 'Start', '16:53:55'),
       ('52', '34', 'Success', '16:55:16'),
       ('53', '35', 'Start', '23:40:03'),
       ('54', '35', 'Success', '23:43:37'),

       ('55', '36', 'Start', '21:34:22'),
       ('56', '36', 'Success', '21:37:22'),
       ('57', '37', 'Start', '20:15:02'),
       ('58', '37', 'Success', '20:17:34'),

       ('59', '39', 'Start', '20:08:16'),
       ('60', '39', 'Success', '20:10:21'),
       ('61', '40', 'Start', '17:54:26'),
       ('62', '40', 'Success', '17:55:10'),
       ('63', '41', 'Start', '21:07:28'),
       ('64', '41', 'Success', '21:11:59'),

       ('65', '42', 'Start', '04:46:57'),
       ('66', '42', 'Success', '04:48:10'),
       ('67', '43', 'Start', '11:47:00'),
       ('68', '43', 'Success', '11:50:18');

--==XP inserts==-
insert into XP
values('1', '1', '350'),
      ('2', '2', '700'),
      ('3', '3', '300'),
      ('4', '4', '300'),
      ('5', '5', '250'),
      ('6', '6', '500'),

      ('7', '8', '350'),
      ('8', '9', '700'),
      ('9', '10', '300'),
      ('10', '11', '300'),
      ('11', '12', '300'),
      ('12', '13', '600'),

      ('13', '15', '300'),
      ('14', '16', '700'),
      ('15', '17', '300'),
      ('16', '18', '300'),
      ('17', '19', '300'),
      ('18', '20', '600'),

      ('19', '22', '300'),
      ('20', '23', '700'),
      ('21', '24', '300'),
      ('22', '25', '300'),
      ('23', '26', '300'),
      ('24', '27', '650'),
      ('25', '28', '800'),

      ('26', '29', '350'),
      ('27', '30', '700'),
      ('28', '31', '300'),
      ('29', '32', '350'),

      ('30', '33', '350'),
      ('31', '34', '700'),
      ('32', '35', '300'),

      ('33', '36', '350'),
      ('34', '37', '600'),

      ('35', '39', '350'),
      ('36', '40', '600'),
      ('37', '41', '300'),

      ('38', '42', '350'),
      ('39', '43', '700');

--==TransferredPoints inserts==-
insert into TransferredPoints
values ('1', 'sherlynt', 'windhelg', '2'),
       ('2', 'myeshask', 'windhelg', '1'),
       ('3', 'flashern', 'windhelg', '2'),
       ('4', 'flaviate', 'windhelg', '1'),
       ('5', 'lavondas', 'windhelg', '1'),

       ('6', 'windhelg', 'myeshask', '2'),
       ('7', 'lavondas', 'myeshask', '2'),
       ('8', 'pearlecr', 'myeshask', '1'),
       ('9', 'hirokose', 'myeshask', '1'),
       ('10', 'karleenk', 'myeshask', '1'),

       ('11', 'myeshask', 'sherlynt', '1'),
       ('12', 'wendybor', 'sherlynt', '1'),
       ('13', 'hirokose', 'sherlynt', '1'),
       ('14', 'richesea', 'sherlynt', '2'),
       ('15', 'flashern', 'sherlynt', '1'),
       ('16', 'flaviate', 'sherlynt', '1'),

       ('17', 'windhelg', 'flaviate', '2'),
       ('18', 'sherlynt', 'flaviate', '1'),
       ('19', 'pearlecr', 'flaviate', '1'),
       ('20', 'karleenk', 'flaviate', '1'),
       ('21', 'myeshask', 'flaviate', '1'),
       ('22', 'flashern', 'flaviate', '1'),

       ('23', 'myeshask', 'lavondas', '2'),
       ('24', 'flashern', 'lavondas', '1'),
       ('25', 'windhelg', 'lavondas', '1'),

       ('26', 'flaviate', 'flashern', '1'),
       ('27', 'lavondas', 'flashern', '1'),
       ('28', 'hirokose', 'flashern', '1'),

       ('29', 'hirokose', 'karleenk', '1'),
       ('30', 'pearlecr', 'karleenk', '1'),
       ('31', 'windhelg', 'karleenk', '1'),

       ('32', 'sherlynt', 'pearlecr', '1'),
       ('33', 'myeshask', 'pearlecr', '1'),
       ('34', 'wendybor', 'pearlecr', '1'),

       ('35', 'richesea', 'hirokose', '1'),
       ('36', 'wendybor', 'hirokose', '1'),
       ('37', 'windhelg', 'hirokose', '1');

----------Создание процедур----------
--==export_data procedure==--
-- call export_data('transferredpoints', '/Users/myeshask/Desktop/', '|');
create or replace procedure export_data(table_name varchar, file_path varchar, delimiter char(1))
AS
$$
DECLARE
    file_path_regex text := E'^\/[a-zA-Z0-9_-]+.+\/$';
BEGIN
    IF
            file_path !~ file_path_regex
    THEN
        RAISE EXCEPTION 'Invalid data file_path (% doesn''t match %)', file_path, file_path_regex;
    END IF;
    EXECUTE '
				COPY
					' || quote_ident(table_name) || '
				TO
					' || quote_literal(file_path || table_name || '.csv') || '
                WITH (
					DELIMITER ' || quote_literal(delimiter) || '
				,FORMAT CSV, HEADER);
			';
END;
$$
    language plpgsql;

--==import_data procedure==--
-- call import_data('transferredpoints', '/Users/myeshask/Desktop/transferredpoints.csv', '|');
create or replace procedure import_data(table_name varchar, file_path varchar, delimiter char(1))
AS
$$
DECLARE
    file_path_regex text := E'^\/[a-zA-Z0-9_-]+.+\.csv$';
BEGIN
    IF
            file_path !~ file_path_regex
    THEN
        RAISE EXCEPTION 'Invalid data file_path (% doesn''t match %)', file_path, file_path_regex;
    END IF;
    EXECUTE '
				COPY
					' || quote_ident(table_name) || '
				FROM
					' || quote_literal(file_path) || '
                WITH (
					DELIMITER ' || quote_literal(delimiter) || '
				,FORMAT CSV, HEADER);
			';
END;
$$
    language plpgsql;
