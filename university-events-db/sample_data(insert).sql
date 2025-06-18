-- Users
INSERT INTO users (name, email, role) VALUES
('Ali Ahmed', 'ali.ahmed@university.edu', 'student'),
('Fatima Khan', 'fatima.khan@university.edu', 'student'),
('Dr. Saeed Mahmood', 's.mahmood@university.edu', 'staff'),
('Zainab Hassan', 'z.hassan@university.edu', 'admin'),
('Omar Farooq', 'omar.f@university.edu', 'student');

-- Events (Mixed Status)
INSERT INTO events (title, description, venue, start_datetime, end_datetime, capacity, organizer_id) VALUES
('Tech Symposium', 'Annual tech conference', 'Main Auditorium', '2025-07-15 09:00:00', '2025-07-15 17:00:00', 200, 4),
('Career Workshop', 'Resume building', 'Room B-205', '2025-06-18 13:00:00', '2025-06-18 15:00:00', 50, 3),
('AI Hackathon', '24-hour competition', 'CS Department Lab', '2025-08-10 10:00:00', '2025-08-11 10:00:00', 100, 4),
('Alumni Meetup', 'Networking event', 'Garden Cafe', '2025-07-01 18:00:00', '2025-07-01 21:00:00', 80, 4),
('Database Bootcamp', 'SQL training', 'Room A-101', '2025-06-17 10:00:00', '2025-06-17 12:00:00', 30, 3);

-- Registrations
INSERT INTO registrations (user_id, event_id, status) VALUES
(1, 1, 'confirmed'),
(1, 2, 'confirmed'),
(2, 1, 'confirmed'),
(3, 3, 'confirmed'),
(5, 5, 'confirmed'),
(2, 5, 'waitlisted'),
(1, 5, 'waitlisted');

-- Feedback
INSERT INTO feedback (event_id, user_id, rating, comment) VALUES
(5, 3, 3, 'Good for beginners'),
(5, 5, 4, 'Practical examples'),
(2, 1, 4, 'Helpful session'),
(2, 2, 5, 'Excellent workshop!'),
(1, 4, 2, 'Needs better organization');

INSERT INTO events (title, description, venue, start_datetime, end_datetime, capacity, organizer_id)
VALUES (
    'Live Coding Workshop', 
    'Real-time Python programming session', 
    'CS Lab 3', 
    NOW() - INTERVAL 1 HOUR,  -- Started 1 hour ago
    NOW() + INTERVAL 100 HOUR,  -- Ends in 100 hours
    30, 
    3  -- Organizer: Dr. Saeed Mahmood
);
