#include "..\Loader.mqh"

class COrderCommandHandlerBase : public CServiceProvider
{
public:
   TraitAppAccess
   TraitGetType(classOrderCommandHandler)

protected:
   shared_ptr<CStopsCalcInterface> sl;
   shared_ptr<CStopsCalcInterface> tp;
   shared_ptr<CMoneyManagementInterface> mm;
   shared_ptr<CStopsCalcInterface> entry;   
   ENUM_ORDER_TYPE buy_cmd;
   ENUM_ORDER_TYPE sell_cmd;

public:
   COrderCommandHandlerBase() {
      buy_cmd = ORDER_TYPE_BUY;
      sell_cmd = ORDER_TYPE_SELL;
      entry.reset(NULL);
   }
   
   virtual void Initalize() {
      COrderCommandDispatcher* ordercommanddispatcher = App().GetService(srvOrderCommandDispatcher);
      ordercommanddispatcher.AddObserver(GetPointer(this));      
   }

   virtual void EventCallback(const int event_id, CObject* event) {
      switch(event_id) {
         case commandOpenOrder: CommandOpenOrder(event); break;
         case commandCloseAll:
            if (event == NULL) CommandCloseAll(ORDERSELECT_ANY);
            else CommandCloseAll(event);
            break;
         case commandCloseLast: CommandCloseLast(event); break;
         case commandOpenBuy: CommandOpenBuy(); break;
         case commandOpenSell: CommandOpenSell(); break;
         case commandCloseBuy: CommandCloseAll(ORDERSELECT_LONG); break;
         case commandCloseSell: CommandCloseAll(ORDERSELECT_SHORT); break;
      }
   }
   
   virtual void OnInit()
   {

   }

   virtual bool CommandCloseAll(COrderCommand *obj)
   {
      App().orderrepository.CloseAll(COrderCommand::GetSelect(obj,ORDERSELECT_ANY),STATESELECT_ONGOING);
      return true;
   }
   
   virtual bool CommandCloseAll(ENUM_ORDERSELECT orderselect, ENUM_STATESELECT stateselect = STATESELECT_ONGOING)
   {
      App().orderrepository.CloseAll(orderselect,stateselect);
      return true;
   }
   
   virtual bool CommandCloseLast(COrderCommand *command)
   {
      COrderInterface* order;
      while(App().orderrepository.Orders().ForEachBackward(order)) {
         if (state_ongoing(order.State())) order.Close();
      }
      return true;
   }
   virtual void BeforeOrder(ENUM_ORDER_TYPE cmd) {
      return;
   }
   virtual bool CommandOpenOrder(COrderCommand *command)
   {
      this.BeforeOrder(command.cmd);
      PStopsCalc thisentry = entry;
      PStopsCalc thissl = sl;
      PStopsCalc thistp = tp;
      PMoneyManagement thismm = mm;
      
      ENUM_ORDER_TYPE cmd = command.cmd;
      if (isset(command.entry)) thisentry.reset(command.entry);
      if (isset(command.sl)) thissl.reset(command.sl);
      if (isset(command.tp)) thistp.reset(command.tp);
      if (isset(command.mm)) thismm.reset(command.mm);
      
      COrderInterface* order = App().ordermanager.NewOrder(symbol,cmd,thismm,thisentry,thissl,thistp);
      this._callback_result = order;
      return true;
   }
   
   virtual void CommandOpenBuy()
   {
      this.BeforeOrder(ORDER_TYPE_BUY);
      COrderInterface* order = App().ordermanager.NewOrder(symbol,buy_cmd,mm,entry,sl,tp);
      this._callback_result = order;   
   }

   virtual void CommandOpenSell()
   {
      this.BeforeOrder(ORDER_TYPE_SELL);
      COrderInterface* order = App().ordermanager.NewOrder(symbol,sell_cmd,mm,entry,sl,tp);
      this._callback_result = order;
   }
   
};