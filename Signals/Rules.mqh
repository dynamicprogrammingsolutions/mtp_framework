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
   ENUM_SIGNAL currentsignal;
   ENUM_SIGNAL lastsignal;
   CSignalValidatorSignalChange(): currentsignal(SIGNAL_NONE), lastsignal(SIGNAL_NONE) {}
   virtual bool Validate(CSignal* signal)
   {
      if (lastsignal == SIGNAL_NONE || currentsignal == lastsignal) {
         return false;
      }
      return true;
   }
   virtual void OnSignal(CSignal* signal)
   {
      lastsignal = currentsignal;
      currentsignal = signal.signal;
   }
};

class CSignalValidatorSignalChangeOfMainSignal : public CSignalValidatorRule
{
   shared_ptr<CSignal> mainsignal;

public:
   CSignalValidatorSignalChangeOfMainSignal(CSignal* _mainsignal) {
      this.mainsignal.reset(_mainsignal);
   }
   ENUM_SIGNAL lastsignal;
   virtual bool Validate(CSignal* _signal)
   {
      CSignal* signal = mainsignal.get();
      if (signal == NULL) return false;
   
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
   ENUM_SIGNAL currentsignal;
   ENUM_SIGNAL lastsignal;
   CSignalValidatorSignalChangeClose(): currentsignal(SIGNAL_NONE), lastsignal(SIGNAL_NONE) {}
   virtual bool Validate(CSignal* signal)
   {
      if (lastsignal == SIGNAL_NONE || currentsignal == lastsignal) {
         return false;
      }
      return true;
   }
   virtual void OnSignal(CSignal* signal)
   {
      lastsignal = currentsignal;
      currentsignal = signal.closesignal;
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
      if (iTime(symbol,tf,0) == last_valid_signal) {
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