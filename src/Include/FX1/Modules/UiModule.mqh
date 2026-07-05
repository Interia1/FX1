#ifndef FX1_UI_MODULE_MQH
#define FX1_UI_MODULE_MQH

#include <FX1/Core/Contracts.mqh>

class CUiModule : public IUiModule
{
public:
   bool OnInitUi(const SAppContext &ctx) override
   {
      if(ctx.symbol == "")
         return true;
      return true;
   }

   void OnDeinitUi() override
   {
   }
};

#endif
