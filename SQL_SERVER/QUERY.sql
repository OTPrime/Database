USE COURSE
GO

SELECT * FROM Learner
GO

SELECT * FROM Enroll 
GO

SELECT * FROM Course
GO

SELECT * FROM Learner_Audit
GO

DELETE FROM Instructor
WHERE Instructor_ID = '07'
GO

DELETE FROM Course
WHERE Course_ID = '0003'
GO

DELETE FROM Learner
WHERE Learner_ID = '1712247'
GO

DELETE FROM Instructor
GO

DELETE FROM Enroll WHERE  Learner_ID = '1712244' AND Course_ID = '0001'
GO

------------------------------------CHECK PROCEDURE--------------------------------------------
--EXECUTE STORED PROCEDURE
EXECUTE PR_InsertLearner '1712250', 'learner11', '123456789', N'Pham Ngoc Linh',
'female', '1999-01-10', 'abc50@gmail.com'
GO

SELECT * FROM Learner
GO

--EXECUTE STORED PROCEDURE
EXECUTE PR_GetLearner 18
GO

---------------------------------------CHECK TRIGGER-------------------------------------------
EXECUTE PR_InsertLearner '1712251', 'learner12', '123456789', N'Dang Nhat Minh',
'male', '2001-08-12', 'abc13@gmail.com'
GO
UPDATE Learner SET Password = '987654321' WHERE Learner_ID = '1712251'
GO
DELETE FROM Learner WHERE Learner_ID = '1712251'
GO

SELECT * FROM Learner_Audit
GO

-- TRIGGER DELETE LEARNER
DELETE FROM Learner WHERE Learner_ID = '1712240'
GO

SELECT * FROM Enroll
GO

-- TRIGGER INSERT ENROLL
EXECUTE PR_InsertEnroll '1712248', '0001', 0
EXECUTE PR_InsertEnroll '1712249', '0001', 0
EXECUTE PR_InsertEnroll '1712250', '0001', 0
GO

SELECT * FROM Enroll
GO

SELECT * FROM Course
GO

--TRIGGER DELETE ENROLL
DELETE FROM Enroll WHERE Learner_ID = '1712241' AND Course_ID = '0001'
GO
DELETE FROM Enroll WHERE Learner_ID = '1712241' AND Course_ID = '0003'
GO
DELETE FROM Enroll WHERE Learner_ID = '1712242' AND Course_ID = '0001'
GO
DELETE FROM Enroll WHERE Learner_ID = '1712242' AND Course_ID = '0002'
GO

SELECT * FROM Enroll
GO

-- EXERCISE 3
-- EXECUTE: GET LEARNERS WITH SEX
EXECUTE PR_GetLearnerWithSex 'male'
GO

-- EXECUTE: GET LEARNERS OF COURSES
EXECUTE PR_GetLearnerOfCourse 20
GO

-- EXECUTE: COURSE STATISTICS
EXECUTE PR_CourseStatistics 2
GO

------------------------------------------CHECK FUNCTION-------------------------------
-- GET LEARNER ENROLL IN THE TIME
SELECT * FROM FC_By_Time_Learner(DATEADD(DD,-1,GETDATE()), DATEADD(DD,1,GETDATE()))
WHERE Progress > 50
GO

-- GET A NUMBER OF LEARNERS HAVE MOST PROGRESS
SELECT * FROM FC_Get_Best_Learner(3)
GO