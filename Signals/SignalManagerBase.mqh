#include "Signal.mqh"

class CSignalManagerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classSignalManagerBase; }

   TraitAppAccess

   CSignal* mainsignal;
   CEntryMethodInterface* entrymethod;
   int bar;
   
   virtual void Initalize()
   {
      entrymethod = App().GetService(srvEntryMethod);
   }
   
   virtual void OnTick()
   {
      mainsignal.Run(bar);
      switch (mainsignal.closesignal) {
         case SIGNAL_BUY: entrymethod.OnCloseSellSignal(true); break;
         case SIGNAL_SELL: entrymethod.OnCloseBuySignal(true); break;
         case SIGNAL_BOTH: entrymethod.OnCloseAllSignal(true); break;
      }
      switch (mainsignal.signal) {
         case SIGNAL_BUY: entrymethod.OnBuySignal(mainsignal.valid); break;
         case SIGNAL_SELL: entrymethod.OnSellSignal(mainsignal.valid); break;
         case SIGNAL_BOTH: entrymethod.OnBothSignal(mainsignal.valid); break;
      }
      mainsignal.OnTick();
   }
   
};