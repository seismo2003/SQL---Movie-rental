
/* Query 1 - query used for first insight */
WITH t1 AS(
  SELECT c.name Movie_Category, f.title Film_Title, COUNT(r.rental_id) Rental_Times
	FROM category c
	JOIN film_category fc
	ON c.category_id = fc.category_id
	JOIN film f
	ON fc.film_id = f.film_id
	JOIN inventory i
	ON i.film_id = f.film_id
	JOIN rental r
	ON r.inventory_id = i.inventory_id
	WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	GROUP BY 1, 2
  ORDER BY 1, 2)

SELECT Movie_Category, SUM(Rental_Times)
FROM t1
GROUP BY 1;

/* Query 2 - query used for second insight */
WITH t1 AS(
            SELECT c.name Movie_Category, f.title Film_Title, COUNT(r.rental_id) Rental_Times
          	FROM category c
          	JOIN film_category fc
          	ON c.category_id = fc.category_id
          	JOIN film f
          	ON fc.film_id = f.film_id
          	JOIN inventory i
          	ON i.film_id = f.film_id
          	JOIN rental r
          	ON r.inventory_id = i.inventory_id
          	WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
          	GROUP BY 1, 2
            ORDER BY 1, 2),
     t2 AS(
            SELECT t1.*, RANK() OVER (PARTITION BY Movie_Category ORDER BY rental_times DESC)
            FROM t1)

SELECT t2.*
FROM t2
WHERE rank IN ('1', '2', '3');

/* Query 3 - query used for third insight */
WITH t1 As( SELECT c.name Movie_Category, f.title Film_Title, r.rental_date, r.return_date
  FROM category c
  JOIN film_category fc
  ON c.category_id = fc.category_id
  JOIN film f
  ON fc.film_id = f.film_id
  JOIN inventory i
  ON i.film_id = f.film_id
  JOIN rental r
  ON r.inventory_id = i.inventory_id
  WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
  AND NOT return_date IS NULL
  ORDER BY 3
  ),

 t2 AS( SELECT t1.film_title, AVG(DATE_PART('day', t1.return_date - t1.rental_date)) rent_duration
  FROM t1
  GROUP BY 1),

t3 AS( SELECT t2.film_title, c.name, ROUND(t2.rent_duration) rent_duration, NTILE(4) OVER (ORDER BY t2.rent_duration) AS percentile
  FROM t2
  JOIN film f
  ON t2.film_title = f.title
  JOIN film_category fc
  ON fc.film_id = f.film_id
  JOIN category c
  ON c.category_id = fc.category_id
  ORDER BY 1)

SELECT t3.name, percentile, COUNT(*)
FROM t3
GROUP BY 1, 2
ORDER BY 1;

/* Query 4 - query used for fourth insight */
WITH t1 AS(
	    SELECT DATE_TRUNC('month', p.payment_date) pay_mon, CONCAT(c.first_name, ' ', c.last_name) fullname, COUNT(p.payment_id), SUM(p.amount)
		FROM customer c
		JOIN payment p
		ON c. customer_id = p.customer_id
		WHERE p.payment_date BETWEEN '2007-01-01' AND '2008-01-01'
		GROUP BY 1, 2
		ORDER BY 2),

     t2 AS(
		SELECT CONCAT(c.first_name, ' ', c.last_name) fullname, SUM(p.amount)
		FROM customer c
		JOIN payment p
		ON c. customer_id = p.customer_id
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 10
		 )

SELECT t1.*
FROM t1
JOIN t2
ON t1.fullname = t2.fullname
ORDER BY 2;
