#include "..\Loader.mqh"

#include "..\Commands\Loader.mqh"

/*class COrderScriptHandler : public CServiceProvider
{
public:
    virtual int Type() const { return classOrderScriptHandler; }
   
   TraitAppAccess
  
   int GetId() { return 112; }
   string ActionOpenBuy() { return "openbuy"; }
   string ActionOpenSell() { return "opensell"; }
   string ActionCloseBuy() { return "closebuy"; }
   string ActionCloseSell() { return "closesell"; }
   string ActionCloseAll() { return "closeall"; }
   
   CALLBACK_VOID_P(BAppObject &p,
      CBFUNC_VOID_P(1,HandleCommand,p.get())
   )
   
   virtual bool HandleCommand(CObject* command)
   {
      CScript* script = command;
      if (script.id == GetId()) {
         Print("Script: ",script.id," ",script.sparam);
         if (script.sparam == ActionOpenBuy()) TRIGGER_VOID(classOrderCommand,commandOpenBuy);
         if (script.sparam == ActionOpenSell())  TRIGGER_VOID(classOrderCommand,commandOpenSell);
         if (script.sparam == ActionCloseBuy())  TRIGGER_VOID(classOrderCommand,commandCloseBuy);
         if (script.sparam == ActionCloseSell())  TRIGGER_VOID(classOrderCommand,commandCloseSell);
         if (script.sparam == ActionCloseAll())  TRIGGER_VOID(classOrderCommand,commandCloseAll);
         return true;
      }
      return false;
   }
   
   virtual void Initalize()
   {
      if (AppBase() != NULL) {
         CScriptManagerInterface* sm = this.App().GetService(srvScriptManager);
         sm.RegisterScript(GetId()); 

         LISTEN(classScript,CScript::Command,1);
      }  
   }
};*/

class COrderScriptHandler : public CServiceProvider
{
public:
    virtual int Type() const { return classOrderScriptHandler; }
   
   TraitAppAccess
  
   virtual void callback(const int id, BAppObject &obj)
   {
      if (id == 0) HandleCommand(obj.get());
   }
   
   virtual bool HandleCommand(CScript* script)
   {
      if (script.id == 112) {
         Print("Script: ",script.id," ",script.sparam);
         if (script.sparam == "gow4_openbuy") App().trigger.Trigger(classOrderCommand,commandOpenOrder,MakeAppObject(new COrderCommand(ORDER_TYPE_BUY)));
         if (script.sparam == "gow4_opensell")  App().trigger.Trigger(classOrderCommand,commandOpenOrder,MakeAppObject(new COrderCommand(ORDER_TYPE_SELL)));
         if (script.sparam == "gow4_closebuy")  App().trigger.Trigger(classOrderCommand,commandCloseAll,MakeAppObject(new COrderCommand(ORDERSELECT_LONG)));
         if (script.sparam == "gow4_closesell")  App().trigger.Trigger(classOrderCommand,commandCloseAll,MakeAppObject(new COrderCommand(ORDERSELECT_SHORT)));
         if (script.sparam == "gow4_closeall")  App().trigger.Trigger(classOrderCommand,commandCloseAll,MakeAppObject(new COrderCommand(ORDERSELECT_ANY)));
         return true;
      }
      return false;
   }
   
   virtual void Initalize()
   {
      if (AppBase() != NULL) {
         CScriptManagerInterface* sm = this.App().GetService(srvScriptManager);
         sm.RegisterScript(112); 

         LISTEN(classScript,CScript::Command,0);
      }  
   }
};