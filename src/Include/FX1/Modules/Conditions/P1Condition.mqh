#ifndef FX1_P1_CONDITION_MQH
#define FX1_P1_CONDITION_MQH

#include <FX1/Config/DevSettings.mqh>
#include <FX1/Core/Types.mqh>

class CP1Condition
{
private:
   bool m_enabled;
   int m_max_spread_points;
   EP1Rezim m_mode;
   EP1SmerSignalu m_signal_mode;
   ENUM_TIMEFRAMES m_stoch_timeframe;
   int m_stoch_k_period;
   int m_stoch_d_period;
   int m_stoch_slowing;
   ENUM_MA_METHOD m_stoch_ma_method;
   ENUM_STO_PRICE m_stoch_price_field;
   double m_angle_scale;
   EAngleCompare m_main_cmp_1;
   double m_main_deg_1;
   EAngleCompare m_main_cmp_2;
   double m_main_deg_2;
   EAngleCompare m_main_cmp_3;
   double m_main_deg_3;
   EAngleCompare m_main_cmp_4;
   double m_main_deg_4;
   EAngleCompare m_signal_cmp_1;
   double m_signal_deg_1;
   EAngleCompare m_signal_cmp_2;
   double m_signal_deg_2;
   EAngleCompare m_signal_cmp_3;
   double m_signal_deg_3;
   EAngleCompare m_signal_cmp_4;
   double m_signal_deg_4;
   int m_stoch_handle;
   string m_stoch_symbol;
   ENUM_TIMEFRAMES m_active_timeframe;

   void ResetHandle()
   {
      if(m_stoch_handle != INVALID_HANDLE)
         IndicatorRelease(m_stoch_handle);
      m_stoch_handle = INVALID_HANDLE;
      m_stoch_symbol = "";
      m_active_timeframe = PERIOD_CURRENT;
   }

   ENUM_TIMEFRAMES ResolveTimeframe() const
   {
      if(m_stoch_timeframe == PERIOD_CURRENT)
         return (ENUM_TIMEFRAMES)Period();
      return m_stoch_timeframe;
   }

   bool EnsureStochastic(const string symbol)
   {
      ENUM_TIMEFRAMES tf = ResolveTimeframe();
      bool need_recreate = (m_stoch_handle == INVALID_HANDLE || m_stoch_symbol != symbol || m_active_timeframe != tf);
      if(!need_recreate)
         return true;

      ResetHandle();
      m_stoch_handle = iStochastic(symbol,
                                   tf,
                                   m_stoch_k_period,
                                   m_stoch_d_period,
                                   m_stoch_slowing,
                                   m_stoch_ma_method,
                                   m_stoch_price_field);
      if(m_stoch_handle == INVALID_HANDLE)
         return false;

      m_stoch_symbol = symbol;
      m_active_timeframe = tf;
      return true;
   }

   bool LoadBufferValue(const int buffer_index, const int shift, double &value) const
   {
      double one[1];
      int copied = CopyBuffer(m_stoch_handle, buffer_index, shift, 1, one);
      if(copied != 1)
         return false;

      value = one[0];
      return true;
   }

   double AngleFromValues(const double current, const double previous) const
   {
      const double pi = 3.14159265358979323846;
      double slope = (current - previous) / m_angle_scale;
      return MathArctan(slope) * 180.0 / pi;
   }

   bool CompareAngle(const double value, const EAngleCompare cmp, const double threshold) const
   {
      if(cmp == UHOL_VACSIE)
         return value > threshold;
      if(cmp == UHOL_VACSIE_ALBO_ROVNE)
         return value >= threshold;
      if(cmp == UHOL_MENSIE)
         return value < threshold;
      if(cmp == UHOL_MENSIE_ALBO_ROVNE)
         return value <= threshold;
      return false;
   }

   EAngleCompare MainCmpByIndex(const int index) const
   {
      if(index == 0)
         return m_main_cmp_1;
      if(index == 1)
         return m_main_cmp_2;
      if(index == 2)
         return m_main_cmp_3;
      return m_main_cmp_4;
   }

   double MainDegByIndex(const int index) const
   {
      if(index == 0)
         return m_main_deg_1;
      if(index == 1)
         return m_main_deg_2;
      if(index == 2)
         return m_main_deg_3;
      return m_main_deg_4;
   }

   EAngleCompare SignalCmpByIndex(const int index) const
   {
      if(index == 0)
         return m_signal_cmp_1;
      if(index == 1)
         return m_signal_cmp_2;
      if(index == 2)
         return m_signal_cmp_3;
      return m_signal_cmp_4;
   }

   double SignalDegByIndex(const int index) const
   {
      if(index == 0)
         return m_signal_deg_1;
      if(index == 1)
         return m_signal_deg_2;
      if(index == 2)
         return m_signal_deg_3;
      return m_signal_deg_4;
   }

   string CompareLabel(const EAngleCompare cmp) const
   {
      if(cmp == UHOL_VACSIE)
         return ">";
      if(cmp == UHOL_VACSIE_ALBO_ROVNE)
         return ">=";
      if(cmp == UHOL_MENSIE)
         return "<";
      if(cmp == UHOL_MENSIE_ALBO_ROVNE)
         return "<=";
      return "?";
   }

public:
   CP1Condition()
   {
      SDevSettings d = DefaultDevSettings();
      m_stoch_handle = INVALID_HANDLE;
      m_stoch_symbol = "";
      m_active_timeframe = PERIOD_CURRENT;
      m_enabled = d.p1_enabled;
      m_max_spread_points = d.p1_max_spread_points;
      m_mode = d.p1_rezim;
      m_signal_mode = d.p1_signal_mode;
      m_stoch_timeframe = d.p1_stoch_timeframe;
      m_stoch_k_period = d.p1_stoch_k_period;
      m_stoch_d_period = d.p1_stoch_d_period;
      m_stoch_slowing = d.p1_stoch_slowing;
      m_stoch_ma_method = d.p1_stoch_ma_method;
      m_stoch_price_field = d.p1_stoch_price_field;
      m_angle_scale = d.p1_angle_scale;
      m_main_cmp_1 = d.p1_main_cmp_1;
      m_main_deg_1 = d.p1_main_deg_1;
      m_main_cmp_2 = d.p1_main_cmp_2;
      m_main_deg_2 = d.p1_main_deg_2;
      m_main_cmp_3 = d.p1_main_cmp_3;
      m_main_deg_3 = d.p1_main_deg_3;
      m_main_cmp_4 = d.p1_main_cmp_4;
      m_main_deg_4 = d.p1_main_deg_4;
      m_signal_cmp_1 = d.p1_signal_cmp_1;
      m_signal_deg_1 = d.p1_signal_deg_1;
      m_signal_cmp_2 = d.p1_signal_cmp_2;
      m_signal_deg_2 = d.p1_signal_deg_2;
      m_signal_cmp_3 = d.p1_signal_cmp_3;
      m_signal_deg_3 = d.p1_signal_deg_3;
      m_signal_cmp_4 = d.p1_signal_cmp_4;
      m_signal_deg_4 = d.p1_signal_deg_4;
   }

   ~CP1Condition()
   {
      ResetHandle();
   }

   void Configure(const SDevSettings &dev)
   {
      bool stoch_changed = (m_stoch_timeframe != dev.p1_stoch_timeframe ||
                            m_stoch_k_period != dev.p1_stoch_k_period ||
                            m_stoch_d_period != dev.p1_stoch_d_period ||
                            m_stoch_slowing != dev.p1_stoch_slowing ||
                            m_stoch_ma_method != dev.p1_stoch_ma_method ||
                            m_stoch_price_field != dev.p1_stoch_price_field);

      m_enabled = dev.p1_enabled;
      m_max_spread_points = dev.p1_max_spread_points;
      m_mode = dev.p1_rezim;
      m_signal_mode = dev.p1_signal_mode;
      m_stoch_timeframe = dev.p1_stoch_timeframe;
      m_stoch_k_period = dev.p1_stoch_k_period;
      m_stoch_d_period = dev.p1_stoch_d_period;
      m_stoch_slowing = dev.p1_stoch_slowing;
      m_stoch_ma_method = dev.p1_stoch_ma_method;
      m_stoch_price_field = dev.p1_stoch_price_field;
      m_angle_scale = dev.p1_angle_scale;
      m_main_cmp_1 = dev.p1_main_cmp_1;
      m_main_deg_1 = dev.p1_main_deg_1;
      m_main_cmp_2 = dev.p1_main_cmp_2;
      m_main_deg_2 = dev.p1_main_deg_2;
      m_main_cmp_3 = dev.p1_main_cmp_3;
      m_main_deg_3 = dev.p1_main_deg_3;
      m_main_cmp_4 = dev.p1_main_cmp_4;
      m_main_deg_4 = dev.p1_main_deg_4;
      m_signal_cmp_1 = dev.p1_signal_cmp_1;
      m_signal_deg_1 = dev.p1_signal_deg_1;
      m_signal_cmp_2 = dev.p1_signal_cmp_2;
      m_signal_deg_2 = dev.p1_signal_deg_2;
      m_signal_cmp_3 = dev.p1_signal_cmp_3;
      m_signal_deg_3 = dev.p1_signal_deg_3;
      m_signal_cmp_4 = dev.p1_signal_cmp_4;
      m_signal_deg_4 = dev.p1_signal_deg_4;

      if(stoch_changed)
         ResetHandle();
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

      if(!EnsureStochastic(snapshot.symbol))
      {
         out_signal.reason = "P1 fail: stochastic handle";
         return false;
      }

      double main_values[5];
      double signal_values[5];
      for(int i = 0; i < 5; i++)
      {
         // Shift 1 is the last closed bar, shift 2 is one bar older, etc.
         int shift = i + 1;
         if(!LoadBufferValue(0, shift, main_values[i]) ||
            !LoadBufferValue(1, shift, signal_values[i]))
         {
            out_signal.reason = "P1 fail: insufficient stochastic data";
            return false;
         }
      }

      for(int i = 0; i < 4; i++)
      {
         double main_angle = AngleFromValues(main_values[i], main_values[i + 1]);
         EAngleCompare main_cmp = MainCmpByIndex(i);
         double main_threshold = MainDegByIndex(i);
         // Threshold 0 means "ignore this slot" for flexible 1..4 bar setups.
         if(main_threshold != 0.0 && !CompareAngle(main_angle, main_cmp, main_threshold))
         {
            out_signal.reason = "P1 fail: MAIN b" + IntegerToString(i + 1) + " " +
                                DoubleToString(main_angle, 2) + " not " +
                                CompareLabel(main_cmp) + " " +
                                DoubleToString(main_threshold, 2);
            return false;
         }

         double signal_angle = AngleFromValues(signal_values[i], signal_values[i + 1]);
         EAngleCompare signal_cmp = SignalCmpByIndex(i);
         double signal_threshold = SignalDegByIndex(i);
         if(signal_threshold != 0.0 && !CompareAngle(signal_angle, signal_cmp, signal_threshold))
         {
            out_signal.reason = "P1 fail: SIGNAL b" + IntegerToString(i + 1) + " " +
                                DoubleToString(signal_angle, 2) + " not " +
                                CompareLabel(signal_cmp) + " " +
                                DoubleToString(signal_threshold, 2);
            return false;
         }
      }

      out_signal.reason = "P1 pass: stochastic slopes matched";
      out_signal.confidence = 1.0;

      if(m_mode == RealSignalP1)
      {
         if(m_signal_mode == P1_SIGNAL_BUY)
         {
            out_signal.side = SIGNAL_BUY;
            out_signal.reason = "P1 pass: emit BUY";
         }
         else if(m_signal_mode == P1_SIGNAL_SELL)
         {
            out_signal.side = SIGNAL_SELL;
            out_signal.reason = "P1 pass: emit SELL";
         }
         else if(m_signal_mode == P1_SIGNAL_BUY_AJ_SELL)
         {
            // In BOTH mode choose side from current stochastic line relation.
            out_signal.side = (main_values[0] >= signal_values[0]) ? SIGNAL_BUY : SIGNAL_SELL;
            out_signal.reason = "P1 pass: emit BOTH(auto side)";
         }
      }

      return true;
   }
};

#endif