#include "SignalValidator.mqh"

class CSignalValidatorOnlyFirstTick : public CSignalValidatorRule
{
public:
   shared_ptr<CIsFirstTick> isfirsttick;   
   CSignalValidatorOnlyFirstTick(CIsFirstTick* in_isfirsttick) : isfirsttick(in_isfirsttick) {}
   virtual bool Validate(CSignal* signal)
   {
      if (!isfirsttick.get().isfirsttick()) {
         return false;
      }
      else return true;
   }
};

class CSignalValidatorReverse : public CSignalValidatorRule
{
public:
   virtual bool Validate(CSignal* signal)
   {
      signal.Reverse();
      return true;
   }
};

class CSignalValidatorSignalChange : public CSignalValidatorRule
{
public:
   ENUM_SIGNAL lastsignal;
   virtual bool Validate(CSignal* signal)
   {
      if (this.lastsignal == SIGNAL_NONE) {
         lastsignal = signal.signal;
         return false;
      }
      if (signal.signal == lastsignal) {
         return false;
      }
      lastsignal = signal.signal;
      return true;
   }
};

class CSignalValidatorSignalChangeClose : public CSignalValidatorRule
{
public:
   ENUM_SIGNAL lastsignal;
   virtual bool Validate(CSignal* signal)
   {
      if (this.lastsignal == SIGNAL_NONE) {
         lastsignal = signal.closesignal;
         return false;
      }
      if (signal.closesignal == lastsignal) {
         return false;
      }
      lastsignal = signal.closesignal;
      return true;
   }
};


class CSignalValidatorOneSignalPerBar : public CSignalValidatorRule
{
public:
   datetime last_valid_signal;
   string symbol;
   ENUM_TIMEFRAMES tf;
   CSignalValidatorOneSignalPerBar(string in_symbol, ENUM_TIMEFRAMES in_timeframe) : symbol(in_symbol), tf(in_timeframe) {}
   virtual bool Validate(CSignal* signal)
   {
      if (iTime(symbol,timeframe,0) == last_valid_signal) {
         return false;
      }
      return true;
   }
   virtual void OnValidSignal(CSignal* signal)
   {
      if (signal.signal != SIGNAL_NONE && signal.signal != SIGNAL_NO) {
         last_valid_signal = iTime(this.symbol,tf,0);
      }
   }
};