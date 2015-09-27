#include "..\Loader.mqh"

class CEntryMethodBase : public CEntryMethodInterface
{
public:
   virtual int Type() const { return classEntryMethodBase; }

   TraitAppAccess

   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }
   
   virtual void OnCloseSellSignal(bool valid)
   {
      if (valid) App().commandmanager.Send(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
      if (valid) App().commandmanager.Send(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
      if (valid) App().commandmanager.Send(COrderCommand::CommandCloseAll);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      if (valid) App().commandmanager.Send(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      if (valid) App().commandmanager.Send(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (BuySignalFilter(valid)) {
         App().commandmanager.Send(COrderCommand::CommandOpenBuy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (SellSignalFilter(valid)) {
         App().commandmanager.Send(COrderCommand::CommandOpenSell);
      }
   }
   
   virtual bool CloseOpposite()
   {
      return false;
   }
   
   virtual bool BuySignalFilter(bool valid)
   {
      return valid;
   }
   
   virtual bool SellSignalFilter(bool valid)
   {
      return valid;
   }

};