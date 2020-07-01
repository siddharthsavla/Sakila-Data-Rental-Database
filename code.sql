Question 1 :What is distribution of rentals for different family movie categories?

/*Query 1 */
SELECT f.title,c.name,COUNT(r.rental_id) as rental_count
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON c.category_id = fc.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation','Children','Comedy','Classics','Family','Music')
GROUP BY 1,2
ORDER BY 2

Question 2: What is the average rental duration of different family-friendly movie categories ?

/*Query 2 */
SELECT f.title,c.name,f.rental_duration,
       NTILE(4) OVER (PARTITION  BY f.title ORDER BY f.rental_duration) AS standard_quartile
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id 
JOIN category c
ON c.category_id = fc.category_id 
WHERE c.name IN ('Animation','Children','Comedy','Classics','Family','Music')
GROUP BY 1,2,3
ORDER BY 3 

Question 3: What is the percentage of total payments made for the top five categories compared to the rest?

/*Query 3 */
WITH totalshare AS
				(SELECT c.name category, sum(amount) total_amount
				 FROM category c
				 JOIN film_category fc
				 ON c.category_id=fc.category_id
				 JOIN film f
				 ON f.film_id=fc.film_id
				 JOIN inventory i
				 ON i.film_id=f.film_id
				 JOIN rental r
				 ON r.inventory_id=i.inventory_id
				 JOIN payment p
				 ON p.rental_id=r.rental_id
				 GROUP BY 1
				 ORDER BY 2 DESC),

	topfiveshare AS (SELECT * FROM totalshare LIMIT 5),

	subquery AS (SELECT CASE WHEN totalshare.category=topfiveshare.category
				   				THEN 'TOP FIVE PAID CATEGORIES'
				   				ELSE 'OTHER CATEGORIES'
				   				END categories,
				   		SUM(totalshare.total_amount) total
					FROM totalshare
					LEFT JOIN topfiveshare
					ON totalshare.category=topfiveshare.category
					GROUP BY 1
					ORDER BY 2)
SELECT categories, ROUND(total/SUM(total) OVER(),2) Percentage
FROM subquery

Question 4: Who where the top 10 paying customers and what was the amount of monthly payments made in year 2007?

/* Query 4 */

SELECT DATE_TRUNC('month', p.payment_date) pay_month, c.first_name || ' ' || c.last_name AS full_name, COUNT(p.amount) AS pay_countpermon, SUM(p.amount) AS pay_amount
 FROM customer c
  JOIN payment p
  ON p.customer_id = c.customer_id
WHERE c.first_name || ' ' || c.last_name IN
 (SELECT t1.full_name
   FROM
 (SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.amount) as amount_total
   FROM customer c
    JOIN payment p
     ON p.customer_id = c.customer_id
  GROUP BY 1	
  ORDER BY 2 DESC
  LIMIT 10) t1) 
  AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
GROUP BY 2, 1
ORDER BY 2, 1, 3
