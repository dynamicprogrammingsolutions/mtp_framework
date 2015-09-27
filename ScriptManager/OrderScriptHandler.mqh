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
   
   void callback(CObject* o)
   {
      HandleCommand(o);
   }
   
   virtual void HandleCommand(CObject* command)
   {
      CScript* script = command;
      Print("Script: ",script.id," ",script.sparam);
      if (script.id == GetId()) {
         if (script.sparam == ActionOpenBuy()) this.App().commandmanager.Send(COrderCommand::Command,(int)commandOpenBuy);
         if (script.sparam == ActionOpenSell())  this.App().commandmanager.Send(COrderCommand::Command,(int)commandOpenSell);
         if (script.sparam == ActionCloseBuy())  this.App().commandmanager.Send(COrderCommand::Command,(int)commandCloseBuy);
         if (script.sparam == ActionCloseSell())  this.App().commandmanager.Send(COrderCommand::Command,(int)commandCloseSell);
         if (script.sparam == ActionCloseAll())  this.App().commandmanager.Send(COrderCommand::Command,(int)commandCloseAll);
      }
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