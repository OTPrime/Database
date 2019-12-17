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

---------------------------------------------------TRIGGER DELETE ENROLL------------------------------------------------
CREATE TRIGGER TR_DeleteEnroll ON Enroll
INSTEAD OF DELETE
AS
BEGIN
    -- SELECT * FROM DELETED
    DECLARE @learner_ID CHAR(10)
    DECLARE @state BIT
    DECLARE @count INT
    SELECT @count = COUNT(*) FROM DELETED
    SELECT @learner_ID = d.Learner_ID, @state = d.State FROM DELETED d
    -- IF learner account still exists
    IF  @state = 1 AND @count = 1
    BEGIN
        PRINT 'CD'    
        UPDATE Enroll
        SET State = 0
        WHERE Learner_ID = @learner_ID AND Course_ID IN (SELECT d.Course_ID FROM DELETED d)
        PRINT 'LEARNER DISABLE COURSE'
    END
    ELSE
    BEGIN
        DECLARE @course_ID CHAR(10)
        DECLARE @count_c INT
        -- DECLARE CURSOR
        DECLARE En_Cursor CURSOR LOCAL FOR
        SELECT Course_ID, COUNT(*)
        FROM DELETED
        GROUP BY Course_ID
        -- OPEN CURSOR
        OPEN En_Cursor
        FETCH NEXT FROM En_Cursor INTO @course_ID, @count_c
        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Course
            SET [Number_Learner] = [Number_Learner] - @count_c
            WHERE Course_ID = @course_ID
            FETCH NEXT FROM En_Cursor INTO @course_ID, @count_c
        END
        -- CLOSE CURSOR
        CLOSE En_Cursor
        -- DELETE ENROLL
        IF @count = (SELECT COUNT(*) FROM Enroll)
        BEGIN 
            DELETE FROM Enroll
        END
        ELSE
        BEGIN
            DELETE FROM Enroll 
            WHERE Learner_ID = @learner_ID AND Course_ID IN (SELECT d.Course_ID FROM DELETED d)
        END
        PRINT 'DELETED LEARNER IN ENROLL!'
    END
END
GO
