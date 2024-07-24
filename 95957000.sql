
	
	
WITH cte AS (
	SELECT * FROM public."Order000001"
	WHERE time <= 95957000
			 ),

 cte1 AS (
	SELECT bid_order, SUM(trade_volume) AS sumbid FROM public."Transaction000001"
	WHERE time <= 95957000
	AND function_code <> 67
	GROUP BY bid_order
	),

 cte2 AS (
	SELECT ask_order, SUM(trade_volume) AS sumask FROM public."Transaction000001"
	WHERE time <= 95957000
	AND function_code <> 67
	GROUP BY ask_order
)


SELECT function_code, order_price, cte.order, order_volume, sumbid, sumask FROM cte
	LEFT JOIN cte1 ON bid_order = cte.order AND sumbid <> order_volume
	LEFT JOIN cte2 ON ask_order = cte.order AND sumask <> order_volume
	WHERE sumask IS NOT NULL OR sumbid IS NOT NULL


-- 95957000前所有未全部交易且未被撤销的订单
	SELECT function_code, order_price, cte.order, order_volume, sumbid, sumask,
	(CASE WHEN sumbid IS NULL THEN order_volume - sumask ELSE order_volume - sumbid END) AS leftover
	FROM cte
	LEFT JOIN cte1 ON bid_order = cte.order AND sumbid <> order_volume
	LEFT JOIN cte2 ON ask_order = cte.order AND sumask <> order_volume
	WHERE cte.order NOT IN 
	(SELECT ask_order FROM public."Transaction000001"
	WHERE time <= 95957000
	AND function_code = 67) 
	AND 
	cte.order NOT IN (SELECT bid_order FROM public."Transaction000001"
	WHERE time <= 95957000
	AND function_code = 67) 
	AND (sumask IS NOT NULL OR sumbid IS NOT NULL)


-- 




-- 95957000前 Level 1 所有新生成 Bid Order Queue
SELECT function_code, order_price, order_volume, cte.order, time FROM cte 
WHERE order_price = 112600 AND function_code = 66 AND cte.order NOT IN (
	SELECT ask_order FROM public."Transaction000001"
WHERE time <= 95957000
	) AND  cte.order NOT IN (
	SELECT bid_order FROM public."Transaction000001"
WHERE time <= 95957000
	) 
	ORDER BY time;


*/


-- 95957000前 Level 1 所有新生成 Bid Order 数量
SELECT function_code, order_price, COUNT(cte.order_volume) FROM cte 
WHERE cte.order NOT IN (
	SELECT ask_order FROM public."Transaction000001"
WHERE time <= 95957000
	) AND  cte.order NOT IN (
	SELECT bid_order FROM public."Transaction000001"
WHERE time <= 95957000
	) 
	GROUP BY function_code, order_price
	ORDER BY order_price, function_code
