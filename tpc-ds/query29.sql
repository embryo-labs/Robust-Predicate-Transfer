SELECT i_item_id,
       i_item_desc,
       s_store_id,
       s_store_name,
       Avg(ss_quantity) AS store_sales_quantity,
       Avg(sr_return_quantity) AS store_returns_quantity,
       Avg(cs_quantity) AS catalog_sales_quantity 
FROM ss, sr, cs, d1, d2, d3, s, i 
WHERE d1.d_moy = 4 
      AND d1.d_year = 1998 
      AND d1.d_date_sk = ss_sold_date_sk 
      AND i_item_sk = ss_item_sk 
      AND s_store_sk = ss_store_sk 
      AND ss_customer_sk = sr_customer_sk 
      AND ss_item_sk = sr_item_sk 
      AND ss_ticket_number = sr_ticket_number 
      AND sr_returned_date_sk = d2.d_date_sk 
      AND d2.d_moy BETWEEN 4 AND 4 + 3 
      AND d2.d_year = 1998 
      AND sr_customer_sk = cs_bill_customer_sk 
      AND sr_item_sk = cs_item_sk 
      AND cs_sold_date_sk = d3.d_date_sk 
      AND d3.d_year IN (1998, 1998 + 1, 1998 + 2) 
GROUP  BY i_item_id, i_item_desc, s_store_id, s_store_name 
ORDER  BY i_item_id, i_item_desc, s_store_id, s_store_name
LIMIT 100; 
