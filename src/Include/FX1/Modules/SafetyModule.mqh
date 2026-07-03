#ifndef FX1_SAFETY_MODULE_MQH
#define FX1_SAFETY_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CSafetyModule : public ISafetyGate
{
private:
   int m_max_spread_points;

public:
   CSafetyModule() : m_max_spread_points(25) {}

   void SetMaxSpreadPoints(const int max_spread_points)
   {
      m_max_spread_points = max_spread_points;
   }

   bool AllowTrading(const SAppContext &ctx, const SMarketSnapshot &snapshot, string &reason) override
   {
      if(!ctx.settings.trading_enabled)
      {
         reason = "trading disabled";
         return false;
      }

      if(snapshot.spread_points > (double)m_max_spread_points)
      {
         reason = "spread too high";
         return false;
      }

      reason = "ok";
      return true;
   }
};

#endif
