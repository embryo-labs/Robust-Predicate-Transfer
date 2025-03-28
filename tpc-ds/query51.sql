WITH web_v1 AS 
( 
         SELECT   ws_item_sk item_sk,
                  d_date,
                  sum(Sum(ws_sales_price)) OVER (partition BY ws_item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND CURRENT row) AS cume_sales
         FROM     ws,
                  d
         WHERE    ws_sold_date_sk = d_date_sk
         AND      d_month_seq BETWEEN 1192 AND 1192 + 11
         AND      ws_item_sk IS NOT NULL
         GROUP BY ws_item_sk,
                  d_date), store_v1 AS
( 
         SELECT   ss_item_sk item_sk, 
                  d_date, 
                  sum(sum(ss_sales_price)) OVER (partition BY ss_item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND CURRENT row) AS cume_sales
         FROM     ss, 
                  d
         WHERE    ss_sold_date_sk = d_date_sk 
         AND      d_month_seq BETWEEN 1192 AND 1192 + 11 
         AND      ss_item_sk IS NOT NULL 
         GROUP BY ss_item_sk, 
                  d_date) 
SELECT 
         * 
FROM     ( 
                  SELECT   item_sk, 
                           d_date, 
                           web_sales, 
                           store_sales, 
                           max(web_sales) OVER (partition BY item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND CURRENT row) AS web_cumulative ,
                           max(store_sales) OVER (partition BY item_sk ORDER BY d_date rows BETWEEN UNBOUNDED PRECEDING AND CURRENT row) AS store_cumulative
                  FROM     ( 
                                           SELECT 
                                                           CASE 
                                                                           WHEN web.item_sk IS NOT NULL THEN web.item_sk
                                                                           ELSE store.item_sk 
                                                           END item_sk , 
                                                           CASE 
                                                                           WHEN web.d_date IS NOT NULL THEN web.d_date
                                                                           ELSE store.d_date 
                                                           END              d_date , 
                                                           web.cume_sales   web_sales , 
                                                           store.cume_sales store_sales 
                                           FROM            web_v1 web 
                                           FULL OUTER JOIN store_v1 store 
                                           ON              ( 
                                                                           web.item_sk = store.item_sk
                                                           AND             web.d_date = store.d_date) )x )y
WHERE    web_cumulative > store_cumulative 
ORDER BY item_sk , 
         d_date 
LIMIT 100; 
