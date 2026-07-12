#ifndef FX1_SETTINGS_MQH
#define FX1_SETTINGS_MQH

enum EObjemRezim
{
   OBJEM_FIXNY_LOT = 0,
   OBJEM_RIZIKO_PERCENT = 1,
   OBJEM_MARZA_PERCENT = 2
};

enum ECiastocnyVystupSpustenieRezim
{
   CIASTOCNY_SPUSTENIE_BODY = 0,
   CIASTOCNY_SPUSTENIE_TP_PERCENT = 1
};

enum EVystupRezim
{
   VYSTUP_VYPNUTY = 0,
   VYSTUP_STRUCNY = 1,
   VYSTUP_DETAILNY = 2
};

enum EVystupPanelPozicia
{
   PANEL_NEUKAZOVAT = 0,
   PANEL_VLAVO_HORE = 1,
   PANEL_VPRAVO_HORE = 2
};

struct SEaSettings
{
   long magic;
   double risk_percent;
   double margin_percent;
   double fixed_lot;
   int volume_mode;
   bool use_fixed_lot;
   int max_spread_points;
   int slippage_points;
   int stop_loss_points;
   int take_profit_points;
   bool trailing_enabled;
   int trailing_start_points;
   int trailing_step_points;
   bool partial_close_enabled;
   int partial_close_trigger_mode;
   int partial_close_trigger_points;
   double partial_close_trigger_tp_percent;
   double partial_close_percent;
   int output_mode;
   int output_panel_position;
   bool output_show_spread;
   bool output_show_signal;
   bool output_show_p1;
   bool output_show_risk;
   bool output_show_volume;
   bool trading_enabled;
};

SEaSettings DefaultSettings()
{
   SEaSettings s;
   s.magic = 51001;
   s.risk_percent = 1.0;
      s.margin_percent = 5.0;
   s.fixed_lot = 0.10;
      s.volume_mode = OBJEM_FIXNY_LOT;
   s.use_fixed_lot = true;
   s.max_spread_points = 25;
   s.slippage_points = 20;
   s.stop_loss_points = 200;
   s.take_profit_points = 300;
      s.trailing_enabled = true;
      s.trailing_start_points = 150;
      s.trailing_step_points = 50;
      s.partial_close_enabled = true;
      s.partial_close_trigger_mode = CIASTOCNY_SPUSTENIE_BODY;
      s.partial_close_trigger_points = 120;
      s.partial_close_trigger_tp_percent = 50.0;
      s.partial_close_percent = 50.0;
      s.output_mode = VYSTUP_DETAILNY;
      s.output_panel_position = PANEL_VLAVO_HORE;
      s.output_show_spread = true;
      s.output_show_signal = true;
      s.output_show_p1 = true;
      s.output_show_risk = true;
      s.output_show_volume = true;
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
   if(s.margin_percent <= 0.0 || s.margin_percent > 100.0)
   {
      err = "margin_percent out of range (0, 100]";
      return false;
   }
   if(s.fixed_lot <= 0.0)
   {
      err = "fixed_lot must be positive";
      return false;
   }
   if(s.volume_mode < OBJEM_FIXNY_LOT || s.volume_mode > OBJEM_MARZA_PERCENT)
   {
      err = "volume_mode out of range";
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
   if(s.trailing_enabled)
   {
      if(s.trailing_start_points <= 0 || s.trailing_step_points <= 0)
      {
         err = "trailing_start_points and trailing_step_points must be positive";
         return false;
      }
   }
   if(s.partial_close_enabled)
   {
      if(s.partial_close_trigger_mode < CIASTOCNY_SPUSTENIE_BODY || s.partial_close_trigger_mode > CIASTOCNY_SPUSTENIE_TP_PERCENT)
      {
         err = "partial_close_trigger_mode out of range";
         return false;
      }
      if(s.partial_close_trigger_points <= 0)
      {
         err = "partial_close_trigger_points must be positive";
         return false;
      }
      if(s.partial_close_trigger_tp_percent <= 0.0 || s.partial_close_trigger_tp_percent > 100.0)
      {
         err = "partial_close_trigger_tp_percent out of range (0, 100]";
         return false;
      }
      if(s.partial_close_percent <= 0.0 || s.partial_close_percent >= 100.0)
      {
         err = "partial_close_percent out of range (0, 100)";
         return false;
      }
   }
   if(s.output_mode < VYSTUP_VYPNUTY || s.output_mode > VYSTUP_DETAILNY)
   {
      err = "output_mode out of range";
      return false;
   }
   if(s.output_panel_position < PANEL_NEUKAZOVAT || s.output_panel_position > PANEL_VPRAVO_HORE)
   {
      err = "output_panel_position out of range";
      return false;
   }
   err = "";
   return true;
}

#endif
