USE [master]
GO

/****** Object:  Database [Scd_2]    Script Date: 6/25/2018 2:56:00 PM ******/
CREATE DATABASE [Scd_2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Scd_2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Scd_2.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Scd_2_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Scd_2_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [Scd_2] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Scd_2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [Scd_2] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [Scd_2] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [Scd_2] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [Scd_2] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [Scd_2] SET ARITHABORT OFF 
GO

ALTER DATABASE [Scd_2] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [Scd_2] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [Scd_2] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [Scd_2] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [Scd_2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [Scd_2] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [Scd_2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [Scd_2] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [Scd_2] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [Scd_2] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [Scd_2] SET  DISABLE_BROKER 
GO

ALTER DATABASE [Scd_2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [Scd_2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [Scd_2] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [Scd_2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [Scd_2] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [Scd_2] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [Scd_2] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [Scd_2] SET RECOVERY FULL 
GO

ALTER DATABASE [Scd_2] SET  MULTI_USER 
GO

ALTER DATABASE [Scd_2] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [Scd_2] SET DB_CHAINING OFF 
GO

ALTER DATABASE [Scd_2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [Scd_2] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [Scd_2] SET  READ_WRITE 
GO

