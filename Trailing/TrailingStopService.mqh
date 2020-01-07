

class CTrailingStopServiceBase : public CServiceProvider
{
public:
   TraitGetType(classTrailingStopService)

protected:
   shared_ptr<CTrailing> trailing;
   shared_ptr<CTrailing> lockin;
   
   int trailingstop_activate;
   int trailingstop;
   int trailingstop_step;
   int breakevenat;
   int breakeven_profit;
   
public:
   virtual void OnInit() {
      trailing.reset(new CTrailingSLTicks(convertfract(trailingstop_activate),0,convertfract(trailingstop),convertfract(trailingstop_step),false));
      lockin.reset(new CTrailingSLLockin(convertfract(breakevenat),convertfract(breakeven_profit)));
   }

   virtual void OnTick()
   {
      if (isset(app.testmanager) && app.testmanager.IsRunning()) return;
      
      while (App().orderrepository.GetOrders())
      {
         trailing.get().OnOrder(App().orderrepository.Selected());
         lockin.get().OnOrder(App().orderrepository.Selected());
      }
  }
};