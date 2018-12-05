﻿using Gdc.Scd.BusinessLogicLayer.Helpers;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;
using System.DirectoryServices.ActiveDirectory;
using System.Linq;
using System.Security.Principal;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class ActiveDirectoryService : IActiveDirectoryService
    {
        private readonly WindowsIdentity currentIdentity;
        public ActiveDirectoryConfig Configuration { get; set; }
        public ActiveDirectoryService()
        {
            currentIdentity = WindowsIdentity.GetCurrent();
        }
        public bool CheckCredentials(string userName, string password, string domainName)
        {
            var nameToCheck = userName.Split('\\').Last();
            try
            {
                using (var context = new PrincipalContext(ContextType.Domain, domainName, userName, password))
                {
                    var result = context.ValidateCredentials(nameToCheck, password);
                    return result;
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public DirectoryEntry GetUserByEmail(string email, string userName, string password, string domainName)
        {
            using (var context = new PrincipalContext(ContextType.Domain, domainName, userName, password))
            {
                using (var user = new UserPrincipal(context))
                {
                    user.EmailAddress = string.Format("*{0}*", email);
                    var searcher = new PrincipalSearcher
                    {
                        QueryFilter = user,
                    };
                    try
                    {
                        var result = searcher.FindOne();
                        if (result == null)
                            return null;
                        DirectoryEntry de = result.GetUnderlyingObject() as DirectoryEntry;
                        return de;
                    }
                    catch (Exception)
                    {
                        return null;
                    }
                }
            }
        }

        public DirectoryEntry GetUserFromForestByUsername(string userName, string password, string domainName)
        {
            if (string.IsNullOrEmpty(Configuration.ForestName) || string.IsNullOrEmpty(userName) ||
                string.IsNullOrEmpty(password))
                return null;
            var domainContext = new DirectoryContext(DirectoryContextType.Forest, Configuration.ForestName, userName, password);
            var currentForest = Forest.GetForest(domainContext);
            var gc = currentForest.FindGlobalCatalog();

            using (var userSearcher = gc.GetDirectorySearcher())
            {
                userSearcher.Filter = "(&((&(objectCategory=Person)(objectClass=User)))(|(samaccountname=" + userName + ")(mail=" + userName + ")))";
                var result = userSearcher.FindOne();
                if (result == null)
                    return null;
                return result.GetDirectoryEntry();
            }
        }

        public List<UserPrincipal> SearchForUserByString(string search, int count = 5)
        {
            var searchResults = new List<DirectoryEntry>();
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                using (var user = new UserPrincipal(context))
                {
                    var searchPrinciples = new List<UserPrincipal>();
                    searchPrinciples.Add(new UserPrincipal(context) { Surname = string.Format("{0}*", search) });
                    searchPrinciples.Add(new UserPrincipal(context) { GivenName = string.Format("{0}*", search) });                 

                    var results = new List<UserPrincipal>();
                    
                    try
                    {
                        var searcher = new PrincipalSearcher();
                        foreach (var item in searchPrinciples)
                        {
                            searcher = new PrincipalSearcher(item);
                            results.AddRange(searcher.FindAll().Cast<UserPrincipal>());
                        }
                        if (results.Count() == 0)
                            return new List<UserPrincipal>();
                        return results.GroupBy(u => u.Sid).Select(group => group.First()).Take(count).ToList();
                    }
                    catch (Exception)
                    {
                        return null;
                    }
                }
            }
        }
        public UserPrincipal FindByIdentity(string userIdentity)
        {
            using (var context = new PrincipalContext(ContextType.Domain))
            {
                try
                {
                    UserPrincipal user = UserPrincipal.FindByIdentity(context, userIdentity);
                    return user;
                }
                catch (Exception)
                {
                    return null;
                }
            }
        }
    }
}