#include "..\Loader.mqh"

class COrderScriptHandler : public CServiceProvider
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
   
   bool callback(const int i, CObject*& o)
   {
      if (i == 0) return HandleCommand(o);
      return false;
   }
   
   virtual bool HandleCommand(CObject* command)
   {
      CScript* script = command;
      if (script.id == GetId()) {
         Print("Script: ",script.id," ",script.sparam);
         if (script.sparam == ActionOpenBuy()) TRIGGER(COrderCommand::CommandOpenBuy);
         if (script.sparam == ActionOpenSell())  TRIGGER(COrderCommand::CommandOpenSell);
         if (script.sparam == ActionCloseBuy())  TRIGGER(COrderCommand::CommandCloseBuy);
         if (script.sparam == ActionCloseSell())  TRIGGER(COrderCommand::CommandCloseSell);
         if (script.sparam == ActionCloseAll())  TRIGGER(COrderCommand::CommandCloseAll);
         return true;
      }
      return false;
   }
   
   virtual void Initalize()
   {
      if (AppBase() != NULL) {
         CScriptManagerInterface* sm = this.App().GetService(srvScriptManager);
         sm.RegisterScript(GetId()); 

         LISTEN(CScript::Command,0);
      }  
   }
};