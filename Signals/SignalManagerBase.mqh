#include "..\Loader.mqh"
#include "Signal.mqh"

class CSignalManagerBase : public CServiceProvider
{
public:
   virtual int Type() const { return classSignalManagerBase; }

   TraitAppAccess
   TraitHasEvents

   static int Signal;

   void GetEvents(int& events[])
   {
      ArrayResize(events,1);
      events[0] = EventId(Signal);
   }

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
      
      if (mainsignal.signal != mainsignal.lastsignal || mainsignal.closesignal != mainsignal.lastclosesignal) {
         App().eventmanager.Send(Signal,mainsignal);
      }
      
      switch (mainsignal.closesignal) {
         case SIGNAL_BUY: entrymethod.OnCloseSellSignal(mainsignal.closesignal_valid); break;
         case SIGNAL_SELL: entrymethod.OnCloseBuySignal(mainsignal.closesignal_valid); break;
         case SIGNAL_BOTH: entrymethod.OnCloseAllSignal(mainsignal.closesignal_valid); break;
      }
      switch (mainsignal.signal) {
         case SIGNAL_BUY: entrymethod.OnBuySignal(mainsignal.valid); break;
         case SIGNAL_SELL: entrymethod.OnSellSignal(mainsignal.valid); break;
         case SIGNAL_BOTH: entrymethod.OnBothSignal(mainsignal.valid); break;
      }
      mainsignal.OnTick();
   }
   
};

int CSignalManagerBase::Signal = 0;