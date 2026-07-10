#ifndef FX1_APP_CONTEXT_MQH
#define FX1_APP_CONTEXT_MQH

#include <FX1/Config/Settings.mqh>
#include <FX1/Config/DevSettings.mqh>

struct SAppContext
{
   string symbol;
   ENUM_TIMEFRAMES timeframe;
   SEaSettings settings;
   SDevSettings dev;
};

#endif
