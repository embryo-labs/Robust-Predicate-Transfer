SELECT 'web' AS channel, web.item, web.return_ratio, web.return_rank, web.currency_rank 
FROM (SELECT item, return_ratio, currency_ratio, Rank() OVER (ORDER BY return_ratio) AS return_rank, Rank() OVER (ORDER BY currency_ratio) AS currency_rank
      FROM (SELECT ws.ws_item_sk AS item, (Cast(Sum(COALESCE(wr.wr_return_quantity, 0)) AS DEC(15, 4)) / Cast(Sum(COALESCE(ws.ws_quantity, 0)) AS DEC(15, 4))) AS return_ratio, (Cast(Sum(COALESCE(wr.wr_return_amt, 0)) AS DEC(15, 4)) / Cast(Sum(COALESCE(ws.ws_net_paid, 0)) AS DEC(15, 4))) AS currency_ratio 
            FROM ws LEFT OUTER JOIN wr ON (ws.ws_order_number = wr.wr_order_number AND ws.ws_item_sk = wr.wr_item_sk), d 
            WHERE wr.wr_return_amt > 10000 
                  AND ws.ws_net_profit > 1 
                  AND ws.ws_net_paid > 0 
                  AND ws.ws_quantity > 0 
                  AND ws_sold_date_sk = d_date_sk 
                  AND d_year = 1999 
                  AND d_moy = 12 
            GROUP  BY ws.ws_item_sk) in_web) web 
WHERE (web.return_rank <= 10 OR web.currency_rank <= 10) 
UNION 
SELECT 'catalog' AS channel, catalog.item, catalog.return_ratio, catalog.return_rank, catalog.currency_rank 
FROM (SELECT item, return_ratio, currency_ratio, Rank() OVER (ORDER BY return_ratio) AS return_rank, Rank() OVER (ORDER BY currency_ratio) AS currency_rank 
      FROM (SELECT cs.cs_item_sk AS item, (Cast(Sum(COALESCE(cr.cr_return_quantity, 0)) AS DEC(15,4)) / Cast(Sum(COALESCE(cs.cs_quantity, 0)) AS DEC(15, 4))) AS return_ratio, (Cast(Sum(COALESCE(cr.cr_return_amount, 0)) AS DEC(15, 4)) / Cast(Sum(COALESCE(cs.cs_net_paid, 0)) AS DEC(15, 4))) AS currency_ratio 
            FROM cs LEFT OUTER JOIN cr ON (cs.cs_order_number = cr.cr_order_number AND cs.cs_item_sk = cr.cr_item_sk), d 
            WHERE cr.cr_return_amount > 10000 
                  AND cs.cs_net_profit > 1 
                  AND cs.cs_net_paid > 0 
                  AND cs.cs_quantity > 0 
                  AND cs_sold_date_sk = d_date_sk 
                  AND d_year = 1999 
                  AND d_moy = 12 
            GROUP BY cs.cs_item_sk) in_cat) catalog 
WHERE (catalog.return_rank <= 10 OR catalog.currency_rank <= 10) 
UNION 
SELECT 'store' AS channel, store.item, store.return_ratio, store.return_rank, store.currency_rank 
FROM (SELECT item, return_ratio, currency_ratio, Rank() OVER (ORDER BY return_ratio)   AS return_rank, Rank() OVER (ORDER BY currency_ratio) AS currency_rank 
      FROM (SELECT sts.ss_item_sk AS item, (Cast(Sum(COALESCE(sr.sr_return_quantity, 0)) AS DEC(15, 4)) / Cast(Sum(COALESCE(sts.ss_quantity, 0)) AS DEC(15, 4))) AS return_ratio, (Cast(Sum(COALESCE(sr.sr_return_amt, 0)) AS DEC(15, 4)) / Cast(Sum(COALESCE(sts.ss_net_paid, 0)) AS DEC(15, 4))) AS currency_ratio 
            FROM sts LEFT OUTER JOIN sr ON (sts.ss_ticket_number = sr.sr_ticket_number AND sts.ss_item_sk = sr.sr_item_sk), d 
            WHERE sr.sr_return_amt > 10000 
                  AND sts.ss_net_profit > 1 
                  AND sts.ss_net_paid > 0 
                  AND sts.ss_quantity > 0 
                  AND ss_sold_date_sk = d_date_sk 
                  AND d_year = 1999 
                  AND d_moy = 12 
            GROUP  BY sts.ss_item_sk) in_store) store 
WHERE (store.return_rank <= 10 OR store.currency_rank <= 10) 
ORDER BY 1, 4, 5
LIMIT 100; 
