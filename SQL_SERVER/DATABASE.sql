CREATE DATABASE COURSE
GO

USE COURSE
GO

-------------------------------------LEARNER-----------------------------------------------
CREATE TABLE Learner 
(
    Learner_ID CHAR(10) PRIMARY KEY,	
    Username VARCHAR(20) NOT NULL UNIQUE,
    Password VARCHAR(12) NOT NULL ,
    Name NVARCHAR(40),  
    Sex VARCHAR(6),	
    Birth_day DATE,	
    Age INT,
    Email VARCHAR(50),
	CONSTRAINT CH_AccLeaLen CHECK ((LEN(Username) >= 8) AND (LEN(Password) >= 8)),
    CONSTRAINT CH_SexLearner CHECK (Sex = 'male' OR Sex = 'female' OR Sex = 'other')
)
GO

-------------------------------------INSTRUCTOR----------------------------------------------
CREATE TABLE Instructor
(
	Instructor_ID CHAR(10) PRIMARY KEY, -- static allocation of 10 characters
	Username VARCHAR(20) NOT NULL UNIQUE,
    Password VARCHAR(12) NOT NULL,
	Name NVARCHAR(40),
	Sex VARCHAR(6), 
	Birth_day DATE NOT NULL,
    Age INT, 
	Bio TEXT,   --Biography
	Field VARCHAR(50),  -- Field of teaching
    Email VARCHAR(50),
    CONSTRAINT CH_AccInsLen CHECK ((LEN(Username) > 8) AND (LEN(Password) > 8)),
    CONSTRAINT CH_AgeIns CHECK (YEAR(GETDATE()) - YEAR(Birth_day) > 22),
    CONSTRAINT CH_SexIns CHECK (Sex = 'male' OR Sex = 'female' OR Sex = 'other')
)
GO

-----------------------------------------INSTRUCTOR RANK----------------------------------------
CREATE TABLE Instructor_Rank
(
    Instructor_ID CHAR(10) NOT NULL,
    Rank VARCHAR(20) NOT NULL, -- M.S., Ph.D, Assoc. Prof., Prof.
    CONSTRAINT PK_InsRank PRIMARY KEY (Instructor_ID, Rank)
)
GO

-----------------------------------------------SUBJECT------------------------------------------
CREATE TABLE Subject
(
    Subject_ID CHAR(10) PRIMARY KEY,    
    Title VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT DEFAULT 'Description'
)
GO

------------------------------------------------COURSE--------------------------------------------
CREATE TABLE Course
(
    Course_ID CHAR(10) NOT NULL UNIQUE,
    Title VARCHAR(100),
    Description TEXT DEFAULT 'Description',
    Time_to_finish INT, -- UNIT IS WEEK
    Cost MONEY DEFAULT 'Free',
    Ins_ID CHAR(10), 
    Create_date DATE DEFAULT GETDATE(),
    Subject_ID CHAR(10),    
    Number_Learner INT, -- number of learner enroll into the course
    CONSTRAINT PK_Course PRIMARY KEY (Course_ID),
    CONSTRAINT CH_TimeToFinish CHECK (Time_to_finish <= 12),
)
GO

-----------------------------------------------ENROLL----------------------------------------------
CREATE TABLE Enroll
(
    Learner_ID CHAR(10) NOT NULL,
    Course_ID CHAR(10) NOT NULL,
    Enroll_date DATE DEFAULT GETDATE(),
    State BIT DEFAULT 1, 
    Progress INT DEFAULT 0,-- complete: %(progress of learner)
    Active_ID INT DEFAULT 0,
    CONSTRAINT PK_Enroll PRIMARY KEY (Learner_ID, Course_ID),
    CONSTRAINT CH_State CHECK (Progress >= 0 AND Progress <= 100) -- the progress of the learner
)
GO

-------------------------------------------LESSON--------------------------------------------------
CREATE TABLE Lesson
(
    Course_ID CHAR(10) NOT NULL,
    L_number INT NOT NULL,
    Content TEXT,
    CONSTRAINT PK_Lesson PRIMARY KEY(Course_ID, L_number)
)
GO


-----------------------------------------LESSON MATERIAL-----------------------------------------
CREATE TABLE Lesson_Material
(
    Course_ID CHAR(10) NOT NULL,
    L_number INT NOT NULL,
    Material_ID CHAR(10) NOT NULL UNIQUE,
    Type VARCHAR(50),
    Format VARCHAR(50),
    Title VARCHAR(50),
    URL VARCHAR(2083),
    CONSTRAINT PK_Material PRIMARY KEY (Course_ID, L_number, Material_ID)
)
GO

-------------------------------------------LEARN--------------------------------------------------
CREATE TABLE Learn
(
    Learner_ID CHAR(10) NOT NULL,
    Course_ID CHAR(10) NOT NULL,
    L_number INT NOT NULL,
    Learn_date DATE DEFAULT GETDATE(),
    Progress INT, -- PROGRESS OF LEARNER(%)
    CONSTRAINT PK_Learn PRIMARY KEY (Learner_ID, Course_ID, L_number)
)
GO

--------------------------------------------LESSON QUIZ---------------------------------------------
CREATE TABLE Lesson_quiz
(
    Course_ID CHAR(10) NOT NULL,
    L_number INT NOT NULL,
    Lquiz_ID CHAR(10) NOT NULL UNIQUE,
    Form VARCHAR(50),   -- Multiple-choice | Essay
    Question TEXT,
    Answer TEXT,
    CONSTRAINT PK_Lquiz PRIMARY KEY (Course_ID, L_number, Lquiz_ID)
)
GO

-----------------------------------------------TAKE QUIZ----------------------------------------------
CREATE TABLE Take_quiz
(
    Learner_ID CHAR(10) NOT NULL,
    Course_ID CHAR(10) NOT NULL,
    L_number INT NOT NULL,
    Lquiz_ID CHAR(10) NOT NULL,
    Take_date DATE DEFAULT GETDATE(),
    Scoure INT, -- SCORE OF LEARNER(/100)
    CONSTRAINT PK_TakeQuiz PRIMARY KEY (Learner_ID, Course_ID, L_number, Lquiz_ID),
    CONSTRAINT CH_ScoreQuiz CHECK (Scoure >= 0 AND Scoure <= 100)
)
GO

-------------------------------------------CERTIFICATE-------------------------------------------------
CREATE TABLE Certificate
(
    Certificate_ID CHAR(10) NOT NULL UNIQUE, -- primary key column
    Rank VARCHAR(50),   -- Rank of certificate
    Description TEXT DEFAULT 'Description',
    Certification_bodies NVARCHAR(500), -- Certification organizations that issue certificates
    Learner_ID CHAR(10) NOT NULL, -- Recipient of the certificate
    Received_date DATE DEFAULT GETDATE(), -- The date the certificate was received
    Course_ID CHAR(10) NOT NULL, -- Certificate of courses
    CONSTRAINT PK_Certificate PRIMARY KEY (Certificate_ID)
)
GO


---------------------------------------------COURSE EXAM------------------------------------------------
CREATE TABLE Course_exam
(
    Exam_ID CHAR(10) NOT NULL UNIQUE,
    Course_ID CHAR(10) NOT NULL,
    Form VARCHAR(50) DEFAULT 'Multiple choice', -- Multiple-choice | Essay
    Title VARCHAR(100), -- Topic of the exam
    Question TEXT,
    Answer TEXT,
    CONSTRAINT PK_CourExam PRIMARY KEY (Exam_ID)
)
GO

----------------------------------------------TAKE EXAM-------------------------------------------------
CREATE TABLE Take_Exam
(
    Learner_ID CHAR(10) NOT NULL, -- The examiner
    Exam_ID CHAR(10) NOT NULL, -- The Test
    Take_date DATE DEFAULT GETDATE(),
    Scoure INT, -- Exam result
    State INT, -- Test progress
    CONSTRAINT PK_TakeExam PRIMARY KEY (Learner_ID, Exam_ID) 
)
GO

-----------------------------------------------FEED BACK-------------------------------------------------
CREATE TABLE Feedback
(
    Exam_ID CHAR(10) NOT NULL,
    Fb_ID CHAR(10) NOT NULL UNIQUE,
    Title VARCHAR(100),
    Content TEXT,
    Learner_ID CHAR(10) NOT NULL,
    Fb_date DATE DEFAULT GETDATE(),
    Instructor_ID CHAR(10) NOT NULL,
    Reply_date DATE,
    CONSTRAINT PK_Feedback PRIMARY KEY (Exam_ID, Fb_ID)
)
GO

--------------------------------------------LEARNER AUDIT-----------------------------------------------------
CREATE TABLE Learner_Audit
(
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Learner_ID CHAR(10) NOT NULL,
    Learner_Name NVARCHAR(40),
    Change_date DATE DEFAULT NULL,
    Action VARCHAR(10) DEFAULT NULL
)
GO

------------FOREIGN KEY-------------

---------------------------------------INSTRUCTOR RANK-----------------------------------------
ALTER TABLE Instructor_Rank
ADD
    CONSTRAINT FK_InsRankID FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) -- reference to instructor relation
    ON DELETE CASCADE   -- if the parent date is deleted(updated), the child data will be deleted(updated) 
    ON UPDATE CASCADE   --NO ACTION | SET NULL | SET DEFAULT
GO

------------------------------------------------COURSE-------------------------------------------------
ALTER TABLE Course
ADD
    CONSTRAINT FK_CourInsID FOREIGN KEY (Ins_ID) REFERENCES Instructor(Instructor_ID) 
    ON DELETE SET NULL
    ON UPDATE CASCADE,
    CONSTRAINT FK_CourSubID FOREIGN KEY (Subject_ID) REFERENCES Subject(Subject_ID) 
    ON DELETE SET NULL
    ON UPDATE CASCADE
GO

-----------------------------------------------ENROLL--------------------------------------------------
ALTER TABLE Enroll
ADD
    CONSTRAINT FK_EnrLearID FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID) -- course registrants
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    CONSTRAINT FK_EnrCourID FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) -- the course is registered
    ON DELETE NO ACTION
    ON UPDATE CASCADE
GO

-------------------------------------------LESSON----------------------------------------------
ALTER TABLE Lesson
ADD
    CONSTRAINT FK_LessCour FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

-----------------------------------------LESSON MATERIAL-----------------------------------------
ALTER TABLE Lesson_Material
ADD
    CONSTRAINT FK_MaterLess FOREIGN KEY (Course_ID, L_number) REFERENCES Lesson(Course_ID, L_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

-------------------------------------------LEARN--------------------------------------------------
ALTER TABLE Learn
ADD
    CONSTRAINT FK_OfLearner FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT FK_OfLess FOREIGN KEY (Course_ID, L_number) REFERENCES Lesson(Course_ID, L_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

--------------------------------------------LESSON QUIZ---------------------------------------------
ALTER TABLE Lesson_quiz
ADD
    CONSTRAINT FK_Lquiz FOREIGN KEY (Course_ID, L_number) REFERENCES Lesson(Course_ID, L_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO


-----------------------------------------------TAKE QUIZ----------------------------------------------
ALTER TABLE Take_quiz
ADD
    CONSTRAINT FK_OfLear FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT FK_OfLessQuiz FOREIGN KEY (Course_ID, L_number, Lquiz_ID) REFERENCES Lesson_quiz(Course_ID, L_number, Lquiz_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

-------------------------------------------CERTIFICATE-------------------------------------------------
ALTER TABLE Certificate
ADD
    CONSTRAINT FK_CertLear FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT FK_CerCour FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

---------------------------------------------COURSE EXAM------------------------------------------------
ALTER TABLE Course_exam
ADD
    CONSTRAINT FK_OfCour FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO


----------------------------------------------TAKE EXAM-------------------------------------------------
ALTER TABLE Take_Exam
ADD
    CONSTRAINT FK_ExamOfLear FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT FK_OfCourseExam FOREIGN KEY (Exam_ID) REFERENCES Course_exam(Exam_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
GO

-----------------------------------------------FEED BACK-------------------------------------------------
ALTER TABLE Feedback
ADD
    
    CONSTRAINT FK_FbLearner FOREIGN KEY (Learner_ID) REFERENCES Learner(Learner_ID)
    ON DELETE NO ACTION
    On UPDATE CASCADE,
    CONSTRAINT FK_FBInstructor FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID)
    ON DELETE NO ACTION
    On UPDATE CASCADE,
    CONSTRAINT FK_FbofExam FOREIGN KEY (Exam_ID) REFERENCES Course_Exam(Exam_ID)
    -- ON DELETE NO ACTION
    -- ON UPDATE NO ACTION
GO


----------------INDEX---------------
------------------------------------- INDEX FOR TABLE LEARANER------------------------------------------
CREATE INDEX Idx_Learner
ON Learner(Name)
GO

------------------------------------- INDEX FOR TABLE INSTRUCTOR-----------------------------------------
CREATE INDEX Idx_Instructor
ON Instructor(Name)
GO
------------------------------------- INDEX FOR TABLE COURSE---------------------------------------------
CREATE INDEX Idx_Course
ON Course(Title)
GO

