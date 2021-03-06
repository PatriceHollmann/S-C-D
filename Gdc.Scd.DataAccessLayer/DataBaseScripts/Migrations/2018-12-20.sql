/****** Object:  Table [Portfolio].[LocalPortfolio]    Script Date: 20.12.2018 11:37:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE SCHEMA Portfolio;
GO 

CREATE TABLE [Portfolio].[LocalPortfolio](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[AvailabilityId] [bigint] NOT NULL,
	[CountryId] [bigint] NOT NULL,
	[DurationId] [bigint] NOT NULL,
	[ProActiveSlaId] [bigint] NOT NULL,
	[ReactionTimeId] [bigint] NOT NULL,
	[ReactionTypeId] [bigint] NOT NULL,
	[ServiceLocationId] [bigint] NOT NULL,
	[WgId] [bigint] NOT NULL,
 CONSTRAINT [PK_LocalPortfolio] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Portfolio].[PrincipalPortfolio]    Script Date: 20.12.2018 11:37:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Portfolio].[PrincipalPortfolio](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[AvailabilityId] [bigint] NOT NULL,
	[DurationId] [bigint] NOT NULL,
	[ProActiveSlaId] [bigint] NOT NULL,
	[ReactionTimeId] [bigint] NOT NULL,
	[ReactionTypeId] [bigint] NOT NULL,
	[ServiceLocationId] [bigint] NOT NULL,
	[WgId] [bigint] NOT NULL,
	[IsCorePortfolio] [bit] NOT NULL,
	[IsGlobalPortfolio] [bit] NOT NULL,
	[IsMasterPortfolio] [bit] NOT NULL,
 CONSTRAINT [PK_PrincipalPortfolio] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_LocalPortfolio_AvailabilityId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_AvailabilityId] ON [Portfolio].[LocalPortfolio]
(
	[AvailabilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_CountryId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_CountryId] ON [Portfolio].[LocalPortfolio]
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_DurationId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_DurationId] ON [Portfolio].[LocalPortfolio]
(
	[DurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_ProActiveSlaId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_ProActiveSlaId] ON [Portfolio].[LocalPortfolio]
(
	[ProActiveSlaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_ReactionTimeId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_ReactionTimeId] ON [Portfolio].[LocalPortfolio]
(
	[ReactionTimeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_ReactionTypeId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_ReactionTypeId] ON [Portfolio].[LocalPortfolio]
(
	[ReactionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_ServiceLocationId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_ServiceLocationId] ON [Portfolio].[LocalPortfolio]
(
	[ServiceLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocalPortfolio_WgId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_LocalPortfolio_WgId] ON [Portfolio].[LocalPortfolio]
(
	[WgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_AvailabilityId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_AvailabilityId] ON [Portfolio].[PrincipalPortfolio]
(
	[AvailabilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_DurationId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_DurationId] ON [Portfolio].[PrincipalPortfolio]
(
	[DurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_ProActiveSlaId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_ProActiveSlaId] ON [Portfolio].[PrincipalPortfolio]
(
	[ProActiveSlaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_ReactionTimeId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_ReactionTimeId] ON [Portfolio].[PrincipalPortfolio]
(
	[ReactionTimeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_ReactionTypeId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_ReactionTypeId] ON [Portfolio].[PrincipalPortfolio]
(
	[ReactionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_ServiceLocationId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_ServiceLocationId] ON [Portfolio].[PrincipalPortfolio]
(
	[ServiceLocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrincipalPortfolio_WgId]    Script Date: 20.12.2018 11:37:34 ******/
CREATE NONCLUSTERED INDEX [IX_PrincipalPortfolio_WgId] ON [Portfolio].[PrincipalPortfolio]
(
	[WgId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] ADD  DEFAULT ((0)) FOR [IsCorePortfolio]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] ADD  DEFAULT ((1)) FOR [IsGlobalPortfolio]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] ADD  DEFAULT ((0)) FOR [IsMasterPortfolio]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_Availability_AvailabilityId] FOREIGN KEY([AvailabilityId])
REFERENCES [Dependencies].[Availability] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_Availability_AvailabilityId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_Country_CountryId] FOREIGN KEY([CountryId])
REFERENCES [InputAtoms].[Country] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_Country_CountryId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_Duration_DurationId] FOREIGN KEY([DurationId])
REFERENCES [Dependencies].[Duration] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_Duration_DurationId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_ProActiveSla_ProActiveSlaId] FOREIGN KEY([ProActiveSlaId])
REFERENCES [Dependencies].[ProActiveSla] ([Id])
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_ProActiveSla_ProActiveSlaId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_ReactionTime_ReactionTimeId] FOREIGN KEY([ReactionTimeId])
REFERENCES [Dependencies].[ReactionTime] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_ReactionTime_ReactionTimeId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_ReactionType_ReactionTypeId] FOREIGN KEY([ReactionTypeId])
REFERENCES [Dependencies].[ReactionType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_ReactionType_ReactionTypeId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_ServiceLocation_ServiceLocationId] FOREIGN KEY([ServiceLocationId])
REFERENCES [Dependencies].[ServiceLocation] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_ServiceLocation_ServiceLocationId]
GO
ALTER TABLE [Portfolio].[LocalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalPortfolio_Wg_WgId] FOREIGN KEY([WgId])
REFERENCES [InputAtoms].[Wg] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[LocalPortfolio] CHECK CONSTRAINT [FK_LocalPortfolio_Wg_WgId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_Availability_AvailabilityId] FOREIGN KEY([AvailabilityId])
REFERENCES [Dependencies].[Availability] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_Availability_AvailabilityId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_Duration_DurationId] FOREIGN KEY([DurationId])
REFERENCES [Dependencies].[Duration] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_Duration_DurationId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_ProActiveSla_ProActiveSlaId] FOREIGN KEY([ProActiveSlaId])
REFERENCES [Dependencies].[ProActiveSla] ([Id])
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_ProActiveSla_ProActiveSlaId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_ReactionTime_ReactionTimeId] FOREIGN KEY([ReactionTimeId])
REFERENCES [Dependencies].[ReactionTime] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_ReactionTime_ReactionTimeId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_ReactionType_ReactionTypeId] FOREIGN KEY([ReactionTypeId])
REFERENCES [Dependencies].[ReactionType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_ReactionType_ReactionTypeId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_ServiceLocation_ServiceLocationId] FOREIGN KEY([ServiceLocationId])
REFERENCES [Dependencies].[ServiceLocation] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_ServiceLocation_ServiceLocationId]
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio]  WITH NOCHECK ADD  CONSTRAINT [FK_PrincipalPortfolio_Wg_WgId] FOREIGN KEY([WgId])
REFERENCES [InputAtoms].[Wg] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Portfolio].[PrincipalPortfolio] CHECK CONSTRAINT [FK_PrincipalPortfolio_Wg_WgId]
GO
