//

class CChartComment : public CServiceProvider
{
public:
   TraitAppAccess
   
   virtual void OnTick()
   {
      if (comments_enabled) {
         writecomment();
         if (printcomment) printcomment();
         delcomment();
      } else {
         delcomment();
      }
   }
   
   virtual void OnInit()
   {
      if (IsTesting() && !IsVisualMode() && !printcomment) {    
         comments_enabled = false;
      }    
   }
};