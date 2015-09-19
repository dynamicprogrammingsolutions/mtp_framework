
class CSignalManagerBase : public CServiceProvider
{
public:
   CSignal* mainsignal;
   CEntryMethodInterface* entrymethod;
   int bar;
   
   CSignalManagerBase()
   {
      use_ontick = true;
   }
   
   virtual void Initalize()
   {
      entrymethod = App().GetService(srvEntryMethod);
   }
   
   virtual void OnTick()
   {
      mainsignal.Run(bar);
      switch (mainsignal.closesignal) {
         case SIGNAL_BUY: entrymethod.OnCloseSellSignal(mainsignal.valid); break;
         case SIGNAL_SELL: entrymethod.OnCloseBuySignal(mainsignal.valid); break;
         case SIGNAL_BOTH: entrymethod.OnCloseAllSignal(mainsignal.valid); break;
      }
      switch (mainsignal.signal) {
         case SIGNAL_BUY: entrymethod.OnBuySignal(mainsignal.valid); break;
         case SIGNAL_SELL: entrymethod.OnSellSignal(mainsignal.valid); break;
         case SIGNAL_BOTH: entrymethod.OnBothSignal(mainsignal.valid); break;
      }
      mainsignal.OnTick();
   }
   
};