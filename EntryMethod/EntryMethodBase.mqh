class CEntryMethodBase : public CEntryMethodInterface
{
public:
   virtual int Type() const { return classEntryMethodBase; }

   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }
   
   virtual void OnCloseSellSignal()
   {
      App().Command(new CCloseSell());
   }
   
   virtual void OnCloseBuySignal()
   {
      App().Command(new CCloseBuy());
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      App().Command(new CCloseSell());
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      App().Command(new CCloseBuy());
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (valid && BuySignalFilter()) {
         App().Command(new COpenBuy());
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (valid && SellSignalFilter()) {
         App().Command(new COpenSell());
      }
   }
   
   virtual bool CloseOpposite()
   {
      return false;
   }
   
   virtual bool BuySignalFilter()
   {
      return true;
   }
   
   virtual bool SellSignalFilter()
   {
      return true;
   }

};