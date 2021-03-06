//
#include "..\Loader.mqh"
#include "..\Commands\Loader.mqh"

#include <Arrays\ArrayInt.mqh>

class CScriptManagerBase : public CScriptManagerInterface
{
   CArrayInt scriptids;
protected:
   COrderCommandDispatcher* ordercommanddispatcher;
   CScriptDispatcher* scriptdispatcher;
public:
   TraitAppAccess

   virtual int Type() const { return classScriptManagerBase; }

   virtual void Initalize() {
      scriptdispatcher = App().GetService(srvScriptDispatcher);
   }

   virtual void RegisterScript(int id)
   {
      if (!FindScript(id)) scriptids.Add(id);
   }
   bool FindScript(int id)
   {
      for (int i = 0; i < scriptids.Total(); i++) {
	      if (scriptids.At(i) == id) return true;
      }
      return false;
   }
   void CheckObjects()
   {
      for (int i = 0; i < scriptids.Total(); i++) {
         string objname = "eascript_"+(string)scriptids.At(i);
         if (ObjectFind(ChartID(),objname) >= 0) {
            long lparam = ObjectGetInteger(ChartID(),objname,OBJPROP_TIME);
            double dparam = ObjectGetDouble(ChartID(),objname,OBJPROP_PRICE);
            string sparam = ObjectGetString(ChartID(),objname,OBJPROP_TEXT);
            HandleScript(scriptids.At(i),lparam,dparam,sparam);
            ObjectDelete(ChartID(),objname);
         }
      }
   }
   virtual void RunScript(int id, long lparam, double dparam, string sparam)
   {
      //Print("Running Script: ",id," ",lparam," ",dparam," ",sparam);
      EventChartCustom(
         ChartID(),
         (ushort)id,
         lparam,
         dparam,
         sparam
      );
      string objname = "eascript_"+(string)id;
      ObjectCreate(ChartID(),objname,OBJ_ARROW,0,0,0);
      ObjectSetInteger(ChartID(),objname,OBJPROP_TIME,lparam);
      ObjectSetDouble(ChartID(),objname,OBJPROP_PRICE,dparam);
      ObjectSetString(ChartID(),objname,OBJPROP_TEXT,sparam);
   }
   virtual void HandleScript(int id, long lparam, double dparam, string sparam)
   {
      scriptdispatcher.Dispatch(CScript::Command,new CScript(id,lparam,dparam,sparam),true);
      //App().trigger.Trigger(classScript,CScript::Command,MakeAppObject(new CScript(id,lparam,dparam,sparam)));
      //TRIGGERCR(CScript::Command,new CScript(id,lparam,dparam,sparam));
   }
   virtual void OnTick()
   {
#ifdef __MQL4__     
      if (IsTesting() && IsVisualMode()) {
         CheckObjects();
      }
#endif
   }   
   virtual void OnChartEvent(int id, long lparam, double dparam, string sparam)
   {   
      if (id > CHARTEVENT_CUSTOM) {
	      if (FindScript(id-CHARTEVENT_CUSTOM)) HandleScript(id-CHARTEVENT_CUSTOM,lparam,dparam,sparam);
      }
   }
   
   
   
};