SELECT   a.f_ivk,
           a.f_modkod,
           a.f_erkezes,
           a.f_lezaras,
           a.f_kecs,
           CASE
              WHEN f_modkod IN ('13217', '13410', '13411', '13412')
              THEN
                 'Easy_nincseü'
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
                                    AND f_alirattipusid IN (1921, 1926, 2027)))
              THEN
                 'Hard_senior'
              WHEN f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407')
                   AND EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
              THEN
                 'Middle_negeü_nyug'
           END
              AS Szegmens,
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
              WHEN f_modkod IN ('13217', '13410', '13411', '13412')
              THEN
                 'Easy_nincseü'
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
                                    AND f_alirattipusid IN (1921, 1926, 2027)))
              THEN
                 'Hard_senior'
              WHEN f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407')
                   AND EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
              THEN
                 'Middle_negeü_nyug'
           END
ORDER BY   a.f_ivk,
           a.f_modkod,
           a.f_erkezes,
           a.f_lezaras,
           a.f_kecs,
           CASE
              WHEN f_modkod IN ('13217', '13410', '13411', '13412')
              THEN
                 'Easy_nincseü'
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
                                    AND f_alirattipusid IN (1921, 1926, 2027)))
              THEN
                 'Hard_senior'
              WHEN f_modkod IN
                         ('13401',
                          '13402',
                          '13408',
                          '13409',
                          '13403',
                          '13404',
                          '13405',
                          '13406',
                          '13407')
                   AND EXISTS
                         (SELECT   1
                            FROM   fproposal@dl_peep x
                           WHERE   a.f_ivk = x.proposal_idntfr
                                   AND x.medical_reception = 'N')
              THEN
                 'Middle_negeü_nyug'
           END
           
           