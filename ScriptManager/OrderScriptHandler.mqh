#include "..\Loader.mqh"

class COrderScriptHandler : public CServiceProvider
{
public:
   int GetId() { return 112; }
   string ActionOpenBuy() { return "openbuy"; }
   string ActionOpenSell() { return "opensell"; }
   string ActionCloseBuy() { return "closebuy"; }
   string ActionCloseSell() { return "closesell"; }
   string ActionCloseAll() { return "closeall"; }
   
   virtual void HandleCommand(CObject* command)
   {
      CScript* script = command;
      if (script.id == GetId()) {
         if (script.sparam == ActionOpenBuy()) this.App().Command(new COpenBuy());
         if (script.sparam == ActionOpenSell()) this.App().Command(new COpenSell());
         if (script.sparam == ActionCloseBuy()) this.App().Command(new CCloseBuy());
         if (script.sparam == ActionCloseSell()) this.App().Command(new CCloseSell());
         if (script.sparam == ActionCloseAll()) this.App().Command(new CCloseAll());
      }
   }
   
   virtual void Initalize()
   {
      if (AppBase() != NULL) {
         CScriptManagerInterface* sm = this.App().GetService(srvScriptManager);
         sm.RegisterScript(GetId()); 
      }  
   }
};