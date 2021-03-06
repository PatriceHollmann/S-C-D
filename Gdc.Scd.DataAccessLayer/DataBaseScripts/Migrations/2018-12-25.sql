USE [Scd_2]
GO
/****** Object:  Table [History_RelatedItems].[CentralContractGroup]    Script Date: 24.12.2018 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [History_RelatedItems].[CentralContractGroup](
	[CostBlockHistory] [bigint] NOT NULL,
	[CentralContractGroup] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [InputAtoms].[CentralContractGroup]    Script Date: 24.12.2018 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[CentralContractGroup](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_CentralContractGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [InputAtoms].[CentralContractGroup] ON 

GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (1, N'UNASSIGNED', N'NA')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (2, N'STORAGE HIGHEND', N'CG330')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (3, N'STORAGE ENTRY', N'CG310')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (4, N'SERVER MIDRANGE', N'CG220')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (5, N'SERVER HIGHEND', N'CG230')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (6, N'SERVER ENTRY', N'CG210')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (7, N'SERVER  SUBENTRY/ SWAP / EXCHANGE', N'CG200')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (8, N'SECURITY DEVICES', N'CG060')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (9, N'RETAIL SUBENTRY/ SWAP / EXCHANGE', N'CG500')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (10, N'RETAIL PRODUCTS ENTRY', N'CG510')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (11, N'STORAGE MIDRANGE', N'CG320')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (12, N'PRINTER', N'CG070')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (13, N'ENTERPRISE SERVER MIDRANGE', N'CG260')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (14, N'ENTERPRISE SERVER HIGHEND', N'CG270')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (15, N'DISPLAYS', N'CG040')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (16, N'DISPLAY W/O ODM', N'CG041')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (17, N'CLIENTS SUBENTRY/ SWAP / EXCHANGE', N'CG100')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (18, N'CLIENTS MIDRANGE', N'CG120')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (19, N'CLIENTS HIGHEND', N'CG130')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (20, N'CLIENTS ENTRY', N'CG110')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (21, N'CENTRICSTOR', N'CG350')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (22, N'PERIPHERALS', N'CG050')
GO
INSERT [InputAtoms].[CentralContractGroup] ([Id], [Description], [Name]) VALUES (23, N'THIRD PARTY VENDORS', N'CG540')
GO
SET IDENTITY_INSERT [InputAtoms].[CentralContractGroup] OFF
GO

ALTER TABLE [InputAtoms].[Wg] ADD CentralContractGroupId bigint NULL

UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'AC2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'ACA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'ACC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG260') WHERE [Name] = 'AP1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG260') WHERE [Name] = 'AP2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG260') WHERE [Name] = 'AP3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG260') WHERE [Name] = 'AP4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'AP5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'AP6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'AP7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG260') WHERE [Name] = 'AP8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'AU1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'AU2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'B2R'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'B2T'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'BC1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'BC2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'BD2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'BD5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'BD8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BD9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BDH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BDL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'BDS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'BW1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C16'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C18'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C33'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C35'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C36'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C37'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C38'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C39'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C40'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C45'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C46'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG350') WHERE [Name] = 'C70'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C71'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C72'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C73'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C74'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C75'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C80'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C83'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'C84'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C90'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C91'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C92'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C95'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C96'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C97'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C98'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'C9A'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CC5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CC9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CD9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDM'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'CDU'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CE1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CE2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CS1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CS2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CS3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CS4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'CS5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'CS6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'CS7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CS8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CX3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'CXA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DPA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DPB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DPE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DPH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DPM'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG041') WHERE [Name] = 'DPX'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DS1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DYE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DYH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'DYM'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG200') WHERE [Name] = 'EC1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F11'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F12'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F13'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F14'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F15'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F16'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F17'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F18'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F19'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F20'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F21'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F22'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F23'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F24'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F25'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F26'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F27'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F28'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F29'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F30'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F31'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F32'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'F33'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F34'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F35'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F36'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F37'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F38'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F39'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F40'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F41'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F42'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F43'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F44'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F45'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F46'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F47'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F48'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F49'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F50'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F51'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F52'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F53'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F54'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F55'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F56'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG330') WHERE [Name] = 'F57'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'F58'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'FC8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'FC9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'FCS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'GA1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'GA2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'HMD'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'IE1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'IE2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'IOA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'IOB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'IOC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'IPR'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'IPT'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'LCR'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'LDE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'MC4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'MD1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'MN1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'MN2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'MN3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'MN4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'MN5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'MS1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'MS2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'MU1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG040') WHERE [Name] = 'MU2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'MZ1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NB9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'NBH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NBL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'NBP'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NBS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'NC1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NC2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'NC3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NC4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NC5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'NC6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NC7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'NC8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NC9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG070') WHERE [Name] = 'ND1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'ND2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'ND3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NEE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NEM'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NEP'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NME'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NML'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'NXL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG070') WHERE [Name] = 'O01'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG070') WHERE [Name] = 'O02'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG070') WHERE [Name] = 'O03'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P2A'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P2B'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P2C'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P4A'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P4B'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'P4C'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PA1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PA2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'PB2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'PB4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PB6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PB7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PE1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'PEN'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'PER'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG050') WHERE [Name] = 'PHL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'PP2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'PP4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ0'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG270') WHERE [Name] = 'PQ9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PRC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PS3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PSB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG060') WHERE [Name] = 'PSN'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PX1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PX2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PX3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PX6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PX7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'PX8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PXC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PXL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PXS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PY1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PY2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PY3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'PY4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PZ1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'PZ2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG510') WHERE [Name] = 'RB0'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG510') WHERE [Name] = 'RB1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG510') WHERE [Name] = 'RB2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG510') WHERE [Name] = 'RB3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG510') WHERE [Name] = 'RB4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RB5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RB6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RB7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RB8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RB9'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBG'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBI'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBJ'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBK'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBN'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBP'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBR'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG500') WHERE [Name] = 'RBX'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'RTE'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S14'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S15'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S16'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S17'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S18'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S19'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S20'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S30'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S33'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S34'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S35'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'S36'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG320') WHERE [Name] = 'S37'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S38'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S39'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S40'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S41'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S42'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S43'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S44'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S45'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S46'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S47'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S48'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'S49'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S50'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S51'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S52'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S53'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S54'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S55'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S56'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S57'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG310') WHERE [Name] = 'S58'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'SB1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'SB2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'SB3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'SRI'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC1'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC2'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC3'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC4'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'TC5'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'TC6'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'TC8'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'TCL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG540') WHERE [Name] = 'TPV'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'TR7'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'U01'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U02'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U03'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U04'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'U05'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'U06'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U07'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'U08'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'U09'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U10'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'U11'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'U12'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'U13'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG110') WHERE [Name] = 'U14'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'W01'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG100') WHERE [Name] = 'WRA'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WRC'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WSB'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WSH'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'WSJ'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'WSL'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WSN'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WSS'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG130') WHERE [Name] = 'WSU'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG120') WHERE [Name] = 'WSW'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'Y01'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y02'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y03'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y04'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y05'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y06'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y07'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y08'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'Y09'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y10'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'Y12'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y13'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y14'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y15'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'Y16'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y17'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y18'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y19'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y20'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y21'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG210') WHERE [Name] = 'Y22'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG230') WHERE [Name] = 'Y23'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y24'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y25'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y26'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y27'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y28'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y29'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y30'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y31'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y32'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y33'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y34'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y36'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y37'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y38'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y39'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'Y40'
UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = (SELECT Id FROM [InputAtoms].[CentralContractGroup] WHERE [Name] = 'CG220') WHERE [Name] = 'YGR'

UPDATE [InputAtoms].[Wg] SET CentralContractGroupId = 1 WHERE CentralContractGroupId IS NULL

ALTER TABLE [InputAtoms].[Wg]  WITH CHECK ADD  CONSTRAINT [FK_Wg_CentralContractGroup_CentralContractGroupId] FOREIGN KEY([CentralContractGroupId])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [InputAtoms].[Wg] CHECK CONSTRAINT [FK_Wg_CentralContractGroup_CentralContractGroupId]
GO

--FIELD SERVICE COST
ALTER TABLE [Hardware].[FieldServiceCost] ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[FieldServiceCost] WITH CHECK ADD  CONSTRAINT [FK_HardwareFieldServiceCostCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[FieldServiceCost] CHECK CONSTRAINT [FK_HardwareFieldServiceCostCentralContractGroup_InputAtomsCentralContractGroup]
GO



ALTER TABLE [History].[Hardware_FieldServiceCost] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_FieldServiceCost]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_FieldServiceCostCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_FieldServiceCost] CHECK CONSTRAINT [FK_HistoryHardware_FieldServiceCostCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[FieldServiceCost] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_FieldServiceCost] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])


--HISTORY RELATED ITEMS
ALTER TABLE [History_RelatedItems].[CentralContractGroup] ADD CentralContractGroup bigint NULL
ALTER TABLE [History_RelatedItems].[CentralContractGroup]  WITH CHECK ADD  CONSTRAINT [FK_History_RelatedItemsCentralContractGroupCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History_RelatedItems].[CentralContractGroup] CHECK CONSTRAINT [FK_History_RelatedItemsCentralContractGroupCentralContractGroup_InputAtomsCentralContractGroup]
GO
ALTER TABLE [History_RelatedItems].[CentralContractGroup]  WITH CHECK ADD  CONSTRAINT [FK_History_RelatedItemsCentralContractGroupCostBlockHistory_HistoryCostBlockHistory] FOREIGN KEY([CostBlockHistory])
REFERENCES [History].[CostBlockHistory] ([Id])
GO
ALTER TABLE [History_RelatedItems].[CentralContractGroup] CHECK CONSTRAINT [FK_History_RelatedItemsCentralContractGroupCostBlockHistory_HistoryCostBlockHistory]
GO

--INSTALL BASE
ALTER TABLE [Hardware].[InstallBase]  ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[InstallBase]  WITH CHECK ADD  CONSTRAINT [FK_InstallBase_CentralContractGroup_CentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[InstallBase] CHECK CONSTRAINT [FK_InstallBase_CentralContractGroup_CentralContractGroup]
GO

ALTER TABLE [History].[Hardware_InstallBase] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_InstallBase]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_InstallBaseCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_InstallBase] CHECK CONSTRAINT [FK_HistoryHardware_InstallBaseCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[InstallBase]
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_InstallBase]
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--LOGISTICS COST 
ALTER TABLE [Hardware].[LogisticsCosts]  ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[LogisticsCosts]  WITH CHECK ADD  CONSTRAINT [FK_HardwareLogisticsCostsCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[LogisticsCosts] CHECK CONSTRAINT [FK_HardwareLogisticsCostsCentralContractGroup_InputAtomsCentralContractGroup]
GO

ALTER TABLE [History].[Hardware_LogisticsCosts] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_LogisticsCosts]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_LogisticsCostsCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_LogisticsCosts] CHECK CONSTRAINT [FK_HistoryHardware_LogisticsCostsCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[LogisticsCosts] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_LogisticsCosts]
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--MARKUP OTHER COSTS
ALTER TABLE [Hardware].[MarkupOtherCosts]  ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[MarkupOtherCosts]  WITH CHECK ADD  CONSTRAINT [FK_HardwareMarkupOtherCostsCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[MarkupOtherCosts] CHECK CONSTRAINT [FK_HardwareMarkupOtherCostsCentralContractGroup_InputAtomsCentralContractGroup]
GO
ALTER TABLE [History].[Hardware_MarkupOtherCosts] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_MarkupOtherCosts]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_MarkupOtherCostsCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_MarkupOtherCosts] CHECK CONSTRAINT [FK_HistoryHardware_MarkupOtherCostsCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[MarkupOtherCosts]
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_MarkupOtherCosts]
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--MARKUP STANDARD WARRANTY
ALTER TABLE [Hardware].[MarkupStandardWaranty]  ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[MarkupStandardWaranty]  WITH CHECK ADD  CONSTRAINT [FK_HardwareMarkupStandardWarantyCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[MarkupStandardWaranty] CHECK CONSTRAINT [FK_HardwareMarkupStandardWarantyCentralContractGroup_InputAtomsCentralContractGroup]
GO

ALTER TABLE [History].[Hardware_MarkupStandardWaranty] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_MarkupStandardWaranty]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_MarkupStandardWarantyCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_MarkupStandardWaranty] CHECK CONSTRAINT [FK_HistoryHardware_MarkupStandardWarantyCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[MarkupStandardWaranty] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_MarkupStandardWaranty] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--HARDWARE PROACTIVE
ALTER TABLE [Hardware].[ProActive] ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[ProActive]  WITH CHECK ADD  CONSTRAINT [FK_HardwareProActiveCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[ProActive] CHECK CONSTRAINT [FK_HardwareProActiveCentralContractGroup_InputAtomsCentralContractGroup]
GO

ALTER TABLE [History].[Hardware_ProActive] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_ProActive]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_ProActiveCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_ProActive] CHECK CONSTRAINT [FK_HistoryHardware_ProActiveCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[ProActive] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_ProActive] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--PROLONGATION MARKUP
ALTER TABLE  [Hardware].[ProlongationMarkup] ADD CentralContractGroup bigint NULL
ALTER TABLE [Hardware].[ProlongationMarkup]  WITH CHECK ADD  CONSTRAINT [FK_HardwareProlongationMarkupCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [Hardware].[ProlongationMarkup] CHECK CONSTRAINT [FK_HardwareProlongationMarkupCentralContractGroup_InputAtomsCentralContractGroup]
GO

ALTER TABLE [History].[Hardware_ProlongationMarkup] ADD CentralContractGroup bigint NULL
ALTER TABLE [History].[Hardware_ProlongationMarkup]  WITH CHECK ADD  CONSTRAINT [FK_HistoryHardware_ProlongationMarkupCentralContractGroup_InputAtomsCentralContractGroup] FOREIGN KEY([CentralContractGroup])
REFERENCES [InputAtoms].[CentralContractGroup] ([Id])
GO
ALTER TABLE [History].[Hardware_ProlongationMarkup] CHECK CONSTRAINT [FK_HistoryHardware_ProlongationMarkupCentralContractGroup_InputAtomsCentralContractGroup]
GO

UPDATE [Hardware].[ProlongationMarkup] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

UPDATE [History].[Hardware_ProlongationMarkup] 
SET CentralContractGroup = (SELECT CentralContractGroupId FROM [InputAtoms].[Wg] WHERE Id = [Wg])

--CHANGE  CentralContractGroup to not NULL
ALTER TABLE [Hardware].[FieldServiceCost] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[InstallBase] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[LogisticsCosts] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[MarkupOtherCosts] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[MarkupStandardWaranty] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[ProActive] ALTER COLUMN CentralContractGroup bigint NOT NULL
ALTER TABLE [Hardware].[ProlongationMarkup] ALTER COLUMN CentralContractGroup bigint NOT NULL




