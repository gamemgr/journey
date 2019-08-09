USE GDB
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Maintenance' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Maintenance]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Error' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Error]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Account' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Account]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_TestAccount' AND TYPE = 'U')
   DROP TABLE [dbo].[T_TestAccount]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_User' AND TYPE = 'U')
   DROP TABLE [dbo].[T_User]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Material' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Material]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Hero' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Hero]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Item' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Item]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Key' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Key]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Space' AND TYPE = 'U')
   DROP TABLE [dbo].[T_Space]
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Maintenance
-- DESC         : 점검 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Maintenance]
(
    [State]             TINYINT         NOT NULL,                       -- 서버 상태 [ 0 : On, 1 : Off ]

    [Version]           INT             NOT NULL DEFAULT(0),            -- 서버 버전 [ 클라이언트와 버전이 맞지 않을경우 로그인 불가 ]

    [EndTime]           SMALLDATETIME   NULL,                           -- 서버 상태 Off 일 경우 점검 종료 시간.
)
GO

INSERT INTO [dbo].[T_Maintenance]([State], [Version], [EndTime])
VALUES(0, 1, GETDATE())

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Error
-- DESC         : 에러 테이블 [ Procedure Error ]
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Error]
(
    [ErrorNumber]       INT             NULL,

    [ErrorSeverity]     INT             NULL,

    [ErrorState]        INT             NULL,

    [ErrorProc]         NVARCHAR(200)   NULL,

    [ErrorLine]         INT             NULL,

    [ErrorMessage]      NVARCHAR(4000)  NULL,

    [ErrorTime]         DATETIME2       NULL,
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_TestAccount
-- DESC         : Test 계정 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_TestAccount]
(
    [LoginId]           VARCHAR(50)     NOT NULL,                       -- Test Account LoginId

    [RegTime]           DATETIME2       NOT NULL DEFAULT(GETDATE()),    -- 등록 시간

    CONSTRAINT [PK_T_TestAccount] PRIMARY KEY CLUSTERED
    (
        [LoginId] ASC
    )
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Account
-- DESC         : 계정 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Account]
(
    [AccUid]            INT             IDENTITY(1,1),                  -- T_Account Uid
    
    [LoginId]           VARCHAR(50)     NOT NULL,                       -- Guest : UUID, Google : email, Ios : Game Center ID [ UUID : Universally Unique Identifire, 시간 & 공간을 이용하여 뽑아낸 128bit 중복되지 않는 값 ( for Unity SystemInfo.deviceUniqueIdentifier ) ]
    
    [LoginPlatform]     TINYINT         NOT NULL,                       -- Guest = 0, Google = 1, IOS = 2
    
    [LoginCount]        INT             NOT NULL DEFAULT(0),            -- 로그인 횟수
    
    [SystemLanguage]    TINYINT         NOT NULL DEFAULT(0),            -- Input Language
    
    [Ban]               TINYINT         NOT NULL DEFAULT(0),            -- BAN 여부 [ 0 : 벤 아님, 1 : 불법 프로그램 사용, 2 : 욕설, 3 : 기타 ]
    
    [BanEndTime]        SMALLDATETIME   NOT NULL DEFAULT(0),            -- BAN 일 경우 종료시간
    
    [CreatedTime]       DATETIME2       NOT NULL DEFAULT(GETDATE()),    -- 계정 생성 시간
    
    [LoginTime]         DATETIME2       NOT NULL DEFAULT(GETDATE()),    -- 로그인 시간
    
    CONSTRAINT [PK_T_Account] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC
    )
)
CREATE UNIQUE NONCLUSTERED INDEX [NIX_T_Account_LoginId] ON [dbo].[T_Account]
(
    [LoginId] ASC
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_User
-- DESC         : 유저 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_User]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Uid
    
    [Nick]              NVARCHAR(8)     NOT NULL,                       -- 닉네임 [ 유니코드 8자 까지, 중복 불가, 변경 가능 : 500 Jewel ]
    
    [Icon]              SMALLINT        NOT NULL DEFAULT(0),            -- 아이콘
    
    [Title]             SMALLINT        NOT NULL DEFAULT(0),            -- 칭호
    
    [Level]             INT             NOT NULL DEFAULT(1),            -- 유저 레벨
    
    [Exp]               INT             NOT NULL DEFAULT(0),            -- 유저 경험치
    
    [Gold]              INT             NOT NULL DEFAULT(0),            -- 골드

    [Cash]              INT             NOT NULL DEFAULT(0),            -- 캐시

    [RCash]             INT             NOT NULL DEFAULT(0),            -- 캐시 [ 현금 ]
    
    [Jewel]             INT             NOT NULL DEFAULT(0),            -- 보석
    
    [HonorPT]           INT             NOT NULL DEFAULT(0),            -- 명예 포인트
    
    [GuildPT]           INT             NOT NULL DEFAULT(0),            -- 길드 포인트
    
    [ItemInventory]     SMALLINT        NOT NULL DEFAULT(60),           -- 인벤 갯수 [ Default 60개 ]
    
    [Tutorial]          INT             NOT NULL DEFAULT(0),            -- 튜토리얼 State
    
    [StageId]           INT             NOT NULL DEFAULT(0),            -- 현재 진행 스테이지 Id [ From Server ]
    
    [GuildUid]          INT             NOT NULL DEFAULT(0),            -- T_Guild Primary Key
    
    [InitTime]          DATETIME2       NOT NULL DEFAULT(GETDATE()),    -- 일일 초기화 진행된 시간 [ From Server ]
    
    CONSTRAINT [PK_T_User] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC
    )
)
CREATE UNIQUE NONCLUSTERED INDEX [NIX_T_User_Nick] ON [dbo].[T_User]
(
    [Nick] ASC
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Material
-- DESC         : 재료 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Material]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Uid

    [Id]                TINYINT         NOT NULL,                       -- ID

    [Count]             INT             NOT NULL DEFAULT(0),            -- COUNT

    CONSTRAINT [PK_T_Material] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC,
        [Id] ASC
    )
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Hero
-- DESC         : 영웅 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Hero]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Uid

    [HeroUid]           INT             IDENTITY(1,1),                  -- T_Hero Uid

    [Id]                INT             NOT NULL,                       -- Hero Id [ 1, 2, 3 ]

    [Level]             INT             NOT NULL DEFAULT(1),            -- Level

	[Exp]               INT             NOT NULL DEFAULT(0),            -- 경험치

	[Str]               INT             NOT NULL DEFAULT(0),            -- 근력 [ 물공, 물방, 견고 증가 ]

	[Int]               INT             NOT NULL DEFAULT(0),            -- 지력 [ 마공, 치명 증가 ]

	[Dex]               INT         	NOT NULL DEFAULT(0),            -- 민첩 [ 마방, 회피, 명중 증가 ]

	[Con]               INT             NOT NULL DEFAULT(0),            -- 체력 [ 물방, HP 증가 ]

	-- 물리공격 : 물리공격력 증가
	-- 마법공격 : 마법공격력 증가
	-- 물리방어 : 물리공격피해 감소
	-- 마법방어 : 마법공격피해 감소
	-- 명중     : 공격 명중률 증가
	-- 회피     : 공격 회피율 증가
	-- 치명     : 1.5배 피해 확률 증가
	-- 견고     : 치명타를 입을 확률 감소

    CONSTRAINT [PK_T_Hero] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC,
        [HeroUid] ASC
    )
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Item
-- DESC         : 아이템 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Item]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Uid

    [ItemUid]           INT             IDENTITY(1,1),                  -- T_Item Uid

    [Id]                INT             NOT NULL,                       -- Item Table ID

    [Enchant]           INT             NOT NULL DEFAULT(0),            -- 강화 수치

    [Count]             INT             NOT NULL DEFAULT(1),            -- 아이템 수량 [ 0개일경우 삭제된 아이템으로 판별 ]

    CONSTRAINT [PK_T_Item] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC,
        [ItemUid] ASC
    )
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Key
-- DESC         : 열쇠 (시간재화) 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Key]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Primary Key

    [Id]                TINYINT         NOT NULL,                       -- 시간 재화 ID [ 21 : Stage ]

    [Count]             INT             NOT NULL DEFAULT(5),            -- 보유 수량

    [MaxTime]           DATETIME2       NOT NULL DEFAULT(GETDATE()),    -- 최대치로 충전되는 시간

    CONSTRAINT [PK_T_Key] PRIMARY KEY CLUSTERED
    (
        [AccUid] ASC,
        [Id] ASC
    )
)
GO

-- ==========================================================================================
-- Type         : Table
-- ID           : T_Space
-- DESC         : 공간 테이블
-- Author       : gmlee
-- Modify       :
-- ==========================================================================================
CREATE TABLE [dbo].[T_Space]
(
    [AccUid]            INT             NOT NULL,                       -- T_Account Primary Key

    [Id]                TINYINT         NOT NULL,                       -- Space Table Id

    [Level]             TINYINT         NOT NULL DEFAULT(1),            -- Level

    [HeroUid]           INT             NOT NULL DEFAULT(0),            -- collocated hero

    [collocateTime]     DATETIME2       NOT NULL DEFAULT('0001-01-01')  -- 배치된 시간
)
GO