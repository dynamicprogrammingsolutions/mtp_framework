#include "..\Loader.mqh"

class CEntryMethodSignal : public CServiceProvider
{
public:
   virtual int Type() const { return classEntryMethodSignal; }

   TraitAppAccess
   
   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }

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
      if (valid) TRIGGER(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
      if (valid) TRIGGER(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
      if (valid) TRIGGER(COrderCommand::CommandCloseAll);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      if (valid) TRIGGER(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      if (valid) TRIGGER(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (BuySignalFilter(valid)) {
         TRIGGER(COrderCommand::CommandOpenBuy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (SellSignalFilter(valid)) {
         TRIGGER(COrderCommand::CommandOpenSell);
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
