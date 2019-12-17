USE COURSE
GO

----------------------------------------------------------Insert Ins----------------------------------------------------
CREATE PROCEDURE InsertIns
    @Instructor_ID CHAR(10),
    @Username VARCHAR(20),
    @Password VARCHAR(12),
    @Name NVARCHAR(40),
    @Sex VARCHAR(6), 
    @Birth_day DATE,
    @Age INT, 
    @Bio TEXT,   
    @Field VARCHAR(50),
    @Email VARCHAR(50)
AS 
BEGIN
    IF (YEAR(GETDATE())-YEAR(@Birth_day)<22) 
    BEGIN PRINT 'Instructor must be older than 22 years old'
        RETURN
    END
INSERT INTO dbo.Instructor(Instructor_ID, Username, Password, Name, Sex, Birth_day, Age, Bio, Field, Email)
VALUES(@Instructor_ID, @Username, @Password, @Name, @Sex, @Birth_day, @Age, @Bio, @Field, @Email);
END
GO
----------------------------------------------------------EXERCISE 2----------------------------------------------------

SELECT * FROM Instructor
GO

------------------------------------------------------Trigger AfterInsert Ins------------------------------------------------
--  Mô tả chức năng: Mỗi khi thêm hoặc xóa dữ liệu trên bảng Instructor, số lượng Instructor sẽ tăng hoặc giảm trên bảng ThongKe
CREATE TRIGGER AI_Ins ON Instructor
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @count INT
    DECLARE @countCourse INT
    IF EXISTS(SELECT * FROM Inserted)
        BEGIN
            SELECT @count=COUNT(*) FROM INSERTED
            UPDATE ThongKe
            SET number_Ins = number_Ins + @count
        END
    IF EXISTS(SELECT * FROM DELETED)
        BEGIN
            SELECT @count=COUNT(*) FROM INSERTED
            SELECT @countCourse = COUNT(*) FROM Course
            UPDATE ThongKe
            SET number_Ins = number_Ins - @count,
                number_Course = number_Course - @countCourse
        END
END
GO
------------------------------------------------------Trigger BeforeDELETE Ins------------------------------------------------
-- Mô tả chức năng: Trước khi xóa một Instructor thì chúng ta cần xóa những Course của Instructor tạo ra trước.
ALTER TRIGGER AD_Ins ON Instructor
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS(SELECT * FROM DELETED)
    BEGIN
        DELETE FROM Course WHERE EXISTS(
            SELECT * FROM DELETED 
            WHERE DELETED.Instructor_ID = Course.Ins_ID
            );
        DELETE FROM Instructor WHERE EXISTS(
            SELECT * FROM DELETED 
            WHERE DELETED.Instructor_ID = Instructor.Instructor_ID
        )
        PRINT 'AV'
    END
END
GO


----------------------------------------------------------EXERCISE 3----------------------------------------------------
--Truy xuất thông tin chi tiết của Giảng viên muốn xem
CREATE PROCEDURE getInfoIns
   @Instructor_ID CHAR(10)
AS
BEGIN
    SELECT i.Instructor_ID, i.Name, i.Sex, i.Birth_day, i.Bio, i.Field, i.Email, r.Rank
    FROM Instructor i, Instructor_Rank r
    WHERE i.Instructor_ID = @Instructor_ID AND r.Rank = i.Instructor_ID
    ORDER BY r.Rank ASC
END
GO

--
-- Truy xuất thông tin của khóa học muốn xem (bao gồm số lượng học viên của khóa học > 10)
CREATE PROCEDURE getInfoSubject
@Course_ID CHAR(10)
AS
BEGIN
    SELECT Course_ID,Title,Description,Time_to_ﬁnish,Cost,Instructor,Subject_ID,COUNT(Learner_ID) AS Number_Learner
    FROM Course
    INNER JOIN Enroll ON Course.Course_ID = Enroll.Course_ID
    WHERE Course_ID = @Course_ID
    GROUP BY Course_ID
    HAVING COUNT(Learner_ID)>10
    ORDER BY COUNT(Learner_ID) DESC
END
GO