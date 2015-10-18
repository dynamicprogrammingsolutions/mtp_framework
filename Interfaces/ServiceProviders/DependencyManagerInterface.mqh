#include "..\..\Loader.mqh"

class CDependencyManagerInterface : public CServiceProviderArrayObj
{

public:

   virtual void SetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency, CAppObject* callback)
   {
      
   }
   
   virtual CAppObject* GetDependency(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      return NULL;
   }
   
   virtual bool DependencyIsSet(ENUM_CLASS_NAMES caller, ENUM_CLASS_NAMES dependency)
   {
      return false;
   }
   
};