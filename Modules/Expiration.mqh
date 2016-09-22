//

#ifdef EXPIRATION_DAYS

class CExpiration : public CServiceProvider
{
public:
   TraitAppAccess
   
   int expiration_days;
   bool comment_enabled;
   
   CExpiration(int days, bool _comment_enabled = true)
   {
      expiration_days = days;
      comment_enabled = _comment_enabled;
   }
   
   virtual void OnTick()
   {
      if (IsExpired()) {
         if (comment_enabled) addcomment("EA Expired\n");
         if (this.App().ServiceIsRegistered(srvSignalManager)) application.DeregisterService(srvSignalManager);
         if (this.App().ServiceIsRegistered(srvScriptManager)) application.DeregisterService(srvScriptManager);
         if (this.App().ServiceIsRegistered(srvScriptManager)) application.DeregisterService(srvMain);
         this.App().orderrepository.CloseAll(ORDERSELECT_ANY);
      } else {
         if (comment_enabled) addcomment("This is a test version. EA will work until "+TimeToStr(GetExpirationTime()-1,TIME_DATE)+"\n");
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

#ifdef INDICATOR_EXPIRATION_DAYS

class CExpiration : public CServiceProvider
{
public:
   TraitAppAccess
   
   int expiration_days;
   bool comment_enabled;
   
   CExpiration(int days, bool _comment_enabled = true)
   {
      expiration_days = days;
      comment_enabled = _comment_enabled;
   }
   
   virtual void OnTick()
   {
      if (IsExpired()) {
         if (comment_enabled) addcomment("EA Expired\n");
         if (this.App().ServiceIsRegistered(srvMain)) application.DeregisterService(srvMain);
      } else {
         if (comment_enabled) addcomment("This is a test version. EA will work until "+TimeToStr(GetExpirationTime()-1,TIME_DATE)+"\n");
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