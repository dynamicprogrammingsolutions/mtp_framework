#include "..\Loader.mqh"

class CEntryMethodSignal : public CServiceProvider
{
public:
   virtual int Type() const { return classEntryMethodSignal; }

   TraitAppAccess
   
   CSignal* mainsignal;
   int bar;

   virtual void OnTick()
   {
      mainsignal.Run(bar);
      
      switch (mainsignal.closesignal) {
         case SIGNAL_BUY: OnCloseSellSignal(mainsignal.closesignal_valid); break;
         case SIGNAL_SELL: OnCloseBuySignal(mainsignal.closesignal_valid); break;
         case SIGNAL_BOTH: OnCloseAllSignal(mainsignal.closesignal_valid); break;
      }
      switch (mainsignal.signal) {
         case SIGNAL_BUY: OnBuySignal(mainsignal.valid); break;
         case SIGNAL_SELL: OnSellSignal(mainsignal.valid); break;
         case SIGNAL_BOTH: OnBothSignal(mainsignal.valid); break;
      }
      
      mainsignal.OnTick();
   }
   
   virtual void OnCloseSellSignal(bool valid)
   {
      if (valid) TRIGGER_VOID(classOrderCommand,commandCloseSell);
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
      if (valid) TRIGGER_VOID(classOrderCommand,commandCloseBuy);
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
      if (valid) TRIGGER_VOID(classOrderCommand,commandCloseAll);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      if (valid) TRIGGER_VOID(classOrderCommand,commandCloseSell);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      if (valid) TRIGGER_VOID(classOrderCommand,commandCloseBuy);
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (BuySignalFilter(valid)) {
         TRIGGER_VOID(classOrderCommand,commandOpenBuy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (SellSignalFilter(valid)) {
         TRIGGER_VOID(classOrderCommand,commandOpenSell);
      }
   }
   virtual void OnBothSignal(bool valid)
   {
      
   }
   
   virtual bool CloseOpposite()
   {
      return false;
   }
   
   virtual bool BuySignalFilter(bool valid)
   {
      return valid;
   }
   
   virtual bool SellSignalFilter(bool valid)
   {
      return valid;
   }

};
