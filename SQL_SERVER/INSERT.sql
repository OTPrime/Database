USE COURSE
GO

-- INSERT SUBJECT
INSERT INTO Subject
VALUES 
    ('001', 'Title1', 'Description'),
    ('002', 'Title2', 'Description2'),
    ('003', 'Title3', 'Description3')
GO

-- INSERT DATA BY STORE PROCEDURE
EXECUTE PR_InsertLearner '1712240', 'learner1', '123456789', N'Dương Thị Minh Ngọc',  'female', '1999-02-21', 'abc1@gmail.com'
EXECUTE PR_InsertLearner '1712241', 'learner2', '123456789', N'Nguyễn Trần Thanh Tâm',  'female', '2001-01-22', 'abc2@gmail.com'
EXECUTE PR_InsertLearner '1712242', 'learner3', '123456789', N'Hồ Văn Lợi',  'male', '2003-12-08', 'abc3@gmail.com'
EXECUTE PR_InsertLearner '1712243', 'learner4', '123456789', N'Ngô Văn Mạnh',  'male', '1997-03-16', 'abc4@gmail.com'
EXECUTE PR_InsertLearner '1712244', 'learner5', '123456789', N'Nguyễn Văn Thanh',  'male', '2005-01-23', 'abc5@gmail.com'
EXECUTE PR_InsertLearner '1712245', 'learner6', '123456789', N'Nguyễn Thanh Hoàng',  'male', '2000-05-06', 'abc6@gmail.com'
EXECUTE PR_InsertLearner '1712246', 'learner7', '123456789', N'Đoàn Thị Ngọc Nhi',  'female', '1999-01-13', 'abc7@gmail.com'
EXECUTE PR_InsertLearner '1712247', 'learner8', '123456789', N'Nguyễn Thanh Hằng',  'female', '2002-12-12', 'abc8@gmail.com'
EXECUTE PR_InsertLearner '1712248', 'learner9', '123456789', N'Đoàn Văn Sang',  'male', '2000-12-08', 'abc9@gmail.com'
EXECUTE PR_InsertLearner '1712249', 'learner10', '123456789', N'Nguyễn Vũ Cát Tường',  'other', '2000-12-08', 'abc10@gmail.com'
GO

-- INSERT INSTRUCTOR
INSERT INTO Instructor(Instructor_ID, Username, Password, Name, Sex, Birth_day, Bio, Field, Email)
VALUES  
    ('01', 'instructor1', '123456789', 'Tran Thanh A', 'Female', '1990-12-18', 'Bio', 'Economics', 'ins1@gmail.com'),
    ('02', 'instructor2', '123456789', 'Tran Thanh C', 'Male', '1986-10-12', 'Bio', 'Biology', 'ins2@gmail.com') ,
    ('03', 'instructor3', '123456789', 'Tran Thanh C', 'Male', '1990-10-12', 'Bio', 'Biology', 'ins3@gmail.com'), 
    ('04', 'instructor4', '123456789', 'Tran Thanh M', 'Male', '1994-10-12', 'Bio', 'Biology', 'ins4@gmail.com'),
    ('05', 'instructor5', '123456789', 'Tran Thanh B', 'other', '1990-10-12', 'Bio', 'Biology', 'ins5@gmail.com'),
    ('06', 'instructor6', '123456789', 'Tran Thanh D', 'Male', '1990-10-12', 'Bio', 'Biology', 'ins6@gmail.com'), 
    ('07', 'instructor7', '123456789', 'Tran Thanh H', 'Male', '1990-10-12', 'Bio', 'Chemistry', 'ins7@gmail.com'), 
    ('08', 'instructor8', '123456789', 'Tran Thanh N', 'Female', '1990-10-12', 'Bio', 'Foreign Language', 'ins8@gmail.com') 
GO

-- INSERT COURSE
EXECUTE PR_InsertCourse '0001', 'Basis English', 'Description', 10, 50, '08', '001'
EXECUTE PR_InsertCourse '0002', 'Food chemistry', 'Description', 10, 50, '07', '002'
EXECUTE PR_InsertCourse '0003', 'Gene regulation', 'Description', 6, 100, '02', '002'
GO

-- ENROLL COURSE
EXECUTE PR_InsertEnroll '1712240', '0001', 10
EXECUTE PR_InsertEnroll '1712240', '0002', 15
EXECUTE PR_InsertEnroll '1712240', '0003', 5
EXECUTE PR_InsertEnroll '1712241', '0001', 59
EXECUTE PR_InsertEnroll '1712241', '0003', 39
EXECUTE PR_InsertEnroll '1712242', '0001', 42
EXECUTE PR_InsertEnroll '1712242', '0002', 77
EXECUTE PR_InsertEnroll '1712242', '0003', 78
EXECUTE PR_InsertEnroll '1712243', '0002', 16
EXECUTE PR_InsertEnroll '1712244', '0001', 89
EXECUTE PR_InsertEnroll '1712245', '0002', 30
EXECUTE PR_InsertEnroll '1712247', '0003', 50
EXECUTE PR_InsertEnroll '1712246', '0002', 40
GO

-- DELETE FROM Learner
-- WHERE Learner_ID = '1712241'
-- GO

-- -- SELECT Course_ID, COUNT(*) FROM Enroll
-- -- GROUP BY Course_ID
-- -- GO

-- DELETE FROM Course
-- -- WHERE Learner_ID = '1712243'
-- GO

