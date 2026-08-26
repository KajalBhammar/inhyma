USE [master]
GO
/****** Object:  Database [InhymaDB]    Script Date: 26-Aug-26 10:47:24 AM ******/
CREATE DATABASE [InhymaDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InhymaDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\InhymaDB.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'InhymaDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\InhymaDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [InhymaDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [InhymaDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [InhymaDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InhymaDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InhymaDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InhymaDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InhymaDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [InhymaDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [InhymaDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InhymaDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InhymaDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InhymaDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InhymaDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InhymaDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InhymaDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InhymaDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InhymaDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [InhymaDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InhymaDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InhymaDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [InhymaDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [InhymaDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InhymaDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InhymaDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [InhymaDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [InhymaDB] SET  MULTI_USER 
GO
ALTER DATABASE [InhymaDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InhymaDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [InhymaDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [InhymaDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [InhymaDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [InhymaDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [InhymaDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [InhymaDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [InhymaDB]
GO
/****** Object:  Table [dbo].[BlogPosts]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogPosts](
	[PostId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](250) NOT NULL,
	[Slug] [nvarchar](270) NOT NULL,
	[Tag] [nvarchar](80) NULL,
	[Excerpt] [nvarchar](800) NULL,
	[Body] [nvarchar](max) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[IconEmoji] [nvarchar](20) NULL,
	[ReadTime] [nvarchar](40) NULL,
	[Author] [nvarchar](120) NULL,
	[PublishedDate] [date] NULL,
	[IsPublished] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CallLogs]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CallLogs](
	[CallLogId] [int] IDENTITY(1,1) NOT NULL,
	[LeadId] [int] NOT NULL,
	[Notes] [nvarchar](max) NOT NULL,
	[NextReminderDate] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CallLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](120) NOT NULL,
	[Slug] [nvarchar](140) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
	[ShowOnHome] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientLogos]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientLogos](
	[LogoId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ImagePath] [nvarchar](255) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ClientLogos] PRIMARY KEY CLUSTERED 
(
	[LogoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoreValues]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoreValues](
	[ValueId] [int] IDENTITY(1,1) NOT NULL,
	[Icon] [nvarchar](20) NULL,
	[Title] [nvarchar](120) NOT NULL,
	[Body] [nvarchar](500) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ValueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Industries]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Industries](
	[IndustryId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](160) NOT NULL,
	[Slug] [nvarchar](180) NOT NULL,
	[ShortDescription] [nvarchar](800) NULL,
	[Description] [nvarchar](max) NULL,
	[IconEmoji] [nvarchar](20) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[IndustryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndustryTags]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndustryTags](
	[TagId] [int] IDENTITY(1,1) NOT NULL,
	[IndustryId] [int] NOT NULL,
	[TagText] [nvarchar](160) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Leads]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Leads](
	[LeadId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](160) NOT NULL,
	[Company] [nvarchar](200) NULL,
	[Mobile] [nvarchar](40) NULL,
	[Email] [nvarchar](160) NULL,
	[Industry] [nvarchar](120) NULL,
	[ProductRequirement] [nvarchar](200) NULL,
	[Quantity] [nvarchar](80) NULL,
	[Budget] [nvarchar](80) NULL,
	[Subject] [nvarchar](200) NULL,
	[Message] [nvarchar](max) NULL,
	[Source] [nvarchar](40) NOT NULL,
	[Status] [nvarchar](40) NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LeadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductApplications]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductApplications](
	[AppId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[AppText] [nvarchar](160) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductFeatures]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductFeatures](
	[FeatureId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[FeatureText] [nvarchar](160) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FeatureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductImages]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductImages](
	[ImageId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[FilePath] [nvarchar](400) NOT NULL,
	[FileName] [nvarchar](260) NULL,
	[AltText] [nvarchar](200) NULL,
	[IsPrimary] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Slug] [nvarchar](220) NOT NULL,
	[CategoryLabel] [nvarchar](120) NULL,
	[ShortDescription] [nvarchar](600) NULL,
	[Description] [nvarchar](max) NULL,
	[Badge] [nvarchar](60) NULL,
	[IsFeatured] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
	[SubcategoryId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductSpecs]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductSpecs](
	[SpecId] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[SpecName] [nvarchar](160) NOT NULL,
	[SpecValue] [nvarchar](400) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SpecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SiteSettings]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteSettings](
	[SettingId] [int] IDENTITY(1,1) NOT NULL,
	[SettingKey] [nvarchar](120) NOT NULL,
	[SettingValue] [nvarchar](max) NULL,
	[SettingGroup] [nvarchar](60) NULL,
	[Label] [nvarchar](160) NULL,
	[UpdatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[SettingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SettingKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SolutionFeatures]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SolutionFeatures](
	[FeatureId] [int] IDENTITY(1,1) NOT NULL,
	[SolutionId] [int] NOT NULL,
	[FeatureText] [nvarchar](300) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FeatureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Solutions]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Solutions](
	[SolutionId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Slug] [nvarchar](220) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[SolutionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stats]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stats](
	[StatId] [int] IDENTITY(1,1) NOT NULL,
	[Label] [nvarchar](120) NOT NULL,
	[Value] [int] NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[StatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Subcategories]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subcategories](
	[SubcategoryId] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[Name] [nvarchar](120) NOT NULL,
	[Slug] [nvarchar](140) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[UpdatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[SubcategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Subcategories_Category_Slug] UNIQUE NONCLUSTERED 
(
	[CategoryId] ASC,
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TeamMembers]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TeamMembers](
	[MemberId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](120) NOT NULL,
	[Role] [nvarchar](120) NULL,
	[Initials] [nvarchar](8) NULL,
	[ImagePath] [nvarchar](400) NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Testimonials]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Testimonials](
	[TestimonialId] [int] IDENTITY(1,1) NOT NULL,
	[AuthorName] [nvarchar](120) NOT NULL,
	[AuthorRole] [nvarchar](120) NULL,
	[Initials] [nvarchar](8) NULL,
	[Rating] [int] NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TestimonialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](60) NOT NULL,
	[Email] [nvarchar](160) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[FullName] [nvarchar](120) NULL,
	[Role] [nvarchar](30) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[LastLoginAt] [datetime2](7) NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlogPosts] ADD  CONSTRAINT [DF_BlogPosts_Published]  DEFAULT ((1)) FOR [IsPublished]
GO
ALTER TABLE [dbo].[BlogPosts] ADD  CONSTRAINT [DF_BlogPosts_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CallLogs] ADD  CONSTRAINT [DF_CallLogs_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [DF_Categories_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [DF_Categories_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [DF_Categories_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [DF_Categories_ShowOnHome]  DEFAULT ((1)) FOR [ShowOnHome]
GO
ALTER TABLE [dbo].[ClientLogos] ADD  CONSTRAINT [DF_ClientLogos_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[ClientLogos] ADD  CONSTRAINT [DF_ClientLogos_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ClientLogos] ADD  CONSTRAINT [DF_ClientLogos_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CoreValues] ADD  CONSTRAINT [DF_CoreValues_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[CoreValues] ADD  CONSTRAINT [DF_CoreValues_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Industries] ADD  CONSTRAINT [DF_Industries_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Industries] ADD  CONSTRAINT [DF_Industries_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Industries] ADD  CONSTRAINT [DF_Industries_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[IndustryTags] ADD  CONSTRAINT [DF_IndustryTags_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Leads] ADD  CONSTRAINT [DF_Leads_Source]  DEFAULT ('contact') FOR [Source]
GO
ALTER TABLE [dbo].[Leads] ADD  CONSTRAINT [DF_Leads_Status]  DEFAULT ('new') FOR [Status]
GO
ALTER TABLE [dbo].[Leads] ADD  CONSTRAINT [DF_Leads_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ProductApplications] ADD  CONSTRAINT [DF_ProductApplications_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[ProductFeatures] ADD  CONSTRAINT [DF_ProductFeatures_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[ProductImages] ADD  CONSTRAINT [DF_ProductImages_Primary]  DEFAULT ((0)) FOR [IsPrimary]
GO
ALTER TABLE [dbo].[ProductImages] ADD  CONSTRAINT [DF_ProductImages_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[ProductImages] ADD  CONSTRAINT [DF_ProductImages_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_Featured]  DEFAULT ((0)) FOR [IsFeatured]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ProductSpecs] ADD  CONSTRAINT [DF_ProductSpecs_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[SolutionFeatures] ADD  CONSTRAINT [DF_SolutionFeatures_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Solutions] ADD  CONSTRAINT [DF_Solutions_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Solutions] ADD  CONSTRAINT [DF_Solutions_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Solutions] ADD  CONSTRAINT [DF_Solutions_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Stats] ADD  CONSTRAINT [DF_Stats_Value]  DEFAULT ((0)) FOR [Value]
GO
ALTER TABLE [dbo].[Stats] ADD  CONSTRAINT [DF_Stats_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Stats] ADD  CONSTRAINT [DF_Stats_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Subcategories] ADD  CONSTRAINT [DF_Subcategories_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Subcategories] ADD  CONSTRAINT [DF_Subcategories_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Subcategories] ADD  CONSTRAINT [DF_Subcategories_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[TeamMembers] ADD  CONSTRAINT [DF_TeamMembers_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[TeamMembers] ADD  CONSTRAINT [DF_TeamMembers_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Testimonials] ADD  CONSTRAINT [DF_Testimonials_Rating]  DEFAULT ((5)) FOR [Rating]
GO
ALTER TABLE [dbo].[Testimonials] ADD  CONSTRAINT [DF_Testimonials_Order]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[Testimonials] ADD  CONSTRAINT [DF_Testimonials_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Testimonials] ADD  CONSTRAINT [DF_Testimonials_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Role]  DEFAULT ('admin') FOR [Role]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_CreatedAt]  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CallLogs]  WITH CHECK ADD FOREIGN KEY([LeadId])
REFERENCES [dbo].[Leads] ([LeadId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IndustryTags]  WITH CHECK ADD  CONSTRAINT [FK_IndustryTags_Industries] FOREIGN KEY([IndustryId])
REFERENCES [dbo].[Industries] ([IndustryId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IndustryTags] CHECK CONSTRAINT [FK_IndustryTags_Industries]
GO
ALTER TABLE [dbo].[ProductApplications]  WITH CHECK ADD  CONSTRAINT [FK_ProductApplications_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ProductId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductApplications] CHECK CONSTRAINT [FK_ProductApplications_Products]
GO
ALTER TABLE [dbo].[ProductFeatures]  WITH CHECK ADD  CONSTRAINT [FK_ProductFeatures_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ProductId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductFeatures] CHECK CONSTRAINT [FK_ProductFeatures_Products]
GO
ALTER TABLE [dbo].[ProductImages]  WITH CHECK ADD  CONSTRAINT [FK_ProductImages_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ProductId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductImages] CHECK CONSTRAINT [FK_ProductImages_Products]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Categories]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Subcategories] FOREIGN KEY([SubcategoryId])
REFERENCES [dbo].[Subcategories] ([SubcategoryId])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Subcategories]
GO
ALTER TABLE [dbo].[ProductSpecs]  WITH CHECK ADD  CONSTRAINT [FK_ProductSpecs_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([ProductId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductSpecs] CHECK CONSTRAINT [FK_ProductSpecs_Products]
GO
ALTER TABLE [dbo].[SolutionFeatures]  WITH CHECK ADD  CONSTRAINT [FK_SolutionFeatures_Solutions] FOREIGN KEY([SolutionId])
REFERENCES [dbo].[Solutions] ([SolutionId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SolutionFeatures] CHECK CONSTRAINT [FK_SolutionFeatures_Solutions]
GO
ALTER TABLE [dbo].[Subcategories]  WITH CHECK ADD  CONSTRAINT [FK_Subcategories_Categories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([CategoryId])
GO
ALTER TABLE [dbo].[Subcategories] CHECK CONSTRAINT [FK_Subcategories_Categories]
GO
/****** Object:  StoredProcedure [dbo].[usp_Blog_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   BLOG
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Blog_Manage]
    @Action             VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'GET_BY_SLUG', 'GET_RELATED', 'CREATE', 'UPDATE', 'DELETE'
    @PostId             INT = NULL,
    @Title              NVARCHAR(250) = NULL,
    @Slug               NVARCHAR(270) = NULL,
    @Tag                NVARCHAR(80) = NULL,
    @Excerpt            NVARCHAR(800) = NULL,
    @Body               NVARCHAR(MAX) = NULL,
    @ImagePath          NVARCHAR(400) = NULL,
    @IconEmoji          NVARCHAR(20) = NULL,
    @ReadTime           NVARCHAR(40) = NULL,
    @Author             NVARCHAR(120) = NULL,
    @PublishedDate      DATE = NULL,
    @IsPublished        BIT = NULL,
    @IncludeUnpublished BIT = 0,
    @Top                INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT TOP (COALESCE(@Top, 100000))
            PostId, Title, Slug, Tag, Excerpt, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM dbo.BlogPosts
        WHERE (@IncludeUnpublished = 1 OR IsPublished = 1)
        ORDER BY PublishedDate DESC, PostId DESC;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT PostId, Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM dbo.BlogPosts WHERE PostId = @PostId;
    END
    ELSE IF @Action = 'GET_BY_SLUG'
    BEGIN
        SELECT PostId, Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM dbo.BlogPosts WHERE Slug = @Slug;
    END
    ELSE IF @Action = 'GET_RELATED'
    BEGIN
        SELECT TOP (COALESCE(@Top, 3)) PostId, Title, Slug, Tag, IconEmoji, ImagePath, ReadTime, PublishedDate
        FROM dbo.BlogPosts
        WHERE IsPublished = 1 AND PostId <> @PostId
        ORDER BY PublishedDate DESC, PostId DESC;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.BlogPosts (Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished)
        VALUES (@Title, @Slug, @Tag, @Excerpt, @Body, @ImagePath, @IconEmoji, @ReadTime, @Author, @PublishedDate, COALESCE(@IsPublished, 1));
        SELECT SCOPE_IDENTITY() AS PostId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.BlogPosts
        SET Title = @Title, Slug = @Slug, Tag = @Tag, Excerpt = @Excerpt, Body = @Body,
            ImagePath = COALESCE(@ImagePath, ImagePath), IconEmoji = @IconEmoji, ReadTime = @ReadTime,
            Author = @Author, PublishedDate = @PublishedDate, IsPublished = @IsPublished, UpdatedAt = SYSUTCDATETIME()
        WHERE PostId = @PostId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.BlogPosts WHERE PostId = @PostId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Category_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   CATEGORIES
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Category_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @CategoryId      INT = NULL,
    @Name            NVARCHAR(120) = NULL,
    @Slug            NVARCHAR(140) = NULL,
    @Description     NVARCHAR(500) = NULL,
    @ImagePath       NVARCHAR(400) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @ShowOnHome      BIT = 1,
    @IncludeInactive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT c.CategoryId, c.Name, c.Slug, c.Description,
               COALESCE(c.ImagePath, (
                   SELECT TOP 1 pi.FilePath
                   FROM dbo.Products p
                   JOIN dbo.ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.CategoryId = c.CategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
               )) AS ImagePath,
               c.DisplayOrder, c.IsActive, c.ShowOnHome,
               (SELECT COUNT(*) FROM dbo.Subcategories s
                WHERE s.CategoryId = c.CategoryId
                  AND (@IncludeInactive = 1 OR s.IsActive = 1)) AS SubcategoryCount,
               (SELECT COUNT(*) FROM dbo.Products p
                WHERE p.CategoryId = c.CategoryId
                  AND (@IncludeInactive = 1 OR p.IsActive = 1)) AS ProductCount
        FROM dbo.Categories c
        WHERE (@IncludeInactive = 1 OR c.IsActive = 1)
        ORDER BY c.DisplayOrder, c.Name;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT c.CategoryId, c.Name, c.Slug, c.Description,
               COALESCE(c.ImagePath, (
                   SELECT TOP 1 pi.FilePath
                   FROM dbo.Products p
                   JOIN dbo.ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.CategoryId = c.CategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
               )) AS ImagePath,
               c.DisplayOrder, c.IsActive, c.ShowOnHome
        FROM dbo.Categories c WHERE c.CategoryId = @CategoryId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Categories (Name, Slug, Description, ImagePath, DisplayOrder, IsActive, ShowOnHome)
        VALUES (@Name, @Slug, @Description, @ImagePath, @DisplayOrder, @IsActive, @ShowOnHome);
        SELECT SCOPE_IDENTITY() AS CategoryId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Categories
        SET Name = @Name, Slug = @Slug, Description = @Description,
            ImagePath = COALESCE(@ImagePath, ImagePath),
            DisplayOrder = @DisplayOrder, IsActive = @IsActive, ShowOnHome = @ShowOnHome, UpdatedAt = SYSUTCDATETIME()
        WHERE CategoryId = @CategoryId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        UPDATE dbo.Products SET SubcategoryId = NULL WHERE CategoryId = @CategoryId;
        DELETE FROM dbo.Subcategories WHERE CategoryId = @CategoryId;
        DELETE FROM dbo.Categories WHERE CategoryId = @CategoryId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_ClientLogo_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =========================================================================
   CLIENT LOGOS
   ========================================================================= */
CREATE   PROCEDURE [dbo].[usp_ClientLogo_Manage]
    @Action        NVARCHAR(50),
    @LogoId        INT = NULL,
    @Name          NVARCHAR(100) = NULL,
    @ImagePath     NVARCHAR(255) = NULL,
    @DisplayOrder  INT = 0,
    @IsActive      BIT = 1,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT *
        FROM dbo.ClientLogos
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder ASC, Name ASC;
    END

    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT *
        FROM dbo.ClientLogos WHERE LogoId = @LogoId;
    END

    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.ClientLogos (Name, ImagePath, DisplayOrder, IsActive)
        VALUES (@Name, @ImagePath, @DisplayOrder, @IsActive);
    END

    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.ClientLogos
        SET Name = ISNULL(@Name, Name),
            ImagePath = ISNULL(@ImagePath, ImagePath),
            DisplayOrder = ISNULL(@DisplayOrder, DisplayOrder),
            IsActive = ISNULL(@IsActive, IsActive)
        WHERE LogoId = @LogoId;
    END

    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.ClientLogos WHERE LogoId = @LogoId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Dashboard_Counts]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   DASHBOARD
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Dashboard_Counts]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM dbo.Products)                     AS Products,
        (SELECT COUNT(*) FROM dbo.Categories)                   AS Categories,
        (SELECT COUNT(*) FROM dbo.Industries)                   AS Industries,
        (SELECT COUNT(*) FROM dbo.Solutions)                    AS Solutions,
        (SELECT COUNT(*) FROM dbo.BlogPosts)                    AS BlogPosts,
        (SELECT COUNT(*) FROM dbo.Leads)                        AS Leads,
        (SELECT COUNT(*) FROM dbo.Leads WHERE Status = 'new')   AS NewLeads,
        (SELECT COUNT(*) FROM dbo.Testimonials)                 AS Testimonials;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Industry_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   INDUSTRIES
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Industry_Manage]
    @Action           VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'GET_BY_SLUG', 'CREATE', 'UPDATE', 'DELETE', 'CREATE_TAG', 'DELETE_TAGS'
    @IndustryId       INT = NULL,
    @Name             NVARCHAR(160) = NULL,
    @Slug             NVARCHAR(180) = NULL,
    @ShortDescription NVARCHAR(800) = NULL,
    @Description      NVARCHAR(MAX) = NULL,
    @IconEmoji        NVARCHAR(20) = NULL,
    @ImagePath        NVARCHAR(400) = NULL,
    @DisplayOrder     INT = 0,
    @IsActive         BIT = 1,
    @IncludeInactive  BIT = 0,
    @TagText          NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT IndustryId, Name, Slug, ShortDescription, IconEmoji, ImagePath, DisplayOrder, IsActive
        FROM dbo.Industries
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, Name;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT IndustryId, Name, Slug, ShortDescription, Description, IconEmoji, ImagePath, DisplayOrder, IsActive
        FROM dbo.Industries WHERE IndustryId = @IndustryId;

        SELECT TagId, TagText, DisplayOrder FROM dbo.IndustryTags
        WHERE IndustryId = @IndustryId ORDER BY DisplayOrder, TagId;
    END
    ELSE IF @Action = 'GET_BY_SLUG'
    BEGIN
        DECLARE @Id INT = (SELECT IndustryId FROM dbo.Industries WHERE Slug = @Slug);
        IF @Id IS NOT NULL
        BEGIN
            EXEC dbo.usp_Industry_Manage @Action = 'GET_BY_ID', @IndustryId = @Id;
        END
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Industries (Name, Slug, ShortDescription, Description, IconEmoji, ImagePath, DisplayOrder, IsActive)
        VALUES (@Name, @Slug, @ShortDescription, @Description, @IconEmoji, @ImagePath, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS IndustryId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Industries
        SET Name = @Name, Slug = @Slug, ShortDescription = @ShortDescription, Description = @Description,
            IconEmoji = @IconEmoji, ImagePath = COALESCE(@ImagePath, ImagePath),
            DisplayOrder = @DisplayOrder, IsActive = @IsActive, UpdatedAt = SYSUTCDATETIME()
        WHERE IndustryId = @IndustryId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Industries WHERE IndustryId = @IndustryId;
    END
    ELSE IF @Action = 'CREATE_TAG'
    BEGIN
        INSERT INTO dbo.IndustryTags (IndustryId, TagText, DisplayOrder)
        VALUES (@IndustryId, @TagText, @DisplayOrder);
    END
    ELSE IF @Action = 'DELETE_TAGS'
    BEGIN
        DELETE FROM dbo.IndustryTags WHERE IndustryId = @IndustryId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Lead_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   LEADS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Lead_Manage]
    @Action             VARCHAR(20), -- 'CREATE', 'GET_ALL', 'GET_BY_ID', 'UPDATE_STATUS', 'DELETE', 'CREATE_CALL_LOG', 'GET_CALL_LOGS'
    @LeadId             INT = NULL,
    @Name               NVARCHAR(160) = NULL,
    @Company            NVARCHAR(200) = NULL,
    @Mobile             NVARCHAR(40) = NULL,
    @Email              NVARCHAR(160) = NULL,
    @Industry           NVARCHAR(120) = NULL,
    @ProductRequirement NVARCHAR(200) = NULL,
    @Quantity           NVARCHAR(80) = NULL,
    @Budget             NVARCHAR(80) = NULL,
    @Subject            NVARCHAR(200) = NULL,
    @Message            NVARCHAR(MAX) = NULL,
    @Source             NVARCHAR(40) = 'contact',
    @Status             NVARCHAR(40) = NULL,
    
    -- Call Log parameters
    @Notes              NVARCHAR(MAX) = NULL,
    @NextReminderDate   DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Leads (Name, Company, Mobile, Email, Industry, ProductRequirement, Quantity, Budget, Subject, Message, Source)
        VALUES (@Name, @Company, @Mobile, @Email, @Industry, @ProductRequirement, @Quantity, @Budget, @Subject, @Message, @Source);
        SELECT SCOPE_IDENTITY() AS LeadId;
    END
    ELSE IF @Action = 'GET_ALL'
    BEGIN
        SELECT LeadId, Name, Company, Mobile, Email, Industry, ProductRequirement, Quantity, Budget,
               Subject, Message, Source, Status, CreatedAt,
               (SELECT TOP 1 NextReminderDate 
                FROM dbo.CallLogs 
                WHERE LeadId = L.LeadId AND NextReminderDate IS NOT NULL AND NextReminderDate >= SYSUTCDATETIME()
                ORDER BY NextReminderDate ASC) AS NextReminderDate
        FROM dbo.Leads L
        WHERE (@Status IS NULL OR Status = @Status)
        ORDER BY CreatedAt DESC;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT LeadId, Name, Company, Mobile, Email, Industry, ProductRequirement, Quantity, Budget,
               Subject, Message, Source, Status, CreatedAt,
               (SELECT TOP 1 NextReminderDate 
                FROM dbo.CallLogs 
                WHERE LeadId = @LeadId AND NextReminderDate IS NOT NULL AND NextReminderDate >= SYSUTCDATETIME()
                ORDER BY NextReminderDate ASC) AS NextReminderDate
        FROM dbo.Leads WHERE LeadId = @LeadId;
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE dbo.Leads SET Status = @Status WHERE LeadId = @LeadId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Leads WHERE LeadId = @LeadId;
    END
    ELSE IF @Action = 'CREATE_CALL_LOG'
    BEGIN
        INSERT INTO dbo.CallLogs (LeadId, Notes, NextReminderDate)
        VALUES (@LeadId, @Notes, @NextReminderDate);
        SELECT SCOPE_IDENTITY() AS CallLogId;
    END
    ELSE IF @Action = 'GET_CALL_LOGS'
    BEGIN
        SELECT CallLogId, LeadId, Notes, NextReminderDate, CreatedAt
        FROM dbo.CallLogs
        WHERE LeadId = @LeadId
        ORDER BY CreatedAt DESC;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Product_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   PRODUCTS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Product_Manage]
    @Action           VARCHAR(30), -- includes 'GET_ALL', 'GET_EXPORT', CRUD and child collection actions
    @ProductId        INT = NULL,
    @CategoryId       INT = NULL,
    @SubcategoryId    INT = NULL,
    @Name             NVARCHAR(200) = NULL,
    @Slug             NVARCHAR(220) = NULL,
    @CategoryLabel    NVARCHAR(120) = NULL,
    @ShortDescription NVARCHAR(600) = NULL,
    @Description      NVARCHAR(MAX) = NULL,
    @Badge            NVARCHAR(60) = NULL,
    @IsFeatured       BIT = NULL,
    @IsActive         BIT = NULL,
    @DisplayOrder     INT = 0,
    @CategorySlug     NVARCHAR(140) = NULL,
    @SubcategorySlug  NVARCHAR(140) = NULL,
    @Search           NVARCHAR(200) = NULL,
    @IncludeInactive  BIT = 0,
    @FeaturedOnly     BIT = 0,
    @Top              INT = NULL,
    
    -- Child lists parameters
    @FeatureText      NVARCHAR(160) = NULL,
    @SpecName         NVARCHAR(160) = NULL,
    @SpecValue        NVARCHAR(400) = NULL,
    @AppText          NVARCHAR(160) = NULL,
    
    -- Image parameters
    @ImageId          INT = NULL,
    @FilePath         NVARCHAR(400) = NULL,
    @FileName         NVARCHAR(260) = NULL,
    @AltText          NVARCHAR(200) = NULL,
    @IsPrimary        BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EffectiveCategoryId INT = @CategoryId;
    DECLARE @EffectiveSubcategoryId INT = @SubcategoryId;

    IF @Action IN ('CREATE', 'UPDATE')
    BEGIN
        IF @EffectiveSubcategoryId IS NOT NULL
        BEGIN
            SELECT @EffectiveCategoryId = CategoryId
            FROM dbo.Subcategories
            WHERE SubcategoryId = @EffectiveSubcategoryId;
        END
        ELSE IF @EffectiveCategoryId IS NOT NULL
        BEGIN
            SELECT @EffectiveSubcategoryId = SubcategoryId
            FROM dbo.Subcategories
            WHERE CategoryId = @EffectiveCategoryId AND Slug = 'general-products';

            IF @EffectiveSubcategoryId IS NULL
            BEGIN
                INSERT INTO dbo.Subcategories
                    (CategoryId, Name, Slug, Description, DisplayOrder, IsActive)
                VALUES
                    (@EffectiveCategoryId, 'General Products', 'general-products',
                     'Products awaiting assignment to a specific subcategory.', 9999, 1);
                SET @EffectiveSubcategoryId = SCOPE_IDENTITY();
            END
        END
    END

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT TOP (COALESCE(@Top, 100000))
            p.ProductId, p.Name, p.Slug, p.CategoryLabel, p.ShortDescription, p.Badge,
            p.IsFeatured, p.IsActive, p.DisplayOrder, p.CategoryId, p.SubcategoryId,
            c.Name AS CategoryName, c.Slug AS CategorySlug,
            s.Name AS SubcategoryName, s.Slug AS SubcategorySlug,
            (SELECT TOP 1 pi.FilePath FROM dbo.ProductImages pi
                WHERE pi.ProductId = p.ProductId
                ORDER BY pi.IsPrimary DESC, pi.DisplayOrder, pi.ImageId) AS PrimaryImage
        FROM dbo.Products p
        LEFT JOIN dbo.Categories c ON c.CategoryId = p.CategoryId
        LEFT JOIN dbo.Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE (@IncludeInactive = 1 OR p.IsActive = 1)
          AND (@FeaturedOnly = 0 OR p.IsFeatured = 1)
          AND (@CategorySlug IS NULL OR c.Slug = @CategorySlug)
          AND (@SubcategorySlug IS NULL OR s.Slug = @SubcategorySlug)
          AND (@Search IS NULL OR p.Name LIKE '%' + @Search + '%'
               OR p.ShortDescription LIKE '%' + @Search + '%'
               OR p.CategoryLabel LIKE '%' + @Search + '%'
               OR c.Name LIKE '%' + @Search + '%'
               OR s.Name LIKE '%' + @Search + '%')
        ORDER BY p.DisplayOrder, p.Name;
    END
    ELSE IF @Action = 'GET_EXPORT'
    BEGIN
        CREATE TABLE #ExportProducts (ProductId INT NOT NULL PRIMARY KEY);

        INSERT INTO #ExportProducts (ProductId)
        SELECT p.ProductId
        FROM dbo.Products p
        LEFT JOIN dbo.Categories c ON c.CategoryId = p.CategoryId
        LEFT JOIN dbo.Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE (@IncludeInactive = 1 OR p.IsActive = 1)
          AND (@CategorySlug IS NULL OR c.Slug = @CategorySlug)
          AND (@SubcategorySlug IS NULL OR s.Slug = @SubcategorySlug)
          AND (@Search IS NULL OR p.Name LIKE '%' + @Search + '%'
               OR p.ShortDescription LIKE '%' + @Search + '%'
               OR p.CategoryLabel LIKE '%' + @Search + '%'
               OR c.Name LIKE '%' + @Search + '%'
               OR s.Name LIKE '%' + @Search + '%');

        SELECT p.ProductId, p.Name,
               c.Name AS CategoryName,
               s.Name AS SubcategoryName,
               p.DisplayOrder
        FROM #ExportProducts ep
        JOIN dbo.Products p ON p.ProductId = ep.ProductId
        LEFT JOIN dbo.Categories c ON c.CategoryId = p.CategoryId
        LEFT JOIN dbo.Subcategories s ON s.SubcategoryId = p.SubcategoryId
        ORDER BY p.DisplayOrder, p.Name;

        SELECT pf.ProductId, pf.FeatureText, pf.DisplayOrder
        FROM dbo.ProductFeatures pf
        JOIN #ExportProducts ep ON ep.ProductId = pf.ProductId
        JOIN dbo.Products p ON p.ProductId = pf.ProductId
        ORDER BY p.DisplayOrder, p.Name, pf.DisplayOrder, pf.FeatureId;

        SELECT ps.ProductId, ps.SpecName, ps.SpecValue, ps.DisplayOrder
        FROM dbo.ProductSpecs ps
        JOIN #ExportProducts ep ON ep.ProductId = ps.ProductId
        JOIN dbo.Products p ON p.ProductId = ps.ProductId
        ORDER BY p.DisplayOrder, p.Name, ps.DisplayOrder, ps.SpecId;

        SELECT pa.ProductId, pa.AppText, pa.DisplayOrder
        FROM dbo.ProductApplications pa
        JOIN #ExportProducts ep ON ep.ProductId = pa.ProductId
        JOIN dbo.Products p ON p.ProductId = pa.ProductId
        ORDER BY p.DisplayOrder, p.Name, pa.DisplayOrder, pa.AppId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT p.ProductId, p.CategoryId, p.SubcategoryId, p.Name, p.Slug, p.CategoryLabel, p.ShortDescription,
               p.Description, p.Badge, p.IsFeatured, p.IsActive, p.DisplayOrder,
               c.Name AS CategoryName, c.Slug AS CategorySlug,
               s.Name AS SubcategoryName, s.Slug AS SubcategorySlug
        FROM dbo.Products p
        LEFT JOIN dbo.Categories c ON c.CategoryId = p.CategoryId
        LEFT JOIN dbo.Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE p.ProductId = @ProductId;

        SELECT FeatureId, FeatureText, DisplayOrder FROM dbo.ProductFeatures
        WHERE ProductId = @ProductId ORDER BY DisplayOrder, FeatureId;

        SELECT SpecId, SpecName, SpecValue, DisplayOrder FROM dbo.ProductSpecs
        WHERE ProductId = @ProductId ORDER BY DisplayOrder, SpecId;

        SELECT AppId, AppText, DisplayOrder FROM dbo.ProductApplications
        WHERE ProductId = @ProductId ORDER BY DisplayOrder, AppId;

        SELECT ImageId, FilePath, FileName, AltText, IsPrimary, DisplayOrder FROM dbo.ProductImages
        WHERE ProductId = @ProductId ORDER BY IsPrimary DESC, DisplayOrder, ImageId;
    END
    ELSE IF @Action = 'GET_BY_SLUG'
    BEGIN
        DECLARE @SlugProductId INT = (SELECT ProductId FROM dbo.Products WHERE Slug = @Slug);
        IF @SlugProductId IS NOT NULL
        BEGIN
            EXEC dbo.usp_Product_Manage @Action = 'GET_BY_ID', @ProductId = @SlugProductId;
        END
    END
    ELSE IF @Action = 'GET_RELATED'
    BEGIN
        DECLARE @RelCategoryId INT = (SELECT CategoryId FROM dbo.Products WHERE ProductId = @ProductId);
        DECLARE @RelSubcategoryId INT = (SELECT SubcategoryId FROM dbo.Products WHERE ProductId = @ProductId);
        SELECT TOP (COALESCE(@Top, 3))
            p.ProductId, p.Name, p.Slug, p.CategoryLabel, p.Badge,
            c.Name AS CategoryName, s.Name AS SubcategoryName,
            (SELECT TOP 1 pi.FilePath FROM dbo.ProductImages pi
                WHERE pi.ProductId = p.ProductId ORDER BY pi.IsPrimary DESC, pi.DisplayOrder) AS PrimaryImage
        FROM dbo.Products p
        LEFT JOIN dbo.Categories c ON c.CategoryId = p.CategoryId
        LEFT JOIN dbo.Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE p.IsActive = 1 AND p.ProductId <> @ProductId
          AND ((@RelSubcategoryId IS NOT NULL AND p.SubcategoryId = @RelSubcategoryId)
               OR (@RelSubcategoryId IS NULL AND (@RelCategoryId IS NULL OR p.CategoryId = @RelCategoryId)))
        ORDER BY p.DisplayOrder, NEWID();
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Products (CategoryId, SubcategoryId, Name, Slug, CategoryLabel, ShortDescription, Description, Badge, IsFeatured, IsActive, DisplayOrder)
        VALUES (@EffectiveCategoryId, @EffectiveSubcategoryId, @Name, @Slug, @CategoryLabel, @ShortDescription, @Description, @Badge, COALESCE(@IsFeatured, 0), COALESCE(@IsActive, 1), @DisplayOrder);
        SELECT SCOPE_IDENTITY() AS ProductId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Products
        SET CategoryId = @EffectiveCategoryId, SubcategoryId = @EffectiveSubcategoryId,
            Name = @Name, Slug = @Slug, CategoryLabel = @CategoryLabel,
            ShortDescription = @ShortDescription, Description = @Description, Badge = @Badge,
            IsFeatured = COALESCE(@IsFeatured, IsFeatured), IsActive = COALESCE(@IsActive, IsActive), DisplayOrder = @DisplayOrder,
            UpdatedAt = SYSUTCDATETIME()
        WHERE ProductId = @ProductId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Products WHERE ProductId = @ProductId;
    END
    
    -- Child actions
    ELSE IF @Action = 'CREATE_FEATURE'
    BEGIN
        INSERT INTO dbo.ProductFeatures (ProductId, FeatureText, DisplayOrder)
        VALUES (@ProductId, @FeatureText, @DisplayOrder);
    END
    ELSE IF @Action = 'DELETE_FEATURES'
    BEGIN
        DELETE FROM dbo.ProductFeatures WHERE ProductId = @ProductId;
    END
    ELSE IF @Action = 'CREATE_SPEC'
    BEGIN
        INSERT INTO dbo.ProductSpecs (ProductId, SpecName, SpecValue, DisplayOrder)
        VALUES (@ProductId, @SpecName, @SpecValue, @DisplayOrder);
    END
    ELSE IF @Action = 'DELETE_SPECS'
    BEGIN
        DELETE FROM dbo.ProductSpecs WHERE ProductId = @ProductId;
    END
    ELSE IF @Action = 'CREATE_APP'
    BEGIN
        INSERT INTO dbo.ProductApplications (ProductId, AppText, DisplayOrder)
        VALUES (@ProductId, @AppText, @DisplayOrder);
    END
    ELSE IF @Action = 'DELETE_APPS'
    BEGIN
        DELETE FROM dbo.ProductApplications WHERE ProductId = @ProductId;
    END
    
    -- Image actions
    ELSE IF @Action = 'CREATE_IMAGE'
    BEGIN
        IF @IsPrimary = 1
            UPDATE dbo.ProductImages SET IsPrimary = 0 WHERE ProductId = @ProductId;
        INSERT INTO dbo.ProductImages (ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder)
        VALUES (@ProductId, @FilePath, @FileName, @AltText, @IsPrimary, @DisplayOrder);
        SELECT SCOPE_IDENTITY() AS ImageId;
    END
    ELSE IF @Action = 'GET_IMAGES'
    BEGIN
        SELECT ImageId, ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder
        FROM dbo.ProductImages WHERE ProductId = @ProductId
        ORDER BY IsPrimary DESC, DisplayOrder, ImageId;
    END
    ELSE IF @Action = 'GET_IMAGE_BY_ID'
    BEGIN
        SELECT ImageId, ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder
        FROM dbo.ProductImages WHERE ImageId = @ImageId;
    END
    ELSE IF @Action = 'DELETE_IMAGE'
    BEGIN
        DELETE FROM dbo.ProductImages WHERE ImageId = @ImageId;
    END
    ELSE IF @Action = 'SET_PRIMARY_IMAGE'
    BEGIN
        DECLARE @ImgProductId INT = (SELECT ProductId FROM dbo.ProductImages WHERE ImageId = @ImageId);
        UPDATE dbo.ProductImages SET IsPrimary = 0 WHERE ProductId = @ImgProductId;
        UPDATE dbo.ProductImages SET IsPrimary = 1 WHERE ImageId = @ImageId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Setting_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   SITE SETTINGS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Setting_Manage]
    @Action       VARCHAR(20), -- 'GET_ALL', 'GET_BY_KEY', 'UPSERT'
    @SettingKey   NVARCHAR(120) = NULL,
    @SettingValue NVARCHAR(MAX) = NULL,
    @SettingGroup NVARCHAR(60) = NULL,
    @Label        NVARCHAR(160) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT SettingId, SettingKey, SettingValue, SettingGroup, Label, UpdatedAt
        FROM dbo.SiteSettings ORDER BY SettingGroup, SettingKey;
    END
    ELSE IF @Action = 'GET_BY_KEY'
    BEGIN
        SELECT SettingId, SettingKey, SettingValue, SettingGroup, Label FROM dbo.SiteSettings WHERE SettingKey = @SettingKey;
    END
    ELSE IF @Action = 'UPSERT'
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.SiteSettings WHERE SettingKey = @SettingKey)
            UPDATE dbo.SiteSettings
            SET SettingValue = @SettingValue,
                SettingGroup = COALESCE(@SettingGroup, SettingGroup),
                Label = COALESCE(@Label, Label),
                UpdatedAt = SYSUTCDATETIME()
            WHERE SettingKey = @SettingKey;
        ELSE
            INSERT INTO dbo.SiteSettings (SettingKey, SettingValue, SettingGroup, Label, UpdatedAt)
            VALUES (@SettingKey, @SettingValue, @SettingGroup, @Label, SYSUTCDATETIME());
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Solution_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   SOLUTIONS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Solution_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE', 'CREATE_FEATURE', 'DELETE_FEATURES'
    @SolutionId      INT = NULL,
    @Title           NVARCHAR(200) = NULL,
    @Slug            NVARCHAR(220) = NULL,
    @Description     NVARCHAR(MAX) = NULL,
    @ImagePath       NVARCHAR(400) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 0,
    @FeatureText     NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT SolutionId, Title, Slug, Description, ImagePath, DisplayOrder, IsActive
        FROM dbo.Solutions
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, Title;

        SELECT FeatureId, SolutionId, FeatureText, DisplayOrder
        FROM dbo.SolutionFeatures
        ORDER BY SolutionId, DisplayOrder, FeatureId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT SolutionId, Title, Slug, Description, ImagePath, DisplayOrder, IsActive
        FROM dbo.Solutions WHERE SolutionId = @SolutionId;

        SELECT FeatureId, FeatureText, DisplayOrder FROM dbo.SolutionFeatures
        WHERE SolutionId = @SolutionId ORDER BY DisplayOrder, FeatureId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Solutions (Title, Slug, Description, ImagePath, DisplayOrder, IsActive)
        VALUES (@Title, @Slug, @Description, @ImagePath, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS SolutionId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Solutions
        SET Title = @Title, Slug = @Slug, Description = @Description,
            ImagePath = COALESCE(@ImagePath, ImagePath),
            DisplayOrder = @DisplayOrder, IsActive = @IsActive, UpdatedAt = SYSUTCDATETIME()
        WHERE SolutionId = @SolutionId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Solutions WHERE SolutionId = @SolutionId;
    END
    ELSE IF @Action = 'CREATE_FEATURE'
    BEGIN
        INSERT INTO dbo.SolutionFeatures (SolutionId, FeatureText, DisplayOrder)
        VALUES (@SolutionId, @FeatureText, @DisplayOrder);
    END
    ELSE IF @Action = 'DELETE_FEATURES'
    BEGIN
        DELETE FROM dbo.SolutionFeatures WHERE SolutionId = @SolutionId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Stat_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   STATS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Stat_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @StatId          INT = NULL,
    @Label           NVARCHAR(120) = NULL,
    @Value           INT = 0,
    @Suffix          NVARCHAR(10) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT StatId, Label, Value, Suffix, DisplayOrder, IsActive
        FROM dbo.Stats
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, StatId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT StatId, Label, Value, Suffix, DisplayOrder, IsActive FROM dbo.Stats WHERE StatId = @StatId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Stats (Label, Value, Suffix, DisplayOrder, IsActive)
        VALUES (@Label, @Value, @Suffix, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS StatId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Stats
        SET Label = @Label, Value = @Value, Suffix = @Suffix, DisplayOrder = @DisplayOrder, IsActive = @IsActive
        WHERE StatId = @StatId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Stats WHERE StatId = @StatId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Subcategory_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   SUBCATEGORIES
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Subcategory_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @SubcategoryId   INT = NULL,
    @CategoryId      INT = NULL,
    @CategorySlug    NVARCHAR(140) = NULL,
    @Name            NVARCHAR(120) = NULL,
    @Slug            NVARCHAR(140) = NULL,
    @Description     NVARCHAR(500) = NULL,
    @ImagePath       NVARCHAR(400) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT s.SubcategoryId, s.CategoryId, s.Name, s.Slug, s.Description,
               COALESCE(s.ImagePath, (
                   SELECT TOP 1 pi.FilePath
                   FROM dbo.Products p
                   JOIN dbo.ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.SubcategoryId = s.SubcategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
               )) AS ImagePath,
               s.DisplayOrder, s.IsActive,
               c.Name AS CategoryName, c.Slug AS CategorySlug,
               (SELECT COUNT(*) FROM dbo.Products p WHERE p.SubcategoryId = s.SubcategoryId) AS ProductCount
        FROM dbo.Subcategories s
        JOIN dbo.Categories c ON c.CategoryId = s.CategoryId
        WHERE (@IncludeInactive = 1 OR (s.IsActive = 1 AND c.IsActive = 1))
          AND (@CategoryId IS NULL OR s.CategoryId = @CategoryId)
          AND (@CategorySlug IS NULL OR c.Slug = @CategorySlug)
        ORDER BY c.DisplayOrder, c.Name, s.DisplayOrder, s.Name;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT s.SubcategoryId, s.CategoryId, s.Name, s.Slug, s.Description,
               s.ImagePath, s.DisplayOrder, s.IsActive,
               c.Name AS CategoryName, c.Slug AS CategorySlug
        FROM dbo.Subcategories s
        JOIN dbo.Categories c ON c.CategoryId = s.CategoryId
        WHERE s.SubcategoryId = @SubcategoryId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Subcategories (CategoryId, Name, Slug, Description, ImagePath, DisplayOrder, IsActive)
        VALUES (@CategoryId, @Name, @Slug, @Description, @ImagePath, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS SubcategoryId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Subcategories
        SET CategoryId = @CategoryId, Name = @Name, Slug = @Slug, Description = @Description,
            ImagePath = COALESCE(@ImagePath, ImagePath), DisplayOrder = @DisplayOrder,
            IsActive = @IsActive, UpdatedAt = SYSUTCDATETIME()
        WHERE SubcategoryId = @SubcategoryId;

        UPDATE dbo.Products
        SET CategoryId = @CategoryId, UpdatedAt = SYSUTCDATETIME()
        WHERE SubcategoryId = @SubcategoryId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Products WHERE SubcategoryId = @SubcategoryId)
            THROW 50001, 'Move or delete the products in this subcategory before deleting it.', 1;

        DELETE FROM dbo.Subcategories WHERE SubcategoryId = @SubcategoryId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Team_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   TEAM MEMBERS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Team_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @MemberId        INT = NULL,
    @Name            NVARCHAR(120) = NULL,
    @Role            NVARCHAR(120) = NULL,
    @Initials        NVARCHAR(8) = NULL,
    @ImagePath       NVARCHAR(400) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT MemberId, Name, Role, Initials, ImagePath, DisplayOrder, IsActive
        FROM dbo.TeamMembers
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, MemberId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT MemberId, Name, Role, Initials, ImagePath, DisplayOrder, IsActive
        FROM dbo.TeamMembers WHERE MemberId = @MemberId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.TeamMembers (Name, Role, Initials, ImagePath, DisplayOrder, IsActive)
        VALUES (@Name, @Role, @Initials, @ImagePath, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS MemberId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.TeamMembers
        SET Name = @Name, Role = @Role, Initials = @Initials,
            ImagePath = COALESCE(@ImagePath, ImagePath), DisplayOrder = @DisplayOrder, IsActive = @IsActive
        WHERE MemberId = @MemberId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.TeamMembers WHERE MemberId = @MemberId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Testimonial_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   TESTIMONIALS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Testimonial_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @TestimonialId   INT = NULL,
    @AuthorName      NVARCHAR(120) = NULL,
    @AuthorRole      NVARCHAR(120) = NULL,
    @Initials        NVARCHAR(8) = NULL,
    @Rating          INT = 5,
    @Content         NVARCHAR(MAX) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT TestimonialId, AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive, CreatedAt
        FROM dbo.Testimonials
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, TestimonialId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT TestimonialId, AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive, CreatedAt
        FROM dbo.Testimonials WHERE TestimonialId = @TestimonialId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Testimonials (AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive)
        VALUES (@AuthorName, @AuthorRole, @Initials, @Rating, @Content, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS TestimonialId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.Testimonials
        SET AuthorName = @AuthorName, AuthorRole = @AuthorRole, Initials = @Initials,
            Rating = @Rating, Content = @Content, DisplayOrder = @DisplayOrder, IsActive = @IsActive
        WHERE TestimonialId = @TestimonialId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.Testimonials WHERE TestimonialId = @TestimonialId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_User_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   USERS
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_User_Manage]
    @Action       VARCHAR(30), -- 'GET_BY_LOGIN', 'GET_BY_ID', 'CREATE', 'COUNT', 'UPDATE_LAST_LOGIN', 'UPDATE_PASSWORD'
    @UserId       INT = NULL,
    @Login        NVARCHAR(160) = NULL,
    @Username     NVARCHAR(60) = NULL,
    @Email        NVARCHAR(160) = NULL,
    @PasswordHash NVARCHAR(255) = NULL,
    @FullName     NVARCHAR(120) = NULL,
    @Role         NVARCHAR(30) = 'admin'
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_BY_LOGIN'
    BEGIN
        SELECT TOP 1 UserId, Username, Email, PasswordHash, FullName, Role, IsActive, LastLoginAt, CreatedAt
        FROM dbo.Users
        WHERE (Username = @Login OR Email = @Login);
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT UserId, Username, Email, PasswordHash, FullName, Role, IsActive, LastLoginAt, CreatedAt
        FROM dbo.Users WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role)
        VALUES (@Username, @Email, @PasswordHash, @FullName, @Role);
        SELECT SCOPE_IDENTITY() AS UserId;
    END
    ELSE IF @Action = 'COUNT'
    BEGIN
        SELECT COUNT(*) AS Cnt FROM dbo.Users;
    END
    ELSE IF @Action = 'UPDATE_LAST_LOGIN'
    BEGIN
        UPDATE dbo.Users SET LastLoginAt = SYSUTCDATETIME() WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'UPDATE_PASSWORD'
    BEGIN
        UPDATE dbo.Users SET PasswordHash = @PasswordHash WHERE UserId = @UserId;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_Value_Manage]    Script Date: 26-Aug-26 10:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================
   CORE VALUES
   ============================================================ */
CREATE   PROCEDURE [dbo].[usp_Value_Manage]
    @Action          VARCHAR(20), -- 'GET_ALL', 'GET_BY_ID', 'CREATE', 'UPDATE', 'DELETE'
    @ValueId         INT = NULL,
    @Icon            NVARCHAR(20) = NULL,
    @Title           NVARCHAR(120) = NULL,
    @Body            NVARCHAR(500) = NULL,
    @DisplayOrder    INT = 0,
    @IsActive        BIT = 1,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'GET_ALL'
    BEGIN
        SELECT ValueId, Icon, Title, Body, DisplayOrder, IsActive
        FROM dbo.CoreValues
        WHERE (@IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, ValueId;
    END
    ELSE IF @Action = 'GET_BY_ID'
    BEGIN
        SELECT ValueId, Icon, Title, Body, DisplayOrder, IsActive FROM dbo.CoreValues WHERE ValueId = @ValueId;
    END
    ELSE IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.CoreValues (Icon, Title, Body, DisplayOrder, IsActive)
        VALUES (@Icon, @Title, @Body, @DisplayOrder, @IsActive);
        SELECT SCOPE_IDENTITY() AS ValueId;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.CoreValues
        SET Icon = @Icon, Title = @Title, Body = @Body, DisplayOrder = @DisplayOrder, IsActive = @IsActive
        WHERE ValueId = @ValueId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.CoreValues WHERE ValueId = @ValueId;
    END
END
GO
USE [master]
GO
ALTER DATABASE [InhymaDB] SET  READ_WRITE 
GO
