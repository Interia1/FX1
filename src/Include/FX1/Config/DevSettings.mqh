#ifndef FX1_DEV_SETTINGS_MQH
#define FX1_DEV_SETTINGS_MQH

enum EConditionId
{
   CONDITION_NONE = 0,
   CONDITION_P1 = 1
};

struct SDevSettings
{
   bool condition_test_mode;
   int single_condition_id;

   bool p1_enabled;
   int p1_max_spread_points;
   bool p1_emit_signal;
   bool p1_buy_signal;
};

SDevSettings DefaultDevSettings()
{
   SDevSettings s;
   s.condition_test_mode = false;
   s.single_condition_id = 0;

   s.p1_enabled = true;
   s.p1_max_spread_points = 25;
   s.p1_emit_signal = false;
   s.p1_buy_signal = true;
   return s;
}

bool ValidateDevSettings(const SDevSettings &s, string &err)
{
   if(s.single_condition_id < 0)
   {
      err = "single_condition_id must be >= 0";
      return false;
   }

   if(s.condition_test_mode && s.single_condition_id <= 0)
   {
      err = "single_condition_id must be > 0 when condition_test_mode is enabled";
      return false;
   }

   if(s.condition_test_mode && s.single_condition_id != CONDITION_P1)
   {
      err = "single_condition_id is not implemented yet";
      return false;
   }

   if(s.p1_max_spread_points <= 0)
   {
      err = "p1_max_spread_points must be positive";
      return false;
   }

   err = "";
   return true;
}

#endif