//
#include "Loader.mqh"

#define SCRIPT_MANAGER_INTERFACE_H
class CScriptManagerInterface : public CServiceProvider
{
public:
   virtual void RegisterScript(int id)
   {
      
   }
   virtual void RunScript(int id, long lparam, double dparam, string sparam)
   {
      
   }
   virtual void HandleScript(int id, long lparam, double dparam, string sparam)
   {
     
   }
};