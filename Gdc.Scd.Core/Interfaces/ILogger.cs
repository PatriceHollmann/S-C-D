﻿using System;

namespace Gdc.Scd.Core.Interfaces
{
    public interface ILogger<T>
    {
        void Log(T level, string message, params object[] args);

        void Log(T level, Exception exception, string message, params object[] args);
    }
}
