DROP TABLE t_life_2017;
COMMIT;

CREATE TABLE t_life_2017
AS
     SELECT   a.f_ivk,
              a.f_modkod,
              a.f_erkezes,
              a.f_lezaras,
              a.f_kecs,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   afc.t_afc_wflog_lin2 b
                           WHERE   a.f_ivk = b.f_ivk
                                   AND afc.afc_wflog_intezkedes (b.f_ivkwfid,
                                                                 b.f_logid) LIKE
                                         '%Senior validálásra%')
                      OR (EXISTS
                             (SELECT   1
                                FROM   t_irat_tevlog t1
                               WHERE   t1.f_ivk = a.f_ivk
                                       AND f_alirattipusid IN
                                                (1921, 1926, 2027)))
                 THEN
                    1
                 ELSE
                    0
              END
                 AS Senior_kockelb,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
                 THEN
                    1
                 ELSE
                    0
              END
                 AS eunyil,
              SUM (b.f_int_end - b.f_int_begin) * 1440 AS ido_perc
       FROM   kontakt.t_ajanlat_attrib a, afc.t_afc_wflog_lin2 b
      WHERE       f_erkezes BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
              AND a.f_ivk = b.f_ivk
              AND f_termcsop = 'ÉLET'
              AND f_modkod NOT IN ('12701', '12702')
              AND f_lezaras IS NOT NULL
              AND f_kecs_pg = 'Feldolgozott'
              AND f_kecs <> 'Törölve'
   GROUP BY   a.f_ivk,
              a.f_modkod,
              a.f_erkezes,
              a.f_lezaras,
              a.f_kecs,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   afc.t_afc_wflog_lin2 b
                           WHERE   a.f_ivk = b.f_ivk
                                   AND afc.afc_wflog_intezkedes (b.f_ivkwfid,
                                                                 b.f_logid) LIKE
                                         '%Senior validálásra%')
                      OR (EXISTS
                             (SELECT   1
                                FROM   t_irat_tevlog t1
                               WHERE   t1.f_ivk = a.f_ivk
                                       AND f_alirattipusid IN
                                                (1921, 1926, 2027)))
                 THEN
                    1
                 ELSE
                    0
              END,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
                 THEN
                    1
                 ELSE
                    0
              END
   ORDER BY   a.f_ivk,
              a.f_modkod,
              a.f_erkezes,
              a.f_lezaras,
              a.f_kecs,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   afc.t_afc_wflog_lin2 b
                           WHERE   a.f_ivk = b.f_ivk
                                   AND afc.afc_wflog_intezkedes (b.f_ivkwfid,
                                                                 b.f_logid) LIKE
                                         '%Senior validálásra%')
                      OR (EXISTS
                             (SELECT   1
                                FROM   t_irat_tevlog t1
                               WHERE   t1.f_ivk = a.f_ivk
                                       AND f_alirattipusid IN
                                                (1921, 1926, 2027)))
                 THEN
                    1
                 ELSE
                    0
              END,
              CASE
                 WHEN EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
                 THEN
                    1
                 ELSE
                    0
              END;

COMMIT;
ALTER TABLE t_life_2017
ADD
(
alap_bo number,
kieg_es_cs char(2)
);
COMMIT;
DROP INDEX ivk;
COMMIT;

CREATE INDEX ivk
   ON t_life_2017 (f_ivk);

COMMIT;

UPDATE   t_life_2017 a
   SET   alap_bo =
            (SELECT   SUM (c.init_sum_insured)
               FROM   fproposal@dl_peep b, fcontract_coverage@dl_peep c
              WHERE       a.f_ivk = b.proposal_idntfr
                      AND b.contract_oid = c.contract_oid
                      AND c.cntry_flg = 'HU'
                      AND (c.main_coverage_flag = 'Y'
                           OR coverage_code = '13400C'));

COMMIT;

UPDATE   t_life_2017 a
   SET   kieg_es_cs = 'I'
 WHERE   NOT EXISTS
            (SELECT   1
               FROM   fproposal@dl_peep b, fcontract_coverage@dl_peep c
              WHERE   a.f_ivk = b.proposal_idntfr
                      AND b.contract_oid = c.contract_oid
                      AND coverage_code IN
                               ('13400C',
                                '13400G',
                                '13400Y',
                                '13400E',
                                '13400F',
                                '13400X',
                                '13400A',
                                '13400I',
                                '13400U',
                                '13400Z',
                                '13400Q',
                                '13400L',
                                '13400J',
                                '13400R',
                                '13400M',
                                '13400T',
                                '13400H',
                                '1340EH',
                                '1340DH'));
COMMIT;


ALTER TABLE t_life_2017
add
(szegmens varchar2(20),
szegmens_old varchar2(20));
COMMIT;

UPDATE t_life_2017 a
set szegmens_old =  'S1' where a.f_modkod IN ('13217', '13410', '13411', '13412');

UPDATE t_life_2017 a
set szegmens_old =  'S3' where a.senior_kockelb = 1;

UPDATE t_life_2017 a
set szegmens_old =  'S2' where  szegmens_old is null and f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407') and eunyil = 1;
COMMIT;


UPDATE t_life_2017 a
set szegmens =  'S1' where a.f_modkod IN ('13217', '13410', '13411', '13412')
                    or (f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407') and alap_bo <= 500000 and kieg_es_cs = 'I');

UPDATE t_life_2017 a
set szegmens =  'S3' where a.senior_kockelb = 1;

UPDATE t_life_2017 a
set szegmens =  'S2' where  szegmens is null and f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407') and eunyil = 1;
COMMIT;


ALTER TABLE t_life_2017
ADD
(
erk_szerz number);
COMMIT;


UPDATE   t_life_2017 a
   SET   erk_szerz =
            f_lezaras - f_erkezes - bnap_db@dl_peep (f_lezaras, f_erkezes);

COMMIT;