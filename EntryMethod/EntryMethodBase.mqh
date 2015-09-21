class    CEntryMethodBase : public CEntryMethodInterface
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
      ordermanager.CloseAll(ORDERSELECT_SHORT,STATESELECT_FILLED);
   }
   
   virtual void OnCloseBuySignal()
   {
      ordermanager.CloseAll(ORDERSELECT_LONG,STATESELECT_FILLED);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      ordermanager.CloseAll(ORDERSELECT_SHORT,STATESELECT_FILLED);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      ordermanager.CloseAll(ORDERSELECT_LONG,STATESELECT_FILLED);
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