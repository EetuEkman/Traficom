CREATE DATABASE Traficom
GO

USE [Traficom]
GO

/****** Object:  UserDefinedFunction [dbo].[GetBodyId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetBodyId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	IF @code IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[KORITYYPPI]
		WHERE KOODINTUNNUS IS NULL
	END
	ELSE
	BEGIN
		SELECT @id = Id
		FROM dbo.[KORITYYPPI]
		WHERE KOODINTUNNUS = @code
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetCabinId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetCabinId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	IF @code IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[OHJAAMOTYYPPI]
		WHERE KOODINTUNNUS IS NULL
	END
	ELSE
	BEGIN
		SELECT @id = Id
		FROM dbo.[OHJAAMOTYYPPI]
		WHERE KOODINTUNNUS = @code
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetClassId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetClassId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	SELECT @id = Id
	FROM dbo.AJONEUVOLUOKKA
	WHERE KOODINTUNNUS = @code

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetColorId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetColorId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	IF @code IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[VARI]
		WHERE KOODINTUNNUS IS NULL
	END
	ELSE
	BEGIN
		SELECT @id = Id
		FROM dbo.[VARI]
		WHERE KOODINTUNNUS = @code
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetGroupId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetGroupId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int
	
	SELECT @id = Id
	FROM dbo.[AJONEUVORYHMÄ]
	WHERE ryhma = @code

	IF @id IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[AJONEUVORYHMÄ]
		WHERE ryhma IS NULL
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetMotivePowerId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetMotivePowerId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	IF @code IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[KAYTTOVOIMA]
		WHERE KOODINTUNNUS IS NULL
	END
	ELSE
	BEGIN
		SELECT @id = Id
		FROM dbo.[KAYTTOVOIMA]
		WHERE KOODINTUNNUS = @code
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetUsageId]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetUsageId]
(
	@code nvarchar(64)
)
RETURNS int
AS
BEGIN
	DECLARE @id int

	IF @code IS NULL
	BEGIN
		SELECT @id = Id
		FROM dbo.[AJONEUVON KAYTTO]
		WHERE KOODINTUNNUS IS NULL
	END
	ELSE
	BEGIN
		SELECT @id = Id
		FROM dbo.[AJONEUVON KAYTTO]
		WHERE KOODINTUNNUS = @code
	END

	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[ToDate]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ToDate] (@dateString nvarchar(64))
RETURNS date
AS
BEGIN
	DECLARE @date date

	SET @date = TRY_CONVERT(date, @dateString)

	RETURN @date
END
GO
/****** Object:  UserDefinedFunction [dbo].[ValidateClassCode]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ValidateClassCode]
(
	@classCode nvarchar(64), 
	@groupCode nvarchar(64)
)
RETURNS @returnTable table
	(
		HasErrors bit,
		ErrorDescription nvarchar(255)
	)
AS
BEGIN
	DECLARE @hasErrors bit,
		@errorDescription nvarchar(255)

	SET @hasErrors = 0
	SET @errorDescription = ''

	IF @classCode != 'Muu'
	BEGIN
		IF @groupCode IS NULL
		BEGIN
			SET @hasErrors = 1
			SET @errorDescription += 'If the vehicle class code is not "Muu", the vehicle group code is mandatory. '
		END
	END

	INSERT INTO @returnTable 
	(
		HasErrors,
		ErrorDescription
	)
	VALUES
	(
		@hasErrors,
		@errorDescription
	) 

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[ValidateDates]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ValidateDates]
(
	@registerationDateString nvarchar(64),
	@introductionDateString nvarchar(64)
)
RETURNS @dateValidationTable table
(
	RegisterationDate date NULL,
	IntroductionDate date NULL,
	HasErrors bit,
	ErrorDescription nvarchar(255)
)
AS
BEGIN
	DECLARE @hasErrors bit,
		@errorDescription nvarchar(255),
		@registerationDate date,
		@introductionDate date

	SET @hasErrors = 'false'
	
	SET @introductionDate = dbo.ToDate(@introductionDateString)
	SET @registerationDate = dbo.ToDate(@registerationDateString)

	IF @registerationDate IS NULL AND @introductionDate IS NULL
	BEGIN
		SET @hasErrors = 'true'
		SET @errorDescription = 'Both the date of registration and the date of introduction are missing or invalid. '
	END
	ELSE IF @registerationDate IS NULL AND @introductionDate IS NOT NULL
	BEGIN
		SET @registerationDate = @introductionDate
	END
	ELSE IF @registerationDate IS NOT NULL AND @introductionDate IS NULL
	BEGIN
		SET @introductionDate = @registerationDate
	END

	INSERT INTO @dateValidationTable
	(
		RegisterationDate,
		IntroductionDate,
		HasErrors,
		ErrorDescription
	)
	VALUES
	(
		@introductionDate,
		@registerationDate,
		@hasErrors,
		@errorDescription
	)

	RETURN
END
GO
/****** Object:  Table [dbo].[AJONEUVOLUOKKA]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AJONEUVOLUOKKA](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[LYHYTSELITE] [nvarchar](max) NULL,
	[PITKASELITE] [nvarchar](max) NULL,
	[LYHYTSELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[LYHYTSELITE_en] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_AJONEUVOLUOKKA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AJONEUVON KAYTTO]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AJONEUVON KAYTTO](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[LYHYTSELITE_fi] [nvarchar](max) NULL,
	[PITKASELITE_fi] [nvarchar](max) NULL,
	[LYHYTSELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[LYHYTSELITE_en] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_AJONEUVON KAYTTO] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AJONEUVORYHMÄ]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AJONEUVORYHMÄ](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ryhma] [nvarchar](max) NULL,
	[PITKASELITE_fi] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_AJONEUVORYHMÄ] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Errors]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Errors](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ajoneuvoluokka_id] [bigint] NOT NULL,
	[ensirekisterointipvm] [date] NULL,
	[ajoneuvoryhma_id] [bigint] NOT NULL,
	[ajoneuvonkaytto_id] [bigint] NOT NULL,
	[variantti] [nvarchar](64) NULL,
	[versio] [nvarchar](64) NULL,
	[kayttoonottopvm] [date] NULL,
	[vari_id] [bigint] NOT NULL,
	[ovienLukumaara] [bigint] NULL,
	[korityyppi_id] [bigint] NOT NULL,
	[ohjaamotyyppi_id] [bigint] NOT NULL,
	[istumapaikkojenLkm] [bigint] NULL,
	[omamassa] [bigint] NULL,
	[teknSuurSallKokmassa] [bigint] NULL,
	[selite] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KAYTTOVOIMA]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KAYTTOVOIMA](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[SELITE_fi] [nvarchar](max) NULL,
	[SELITE_sv] [nvarchar](max) NULL,
	[SELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_KAYTTOVOIMA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KORITYYPPI]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KORITYYPPI](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[PITKASELITE_fi] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_KORITYYPPI] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[kunta]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kunta](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[PITKASELITE_fi] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_kunta] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OHJAAMOTYYPPI]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OHJAAMOTYYPPI](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[LYHYTSELITE] [nvarchar](max) NULL,
	[LYHYTSELITE1] [nvarchar](max) NULL,
	[LYHYTSELITE2] [nvarchar](max) NULL,
 CONSTRAINT [PK_OHJAAMOTYYPPI] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sähköhybridin luokka]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sähköhybridin luokka](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[koodi] [nvarchar](max) NULL,
	[selite] [nvarchar](max) NULL,
 CONSTRAINT [PK_sähköhybridin luokka] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VARI]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VARI](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[KOODINTUNNUS] [nvarchar](max) NULL,
	[PITKASELITE_fi] [nvarchar](max) NULL,
	[PITKASELITE_sv] [nvarchar](max) NULL,
	[PITKASELITE_en] [nvarchar](max) NULL,
 CONSTRAINT [PK_VARI] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehicles]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicles](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ajoneuvoluokka_id] [bigint] NOT NULL,
	[ensirekisterointipvm] [date] NULL,
	[ajoneuvoryhma_id] [bigint] NOT NULL,
	[ajoneuvonkaytto_id] [bigint] NULL,
	[variantti] [nvarchar](64) NULL,
	[versio] [nvarchar](64) NULL,
	[kayttoonottopvm] [date] NULL,
	[vari_id] [bigint] NOT NULL,
	[ovienLukumaara] [bigint] NULL,
	[korityyppi_id] [bigint] NOT NULL,
	[ohjaamotyyppi_id] [bigint] NOT NULL,
	[istumapaikkojenLkm] [bigint] NULL,
	[omamassa] [bigint] NULL,
	[teknSuurSallKokmassa] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[AJONEUVOLUOKKA] ON 

INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (1, N'C1', N'Traktori', N'Telaketjutraktori, v <= 40 km/h, m > 600 kg, maavara <= 1000 mm', N'Traktor', N'Bandtraktor, v <= 40 km/h, m > 600 kg, markfria gång <= 1000 mm', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (2, N'C2', N'Traktori', N'Telaketjutraktori, v <= 40 km/h, m > 600 kg, maavara <= 600 mm', N'Traktor', N'Bandtraktor, v <= 40 km/h, m > 600 kg, markfria gång <= 600 mm', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (3, N'C3', N'Traktori', N'Telaketjutraktori, v <= 40 km/h, m <= 600 kg', N'Traktor', N'Bandtraktor, v <= 40 km/h, m <= 600 kg', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (4, N'C4', N'Traktori', N'Erityiskäyttöön tarkoitettu telaketjutraktori, v <= 40 km/h', N'Traktor', N'Bandtraktor konstruerad för ett särskilt ändamål, v <= 40 km/h', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (5, N'C5', N'Traktori', N'Telaketjutraktori, v > 40 km/h', N'Traktor', N'Bandtraktor, v > 40 km/h', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (6, N'KNP', N'Kevyt nelipyörä', N'Nelipyöräinen ajoneuvo, m (kuormittamaton) <= 350 kg, v <= 45 km/h, Vi <= 50 cm3', N'Lätt fyrhjuling', N'Fyrhjuligt fordon, m (olastad) <= 350 kg, v <= 45 km/h, Vi <= 50 cm3', N'Light quadricycle', N'Light quadricycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (7, N'L1', N'Mopo', N'Kaksipyöräinen ajoneuvo, Vi <= 50 cm3, v <= 45 km/h', N'Moped', N'Tvåhjuligt fordon, Vi <= 50 cm3, v <= 45 km/h', N'Moped', N'Moped')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (8, N'L1e', N'Mopo', N'Kaksipyöräinen ajoneuvo, v <= 45 km/h, Vi <= 50 cm3', N'Moped', N'Tvåhjuligt fordon, v <= 45 km/h, Vi <= 50 cm3', N'Moped', N'Moped')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (9, N'L2', N'Mopo', N'Kolmipyöräinen ajoneuvo, Vi <= 50 cm3, v <= 45 km/h', N'Moped', N'Trehjuligt fordon, Vi <= 50 cm3, v <= 45 km/h', N'Moped', N'Moped')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (10, N'L2e', N'Mopo', N'Kolmipyöräinen ajoneuvo, v <= 45 km/h, Vi <= 50 cm3', N'Moped', N'Trehjuligt fordon, v <= 45 km/h, Vi <= 50 cm3', N'Moped', N'Moped')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (11, N'L3', N'Moottoripyörä', N'Kaksipyöräinen moottoripyörä, Vi > 50 cm3 ja/tai v > 45 km/h,', N'Motorcykel', N'Tvåhjuligt fordon, Vi > 50 cm3 och/eller v > 45 km/h,', N'Motorcycle', N'Motorcycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (12, N'L3e', N'Moottoripyörä', N'Kaksipyöräinen ajoneuvo, Vi > 50 cm3 ja/tai v > 45 km/h,', N'Motorcykel', N'Tvåhjuligt fordon, Vi > 50 cm3 och/eller v > 45 km/h', N'Motorcycle', N'Motorcycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (13, N'L4', N'Moottoripyörä', N'Kaksipyöräinen, sivuvaunullinen moottoripyörä, Vi > 50 cm3 ja/tai v > 45 km/h', N'Motorcykel', N'Tvåhjuligt fordon med sidvagn, Vi > 50 cm3 ja/tai v > 45 km/h', N'Motorcycle', N'Motorcycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (14, N'L4e', N'Moottoripyörä', N'Kaksipyöräinen, sivuvaunullinen moottoripyörä, Vi > 50 cm3 ja/tai v > 45 km/h', N'Motorcykel', N'Tvåhjuligt fordon med sidvagn, Vi > 50 cm3 och/eller v > 45 km/h', N'Motorcycle', N'Motorcycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (15, N'L5', N'Kolmi- tai nelipyörä', N'Kolmipyöräinen ajoneuvo, Vi > 50 cm3, v > 45 km/h, pyörät symmetrisesti keskiakselin suhteen, m <= 1000 kg TAI nelipyöräinen ajoneuvo, Vi > 50 cm3, v > 45 km/h, m (kuormittamaton) < 400 kg tai m (kuormittamaton) < 550 kg tavarankuljetuskäytössä, P <= 15 k', N'Tre- eller fyrhjuling', N'Trehjuligt fordon, Vi > 50 cm3, v > 45 km/h, hjul är symmetriskt placerade i förhållande till fordonets mittaxel, m <= 1000 kg ELLER ett fyrhjuligt fordon, Vi > 50 cm3, v > 45 km/h, m (olastad) < 400 kg tai m (olastad) < 550 kg, när avsett för godstranspo', N'Motor tricycle or quadricycle', N'Motor tricycle or quadricycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (16, N'L5e', N'Kolmipyörä', N'Kolmipyörä, Vi > 50 cm3, v > 45 km/h', N'Trehjuling', N'Trehjuligt fordon, Vi > 50 cm3, v > 45 km/h', N'Motor tricycle', N'Motor tricycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (17, N'L6e', N'Kevyt nelipyörä', N'Kevyt nelipyörä, m <= 350 kg (kuormittamaton), v <= 45 km/h', N'Lätt fyrhjuling', N'Fyrhjuligt fordon, m <= 350 kg (olastad), v <= 45 km/h', N'Light quadricycle', N'Light quadricycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (18, N'L7e', N'Nelipyörä', N'Nelipyörä, m <= 400 kg (kuormittamaton), P <= 15 kW', N'Fyrhjuling', N'Fyrhjuligt fordon, m <= 400 kg (olastad), P <= 15 kW', N'Quadricycle', N'Quadricycle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (19, N'LTR', N'Liikennetraktori', N'Tavarankuljetukseen tarkoitettu kuormaa kantava nestepainetoimisella runko-ohjauksella varustettu traktori, v <= 50 km/h.', N'Trafiktraktor', N'En lastbärande traktor med hydraulisk ledramstyrning som är avsedd för godstransport, v <= 50 km/h.', N'Tractor registered for road use', N'Tractor registered for road use')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (20, N'M1', N'Henkilöauto', N'Matkustajien kuljettamiseen valmistettu ajoneuvo, tilaa kuljettajan lisäksi enintään kahdeksalle matkustajalle', N'Personbil', N'Ett för persontransport tillverkat fordon med plats för högst åtta personer utöver föraren', N'Car', N'Car')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (21, N'M1G', N'Henkilöauto', N'Matkustajien kuljettamiseen valmistettu maastoauto, tilaa kuljettajan lisäksi enintään kahdeksalle matkustajalle', N'Personbil', N'En för persontransport tillverkad terrängbil med plats för högst åtta personer utöver föraren', N'Car', N'Car')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (22, N'M2', N'Linja-auto', N'Matkustajien kuljettamiseen valmistettu ajoneuvo, tilaa kuljettajan lisäksi yli kahdeksalle matkustajalle, m <= 5000 kg', N'Buss', N'Ett för persontransport tillverkat fordon med plats för fler än åtta personer utöver föraren, m <= 5000 kg', N'Bus/coach', N'Bus/coach')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (23, N'M2G', N'Linja-auto', N'Matkustajien kuljettamiseen valmistettu maastoauto, tilaa kuljettajan lisäksi yli kahdeksalle matkustajalle, m <= 5000 kg', N'Buss', N'En för persontransport tillverkad terrängbil med plats för fler än åtta personer utöver föraren, m <= 5000 kg', N'Bus/coach', N'Bus/coach')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (24, N'M3', N'Linja-auto', N'Matkustajien kuljettamiseen tarkoitettu ajoneuvo, tilaa kuljettajan lisäksi yli kahdeksalle matkustajalle, m > 5000 kg', N'Buss', N'Ett för persontransport tillverkat fordon med plats för fler än åtta personer utöver föraren, m > 5000 kg', N'Bus/coach', N'Bus/coach')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (25, N'M3G', N'Linja-auto', N'Matkustajien kuljettamiseen valmistettu maastoauto, tilaa kuljettajan lisäksi yli kahdeksalle matkustajalle, m > 5000 kg', N'Buss', N'En för persontransport tillverkad terrängbil med plats för fler än åtta personer utöver föraren, m > 5000 kg', N'Bus/coach', N'Bus/coach')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (26, N'MA', N'Maastoajoneuvo', N'Henkilöiden tai tavaran kuljetukseen tarkoitettu jäällä, lumessa tai vajottavassa maastossa tai maahan tukeutuen kulkemaan valmistettu moottorikäyttöinen ajoneuvo', N'Terrängfordon', N'Fordon tillverkat för person- eller godstransport eller för dragning av andra fordon på is, i snö eller på sank mark eller för färd med marken som stöd', N'All-terrain vehicle', N'All-terrain vehicle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (27, N'MTK', N'Moottorityökone', N'Työkoneeksi valmistettu tai varustettava ajoneuvo, v <= 40 km/h; tienpitoon tarkoitettu muu moottorikäyttöinen ajoneuvo kuin auto; vetotrukki, v <= 50 km/h', N'Motorredskap', N'Fordon som tillverkats eller är avsett att utrustas som arbetsmaskin, v <= 40 km/h; ett för väghållningsarbete tillverkat annat motordrivet fordon än en bil; en dragtruck, v <= 50 km/h', N'Public works vehicle', N'Public works vehicle')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (28, N'N1', N'Pakettiauto', N'Tavaroiden kuljettamiseen valmistettu ajoneuvo, m <= 3500 kg', N'Paketbil', N'Ett för godstransport tillverkat fordon, m <= 3500 kg', N'Van', N'Van')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (29, N'N1G', N'Pakettiauto', N'Tavaroiden kuljettamiseen valmistettu maastoauto, m <= 3500 kg', N'Paketbil', N'En för godstransport tillverkad terrängbil, m <= 3500 kg', N'Van', N'Van')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (30, N'N2', N'Kuorma-auto', N'Tavaroiden kuljettamiseen valmistettu ajoneuvo, 3500 < m <= 12000 kg', N'Lastbil', N'Ett för godstransport tillverkat fordon, 3500 < m <= 12000 kg', N'Lorry', N'Lorry')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (31, N'N2G', N'Kuorma-auto', N'Tavaroiden kuljettamiseen valmistettu maastoauto, 3500 < m <= 12000 kg', N'Lastbil', N'En för godstransport tillverkad terrängbil, 3500 < m <= 12000 kg', N'Lorry', N'Lorry')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (32, N'N3', N'Kuorma-auto', N'Tavaroiden kuljettamiseen valmistettu ajoneuvo, m > 12000 kg', N'Lastbil', N'Ett för godstransport tillverkat fordon, m > 12000 kg', N'Lorry', N'Lorry')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (33, N'N3G', N'Kuorma-auto', N'Tavaroiden kuljettamiseen valmistettu maastoauto, m > 12000 kg', N'Lastbil', N'En för godstransport tillverkad terrängbil, m > 12000 kg', N'Lorry', N'Lorry')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (34, N'O1', N'Kevyt perävaunu', N'Perävaunu, m <= 750 kg', N'Lätt släpvagn', N'Släpvagn, m <= 750 kg', N'Light trailer', N'Light trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (35, N'O2', N'Perävaunu', N'Perävaunu, 750 < m <= 3500 kg', N'Släpvagn', N'Släpvagn, 750 < m <= 3500 kg', N'Trailer', N'Trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (36, N'O3', N'Perävaunu', N'Perävaunu, 3500 < m <= 10000 kg', N'Släpvagn', N'Släpvagn, 3500 < m <= 10000 kg', N'Trailer', N'Trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (37, N'O4', N'Perävaunu', N'Perävaunu, m > 10000 kg', N'Släpvagn', N'Släpvagn, m > 10000 kg', N'Trailer', N'Trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (38, N'Ra1', N'Traktorin perävaunu', N'Traktorin perävaunu, m <= 1500 kg, v <= 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, m <= 1500 kg, v <= 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (39, N'Ra2', N'Traktorin perävaunu', N'Traktorin perävaunu, 1500 < m <= 3500 kg, v <= 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, 1500 < m <= 3500 kg, v <= 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (40, N'Ra3', N'Traktorin perävaunu', N'Traktorin perävaunu, 3500 < m <= 21000 kg, v <= 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, 3500 < m <= 21000 kg, v <= 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (41, N'Ra4', N'Traktorin perävaunu', N'Traktorin perävaunu, m > 21000 kg, v <= 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, m > 21000 kg, v <= 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (42, N'Rb1', N'Traktorin perävaunu', N'Traktorin perävaunu, m <= 1500 kg, v > 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, m <= 1500 kg, v > 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (43, N'Rb2', N'Traktorin perävaunu', N'Traktorin perävaunu, 1500 < m <= 3500 kg, v > 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, 1500 < m <= 3500 kg, v > 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (44, N'Rb3', N'Traktorin perävaunu', N'Traktorin perävaunu, 3500 < m <= 21000 kg, v > 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, 3500 < m <= 21000 kg, v > 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (45, N'Rb4', N'Traktorin perävaunu', N'Traktorin perävaunu, m > 21000 kg, v > 40 km/h', N'Traktorsläpvagn', N'Traktorsläpvagn, m > 21000 kg, v > 40 km/h', N'Tractor trailer', N'Tractor trailer')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (46, N'Sa1', N'Vedettävä kone', N'Vedettävä vaihdettavissa oleva kone, m <= 3500 kg, v <= 40 km/h', N'Dragen maskin', N'Utbytbar dragen maskin, m <= 3500 kg, v <= 40 km/h', N'Towed machinery', N'Towed machinery')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (47, N'Sa2', N'Vedettävä kone', N'Vedettävä vaihdettavissa oleva kone, m > 3500 kg, v <= 40 km/h', N'Dragen maskin', N'Utbytbar dragen maskin, m > 3500 kg, v <= 40 km/h', N'Towed machinery', N'Towed machinery')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (48, N'Sb1', N'Vedettävä kone', N'Vedettävä vaihdettavissa oleva kone, m <= 3500 kg, v > 40 km/h', N'Dragen maskin', N'Utbytbar dragen maskin, m <= 3500 kg, v > 40 km/h', N'Towed machinery', N'Towed machinery')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (49, N'Sb2', N'Vedettävä kone', N'Vedettävä vaihdettavissa oleva kone, m > 3500 kg, v > 40 km/h', N'Dragen maskin', N'Utbytbar dragen maskin, m > 3500 kg, v > 40 km/h', N'Towed machinery', N'Towed machinery')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (50, N'T', N'Traktori', N'Pyörin tai teloin varustettu ajoneuvo; valmistettu vetämään, työntämään, käyttämään tai kuljettamaan maa- ja metsätalouden työvälineitä tai työntämään maa- ja metsätalouden ajoneuvoja, v <= 40 km/h', N'Traktor', N'Ett fordon med hjul eller band; tillverkats för att dra, skjuta, använda eller transportera för jord- och skogsbruk avsedda arbetsredskap eller för att dra eller skjuta fordon som används för jord- och skogsbruk, v <= 40 km/h.', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (51, N'T1', N'Traktori', N'Pyörillä varustettu traktori, v <= 40 km/h, m > 600 kg, maavara <= 1000 mm', N'Traktor', N'Hjultraktor, v <= 40 km/h, m > 600 kg, markfria gång <= 1000 mm', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (52, N'T2', N'Traktori', N'Pyörillä varustettu traktori, v < 40 km/h, m > 600 kg, maavara < 600 mm', N'Traktor', N'Hjultraktor, v <= 40 km/h, m > 600 kg, markfria gång <= 600 mm', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (53, N'T3', N'Traktori', N'Pyörillä varustettu traktori, v <= 40 km/h, m <= 600 kg', N'Traktor', N'Hjultraktor, v <= 40 km/h, m <= 600 kg', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (54, N'T4', N'Traktori', N'Erityiskäyttöön tarkoitettu pyörillä varustettu traktori, v <= 40 km/h', N'Traktor', N'Hjultraktor konstruerad för ett särskilt ändamål, v <= 40 km/h', N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (55, N'T5', N'Traktori', N'Pyörillä varustettu traktori, v > 40 km/h', NULL, NULL, N'Tractor', N'Tractor')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (56, NULL, N'Tuntematon', N'Tuntematon', N'Ökand', N'Okand', N'Unknown', N'Unknown')
INSERT [dbo].[AJONEUVOLUOKKA] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [PITKASELITE], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (57, N'Muu', N'Muu', N'Muu', N'Andra', N'Andra', N'Other', N'Other')
SET IDENTITY_INSERT [dbo].[AJONEUVOLUOKKA] OFF
SET IDENTITY_INSERT [dbo].[AJONEUVON KAYTTO] ON 

INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (1, N'01', N'Yksityinen', N'Yksityinen (LTJ = 1)', N'Privat', N'Privat', N'Private', N'Private')
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (2, N'02', N'Luvanvarainen', N'Luvanvarainen (LTJ = 2)', N'Tillståndspliktig', N'Tillståndspliktig', N'Subject to permit', N'Subject to permit')
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (3, N'03', N'Kouluajoneuvo', N'Kouluajoneuvo (LTJ = 3)', N'Skolfordon', N'Skolfordon', N'School vehicle', N'School vehicle')
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (4, N'04', N'Vuokraus ilman kuljettajaa', N'Vuokraus ilman kuljettajaa (LTJ = 4)', N'Uthyrning utan förare', N'Uthyrning utan förare', N'Rental without driver', N'Rental without driver')
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (5, N'05', N'Myyntivarasto', N'Myyntivarasto (varastovakuutus) (LTJ = 5)', N'Försäljningslager (lagerförsäkring)', N'Försäljningslager (lagerförsäkring)', N'Sales storage', N'Sales storage')
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (6, N'06', N'Luvanvarainen tavaraliikenne', N'Luvanvarainen tavaraliikenne', N'Tillståndspliktig godstrafik', N'Tillståndspliktig godstrafik', NULL, NULL)
INSERT [dbo].[AJONEUVON KAYTTO] ([Id], [KOODINTUNNUS], [LYHYTSELITE_fi], [PITKASELITE_fi], [LYHYTSELITE_sv], [PITKASELITE_sv], [LYHYTSELITE_en], [PITKASELITE_en]) VALUES (7, NULL, N'Tuntematon', N'Tuntematon', N'Ökand', N'Ökand', N'Unknown', N'Unknown')
SET IDENTITY_INSERT [dbo].[AJONEUVON KAYTTO] OFF
SET IDENTITY_INSERT [dbo].[AJONEUVORYHMÄ] ON 

INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (1, N'1', N'Kevyt tavarankuljetusperävaunu', N'Lätt varutransport släpvagn', N'Light goods trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (2, N'10', N'Ajoneuvonkuljetusperävaunu, kokm >750kg', N'Fordontransportsläpvagn, totm > 750kg', N'Vehicle transport trailer, total mass >750 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (3, N'100', N'Ruohonleikkuukone', N'Gräsklippningsmaskin', N'Lawnmower')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (4, N'101', N'Jäänhoitokone', N'Isskötselmaskin', N'Ice resurfacer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (5, N'102', N'Konttinosturi', N'Containerlyftkran', N'Container crane')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (6, N'103', N'Betonisekoitin', N'Betongblandare', N'Concrete mixer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (7, N'104', N'Monitoimikone', N'Mångsysslomaskin', N'Harvester')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (8, N'105', N'Lumiaura-harjapuhallin', N'Plog-sopblåsmaskin', N'Snow plough/blower')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (9, N'106', N'Moottorireki', N'Motorsläde', N'Snowmobile')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (10, N'107', N'Moottorikelkka', N'Snöskoter', N'Ski-doo')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (11, N'108', N'Kevyt moottoripyörä', N'Lätt motorcykel', N'Light motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (12, N'109', N'2-pyöräinen', N'Tvåhjuling', N'Motor bicycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (13, N'110', N'3-pyöräinen', N'Trehjuling', N'Motor tricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (14, N'111', N'2-pyöräinen tavarapyörä', N'Tvåhjulig varucykell', N'Cargo bicycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (15, N'112', N'3-pyöräinen tavarapyörä', N'Trehjulig varucykel', N'Cargo tricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (16, N'113', N'Invalidipyörä', N'Invalidcykel', N'Disabled moped')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (17, N'114', N'Sivuvaunumoottoripyörä', N'Motorcykel med sidvagn', N'Motorcycle with sidecar')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (18, N'115', N'Kevyt nelipyörä', N'Lätt fyrhjuling', N'Light quadricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (19, N'116', N'Nelipyörä', N'Fyrhjuling', N'Quadricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (20, N'117', N'Varsinaisen perävaunun vetoajoneuvo', N'Dragbil för egentlig släpvagn', N'Towing vehicle for drawbar trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (21, N'118', N'Puoliperävaunun vetoauto', N'Dragbil för påhängsvagn', N'Towing vehicle for semi trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (22, N'119', N'Keskiakseliperävaunun vetoauto', N'Dragbil för medelaxelsläpvagn', N'Towing vehicle for centre-axle trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (23, N'12', N'Varsinainen perävaunu, (ka)', N'Egentlig släpvagn, (lb)', N'Drawbar trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (24, N'120', N'Auton alustalle rakennettu työkone', N'Motorredskap som byggts på bilunderrede', N'Machinery mounted on a vehicle chassis')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (25, N'121', N'Alusta', N'Chassis', N'Chassis')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (26, N'122', N'Matkatyöperävaunu', N'Researbetssläpvagn', N'Work caravan')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (27, N'123', N'Betoninkuljetusauto', N'Betongtransportbil', N'Concrete transport lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (28, N'124', N'Jätteenkuljetusauto', N'Sopbil', N'Refuse transport lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (29, N'125', N'Koneenkuljetusauto', N'Maskintransportbil', N'Machinery transport lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (30, N'126', N'Nelipyöräinen', N'Fyrhjuling', N'Quadricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (31, N'127', N'Hihnakuljetinauto', N'Remtransportörbil', N'Conveyor belt lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (32, N'128', N'Rinnekone', N'Pistmaskin', N'Piste machine')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (33, N'129', N'Hitsausauto', N'Svetsningsbil', N'Welding vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (34, N'13', N'Keskiakseliperävaunu', N'Släpvagn med centralaxel', N'Centre-axle trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (35, N'130', N'Kaapelikelan kuljetusperävaunu', N'Kabeltrummasläpvagn', N'Cable drum trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (36, N'131', N'Esteetön taksiauto', N'Tillgänglig taxibil', N'Accessible taxi')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (37, N'132', N'Hinattava laite', N'Släpanordning', N'Towed machinery')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (38, N'133', N'Eläintenkuljetusperävaunu', N'Djurtransportsläpvagn', N'Animal transport trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (39, N'134', N'Pieni esteetön ajoneuvo', N'Litet tillgängligt fordon', N'Small accessible vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (40, N'135', N'Suuri esteetön ajoneuvo', N'Stort tillgängligt fordon', N'Large accessible vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (41, N'136', N'Autoverovapaa esteetön ajoneuvo', N'Bilskattefritt tillgängligt fordon', N'Tax exempt accessible vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (42, N'137', N'Autoverovapaa koulu- ja päivähoitokuljetusajoneuvo', N'Bilskattefritt fordon för transport av skol- och dagvårdsbarn', N'Tax exempt vehicle for school and day care transport')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (43, N'14', N'Puoliperävaunu', N'Påhängsvagn', N'Semi-trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (44, N'15', N'Erikoiskuljetusperävaunu', N'Specialtransportsläpvagn', N'Exceptional load transport trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (45, N'16', N'Erikoiskuljetuspuoliperävaunu', N'Specialtransportpåhängsvagn', N'Exceptional load transport semi-trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (46, N'17', N'Varsinainen säiliöperävaunu', N'Egentlig tanksläpvagn', N'Drawbar tanker trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (47, N'18', N'Säiliöpuoliperävaunu', N'Tankpåhängsvagn', N'Tanker semi-trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (48, N'19', N'Dolly', N'Dolly', N'Dolly')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (49, N'2', N'Kevyt veneenkuljetusperävaunu', N'Lätt båttrailer', N'Light boat trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (50, N'20', N'Kevytperävaunu', N'Lätt släpvagn', N'Light trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (51, N'21', N'Museoajoneuvo', N'Museifordon', N'Historic vintage vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (52, N'22', N'Myymäläauto', N'Butikbil', N'Shopmobile')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (53, N'23', N'Nosturiauto', N'Kranbil', N'Crane lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (54, N'24', N'Invataksi', N'Invataxi', N'Disabled taxi')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (55, N'25', N'Säiliöauto', N'Tankbil', N'Tanker truck')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (56, N'27', N'Nosturiauton alusta', N'Kranbils chassi', N'Crane lorry chassis')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (57, N'28', N'Hevosenkuljetusauto', N'Hästtransportbil', N'Horse lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (58, N'29', N'Matkailuauto', N'Campingbil', N'Motor caravan')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (59, N'3', N'Kevyt telttaperävaunu', N'Lätt tältsläpvagn', N'Light tent trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (60, N'30', N'Eläintenkuljetusauto', N'Djurtransportbil', N'Animal transport vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (61, N'31', N'Rikka-auto', N'Avskrädebil', N'Vacuum cleaner vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (62, N'32', N'Pelastusauto', N'Räddningsbil', N'Rescue vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (63, N'33', N'Sairasauto', N'Ambulans', N'Ambulance')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (64, N'34', N'Poliisiajoneuvo', N'Polisfordon', N'Police vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (65, N'35', N'Pienoislinja-auto', N'Minibus', N'Minibus')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (66, N'36', N'Betonipumppuauto', N'Betongpumpsbil', N'Concrete pump truck')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (67, N'37', N'Nivellinja-auto', N'Ledad buss', N'Articulated bus')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (68, N'38', N'Nivellinja-auto (kaksikerroksinen)', N'Ledad tvåvåningsbuss', N'Articulated bus (double-deck)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (69, N'39', N'Linja-auto (kaksikerroksinen)', N'Tvåvåningsbuss', N'Bus/coach (double-deck)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (70, N'4', N'Kevyt moottoripyöränkuljetusperävaunu', N'Lätt motorcykeltransportsläpvagn', N'Light motorcycle trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (71, N'40', N'Alaluokka I (M2/M3)', N'Klass I (M2/M3)', N'Class I (M2/M3)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (72, N'41', N'Alaluokka II (M2/M3)', N'Klass II (M2/M3)', N'Class II (M2/M3)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (73, N'42', N'Alaluokka III (M2/M3)', N'Klass III (M2/M3)', N'Class III (M2/M3)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (74, N'43', N'Alaluokka A', N'Klass A', N'Class A')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (75, N'44', N'Alaluokka B', N'Klass B', N'Class B')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (76, N'45', N'Alaluokka I (matalalattialinja-auto)', N'Klass I (låggolvsbuss)', N'Class I (low-floor bus)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (77, N'46', N'Alaluokka II (matalalattialinja-auto)', N'Klass II (låggolvsbuss)', N'Class II (low-floor bus)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (78, N'47', N'Alaluokka A (matalalattialinja-auto)', N'Klass A (låggolvsbuss)', N'Class III (low-floor bus)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (79, N'48', N'Ruumisauto', N'Likbil', N'Hearse')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (80, N'49', N'Maastoauto', N'Terrängbil', N'Off-road car')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (81, N'5', N'Kevyt lentokoneenkuljetusperävaunu', N'Lätt transportsläpvagn för flygplan', N'Light aircraft trailer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (82, N'51', N'Nosturiauto', N'Kranbil', N'Crane lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (83, N'52', N'Lakaisuauto', N'Sopningsbil', N'Street sweeper')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (84, N'53', N'Hinausauto', N'Bogserbil', N'Tow truck')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (85, N'54', N'Kaivukoneauto', N'Grävmaskinsbil', N'Digger lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (86, N'55', N'Porausauto', N'Borrningsbil', N'Drilling lorry')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (87, N'56', N'Huoltoauto', N'Servicebil', N'Service vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (88, N'57', N'Lumilinko', N'Snöslunga', N'Snow blower')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (89, N'58', N'Pankkiauto', N'Bankbil', N'Security van')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (90, N'59', N'Viemärin/putkiston korjausauto', N'Kloaks/rörnätetsrepareringsbil', N'Sewer/pipe repair vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (91, N'6', N'Tavarankuljetusperävaunu, kokm > 750kg', N'Varutransportsläpvagn, tom > 750 kg', N'Goods trailer, total mass >750 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (92, N'60', N'Rehulaitosauto', N'Foderinrättningsbil', N'Animal feed transport vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (93, N'62', N'Nostokoriauto', N'Bil med lyftkorg', N'Vehicle with lifting cage')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (94, N'63', N'Imuauto', N'Sugningsbil', N'Suction unit vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (95, N'64', N'Polyuretaanin ruiskutusauto', N'Sprutbil för polyuretan', N'Polyurethane injection vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (96, N'65', N'Näyttelyauto', N'Utställningsbil', N'Exhibition vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (97, N'66', N'Mittausauto', N'Mätningsbil', N'Measuring vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (98, N'67', N'TV/radioauto', N'TV/radiobil', N'TV/radio vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (99, N'68', N'Eläinlääkintäauto', N'Veterinärbil', N'Veterinarian vehicle')
GO
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (100, N'69', N'Kahden toiminnan erikoisauto', N'Specialbil med två funktioner', N'Twin-function special vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (101, N'7', N'Veneenkuljetusperävaunu, kokm > 750kg', N'Båttrailer, totm > 750 kg', N'Boat trailer, total mass >750 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (102, N'70', N'Kirjastoauto', N'Biblioteksbil', N'Mobile library')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (103, N'71', N'Kaksikäyttöauto', N'Bil avsedd för två ändamål', N'Dual-purpose vehicle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (104, N'72', N'Alaluokka I (N1)', N'Klass I (N1)', N'Class I (N1)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (105, N'73', N'Alaluokka II (N1)', N'Klass II (N1)', N'Class II (N1)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (106, N'74', N'Alaluokka III (N1)', N'Klass III (N1)', N'Class III (N1)')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (107, N'75', N'Maataloustraktori', N'Lantbrukstraktor', N'Agricultural tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (108, N'76', N'Puutarhatraktori', N'Trädgårdstraktor', N'Horticultural tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (109, N'77', N'Maansiirtotraktori', N'Jordtransporttraktor', N'Earth-moving tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (110, N'78', N'Metsätraktori', N'Skogstraktor', N'Forestry tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (111, N'79', N'Teollisuustraktori', N'Industritraktor', N'Industrial tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (112, N'8', N'Hevosenkuljetusperävaunu, kokm > 750kg', N'Hästtransportsläpvagn, totm > 750 kg', N'Horse box, total mass >750 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (113, N'80', N'Kiinteistötraktori', N'Fastighetstraktor', N'Property maintenance tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (114, N'81', N'Liikennetraktori', N'Trafiktraktor', N'Tractor registered for road use')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (115, N'82', N'Haarukkanosturi', N'Gaffeltruck', N'Forklift truck')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (116, N'83', N'Sivuhaarukkanosturi', N'Sidogaffeltruck', N'Side loading forklift truck')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (117, N'84', N'Puomihaarukkanosturi', N'Bomgaffeltruck', N'Forklift truck with crane boom')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (118, N'85', N'Kauhakuormain', N'Skoplastare', N'Shovel loader')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (119, N'86', N'Kourakuormain', N'Griplastare', N'Grapple crane')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (120, N'87', N'Kaivukone', N'Grävmaskin', N'Excavator')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (121, N'88', N'Puominosturi', N'Bomlyftkran', N'Boom crane')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (122, N'89', N'Kauhakuormain-kaivukone', N'Skoplastare-grävmaskin', N'Shovel loader excavator')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (123, N'9', N'Matkailuperävaunu', N'Campingsläpvagn', N'Caravan')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (124, N'90', N'Puomikauhakuormain', N'Bomskoplastare', N'Telehandler excavator')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (125, N'900', N'L3e-A1 pienitehoinen moottoripyörä', N'L3e-A1 motorcykel med låg prestanda', N'L3e-A1 low-performance motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (126, N'901', N'L1e-A moottorilla varustettu polkupyörä', N'L1e-A motordriven cykel', N'L1e-A powered cycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (127, N'902', N'L1e-B kaksipyöräinen mopo', N'L1e-B tvåhjulig moped', N'L1e-B two-wheel moped')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (128, N'903', N'L2e-P kolmipyöräinen henkilömopo', N'L2e-P trehjulig moped konstruerad för passagerarbefordran', N'L2e-P three-wheel moped designed for passenger transport')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (129, N'904', N'L2e-U kolmipyöräinen tavaramopo', N'L2e-U trehjulig moped konstruerad för godsbefordran', N'L2e-U three-wheel moped designed for utility purposes')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (130, N'905', N'L3e-A2 keskitehoinen moottoripyörä', N'L3e-A2 motorcykel med medelhög prestanda', N'L3e-A2 medium-performance motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (131, N'906', N'L3e-A3 suuritehoinen moottoripyörä', N'L3e-A3 motorcykel med hög prestanda', N'L3e-A3 high-performance motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (132, N'907', N'L3e-A1E pienitehoinen enduro-moottoripyörä', N'L3e-A1E enduromotorcykel med låg prestanda', N'L3e-A1E low-performance enduro motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (133, N'908', N'L3e-A2E keskitehoinen enduro-moottoripyörä', N'L3e-A2E enduromotorcykel med medelhög prestanda', N'L3e-A2E medium-performance enduro motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (134, N'909', N'L3e-A3E suuritehoinen enduro-moottoripyörä', N'L3e-A3E enduromotorcykel med hög prestanda', N'L3e-A3E high-performance enduro motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (135, N'91', N'(monitoimi)metsäkone', N'(mångssysslo) skogsmaskin', N'Harvester, forest harvester')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (136, N'910', N'L3e-A1T pienitehoinen trial-moottoripyörä', N'L3e-A1T trialmotorcykel med låg prestanda', N'L3e-A1T low-performance trial motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (137, N'911', N'L3e-A2T keskitehoinen trial-moottoripyörä', N'L3e-A2T trialmotorcykel med medelhög prestanda', N'L3e-A2T medium-performance trial motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (138, N'912', N'L3e-A3T suuritehoinen trial-moottoripyörä', N'L3e-A3T trialmotorcykel med hög prestanda', N'L3e-A3T high-performance trial motorcycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (139, N'913', N'L4e-A1 pienitehoinen sivuvaunullinen kaksipyöräinen moottoripyörä', N'L4e-A1 tvåhjulig motorcykel med sidovagn och med låg prestanda', N'L4e-A1 low-performance two-wheel motorcycle with side-car')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (140, N'914', N'L4e-A2 keskitehoinen sivuvaunullinen kaksipyöräinen moottoripyörä', N'L4e-A2 tvåhjulig motorcykel med sidovagn och med medelhög prestanda', N'L4e-A2 medium-performance two-wheel motorcycle with side-car')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (141, N'915', N'L4e-A3 suuritehoinen sivuvaunullinen kaksipyöräinen moottoripyörä', N'L4e-A3 tvåhjulig motorcykel med sidovagn och med hög prestanda', N'L4e-A3 high-performance two-wheel motorcycle with side-car')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (142, N'916', N'L5e-A kolmipyörä', N'L5e-A trehjuling', N'L5e-A tricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (143, N'917', N'L5e-B hyötykolmipyörä', N'L5e-B trehjuling för nyttotrafik', N'L5e-B commercial tricycle')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (144, N'918', N'L6e-A kevyt maantiemönkijä', N'L6e-A lätt fyrhjuling avsedd för väg', N'L6e-A light on-road quad')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (145, N'919', N'L6e-BP henkilömopoauto', N'L6e-BP lätt mopedbil för passagerarbefordran', N'L6e-BP light quadri-mobile for passenger transport')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (146, N'92', N'Haketuskone', N'Flisningsmaskin', N'Wood chipper')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (147, N'920', N'L6e-BU tavaramopoauto', N'L6e-BU lätt mopedbil för godsbefordran', N'L6e-BU light quadri-mobile for utility purposes')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (148, N'921', N'L7e-A1 alaluokan A1 maantiemönkijä', N'L7e-A1 A1 - fyrhjuling avsedd för väg', N'L7e-A1 A1 on-road quad')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (149, N'922', N'L7e-A2 alaluokan A2 maantiemönkijä', N'L7e-A2 A2 - fyrhjuling avsedd för väg', N'L7e-A2 A2 on-road quad')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (150, N'923', N'L7e-B1 tavallinen maastomönkijä', N'L7e-B1 terränggående fyrhjuling', N'L7e-B1 all terrain quad')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (151, N'924', N'L7e-B2 rinnakkain istuttava maastomönkijä', N'L7e-B2 side-by-side buggy', N'L7e-B2 side-by-side buggy')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (152, N'925', N'L7e-CP henkilönelipyörä', N'L7e-CP tung mopedbil för passagerarbefordran', N'L7e-CP heavy quadri-mobile for passenger transport')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (153, N'926', N'L7e-CU tavaranelipyörä', N'L7e-CU tung mopedbil för godsbefordran', N'L7e-CU heavy quadri-mobile for utility purposes')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (154, N'928', N'Pyörillä varustettu traktori, v <= 40 km/h, m > 600 kg, maavara <= 1000 mm', N'Hjultraktor, v <= 40 km/h, m > 600 kg, markfrigång <= 1000 mm', N'Wheeled tractor, v <= 40 km/h, m > 600 kg, ground clearance <= 1000 mm')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (155, N'929', N'Pyörillä varustettu traktori, v > 40 km/h, m > 600 kg, maavara <= 1000 mm', N'Hjultraktor, v > 40 km/h, m > 600 kg, markfrigång <= 1000 mm', N'Wheeled tractor, v > 40 km/h, m > 600 kg, ground clearance <= 1000 mm')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (156, N'93', N'Vetotrukki', N'Dragtruck', N'Towing tractor')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (157, N'930', N'Pyörillä varustettu traktori, v <= 40 km/h, m > 600 kg, maavara <= 600 mm, pienin raideväli <1150mm', N'Hjultraktor, v <= 40 km/h, m > 600 kg, markfrigång <= 600 mm, minsta spårvidd <1150mm', N'Wheeled tractor, v <= 40 km/h, m > 600 kg, ground clearance <= 600 mm, min. track width <1150mm')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (158, N'932', N'Pyörillä varustettu traktori, v <= 40 km/h, m <= 600 kg', N'Hjultraktor, v <= 40 km/h, m <= 600 kg', N'Wheeled tractor, v <= 40 km/h, m <= 600 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (159, N'933', N'Pyörillä varustettu traktori, v > 40 km/h, m <= 600 kg', N'Hjultraktor, v > 40 km/h, m <= 600 kg', N'Wheeled tractor, v > 40 km/h, m <= 600 kg')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (160, N'94', N'Lumilinko', N'Snöslunga', N'Snow blower')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (161, N'940', N'Telaketjuilla varustettu traktori,v <= 40 km/h, m > 600 kg, maavara <= 1000 mm', N'Bandtraktor, v <= 40 km/h, m > 600 kg, markfrigång <= 1000 mm', N'Track-laying tractor,v <= 40 km/h, m > 600 kg, ground clearance <= 1000 mm')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (162, N'95', N'Hajasääritrukki', N'Grensletruck', N'Straddle carrier')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (163, N'96', N'Kuljetusalusta', N'Transportchassi', N'Transport platform')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (164, N'97', N'Lakaisukone', N'Sopningsmaskin', N'Street sweeper')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (165, N'98', N'Hiekanlevitin', N'Sandspridare', N'Sander')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (166, N'99', N'Linjanrakennuskone', N'Linjebyggnadsmaskin', N'Pipelayer')
INSERT [dbo].[AJONEUVORYHMÄ] ([Id], [ryhma], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (167, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[AJONEUVORYHMÄ] OFF
SET IDENTITY_INSERT [dbo].[KAYTTOVOIMA] ON 

INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (1, N'01', N'Bensiini', N'Bensin', N'Petrol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (2, N'02', N'Dieselöljy', N'Dieselolja', N'Diesel fuel')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (3, N'03', N'Polttoöljy', N'Brännolja', N'Fuel oil')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (4, N'04', N'Sähkö', N'Elektricitet', N'Electricity')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (5, N'05', N'Vety', N'Hydrogen', N'Hydrogen')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (6, N'06', N'Kaasu', N'Gas', N'Gas')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (7, N'07', N'Metanoli', N'Metanol', N'Methanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (8, N'10', N'Biodiesel', N'Biodiesel', N'Biodiesel fuel')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (9, N'11', N'LPG', N'LPG', N'LPG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (10, N'13', N'CNG', N'CNG', N'CNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (11, N'31', N'Moottoripetroli', N'Motorfotogen', N'Light fuel oil (kerosene)')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (12, N'32', N'Diesel/Puu', N'Diesel/Trä', N'Diesel/wood')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (13, N'33', N'Bensiini/Puu', N'Bensin/Trä', N'Petrol/wood')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (14, N'34', N'Bensiini + moottoripetroli', N'Bensin + motorfotogen', N'Petrol + light fuel oil (kerosene)')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (15, N'37', N'Etanoli', N'Etanol', N'Ethanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (16, N'38', N'Bensiini/CNG', N'Bensin/CNG', N'Petrol/CNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (17, N'39', N'Bensiini/Sähkö', N'Bensin/Elektricitet', N'Petrol/Electricity')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (18, N'40', N'Bensiini/Etanoli', N'Bensin/Etanol', N'Petrol/Ethanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (19, N'41', N'Bensiini/Metanoli', N'Bensin/Metanol', N'Petrol/Methanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (20, N'42', N'Bensiini/LPG', N'Bensin/LPG', N'Petrol/LPG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (21, N'43', N'Diesel/CNG', N'Diesel/CNG', N'Diesel fuel / CNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (22, N'44', N'Diesel/Sähkö', N'Diesel/Elektricitet', N'Diesel fuel / Electricity')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (23, N'45', N'Diesel/Etanoli', N'Diesel/Etanol', N'Diesel fuel / Ethanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (24, N'46', N'Diesel/Metanoli', N'Diesel/Metanol', N'Diesel fuel / Methanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (25, N'47', N'Diesel/LPG', N'Diesel/LPG', N'Diesel fuel / LPG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (26, N'48', N'Diesel/Biodiesel', N'Diesel/Biodiesel', N'Diesel fuel / Biodiesel fuel')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (27, N'49', N'Diesel/Biodiesel/Sähkö', N'Diesel/Biodiesel/Elektricitet', N'Diesel fuel / Biodiesel fuel / Electricity')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (28, N'50', N'Diesel/Biodiesel/Etanoli', N'Diesel/Biodiesel/Etanol', N'Diesel fuel / Biodiesel fuel / Ethanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (29, N'51', N'Diesel/Biodiesel/Metanoli', N'Diesel/Biodiesel/Metanol', N'Diesel fuel / Biodiesel fuel / Methanol')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (30, N'52', N'Diesel/Biodiesel/LPG', N'Diesel/Biodiesel/LPG', N'Diesel fuel / Biodiesel fuel / LPG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (31, N'53', N'Diesel/Biodiesel/CNG', N'Diesel/Biodiesel/CNG', N'Diesel fuel / Biodiesel fuel / CNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (32, N'54', N'Vety/Sähkö', N'Hydrogen/Elektricitet', N'Hydrogen/Electricity')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (33, N'55', N'Dieselöljy/Muu', N'Dieselolja/Övrig', N'Diesel fuel / Other')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (34, N'56', N'H-ryhmän maakaasu', N'Naturgastyp H', N'Natural gas type H')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (35, N'57', N'L-ryhmän maakaasu', N'Naturgastyp L', N'Natural gas type L')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (36, N'58', N'HL-ryhmän maakaasu', N'Naturgastyp HL', N'Natural gas type HL')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (37, N'59', N'CNG/Biometaani', N'CNG/Biometan', N'Natural gas / Biomethane')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (38, N'60', N'Biometaani', N'Biometan', N'Biomethan')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (39, N'61', N'Puu', N'Träd', N'Wood')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (40, N'62', N'Etanoli (ED95)', N'Etanol (ED95)', N'Ethanol (ED95)')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (41, N'63', N'Etanoli (E85)', N'Etanol (E85)', N'Ethanol (E85)')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (42, N'64', N'Vety-maakaasuseos', N'H2NG-blandning', N'H2NG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (43, N'65', N'LNG', N'LNG', N'LNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (44, N'66', N'LNG20', N'LNG20', N'LNG20')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (45, N'67', N'Diesel/LNG', N'Diesel/LNG', N'Diesel/LNG')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (46, N'68', N'Diesel/LNG20', N'Diesel/LNG20', N'Diesel/LNG20')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (47, N'X', N'Ei sovellettavissa', N'Ej tillämplig', N'Not applicable')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (48, N'Y', N'Muu', N'Övrig', N'Other')
INSERT [dbo].[KAYTTOVOIMA] ([Id], [KOODINTUNNUS], [SELITE_fi], [SELITE_sv], [SELITE_en]) VALUES (49, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[KAYTTOVOIMA] OFF
SET IDENTITY_INSERT [dbo].[KORITYYPPI] ON 

INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (1, N'AA', N'Sedan (AA)', N'Sedan (AA)', N'Saloon (AA)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (2, N'AB', N'Viistoperä (AB)', N'Kombisedan (AB)', N'Hatchback (AB)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (3, N'AC', N'Farmari (AC)', N'Stationsvagn (AC)', N'Station wagon (AC)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (4, N'AD', N'Coupé (AD)', N'Kupé (AD)', N'Coupé (AD)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (5, N'AE', N'Avoauto (AE)', N'Cabriolet (AE)', N'Convertible (AE)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (6, N'AF', N'Monikäyttöajoneuvo (AF)', N'Fordon avsett för flera ändamål (AF)', N'Multi-purpose vehicle (AF)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (7, N'BA', N'Avolavakuorma-auto (BA)', N'Lastbil (BA)', N'Lorry (BA)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (8, N'BB', N'Umpikorinen (BB)', N'Skåpbil (BB)', N'Van (BB)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (9, N'BC', N'Puoliperävaunun vetoauto (BC)', N'Dragfordon för påhängsvagn (BC)', N'Semi-trailer tractor (BC)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (10, N'BD', N'Perävaunun vetoajoneuvo (BD)', N'Dragfordon för släpvagn (BD)', N'Towing vehicle for a trailer (BD)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (11, N'CA', N'Yksikerroksinen (CA)', N'Envåningsbuss (CA)', N'Single-deck (CA)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (12, N'CB', N'Kaksikerroksinen (CB)', N'Tvåvåningsbuss (CB)', N'Double-deck (CB)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (13, N'CC', N'Nivelöity yksikerroksinen (CC)', N'Ledad envåningsbuss (CC)', N'Articulated single-deck (CC)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (14, N'CD', N'Nivelöity kaksikerroksinen (CD)', N'Ledad tvåvåningsbuss (CD)', N'Articulated double-deck (CD)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (15, N'CE', N'Matalalattiainen yksikerroksinen (CE)', N'Envånings låggolvsbuss (CE)', N'Low-floor single-deck (CE)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (16, N'CF', N'Matalalattiainen kaksikerroksinen (CF)', N'Tvåvånings låggolvsbuss (CF)', N'Low-floor double-deck (CF)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (17, N'CG', N'Nivelöity matalalattiainen yksikerroksinen (CG)', N'Ledad envånings låggolvsbuss (CG)', N'Articulated low-floor single-deck (CG)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (18, N'CH', N'Nivelöity matalalattiainen kaksikerroksinen (CH)', N'Ledad envånings låggolvsbuss (CG)', N'Articulated low-floor double-deck (CH)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (19, N'CI', N'Yksikerroksinen (CI)', N'Envåningsbuss (CI)', N'Single-deck (CI)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (20, N'CJ', N'Kaksikerroksinen (CJ)', N'Tvåvåningsbuss (CJ)', N'Double-deck (CJ)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (21, N'CK', N'Nivelöity yksikerroksinen (CK)', N'Ledad envåningsbuss (CK)', N'Articulated single-deck (CK)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (22, N'CL', N'Nivelöity kaksikerroksinen (CL)', N'Ledad tvåvåningsbuss (CL)', N'Articulated double-deck (CL)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (23, N'CM', N'Matalalattiainen yksikerroksinen (CM)', N'Envånings låggolvsbuss (CM)', N'Low-floor single-deck (CM)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (24, N'CN', N'Matalalattiainen kaksikerroksinen (CN)', N'Tvåvånings låggolvsbuss (CN)', N'Low-floor double-deck (CN)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (25, N'CO', N'Nivelöity matalalattiainen yksikerroksinen (CO)', N'Ledad envånings låggolvsbuss (CO)', N'Articulated low-floor single-deck (CO)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (26, N'CP', N'Nivelöity matalalattiainen kaksikerroksinen (CP)', N'Ledad tvåvånings låggolvsbuss (CP)', N'Articulated low-floor double-deck (CP)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (27, N'CQ', N'Yksikerroksinen (CQ)', N'Envåningsbuss (CQ)', N'Single-deck (CQ)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (28, N'CR', N'Kaksikerroksinen (CR)', N'Tvåvåningsbuss (CR)', N'Double-deck (CR)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (29, N'CS', N'Nivelöity yksikerroksinen (CS)', N'Ledad envåningsbuss (CS)', N'Articulated single-deck (CS)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (30, N'CT', N'Nivelöity kaksikerroksinen (CT)', N'Ledad tvåvåningsbuss (CT)', N'Articulated double-deck (CT)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (31, N'CU', N'Yksikerroksinen (CU)', N'Envåningsbuss (CU)', N'Single-deck (CU)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (32, N'CV', N'Matalalattiainen yksikerroksinen (CV)', N'Envånings låggolvsbuss (CV)', N'Low-floor single-deck (CV)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (33, N'CW', N'Yksikerroksinen (CW)', N'Envåningsbuss (CW)', N'Single-deck (CW)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (34, N'DA', N'Puoliperävaunu (DA)', N'Påhängsvagn (DA)', N'Semi-trailer (DA)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (35, N'DB', N'Varsinainen perävaunu (DB)', N'Släpvagn med dragstång (DB)', N'Trailer (DB)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (36, N'DC', N'Keskiakseliperävaunu (DC)', N'Släpkärra (DC)', N'Centre-axle trailer (DC)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (37, N'SA', N'Matkailuauto (SA)', N'Campingbil (SA)', N'Motor caravan (SA)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (38, N'SB', N'Panssariajoneuvo (SB)', N'Bepansrat fordon (SB)', N'Armoured vehicle (SB)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (39, N'SC', N'Ambulanssi (SC)', N'Ambulans (SC)', N'Ambulance (SC)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (40, N'SD', N'Ruumisauto (SD)', N'Likbil (SD)', N'Hearse (SD)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (41, N'SE', N'Matkailuperävaunu (SE)', N'Husvagn (SE)', N'Caravan (SE)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (42, N'SF', N'Ajoneuvonosturi (SF)', N'Mobilkran (SF)', N'Mobile crane (SF)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (43, N'SG', N'Muut erikoiskäyttöön tarkoitetut ajoneuvot (SG)', N'Andra fordon avsedda för särskilda ändamål (SG)', N'Other special purpose vehicles (SG)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (44, N'SH', N'Pyörätuolin käyttäjälle tarkoitettu ajoneuvo (SH)', N'Rullstolsanpassade fordon (SH)', N'Wheelchair accessible vehicle (SH)')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (45, N'U/A', N'Umpi/avo', N'Sluten/öppen', N'Sedan/convertible')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (46, N'1.7', N'AG Tavarafarmari', N'Släpvagn för transport av exceptionell last', N'Exceptional load transport trailer')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (47, N'2.11', N'CX Linja-auton alusta', N'Motorfordon för transport av exceptionell last', N'Exceptional load transport motor vehicle')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (48, N'3.5', N'BE Avopakettiauto', N'Redskapsbärare', N'Multi-equipment carrier')
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (49, N'3.6', N'BX Alusta-ohjaamo', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (50, N'4.4', N'DE Nivelöimättömällä vetoaisalla varustettu perävaunu', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (51, N'5.9', N'SJ Apuvaunu', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (52, N'5.10', N'SK Erikoiskuljetusperävaunu', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (53, N'2.9', N'CI Avokattoinen yksikerroksinen ajoneuvo', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (54, N'3.1', N'BA Tavara-auto', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (55, N'2.10', N'CJ Avokattoinen kaksikerroksinen ajoneuvo', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (56, N'SK', N'Erikoiskuljetusperävaunu', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (57, N'SL', N'Erikoiskuljetusauto', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (58, N'SM', N'Monilaiteajoneuvo', NULL, NULL)
INSERT [dbo].[KORITYYPPI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (59, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[KORITYYPPI] OFF
SET IDENTITY_INSERT [dbo].[kunta] ON 

INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (1, N'005', N'Alajärvi', N'Alajärvi', N'Alajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (2, N'009', N'Alavieska', N'Alavieska', N'Alavieska')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (3, N'010', N'Alavus', N'Alavo', N'Alavus')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (4, N'016', N'Asikkala', N'Asikkala', N'Asikkala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (5, N'018', N'Askola', N'Askola', N'Askola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (6, N'019', N'Aura', N'Aura', N'Aura')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (7, N'020', N'Akaa', N'Ackas', N'Akaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (8, N'035', N'Brändö', N'Brändö', N'Brändö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (9, N'043', N'Eckerö', N'Eckerö', N'Eckerö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (10, N'046', N'Enonkoski', N'Enonkoski', N'Enonkoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (11, N'047', N'Enontekiö', N'Enontekiö', N'Enontekiö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (12, N'049', N'Espoo', N'Esbo', N'Espoo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (13, N'050', N'Eura', N'Eura', N'Eura')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (14, N'051', N'Eurajoki', N'Eurajoki', N'Eurajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (15, N'052', N'Evijärvi', N'Evijärvi', N'Evijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (16, N'060', N'Finström', N'Finström', N'Finström')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (17, N'061', N'Forssa', N'Forssa', N'Forssa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (18, N'062', N'Föglö', N'Föglö', N'Föglö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (19, N'065', N'Geta', N'Geta', N'Geta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (20, N'069', N'Haapajärvi', N'Haapajärvi', N'Haapajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (21, N'071', N'Haapavesi', N'Haapavesi', N'Haapavesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (22, N'072', N'Hailuoto', N'Karlö', N'Hailuoto')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (23, N'074', N'Halsua', N'Halsua', N'Halsua')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (24, N'075', N'Hamina', N'Fredrikshamn', N'Hamina')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (25, N'076', N'Hammarland', N'Hammarland', N'Hammarland')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (26, N'077', N'Hankasalmi', N'Hankasalmi', N'Hankasalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (27, N'078', N'Hanko', N'Hangö', N'Hanko')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (28, N'079', N'Harjavalta', N'Harjavalta', N'Harjavalta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (29, N'081', N'Hartola', N'Hartola', N'Hartola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (30, N'082', N'Hattula', N'Hattula', N'Hattula')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (31, N'086', N'Hausjärvi', N'Hausjärvi', N'Hausjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (32, N'090', N'Heinävesi', N'Heinävesi', N'Heinävesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (33, N'091', N'Helsinki', N'Helsingfors', N'Helsinki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (34, N'092', N'Vantaa', N'Vanda', N'Vantaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (35, N'097', N'Hirvensalmi', N'Hirvensalmi', N'Hirvensalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (36, N'098', N'Hollola', N'Hollola', N'Hollola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (37, N'099', N'Honkajoki', N'Honkajoki', N'Honkajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (38, N'102', N'Huittinen', N'Huittinen', N'Huittinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (39, N'103', N'Humppila', N'Humppila', N'Humppila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (40, N'105', N'Hyrynsalmi', N'Hyrynsalmi', N'Hyrynsalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (41, N'106', N'Hyvinkää', N'Hyvinge', N'Hyvinkää')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (42, N'108', N'Hämeenkyrö', N'Tavastkyro', N'Hämeenkyrö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (43, N'109', N'Hämeenlinna', N'Tavastehus', N'Hämeenlinna')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (44, N'111', N'Heinola', N'Heinola', N'Heinola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (45, N'139', N'Ii', N'Ii', N'Ii')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (46, N'140', N'Iisalmi', N'Idensalmi', N'Iisalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (47, N'142', N'Iitti', N'Iitti', N'Iitti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (48, N'143', N'Ikaalinen', N'Ikalis', N'Ikaalinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (49, N'145', N'Ilmajoki', N'Ilmajoki', N'Ilmajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (50, N'146', N'Ilomantsi', N'Ilomantsi', N'Ilomantsi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (51, N'148', N'Inari', N'Enare', N'Inari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (52, N'149', N'Inkoo', N'Ingå', N'Inkoo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (53, N'151', N'Isojoki', N'Storå', N'Isojoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (54, N'152', N'Isokyrö', N'Storkyro', N'Isokyrö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (55, N'153', N'Imatra', N'Imatra', N'Imatra')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (56, N'165', N'Janakkala', N'Janakkala', N'Janakkala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (57, N'167', N'Joensuu', N'Joensuu', N'Joensuu')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (58, N'169', N'Jokioinen', N'Jokioinen', N'Jokioinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (59, N'170', N'Jomala', N'Jomala', N'Jomala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (60, N'171', N'Joroinen', N'Joroinen', N'Joroinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (61, N'172', N'Joutsa', N'Joutsa', N'Joutsa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (62, N'176', N'Juuka', N'Juuka', N'Juuka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (63, N'177', N'Juupajoki', N'Juupajoki', N'Juupajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (64, N'178', N'Juva', N'Jockas', N'Juva')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (65, N'179', N'Jyväskylä', N'Jyväskylä', N'Jyväskylä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (66, N'181', N'Jämijärvi', N'Jämijärvi', N'Jämijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (67, N'182', N'Jämsä', N'Jämsä', N'Jämsä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (68, N'186', N'Järvenpää', N'Järvenpää', N'Järvenpää')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (69, N'198', N'Ulkomaat', N'Utlandet', N'Ulkomaat')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (70, N'199', N'Tuntematon', N'Okänd', N'Tuntematon')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (71, N'200', N'Ulkomaat', N'Utlandet', N'Ulkomaat')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (72, N'201', N'Pohjoismaat', N'Norden', N'Pohjoismaat')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (73, N'202', N'Kaarina', N'St Karins', N'Kaarina')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (74, N'204', N'Kaavi', N'Kaavi', N'Kaavi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (75, N'205', N'Kajaani', N'Kajana', N'Kajaani')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (76, N'208', N'Kalajoki', N'Kalajoki', N'Kalajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (77, N'211', N'Kangasala', N'Kangasala', N'Kangasala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (78, N'213', N'Kangasniemi', N'Kangasniemi', N'Kangasniemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (79, N'214', N'Kankaanpää', N'Kankaanpää', N'Kankaanpää')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (80, N'216', N'Kannonkoski', N'Kannonkoski', N'Kannonkoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (81, N'217', N'Kannus', N'Kannus', N'Kannus')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (82, N'218', N'Karijoki', N'Bötom', N'Karijoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (83, N'224', N'Karkkila', N'Högfors', N'Karkkila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (84, N'226', N'Karstula', N'Karstula', N'Karstula')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (85, N'230', N'Karvia', N'Karvia', N'Karvia')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (86, N'231', N'Kaskinen', N'Kaskö', N'Kaskinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (87, N'232', N'Kauhajoki', N'Kauhajoki', N'Kauhajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (88, N'233', N'Kauhava', N'Kauhava', N'Kauhava')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (89, N'235', N'Kauniainen', N'Grankulla', N'Kauniainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (90, N'236', N'Kaustinen', N'Kaustby', N'Kaustinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (91, N'239', N'Keitele', N'Keitele', N'Keitele')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (92, N'240', N'Kemi', N'Kemi', N'Kemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (93, N'241', N'Keminmaa', N'Keminmaa', N'Keminmaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (94, N'244', N'Kempele', N'Kempele', N'Kempele')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (95, N'245', N'Kerava', N'Kervo', N'Kerava')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (96, N'249', N'Keuruu', N'Keuruu', N'Keuruu')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (97, N'250', N'Kihniö', N'Kihniö', N'Kihniö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (98, N'256', N'Kinnula', N'Kinnula', N'Kinnula')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (99, N'257', N'Kirkkonummi', N'Kyrkslätt', N'Kirkkonummi')
GO
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (100, N'260', N'Kitee', N'Kitee', N'Kitee')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (101, N'261', N'Kittilä', N'Kittilä', N'Kittilä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (102, N'263', N'Kiuruvesi', N'Kiuruvesi', N'Kiuruvesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (103, N'265', N'Kivijärvi', N'Kivijärvi', N'Kivijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (104, N'271', N'Kokemäki', N'Kumo', N'Kokemäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (105, N'272', N'Kokkola', N'Karleby', N'Kokkola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (106, N'273', N'Kolari', N'Kolari', N'Kolari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (107, N'275', N'Konnevesi', N'Konnevesi', N'Konnevesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (108, N'276', N'Kontiolahti', N'Kontiolahti', N'Kontiolahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (109, N'280', N'Korsnäs', N'Korsnäs', N'Korsnäs')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (110, N'284', N'Koski Tl', N'Koski Tl', N'Koski Tl')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (111, N'285', N'Kotka', N'Kotka', N'Kotka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (112, N'286', N'Kouvola', N'Kouvola', N'Kouvola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (113, N'287', N'Kristiinankaupunki', N'Kristinestad', N'Kristiinankaupunki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (114, N'288', N'Kruunupyy', N'Kronoby', N'Kruunupyy')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (115, N'290', N'Kuhmo', N'Kuhmo', N'Kuhmo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (116, N'291', N'Kuhmoinen', N'Kuhmoinen', N'Kuhmoinen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (117, N'295', N'Kumlinge', N'Kumlinge', N'Kumlinge')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (118, N'297', N'Kuopio', N'Kuopio', N'Kuopio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (119, N'300', N'Kuortane', N'Kuortane', N'Kuortane')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (120, N'301', N'Kurikka', N'Kurikka', N'Kurikka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (121, N'304', N'Kustavi', N'Gustavs', N'Kustavi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (122, N'305', N'Kuusamo', N'Kuusamo', N'Kuusamo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (123, N'309', N'Outokumpu', N'Outokumpu', N'Outokumpu')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (124, N'312', N'Kyyjärvi', N'Kyyjärvi', N'Kyyjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (125, N'316', N'Kärkölä', N'Kärkölä', N'Kärkölä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (126, N'317', N'Kärsämäki', N'Kärsämäki', N'Kärsämäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (127, N'318', N'Kökar', N'Kökar', N'Kökar')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (128, N'320', N'Kemijärvi', N'Kemijärvi', N'Kemijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (129, N'322', N'Kemiönsaari', N'Kimitoö', N'Kemiönsaari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (130, N'398', N'Lahti', N'Lahtis', N'Lahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (131, N'399', N'Laihia', N'Laihia', N'Laihia')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (132, N'400', N'Laitila', N'Laitila', N'Laitila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (133, N'402', N'Lapinlahti', N'Lapinlahti', N'Lapinlahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (134, N'403', N'Lappajärvi', N'Lappajärvi', N'Lappajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (135, N'405', N'Lappeenranta', N'Villmanstrand', N'Lappeenranta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (136, N'407', N'Lapinjärvi', N'Lappträsk', N'Lapinjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (137, N'408', N'Lapua', N'Lappo', N'Lapua')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (138, N'410', N'Laukaa', N'Laukaa', N'Laukaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (139, N'416', N'Lemi', N'Lemi', N'Lemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (140, N'417', N'Lemland', N'Lemland', N'Lemland')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (141, N'418', N'Lempäälä', N'Lempäälä', N'Lempäälä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (142, N'420', N'Leppävirta', N'Leppävirta', N'Leppävirta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (143, N'421', N'Lestijärvi', N'Lestijärvi', N'Lestijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (144, N'422', N'Lieksa', N'Lieksa', N'Lieksa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (145, N'423', N'Lieto', N'Lieto', N'Lieto')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (146, N'425', N'Liminka', N'Liminka', N'Liminka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (147, N'426', N'Liperi', N'Libelits', N'Liperi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (148, N'430', N'Loimaa', N'Loimaa', N'Loimaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (149, N'433', N'Loppi', N'Loppi', N'Loppi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (150, N'434', N'Loviisa', N'Lovisa', N'Loviisa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (151, N'435', N'Luhanka', N'Luhanka', N'Luhanka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (152, N'436', N'Lumijoki', N'Lumijoki', N'Lumijoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (153, N'438', N'Lumparland', N'Lumparland', N'Lumparland')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (154, N'440', N'Luoto', N'Larsmo', N'Luoto')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (155, N'441', N'Luumäki', N'Luumäki', N'Luumäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (156, N'444', N'Lohja', N'Lojo', N'Lohja')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (157, N'445', N'Parainen', N'Pargas', N'Parainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (158, N'475', N'Maalahti', N'Malax', N'Maalahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (159, N'478', N'Maarianhamina', N'Mariehamn', N'Maarianhamina')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (160, N'480', N'Marttila', N'St Mårtens', N'Marttila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (161, N'481', N'Masku', N'Masku', N'Masku')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (162, N'483', N'Merijärvi', N'Merijärvi', N'Merijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (163, N'484', N'Merikarvia', N'Merikarvia', N'Merikarvia')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (164, N'489', N'Miehikkälä', N'Miehikkälä', N'Miehikkälä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (165, N'491', N'Mikkeli', N'St Michel', N'Mikkeli')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (166, N'494', N'Muhos', N'Muhos', N'Muhos')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (167, N'495', N'Multia', N'Multia', N'Multia')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (168, N'498', N'Muonio', N'Muonio', N'Muonio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (169, N'499', N'Mustasaari', N'Korsholm', N'Mustasaari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (170, N'500', N'Muurame', N'Muurame', N'Muurame')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (171, N'503', N'Mynämäki', N'Virmo', N'Mynämäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (172, N'504', N'Myrskylä', N'Mörskom', N'Myrskylä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (173, N'505', N'Mäntsälä', N'Mäntsälä', N'Mäntsälä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (174, N'507', N'Mäntyharju', N'Mäntyharju', N'Mäntyharju')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (175, N'508', N'Mänttä-Vilppula', N'Mänttä-Vilppula', N'Mänttä-Vilppula')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (176, N'529', N'Naantali', N'Nådendal', N'Naantali')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (177, N'531', N'Nakkila', N'Nakkila', N'Nakkila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (178, N'535', N'Nivala', N'Nivala', N'Nivala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (179, N'536', N'Nokia', N'Nokia', N'Nokia')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (180, N'538', N'Nousiainen', N'Nousiainen', N'Nousiainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (181, N'541', N'Nurmes', N'Nurmes', N'Nurmes')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (182, N'543', N'Nurmijärvi', N'Nurmijärvi', N'Nurmijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (183, N'545', N'Närpiö', N'Närpes', N'Närpiö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (184, N'560', N'Orimattila', N'Orimattila', N'Orimattila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (185, N'561', N'Oripää', N'Oripää', N'Oripää')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (186, N'562', N'Orivesi', N'Orivesi', N'Orivesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (187, N'563', N'Oulainen', N'Oulainen', N'Oulainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (188, N'564', N'Oulu', N'Uleåborg', N'Oulu')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (189, N'576', N'Padasjoki', N'Padasjoki', N'Padasjoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (190, N'577', N'Paimio', N'Pemar', N'Paimio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (191, N'578', N'Paltamo', N'Paltamo', N'Paltamo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (192, N'580', N'Parikkala', N'Parikkala', N'Parikkala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (193, N'581', N'Parkano', N'Parkano', N'Parkano')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (194, N'583', N'Pelkosenniemi', N'Pelkosenniemi', N'Pelkosenniemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (195, N'584', N'Perho', N'Perho', N'Perho')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (196, N'588', N'Pertunmaa', N'Pertunmaa', N'Pertunmaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (197, N'592', N'Petäjävesi', N'Petäjävesi', N'Petäjävesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (198, N'593', N'Pieksämäki', N'Pieksämäki', N'Pieksämäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (199, N'595', N'Pielavesi', N'Pielavesi', N'Pielavesi')
GO
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (200, N'598', N'Pietarsaari', N'Jakobstad', N'Pietarsaari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (201, N'599', N'Pedersören kunta', N'Pedersöre', N'Pedersören kunta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (202, N'601', N'Pihtipudas', N'Pihtipudas', N'Pihtipudas')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (203, N'604', N'Pirkkala', N'Pirkkala', N'Pirkkala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (204, N'607', N'Polvijärvi', N'Polvijärvi', N'Polvijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (205, N'608', N'Pomarkku', N'Påmark', N'Pomarkku')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (206, N'609', N'Pori', N'Björneborg', N'Pori')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (207, N'611', N'Pornainen', N'Borgnäs', N'Pornainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (208, N'614', N'Posio', N'Posio', N'Posio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (209, N'615', N'Pudasjärvi', N'Pudasjärvi', N'Pudasjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (210, N'616', N'Pukkila', N'Pukkila', N'Pukkila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (211, N'619', N'Punkalaidun', N'Punkalaidun', N'Punkalaidun')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (212, N'620', N'Puolanka', N'Puolanka', N'Puolanka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (213, N'623', N'Puumala', N'Puumala', N'Puumala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (214, N'624', N'Pyhtää', N'Pyttis', N'Pyhtää')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (215, N'625', N'Pyhäjoki', N'Pyhäjoki', N'Pyhäjoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (216, N'626', N'Pyhäjärvi', N'Pyhäjärvi', N'Pyhäjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (217, N'630', N'Pyhäntä', N'Pyhäntä', N'Pyhäntä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (218, N'631', N'Pyhäranta', N'Pyhäranta', N'Pyhäranta')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (219, N'635', N'Pälkäne', N'Pälkäne', N'Pälkäne')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (220, N'636', N'Pöytyä', N'Pöytyä', N'Pöytyä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (221, N'638', N'Porvoo', N'Borgå', N'Porvoo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (222, N'678', N'Raahe', N'Brahestad', N'Raahe')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (223, N'680', N'Raisio', N'Reso', N'Raisio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (224, N'681', N'Rantasalmi', N'Rantasalmi', N'Rantasalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (225, N'683', N'Ranua', N'Ranua', N'Ranua')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (226, N'684', N'Rauma', N'Raumo', N'Rauma')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (227, N'686', N'Rautalampi', N'Rautalampi', N'Rautalampi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (228, N'687', N'Rautavaara', N'Rautavaara', N'Rautavaara')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (229, N'689', N'Rautjärvi', N'Rautjärvi', N'Rautjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (230, N'691', N'Reisjärvi', N'Reisjärvi', N'Reisjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (231, N'694', N'Riihimäki', N'Riihimäki', N'Riihimäki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (232, N'697', N'Ristijärvi', N'Ristijärvi', N'Ristijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (233, N'698', N'Rovaniemi', N'Rovaniemi', N'Rovaniemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (234, N'700', N'Ruokolahti', N'Ruokolahti', N'Ruokolahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (235, N'702', N'Ruovesi', N'Ruovesi', N'Ruovesi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (236, N'704', N'Rusko', N'Rusko', N'Rusko')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (237, N'707', N'Rääkkylä', N'Rääkkylä', N'Rääkkylä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (238, N'710', N'Raasepori', N'Raseborg', N'Raasepori')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (239, N'729', N'Saarijärvi', N'Saarijärvi', N'Saarijärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (240, N'732', N'Salla', N'Salla', N'Salla')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (241, N'734', N'Salo', N'Salo', N'Salo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (242, N'736', N'Saltvik', N'Saltvik', N'Saltvik')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (243, N'738', N'Sauvo', N'Sagu', N'Sauvo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (244, N'739', N'Savitaipale', N'Savitaipale', N'Savitaipale')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (245, N'740', N'Savonlinna', N'Nyslott', N'Savonlinna')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (246, N'742', N'Savukoski', N'Savukoski', N'Savukoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (247, N'743', N'Seinäjoki', N'Östermyra', N'Seinäjoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (248, N'746', N'Sievi', N'Sievi', N'Sievi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (249, N'747', N'Siikainen', N'Siikainen', N'Siikainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (250, N'748', N'Siikajoki', N'Siikajoki', N'Siikajoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (251, N'749', N'Siilinjärvi', N'Siilinjärvi', N'Siilinjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (252, N'751', N'Simo', N'Simo', N'Simo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (253, N'753', N'Sipoo', N'Sibbo', N'Sipoo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (254, N'755', N'Siuntio', N'Sjundeå', N'Siuntio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (255, N'758', N'Sodankylä', N'Sodankylä', N'Sodankylä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (256, N'759', N'Soini', N'Soini', N'Soini')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (257, N'761', N'Somero', N'Somero', N'Somero')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (258, N'762', N'Sonkajärvi', N'Sonkajärvi', N'Sonkajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (259, N'765', N'Sotkamo', N'Sotkamo', N'Sotkamo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (260, N'766', N'Sottunga', N'Sottunga', N'Sottunga')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (261, N'768', N'Sulkava', N'Sulkava', N'Sulkava')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (262, N'771', N'Sund', N'Sund', N'Sund')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (263, N'777', N'Suomussalmi', N'Suomussalmi', N'Suomussalmi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (264, N'778', N'Suonenjoki', N'Suonenjoki', N'Suonenjoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (265, N'781', N'Sysmä', N'Sysmä', N'Sysmä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (266, N'783', N'Säkylä', N'Säkylä', N'Säkylä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (267, N'785', N'Vaala', N'Vaala', N'Vaala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (268, N'790', N'Sastamala', N'Sastamala', N'Sastamala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (269, N'791', N'Siikalatva', N'Siikalatva', N'Siikalatva')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (270, N'831', N'Taipalsaari', N'Taipalsaari', N'Taipalsaari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (271, N'832', N'Taivalkoski', N'Taivalkoski', N'Taivalkoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (272, N'833', N'Taivassalo', N'Tövsala', N'Taivassalo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (273, N'834', N'Tammela', N'Tammela', N'Tammela')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (274, N'837', N'Tampere', N'Tammerfors', N'Tampere')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (275, N'844', N'Tervo', N'Tervo', N'Tervo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (276, N'845', N'Tervola', N'Tervola', N'Tervola')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (277, N'846', N'Teuva', N'Östermark', N'Teuva')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (278, N'848', N'Tohmajärvi', N'Tohmajärvi', N'Tohmajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (279, N'849', N'Toholampi', N'Toholampi', N'Toholampi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (280, N'850', N'Toivakka', N'Toivakka', N'Toivakka')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (281, N'851', N'Tornio', N'Torneå', N'Tornio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (282, N'853', N'Turku', N'Åbo', N'Turku')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (283, N'854', N'Pello', N'Pello', N'Pello')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (284, N'857', N'Tuusniemi', N'Tuusniemi', N'Tuusniemi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (285, N'858', N'Tuusula', N'Tusby', N'Tuusula')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (286, N'859', N'Tyrnävä', N'Tyrnävä', N'Tyrnävä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (287, N'886', N'Ulvila', N'Ulvsby', N'Ulvila')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (288, N'887', N'Urjala', N'Urjala', N'Urjala')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (289, N'889', N'Utajärvi', N'Utajärvi', N'Utajärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (290, N'890', N'Utsjoki', N'Utsjoki', N'Utsjoki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (291, N'892', N'Uurainen', N'Uurainen', N'Uurainen')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (292, N'893', N'Uusikaarlepyy', N'Nykarleby', N'Uusikaarlepyy')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (293, N'895', N'Uusikaupunki', N'Nystad', N'Uusikaupunki')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (294, N'905', N'Vaasa', N'Vasa', N'Vaasa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (295, N'908', N'Valkeakoski', N'Valkeakoski', N'Valkeakoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (296, N'911', N'Valtimo', N'Valtimo', N'Valtimo')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (297, N'915', N'Varkaus', N'Varkaus', N'Varkaus')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (298, N'918', N'Vehmaa', N'Vehmaa', N'Vehmaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (299, N'921', N'Vesanto', N'Vesanto', N'Vesanto')
GO
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (300, N'922', N'Vesilahti', N'Vesilahti', N'Vesilahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (301, N'924', N'Veteli', N'Vetil', N'Veteli')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (302, N'925', N'Vieremä', N'Vieremä', N'Vieremä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (303, N'927', N'Vihti', N'Vichtis', N'Vihti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (304, N'931', N'Viitasaari', N'Viitasaari', N'Viitasaari')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (305, N'934', N'Vimpeli', N'Vindala', N'Vimpeli')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (306, N'935', N'Virolahti', N'Virolahti', N'Virolahti')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (307, N'936', N'Virrat', N'Virdois', N'Virrat')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (308, N'941', N'Vårdö', N'Vårdö', N'Vårdö')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (309, N'946', N'Vöyri', N'Vörå', N'Vöyri')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (310, N'976', N'Ylitornio', N'Övertorneå', N'Ylitornio')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (311, N'977', N'Ylivieska', N'Ylivieska', N'Ylivieska')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (312, N'980', N'Ylöjärvi', N'Ylöjärvi', N'Ylöjärvi')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (313, N'981', N'Ypäjä', N'Ypäjä', N'Ypäjä')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (314, N'989', N'Ähtäri', N'Ähtäri', N'Ähtäri')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (315, N'992', N'Äänekoski', N'Äänekoski', N'Äänekoski')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (316, N'999', N'Ei vak asuinkuntaa', N'Ej stadigvarande hemkommun', N'Ei vak asuinkuntaa')
INSERT [dbo].[kunta] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (317, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[kunta] OFF
SET IDENTITY_INSERT [dbo].[OHJAAMOTYYPPI] ON 

INSERT [dbo].[OHJAAMOTYYPPI] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [LYHYTSELITE1], [LYHYTSELITE2]) VALUES (1, N'1', N'Umpiohjaamo', N'Sluten förarhytt', N'Closed cab')
INSERT [dbo].[OHJAAMOTYYPPI] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [LYHYTSELITE1], [LYHYTSELITE2]) VALUES (2, N'2', N'Suojakehys', N'Skyddsram', N'Protective frame')
INSERT [dbo].[OHJAAMOTYYPPI] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [LYHYTSELITE1], [LYHYTSELITE2]) VALUES (3, N'3', N'Jatko-ohjaamo', N'Förlängd förarhytt', N'Extended cab')
INSERT [dbo].[OHJAAMOTYYPPI] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [LYHYTSELITE1], [LYHYTSELITE2]) VALUES (4, N'4', N'Avo-ohjaamo', N'Öppen förarhytt', N'Open cab')
INSERT [dbo].[OHJAAMOTYYPPI] ([Id], [KOODINTUNNUS], [LYHYTSELITE], [LYHYTSELITE1], [LYHYTSELITE2]) VALUES (5, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[OHJAAMOTYYPPI] OFF
SET IDENTITY_INSERT [dbo].[sähköhybridin luokka] ON 

INSERT [dbo].[sähköhybridin luokka] ([Id], [koodi], [selite]) VALUES (1, N'01', N'Sähköverkosta ladattava')
INSERT [dbo].[sähköhybridin luokka] ([Id], [koodi], [selite]) VALUES (2, N'02', N'Pelkästään polttomoottorilla ladattava')
INSERT [dbo].[sähköhybridin luokka] ([Id], [koodi], [selite]) VALUES (3, N'03', N'Sähköverkosta ladattava polttokennohybridi')
INSERT [dbo].[sähköhybridin luokka] ([Id], [koodi], [selite]) VALUES (4, N'04', N'Pelkästään polttokennolla ladattava')
INSERT [dbo].[sähköhybridin luokka] ([Id], [koodi], [selite]) VALUES (5, NULL, N'Tuntematon')
SET IDENTITY_INSERT [dbo].[sähköhybridin luokka] OFF
SET IDENTITY_INSERT [dbo].[VARI] ON 

INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (1, N'0', N'Musta', N'Svart', N'Black')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (2, N'1', N'Ruskea (beige)', N'Brun (beige)', N'Brown (beige)')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (3, N'2', N'Punainen', N'Röd', N'Red')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (4, N'3', N'Oranssi', N'Orange', N'Orange')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (5, N'4', N'Keltainen', N'Gul', N'Yellow')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (6, N'5', N'Vihreä', N'Grön', N'Green')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (7, N'6', N'Sininen', N'Blå', N'Blue')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (8, N'7', N'Violetti', N'Violett', N'Violet')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (9, N'8', N'Harmaa', N'Grå', N'Grey')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (10, N'9', N'Valkoinen', N'Vit', N'White')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (11, N'X', N'Monivär.', N'Flerfärg', N'Multi-coloured')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (12, N'Y', N'Hopea', N'Silver', N'Silver')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (13, N'Z', N'Turkoosi', N'Turkos', N'Turquoise')
INSERT [dbo].[VARI] ([Id], [KOODINTUNNUS], [PITKASELITE_fi], [PITKASELITE_sv], [PITKASELITE_en]) VALUES (14, NULL, N'Tuntematon', N'Ökand', N'Unknown')
SET IDENTITY_INSERT [dbo].[VARI] OFF
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_ajoneuvoluokka] FOREIGN KEY([ajoneuvoluokka_id])
REFERENCES [dbo].[AJONEUVOLUOKKA] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_ajoneuvoluokka]
GO
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_ajoneuvonkaytto] FOREIGN KEY([ajoneuvonkaytto_id])
REFERENCES [dbo].[AJONEUVON KAYTTO] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_ajoneuvonkaytto]
GO
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_ajoneuvoryhma] FOREIGN KEY([ajoneuvoryhma_id])
REFERENCES [dbo].[AJONEUVORYHMÄ] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_ajoneuvoryhma]
GO
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_korityyppi] FOREIGN KEY([korityyppi_id])
REFERENCES [dbo].[KORITYYPPI] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_korityyppi]
GO
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_ohjaamotyyppi] FOREIGN KEY([korityyppi_id])
REFERENCES [dbo].[KORITYYPPI] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_ohjaamotyyppi]
GO
ALTER TABLE [dbo].[Errors]  WITH CHECK ADD  CONSTRAINT [FK_errors_vari] FOREIGN KEY([vari_id])
REFERENCES [dbo].[VARI] ([Id])
GO
ALTER TABLE [dbo].[Errors] CHECK CONSTRAINT [FK_errors_vari]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_ajoneuvoluokka] FOREIGN KEY([ajoneuvoluokka_id])
REFERENCES [dbo].[AJONEUVOLUOKKA] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_ajoneuvoluokka]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_ajoneuvonkaytto] FOREIGN KEY([ajoneuvonkaytto_id])
REFERENCES [dbo].[AJONEUVON KAYTTO] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_ajoneuvonkaytto]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_ajoneuvoryhma] FOREIGN KEY([ajoneuvoryhma_id])
REFERENCES [dbo].[AJONEUVORYHMÄ] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_ajoneuvoryhma]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_korityyppi] FOREIGN KEY([korityyppi_id])
REFERENCES [dbo].[KORITYYPPI] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_korityyppi]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_ohjaamotyyppi] FOREIGN KEY([korityyppi_id])
REFERENCES [dbo].[KORITYYPPI] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_ohjaamotyyppi]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD  CONSTRAINT [FK_vari] FOREIGN KEY([vari_id])
REFERENCES [dbo].[VARI] ([Id])
GO
ALTER TABLE [dbo].[Vehicles] CHECK CONSTRAINT [FK_vari]
GO
/****** Object:  StoredProcedure [dbo].[Commit]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Commit]
AS
BEGIN
	DECLARE @classCode nvarchar(64),
		@registerDateString nvarchar(64),
		@groupCode nvarchar(64),
		@usageCode nvarchar(64),
		@variant nvarchar(64),
		@version nvarchar(64),
		@introductionDateString nvarchar(64),
		@colorCode nvarchar(64),
		@doorCountString nvarchar(64),
		@bodyCode nvarchar(64),
		@cabinCode nvarchar(64),
		@seatCountString nvarchar(64),
		@unladenWeightString nvarchar(64),
		@maximumPermissibleLadenWeightString nvarchar(64)

	DECLARE @classId int, 
		@registerDate date,
		@groupId int,
		@usageId int,
		@introductionDate date,
		@colorId int,
		@doorCount int,
		@bodyId int,
		@cabinId int,
		@seatCount int,
		@unladenWeight int,
		@maximumPermissibleLadenWeight int

	DECLARE stagingCursor CURSOR
	FOR
	SELECT /* Add TOP X to this statement to test the cursor, e.g. SELECT TOP 50000 */
		ajoneuvoluokka,
		ensirekisterointipvm,
		ajoneuvoryhma,
		ajoneuvonkaytto,
		variantti,
		versio,
		kayttoonottopvm,
		vari,
		ovienLukumaara,
		korityyppi,
		ohjaamotyyppi,
		istumapaikkojenLkm,
		omamassa,
		teknSuurSallKokmassa
	FROM [dbo].[Staging];
	
	OPEN stagingCursor;
	
	FETCH NEXT FROM stagingCursor
	INTO @classCode,
		@registerDateString,
		@groupCode,
		@usageCode,
		@variant,
		@version,
		@introductionDateString,
		@colorCode,
		@doorCountString,
		@bodyCode,
		@cabinCode,
		@seatCountString,
		@unladenWeightString,
		@maximumPermissibleLadenWeightString
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @classCodeValidation table
		(
			HasErrors bit,
			ErrorDescription nvarchar(255)
		)

		DECLARE @dateValidation table
		(
			RegisterationDate date NULL,
			IntroductionDate date NULL,
			HasErrors bit,
			ErrorDescription nvarchar(255)
		)

		INSERT INTO @classCodeValidation
		(
			HasErrors,
			ErrorDescription
		)
		SELECT HasErrors, ErrorDescription
		FROM [dbo].ValidateClassCode(@classCode, @groupCode)

		INSERT INTO @dateValidation
		(
			RegisterationDate,
			IntroductionDate,
			HasErrors,
			ErrorDescription
		)
		SELECT RegisterationDate,
			IntroductionDate,
			HasErrors,
			ErrorDescription
		FROM [dbo].ValidateDates
		(
			@registerDateString,
			@introductionDateString
		)

		DECLARE @hasClassCodeErrors bit,
			@hasDateErrors bit,
			@hasErrors bit,
			@errorDescription nvarchar(255),
			@classCodeErrorDescription nvarchar(255),
			@dateErrorDescription nvarchar(255)

		SELECT @hasClassCodeErrors = HasErrors,
			@classCodeErrorDescription = ErrorDescription
		FROM @classCodeValidation

		SELECT @hasDateErrors = HasErrors,
			@dateErrorDescription = ErrorDescription,
			@registerDate = RegisterationDate,
			@introductionDate = IntroductionDate
		FROM @dateValidation

		SET @hasErrors = 'false'
		
		SET @errorDescription = ''

		IF @hasClassCodeErrors = 'true'
		BEGIN
			SET @hasErrors = 'true'
			SET @errorDescription = CONCAT(@errorDescription, @classCodeErrorDescription)
		END

		IF @hasDateErrors = 'true'
		BEGIN
			SET @hasErrors = 'true'
			SET @errorDescription = CONCAT(@errorDescription, @dateErrorDescription);
		END

		SET @classId = dbo.GetClassId(@classCode)
		SET @groupId = dbo.GetGroupId(@groupCode)
		SET @usageId = dbo.GetUsageId(@usageCode)
		SET @ColorId = dbo.GetColorId(@colorCode)
		SET @bodyId = dbo.GetBodyId(@bodyCode)
		SET @cabinId = dbo.GetCabinId(@cabinCode)

		SET @doorCount = CONVERT(int, @doorCountString)
		SET @seatCount = CONVERT(int, @seatCountString)
		SET @unladenWeight = CONVERT(int, @unladenWeightString)
		SET @maximumPermissibleLadenWeight = CONVERT(int, @maximumPermissibleLadenWeightString)

		IF @hasErrors = 'true'
		BEGIN
			INSERT INTO dbo.Errors
			(
				ajoneuvoluokka_id,
				ensirekisterointipvm,
				ajoneuvoryhma_id,
				ajoneuvonkaytto_id,
				variantti,
				versio,
				kayttoonottopvm,
				vari_id,
				ovienLukumaara,
				korityyppi_id,
				ohjaamotyyppi_id,
				istumapaikkojenLkm,
				omamassa,
				teknSuurSallKokmassa,
				selite
			)
			VALUES
			(
				@classId,
				@registerDate,
				@groupId,
				@usageId,
				@variant,
				@version,
				@introductionDate,
				@colorId,
				@doorCount,
				@bodyId,
				@cabinId,
				@seatCount,
				@unladenWeight,
				@maximumPermissibleLadenWeight,
				@errorDescription
			)
		END

		ELSE
		BEGIN
			INSERT INTO dbo.Vehicles
			(
				ajoneuvoluokka_id,
				ensirekisterointipvm,
				ajoneuvoryhma_id,
				ajoneuvonkaytto_id,
				variantti,
				versio,
				kayttoonottopvm,
				vari_id,
				ovienLukumaara,
				korityyppi_id,
				ohjaamotyyppi_id,
				istumapaikkojenLkm,
				omamassa,
				teknSuurSallKokmassa
			)
			VALUES
			(
				@classId,
				@registerDate,
				@groupId,
				@usageId,
				@variant,
				@version,
				@introductionDate,
				@colorId,
				@doorCount,
				@bodyId,
				@cabinId,
				@seatCount,
				@unladenWeight,
				@maximumPermissibleLadenWeight
			)
		END
		
		FETCH NEXT FROM stagingCursor
		INTO @classCode,
			@registerDateString,
			@groupCode,
			@usageCode,
			@variant,
			@version,
			@introductionDateString,
			@colorCode,
			@doorCountString,
			@bodyCode,
			@cabinCode,
			@seatCountString,
			@unladenWeightString,
			@maximumPermissibleLadenWeightString;
	END
	
	CLOSE stagingCursor;
	
	DEALLOCATE stagingCursor;
END
GO
/****** Object:  StoredProcedure [dbo].[CreateFinalTables]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateFinalTables]
AS
BEGIN
	CREATE TABLE dbo.Vehicles
	(
		Id bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
		ajoneuvoluokka_id bigint NOT NULL,
		ensirekisterointipvm date,
		ajoneuvoryhma_id bigint NOT NULL,
		ajoneuvonkaytto_id bigint,
		variantti nvarchar(64),
		versio nvarchar(64),
		kayttoonottopvm date,
		vari_id bigint NOT NULL,
		ovienLukumaara bigint,
		korityyppi_id bigint NOT NULL,
		ohjaamotyyppi_id bigint NOT NULL,
		istumapaikkojenLkm bigint,
		omamassa bigint,
		teknSuurSallKokmassa bigint,

		CONSTRAINT FK_ajoneuvoluokka
		FOREIGN KEY (ajoneuvoluokka_id)
		REFERENCES dbo.AJONEUVOLUOKKA(Id),

		CONSTRAINT FK_ajoneuvoryhma
		FOREIGN KEY (ajoneuvoryhma_id)
		REFERENCES dbo.[AJONEUVORYHMÄ](Id),

		CONSTRAINT FK_ajoneuvonkaytto
		FOREIGN KEY (ajoneuvonkaytto_id)
		REFERENCES dbo.[AJONEUVON KAYTTO](Id),

		CONSTRAINT FK_vari
		FOREIGN KEY (vari_id)
		REFERENCES dbo.VARI(Id),

		CONSTRAINT FK_korityyppi
		FOREIGN KEY (korityyppi_id)
		REFERENCES dbo.KORITYYPPI(Id),

		CONSTRAINT FK_ohjaamotyyppi
		FOREIGN KEY (korityyppi_id)
		REFERENCES dbo.KORITYYPPI(Id)
	)

	CREATE TABLE dbo.Errors
	(
		Id bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
		ajoneuvoluokka_id bigint NOT NULL,
		ensirekisterointipvm date,
		ajoneuvoryhma_id bigint NOT NULL,
		ajoneuvonkaytto_id bigint NOT NULL,
		variantti nvarchar(64),
		versio nvarchar(64),
		kayttoonottopvm date,
		vari_id bigint NOT NULL,
		ovienLukumaara bigint,
		korityyppi_id bigint NOT NULL,
		ohjaamotyyppi_id bigint NOT NULL,
		istumapaikkojenLkm bigint,
		omamassa bigint,
		teknSuurSallKokmassa bigint,
		selite nvarchar(255)

		CONSTRAINT FK_errors_ajoneuvoluokka
		FOREIGN KEY (ajoneuvoluokka_id)
		REFERENCES dbo.AJONEUVOLUOKKA(Id),

		CONSTRAINT FK_errors_ajoneuvoryhma
		FOREIGN KEY (ajoneuvoryhma_id)
		REFERENCES dbo.[AJONEUVORYHMÄ](Id),

		CONSTRAINT FK_errors_ajoneuvonkaytto
		FOREIGN KEY (ajoneuvonkaytto_id)
		REFERENCES dbo.[AJONEUVON KAYTTO](Id),

		CONSTRAINT FK_errors_vari
		FOREIGN KEY (vari_id)
		REFERENCES dbo.VARI(Id),

		CONSTRAINT FK_errors_korityyppi
		FOREIGN KEY (korityyppi_id)
		REFERENCES dbo.KORITYYPPI(Id),

		CONSTRAINT FK_errors_ohjaamotyyppi
		FOREIGN KEY (korityyppi_id)
		REFERENCES dbo.KORITYYPPI(Id)
	)
END
GO
/****** Object:  StoredProcedure [dbo].[CreateStaging]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateStaging]
AS
CREATE TABLE [Traficom].[dbo].[Staging] (
	[ajoneuvoluokka] nvarchar(max),
	[ensirekisterointipvm] nvarchar(max),
	[ajoneuvoryhma] nvarchar(max),
	[ajoneuvonkaytto] nvarchar(max),
	[variantti] nvarchar(max),
	[versio] nvarchar(max),
	[kayttoonottopvm] nvarchar(max),
	[vari] nvarchar(max),
	[ovienLukumaara] nvarchar(max),
	[korityyppi] nvarchar(max),
	[ohjaamotyyppi] nvarchar(max),
	[istumapaikkojenLkm] nvarchar(max),
	[omamassa] nvarchar(max),
	[teknSuurSallKokmassa] nvarchar(max),
	[tieliikSuurSallKokmassa] nvarchar(max),
	[ajonKokPituus] nvarchar(max),
	[ajonLeveys] nvarchar(max),
	[ajonKorkeus] nvarchar(max),
	[kayttovoima] nvarchar(max),
	[iskutilavuus] nvarchar(max),
	[suurinNettoteho] nvarchar(max),
	[sylintereidenLkm] nvarchar(max),
	[ahdin] nvarchar(max),
	[sahkohybridi] nvarchar(max),
	[sahkohybridinluokka] nvarchar(max),
	[merkkiSelvakielinen] nvarchar(max),
	[mallimerkinta] nvarchar(max),
	[vaihteisto] nvarchar(max),
	[vaihteidenLkm] nvarchar(max),
	[kaupallinenNimi] nvarchar(max),
	[voimanvalJaTehostamistapa] nvarchar(max),
	[tyyppihyvaksyntanro] nvarchar(max),
	[yksittaisKayttovoima] nvarchar(max),
	[kunta] nvarchar(max),
	[Co2] nvarchar(max),
	[matkamittarilukema] nvarchar(max),
	[valmistenumero2] nvarchar(max),
	[jarnro] nvarchar(max)
)
GO
/****** Object:  StoredProcedure [dbo].[DropFinalTables]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropFinalTables]
AS
BEGIN
	DROP TABLE IF EXISTS dbo.Vehicles
	DROP TABLE IF EXISTS dbo.Errors
END
GO
/****** Object:  StoredProcedure [dbo].[DropStaging]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DropStaging]
AS
DROP TABLE IF EXISTS [Traficom].[dbo].[Staging]
GO
/****** Object:  StoredProcedure [dbo].[Loader]    Script Date: 11.12.2019 23.57.40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Loader]
AS
BULK INSERT [Traficom].[dbo].[Staging]
FROM 'C:\temp\TieliikenneAvoinData_5_8.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ';',
	ROWTERMINATOR = '\n'
)
GO
