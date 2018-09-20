﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.DirectoryServices;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Mvc;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Web.Api.Entities;
using Gdc.Scd.Web.Server.Entities;

namespace Gdc.Scd.Web.Api.Controllers
{
    public class UsersController : ApiController
    {
        private readonly IActiveDirectoryService activeDirectoryService;
        public UsersController(IActiveDirectoryService activeDirectoryService)
        {
            this.activeDirectoryService = activeDirectoryService;
        }
        [System.Web.Http.HttpGet]
        public void SelectUser([System.Web.Http.FromBody]DirectoryEntry user)
        {
            //TODO: need to add behavior
        }
        [System.Web.Http.HttpGet]
        public DataInfo<UserInfo> SearchUser(string _dc, string searchString, int page = 1, int start = 0, int limit = 25)
        {
            if (string.IsNullOrEmpty(searchString))
                return new DataInfo<UserInfo> { Items = new List<UserInfo>(), Total = 0 };
            activeDirectoryService.Configuration = new Scd.BusinessLogicLayer.Helpers.ActiveDirectoryConfig
            {
                ForestName = ConfigurationManager.AppSettings["AdForestName"],
                DefaultDomain = ConfigurationManager.AppSettings["DefaultDomain"],
                AdServiceAccount = ConfigurationManager.AppSettings["AdServiceAccount"],
                AdServicePassword = ConfigurationManager.AppSettings["AdServicePassword"],
            };
            var foundUsers = activeDirectoryService.SearchForUserByString(searchString, 5).Select(
                user => new UserInfo
                {
                    Username = user.DisplayName,
                    UserSamAccount = user.SamAccountName,
                }).ToList();

            return new DataInfo<UserInfo> { Items = foundUsers, Total = foundUsers.Count() };
        }
    }
}
