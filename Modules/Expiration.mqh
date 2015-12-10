//

#ifdef EXPIRATION_DAYS

class CExpiration : public CServiceProvider
{
public:
   TraitAppAccess
   
   int expiration_days;
   
   CExpiration(int days)
   {
      expiration_days = days;
   }
   
   virtual void OnTick()
   {
      if (IsExpired()) {
         addcomment("EA Expired\n");
         if (this.App().ServiceIsRegistered(srvSignalManager)) application.DeregisterService(srvSignalManager);
         if (this.App().ServiceIsRegistered(srvScriptManager)) application.DeregisterService(srvScriptManager);
         ((COrderManager*)this.App().ordermanager).CloseAll(ORDERSELECT_ANY);
      } else {
         addcomment("This is a test version. EA will work until "+TimeToStr(GetExpirationTime()-1,TIME_DATE)+"\n");
      }
   }
   
   datetime GetExpirationTime()
   {
      return __DATE__+86400*expiration_days;
   }
   
   bool IsExpired()
   {
      return (TimeCurrent() > GetExpirationTime());
   }
};

#endif