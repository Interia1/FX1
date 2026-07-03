#ifndef FX1_TYPES_MQH
#define FX1_TYPES_MQH

enum ESignalSide
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY = 1,
   SIGNAL_SELL = -1
};

struct SMarketSnapshot
{
   datetime timestamp;
   string symbol;
   double bid;
   double ask;
   double point;
   double tick_size;
   double tick_value;
   int digits;
   double spread_points;
};

struct SSignal
{
   ESignalSide side;
   double confidence;
   string reason;
};

struct SRiskDecision
{
   bool allowed;
   double volume;
   double stop_loss;
   double take_profit;
   string reason;
};

#endif
