#include "Signal.mqh"

class CSignalValidatorRule : public CAppObject
{
public:
   virtual bool Validate(CSignal* signal)
   {
      return true;
   }
   virtual void OnValidSignal(CSignal* signal)
   {
   
   }
};

class CSignalValidator : public CAppObject
{
public:
   CArrayObject<CSignalValidatorRule> rules;
   virtual bool Validate(CSignal* signal)
   {
      int i = 0;
      CSignalValidatorRule* rule;
      while(rules.ForEach(rule,i,true)) {
         if (!rule.Validate(signal)) {
            return false;
         }
      }
      return true;
   }
   virtual void OnValidSignal(CSignal* signal)
   {
      int i = 0;
      CSignalValidatorRule* rule;
      while(rules.ForEach(rule,i,true)) {
         rule.OnValidSignal(signal);
      }
   }
};
