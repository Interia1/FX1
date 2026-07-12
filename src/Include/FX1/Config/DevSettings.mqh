#ifndef FX1_DEV_SETTINGS_MQH
#define FX1_DEV_SETTINGS_MQH

enum EConditionId
{
   CONDITION_NONE = 0,
   CONDITION_P1 = 1,
   CONDITION_P2 = 2,
   CONDITION_P3 = 3
};

bool IsValidConditionId(const EConditionId id)
{
   return (id == CONDITION_NONE ||
           id == CONDITION_P1 ||
           id == CONDITION_P2 ||
           id == CONDITION_P3);
}

enum EAngleCompare
{
   UHOL_VACSIE = 0,
   UHOL_VACSIE_ALBO_ROVNE = 1,
   UHOL_MENSIE = 2,
   UHOL_MENSIE_ALBO_ROVNE = 3
};

enum EP1SmerSignalu
{
   P1_SIGNAL_BUY = 0,
   P1_SIGNAL_SELL = 1,
   P1_SIGNAL_BUY_AJ_SELL = 2
};

struct SDevSettings
{
   bool condition_test_mode;
   EConditionId single_condition_id;

   bool p1_enabled;
   int p1_max_spread_points;
   bool p1_je_len_filter;
   EP1SmerSignalu p1_signal_mode;

   ENUM_TIMEFRAMES p1_stoch_timeframe;
   int p1_stoch_k_period;
   int p1_stoch_d_period;
   int p1_stoch_slowing;
   ENUM_MA_METHOD p1_stoch_ma_method;
   ENUM_STO_PRICE p1_stoch_price_field;
   double p1_angle_scale;

   EAngleCompare p1_main_cmp_1;
   double p1_main_deg_1;
   EAngleCompare p1_main_cmp_2;
   double p1_main_deg_2;
   EAngleCompare p1_main_cmp_3;
   double p1_main_deg_3;
   EAngleCompare p1_main_cmp_4;
   double p1_main_deg_4;

   EAngleCompare p1_signal_cmp_1;
   double p1_signal_deg_1;
   EAngleCompare p1_signal_cmp_2;
   double p1_signal_deg_2;
   EAngleCompare p1_signal_cmp_3;
   double p1_signal_deg_3;
   EAngleCompare p1_signal_cmp_4;
   double p1_signal_deg_4;

   bool p2_enabled;
   bool p2_emit_signal;
   bool p2_buy_signal;

   bool p3_enabled;
   bool p3_emit_signal;
   bool p3_buy_signal;
};

bool IsValidAngleCompare(const EAngleCompare cmp)
{
   return (cmp == UHOL_VACSIE ||
      cmp == UHOL_VACSIE_ALBO_ROVNE ||
      cmp == UHOL_MENSIE ||
      cmp == UHOL_MENSIE_ALBO_ROVNE);
}

bool IsValidP1SignalMode(const EP1SmerSignalu mode)
{
   return (mode == P1_SIGNAL_BUY ||
      mode == P1_SIGNAL_SELL ||
      mode == P1_SIGNAL_BUY_AJ_SELL);
}

SDevSettings DefaultDevSettings()
{
   SDevSettings s;
   s.condition_test_mode = false;
   s.single_condition_id = CONDITION_NONE;

   s.p1_enabled = true;
   s.p1_max_spread_points = 25;
   s.p1_je_len_filter = true;
   s.p1_signal_mode = P1_SIGNAL_BUY;

   s.p1_stoch_timeframe = PERIOD_CURRENT;
   s.p1_stoch_k_period = 14;
   s.p1_stoch_d_period = 3;
   s.p1_stoch_slowing = 3;
   s.p1_stoch_ma_method = MODE_SMA;
   s.p1_stoch_price_field = STO_LOWHIGH;
   s.p1_angle_scale = 2.0;

   s.p1_main_cmp_1 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_main_deg_1 = 0.0;
   s.p1_main_cmp_2 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_main_deg_2 = 0.0;
   s.p1_main_cmp_3 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_main_deg_3 = 0.0;
   s.p1_main_cmp_4 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_main_deg_4 = 0.0;

   s.p1_signal_cmp_1 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_signal_deg_1 = 0.0;
   s.p1_signal_cmp_2 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_signal_deg_2 = 0.0;
   s.p1_signal_cmp_3 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_signal_deg_3 = 0.0;
   s.p1_signal_cmp_4 = UHOL_VACSIE_ALBO_ROVNE;
   s.p1_signal_deg_4 = 0.0;

   s.p2_enabled = false;
   s.p2_emit_signal = false;
   s.p2_buy_signal = true;

   s.p3_enabled = false;
   s.p3_emit_signal = false;
   s.p3_buy_signal = true;

   return s;
}

bool ValidateDevSettings(const SDevSettings &s, string &err)
{
   if(!IsValidConditionId(s.single_condition_id))
   {
      err = "single_condition_id is invalid";
      return false;
   }

   if(s.condition_test_mode && s.single_condition_id == CONDITION_NONE)
   {
      err = "single_condition_id must not be CONDITION_NONE when condition_test_mode is enabled";
      return false;
   }

   if(s.p1_max_spread_points <= 0)
   {
      err = "p1_max_spread_points must be positive";
      return false;
   }

   if(!IsValidP1SignalMode(s.p1_signal_mode))
   {
      err = "p1_signal_mode is invalid";
      return false;
   }

   if(s.p1_stoch_k_period <= 0 || s.p1_stoch_d_period <= 0 || s.p1_stoch_slowing <= 0)
   {
      err = "p1 stochastic periods must be positive";
      return false;
   }

   if(s.p1_angle_scale <= 0.0)
   {
      err = "p1_angle_scale must be positive";
      return false;
   }

   if(s.p1_main_deg_1 < -90.0 || s.p1_main_deg_1 > 90.0 ||
      s.p1_main_deg_2 < -90.0 || s.p1_main_deg_2 > 90.0 ||
      s.p1_main_deg_3 < -90.0 || s.p1_main_deg_3 > 90.0 ||
      s.p1_main_deg_4 < -90.0 || s.p1_main_deg_4 > 90.0 ||
      s.p1_signal_deg_1 < -90.0 || s.p1_signal_deg_1 > 90.0 ||
      s.p1_signal_deg_2 < -90.0 || s.p1_signal_deg_2 > 90.0 ||
      s.p1_signal_deg_3 < -90.0 || s.p1_signal_deg_3 > 90.0 ||
      s.p1_signal_deg_4 < -90.0 || s.p1_signal_deg_4 > 90.0)
   {
      err = "p1 angle thresholds must be in range [-90, 90]";
      return false;
   }

   if(!IsValidAngleCompare(s.p1_main_cmp_1) ||
      !IsValidAngleCompare(s.p1_main_cmp_2) ||
      !IsValidAngleCompare(s.p1_main_cmp_3) ||
      !IsValidAngleCompare(s.p1_main_cmp_4) ||
      !IsValidAngleCompare(s.p1_signal_cmp_1) ||
      !IsValidAngleCompare(s.p1_signal_cmp_2) ||
      !IsValidAngleCompare(s.p1_signal_cmp_3) ||
      !IsValidAngleCompare(s.p1_signal_cmp_4))
   {
      err = "p1 angle compare mode is invalid";
      return false;
   }

   err = "";
   return true;
}

#endif