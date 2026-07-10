#ifndef FX1_P2_CONDITION_MQH
#define FX1_P2_CONDITION_MQH

#include <FX1/Config/DevSettings.mqh>
#include <FX1/Core/Types.mqh>

class CP2Condition
{
private:
   bool m_enabled;
   bool m_emit_signal;
   ESignalSide m_signal_side;

public:
   CP2Condition()
   {
      SDevSettings d = DefaultDevSettings();
      m_enabled = d.p2_enabled;
      m_emit_signal = d.p2_emit_signal;
      m_signal_side = d.p2_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   void Configure(const SDevSettings &dev)
   {
      m_enabled = dev.p2_enabled;
      m_emit_signal = dev.p2_emit_signal;
      m_signal_side = dev.p2_buy_signal ? SIGNAL_BUY : SIGNAL_SELL;
   }

   bool IsEnabled() const
   {
      return m_enabled;
   }

   bool Evaluate(const SMarketSnapshot &snapshot, SSignal &out_signal)
   {
      (void)snapshot;
      out_signal.side = SIGNAL_NONE;
      out_signal.confidence = 0.0;

      if(!m_enabled)
      {
         out_signal.reason = "P2 disabled";
         return false;
      }

      out_signal.reason = "P2 TODO: logic not implemented yet";
      if(m_emit_signal)
         out_signal.side = m_signal_side;

      return false;
   }
};

#endif