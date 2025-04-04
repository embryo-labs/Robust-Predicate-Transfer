WITH cross_items AS (
       SELECT i_item_sk AS ss_item_sk 
       FROM i, (SELECT iss.i_brand_id AS brand_id, iss.i_class_id AS class_id, iss.i_category_id AS category_id 
                FROM ss, iss, d1 
                WHERE ss_item_sk = iss.i_item_sk AND ss_sold_date_sk = d1.d_date_sk AND d1.d_year BETWEEN 1999 AND 1999 + 2 
               INTERSECT 
                SELECT ics.i_brand_id, ics.i_class_id, ics.i_category_id 
                FROM cs, ics, d2 
                WHERE cs_item_sk = ics.i_item_sk 
                      AND cs_sold_date_sk = d2.d_date_sk 
                      AND d2.d_year BETWEEN 1999 AND 1999 + 2 
               INTERSECT 
                SELECT iws.i_brand_id, iws.i_class_id, iws.i_category_id 
                FROM ws, iws, d3 
                WHERE ws_item_sk = iws.i_item_sk 
                      AND ws_sold_date_sk = d3.d_date_sk 
                      AND d3.d_year BETWEEN 1999 AND 1999 + 2) 
       WHERE  i_brand_id = brand_id AND i_class_id = class_id AND i_category_id = category_id), 
     avg_sales AS (
       SELECT Avg(quantity * list_price) AS average_sales 
       FROM (SELECT ss_quantity AS quantity, ss_list_price AS list_price 
             FROM ss, d 
             WHERE ss_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2 
            UNION ALL 
             SELECT cs_quantity AS quantity, cs_list_price AS list_price 
             FROM cs, d 
             WHERE cs_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2 
            UNION ALL 
             SELECT ws_quantity AS quantity, ws_list_price AS list_price 
             FROM ws, d 
             WHERE ws_sold_date_sk = d_date_sk AND d_year BETWEEN 1999 AND 1999 + 2) x) 
SELECT channel, i_brand_id, i_class_id, i_category_id, Sum(sales), Sum(number_sales) 
FROM  (SELECT 'store' AS channel, i_brand_id, i_class_id, i_category_id, Sum(ss_quantity * ss_list_price) sales, Count(*) AS number_sales 
       FROM ss, i, d 
       WHERE ss_item_sk IN (SELECT ss_item_sk FROM cross_items) 
             AND ss_item_sk = i_item_sk 
             AND ss_sold_date_sk = d_date_sk 
             AND d_year = 1999 + 2 
             AND d_moy = 11 
       GROUP BY i_brand_id, 
                i_class_id, 
                i_category_id 
       HAVING Sum(ss_quantity * ss_list_price) > (SELECT average_sales FROM avg_sales) 
      UNION ALL 
       SELECT 'catalog' AS channel, i_brand_id, i_class_id, i_category_id, Sum(cs_quantity * cs_list_price) sales, Count(*) AS number_sales 
       FROM cs, i, d 
       WHERE cs_item_sk IN (SELECT ss_item_sk FROM cross_items) 
             AND cs_item_sk = i_item_sk 
             AND cs_sold_date_sk = d_date_sk 
             AND d_year = 1999 + 2 
             AND d_moy = 11 
       GROUP BY i_brand_id, i_class_id, i_category_id 
       HAVING Sum(cs_quantity * cs_list_price) > (SELECT average_sales FROM avg_sales) 
      UNION ALL 
       SELECT 'web' AS channel, i_brand_id, i_class_id, i_category_id, Sum(ws_quantity * ws_list_price) AS sales, Count(*) AS number_sales 
       FROM ws, i, d 
       WHERE ws_item_sk IN (SELECT ss_item_sk FROM cross_items) 
             AND ws_item_sk = i_item_sk 
             AND ws_sold_date_sk = d_date_sk 
             AND d_year = 1999 + 2 
             AND d_moy = 11 
       GROUP BY i_brand_id, i_class_id, i_category_id 
       HAVING Sum(ws_quantity * ws_list_price) > (SELECT average_sales FROM avg_sales)) y 
GROUP BY rollup ( channel, i_brand_id, i_class_id, i_category_id ) 
ORDER BY channel, i_brand_id, i_class_id, i_category_id 
LIMIT 100; 
