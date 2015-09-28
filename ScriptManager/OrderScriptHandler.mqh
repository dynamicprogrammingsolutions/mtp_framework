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
      return HandleCommand(o);
   }
   
   virtual bool HandleCommand(CObject* command)
   {
      CScript* script = command;
      if (script.id == GetId()) {
         Print("Script: ",script.id," ",script.sparam);
         if (script.sparam == ActionOpenBuy()) this.App().commandmanager.Send(COrderCommand::CommandOpenBuy);
         if (script.sparam == ActionOpenSell())  this.App().commandmanager.Send(COrderCommand::CommandOpenSell);
         if (script.sparam == ActionCloseBuy())  this.App().commandmanager.Send(COrderCommand::CommandCloseBuy);
         if (script.sparam == ActionCloseSell())  this.App().commandmanager.Send(COrderCommand::CommandCloseSell);
         if (script.sparam == ActionCloseAll())  this.App().commandmanager.Send(COrderCommand::CommandCloseAll);
         return true;
      }
      return false;
   }
   
   virtual void Initalize()
   {
      if (AppBase() != NULL) {
         CScriptManagerInterface* sm = this.App().GetService(srvScriptManager);
         sm.RegisterScript(GetId()); 

         this.App().commandmanager.Register(CScript::Command,GetPointer(this));
      }  
   }
};