#include "..\Loader.mqh"

class CEntryMethodSignal : public CServiceProvider
{
protected:
   COrderCommandDispatcher* ordercommanddispatcher;
   bool close_opposite_order;
   int maxorders;
   int maxspread;
public:
   bool enableopen;
   bool long_enabled;
   bool short_enabled;

   TraitGetType(classEntryMethod)
   TraitAppAccess
   TraitLoadSymbolFunction
   
   CEntryMethodSignal() {
      close_opposite_order = false;
      long_enabled = true;
      short_enabled = true;
      maxorders = 1;
      maxspread = -1;
   }
   
   virtual void Initalize() {
      ((CSignalServiceProviderBase*)App().GetService(srvSignalServiceProvider)).AddObserver(GetPointer(this));
      this.ordercommanddispatcher = App().GetService(srvOrderCommandDispatcher);
   }

   virtual void EventCallback(const int event_id, CObject* event) {
      if (event_id == CSignalServiceProviderBase::OpenSignal) OpenSignal(event);
      if (event_id == CSignalServiceProviderBase::CloseSignal) CloseSignal(event);
   }
   
   void OpenSignal(CSignal* signal)
   {
      switch (signal.signal) {
         case SIGNAL_BUY:
            if (close_opposite_order) ordercommanddispatcher.Dispatch(commandCloseSell);
            if (BuySignalFilter()) {
              ordercommanddispatcher.Dispatch(commandOpenBuy);
            }
         break;
         case SIGNAL_SELL:
            if (close_opposite_order) ordercommanddispatcher.Dispatch(commandCloseBuy);
            if (SellSignalFilter()) {
               ordercommanddispatcher.Dispatch(commandOpenSell);
            }
         break;
         case SIGNAL_BOTH: break;
      }
   }
   
   void CloseSignal(CSignal* signal)
   {
      switch (signal.closesignal) {
         case SIGNAL_BUY: ordercommanddispatcher.Dispatch(commandCloseSell); break;
         case SIGNAL_SELL: ordercommanddispatcher.Dispatch(commandCloseBuy); break;
         case SIGNAL_BOTH: ordercommanddispatcher.Dispatch(commandCloseAll); break;
      }
   }

   virtual void OnTick()
   {
      if (app.testmanager.IsRunning()) return;
      enableopen = true;     
  }
   
   virtual bool BuySignalFilter()
   {
      if (!enableopen) {
         return false;
      }
      if (!long_enabled) {
         return false;
      }
      if (maxspread >= 0) {
         loadsymbol(symbol);
         if (_symbol.SpreadInTicks() > maxspread) {
            return false;
         }
      }
      int cnt = App().orderrepository.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED);
      if (cnt >= maxorders) {
         return false;
      }
      return true;
   }
   
   virtual bool SellSignalFilter()
   {
      if (!enableopen) return false;
      if (!short_enabled) return false;
      if (maxspread >= 0) {
         loadsymbol(symbol);
         if (_symbol.SpreadInTicks() > maxspread) {
            return false;
         }
      }
      if (App().orderrepository.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED) >= maxorders) {
         return false;
      }
      return true;
   }
};
