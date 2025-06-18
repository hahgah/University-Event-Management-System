 --Event Status Tracking:
SELECT event_id, title, venue, 
       DATE_FORMAT(start_datetime, '%W, %e %b %Y %h:%i %p') AS event_date,
       CASE
           WHEN start_datetime > NOW() THEN 'Upcoming'
           WHEN end_datetime < NOW() THEN 'Completed'
           ELSE 'Ongoing'
       END AS status
FROM events
WHERE start_datetime > NOW()
ORDER BY start_datetime;

--Upcoming Events (Excluding Past/Ongoing):
SELECT event_id, title, venue, 
       DATE_FORMAT(start_datetime, '%a, %e %b %Y %h:%i %p') AS event_time
FROM events
WHERE start_datetime > NOW();

--Feedback for Completed Events:
SELECT e.title, 
       ROUND(AVG(f.rating),1) AS avg_rating,
       COUNT(f.feedback_id) AS responses
FROM events e
JOIN feedback f ON e.event_id = f.event_id
WHERE e.end_datetime < NOW()
GROUP BY e.event_id;

--Registration Management (Ongoing Event):
SELECT 
    e.title,
    u.name,
    r.status,
    CASE 
        WHEN e.start_datetime <= NOW() AND e.end_datetime >= NOW() THEN 'Ongoing'
        ELSE 'Not Active'
    END AS event_status
FROM registrations r
JOIN events e ON r.event_id = e.event_id
JOIN users u ON r.user_id = u.user_id
WHERE e.title = 'Live Coding Workshop';

--Feedback Statistics:
SELECT e.title, COUNT(f.feedback_id) AS responses, ROUND(AVG(f.rating), 1) AS avg_rating, CONCAT(ROUND(SUM(CASE WHEN f.rating >= 4 THEN 1 ELSE 0 END) / COUNT(*) * 100), '%') AS satisfaction FROM events e LEFT JOIN feedback f ON e.event_id = f.event_id WHERE e.end_datetime < NOW() GROUP BY e.event_id;
