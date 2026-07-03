#ifndef FX1_POSITION_MODULE_MQH
#define FX1_POSITION_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CPositionModule : public IPositionManager
{
public:
   void ManageOpenPositions(const SAppContext &ctx, const SMarketSnapshot &snapshot) override
   {
      // Reserved for trailing stop, break-even, partial exits, and time-stop rules.
      // Kept intentionally simple in the architecture scaffold.
      (void)ctx;
      (void)snapshot;
   }
};

#endif
