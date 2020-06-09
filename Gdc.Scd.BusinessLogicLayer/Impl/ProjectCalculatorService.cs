﻿using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.ProjectCalculator;
using Gdc.Scd.Core.Enums;
using Gdc.Scd.DataAccessLayer.Interfaces;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class ProjectCalculatorService : DomainService<Project>, IProjectCalculatorService
    {
        private const int MinutesInHour = 60;
        private const int MinutesInDay = MinutesInHour * 24;
        private const int MinutesInWeek = MinutesInDay * 7;
        private const int MinutesInMonth = MinutesInDay * 30;
        private const int MinutesInYear = MinutesInMonth * 12;

        private static readonly PeriodNameBuilder periodNameBuilder = new PeriodNameBuilder();
        private static readonly PeriodService periodService = new PeriodService();

        private readonly IDomainService<Wg> wgService;
        private readonly IDomainService<Country> countryService;
        private readonly IDomainService<ReactionType> reactionTypeService;
        private readonly IDomainService<ServiceLocation> serviceLocationService;

        public ProjectCalculatorService(
            IRepositorySet repositorySet, 
            IDomainService<Wg> wgService,
            IDomainService<Country> countryService,
            IDomainService<ReactionType> reactionTypeService,
            IDomainService<ServiceLocation> serviceLocationService) 
            : base(repositorySet)
        {
            this.wgService = wgService;
            this.countryService = countryService;
            this.reactionTypeService = reactionTypeService;
            this.serviceLocationService = serviceLocationService;
        }

        public ProjectCalculatorData GetProjectCalculatorData()
        {
            return new ProjectCalculatorData
            {
                Wgs = this.wgService.GetAll().Where(wg => wg.WgType == WgType.Por).ToArray(),
                Countries = this.countryService.GetAll().Where(country => country.IsMaster).ToArray(),
                ReactionTypes = this.reactionTypeService.GetAll().ToArray(),
                ServiceLocations = this.serviceLocationService.GetAll().ToArray(),
                ReactionTimePeriods = periodService.GetPeriods(PeriodType.Minutes, PeriodType.Hours),
                DurationPeriods = periodService.GetPeriods(PeriodType.Months, PeriodType.Years)
            };
        }

        public void SaveWithInterpolation(Project[] projects)
        {
            foreach (var project in projects)
            {
                project.IsCalculated = true;
            }

            this.Save(projects);

            this.repositorySet.ExecuteProc("[ProjectCalculator].[InterpolateProjects]");
        }

        protected override void InnerSave(Project item)
        {
            item.Availability.Name = item.Availability.ToString();
            item.Duration.Name = periodNameBuilder.GetPeriodName(item.Duration.Months * MinutesInMonth, item.Duration.PeriodType);
            item.ReactionTime.Name = periodNameBuilder.GetPeriodName(item.ReactionTime.Minutes, item.ReactionTime.PeriodType);

            base.InnerSave(item);
        }

        private class PeriodInfo
        {
            public int Devider { get; }

            public string Caption { get; }

            public PeriodInfo(int devider, string caption)
            {
                this.Devider = devider;
                this.Caption = caption;
            }
        }

        private class PeriodNameBuilder
        {
            private readonly Dictionary<PeriodType, PeriodInfo> periodInfos = new Dictionary<PeriodType, PeriodInfo>
            {
                [PeriodType.Minutes] = new PeriodInfo(1, "mins"),
                [PeriodType.Days] = new PeriodInfo(MinutesInDay, "days"),
                [PeriodType.Weeks] = new PeriodInfo(MinutesInWeek, "weeks"),
                [PeriodType.Months] = new PeriodInfo(MinutesInMonth, "months"),
                [PeriodType.Years] = new PeriodInfo(MinutesInYear, "years"),
            };

            public string GetPeriodName(int minutes, PeriodType periodType)
            {
                var periodInfo = this.periodInfos[periodType];

                return $"{minutes / periodInfo.Devider} {periodInfo.Caption}";
            }

            public string GetPeriodName(int? minutes, PeriodType? periodType)
            {
                return minutes.HasValue
                    ? this.GetPeriodName(minutes.Value, periodType.Value)
                    : "none";
            }
        }

        private class PeriodService
        {
            private readonly Dictionary<PeriodType, NamedId> periods = new Dictionary<PeriodType, NamedId>();

            public PeriodService()
            {
                this.AddPeriod(PeriodType.Minutes, "min");
                this.AddPeriod(PeriodType.Hours, "h");
                this.AddPeriod(PeriodType.Months, "m");
                this.AddPeriod(PeriodType.Years, "y");
            }

            public NamedId[] GetPeriods(params PeriodType[] periodTypes)
            {
                return periodTypes.Select(periodType => this.periods[periodType]).ToArray();
            }

            private void AddPeriod(PeriodType periodType, string name)
            {
                var period = new NamedId
                {
                    Id = (long)periodType,
                    Name = name
                };

                this.periods.Add(periodType, period);
            }
        }
    }
}
