-- Get feedback reminders
CALL sp_send_feedback_reminders();

-- Get stats for event 5
CALL sp_get_event_stats(5);


-- Try to register for full event
INSERT INTO registrations (user_id, event_id)
VALUES (1, 6);  -- Will be waitlisted

-- Cancel a registration (triggers waitlist promotion)
UPDATE registrations
SET status = 'cancelled'
WHERE user_id = 3 AND event_id = 6;


-- Public event listing
SELECT * FROM vw_public_events 
WHERE venue LIKE '%Lab%';

-- Event statistics
SELECT * FROM vw_event_stats
WHERE status = 'Completed';