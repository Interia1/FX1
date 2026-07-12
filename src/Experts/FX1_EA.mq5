#property strict
#property version "1.00"
#property description "FX1 modular EA architecture scaffold"

#include <FX1/Config/Settings.mqh>
#include <FX1/Config/DevSettings.mqh>
#include <FX1/Core/AppContext.mqh>
#include <FX1/Core/Engine.mqh>

#include <FX1/Modules/UnitConversion.mqh>
#include <FX1/Modules/ConditionModule.mqh>
#include <FX1/Modules/CompositeConditionModule.mqh>
#include <FX1/Modules/SafetyModule.mqh>
#include <FX1/Modules/RiskModule.mqh>
#include <FX1/Modules/ExecutionModule.mqh>
#include <FX1/Modules/PositionModule.mqh>
#include <FX1/Modules/ChartModule.mqh>
#include <FX1/Modules/UiModule.mqh>

input group "Zakladne nastavenia"
input bool PovolitObchodovanie = true;   // Povolit obchodovanie
input long MagickeCisloEA = 51001;       // Magic cislo EA

input group "Riziko a objem"
input EObjemRezim RezimObjemu = OBJEM_FIXNY_LOT; // Aktivny je len zvoleny rezim
input double FixnyLot = 0.10;           // Pouzije sa len pre OBJEM_FIXNY_LOT
input double RizikoPercent = 1.0;       // Riziko na obchod (%)
input double MarzaPercent = 5.0;        // Pouzije sa len pre OBJEM_MARZA_PERCENT

input group "Exekucia a limity"
input int MaxSpreadBody = 25;       // Max spread (body)
input int MaxSklzBody = 20;         // Max sklz (body)
input int StopLossBody = 200;       // Stop Loss (body)
input int TakeProfitBody = 300;     // Take Profit (body)

input group "Sprava pozicie"
input bool ZapnutTrailingStop = true;      // Zapnut trailing stop
input int TrailingStartBody = 150;         // Aktivacia trailingu (body zisku)
input int TrailingKrokBody = 50;           // Minimalny krok posunu trailingu (body)
input bool ZapnutCiastocnyVystup = true;   // Zapnut partial close
input ECiastocnyVystupSpustenieRezim RezimSpusteniaCiastocnehoVystupu = CIASTOCNY_SPUSTENIE_BODY; // Aktivny je len zvoleny rezim
input int CiastocnyVystupSpustenieBody = 120; // Pouzije sa len pre CIASTOCNY_SPUSTENIE_BODY
input double CiastocnyVystupSpustenieTPPercent = 50.0; // Pouzije sa len pre CIASTOCNY_SPUSTENIE_TP_PERCENT
input double CiastocnyVystupPercent = 50.0;   // Percento objemu na zavretie

input group "P1 - Zapnutie"
input bool P1Zapnuta = true;                  // Zapnut podmienku P1
input int P1MaxSpreadBody = 25;               // Max spread pre P1 (body)
input bool P1EmitovatSignal = false;          // Ak true, P1 moze emitovat BUY/SELL
input bool P1SignalBuy = true;                // Smer signalu pri emitovani (true=BUY, false=SELL)

input group "P1 - Stochastic"
input ENUM_TIMEFRAMES P1StochTimeframe = PERIOD_CURRENT;
input int P1StochK = 14;
input int P1StochD = 3;
input int P1StochSlowing = 3;
input ENUM_MA_METHOD P1StochMAMethod = MODE_SMA;
input ENUM_STO_PRICE P1StochPriceField = STO_LOWHIGH;
input double P1AngleScale = 2.0;

input group "P1 - MAIN uhly"
input EAngleCompare P1MainCmp1 = ANGLE_CMP_GREATER_EQUAL;
input double P1MainDeg1 = 0.0;
input EAngleCompare P1MainCmp2 = ANGLE_CMP_GREATER_EQUAL;
input double P1MainDeg2 = 0.0;
input EAngleCompare P1MainCmp3 = ANGLE_CMP_GREATER_EQUAL;
input double P1MainDeg3 = 0.0;
input EAngleCompare P1MainCmp4 = ANGLE_CMP_GREATER_EQUAL;
input double P1MainDeg4 = 0.0;

input group "P1 - SIGNAL uhly"
input EAngleCompare P1SignalCmp1 = ANGLE_CMP_GREATER_EQUAL;
input double P1SignalDeg1 = 0.0;
input EAngleCompare P1SignalCmp2 = ANGLE_CMP_GREATER_EQUAL;
input double P1SignalDeg2 = 0.0;
input EAngleCompare P1SignalCmp3 = ANGLE_CMP_GREATER_EQUAL;
input double P1SignalDeg3 = 0.0;
input EAngleCompare P1SignalCmp4 = ANGLE_CMP_GREATER_EQUAL;
input double P1SignalDeg4 = 0.0;

SAppContext g_ctx;

CUnitConversionModule g_converter;
CConditionModule g_condition;
CCompositeConditionModule g_composite;
CSafetyModule g_safety;
CRiskModule *g_risk = NULL;
CExecutionModule *g_execution = NULL;
CPositionModule g_positions;
CChartModule g_chart;
CUiModule g_ui;
CEngine *g_engine = NULL;

int OnInit()
{
   g_ctx.symbol = _Symbol;
   g_ctx.timeframe = _Period;

   g_ctx.settings = DefaultSettings();
   g_ctx.settings.magic = MagickeCisloEA;
   g_ctx.settings.risk_percent = RizikoPercent;
   g_ctx.settings.margin_percent = MarzaPercent;
   g_ctx.settings.use_fixed_lot = (RezimObjemu == OBJEM_FIXNY_LOT);
   g_ctx.settings.fixed_lot = FixnyLot;
   g_ctx.settings.volume_mode = (int)RezimObjemu;
   g_ctx.settings.max_spread_points = MaxSpreadBody;
   g_ctx.settings.slippage_points = MaxSklzBody;
   g_ctx.settings.stop_loss_points = StopLossBody;
   g_ctx.settings.take_profit_points = TakeProfitBody;
   g_ctx.settings.trailing_enabled = ZapnutTrailingStop;
   g_ctx.settings.trailing_start_points = TrailingStartBody;
   g_ctx.settings.trailing_step_points = TrailingKrokBody;
   g_ctx.settings.partial_close_enabled = ZapnutCiastocnyVystup;
   g_ctx.settings.partial_close_trigger_mode = (int)RezimSpusteniaCiastocnehoVystupu;
   g_ctx.settings.partial_close_trigger_points = CiastocnyVystupSpustenieBody;
   g_ctx.settings.partial_close_trigger_tp_percent = CiastocnyVystupSpustenieTPPercent;
   g_ctx.settings.partial_close_percent = CiastocnyVystupPercent;
   g_ctx.settings.trading_enabled = PovolitObchodovanie;

   SDevSettings dev = DefaultDevSettings();
   dev.p1_enabled = P1Zapnuta;
   dev.p1_max_spread_points = P1MaxSpreadBody;
   dev.p1_emit_signal = P1EmitovatSignal;
   dev.p1_buy_signal = P1SignalBuy;

   dev.p1_stoch_timeframe = P1StochTimeframe;
   dev.p1_stoch_k_period = P1StochK;
   dev.p1_stoch_d_period = P1StochD;
   dev.p1_stoch_slowing = P1StochSlowing;
   dev.p1_stoch_ma_method = P1StochMAMethod;
   dev.p1_stoch_price_field = P1StochPriceField;
   dev.p1_angle_scale = P1AngleScale;

   dev.p1_main_cmp_1 = P1MainCmp1;
   dev.p1_main_deg_1 = P1MainDeg1;
   dev.p1_main_cmp_2 = P1MainCmp2;
   dev.p1_main_deg_2 = P1MainDeg2;
   dev.p1_main_cmp_3 = P1MainCmp3;
   dev.p1_main_deg_3 = P1MainDeg3;
   dev.p1_main_cmp_4 = P1MainCmp4;
   dev.p1_main_deg_4 = P1MainDeg4;

   dev.p1_signal_cmp_1 = P1SignalCmp1;
   dev.p1_signal_deg_1 = P1SignalDeg1;
   dev.p1_signal_cmp_2 = P1SignalCmp2;
   dev.p1_signal_deg_2 = P1SignalDeg2;
   dev.p1_signal_cmp_3 = P1SignalCmp3;
   dev.p1_signal_deg_3 = P1SignalDeg3;
   dev.p1_signal_cmp_4 = P1SignalCmp4;
   dev.p1_signal_deg_4 = P1SignalDeg4;

   string err = "";
   if(!ValidateSettings(g_ctx.settings, err))
   {
      Print("Settings validation failed: ", err);
      return INIT_PARAMETERS_INCORRECT;
   }

   if(!ValidateDevSettings(dev, err))
   {
      Print("Dev settings validation failed: ", err);
      return INIT_PARAMETERS_INCORRECT;
   }

   g_safety.SetMaxSpreadPoints(g_ctx.settings.max_spread_points);
   g_condition.Configure(dev);
   g_composite.SetPrimary(&g_condition);

   g_risk = new CRiskModule(&g_converter);
   g_execution = new CExecutionModule(&g_converter);
   g_engine = new CEngine(&g_converter, &g_composite, &g_safety, g_risk, g_execution, &g_positions, &g_chart);

   if(!g_ui.OnInitUi(g_ctx))
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(reason == -1)
      Print("Deinit reason: ", reason);

   g_ui.OnDeinitUi();
   Comment("");

   if(g_engine != NULL)
   {
      delete g_engine;
      g_engine = NULL;
   }

   if(g_execution != NULL)
   {
      delete g_execution;
      g_execution = NULL;
   }

   if(g_risk != NULL)
   {
      delete g_risk;
      g_risk = NULL;
   }
}

void OnTick()
{
   if(g_engine == NULL)
      return;

   g_engine.OnTick(g_ctx);
}
