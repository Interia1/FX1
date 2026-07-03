#ifndef FX1_SETTINGS_MQH
#define FX1_SETTINGS_MQH

struct SEaSettings
{
   long magic;
   double risk_percent;
   double fixed_lot;
   bool use_fixed_lot;
   int max_spread_points;
   int slippage_points;
   int stop_loss_points;
   int take_profit_points;
   bool trading_enabled;
};

SEaSettings DefaultSettings()
{
   SEaSettings s;
   s.magic = 51001;
   s.risk_percent = 1.0;
   s.fixed_lot = 0.10;
   s.use_fixed_lot = true;
   s.max_spread_points = 25;
   s.slippage_points = 20;
   s.stop_loss_points = 200;
   s.take_profit_points = 300;
   s.trading_enabled = true;
   return s;
}

bool ValidateSettings(const SEaSettings &s, string &err)
{
   if(s.magic <= 0)
   {
      err = "magic must be positive";
      return false;
   }
   if(s.risk_percent <= 0.0 || s.risk_percent > 10.0)
   {
      err = "risk_percent out of range (0, 10]";
      return false;
   }
   if(s.fixed_lot <= 0.0)
   {
      err = "fixed_lot must be positive";
      return false;
   }
   if(s.max_spread_points <= 0)
   {
      err = "max_spread_points must be positive";
      return false;
   }
   if(s.slippage_points < 0)
   {
      err = "slippage_points must be >= 0";
      return false;
   }
   if(s.stop_loss_points <= 0 || s.take_profit_points <= 0)
   {
      err = "stop_loss_points and take_profit_points must be positive";
      return false;
   }
   err = "";
   return true;
}

#endif
