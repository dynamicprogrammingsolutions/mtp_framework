//
#include "Loader.mqh"

#define SCRIPT_MANAGER_INTERFACE_H
class CScriptManagerInterface : public CServiceProvider
{
public:
   virtual void RegisterScript(int id)
   {
      AbstractFunctionWarning(__FUNCTION__); 
   }
   virtual void RunScript(int id, long lparam, double dparam, string sparam)
   {
      AbstractFunctionWarning(__FUNCTION__); 
   }
   virtual void HandleScript(int id, long lparam, double dparam, string sparam)
   {
      AbstractFunctionWarning(__FUNCTION__); 
   }
};