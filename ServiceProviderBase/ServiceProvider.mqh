//
class CServiceProvider : public CAppObject
{
public:
   string name;
   ENUM_APPLICATION_SERVICE srv;
   
   virtual void InitalizeService() {}
   
   bool use_oninit;
   bool use_ontick;
   bool use_ondeinit;
   virtual void OnInit() {}
   virtual void OnTick() {}
   virtual void OnDeinit() {}
   
};