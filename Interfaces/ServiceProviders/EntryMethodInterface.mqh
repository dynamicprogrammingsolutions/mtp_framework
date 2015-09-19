
class CEntryMethodInterface : public CServiceProvider
{
public:

   virtual void OnCloseSellSignal(bool valid)
   {
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
   }
   
   virtual void OnBuySignal(bool valid)
   {
   }
   
   virtual void OnSellSignal(bool valid)
   {   
   }

   virtual void OnBothSignal(bool valid)
   {   
   }

};