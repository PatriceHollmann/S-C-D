﻿using Gdc.Scd.Core.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace Gdc.Scd.Web.Server
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        private static bool _firstRequest = true;

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        protected void Application_EndRequest()
        {
            if (_firstRequest)
            {
                var handlers = DependencyResolver.Current.GetServices<IConfigureApplicationHandler>();
                foreach (var handler in handlers)
                {
                    handler.Handle();
                }
                _firstRequest = false;
            }
        }

//TODO: Fake behavior
#if DEBUG
        protected void Application_PostAuthenticateRequest()
        {
            this.Context.User = new FakePrincipal
            {
                Identity = new FakeIIdentity
                {
                    Name = "g02\\testUser1",
                    IsAuthenticated = true
                }
            };
        }            

        private class FakeIIdentity : System.Security.Principal.IIdentity
        {
            public string Name { get; set; }

            public string AuthenticationType { get; set; }

            public bool IsAuthenticated { get; set; }
        }

        private class FakePrincipal : System.Security.Principal.IPrincipal
        {
            public System.Security.Principal.IIdentity Identity { get; set; }

            public bool IsInRole(string role)
            {
                throw new System.NotImplementedException();
            }
        }
#endif
    }
}
