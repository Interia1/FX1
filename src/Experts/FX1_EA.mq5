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

input long InpMagic = 51001;
input double InpRiskPercent = 1.0;
input bool InpUseFixedLot = true;
input double InpFixedLot = 0.10;
input int InpMaxSpreadPoints = 25;
input int InpSlippagePoints = 20;
input int InpStopLossPoints = 200;
input int InpTakeProfitPoints = 300;
input bool InpTradingEnabled = true;

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
   g_ctx.settings.magic = InpMagic;
   g_ctx.settings.risk_percent = InpRiskPercent;
   g_ctx.settings.use_fixed_lot = InpUseFixedLot;
   g_ctx.settings.fixed_lot = InpFixedLot;
   g_ctx.settings.max_spread_points = InpMaxSpreadPoints;
   g_ctx.settings.slippage_points = InpSlippagePoints;
   g_ctx.settings.stop_loss_points = InpStopLossPoints;
   g_ctx.settings.take_profit_points = InpTakeProfitPoints;
   g_ctx.settings.trading_enabled = InpTradingEnabled;

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
   (void)reason;

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
