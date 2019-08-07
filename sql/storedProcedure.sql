USE GDB
GO

-- PROCEDURE ERRORCODE

-- 1001 : 서버 점검중입니다.
-- 1002 : 서버와의 버전이 맞지 않습니다. 스토어에서 업데이트 하세요.
-- 1003 : 닉네임이 중복되었습니다.
-- 1004 : 계정을 찾지 못하였습니다.
-- 1005 : 계정 블럭 상태입니다.
-- 1006 : 중복 로그인 하였습니다.
-- 1007 : 이미 로그인 하였습니다.
-- 1008 : 로그인 하지 않았습니다.

-- 2001 : 동일한 길드명이 존재합니다.
-- 2002 : 길드에 가입한 상태입니다.
-- 2003 : 가입 신청한 길드입니다.
-- 2004 : 존재하지 않는 길드입니다.
-- 2005 : 길드 인원이 가득 차 있습니다.
-- 2006 : 길드 가입 요청이 가득 차 있습니다.
-- 2007 : 길드 마스터만 가능합니다.
-- 2008 : 소속된 길드가 없습니다.
-- 2009 : 길드에 이미 출석하였습니다.
-- 2010 : 이미 길드정보를 로드 하였습니다.
-- 2011 : 가입신청 정보가 없습니다.

-- 3001 : 이미 수령한 우편입니다.
-- 3002 : 존재하지 않는 우편 정보입니다.

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Error_Insert' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Error_Insert]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Account_Login' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Account_Login]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_User_Load' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_User_Load]
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Error_Insert]
-- DESC         : 에러 삽입 프로시저
-- Author       : gmlee
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Error_Insert]
AS
SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
BEGIN
	IF ERROR_NUMBER() IS NULL
		RETURN;

	INSERT INTO [dbo].[T_Error] ( [ErrorNumber], [ErrorSeverity], [ErrorState], [ErrorProc], [ErrorLine], [ErrorMessage], [ErrorTime] )
	VALUES( ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ISNULL(ERROR_PROCEDURE(), '-'), ERROR_LINE(), ERROR_MESSAGE(), GETDATE() )
END
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Account_Login]
-- DESC         : 로그인 프로시저
-- Author       : gmlee
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Account_Login]
    @LoginId			VARCHAR(50),				-- UID or Google Game Service ID를 이용한 로그인에 사용.

    @Nick				NVARCHAR(8),				-- 최초 로그인때 사용.

    @LoginPlatform		TINYINT,					-- [ Guest = 0, Google = 1, iOS = 2 ]

    @SystemLanguage		TINYINT,					-- [ Input Language ]
	
    @Version			INT,						-- 클라이언트에서 전송된 서버 버전 체크용도

    @_AccUid			INT OUTPUT,					-- T_Account Primary Key

    @_Version			INT OUTPUT,					-- 현재 서버 버전

    @_EndTime			SMALLDATETIME OUTPUT,		-- 서버 상태 Off 일 경우 점검 종료 시간.

    @_BanEndTime		SMALLDATETIME OUTPUT,		-- 계정 벤일경우 종료시간.

    @_NewCreate			TINYINT OUTPUT				-- 신규생성 여부
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET @_AccUid = 0
SET @_Version = 0
SET @_EndTime = 0
SET @_BanEndTime = 0
SET @_NewCreate = 0

BEGIN TRY
	DECLARE @state TINYINT = 0
	DECLARE @ban TINYINT = 0

	-- 점검 테이블 SELECT
	SELECT TOP 1 @state = [State], @_Version = [Version], @_EndTime = [EndTime]
	FROM [dbo].[T_Maintenance]

	-- 서버 점검중인지 체크
	IF @state <> 0
	BEGIN
		-- 테스트 계정은 진입할수 있게끔 함.
		IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_TestAccount] WHERE [LoginId] = @LoginId)
			RETURN 1001				-- 1001 : 서버 점검중입니다.
	END

	-- 게임 버전 체크
	IF @Version <> @_Version
		RETURN 1002					-- 1002 : 서버와의 버전이 맞지 않습니다. 스토어에서 업데이트 하세요.

	IF LEN(@Nick) < 2
	BEGIN
		-- LoginId로 계정을 찾아봅니다.
		SELECT TOP 1
		@_AccUid = [AccUid],
		@_BanEndTime = [BanEndTime],
		@ban = [Ban]
		FROM [dbo].[T_Account] WHERE [LoginId] = @LoginId

		IF @@ROWCOUNT = 0
			RETURN 1004				-- 1004 : 계정을 찾지 못하였습니다. [ 닉네임 등록 프로세스 진행 ]

		-- 계정블럭 여부 체크
		IF @ban <> 0
		BEGIN
			IF @_BanEndTime < GETDATE()
				UPDATE [dbo].[T_Account] SET [Ban] = 0 WHERE [AccUid] = @_AccUid
			ELSE
				RETURN 1005			-- 1005 : 계정 블럭 상태입니다.
		END

		-- 로그인 처리합니다
		UPDATE [dbo].[T_Account]
		SET [SystemLanguage] = @SystemLanguage,
		[LoginPlatform] = @LoginPlatform,
		[LoginTime] = GETDATE(),
		[LoginCount] = [LoginCount] + 1
		WHERE [AccUid] = @_AccUid

		RETURN 0
	END
	ELSE
	BEGIN
		-- Nick EXISTS
		IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_User] WHERE [Nick] = @Nick)
			RETURN 1003				-- 1003 : 닉네임이 중복되었습니다.

		-- 신규 계정을 생성합니다
		BEGIN TRAN

		INSERT INTO [dbo].[T_Account] ([LoginId], [LoginPlatform], [LoginCount], [SystemLanguage])
		VALUES(@LoginId, @LoginPlatform, 1, @SystemLanguage)
		SET @_AccUid = SCOPE_IDENTITY()

		INSERT INTO [dbo].[T_User] ([AccUid], [Nick])
		VALUES(@_AccUid, @Nick)

		INSERT INTO [dbo].[T_Key] ([AccUid], [Id])
		VALUES(@_AccUid, 21)

		SET @_NewCreate = 1

		COMMIT TRAN

		RETURN 0
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT <> 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 99999999
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_User_Load]
-- DESC         : UserData Load
-- Author       : gmlee
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_User_Load]
    @AccUid				INT							-- T_Account PK
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	SELECT [Nick], [Icon], [Title], [Level], [Exp], [Gold], [Jewel], [HonorPT], [GuildPT], [ItemInventory], [Tutorial], [StageId], [GuildUid], [InitTime]
	FROM [dbo].[T_User] WITH (NOLOCK)
	WHERE [AccUid] = @AccUid

	SELECT [ItemUid], [Id], [Enchant], [Count]
	FROM [dbo].[T_Item] WITH (NOLOCK)
	WHERE [AccUid] = @AccUid

	SELECT [Id], [Count], [MaxTime]
	FROM [dbo].[T_Key] WITH (NOLOCK)
	WHERE [AccUid] = @AccUid

	RETURN 0
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 99999999
END CATCH
GO