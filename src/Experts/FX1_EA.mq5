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

input group "Zobrazenie vystupov"
input EVystupRezim RezimVystupu = VYSTUP_DETAILNY; // VYPNUTY/STRUCNY/DETAILNY
input EVystupPanelPozicia PoziciaPaneluVystupov = PANEL_VLAVO_HORE; // NEUKAZOVAT/VLAVO_HORE/VPRAVO_HORE
input bool VystupZobrazitSpread = true;
input bool VystupZobrazitSignal = true;
input bool VystupZobrazitP1 = true;
input bool VystupZobrazitRiziko = true;
input bool VystupZobrazitObjem = true;

input group "P1 - Zaklad"
input bool P1Zapnuta = true;                      // Zapnut podmienku P1
input int P1MaxSpreadBody = 25;                   // Max spread pre P1 (body)
input EP1Rezim P1Rezim = LenTestP1;               // LenTestP1 / RealSignalP1
input EP1SmerSignalu P1SmerSignalu = P1_SIGNAL_BUY; // Pouzije sa iba ked P1Rezim=RealSignalP1

input group "P1 - Stochastic nastavenia"
input ENUM_TIMEFRAMES P1CasovyRamecStoch = PERIOD_CURRENT; // Casovy ramec Stochastic
input int P1StochKPerioda = 14;                   // K perioda
input int P1StochDPerioda = 3;                    // D perioda
input int P1StochSpomalenie = 3;                  // Spomalenie
input ENUM_MA_METHOD P1StochMAMetoda = MODE_SMA;  // MA metoda
input ENUM_STO_PRICE P1StochCenovePole = STO_LOWHIGH; // Cenove pole
input double P1SkalaUhlu = 2.0;                   // Skala pre vypocet uhlu

input group "P1 - MAIN uhly"
input EAngleCompare P1MainPorovnanie1 = UHOL_VACSIE_ALBO_ROVNE;
input double P1MainStupne1 = 0.0;
input EAngleCompare P1MainPorovnanie2 = UHOL_VACSIE_ALBO_ROVNE;
input double P1MainStupne2 = 0.0;
input EAngleCompare P1MainPorovnanie3 = UHOL_VACSIE_ALBO_ROVNE;
input double P1MainStupne3 = 0.0;
input EAngleCompare P1MainPorovnanie4 = UHOL_VACSIE_ALBO_ROVNE;
input double P1MainStupne4 = 0.0;

input group "P1 - SIGNAL uhly"
input EAngleCompare P1SignalPorovnanie1 = UHOL_VACSIE_ALBO_ROVNE;
input double P1SignalStupne1 = 0.0;
input EAngleCompare P1SignalPorovnanie2 = UHOL_VACSIE_ALBO_ROVNE;
input double P1SignalStupne2 = 0.0;
input EAngleCompare P1SignalPorovnanie3 = UHOL_VACSIE_ALBO_ROVNE;
input double P1SignalStupne3 = 0.0;
input EAngleCompare P1SignalPorovnanie4 = UHOL_VACSIE_ALBO_ROVNE;
input double P1SignalStupne4 = 0.0;

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
   g_ctx.settings.output_mode = (int)RezimVystupu;
   g_ctx.settings.output_panel_position = (int)PoziciaPaneluVystupov;
   g_ctx.settings.output_show_spread = VystupZobrazitSpread;
   g_ctx.settings.output_show_signal = VystupZobrazitSignal;
   g_ctx.settings.output_show_p1 = VystupZobrazitP1;
   g_ctx.settings.output_show_risk = VystupZobrazitRiziko;
   g_ctx.settings.output_show_volume = VystupZobrazitObjem;
   g_ctx.settings.trading_enabled = PovolitObchodovanie;

   SDevSettings dev = DefaultDevSettings();
   dev.p1_enabled = P1Zapnuta;
   dev.p1_max_spread_points = P1MaxSpreadBody;
   dev.p1_rezim = P1Rezim;
   dev.p1_signal_mode = P1SmerSignalu;

   dev.p1_stoch_timeframe = P1CasovyRamecStoch;
   dev.p1_stoch_k_period = P1StochKPerioda;
   dev.p1_stoch_d_period = P1StochDPerioda;
   dev.p1_stoch_slowing = P1StochSpomalenie;
   dev.p1_stoch_ma_method = P1StochMAMetoda;
   dev.p1_stoch_price_field = P1StochCenovePole;
   dev.p1_angle_scale = P1SkalaUhlu;

   dev.p1_main_cmp_1 = P1MainPorovnanie1;
   dev.p1_main_deg_1 = P1MainStupne1;
   dev.p1_main_cmp_2 = P1MainPorovnanie2;
   dev.p1_main_deg_2 = P1MainStupne2;
   dev.p1_main_cmp_3 = P1MainPorovnanie3;
   dev.p1_main_deg_3 = P1MainStupne3;
   dev.p1_main_cmp_4 = P1MainPorovnanie4;
   dev.p1_main_deg_4 = P1MainStupne4;

   dev.p1_signal_cmp_1 = P1SignalPorovnanie1;
   dev.p1_signal_deg_1 = P1SignalStupne1;
   dev.p1_signal_cmp_2 = P1SignalPorovnanie2;
   dev.p1_signal_deg_2 = P1SignalStupne2;
   dev.p1_signal_cmp_3 = P1SignalPorovnanie3;
   dev.p1_signal_deg_3 = P1SignalStupne3;
   dev.p1_signal_cmp_4 = P1SignalPorovnanie4;
   dev.p1_signal_deg_4 = P1SignalStupne4;

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
   ObjectDelete(0, "FX1_OUTPUT_PANEL");

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
