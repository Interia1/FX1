#ifndef FX1_CONTRACTS_MQH
#define FX1_CONTRACTS_MQH

#include <FX1/Core/Types.mqh>
#include <FX1/Core/AppContext.mqh>

class IUnitConverter
{
public:
   virtual bool RefreshSymbolContext(const string symbol) = 0;
   virtual double PointsToPrice(const string symbol, const double points) = 0;
   virtual double PriceToPoints(const string symbol, const double price_delta) = 0;
   virtual double NormalizePrice(const string symbol, const double price) = 0;
   virtual double NormalizeVolume(const string symbol, const double volume) = 0;
   virtual double SpreadInPoints(const string symbol) = 0;
   virtual int SlippageToDeviationPoints(const int slippage_points) = 0;
};

class ICondition
{
public:
   virtual bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal) = 0;
};

class ISafetyGate
{
public:
   virtual bool AllowTrading(const SAppContext &ctx, const SMarketSnapshot &snapshot, string &reason) = 0;
};

class IRiskManager
{
public:
   virtual bool BuildDecision(const SAppContext &ctx,
                              const SMarketSnapshot &snapshot,
                              const SSignal &signal,
                              SRiskDecision &out_decision) = 0;
};

class IExecution
{
public:
   virtual bool Execute(const SAppContext &ctx,
                        const SMarketSnapshot &snapshot,
                        const SSignal &signal,
                        const SRiskDecision &decision,
                        ulong &ticket,
                        string &reason) = 0;
};

class IPositionManager
{
public:
   virtual void ManageOpenPositions(const SAppContext &ctx, const SMarketSnapshot &snapshot) = 0;
};

class IChartOutput
{
public:
   virtual void Render(const SAppContext &ctx,
                       const SMarketSnapshot &snapshot,
                       const SSignal &signal,
                       const SRiskDecision &decision) = 0;
};

class IUiModule
{
public:
   virtual bool OnInitUi(const SAppContext &ctx) = 0;
   virtual void OnDeinitUi() = 0;
};

#endif
