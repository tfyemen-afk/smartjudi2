CREATE DATABASE JudicialSmartDB
COLLATE Arabic_CI_AS;
GO
USE JudicialSmartDB;
GO
CREATE TABLE Users (
    UserID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    NationalID NVARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(150),
    UserRole NVARCHAR(50), -- „Õ«„Ì° „Ê«ÿ‰° ﬁ«÷Ì° „œÌ—
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE UserSessions (
    SessionID INT IDENTITY PRIMARY KEY,
    UserID INT,
    DeviceType NVARCHAR(100),
    Browser NVARCHAR(100),
    IPAddress NVARCHAR(50),
    Country NVARCHAR(100),
    Governorate NVARCHAR(100),
    City NVARCHAR(100),
    LoginTime DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE UserActivityLogs (
    LogID INT IDENTITY PRIMARY KEY,
    UserID INT,
    Action NVARCHAR(300),
    ActionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
CREATE TABLE Governorates (
    GovernorateID INT IDENTITY PRIMARY KEY,
    GovernorateName NVARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE Districts (
    DistrictID INT IDENTITY PRIMARY KEY,
    GovernorateID INT NOT NULL,
    DistrictName NVARCHAR(150) NOT NULL,
    FOREIGN KEY (GovernorateID) REFERENCES Governorates(GovernorateID)
);
CREATE TABLE CourtTypes (
    CourtTypeID INT IDENTITY PRIMARY KEY,
    CourtTypeName NVARCHAR(150),
    JudicialLevel NVARCHAR(50)
);

CREATE TABLE CourtSpecializations (
    SpecializationID INT IDENTITY PRIMARY KEY,
    SpecializationName NVARCHAR(150)
);

CREATE TABLE Courts (
    CourtID INT IDENTITY PRIMARY KEY,
    CourtName NVARCHAR(200),
    CourtTypeID INT,
    GovernorateID INT,
    DistrictID INT,
    Address NVARCHAR(300),
    LocationURL NVARCHAR(500),
    Latitude DECIMAL(10,7),
    Longitude DECIMAL(10,7),
    FOREIGN KEY (CourtTypeID) REFERENCES CourtTypes(CourtTypeID),
    FOREIGN KEY (GovernorateID) REFERENCES Governorates(GovernorateID),
    FOREIGN KEY (DistrictID) REFERENCES Districts(DistrictID)
);

CREATE TABLE CourtSpecializationMap (
    ID INT IDENTITY PRIMARY KEY,
    CourtID INT,
    SpecializationID INT,
    UNIQUE (CourtID, SpecializationID),
    FOREIGN KEY (CourtID) REFERENCES Courts(CourtID),
    FOREIGN KEY (SpecializationID) REFERENCES CourtSpecializations(SpecializationID)
);
CREATE TABLE Lawsuit_Main (
    LawsuitID INT IDENTITY PRIMARY KEY,
    CaseNumber NVARCHAR(100),
    CaseType NVARCHAR(100),
    CourtID INT,
    FilingDate DATE,
    Status NVARCHAR(50),
    CreatedBy INT,
    FOREIGN KEY (CourtID) REFERENCES Courts(CourtID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);

CREATE TABLE Plaintiffs (
    PlaintiffID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    FullName NVARCHAR(200),
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Defendants (
    DefendantID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    FullName NVARCHAR(200),
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Lawsuit_Facts (
    FactID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    Facts NVARCHAR(MAX),
    LegalBasis NVARCHAR(MAX),
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Lawsuit_Attachments (
    AttachmentID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    FileName NVARCHAR(200),
    FilePath NVARCHAR(500),
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Lawsuit_Response (
    ResponseID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    ResponseText NVARCHAR(MAX),
    ResponseDate DATE,
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Appeals (
    AppealID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    AppealReason NVARCHAR(MAX),
    AppealDate DATE,
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);

CREATE TABLE Payment_Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    Amount DECIMAL(18,2),
    OrderDate DATE,
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID)
);
CREATE TABLE LegalCategories (
    CategoryID INT IDENTITY PRIMARY KEY,
    CategoryName NVARCHAR(150)
);

CREATE TABLE Laws (
    LawID INT IDENTITY PRIMARY KEY,
    CategoryID INT,
    LawName NVARCHAR(300),
    IssueYear INT,
    FOREIGN KEY (CategoryID) REFERENCES LegalCategories(CategoryID)
);

CREATE TABLE LawChapters (
    ChapterID INT IDENTITY PRIMARY KEY,
    LawID INT,
    ChapterTitle NVARCHAR(300),
    FOREIGN KEY (LawID) REFERENCES Laws(LawID)
);

CREATE TABLE LawSections (
    SectionID INT IDENTITY PRIMARY KEY,
    ChapterID INT,
    SectionTitle NVARCHAR(300),
    FOREIGN KEY (ChapterID) REFERENCES LawChapters(ChapterID)
);

CREATE TABLE LawArticles (
    ArticleID INT IDENTITY PRIMARY KEY,
    SectionID INT,
    ArticleNumber NVARCHAR(50),
    ArticleText NVARCHAR(MAX),
    FOREIGN KEY (SectionID) REFERENCES LawSections(SectionID)
);
CREATE TABLE CaseLegalReferences (
    ID INT IDENTITY PRIMARY KEY,
    LawsuitID INT,
    ArticleID INT,
    ConfidenceScore DECIMAL(5,2),
    IsAI BIT DEFAULT 0,
    FOREIGN KEY (LawsuitID) REFERENCES Lawsuit_Main(LawsuitID),
    FOREIGN KEY (ArticleID) REFERENCES LawArticles(ArticleID)
);
CREATE TABLE SearchLogs (
    SearchID INT IDENTITY PRIMARY KEY,
    UserID INT,
    SearchQuery NVARCHAR(MAX),
    SearchDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE AIChatLogs (
    ChatID INT IDENTITY PRIMARY KEY,
    UserID INT,
    Question NVARCHAR(MAX),
    Answer NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);