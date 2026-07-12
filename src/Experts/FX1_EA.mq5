#property strict
#property version "1.00"
#property description "FX1 modular EA architecture scaffold"

#include <FX1/Config/Settings.mqh>
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
input double RizikoPercent = 1.0;       // Riziko na obchod (%)
input double MarzaPercent = 5.0;        // Percento z volnej marze na vstup
input bool PouzitFixnyLot = true;       // Pouzit fixny lot
input double FixnyLot = 0.10;           // Fixny lot
input EObjemRezim RezimObjemu = OBJEM_FIXNY_LOT; // Rezim vypoctu objemu

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
input int CiastocnyVystupSpustenieBody = 120; // Spustenie partial close (body zisku)
input double CiastocnyVystupPercent = 50.0;   // Percento objemu na zavretie

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
   g_ctx.settings.use_fixed_lot = PouzitFixnyLot;
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
   g_ctx.settings.partial_close_trigger_points = CiastocnyVystupSpustenieBody;
   g_ctx.settings.partial_close_percent = CiastocnyVystupPercent;
   g_ctx.settings.trading_enabled = PovolitObchodovanie;

   string err = "";
   if(!ValidateSettings(g_ctx.settings, err))
   {
      Print("Settings validation failed: ", err);
      return INIT_PARAMETERS_INCORRECT;
   }

   g_safety.SetMaxSpreadPoints(g_ctx.settings.max_spread_points);
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
