﻿using Gdc.Scd.BusinessLogicLayer.Interfaces;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class MemoryChannel : INotifyChannel
    {
        static ConcurrentDictionary<string, List<object>> channels =
            new ConcurrentDictionary<string, List<object>>(StringComparer.OrdinalIgnoreCase);

        public static readonly MemoryChannel Instance = new MemoryChannel();

        private MemoryChannel() { }

        public void Create(string username)
        {
            channels.TryAdd(username, new List<object>());
        }

        public void Send(object value)
        {
            foreach (var c in channels)
            {
                c.Value.Add(value);
            }
        }

        public void Send(string userName, object value)
        {
            List<object> list;
            if (channels.TryGetValue(userName, out list))
            {
                list.Add(value);
            }
        }

        public object GetMessage(string userName)
        {
            object result = null;

            List<object> list;
            if (channels.TryGetValue(userName, out list))
            {
                result = list.FirstOrDefault();
            }

            return result;
        }

        public void RemoveMessage(string userName, object msg)
        {
            List<object> list;
            if (channels.TryGetValue(userName, out list))
            {
                list.Remove(msg);
            }
        }
    }
}