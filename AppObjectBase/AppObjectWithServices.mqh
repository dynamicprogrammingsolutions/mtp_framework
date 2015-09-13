//
#include "..\Loader.mqh"

class CAppObjectWithServices : public CAppObjectWithBaseServices
{
public:
   COrderManagerBase* ordermanager;
   
   CAppObjectWithServices()
   {
      CObject* service = app.GetService(srvOrderManager);
      if (service != NULL)
         ordermanager = service;
   }   
};