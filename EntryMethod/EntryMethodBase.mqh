#include "..\Loader.mqh"

class CEntryMethodBase : public CEntryMethodInterface
{
public:
   virtual int Type() const { return classEntryMethodBase; }

   TraitAppAccess
   TraitSendCommands

   COrderManager* ordermanager;
   virtual void Initalize()
   {
      this.ordermanager = this.App().GetService(srvOrderManager);
   }
   
   virtual void OnCloseSellSignal(bool valid)
   {
      if (valid) CommandSend(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseBuySignal(bool valid)
   {
      if (valid) CommandSend(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnCloseAllSignal(bool valid)
   {
      if (valid) CommandSend(COrderCommand::CommandCloseAll);
   }
   
   virtual void OnCloseBuyOpposite(bool valid)
   {
      if (valid) CommandSend(COrderCommand::CommandCloseSell);
   }
   
   virtual void OnCloseSellOpposite(bool valid)
   {
      if (valid) CommandSend(COrderCommand::CommandCloseBuy);
   }
   
   virtual void OnBuySignal(bool valid)
   {
      if (CloseOpposite()) OnCloseBuyOpposite(valid);
      if (BuySignalFilter(valid)) {
         CommandSend(COrderCommand::CommandOpenBuy);
      }
   }
   virtual void OnSellSignal(bool valid)
   {   
      if (CloseOpposite()) OnCloseSellOpposite(valid);
      if (SellSignalFilter(valid)) {
         CommandSend(COrderCommand::CommandOpenSell);
      }
   }
   virtual void OnBothSignal(bool valid)
   {
      
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