#ifndef FX1_P1_CONDITION_MQH
#define FX1_P1_CONDITION_MQH

#include <FX1/Config/DevSettings.mqh>
#include <FX1/Core/Types.mqh>

class CP1Condition
{
private:
   bool m_enabled;
   int m_max_spread_points;
   bool m_emit_signal;
   ESignalSide m_signal_side;

public:
   CP1Condition()
   {
      SDevSettings d = DefaultDevSettings();
      m_enabled = d.p1_enabled;
      m_max_spread_points = d.p1_max_spread_points;
      m_emit_signal = d.p1_emit_signal;
      m_signal_side = d.p1_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   void Configure(const SDevSettings &dev)
   {
      m_enabled = dev.p1_enabled;
      m_max_spread_points = dev.p1_max_spread_points;
      m_emit_signal = dev.p1_emit_signal;
      m_signal_side = dev.p1_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   bool IsEnabled() const
   {
      return m_enabled;
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal)
   {
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;

      if(!m_enabled)
      {
         out_signal.reason = "P1 disabled";
         return false;
      }

      if(snapshot.spread_points > (double)m_max_spread_points)
      {
         out_signal.reason = "P1 fail: spread > max";
         return false;
      }

      out_signal.reason = "P1 pass: spread <= max";
      out_signal.confidence = 1.0;
      if(m_emit_signal)
         out_signal.side = m_signal_side;

      return true;
   }
};

#endif