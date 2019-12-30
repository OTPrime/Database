USE COURSE
GO

----------------------------------------------------EXERCISE 1--------------------------------------------------
--------------------------------------------------PROCEDURE INSERT COURSE---------------------------------------
CREATE PROCEDURE PR_InsertCourse
(
    @course_ID CHAR(10),
    @title VARCHAR(100),
    @description TEXT,
    @time_to_finish INT,
    @cost MONEY,
    @ins_ID CHAR(10),
    @subject_ID CHAR(10)
)
AS
BEGIN   
    IF @time_to_finish > 12
    BEGIN
        RAISERROR('Time to finish is not valid', 11, 2)
        RETURN
    END
    INSERT INTO Course
    VALUES(@course_ID, @title, @description, @time_to_finish, @cost, @ins_ID, GETDATE(), @subject_ID, 0)
END
GO


-------------------------------------------------PROCEDURE INSERT ENROLL--------------------------------------------
CREATE PROCEDURE PR_InsertEnroll
(
    @learner_ID CHAR(10),
    @course_ID CHAR(10),
    @progress INT
)
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Learner WHERE Learner_ID = @learner_ID)
    BEGIN
        RAISERROR('The learner is not exist', 11, 3)
        RETURN
    END
    IF NOT EXISTS(SELECT * FROM Course WHERE Course_ID = @course_ID)
    BEGIN
        RAISERROR('The course is not exist', 11, 3)
        RETURN
    END
    INSERT INTO Enroll(Learner_ID, Course_ID, Progress)
    VALUES(@learner_ID, @course_ID, @progress)
END
GO

--------------------------------------------------------EXERCISE 2----------------------------------------------------
---------------------------------------------------TRIGGER INSERT ENROLL----------------------------------------------
CREATE TRIGGER TG_InsertEnroll ON Enroll
AFTER INSERT
AS
BEGIN
    DECLARE @course_ID CHAR(10)
    DECLARE @number_learner INT
    DECLARE @count INT

    SELECT @course_ID=i.Course_ID FROM INSERTED i
    SELECT @count = COUNT(*) FROM INSERTED

    SET @number_learner = (SELECT Number_Learner FROM Course WHERE Course_ID = @course_ID)
    -- Update rows in table 'Course'
    UPDATE Course
    SET [Number_Learner] = @number_learner + @count
    WHERE Course_ID = @course_ID
END
GO

USE COURSE
GO
---------------------------------------------------TRIGGER DELETE ENROLL------------------------------------------------
CREATE TRIGGER TR_DeleteEnroll ON Enroll
INSTEAD OF DELETE
AS
BEGIN
    -- SELECT * FROM DELETED
    DECLARE @active_ID INT
    -- IDENTIFY THE CASE
    SELECT @active_ID = d.Active_ID FROM DELETED AS d GROUP BY d.Active_ID
    
    -- DELETE ALL ENROLL
    IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM Enroll)
    BEGIN
        DELETE FROM Enroll
        UPDATE Course SET Number_Learner = 0
    END
    -- DELETE ON ENROLL
    ELSE IF @active_ID = 0
    BEGIN
        DECLARE @learner_ID_0 CHAR(10)
        DECLARE @course_ID CHAR(10)
        
        -- DECLARE CURSOR
        DECLARE En_Cursor CURSOR LOCAL FOR SELECT Learner_ID, Course_ID FROM DELETED
        -- OPEN CURSOR
        OPEN En_Cursor
        FETCH NEXT FROM En_Cursor INTO @learner_ID_0, @course_ID
        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Enroll SET State = 0 WHERE Learner_ID = @learner_ID_0 AND Course_ID = @course_ID
            FETCH NEXT FROM En_Cursor INTO @learner_ID_0, @course_ID
        END
        -- CLOSE CURSOR
        CLOSE En_Cursor
        PRINT 'DISABLED ON ENROLL'
    END
    
    -- DELETE ON LEARNER
    ELSE IF @active_ID = 1
    BEGIN
        DECLARE @learner_ID_1 CHAR(10)
        DECLARE @course_ID_1 CHAR(10)
        DECLARE @count INT
        -- DECLARE CURSOR
        DECLARE En_Cursor CURSOR LOCAL FOR SELECT Course_ID, COUNT(*) FROM DELETED GROUP BY Course_ID
        -- OPEN CURSOR
        OPEN En_Cursor
        FETCH NEXT FROM En_Cursor INTO @course_ID_1, @count
        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Course   SET [Number_Learner] = [Number_Learner] - @count    WHERE Course_ID = @course_ID_1
            FETCH NEXT FROM En_Cursor INTO @course_ID_1, @count
        END
        -- CLOSE CURSOR
        CLOSE En_Cursor
        -- DELETE ENROLL
        SELECT @learner_ID_1 = d.Learner_ID FROM DELETED AS d GROUP BY d.Learner_ID
        DELETE FROM Enroll WHERE Learner_ID = @learner_ID_1
        PRINT 'DELETED LEARNER ON ENROLL!'
    END
    -- DELETE ON COURSE
    ELSE IF @active_ID = 2
    BEGIN
        DECLARE @course_ID_2 CHAR(10)
        SELECT @course_ID_2 = Course_ID FROM DELETED GROUP BY Course_ID
        DELETE FROM Enroll WHERE Course_ID = @course_ID_2
        PRINT 'DELETED COURSE ON ENROLL!'
    END
    -- DELETE ON COURSE
END
GO

--------------------------------------TRIGGER COURSE------------------------------------------
CREATE TRIGGER TR_DeleteCourse ON Course
INSTEAD OF DELETE
AS 
BEGIN
    DECLARE @Course_ID CHAR(10)
    SELECT @Course_ID = d.Course_ID FROM DELETED d
    -- DELETE INFO OF ENROLLED COURSE
    IF EXISTS(SELECT * FROM Enroll WHERE Course_ID IN (SELECT d.Course_ID FROM DELETED d))
    BEGIN
        UPDATE Enroll SET Active_ID = 2 WHERE Course_ID = @Course_ID
        DELETE FROM Enroll WHERE Course_ID IN (SELECT d.Course_ID FROM DELETED d)
    END
    -- DELETE COURSE
    DELETE FROM Course WHERE Course_ID IN (SELECT d.Course_ID FROM DELETED d)
    PRINT 'DELETED ON COURSE'
END
GO

