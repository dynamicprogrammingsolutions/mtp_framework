//
#include "Loader.mqh"

class CAppObjectWithServices : public CAppObjectWithBaseServices
{
public:
   COrderBaseBase* ordermanager;
   
   CAppObjectWithServices()
   {
      ordermanager = app.GetService(srvOrderManager);
   }   
};