-- Trigger 1: Prevent over-capacity registrations
DELIMITER //
CREATE TRIGGER trg_registration_capacity
BEFORE INSERT ON registrations
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_capacity INT;
    DECLARE event_ended BOOLEAN;
    -- Check if event has ended
    SELECT end_datetime < NOW() INTO event_ended
    FROM events WHERE event_id = NEW.event_id;
    IF event_ended THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot register for past events';
    END IF;
    -- Get current registration count
    SELECT COUNT(*) INTO current_count
    FROM registrations
    WHERE event_id = NEW.event_id
    AND status = 'confirmed';
    -- Get event capacity
    SELECT capacity INTO max_capacity
    FROM events
    WHERE event_id = NEW.event_id;
    
    -- Apply business rules
    IF current_count >= max_capacity THEN
        SET NEW.status = 'waitlisted';
    END IF;
END;
//
DELIMITER ;
-- Trigger 2: Update waitlist when registrations change
DELIMITER //
CREATE TRIGGER trg_update_waitlist
AFTER UPDATE ON registrations
FOR EACH ROW
BEGIN
    IF OLD.status = 'confirmed' AND NEW.status = 'cancelled' THEN
        -- Find first waitlisted user for this event
        UPDATE registrations
        SET status = 'confirmed'
        WHERE registration_id = (
            SELECT registration_id
            FROM registrations
            WHERE event_id = NEW.event_id
            AND status = 'waitlisted'
            ORDER BY registration_time
            LIMIT 1
        );
    END IF;
END;
//
DELIMITER ;




-- Procedure 1: Send feedback reminders
DELIMITER //
CREATE PROCEDURE sp_send_feedback_reminders()
BEGIN
    SELECT u.email, e.title, e.end_datetime
    FROM events e
    JOIN registrations r ON e.event_id = r.event_id
    JOIN users u ON r.user_id = u.user_id
    WHERE e.end_datetime < NOW()  -- Completed events
    AND e.end_datetime > NOW() - INTERVAL 7 DAY  -- Within last week
    AND r.status = 'confirmed'  -- Only confirmed attendees
    AND NOT EXISTS (  -- No feedback submitted
        SELECT 1 FROM feedback f 
        WHERE f.event_id = e.event_id 
        AND f.user_id = u.user_id
    );
END;
//
DELIMITER ;

-- Procedure 2: Calculate event statistics
DELIMITER //
CREATE PROCEDURE sp_get_event_stats(IN event_id INT)
BEGIN
    SELECT 
        e.title,
        COUNT(DISTINCT r.user_id) AS total_attendees,
        COUNT(f.feedback_id) AS feedback_count,
        ROUND(AVG(f.rating), 1) AS avg_rating
    FROM events e
    LEFT JOIN registrations r ON e.event_id = r.event_id 
        AND r.status = 'confirmed'
    LEFT JOIN feedback f ON e.event_id = f.event_id
    WHERE e.event_id = event_id
    GROUP BY e.event_id;
END;
//
DELIMITER ;
  


  -- View 1: Public event listing
CREATE VIEW vw_public_events AS
SELECT 
    event_id,
    title,
    description,
    venue,
    DATE_FORMAT(start_datetime, '%a, %b %e %Y') AS event_date,
    TIME_FORMAT(start_datetime, '%h:%i %p') AS start_time,
    CONCAT(
        FLOOR(TIMESTAMPDIFF(HOUR, NOW(), start_datetime)/24), ' days ',
        MOD(TIMESTAMPDIFF(HOUR, NOW(), start_datetime), 24), ' hours'
    ) AS starts_in
FROM events
WHERE start_datetime > NOW()
ORDER BY start_datetime;

-- View 2: Event statistics dashboard
CREATE VIEW vw_event_stats AS
SELECT 
    e.event_id,
    e.title,
    DATE(e.start_datetime) AS event_date,
    COUNT(r.registration_id) AS total_registrations,
    SUM(CASE WHEN r.status = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_attendees,
    COUNT(f.feedback_id) AS feedback_count,
    ROUND(AVG(f.rating), 1) AS avg_rating,
    CASE 
        WHEN e.start_datetime > NOW() THEN 'Upcoming'
        WHEN e.end_datetime < NOW() THEN 'Completed'
        ELSE 'Ongoing'
    END AS status
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
LEFT JOIN feedback f ON e.event_id = f.event_id
GROUP BY e.event_id;
