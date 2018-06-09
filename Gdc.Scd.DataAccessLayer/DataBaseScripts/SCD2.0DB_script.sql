USE [master]
GO
/****** Object:  Database [SCD2.0]    Script Date: 06/08/2018 16:56:52 ******/
CREATE DATABASE [SCD2.0] ON  PRIMARY 
( NAME = N'SCD2.0', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\SCD2.0.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'SCD2.0_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\SCD2.0_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [SCD2.0] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SCD2.0].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SCD2.0] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [SCD2.0] SET ANSI_NULLS OFF
GO
ALTER DATABASE [SCD2.0] SET ANSI_PADDING OFF
GO
ALTER DATABASE [SCD2.0] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [SCD2.0] SET ARITHABORT OFF
GO
ALTER DATABASE [SCD2.0] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [SCD2.0] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [SCD2.0] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [SCD2.0] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [SCD2.0] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [SCD2.0] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [SCD2.0] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [SCD2.0] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [SCD2.0] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [SCD2.0] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [SCD2.0] SET  DISABLE_BROKER
GO
ALTER DATABASE [SCD2.0] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [SCD2.0] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [SCD2.0] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [SCD2.0] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [SCD2.0] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [SCD2.0] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [SCD2.0] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [SCD2.0] SET  READ_WRITE
GO
ALTER DATABASE [SCD2.0] SET RECOVERY FULL
GO
ALTER DATABASE [SCD2.0] SET  MULTI_USER
GO
ALTER DATABASE [SCD2.0] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [SCD2.0] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'SCD2.0', N'ON'
GO
USE [SCD2.0]
GO
/****** Object:  Schema [System]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [System] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Solution]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [Solution] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [SoftwareAndSolution]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [SoftwareAndSolution] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Software]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [Software] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [SCDConfiguration]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [SCDConfiguration] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [InputAtoms]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [InputAtoms] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Hardware]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [Hardware] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Dependencies]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [Dependencies] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [CapabilityMatrix]    Script Date: 06/08/2018 16:56:52 ******/
CREATE SCHEMA [CapabilityMatrix] AUTHORIZATION [dbo]
GO
/****** Object:  Table [Dependencies].[Years]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[Years](
	[YearCode] [int] NOT NULL,
 CONSTRAINT [PK_Years] PRIMARY KEY CLUSTERED 
(
	[YearCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[WGs_SOGs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[WGs_SOGs](
	[WG] [nvarchar](3) NOT NULL,
	[SOG] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_WGs_SOGs] PRIMARY KEY CLUSTERED 
(
	[WG] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[WGs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[WGs](
	[WG] [nvarchar](3) NOT NULL,
	[HDDRetentionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_WGs] PRIMARY KEY CLUSTERED 
(
	[WG] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Software].[SystemHealthCheck]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Software].[SystemHealthCheck](
	[Country] [nvarchar](30) NULL,
	[SoftwareLicense] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[LocalRemoteAccessSetupPreparation] [float] NULL,
	[LocalRemoteAccessSetupPreparation_Approved] [float] NULL,
	[LocalRegularUpdateReadyForService] [float] NULL,
	[LocalRegularUpdateReadyForService_Approved] [float] NULL,
	[LocalPreparationSHC] [float] NULL,
	[LocalPreparationSHC_Approved] [float] NULL,
	[CentralExecutionSHCReport] [float] NULL,
	[CentralExecutionSHCReport_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[SystemHealthCheck]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[SystemHealthCheck](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[LocalRemoteAccessSetupPreparation] [float] NULL,
	[LocalRemoteAccessSetupPreparation_Approved] [float] NULL,
	[LocalRegularUpdateReadyForService] [float] NULL,
	[LocalRegularUpdateReadyForService_Approved] [float] NULL,
	[LocalPreparationSHC] [float] NULL,
	[LocalPreparationSHC_Approved] [float] NULL,
	[CentralExecutionSHCReport] [float] NULL,
	[CentralExecutionSHCReport_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SWLicenses_SOGs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SWLicenses_SOGs](
	[SWLicense] [nvarchar](30) NOT NULL,
	[SOG] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_SWLicenses_SOGs] PRIMARY KEY CLUSTERED 
(
	[SWLicense] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SWLicenses]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SWLicenses](
	[SWLicense] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_SWLicenses] PRIMARY KEY CLUSTERED 
(
	[SWLicense] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Software].[SW/SPMaintenanceListPrice]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Software].[SW/SPMaintenanceListPrice](
	[Country] [nvarchar](30) NULL,
	[SoftwareLicense] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[RecommendedSW/SPMaintenanceListPrice] [float] NULL,
	[RecommendedSW/SPMaintenanceListPrice_Approved] [float] NULL,
	[ReactionTimeCode] [nvarchar](1) NULL,
	[MarkupForProductMarginOfSWLicenseListPrice] [float] NULL,
	[MarkupForProductMarginOfSWLicenseListPrice_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SOGs_SFabs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SOGs_SFabs](
	[SOG] [nvarchar](3) NOT NULL,
	[SFab] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_SOGs_SFabs] PRIMARY KEY CLUSTERED 
(
	[SOG] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SOGs_Digits]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SOGs_Digits](
	[SOG] [nvarchar](3) NOT NULL,
	[Digit] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_SOGs_Digits] PRIMARY KEY CLUSTERED 
(
	[SOG] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SOGs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SOGs](
	[SOG] [nvarchar](3) NOT NULL,
	[ContractGroupCode] [int] NOT NULL,
 CONSTRAINT [PK_SOGs] PRIMARY KEY CLUSTERED 
(
	[SOG] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[SFabs_PLAs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[SFabs_PLAs](
	[SFab] [nvarchar](30) NOT NULL,
	[PLA] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_SFabs_PLAs] PRIMARY KEY CLUSTERED 
(
	[SFab] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Software].[ServiceSupportCost]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Software].[ServiceSupportCost](
	[Country] [nvarchar](30) NULL,
	[SoftwareLicense] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[1stLevelSupportCostsCountry] [float] NULL,
	[1stLevelSupportCostsCountry_Approved] [float] NULL,
	[2ndLevelSupportCostsPLAnonEMEIA] [float] NULL,
	[2ndLevelSupportCostsPLAnonEMEIA_Approved] [float] NULL,
	[2ndLevelSupportCostsPLA] [float] NULL,
	[2ndLevelSupportCostsPLA_Approved] [float] NULL,
	[InstalledBaseCountry] [float] NULL,
	[InstalledBaseCountry_Approved] [float] NULL,
	[InstalledBasePLA] [float] NULL,
	[InstalledBasePLA_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[ServiceSupportCost]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[ServiceSupportCost](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[1stLevelSupportCostsCountry] [float] NULL,
	[1stLevelSupportCostsCountry_Approved] [float] NULL,
	[2ndLevelSupportCostsPLAnonEMEIA] [float] NULL,
	[2ndLevelSupportCostsPLAnonEMEIA_Approved] [float] NULL,
	[2ndLevelSupportCostsPLA] [float] NULL,
	[2ndLevelSupportCostsPLA_Approved] [float] NULL,
	[InstalledBaseCountry] [float] NULL,
	[InstalledBaseCountry_Approved] [float] NULL,
	[InstalledBasePLA] [float] NULL,
	[InstalledBasePLA_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[ServiceLocations]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[ServiceLocations](
	[ServiceLocationCode] [nvarchar](1) NOT NULL,
	[Description] [nvarchar](30) NOT NULL,
	[ServiceLocation_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_ServiceLocations] PRIMARY KEY CLUSTERED 
(
	[ServiceLocationCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SCDTransactionDetail]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCDTransactionDetail](
	[TransactionID] [int] NOT NULL,
	[WG] [nvarchar](3) NOT NULL,
	[SoftwareLicense] [nvarchar](3) NULL,
	[CountryGroup] [nvarchar](30) NULL,
	[SOG] [nvarchar](3) NULL,
	[Digit] [nvarchar](30) NOT NULL,
	[SFab] [nvarchar](30) NOT NULL,
	[PLA] [nvarchar](30) NULL,
	[ClusteredPLA] [nvarchar](30) NULL,
	[DependencyColumn] [nvarchar](30) NULL,
	[DependencyValue] [nvarchar](30) NULL,
	[OldValue] [float] NOT NULL,
	[NewValue] [float] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SCDTransaction]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SCDTransaction](
	[TransactionID] [int] NOT NULL,
	[ChangeTimeStamp] [datetime] NOT NULL,
	[UserID] [nvarchar](30) NULL,
	[ApplicationType] [nvarchar](30) NULL,
	[CostBlock] [nvarchar](30) NULL,
	[CostElement] [nvarchar](30) NULL,
	[WG_Flag] [bit] NOT NULL,
	[SoftwareLicense_Flag] [bit] NOT NULL,
	[CountryGroup_Flag] [bit] NOT NULL,
	[SOG_Flag] [bit] NOT NULL,
	[Digit_Flag] [bit] NOT NULL,
	[SFab_Flag] [bit] NOT NULL,
	[PLA_Flag] [bit] NOT NULL,
	[ClusteredPLA_Flag] [bit] NOT NULL,
	[ApprovedBy] [nvarchar](30) NULL,
	[DeclinedBy] [nvarchar](30) NULL,
	[ApprovedTimeStamp] [datetime] NULL,
	[DeclinedTimeStamp] [datetime] NULL,
	[Comment] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[RoleCodes]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[RoleCodes](
	[RoleCodeCode] [nvarchar](6) NOT NULL,
	[Description] [nvarchar](30) NOT NULL,
	[RoleCode_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_RoleCodes] PRIMARY KEY CLUSTERED 
(
	[RoleCodeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Software].[Reinsurance]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Software].[Reinsurance](
	[Country] [nvarchar](30) NULL,
	[SoftwareLicense] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[ReinsuranceFlatfee1year] [float] NULL,
	[ReinsuranceFlatfee1year_Approved] [float] NULL,
	[ReactionTimeCode] [nvarchar](1) NULL,
	[ReinsuranceFlatfee2years] [float] NULL,
	[ReinsuranceFlatfee2years_Approved] [float] NULL,
	[ReinsuranceFlatfee3years] [float] NULL,
	[ReinsuranceFlatfee3years_Approved] [float] NULL,
	[ReinsuranceFlatfee4years] [float] NULL,
	[ReinsuranceFlatfee4years_Approved] [float] NULL,
	[ReinsuranceFlatfee5years] [float] NULL,
	[ReinsuranceFlatfee5years_Approved] [float] NULL,
	[ReinsuranceFlatfeeProlongation] [float] NULL,
	[ReinsuranceFlatfeeProlongation_Approved] [float] NULL,
	[CurrencyReinsurance] [float] NULL,
	[CurrencyReinsurance_Approved] [float] NULL,
	[ShareSW/SPMaintenanceListPrice] [float] NULL,
	[ShareSW/SPMaintenanceListPrice_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[Reinsurance]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[Reinsurance](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[ReinsuranceNBDinWarranty] [float] NULL,
	[ReinsuranceNBDinWarranty_Approved] [float] NULL,
	[ReinsuranceNBDOOW] [float] NULL,
	[ReinsuranceNBDOOW_Approved] [float] NULL,
	[Reinsurance7x24inWarranty] [float] NULL,
	[Reinsurance7x24inWarranty_Approved] [float] NULL,
	[Reinsurance7x24OOW] [float] NULL,
	[Reinsurance7x24OOW_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[ReactionTimes]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[ReactionTimes](
	[ReactionTimeCode] [nvarchar](1) NOT NULL,
	[Description] [nvarchar](30) NOT NULL,
	[ReactionTime_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_ReactionTimes] PRIMARY KEY CLUSTERED 
(
	[ReactionTimeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[PLAs_ClusteredPLAs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[PLAs_ClusteredPLAs](
	[PLA] [nvarchar](30) NOT NULL,
	[ClusteredPLA] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_PLAs_ClusteredPLAs] PRIMARY KEY CLUSTERED 
(
	[PLA] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[OtherCosts]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[OtherCosts](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[MarkupForOtherCost] [float] NULL,
	[MarkupForOtherCost_Approved] [float] NULL,
	[ProlongationMarkupForOtherCost] [float] NULL,
	[ProlongationMarkupForOtherCost_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[MaterialCosts]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[MaterialCosts](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[MaterialCostOOW] [float] NULL,
	[MaterialCostOOW_Approved] [float] NULL,
	[MaterialCostBaseWarranty] [float] NULL,
	[MaterialCostBaseWarranty_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[LogisticsCost]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[LogisticsCost](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[StandardHandlingInCountry] [float] NULL,
	[StandardHandlingInCountry_Approved] [float] NULL,
	[ReactionTimeCode] [nvarchar](1) NULL,
	[HighAvailabilityHandlingInCountry] [float] NULL,
	[HighAvailabilityHandlingInCountry_Approved] [float] NULL,
	[StandardDelivery] [float] NULL,
	[StandardDelivery_Approved] [float] NULL,
	[ExpressDelivery] [float] NULL,
	[ExpressDelivery_Approved] [float] NULL,
	[Taxi/CourierDelivery] [float] NULL,
	[Taxi/CourierDelivery_Approved] [float] NULL,
	[ReturnDeliveryToFactory] [float] NULL,
	[ReturnDeliveryToFactory_Approved] [float] NULL,
	[TaxAndDuties] [float] NULL,
	[TaxAndDuties_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[InstalledBaseCountry]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[InstalledBaseCountry](
	[WG] [nvarchar](3) NOT NULL,
	[Country] [nvarchar](30) NOT NULL,
	[InstalledBaseCountry] [float] NULL,
	[IsImported] [bit] NULL,
 CONSTRAINT [PK_InstalledBaseCountry] PRIMARY KEY CLUSTERED 
(
	[WG] ASC,
	[Country] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[IBCountriesNonAutomated]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[IBCountriesNonAutomated](
	[CountryCode] [int] NOT NULL,
	[CountryCode_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_IBCountriesNonAutomated] PRIMARY KEY CLUSTERED 
(
	[CountryCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[IBCountriesAutomated]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[IBCountriesAutomated](
	[CountryCode] [int] NOT NULL,
	[CountryCode_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_IBCountriesAutomated] PRIMARY KEY CLUSTERED 
(
	[CountryCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[FieldService]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[FieldService](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[TravelTime] [float] NULL,
	[TravelTime_Approved] [float] NULL,
	[OnsiteHourlyRate] [float] NULL,
	[OnsiteHourlyRate_Approved] [float] NULL,
	[RoleCodeCode] [nvarchar](6) NULL,
	[LabourFlatFee] [float] NULL,
	[LabourFlatFee_Approved] [float] NULL,
	[ServiceLocationCode] [nvarchar](1) NULL,
	[TravelCost] [float] NULL,
	[TravelCost_Approved] [float] NULL,
	[PerformanceRatePerReactiontime] [float] NULL,
	[PerformanceRatePerReactiontime_Approved] [float] NULL,
	[ReactionTimeCode] [nvarchar](1) NULL,
	[TimeAndMaterialShare] [float] NULL,
	[TimeAndMaterialShare_Approved] [float] NULL,
	[CostPerCallShare] [float] NULL,
	[CostPerCallShare_Approved] [float] NULL,
	[RepairTime] [float] NULL,
	[RepairTime_Approved] [float] NULL,
	[RoleCode] [float] NULL,
	[RoleCode_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[FailureRates]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[FailureRates](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[AFR] [float] NULL,
	[AFR_Approved] [float] NULL,
	[YearCode] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[Digits_SFabs]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[Digits_SFabs](
	[Digit] [nvarchar](30) NOT NULL,
	[SFab] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Digits_SFabs] PRIMARY KEY CLUSTERED 
(
	[Digit] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[Digits]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[Digits](
	[Digit] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_Digits] PRIMARY KEY CLUSTERED 
(
	[Digit] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CapabilityMatrix].[DeniedCouples]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapabilityMatrix].[DeniedCouples](
	[Country] [nvarchar](30) NULL,
	[AssetCode] [int] NULL,
	[AssetLocationCode] [int] NULL,
	[AvailabilityCode] [nvarchar](2) NULL,
	[DurationCode] [nvarchar](2) NULL,
	[ReactionTypeCode] [nvarchar](2) NULL,
	[ServiceLocationCode] [nvarchar](2) NULL,
	[ReactionTimeCode] [nvarchar](2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Software].[DealerPrice]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Software].[DealerPrice](
	[Country] [nvarchar](30) NULL,
	[SoftwareLicense] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[DiscountToDealerPrice] [float] NULL,
	[DiscountToDealerPrice_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[Countries_Regions]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[Countries_Regions](
	[Country] [nvarchar](30) NOT NULL,
	[Region] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Countries_Regions] PRIMARY KEY CLUSTERED 
(
	[Country] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[Countries]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[Countries](
	[Country] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[Country] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[CostBlocksConfig]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[CostBlocksConfig](
	[CostBlock] [nvarchar](50) NOT NULL,
	[Application] [nvarchar](50) NOT NULL,
	[CostBlock_Caption] [nvarchar](50) NULL,
	[CostBlock_ConfigTable] [nvarchar](80) NOT NULL,
 CONSTRAINT [PK_CostBlocksConfiguration] PRIMARY KEY CLUSTERED 
(
	[CostBlock] ASC,
	[Application] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [InputAtoms].[ContractGroups]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InputAtoms].[ContractGroups](
	[ContractGroupCode] [int] NOT NULL,
	[ContractGroupDescription] [nvarchar](30) NULL,
 CONSTRAINT [PK_ContractGroups] PRIMARY KEY CLUSTERED 
(
	[ContractGroupCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_SoftwareAndSolution_SystemHealthCheck]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_SoftwareAndSolution_SystemHealthCheck](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_SoftwareAndSolution_SW/SPMaintenanceListPrice]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_SoftwareAndSolution_SW/SPMaintenanceListPrice](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_SoftwareAndSolution_Reinsurance]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_SoftwareAndSolution_Reinsurance](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_SoftwareAndSolution_DealerPrice]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_SoftwareAndSolution_DealerPrice](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_HDDRetention_HDDRetention]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_HDDRetention_HDDRetention](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_SystemHealthCheck]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_SystemHealthCheck](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_Reinsurance]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_Reinsurance](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_OtherCosts]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_OtherCosts](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_MaterialCosts]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_MaterialCosts](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_LogisticsCost]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_LogisticsCost](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_FieldService]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_FieldService](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_FailureRates]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_FailureRates](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware_AvailabilityFee]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware_AvailabilityFee](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [SCDConfiguration].[Config_Hardware,SoftwareAndSolution_ServiceSupportCost]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SCDConfiguration].[Config_Hardware,SoftwareAndSolution_ServiceSupportCost](
	[CostElementName] [nvarchar](50) NULL,
	[DependencyName] [nvarchar](30) NULL,
	[DependencyTable] [nvarchar](30) NULL,
	[DependencyRelation] [nvarchar](30) NULL,
	[RelationToInputParameterTable] [nvarchar](30) NULL,
	[HasRelationToInputParameter] [nvarchar](30) NULL,
	[RelationToInputParameter] [nvarchar](30) NULL,
	[DataEntry] [nvarchar](30) NULL,
	[LowestInputLevel] [nvarchar](30) NULL,
	[DefaultInputLevel] [nvarchar](30) NULL,
	[HighestInputLevel] [nvarchar](30) NULL,
	[Unit] [nvarchar](30) NULL,
	[Domain] [nvarchar](30) NULL,
	[ApplicationPart] [nvarchar](30) NULL,
	[ManualChangeAllowed] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CapabilityMatrix].[CapabilityPortfolio]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapabilityMatrix].[CapabilityPortfolio](
	[Country] [nvarchar](30) NULL,
	[AssetCode] [int] NULL,
	[AssetLocationCode] [int] NULL,
	[AvailabilityCode] [nvarchar](2) NULL,
	[DurationCode] [nvarchar](2) NULL,
	[ReactionTypeCode] [nvarchar](2) NULL,
	[ServiceLocationCode] [nvarchar](2) NULL,
	[ReactionTimeCode] [nvarchar](2) NULL,
	[Allowed] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Hardware].[AvailabilityFee]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Hardware].[AvailabilityFee](
	[Country] [nvarchar](30) NULL,
	[WG] [nvarchar](3) NOT NULL,
	[IsImported] [bit] NOT NULL,
	[TotalLogisticsInfrastructureCost] [float] NULL,
	[TotalLogisticsInfrastructureCost_Approved] [float] NULL,
	[StockValueInCountryFJ] [float] NULL,
	[StockValueInCountryFJ_Approved] [float] NULL,
	[StockValueInCountryMV] [float] NULL,
	[StockValueInCountryMV_Approved] [float] NULL,
	[AverageContractDuration] [float] NULL,
	[AverageContractDuration_Approved] [float] NULL,
	[JapanBuy] [float] NULL,
	[JapanBuy_Approved] [float] NULL,
	[CostPerKit] [float] NULL,
	[CostPerKit_Approved] [float] NULL,
	[CostPerKitJapanBuy] [float] NULL,
	[CostPerKitJapanBuy_Approved] [float] NULL,
	[MaxQty] [float] NULL,
	[MaxQty_Approved] [float] NULL,
	[InstalledBaseHighAvailability] [float] NULL,
	[InstalledBaseHighAvailability_Approved] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Dependencies].[Availabilities]    Script Date: 06/08/2018 16:56:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dependencies].[Availabilities](
	[AvailabilityCode] [nvarchar](1) NOT NULL,
	[Description] [nvarchar](10) NOT NULL,
	[Availability_IDForSorting] [nvarchar](3) NOT NULL,
 CONSTRAINT [PK_Availabilities] PRIMARY KEY CLUSTERED 
(
	[AvailabilityCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__WGs__HDDRetentio__3C89F72A]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [InputAtoms].[WGs] ADD  DEFAULT ((0)) FOR [HDDRetentionFlag]
GO
/****** Object:  Default [DF__SystemHea__IsImp__2942188C]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Software].[SystemHealthCheck] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__SystemHea__IsImp__257187A8]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[SystemHealthCheck] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__SW/SPMain__IsImp__1DD065E0]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Software].[SW/SPMaintenanceListPrice] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__ServiceSu__IsImp__7D63964E]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Software].[ServiceSupportCost] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__ServiceSu__IsImp__7B7B4DDC]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[ServiceSupportCost] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__SCDTransa__WG_Fl__1F2E9E6D]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [WG_Flag]
GO
/****** Object:  Default [DF__SCDTransa__Softw__2022C2A6]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [SoftwareLicense_Flag]
GO
/****** Object:  Default [DF__SCDTransa__Count__2116E6DF]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [CountryGroup_Flag]
GO
/****** Object:  Default [DF__SCDTransa__SOG_F__220B0B18]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [SOG_Flag]
GO
/****** Object:  Default [DF__SCDTransa__Digit__22FF2F51]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [Digit_Flag]
GO
/****** Object:  Default [DF__SCDTransa__SFab___23F3538A]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [SFab_Flag]
GO
/****** Object:  Default [DF__SCDTransa__PLA_F__24E777C3]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [PLA_Flag]
GO
/****** Object:  Default [DF__SCDTransa__Clust__25DB9BFC]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [dbo].[SCDTransaction] ADD  DEFAULT ((0)) FOR [ClusteredPLA_Flag]
GO
/****** Object:  Default [DF__Reinsuran__IsImp__162F4418]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Software].[Reinsurance] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__Reinsuran__IsImp__125EB334]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[Reinsurance] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__OtherCost__IsImp__19FFD4FC]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[OtherCosts] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__MaterialC__IsImp__08D548FA]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[MaterialCosts] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__Logistics__IsImp__01342732]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[LogisticsCost] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__Installed__IsImp__39AD8A7F]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [InputAtoms].[InstalledBaseCountry] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__FieldServ__IsImp__77AABCF8]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[FieldService] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__FailureRa__IsImp__0CA5D9DE]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[FailureRates] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__DealerPri__IsImp__21A0F6C4]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Software].[DealerPrice] ADD  DEFAULT ((0)) FOR [IsImported]
GO
/****** Object:  Default [DF__Config_So__Manua__2759D01A]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_SoftwareAndSolution_SystemHealthCheck] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_So__Manua__1BE81D6E]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_SoftwareAndSolution_SW/SPMaintenanceListPrice] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_So__Manua__1446FBA6]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_SoftwareAndSolution_Reinsurance] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_So__Manua__1FB8AE52]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_SoftwareAndSolution_DealerPrice] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_HD__Manua__0E8E2250]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_HDDRetention_HDDRetention] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__23893F36]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_SystemHealthCheck] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__10766AC2]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_Reinsurance] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__18178C8A]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_OtherCosts] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__06ED0088]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_MaterialCosts] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__7F4BDEC0]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_LogisticsCost] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__75C27486]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_FieldService] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__0ABD916C]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_FailureRates] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__031C6FA4]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware_AvailabilityFee] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Config_Ha__Manua__7993056A]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [SCDConfiguration].[Config_Hardware,SoftwareAndSolution_ServiceSupportCost] ADD  DEFAULT ('true') FOR [ManualChangeAllowed]
GO
/****** Object:  Default [DF__Availabil__IsImp__0504B816]    Script Date: 06/08/2018 16:56:53 ******/
ALTER TABLE [Hardware].[AvailabilityFee] ADD  DEFAULT ((0)) FOR [IsImported]
GO
